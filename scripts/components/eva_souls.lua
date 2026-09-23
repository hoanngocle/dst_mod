local function Clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, value))
end

local BASE_MAX = 100
local MAX_PER_LEVEL = 6
local HARD_MAX = 1000

local function NormalizeLevel(value)
    value = tonumber(value)
    if value == nil or value ~= value or value == math.huge or value == -math.huge then
        return 1
    end
    return math.max(1, math.floor(value))
end

local eva_souls = Class(function(self, inst)
    self.inst = inst
    self.level = 1
    self.max = BASE_MAX
    self.current = BASE_MAX
    self._death_applied = false
    self._onlevelup = function() self:RefreshLevel() end
    self._ondeath = function() self:ApplyDeathPenalty() end
    self._onrespawn = function() self._death_applied = false end
    inst:ListenForEvent("hh_levelup", self._onlevelup)
    inst:ListenForEvent("death", self._ondeath)
    inst:ListenForEvent("ms_respawnedfromghost", self._onrespawn)
    -- Component OnLoad order is unspecified. Reconcile after all components load.
    self._initial_task = inst:DoTaskInTime(0, function()
        self._initial_task = nil
        self:RefreshLevel()
    end)
    self._regen_task = inst:DoPeriodicTask(1, function() self:UpdateProgression() end)
    self:SyncNet()
end)

function eva_souls:GetLevel()
    local levels = self.inst.components.hh_leveling
    -- Unified progression is authoritative, including after a legacy save load.
    self.level = NormalizeLevel(levels ~= nil and levels.level or nil)
    return self.level
end

function eva_souls:RefreshLevel()
    local oldlevel = self.level
    local level = self:GetLevel()
    local maximum = math.min(HARD_MAX, BASE_MAX + MAX_PER_LEVEL * (level - 1))
    if maximum ~= self.max or self.current > maximum then
        self:SetMax(maximum)
    elseif oldlevel ~= level then
        self:SyncNet()
    end
    return level
end

function eva_souls:UpdateProgression()
    -- Also detects delayed restoration of unified progression.
    local level = self:RefreshLevel()
    local health = self.inst.components.health
    if level > 100 and self.current < self.max
        and not self._death_applied
        and not self.inst:HasTag("playerghost")
        and health ~= nil and not health:IsDead() then
        self:DoDelta(1, true)
    end
end

function eva_souls:ApplyDeathPenalty()
    if self._death_applied then return end
    self._death_applied = true
    -- Whole souls: 257 becomes 25; never apply a second time on ghost reload.
    self:DoDelta(math.floor(self.current / 10) - self.current)
end

function eva_souls:SyncNet()
    if self.inst.eva_level ~= nil then
        self.inst.eva_level:set(math.min(4294967295, self.level))
    end
    if self.inst.maxsouls ~= nil then
        self.inst.maxsouls:set(self.max)
    end
    if self.inst.currentsouls ~= nil then
        self.inst.currentsouls:set(math.floor(self.current))
    end
end

function eva_souls:OnSave()
    self:RefreshLevel()
    return {
        level = self.level,
        current = self.current,
        maxsouls = self.max,
        death_applied = self._death_applied,
    }
end

function eva_souls:OnLoad(data)
    self:GetLevel()
    -- Do not clamp to the temporary level-1 cap before hh_leveling:OnLoad runs.
    self.current = Clamp(math.floor(data ~= nil and data.current or 0), 0, HARD_MAX)
    self._death_applied = data ~= nil and data.death_applied == true or false
    if self._initial_task ~= nil then self._initial_task:Cancel() end
    self._initial_task = self.inst:DoTaskInTime(0, function()
        self._initial_task = nil
        self:RefreshLevel()
    end)
    self:SyncNet()
end

function eva_souls:GetDebugString()
    return string.format("%d / %d", self.current, self.max)
end

function eva_souls:SetMax(amount)
    local old = self.current
    local oldpercent = self:GetPercent()
    self.max = Clamp(math.floor(amount or BASE_MAX), 0, HARD_MAX)
    self.current = Clamp(self.current, 0, self.max)
    self:SyncNet()
    self.inst:PushEvent("eva_soulsdelta", {
        oldpercent = oldpercent,
        newpercent = self:GetPercent(),
        delta = self.current - old,
    })
end

function eva_souls:DoDelta(delta, overtime)
    local old = self.current
    self.current = Clamp(math.floor(self.current + (delta or 0)), 0, self.max)
    self:SyncNet()
    self.inst:PushEvent("eva_soulsdelta", {
        oldpercent = self.max > 0 and old / self.max or 0,
        newpercent = self:GetPercent(),
        overtime = overtime,
        delta = self.current - old,
    })
end

function eva_souls:GetPercent()
    return self.max > 0 and self.current / self.max or 0
end

function eva_souls:SetPercent(percent, overtime)
    local old = self.current
    local normalized = Clamp(percent or 0, 0, 1)
    self.current = math.floor(normalized * self.max)
    self:SyncNet()
    self.inst:PushEvent("eva_soulsdelta", {
        oldpercent = self.max > 0 and old / self.max or 0,
        newpercent = self:GetPercent(),
        overtime = overtime,
        delta = self.current - old,
    })
end

function eva_souls:OnRemoveFromEntity()
    if self._initial_task ~= nil then self._initial_task:Cancel() end
    if self._regen_task ~= nil then self._regen_task:Cancel() end
    self.inst:RemoveEventCallback("hh_levelup", self._onlevelup)
    self.inst:RemoveEventCallback("death", self._ondeath)
    self.inst:RemoveEventCallback("ms_respawnedfromghost", self._onrespawn)
end

return eva_souls
