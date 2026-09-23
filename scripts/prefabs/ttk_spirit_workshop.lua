require("prefabutil")
local assets = {
    Asset("ANIM", "anim/ttk_spirit_workshop.zip"),
    Asset("ATLAS", "images/ttk_spirit_workshop/icon.xml"),
    Asset("IMAGE", "images/ttk_spirit_workshop/icon.tex"),
}
local PERIOD = 5 * TUNING.TOTAL_DAY_TIME

local function Ready(inst)
    inst.AnimState:SetMultColour(1, 1, 1, 1)
    inst.Light:Enable(true)
end

local function Empty(inst)
    inst.AnimState:SetMultColour(0.65, 0.65, 0.75, 1)
    inst.Light:Enable(false)
end

local function BeginCycle(inst, remaining)
    inst.components.pickable:MakeEmpty()
    inst.components.timer:StopTimer("produce")
    inst.components.timer:StartTimer("produce", remaining or PERIOD)
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddNetwork()
    MakeObstaclePhysics(inst, 1.4)
    inst.AnimState:SetBank("ttk_spirit_workshop")
    inst.AnimState:SetBuild("ttk_spirit_workshop")
    inst.AnimState:PlayAnimation("idle", true)
    inst.MiniMapEntity:SetIcon("ttk_spirit_workshop.tex")
    inst.Light:SetRadius(1.5)
    inst.Light:SetFalloff(0.7)
    inst.Light:SetIntensity(0.5)
    inst.Light:SetColour(0.35, 0.5, 1)
    inst.Light:Enable(false)
    inst:AddTag("structure")
    inst:AddTag("ttk_spirit_workshop")
    inst:AddTag("pickable_harvest_str")
    MakeSnowCoveredPristine(inst)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = function(ent)
        return ent.components.pickable:CanBePicked() and "READY" or "GROWING"
    end
    inst:AddComponent("timer")
    inst:AddComponent("lootdropper")
    -- This component serves harvests, not demolition material refunds.
    inst.components.lootdropper.droprecipeloot = false
    local loot = {}
    for i = 1, 20 do table.insert(loot, "ttk_lingshi1") end
    for i = 1, 2 do table.insert(loot, "ttk_lingshi2") end
    inst.components.lootdropper:SetLoot(loot)
    inst.components.lootdropper:AddChanceLoot("ttk_lingshi3", 0.2)
    inst:AddComponent("pickable")
    -- Use a plain timer, not plant regrowth (which accelerates during spring).
    inst.components.pickable:SetUp(nil)
    inst.components.pickable.use_lootdropper_for_product = true
    inst.components.pickable.quickpick = true
    inst.components.pickable.makeemptyfn = Empty
    inst.components.pickable.makefullfn = Ready
    inst.components.pickable.onpickedfn = function(ent) BeginCycle(ent) end
    inst:ListenForEvent("onbuilt", function(ent) BeginCycle(ent) end)
    inst:ListenForEvent("timerdone", function(ent, data)
        if data.name == "produce" then ent.components.pickable:Regen() end
    end)
    inst.BeginProduction = BeginCycle
    Ready(inst)
    MakeSnowCovered(inst)
    return inst
end

return Prefab("ttk_spirit_workshop", fn, assets, {"ttk_lingshi1", "ttk_lingshi2", "ttk_lingshi3"}),
    MakePlacer("ttk_spirit_workshop_placer", "ttk_spirit_workshop", "ttk_spirit_workshop", "idle")
