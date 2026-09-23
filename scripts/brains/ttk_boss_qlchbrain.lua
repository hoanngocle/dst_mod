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
require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/wander"
require "behaviours/doaction"
require "behaviours/attackwall"
require "behaviours/panic"
require "behaviours/leash"
require "behaviours/minperiod"
require "behaviours/standstill"
local QlcyBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
    self.abilityname = nil
    self.abilitydata = nil
end)
local function HomePoint(inst)
    return inst.components.knownlocations:GetLocation("spawnpoint")
end
local function skillrange(inst)
    if inst.skillmode == 1 or inst.skillmode == 3 then
        return 16
    else
        return 20
    end
end
local function ShouldSpell1(self)
    if not self.inst.components.timer:TimerExists("spell_cd") then
        local target = self.inst.components.combat.target
        if target and target:IsValid() and self.inst:IsNear(target,skillrange(self.inst)) then
            self.abilitydata = { target = target }
            return true
        end
    end
    return false
end
local function ShouldUseAbility(self)
    self.abilityname = self.inst.components.combat:HasTarget() and (
        (ShouldSpell1(self) and "spell1")
    ) or nil
    return self.abilityname ~= nil
end
local function ShouldReset(self)
    if not self.inst.reset and  not self.inst.components.health:IsDead() then
        local dx, dy, dz = self.inst.Transform:GetWorldPosition()
        local spx, spy, spz = self.inst.components.knownlocations:GetLocation("spawnpoint"):Get()
        if distsq(spx, spz, dx, dz) >= (60 * 60) or
                TheWorld.Map:IsSurroundedByWater(dx, dy, dz, 4) then
            return true
        end
    end
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
function QlcyBrain:OnStart()
    local root =
        PriorityNode(
        {
            WhileNode(function() return ShouldReset(self) end, "Reset Fight",
                ActionNode(function()
                    self.inst.reset = true
                    self.inst:GoHome()
                end)),
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
            Leash(self.inst, HomePoint, 20, 10),
            Wander(self.inst, HomePoint, 8)
        }, .25)
    self.bt = BT(self.inst, root)
end
function QlcyBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("spawnpoint", self.inst:GetPosition())
end
return QlcyBrain
