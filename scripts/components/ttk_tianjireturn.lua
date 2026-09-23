local Return = Class(function(self, inst) self.inst=inst end)
function Return:Mark(x,z)
    self.pos={x=x,z=z,shard=tostring(TheShard:GetShardId())}
end
function Return:OnSave() return {pos=self.pos} end
function Return:OnLoad(data) self.pos=data and data.pos or nil end
return Return
