-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
require "behaviours/follow"
require "behaviours/leash"
require "behaviours/doaction"
require "behaviours/runaway"
require "behaviours/chaseandattack"
require "behaviours/wander"
require "behaviours/faceentity"
require "behaviours/wander"
require "behaviours/faceentity"
require "behaviours/chaseandattack"
local START_FACE_DIST = 8
local KEEP_FACE_DIST = 15
local Shadow_BishopBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
    self._shouldchase = false
end)
local function GetLeader(inst)
    return inst.components.follower ~= nil and inst.components.follower.leader or nil
end
local function IsNearLeader(inst, dist)
    local leader = GetLeader(inst)
    return leader ~= nil and leader:IsValid() and inst:IsValid() and inst:IsNear(leader, dist)
end
local function GetTarget(inst)
	return inst.components.combat.target
end
local function IsTarget(inst, target)
	return inst.components.combat:TargetIs(target)
end
local function GetTargetPos(inst)
	local target = GetTarget(inst)
	return target ~= nil and target:GetPosition() or nil
end
local MIN_FOLLOW_LEADER = 3
local MAX_FOLLOW_LEADER = 14
local TARGET_FOLLOW_LEADER = 8
local function shouldspit(inst)
    if inst.components.timer:TimerExists("spit_cooldown") then
        return false
    end
    return inst.components.combat.target and inst.components.combat.target:IsValid() and
               inst:GetDistanceSqToInst(inst.components.combat.target) <= 12 *
               12
end
local function spit(inst)
    local act = BufferedAction(inst, inst.components.combat.target, ACTIONS.TOSS)
    return act
end
local function shouldwaittospit(inst)
    return inst.components.combat.target and inst.components.combat.target:IsValid() and
               inst:GetDistanceSqToInst(inst.components.combat.target) <= 4 * 4
end
function Shadow_BishopBrain:OnStart()
    local brain =
    {
        WhileNode(function() return self.inst.components.combat:InCooldown() end, "Chase",
        PriorityNode({
            FailIfSuccessDecorator(
                Leash(self.inst, GetTargetPos, TUNING.DEERCLOPS_ATTACK_RANGE, 3)),
            FaceEntity(self.inst, GetTarget, IsTarget),
        }, 0.5)),
        ChaseAndAttack(self.inst),
        Follow(self.inst, GetLeader, MIN_FOLLOW_LEADER, TARGET_FOLLOW_LEADER, MAX_FOLLOW_LEADER),
        Wander(self.inst, function() return self.inst:GetPosition() end, 4)
    }
    if self.inst:HasTag("spitter") then
        table.insert(brain, 1, WhileNode(function() return shouldspit(self.inst) end, "Spit",
            DoAction(self.inst, spit)))
        table.insert(brain, 2, IfNode(function() return shouldwaittospit(self.inst) end, "waittospit",
            StandStill(self.inst)))
    end
    local root = PriorityNode(brain, .25)
    self.bt = BT(self.inst, root)
end
return Shadow_BishopBrain
