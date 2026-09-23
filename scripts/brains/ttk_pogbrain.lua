require "behaviours/follow"
require "behaviours/wander"
require "behaviours/faceentity"
require "behaviours/panic"
require "behaviours/runaway"
require "behaviours/leash"
require "behaviours/doaction"
require "behaviours/chaseandattack"

local START_FACE_DIST = 4
local KEEP_FACE_DIST = 6

local MAX_CHASE_TIME = 4
local MAX_CHASE_DIST = 10

local NO_TAGS = {"FX", "NOCLICK", "DECOR","INLIMBO", "stump", "burnt"}
local PLAY_TAGS = {"cattoy", "cattoyairborne", "catfood"}

local PogBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local FINDFOOD_CANT_TAGS = { "outofreach" }
local function FindFoodAction(inst)
    if inst.sg:HasStateTag("busy") then
        return
    end
    if inst.components.timer:TimerExists("guyong") or inst.isshadow then
        return
    end
    if inst.components.homeseeker and inst.components.homeseeker.home and inst.components.homeseeker.home:IsValid() and inst:IsValid() then
        if not inst:IsNear(inst.components.homeseeker.home,22) then
            return
        end
    end
    local target = FindEntity(inst,
        20,
        function(item)
            return item:GetTimeAlive() >= 8
                and item.components.edible ~= nil
                and item.components.edible.foodtype == FOODTYPE.MEAT
                and item:IsOnPassablePoint()
                and inst.components.eater:CanEat(item)
        end,
        nil,
        FINDFOOD_CANT_TAGS
    )
    if target ~= nil then
        return BufferedAction(inst, target, ACTIONS.EAT)
    end
end

local function FindPickAction(inst)
    if inst.sg:HasStateTag("busy") then
        return
    end
    if not inst.components.timer:TimerExists("guyong") then
        return
    end
    if inst.components.homeseeker and inst.components.homeseeker.home and inst.components.homeseeker.home:IsValid() and inst:IsValid() then
        if not inst:IsNear(inst.components.homeseeker.home,22) then
            return
        end
    end
    local target = FindEntity(inst,
        20,
        function(item)
            return item:GetTimeAlive() >= 8
                and not item.components.trader
                and item.components.pickable ~= nil
                and item.components.pickable:CanBePicked()
                and item:IsOnPassablePoint()
        end,
        nil,
        {"pickbale"}
    )
    if target ~= nil then
        return BufferedAction(inst, target, ACTIONS.PICK)
    end
end

local function GetFaceTargetFn(inst)
    local target = GetClosestInstWithTag("player", inst, START_FACE_DIST)
    if target and not target:HasTag("notarget") then
        return target
    end
end

local function KeepFaceTargetFn(inst, target)
    return inst:GetDistanceSqToInst(target) <= KEEP_FACE_DIST*KEEP_FACE_DIST and not target:HasTag("notarget")
end

local function getwanderpso(inst)
    if inst.components.homeseeker and inst.components.homeseeker.home and inst.components.homeseeker.home:IsValid() then
        return inst.components.homeseeker.home:GetPosition()
    end
    return inst:GetPosition()
end

local function GoHomeAction(inst)
	local home = inst.components.homeseeker and inst.components.homeseeker.home or nil
    if home ~= nil and home:IsValid() and (not home.components.burnable or not home.components.burnable:IsBurning()) then
        return BufferedAction(inst, home, ACTIONS.GOHOME)
    end
end

local function cangohome(inst)
    return TheWorld.state.isdusk and not inst.components.timer:TimerExists("guyong") and not inst.isshadow
end

function PogBrain:OnStart()
    local root = 
    PriorityNode(
    {
        WhileNode( function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),
        
        WhileNode(function() return cangohome(self.inst)   end, "GoingHome", 
            DoAction(self.inst, GoHomeAction, "go home", true )),
        
        ChaseAndAttack(self.inst),
        DoAction(self.inst, FindPickAction ),
        
        DoAction(self.inst, FindFoodAction ),

        Wander(self.inst, function() return getwanderpso(self.inst) end, 12)
    }, .25)
    self.bt = BT(self.inst, root)
end

return PogBrain