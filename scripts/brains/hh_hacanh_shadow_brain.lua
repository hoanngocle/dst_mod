require("behaviours/chaseandattack")
require("behaviours/follow")
require("behaviours/runaway")

local BrainCommon = require("brains/braincommon")

local MIN_FOLLOW_DIST = 0
local TARGET_FOLLOW_DIST = 6
local MAX_FOLLOW_DIST = 8

local function GetLeader(inst)
    return inst.components.follower ~= nil and inst.components.follower:GetLeader() or nil
end

local function ShouldAvoidExplosive(target)
    return target.components.explosive == nil
        or target.components.burnable == nil
        or target.components.burnable:IsBurning()
end

local LOW_HEALTH_THRESHOLD = .35
local RETREAT_MIN_TIME = .8
local ENEMY_ATTACK_MEMORY = .35

local function IsEnemyAttacking(target)
    if target == nil or not target:IsValid() then return false end
    if target.sg ~= nil and target.sg:HasStateTag("attack") then
        return true
    end
    local combat = target.components.combat
    return combat ~= nil and (GetTime() - (combat.lastdoattacktime or 0)) <= ENEMY_ATTACK_MEMORY
end

local function GetSafeRetreatDistance(inst)
    local health = inst.components.health
    return health ~= nil and health:GetPercent() <= LOW_HEALTH_THRESHOLD and 9 or 7
end

local function ShouldTacticalRetreat(inst, target)
    if target == nil or not target:IsValid() or target.components.health == nil or target.components.health:IsDead() then
        return false
    end
    local now = GetTime()
    if inst._hh_retreat_until ~= nil and now < inst._hh_retreat_until then
        return true
    end
    local combat = inst.components.combat
    local just_attacked = combat ~= nil and combat:GetCooldown() > .5
    local enemy_attacking = IsEnemyAttacking(target)
    local low_health = inst.components.health ~= nil and inst.components.health:GetPercent() <= LOW_HEALTH_THRESHOLD
    if enemy_attacking or just_attacked or (low_health and inst:IsNear(target, GetSafeRetreatDistance(inst))) then
        inst._hh_retreat_until = now + RETREAT_MIN_TIME
        return true
    end
    return false
end
local function ShouldKite(target, inst)
    return target ~= nil and inst.components.combat:TargetIs(target)
        and target.components.health ~= nil and not target.components.health:IsDead()
end

local function ShouldRunAway(target, inst)
    if target.components.health ~= nil and target.components.health:IsDead() then
        return false
    elseif target:HasAnyTag("shadowcreature", "nightmarecreature") then
        return target.HostileToPlayerTest ~= nil
            and GetLeader(inst) ~= nil
            and target:HostileToPlayerTest(GetLeader(inst))
    elseif target:HasTag("stalker") then
        return target.atriumstalker
            or (target.canfight and target.components.combat ~= nil and target.components.combat:HasTarget())
    end
    return true
end

local HHHacanhShadowBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function HHHacanhShadowBrain:OnStart()
    local avoid_explosions = RunAway(self.inst,
        { fn = ShouldAvoidExplosive, tags = { "explosive" }, notags = { "INLIMBO" } },
        5, 5)
    local avoid_danger = RunAway(self.inst,
        { fn = ShouldRunAway, oneoftags = { "monster", "hostile" },
            notags = { "player", "INLIMBO", "companion", "spiderden" } },
        5, 8)

    self.bt = BT(self.inst, PriorityNode({
        avoid_explosions,
        WhileNode(function()
            local target = self.inst.components.combat.target
            return ShouldTacticalRetreat(self.inst, target)
        end, "Tactical Retreat", RunAway(self.inst,
            { fn = function(target, inst) return ShouldTacticalRetreat(inst, target) end, tags = { "_combat", "_health" }, notags = { "INLIMBO" } },
            5, 7)),
        ChaseAndAttack(self.inst),
        avoid_danger,
        Follow(self.inst, GetLeader, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
    }, .25))
end

return HHHacanhShadowBrain

