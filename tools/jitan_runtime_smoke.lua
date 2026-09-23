-- Dedicated-server smoke for the disposable Tế Đàn audit cluster.
-- It exercises the real registered prefabs and components, then removes only
-- entities tagged with its own run ids. Never execute this in a player world.
local Catalog = require("ttk_jitan_encounter_catalog")
local Bosses = require("ttk_jitan_bosses")
local Setup = require("ttk_jitan_encounter_setup")

local PREFIX = "TTK_JITAN_RUNTIME_"
local failures = {}
local passed = 0
local unavailable = 0

local function ReportFailure(id, problem)
    failures[#failures + 1] = tostring(id) .. ":" .. tostring(problem)
    print(PREFIX .. "ENCOUNTER_FAIL", tostring(id), tostring(problem))
end

local function Check(condition, problem)
    if not condition then error(problem or "assertion failed", 2) end
    return condition
end

local function IsValid(entity)
    return entity ~= nil and (entity.IsValid == nil or entity:IsValid())
end

local function Remove(entity)
    if IsValid(entity) and entity.Remove ~= nil then entity:Remove() end
end

local map = TheWorld.Map
local function IsLand(x, z)
    if not map:IsPassableAtPoint(x, 0, z) then return false end
    local point = Vector3(x, 0, z)
    return not (map.IsGroundTargetBlocked ~= nil and map:IsGroundTargetBlocked(point))
        and not (map.IsPointNearHole ~= nil and map:IsPointNearHole(point))
end

local function IsOcean(x, z)
    return map.IsOceanAtPoint ~= nil and map:IsOceanAtPoint(x, 0, z)
end

local function IsShore(x, z)
    if not IsLand(x, z) then return false end
    for sample = 0, 7 do
        local angle = sample * PI / 4
        if IsOcean(x + math.cos(angle) * 6, z + math.sin(angle) * 6) then return true end
    end
    return false
end

local function CanSpawnFrom(kind, x, z)
    local radii = kind == "land" and { 8, 12, 16 } or { 12, 20, 28, 36, 44, 52 }
    local samples = kind == "land" and 5 or 24
    for _, radius in ipairs(radii) do
        for sample = 0, samples - 1 do
            local angle = sample / samples * 2 * PI
            local px, pz = x + math.cos(angle) * radius, z + math.sin(angle) * radius
            if kind == "ocean" and IsOcean(px, pz)
                or kind == "water_adjacent" and IsShore(px, pz)
                or kind == "land" and IsLand(px, pz) then
                return true
            end
        end
    end
    return false
end

local function FindAnchor(kind, ox, oz)
    if CanSpawnFrom(kind, ox, oz) then return Vector3(ox, 0, oz) end
    for radius = 24, 800, 16 do
        for sample = 0, 47 do
            local angle = sample / 48 * 2 * PI
            local x, z = ox + math.cos(angle) * radius, oz + math.sin(angle) * radius
            if CanSpawnFrom(kind, x, z) then return Vector3(x, 0, z) end
        end
    end
end

local function StartRun(trial, owner, id, index, anchor)
    trial:CancelTasks()
    trial.tracked_entities = {}
    trial.state = "active"
    trial.run_id = "runtime:" .. tostring(index) .. ":" .. id
    trial.run_number = index
    trial.owner = owner
    trial.owner_userid = owner.userid
    trial.boss_id = id
    trial.score = 3
    trial.rng = function() return .5 end
    trial._finishing = false
    trial.run_context = nil
    trial.availability_context = nil
    trial.inst.Transform:SetPosition(anchor.x, 0, anchor.z)
    owner.Transform:SetPosition(anchor.x, 0, anchor.z)
    trial:SetState("active")
end

local function AbortRun(trial)
    local run_id = trial.run_id
    if trial.state == "active" then trial:CaptureOwnedEntities(run_id) end
    trial._finishing = true
    trial:SetState("settling")
    trial:CleanupEntities(run_id, true)
    trial._finishing = false
    trial.tracked_entities = {}
    trial.owner = nil
    trial.owner_userid = nil
    trial.boss_id = nil
    trial:SetState("idle")
end

local function FindRequired(trial, prefab)
    for entity, record in pairs(trial.tracked_entities) do
        if record.required and entity.prefab == prefab and IsValid(entity) then return entity end
    end
end

local function Contains(list, value)
    for _, item in ipairs(list or {}) do if item == value then return true end end
    return false
end

local function CountItems(container)
    local count = 0
    for _ in pairs(container:GetAllItems() or {}) do count = count + 1 end
    return count
end

local function RunSmoke()
    Check(TheWorld ~= nil and TheWorld.ismastersim, "master simulation required")
    local portal = Check(TheSim:FindFirstEntityWithTag("multiplayer_portal"), "portal missing")
    local ox, _, oz = portal.Transform:GetWorldPosition()
    local anchors = {
        land = FindAnchor("land", ox, oz),
        ocean = FindAnchor("ocean", ox, oz),
        water_adjacent = FindAnchor("water_adjacent", ox, oz),
    }
    Check(anchors.land ~= nil, "land anchor missing")

    local altar = Check(SpawnPrefab("ttk_jitan"), "altar prefab missing")
    local owner = Check(SpawnPrefab("wilson"), "owner prefab missing")
    owner.userid = "KU_TTK_JITAN_RUNTIME_A"
    if owner.components.health ~= nil then owner.components.health:SetInvincible(true) end
    local trial = Check(altar.components.ttk_jitan_trial, "trial component missing")
    local entries = Catalog.GetEntries()
    local deferred = {}

    local function Exercise(encounter, index, done)
        local anchor = anchors[encounter.position_kind or "land"]
        if anchor == nil then done(false, "missing_map_capability:" .. tostring(encounter.position_kind)); return end
        local setup_problem = nil
        local ok, problem = pcall(function()
            StartRun(trial, owner, encounter.id, index, anchor)
            local available, reason = Setup.IsAvailable(encounter, Bosses.BuildContext(trial))
            if not available then setup_problem = reason; return end
            local entities, spawn_error = Bosses.Spawn(trial, encounter.id)
            Check(entities ~= nil, spawn_error)
            local expected = 0
            for _, spec in ipairs(encounter.spawns) do expected = expected + (spec.count or 1) end
            Check(#entities == expected, "spawn cardinality " .. tostring(#entities) .. "/" .. tostring(expected))
        end)
        if not ok then done(false, problem); return end
        if setup_problem ~= nil then done(false, setup_problem); return end
        -- Let zero-delay Solo scaling and native initialization tasks execute.
        TheWorld:DoTaskInTime(.5, function()
            local verified, detail, maxhealth = xpcall(function()
                Check(trial.state == "active", "trial left active state")
                Check(trial:TickActive(trial.run_id), "active tick failed")
                local tracked, maxhealth = 0, 0
                for entity, record in pairs(trial.tracked_entities) do
                    Check(IsValid(entity), "tracked entity became invalid")
                    Check(entity._ttk_jitan_run_id == trial.run_id, "unowned tracked entity")
                    if record.required then
                        Check(entity.components ~= nil and entity.components.health ~= nil,
                            "required entity missing health:" .. tostring(entity.prefab))
                        Check(entity.components.combat ~= nil,
                            "required entity missing combat:" .. tostring(entity.prefab))
                        maxhealth = maxhealth + (entity.components.health.maxhealth or 0)
                    end
                    tracked = tracked + 1
                end
                Check(tracked > 0 and maxhealth > 0, "no live required encounter entities")
                AbortRun(trial)
                return tracked, maxhealth
            end, debug.traceback)
            if not verified then
                if trial.state ~= "idle" then pcall(AbortRun, trial) end
                done(false, detail)
            else
                done(true, detail, maxhealth)
            end
        end)
    end

    local function RunSpecials()
        local ok, problem = xpcall(function()
            -- Scoped three-phase replacement reaches phase 3 without a
            -- global prefab-adoption queue.
            local phase = Catalog.GetById("celestial_champion")
            StartRun(trial, owner, phase.id, 9001, anchors.land)
            local entities, spawn_error = Bosses.Spawn(trial, phase.id)
            Check(entities ~= nil, spawn_error)
            local p1 = Check(FindRequired(trial, "alterguardian_phase1"), "phase1 not tracked")
            p1.components.health.currenthealth = 0
            Check(p1:PushEvent("phasetransition") ~= false, "phase1 transition failed")
            local p2 = Check(FindRequired(trial, "alterguardian_phase2"), "phase2 not adopted")
            p2.components.health.currenthealth = 0
            Check(p2:PushEvent("phasetransition") ~= false, "phase2 transition failed")
            Check(FindRequired(trial, "alterguardian_phase3") ~= nil, "phase3 not adopted")
            AbortRun(trial)
            print(PREFIX .. "PHASE_PASS")

            -- Preserve the manager through native final-pair loot setup.
            local twins = Catalog.GetById("twins_of_terror")
            StartRun(trial, owner, twins.id, 9002, anchors.land)
            entities, spawn_error = Bosses.Spawn(trial, twins.id)
            Check(entities ~= nil, spawn_error)
            local t1 = Check(FindRequired(trial, "twinofterror1"), "twin1 missing")
            local t2 = Check(FindRequired(trial, "twinofterror2"), "twin2 missing")
            t1.components.health.currenthealth = 0
            t2.components.health.currenthealth = 0
            t1:PushEvent("death"); t2:PushEvent("death")
            local final_loot = t2.components.lootdropper.loot
            Check(Contains(final_loot, "shieldofterror"), "shield loot lost")
            Check(Contains(final_loot, "chesspiece_twinsofterror_sketch"), "sketch loot lost")
            print(PREFIX .. "TWINS_PASS")
            Remove(t1); Remove(t2)
            for _, entity in ipairs(entities) do Remove(entity) end

            -- A rebuilt facade flushes a nearby altar backup on first open.
            local chest = Check(SpawnPrefab("ttk_llbx"), "reward chest missing")
            chest.Transform:SetPosition(anchors.land.x + 2, 0, anchors.land.z)
            altar.Transform:SetPosition(anchors.land.x, 0, anchors.land.z)
            owner.Transform:SetPosition(anchors.land.x, 0, anchors.land.z)
            local seed = Check(SpawnPrefab("ttk_lingshi1"), "reward item missing")
            local saved = seed:GetSaveRecord(); seed:Remove()
            Check(trial:AdoptRewardBackup("runtime-recovery:1", owner.userid, {
                { save_record = saved },
            }), "backup adoption failed")
            Check(chest.components.container.itemtestfn ~= nil
                and chest.components.container:itemtestfn({}) == false, "facade accepts insertion")
            Check(chest.components.container:Open(owner), "owner facade open failed")
            local private_a = Check(chest:GetRewardContainer(owner, false), "owner compartment missing")
            Check(private_a.components.container.itemtestfn == nil, "private compartment rejects rewards")
            Check(CountItems(private_a.components.container) >= 1, "open did not flush backup")

            local other = Check(SpawnPrefab("wilson"), "second owner missing")
            other.userid = "KU_TTK_JITAN_RUNTIME_B"
            other.Transform:SetPosition(anchors.land.x, 0, anchors.land.z)
            Check(chest.components.ttk_jitan_rewards:Queue("runtime-other:1", other.userid, {
                { save_record = saved },
            }), "second queue failed")
            Check(chest.components.container:Open(other), "second facade open failed")
            local private_b = Check(chest:GetRewardContainer(other, false), "second compartment missing")
            Check(private_a ~= private_b, "private compartments shared")
            Check(CountItems(private_b.components.container) == 1, "second reward missing")
            Check(private_a.components.container:Open(other) == false, "direct cross-user open allowed")
            Check(private_a.components.container:Open(owner) == true, "direct owner open denied")
            print(PREFIX .. "CHEST_PASS")
            Remove(chest); Remove(other); Remove(owner); Remove(altar)
        end, debug.traceback)
        if not ok then failures[#failures + 1] = "specials:" .. tostring(problem) end
        if #failures == 0 then
            print(PREFIX .. "PASS", "encounters=" .. tostring(passed), "unavailable=" .. tostring(unavailable))
        else
            print(PREFIX .. "FAIL", table.concat(failures, ","))
        end
    end

    local function RunDeferred(index, current_season)
        if index > #deferred then RunSpecials(); return end
        local encounter = deferred[index]
        local desired = encounter.world_state.iswinter and "winter" or "spring"
        local function StartDeferred()
            Exercise(encounter, 8000 + index, function(ok, detail, health)
                if ok then
                    passed = passed + 1
                    print(PREFIX .. "ENCOUNTER_PASS", encounter.id,
                        "tracked=" .. tostring(detail), "maxhealth=" .. tostring(health), "season=" .. desired)
                else
                    ReportFailure(encounter.id, detail)
                end
                TheWorld:DoTaskInTime(.1, function() RunDeferred(index + 1, desired) end)
            end)
        end
        if desired ~= current_season then
            TheWorld:PushEvent("ms_setseason", desired)
            TheWorld:DoTaskInTime(1, StartDeferred)
        else
            StartDeferred()
        end
    end

    local function RunEntry(index)
        if index > #entries then RunDeferred(1, TheWorld.state.season); return end
        local encounter = entries[index]
        Exercise(encounter, index, function(ok, detail, health)
            if ok then
                passed = passed + 1
                print(PREFIX .. "ENCOUNTER_PASS", encounter.id,
                    "tracked=" .. tostring(detail), "maxhealth=" .. tostring(health))
            elseif type(detail) == "string" and string.find(detail, "^missing_world_state:") then
                deferred[#deferred + 1] = encounter
                print(PREFIX .. "ENCOUNTER_DEFERRED", encounter.id, detail)
                if trial.state ~= "idle" then AbortRun(trial) end
            elseif type(detail) == "string" and string.find(detail, "^missing_map_capability:") then
                unavailable = unavailable + 1
                print(PREFIX .. "ENCOUNTER_UNAVAILABLE", encounter.id, detail)
                if trial.state ~= "idle" then AbortRun(trial) end
            elseif detail == "missing_dependency:solo_leveling" then
                unavailable = unavailable + 1
                print(PREFIX .. "ENCOUNTER_UNAVAILABLE", encounter.id, detail)
                if trial.state ~= "idle" then AbortRun(trial) end
            else
                ReportFailure(encounter.id, detail)
                if trial.state ~= "idle" then pcall(AbortRun, trial) end
            end
            TheWorld:DoTaskInTime(.1, function() RunEntry(index + 1) end)
        end)
    end

    RunEntry(1)
end

TheWorld:DoTaskInTime(1, function()
    local ok, problem = xpcall(RunSmoke, debug.traceback)
    if not ok then print(PREFIX .. "FAIL", tostring(problem)) end
end)
