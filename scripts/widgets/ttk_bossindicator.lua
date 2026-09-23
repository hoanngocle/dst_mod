local TargetIndicator = require "widgets/targetindicator"

local BossIndicator = Class(TargetIndicator, function(self, owner, target, data)
    TargetIndicator._ctor(self, owner, target, data)
    if data ~= nil and data.name ~= nil then
        self.name = data.name
        self.name_label:SetString(data.name)
    end
end)

return BossIndicator
