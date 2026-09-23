require "behaviours/follow"
require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/faceentity"

local ShadowBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local MIN_FOLLOW_DIST = 2
local TARGET_FOLLOW_DIST = 4
local MAX_FOLLOW_DIST = 8

function ShadowBrain:OnStart()
    local root = PriorityNode(
    {
        -- Đánh kẻ thù
        ChaseAndAttack(self.inst, 15),

        -- Theo đuôi chủ nhân
        Follow(self.inst, function() return self.inst.components.follower.leader end, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),

        -- Nhìn về phía chủ nhân khi rảnh rỗi
        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn)
    }, .25)
    
    self.bt = BT(self.inst, root)
end

function GetFaceTargetFn(inst)
    return inst.components.follower.leader
end

function KeepFaceTargetFn(inst, target)
    return inst.components.follower.leader == target
end

return ShadowBrain
