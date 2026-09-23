local Common = require "util/eva_combat_common"

local EvaMeleeWave = Class(function(self, inst)
    self.inst = inst
    self.hit_count = 0
    self.pending = nil
    self.waves = {}

    self._onattackother = function(_, data) self:_OnAttackOther(data) end
    self._onhitother = function(_, data) self:_OnHitOther(data) end
    self._onmissother = function() self:_ClearPending() end
    self._ondeath = function() self:Stop("death") end
    self._onghost = function() self:Stop("ghost") end
    self._onremove = function() self:Stop("remove") end

    inst:ListenForEvent("onattackother", self._onattackother)
    inst:ListenForEvent("onhitother", self._onhitother)
    inst:ListenForEvent("onmissother", self._onmissother)
    inst:ListenForEvent("death", self._ondeath)
    inst:ListenForEvent("ms_becameghost", self._onghost)
    inst:ListenForEvent("onremove", self._onremove)
end)

function EvaMeleeWave:_ClearPending()
    local pending = self.pending
    self.pending = nil
    if pending ~= nil and pending.task ~= nil then pending.task:Cancel() end
end

function EvaMeleeWave:_OnAttackOther(data)
    self:_ClearPending()
    if not Common.IsMeleeAttackCandidate(self.inst, data) then return end

    local pending = {target = data.target, weapon = data.weapon}
    self.pending = pending
    pending.task = self.inst:DoTaskInTime(0, function()
        if self.pending == pending then self.pending = nil end
    end)
end

function EvaMeleeWave:_SpawnWave()
    if not Common.CanOwnerRemain(self.inst) then return false end
    local wave = SpawnPrefab("eva_melee_wave_fx")
    if wave == nil then return false end

    local x, _, z = self.inst.Transform:GetWorldPosition()
    local rotation = self.inst.Transform:GetRotation()
    local theta = rotation * DEGREES
    wave.Transform:SetPosition(
        x + math.cos(theta) * Common.MELEE_WAVE_OFFSET,
        0,
        z - math.sin(theta) * Common.MELEE_WAVE_OFFSET)
    wave.Transform:SetRotation(rotation)
    self.waves[wave] = true
    if wave.Launch == nil or not wave:Launch(self.inst, self, rotation) then
        self.waves[wave] = nil
        if wave:IsValid() then wave:Remove() end
        return false
    end
    return true
end

function EvaMeleeWave:_OnHitOther(data)
    local pending = self.pending
    if not Common.CanOwnerRemain(self.inst) then
        self:_ClearPending()
        return
    end
    if not Common.IsMatchingSuccessfulHit(pending, data) then
        return
    end
    self:_ClearPending()

    self.hit_count = self.hit_count + 1
    if self.hit_count >= Common.MELEE_TRIGGER_HITS then
        self.hit_count = 0
        self:_SpawnWave()
    end
end

function EvaMeleeWave:_OnWaveRemoved(wave)
    self.waves[wave] = nil
end

function EvaMeleeWave:Stop(reason)
    self:_ClearPending()
    self.hit_count = 0
    local stopped = false
    for wave in pairs(self.waves) do
        self.waves[wave] = nil
        if wave:IsValid() then
            stopped = true
            wave:Remove()
        end
    end
    return stopped, reason
end

function EvaMeleeWave:OnSave()
    return nil
end

function EvaMeleeWave:OnLoad()
    self:Stop("load")
end

function EvaMeleeWave:OnRemoveFromEntity()
    self:Stop("component_removed")
    self.inst:RemoveEventCallback("onattackother", self._onattackother)
    self.inst:RemoveEventCallback("onhitother", self._onhitother)
    self.inst:RemoveEventCallback("onmissother", self._onmissother)
    self.inst:RemoveEventCallback("death", self._ondeath)
    self.inst:RemoveEventCallback("ms_becameghost", self._onghost)
    self.inst:RemoveEventCallback("onremove", self._onremove)
end

return EvaMeleeWave
