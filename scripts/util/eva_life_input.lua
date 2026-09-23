local Input = {
    NAMESPACE = "EVA_LIFE_V1",
    RPC_NAME = "ACTIVATE",
}

local RPC_INTERVAL = 0.25

function Input.HandleActivation(player)
    if player == nil or not player:IsValid()
        or player.prefab ~= "eva"
        or not player:HasTag("eva") then
        return false, "invalid_character"
    end
    local life = player.components ~= nil and player.components.eva_life or nil
    if life == nil then return false, "missing_component" end
    local now = GetTime()
    if player._eva_life_last_rpc_time ~= nil
        and now - player._eva_life_last_rpc_time < RPC_INTERVAL then
        return false, "rate_limited"
    end
    player._eva_life_last_rpc_time = now
    return life:Activate()
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
    deps.add_rpc(Input.NAMESPACE, Input.RPC_NAME, function(player)
        return Input.HandleActivation(player)
    end)
    if deps.key == nil or deps.key == 0 then return end
    deps.add_key_handler(deps.key, function()
        local player = deps.get_player()
        if Input.CanUseShortcut(player, deps.get_frontend()) then
            deps.send_rpc(Input.NAMESPACE, Input.RPC_NAME)
        end
    end)
end

return Input
