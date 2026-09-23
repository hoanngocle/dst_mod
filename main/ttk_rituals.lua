local G = GLOBAL
local tonumber = G.tonumber

table.insert(PrefabFiles, "ttk_sj_kls")
table.insert(PrefabFiles, "ttk_lbjlt")

local function IsLivingPlayer(player)
    return player ~= nil and player:IsValid() and not player:HasTag("playerghost")
        and (player.components.health == nil or not player.components.health:IsDead())
end

local function ClearKlsChannel(player)
    if player ~= nil and player:IsValid() then
        player:RemoveTag("ttk_kls_channeling")
        player._ttk_kls_target = nil
        player._ttk_kls_clear_task = nil
    end
end

local channel = G.Action({priority = 2, rmb = true, mount_valid = true})
channel.id = "TTK_KLS_CHANNEL"
channel.str = "Nhập sơn"
channel.fn = function(act)
    local player, target = act.doer, act.target
    if not IsLivingPlayer(player) or target == nil or not target:IsValid()
        or not target:HasTag("ttk_sj_kls") or player:GetDistanceSqToInst(target) > 16 then
        return false
    end
    if player._ttk_kls_clear_task ~= nil then player._ttk_kls_clear_task:Cancel() end
    player._ttk_kls_target = target
    player:AddTag("ttk_kls_channeling")
    player._ttk_kls_clear_task = player:DoTaskInTime(20, ClearKlsChannel)
    if player.components.talker ~= nil then
        player.components.talker:Say("Mở bản đồ và chọn nơi đã khám phá trong 20 giây.")
    end
    return true
end
AddAction(channel)
AddComponentAction("SCENE", "inspectable", function(inst, doer, actions, right)
    if right and inst:HasTag("ttk_sj_kls") and not doer:HasTag("ttk_kls_channeling") then
        table.insert(actions, channel)
    end
end)
AddStategraphActionHandler("wilson", G.ActionHandler(channel, "doshortaction"))
AddStategraphActionHandler("wilson_client", G.ActionHandler(channel, "doshortaction"))

local function ValidMapPoint(player, point)
    if not IsLivingPlayer(player) or point == nil or type(point.x) ~= "number" or type(point.z) ~= "number"
        or point.x ~= point.x or point.z ~= point.z or math.abs(point.x) == math.huge
        or math.abs(point.z) == math.huge or not player:CanSeePointOnMiniMap(point.x, 0, point.z)
        or not G.TheWorld.Map:IsPassableAtPoint(point.x, 0, point.z)
        or G.TheWorld.Map:IsGroundTargetBlocked(point) then
        return false
    end
    local x, y, z = player.Transform:GetWorldPosition()
    return G.IsTeleportingPermittedFromPointToPoint(x, y, z, point.x, 0, point.z)
end

local maptravel = G.Action({
    priority = 20, rmb = true, mount_valid = true, encumbered_valid = true,
    map_action = true, map_only = true, closes_map = true,
    customarrivecheck = function() return true end,
})
maptravel.id = "TTK_KLS_MAPTRAVEL"
maptravel.str = "Độn nhập"
maptravel.maponly_checkvalidpos_fn = function(act)
    local point = act:GetActionPoint()
    if not act.doer:HasTag("ttk_kls_channeling") or not ValidMapPoint(act.doer, point) then
        return false
    end
    return true, nil, point.x, point.z
end
maptravel.fn = function(act)
    local player, point = act.doer, act:GetActionPoint()
    local target = player ~= nil and player._ttk_kls_target or nil
    if not IsLivingPlayer(player) or target == nil or not target:IsValid()
        or not target:HasTag("ttk_sj_kls") or player:GetDistanceSqToInst(target) > 36
        or not player:HasTag("ttk_kls_channeling") or not ValidMapPoint(player, point) then
        ClearKlsChannel(player)
        return false
    end
    if player.components.sanity ~= nil then player.components.sanity:DoDelta(-25) end
    local fx = G.SpawnPrefab("spawn_fx_medium_static")
    if fx ~= nil then fx.Transform:SetPosition(player.Transform:GetWorldPosition()) end
    if player.Physics ~= nil then
        player.Physics:Teleport(point.x, 0, point.z)
    else
        player.Transform:SetPosition(point.x, 0, point.z)
    end
    player:SnapCamera()
    ClearKlsChannel(player)
    return true
end
AddAction(maptravel)
AddStategraphActionHandler("wilson", G.ActionHandler(maptravel, "doshortaction"))
AddStategraphActionHandler("wilson_client", G.ActionHandler(maptravel, "doshortaction"))

AddComponentPostInit("playercontroller", function(self)
    local original = self.GetMapActions
    self.GetMapActions = function(controller, position, maptarget, actiondef, ...)
        local left, right = original(controller, position, maptarget, actiondef, ...)
        if not controller.skip_inherentmapaction
            and (actiondef == nil or actiondef == maptravel)
            and controller.inst:HasTag("ttk_kls_channeling") then
            local act = G.BufferedAction(controller.inst, nil, maptravel, nil, position)
            right = controller:RemapMapAction(act, position)
        end
        return left, right
    end
end)

local costs = {1, 1, 1, 3, 6, 12, 33, 99, 300}
local params = G.require("containers").params
params.ttk_lbjlt = {
    widget = {
        slotpos = {G.Vector3(0, 32, 0)}, animbank = "ui_beard_1x1", animbuild = "ui_beard_1x1",
        pos = G.Vector3(0, 200, 0), side_align_tip = 160,
        buttoninfo = {text = "Tế luyện", position = G.Vector3(0, -45, 0)},
    },
    type = "chest",
    itemtestfn = function(container, item)
        return item.prefab == "lucmachthankiem" or item.prefab == "vanhonphien"
            or item.prefab == "ttk_lucnguyenkiemdong"
    end,
}
params.ttk_lbjlt.widget.buttoninfo.fn = function(inst, doer)
    if inst.components.container ~= nil then
        if inst.Refine ~= nil then inst:Refine(doer) end
    elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
        G.SendRPCToServer(G.RPC.DoWidgetButtonAction,
            G.ACTIONS.ACTIVATE_CONTAINER.code, inst, G.ACTIONS.ACTIVATE_CONTAINER.mod_name)
    end
