--[[
Copyright (C) 2018 Forged Forge

This file is part of Forged Forge.

The source code of this program is shared under the RECEX
SHARED SOURCE LICENSE (version 1.0).
The source code is shared for referrence and academic purposes
with the hope that people can read and learn from it. This is not
Free and Open Source software, and code is not redistributable
without permission of the author. Read the RECEX SHARED
SOURCE LICENSE for details
The source codes does not come with any warranty including
the implied warranty of merchandise.
You should have received a copy of the RECEX SHARED SOURCE
LICENSE in the form of a LICENSE file in the root of the source
directory. If not, please refer to
<https://raw.githubusercontent.com/Recex/Licenses/master/SharedSourceLicense/LICENSE.txt>
]]
local common_brain = require("brains/common_brain_functions")

local BoarriorBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

-- TODO tuning global variable MAP_RANGE
-- Add inst.avoid_healing_circle check
-- Why was notarget a canttag, and healingcircle a mustoneoftags?
local function AvoidHealingCircles(inst) -- TODO common fn???
	local x, y, z = inst.Transform:GetWorldPosition()
	return inst.avoid_healing_circles and TheSim:FindEntities(x, y, z, 255, {"healingcircle"}) or {}
end

local behaviour_values = {
	findavoidanceobjectsfn = AvoidHealingCircles,
	avoid_dist = 4, -- TODO tuning?
}

function BoarriorBrain:OnStart()
    self.bt = BT(self.inst, common_brain.CreateMobBehaviorRoot(self.inst, nil, behaviour_values))
end

return BoarriorBrain
