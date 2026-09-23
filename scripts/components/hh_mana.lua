local HHMana = Class(function(self, inst)
    self.inst = inst
    self.current = 0
    self.max = 100
    self.regen_delay_end = 0
    self.regen_task = nil

    if TheWorld.ismastersim then
        self:RecalculateMax(true)
        self.regen_task = inst:DoPeriodicTask(TUNING.HH_MANA.REGEN_INTERVAL or 0.5, function()
            self:RegenTick()
        end)
    end
end)

function HHMana:Sync()
    if self.inst.hh_mana_current then self.inst.hh_mana_current:set(math.floor(self.current + 0.5)) end
    if self.inst.hh_mana_max then self.inst.hh_mana_max:set(math.floor(self.max + 0.5)) end
end

function HHMana:GetInt()
    return self.inst.components.hh_leveling and self.inst.components.hh_leveling.stat_int or 0
end

function HHMana:GetRegenPerSecond()
    local cfg = TUNING.HH_MANA
    return (cfg.BASE_REGEN or 1) + self:GetInt() * (cfg.REGEN_PER_INT or 0)
end

function HHMana:RecalculateMax(fill_initial)
    local cfg = TUNING.HH_MANA
    self.max = math.max(1, (cfg.BASE_MAX or 100) + self:GetInt() * (cfg.MAX_PER_INT or 0))
    if fill_initial then self.current = self.max else self.current = math.min(self.current, self.max) end
    self:Sync()
end

function HHMana:GetCurrent() return self.current end
function HHMana:GetMax() return self.max end
function HHMana:GetPercent() return self.max > 0 and self.current / self.max or 0 end
function HHMana:GetFinalCost(amount, reason)
    amount = math.max(0, tonumber(amount) or 0)
    local effects = self.inst.components.hh_dungeon_effects
    local multiplier = effects ~= nil and effects:GetManaCostMultiplier(reason) or 1
    return amount * multiplier
end

function HHMana:CanSpend(amount, reason)
    return self.current >= self:GetFinalCost(amount, reason)
end

function HHMana:DoDelta(amount)
    local old = self.current
    self.current = math.max(0, math.min(self.max, self.current + (tonumber(amount) or 0)))
    if self.current ~= old then self:Sync() end
    return self.current - old
end

function HHMana:Spend(amount, reason)
    amount = self:GetFinalCost(amount, reason)
    if self.current < amount then
        if self.inst.components.talker then self.inst.components.talker:Say("Không đủ Mana!") end
        return false
    end
    self:DoDelta(-amount)
    if amount > 0 then
        self.regen_delay_end = GetTime() + (TUNING.HH_MANA.REGEN_DELAY or 0)
    end
    self.inst:PushEvent("hh_mana_spent", {amount = amount, reason = reason})
    return true
end

function HHMana:RegenTick()
    if not self.inst:IsValid() or not self.inst.components.health or self.inst.components.health:IsDead()
        or self.inst:HasTag("playerghost") or self.current >= self.max
        or GetTime() < (self.regen_delay_end or 0) then return end
    local interval = TUNING.HH_MANA.REGEN_INTERVAL or 0.5
    self:DoDelta(self:GetRegenPerSecond() * interval)
end

function HHMana:OnSave()
    return {current = self.current}
end

function HHMana:OnLoad(data)
    local loaded_current = data and tonumber(data.current) or self.current
    self:RecalculateMax(false)
    self.current = math.max(0, math.min(self.max, loaded_current))
    self.regen_delay_end = 0
    self:Sync()

    -- Components are loaded independently. Reconcile after hh_leveling has restored stat_int.
    self.inst:DoTaskInTime(0, function(inst)
        if inst:IsValid() and inst.components.hh_mana == self then
            self:RecalculateMax(false)
            self.current = math.max(0, math.min(self.max, loaded_current))
            self:Sync()
        end
    end)
end

function HHMana:TransferComponent(newinst)
    local target = newinst and newinst.components and newinst.components.hh_mana
    if not target then
        return
    end

    local current = self.current
    local remaining_delay = math.max(0, (self.regen_delay_end or 0) - GetTime())
    newinst:DoTaskInTime(0, function(inst)
        if not inst:IsValid() or inst.components.hh_mana ~= target then
            return
        end
        target:RecalculateMax(false)
        target.current = math.max(0, math.min(target.max, current))
        target.regen_delay_end = GetTime() + remaining_delay
        target:Sync()
    end)
end

function HHMana:OnRemoveFromEntity()
    if self.regen_task then self.regen_task:Cancel(); self.regen_task = nil end
end

return HHMana
