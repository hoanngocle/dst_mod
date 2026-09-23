local assets = {
    Asset("ANIM", "anim/ttk_lbjlt.zip"),
    Asset("ATLAS", "images/inventoryimages/ttk_lbjlt.xml"),
    Asset("IMAGE", "images/inventoryimages/ttk_lbjlt.tex"),
}

local prefabs = {"collapse_small", "ttk_lbjlt_fx"}

local function RefreshAnim(inst)
    local item = inst.components.container ~= nil and inst.components.container:GetItemInSlot(1) or nil
    local anim = item ~= nil and (item.prefab == "lucmachthankiem"
        or item.prefab == "ttk_lucnguyenkiemdong") and "idle_2"
        or item ~= nil and item.prefab == "vanhonphien" and "idle_1" or "idle"
    inst.AnimState:PlayAnimation(anim, anim == "idle_2")
end

local function OnOpen(inst) inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open") end
local function OnClose(inst) inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close") end

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

local function Save(inst, data)
    data.ritual_owner = inst._ttk_ritual_owner
end

local function Load(inst, data)
    if data ~= nil then inst._ttk_ritual_owner = data.ritual_owner end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 0.5)
    inst.AnimState:SetBank("xd_lbjlt")
    inst.AnimState:SetBuild("xd_lbjlt")
    inst.AnimState:PlayAnimation("idle")
    inst.MiniMapEntity:SetIcon("ttk_lbjlt.tex")
    inst:AddTag("structure")
    inst:AddTag("ttk_lbjlt")
    MakeSnowCoveredPristine(inst)
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then return inst end

    inst:AddComponent("inspectable")
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("ttk_lbjlt")
    inst.components.container.onopenfn = OnOpen
    inst.components.container.onclosefn = OnClose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(OnHammered)
    inst:ListenForEvent("itemget", RefreshAnim)
    inst:ListenForEvent("itemlose", RefreshAnim)
    inst.TTKRefreshDecor = RefreshAnim
    inst.OnLoadPostPass = RefreshAnim
    inst.OnSave = Save
    inst.OnLoad = Load
    MakeSnowCovered(inst)
    AddHauntableDropItemOrWork(inst)
    return inst
end

local function fxfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.AnimState:SetBank("lunar_fx")
    inst.AnimState:SetBuild("moonbase_fx")
    inst.AnimState:PlayAnimation("lunar_front_pre")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetFinalOffset(2)
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst.SoundEmitter:PlaySound("dontstarve/common/together/moonbase/beam", "beam")
    inst.SoundEmitter:SetParameter("beam", "intensity", 0)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end
    inst.persists = false
    inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength(), function()
        if not inst:IsValid() then return end
        inst.SoundEmitter:SetParameter("beam", "intensity", 0.6)
        inst.SoundEmitter:PlaySound("dontstarve/common/together/moonbase/beam_level_up")
        inst.AnimState:PlayAnimation("lunar_front_loop", true)
        inst:DoTaskInTime(1.2, function()
            if not inst:IsValid() then return end
            inst.SoundEmitter:KillSound("beam")
            inst.SoundEmitter:PlaySound("dontstarve/common/together/moonbase/beam_stop")
            inst.AnimState:PlayAnimation("lunar_front_pst")
            inst:ListenForEvent("animover", inst.Remove)
        end)
    end)
    inst:DoTaskInTime(5, inst.Remove)
    return inst
end

return Prefab("ttk_lbjlt", fn, assets, prefabs),
    Prefab("ttk_lbjlt_fx", fxfn),
    MakePlacer("ttk_lbjlt_placer", "xd_lbjlt", "xd_lbjlt", "idle")
