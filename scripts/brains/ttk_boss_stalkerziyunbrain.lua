-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local XD_CanAttackTrget = Boss.XD_CanAttackTrget
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
local function ShouldChase(self)
    self._shouldchase =
        not self.inst.components.combat:HasTarget() or
        not self.inst.components.combat:InCooldown() or
        not self.inst:IsNear(self.inst.components.combat.target, self.inst.components.combat.attackrange + (self._shouldchase and 0 or 3))
    return self._shouldchase
end
local function GetLeader(inst)
    return inst.components.follower ~= nil and inst.components.follower.leader or nil
end
local function IsNearLeader(inst, dist)
    local leader = GetLeader(inst)
    return leader ~= nil and leader:IsValid() and inst:IsNear(leader, dist)
end
local MIN_FOLLOW_LEADER = 3
local MAX_FOLLOW_LEADER = 14
local TARGET_FOLLOW_LEADER = 8
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
local attacktag = {"_combat","_health"}
local noltags =  {"ttk_boss_ziyun","notarget", "noattack", "flight", "invisible", "playerghost"}
local function ShouldSpell(self)
    local target = self.inst.components.combat.target
    if target and target:IsValid() and not self.inst.components.timer:TimerExists("skillcdtime") and self.inst:IsNear(target,12) then
        if self.inst.skillmode == 2 then
            local targets = {target}
            self.abilitydata = { targets = targets }
        else
            local targets = {target}
            local pos = self.inst:GetPosition()
		    local ents =  TheSim:FindEntities(pos.x,0,pos.z, 12, attacktag,noltags)
		    for i,v in pairs(ents) do
			    if v and v:IsValid() and v ~= target and XD_CanAttackTrget(self.inst,v) then
                    table.insert(targets,v)
			    end
		    end
            self.abilitydata = { targets = targets }
        end
        return true
    end
    return false
end
local function ShouldUseAbility(self)
    self.abilityname = self.inst.components.combat:HasTarget() and (
        (ShouldSpell(self) and "spell")
    ) or nil
    return self.abilityname ~= nil
end
function Shadow_BishopBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode(function() return ShouldUseAbility(self) end, "Ability",
        ActionNode(function()
            self.inst:PushEvent(self.abilityname, self.abilitydata)
            self.abilityname = nil
            self.abilitydata = nil
        end)),
        WhileNode(function() return self.inst.components.combat:InCooldown() end, "Chase",
            PriorityNode({
                FailIfSuccessDecorator(
                    Leash(self.inst, GetTargetPos, TUNING.DEERCLOPS_ATTACK_RANGE, 3)),
                FaceEntity(self.inst, GetTarget, IsTarget),
            }, 0.5)),
        ChaseAndAttack(self.inst),
        Follow(self.inst, GetLeader, MIN_FOLLOW_LEADER, TARGET_FOLLOW_LEADER, MAX_FOLLOW_LEADER),
        Wander(self.inst, function() return self.inst:GetPosition() end, 4)
    }, .25)
    self.bt = BT(self.inst, root)
end
return Shadow_BishopBrain
