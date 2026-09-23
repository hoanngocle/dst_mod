-- Pure resolved-damage ledger. No DST globals so the integration path can be
-- exercised under stock Lua 5.1.
local Resolver = {}
Resolver.__index = Resolver

local function positive_loss(before, after)
    before, after = tonumber(before), tonumber(after)
    if before == nil or after == nil then return 0 end
    return math.max(0, before - after)
end

function Resolver.new(emit)
    return setmetatable({ emit = emit, serial = 0, active = {}, stack = {} }, Resolver)
end

function Resolver:begin_hit(attacker, victim, health)
    self.serial = self.serial + 1
    local hit = {
        id = self.serial, attacker = attacker, victim = victim,
        before = health, cursor = health, critical = false, emitted = 0,
        parent = self.active[victim],
    }
    self.active[victim] = hit
    self.stack[#self.stack + 1] = hit
    return hit
end

function Resolver:mark_critical(hit, multiplier)
    if hit ~= nil then
        hit.critical = true
        hit.critical_multiplier = tonumber(multiplier)
    end
end

function Resolver:_emit(hit, victim, attacker, amount, kind)
    if amount <= 0 then return end
    self.emit({
        hit_id = hit and hit.id or nil,
        victim = victim, attacker = attacker,
        amount = amount, kind = kind,
        critical_multiplier = hit and hit.critical_multiplier or nil,
    })
end

function Resolver:health_changed(victim, before, after, cause, attacker)
    local amount = positive_loss(before, after)
    if amount <= 0 then return end
    local hit = self.active[victim]
    if hit ~= nil then
        hit.cursor = after
        hit.emitted = hit.emitted + amount
        local kind = cause == "hh_true_damage" and "true" or (hit.critical and "crit" or "normal")
        self:_emit(hit, victim, attacker or hit.attacker, amount, kind)
    else
        self:_emit(nil, victim, attacker, amount, cause == "hh_true_damage" and "true" or "normal")
    end
end

function Resolver:finish_hit(hit, health)
    if hit == nil then return end
    if self.active[hit.victim] == hit then self.active[hit.victim] = hit.parent end
    for i = #self.stack, 1, -1 do
        if self.stack[i] == hit then table.remove(self.stack, i) break end
    end
end

return Resolver
