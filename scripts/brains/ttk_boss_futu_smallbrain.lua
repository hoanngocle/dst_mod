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
require "behaviours/avoidlight"
require "behaviours/attackwall"
require "behaviours/useshield"
local BrainCommon = require "brains/braincommon"
local SEE_FOOD_DIST = 10
local TRADE_DIST = 20
local MAX_WANDER_DIST = 32
local DAMAGE_UNTIL_SHIELD = 50
local SHIELD_TIME = 3
local AVOID_PROJECTILE_ATTACKS = false
local HIDE_WHEN_SCARED = true
local SpiderBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)
local function GetFaceTargetFn(inst)
    return inst.components.follower.leader
end
local function KeepFaceTargetFn(inst, target)
    return inst.components.follower.leader == target
end
local function ShouldSpell(self)
    local target = self.inst.components.combat.target
    if target and target:IsValid() and self.inst:IsValid() then
        local distancesq = self.inst:GetDistanceSqToInst(target)
        if not self.inst.components.timer:TimerExists("skill1") and distancesq >= 100 and distancesq < 256 then
            self.abilityname = "skill1"
            self.abilitydata = {target = target}
        elseif not self.inst.components.timer:TimerExists("skill2") and distancesq >= 16 and distancesq < 100 then
            self.abilityname = "skill2"
            self.abilitydata = {target = target}
        end
    end
    return self.abilityname ~= nil
end
local function ShouldGoHome(self)
    if self.inst.target then
        local target = self.inst.target
        if not (target and target:IsValid() and not IsEntityDeadOrGhost(target)) then
            return true
        end
    end
end
function SpiderBrain:CanCastSkill()
    local target = self.inst.components.combat.target
	return self.inst:IsValid() and self.inst:GetTimeAlive() > 5 and not self.inst.components.health:IsDead()
		and not self.inst.sg:HasStateTag("busy")
        and target and target:IsValid() and target:HasTag("player") and not self.inst.components.timer:TimerExists("skill")
end
function SpiderBrain:OnStart()
    local post_nodes = PriorityNode({
        Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, MAX_WANDER_DIST)
    })
    local attack_nodes = PriorityNode({
        WhileNode(function() return ShouldGoHome(self) end, "Reset Fight",
            ActionNode(function()
                self.inst:GoDeath()
            end)),
        IfNode(function() return self:CanCastSkill() end, "skill",
			ActionNode(function() self.inst.sg:GoToState("skill5") end, "do castskill" )),
        ChaseAndAttack(self.inst, SpringCombatMod(10)),
    })
    local follow_nodes = PriorityNode({
        Follow(self.inst, function() return self.inst.components.follower.leader end,
                4, 4, 6),
        IfNode(function() return self.inst.components.follower.leader ~= nil end, "HasLeader",
            FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn )),
    })
    local root =
        PriorityNode(
        {
            attack_nodes,
            follow_nodes,
            post_nodes,
        }, 1)
    self.bt = BT(self.inst, root)
end
function SpiderBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("home", Point(self.inst.Transform:GetWorldPosition()))
end
return SpiderBrain
