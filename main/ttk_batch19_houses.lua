local G = GLOBAL
for _, file in ipairs({
    "ttk_zzxhcx", "ttk_lycx", "ttk_spiderden", "ttk_pog", "ttk_stool",
    "ttk_bearger", "ttk_dragonfly", "ttk_spider", "ttk_batch19_houseitems", "ttk_tianji_byj",
}) do
    table.insert(PrefabFiles, file)
end

table.insert(Assets, G.Asset("SOUNDPACKAGE", "sound/ttk_pog_sound.fev"))
table.insert(Assets, G.Asset("SOUND", "sound/ttk_pog_sound.fsb"))
for _, name in ipairs({"tianjiwu_skins_byj", "floortjw_byj", "walltjw_byj",
    "wall_decals_tjw_byj", "door_exittjw_byj", "door_exittjw_heng_byj"}) do
    table.insert(Assets, G.Asset("ANIM", "anim/ttk_" .. name .. ".zip"))
end

local byj_builds = {
    ttk_tianji_floor = "xd_floortjw_byj",
    ttk_tianji_wallpaper = "xd_walltjw_byj",
    ttk_tianji_doorart = "xd_door_exittjw_heng_byj",
    ttk_tianji_exit = "xd_door_exittjw_byj",
    ttk_tianji_decals = "xd_wall_decals_tjw_byj",
}
local base_builds = {
    ttk_tianji_floor = "xd_floortjw", ttk_tianji_wallpaper = "xd_walltjw",
    ttk_tianji_doorart = "xd_door_exittjw_heng", ttk_tianji_exit = "xd_door_exittjw",
    ttk_tianji_decals = "xd_wall_decals_tjw",
}
local function IsByjHouse(house)
    local skinbuild = house.GetSkinBuild ~= nil and house:GetSkinBuild() or nil
    return skinbuild == "xd_tianjiwu_skins_byj"
        or (house.AnimState ~= nil and house.AnimState:GetBuild() == "xd_tianjiwu_skins_byj")
end
local BYJ_TIMER = "ttk_tianji_byj_fx"
local function ScheduleByj(inst)
    if inst.components.timer == nil then inst:AddComponent("timer") end
    if not inst.components.timer:TimerExists(BYJ_TIMER) then
        inst.components.timer:StartTimer(BYJ_TIMER, math.random(110, 120))
    end
