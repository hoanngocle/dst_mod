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
require "behaviours/leash"
require "behaviours/standstill"
require "behaviours/wander"
local BrainCommon = require("brains/braincommon")
local STALKER_RADIUS = .75
local MINION_RADIUS = .3
local LEASH_DIST = STALKER_RADIUS + MINION_RADIUS
local StalkerMinionBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)
local function GetTarget(inst)
    local target = inst.target
    if target and target:IsValid() then
        return target
    end
end
local function GetTargetPos(inst)
    local target = GetTarget(inst)
    return target ~= nil and  target:GetPosition() or nil
end
function StalkerMinionBrain:OnStart()
    local root = PriorityNode({
		BrainCommon.PanicTrigger(self.inst),
        Leash(self.inst, GetTargetPos, LEASH_DIST, LEASH_DIST),
        ActionNode(function()
            local target = GetTarget(self.inst)
            local range = target ~= nil and  (target:GetPhysicsRadius(0) + (target:HasTag("largecreature") and 2.5 or 1.8)) or 0
            if target ~= nil and self.inst:GetDistanceSqToInst(target) < range * range and  not self.inst.components.health:IsDead() then
                self.inst.components.health:Kill()
            end
        end),
        StandStill(self.inst)
    }, 0.2)
    self.bt = BT(self.inst, root)
end
return StalkerMinionBrain
