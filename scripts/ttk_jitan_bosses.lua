local defs = require("ttk_jitan_defs")
local catalog = require("ttk_jitan_encounter_catalog")
local setup = require("ttk_jitan_encounter_setup")

local M = {}
local solo_capability_provider = function() return false end

local function Cleanup(entities)
    for _, entity in ipairs(entities) do
        if entity ~= nil and entity.IsValid ~= nil and entity:IsValid() then entity:Remove() end
    end
end

local function IsLandPoint(map, x, y, z)
    if map == nil or not map:IsPassableAtPoint(x, y, z) then return false end
    local point = Vector3(x, y, z)
    return not (map.IsGroundTargetBlocked ~= nil and map:IsGroundTargetBlocked(point))
        and not (map.IsPointNearHole ~= nil and map:IsPointNearHole(point))
end

local function IsOceanPoint(map, x, z)
    return map ~= nil and map.IsOceanAtPoint ~= nil and map:IsOceanAtPoint(x, 0, z)
end

local function IsWaterAdjacent(map, x, y, z)
    if not IsLandPoint(map, x, y, z) then return false end
    for i = 0, 7 do
        local angle = i * math.pi / 4
        if IsOceanPoint(map, x + math.cos(angle) * 6, z + math.sin(angle) * 6) then return true end
    end
    return false
end

local function IsValidSpawnPoint(kind, x, y, z)
    local map = TheWorld ~= nil and TheWorld.Map or nil
    if kind == "ocean" then return IsOceanPoint(map, x, z) end
    if kind == "water_adjacent" then return IsWaterAdjacent(map, x, y, z) end
    return IsLandPoint(map, x, y, z)
end

