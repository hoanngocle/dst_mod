local assets = {
    Asset("ANIM", "anim/ttk_mg.zip"),
    Asset("ANIM", "anim/ttk_ui_4x5.zip"),
    Asset("ATLAS", "images/inventoryimages/ttk_mg.xml"),
    Asset("IMAGE", "images/inventoryimages/ttk_mg.tex"),
}

local prefabs = {
    "collapse_small", "sand_puff", "collapsed_treasurechest", "chestupgrade_stacksize_fx",
}

local function OnOpen(inst) inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_open") end
local function OnClose(inst) inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_close") end

local function OnHammered(inst)
    inst.components.lootdropper:DropLoot()
    inst.components.container:DropEverything()
    local fx = SpawnPrefab("collapse_small")
    if fx ~= nil then
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        fx:SetMaterial("metal")
    end
    inst:Remove()
end

local function OnHit(inst)
    inst.components.container:DropEverything()
    inst.components.container:Close()
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst)

    inst.AnimState:SetBank("xd_mg")
    inst.AnimState:SetBuild("xd_mg")
    inst.AnimState:PlayAnimation("idle")
    inst.MiniMapEntity:SetIcon("ttk_mg.tex")
    MakeSnowCoveredPristine(inst)
    inst:AddTag("structure")
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then return inst end

    inst:AddComponent("inspectable")
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("ttk_mg")
    inst.components.container.onopenfn = OnOpen
    inst.components.container.onclosefn = OnClose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(OnHammered)
    inst.components.workable:SetOnWorkCallback(OnHit)
    inst:AddComponent("preserver")
    inst.components.preserver:SetPerishRateMultiplier(-0.2)
    MakeSnowCovered(inst)
    AddHauntableDropItemOrWork(inst)
    require("ttk_chestupgrade")(inst)
    return inst
end

return Prefab("ttk_mg", fn, assets, prefabs),
    MakePlacer("ttk_mg_placer", "xd_mg", "xd_mg", "idle")
