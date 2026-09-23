local assets = {
    Asset("ANIM", "anim/ttk_ylxq.zip"),
    Asset("ATLAS", "images/inventoryimages/ttk_ylxq.xml"),
    Asset("IMAGE", "images/inventoryimages/ttk_ylxq.tex"),
}

local prefabs = {
    "collapse_small",
    "ttk_plant_hsc", "ttk_plant_dms", "ttk_plant_qfx",
    "ttk_plant_cyh", "ttk_plant_lmg", "ttk_plant_yhh",
}

local function OnHammered(inst)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    if inst.components.ttk_ylxq_grower ~= nil then inst.components.ttk_ylxq_grower:DoDrop() end
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    if fx ~= nil then
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        fx:SetMaterial("wood")
    end
    inst:Remove()
end

local function IsLowPriorityAction(act, force_inspect)
    return act == nil or act.action == ACTIONS.WALKTO
        or (act.action == ACTIONS.LOOKAT and not force_inspect)
end

local function CanMouseThrough(inst)
    if inst:HasTag("fire") or ThePlayer == nil
        or ThePlayer.components.playeractionpicker == nil then return false end
    local controller = ThePlayer.components.playercontroller
    local force_inspect = controller ~= nil and controller:IsControlPressed(CONTROL_FORCE_INSPECT)
    local lmb, rmb = ThePlayer.components.playeractionpicker:DoGetMouseActions(inst:GetPosition(), inst)
    return IsLowPriorityAction(rmb, force_inspect) and IsLowPriorityAction(lmb, force_inspect)
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("xd_ylxq")
    inst.AnimState:SetBuild("xd_ylxq")
    inst.AnimState:PlayAnimation("idle")
    inst.MiniMapEntity:SetIcon("ttk_ylxq.tex")
    inst:SetDeploySmartRadius(1.5)
    MakeObstaclePhysics(inst, .5)
    inst.CanMouseThrough = CanMouseThrough
    inst:AddTag("structure")
    inst:AddTag("ttk_ylxq_grower")
    inst:AddTag("ttk_ylxq_chargeable")
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then return inst end

    inst:AddComponent("inspectable")
    inst:AddComponent("lootdropper")
    inst:AddComponent("named")
    inst:AddComponent("ttk_ylxq_grower")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(OnHammered)
    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst.OnSave = function(_, data)
        data.ttk_ylxq_version = 1
    end
    return inst
end

return Prefab("ttk_ylxq", fn, assets, prefabs),
    MakePlacer("ttk_ylxq_placer", "xd_ylxq", "xd_ylxq", "idle")
