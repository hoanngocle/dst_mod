local RankDefs = require("guild/hh_rank_defs")

local REGEN_CAUSE = "hh_death_threshold_regen"

local function GetDeathThresholdTuning()
    return TUNING.HH_DEATH_THRESHOLD or {}
end

local function IsValidLivingHunter(inst)
    return inst ~= nil
        and inst:IsValid()
        and inst:HasTag("player")
        and not inst:HasTag("playerghost")
        and not inst:HasTag("INLIMBO")
        and inst.components ~= nil
        and inst.components.health ~= nil
        and not inst.components.health:IsDead()
end

local function HasRankS(inst)
    local rank = inst ~= nil and inst.components ~= nil and inst.components.hh_rank or nil
    return rank ~= nil and rank:GetRank() >= RankDefs.RANK.S
end

local HHDeathThreshold = Class(function(self, inst)
    self.inst = inst
    self.ready_time = 0
    self.cooldown_total = self:GetCooldown()
    self.regen_task = nil
    self.regen_ticks = 0
    self._activation_serial = 0
    self._removing = false
end)

function HHDeathThreshold:GetCooldown()
    return math.max(0, tonumber(GetDeathThresholdTuning().BASE_COOLDOWN) or 480)
end

function HHDeathThreshold:GetRemainingCooldown(now)
    return math.max(0, math.ceil(self.ready_time - (now or GetTime())))
end

function HHDeathThreshold:SyncCooldown(now)
    now = now or GetTime()
    if self.inst.hh_death_threshold_cd ~= nil then
        self.inst.hh_death_threshold_cd:set(self:GetRemainingCooldown(now))
    end
end

function HHDeathThreshold:CanArmDamageGuard()
    if self._removing
        or TheWorld == nil
        or not TheWorld.ismastersim
        or not IsValidLivingHunter(self.inst)
        or not HasRankS(self.inst)
        or GetTime() < self.ready_time then
        return false
    end

    local health = self.inst.components.health
    local max_health = tonumber(health.maxhealth) or 0
    local current_health = tonumber(health.currenthealth) or 0
    local ratio = tonumber(GetDeathThresholdTuning().TRIGGER_HEALTH_RATIO) or .90
    return max_health > 0 and current_health > 0 and current_health / max_health >= ratio
end

function HHDeathThreshold:ArmDamageGuard()
    if not self:CanArmDamageGuard() then
        return nil
    end
    return {
        component = self,
        activation_serial = self._activation_serial,
        prevented = false,
        consumed = false,
    }
end

function HHDeathThreshold:CanPreventDamageGuard(guard)
    return guard ~= nil
        and guard.component == self
        and not guard.prevented
        and guard.activation_serial == self._activation_serial
        and not self._removing
        and TheWorld ~= nil
        and TheWorld.ismastersim
        and IsValidLivingHunter(self.inst)
        and HasRankS(self.inst)
        and GetTime() >= self.ready_time
end

function HHDeathThreshold:MarkDamageGuardPrevented(guard)
    if not self:CanPreventDamageGuard(guard) then
        return false
    end
    guard.prevented = true
    guard.prevented_serial = self._activation_serial
    return true
end

function HHDeathThreshold:FinishDamageGuard(guard)
    if guard == nil or guard.component ~= self or guard.consumed
        or not guard.prevented
        or guard.prevented_serial ~= self._activation_serial then
        return false
    end

    guard.consumed = true
    local now = GetTime()
    if self._removing or not IsValidLivingHunter(self.inst)
        or not HasRankS(self.inst) or now < self.ready_time then
        return false
    end

    self._activation_serial = self._activation_serial + 1
    self.cooldown_total = self:GetCooldown()
    self.ready_time = now + self.cooldown_total
    self:SyncCooldown(now)
    self:StartRegen()
    return true
end

function HHDeathThreshold:StopRegen()
    if self.regen_task ~= nil then
        self.regen_task:Cancel()
        self.regen_task = nil
    end
    self.regen_ticks = 0
end

function HHDeathThreshold:ScheduleRegenTick()
    if self._removing or not IsValidLivingHunter(self.inst) then
        self:StopRegen()
        return
    end

    local interval = math.max(0, tonumber(GetDeathThresholdTuning().REGEN_INTERVAL) or .3)
    self.regen_task = self.inst:DoTaskInTime(interval, function(inst)
        self.regen_task = nil
        if self._removing or not IsValidLivingHunter(inst) then
            self:StopRegen()
            return
        end

        self.regen_ticks = self.regen_ticks + 1
        local health = inst.components.health
        local max_health = tonumber(health.maxhealth) or 0
        local heal_ratio = tonumber(GetDeathThresholdTuning().REGEN_MAX_HEALTH_RATIO) or .01
        if max_health > 0 then
            health:DoDelta(max_health * heal_ratio, false, REGEN_CAUSE)
        end

        local max_ticks = math.max(0, math.floor(
            tonumber(GetDeathThresholdTuning().REGEN_TICKS) or 33
        ))
        if self.regen_ticks >= max_ticks or not IsValidLivingHunter(inst) then
            self:StopRegen()
        else
            self:ScheduleRegenTick()
        end
    end)
end

function HHDeathThreshold:StartRegen()
    self:StopRegen()
    self:ScheduleRegenTick()
end

function HHDeathThreshold:OnSave()
    local remaining = math.max(0, self.ready_time - GetTime())
    if remaining > 0 then
        return { cooldown_remaining = remaining }
    end
    return nil
end

function HHDeathThreshold:OnLoad(data)
    self:StopRegen()
    self.ready_time = 0
    self.cooldown_total = self:GetCooldown()
    self._activation_serial = self._activation_serial + 1
    if type(data) == "table" then
        local remaining = math.max(0, tonumber(data.cooldown_remaining) or 0)
        self.ready_time = GetTime() + remaining
    end
    self:SyncCooldown()
end

function HHDeathThreshold:OnRemoveFromEntity()
    if self._removing then
        return
    end
    self._removing = true
    self:StopRegen()
end

return HHDeathThreshold
