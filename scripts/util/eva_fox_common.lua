local Life = require "util/eva_life_common"

local Fox = {}

Fox.COOLDOWN = 15
Fox.CAST_RANGE = 20
Fox.BLINK_DELAY = 0.25
Fox.LUNGE_DAMAGE = 600
Fox.LUNGE_SIDE_RANGE = 1
Fox.LUNGE_PHYSICS_PADDING = 3
Fox.FADE_TIME = 0.5
Fox.TELEPORT_TIME = 1.75
Fox.RESTORE_TIME = 2.0
Fox.FINISH_TIME = 2.2
Fox.FIRE_DAMAGE = 266.7
Fox.FIRE_RADIUS = 4
Fox.FIRE_PERIOD = 0.2
Fox.FIRE_TICKS = 3
Fox.FIRE_LIFETIME = 1.5
Fox.HEAL_FRACTION = 0.033
Fox.SLEEPINESS = 0.8
Fox.SLEEP_DURATION = 3

local TARGET_MUST_TAGS = {"_combat"}
local TARGET_CANT_TAGS = {
    "INLIMBO", "NOCLICK", "notarget", "noattack", "playerghost",
    "flight", "invisible", "companion", "wall",
}
local LUNGE_TARGET_CANT_TAGS = {"INLIMBO", "playerghost"}

function Fox.IsFiniteNumber(value)
    return type(value) == "number"
        and value == value
        and value > -math.huge
        and value < math.huge
end

local function HasStateTag(owner, tag)
    return owner.sg ~= nil and owner.sg:HasStateTag(tag)
end

local function IsMountedOrTransitioning(owner)
    local components = owner.components or {}
    return (components.rider ~= nil and components.rider:IsRiding())
        or (components.locomotor ~= nil and (components.locomotor.hopping == true
            or (components.locomotor.IsHopping ~= nil and components.locomotor:IsHopping())))
        or (components.freezable ~= nil and components.freezable:IsFrozen())
        or HasStateTag(owner, "knockout")
        or HasStateTag(owner, "frozen")
        or HasStateTag(owner, "hopping")
        or HasStateTag(owner, "jumping")
        or HasStateTag(owner, "mounting")
        or HasStateTag(owner, "dismounting")
end

function Fox.CanActivate(owner)
    return owner ~= nil
        and Life.CanActivate(owner)
        and not IsMountedOrTransitioning(owner)
end

function Fox.CanContinueCast(owner)
    return owner ~= nil
        and Life.CanRemainActive(owner)
        and not IsMountedOrTransitioning(owner)
end

function Fox.CanOwnerRemain(owner)
    return Life.CanRemainActive(owner)
end

local function HasActiveWings(owner)
    local wings = owner.components ~= nil and owner.components.eva_wings or nil
    return wings ~= nil and wings.IsActive ~= nil and wings:IsActive()
end

function Fox.ValidateDestination(owner, x, z, origin_x, origin_z)
    if not Fox.IsFiniteNumber(x) or not Fox.IsFiniteNumber(z) then
        return false, "invalid_coordinates"
    end
    if not Fox.IsFiniteNumber(origin_x) or not Fox.IsFiniteNumber(origin_z) then
        return false, "invalid_origin"
    end
    local dx, dz = x - origin_x, z - origin_z
    if dx * dx + dz * dz > Fox.CAST_RANGE * Fox.CAST_RANGE then
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

    local point = Vector3(x, 0, z)
    if map:IsGroundTargetBlocked(point) then return false, "ground_blocked" end

    local platform = map:GetPlatformAtPoint(x, z)
    local passable = map:IsPassableAtPoint(x, 0, z, false)
    local is_ocean = map:IsOceanAtPoint(x, 0, z, false)
    if platform == nil and not passable then
        if not is_ocean or (TheWorld.HasTag ~= nil and TheWorld:HasTag("cave")) then
            return false, "invalid_terrain"
        end
        if not HasActiveWings(owner) then return false, "ocean_requires_wings" end
    end

    local source_x, source_y, source_z = owner.Transform:GetWorldPosition()
    if IsTeleportingPermittedFromPointToPoint == nil
        or not IsTeleportingPermittedFromPointToPoint(
            source_x, source_y, source_z, x, 0, z) then
        return false, "teleport_not_permitted"
    end
    return true
end

