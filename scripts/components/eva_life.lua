local Common = require "util/eva_life_common"
local SkillDamage = require "util/eva_skill_damage"

local EvaLife = Class(function(self, inst)
    self.inst = inst
    self.active = false
    self.cooldown_end = 0
    self.active_end = 0
    self.shield = 0
    self.tasks = {}
    self.projectiles = {}
    self.aura_fx = nil
    self.shield_fx = nil
    self.shield_token = nil
    self.shield_wrapper = nil
    self.previous_delta_modifier = nil

    self._ondeath = function() self:Stop("death") end
    self._onghost = function() self:Stop("ghost") end
    self._onremove = function() self:Stop("remove") end
    inst:ListenForEvent("death", self._ondeath)
    inst:ListenForEvent("ms_becameghost", self._onghost)
    inst:ListenForEvent("onremove", self._onremove)
end)

local function CancelTask(task)
    if task ~= nil then task:Cancel() end
end

local function RemoveEntity(entity)
    if entity ~= nil and entity:IsValid() then entity:Remove() end
end

function EvaLife:IsActive()
    return self.active
end

function EvaLife:GetCooldownRemaining()
    return math.max(0, self.cooldown_end - GetTime())
end

function EvaLife:GetShieldRemaining()
    return math.max(0, self.shield)
end

function EvaLife:_Say(message)
    local talker = self.inst.components.talker
    if talker ~= nil then talker:Say(message) end
end

function EvaLife:_RemoveShieldFx()
    RemoveEntity(self.shield_fx)
    self.shield_fx = nil
end

function EvaLife:_ReleaseShield()
    local health = self.inst.components.health
    local wrapper = self.shield_wrapper
    if health ~= nil and wrapper ~= nil and health.deltamodifierfn == wrapper then
        health.deltamodifierfn = self.previous_delta_modifier
    end
    self.shield_token = nil
    self.shield_wrapper = nil
    self.previous_delta_modifier = nil
    self.shield = 0
    self:_RemoveShieldFx()
end

