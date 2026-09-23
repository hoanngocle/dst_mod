local M = {}

local GENERIC_DEATH = {
    spiderqueen = true,
    minotaur = true,
    bearger = true,
    deerclops = true,
    dragonfly = true,
    mutatedbearger = true,
    beequeen = true,
    alterguardian_phase3 = true,
    mutateddeerclops = true,
    mutatedwarg = true,
    shadowthrall_horns = true,
    shadowthrall_hands = true,
    shadowthrall_wings = true,
    shadow_knight = true,
    shadow_bishop = true,
    shadow_rook = true,
}

local function IsOwned(inst, trial, run_id)
    return inst ~= nil and trial ~= nil and trial.run_id == run_id
        and inst._ttk_jitan_run_id == run_id
        and (inst.HasTag == nil or inst:HasTag("ttk_jitan_boss"))
end

local function Mark(inst, trial, run_id)
    return IsOwned(inst, trial, run_id) and trial:MarkBossDefeated(run_id, inst) or false
end

local function TrackAuxiliary(entity, trial, run_id)
    if entity ~= nil and entity.IsValid ~= nil and entity:IsValid() then
        trial:TrackEntity(run_id, entity, false)
    end
    return entity
end

local function WrapOwnedChildren(inst, trial, run_id)
    local commander = inst.components ~= nil and inst.components.commander or nil
    if commander ~= nil and type(commander.AddSoldier) == "function"
        and commander._ttk_jitan_run ~= run_id then
        commander._ttk_jitan_run = run_id
        local original = commander.AddSoldier
        commander.AddSoldier = function(component, child, ...)
            local results = { original(component, child, ...) }
            TrackAuxiliary(child, trial, run_id)
            return unpack(results)
        end
        if type(commander.GetAllSoldiers) == "function" then
            for _, soldier in ipairs(commander:GetAllSoldiers() or {}) do TrackAuxiliary(soldier, trial, run_id) end
            inst:ListenForEvent("soldierschanged", function()
                for _, soldier in ipairs(commander:GetAllSoldiers() or {}) do
                    TrackAuxiliary(soldier, trial, run_id)
                end
            end)
        end
    end

    local leader = inst.components ~= nil and inst.components.leader or nil
    if leader ~= nil and type(leader.AddFollower) == "function" and leader._ttk_jitan_run ~= run_id then
        leader._ttk_jitan_run = run_id
        local original = leader.AddFollower
        leader.AddFollower = function(component, follower, ...)
            local results = { original(component, follower, ...) }
            TrackAuxiliary(follower, trial, run_id)
            return unpack(results)
        end
        for follower in pairs(leader.followers or {}) do TrackAuxiliary(follower, trial, run_id) end
    end

    local childspawner = inst.components ~= nil and inst.components.childspawner or nil
    if childspawner ~= nil and childspawner._ttk_jitan_run ~= run_id then
        childspawner._ttk_jitan_run = run_id
        for _, method in ipairs({ "SpawnChild", "SpawnEmergencyChild" }) do
            local original = childspawner[method]
            if type(original) == "function" then
                childspawner[method] = function(component, ...)
                    local child = original(component, ...)
                    TrackAuxiliary(child, trial, run_id)
                    return child
                end
            end
        end
        for child in pairs(childspawner.childrenoutside or {}) do TrackAuxiliary(child, trial, run_id) end
        for child in pairs(childspawner.emergencychildrenoutside or {}) do TrackAuxiliary(child, trial, run_id) end
    end


    if (inst.prefab == "daywalker" or inst.prefab == "daywalker2") and not inst._ttk_jitan_leech_wrapped
        and type(inst.StartTrackingLeech) == "function" then
        inst._ttk_jitan_leech_wrapped = true
        local original = inst.StartTrackingLeech
        inst.StartTrackingLeech = function(entity, leech, ...)
            local results = { original(entity, leech, ...) }
            TrackAuxiliary(leech, trial, run_id)
            return unpack(results)
        end
        for leech in pairs(inst._leeches or {}) do TrackAuxiliary(leech, trial, run_id) end
    end
end

local function AttachDeath(inst, trial, run_id, predicate)
    inst:ListenForEvent("death", function(entity)
        if predicate == nil or predicate(entity) then Mark(entity, trial, run_id) end
    end)
end

