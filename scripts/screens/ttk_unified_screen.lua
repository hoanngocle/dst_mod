local Screen = require("widgets/screen")
local Widget = require("widgets/widget")
local Controller = require("ui/ttk_unified_controller")
local Registry = require("ui/ttk_unified_registry")
local NativeBridge = require("ui/ttk_native_bridge")
local NativeInput = require("ui/ttk_native_input")
local Theme = require("widgets/hh_ui/ttk_unified_theme")
local Primitive = require("widgets/hh_ui/ttk_artifact_primitives")

local TABS = {
    { id = "character", label = "Nhân vật" },
    { id = "equipment", label = "Trang bị" },
    { id = "quests", label = "Nhiệm vụ" },
    { id = "army", label = "Quân đoàn" },
    { id = "shop", label = "Cửa hàng" },
    { id = "storage", label = "Kho" },
}

local function Embedded(child)
    return {
        child = child,
        ShowPanel = function(self)
            self.child:Show()
            if self.child.ShowPanel ~= nil then self.child:ShowPanel() end
        end,
        HidePanel = function(self)
            if self.child.HidePanel ~= nil then self.child:HidePanel() end
            self.child:Hide()
        end,
        DisposePanel = function(self)
            if self.child.DisposePanel ~= nil then self.child:DisposePanel() else self.child:Kill() end
        end,
    }
end

local function CreateNativePanel(owner, shell, panel_id, modes)
    local NativePanel = require("widgets/hh_ui/ttk_native_panel")
    return shell.content_root:AddChild(NativePanel(owner, shell, panel_id, modes))
end

local function DefaultFactories(owner, shell)
    return {
        character = function()
            local UI = require("widgets/hh_status_ui")
            local child = shell.content_root:AddChild(UI(owner, nil, {
                embedded = true,
                content_mode = "character",
                select_tab = function(id) shell:SelectTab(id) end,
            }))
            return Embedded(child)
        end,
        equipment = function()
            return CreateNativePanel(owner, shell, "equipment", {
                {
                    id = "summary", label = "Tổng Hợp", prefab = "hh_ui_container",
                    open = function(_, request_id)
                        SendModRPCToServer(MOD_RPC.hh_rpc.hh_ui_container, "ui_container", request_id)
                    end,
                },
                {
                    id = "forge", label = "Thần Binh Phổ", prefab = "hh_forge_container",
                    open = function(_, request_id)
                        SendModRPCToServer(MOD_RPC.hh_rpc.hh_ui_container, "forge_container", request_id)
                    end,
                },
            })
        end,
        quests = function()
            local UI = require("widgets/hh_ui/ttk_quest_panel")
            return shell.content_root:AddChild(UI(owner))
        end,
        army = function()
            local UI = require("screens/hh_shadow_upgrade_screen")
            return Embedded(shell.content_root:AddChild(UI(owner, { embedded = true })))
        end,
        shop = function()
            local ShopDefs = require("dungeon_shop/hh_dungeon_shop_defs")
            local UI = require("screens/hh_dungeon_shop_screen")
            return Embedded(shell.content_root:AddChild(UI(owner, ShopDefs, nil, { embedded = true })))
        end,
        storage = function()
            return CreateNativePanel(owner, shell, "storage", {
                {
                    id = "storage", label = "Kho Quân Vương", prefab = "hh_monarch_storage_container",
                    waiting = "Đang mở Kho Quân Vương theo quyền sở hữu hiện tại…",
                    open = function(_, request_id)
                        SendModRPCToServer(MOD_RPC.hh_rpc.hh_monarch_storage_open, request_id)
                    end,
                },
            })
        end,
    }
end

