local Registry = require("ui/ttk_unified_registry")

local NativeOpenAck = {}

function NativeOpenAck.SendFailure(player, prefab, request_id, reason, sender)
    local rpc = CLIENT_MOD_RPC ~= nil
        and CLIENT_MOD_RPC.hh_rpc ~= nil
        and CLIENT_MOD_RPC.hh_rpc.hh_native_open_failed
        or nil
    sender = sender or SendModRPCToClient
    if player == nil or player.userid == nil or type(prefab) ~= "string"
        or type(request_id) ~= "number" or rpc == nil or sender == nil then
        return false
    end
    sender(rpc, player.userid, prefab, request_id, reason or "Không thể mở giao diện lúc này")
    return true
end

function NativeOpenAck.HandleFailure(owner, prefab, request_id, reason)
    local screen = Registry.Get(owner)
    if screen ~= nil and screen.HandleNativeOpenFailure ~= nil then
        return screen:HandleNativeOpenFailure(prefab, request_id, reason)
    end
    return Registry.FailNative(owner, prefab, request_id)
end

return NativeOpenAck