function Fox.FindTargetsAt(owner, x, z)
    if not Life.CanRemainActive(owner) then return {} end
    local found = TheSim:FindEntities(
        x, 0, z, Fox.FIRE_RADIUS, TARGET_MUST_TAGS, TARGET_CANT_TAGS)
    local targets = {}
    for _, target in ipairs(found) do
        if Life.IsValidTarget(owner, target, nil) then
            local tx, _, tz = target.Transform:GetWorldPosition()
            local dx, dz = tx - x, tz - z
            if dx * dx + dz * dz <= Fox.FIRE_RADIUS * Fox.FIRE_RADIUS then
                targets[#targets + 1] = target
            end
        end
    end
    return targets
end

local function IsAlive(inst)
    return inst ~= nil
        and inst:IsValid()
        and not inst:IsInLimbo()
        and inst.components ~= nil
        and inst.components.health ~= nil
        and not inst.components.health:IsDead()
end

local function IsPlayerProtected(target)
    return target:HasTag("player")
        and (TheNet == nil or not TheNet:GetPVPEnabled())
end

local function IsProtectedFollower(owner, target)
    local follower = target.components.follower
    if follower == nil or follower.leader == nil then return false end
    if follower.leader == owner then return true end
    return (TheNet == nil or not TheNet:GetPVPEnabled())
        and follower.leader:HasTag("player")
end

function Fox.IsValidLungeTarget(owner, target)
    if not IsAlive(owner) or not IsAlive(target) or target == owner then
        return false
    end
    if target.components.combat == nil
        or target:HasTag("playerghost")
        or target:HasTag("INLIMBO")
        or target:HasTag("companion")
        or IsPlayerProtected(target)
        or IsProtectedFollower(owner, target) then
        return false
    end
    local combat = owner.components.combat
    if combat == nil then return false end
    return combat.IsAlly == nil or not combat:IsAlly(target)
end

local function PointToSegmentDistanceSq(px, pz, x1, z1, x2, z2)
    local dx, dz = x2 - x1, z2 - z1
    local length_sq = dx * dx + dz * dz
    if length_sq <= 0 then
        local ox, oz = px - x1, pz - z1
        return ox * ox + oz * oz
    end
    local t = ((px - x1) * dx + (pz - z1) * dz) / length_sq
    t = math.max(0, math.min(1, t))
    local nearest_x, nearest_z = x1 + t * dx, z1 + t * dz
    local ox, oz = px - nearest_x, pz - nearest_z
    return ox * ox + oz * oz
end

function Fox.FindTargetsAlongPath(owner, origin_x, origin_z, target_x, target_z)
    if not Life.CanRemainActive(owner) then return {} end
    local dx, dz = target_x - origin_x, target_z - origin_z
    local distance = math.sqrt(dx * dx + dz * dz)
    local center_x = (origin_x + target_x) * 0.5
    local center_z = (origin_z + target_z) * 0.5
    local found = TheSim:FindEntities(
        center_x, 0, center_z,
        distance * 0.5 + Fox.LUNGE_PHYSICS_PADDING,
        TARGET_MUST_TAGS, LUNGE_TARGET_CANT_TAGS)
    local targets, seen = {}, {}
    for _, target in ipairs(found) do
        if not seen[target] and Fox.IsValidLungeTarget(owner, target) then
            seen[target] = true
            local tx, _, tz = target.Transform:GetWorldPosition()
            local radius = target.GetPhysicsRadius ~= nil
                and target:GetPhysicsRadius(0.5) or 0.5
            radius = Fox.IsFiniteNumber(radius) and math.max(0, radius) or 0.5
            local hit_range = Fox.LUNGE_SIDE_RANGE + radius
            if PointToSegmentDistanceSq(
                    tx, tz, origin_x, origin_z, target_x, target_z)
                < hit_range * hit_range then
                targets[#targets + 1] = target
            end
        end
    end
    return targets
end

function Fox.IsValidTarget(owner, target)
    return Life.IsValidTarget(owner, target, nil)
end

function Fox.CanSleep(target)
    local components = target.components or {}
    return not (components.freezable ~= nil and components.freezable:IsFrozen())
        and not (components.pinnable ~= nil and components.pinnable:IsStuck())
        and not (components.fossilizable ~= nil and components.fossilizable:IsFossilized())
end

return Fox
