local assets = {
    Asset("ANIM", "anim/ttk_lgzbh.zip"),
    Asset("ANIM", "anim/ttk_ui_4x5.zip"),
    Asset("ATLAS", "images/inventoryimages/ttk_lgzbh.xml"),
    Asset("IMAGE", "images/inventoryimages/ttk_lgzbh.tex"),
}

local prefabs = {
    "collapse_small", "sand_puff", "collapsed_treasurechest",
    "chestupgrade_stacksize_fx", "ttk_lgzbh_fx",
}

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

local function OnHit(inst)
    inst.components.container:DropEverything()
    inst.components.container:Close()
end

local function Shine(inst)
    inst._shine_task = nil
    if inst.sparkle == nil or not inst.sparkle:IsValid() then return end
    inst.sparkle.Transform:SetPosition(math.random() * 2 - 1, 0.5 + math.random() * 0.5, 0)
    inst.sparkle.AnimState:PlayAnimation("sparkle")
    inst._shine_task = inst:DoTaskInTime(2 + math.random() * 3, Shine)
    if math.random() < 0.6 then
        inst:DoTaskInTime(1 + math.random(), function()
            if inst.sparkle ~= nil and inst.sparkle:IsValid() then
                inst.sparkle.Transform:SetPosition(math.random() * 2 - 1, 0.5 + math.random() * 0.5, 0)
                inst.sparkle.AnimState:PlayAnimation("sparkle")
            end
        end)
    end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("xd_lgzbh")
    inst.AnimState:SetBuild("xd_lgzbh")
    inst.AnimState:PlayAnimation("idle")
    inst.MiniMapEntity:SetIcon("ttk_lgzbh.tex")
    MakeSnowCoveredPristine(inst)
    inst:AddTag("structure")
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then return inst end

    inst:AddComponent("inspectable")
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("ttk_lgzbh")
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
    inst.sparkle = inst:SpawnChild("ttk_lgzbh_fx")
    Shine(inst)
    MakeSnowCovered(inst)
    AddHauntableDropItemOrWork(inst)
    require("ttk_chestupgrade")(inst)
    return inst
end

local function fxfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddFollower()
    inst.AnimState:SetBank("goldnugget")
    inst.AnimState:SetBuild("gold_nugget")
    inst.AnimState:PlayAnimation("sparkle", true)
    inst.AnimState:HideSymbol("nugget")
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end
    inst.persists = false
    return inst
end

return Prefab("ttk_lgzbh", fn, assets, prefabs),
    Prefab("ttk_lgzbh_fx", fxfn),
    MakePlacer("ttk_lgzbh_placer", "xd_lgzbh", "xd_lgzbh", "idle")