local TTKUnifiedScreen = Class(Screen, function(self, owner, options)
    Screen._ctor(self, "TTKUnifiedScreen")
    options = options or {}
    self.owner = owner
    self.tab_order = TABS
    self.active_tab = nil
    self.native_token = nil
    self.native_widget = nil
    self.closed = false

    self.root = self:AddChild(Widget("ttk_unified_root"))
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    local viewport_width, viewport_height = Theme.design.width, Theme.design.height
    if options.viewport_width ~= nil and options.viewport_height ~= nil then
        viewport_width, viewport_height = options.viewport_width, options.viewport_height
    elseif TheSim ~= nil and TheSim.GetScreenSize ~= nil then
        viewport_width, viewport_height = TheSim:GetScreenSize()
    end
    self.design_bounds = self:GetDesignBounds(viewport_width, viewport_height)
    self.root:SetScale(self.design_bounds.scale)

    self.backdrop = Primitive.Frame(
        self.root, 0, 0, Theme.shell.width, Theme.shell.height, Theme.colours.backdrop)
    self.title = Primitive.Label(
        self.root, "PHÀM NHÂN TU TIÊN", 42, 0, 382, Theme.colours.silver)
    self.top_divider = Primitive.Divider(self.root, 1280, 0, 292)

    self.content_root = self.root:AddChild(Widget("ttk_unified_content"))
    self.content_root:SetPosition(0, Theme.content.y, 1)

    self.close_button = Primitive.Button(
        self.root, "×", 54, 54, 650, 382, function() self:Close() end)

    self.tab_buttons = {}
    for index, tab in ipairs(TABS) do
        local button = Primitive.Button(
            self.root, tab.label, 204, 58,
            -535 + (index - 1) * 214, 330,
            function() self:SelectTab(tab.id) end)
        self.tab_buttons[index] = button
    end
    for index, button in ipairs(self.tab_buttons) do
        if self.tab_buttons[index - 1] ~= nil then
            button:SetFocusChangeDir(MOVE_LEFT, self.tab_buttons[index - 1])
        end
        if self.tab_buttons[index + 1] ~= nil then
            button:SetFocusChangeDir(MOVE_RIGHT, self.tab_buttons[index + 1])
        end
    end
    self.default_focus = self.tab_buttons[1]

    local factories = options.factories or DefaultFactories(owner, self)
    self.controller = Controller(factories)
    Registry.Set(owner, self)
    self:SelectTab(options.initial_tab or "character")
end)

function TTKUnifiedScreen:GetDesignBounds(viewport_width, viewport_height)
    viewport_width = math.max(1, viewport_width or Theme.design.width)
    viewport_height = math.max(1, viewport_height or Theme.design.height)
    local scale = Theme.GetFitScale(viewport_width, viewport_height)
    local width = Theme.design.width * scale
    local height = Theme.design.height * scale
    local left = (viewport_width - width) * .5
    local bottom = (viewport_height - height) * .5
    local right = left + width
    local top = bottom + height
    return {
        inside = left >= 0 and bottom >= 0 and right <= viewport_width and top <= viewport_height,
        left = left,
        right = right,
        top = top,
        bottom = bottom,
        scale = scale,
    }
end

function TTKUnifiedScreen:SelectTab(id)
    if self.closed or id == self.active_tab then return false end
    self.controller:CloseNative()
    self.native_token = nil
    local previous_tab = self.active_tab
    self.active_tab = id
    if not self.controller:Show(id) then
        self.active_tab = previous_tab
        return false
    end
    for index, tab in ipairs(self.tab_order) do
        self.tab_buttons[index]:SetTextColour(unpack(tab.id == id and Theme.colours.purple_soft or Theme.colours.text))
    end
    return true
end

function TTKUnifiedScreen:BeginNativeOpen(panel_id, prefab)
    local should_send, request_id = Registry.BeginNative(self.owner, self, prefab)
    if not should_send then
        self.native_token = nil
        self.controller:CancelNativeOpen()
        return false
    end
    self.native_token = self.controller:BeginNativeOpen(panel_id, prefab)
    return true, request_id
end

function TTKUnifiedScreen:CancelNativeOpen()
    self.native_token = nil
    self.controller:CancelNativeOpen()
    return Registry.CancelNative(self.owner, self)
end

function TTKUnifiedScreen:WantsNativeContainer(prefab)
    return self.controller:AcceptNativeOpen(self.native_token, self.active_tab, prefab)
end

function TTKUnifiedScreen:RejectNativeContainer(prefab)
    local resolved, queued_screen = Registry.ResolveNative(self.owner, self, prefab)
    local rejected = NativeBridge.Reject(prefab)
    if resolved and rejected and queued_screen ~= nil
        and queued_screen == Registry.Get(self.owner)
        and queued_screen.OnNativeRequestResolved ~= nil then
        queued_screen:OnNativeRequestResolved(prefab)
    end
    return rejected
end

function TTKUnifiedScreen:OnNativeRequestResolved(prefab)
    local panel = self.controller ~= nil and self.controller.active_panel or nil
    if panel ~= nil and panel.OnNativeRequestResolved ~= nil then
        return panel:OnNativeRequestResolved(prefab)
    end
    return false