end
params.ttk_lbjlt.widget.buttoninfo.validfn = function(inst)
    local container = inst.replica.container
    return container ~= nil and container:GetItemInSlot(1) ~= nil
end

local function ApplyLucMachLevel(inst)
    local level = math.max(0, math.min(9, tonumber(inst._ttk_ritual_level) or 0))
    local multiplier = 1 + level * 0.05
    local weapon = inst.real_weapon
    if weapon == nil then return end
    local previous = inst._ttk_ritual_applied_multiplier or 1
    if weapon.components.weapon ~= nil and type(weapon.components.weapon.damage) == "number" then
        weapon.components.weapon:SetDamage(weapon.components.weapon.damage / previous * multiplier)
    end
    if weapon.components.planardamage ~= nil and type(weapon.components.planardamage.basedamage) == "number" then
        weapon.components.planardamage:SetBaseDamage(weapon.components.planardamage.basedamage / previous * multiplier)
    end
    inst._ttk_ritual_applied_multiplier = multiplier
end

AddPrefabPostInit("lucmachthankiem", function(inst)
    if not G.TheWorld.ismastersim then return end
    local old_save, old_load, old_set_count = inst.OnSave, inst.OnLoad, inst.SetSummonCount
    inst.OnSave = function(item, data)
        if old_save ~= nil then old_save(item, data) end
        data.ttk_ritual_level = item._ttk_ritual_level or 0
    end
    inst.OnLoad = function(item, data)
        if old_load ~= nil then old_load(item, data) end
        item._ttk_ritual_level = data ~= nil and tonumber(data.ttk_ritual_level) or 0
        item._ttk_ritual_applied_multiplier = 1
        ApplyLucMachLevel(item)
    end
    if old_set_count ~= nil then
        inst.SetSummonCount = function(item, count)
            old_set_count(item, count)
            item._ttk_ritual_applied_multiplier = 1
            ApplyLucMachLevel(item)
        end
    end
    inst.TTKApplyRitualLevel = function(item, level)
        item._ttk_ritual_level = level
        ApplyLucMachLevel(item)
    end
    ApplyLucMachLevel(inst)
end)

AddPrefabPostInit("vanhonphien", function(inst)
    if not G.TheWorld.ismastersim then return end
    inst.TTKApplyRitualLevel = function(item, level)
        require("vanhonphien_damage").SetRitualLevel(item, level)
    end
end)

local function InstallRefine(inst)
    inst.Refine = function(altar, doer)
        if altar._ttk_refine_busy or not IsLivingPlayer(doer)
            or doer:GetDistanceSqToInst(altar) > 25 or doer.components.inventory == nil then
            return false
        end
        local item = altar.components.container:GetItemInSlot(1)
        if item == nil or item.TTKApplyRitualLevel == nil then return false end
        local level = math.max(0, math.min(9, tonumber(item._ttk_ritual_level) or 0))
        if level >= 9 then
            if doer.components.talker ~= nil then doer.components.talker:Say("Pháp bảo đã tế luyện tối đa.") end
            return false
        end
        local cost = costs[level + 1]
        local has_enough = doer.components.inventory:Has("ttk_lingshi3", cost)
        if not has_enough then
            if doer.components.talker ~= nil then
                doer.components.talker:Say("Cần " .. cost .. " Linh Thạch bậc 3.")
            end
            return false
        end
        -- Inventory:ConsumeByName has no success return value in DST. The
        -- server-side Has check above is the atomic gate; consume only after it.
        doer.components.inventory:ConsumeByName("ttk_lingshi3", cost)
        altar._ttk_refine_busy = true
        altar._ttk_ritual_owner = doer.userid
        item:TTKApplyRitualLevel(level + 1)
        local fx = G.SpawnPrefab("ttk_lbjlt_fx")
        if fx ~= nil then fx.Transform:SetPosition(altar.Transform:GetWorldPosition()) end
        altar:DoTaskInTime(1.25, function() altar._ttk_refine_busy = false end)
        if doer.components.talker ~= nil then
            doer.components.talker:Say("Tế luyện thành công: cấp " .. (level + 1) .. "/9.")
        end
        return true
    end
end
AddPrefabPostInit("ttk_lbjlt", InstallRefine)

local definitions = {
    ttk_sj_kls = {"Khô Lâu Sơn", "Nhập sơn rồi mở bản đồ trong 20 giây để đến nơi đã khám phá, tiêu hao 25 tinh thần.",
        {{"cutstone",6},{"boneshard",3},{"purplegem",1},{"ttk_lingshi2",1}}, G.TECH.MAGIC_TWO, 3},
    ttk_lbjlt = {"Linh Bảo Tế Luyện Đài", "Tế luyện Lục Mạch Thần Kiếm, Cửu Thiên Tinh Thần Phiên hoặc Lục Nguyên Kiếm Đồng tối đa chín cấp.",
        {{"flint",3},{"cutstone",6},{"ttk_lingshi2",1}}, G.TECH.MAGIC_TWO, 2},
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
    AddRecipe2(name, ingredients, def[4], {
        atlas = atlas, image = name .. ".tex", placer = name .. "_placer",
        min_spacing = def[5], no_deconstruction = true,
    }, {"STRUCTURES", "MAGIC"})
end
