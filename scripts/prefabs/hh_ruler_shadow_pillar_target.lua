local function GetRulerTuning()
    return TUNING.HH_RULER or {}
end

local function CalcTargetDuration(target)
    return target ~= nil and (
            (target:HasTag("epic") and TUNING.SHADOW_PILLAR_DURATION_BOSS) or
            (target:HasTag("player") and TUNING.SHADOW_PILLAR_DURATION_PLAYER)
        ) or TUNING.SHADOW_PILLAR_DURATION
end

local function IsValidTarget(target)
    return target ~= nil
        and target:IsValid()
        and not target:HasTag("INLIMBO")
end

local function Target_OnTimerDone(inst, data)
    if data == nil then
        return
    end

    if data.name == "delay" then
        local target = inst.components.entitytracker:GetEntity("target")
        if target ~= nil and target:IsValid() then
            inst.components.timer:StartTimer("lifetime", CalcTargetDuration(target))
        else
            inst:Remove()
        end
    elseif data.name == "lifetime" then
        inst:Remove()
    end
end

local function Target_SetDelay(inst, delay)
    if inst.components.timer:TimerExists("delay") then
        inst.components.timer:StopTimer("delay")
        inst.components.timer:StartTimer("delay", delay)
    end
end

local MOVED_DIST_SQ = 0.5 * 0.5
local UPDATE_PERIOD = 1
local MAX_PLAYERS_CAP = 4
local RULER_NO_HEAL_TAG = "hh_ruler_no_heal"

local function AddRulerNoHealSource(target, source)
    if target == nil or not target:IsValid()
        or target.components == nil
        or target.components.health == nil then
        return
    end

    local sources = target._hh_ruler_no_heal_sources
    if sources == nil then
        sources = {}
        target._hh_ruler_no_heal_sources = sources
    end

    sources[source] = true
    target:AddTag(RULER_NO_HEAL_TAG)
end

local function RemoveRulerNoHealSource(target, source)
    if target == nil then
        return
    end

    local sources = target._hh_ruler_no_heal_sources
    if sources == nil then
        return
    end

    sources[source] = nil
    if next(sources) == nil then
        target._hh_ruler_no_heal_sources = nil
        if target:IsValid() then
            target:RemoveTag(RULER_NO_HEAL_TAG)
        end
    end
end

local function Target_Update(inst, x, z, target, attackers)
    if not IsValidTarget(target) then
        inst:Remove()
        return
    end

    -- This is the same backup movement test used by vanilla Shadow Prison.
    if target:GetDistanceSqToPoint(x, 0, z) > MOVED_DIST_SQ then
        target:PushEvent("remove_shadow_pillars")
        inst:Remove()
        return
    end

    local t = inst.components.timer:GetTimeLeft("lifetime")
    if t == nil then
        return
    end

    local count = 0
    local countothers = attackers.other and 1 or 0
    attackers.other = nil
    for k in pairs(attackers) do
        attackers[k] = nil
        count = count + 1
    end
    count = math.max(count, countothers)

    if count > 0 then
        local dt = Remap(math.min(count, MAX_PLAYERS_CAP), 1, MAX_PLAYERS_CAP, 0, 1)
        dt = Lerp(TUNING.SHADOW_PILLAR_BREAK_MULT.MIN, TUNING.SHADOW_PILLAR_BREAK_MULT.MAX, dt)
        if dt > 1 then
            dt = UPDATE_PERIOD * (dt - 1)
            if t < dt then
                target:PushEvent("remove_shadow_pillars")
                inst:Remove()
                return
            end
            inst.components.timer:SetTimeLeft("lifetime", t - dt)
            target:PushEvent("reduce_shadow_pillars_time", dt)
        end
    end
end

local function Target_StopDot(inst)
    if inst._dot_task ~= nil then
        inst._dot_task:Cancel()
        inst._dot_task = nil
    end
end

local function Target_RemoveAura(inst)
    local aura = inst._aura_fx
    inst._aura_fx = nil
    if aura ~= nil and aura:IsValid() then
        aura:Remove()
    end
end

