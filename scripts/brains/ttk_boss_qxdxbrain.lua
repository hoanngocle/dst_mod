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
require "behaviours/standandattack"
require "behaviours/faceentity"
require "behaviours/standstill"
require "behaviours/chaseandattack"
local START_FACE_DIST = 10
local KEEP_FACE_DIST = 15
local ttk_qxdx = Class(Brain, function(self, inst)
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
local COMBAT_TIMEOUT = 480
local function IsInCombat(inst)
    local combat = inst.components.combat
    if inst:GetTimeAlive() < COMBAT_TIMEOUT then
        return true
    end
    local timeout_time = GetTime() - COMBAT_TIMEOUT
    local attack_time = math.max(combat.laststartattacktime or 0, combat.lastdoattacktime or 0)
    if attack_time > timeout_time then
        return true
    end
    if combat:GetLastAttackedTime() > timeout_time then
        if combat.lastattacker ~= nil and combat.lastattacker.components.combat == nil then
            return false
        end
        return true
    end
    return false
end
local function ShouldUseAbility(self)
    if not self.inst:IsValid() then
        return false
    end
    if not IsInCombat(self.inst) then
        self.abilityname = "goaway"
        self.abilitydata = { }
    elseif self.inst.mode == 1 and self.inst.components.health:GetPercent() <= 0.65 and not self.inst.components.health:IsDead() then
        self.abilityname = "transform"
        self.abilitydata = { }
    elseif self.inst.mode == 2 and not self.inst.components.health:IsDead() and not self.inst.components.timer:TimerExists("superjump_cd")
        and self.inst.components.combat.target then
        self.abilityname = "superjump"
        self.abilitydata = { }
    elseif self.inst.mode == 2 and not self.inst.components.health:IsDead() and not self.inst.components.timer:TimerExists("spike_cd")
        and self.inst.components.combat.target then
        self.abilityname = "spike"
        self.abilitydata = {}
    end
    return self.abilityname ~= nil
end
local function GetHomePos(inst)
	return inst.components.knownlocations:GetLocation("spawnpoint")
end
function ttk_qxdx:OnStart()
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
function ttk_qxdx:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("spawnpoint", self.inst:GetPosition())
end
return ttk_qxdx
