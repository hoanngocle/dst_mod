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
local function ShouldSpell(self)
    if self.inst.prefab == "ttk_boss_bjms" then
        if self.inst.skill1pos and  (not self.inst.skill1_time or (GetTime() - self.inst.skill1_time) < 10) then
            self.abilityname = "skill1"
            self.abilitydata = {pos = self.inst.skill1pos}
        elseif self.inst.skill2pos and  (not self.inst.skill2_time or (GetTime() - self.inst.skill2_time) < 10) then
            self.abilityname = "skill2"
            self.abilitydata = {pos = self.inst.skill2pos}
        end
    else
        if self.inst.shouldgoaway then
         self.abilityname = "goaway"
            self.abilitydata = { }
        elseif self.inst.skill1target and self.inst.skill1target:IsValid() and (not self.inst.skill1_time or (GetTime() - self.inst.skill1_time) < 10) then
            self.abilityname = "skill1"
            self.abilitydata = {target = self.inst.skill1target}
        elseif self.inst.skill2pos and  (not self.inst.skill2_time or (GetTime() - self.inst.skill2_time) < 10) then
            self.abilityname = "skill2"
            self.abilitydata = {pos = self.inst.skill2pos}
        elseif self.inst.skill3pos and  (not self.inst.skill3_time or (GetTime() - self.inst.skill3_time) < 10) then
            self.abilityname = "skill3"
            self.abilitydata = {pos = self.inst.skill3pos}
        end
    end
    return self.abilityname ~= nil
end
local function GetFaceTargetFn(inst)
    return inst.components.follower.leader
end
local function KeepFaceTargetFn(inst, target)
    return inst.components.follower.leader == target
end
function Shadow_BishopBrain:OnStart()
    local brain =
    {
        WhileNode(function()return ShouldSpell(self) end, "ShouldSpell",
            ActionNode(function()
                self.inst:PushEvent(self.abilityname, self.abilitydata)
                self.abilityname = nil
                self.abilitydata = nil
            end)
        ),
        Follow(self.inst, GetLeader, self.inst.MIN_FOLLOW_LEADER or MIN_FOLLOW_LEADER, self.inst.TARGET_FOLLOW_LEADER or TARGET_FOLLOW_LEADER, self.inst.MAX_FOLLOW_LEADER or MAX_FOLLOW_LEADER),
	    IfNode(function() return self.inst.faceentity end, "FaceEntity",
		    FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn)),
        Wander(self.inst, function() return self.inst:GetPosition() end, 4)
    }
    local root = PriorityNode(brain, .25)
    self.bt = BT(self.inst, root)
end
return Shadow_BishopBrain
