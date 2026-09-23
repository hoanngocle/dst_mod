require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/wander"
require "behaviours/faceentity"
require "behaviours/chaseandattack"
require "behaviours/follow"
require "behaviours/attackwall"

local BrainCommon = require("brains/braincommon")

local COMBAT_TOO_CLOSE_DIST = 5                 
local COMBAT_TOO_CLOSE_DIST_SQ = COMBAT_TOO_CLOSE_DIST * COMBAT_TOO_CLOSE_DIST
local COMBAT_SAFE_TO_WATCH_FROM_DIST = 8        
local COMBAT_SAFE_TO_WATCH_FROM_MAX_DIST = 16   
local COMBAT_SAFE_TO_WATCH_FROM_MAX_DIST_SQ = COMBAT_SAFE_TO_WATCH_FROM_MAX_DIST * COMBAT_SAFE_TO_WATCH_FROM_MAX_DIST
local COMBAT_TIMEOUT = 6
local BeefaloBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function GetWanderDistFn(inst)
    return TheWorld.state.isday and 12 or 5
end
local function getwanderpso(inst)
    if inst.components.homeseeker and inst.components.homeseeker.home then
        return inst.components.homeseeker.home:GetPosition()
    end
    return inst:GetPosition()
end
local function _avoidtargetfn(self, target)
    if target == nil or not target:IsValid()  then
        return false
    end
    local target_combat = target.components.combat
    local distsq = self.inst:GetDistanceSqToInst(target)
    if distsq >= COMBAT_SAFE_TO_WATCH_FROM_MAX_DIST_SQ then
        
        return false
    elseif distsq < COMBAT_TOO_CLOSE_DIST_SQ and target_combat:HasTarget() then
        
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

function BeefaloBrain:OnStart()
    local root = PriorityNode(
    {
        
        PriorityNode{
            RunAway(self.inst, {tags={"_combat", "_health"}, notags={"wall", "INLIMBO"}, 
            fn = CombatAvoidanceFindEntityCheck(self)}, 
            COMBAT_TOO_CLOSE_DIST, 
            COMBAT_SAFE_TO_WATCH_FROM_DIST),
        },

        WhileNode(function() return TheWorld.state.isnight end, "GoingHome",
            DoAction(self.inst, GoHomeAction, "go home", true )),

        Wander(self.inst, function() return getwanderpso(self.inst) end, GetWanderDistFn)
    }, .25)

    self.bt = BT(self.inst, root)
end

return BeefaloBrain