function EvaLife:_InstallShield()
    local health = self.inst.components.health
    if health == nil then return end

    self.shield = health.maxhealth * Common.SHIELD_FRACTION
    local previous = health.deltamodifierfn
    local token = {}
    local wrapper
    wrapper = function(inst, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
        local adjusted = amount
        if previous ~= nil then
            adjusted = previous(inst, amount, overtime, cause,
                ignore_invincible, afflicter, ignore_absorb)
            if adjusted == nil then adjusted = amount end
        end
        if adjusted >= 0 or not self.active
            or self.shield_token ~= token or self.shield <= 0 then
            return adjusted
        end

        local absorbed = math.min(self.shield, -adjusted)
        self.shield = self.shield - absorbed
        adjusted = adjusted + absorbed
        if self.shield <= 0 then
            self.shield = 0
            if health.deltamodifierfn == wrapper then
                health.deltamodifierfn = previous
            end
            if self.shield_token == token then
                self.shield_token = nil
                self.shield_wrapper = nil
                self.previous_delta_modifier = nil
                self:_RemoveShieldFx()
            end
        end
        return adjusted
    end

    self.shield_token = token
    self.shield_wrapper = wrapper
    self.previous_delta_modifier = previous
    health.deltamodifierfn = wrapper
end

function EvaLife:_Heal()
    if not self.active or not Common.CanRemainActive(self.inst) then return end
    local health = self.inst.components.health
    health:DoDelta(health.maxhealth * Common.HEAL_FRACTION, true, "eva_life_heal")
    local fx = SpawnPrefab("eva_life_heal_fx")
    if fx ~= nil then
        fx.entity:SetParent(self.inst.entity)
        fx.Transform:SetPosition(0, 0, 0)
    end
end

function EvaLife:_AuraTick()
    if not self.active or GetTime() >= self.active_end then return end
    for _, target in ipairs(Common.FindTargets(self.inst, Common.AURA_RADIUS)) do
        if Common.IsValidTarget(self.inst, target, Common.AURA_RADIUS) then
            SkillDamage.Apply(self.inst, target, Common.AURA_DAMAGE, "eva_life_aura")
        end
    end
end

function EvaLife:_ProjectileTick()
    if not self.active or GetTime() >= self.active_end then return end
    local target = Common.SelectTarget(self.inst, Common.PROJECTILE_RANGE)
    if target == nil then return end
    local projectile = SpawnPrefab("eva_life_projectile")
    if projectile == nil then return end
    self.projectiles[projectile] = true
    projectile:Launch(self.inst, target, self)
end

function EvaLife:_ValidateActive()
    if self.active and not Common.CanRemainActive(self.inst) then
        self:Stop("invalid_state")
    end
end

function EvaLife:_OnProjectileRemoved(projectile)
    self.projectiles[projectile] = nil
end

function EvaLife:Activate()
    if not require("util/eva_progression").Check(self.inst, "life") then return false, "level_locked" end
    if self.active then
        self:_Say("Sinh Chi Hoa đang hoạt động.")
        return false, "active"
    end
    local remaining = self:GetCooldownRemaining()
    if remaining > 0 then
        self:_Say("Sinh Chi Hoa hồi sau " .. tostring(math.ceil(remaining)) .. " giây.")
        return false, "cooldown"
    end
    if not Common.CanActivate(self.inst) then
        return false, "invalid_state"
    end
    local souls = self.inst.components.eva_souls
    if souls == nil or souls.current < Common.SOUL_COST then
        self:_Say("Cần 10 Hồn Lực để dùng Sinh Chi Hoa.")
        return false, "insufficient_souls"
    end

    self.active = true
    self.active_end = GetTime() + Common.DURATION
    self.cooldown_end = GetTime() + Common.COOLDOWN
    souls:DoDelta(-Common.SOUL_COST)
    self:_InstallShield()

    self.aura_fx = SpawnPrefab("eva_life_aura_fx")
    if self.aura_fx ~= nil then
        self.aura_fx.entity:SetParent(self.inst.entity)
        self.aura_fx.Transform:SetPosition(0, 0, 0)
    end
    self.shield_fx = SpawnPrefab("eva_life_shield_fx")
    if self.shield_fx ~= nil then
        self.shield_fx.entity:SetParent(self.inst.entity)
        self.shield_fx.Transform:SetPosition(0, 0, 0)
    end

    self.tasks.end_task = self.inst:DoTaskInTime(Common.DURATION, function()
        self:Stop("expired")
    end)
    for index = 2, #Common.HEAL_TIMES do
        local delay = Common.HEAL_TIMES[index]
        self.tasks["heal_" .. tostring(delay)] = self.inst:DoTaskInTime(delay, function()
            self:_Heal()
        end)
    end
    self.tasks.projectile = self.inst:DoPeriodicTask(
        Common.PROJECTILE_PERIOD, function() self:_ProjectileTick() end,
        Common.PROJECTILE_PERIOD)
    self.tasks.aura = self.inst:DoPeriodicTask(
        Common.AURA_PERIOD, function() self:_AuraTick() end,
        Common.AURA_PERIOD)
    self.tasks.validate = self.inst:DoPeriodicTask(
        0.25, function() self:_ValidateActive() end, 0.25)

    self:_Heal()
    self:_Say("Sinh Chi Hoa!")
    return true, "activated"
end

function EvaLife:Stop(reason)
    if not self.active and self.shield_wrapper == nil then return false end
    self.active = false
    self.active_end = 0
    for key, task in pairs(self.tasks) do
        CancelTask(task)
        self.tasks[key] = nil
    end
    for projectile in pairs(self.projectiles) do
        RemoveEntity(projectile)
        self.projectiles[projectile] = nil
    end
    RemoveEntity(self.aura_fx)
    self.aura_fx = nil
    self:_ReleaseShield()
    return true, reason
end

function EvaLife:OnSave()
    local remaining = self:GetCooldownRemaining()
    return remaining > 0 and {cooldown = remaining} or nil
end

function EvaLife:OnLoad(data)
    self:Stop("load")
    local remaining = data ~= nil and tonumber(data.cooldown) or 0
    self.cooldown_end = GetTime() + math.max(0, math.min(Common.COOLDOWN, remaining or 0))
end

function EvaLife:OnRemoveFromEntity()
    self:Stop("component_removed")
    self.inst:RemoveEventCallback("death", self._ondeath)
    self.inst:RemoveEventCallback("ms_becameghost", self._onghost)
    self.inst:RemoveEventCallback("onremove", self._onremove)
end

return EvaLife
