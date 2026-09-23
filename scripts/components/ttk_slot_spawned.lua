-- Persist the distinction between a lottery creature and a natural world boss.
local Spawned = Class(function(self, inst)
    self.inst = inst
    self.add_component_if_missing = true
end)
function Spawned:OnSave()
    return {add_component_if_missing = true}
end
return Spawned