local function WrapDaywalker(inst, trial, run_id)
    local original = inst.MakeDefeated
    if type(original) ~= "function" then return end
    inst.MakeDefeated = function(entity, ...)
        local results = { original(entity, ...) }
        if entity.defeated then Mark(entity, trial, run_id) end
        return unpack(results)
    end
end

local function WrapSharkboi(inst, trial, run_id)
    local original = inst.MakeTrader
    if type(original) ~= "function" then return end
    inst.MakeTrader = function(entity, ...)
        local results = { original(entity, ...) }
        local health = entity.components ~= nil and entity.components.health or nil
        if health ~= nil and health.currenthealth <= health.minhealth
            and entity.components.trader ~= nil then
            Mark(entity, trial, run_id)
        end
        return unpack(results)
    end
end

local function WrapKlaus(inst, trial, run_id)
    AttachDeath(inst, trial, run_id, function(entity)
        return type(entity.IsUnchained) == "function" and entity:IsUnchained()
    end)
    local original = inst.SpawnDeer
    if type(original) ~= "function" then return end
    inst.SpawnDeer = function(entity, ...)
        local results = { original(entity, ...) }
        local commander = entity.components ~= nil and entity.components.commander or nil
        if commander ~= nil and type(commander.GetAllSoldiers) == "function" then
            for _, soldier in ipairs(commander:GetAllSoldiers() or {}) do
                trial:TrackEntity(run_id, soldier, false)
            end
        end
        return unpack(results)
    end
end

function M.Attach(inst, trial, run_id)
    if not IsOwned(inst, trial, run_id) or inst._ttk_jitan_adapter_run == run_id then return false end
    inst._ttk_jitan_adapter_run = run_id
    WrapOwnedChildren(inst, trial, run_id)
    if inst.prefab == "klaus" then
        WrapKlaus(inst, trial, run_id)
    elseif inst.prefab == "daywalker" or inst.prefab == "daywalker2" then
        WrapDaywalker(inst, trial, run_id)
        AttachDeath(inst, trial, run_id)
    elseif inst.prefab == "sharkboi" then
        WrapSharkboi(inst, trial, run_id)
        AttachDeath(inst, trial, run_id)
    elseif GENERIC_DEATH[inst.prefab] then
        AttachDeath(inst, trial, run_id)
    else
        AttachDeath(inst, trial, run_id)
    end
    return true
end

function M.CaptureOwned(inst, trial, run_id)
    if not IsOwned(inst, trial, run_id) then return end
    WrapOwnedChildren(inst, trial, run_id)
    for trap in pairs(inst._traps or {}) do TrackAuxiliary(trap, trial, run_id) end
    for leech in pairs(inst._leeches or {}) do TrackAuxiliary(leech, trial, run_id) end
    local mem = inst.sg ~= nil and inst.sg.mem or nil
    if mem ~= nil then
        TrackAuxiliary(mem.summon_circle, trial, run_id)
        TrackAuxiliary(mem.summon_fx, trial, run_id)
    end
end

function M.Install(env)
    env.AddStategraphPostInit("alterguardian_phase3", function(sg)
        local death = sg.states ~= nil and sg.states.death or nil
        if death == nil or type(death.onenter) ~= "function" or death._ttk_jitan_wrapped then return end
        death._ttk_jitan_wrapped = true
        local original = death.onenter
        death.onenter = function(inst, ...)
            if inst._ttk_jitan_run_id ~= nil and inst.HasTag ~= nil and inst:HasTag("ttk_jitan_boss") then
                inst.components.locomotor:StopMoving()
                inst.AnimState:SetBuild("alterguardian_spawn_death")
                inst.AnimState:SetBankAndPlayAnimation("alterguardian_spawn_death", "phase3_death")
                RemovePhysicsColliders(inst)
                inst.Light:SetIntensity(0.60 + 0.39 * 0.9 * 0.9)
                inst.Light:SetRadius(4.5)
                inst.Light:SetFalloff(0.85)
                inst:SetNoMusic(true)
                return
            end
            return original(inst, ...)
        end
        local animover = death.events ~= nil and death.events.animover or nil
        if animover ~= nil and type(animover.fn) == "function" then
            local original_animover = animover.fn
            animover.fn = function(inst, ...)
                if inst._ttk_jitan_run_id ~= nil and inst.HasTag ~= nil
                    and inst:HasTag("ttk_jitan_boss") then
                    inst:Remove()
                    return
                end
                return original_animover(inst, ...)
            end
        end
    end)
end

return M
