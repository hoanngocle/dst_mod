require "behaviours/wander"
require "behaviours/faceentity"
require "behaviours/chaseandattack"
require "behaviours/follow"
require "behaviours/attackwall"

local BrainCommon = require("brains/braincommon")

local COMBAT_TOO_CLOSE_DIST = 8                 
local COMBAT_TOO_CLOSE_DIST_SQ = COMBAT_TOO_CLOSE_DIST * COMBAT_TOO_CLOSE_DIST
local COMBAT_SAFE_TO_WATCH_FROM_DIST = 12        
local COMBAT_SAFE_TO_WATCH_FROM_MAX_DIST = 20   
local COMBAT_SAFE_TO_WATCH_FROM_MAX_DIST_SQ = COMBAT_SAFE_TO_WATCH_FROM_MAX_DIST * COMBAT_SAFE_TO_WATCH_FROM_MAX_DIST
local COMBAT_TIMEOUT = 4

local MIN_FOLLOW_LEADER = 0
local MAX_FOLLOW_LEADER = 12
local TARGET_FOLLOW_LEADER = 8

local BeefaloBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function GetWanderDistFn(inst)
    return 8
end
local function getwanderpso(inst)
    if inst.components.follower ~= nil and inst.components.follower.leader and inst.components.follower.leader:IsValid() then
        return inst.components.follower.leader:GetPosition()
    end
    if inst.components.homeseeker and inst.components.homeseeker.home and inst.components.homeseeker.home:IsValid() then
        return inst.components.homeseeker.home:GetPosition()
    end
    return inst:GetPosition()
end
local function _avoidtargetfn(self, target)
    if target == nil or not target:IsValid()  then
        return false
    end
    if self.inst.runaway_target ~= target then
        return false
    end
    local distsq = self.inst:GetDistanceSqToInst(target)
    if distsq >= COMBAT_SAFE_TO_WATCH_FROM_MAX_DIST_SQ then
        return false
    end
    if self.inst.last_runaway_time and (GetTime() - self.inst.last_runaway_time) < COMBAT_TIMEOUT then
        return true
    end
end

local function CombatAvoidanceFindEntityCheck(self)
    return function(ent)
            if _avoidtargetfn(self, ent) then
                self.inst:PushEvent("avoidcombat", {avoid=true})
                self.runawayfrom = ent
                return true
            end
            return false
        end
end

local function GoHomeAction(inst)
	local home = inst.components.homeseeker and inst.components.homeseeker.home or nil
    if home ~= nil and home:IsValid() and (not home.components.burnable or not home.components.burnable:IsBurning()) then
        return BufferedAction(inst, home, ACTIONS.GOHOME)
    end
end

local function GetLeader(inst)
    return inst.components.follower ~= nil and inst.components.follower.leader or nil
end

function BeefaloBrain:OnStart()
    local root = PriorityNode(
    {
        
        PriorityNode{
            RunAway(self.inst, {tags={"_combat", "_health"}, notags={"wall", "INLIMBO"}, 
            fn = CombatAvoidanceFindEntityCheck(self)}, 
            COMBAT_TOO_CLOSE_DIST, 
            COMBAT_SAFE_TO_WATCH_FROM_DIST),
        },
        Follow(self.inst, GetLeader, MIN_FOLLOW_LEADER, TARGET_FOLLOW_LEADER, MAX_FOLLOW_LEADER),
        
        WhileNode(function() return TheWorld.state.isnight and not GetLeader(self.inst)  end, "GoingHome",
            DoAction(self.inst, GoHomeAction, "go home", true )),

        ChaseAndAttack(self.inst),

        Wander(self.inst, function() return getwanderpso(self.inst) end, GetWanderDistFn)
    }, .25)

    self.bt = BT(self.inst, root)
end

return BeefaloBrain
