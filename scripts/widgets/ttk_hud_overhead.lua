local Widget = require("widgets/widget")
local Standard = require("widgets/ttk_hud_standard_bar")

local function IsEpicDisplayed(parent, player)
    local controls = player ~= nil and player.HUD ~= nil and player.HUD.controls or nil
    local epic = controls ~= nil and controls.epichealthbar or nil
    return epic ~= nil and epic.target == parent and epic.shown
        and (epic.active or (type(epic.IsMoving) == "function" and epic:IsMoving()))
        or false
end

local Bar = Class(Widget, function(self, proxy)
    Widget._ctor(self, "TTKHUDOverheadBar")
    self:SetClickable(false)
    self:SetScaleMode(SCALEMODE_NONE)
    self:SetHAnchor(ANCHOR_LEFT)
    self:SetVAnchor(ANCHOR_BOTTOM)
    self.proxy = proxy
    self.standard = self:AddChild(Standard.Widget())
    self._parent = nil
    self._initialized = false
    self.inst:ListenForEvent("ttk_hud_overhead_dirty", function()
        if proxy._visible:value() then self:StartUpdating() end
    end, proxy)
    self.inst:ListenForEvent("onremove", function() self:Kill() end, proxy)
    self:StartUpdating()
end)

function Bar:OnUpdate()
    local proxy = self.proxy
    if proxy == nil or not proxy:IsValid() then self:Kill() return end
    if not proxy._visible:value() then self:Hide(); self:StopUpdating(); return end
    local parent = proxy.entity:GetParent()
    if parent == nil or not parent:IsValid() then self:Hide() return end
    if TUNING.TTK_HUD.HIDE_BOSS_OVERHEAD and IsEpicDisplayed(parent, ThePlayer) then
        self:Hide()
        return
    end
    if ThePlayer == nil or parent:GetDistanceSqToInst(ThePlayer) > 1225 then self:Hide(); self:StopUpdating(); return end
    self:Show()
    local current, maximum = proxy._current:value(), math.max(1, proxy._maximum:value())
    local x, y, z = parent.Transform:GetWorldPosition()
    local sx, sy = TheSim:GetScreenPos(x, y + 2.7, z)
    local width, height = TheSim:GetScreenSize()
    if sx == nil or sy == nil or sx < -80 or sy < -80 or sx > width + 80 or sy > height + 80 then
        self:Hide()
        return
    end

    if self._parent ~= parent then
        self._parent = parent
        self._initialized = false
        self.standard:SetTarget(parent)
        self.standard:SetHBSize(Standard.BASE_WIDTH * Standard.GetEntityWidth(parent),
            Standard.FIXED_HEIGHT)
        self.standard:SetFontSize(Standard.FONT_SIZE)
        self.standard:SetTextColor(1, 1, 1, 1)
        self.standard:SetOpacity(Standard.OPACITY)
        self.standard:AnimateIn(parent:HasTag("largecreature") and 2 or 8)
    end

    self.standard.showValue = TUNING.TTK_HUD.SHOW_VALUES
    local r, g, b = Standard.ResolveDynamic2(parent, ThePlayer)
    self.standard:SetBarColor(r, g, b)
    self.standard:SetValue(current, maximum, not self._initialized)
    self._initialized = true
end

Bar.IsEpicDisplayed = IsEpicDisplayed

return Bar
