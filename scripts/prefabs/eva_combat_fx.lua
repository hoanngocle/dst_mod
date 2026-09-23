local Common = require "util/eva_combat_common"
local SkillDamage = require "util/eva_skill_damage"

local assets = {
    Asset("ANIM", "anim/eva_scythe.zip"),
    Asset("ANIM", "anim/lavaarena_shadow_lunge_fx.zip"),
}

local function AddFxTags(inst)
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")
end

local function ConfigureScythe(inst, scale, alpha)
    inst.AnimState:SetBank("eva_scythe")
    inst.AnimState:SetBuild("eva_scythe")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetMultColour(0.72, 0.46, 1, alpha or 1)
    inst.AnimState:SetAddColour(0.18, 0.06, 0.3, 0)
    inst.AnimState:SetLightOverride(0.7)
    inst.Transform:SetScale(scale, scale, scale)
end

local function melee_wave_fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    AddFxTags(inst)
    inst.Transform:SetEightFaced()
    inst.AnimState:SetBank("lavaarena_shadow_lunge_fx")
    inst.AnimState:SetBuild("lavaarena_shadow_lunge_fx")
    inst.AnimState:PlayAnimation("curve", true)
    inst.AnimState:SetMultColour(0.72, 0.56, 1, 0.9)
    inst.AnimState:SetAddColour(0.22, 0.12, 0.34, 0)
    inst.AnimState:SetLightOverride(0.75)
    inst.AnimState:SetFinalOffset(1)
    inst.Transform:SetScale(1.25, 1.25, 1.25)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end

    inst.entity:SetCanSleep(false)
    inst.persists = false
    inst.owner = nil
    inst.owner_component = nil
    inst.rotation = 0
    inst.hit_targets = {}
    inst.update_task = nil
    inst.timeout_task = nil

    local function TryHitTargets()
        if not Common.CanOwnerRemain(inst.owner) then
            inst:Remove()
            return false
        end
        local x, _, z = inst.Transform:GetWorldPosition()
        for _, target in ipairs(Common.FindTargetsAt(
                inst.owner, x, z, Common.MELEE_WAVE_RADIUS)) do
            if not inst:IsValid() or not Common.CanOwnerRemain(inst.owner) then
                return false
            end
            if inst.hit_targets[target] == nil
                and Common.IsValidTarget(inst.owner, target) then
                inst.hit_targets[target] = true
                SkillDamage.Apply(inst.owner, target, Common.MELEE_WAVE_DAMAGE, "eva_melee_wave")
                if not inst:IsValid() or not Common.CanOwnerRemain(inst.owner) then
                    return false
                end
            end
        end
        return true
    end

    local function Update()
        if not TryHitTargets() then return end
        local x, y, z = inst.Transform:GetWorldPosition()
        local theta = inst.rotation * DEGREES
        local step = Common.MELEE_WAVE_SPEED * FRAMES
        inst.Transform:SetPosition(
            x + math.cos(theta) * step,
            y,
            z - math.sin(theta) * step)
    end

    function inst:Launch(owner, owner_component, rotation)
        if self.owner ~= nil or not Common.CanOwnerRemain(owner) then return false end
        self.owner = owner
        self.owner_component = owner_component
        self.rotation = rotation or self.Transform:GetRotation()
        self.update_task = self:DoPeriodicTask(FRAMES, Update, 0)
        self.timeout_task = self:DoTaskInTime(Common.MELEE_WAVE_LIFETIME, self.Remove)
        return true
    end

    inst.OnRemoveEntity = function(self)
        if self.update_task ~= nil then self.update_task:Cancel() end
        if self.timeout_task ~= nil then self.timeout_task:Cancel() end
        local component = self.owner_component
        self.owner = nil
        self.owner_component = nil
        if component ~= nil then component:_OnWaveRemoved(self) end
    end
    return inst
end

local DAYDU_PROJECTILE_SPEED = 20
local DAYDU_PROJECTILE_HIT_DISTANCE = 0.55
local DAYDU_PROJECTILE_LIFETIME = 2

