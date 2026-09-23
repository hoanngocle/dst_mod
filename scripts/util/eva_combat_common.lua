local Life = require "util/eva_life_common"

local Combat = {}

Combat.MELEE_TRIGGER_HITS = 2
Combat.MELEE_WAVE_DAMAGE = 50
Combat.MELEE_WAVE_SPEED = 18
Combat.MELEE_WAVE_LIFETIME = 2
Combat.MELEE_WAVE_RADIUS = 2
Combat.MELEE_WAVE_OFFSET = 1.5

Combat.DAYDU_RANGE = 12
Combat.DAYDU_POINT_RADIUS = 2
Combat.DAYDU_COST = 5
Combat.DAYDU_COOLDOWN = 15
Combat.DAYDU_MARK_DURATION = 5
Combat.DAYDU_DAMAGE_TAKEN_MULT = 1.10
Combat.DAYDU_DEBUFF_NAME = "eva_daydu_mark"
Combat.DAYDU_DEBUFF_PREFAB = "eva_daydu_debuff"

local TARGET_MUST_TAGS = {"_combat"}
local TARGET_CANT_TAGS = {
    "INLIMBO", "NOCLICK", "notarget", "noattack", "playerghost",
    "flight", "invisible", "companion", "wall", "structure",
}

function Combat.IsFiniteNumber(value)
    return type(value) == "number"
        and value == value
        and value > -math.huge
        and value < math.huge
end

function Combat.ClampDuration(value, maximum)
    value = tonumber(value) or 0
    if not Combat.IsFiniteNumber(value) then return 0 end
    return math.max(0, math.min(maximum, value))
end

function Combat.CanOwnerRemain(owner)
    return Life.CanRemainActive(owner)
end

function Combat.IsValidTarget(owner, target)
    return Life.IsValidTarget(owner, target, nil)
end

function Combat.CanAcceptDayduMark(target)
    if target == nil or target.AddDebuff == nil then return false end
    if target.DebuffsEnabled ~= nil and not target:DebuffsEnabled() then return false end
    local debuffable = target.components ~= nil and target.components.debuffable or nil
    return debuffable == nil or debuffable.IsEnabled == nil or debuffable:IsEnabled()
end

function Combat.IsMeleeAttackCandidate(owner, data)
    if not Combat.CanOwnerRemain(owner) or data == nil
        or not Combat.IsValidTarget(owner, data.target) then
        return false
    end

    local weapon = data.weapon
    local weapon_component = weapon ~= nil and weapon.components ~= nil
        and weapon.components.weapon or nil
    if weapon_component == nil or data.projectile ~= nil then return false end
    if weapon.components.projectile ~= nil then return false end
    if weapon.components.complexprojectile ~= nil
        and not weapon.components.complexprojectile.ismeleeweapon then
        return false
    end
    return weapon_component.CanRangedAttack == nil
        or not weapon_component:CanRangedAttack()
end

function Combat.IsMatchingSuccessfulHit(pending, data)
    return pending ~= nil
        and data ~= nil
        and data.target == pending.target
        and data.weapon == pending.weapon
        and Combat.IsFiniteNumber(data.damage)
        and data.damage > 0
end

function Combat.FindTargetsAt(owner, x, z, radius)
    if not Combat.CanOwnerRemain(owner) then return {} end
    local found = TheSim:FindEntities(x, 0, z, radius, TARGET_MUST_TAGS, TARGET_CANT_TAGS)
    local targets = {}
    local radius_sq = radius * radius
    for _, target in ipairs(found) do
        if Combat.IsValidTarget(owner, target) then
            local tx, _, tz = target.Transform:GetWorldPosition()
            local dx, dz = tx - x, tz - z
            if dx * dx + dz * dz <= radius_sq then
                targets[#targets + 1] = target
            end
        end
    end
    return targets
end

local function HasActiveWings(owner)
    local wings = owner.components ~= nil and owner.components.eva_wings or nil
    return wings ~= nil and wings.IsActive ~= nil and wings:IsActive()
end

function Combat.ValidateCastPoint(owner, x, z)
    if not Combat.IsFiniteNumber(x) or not Combat.IsFiniteNumber(z) then
        return false, "invalid_coordinates"
    end
    if not Life.CanActivate(owner) then return false, "invalid_state" end
    if owner:GetDistanceSqToPoint(x, 0, z) > Combat.DAYDU_RANGE * Combat.DAYDU_RANGE then
        return false, "out_of_range"
    end

    local map = TheWorld ~= nil and TheWorld.Map or nil
    if map == nil then return false, "invalid_terrain" end
    local width, height = map:GetSize()
    local scale = TILE_SCALE or 4
    if not Combat.IsFiniteNumber(width) or not Combat.IsFiniteNumber(height)
        or math.abs(x) >= width * scale / 2
        or math.abs(z) >= height * scale / 2 then
        return false, "out_of_bounds"
    end
    local point = Vector3(x, 0, z)
    if map.IsGroundTargetBlocked ~= nil and map:IsGroundTargetBlocked(point) then
        return false, "ground_blocked"
    end
    if map:GetPlatformAtPoint(x, z) ~= nil
        or map:IsPassableAtPoint(x, 0, z, false) then
        return true
    end
    if map:IsOceanAtPoint(x, 0, z, false) then
        if TheWorld.HasTag ~= nil and TheWorld:HasTag("cave") then
            return false, "invalid_terrain"
        end
        if HasActiveWings(owner) then return true end
        return false, "ocean_requires_wings"
    end
    return false, "invalid_terrain"
end

function Combat.FindDayduTarget(owner, x, z)
    local best = nil
    local best_distance = nil
    for _, target in ipairs(Combat.FindTargetsAt(
            owner, x, z, Combat.DAYDU_POINT_RADIUS)) do
        if owner:GetDistanceSqToInst(target) <= Combat.DAYDU_RANGE * Combat.DAYDU_RANGE
            and Combat.CanAcceptDayduMark(target) then
            local tx, _, tz = target.Transform:GetWorldPosition()
            local dx, dz = tx - x, tz - z
            local distance = dx * dx + dz * dz
            if best == nil or distance < best_distance then
                best = target
                best_distance = distance
            end
        end
    end
    return best
end

return Combat
