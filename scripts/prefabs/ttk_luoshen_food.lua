local foods = require("ttk_luoshen_fooddefs")

local function MakeFood(name, data)
    local assets = {
        Asset("ANIM", "anim/" .. data.overridebuild .. ".zip"),
        Asset("ATLAS", "images/inventoryimages/" .. name .. ".xml"),
        Asset("IMAGE", "images/inventoryimages/" .. name .. ".tex"),
    }
    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()
        MakeInventoryPhysics(inst)
        inst.AnimState:SetBank(data.overridebuild)
        inst.AnimState:SetBuild(data.overridebuild)
        inst.AnimState:PlayAnimation("idle")
        inst:AddTag("preparedfood")
        inst:AddTag("quickeat")
        MakeInventoryFloatable(inst)
        inst.entity:SetPristine()
        if not TheWorld.ismastersim then return inst end
        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.atlasname = "images/inventoryimages/" .. name .. ".xml"
        inst:AddComponent("edible")
        inst.components.edible.foodtype = data.foodtype
        inst.components.edible.healthvalue = data.health
        inst.components.edible.hungervalue = data.hunger
        inst.components.edible.sanityvalue = data.sanity
        inst.components.edible:SetOnEatenFn(data.oneatenfn)
        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
        inst:AddComponent("perishable")
        inst.components.perishable:SetPerishTime(data.perishtime)
        inst.components.perishable:StartPerishing()
        inst.components.perishable.onperishreplacement = "spoiled_food"
        inst:AddComponent("bait")
        inst:AddComponent("tradable")
        MakeSmallBurnable(inst)
        MakeSmallPropagator(inst)
        MakeHauntableLaunchAndPerish(inst)
        return inst
    end
    return Prefab(name, fn, assets, {"spoiled_food", "ttk_luoxiang_pengrou_buff"})
end

local function OnAttack(inst, owner, data)
    local target = data ~= nil and data.target or nil
    if owner.components.health ~= nil and not owner.components.health:IsDead()
        and target ~= nil and target:IsValid() and target.components.health ~= nil
        and not target.components.health:IsDead() then
        owner.components.health:DoDelta(2, false, "ttk_luoxiang_pengrou_buff", true, owner)
    end
end

local function BuffFn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:Hide()
    inst:AddTag("CLASSIFIED")
    inst.persists = false
    if not TheWorld.ismastersim then
        inst:DoTaskInTime(0, inst.Remove)
        return inst
    end
    inst:AddComponent("debuff")
    inst.components.debuff.keepondespawn = true
    inst.components.debuff:SetAttachedFn(function(self, target)
        self.entity:SetParent(target.entity)
        self.Transform:SetPosition(0, 0, 0)
        -- Event callbacks run with the listening buff as their first argument;
        -- close over the attached player instead of treating that buff as owner.
        self._attack = function(_, data) OnAttack(self, target, data) end
        self:ListenForEvent("onattackother", self._attack, target)
        self:ListenForEvent("death", function() self.components.debuff:Stop() end, target)
    end)
    inst.components.debuff:SetExtendedFn(function(self)
        self.components.timer:StopTimer("buffover")
        self.components.timer:StartTimer("buffover", 480)
    end)
    inst.components.debuff:SetDetachedFn(function(self, target)
        if self._attack ~= nil then self:RemoveEventCallback("onattackother", self._attack, target) end
        self:Remove()
    end)
    inst:AddComponent("timer")
    inst.components.timer:StartTimer("buffover", 480)
    inst:ListenForEvent("timerdone", function(self, data)
        if data.name == "buffover" then self.components.debuff:Stop() end
    end)
    return inst
end

return MakeFood("ttk_luoshen_qingshu", foods.ttk_luoshen_qingshu),
    MakeFood("ttk_luoxiang_pengrou", foods.ttk_luoxiang_pengrou),
    Prefab("ttk_luoxiang_pengrou_buff", BuffFn)
