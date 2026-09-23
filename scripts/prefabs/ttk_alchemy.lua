local Defs = require("alchemy/ttk_alchemy_defs")

local furnace_assets = {
    Asset("ANIM", "anim/xd_liandanlu.zip"),
    Asset("ATLAS", "images/inventoryimages/xd_liandanlu.xml"),
    Asset("IMAGE", "images/inventoryimages/xd_liandanlu.tex"),
}

local function OnEaten(inst, eater)
    if eater == nil or not TheWorld.ismastersim then return end
    local cultivation = eater.components.ttk_cultivation
    if cultivation ~= nil and Defs.GetCultivationStage(cultivation:GetStage() + 1) ~= nil then
        local row = Defs.Get(inst.prefab)
        if row ~= nil and row == Defs.GetCultivationStage(cultivation:GetStage() + 1) then
            eater.components.ttk_cultivation:Consume(inst.prefab)
            -- Native Eater owns removal after the committed OnEaten callback.
            return
        end
    end
    if eater.components.ttk_alchemy_effects ~= nil then eater.components.ttk_alchemy_effects:Apply(inst.prefab) end
end

local function MakePill(prefab)
    -- Reuse the shipped pill art. Cultivation/fasting pills share the healing
    -- pill presentation until bespoke art exists; prefab/save IDs stay intact.
    local animation = prefab:match("^xd_dy_(%w+)_1$") or "dmhsd"
    local image = "xd_dy_" .. animation .. "_5"
    local atlas = "images/inventoryimages/" .. image .. ".xml"
    local assets = {
        Asset("ANIM", "anim/xd_danyao_new.zip"),
        Asset("ATLAS", atlas),
        Asset("IMAGE", "images/inventoryimages/" .. image .. ".tex"),
    }
    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform(); inst.entity:AddAnimState(); inst.entity:AddNetwork()
        MakeInventoryPhysics(inst)
        inst:AddTag("xd_danyao")
        inst.AnimState:SetBank("xd_danyao_new"); inst.AnimState:SetBuild("xd_danyao_new"); inst.AnimState:PlayAnimation(animation, true)
        inst.entity:SetPristine()
        if not TheWorld.ismastersim then return inst end
        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.atlasname = atlas
        inst.components.inventoryitem.imagename = image
        inst:AddComponent("edible")
        inst.components.edible.foodtype = FOODTYPE.GOODIES
        inst.components.edible:SetOnEatenFn(OnEaten)
        return inst
    end
    return Prefab(prefab, fn, assets)
end

local function OnFurnaceHammered(inst, worker)
    local station = inst.components.ttk_alchemy_station
    if station ~= nil and station:IsBusy() then
        inst.components.workable:SetWorkLeft(3)
        return
    end
    if inst.components.container ~= nil then inst.components.container:DropEverything() end
    local fx = SpawnPrefab("collapse_small")
    if fx ~= nil then fx.Transform:SetPosition(inst.Transform:GetWorldPosition()) end
    inst:Remove()
end

local function OnFurnaceHit(inst)
    local station = inst.components.ttk_alchemy_station
    if station ~= nil and station:IsBusy() then inst.components.workable:SetWorkLeft(3) end
end

local function MakeFurnace()
    local inst = CreateEntity()
    inst.entity:AddTransform(); inst.entity:AddAnimState(); inst.entity:AddSoundEmitter(); inst.entity:AddNetwork()
    MakeObstaclePhysics(inst, .7)
    inst.AnimState:SetBank("xd_liandanlu"); inst.AnimState:SetBuild("xd_liandanlu"); inst.AnimState:PlayAnimation("idle")
    inst:AddTag("structure")
    inst:AddTag("ttk_alchemy_station")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end

    inst:AddComponent("inspectable")
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("xd_liandanlu")
    local Open = inst.components.container.Open
    inst.components.container.Open = function(container, doer)
        if inst.components.ttk_alchemy_station:IsBusy() then return false end
        return Open(container, doer)
    end
    inst:AddComponent("ttk_alchemy_station")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnWorkCallback(OnFurnaceHit)
    inst.components.workable:SetOnFinishCallback(OnFurnaceHammered)
    inst.OnSave = function(furnace, data) data.ttk_alchemy_station = furnace.components.ttk_alchemy_station:OnSave() end
    inst.OnLoad = function(furnace, data) furnace.components.ttk_alchemy_station:OnLoad(data ~= nil and data.ttk_alchemy_station or nil) end
    MakeHauntableWork(inst)
    return inst
end

return MakePill("xd_danyao_jq"), MakePill("xd_danyao_dt"), MakePill("xd_danyao_zj"),
    MakePill("xd_danyao_xs"), MakePill("xd_danyao_hj"), MakePill("xd_danyao_yz"),
    MakePill("xd_danyao_sm"), MakePill("xd_danyao_rl"), MakePill("xd_danyao_jy"),
    MakePill("xd_danyao_yx"), MakePill("xd_danyao_ns"), MakePill("xd_danyao_hs"),
    MakePill("xd_danyao_hy"), MakePill("xd_danyao_hl"), MakePill("xd_danyao_kx"),
    MakePill("xd_danyao_bg"), MakePill("xd_dy_cyfxd_1"), MakePill("xd_dy_dmhsd_1"),
    MakePill("xd_dy_lmsqd_1"), MakePill("xd_dy_qxdhd_1"), MakePill("xd_dy_yfsxd_1"),
    MakePill("xd_dy_pshsd_1"), MakePill("xd_dy_qjqsd_1"), MakePill("xd_dy_xynyd_1"),
    MakePill("xd_dy_hsphd_1"), MakePill("xd_dy_xttyd_1"),
    Prefab("xd_liandanlu", MakeFurnace, furnace_assets, { "collapse_small" }),
    MakePlacer("xd_liandanlu_placer", "xd_liandanlu", "xd_liandanlu", "idle")
