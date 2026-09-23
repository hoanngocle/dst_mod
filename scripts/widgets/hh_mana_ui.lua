local Widget = require "widgets/widget"
local Image = require "widgets/image"
local Text = require "widgets/text"

local HHManaUI = Class(Widget, function(self, owner, inventorybar)
    Widget._ctor(self, "HHManaUI")
    self.owner = owner
    self.inventorybar = inventorybar
    self.displayed_ratio = 1
    self.target_ratio = 1
    self.width = TUNING.HH_MANA.HUD_WIDTH or 240
    self.height = TUNING.HH_MANA.HUD_HEIGHT or 24
    self.scale = TUNING.HH_MANA.HUD_SCALE or 1
    self:SetScale(self.scale)

    self.liquid = self:AddChild(Image("images/mana_liquid.xml", "mana_liquid.tex"))
    self.liquid:SetSize(self.width, self.height)
    self.liquid:SetPosition(0, 0, 0)

    self.frame = self:AddChild(Image("images/mana_frame.xml", "mana_frame.tex"))
    self.frame:SetSize(self.width, self.height)

    self.value = self:AddChild(Text(UIFONT, 18))
    self.value:SetPosition(0, -1, 1)
    self.value:SetColour(0.85, 0.72, 1, 1)

    self.inst:ListenForEvent("hh_mana_currentdirty", function() self:RefreshTarget() end, owner)
    self.inst:ListenForEvent("hh_mana_maxdirty", function() self:RefreshTarget() end, owner)
    self:RefreshTarget(true)
    self:StartUpdating()
end)

function HHManaUI:RefreshTarget(snap)
    local current = self.owner.hh_mana_current and self.owner.hh_mana_current:value() or 0
    local maximum = self.owner.hh_mana_max and self.owner.hh_mana_max:value() or 1
    maximum = math.max(1, maximum)
    self.target_ratio = math.max(0, math.min(1, current / maximum))
    if snap or current <= 0 then
        self.displayed_ratio = self.target_ratio
    end
    if current <= 0 then
        self.liquid:Hide()
    end
    self.value:SetString(tostring(current) .. " / " .. tostring(maximum))
end

function HHManaUI:UpdateLiquid()
    local inset_left = TUNING.HH_MANA.LIQUID_INSET_LEFT or 0
    local inset_right = TUNING.HH_MANA.LIQUID_INSET_RIGHT or 0
    local inner_width = math.max(0, self.width - inset_left - inset_right)
    local clip_width = inner_width * self.displayed_ratio
    if self.displayed_ratio <= 0.001 or clip_width <= 0.5 then
        self.liquid:Hide()
    else
        self.liquid:Show()
        self.liquid:SetScissor(
            -self.width * 0.5 + inset_left,
            -self.height * 0.5,
            clip_width,
            self.height
        )
    end
end

function HHManaUI:UpdateInventoryOffset()
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
    local offset_x = TUNING.HH_MANA.HUD_OFFSET_X or 0
    local offset_y = TUNING.HH_MANA.HUD_OFFSET_Y or 18
    local frame_half_height = self.height * 0.5 * self.scale
    self:SetPosition(offset_x, top_row_y + frame_half_height + offset_y, 0)
end

function HHManaUI:OnUpdate(dt)
    local speed = 12
    local blend = 1 - math.exp(-speed * math.max(0, dt or 0))
    self.displayed_ratio = self.displayed_ratio + (self.target_ratio - self.displayed_ratio) * blend
    if math.abs(self.target_ratio - self.displayed_ratio) < 0.001 then self.displayed_ratio = self.target_ratio end
    self:UpdateLiquid()
    self:UpdateInventoryOffset()
end

return HHManaUI
