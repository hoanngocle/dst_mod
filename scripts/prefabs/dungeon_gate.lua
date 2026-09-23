local IsDungeonSurfaceAuthority = require("utils/hh_dungeon_authority")

local assets = {
    Asset("ANIM", "anim/monkey_island_portal1.zip"),
    Asset("ANIM", "anim/monkey_island_portal2.zip"),
    Asset("ANIM", "anim/monkey_island_portal3.zip"),
    Asset("ANIM", "anim/monkey_island_portal_fx.zip"),
    Asset("ATLAS", "images/minimap/gate_reset.xml"),
    Asset("IMAGE", "images/minimap/gate_reset.tex"),
    Asset("ATLAS", "images/minimap/gate_low.xml"),
    Asset("IMAGE", "images/minimap/gate_low.tex"),
    Asset("ATLAS", "images/minimap/gate_high.xml"),
    Asset("IMAGE", "images/minimap/gate_high.tex"),
    Asset("ATLAS", "images/minimap/gate_reset_max.xml"),
    Asset("IMAGE", "images/minimap/gate_reset_max.tex"),
    Asset("ATLAS", "images/minimap/gate_low_max.xml"),
    Asset("IMAGE", "images/minimap/gate_low_max.tex"),
    Asset("ATLAS", "images/minimap/gate_high_max.xml"),
    Asset("IMAGE", "images/minimap/gate_high_max.tex"),
}

local prefabs = {
    "rock_flintless",
}

local LARGE_GATE_ICON_BY_STATE = {
    ["gate_reset.tex"] = "gate_reset_max.tex",
    ["gate_low.tex"] = "gate_low_max.tex",
    ["gate_high.tex"] = "gate_high_max.tex",
}

local DUNGEON_RANK_BY_WAVES = {
    [2] = "E",
    [3] = "D",
    [4] = "C",
    [5] = "B",
    [6] = "A",
}

local function GetDungeonHoverData(total_waves)
    if type(total_waves) ~= "number" then
        return nil
    end

    local rank = DUNGEON_RANK_BY_WAVES[total_waves]
    if rank == nil and total_waves >= 7 and total_waves <= 10 then
        rank = "S"
    end

    local party_size
    if total_waves >= 2 and total_waves <= 3 then
        party_size = 2
    elseif total_waves >= 4 and total_waves <= 5 then
        party_size = 3
    elseif total_waves >= 6 and total_waves <= 10 then
        party_size = 4
    end

    if rank == nil or party_size == nil then
        return nil
    end

    return rank, party_size
end

local function GetGateMapIcon(icon)
    return LARGE_GATE_ICON_BY_STATE[icon] or icon
end

local function SetGateIcon(inst, icon)
    local map_icon = GetGateMapIcon(icon)
    if inst.MiniMapEntity then
        inst.MiniMapEntity:SetIcon(map_icon)
    end
    if inst._globalmapicon ~= nil
        and inst._globalmapicon:IsValid()
        and inst._globalmapicon.MiniMapEntity ~= nil then
        inst._globalmapicon.MiniMapEntity:SetIcon(map_icon)
    end
end

local function OnStateChanged(inst, data)
    if not data then return end
    if data.state == "COOLDOWN" then
        inst:AddTag("dungeon_resetting")
        inst.AnimState:SetBank("monkey_island_porta3")
        inst.AnimState:SetBuild("monkey_island_porta3")
        inst.AnimState:PlayAnimation("out_idle", true)
        SetGateIcon(inst, "gate_reset.tex")
    elseif data.state == "READY" or data.state == "IN_PROGRESS" then
        inst:RemoveTag("dungeon_resetting")
        if data.stages and data.stages >= 6 then
            inst.AnimState:SetBank("monkey_island_porta2")
            inst.AnimState:SetBuild("monkey_island_porta2")
            inst.AnimState:PlayAnimation("out_idle", true)
            SetGateIcon(inst, "gate_high.tex")
        else
            inst.AnimState:SetBank("monkey_island_porta1")
            inst.AnimState:SetBuild("monkey_island_porta1")
            inst.AnimState:PlayAnimation("out_idle", true)
            SetGateIcon(inst, "gate_low.tex")
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon(GetGateMapIcon("gate_low.tex"))
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetDrawOverFogOfWar(true)
    inst.MiniMapEntity:SetPriority(22)

    MakeObstaclePhysics(inst, 1)

    inst.AnimState:SetBank("monkey_island_porta1")
    inst.AnimState:SetBuild("monkey_island_porta1")
    inst.AnimState:PlayAnimation("out_idle", true)
    
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetLightOverride(1)
    
    inst:AddTag("dungeon_gate")

    inst.name = "Cổng Hầm Ngục"

    local is_surface_authority = IsDungeonSurfaceAuthority(TheWorld)
    local is_surface_client = not TheWorld.ismastersim and TheWorld:HasTag("forest")
    if (is_surface_authority or is_surface_client) and RegisterGlobalMapIcon ~= nil then
        -- Keep vanilla's registration-before-pristine ordering on valid
        -- Surface instances, while never registering a Cave gate icon.
        RegisterGlobalMapIcon(inst, "dungeon_gate")
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    if not is_surface_authority then
        inst._dungeon_gate_remove_intent = true
        inst:DoTaskInTime(0, function(gate)
            if gate:IsValid() then
                gate:Remove()
            end
        end)
        return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable:SetDescription("Một cánh cổng bí ẩn toát ra luồng sức mạnh hắc ám...")

    inst:ListenForEvent("dungeon_state_changed", function(world, data)
        OnStateChanged(inst, data)
    end, TheWorld)

    local manager = TheWorld.components.dungeon_manager
    if manager ~= nil then
        local total_waves = manager.max_waves
        local rank, party_size = GetDungeonHoverData(total_waves)
        if rank ~= nil and party_size ~= nil then
            inst.dungeon_total_waves = total_waves
            inst.GetHHSpDesc01 = function(_, _viewer)
                return {
                    title = "Thông tin",
                    desc = "Hầm Ngục hạng " .. rank,
                }
            end
            inst.GetHHSpDesc02 = function(_, _viewer)
                return {
                    title = "Tổ đội khuyến nghị",
                    desc = tostring(party_size) .. " thợ săn",
                }
            end
            inst.GetHHSpDesc03 = function(_, _viewer)
                return {
                    title = "Rank khuyến nghị",
                    desc = "Thợ Săn hạng " .. rank,
                }
            end
        end
        OnStateChanged(inst, {state = manager.state, stages = manager.max_waves})
    end

    inst._globalmapicon = SpawnPrefab("globalmapicon")
    if inst._globalmapicon ~= nil then
        inst._globalmapicon:AddTag("hh_dungeon_gate_mapicon")
        inst._globalmapicon:TrackEntity(inst)
        inst._globalmapicon.MiniMapEntity:SetIcon(GetGateMapIcon("gate_low.tex"))
        inst._globalmapicon.MiniMapEntity:SetPriority(21)
    end

    inst:ListenForEvent("onremove", function()
        if inst._globalmapicon ~= nil and inst._globalmapicon:IsValid() then
            inst._globalmapicon:Remove()
        end
        local current_manager = TheWorld.components.dungeon_manager
        if current_manager ~= nil then
            current_manager:OnGateRemoved(inst)
        end
    end)

    MakeHauntable(inst)

    return inst
end

return Prefab("dungeon_gate", fn, assets, prefabs)
