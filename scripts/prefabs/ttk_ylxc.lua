local assets = {
    Asset("ANIM", "anim/ttk_ylxc.zip"),
    Asset("ANIM", "anim/ttk_ui_6x6.zip"),
    Asset("ATLAS", "images/inventoryimages/ttk_ylxc.xml"),
    Asset("IMAGE", "images/inventoryimages/ttk_ylxc.tex"),
}

local prefabs = {"collapse_small", "collapsed_treasurechest"}

local function OnOpen(inst)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
end

local function OnClose(inst)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
end

local function OnHammered(inst)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    local container = inst.components.container
    if container ~= nil then
        container:Close()
        container:DropEverythingUpToMaxStacks(TUNING.COLLAPSED_CHEST_MAX_EXCESS_STACKS_DROPS)
        if not container:IsEmpty() then
            local pile = TheWorld.Map:IsPassableAtPoint(inst.Transform:GetWorldPosition())
                and SpawnPrefab("collapsed_treasurechest") or nil
            if pile == nil or pile.SetChest == nil then
                if pile ~= nil then pile:Remove() end
                inst.components.workable:SetWorkLeft(1)
                return
            end
            inst.components.lootdropper:DropLoot()
            inst.components.workable:SetWorkLeft(3)
            pile.Transform:SetPosition(inst.Transform:GetWorldPosition())
            pile:SetChest(inst, false)
            return
        end
    end
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    if fx ~= nil then
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        fx:SetMaterial("wood")
    end
    inst:Remove()
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("xd_ylxc")
    inst.AnimState:SetBuild("xd_ylxc")
    inst.AnimState:PlayAnimation("idle")
    inst.MiniMapEntity:SetIcon("ttk_ylxc.tex")
    MakeObstaclePhysics(inst, .5)
    inst:SetDeploySmartRadius(1.5)
    inst:AddTag("structure")
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then return inst end

    inst:AddComponent("inspectable")
    inst:AddComponent("lootdropper")
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("ttk_ylxc")
    inst.components.container.onopenfn = OnOpen
    inst.components.container.onclosefn = OnClose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true
    inst.components.container:EnableInfiniteStackSize(true)

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(OnHammered)

    inst:AddComponent("preserver")
    inst.components.preserver:SetPerishRateMultiplier(-1)
    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)
    return inst
end

return Prefab("ttk_ylxc", fn, assets, prefabs),
    MakePlacer("ttk_ylxc_placer", "xd_ylxc", "xd_ylxc", "idle")
