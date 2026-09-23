local function WidgetCtor(self, name)
    self.name = name
    self.children = {}
    self.shown = true
    self.inst = {
        ListenForEvent = function() end,
        RemoveEventCallback = function() end,
        IsValid = function() return true end,
        DoTaskInTime = function(_, delay, fn)
            local task = { delay = delay, fn = fn, cancelled = false }
            function task:Cancel() self.cancelled = true end
            self.scheduled = task
            return task
        end,
    }
end

local Widget = Class(WidgetCtor)
function Widget:AddChild(child) table.insert(self.children, child); child.parent = self; return child end
function Widget:SetPosition(x, y, z) self.position = { x, y, z } end
function Widget:SetScale(x, y, z) self.scale = { x, y, z } end
function Widget:SetScaleMode(value) self.scale_mode = value end
function Widget:SetHAnchor(value) self.hanchor = value end
function Widget:SetVAnchor(value) self.vanchor = value end
function Widget:SetSize(w, h) self.size = { w, h } end
function Widget:SetTint(r, g, b, a) self.tint = { r, g, b, a } end
function Widget:SetColour(r, g, b, a) self.colour = { r, g, b, a } end
function Widget:SetRegionSize(w, h) self.region = { w, h } end
function Widget:EnableWordWrap(value) self.wordwrap = value end
function Widget:SetHAlign(value) self.align = value end
function Widget:SetFont(value) self.font = value end
function Widget:SetSize(value) self.font_size = value end
function Widget:SetString(value) self.text_value = value end
function Widget:SetText(value) self.text_value = value end
function Widget:SetTextSize(value) self.text_size = value end
function Widget:SetTextColour(...) self.text_colour = { ... } end
function Widget:SetTextFocusColour(...) self.focus_colour = { ... } end
function Widget:SetTextDisabledColour(...) self.disabled_colour = { ... } end
function Widget:SetTextSelectedColour(...) self.selected_colour = { ... } end
function Widget:SetOnClick(fn) self.onclick = fn end
function Widget:SetFocusChangeDir(direction, target) self["focus_" .. tostring(direction)] = target end
function Widget:Click() if self.onclick then self.onclick() end end
function Widget:Show() self.shown = true end
function Widget:Hide() self.shown = false end
function Widget:Kill() self.killed = true end
function Widget:MoveToFront() end
function Widget:MoveToBack() end
function Widget:GetParent() return self.parent end
function Widget:OnControl() return false end
function Widget:OnMouseButton() return false end
function Widget:OnDestroy() end

local Screen = Class(Widget, function(self, name) WidgetCtor(self, name) end)
local Text = Class(Widget, function(self, font, size, value)
    WidgetCtor(self, "text"); self.text = self; self.text_value = value
end)
local Image = Class(Widget, function(self) WidgetCtor(self, "image") end)
local TextButton = Class(Widget, function(self)
    WidgetCtor(self, "button"); self.text = self
end)

package.preload["widgets/widget"] = function() return Widget end
package.preload["widgets/screen"] = function() return Screen end
package.preload["widgets/text"] = function() return Text end
package.preload["widgets/image"] = function() return Image end
package.preload["widgets/textbutton"] = function() return TextButton end

ANCHOR_MIDDLE = 0
ANCHOR_LEFT = 1
SCALEMODE_PROPORTIONAL = 1
CONTROL_CANCEL = 10
CONTROL_PRIMARY = 11
MOVE_LEFT = "left"
MOVE_RIGHT = "right"
UIFONT = "ui"
TITLEFONT = "title"
Vector3 = function(x, y, z) return { x = x, y = y, z = z } end
MOD_RPC = { hh_rpc = {
    hh_ui_container = "summary_toggle",
    hh_monarch_storage_close = "storage_close",
    hh_dungeon_shop_open = "shop_open",
} }
local sent_rpcs = {}
SendModRPCToServer = function(...)
    table.insert(sent_rpcs, { ... })
end
TheInput = { GetControllerID = function() return 0 end, GetLocalizedControl = function() return "Esc" end }
TheFrontEnd = { PopScreen = function(_, screen) screen.popped = true end }
GetTime = function() return 1 end

