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
local BrainCommon = require("brains/braincommon")
local SpiderQueenBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)
function SpiderQueenBrain:CanCastSkill1()
	local target = self.inst.components.combat.target
	return self.inst:IsValid() and self.inst:GetTimeAlive() > 5 and not self.inst.components.health:IsDead()
		and not self.inst.sg:HasStateTag("busy")
		and target and target:IsValid() and target:HasTag("player") and not self.inst.components.timer:TimerExists("skill")
		and (self.inst.skillmode == 1 or self.inst.skillmode == 5)
end
function SpiderQueenBrain:CanCastSkill2()
	local target = self.inst.components.combat.target
	return self.inst:IsValid() and self.inst:GetTimeAlive() > 5 and not self.inst.components.health:IsDead()
		and not self.inst.sg:HasStateTag("busy")
		and target and target:IsValid() and target:HasTag("player") and not self.inst.components.timer:TimerExists("skill")
		and (self.inst.skillmode == 4 or self.inst.skillmode == 8)
end
function SpiderQueenBrain:CanCastSkill3()
	local target = self.inst.components.combat.target
	return self.inst:IsValid() and self.inst:GetTimeAlive() > 5 and not self.inst.components.health:IsDead()
		and not self.inst.sg:HasStateTag("busy")
		and target and target:IsValid() and target:HasTag("player") and not self.inst.components.timer:TimerExists("skill")
		and self.inst:IsNear(target,12)
		and self.inst.skillmode == 3
end
function SpiderQueenBrain:CanCastSkill4()
	local target = self.inst.components.combat.target
	return self.inst:IsValid() and self.inst:GetTimeAlive() > 5 and not self.inst.components.health:IsDead()
		and not self.inst.sg:HasStateTag("busy")
		and target and target:IsValid() and target:HasTag("player") and not self.inst.components.timer:TimerExists("skill")
		and self.inst:IsNear(target,12)
		and self.inst.skillmode == 7
end
local function GetHomePos(inst)
	return inst.components.knownlocations:GetLocation("spawnpoint") or inst:GetPosition()
end
local function ShouldReset(self)
    if not self.inst.reset and  not self.inst.components.health:IsDead() and self.inst.components.knownlocations:GetLocation("spawnpoint") then
        local dx, dy, dz = self.inst.Transform:GetWorldPosition()
        local spx, spy, spz = self.inst.components.knownlocations:GetLocation("spawnpoint"):Get()
        if distsq(spx, spz, dx, dz) >= (120 * 120) then
            return true
        end
    end
end
function SpiderQueenBrain:IsShield()
	return self.inst:IsValid() and self.inst.sg:HasStateTag("shield")
end
function SpiderQueenBrain:OnStart()
    local root = PriorityNode(
    {
		IfNode(function() return ShouldReset(self) end, "Reset Fight",
			ActionNode(function() self.inst.reset = true self.inst:GoHome() end)),
		IfNode(function() return self:CanCastSkill1() end, "skill",
			ActionNode(function() self.inst.sg:GoToState("skill1") end, "do castskill1" )),
		IfNode(function() return self:CanCastSkill2() end, "skill",
			ActionNode(function() self.inst.sg:GoToState("skill2",self.inst.components.combat.target) end, "do castskill2" )),
		IfNode(function() return self:CanCastSkill3() end, "skill",
			ActionNode(function() self.inst.sg:GoToState("skill3") end, "do castskill3" )),
		IfNode(function() return self:CanCastSkill4() end, "skill",
			ActionNode(function() self.inst.sg:GoToState("skill4") end, "do castskill4" )),
		ChaseAndAttack(self.inst, 60, 40, nil, nil, nil, 25),
		IfNode(function() return self:IsShield() end, "Shield",
			ActionNode(function() end, "do shield" )),
		Wander(self.inst, GetHomePos, 6)
    }, 1)
    self.bt = BT(self.inst, root)
end
function SpiderQueenBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("spawnpoint", self.inst:GetPosition())
end
return SpiderQueenBrain
