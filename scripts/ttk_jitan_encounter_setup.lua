local M = {}

local installed_envs = setmetatable({}, { __mode = "k" })

local NEXT_PHASE = {
    alterguardian_phase1 = "alterguardian_phase2",
    alterguardian_phase2 = "alterguardian_phase3",
}

local CRABKING_GEMS = {
    "redgem", "bluegem", "purplegem", "orangegem", "yellowgem", "greengem",
    "redgem", "bluegem", "purplegem",
}

local function IsCurrent(trial, run_id)
    return trial ~= nil and trial.state == "active" and trial.run_id == run_id
end

local function Owner(trial)
    if trial == nil then return nil end
    if type(trial.FindOwner) == "function" then return trial:FindOwner() end
    return trial.owner
end

local function Track(trial, run_id, entity, required)
    if entity == nil or type(trial.TrackEntity) ~= "function" then return false end
    return trial:TrackEntity(run_id, entity, required)
end

local function Remember(entity, key)
    local known = entity.components ~= nil and entity.components.knownlocations or nil
    if known == nil or type(known.RememberLocation) ~= "function" or type(entity.GetPosition) ~= "function" then
        return false
    end
    known:RememberLocation(key, entity:GetPosition(), true)
    return true
end

local function TargetOwner(entity, trial)
    local combat = entity.components ~= nil and entity.components.combat or nil
    local owner = Owner(trial)
    if combat == nil or owner == nil then return false end
    if type(combat.SuggestTarget) == "function" then
        combat:SuggestTarget(owner)
    elseif type(combat.SetTarget) == "function" then
        combat:SetTarget(owner)
    else
        return false
    end
    return true
end

local function DisableOffscreenRemoval(entity)
    local task = entity.sleeptask or entity._sleeptask
    if task ~= nil and type(task.Cancel) == "function" then task:Cancel() end
    entity.sleeptask = nil
    entity._sleeptask = nil
    entity.OnEntitySleep = function() end
end

local function WrapEntityTracker(entity, trial, run_id, required_keys)
    local tracker = entity.components ~= nil and entity.components.entitytracker or nil
    if tracker == nil or type(tracker.TrackEntity) ~= "function" or tracker._ttk_jitan_run == run_id then
        return tracker ~= nil
    end
    tracker._ttk_jitan_run = run_id
    local original = tracker.TrackEntity
    tracker.TrackEntity = function(component, key, child, ...)
        local results = { original(component, key, child, ...) }
        Track(trial, run_id, child, required_keys ~= nil and required_keys[key] == true and true or false)
        return unpack(results)
    end
    return true
end

local function PrepareMinotaur(entity)
    local site = entity.components ~= nil and entity.components.constructionsite or nil
    if site == nil then return true end
    if type(site.Disable) ~= "function" or type(site.SetOnConstructedFn) ~= "function" then
        return false, "invalid_component:constructionsite"
    end
    site:Disable()
    site:SetOnConstructedFn(nil)
    return true
end

local function PrepareAntlion(entity, trial)
    local owner = Owner(trial)
    if type(entity.StartCombat) ~= "function" then return false, "missing_api:StartCombat" end
    if owner == nil then return false, "missing_owner" end

    -- Native StartCombat creates combat/health only while the entity persists.
    -- Trial ownership has already made it nonpersistent, so permit activation
    -- only for this synchronous call and restore the trial cleanup contract.
    local previous_persists = entity.persists
    entity.persists = true
    local call_ok = pcall(entity.StartCombat, entity, owner)
    entity.persists = previous_persists
    if not call_ok or entity.components == nil or entity.components.combat == nil
        or entity.components.health == nil then
        return false, "activation_failed:antlion"
    end
    return true
end

local function WrapReturnedEntity(entity, method, trial, run_id)
    local original = entity[method]
    if type(original) ~= "function" or entity["_ttk_jitan_" .. method] == run_id then return end
    entity["_ttk_jitan_" .. method] = run_id
    entity[method] = function(inst, ...)
        local results = { original(inst, ...) }
        Track(trial, run_id, results[1], false)
        return unpack(results)
    end
