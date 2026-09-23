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
require "behaviours/panic"
require "behaviours/attackwall"
require "behaviours/leash"
require "behaviours/standstill"
local BrainCommon = require("brains/braincommon")
local RETURN_DIST = 15
local BASE_DIST = 6
local BirdMutantBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
    self._losttime = nil
    self._petrifytime = nil
end)
local function GetSwarmTarget(inst)
    return inst.components.entitytracker:GetEntity("ttk_jfsn")
end
local function GetSwarmTargetPos(inst)
    local target = GetSwarmTarget(inst)
    return target ~= nil and target:GetPosition() or nil
end
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
function BirdMutantBrain:OnStart()
    local brain =
    {
        IfNode(function() return GetSwarmTargetPos(self.inst) end, "move to target",
            Leash(self.inst,GetSwarmTargetPos,self.inst.maxdist or 0.5,self.inst.targetdist or 1)),
        StandStill(self.inst),
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
return BirdMutantBrain