local function daydu_projectile_fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    AddFxTags(inst)
    ConfigureScythe(inst, 1.05, 0.95)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end

    inst.entity:SetCanSleep(false)
    inst.persists = false
    inst.owner = nil
    inst.target = nil
    inst.owner_component = nil
    inst.update_task = nil
    inst.timeout_task = nil

    local function RemoveProjectile()
        if inst:IsValid() then inst:Remove() end
    end

    local function Impact()
        local owner = inst.owner
        local target = inst.target
        if Common.CanOwnerRemain(owner)
            and Common.IsValidTarget(owner, target)
            and Common.CanAcceptDayduMark(target) then
            target:AddDebuff(Common.DAYDU_DEBUFF_NAME, Common.DAYDU_DEBUFF_PREFAB)
            local fx = SpawnPrefab("eva_daydu_hit_fx")
            if fx ~= nil then fx.Transform:SetPosition(target.Transform:GetWorldPosition()) end
        end
        RemoveProjectile()
    end

    local function Update()
        if not Common.CanOwnerRemain(inst.owner)
            or not Common.IsValidTarget(inst.owner, inst.target)
            or not Common.CanAcceptDayduMark(inst.target) then
            RemoveProjectile()
            return
        end
        local x, y, z = inst.Transform:GetWorldPosition()
        local tx, ty, tz = inst.target.Transform:GetWorldPosition()
        local dx, dz = tx - x, tz - z
        local distance = math.sqrt(dx * dx + dz * dz)
        local step = DAYDU_PROJECTILE_SPEED * FRAMES
        if distance <= DAYDU_PROJECTILE_HIT_DISTANCE or step >= distance then
            inst.Transform:SetPosition(tx, ty, tz)
            Impact()
            return
        end
        inst.Transform:SetRotation(inst:GetAngleToPoint(tx, ty, tz))
        inst.Transform:SetPosition(x + dx / distance * step, y, z + dz / distance * step)
    end

    function inst:Launch(owner, target, owner_component)
        if self.owner ~= nil or not Common.CanOwnerRemain(owner)
            or not Common.IsValidTarget(owner, target) then
            return false
        end
        self.owner = owner
        self.target = target
        self.owner_component = owner_component
        self.Transform:SetPosition(owner.Transform:GetWorldPosition())
        self.update_task = self:DoPeriodicTask(FRAMES, Update, 0)
        self.timeout_task = self:DoTaskInTime(DAYDU_PROJECTILE_LIFETIME, RemoveProjectile)
        return true
    end

    inst.OnRemoveEntity = function(self)
        if self.update_task ~= nil then self.update_task:Cancel() end
        if self.timeout_task ~= nil then self.timeout_task:Cancel() end
        local component = self.owner_component
        self.owner = nil
        self.target = nil
        self.owner_component = nil
        if component ~= nil then component:_OnProjectileRemoved(self) end
    end
    return inst
end

local function daydu_hit_fx_fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    AddFxTags(inst)
    ConfigureScythe(inst, 1.45, 0.8)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end
    inst.persists = false
    inst:DoTaskInTime(0.45, inst.Remove)
    return inst
end

local function daydu_debuff_fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    AddFxTags(inst)
    inst:AddTag("CLASSIFIED")
    ConfigureScythe(inst, 0.48, 0.62)
    inst.Transform:SetPosition(0, 1.9, 0)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end

    inst.persists = false
    inst.expiry_task = nil
    inst.target = nil
    inst.death_callback = nil

    local function CancelExpiry()
        if inst.expiry_task ~= nil then
            inst.expiry_task:Cancel()
            inst.expiry_task = nil
        end
    end

    local function ScheduleExpiry()
        CancelExpiry()
        inst.expiry_task = inst:DoTaskInTime(Common.DAYDU_MARK_DURATION, function()
            inst.expiry_task = nil
            if inst.components.debuff ~= nil then inst.components.debuff:Stop() end
        end)
    end

    local function OnAttached(_, target)
        inst.target = target
        inst.entity:SetParent(target.entity)
        inst.Transform:SetPosition(0, 1.9, 0)
        if target.components.combat ~= nil then
            target.components.combat.externaldamagetakenmultipliers:SetModifier(
                inst, Common.DAYDU_DAMAGE_TAKEN_MULT, Common.DAYDU_DEBUFF_NAME)
        end
        inst.death_callback = function()
            if inst.components.debuff ~= nil then inst.components.debuff:Stop() end
        end
        inst:ListenForEvent("death", inst.death_callback, target)
        ScheduleExpiry()
    end

    local function OnExtended()
        ScheduleExpiry()
    end

    local function OnDetached(_, target)
        CancelExpiry()
        if target ~= nil then
            if inst.death_callback ~= nil then
                inst:RemoveEventCallback("death", inst.death_callback, target)
            end
            if target.components ~= nil and target.components.combat ~= nil then
                target.components.combat.externaldamagetakenmultipliers:RemoveModifier(
                    inst, Common.DAYDU_DEBUFF_NAME)
            end
        end
        inst.target = nil
        inst.death_callback = nil
        inst:Remove()
    end

    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(OnAttached)
    inst.components.debuff:SetExtendedFn(OnExtended)
    inst.components.debuff:SetDetachedFn(OnDetached)
    return inst
end

return Prefab("eva_melee_wave_fx", melee_wave_fn, assets),
    Prefab("eva_daydu_projectile", daydu_projectile_fn, assets, {
        "eva_daydu_hit_fx", "eva_daydu_debuff",
    }),
    Prefab("eva_daydu_hit_fx", daydu_hit_fx_fn, assets),
    Prefab("eva_daydu_debuff", daydu_debuff_fn, assets)