end

local function PrepareCrabKing(entity, trial, run_id)
    if type(entity.SocketItem) ~= "function" then return false, "missing_api:SocketItem" end
    -- These exported methods return the exact entity created by this Crab King.
    -- Wrapping them avoids radius scans and cannot adopt pre-existing sea mobs.
    for _, method in ipairs({ "LaunchProjectile", "SpawnCannonTower", "DoSpawnSeaStack" }) do
        WrapReturnedEntity(entity, method, trial, run_id)
    end
    local made = {}
    for _, prefab in ipairs(CRABKING_GEMS) do
        local gem = SpawnPrefab(prefab)
        if gem == nil then
            for _, item in ipairs(made) do
                if item.IsValid == nil or item:IsValid() then item:Remove() end
            end
            return false, "spawn_failed:" .. prefab
        end
        made[#made + 1] = gem
        entity:SocketItem(gem)
    end

    -- Crab King normally cleans this on death, but a cancelled trial removes a live boss.
    if type(entity.CleanUpArena) == "function" and not entity._ttk_jitan_remove_wrapped then
        entity._ttk_jitan_remove_wrapped = true
        local original_remove = entity.Remove
        if type(original_remove) == "function" then
            entity.Remove = function(inst, ...)
                local health = inst.components ~= nil and inst.components.health or nil
                if health == nil or type(health.IsDead) ~= "function" or not health:IsDead() then
                    inst:CleanUpArena(true)
                end
                return original_remove(inst, ...)
            end
        end
    end
    return true
end

local function PrepareFuelweaver(entity, trial, run_id)
    local original = entity.IsNearAtrium
    if type(original) ~= "function" then return false, "missing_api:IsNearAtrium" end
    entity.IsNearAtrium = function(inst, other)
        if IsCurrent(trial, run_id) then
            local candidate = other or inst
            if candidate == inst then return true end
            if candidate ~= nil and trial.inst ~= nil and type(candidate.GetDistanceSqToInst) == "function"
                and candidate:GetDistanceSqToInst(trial.inst) <= 60 * 60 then
                return true
            end
        end
        return original(inst, other)
    end
    DisableOffscreenRemoval(entity)
    return true
end

local function PrepareTreasure(entity, encounter)
    local component = entity.components ~= nil and entity.components.hh_monster or nil
    if component == nil then return false, "missing_component:hh_monster" end
    if type(component.SetTreasureId) ~= "function" then return false, "missing_api:SetTreasureId" end
    component:SetTreasureId(encounter.treasure_id)
    return true
end

local function PositionLike(entity, other, dx, dz)
    if entity.Transform == nil or type(entity.Transform.SetPosition) ~= "function"
        or other.Transform == nil or type(other.Transform.GetWorldPosition) ~= "function" then return end
    local x, y, z = other.Transform:GetWorldPosition()
    entity.Transform:SetPosition(x + (dx or 0), y, z + (dz or 0))
end

local function PrepareTreasureKrampus(entity, encounter, trial, run_id)
    local ok, reason = PrepareTreasure(entity, encounter)
    if not ok then return false, reason end
    local specs = {
        { id = "pig_tank", dx = 2 },
        { id = "pig_attack", dx = -2 },
    }
    local adds = {}
    for _, spec in ipairs(specs) do
        local pig = SpawnPrefab("pigman")
        local monster = pig ~= nil and pig.components ~= nil and pig.components.hh_monster or nil
        if pig == nil or monster == nil or type(monster.SetTreasureId) ~= "function" then
            if pig ~= nil and type(pig.Remove) == "function" then pig:Remove() end
            for _, add in ipairs(adds) do if type(add.Remove) == "function" then add:Remove() end end
            return false, "missing_component:hh_monster"
        end
        monster:SetTreasureId(spec.id)
        PositionLike(pig, entity, spec.dx, 0)
        Track(trial, run_id, pig, false)
        adds[#adds + 1] = pig
    end
    return true
end

local function PrepareTwins(entity, trial, run_id)
    local tracker = entity.components ~= nil and entity.components.entitytracker or nil
    local owner = Owner(trial)
    if tracker == nil or owner == nil or type(entity.PushEvent) ~= "function" then
        return false, tracker == nil and "missing_component:entitytracker" or "missing_owner"
    end
    WrapEntityTracker(entity, trial, run_id, { twin1 = true, twin2 = true })
    entity:PushEvent("arrive", owner)
    return true
end

local function PrepareKlaus(entity, trial)
    Remember(entity, "spawnpoint")
    if type(entity.SpawnDeer) ~= "function" then return false, "missing_api:SpawnDeer" end
    entity:SpawnDeer()
    TargetOwner(entity, trial)
    return true
end

local function PrepareDragonfly(entity, trial, run_id)
    Remember(entity, "spawnpoint")
    DisableOffscreenRemoval(entity)
    entity:ListenForEvent("rampingspawner_spawn", function(_, data)
        Track(trial, run_id, data ~= nil and data.newent or nil, false)
    end)
    TargetOwner(entity, trial)
    return true
end

local function PrepareMoose(entity, trial, run_id)
    WrapEntityTracker(entity, trial, run_id)
    TargetOwner(entity, trial)
    return true
end

local function PrepareToadstool(entity, trial, run_id)
    if entity._ttk_jitan_sprout_listener_run == run_id then return true end
    if type(entity.ListenForEvent) ~= "function" then return false, "missing_api:ListenForEvent" end
    entity._ttk_jitan_sprout_listener_run = run_id
    entity._ttk_jitan_sprouts = entity._ttk_jitan_sprouts or {}
    entity:ListenForEvent("linkmushroomsprout", function(inst, sprout)
        if inst._ttk_jitan_run_id ~= run_id or not IsCurrent(trial, run_id) then return end
        if sprout ~= nil then
            inst._ttk_jitan_sprouts[sprout] = true
            Track(trial, run_id, sprout, false)
        end
    end)
    return true
end

function M.IsAvailable(encounter, context)
    if type(encounter) ~= "table" or type(context) ~= "table" then
        return false, "invalid_encounter"
    end
    local modflags = context.modflags or {}
    for _, dependency in ipairs(encounter.dependencies or {}) do
        if modflags[dependency] ~= true then return false, "missing_dependency:" .. dependency end
    end
    local prefabs = context.prefabs or {}
    for _, spawn in ipairs(encounter.spawns or {}) do
        if not prefabs[spawn.prefab] then return false, "missing_prefab:" .. tostring(spawn.prefab) end
    end
    for _, prefab in ipairs(encounter.required_prefabs or {}) do
        if not prefabs[prefab] then return false, "missing_prefab:" .. tostring(prefab) end
    end
    local worldstate = context.worldstate or {}
    for key, expected in pairs(encounter.world_state or {}) do
        if worldstate[key] ~= expected then return false, "missing_world_state:" .. tostring(key) end
    end
    if context.spawn_capacity ~= nil and context.spawn_capacity[encounter.id] == false then
        return false, "missing_spawn_capacity:" .. tostring(encounter.id)
    end
    if encounter.position_kind ~= nil and encounter.position_kind ~= "land" then
        local capabilities = context.mapcapabilities or {}
        if capabilities[encounter.position_kind] ~= true then
            return false, "missing_map_capability:" .. encounter.position_kind
        end
    end
    return true
end

function M.Prepare(entity, encounter, trial, run_id, spawn_index)
    if entity == nil or type(encounter) ~= "table" or trial == nil or run_id == nil then
        return false, "invalid_setup"
    end
    local adapter = encounter.adapter
    local ok, reason = true, nil
    if adapter == "minotaur" then
        ok, reason = PrepareMinotaur(entity)
    elseif adapter == "antlion" then
        ok, reason = PrepareAntlion(entity, trial)
    elseif adapter == "crabking" then
        ok, reason = PrepareCrabKing(entity, trial, run_id)
    elseif adapter == "spawnpoint" then
        if not Remember(entity, "spawnpoint") then return false, "missing_component:knownlocations" end
        TargetOwner(entity, trial)
    elseif adapter == "home" then
        if not Remember(entity, "home") then return false, "missing_component:knownlocations" end
        TargetOwner(entity, trial)
    elseif adapter == "twins" then
        ok, reason = PrepareTwins(entity, trial, run_id)
    elseif adapter == "klaus" then
        ok, reason = PrepareKlaus(entity, trial)
    elseif adapter == "fuelweaver" then
        ok, reason = PrepareFuelweaver(entity, trial, run_id)
        TargetOwner(entity, trial)
    elseif adapter == "target_owner" then
        if not TargetOwner(entity, trial) then return false, "missing_combat_target_api" end
    elseif adapter == "wagboss_robot" then
        if type(entity.ConfigureHostile) ~= "function" then return false, "missing_api:ConfigureHostile" end
        entity:ConfigureHostile()
        TargetOwner(entity, trial)
    elseif adapter == "dragonfly" then
        ok, reason = PrepareDragonfly(entity, trial, run_id)
    elseif adapter == "moose" then
        ok, reason = PrepareMoose(entity, trial, run_id)
    elseif adapter == "toadstool" then
        ok, reason = PrepareToadstool(entity, trial, run_id)
    elseif adapter == "worm_boss" then
        DisableOffscreenRemoval(entity)
        TargetOwner(entity, trial)
    elseif adapter == "treasure" then
        ok, reason = PrepareTreasure(entity, encounter)
    elseif adapter == "treasure_krampus" then
        ok, reason = PrepareTreasureKrampus(entity, encounter, trial, run_id)
    end

    if ok and (encounter.source == "solo" or encounter.source == "solo_treasure") then
        DisableOffscreenRemoval(entity)
    end
    return ok, reason
end

local function TrackExact(trial, run_id, entity)
    if entity == nil or type(entity) ~= "table" and type(entity) ~= "userdata" then return end
    if type(entity.IsValid) == "function" and entity:IsValid() then
        Track(trial, run_id, entity, false)
    end
end

local function TrackValues(trial, run_id, values)
    for _, value in pairs(values or {}) do TrackExact(trial, run_id, value) end
end

local function TrackKeys(trial, run_id, values)
    for value in pairs(values or {}) do TrackExact(trial, run_id, value) end
end

local function CaptureWorm(entity, trial, run_id)
    TrackExact(trial, run_id, entity.head)
    TrackExact(trial, run_id, entity.tail)
    TrackExact(trial, run_id, entity.new_crack)
    TrackValues(trial, run_id, entity.segment_pool)
    for _, chunk in ipairs(entity.chunks or {}) do
        TrackExact(trial, run_id, chunk.head)
        TrackExact(trial, run_id, chunk.tail)
        TrackExact(trial, run_id, chunk.dirt_start)
        TrackExact(trial, run_id, chunk.dirt_end)
        TrackExact(trial, run_id, chunk.lastsegment)
        TrackValues(trial, run_id, chunk.segments)
    end
end

local function CaptureCrabKing(entity, trial, run_id)
    -- CleanUpArena(true) is still authoritative for map ice and cancellation.
    -- These tables contain exact owned entities and may also contain false/task placeholders.
    for _, values in ipairs({ entity.arms, entity.cannontowers, entity.keystones, entity.geysers }) do
        TrackValues(trial, run_id, values)
    end
end

local function CaptureMoose(entity, trial, run_id)
    local tracker = entity.components ~= nil and entity.components.entitytracker or nil
    if tracker == nil or type(tracker.GetEntity) ~= "function" then return end
    local egg = tracker:GetEntity("egg")
    TrackExact(trial, run_id, egg)
    local herd = egg ~= nil and egg.components ~= nil and egg.components.herd or nil
    if herd ~= nil then
        for member in pairs(herd.members or {}) do TrackExact(trial, run_id, member) end
    end
end

function M.CaptureOwned(entity, encounter, trial, run_id)
    if entity == nil or type(encounter) ~= "table" or trial == nil or run_id == nil
        or entity._ttk_jitan_run_id ~= run_id then
        return false
    end
    if entity.prefab == "worm_boss" then
        CaptureWorm(entity, trial, run_id)
    elseif entity.prefab == "crabking" then
        CaptureCrabKing(entity, trial, run_id)
    elseif entity.prefab == "moose" then
        CaptureMoose(entity, trial, run_id)
    elseif entity.prefab == "toadstool" or entity.prefab == "toadstool_dark" then
        TrackKeys(trial, run_id, entity._ttk_jitan_sprouts)
        -- Sporebombs are player debuffs with no source identity. They self-expire;
        -- do not adopt players or remove a same-name debuff from another encounter.
    elseif entity.prefab == "alterguardian_phase3" then
        for trap, active in pairs(entity._traps or {}) do
            if active then TrackExact(trial, run_id, trap) end
        end
    elseif entity.prefab == "alterguardian_phase1_lunarrift" then
        local statemem = entity.sg ~= nil and entity.sg.statemem or nil
        TrackExact(trial, run_id, statemem ~= nil and statemem.gestalt or nil)
    end
    return true
end

local function FinishSpawnFailure(trial, run_id)
    if type(trial.Finish) == "function" then
        trial:Finish(run_id, "cancelled", "spawn_failed")
    end
end

local function RemoveIfValid(entity)
    if entity ~= nil and type(entity.Remove) == "function"
        and (type(entity.IsValid) ~= "function" or entity:IsValid()) then
        entity:Remove()
    end
end

local function MarkOwned(entity, run_id)
    entity._ttk_jitan_run_id = run_id
    if type(entity.AddTag) == "function" then entity:AddTag("ttk_jitan_boss") end
end

local function SpawnNextPhase(old, encounter, trial, run_id, spawn_index, next_prefab)
    local transform = old.Transform
    local combat = old.components ~= nil and old.components.combat or nil
    if transform == nil or type(transform.GetWorldPosition) ~= "function"
        or type(transform.GetRotation) ~= "function" or combat == nil then
        FinishSpawnFailure(trial, run_id)
        return false
    end
    local px, py, pz = transform:GetWorldPosition()
    local rotation = transform:GetRotation()
    local target = combat.target
    local next_phase = type(SpawnPrefab) == "function" and SpawnPrefab(next_prefab) or nil
    if next_phase == nil then
        FinishSpawnFailure(trial, run_id)
        return false
    end
    local next_transform = next_phase.Transform
    local next_combat = next_phase.components ~= nil and next_phase.components.combat or nil
    if next_transform == nil or type(next_transform.SetPosition) ~= "function"
        or type(next_transform.SetRotation) ~= "function"
        or next_phase.AnimState == nil or type(next_phase.AnimState.MakeFacingDirty) ~= "function"
        or next_combat == nil or type(next_combat.SuggestTarget) ~= "function"
        or next_phase.sg == nil or type(next_phase.sg.GoToState) ~= "function" then
        RemoveIfValid(next_phase)
        FinishSpawnFailure(trial, run_id)
        return false
    end

    next_transform:SetPosition(px, py, pz)
    next_transform:SetRotation(rotation)
    next_phase.AnimState:MakeFacingDirty()
    next_combat:SuggestTarget(target)
    next_phase.sg:GoToState("spawn")
    MarkOwned(next_phase, run_id)

    local lifecycle_ok = M.AttachLifecycle(next_phase, encounter, trial, run_id, spawn_index)
    if not lifecycle_ok or type(trial.ReplaceRequired) ~= "function"
        or not trial:ReplaceRequired(old, next_phase) then
        RemoveIfValid(next_phase)
        FinishSpawnFailure(trial, run_id)
        return false
    end
    RemoveIfValid(old)
    return true
end

local function WrapPhaseTransition(entity, encounter, trial, run_id, spawn_index)
    if entity._ttk_jitan_phase_push_wrapped then return true end
    local original = entity.PushEvent
    local next_prefab = NEXT_PHASE[entity.prefab]
    if type(original) ~= "function" then return false, "missing_api:PushEvent" end
    if next_prefab == nil then return false, "unexpected_phase:" .. tostring(entity.prefab) end

    MarkOwned(entity, run_id)
    entity._ttk_jitan_phase_push_wrapped = true
    entity.PushEvent = function(inst, name, data, ...)
        local health = inst.components ~= nil and inst.components.health or nil
        local owned = inst._ttk_jitan_run_id == run_id
        if name ~= "phasetransition" or not owned or not IsCurrent(trial, run_id)
            or health == nil or type(health.IsDead) ~= "function" or not health:IsDead() then
            return original(inst, name, data, ...)
        end
        if inst._ttk_jitan_transitioning then return false end
        inst._ttk_jitan_transitioning = true
        return SpawnNextPhase(inst, encounter, trial, run_id, spawn_index, next_prefab)
    end
    return true
end

local function InstallMutationGuard(env)
    env.AddComponentPostInit("lunarriftmutationsmanager", function(component)
        if component._ttk_jitan_guarded then return end
        local original = component.SetMutationDefeated
        if type(original) ~= "function" then return end
        component._ttk_jitan_guarded = true
        component.SetMutationDefeated = function(manager, entity, ...)
            if entity ~= nil and type(entity.HasTag) == "function"
                and entity:HasTag("ttk_jitan_boss") then
                return
            end
            return original(manager, entity, ...)
        end
    end)
end

function M.Install(env)
    if type(env) ~= "table" or type(env.AddComponentPostInit) ~= "function" then
        return false, "missing_api:AddComponentPostInit"
    end
    if installed_envs[env] then return true end
    InstallMutationGuard(env)
    installed_envs[env] = true
    return true
end

function M.AttachLifecycle(entity, encounter, trial, run_id, spawn_index)
    if entity == nil or type(encounter) ~= "table" or trial == nil then
        return false, "invalid_lifecycle"
    end
    if encounter.lifecycle == "phase_chain" then
        if entity.prefab == "alterguardian_phase1" then
            return WrapPhaseTransition(entity, encounter, trial, run_id, spawn_index)
        elseif entity.prefab == "alterguardian_phase2" then
            return WrapPhaseTransition(entity, encounter, trial, run_id, spawn_index)
        elseif entity.prefab == "alterguardian_phase3" then
            MarkOwned(entity, run_id)
            entity:ListenForEvent("death", function(inst) trial:MarkBossDefeated(run_id, inst) end)
            return true
        end
        return false, "unexpected_phase:" .. tostring(entity.prefab)
    elseif encounter.lifecycle == "twins" then
        return true -- Prepare owns the manager-to-twins handoff.
    elseif encounter.lifecycle == "lunar_capture" then
        entity:ListenForEvent("minhealth", function(inst)
            if inst._ttk_jitan_capture_task ~= nil or not IsCurrent(trial, run_id) then return end
            inst._ttk_jitan_capture_task = inst:DoTaskInTime(2, function(owned)
                owned._ttk_jitan_capture_task = nil
                if not IsCurrent(trial, run_id) then return end
                local health = owned.components ~= nil and owned.components.health or nil
                if health == nil or health.currenthealth > health.minhealth then return end
                if owned.sg ~= nil and type(owned.sg.GoToState) == "function" then
                    owned.sg:GoToState("captured")
                    trial:MarkBossDefeated(run_id, owned)
                end
            end)
        end)
        return true
    end
    return true
end

return M
