local Widget = require("widgets/widget")
local Text = require("widgets/text")
local TextButton = require("widgets/textbutton")
local Theme = require("widgets/hh_ui/ttk_unified_theme")

local function AddButton(parent, label, x, callback)
    local button = parent:AddChild(TextButton())
    button:SetPosition(x, 284, 0)
    button:SetFont(Theme.GetFont())
    button:SetTextSize(24)
    button:SetText(label)
    button:SetTextColour(unpack(Theme.colours.text))
    button:SetTextFocusColour(unpack(Theme.colours.purple_soft))
    button:SetTextDisabledColour(unpack(Theme.colours.locked))
    button.text:SetRegionSize(240, 44)
    button:SetOnClick(callback)
    return button
end

local TTKNativePanel = Class(Widget, function(self, owner, shell, panel_id, modes)
    Widget._ctor(self, "ttk_native_panel_" .. panel_id)
    self.owner = owner
    self.shell = shell
    self.panel_id = panel_id
    self.modes = modes
    self.mode = modes[1]
    self.native_widget = nil
    self.open_task = nil
    self.request_pending = false
    self.disposed = false

    self.message = self:AddChild(Text(Theme.GetFont(), 24, ""))
    self.message:SetPosition(0, 0, 0)
    self.message:SetRegionSize(900, 100)
    self.message:EnableWordWrap(true)
    self.message:SetColour(unpack(Theme.colours.muted))

    self.mode_buttons = {}
    local total = #modes
    for index, mode in ipairs(modes) do
        local x = (index - (total + 1) / 2) * 260
        self.mode_buttons[mode.id] = AddButton(self, mode.label, x, function()
            self:SelectMode(mode)
        end)
    end
end)

function TTKNativePanel:SetStatus(value)
    self.message:SetString(value or "")
end

function TTKNativePanel:SelectMode(mode)
    if self.disposed or mode == nil then
        return
    end
    local changing_mode = self.mode ~= mode
    if changing_mode then
        self:CloseNative()
        self.mode = mode
    end
    for _, entry in ipairs(self.modes) do
        local button = self.mode_buttons[entry.id]
        button:SetTextColour(unpack(entry == self.mode and Theme.colours.purple_soft or Theme.colours.text))
    end
    if changing_mode then
        self.open_task = self.inst:DoTaskInTime(.25, function()
            self.open_task = nil
            self:OpenNative()
        end)
    else
        self:OpenNative()
    end
end

function TTKNativePanel:OpenNative()
    if self.disposed or not self.shown or self.native_widget ~= nil or self.mode == nil
        or self.request_pending or self.open_task ~= nil then
        return false
    end
    self:SetStatus(self.mode.waiting or "Đang mở dữ liệu máy chủ…")
    self.request_pending = true
    local should_send, request_id = self.shell:BeginNativeOpen(self.panel_id, self.mode.prefab)
    if should_send then
        self.mode.open(self.owner, request_id)
    else
        self:SetStatus("Đang chờ request container trước hoàn tất…")
    end
    return true
end

function TTKNativePanel:OnNativeOpenFailed(prefab, reason)
    if self.disposed or not self.shown or not self.request_pending or self.mode == nil
        or self.mode.prefab ~= prefab then
        return false
    end
    self.request_pending = false
    self:SetStatus(reason or "Không thể mở giao diện lúc này")
    return true
end

function TTKNativePanel:OnNativeRequestResolved(prefab)
    if self.disposed or not self.shown or not self.request_pending or self.mode == nil
        or self.mode.prefab ~= prefab then
        return false
    end
    self.request_pending = false
    self:SetStatus("Đang đồng bộ lại container…")
    self.open_task = self.inst:DoTaskInTime(.25, function()
        self.open_task = nil
        self:OpenNative()
    end)
    return true
end

function TTKNativePanel:AttachNative(widget)
    self.request_pending = false
    self.native_widget = widget
    self:SetStatus("")
end

function TTKNativePanel:DetachNative(widget)
    if widget == nil or self.native_widget == widget then
        self.native_widget = nil
        self.request_pending = false
    end
end

function TTKNativePanel:CloseNative()
    if self.open_task ~= nil then
        self.open_task:Cancel()
        self.open_task = nil
    end
    if self.request_pending and self.shell.CancelNativeOpen ~= nil then
        self.shell:CancelNativeOpen()
    end
    self.shell:CloseNative()
    self.request_pending = false
    self.native_widget = nil
end

function TTKNativePanel:ShowPanel()
    self:Show()
    self:SelectMode(self.mode)
end

function TTKNativePanel:HidePanel()
    self:CloseNative()
    self:Hide()
end

function TTKNativePanel:DisposePanel()
    if self.disposed then return end
    self.disposed = true
    self:CloseNative()
    self:Kill()
end

return TTKNativePanel