local function FindSpawnPositions(inst, kind, count)
    local x, y, z = inst.Transform:GetWorldPosition()
    local positions = {}
    local radii = kind == "land" and { 8, 12, 16 } or { 12, 20, 28, 36, 44, 52 }
    local samples = kind == "land" and 5 or 24
    for ordinal = 1, count do
        local found = nil
        for _, radius in ipairs(radii) do
            for sample = 0, samples - 1 do
                local angle = ((ordinal - 1) / math.max(count, 1) + sample / samples) * 2 * math.pi
                local px, pz = x + math.cos(angle) * radius, z + math.sin(angle) * radius
                local separated = true
                for _, prior in ipairs(positions) do
                    local dx, dz = px - prior.x, pz - prior.z
                    if dx * dx + dz * dz < 16 then separated = false; break end
                end
                if separated and IsValidSpawnPoint(kind, px, y, pz) then
                    found = Vector3(px, y, pz)
                    break
                end
            end
            if found ~= nil then break end
        end
        if found == nil then return nil end
        positions[#positions + 1] = found
    end
    return positions
end

function M.SetSoloCapabilityProvider(provider)
    if type(provider) ~= "function" then return false end
    solo_capability_provider = provider
    return true
end

local function HasIntegratedSoloCapability()
    local ok, enabled = pcall(solo_capability_provider)
    return ok and enabled == true
end

function M.BuildContext(trial)
    if trial ~= nil and type(trial.availability_context) == "table" then return trial.availability_context end
    local prefabs = {}
    local spawn_capacity = {}
    local capacity_cache = {}
    for _, encounter in ipairs(catalog.GetEntries()) do
        for _, spawn in ipairs(encounter.spawns) do
            prefabs[spawn.prefab] = Prefabs ~= nil and Prefabs[spawn.prefab] ~= nil
                or Prefabs == nil and (encounter.source == "native" or encounter.source == "legacy")
        end
        for _, prefab in ipairs(encounter.required_prefabs or {}) do
            prefabs[prefab] = Prefabs ~= nil and Prefabs[prefab] ~= nil
                or Prefabs == nil and (encounter.source == "native" or encounter.source == "legacy")
        end
        local count = 0
        for _, spawn in ipairs(encounter.spawns) do count = count + (spawn.count or 1) end
        local kind = encounter.position_kind or "land"
        local key = kind .. ":" .. tostring(count)
        if capacity_cache[key] == nil then
            local inst = trial ~= nil and trial.inst or nil
            capacity_cache[key] = inst ~= nil and FindSpawnPositions(inst, kind, count) ~= nil
        end
        spawn_capacity[encounter.id] = capacity_cache[key]
    end
    local inst = trial ~= nil and trial.inst or nil
    return {
        prefabs = prefabs,
        spawn_capacity = spawn_capacity,
        modflags = { solo_leveling = HasIntegratedSoloCapability() },
        worldstate = {
            iswinter = TheWorld ~= nil and TheWorld.state ~= nil
                and (TheWorld.state.iswinter == true
                    or TUNING ~= nil and TUNING.DEERCLOPS_ATTACKS_OFF_SEASON == true),
            isspring = TheWorld ~= nil and TheWorld.state ~= nil and TheWorld.state.isspring == true,
            iscave = TheWorld ~= nil and TheWorld.HasTag ~= nil and TheWorld:HasTag("cave"),
        },
        mapcapabilities = {
            ocean = inst ~= nil and FindSpawnPositions(inst, "ocean", 1) ~= nil,
            water_adjacent = inst ~= nil and FindSpawnPositions(inst, "water_adjacent", 1) ~= nil,
        },
    }
end

function M.AvailableEncounters(group, context)
    local available, rejected = {}, {}
    for _, encounter in ipairs(catalog.GetEntries()) do
        if encounter.group == group then
            local ok, reason = setup.IsAvailable(encounter, context)
            if ok then available[#available + 1] = encounter else rejected[encounter.id] = reason end
        end
    end
    return available, rejected
end

function M.ValidateOffering(offering_prefab, context)
    local offering = defs.offerings[offering_prefab]
    if offering == nil then return false, "invalid_offering" end
    local checked = {}
    for _, score in ipairs(offering) do
        for _, group in ipairs(defs.score_groups[score.score] or {}) do
            if not checked[group.group] then
                checked[group.group] = true
                local available = M.AvailableEncounters(group.group, context)
                if #available == 0 then return false, "no_supported_encounter:group" .. tostring(group.group) end
            end
        end
    end
    return true
end

function M.Choose(group, rng, context)
    local pool = M.AvailableEncounters(group, context)
    if #pool == 0 then return nil, "no_supported_encounter:group" .. tostring(group) end
    local roll = (rng or math.random)()
    local index = math.min(#pool, math.max(1, math.floor(roll * #pool) + 1))
    return pool[index].id
end

function M.GetEncounter(id)
    return catalog.GetById(id)
end

function M.CaptureOwned(entity, encounter_id, trial, run_id)
    local encounter = type(encounter_id) == "table" and encounter_id or catalog.GetById(encounter_id)
    if encounter == nil or type(setup.CaptureOwned) ~= "function" then return false end
    return setup.CaptureOwned(entity, encounter, trial, run_id)
end

function M.Spawn(trial, boss_id)
    local encounter = catalog.GetById(boss_id)
    if encounter == nil then return nil, "Boss Tế Đàn không tồn tại: " .. tostring(boss_id) end
    local entities = {}
    local total = 0
    for _, spawn in ipairs(encounter.spawns) do total = total + (spawn.count or 1) end
    local positions = FindSpawnPositions(trial.inst, encounter.position_kind or "land", total)
    if positions == nil then return nil, "Không có đủ vị trí " .. tostring(encounter.position_kind) .. " an toàn" end

    local ordinal = 0
    for _, spawn in ipairs(encounter.spawns) do
        for _ = 1, spawn.count or 1 do
            ordinal = ordinal + 1
            local entity = SpawnPrefab(spawn.prefab)
            if entity == nil then
                if trial.CleanupEntities ~= nil then trial:CleanupEntities(trial.run_id) end
                Cleanup(entities)
                return nil, "Không thể tạo " .. spawn.prefab
            end
            entities[#entities + 1] = entity
            local position = positions[ordinal]
            entity.Transform:SetPosition(position.x, position.y, position.z)
            local lifecycle_owned = encounter.lifecycle ~= nil
            if not trial:TrackEntity(trial.run_id, entity, spawn.required, {
                skip_adapter = lifecycle_owned, defer_nonpersistent = true,
            }) then
                Cleanup(entities)
                return nil, "Không thể ghi nhận " .. spawn.prefab
            end
            local ok, reason = setup.Prepare(entity, encounter, trial, trial.run_id, ordinal)
            if ok and lifecycle_owned then
                ok, reason = setup.AttachLifecycle(entity, encounter, trial, trial.run_id, ordinal)
            end
            -- The twins manager owns the native final-death listeners that
            -- award the shield/sketch loot.  Keep it through the winning
            -- death dispatch; its own code removes it after settlement.
            if ok and encounter.lifecycle == "twins" and entity.prefab == "twinmanager" then
                entity._ttk_jitan_preserve_on_win = true
            end
            entity.persists = false
            if not ok then
                if trial.CleanupEntities ~= nil then trial:CleanupEntities(trial.run_id) else Cleanup(entities) end
                return nil, "Encounter không tương thích " .. boss_id .. ": " .. tostring(reason)
            end
        end
    end
    return entities
end

return M
