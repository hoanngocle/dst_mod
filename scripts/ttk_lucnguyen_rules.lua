local Rules = {}

local PI = math.pi
local TWO_PI = PI * 2

local function NormalizeAngle(angle)
    return (angle + PI) % TWO_PI - PI
end

function Rules.RollVolley(base_damage, random)
    random = random or math.random
    local pool = { 1, 2, 3, 4, 5, 6 }
    local count = random(1, 6)
    local volley = {}
    for i = 1, count do
        local pick = random(1, #pool)
        volley[i] = {
            element = table.remove(pool, pick),
            damage = base_damage * random(10, 20) / 100,
        }
    end
    return volley
end

function Rules.Step(x, z, heading, target_x, target_z, dt, speed, turn_rate)
    local dx, dz = target_x - x, target_z - z
    local distance = math.sqrt(dx * dx + dz * dz)
    local travel = speed * dt
    if distance <= travel then
        local final_heading = distance > 0 and math.atan2(dz, dx) or heading
        return target_x, target_z, NormalizeAngle(final_heading), true
    end

    local desired = math.atan2(dz, dx)
    local delta = NormalizeAngle(desired - heading)
    local max_turn = turn_rate * dt
    if delta > max_turn then
        delta = max_turn
    elseif delta < -max_turn then
        delta = -max_turn
    end
    heading = NormalizeAngle(heading + delta)
    return x + math.cos(heading) * travel,
        z + math.sin(heading) * travel,
        heading,
        false
end

function Rules.IsExpired(elapsed, timeout)
    return elapsed >= timeout
end

return Rules
