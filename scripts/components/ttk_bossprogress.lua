local defs = require("ttk_boss_defs")

local MAX_STATS = {
    health = true,
    mana = true,
    hunger = true,
    sanity = true,
}

local function IsFoodDefinition(def)
    return def ~= nil and def.food ~= nil and def.stat ~= nil and def.gain ~= nil
end

local function ClampCount(value)
    value = math.floor(tonumber(value) or 0)
    return math.max(0, math.min(defs.limit or 10, value))
end

local BossProgress = Class(function(self, inst)
    self.inst = inst
    self.counts = {}
    self.version = 1
end)

function BossProgress:GetCount(key)
    return ClampCount(self.counts[key])
end

function BossProgress:GetMaxBonus(stat)
    if not MAX_STATS[stat] then return 0 end
    local total = 0
    for key, def in pairs(defs.bosses) do
        if IsFoodDefinition(def) and def.stat == stat then
            total = total + self:GetCount(key) * def.gain
        end
    end
    return total
end

function BossProgress:GetEffectBonus(effect)
    local total = 0
    for key, def in pairs(defs.bosses) do
        if IsFoodDefinition(def) then
            local count = self:GetCount(key)
            if not MAX_STATS[def.stat] and def.stat == effect then
                total = total + count * def.gain
            end
            if def.effect == effect and count >= (defs.limit or 10) then
                total = total + (def.effect_value or 1)
            end
        end
    end
    return total
end

function BossProgress:SyncNet()
    for key, def in pairs(defs.bosses) do
        if IsFoodDefinition(def) then
            local netvar = self.inst["ttk_bossprogress_" .. key]
            if netvar ~= nil then netvar:set(self:GetCount(key)) end
        end
    end
end

function BossProgress:Refresh()
    local components = self.inst.components or {}
    for _, name in ipairs({"health", "hunger", "sanity", "hh_mana"}) do
        local component = components[name]
        if component ~= nil and component._ttk_bossprogress_refresh ~= nil then
            component:_ttk_bossprogress_refresh()
        end
    end
    self:SyncNet()
    self.inst:PushEvent("ttk_bossprogress_refreshed", {counts = self.counts})
end

function BossProgress:Absorb(key)
    local def = defs.bosses[key]
    if not IsFoodDefinition(def) then return false, 0 end
    local count = self:GetCount(key)
    if count >= (defs.limit or 10) then return false, count end
    count = count + 1
    self.counts[key] = count
    self:Refresh()
    self.inst:PushEvent("ttk_bossprogress_absorbed", {key = key, count = count})
    return true, count
end

function BossProgress:OnSave()
    local saved = {}
    for key, def in pairs(defs.bosses) do
        if IsFoodDefinition(def) then
            local count = self:GetCount(key)
            if count > 0 then saved[key] = count end
        end
    end
    return {version = self.version, counts = saved}
end

function BossProgress:OnLoad(data)
    local loaded = {}
    for key, def in pairs(defs.bosses) do
        if IsFoodDefinition(def) then
            local count = ClampCount(data ~= nil and data.counts ~= nil and data.counts[key] or 0)
            if count > 0 then loaded[key] = count end
        end
    end
    self.counts = loaded
    self:SyncNet()
    self.inst:DoTaskInTime(0, function(inst)
        if inst:IsValid() and inst.components.ttk_bossprogress == self then self:Refresh() end
    end)
end

function BossProgress:TransferComponent(newinst)
    local target = newinst ~= nil and newinst.components ~= nil and newinst.components.ttk_bossprogress or nil
    if target == nil then return end
    target.counts = {}
    for key, def in pairs(defs.bosses) do
        if IsFoodDefinition(def) then
            local count = self:GetCount(key)
            if count > 0 then target.counts[key] = count end
        end
    end
    target:Refresh()
end

return BossProgress
