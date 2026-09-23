require("behaviours/wander")
local SpiritBrain = Class(Brain, function(self, inst) Brain._ctor(self, inst) end)
function SpiritBrain:OnStart()
    self.bt = BT(self.inst, PriorityNode({
        Wander(self.inst, function()
            return self.inst.components.knownlocations:GetLocation("home") or self.inst:GetPosition()
        end, 8),
    }, 1))
end
return SpiritBrain
