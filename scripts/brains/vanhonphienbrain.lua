require "behaviours/leash"
require "behaviours/follow"
require "behaviours/wander"
require "behaviours/standandattack"
require "behaviours/faceentity"
require "behaviours/standstill"
require "behaviours/chaseandattack"

local EyeTurretBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function GetLeader(inst)
    return inst.components.entitytracker ~= nil and inst.components.entitytracker:GetEntity("banner") or nil
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

function EyeTurretBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode(function() return self.inst.components.combat:InCooldown() end, "Chase",
        PriorityNode({
            FailIfSuccessDecorator(
                Leash(self.inst, GetTargetPos, 30, 3)),
            FaceEntity(self.inst, GetTarget, IsTarget),
        }, 0.5)),
        ChaseAndAttack(self.inst),
        Follow(self.inst, GetLeader, MIN_FOLLOW_LEADER, TARGET_FOLLOW_LEADER, MAX_FOLLOW_LEADER),
        Wander(self.inst, function() return self.inst:GetPosition() end, 4)
    }, .25)

    self.bt = BT(self.inst, root)
end

return EyeTurretBrain