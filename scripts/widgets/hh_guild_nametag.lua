local Widget = require("widgets/widget")
local Text = require("widgets/text")

local HHGuildNametag = Class(Widget, function(self, owner)
    Widget._ctor(self, "HHGuildNametag")
    self.owner = owner
    self.target = nil
    self.search_elapsed = 0

    self:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self:SetMaxPropUpscale(MAX_HUD_SCALE)
    self:SetHAnchor(ANCHOR_LEFT)
    self:SetVAnchor(ANCHOR_BOTTOM)

    self.label = self:AddChild(Text(TALKINGFONT, 30, "Nhân Viên Hiệp Hội"))
    self.label:SetColour(.45, .85, 1, 1)

    self:StartUpdating()
    self:Hide()
end)

function HHGuildNametag:FindTarget()
    self.target = TheSim:FindFirstEntityWithTag("hh_guild_employee")
end

function HHGuildNametag:OnUpdate(dt)
    self.search_elapsed = self.search_elapsed + (dt or 0)
    if self.target == nil or not self.target:IsValid() or self.search_elapsed >= 1 then
        self.search_elapsed = 0
        self:FindTarget()
    end
    if self.target == nil or not self.target:IsValid() then
        self:Hide()
        return
    end

    local x, y, z = self.target.Transform:GetWorldPosition()
    local screen_x, screen_y = TheSim:GetScreenPos(x, y + 3.1, z)
    local width, height = TheSim:GetScreenSize()
    if screen_x == nil or screen_y == nil
        or screen_x < -80 or screen_y < -80
        or screen_x > width + 80 or screen_y > height + 80 then
        self:Hide()
        return
    end

    self:SetPosition(screen_x, screen_y, 0)
    self:Show()
end

return HHGuildNametag
