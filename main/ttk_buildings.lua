local G = GLOBAL
for _, name in ipairs({"pflnw", "ftys", "klxw", "beefalo", "lightninggoat", "koalefant", "gjx", "dbg", "dc",
    "lbx", "lgzbh", "mg", "hyf_fx"}) do
    table.insert(PrefabFiles, "ttk_" .. name)
end

local params = G.require("containers").params
for _, name in ipairs({"ttk_gjx", "ttk_dbg"}) do
    params[name] = {
        widget = {slotpos = {}, animbank = "ui_chest_3x3", animbuild = "xd_ui_6x6",
            pos = G.Vector3(0, 220, 0), side_align_tip = 160},
        type = "chest",
    }
    for y = 4, -1, -1 do
        for x = -1, 4 do
            table.insert(params[name].widget.slotpos, G.Vector3(80 * x - 120, 80 * y - 120, 0))
        end
    end
end
params.ttk_gjx.itemtestfn = function(container, item)
    return item:HasTag("tool") or item:HasTag("umbrella")
        or item:HasTag("farmtiller") or item:HasTag("terraformer") or item:HasTag("shaver")
        or item:HasTag("xd_farmtiller") or item:HasTag("xd_terraformer") or item:HasTag("xd_shaver")
end
params.ttk_dc = {
    widget = {slotpos = {G.Vector3(0, 2, 0)}, animbank = "ui_beard_1x1", animbuild = "xd_ui_1x1",
        pos = G.Vector3(0, 200, 0), side_align_tip = 160},
    type = "chest",
    itemtestfn = function(container, item) return item.prefab == "ttk_lingshi1" end,
}
for _, name in ipairs({"ttk_lbx", "ttk_lgzbh", "ttk_mg"}) do
    params[name] = {
        widget = {
            slotpos = {}, animbank = "ui_chester_shadow_3x4", animbuild = "xd_ui_4x5",
            pos = G.Vector3(0, 250, 0), side_align_tip = 160,
        },
        type = "chest",
    }
    for y = 2, -2, -1 do
        for x = -1, 2 do
            table.insert(params[name].widget.slotpos, G.Vector3(75 * x - 38, 75 * y, 0))
        end
    end
end

local lbx_items = {
    minotaurhorn = true, townportaltalisman = true, bearger_fur = true,
    royal_jelly = true, hermit_cracked_pearl = true, deerclops_eyeball = true,
    dragon_scales = true, goose_feather = true, malbatross_beak = true,
    shroom_skin = true, alterguardianhatshard = true, milkywhites = true,
    shadowheart = true, horrorfuel = true, bluegem = true, redgem = true,
    purplegem = true, orangegem = true, yellowgem = true, greengem = true,
    opalpreciousgem = true,
}
params.ttk_lbx.itemtestfn = function(container, item)
    return lbx_items[item.prefab] == true
        and not item:HasTag("ttk_lingshi")
        and not item:HasTag("xd_lingshi")
        and not item:HasTag("xd_danyao")
end
params.ttk_lgzbh.itemtestfn = function(container, item)
    return item:HasTag("gem") or item:HasTag("ttk_lingshi")
        or item.prefab == "hermit_cracked_pearl"
end
local honey_items = {
    bandage = true, bee = true, beeswax = true, royal_jelly = true,
    spice_sugar = true, honey = true, honeycomb = true, jellybean = true,
}
params.ttk_mg.itemtestfn = function(container, item)
    return honey_items[item.prefab] == true
end
local containers = G.require("containers")
containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, 36)

for _, network in ipairs({"cave_network", "forest_network"}) do
    AddPrefabPostInit(network, function(inst)
        inst.ttk_lbx_count = G.net_tinybyte(inst.GUID, network .. ".ttk_lbx_count")
    end)
end