local lifecycle = {}
local function Factory(id)
    return function()
        return {
            ShowPanel = function() table.insert(lifecycle, id .. ":show") end,
            HidePanel = function() table.insert(lifecycle, id .. ":hide") end,
            DisposePanel = function() table.insert(lifecycle, id .. ":dispose") end,
        }
    end
end

local factories = {}
for _, id in ipairs({ "character", "equipment", "quests", "army", "shop", "storage" }) do
    factories[id] = Factory(id)
end

local UnifiedScreen = require("screens/ttk_unified_screen")
local screen = UnifiedScreen({}, { factories = factories, initial_tab = "character" })
assert(#screen.tab_order == 6 and #screen.tab_buttons == 6, "shell exposes exactly six primary tabs")
assert(screen.active_tab == "character", "character is the default tab")
assert(screen.default_focus == screen.tab_buttons[1], "controller focus starts on the first tab")
assert(screen.tab_buttons[1].focus_right == screen.tab_buttons[2]
    and screen.tab_buttons[6].focus_left == screen.tab_buttons[5], "controller can traverse all primary tabs")
screen.tab_buttons[5]:Click()
assert(screen.active_tab == "shop", "tab click selects its panel")
assert(table.concat(lifecycle, ",") == "character:show,character:hide,shop:show",
    "shell delegates ordered lifecycle calls")
screen:BeginNativeOpen("shop", "hh_ui_container")
assert(screen:WantsNativeContainer("hh_ui_container"), "shell accepts the current panel's expected container")
assert(not screen:WantsNativeContainer("hh_forge_container"), "shell rejects a stale or unrelated container")

screen:OnControl(CONTROL_CANCEL, false)
assert(screen.popped, "cancel closes the single shell")
screen:OnDestroy()
assert(screen.controller.disposed, "screen disposal tears down all created panels")
print("Unified six-tab shell checks PASS")

local UnifiedOpen = require("ui/ttk_unified_open")
local owner = { HUD = {} }
local pushed = 0
local selected = nil
local closed = 0
TheFrontEnd = {
    GetActiveScreen = function() return owner.HUD end,
    PushScreen = function(_, value) pushed = pushed + 1; value.inst = { IsValid = function() return true end } end,
    PopScreen = function(_, value) value.popped = true end,
}
local fake_screen = {
    SelectTab = function(_, id) selected = id end,
    Close = function() closed = closed + 1 end,
}
assert(UnifiedOpen.Open(owner, "shop", { screen_factory = function() return fake_screen end }) == fake_screen,
    "open creates the one unified shell")
assert(pushed == 1, "open pushes one screen")
assert(UnifiedOpen.Open(owner, "storage") == fake_screen and selected == "storage",
    "later entry points reuse the same shell and select their tab")
UnifiedOpen.Toggle(owner, "storage")
assert(closed == 1, "toggle closes the active unified shell")
print("Unified entry-point checks PASS")

local native_log = {}
local fake_shell = {
    BeginNativeOpen = function(_, _, prefab) table.insert(native_log, "open:" .. prefab); return true end,
    CloseNative = function() table.insert(native_log, "close") end,
}
local NativePanel = require("widgets/hh_ui/ttk_native_panel")
local native_panel = NativePanel({}, fake_shell, "equipment", {
    { id = "summary", label = "Tổng Hợp", prefab = "hh_ui_container", open = function() table.insert(native_log, "rpc:summary") end },
    { id = "forge", label = "Thần Binh Phổ", prefab = "hh_forge_container", open = function() table.insert(native_log, "rpc:forge") end },
})
native_panel:ShowPanel()
local first_open_log_count = #native_log
native_panel:ShowPanel()
native_panel:SelectMode(native_panel.modes[1])
assert(#native_log == first_open_log_count,
    "real NativePanel gates duplicate opens while the first response is pending")
native_panel:AttachNative({})
native_panel:SelectMode(native_panel.modes[2])
assert(native_log[#native_log] == "close", "switch closes the current container before opening another")
assert(native_panel.scheduled ~= nil and native_panel.scheduled.delay >= .2,
    "switch waits past the authoritative container cooldown")
local delayed_task = native_panel.scheduled
native_panel:SelectMode(native_panel.modes[2])
assert(native_panel.scheduled == delayed_task and native_log[#native_log] == "close",
    "reselecting a delayed transition neither bypasses nor duplicates its cooldown")
native_panel.scheduled.fn()
assert(native_log[#native_log] == "rpc:forge", "the next container opens after the cooldown")
print("Unified native transition checks PASS")

local integrated_open_count = 0
local integrated_screen = nil
local integrated_factories = {
    character = Factory("integrated_character"),
    equipment = function()
        return integrated_screen.content_root:AddChild(NativePanel({}, integrated_screen, "equipment", {
            {
                id = "summary",
                label = "Tổng Hợp",
                prefab = "hh_ui_container",
                open = function() integrated_open_count = integrated_open_count + 1 end,
            },
        }))
    end,
}
integrated_screen = UnifiedScreen({}, { factories = integrated_factories, initial_tab = "character" })
assert(integrated_screen:SelectTab("equipment"), "real native panel can be selected")
assert(integrated_open_count == 1, "real native panel sends its initial request once")
assert(integrated_screen:WantsNativeContainer("hh_ui_container"),
    "initial native response remains valid after the panel ShowPanel call")
local native_hud_parent = Widget("native_hud_parent")
local detached_widget = native_hud_parent:AddChild(Widget("detached_native"))
detached_widget.isopen = true
detached_widget.Close = function(self) self.isopen = false end
assert(integrated_screen:TrackNativeContainer(detached_widget, "hh_ui_container"),
    "real native widget is tracked for the pending panel")
assert(detached_widget:GetParent() == native_hud_parent,
    "tracking keeps the Solo container under its original HUD parent")
assert(detached_widget.scale[1] == 1, "summary container keeps native surface scale")
assert(integrated_screen.root.scale_mode == SCALEMODE_PROPORTIONAL,
    "shell owns the only proportional scaling root")
local compact_bounds = integrated_screen:GetDesignBounds(1024, 768)
assert(compact_bounds.inside and compact_bounds.scale == .625,
    "1536x1024 design fits a smaller viewport without clipping")
assert(compact_bounds.left >= 0 and compact_bounds.right <= 1024
    and compact_bounds.bottom >= 0 and compact_bounds.top <= 768,
    "fit bounds remain inside the viewport safe area")
integrated_screen:UntrackNativeContainer(detached_widget)
local rpc_count_after_detach = #sent_rpcs
assert(not integrated_screen:CloseNative(),
    "authoritative native detach clears the registered closer")
assert(#sent_rpcs == rpc_count_after_detach,
    "closing later cannot resend a toggle RPC after authoritative detach")
assert(integrated_screen.controller.active_panel:OpenNative(),
    "real native panel can issue another request after authoritative detach")
integrated_screen:Close()
integrated_screen:OnDestroy()
local NativeBridge = require("ui/ttk_native_bridge")
local late_close_count = 0
assert(NativeBridge.RejectCancelled(integrated_screen.owner, "hh_ui_container", function()
    late_close_count = late_close_count + 1
end), "screen disposal leaves a tombstone for its pending native response")
assert(late_close_count == 1, "late response after disposal is closed instead of becoming a legacy window")
print("Unified real native panel initial-open checks PASS")

local serialized_open_count = 0
local serialized_screen = nil
local serialized_owner = {}
serialized_screen = UnifiedScreen(serialized_owner, {
    factories = {
        character = Factory("serialized_character"),
        equipment = function()
            return serialized_screen.content_root:AddChild(NativePanel(
                serialized_owner,
                serialized_screen,
                "equipment",
                {{
                    id = "summary",
                    label = "Tổng Hợp",
                    prefab = "hh_ui_container",
                    open = function() serialized_open_count = serialized_open_count + 1 end,
                }}
            ))
        end,
    },
    initial_tab = "character",
})
serialized_screen:SelectTab("equipment")
serialized_screen:SelectTab("character")
serialized_screen:SelectTab("equipment")
assert(serialized_open_count == 1,
    "Equipment→Character→Equipment serializes the unresolved toggle across tab lifetimes")
assert(not serialized_screen:WantsNativeContainer("hh_ui_container"),
    "the reopened tab cannot accept the cancelled request as its new response")
local serialized_close_count = #sent_rpcs
assert(serialized_screen:RejectNativeContainer("hh_ui_container"),
    "the old response is closed through its authoritative toggle")
assert(#sent_rpcs == serialized_close_count + 1,
    "resolving the old response emits exactly one close toggle")
local serialized_panel = serialized_screen.controller.active_panel
assert(serialized_panel.scheduled ~= nil and serialized_panel.scheduled.delay >= .2,
    "queued native intent waits for the close cooldown before retrying")
serialized_panel.scheduled.fn()
assert(serialized_open_count == 2 and serialized_screen:WantsNativeContainer("hh_ui_container"),
    "only the post-resolution retry receives a fresh acceptance token")
serialized_screen:Close()
serialized_screen:OnDestroy()
print("Unified unresolved native serialization checks PASS")

local recovery_owner = {}
local recovery_screen = nil
local equipment_attempts = {}
local storage_attempts = {}
recovery_screen = UnifiedScreen(recovery_owner, {
    factories = {
        character = Factory("recovery_character"),
        equipment = function()
            return recovery_screen.content_root:AddChild(NativePanel(
                recovery_owner,
                recovery_screen,
                "equipment",
                {{
                    id = "summary",
                    label = "Tổng Hợp",
                    prefab = "hh_ui_container",
                    open = function(_, request_id) table.insert(equipment_attempts, request_id) end,
                }}
            ))
        end,
        storage = function()
            return recovery_screen.content_root:AddChild(NativePanel(
                recovery_owner,
                recovery_screen,
                "storage",
                {{
                    id = "storage",
                    label = "Kho Quân Vương",
                    prefab = "hh_monarch_storage_container",
                    open = function(_, request_id) table.insert(storage_attempts, request_id) end,
                }}
            ))
        end,
    },
    initial_tab = "character",
})
recovery_screen:SelectTab("equipment")
local equipment_id = equipment_attempts[1]
assert(type(equipment_id) == "number", "equipment request sends its failure-ack context id")
assert(not recovery_screen:HandleNativeOpenFailure(
    "hh_ui_container", equipment_id + 1, "stale failure"
), "stale equipment failure acknowledgment cannot clear the current request")
assert(recovery_screen.controller.active_panel.request_pending,
    "stale equipment failure leaves the matching request pending")
assert(recovery_screen:HandleNativeOpenFailure(
    "hh_ui_container", equipment_id, "Không thể mở khi đang cưỡi"
), "matching riding/cooldown rejection releases the equipment request")
assert(not recovery_screen.controller.active_panel.request_pending,
    "equipment panel becomes retryable after authoritative rejection")
recovery_screen.controller.active_panel:SelectMode(recovery_screen.controller.active_panel.mode)
assert(#equipment_attempts == 2 and equipment_attempts[2] ~= equipment_id,
    "equipment can retry with a fresh id after dismount or cooldown recovery")
local recovery_widget = Widget("recovery_equipment_native")
recovery_widget.isopen = true
recovery_widget.Close = function(self) self.isopen = false end
assert(recovery_screen:AttachNativeContainer(recovery_widget, "hh_ui_container"),
    "successful equipment retry can attach normally")
recovery_screen:DetachNativeContainer(recovery_widget)

recovery_screen:SelectTab("character")
recovery_screen:SelectTab("storage")
local storage_id = storage_attempts[1]
assert(type(storage_id) == "number", "storage request sends its failure-ack context id")
assert(recovery_screen:HandleNativeOpenFailure(
    "hh_monarch_storage_container", storage_id, "Yêu cầu cấp bậc A"
), "rank rejection releases the storage request")
assert(not recovery_screen.controller.active_panel.request_pending,
    "storage panel becomes retryable after authoritative rank rejection")
recovery_screen.controller.active_panel:SelectMode(recovery_screen.controller.active_panel.mode)
assert(#storage_attempts == 2 and storage_attempts[2] ~= storage_id,
    "storage can retry with a fresh id after the player reaches rank A")
recovery_screen:Close()
recovery_screen:OnDestroy()
print("Unified authoritative failed-open recovery checks PASS")

local inventory_root = Widget("inventory_root")
local inventory_slot = inventory_root:AddChild(Widget("inventory_slot"))
local outside_widget = Widget("outside")
local forwarded_mouse = 0
local forwarded_control = 0
local slot_mouse = 0
local slot_control = 0
inventory_slot.OnMouseButton = function()
    slot_mouse = slot_mouse + 1
    return true
end
inventory_slot.OnControl = function()
    slot_control = slot_control + 1
    return true
end
local focused_inventory_widget = inventory_slot
local input_owner = {
    HUD = {
        focus = false,
        controls = { inv = inventory_root, containers = {} },
        GetDeepestFocus = function() return focused_inventory_widget end,
        OnMouseButton = function(self)
            if not self.focus then return false end
            forwarded_mouse = forwarded_mouse + 1
            return true
        end,
        OnControl = function(self)
            if not self.focus then return false end
            forwarded_control = forwarded_control + 1
            return true
        end,
    },
}
local hovered_widget = inventory_slot
TheInput.GetHUDEntityUnderMouse = function() return { widget = hovered_widget } end
local input_screen = UnifiedScreen(input_owner, {
    factories = { equipment = Factory("input_equipment") },
    initial_tab = "equipment",
})
input_screen.native_widget = Widget("native_container")
assert(input_screen:OnMouseButton(1, true, 0, 0),
    "native tabs forward mouse input to the HUD inventory tree")
assert(slot_mouse == 1 and forwarded_mouse == 0,
    "hovered inventory slot receives mouse input even while modal HUD root lacks focus")
assert(input_screen:OnControl(CONTROL_PRIMARY, true),
    "native tabs forward control input to the focused HUD inventory tree")
assert(slot_control == 1 and forwarded_control == 0,
    "focused inventory slot receives control input even while modal HUD root lacks focus")
hovered_widget = outside_widget
focused_inventory_widget = outside_widget
assert(not input_screen:OnMouseButton(1, true, 0, 0) and slot_mouse == 1 and forwarded_mouse == 0,
    "mouse input outside inventory/native trees is never forwarded to the HUD")
assert(not input_screen:OnControl(CONTROL_PRIMARY, true) and slot_control == 1 and forwarded_control == 0,
    "control input outside inventory/native trees is never forwarded to the HUD")
print("Unified native HUD inventory input checks PASS")

local quest_log = {}
local function QuestChild(name)
    local child = Widget(name)
    child.SetQuestFocus = function(_, mode) table.insert(quest_log, name .. ":" .. mode) end
    return child
end
local QuestPanel = require("widgets/hh_ui/ttk_quest_panel")
local quest_panel = QuestPanel({}, {
    status_factory = function(parent) return parent:AddChild(QuestChild("status")) end,
    guild_factory = function(parent) return parent:AddChild(QuestChild("guild")) end,
})
assert(#quest_panel.tabs == 3 and quest_panel.mode == "daily", "quest panel exposes three real-system views")
quest_panel.tabs[2]:Click()
assert(quest_panel.mode == "guild" and quest_panel.guild.shown and not quest_panel.status.shown,
    "guild tab swaps embedded content")
quest_panel.tabs[3]:Click()
assert(quest_panel.mode == "promotion" and quest_log[#quest_log] == "guild:promotion",
    "promotion tab focuses the rank system without inventing data")
print("Unified quest subtab checks PASS")

local shop_open_count = 0
local shop_owner = {
    hh_dungeon_coins = { value = function() return 0 end },
    hh_dungeon_shop_cycle_client = { value = function() return 0 end },
    hh_dungeon_coin_notice = { value = function() return "" end },
    hh_dungeon_shop_products_client = { value = function() return "" end },
    hh_dungeon_shop_stock_client = { value = function() return "" end },
}
local ShopScreen = require("screens/hh_dungeon_shop_screen")
local shop = ShopScreen(shop_owner, { GetByIndex = function() return nil end }, nil, {
    embedded = true,
    open_request = function() shop_open_count = shop_open_count + 1 end,
})
shop:ShowPanel()
shop:ShowPanel()
assert(shop_open_count == 1, "embedded shop requests authoritative sync once per activation")
shop:HidePanel()
shop:ShowPanel()
assert(shop_open_count == 2, "returning to the shop requests a fresh authoritative sync")
print("Unified embedded shop open-sync checks PASS")
