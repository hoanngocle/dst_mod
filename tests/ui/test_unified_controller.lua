local Controller = require("ui/ttk_unified_controller")

local function NewPanel(name, log)
    return {
        ShowPanel = function(self)
            table.insert(log, name .. ":show")
            self.visible = true
        end,
        HidePanel = function(self)
            table.insert(log, name .. ":hide")
            self.visible = false
        end,
        DisposePanel = function(self)
            table.insert(log, name .. ":dispose")
            self.disposed = true
        end,
    }
end

local log = {}
local factories = {
    character = function() return NewPanel("character", log) end,
    equipment = function() return NewPanel("equipment", log) end,
    quests = function() return NewPanel("quests", log) end,
}
local controller = Controller(factories)

assert(controller:Show("character") == true, "first tab must open")
assert(table.concat(log, ",") == "character:show", "first panel is shown once")

assert(controller:Show("equipment") == true, "second tab must open")
assert(table.concat(log, ",") == "character:show,character:hide,equipment:show",
    "switch hides the old panel before showing the new panel")

assert(controller:Show("equipment") == false, "selecting the current tab is idempotent")
assert(#log == 3, "idempotent selection must not duplicate lifecycle calls")

local token = controller:BeginNativeOpen("equipment", "hh_ui_container")
assert(controller:AcceptNativeOpen(token, "equipment", "hh_ui_container") == true,
    "current tab accepts its expected native container")

local stale = controller:BeginNativeOpen("equipment", "hh_forge_container")
controller:Show("quests")
assert(controller:AcceptNativeOpen(stale, "equipment", "hh_forge_container") == false,
    "a delayed native open cannot attach after the user leaves the tab")

local close_count = 0
controller:SetNativeCloser(function() close_count = close_count + 1 end)
controller:CloseNative()
controller:CloseNative()
assert(close_count == 1, "native close is emitted at most once")

controller:Dispose()
assert(controller.disposed == true, "controller is disposed")
assert(log[#log] == "quests:dispose", "active panel is hidden and every panel is disposed")
assert(controller:Show("character") == false, "disposed controller rejects later input")

print("Unified controller lifecycle checks PASS")

local RequestGate = require("ui/ttk_request_gate")
local now = 10
local sent = 0
local gate = RequestGate(function() return now end, 4)
assert(gate:Try(function() sent = sent + 1 end), "first request is sent")
assert(not gate:Try(function() sent = sent + 1 end), "double click is blocked while pending")
assert(sent == 1, "pending request must not be duplicated")
gate:Acknowledge()
assert(gate:Try(function() sent = sent + 1 end), "dirty acknowledgment unlocks the action")
now = 15
assert(gate:Try(function() sent = sent + 1 end), "timeout recovers from a lost acknowledgment")
gate:Dispose()
assert(not gate:Try(function() sent = sent + 1 end), "disposed panel cannot send late requests")
print("Unified request gate checks PASS")

local Registry = require("ui/ttk_unified_registry")
local registry_owner = {}
local registry_screen = {}
Registry.BeginNative(registry_owner, registry_screen, "hh_ui_container")
Registry.CancelNative(registry_owner, registry_screen)
assert(Registry.ConsumeCancelledNative(registry_owner, "hh_ui_container"),
    "a pending native response remains rejectable after its screen is cancelled")
assert(not Registry.ConsumeCancelledNative(registry_owner, "hh_ui_container"),
    "the cancelled response tombstone is consumed exactly once")

Registry.BeginNative(registry_owner, registry_screen, "hh_forge_container")
Registry.ResolveNative(registry_owner, registry_screen, "hh_forge_container")
Registry.CancelNative(registry_owner, registry_screen)
assert(not Registry.ConsumeCancelledNative(registry_owner, "hh_forge_container"),
    "an attached native response does not leave a cancellation tombstone")

local invalid_owner = {}
local invalid_screen = { inst = { IsValid = function() return false end } }
Registry.Set(invalid_owner, invalid_screen)
Registry.BeginNative(invalid_owner, invalid_screen, "hh_ui_container")
assert(Registry.Get(invalid_owner) == nil, "invalid screen is removed from the registry")
assert(Registry.ConsumeCancelledNative(invalid_owner, "hh_ui_container"),
    "invalid-screen cleanup preserves rejection for an in-flight native response")

local serialized_owner = {}
local first_screen = {}
local reopened_screen = {}
assert(Registry.BeginNative(serialized_owner, first_screen, "hh_ui_container"),
    "first unresolved native request is allowed to send")
Registry.CancelNative(serialized_owner, first_screen)
assert(not Registry.BeginNative(serialized_owner, reopened_screen, "hh_ui_container"),
    "reopening before the first response queues intent without a second toggle")
local resolved, queued_screen = Registry.ResolveNative(serialized_owner, reopened_screen, "hh_ui_container")
assert(resolved and queued_screen == reopened_screen,
    "resolving the cancelled response returns the one queued screen")
assert(Registry.BeginNative(serialized_owner, reopened_screen, "hh_ui_container"),
    "a fresh request can send only after the old response is authoritatively resolved")
Registry.CancelNative(serialized_owner, reopened_screen)
Registry.ConsumeCancelledNative(serialized_owner, "hh_ui_container")

local late_owner = {}
local late_screen = {}
local late_now = 0
GetTime = function() return late_now end
Registry.BeginNative(late_owner, late_screen, "hh_ui_container")
Registry.CancelNative(late_owner, late_screen)
late_now = 5
assert(Registry.ConsumeCancelledNative(late_owner, "hh_ui_container"),
    "cancelled request remains rejectable after five seconds until its response resolves")

local failed_owner = {}
local failed_screen = {}
local first_sent, first_request_id = Registry.BeginNative(failed_owner, failed_screen, "hh_ui_container")
assert(first_sent and type(first_request_id) == "number",
    "native request receives a client context id for authoritative failure acknowledgment")
assert(not Registry.FailNative(failed_owner, "hh_ui_container", first_request_id + 1),
    "failure acknowledgment with an older or unrelated id cannot clear the pending request")
assert(not Registry.BeginNative(failed_owner, failed_screen, "hh_ui_container"),
    "mismatched failure acknowledgment leaves serialization in force")
local failed_resolved, failed_target = Registry.FailNative(
    failed_owner, "hh_ui_container", first_request_id
)
assert(failed_resolved and failed_target == failed_screen,
    "matching authoritative failure releases the pending request for its screen")
local retry_sent, retry_request_id = Registry.BeginNative(failed_owner, failed_screen, "hh_ui_container")
assert(retry_sent and retry_request_id ~= first_request_id,
    "a later eligible attempt gets a fresh context id and can send")
Registry.CancelNative(failed_owner, failed_screen)
Registry.ConsumeCancelledNative(failed_owner, "hh_ui_container")
print("Unified native cancellation registry checks PASS")

MOD_RPC = { hh_rpc = {
    hh_ui_container = "summary_toggle",
    hh_monarch_storage_close = "storage_close",
} }
local NativeBridge = require("ui/ttk_native_bridge")
local rejected_rpcs = {}
Registry.BeginNative(registry_owner, registry_screen, "hh_forge_container")
Registry.CancelNative(registry_owner, registry_screen)
assert(NativeBridge.RejectCancelled(registry_owner, "hh_forge_container", function(...)
    table.insert(rejected_rpcs, { ... })
end), "late response is rejected after its shell has been disposed")
assert(#rejected_rpcs == 1 and rejected_rpcs[1][1] == "summary_toggle"
    and rejected_rpcs[1][2] == "forge_container",
    "late forge response uses the existing authoritative close RPC")
assert(not NativeBridge.RejectCancelled(registry_owner, "hh_forge_container", function() end),
    "late response rejection is consumed once")
print("Unified native late-response bridge checks PASS")

CLIENT_MOD_RPC = { hh_rpc = { hh_native_open_failed = "native_open_failed" } }
local NativeOpenAck = require("ui/ttk_native_open_ack")
local failure_rpcs = {}
local failure_player = { userid = "player-1" }
assert(NativeOpenAck.SendFailure(
    failure_player,
    "hh_ui_container",
    17,
    "Không thể mở khi đang cưỡi",
    function(...) table.insert(failure_rpcs, { ... }) end
), "server emits an authoritative native-open failure for a contextual request")
assert(#failure_rpcs == 1
    and failure_rpcs[1][1] == "native_open_failed"
    and failure_rpcs[1][2] == "player-1"
    and failure_rpcs[1][3] == "hh_ui_container"
    and failure_rpcs[1][4] == 17
    and failure_rpcs[1][5] == "Không thể mở khi đang cưỡi",
    "failure acknowledgment preserves player, prefab, request id, and reason")
assert(not NativeOpenAck.SendFailure(failure_player, "hh_ui_container", nil, "legacy", function()
    error("legacy requests must not receive contextual acknowledgments")
end), "legacy native-open requests remain compatible without a request id")

local ack_owner = {}
local acknowledged = nil
Registry.Set(ack_owner, {
    HandleNativeOpenFailure = function(_, prefab, request_id, reason)
        acknowledged = { prefab, request_id, reason }
        return true
    end,
})
assert(NativeOpenAck.HandleFailure(ack_owner, "hh_monarch_storage_container", 23, "Yêu cầu cấp bậc A"),
    "client routes the server failure to the active unified shell")
assert(acknowledged[1] == "hh_monarch_storage_container"
    and acknowledged[2] == 23
    and acknowledged[3] == "Yêu cầu cấp bậc A",
    "client failure routing preserves the authoritative request context")
assert(not NativeOpenAck.HandleFailure({}, "hh_ui_container", 99, "stale"),
    "failure for an owner without an active shell is ignored")

local closed_ack_owner = {}
local closed_ack_screen = {}
local _, closed_ack_request_id = Registry.BeginNative(
    closed_ack_owner, closed_ack_screen, "hh_monarch_storage_container"
)
Registry.Set(closed_ack_owner, closed_ack_screen)
Registry.Clear(closed_ack_owner, closed_ack_screen)
assert(NativeOpenAck.HandleFailure(
    closed_ack_owner,
    "hh_monarch_storage_container",
    closed_ack_request_id,
    "Yêu cầu cấp bậc A"
), "failure acknowledgment resolves a cancelled request after its shell closes")
assert(Registry.BeginNative(closed_ack_owner, {}, "hh_monarch_storage_container"),
    "resolved closed-shell failure does not leave a permanent tombstone")
print("Unified native failed-open acknowledgment bridge checks PASS")