local function Target_DetachCallbacks(inst, target, caster)
    if target ~= nil then
        if inst._on_target_removed ~= nil then
            target:RemoveEventCallback("onremove", inst._on_target_removed)
            target:RemoveEventCallback("death", inst._on_target_removed)
            target:RemoveEventCallback("enterlimbo", inst._on_target_removed)
            target:RemoveEventCallback("teleported", inst._on_target_removed)
            target:RemoveEventCallback("dispell_shadow_pillars", inst._on_target_removed)
            target:RemoveEventCallback("remove_shadow_pillars", inst._on_target_removed)
        end
        if inst._on_target_flight ~= nil then
            target:RemoveEventCallback("newstate", inst._on_target_flight)
        end
        if inst._on_target_attacked ~= nil then
            target:RemoveEventCallback("attacked", inst._on_target_attacked)
            target:RemoveEventCallback("blocked", inst._on_target_attacked)
        end
    end
    if caster ~= nil and inst._on_caster_removed ~= nil then
        caster:RemoveEventCallback("onremove", inst._on_caster_removed)
        caster:RemoveEventCallback("death", inst._on_caster_removed)
        caster:RemoveEventCallback("makeplayerghost", inst._on_caster_removed)
        caster:RemoveEventCallback("enterlimbo", inst._on_caster_removed)
    end

    inst._on_target_removed = nil
    inst._on_target_flight = nil
    inst._on_target_attacked = nil
    inst._on_caster_removed = nil
end

local function Target_Cleanup(inst)
    if inst._cleaned then
        return
    end
    inst._cleaned = true

    Target_StopDot(inst)
    Target_RemoveAura(inst)

    if inst._update_task ~= nil then
        inst._update_task:Cancel()
        inst._update_task = nil
    end

    local target = inst.components.entitytracker:GetEntity("target")
    local caster = inst.components.entitytracker:GetEntity("caster")
    Target_DetachCallbacks(inst, target, caster)

    RemoveRulerNoHealSource(target, inst)

    if target ~= nil and target:IsValid()
        and target.components ~= nil and target.components.rooted ~= nil then
        target.components.rooted:RemoveSource(inst)
    end

    inst.components.entitytracker:ForgetEntity("target")
    inst.components.entitytracker:ForgetEntity("caster")
end

local function Target_StartDot(inst)
    Target_StopDot(inst)

    local interval = tonumber(GetRulerTuning().DAMAGE_INTERVAL) or 0.3
    local damage = tonumber(GetRulerTuning().DAMAGE) or 30
    inst._dot_task = inst:DoPeriodicTask(interval, function()
        local target = inst.components.entitytracker:GetEntity("target")
        local caster = inst.components.entitytracker:GetEntity("caster")
        if not IsValidTarget(target) then
            inst:Remove()
            return
        end
        if caster == nil or not caster:IsValid() then
            -- A disconnected caster cannot remain a valid combat credit source.
            -- Remove this prison instead of applying uncredited damage.
            inst:Remove()
            return
        end

        local combat = target.components.combat
        if combat ~= nil and damage > 0 then
            -- The controller itself is the internal weapon marker. Combat still
            -- resolves armor, resistance, external modifiers and kill credit.
            -- The active flag is also required because vanilla's blocked event
            -- does not carry the weapon field.
            inst._internal_dot_active = true
            combat:GetAttacked(caster, damage, inst, nil)
            inst._internal_dot_active = nil
        end
    end, interval)
end

local function Target_StartAura(inst, target)
    Target_RemoveAura(inst)
    if target == nil or not target:IsValid() then
        return
    end

    local aura = SpawnPrefab("hh_ruler_aura_fx")
    if aura ~= nil then
        inst._aura_fx = aura
        aura.entity:SetParent(target.entity)
        aura.Transform:SetPosition(0, 0, 0)
        aura:ListenForEvent("onremove", function(removed_fx)
            if inst._aura_fx == removed_fx then
                inst._aura_fx = nil
            end
        end)
    end
end

