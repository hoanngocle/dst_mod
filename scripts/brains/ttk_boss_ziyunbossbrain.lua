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
require "behaviours/standandattack"
require "behaviours/faceentity"
require "behaviours/standstill"
require "behaviours/chaseandattack"
local START_FACE_DIST = 10
local KEEP_FACE_DIST = 15
local EyeTurretBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)
local function ShouldKite(target, inst)
    return inst.components.combat:TargetIs(target)
        and target.components.health ~= nil
        and not target.components.health:IsDead()
end
local function ShouldAvoidExplosive(target)
    return target.components.explosive == nil
        or target.components.burnable == nil
        or target.components.burnable:IsBurning()
end
local AVOID_EXPLOSIVE_DIST = 5
local KITING_DIST = 5
local STOP_KITING_DIST = 8
local SKILL_TARGET_DIST = 20
local function ShouldUseAbility(self)
    if not self.inst:IsValid() then
        return false
    end
    if self.inst.mode == 3 and not self.inst.components.timer:TimerExists("liedui") then
        local target = self.inst.components.combat.target
        if not (target and target:IsValid() and self.inst:IsNear(target,SKILL_TARGET_DIST)
            and XD_CanAttackTrget(self.inst,target)) then
            target = nil
        end
        if not (target and target:HasTag("player")) then
            local findtarget = {}
            for i, v in ipairs(AllPlayers) do
                if v:IsValid() and self.inst:IsNear(v,SKILL_TARGET_DIST) and XD_CanAttackTrget(self.inst,v) then
                    table.insert(findtarget,v)
                end
            end
            if next(findtarget) ~= nil then
                shuffleArray(findtarget)
            end
            target = findtarget[1]
        end
        if target and target:IsValid() and target:HasTag("player") then
            self.abilityname = "liedui"
            self.abilitydata = { target = target }
        end
    end
    return self.abilityname ~= nil
end
local function GetHomePos(inst)
	return inst.components.knownlocations:GetLocation("spawnpoint")
end
function EyeTurretBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode(
			function() return not self.inst.sg:HasStateTag("flying") end,"Flying",
            PriorityNode({
                WhileNode(function() return ShouldUseAbility(self) end, "Ability",
                ActionNode(function()
                    self.inst:PushEvent(self.abilityname, self.abilitydata)
                    self.abilityname = nil
                    self.abilitydata = nil
                end)),
                PriorityNode({
                    IfNode(function() return true end, "Is Duelist",
                        PriorityNode({
                            WhileNode(function() return self.inst.components.timer:TimerExists("attack_cd") and ShouldKite(self.inst.components.combat.target, self.inst) end, "Dodge",
                            RunAway(self.inst, { fn = ShouldKite, tags = { "_combat", "_health" }, notags = { "INLIMBO" } }, KITING_DIST, STOP_KITING_DIST)),
                            ChaseAndAttack(self.inst),
                    }, .25)),
                }, .25),
                Wander(self.inst, GetHomePos, 6)
        }, 0.5)),
    }, .25)
    self.bt = BT(self.inst, root)
end
function EyeTurretBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("spawnpoint", self.inst:GetPosition())
end
return EyeTurretBrain