local definitions = {
    ttk_pflnw = {"Chuồng Bò Lai", "Nuôi bò lai, thu hoạch lông và sừng.",
        {{"cutstone",5},{"goldnugget",3},{"horn",2},{"ttk_lingshi1",10}}, 3},
    ttk_ftys = {"Chuồng Dê Điện", "Nuôi dê điện, thu hoạch sữa và sừng.",
        {{"lightninggoathorn",2},{"rocks",10},{"rope",10},{"ttk_lingshi1",10}}, 3},
    ttk_klxw = {"Chuồng Voi Koala", "Nuôi voi Koala, thu hoạch vòi theo kỳ.",
        {{"cutstone",5},{"trunk_summer",1},{"trunk_winter",1},{"ttk_lingshi1",10}}, 3},
    ttk_gjx = {"Công Cụ Hạp", "Cất công cụ và tự nhặt công cụ vô chủ trong phạm vi 8.",
        {{"goldnugget",3},{"boards",2},{"ttk_lingshi1",7}}, 2},
    ttk_dbg = {"Đa Bảo Các", "Kệ 36 ô, trưng bày tám món đầu tiên.",
        {{"boards",6},{"goldnugget",2},{"marble",2},{"ttk_lingshi1",1}}, 1.5},
    ttk_dc = {"Cửu U Xích Linh Đăng", "Thắp sáng đêm tối bằng linh thạch.",
        {{"twigs",10},{"rope",3},{"goldnugget",3},{"ttk_lingshi1",1}}, 2},
    ttk_lbx = {"Linh Bảo Sương", "Mỗi 15 ngày nhân bản một món đang cất khi có ít nhất 12 ô đồ; tối đa ba chiếc mỗi shard.",
        {{"cutstone",10},{"boards",5},{"ttk_lingshi1",20}}, 2},
    ttk_lgzbh = {"Lưu Quang Châu Bảo Hạp", "Hộp 20 ô chỉ nhận đá quý, linh thạch và Trân Châu Nứt.",
        {{"goldnugget",10},{"marble",4},{"ttk_lingshi1",4}}, 2},
    ttk_mg = {"Mật Quán", "Hũ 20 ô cho mật, ong và kẹo; thức ăn bên trong hồi độ tươi chậm.",
        {{"butterfly",10},{"rocks",5},{"rope",2},{"ttk_lingshi1",10}}, 1.5},
}
for name, def in pairs(definitions) do
    local key = string.upper(name)
    G.STRINGS.NAMES[key] = def[1]
    G.STRINGS.RECIPE_DESC[key] = def[2]
    G.STRINGS.CHARACTERS.GENERIC.DESCRIBE[key] = def[2]
    local atlas = "images/inventoryimages/" .. name .. ".xml"
    RegisterInventoryItemAtlas(atlas, name .. ".tex")
    AddMinimapAtlas("images/map_icons/" .. name .. ".xml")
    local ingredients = {}
    for _, entry in ipairs(def[3]) do table.insert(ingredients, G.Ingredient(entry[1], entry[2])) end
    local recipe_options = {atlas = atlas, image = name .. ".tex", placer = name .. "_placer", min_spacing = def[4]}
    if name == "ttk_lbx" then
        recipe_options.testfn = function()
            return G.TheWorld ~= nil and G.TheWorld.net ~= nil
                and G.TheWorld.net.ttk_lbx_count ~= nil
                and G.TheWorld.net.ttk_lbx_count:value() < 3
        end
    end
    AddRecipe2(name, ingredients, G.TECH.SCIENCE_ONE, recipe_options,
        name == "ttk_dc" and {"STRUCTURES", "LIGHT"}
            or (name == "ttk_gjx" or name == "ttk_dbg" or name == "ttk_lbx"
                or name == "ttk_lgzbh" or name == "ttk_mg") and {"STRUCTURES", "CONTAINERS"}
            or {"STRUCTURES"})
end
G.STRINGS.ACTIONS.ACTIVATE.TTK_HARVEST_HOUSE = "Thu hoạch"
G.STRINGS.CHARACTERS.GENERIC.ACTIONFAIL.ACTIVATE = G.STRINGS.CHARACTERS.GENERIC.ACTIONFAIL.ACTIVATE or {}
G.STRINGS.CHARACTERS.GENERIC.ACTIONFAIL.ACTIVATE.TTK_EMPTY_HOUSE = "Chưa có gì để thu hoạch."