local function Target_OnSetTarget(inst, target)
    if target == nil or not target:IsValid() then
        inst:Remove()
        return
    end

    local caster = inst.components.entitytracker:GetEntity("caster")
    inst.caster = caster

    if target.components.rooted == nil then
        target:AddComponent("rooted")
    end
    target.components.rooted:AddSource(inst)
    AddRulerNoHealSource(target, inst)

    inst._on_target_removed = function()
        if inst:IsValid() then
            inst:Remove()
        end
    end
    target:ListenForEvent("onremove", inst._on_target_removed)
    target:ListenForEvent("death", inst._on_target_removed)
    target:ListenForEvent("enterlimbo", inst._on_target_removed)
    target:ListenForEvent("teleported", inst._on_target_removed)
    target:ListenForEvent("dispell_shadow_pillars", inst._on_target_removed)
    target:ListenForEvent("remove_shadow_pillars", inst._on_target_removed)

    if target.sg ~= nil then
        inst._on_target_flight = function(target_inst)
            if target_inst.sg ~= nil and target_inst.sg:HasStateTag("flight") then
                inst:Remove()
            end
        end
        target:ListenForEvent("newstate", inst._on_target_flight)
    end

    local attackers = {}
    inst._on_target_attacked = function(_, data)
        -- Internal DOT must not accelerate prison breaking. Every external
        -- attack, including blocked attacks, remains vanilla-compatible.
        if inst._internal_dot_active
            or (data ~= nil and data.weapon == inst) then
            return
        end

        local attacker = data ~= nil and data.attacker or nil
        if attacker ~= nil then
            if attacker.components ~= nil and attacker.components.follower ~= nil then
                attacker = attacker.components.follower:GetLeader() or attacker
            end
            if not attacker:HasTag("player") then
                attacker = nil
            end
        end
        attackers[attacker or "other"] = true
    end
    target:ListenForEvent("attacked", inst._on_target_attacked)
    target:ListenForEvent("blocked", inst._on_target_attacked)

    if caster ~= nil and caster:IsValid() then
        inst._on_caster_removed = function()
            if inst:IsValid() then
                inst:Remove()
            end
        end
        caster:ListenForEvent("onremove", inst._on_caster_removed)
        caster:ListenForEvent("death", inst._on_caster_removed)
        caster:ListenForEvent("makeplayerghost", inst._on_caster_removed)
        caster:ListenForEvent("enterlimbo", inst._on_caster_removed)
    end

    Target_StartAura(inst, target)
    Target_StartDot(inst)

    local x, _, z = inst.Transform:GetWorldPosition()
    inst._update_task = inst:DoPeriodicTask(UPDATE_PERIOD, Target_Update, nil, x, z, target, attackers)
end

local function Target_SetTarget(inst, target, radius, hasplatform, caster)
    if target ~= nil then
        inst.components.entitytracker:TrackEntity("target", target)
        if caster ~= nil then
            inst.components.entitytracker:TrackEntity("caster", caster)
        end
        Target_OnSetTarget(inst, target)
        if hasplatform then
            inst:RemoveTag("ignorewalkableplatforms")
        end
        inst:DoTaskInTime(14 * FRAMES, function(target_inst)
            if target_inst:IsValid() then
                ShakeAllCameras(CAMERASHAKE.VERTICAL, 1, 0.025, 0.075, target_inst, 12 + radius)
            end
        end)
    end
end

local function Target_OnSave(inst, data)
    data.hasplatform = not inst:HasTag("ignorewalkableplatforms") or nil
end

local function Target_OnLoad(inst)
    if inst.components.timer:TimerExists("lifetime") then
        inst.components.timer:StopTimer("delay")
    elseif not inst.components.timer:TimerExists("delay") then
        inst.persists = false
        inst:DoTaskInTime(0, inst.Remove)
    end
end

local function Target_OnLoadPostPass(inst, ents, data)
    local target = inst.components.entitytracker:GetEntity("target")
    local caster = inst.components.entitytracker:GetEntity("caster")
    if target ~= nil and caster ~= nil
        and (inst.components.timer:TimerExists("lifetime") or inst.components.timer:TimerExists("delay")) then
        Target_OnSetTarget(inst, target)
    else
        inst.persists = false
        inst:DoTaskInTime(0, inst.Remove)
        return
    end

    if data ~= nil and data.hasplatform then
        inst:RemoveTag("ignorewalkableplatforms")
    end
end

local function target_fn()
    local inst = CreateEntity()

    inst:AddTag("ignorewalkableplatforms")
    inst.entity:AddTransform()
    inst:AddComponent("entitytracker")
    inst:AddComponent("timer")
    inst.components.timer:StartTimer("delay", 0)

    inst:ListenForEvent("timerdone", Target_OnTimerDone)
    inst:ListenForEvent("onremove", Target_Cleanup)

    inst.SetDelay = Target_SetDelay
    inst.SetTarget = Target_SetTarget
    inst.OnSave = Target_OnSave
    inst.OnLoad = Target_OnLoad
    inst.OnLoadPostPass = Target_OnLoadPostPass

    return inst
end

return Prefab("hh_ruler_shadow_pillar_target", target_fn)
