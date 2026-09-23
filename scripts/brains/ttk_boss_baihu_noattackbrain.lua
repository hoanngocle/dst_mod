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
require("behaviours/chaseandattack")
require("behaviours/faceentity")
require("behaviours/leash")
require("behaviours/runaway")
require("behaviours/wander")
local DaywalkerBrain = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
end)
local function GetHomePos(inst)
	return inst.components.knownlocations:GetLocation("spawnpoint")
end
function DaywalkerBrain:OnStart()
	local root = PriorityNode({
		Wander(self.inst, GetHomePos, 6)
	})
	self.bt = BT(self.inst, root)
end
function DaywalkerBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("spawnpoint", self.inst:GetPosition())
end
return DaywalkerBrain
