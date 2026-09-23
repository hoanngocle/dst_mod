local Widget = require "widgets/widget"
local Image = require "widgets/image"
local Text = require "widgets/text"

local HHShadowCountUI = Class(Widget, function(self, owner, inventorybar)
    Widget._ctor(self, "HHShadowCountUI")
    self.owner = owner
    self.inventorybar = inventorybar

    local config = TUNING.HH_SHADOW_HUD or {}
    self.width = config.HUD_WIDTH or 320
    self.height = config.HUD_HEIGHT or 100
    self.scale = config.HUD_SCALE or 1
    self:SetScale(self.scale)

    self.frame = self:AddChild(Image("images/shadow_hud.xml", "shadow_hud.tex"))
    self.frame:SetSize(self.width, self.height)

    self.value = self:AddChild(Text(UIFONT, 40, "0 / 0"))
    self.value:SetPosition(6, -4, 1)
    self.value:SetColour(0.85, 0.72, 1, 1)

    self.inst:ListenForEvent("hh_shadow_countdirty", function() self:Refresh() end, owner)
    self.inst:ListenForEvent("hh_shadow_maxdirty", function() self:Refresh() end, owner)

    self:Refresh()
    self:StartUpdating()
end)

function HHShadowCountUI:Refresh()
    if not self.owner then return end
    local count = self.owner.hh_shadow_count and self.owner.hh_shadow_count:value() or 0
    local maximum = self.owner.hh_shadow_max and self.owner.hh_shadow_max:value() or 0
    self.value:SetString("Bóng Ma " .. tostring(count) .. " / " .. tostring(maximum))
end

function HHShadowCountUI:UpdateInventoryOffset()
    local top_row_y = 0
    local top_row = self.inventorybar and self.inventorybar.toprow
    if top_row and top_row.GetPosition then
        top_row_y = top_row:GetPosition().y or 0
    end

    local integrated = self.inventorybar and self.inventorybar.integrated_backpack
        and self.inventorybar.backpackinv and #self.inventorybar.backpackinv > 0
    if integrated and self.inventorybar.bottomrow and self.inventorybar.bottomrow.GetPosition then
        local bottom_row_y = self.inventorybar.bottomrow:GetPosition().y or 0
        top_row_y = top_row_y + math.abs(top_row_y - bottom_row_y) * 0.5
    end

    local config = TUNING.HH_SHADOW_HUD or {}
    local offset_x = config.HUD_OFFSET_X or 0
    local offset_y = config.HUD_OFFSET_Y or 0
    local frame_half_height = self.height * 0.5 * self.scale
    self:SetPosition(offset_x, top_row_y + frame_half_height + offset_y, 0)
end

function HHShadowCountUI:OnUpdate()
    self:UpdateInventoryOffset()
end

return HHShadowCountUI
