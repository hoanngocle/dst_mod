local Widget = require("widgets/widget")
local Text = require("widgets/text")

local HHDungeonCoinHUD = Class(Widget, function(self, owner)
    Widget._ctor(self, "HHDungeonCoinHUD")
    self.owner = owner
    self.text = self:AddChild(Text(UIFONT, 28, ""))
    self.text:SetColour(0.6, 0.8, 1, 1)
    self.inst:ListenForEvent("hh_dungeon_coindirty", function() self:Refresh() end, owner)
    self:Refresh()
end)

function HHDungeonCoinHUD:Refresh()
    local value = self.owner and self.owner.hh_dungeon_coins and self.owner.hh_dungeon_coins:value() or 0
    self.text:SetString("Xu Hầm ngục: " .. tostring(value))
end

return HHDungeonCoinHUD
