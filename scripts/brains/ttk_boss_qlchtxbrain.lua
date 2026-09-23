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
local MAX_WANDER_DIST = 8
local MIN_FOLLOW = 0
local MAX_FOLLOW = 4
local MED_FOLLOW = 2
local function LeaderPos(inst)
    local leader = inst.components.knownlocations:GetLocation("home")
    if leader then
        return leader
    end
    return Vector3(inst.Transform:GetWorldPosition())
end
local ttk_boss_icebutterflybrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)
function ttk_boss_icebutterflybrain:OnStart()
    local root =
        PriorityNode(
        {
            Wander(self.inst, LeaderPos, MAX_WANDER_DIST),
        },1)
    self.bt = BT(self.inst, root)
end
return ttk_boss_icebutterflybrain
