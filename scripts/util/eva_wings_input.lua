local Input = {
    NAMESPACE = "EVA_WINGS_V1",
    RPC_NAME = "TOGGLE",
}

local RPC_INTERVAL = 0.25

local function HasCollisionBit(mask, value)
    return mask % (value * 2) >= value
end

local function IsSurfaceWorld()
    return TheWorld ~= nil and not TheWorld:HasTag("cave")
end

local function IsHuman(inst)
    return inst ~= nil and inst:IsValid() and not inst:HasTag("playerghost")
end

local function IsMountedState(inst)
    local rider = inst.components ~= nil and inst.components.rider or nil
    return (rider ~= nil and rider:IsRiding())
        or (inst.sg ~= nil and (inst.sg:HasStateTag("mounting")
            or inst.sg:HasStateTag("dismounting")))
end

local function SetClientPath(inst, locomotor)
    if inst._eva_wings_client_locomotor ~= locomotor
        or inst._eva_wings_client_pathcaps ~= locomotor.pathcaps then
        inst._eva_wings_client_locomotor = locomotor
        inst._eva_wings_client_pathcaps = locomotor.pathcaps
        inst._eva_wings_client_had_pathcaps = locomotor.pathcaps ~= nil
        if locomotor.pathcaps == nil then locomotor.pathcaps = {} end
        inst._eva_wings_client_pathcaps = locomotor.pathcaps
        inst._eva_wings_client_allowocean = locomotor.pathcaps.allowocean
        inst._eva_wings_client_allow_platform_hopping = locomotor.allow_platform_hopping
    end
    locomotor.pathcaps.allowocean = true
    locomotor:SetAllowPlatformHopping(false)
end

local function ClearClientPath(inst)
    local locomotor = inst.components ~= nil and inst.components.locomotor or nil
    if locomotor ~= nil and locomotor == inst._eva_wings_client_locomotor
        and locomotor.pathcaps == inst._eva_wings_client_pathcaps then
        locomotor.pathcaps.allowocean = inst._eva_wings_client_allowocean
        if not inst._eva_wings_client_had_pathcaps and next(locomotor.pathcaps) == nil then
            locomotor.pathcaps = nil
        end
        locomotor:SetAllowPlatformHopping(inst._eva_wings_client_allow_platform_hopping)
    end
    inst._eva_wings_client_locomotor = nil
    inst._eva_wings_client_pathcaps = nil
    inst._eva_wings_client_had_pathcaps = nil
    inst._eva_wings_client_allowocean = nil
    inst._eva_wings_client_allow_platform_hopping = nil
end

local function SetClientPhysics(inst)
    if not inst._eva_wings_client_physics then
        local mask = inst.Physics:GetCollisionMask()
        inst._eva_wings_client_boat_limit = HasCollisionBit(mask, COLLISION.BOAT_LIMITS)
        inst._eva_wings_client_land_ocean_limit = HasCollisionBit(mask, COLLISION.LAND_OCEAN_LIMITS)
        inst._eva_wings_client_physics = true
    end
    inst.Physics:ClearCollidesWith(COLLISION.LIMITS)
end

local function ClearClientPhysics(inst, restore)
    if inst._eva_wings_client_physics and restore and inst.Physics ~= nil then
        if inst._eva_wings_client_boat_limit then inst.Physics:CollidesWith(COLLISION.BOAT_LIMITS) end
        if inst._eva_wings_client_land_ocean_limit then inst.Physics:CollidesWith(COLLISION.LAND_OCEAN_LIMITS) end
    end
    inst._eva_wings_client_physics = nil
    inst._eva_wings_client_boat_limit = nil
    inst._eva_wings_client_land_ocean_limit = nil
end

function Input.ApplyReplicaState(inst)
    if inst == nil or TheWorld.ismastersim or ThePlayer ~= inst then return end
    local locomotor = inst.components ~= nil and inst.components.locomotor or nil
    local active = inst._eva_wings_active ~= nil and inst._eva_wings_active:value()
    local compatible = IsHuman(inst) and not IsMountedState(inst)
    local should_apply = active and compatible and IsSurfaceWorld() and locomotor ~= nil
    if should_apply then
        SetClientPath(inst, locomotor)
        SetClientPhysics(inst)
    else
        ClearClientPath(inst)
        ClearClientPhysics(inst, compatible and IsSurfaceWorld())
    end
end

function Input.InstallReplica(inst)
    local function apply() Input.ApplyReplicaState(inst) end
    local function defer()
        inst:DoTaskInTime(0, function() Input.ApplyReplicaState(inst) end)
    end
    inst:ListenForEvent("eva_wingsdirty", apply)
    inst:ListenForEvent("playeractivated", defer)
    inst:ListenForEvent("enablemovementprediction", defer)
    inst:ListenForEvent("newstate", defer)
end

function Input.HandleToggle(player)
    if player == nil or not player:IsValid()
        or player.prefab ~= "eva"
        or not player:HasTag("eva") then
        return false, "invalid_character"
    end
    local wings = player.components ~= nil and player.components.eva_wings or nil
    if wings == nil then return false, "missing_component" end
    local now = GetTime()
    if player._eva_wings_last_rpc_time ~= nil
        and now - player._eva_wings_last_rpc_time < RPC_INTERVAL then
        return false, "rate_limited"
    end
    player._eva_wings_last_rpc_time = now
    return wings:Toggle()
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
        return Input.HandleToggle(player)
    end)
    if deps.key == nil or deps.key == 0 or deps.key == deps.life_key then return end
    deps.add_key_handler(deps.key, function()
        local player = deps.get_player()
        if Input.CanUseShortcut(player, deps.get_frontend()) then
            deps.send_rpc(Input.NAMESPACE, Input.RPC_NAME)
        end
    end)
end

return Input
