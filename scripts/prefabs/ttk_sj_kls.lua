local assets = {
    Asset("ANIM", "anim/ttk_sj_kls.zip"),
    Asset("ATLAS", "images/inventoryimages/ttk_sj_kls.xml"),
    Asset("IMAGE", "images/inventoryimages/ttk_sj_kls.tex"),
}

local prefabs = {"collapse_small", "spawn_fx_medium_static"}

local function OnHammered(inst)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    if fx ~= nil then
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        fx:SetMaterial("metal")
    end
    inst:Remove()
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst:SetDeploySmartRadius(0.75)
    MakeObstaclePhysics(inst, 0.5)
    inst.MiniMapEntity:SetIcon("ttk_sj_kls.tex")
    inst.AnimState:SetBank("xd_sj_kls")
    inst.AnimState:SetBuild("xd_sj_kls")
    inst.AnimState:PlayAnimation("idle", true)
    inst:AddTag("structure")
    inst:AddTag("ttk_sj_kls")
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then return inst end

    inst:AddComponent("inspectable")
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(OnHammered)
    AddHauntableDropItemOrWork(inst)
    return inst
end

return Prefab("ttk_sj_kls", fn, assets, prefabs),
    MakePlacer("ttk_sj_kls_placer", "xd_sj_kls", "xd_sj_kls", "idle")
