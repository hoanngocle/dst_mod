local Life = {}
local EvaSkillPanel = require "util/eva_skillpanel"

Life.DURATION = 15
Life.COOLDOWN = 60
Life.SOUL_COST = 10
Life.PROJECTILE_PERIOD = 0.2
Life.PROJECTILE_DAMAGE = 80
Life.PROJECTILE_RANGE = 12
Life.AURA_PERIOD = 0.5
Life.AURA_DAMAGE = 67
Life.AURA_RADIUS = 6
Life.HEAL_FRACTION = 0.05
Life.HEAL_TIMES = {0, 3, 6, 9, 12}
Life.SHIELD_FRACTION = 0.25

local TARGET_MUST_TAGS = {"_combat"}
local TARGET_CANT_TAGS = {
    "INLIMBO", "NOCLICK", "notarget", "noattack", "playerghost",
    "flight", "invisible", "companion", "wall",
}

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
    if follower == nil or follower.leader == nil then
        return false
    end
    if follower.leader == owner then
        return true
    end
    return (TheNet == nil or not TheNet:GetPVPEnabled())
        and follower.leader:HasTag("player")
end

function Life.IsValidTarget(owner, target, range)
    if not IsAlive(owner) or not IsAlive(target) or target == owner then
        return false
    end
    if target.components.combat == nil
        or target:HasTag("playerghost")
        or target:HasTag("notarget")
        or target:HasTag("noattack")
        or target:HasTag("INLIMBO")
        or target:HasTag("NOCLICK")
        or target:HasTag("wall")
        or target:HasTag("structure")
        or target:HasTag("flight")
        or target:HasTag("invisible")
        or target:HasTag("hiding")
        or target:HasTag("companion")
        or IsPlayerProtected(target)
        or IsProtectedFollower(owner, target) then
        return false
    end
    local target_sg = target.sg
    if target_sg ~= nil and (target_sg:HasStateTag("flight")
        or target_sg:HasStateTag("invisible")
        or target_sg:HasStateTag("hiding")) then
        return false
    end
    if target.entity ~= nil and target.entity.IsVisible ~= nil
        and not target.entity:IsVisible() then
        return false
    end
    if range ~= nil and owner:GetDistanceSqToInst(target) > range * range then
        return false
    end
    local combat = owner.components.combat
    if combat == nil or not combat:CanTarget(target) then
        return false
    end
    if combat.IsAlly ~= nil and combat:IsAlly(target) then
        return false
    end
    return target:HasTag("hostile")
        or combat.target == target
        or target.components.combat.target == owner
end

function Life.FindTargets(owner, radius)
    if not IsAlive(owner) then return {} end
    local x, y, z = owner.Transform:GetWorldPosition()
    local entities = TheSim:FindEntities(x, y, z, radius, TARGET_MUST_TAGS, TARGET_CANT_TAGS)
    local targets = {}
    for _, target in ipairs(entities) do
        if Life.IsValidTarget(owner, target, radius) then
            targets[#targets + 1] = target
        end
    end
    return targets
end

function Life.SelectTarget(owner, radius)
    if not IsAlive(owner) then return nil end
    local current = owner.components.combat ~= nil and owner.components.combat.target or nil
    if Life.IsValidTarget(owner, current, radius) then
        return current
    end

    local best = nil
    local best_threat = false
    local best_distance = nil
    for _, target in ipairs(Life.FindTargets(owner, radius)) do
        local target_combat = target.components.combat
        local threat = target:HasTag("hostile")
            or (target_combat ~= nil and target_combat.target == owner)
        local distance = owner:GetDistanceSqToInst(target)
        if best == nil
            or (threat and not best_threat)
            or (threat == best_threat and distance < best_distance) then
            best = target
            best_threat = threat
            best_distance = distance
        end
    end
    return best
end

function Life.CanRemainActive(owner)
    return IsAlive(owner)
        and not owner:HasTag("playerghost")
end

function Life.CanActivate(owner)
    if not Life.CanRemainActive(owner) then return false end
    local sg = owner.sg
    if sg ~= nil and ((sg:HasStateTag("busy")
            and not EvaSkillPanel.IsAuthorizedNativeCast(owner))
        or sg:HasStateTag("knockout")
        or sg:HasStateTag("frozen")) then
        return false
    end
    local freezable = owner.components.freezable
    return freezable == nil or not freezable:IsFrozen()
end

return Life
