local assets = {
    Asset("ANIM", "anim/ttk_hyc.zip"),
    Asset("ATLAS", "images/inventoryimages/ttk_hyc.xml"),
    Asset("IMAGE", "images/inventoryimages/ttk_hyc.tex"),
}

local function Accept(inst, item, giver, count)
    return (count == nil or count == 1) and inst.components.ttk_fishpond:HasSpace()
        and (item:HasTag("oceanfish") or item:HasTag("pondfish"))
end

local function Activate(inst, doer)
    inst.components.activatable.inactive = true
    if inst.components.ttk_fishpond:Harvest(doer) then return true end
    return false, "TTK_FISH_NOT_READY"
end

local function Hammered(inst)
    inst.components.ttk_fishpond:ReleaseAll()
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    if fx ~= nil then
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        fx:SetMaterial("stone")
    end
    inst:Remove()
end

local function Status(inst)
    for i = 1, 3 do if inst.components.ttk_fishpond:IsReady(i) then return "READY" end end
    if next(inst.components.ttk_fishpond.fish) ~= nil then return "GROWING" end
    return "EMPTY"
end

local function Fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddNetwork()
    MakeObstaclePhysics(inst, .8)
    inst.AnimState:SetBank("xd_hyc")
    inst.AnimState:SetBuild("xd_hyc")
    inst.AnimState:PlayAnimation("idle", true)
    inst.MiniMapEntity:SetIcon("ttk_hyc.tex")
    inst.Light:SetFalloff(.33)
    inst.Light:SetIntensity(.8)
    inst.Light:SetRadius(3.5)
    inst.Light:SetColour(0, 183 / 255, 1)
    inst.Light:Enable(false)
    inst:AddTag("structure")
    inst:AddTag("trader")
    inst.GetActivateVerb = function() return "TTK_HARVEST_FISH" end
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end

    inst:AddComponent("timer")
    inst:AddComponent("ttk_fishpond")
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = Status
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(Hammered)
    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(Accept)
    inst.components.trader:SetAbleToAcceptTest(Accept)
    inst.components.trader.onaccept = function(pond, giver, item)
        pond.components.ttk_fishpond:AddFish(item.prefab)
    end
    inst:AddComponent("activatable")
    inst.components.activatable.OnActivate = Activate
    inst.components.activatable.inactive = true
    local function UpdateLight() inst.Light:Enable(TheWorld.state.isnight) end
    inst:WatchWorldState("isnight", UpdateLight)
    UpdateLight()
    MakeHauntable(inst)
    return inst
end

return Prefab("ttk_hyc", Fn, assets, {"collapse_small"}),
    MakePlacer("ttk_hyc_placer", "xd_hyc", "xd_hyc", "idle")
