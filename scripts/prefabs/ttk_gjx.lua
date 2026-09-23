
local assets =
{
    Asset("ANIM", "anim/ttk_gjx.zip"),
    Asset("ANIM", "anim/ttk_ui_6x6.zip"),
	Asset("ATLAS", "images/inventoryimages/ttk_gjx.xml"),
    Asset("IMAGE", "images/inventoryimages/ttk_gjx.tex"),
}

local prefabs = { "collapse_small", "sand_puff", "collapsed_treasurechest", "chestupgrade_stacksize_fx",

}

local function onopen(inst)
    
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
end

local function onclose(inst)
    
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
end

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    inst.components.container:DropEverything()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")
    inst:Remove()
end

local function onhit(inst, worker)
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

    inst.AnimState:SetBank("xd_gjx")
    inst.AnimState:SetBuild("xd_gjx")
    inst.AnimState:PlayAnimation("idle")

    inst.MiniMapEntity:SetIcon("ttk_gjx.tex")

    MakeSnowCoveredPristine(inst)

    inst:AddTag("structure")
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then

        return inst
    end
    inst:AddComponent("inspectable")

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("ttk_gjx")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true

    inst:AddComponent("lootdropper")
    
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit) 

    inst:AddComponent("ttk_storeitem")

    MakeSnowCovered(inst)
    AddHauntableDropItemOrWork(inst)
    require("ttk_chestupgrade")(inst)
    return inst
end

return  Prefab("ttk_gjx", fn, assets, prefabs),
    MakePlacer("ttk_gjx_placer", "xd_gjx", "xd_gjx", "idle")
