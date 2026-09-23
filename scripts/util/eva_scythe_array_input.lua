local Input = {
    NAMESPACE = "EVA_SCYTHE_ARRAY_V1",
    RPC_NAME = "CAST_AT",
}

local RPC_INTERVAL = 0.25

function Input.HandleCast(player, x, z)
    if player == nil or not player:IsValid()
        or player.prefab ~= "eva"
        or not player:HasTag("eva") then
        return false, "invalid_character"
    end
    local component = player.components ~= nil and player.components.eva_scythe_array or nil
    if component == nil then return false, "missing_component" end
    local now = GetTime()
    if player._eva_scythe_array_last_rpc_time ~= nil
        and now - player._eva_scythe_array_last_rpc_time < RPC_INTERVAL then
        return false, "rate_limited"
    end
    player._eva_scythe_array_last_rpc_time = now
    return component:CastAt(x, z)
end

function Input.CanUseShortcut(player, frontend)
    if player == nil or not player:IsValid()
        or player.prefab ~= "eva"
        or player:HasTag("playerghost") then
        return false
    end
    if frontend == nil or frontend:IsControlsDisabled() then return false end
    local screen = frontend:GetActiveScreen()
    if screen == nil or screen.name ~= "HUD" then return false end
    return player.HUD == nil or not player.HUD:HasInputFocus()
end

function Input.Install(deps)
    deps.add_rpc(Input.NAMESPACE, Input.RPC_NAME, function(player, x, z)
        return Input.HandleCast(player, x, z)
    end)
    if deps.key == nil or deps.key == 0
        or deps.key == deps.life_key or deps.key == deps.wings_key then
        return
    end
    deps.add_key_handler(deps.key, function()
        local player = deps.get_player()
        if not Input.CanUseShortcut(player, deps.get_frontend()) then return end
        local point = deps.get_world_position()
        if point ~= nil then
            deps.send_rpc(Input.NAMESPACE, Input.RPC_NAME, point.x, point.z)
        end
    end)
end

return Input