end
local function RemoveOwnPets(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    for _, pet in ipairs(G.TheSim:FindEntities(x, y, z, 8, {"ttk_tianjiwu_baihufx"}, {"INLIMBO"})) do
        if pet._ttk_home == inst then pet:Remove() end
    end
end
local function RefreshTianjiDecor(inst)
    if not G.TheWorld.ismastersim then return end
    local byj = IsByjHouse(inst)
    local manager = G.TheWorld.components.ttk_tianjirooms
    local room = manager ~= nil and manager.rooms[inst._ttk_owner] or nil
    if room ~= nil then
        local room_byj = byj
        if not room_byj then
            for _, house in pairs(G.Ents) do
                if house.prefab == "ttk_tianjiwu" and house._ttk_owner == inst._ttk_owner
                    and IsByjHouse(house) then
                    room_byj = true
                    break
                end
            end
        end
        for _, piece in ipairs(G.TheSim:FindEntities(room.x, 0, room.z, 22, nil, {"INLIMBO"})) do
            local build = (room_byj and byj_builds or base_builds)[piece.prefab]
            if build ~= nil and piece.AnimState ~= nil then piece.AnimState:SetBuild(build) end
        end
    end
    if byj then
        ScheduleByj(inst)
    else
        if inst.components.timer ~= nil then inst.components.timer:StopTimer(BYJ_TIMER) end
        RemoveOwnPets(inst)
    end
end
AddPrefabPostInit("ttk_tianjiwu", function(inst)
    inst.TTKRefreshDecor = RefreshTianjiDecor
    if G.TheWorld.ismastersim then
        if inst.components.timer == nil then inst:AddComponent("timer") end
        inst:ListenForEvent("timerdone", function(house, data)
            if data.name ~= BYJ_TIMER or not IsByjHouse(house) then return end
            local x, y, z = house.Transform:GetWorldPosition()
            for _, nearby in ipairs(G.TheSim:FindEntities(x, y, z, 20, {"ttk_tianji_door"}, {"INLIMBO"})) do
                if nearby.prefab == "ttk_tianjiwu" and IsByjHouse(nearby) then
                    nearby.components.timer:StopTimer(BYJ_TIMER)
                    ScheduleByj(nearby)
                end
            end
            if house:IsAsleep() then return end
            local angle, radius = math.random() * G.TWOPI, math.random(3, 5)
            local pet = G.SpawnPrefab("ttk_tianjiwu_baihufx")
            if pet ~= nil then
                pet._ttk_home = house
                pet.Transform:SetPosition(x + math.cos(angle) * radius, y, z + math.sin(angle) * radius)
            end
        end)
        inst:DoTaskInTime(0, RefreshTianjiDecor)
        inst:DoPeriodicTask(5, RefreshTianjiDecor, 5)
    end
end)
AddPrefabPostInit("ttk_tianji_juanzhou", function(inst)
    if not G.TheWorld.ismastersim then return end
    local old_save, old_load = inst.OnSave, inst.OnLoad
    inst.OnSave = function(scroll, data)
        if old_save ~= nil then old_save(scroll, data) end
        data._ttk_preserved_skin = scroll._ttk_preserved_skin
    end
    inst.OnLoad = function(scroll, data)
        if old_load ~= nil then old_load(scroll, data) end
        scroll._ttk_preserved_skin = data ~= nil and data._ttk_preserved_skin or nil
    end
    inst:DoTaskInTime(0, function(scroll)
        local deployable = scroll.components.deployable
        if deployable == nil or deployable._ttk_byj_wrapped then return end
        deployable._ttk_byj_wrapped = true
        local old_deploy = deployable.ondeploy
        deployable.ondeploy = function(item, point, deployer, ...)
            local skin = item._ttk_preserved_skin
            local owner = item._ttk_owner or (deployer ~= nil and deployer.userid or nil)
            local result = old_deploy(item, point, deployer, ...)
            if result and skin ~= nil then
                for _, house in ipairs(G.TheSim:FindEntities(point.x, 0, point.z, 4, {"structure"}, {"INLIMBO"})) do
                    if house.prefab == "ttk_tianjiwu" and house._ttk_owner == owner then
                        G.TheSim:ReskinEntity(house.GUID, house.skinname, skin, nil,
                            deployer ~= nil and deployer.userid or owner)
                        house:DoTaskInTime(0, RefreshTianjiDecor)
                        break
                    end
                end
            end
            return result
        end
    end)
end)
AddPrefabPostInit("ttk_tianji_room", function(inst)
    if G.TheWorld.ismastersim then
        inst:DoTaskInTime(1, function(room)
            local manager = G.TheWorld.components.ttk_tianjirooms
            if manager == nil then return end
            local x, _, z = room.Transform:GetWorldPosition()
            for owner, pos in pairs(manager.rooms) do
                if math.abs(pos.x - x) < 1 and math.abs(pos.z - z) < 1 then
                    for _, house in pairs(G.Ents) do
                        if house.prefab == "ttk_tianjiwu" and house._ttk_owner == owner then
                            RefreshTianjiDecor(house)
                            return
                        end
                    end
                end
            end
        end)
    end
end)

G.STRINGS.ACTIONS.ACTIVATE.TTK_HARVEST_HOUSE = "Thu hoạch"
G.STRINGS.CHARACTERS.GENERIC.ACTIONFAIL.ACTIVATE = G.STRINGS.CHARACTERS.GENERIC.ACTIONFAIL.ACTIVATE or {}
G.STRINGS.CHARACTERS.GENERIC.ACTIONFAIL.ACTIVATE.TTK_EMPTY_HOUSE = "Chưa có gì để thu hoạch."

local definitions = {
    {"ttk_zzxhcx", "Sào Huyệt Gấu Lưng Thiết Giáp", "Ban ngày sinh Gấu Lưng Thiết Giáp; đủ đàn 10 ngày tạo 2 Quang Hoa Thuần Túy.",
        {{"purebrilliance",4},{"bluegem",10},{"cutstone",10},{"ttk_lingshi2",1}}, "SCIENCE_ONE", 2},
    {"ttk_lycx", "Sào Huyệt Long Đằng", "Ban ngày sinh Long Đằng; đủ đàn 10 ngày tạo vảy và đá quý.",
        {{"lavae_egg",1},{"orangegem",3},{"yellowgem",5},{"ttk_lingshi2",1}}, "SCIENCE_ONE", 2},
    {"ttk_spiderden", "Sào Huyệt Ma Thù", "Sinh tối đa 6 Ma Thù và gọi chúng bảo vệ tổ khi bị đánh.",
        {{"ttk_spider_leg",1},{"silk",12},{"rocks",6}}, "SCIENCE_ONE", 2},
    {"ttk_pog_house", "Thanh Khâu Phường", "Cho Linh Hồ 10 Thịt lớn sống hoặc 5 món nấu nhóm thịt để thuê thu hoạch trong 2.400 giây.",
        {{"ttk_pog_tail",3},{"cutstone",3},{"boards",4}}, "SCIENCE_ONE", 2},
    {"ttk_stool", "Thừa Vận Tọa", "Mỗi 10 giây hồi 5 máu, 2 tinh thần và 2 no cho người đang ngồi.",
        {{"redgem",15},{"green_cap",3},{"ttk_npxsz",1},{"ttk_lingshi3",1}}, "SCIENCE_ONE", 1.5},
}

for _, def in ipairs(definitions) do
    local id, key = def[1], string.upper(def[1])
    G.STRINGS.NAMES[key] = def[2]
    G.STRINGS.RECIPE_DESC[key] = def[3]
    G.STRINGS.CHARACTERS.GENERIC.DESCRIBE[key] = def[3]
    local ingredients = {}
    for _, ingredient in ipairs(def[4]) do
        table.insert(ingredients, G.Ingredient(ingredient[1], ingredient[2]))
    end
    local atlas = "images/inventoryimages/" .. id .. ".xml"
    local options = {atlas = atlas, image = id .. ".tex", min_spacing = def[6]}
    options.placer = id .. "_placer"
    AddRecipe2(id, ingredients, G.TECH[def[5]], options, {"STRUCTURES"})
    RegisterInventoryItemAtlas(atlas, id .. ".tex")
end

local item_names = {
    ttk_pog_tail = "Đuôi Linh Hồ", ttk_spider_leg = "Tà Sát Bộ Túc", ttk_npxsz = "Niết Bàn Huyết Tủy Trúc",
    ttk_pog = "Linh Hồ",
    ttk_bearger = "Gấu Lưng Thiết Giáp", ttk_dragonfly = "Long Đằng", ttk_spider = "Ma Thù",
}
for id, name in pairs(item_names) do
    G.STRINGS.NAMES[string.upper(id)] = name
end
for _, id in ipairs({"ttk_pog_tail", "ttk_spider_leg", "ttk_npxsz"}) do
    RegisterInventoryItemAtlas("images/inventoryimages/" .. id .. ".xml", id .. ".tex")
end
for _, id in ipairs({"ttk_zzxhcx", "ttk_lycx", "ttk_spiderden", "ttk_pog_house"}) do
    AddMinimapAtlas("images/map_icons/" .. id .. ".xml")
end

-- The source obtains these three ingredients from excluded bosses/chains. These bridge recipes keep this batch standalone.
local bridge = {
    {"ttk_pog_tail", {{"monstermeat",8},{"nightmarefuel",2}}},
    {"ttk_spider_leg", {{"monstermeat",4},{"silk",6}}},
    {"ttk_npxsz", {{"shroom_skin",2},{"livinglog",4},{"greengem",1}}},
}
for _, def in ipairs(bridge) do
    local ingredients = {}
    for _, ingredient in ipairs(def[2]) do
        table.insert(ingredients, G.Ingredient(ingredient[1], ingredient[2]))
    end
    AddRecipe2(def[1], ingredients, G.TECH.SCIENCE_TWO,
        {atlas = "images/inventoryimages/" .. def[1] .. ".xml", image = def[1] .. ".tex"}, {"REFINE"})
end