end

function TTKUnifiedScreen:HandleNativeOpenFailure(prefab, request_id, reason)
    local resolved, target_screen = Registry.FailNative(self.owner, prefab, request_id)
    if not resolved then return false end
    if target_screen == Registry.Get(self.owner) and target_screen.OnNativeOpenFailed ~= nil then
        target_screen:OnNativeOpenFailed(prefab, reason)
    end
    return true
end

function TTKUnifiedScreen:OnNativeOpenFailed(prefab, reason)
    self.native_token = nil
    self.controller:CancelNativeOpen()
    local panel = self.controller.active_panel
    if panel ~= nil and panel.OnNativeOpenFailed ~= nil then
        return panel:OnNativeOpenFailed(prefab, reason)
    end
    return false
end

function TTKUnifiedScreen:TrackNativeContainer(widget, prefab)
    if not self:WantsNativeContainer(prefab) then
        return false
    end
    Registry.ResolveNative(self.owner, self, prefab)
    local surface = prefab == "hh_forge_container" and "forge" or "native"
    local scale = Theme.GetSurfaceScale(surface)
    widget:SetScale(scale, scale, 1)
    widget:Show()
    widget:MoveToFront()
    self.native_widget = widget

    local panel = self.controller.active_panel
    if panel ~= nil and panel.AttachNative ~= nil then
        panel:AttachNative(widget)
        if panel.MoveToFront ~= nil then panel:MoveToFront() end
    end
    self.controller:SetNativeCloser(function()
        if widget ~= nil and widget.isopen ~= false and widget.Close ~= nil then widget:Close() end
        if prefab == "hh_monarch_storage_container" then
            SendModRPCToServer(MOD_RPC.hh_rpc.hh_monarch_storage_close)
        elseif prefab == "hh_forge_container" then
            SendModRPCToServer(MOD_RPC.hh_rpc.hh_ui_container, "forge_container")
        else
            SendModRPCToServer(MOD_RPC.hh_rpc.hh_ui_container)
        end
    end)
    return true
end

function TTKUnifiedScreen:UntrackNativeContainer(widget)
    if self.native_widget ~= widget then return false end
    self.native_widget = nil
    self.native_token = nil
    self.controller:NativeClosed()
    local panel = self.controller.active_panel
    if panel ~= nil and panel.DetachNative ~= nil then panel:DetachNative(widget) end
    return true
end

-- Compatibility aliases for old container hooks and tests during migration.
TTKUnifiedScreen.AttachNativeContainer = TTKUnifiedScreen.TrackNativeContainer
TTKUnifiedScreen.DetachNativeContainer = TTKUnifiedScreen.UntrackNativeContainer

function TTKUnifiedScreen:CloseNative()
    return self.controller:CloseNative()
end

function TTKUnifiedScreen:Close()
    if self.closed then return end
    self.closed = true
    self:CancelNativeOpen()
    TheFrontEnd:PopScreen(self)
end

function TTKUnifiedScreen:OnDestroy()
    Registry.Clear(self.owner, self)
    if self.controller ~= nil then self.controller:Dispose() end
    TTKUnifiedScreen._base.OnDestroy(self)
end

function TTKUnifiedScreen:OnControl(control, down)
    if self.native_widget ~= nil and (self.active_tab == "equipment" or self.active_tab == "storage")
        and NativeInput.IsControlInputAllowed(self.owner, control) then
        return NativeInput.ForwardControl(self.owner, control, down)
    end
    if TTKUnifiedScreen._base.OnControl(self, control, down) then return true end
    if not down and control == CONTROL_CANCEL then
        self:Close()
        return true
    end
end

function TTKUnifiedScreen:OnMouseButton(button, down, x, y)
    if self.native_widget ~= nil and (self.active_tab == "equipment" or self.active_tab == "storage")
        and NativeInput.IsMouseInputAllowed(self.owner) then
        return NativeInput.ForwardMouse(self.owner, button, down, x, y)
    end
    if TTKUnifiedScreen._base.OnMouseButton(self, button, down, x, y) then return true end
    return false
end

function TTKUnifiedScreen:GetHelpText()
    return string.format("%s Đóng", TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_CANCEL))
end

return TTKUnifiedScreen
