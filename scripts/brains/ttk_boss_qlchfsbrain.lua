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
require "behaviours/panic"
require "behaviours/attackwall"
require "behaviours/chaseandattack"
require "behaviours/leash"
require "behaviours/faceentity"
require "behaviours/standstill"
local BrainCommon = require("brains/braincommon")
local FAR_DIST_SQ = 7 * 7
local RESET_COMBAT_DELAY = 10
local LOST_KEEPER_MIN_DELAY = .5
local LOST_KEEPER_MAX_DELAY = 2
local MAX_CHASE_TIME = 6
local DeerGemmedBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
    self._farfromkeeper = false
    self._lostkeepertime = nil
end)
local function GetKeeper(inst)
    return inst.components.entitytracker:GetEntity("keeper")
end
local function GetKeeperPos(inst)
    local keeper = GetKeeper(inst)
    return keeper ~= nil and keeper:GetPosition() or nil
end
local function GetKeeperOffset(inst)
    return inst.components.knownlocations:GetLocation("keeperoffset")
end
local function GetSlavePos(inst)
    local pos = GetKeeperPos(inst)
    if pos ~= nil then
        local offset = GetKeeperOffset(inst)
        return offset ~= nil and pos + offset or pos
    end
end
local function IsFarFromKeeper(self)
    if not self._farfromkeeper then
        local pos = GetSlavePos(self.inst)
        self._farfromkeeper = pos ~= nil and self.inst:GetDistanceSqToPoint(pos) >= FAR_DIST_SQ
    end
    return self._farfromkeeper
end
local function GetFaceTargetFn(inst)
    return inst.components.combat.target
end
local function KeepFaceTargetFn(inst, target)
    return inst.components.combat:TargetIs(target)
end
local function ShouldPanic(self)
    if self.inst.shouldavoidmagic then
        self.inst.shouldavoidmagic = nil
        return true
    end
    return BrainCommon.ShouldTriggerPanic(self.inst)
end
local function ShouldChase(self)
    local keeper = GetKeeper(self.inst)
    if keeper == nil then
        return false
    elseif keeper.IsUnchained ~= nil
        and keeper:IsUnchained()
        and keeper.components.health ~= nil
        and keeper.components.health:IsDead() then
        return true
    end
    local target = self.inst.components.combat.target
    if target ~= nil and
        target:IsValid() and self.inst:IsValid() and
        target:IsNear(self.inst, TUNING.DEER_ATTACK_RANGE + target:GetPhysicsRadius(0)) then
        return true
    end
    self.inst.components.combat:SetTarget(nil)
    return false
end
local function ShouldResetCombat(self)
    if GetKeeper(self.inst) ~= nil then
        self._lostkeepertime = nil
        return true
    elseif self._lostkeepertime == nil then
        self._lostkeepertime = GetTime() + GetRandomMinMax(LOST_KEEPER_MIN_DELAY, LOST_KEEPER_MAX_DELAY)
    end
    return false
end
local function ShouldUnshackle(self)
    return self._lostkeepertime ~= nil and self._lostkeepertime < GetTime()
end
function DeerGemmedBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode(function() return IsFarFromKeeper(self) end, "FarFromKeeper",
            Leash(self.inst, GetSlavePos, 1, 1, true)),
        NotDecorator(ActionNode(function() self._farfromkeeper = false end)),
        Leash(self.inst, GetSlavePos, .5, .5, false),
        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
        StandStill(self.inst),
    }, .5)
    self.bt = BT(self.inst, root)
end
return DeerGemmedBrain
