local Life = require "util/eva_life_common"

local Array = {}

Array.SOUL_COST = 100
Array.COOLDOWN = 60
Array.CAST_RANGE = 12
Array.PENTAGON_RADIUS = 5
Array.ROOT_PERIOD = 0.3
Array.ROOT_START = 1.3
Array.CENTER_SCYTHE_TIME = 1.3
Array.STRIKE_TIME = 1.8
Array.STRIKE_DAMAGE = 734
Array.DAMAGE_RADIUS = 6
Array.BEAM_TIME = 1.8
Array.BEAM_PRE_TIME = 1.1
Array.BEAM_DAMAGE = 200
Array.BEAM_PERIOD = 0.5
Array.BEAM_FIRST_HIT = 2.9
Array.BEAM_PULSES = 11
Array.FINISH_TIME = 7.9

local TARGET_MUST_TAGS = {"_combat"}
local TARGET_CANT_TAGS = {
    "INLIMBO", "NOCLICK", "notarget", "noattack", "playerghost",
    "flight", "invisible", "companion", "wall",
}

function Array.IsFiniteNumber(value)
    return type(value) == "number"
        and value == value
        and value > -math.huge
        and value < math.huge
end

function Array.BuildVertices(x, z)
    local vertices = {}
    for index = 1, 5 do
        local angle = -math.pi / 2 + (index - 1) * (2 * math.pi / 5)
        vertices[index] = {
            x + Array.PENTAGON_RADIUS * math.cos(angle),
            z + Array.PENTAGON_RADIUS * math.sin(angle),
        }
    end
    return vertices
end

function Array.PointInPentagon(x, z, vertices)
    if not Array.IsFiniteNumber(x) or not Array.IsFiniteNumber(z)
        or vertices == nil or #vertices ~= 5 then
        return false
    end
    local sign = nil
    for index = 1, 5 do
        local current = vertices[index]
        local following = vertices[index % 5 + 1]
        local cross = (following[1] - current[1]) * (z - current[2])
            - (following[2] - current[2]) * (x - current[1])
        if math.abs(cross) > 0.00001 then
            local current_sign = cross > 0
            if sign ~= nil and sign ~= current_sign then return false end
            sign = current_sign
        end
    end
    return true
end

function Array.CanOwnerRemain(owner)
    return Life.CanRemainActive(owner)
end

local function HasActiveWings(owner)
    local wings = owner.components ~= nil and owner.components.eva_wings or nil
    return wings ~= nil and wings.IsActive ~= nil and wings:IsActive()
end

function Array.ValidateCenter(owner, x, z)
    if not Array.IsFiniteNumber(x) or not Array.IsFiniteNumber(z) then
        return false, "invalid_coordinates"
    end
    if not Life.CanActivate(owner) then return false, "invalid_state" end
    if owner:GetDistanceSqToPoint(x, 0, z) > Array.CAST_RANGE * Array.CAST_RANGE then
        return false, "out_of_range"
    end

    local map = TheWorld ~= nil and TheWorld.Map or nil
    if map == nil then return false, "invalid_terrain" end
    local width, height = map:GetSize()
    local scale = TILE_SCALE or 4
    if type(width) ~= "number" or type(height) ~= "number"
        or math.abs(x) >= width * scale / 2
        or math.abs(z) >= height * scale / 2 then
        return false, "out_of_bounds"
    end

    if map:GetPlatformAtPoint(x, z) ~= nil
        or map:IsPassableAtPoint(x, 0, z, false) then
        return true
    end
    if map:IsOceanAtPoint(x, 0, z, false) then
        if HasActiveWings(owner) then return true end
        return false, "ocean_requires_wings"
    end
    return false, "invalid_terrain"
end

function Array.IsValidTargetAt(owner, target, x, z, radius)
    if not Life.IsValidTarget(owner, target, nil) then return false end
    local tx, _, tz = target.Transform:GetWorldPosition()
    local dx, dz = tx - x, tz - z
    return dx * dx + dz * dz <= radius * radius
end

function Array.FindTargetsAt(owner, x, z, radius)
    if not Array.CanOwnerRemain(owner) then return {} end
    local found = TheSim:FindEntities(x, 0, z, radius, TARGET_MUST_TAGS, TARGET_CANT_TAGS)
    local targets = {}
    for _, target in ipairs(found) do
        if Array.IsValidTargetAt(owner, target, x, z, radius) then
            targets[#targets + 1] = target
        end
    end
    return targets
end

return Array
