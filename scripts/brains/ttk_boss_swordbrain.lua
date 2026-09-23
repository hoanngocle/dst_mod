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
require "behaviours/runaway"
require "behaviours/wander"
require "behaviours/doaction"
require "behaviours/follow"
local MAX_WANDER_DIST = 3
local MIN_FOLLOW = 0
local MAX_FOLLOW = 4
local MED_FOLLOW = 2
local function LeaderPos(inst)
    local leader = inst.components.follower.leader
    if leader == nil then
        leader = inst
    end
    if leader and leader:IsValid() then
        return Vector3(leader.Transform:GetWorldPosition())
    end
end
local function getLeader(self)
    local leader = self.inst.components.follower.leader
    if leader  and leader:IsValid() and leader.mode2_pet and leader.mode2_pet:IsValid() then
        return leader.mode2_pet
    end
    return leader
end
local function ShouldCastShentong(inst)
    return inst.ShouldCastShentong ~= nil and inst:ShouldCastShentong()
end
local ttk_boss_swordbrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)
function ttk_boss_swordbrain:OnStart()
    local root =
        PriorityNode(
        {
            WhileNode(function() return ShouldCastShentong(self.inst) end, "Shentong",
                ActionNode(function()
                    self.inst.sg:GoToState("shentong")
                end)
            ),
            Follow(self.inst, function() return getLeader(self) end, 0, 2.5, 5.5),
            StandStill(self.inst),
        },0.1)
    self.bt = BT(self.inst, root)
end
return ttk_boss_swordbrain
