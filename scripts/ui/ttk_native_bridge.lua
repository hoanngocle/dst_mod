local Registry = require("ui/ttk_unified_registry")

local NativeBridge = {}

function NativeBridge.Reject(prefab, sender)
    sender = sender or SendModRPCToServer
    if sender == nil or MOD_RPC == nil or MOD_RPC.hh_rpc == nil then return false end
    if prefab == "hh_monarch_storage_container" then
        sender(MOD_RPC.hh_rpc.hh_monarch_storage_close)
    elseif prefab == "hh_forge_container" then
        sender(MOD_RPC.hh_rpc.hh_ui_container, "forge_container")
    elseif prefab == "hh_ui_container" then
        sender(MOD_RPC.hh_rpc.hh_ui_container)
    else
        return false
    end
    return true
end

function NativeBridge.RejectCancelled(owner, prefab, sender)
    if not Registry.ConsumeCancelledNative(owner, prefab) then return false end
    return NativeBridge.Reject(prefab, sender)
end

return NativeBridge
