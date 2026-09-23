local Common = require "util/eva_fox_common"
local SkillDamage = require "util/eva_skill_damage"

local assets = {
    Asset("ANIM", "anim/eva_fox.zip"),
    Asset("ANIM", "anim/eva_fox_fire.zip"),
}

local function AddFxTags(inst)
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")
end

local function MakeFoxFx(name, animation)
    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()
        AddFxTags(inst)
        inst.Transform:SetTwoFaced()
        inst.Transform:SetScale(0.8, 0.8, 0.8)
        inst.AnimState:SetBank("eva_fox")
        inst.AnimState:SetBuild("eva_fox")
        inst.AnimState:PlayAnimation(animation)
        inst.AnimState:SetMultColour(0.82, 0.72, 1, 0.72)
        inst.AnimState:SetLightOverride(0.3)
        inst.AnimState:SetFinalOffset(1)
        inst.entity:SetPristine()
        if not TheWorld.ismastersim then return inst end
        inst.persists = false
        inst:ListenForEvent("animover", inst.Remove)
        inst:DoTaskInTime(1.5, function() inst:Remove() end)
        return inst
    end
    return Prefab(name, fn, assets)
end

local function ApplySleep(target)
    if not Common.CanSleep(target) then return end
    local rider = target.components.rider
    if rider ~= nil and rider:IsRiding() then
        local mount = rider:GetMount()
        if mount ~= nil then
            mount:PushEvent("ridersleep", {
                sleepiness = Common.SLEEPINESS,
                sleeptime = Common.SLEEP_DURATION,
            })
        end
    end
    if target.components.sleeper ~= nil then
        target.components.sleeper:AddSleepiness(
            Common.SLEEPINESS, Common.SLEEP_DURATION)
    elseif target.components.grogginess ~= nil then
        target.components.grogginess:AddGrogginess(
            Common.SLEEPINESS, Common.SLEEP_DURATION)
    end
end

local function fire_fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    AddFxTags(inst)
    inst.AnimState:SetBank("eva_fox_fire")
    inst.AnimState:SetBuild("eva_fox_fire")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetMultColour(0.68, 0.48, 1, 0.9)
    inst.AnimState:SetAddColour(0.18, 0.10, 0.32, 0)
    inst.AnimState:SetLightOverride(0.45)
    inst.Transform:SetScale(3, 3, 3)
    inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end

    inst.persists = false
    inst.owner = nil
    inst.owner_component = nil
    inst.tasks = {}
    inst.stopped = false

    function inst:_OwnerValid()
        return self.owner ~= nil and Common.CanOwnerRemain(self.owner)
            and not self.owner:HasTag("playerghost")
    end

    function inst:_Tick(index)
        if self.stopped or not self:_OwnerValid() then self:Remove(); return end
        if index == 1 then
            local health = self.owner.components.health
            health:DoDelta(health:GetMaxWithPenalty() * Common.HEAL_FRACTION,
                true, "eva_fox_fire_heal")
        end
        local x, _, z = self.Transform:GetWorldPosition()
        local owner = self.owner
        for _, target in ipairs(Common.FindTargetsAt(owner, x, z)) do
            SkillDamage.Apply(owner, target, Common.FIRE_DAMAGE, "eva_fox_fire")
            if self.stopped or not owner:IsValid() then return end
            owner:PushEvent("onareaattackother", {target = target})
            if index == Common.FIRE_TICKS
                and Common.IsValidTarget(owner, target) then
                ApplySleep(target)
            end
        end
    end

    function inst:Start(owner, component)
        if self.owner ~= nil or owner == nil or not Common.CanOwnerRemain(owner) then
            return false
        end
        self.owner = owner
        self.owner_component = component
        self._ondeath = function() self:Remove() end
        self._onghost = function() self:Remove() end
        self._onownerremove = function() self:Remove() end
        self:ListenForEvent("death", self._ondeath, owner)
        self:ListenForEvent("ms_becameghost", self._onghost, owner)
        self:ListenForEvent("onremove", self._onownerremove, owner)
        self:_Tick(1)
        for index = 2, Common.FIRE_TICKS do
            self.tasks[index] = self:DoTaskInTime(
                (index - 1) * Common.FIRE_PERIOD, function() self:_Tick(index) end)
        end
        self.tasks.remove = self:DoTaskInTime(
            Common.FIRE_LIFETIME, function() self:Remove() end)
        return true
    end

    inst.OnRemoveEntity = function(self)
        if self.stopped then return end
        self.stopped = true
        for key, task in pairs(self.tasks) do task:Cancel(); self.tasks[key] = nil end
        local owner = self.owner
        if owner ~= nil then
            self:RemoveEventCallback("death", self._ondeath, owner)
            self:RemoveEventCallback("ms_becameghost", self._onghost, owner)
            self:RemoveEventCallback("onremove", self._onownerremove, owner)
        end
        local component = self.owner_component
        self.owner, self.owner_component = nil, nil
        if component ~= nil then component:_OnFireRemoved(self) end
    end
    return inst
end

return MakeFoxFx("eva_fox_depart_fx", "in"),
    MakeFoxFx("eva_fox_arrive_fx", "out"),
    Prefab("eva_fox_fire_fx", fire_fn, assets)
