local Math = {}

local function Number(value)
    return tonumber(value) or 0
end

function Math.Clamp(value, low, high)
    value = Number(value)
    low = Number(low)
    high = Number(high)
    if value < low then return low end
    if value > high then return high end
    return value
end

function Math.RollPercent(rate, rng)
    rate = Math.Clamp(rate, 0, 100)
    if rate <= 0 then return false end
    if rate >= 100 then return true end
    return rng(1, 100) <= rate
end

function Math.ResolvePrimary(base, flat, percent, crit_rate, crit_effect, burst, rng)
    local pre_crit = (Number(base) + Number(flat)) * (1 + Number(percent) / 100)
    local critical = Math.RollPercent(crit_rate, rng)
    local critical_multiplier = critical and (2 + Number(crit_effect) / 100) or 1
    local burst_rate = burst ~= nil and burst.chance or 0
    local burst_multiplier = burst ~= nil and Number(burst.multiplier) or 1
    local burst_active = Math.RollPercent(burst_rate, rng)

    return {
        pre_crit = pre_crit,
        final = pre_crit * critical_multiplier * (burst_active and burst_multiplier or 1),
        critical = critical,
        critical_multiplier = critical_multiplier,
        burst = burst_active,
        burst_multiplier = burst_active and burst_multiplier or 1,
    }
end

function Math.CalculateArmorPierce(base_damage, percent)
    return Number(base_damage) * Math.Clamp(percent, 0, 40) / 100
end

function Math.ApplyReduction(damage, percent)
    return Number(damage) * (100 - Math.Clamp(percent, 0, 80)) / 100
end

function Math.TakeLifestealBudget(state, now, requested, max_health)
    state = state or {}
    now = Number(now)
    max_health = Number(max_health)
    if state.started_at == nil or now - state.started_at >= 1 then
        state.started_at = now
        state.used = 0
    end

    local event_cap = max_health * .15
    local remaining = max_health * .9 - Number(state.used)
    local granted = math.max(0, math.min(Number(requested), event_cap, remaining))
    state.used = Number(state.used) + granted
    return granted
end

return Math
