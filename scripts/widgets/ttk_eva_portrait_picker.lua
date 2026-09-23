local Widget = require "widgets/widget"
local Image = require "widgets/image"
local Text = require "widgets/text"
local TextButton = require "widgets/textbutton"
local Portraits = require "ttk_eva_portraits"

local Picker = Class(Widget, function(self)
    Widget._ctor(self, "TTKEvaPortraitPicker")
    self.title = self:AddChild(Text(TITLEFONT, 34, "EVA"))
    self.title:SetPosition(0, 275)
    self.picture = self:AddChild(Image())
    self.picture:SetPosition(0, 30)
    self.picture:SetClickable(false)
    local function Button(label, x, y, callback)
        local button = self:AddChild(TextButton())
        button:SetText(label)
        button:SetTextSize(28)
        button:SetTextColour(.84, .73, 1, 1)
        button:SetTextFocusColour(1, 1, 1, 1)
        button:SetPosition(x, y)
        button:SetOnClick(callback)
        return button
    end
    self.previous = Button("<", -225, 30, function() self.state:Step(-1) end)
    self.next = Button(">", 225, 30, function() self.state:Step(1) end)
    self.counter = self:AddChild(Text(UIFONT, 24, ""))
    self.counter:SetPosition(0, -205)
    self.save = Button("Đặt làm mặc định", 0, -245, function() self.state:Save() end)
    self.notice = self:AddChild(Text(UIFONT, 20, ""))
    self.notice:SetPosition(0, -280)
    self.state = Portraits.New(TheSim, function()
        if self.inst:IsValid() then self:Refresh() end
    end)
    self:Refresh()
    self.state:Load()
end)
function Picker:Refresh()
    local entry = self.state:Get()
    self.picture:SetTexture(entry.atlas, entry.texture)
    self.picture:SetSize(430 * entry.ratio, 430)
    self.counter:SetString(string.format("Ảnh %d / %d", self.state.index, #Portraits.entries))
    self.notice:SetString(self.state.saving and "Đang lưu..."
        or self.state.error and "Không lưu được. Hãy thử lại."
        or self.state:IsDefault() and "Ảnh mặc định"
        or "Chưa đặt làm mặc định")
    if self.state.saving or self.state:IsDefault() then self.save:Disable() else self.save:Enable() end
end
return Picker
