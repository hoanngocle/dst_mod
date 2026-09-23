local ITEM_DEFS = {
    ttk_pog_tail = "xd_pog_tail",
    ttk_spider_leg = "xd_spider_leg",
    ttk_npxsz = "xd_npxsz",
}

local prefabs = {}

local function MakeItem(name, build)
    local assets = {
        Asset("ANIM", "anim/" .. name .. ".zip"),
        Asset("ATLAS", "images/inventoryimages/" .. name .. ".xml"),
        Asset("IMAGE", "images/inventoryimages/" .. name .. ".tex"),
    }
    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()
        inst.AnimState:SetBank(build)
        inst.AnimState:SetBuild(build)
        inst.AnimState:PlayAnimation("idle")
        MakeInventoryPhysics(inst)
        MakeInventoryFloatable(inst)
        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end
        inst:AddComponent("tradable")
        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.atlasname = "images/inventoryimages/" .. name .. ".xml"
        inst.components.inventoryitem:ChangeImageName(name)
        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM
        MakeHauntableLaunch(inst)
        return inst
    end
    return Prefab(name, fn, assets)
end

for name, build in pairs(ITEM_DEFS) do
    table.insert(prefabs, MakeItem(name, build))
end

local puff_assets = { Asset("ANIM", "anim/ttk_spider_puff.zip") }
local function MakePuff(name, front)
    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()
        inst.AnimState:SetBank("xd_spider_puff")
        inst.AnimState:SetBuild("xd_spider_puff")
        inst.AnimState:PlayAnimation("forage_out")
        inst.AnimState:SetScale(1.5, 1.5, 1.5)
        inst.AnimState:Hide(front and "back" or "front")
        if front then
            inst.AnimState:SetFinalOffset(2)
        end
        inst:AddTag("FX")
        inst:AddTag("NOCLICK")
        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end
        inst.persists = false
        inst:ListenForEvent("animover", inst.Remove)
        return inst
    end
    return Prefab(name, fn, puff_assets)
end
table.insert(prefabs, MakePuff("ttk_spider_puff_front", true))
table.insert(prefabs, MakePuff("ttk_spider_puff_back", false))

local function MakeTimedDebuff(name, duration, startfn, stopfn, extendfn)
    local function OnDetached(inst, target)
        if stopfn ~= nil and target ~= nil and target:IsValid() then
            stopfn(inst, target)
        end
        inst:Remove()
    end
    local function OnAttached(inst, target)
        inst.entity:SetParent(target.entity)
        inst.Transform:SetPosition(0, 0, 0)
        inst._target = target
        if startfn ~= nil then
            startfn(inst, target)
        end
        inst.components.timer:StartTimer("expire", duration)
        inst:ListenForEvent("death", function() inst.components.debuff:Stop() end, target)
    end
    local function OnExtended(inst, target)
        inst.components.timer:StopTimer("expire")
        inst.components.timer:StartTimer("expire", duration)
        if extendfn ~= nil then
            extendfn(inst, target)
        end
    end
    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddNetwork()
        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end
        inst.persists = false
        inst:AddComponent("debuff")
        inst.components.debuff:SetAttachedFn(OnAttached)
        inst.components.debuff:SetDetachedFn(OnDetached)
        inst.components.debuff:SetExtendedFn(OnExtended)
        inst:AddComponent("timer")
        inst:ListenForEvent("timerdone", function(_, data)
            if data ~= nil and data.name == "expire" then
                inst.components.debuff:Stop()
            end
        end)
        return inst
    end
    return Prefab(name, fn)
end

table.insert(prefabs, MakeTimedDebuff(
    "ttk_slow_buff", 12,
    function(inst, target)
        if target.components.locomotor ~= nil then
            target.components.locomotor:SetExternalSpeedMultiplier(target, "ttk_slow_buff", .7)
        end
        local fx = SpawnPrefab("ttk_slow_buff_ent")
        if fx ~= nil then
            fx:SetOwner(target)
            inst._fx = fx
        end
    end,
    function(inst, target)
        if target.components.locomotor ~= nil then
            target.components.locomotor:RemoveExternalSpeedMultiplier(target, "ttk_slow_buff")
        end
        if inst._fx ~= nil and inst._fx:IsValid() then
            inst._fx:Remove()
        end
    end
))

local function PogFireTick(inst, target)
    if target == nil or not target:IsValid() or target.components.combat == nil then
        return
    end
    local victim = target.components.combat.target
    if victim == nil or not require("ttk_batch19_houseutil").CanAttackTarget(target, victim) then
        return
    end
    local fx = require("ttk_batch19_houseutil").SpawnAt("ttk_pog_fire", victim, nil, Vector3(0, 4, 0))
    if fx ~= nil and fx.Physics ~= nil then
        fx.Physics:SetMotorVel(0, -4 / .7, 0)
        fx.damagefn = function()
            if victim:IsValid() and victim.components.combat ~= nil then
                victim.components.combat:GetAttacked(target, 75)
            end
        end
    end
    inst._attacks = (inst._attacks or 0) + 1
    if inst._attacks >= 3 then
        target:RemoveDebuff("ttk_pog_fire_buff")
    end
end

table.insert(prefabs, MakeTimedDebuff(
    "ttk_pog_fire_buff", 14,
    function(inst, target)
        inst._attacks = 0
        inst._task = inst:DoPeriodicTask(4, PogFireTick, .2, target)
    end,
    function(inst, target)
        if inst._task ~= nil then
            inst._task:Cancel()
        end
        if target.components.timer ~= nil then
            target.components.timer:StopTimer("skill2")
            target.components.timer:StartTimer("skill2", 7)
        end
    end
))

return unpack(prefabs)
