local IsDungeonSurfaceAuthority = require("utils/hh_dungeon_authority")
local HHMonsterAutoStack = require("utils/hh_monster_autostack")

local ILLEGAL_DUNGEON_PREFABS = {
    telebase = true,
    townportal = true,
    tent = true,
    siestahut = true,
    wardrobe = true,
}

local DUNGEON_RADIUS = 45
local DUNGEON_COOLDOWN = 480
local DUNGEON_SUCCESS_TIMEOUT = 180
local MIN_GATE_RELOCATION_DISTANCE = 64
local MAX_GATE_CANDIDATES = 200
local GATE_RETRY_DELAY = 5
local DUNGEON_NEW_GATE_ANNOUNCEMENT = "Một Hầm Ngục mới đã xuất hiện ở đâu đó trong thế giới !"
local SUCCESSFUL_LEAVE_REASONS = {
    dungeon_exit = true,
    success_timeout = true,
}

-- Runtime ownership fields are not sufficient after a save/load because
-- vanilla entities may not serialize arbitrary Lua fields. These are the
-- only mob prefabs this manager can spawn, used solely by the bounded arena
-- cleanup fallback.
local DUNGEON_MOB_PREFABS = {
    spider = true,
    hh_dungeon_spider = true,
    hh_dungeon_horrorhound = true,
    hh_dungeon_firehound = true,
    hh_dungeon_icehound = true,
    hh_dungeon_snowhound = true,
    hh_dungeon_lightninghound = true,
    spider_hider = true,
    spider_dropper = true,
    spider_spitter = true,
    tallbird = true,
    lightninggoat = true,
    bishop = true,
    knight = true,
    rook = true,
    bishop_nightmare = true,
    knight_nightmare = true,
    rook_nightmare = true,
    hh_dungeon_pig = true,
    walrus = true,
    warglet = true,
    deerclops = true,
    bearger = true,
    dragonfly = true,
    minotaur = true,
    spiderqueen = true,
    leif = true,
    warg = true,
    hh_igris_dungeon = true,
    hh_sharkboi = true,
    hh_beru_dungeon = true,
}

local DUNGEON_BOSS_CORPSE_PREFABS = {
    deerclops = "deerclopscorpse",
    bearger = "beargercorpse",
    warg = "wargcorpse",
}

local DUNGEON_CORPSE_PREFABS = {
    -- Used only by CleanupDungeon's bounded arena sweep; never globally.
    deerclopscorpse = true,
    beargercorpse = true,
    wargcorpse = true,
}

local DUNGEON_CORPSE_POSITION_TOLERANCE = 4

local function IsValidGate(gate)
    return gate ~= nil
        and gate:IsValid()
        and gate.prefab == "dungeon_gate"
        and gate:HasTag("dungeon_gate")
end

local function IsDungeonGateEntity(entity)
    return entity ~= nil
        and entity:IsValid()
        and (entity.prefab == "dungeon_gate" or entity:HasTag("dungeon_gate"))
end

local function IsDungeonGateMapIcon(entity)
    local target = entity ~= nil and entity:IsValid() and entity._target or nil
    return entity ~= nil
        and entity:IsValid()
        and entity:HasTag("globalmapicon")
        and (entity:HasTag("hh_dungeon_gate_mapicon")
            or (target ~= nil and target.prefab == "dungeon_gate"))
end

local function RemoveNonSurfaceDungeonEntities()
    if Ents == nil then
        return
    end

    local stale_entities = {}
    for _, entity in pairs(Ents) do
        if IsDungeonGateEntity(entity) or IsDungeonGateMapIcon(entity) then
            table.insert(stale_entities, entity)
        end
    end

    for _, entity in ipairs(stale_entities) do
        if entity:IsValid() then
            entity._dungeon_gate_remove_intent = true
            entity:Remove()
        end
    end
end

local function CountPlayers(players)
    local count = 0
    for player, tracked in pairs(players or {}) do
        if tracked and player ~= nil then
            count = count + 1
        end
    end
    return count
end

local function HasTag(tags, tag)
    return tags ~= nil and table.contains(tags, tag)
end

local function TeleportPlayer(player, x, z)
    if player == nil or not player:IsValid() or x == nil or z == nil then
        return false
    end

    if player.Physics ~= nil then
        player.Physics:Teleport(x, 0, z)
    else
        player.Transform:SetPosition(x, 0, z)
    end
    if player.components ~= nil and player.components.playercontroller ~= nil then
        player:SnapCamera()
    end
    return true
end

local function RebindPlayerShadows(player)
    if player ~= nil
        and player:IsValid()
        and player.components ~= nil
        and player.components.hh_shadow_manager ~= nil then
        player.components.hh_shadow_manager:RebindOwnedFollowers()
    end
end

local PERSISTENT_ARENA_PREFABS = {
    dungeon_exit = true,
    dungeon_wall_ruins = true,
    pillar_ruins = true,
    hh_arena_lava_pond = true,
    hh_decor_scorched_skeleton = true,
    hh_decor_skeleton_pig = true,
    hh_decor_skeleton_merm = true,
}

local function IsPersistentArenaEntity(inst)
    if inst == nil or not inst:IsValid() then
        return false
    end
    if PERSISTENT_ARENA_PREFABS[inst.prefab] then
        return true
    end
    local prefab = inst.prefab or ""
    local rock_prefix = "hh_arena_lava_pond_rock"
    return string.sub(prefab, 1, #rock_prefix) == rock_prefix
end

local function IsHeldInventoryItem(inst)
    local inventoryitem = inst.components ~= nil and inst.components.inventoryitem or nil
    return inventoryitem ~= nil and inventoryitem:IsHeld()
end

local function IsProtectedFallbackEntity(inst)
    return inst:HasTag("player")
        or inst:HasTag("playerghost")
        or inst:HasTag("INANIMATE")
        or inst:HasTag("FX")
        or inst:HasTag("INLIMBO")
        or inst:HasTag("DECOR")
        or inst:HasTag("CLASSIFIED")
        or IsPersistentArenaEntity(inst)
end

local function IsKnownDungeonOwnedEntity(inst)
    return DUNGEON_MOB_PREFABS[inst.prefab] == true
        or inst.hh_is_dungeon_monster == true
        or inst:HasTag("hh_dungeon_mob")
        or inst:HasTag("rock_treasure")
        or inst.prefab == "minotaurchest"
end

local function IsWithinDungeonArenaAt(center_x, center_z, x, z)
    if center_x == nil or center_z == nil or x == nil or z == nil then
        return false
    end
    local dx = x - center_x
    local dz = z - center_z
    return dx * dx + dz * dz <= DUNGEON_RADIUS * DUNGEON_RADIUS
end

local function IsWithinDungeonArena(manager, x, z)
    return manager ~= nil
        and IsWithinDungeonArenaAt(manager.dungeon_center_x, manager.dungeon_center_z, x, z)
end

local function IsSafeFallbackCleanupEntity(inst, manager)
    if inst == nil or not inst:IsValid()
        or inst.parent ~= nil
        or IsProtectedFallbackEntity(inst)
        or IsHeldInventoryItem(inst) then
        return false
    end

    local inventoryitem = inst.components ~= nil and inst.components.inventoryitem or nil
    local is_bounded_dungeon_corpse = false
    if manager ~= nil
        and DUNGEON_CORPSE_PREFABS[inst.prefab] == true
        and inst.Transform ~= nil then
        local x, y, z = inst.Transform:GetWorldPosition()
        is_bounded_dungeon_corpse = IsWithinDungeonArena(manager, x, z)
    end
    return IsKnownDungeonOwnedEntity(inst)
        or is_bounded_dungeon_corpse
        or (inventoryitem ~= nil and inventoryitem.owner == nil)
        or inst:HasTag("structure")
        or inst:HasTag("wall")
end

local function IsTrackedRunEntityRemovable(inst)
    return inst ~= nil
        and inst:IsValid()
        and inst.parent == nil
        and not inst:HasTag("player")
        and not inst:HasTag("playerghost")
        and not IsHeldInventoryItem(inst)
        and not IsPersistentArenaEntity(inst)
end

local DungeonManager = Class(function(self, inst)
    self.inst = inst
    self.dungeon_center_x = 0
    self.dungeon_center_z = 0
    -- The manager starts pending until the world topology and mainland
    -- spawnpoint are available.  READY is published only after exactly one
    -- valid runtime gate has been spawned.
    self.state = "COOLDOWN" -- "READY", "IN_PROGRESS", "COOLDOWN"
    
    self.current_wave = 0
    self.max_waves = 3
    self.monsters = {}
    self.run_entities = {}
    self.pending_spawns = 0
    self.spawn_tasks = {}
    
    self.players_in_dungeon = {}
    self.boss_active = false
    self.time_left = 0
    self.cooldown_end_time = 0
    self.unentered_timeout_task = nil
    self.unentered_timeout_end_time = 0
    self.has_started_attempt = false
    self.is_cleared = false
    self.cleared_end_time = nil

    self.run_gate_x = nil
    self.run_gate_z = nil
    self.previous_gate_x = nil
    self.previous_gate_z = nil
    self.active_gate = nil
    self.gate_spawn_pending = false
    self.gate_retry_task = nil
    self.cooldown_task = nil
    self.initialization_task = nil
    self.position_check_task = nil
    self.load_finalized = false
    self.run_epoch = 0
    self.lifecycle_tasks = {}
    self.suppress_gate_respawn = false
    self.mainland_nodes_cache = nil
    self.announce_next_gate_spawn = false
    self.pending_dungeon_corpses = {}

    self.is_surface_authority = IsDungeonSurfaceAuthority(self.inst)
    if not self.is_surface_authority then
        self:DisableNonSurfaceDungeon()
        return
    end

    self.position_check_task = self.inst:DoPeriodicTask(0.5, function()
        self:CheckPlayerPositions()
    end)

    self.initialization_task = self.inst:DoTaskInTime(0.2, function()
        self.initialization_task = nil
        if not self.load_finalized then
            self.load_finalized = true
            self:InitializeNewWorld()
        end
    end)
    
    self.inst:ListenForEvent("ms_playerjoined", function(src, player)
        if player and self.state ~= "IN_PROGRESS" then
            player:DoTaskInTime(0.1, function()
                local px, py, pz = player.Transform:GetWorldPosition()
                if px and py and pz then
                    local dist_sq = (px - self.dungeon_center_x)^2 + (pz - self.dungeon_center_z)^2
                    if dist_sq <= DUNGEON_RADIUS * DUNGEON_RADIUS then
                        player:RemoveTag("in_solo_dungeon")
                        self:TeleportPlayerToRunGate(player)
                    end
                end
            end)
        end
    end, TheWorld)
    
    self.inst:ListenForEvent("ms_playerleft", function(src, player)
        if player and self.players_in_dungeon[player] then
            self:LeaveDungeon(player)
        end
    end, TheWorld)

    self.inst:ListenForEvent("ms_registercorpse", function(_, corpse)
        self:OnCorpseRegistered(corpse)
    end)
end)

function DungeonManager:IsSurfaceAuthority()
    return self.is_surface_authority == true
        and IsDungeonSurfaceAuthority(self.inst)
end

function DungeonManager:IsPointInsideDungeon(x, z)
    if x == nil or z == nil then
        return false
    end

    if self.dungeon_center_x ~= 0 or self.dungeon_center_z ~= 0 then
        return IsWithinDungeonArena(self, x, z)
    end

    local dungeon_exit = TheSim:FindFirstEntityWithTag("dungeon_exit")
    if dungeon_exit == nil or not dungeon_exit:IsValid() or dungeon_exit.Transform == nil then
        return false
    end

    local center_x, _, center_z = dungeon_exit.Transform:GetWorldPosition()
    return IsWithinDungeonArenaAt(center_x, center_z, x, z)
end

function DungeonManager:CancelAllTasks()
    if self.position_check_task ~= nil then
        self.position_check_task:Cancel()
        self.position_check_task = nil
    end
    if self.initialization_task ~= nil then
        self.initialization_task:Cancel()
        self.initialization_task = nil
    end
    if self.cooldown_task ~= nil then
        self.cooldown_task:Cancel()
        self.cooldown_task = nil
    end
    self:CancelGateRetry()
    self:CancelUnenteredTimeout()
    self:CancelRunTasks()
end

function DungeonManager:DisableNonSurfaceDungeon()
    self.is_surface_authority = false
    self.load_finalized = true
    self:CancelAllTasks()

    local active_gate = self.active_gate
    if IsValidGate(active_gate) then
        active_gate._dungeon_gate_remove_intent = true
        active_gate:Remove()
    end
    self.active_gate = nil
    RemoveNonSurfaceDungeonEntities()

    -- A legacy Cave manager state is intentionally discarded.  It must not
    -- be migrated to Forest or restarted as a delayed lifecycle task.
    self.state = "COOLDOWN"
    self.current_wave = 0
    self.has_started_attempt = false
    self.is_cleared = false
    self.cleared_end_time = nil
    self.cooldown_end_time = 0
    self.unentered_timeout_end_time = 0
    self.gate_spawn_pending = false
    self.players_in_dungeon = {}
    self.monsters = {}
    self.run_entities = {}
    self.pending_dungeon_corpses = {}
end

function DungeonManager:OnRemoveFromEntity()
    self:CancelAllTasks()
end

function DungeonManager:TrackLifecycleTask(task)
    if task ~= nil then
        table.insert(self.lifecycle_tasks, task)
    end
    return task
end

function DungeonManager:CancelRunTasks()
    for _, task in ipairs(self.spawn_tasks or {}) do
        if task ~= nil then
            task:Cancel()
        end
    end
    self.spawn_tasks = {}

    for _, task in ipairs(self.lifecycle_tasks or {}) do
        if task ~= nil then
            task:Cancel()
        end
    end
    self.lifecycle_tasks = {}
    self.pending_spawns = 0
end

function DungeonManager:TrackRunEntity(entity, run_epoch)
    if entity == nil or not entity:IsValid() then
        return entity
    end

    entity.hh_dungeon_manager = self
    entity.hh_dungeon_run_epoch = run_epoch or self.run_epoch
    self.run_entities = self.run_entities or {}
    self.run_entities[entity] = true
    return entity
end

function DungeonManager:RecordDungeonBossDeath(monster, run_epoch)
    if monster == nil or not monster:IsValid() then
        return
    end

    local corpse_prefab = DUNGEON_BOSS_CORPSE_PREFABS[monster.prefab]
    if corpse_prefab == nil
        or monster._hh_dungeon_corpse_recorded_epoch == run_epoch then
        return
    end

    local x, y, z = monster.Transform:GetWorldPosition()
    if x == nil or z == nil then
        return
    end

    monster._hh_dungeon_corpse_recorded_epoch = run_epoch
    table.insert(self.pending_dungeon_corpses, {
        boss_prefab = monster.prefab,
        corpse_prefab = corpse_prefab,
        run_epoch = run_epoch,
        death_x = x,
        death_z = z,
    })
end

function DungeonManager:TryClaimDungeonCorpse(corpse)
    if corpse == nil or not corpse:IsValid()
        or DUNGEON_CORPSE_PREFABS[corpse.prefab] ~= true
        or self.state ~= "IN_PROGRESS" then
        return false
    end

    local x, y, z = corpse.Transform:GetWorldPosition()
    if x == nil or z == nil or not IsWithinDungeonArena(self, x, z) then
        return false
    end

    local tolerance_sq = DUNGEON_CORPSE_POSITION_TOLERANCE * DUNGEON_CORPSE_POSITION_TOLERANCE
    local matched_index = nil
    local matched_record = nil
    for index, record in ipairs(self.pending_dungeon_corpses or {}) do
        if record.corpse_prefab == corpse.prefab
            and record.run_epoch == self.run_epoch
            and IsWithinDungeonArena(self, record.death_x, record.death_z) then
            local dx = x - record.death_x
            local dz = z - record.death_z
            if dx * dx + dz * dz <= tolerance_sq then
                matched_index = index
                matched_record = record
                break
            end
        end
    end

    if matched_record == nil then
        return false
    end

    table.remove(self.pending_dungeon_corpses, matched_index)
    corpse.hh_is_dungeon_corpse = true
    self:TrackRunEntity(corpse, matched_record.run_epoch)
    corpse:Remove()
    return true
end

function DungeonManager:OnCorpseRegistered(corpse)
    if corpse == nil or not corpse:IsValid()
        or DUNGEON_CORPSE_PREFABS[corpse.prefab] ~= true then
        return
    end

    -- ms_registercorpse fires while SpawnPrefab is still constructing the
    -- corpse, before TryEntityToCorpse copies its final position and data.
    -- Defer one simulation turn; this is event-driven and not a periodic scan.
    corpse:DoTaskInTime(0, function(inst)
        if inst ~= nil and inst:IsValid() then
            self:TryClaimDungeonCorpse(inst)
        end
    end)
end

function DungeonManager:RemoveActiveGate()
    -- DungeonManager is the sole runtime owner; never search the world for
    -- stale gates during normal lifecycle transitions.
    local gate = self.active_gate
    if gate == nil or not gate:IsValid() then
        self.active_gate = nil
        return false
    end

    self.suppress_gate_respawn = true
    gate._dungeon_gate_remove_intent = true
    gate:Remove()
    self.active_gate = nil
    self.suppress_gate_respawn = false
    return true
end

function DungeonManager:OnGateRemoved(gate)
    if not self:IsSurfaceAuthority() then
        return
    end
    if self.active_gate ~= gate then
        return
    end
    self.active_gate = nil

    if self.suppress_gate_respawn or self.gate_spawn_pending or gate._dungeon_gate_remove_intent then
        return
    end

    if self.state == "READY" or self.state == "IN_PROGRESS" then
        self:ScheduleGateRetry(true)
    end
end

function DungeonManager:IsActiveGate(gate)
    return IsValidGate(gate)
        and IsValidGate(self.active_gate)
        and gate == self.active_gate
end

function DungeonManager:TeleportPlayerToRunGate(player)
    return TeleportPlayer(player, self.run_gate_x, self.run_gate_z)
end

function DungeonManager:FindMainlandSeedIndex()
    local seed = TheSim:FindFirstEntityWithTag("multiplayer_portal")
        or TheSim:FindFirstEntityWithTag("spawnpoint_multiplayer")
    if seed == nil or not seed:IsValid() or TheWorld.Map == nil then
        return nil
    end

    local x, y, z = seed.Transform:GetWorldPosition()
    local node, node_index = TheWorld.Map:FindVisualNodeAtPoint(x, 0, z)
    if node == nil or node_index == nil or node_index <= 0 then
        node, node_index = TheWorld.Map:FindNodeAtPoint(x, 0, z)
    end
    return node_index
end

function DungeonManager:IsNonMainlandNode(node)
    return node == nil
        or HasTag(node.tags, "not_mainland")
        or HasTag(node.tags, "lunacyarea")
        or HasTag(node.tags, "solo_dungeon_arena")
end

function DungeonManager:CollectMainlandNodes()
    if self.mainland_nodes_cache ~= nil then
        return self.mainland_nodes_cache
    end

    local topology = TheWorld.topology
    local seed_index = self:FindMainlandSeedIndex()
    if topology == nil or topology.nodes == nil or seed_index == nil then
        return {}
    end

    local seed = topology.nodes[seed_index]
    if self:IsNonMainlandNode(seed) then
        return {}
    end

    local result = {}
    local visited = {}
    local queue = {seed_index}
    local cursor = 1
    visited[seed_index] = true

    while cursor <= #queue do
        local node_index = queue[cursor]
        cursor = cursor + 1
        local node = topology.nodes[node_index]
        if not self:IsNonMainlandNode(node) then
            result[#result + 1] = node_index
            for _, neighbour_index in ipairs(node.neighbours or {}) do
                if not visited[neighbour_index] then
                    visited[neighbour_index] = true
                    queue[#queue + 1] = neighbour_index
                end
            end
        end
    end

    if #result > 0 then
        -- Forest topology is immutable after world generation.  This cache is
        -- runtime-only and intentionally never serialized.
        self.mainland_nodes_cache = result
    end
    return result
end

function DungeonManager:IsValidGatePoint(x, z, ignore_relocation_distance)
    local map = TheWorld.Map
    if map == nil or x == nil or z == nil then
        return false
    end

    if not map:IsLandTileAtPoint(x, 0, z)
        or map:IsOceanAtPoint(x, 0, z, false)
        or map:IsImpassableTileAtPoint(x, 0, z)
        or not map:IsPassableAtPoint(x, 0, z, false) then
        return false
    end

    local point = Vector3(x, 0, z)
    if map:IsPointNearHole(point, 1.0) or map:IsGroundTargetBlocked(point, 1.0) then
        return false
    end

    local node = nil
    local node_index = nil
    node, node_index = map:FindVisualNodeAtPoint(x, 0, z)
    if node == nil or node_index == nil or node_index <= 0 or self:IsNonMainlandNode(node) then
        return false
    end

    local tagged_node = map:FindVisualNodeAtPoint(x, 0, z, "not_mainland")
    if tagged_node ~= nil then
        return false
    end

    if self.dungeon_center_x ~= 0 or self.dungeon_center_z ~= 0 then
        local arena_distance_sq = (x - self.dungeon_center_x)^2 + (z - self.dungeon_center_z)^2
        if arena_distance_sq <= (DUNGEON_RADIUS + 16)^2 then
            return false
        end
    end

    if not ignore_relocation_distance and self.previous_gate_x ~= nil and self.previous_gate_z ~= nil then
        local distance_sq = (x - self.previous_gate_x)^2 + (z - self.previous_gate_z)^2
        if distance_sq < MIN_GATE_RELOCATION_DISTANCE * MIN_GATE_RELOCATION_DISTANCE then
            return false
        end
    elseif self.previous_gate_x ~= nil and self.previous_gate_z ~= nil then
        local distance_sq = (x - self.previous_gate_x)^2 + (z - self.previous_gate_z)^2
        if distance_sq <= 0.25 then
            return false
        end
    end

    local blockers = TheSim:FindEntities(
        x,
        0,
        z,
        2.5,
        nil,
        {"FX", "NOCLICK", "DECOR", "INANIMATE", "player", "playerghost"}
    )
    for _, blocker in ipairs(blockers) do
        if blocker:IsValid()
            and blocker.prefab ~= "dungeon_gate"
            and not blocker:HasTag("globalmapicon") then
            return false
        end
    end

    return true
end

function DungeonManager:FindMainlandGatePoint(ignore_relocation_distance)
    local topology = TheWorld.topology
    local nodes = self:CollectMainlandNodes()
    if topology == nil or #nodes == 0 then
        return nil, nil
    end

    -- Shuffle the reachable node order without relying on pairs() order.
    for i = #nodes, 2, -1 do
        local j = math.random(i)
        nodes[i], nodes[j] = nodes[j], nodes[i]
    end

    local inspected = 0
    for _, node_index in ipairs(nodes) do
        local node = topology.nodes[node_index]
        if node ~= nil and node.poly ~= nil then
            local points_x, points_z = TheWorld.Map:GetRandomPointsForSite(
                node.x,
                node.y,
                node.poly,
                8
            )
            for i = 1, #(points_x or {}) do
                inspected = inspected + 1
                if inspected > MAX_GATE_CANDIDATES then
                    return nil, nil
                end

                local x = points_x[i]
                local z = points_z ~= nil and points_z[i] or nil
                if x ~= nil and z ~= nil and self:IsValidGatePoint(x, z, ignore_relocation_distance) then
                    return x, z
                end
            end
        end
    end

    return nil, nil
end

function DungeonManager:ScheduleGateRetry(prefer_saved_position)
    if not self:IsSurfaceAuthority() then
        self:DisableNonSurfaceDungeon()
        return
    end
    if self.gate_retry_task ~= nil then
        return
    end

    self.gate_retry_prefer_saved = prefer_saved_position == true
    self.gate_retry_task = self.inst:DoTaskInTime(GATE_RETRY_DELAY, function()
        self.gate_retry_task = nil
        self:TrySpawnGate(self.gate_retry_prefer_saved)
    end)
end

function DungeonManager:CancelGateRetry()
    if self.gate_retry_task ~= nil then
        self.gate_retry_task:Cancel()
        self.gate_retry_task = nil
    end
end

function DungeonManager:TrySpawnGate(prefer_saved_position)
    if not self:IsSurfaceAuthority() then
        self:DisableNonSurfaceDungeon()
        return false
    end
    if self.gate_spawn_pending then
        return false
    end
    if IsValidGate(self.active_gate) then
        self.announce_next_gate_spawn = false
        return true
    end

    self.gate_spawn_pending = true

    if not prefer_saved_position and self.run_gate_x ~= nil and self.run_gate_z ~= nil then
        self.previous_gate_x = self.run_gate_x
        self.previous_gate_z = self.run_gate_z
    end

    local gate_x = nil
    local gate_z = nil
    if prefer_saved_position and self.run_gate_x ~= nil and self.run_gate_z ~= nil
        and self:IsValidGatePoint(self.run_gate_x, self.run_gate_z, true) then
        gate_x = self.run_gate_x
        gate_z = self.run_gate_z
    else
        gate_x, gate_z = self:FindMainlandGatePoint(false)
        if gate_x == nil or gate_z == nil then
            gate_x, gate_z = self:FindMainlandGatePoint(true)
        end
    end

    if gate_x == nil or gate_z == nil then
        self.gate_spawn_pending = false
        if self.state == "READY" then
            self:CancelUnenteredTimeout()
            self.state = "COOLDOWN"
            TheWorld:PushEvent("dungeon_state_changed", {state = "COOLDOWN"})
        end
        self:ScheduleGateRetry(prefer_saved_position)
        return false
    end

    self.run_gate_x = gate_x
    self.run_gate_z = gate_z
    local gate = SpawnPrefab("dungeon_gate")
    if gate == nil then
        self.gate_spawn_pending = false
        self:ScheduleGateRetry(prefer_saved_position)
        return false
    end

    gate.Transform:SetPosition(gate_x, 0, gate_z)
    if not IsValidGate(gate) then
        if gate:IsValid() then
            gate._dungeon_gate_remove_intent = true
            gate:Remove()
        end
        self.gate_spawn_pending = false
        self:ScheduleGateRetry(prefer_saved_position)
        return false
    end

    local announce_new_cycle = self.announce_next_gate_spawn == true
    self.announce_next_gate_spawn = false
    gate.dungeon_run_epoch = self.run_epoch
    self.active_gate = gate
    self.gate_spawn_pending = false

    if self.state == "COOLDOWN" then
        self.state = "READY"
    end
    TheWorld:PushEvent("dungeon_state_changed", {
        state = self.is_cleared and "COOLDOWN" or self.state,
        stages = self.max_waves,
    })
    if self.state == "READY" and not self.has_started_attempt then
        self:StartUnenteredTimeout()
    end
    if announce_new_cycle then
        TheNet:Announce(DUNGEON_NEW_GATE_ANNOUNCEMENT)
    end
    return true
end

function DungeonManager:InitializeNewWorld()
    if not self:IsSurfaceAuthority() then
        self:DisableNonSurfaceDungeon()
        return
    end
    self.state = "COOLDOWN"
    self.run_epoch = self.run_epoch + 1
    self.max_waves = math.random(2, 10)
    self:TrySpawnGate(false)
end

function DungeonManager:StartCooldownTimer(remaining)
    if not self:IsSurfaceAuthority() then
        self:DisableNonSurfaceDungeon()
        return
    end
    self:CancelGateRetry()
    if self.cooldown_task ~= nil then
        self.cooldown_task:Cancel()
        self.cooldown_task = nil
    end

    local timeout = math.max(0, tonumber(remaining) or DUNGEON_COOLDOWN)
    self.cooldown_end_time = GetTime() + timeout
    self.cooldown_task = self.inst:DoTaskInTime(timeout <= 0 and 0.1 or timeout, function()
        self.cooldown_task = nil
        if self.state ~= "COOLDOWN" then
            return
        end

        self.cooldown_end_time = 0
        self.current_wave = 0
        self.has_started_attempt = false
        self.is_cleared = false
        self.cleared_end_time = nil
        self.max_waves = math.random(2, 10)
        self.run_epoch = self.run_epoch + 1
        self.announce_next_gate_spawn = true
        self:TrySpawnGate(false)
    end)
end

function DungeonManager:EvacuatePlayersToRunGate()
    local players = {}
    for player, tracked in pairs(self.players_in_dungeon) do
        if tracked then
            players[#players + 1] = player
        end
    end

    for _, player in ipairs(players) do
        self.players_in_dungeon[player] = nil
        if player ~= nil and player:IsValid() then
            player:RemoveTag("in_solo_dungeon")
            if self:TeleportPlayerToRunGate(player) then
                RebindPlayerShadows(player)
            end
        end
    end
end

local SpawnDetachedDungeonMonster

function DungeonManager:BeginFailure(reason)
    if not self:IsSurfaceAuthority() then
        self:DisableNonSurfaceDungeon()
        return
    end
    if self.state == "COOLDOWN" then
        return
    end

    local detached_gate_x = nil
    local detached_gate_z = nil
    local detached_max_waves = nil
    local detached_gate_valid = false
    if reason == "unentered_timeout" then
        detached_gate_x = self.run_gate_x
        detached_gate_z = self.run_gate_z
        detached_max_waves = self.max_waves
        detached_gate_valid = type(detached_gate_x) == "number"
            and type(detached_gate_z) == "number"
            and self:IsValidGatePoint(detached_gate_x, detached_gate_z, true)
    end

    self.run_epoch = self.run_epoch + 1
    self:CancelUnenteredTimeout()
    self:CancelGateRetry()
    self:CancelRunTasks()
    -- Failure/reset removes the old gate before evacuation, so all return
    -- paths must use the already-saved run_gate_x/run_gate_z snapshot.
    self:RemoveActiveGate()
    self:EvacuatePlayersToRunGate()
    self:CleanupDungeon()
    if reason == "unentered_timeout" and detached_gate_valid then
        SpawnDetachedDungeonMonster(detached_gate_x, detached_gate_z, detached_max_waves)
    end
    self.state = "COOLDOWN"
    self.has_started_attempt = false
    self.is_cleared = false
    self.cleared_end_time = nil
    TheWorld:PushEvent("dungeon_state_changed", {state = "COOLDOWN"})
    self:StartCooldownTimer(DUNGEON_COOLDOWN)
end

function DungeonManager:FinalizeClearedRun()
    if not self:IsSurfaceAuthority() then
        self:DisableNonSurfaceDungeon()
        return
    end
    if self.state ~= "IN_PROGRESS" or not self.is_cleared or CountPlayers(self.players_in_dungeon) ~= 0 then
        return
    end

    self.run_epoch = self.run_epoch + 1
    self:CancelGateRetry()
    self:CancelRunTasks()
    self:RemoveActiveGate()
    self:CleanupDungeon()
    self.state = "COOLDOWN"
    self.has_started_attempt = false
    TheWorld:PushEvent("dungeon_state_changed", {state = "COOLDOWN"})
    self:StartCooldownTimer(DUNGEON_COOLDOWN)
end

function DungeonManager:OnSave()
    if not self:IsSurfaceAuthority() then
        return nil
    end
    local now = GetTime()
    local data = {
        state = self.state,
        current_wave = self.current_wave,
        dungeon_center_x = self.dungeon_center_x,
        dungeon_center_z = self.dungeon_center_z,
        boss_active = self.boss_active,
        max_waves = self.max_waves,
        has_started_attempt = self.has_started_attempt,
        is_cleared = self.is_cleared == true,
        run_gate_x = self.run_gate_x,
        run_gate_z = self.run_gate_z,
        previous_gate_x = self.previous_gate_x,
        previous_gate_z = self.previous_gate_z,
        run_epoch = self.run_epoch,
    }

    if self.state == "IN_PROGRESS" and self.is_cleared then
        data.state = "COOLDOWN"
        data.has_started_attempt = false
        data.cooldown_remaining = math.max(0, (self.cleared_end_time or now) - now)
            + (DUNGEON_COOLDOWN - DUNGEON_SUCCESS_TIMEOUT)
    elseif self.state == "COOLDOWN" and self.cooldown_end_time then
        data.cooldown_remaining = math.max(0, self.cooldown_end_time - now)
    elseif self.state == "READY" and self.unentered_timeout_task then
        data.unentered_timeout_remaining = math.max(0, self.unentered_timeout_end_time - now)
    end
    return data
end

function DungeonManager:OnLoad(data)
    if self.initialization_task ~= nil then
        self.initialization_task:Cancel()
        self.initialization_task = nil
    end
    self.load_finalized = true
    self.mainland_nodes_cache = nil

    if not self:IsSurfaceAuthority() then
        self:DisableNonSurfaceDungeon()
        return
    end

    if data then
        self.state = data.state or "COOLDOWN"
        self.current_wave = data.current_wave or 0
        self.dungeon_center_x = data.dungeon_center_x or 0
        self.dungeon_center_z = data.dungeon_center_z or 0
        self.boss_active = data.boss_active or false
        self.has_started_attempt = data.has_started_attempt or false
        self.is_cleared = data.is_cleared == true
        self.run_gate_x = data.run_gate_x
        self.run_gate_z = data.run_gate_z
        self.previous_gate_x = data.previous_gate_x
        self.previous_gate_z = data.previous_gate_z
        self.run_epoch = data.run_epoch or self.run_epoch
        self.gate_spawn_pending = false
        
        self.max_waves = data.max_waves or math.random(2, 10)
        
        -- Active runs intentionally use the existing fail-safe policy on
        -- restart: no active-run resume.  The saved gate snapshot remains the
        -- authoritative recovery return point until cleanup completes.
        if self.state == "IN_PROGRESS" then
            self.state = "COOLDOWN"
            self.has_started_attempt = false
            self.is_cleared = false
            self.cooldown_end_time = GetTime() + DUNGEON_COOLDOWN
            self.inst:DoTaskInTime(0.5, function()
                self:RemoveActiveGate()
                self:EvacuatePlayersToRunGate()
                self:CleanupDungeon()
            end)
            self:StartCooldownTimer(DUNGEON_COOLDOWN)
        elseif self.state == "COOLDOWN" then
            self.inst:DoTaskInTime(0.5, function()
                self:RemoveActiveGate()
                self:EvacuatePlayersToRunGate()
                self:CleanupDungeon()
            end)
            self:StartCooldownTimer(data.cooldown_remaining or 0)
        elseif self.state == "READY" then
            self.state = "COOLDOWN"
            self.inst:DoTaskInTime(0.2, function()
                self:TrySpawnGate(true)
            end)
        end
    else
        self.max_waves = math.random(2, 10)
        self.state = "COOLDOWN"
        self.run_epoch = self.run_epoch + 1
        self.inst:DoTaskInTime(0.2, function()
            self:TrySpawnGate(false)
        end)
    end

    if data ~= nil and data.state == "READY" and data.unentered_timeout_remaining ~= nil then
        self.inst:DoTaskInTime(0.25, function()
            if self.state == "READY" then
                self:StartUnenteredTimeout(data.unentered_timeout_remaining)
            end
        end)
    end
end

function DungeonManager:CancelUnenteredTimeout()
    if self.unentered_timeout_task then
        self.unentered_timeout_task:Cancel()
        self.unentered_timeout_task = nil
    end
    self.unentered_timeout_end_time = 0
end

function DungeonManager:StartUnenteredTimeout(remaining)
    if not self:IsSurfaceAuthority() then
        self:DisableNonSurfaceDungeon()
        return
    end
    self:CancelUnenteredTimeout()
    if self.state ~= "READY" or self.has_started_attempt then return end
    local timeout = math.max(0, tonumber(remaining) or 480)
    if timeout <= 0 then timeout = 0.1 end
    self.unentered_timeout_end_time = GetTime() + timeout
    self.unentered_timeout_task = self.inst:DoTaskInTime(timeout, function()
        self.unentered_timeout_task = nil
        self.unentered_timeout_end_time = 0
        if self.state ~= "READY" or self.has_started_attempt or next(self.players_in_dungeon) ~= nil then return end
        TheNet:Announce("Hầm Ngục đã để lại một Vết Nứt khiến cho quái vật tràn ra thế giới !")
        self:BeginFailure("unentered_timeout")
    end)
end

function DungeonManager:CheckPlayerPositions()
    if not self:IsSurfaceAuthority() then
        self:DisableNonSurfaceDungeon()
        return
    end
    if self.state == "READY" and not self.has_started_attempt and not self.unentered_timeout_task then
        self:StartUnenteredTimeout()
    end
    if self.dungeon_center_x == 0 and self.dungeon_center_z == 0 then
        local exit_gate = TheSim:FindFirstEntityWithTag("dungeon_exit")
        if exit_gate then
            local cx, y, cz = exit_gate.Transform:GetWorldPosition()
            self.dungeon_center_x = cx
            self.dungeon_center_z = cz
        else
            return
        end
    end
    
    local radius_sq = DUNGEON_RADIUS * DUNGEON_RADIUS
    
    -- Sweep illegal structures only while a run is active or a tracked player
    -- still needs safety handling.  READY/COOLDOWN with no active run does not
    -- need a 45-unit entity scan every 0.5 seconds.
    if self.state == "IN_PROGRESS" or next(self.players_in_dungeon) ~= nil then
        local ents = TheSim:FindEntities(self.dungeon_center_x, 0, self.dungeon_center_z, DUNGEON_RADIUS)
        for i, v in ipairs(ents) do
            if v:IsValid() and v.parent == nil and ILLEGAL_DUNGEON_PREFABS[v.prefab] then
                local vx, vy, vz = v.Transform:GetWorldPosition()
                if v.components.workable and v.components.workable.workleft > 0 then
                    v.components.workable:Destroy(v)
                else
                    v:Remove()
                end
                local collapse_fx = SpawnPrefab("collapse_small")
                if collapse_fx ~= nil then
                    self:TrackRunEntity(collapse_fx, self.run_epoch)
                    collapse_fx.Transform:SetPosition(vx, vy, vz)
                end
            end
        end
    end
    
    for i, player in ipairs(AllPlayers) do
        if player and player:IsValid() then
            local px, py, pz = player.Transform:GetWorldPosition()
            local dist_sq = (px - self.dungeon_center_x)^2 + (pz - self.dungeon_center_z)^2
            local is_inside = dist_sq <= radius_sq
            local has_tag = player:HasTag("in_solo_dungeon")
            
            if self.state ~= "IN_PROGRESS" then
                if is_inside then
                    player:RemoveTag("in_solo_dungeon")
                    self:TeleportPlayerToRunGate(player)
                elseif has_tag then
                    player:RemoveTag("in_solo_dungeon")
                end
            else
                if is_inside and not has_tag then
                    self:PunishPlayer(player)
                elseif not is_inside and has_tag then
                    self:PunishPlayer(player)
                elseif has_tag and player:GetCurrentPlatform() ~= nil then
                    self:PunishPlayer(player)
                elseif has_tag and not self.players_in_dungeon[player] then
                    self.players_in_dungeon[player] = true
                end
            end
        end
    end
end

function DungeonManager:PunishPlayer(player)
    if player.components.health and not player.components.health:IsDead() then
        player._punished_by_dungeon = true
        TheNet:Announce("Đây là hình phạt dành cho " .. (player.name or "Ai đó") .. " vì dám coi thường Hầm Ngục")
        player.components.health:Kill()
        
        if self.players_in_dungeon[player] then
            self:LeaveDungeon(player)
        end
        
        player:DoTaskInTime(5, function()
            self:TeleportPlayerToRunGate(player)
            player._punished_by_dungeon = nil
        end)
    end
end

function DungeonManager:CanEnterDungeon(player, say_reason)
    local function Say(message)
        if say_reason and player ~= nil and player.components.talker ~= nil then
            player.components.talker:Say(message)
        end
    end

    if player == nil or not player:IsValid()
        or player.components.health ~= nil and player.components.health:IsDead()
        or player:HasTag("playerghost")
        or self.players_in_dungeon[player] then
        return false
    end

    if self.state == "COOLDOWN" then
        Say("Hầm ngục đã được chinh phạt, hiện tại không có mối nguy hiểm")
        return false
    end

    if self.is_cleared then
        Say("Hầm ngục đã được chinh phạt, không thể tiếp tục tiến vào")
        return false
    end

    if not IsValidGate(self.active_gate) or not self:IsActiveGate(self.active_gate) then
        Say("Hầm ngục chưa sẵn sàng mở cổng")
        return false
    end

    if self.state == "IN_PROGRESS" and self.current_wave >= 2 then
        Say("Mình đến quá trễ, quá trình chinh phạt đã bắt đầu mất rồi !")
        return false
    end

    local cooldown = player.components.dungeon_cooldown
    if cooldown ~= nil and cooldown:GetTime() > 0 then
        Say("Hầm ngục đang hỗn loạn, chưa thể tiến vào ! (" ..
            math.floor(cooldown:GetTime() / 60) .. " phút còn lại)")
        return false
    end

    if TheSim:FindFirstEntityWithTag("dungeon_exit") == nil then
        Say("Lỗi: Không tìm thấy Hầm Ngục.")
        return false
    end

    if player.components.inventory ~= nil then
        local follower_items = {
            chester_eyebone = true, hutch_fishbowl = true,
            beef_bell = true, beefalobell = true, beefalo_bell = true,
            glommerflower = true, glommer_flower = true,
            fruitflyfruit = true,
        }
        local has_follower_item = false

        local function CheckItems(container)
            if container == nil or has_follower_item then
                return
            end
            local slots = container.itemslots or container.slots
            if slots ~= nil then
                for _, item in pairs(slots) do
                    if follower_items[item.prefab] then
                        has_follower_item = true
                        return
                    elseif item.components.container ~= nil then
                        CheckItems(item.components.container)
                    end
                end
            end
            if container.equipslots ~= nil then
                for _, item in pairs(container.equipslots) do
                    if follower_items[item.prefab] then
                        has_follower_item = true
                        return
                    elseif item.components.container ~= nil then
                        CheckItems(item.components.container)
                    end
                end
            end
        end

        CheckItems(player.components.inventory)
        if has_follower_item then
            Say("Phải cất vật phẩm gọi Đệ và Thú cưỡi lại trước khi vào hầm ngục!")
            return false
        end
    end

    return true
end

function DungeonManager:EnterDungeon(player)
    if not self:IsSurfaceAuthority() or not self:CanEnterDungeon(player, true) then
        return false
    end

    local exit_gate = TheSim:FindFirstEntityWithTag("dungeon_exit")
    if exit_gate then
        local cx, y, cz = exit_gate.Transform:GetWorldPosition()
        self.dungeon_center_x = cx
        self.dungeon_center_z = cz

        if player.components.rider and player.components.rider:IsRiding() then
            player.components.rider:Dismount()
        end

        local shadow_manager = player.components ~= nil and player.components.hh_shadow_manager or nil
        if shadow_manager ~= nil then
            shadow_manager:PrepareForDungeonEntry()
        end

        if player.components.leader then
            local to_remove = {}
            for k, v in pairs(player.components.leader.followers) do
                if k:IsValid() and k.prefab ~= "abigail" and k.prefab ~= "wobybig" and k.prefab ~= "wobysmall" then
                    table.insert(to_remove, k)
                end
            end
            for _, follower in ipairs(to_remove) do
                player.components.leader:RemoveFollower(follower)
            end
        end
        
        if player.Physics then
            player.Physics:Teleport(self.dungeon_center_x, 0, self.dungeon_center_z + 4)
        else
            player.Transform:SetPosition(self.dungeon_center_x, 0, self.dungeon_center_z + 4)
        end
        if player.components.playercontroller then
            player:SnapCamera()
        end
        self.players_in_dungeon[player] = true
        player:AddTag("in_solo_dungeon")
        self.has_started_attempt = true
        self:CancelUnenteredTimeout()
        
        if self.state == "READY" then
            self.state = "IN_PROGRESS"
            TheWorld:PushEvent("dungeon_state_changed", {state = "IN_PROGRESS", stages = self.max_waves})

            local run_epoch = self.run_epoch
            self:TrackLifecycleTask(self.inst:DoTaskInTime(5, function()
                if self.run_epoch == run_epoch and self.state == "IN_PROGRESS" then
                    self:StartWave(1)
                end
            end))
        end
        if self.entry_receipt_epoch ~= self.run_epoch then
            self.entry_receipt_epoch = self.run_epoch
            self.entry_receipts = {}
        end
        local actor = player.userid or player
        if not self.entry_receipts[actor] then
            self.entry_receipts[actor] = true
            player:PushEvent("hh_dungeon_entered", { run_epoch=self.run_epoch })
        end
        return true
    else
        player.components.talker:Say("Lỗi: Không tìm thấy Hầm Ngục.")
        return false
    end
end



function DungeonManager:LeaveDungeon(player, reason)
    local left = false
    local successful_exit = SUCCESSFUL_LEAVE_REASONS[reason] == true
    if self.players_in_dungeon[player] then
        if successful_exit then
            local exit_gate = TheSim:FindFirstEntityWithTag("dungeon_exit")
            if exit_gate == nil
                or not exit_gate:IsValid()
                or exit_gate:HasTag("locked_by_boss")
                or player == nil
                or not player:IsValid()
                or self.run_gate_x == nil
                or self.run_gate_z == nil then
                return false
            end
        end

        if player:IsValid() then
            if successful_exit then
                local shadow_manager = player.components ~= nil
                    and player.components.hh_shadow_manager or nil
                if shadow_manager ~= nil then
                    shadow_manager:PrepareForDungeonTransition("leave")
                end
            end
            self.players_in_dungeon[player] = nil
            player:RemoveTag("in_solo_dungeon")
            left = self:TeleportPlayerToRunGate(player)
            if left then
                RebindPlayerShadows(player)
            end
        else
            self.players_in_dungeon[player] = nil
        end
    end

    local count = CountPlayers(self.players_in_dungeon)
    if count == 0 and self.state == "IN_PROGRESS" and self.is_cleared then
        -- Success keeps the old gate alive while any player remains inside.
        -- The last player triggers removal only after returning via the
        -- already-saved run_gate_x/run_gate_z snapshot.
        self:FinalizeClearedRun()
    elseif count == 0 and self.state == "IN_PROGRESS" and not self.is_cleared then
        TheNet:Announce("Tổ đội đã chinh phục thất bại ! Hầm ngục sẽ tiến vào giai đoạn bất hoạt")
        self:BeginFailure("last_player_left")
    end
    return left
end

function DungeonManager:CleanupDungeon()
    self:CancelRunTasks()

    self.run_entities = self.run_entities or {}
    for _, monster in ipairs(self.monsters or {}) do
        if monster ~= nil then
            self.run_entities[monster] = true
        end
    end

    -- Remove owned roots first. EntityScript:Remove() recursively removes
    -- children, so a child that is inside a chest/player inventory must not
    -- receive a second native Remove() call from the world sweep.
    local tracked_entities = {}
    for entity in pairs(self.run_entities) do
        table.insert(tracked_entities, entity)
    end
    for _, entity in ipairs(tracked_entities) do
        if IsTrackedRunEntityRemovable(entity) then
            entity:Remove()
        end
    end

    local ents = TheSim:FindEntities(self.dungeon_center_x, 0, self.dungeon_center_z, DUNGEON_RADIUS)
    for i, v in ipairs(ents) do
        if IsSafeFallbackCleanupEntity(v, self) then
            v:Remove()
        end
    end

    self.run_entities = {}
    self.monsters = {}
    self.boss_active = false
    self.is_cleared = false
    self.cleared_end_time = nil
    self.players_in_dungeon = self.players_in_dungeon or {}
    self.pending_spawns = 0
    self.pending_dungeon_corpses = {}
end

local vanilla_bosses = {"deerclops", "bearger", "dragonfly", "minotaur", "spiderqueen", "leif", "warg"}

local function GetMixedWave(max_waves)
    local cases = {
        {"hh_dungeon_spider", "hh_dungeon_spider", "hh_dungeon_spider", "hh_dungeon_spider", "hh_dungeon_spider", "hh_dungeon_spider", "hh_dungeon_spider", "hh_dungeon_spider", "hh_dungeon_spider", "hh_dungeon_spider"},
        {"hh_dungeon_horrorhound", "hh_dungeon_horrorhound", "hh_dungeon_firehound", "hh_dungeon_firehound", "hh_dungeon_icehound", "hh_dungeon_icehound", "hh_dungeon_snowhound", "hh_dungeon_snowhound", "hh_dungeon_lightninghound", "hh_dungeon_lightninghound"},
        {"spider_hider", "spider_hider", "spider_dropper", "spider_dropper", "spider_dropper", "spider_dropper", "spider_spitter", "spider_spitter", "spider_spitter", "spider_spitter"},
        {"tallbird", "tallbird", "tallbird", "tallbird", "tallbird", "tallbird", "tallbird", "tallbird", "tallbird", "tallbird"},
        {"lightninggoat", "lightninggoat", "lightninggoat", "lightninggoat", "lightninggoat", "lightninggoat", "lightninggoat", "lightninggoat", "lightninggoat", "lightninggoat"},
    }
    
    local hard_cases = {
        {"bishop", "bishop", "knight", "knight", "rook", "rook", "bishop_nightmare", "bishop_nightmare", "knight_nightmare", "rook_nightmare"},
        {"hh_dungeon_pig", "hh_dungeon_pig", "hh_dungeon_pig", "hh_dungeon_pig", "hh_dungeon_pig", "hh_dungeon_pig", "hh_dungeon_pig", "hh_dungeon_pig", "hh_dungeon_pig", "hh_dungeon_pig"},
        {"walrus", "walrus", "walrus", "walrus", "walrus", "walrus", "walrus", "walrus", "walrus", "walrus"},
        {"warglet", "warglet", "warglet", "warglet", "warglet", "warglet", "warglet", "warglet", "warglet", "warglet"}
    }
    
    local selected_case = nil
    if max_waves >= 6 then
        local combined = {}
        for _, v in ipairs(cases) do table.insert(combined, v) end
        for _, v in ipairs(hard_cases) do table.insert(combined, v) end
        selected_case = combined[math.random(#combined)]
    else
        selected_case = cases[math.random(#cases)]
    end
    
    local shuffled = {}
    for _, v in ipairs(selected_case) do table.insert(shuffled, v) end
    for i = #shuffled, 2, -1 do
        local j = math.random(i)
        shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
    end
    
    return shuffled
end
local super_bosses = {"hh_sharkboi", "hh_igris_dungeon", "hh_beru_dungeon"}

local function IsDungeonBossPrefab(prefab_name)
    for _, boss_name in ipairs(vanilla_bosses) do
        if prefab_name == boss_name then
            return true
        end
    end
    for _, boss_name in ipairs(super_bosses) do
        if prefab_name == boss_name then
            return true
        end
    end
    return false
end

local function ApplySoloLevelingBuffs(monster, multiplier)
    if monster.hh_damage then monster.hh_damage = monster.hh_damage * multiplier end
    if monster.hh_armor then monster.hh_armor = monster.hh_armor * multiplier end
    if monster.hh_fast_atk then monster.hh_fast_atk = monster.hh_fast_atk * multiplier end
    if monster.hh_speed_level then monster.hh_speed_level = monster.hh_speed_level * multiplier end
    if monster.hh_magic_damage then monster.hh_magic_damage = monster.hh_magic_damage * multiplier end
    if monster.hh_magic_def then monster.hh_magic_def = monster.hh_magic_def * multiplier end
end

local function SpawnCustomLoot(manager, monster, multiplier, max_waves, run_epoch, apply_normal_wave_loot_chance)
    local drop_vanilla = true
    local drop_mod = true
    if apply_normal_wave_loot_chance then
        drop_vanilla = math.random() < 0.50
        drop_mod = math.random() < 0.50
    end

    local vanilla_loot = {}
    if monster.components.lootdropper then
        if drop_vanilla then
            local generated = monster.components.lootdropper:GenerateLoot()
            for i, v in ipairs(generated) do
                table.insert(vanilla_loot, v)
            end
        end
        monster.components.lootdropper.DropLoot = function() end
    end
    
    local pos = monster:GetPosition()
    if drop_vanilla then
        for _, item_name in ipairs(vanilla_loot) do
            for i = 1, multiplier do
                local item = SpawnPrefab(item_name)
                if item then
                    if manager ~= nil then
                        manager:TrackRunEntity(item, run_epoch)
                    end
                    item.Transform:SetPosition(pos.x, 0, pos.z)
                    HHMonsterAutoStack.MarkMonsterLoot(item, monster)
                end
            end
        end
    end
    
    if drop_mod then
        local custom_count = (max_waves <= 5) and 1 or 2
        for i = 1, custom_count do
            local tally = SpawnPrefab("hh_effect_tally")
            if tally then
                if manager ~= nil then
                    manager:TrackRunEntity(tally, run_epoch)
                end
                tally.Transform:SetPosition(pos.x, 0, pos.z)
                HHMonsterAutoStack.MarkMonsterLoot(tally, monster)
            end

            local stone = SpawnPrefab("hh_remove_stone")
            if stone then
                if manager ~= nil then
                    manager:TrackRunEntity(stone, run_epoch)
                end
                stone.Transform:SetPosition(pos.x, 0, pos.z)
                HHMonsterAutoStack.MarkMonsterLoot(stone, monster)
            end
        end
    end
end

local function ConfigureDungeonMonsterGameplay(monster, multiplier, is_boss_wave, x, z, manager, run_epoch)
    if monster.prefab == "lightninggoat" then
        if monster.SetCharged then
            monster:SetCharged(true)
        else
            monster:PushEvent("lightningstrike")
        end
    end

    local fx = SpawnPrefab("spawn_fx_medium")
    if fx then
        if manager ~= nil then
            manager:TrackRunEntity(fx, run_epoch)
        end
        fx.Transform:SetPosition(x, 0, z)
    end
    if monster.SoundEmitter then
        monster.SoundEmitter:PlaySound("dontstarve/common/spawn/spawn")
    end

    local stat_multiplier = is_boss_wave and (multiplier == 3 and 1.5 or 1) or multiplier
    if monster.components.health then
        monster.components.health:SetMaxHealth(monster.components.health.maxhealth * stat_multiplier)
    end
    if monster.components.combat then
        local damage_multiplier = monster.components.combat.damagemultiplier or 1
        monster.components.combat.damagemultiplier = damage_multiplier * stat_multiplier
    end

    ApplySoloLevelingBuffs(monster, stat_multiplier)

    if monster.components.combat then
        monster.components.combat:SetKeepTargetFunction(function(inst, target)
            return target ~= nil and target:IsValid()
                and not target:HasTag("hh_dungeon_mob")
                and (target.components.health == nil or not target.components.health:IsDead())
                and inst:IsNear(target, 100)
        end)

        monster.components.combat:SetRetargetFunction(1, function(inst)
            return FindClosestPlayerToInst(inst, 100, true)
        end)

        local target = FindClosestPlayerInRange(x, 0, z, 100, true)
        if target then
            monster.components.combat:SetTarget(target)
        end
    end

    -- Apply the permanent world stage after dungeon-specific health and
    -- combat scaling has been composed. This covers both ordinary waves and
    -- boss spawns without replacing the existing dungeon multipliers.
    local world_rank = TheWorld ~= nil
        and TheWorld.components ~= nil
        and TheWorld.components.hh_world or nil
    if world_rank ~= nil and world_rank.ApplyWorldRankToEntity ~= nil then
        world_rank:ApplyWorldRankToEntity(monster)
    end
end

SpawnDetachedDungeonMonster = function(gate_x, gate_z, max_waves)
    if not IsDungeonSurfaceAuthority(TheWorld) then
        return nil
    end
    if type(gate_x) ~= "number" or type(gate_z) ~= "number" or type(max_waves) ~= "number" then
        return nil
    end

    local shuffled_wave = GetMixedWave(max_waves)
    if type(shuffled_wave) ~= "table" or #shuffled_wave <= 0 then
        return nil
    end

    local eligible_prefabs = {}
    for _, prefab_name in ipairs(shuffled_wave) do
        if type(prefab_name) == "string" and not IsDungeonBossPrefab(prefab_name) then
            table.insert(eligible_prefabs, prefab_name)
        end
    end
    if #eligible_prefabs <= 0 then
        return nil
    end
    local prefab_to_spawn = eligible_prefabs[math.random(#eligible_prefabs)]

    local multiplier = max_waves >= 6 and 3 or 2
    local monster = SpawnPrefab(prefab_to_spawn)
    if monster == nil then
        return nil
    end

    monster.hh_is_dungeon_monster = true
    monster.hh_is_dungeon_boss = false
    monster.hh_dungeon_difficulty = multiplier
    monster.hh_dungeon_reward_tier = multiplier >= 3 and 2 or 1
    monster.Transform:SetPosition(gate_x, 0, gate_z)
    ConfigureDungeonMonsterGameplay(monster, multiplier, false, gate_x, gate_z)
    monster:ListenForEvent("death", function()
        SpawnCustomLoot(nil, monster, multiplier, max_waves, nil, false)
    end)

    return monster
end

function DungeonManager:StartWave(wave_num)
    if self.state ~= "IN_PROGRESS" then
        return
    end

    local run_epoch = self.run_epoch

    self.current_wave = wave_num
    local is_boss_wave = false
    
    if wave_num == self.max_waves then
        is_boss_wave = true
        self.boss_active = true
        
        local exit1 = TheSim:FindFirstEntityWithTag("dungeon_exit")
        if exit1 then
            exit1:AddTag("locked_by_boss")
        end
    end
    
    local multiplier = 2
    if self.max_waves >= 6 then
        multiplier = 3
    end
    
    local monster_name = ""
    local count = 1
    
    if is_boss_wave then
        if self.max_waves <= 5 then
            monster_name = vanilla_bosses[math.random(#vanilla_bosses)]
            multiplier = 2
        else
            local rng = math.random()
            if rng <= 0.33 then
                monster_name = "hh_igris_dungeon"
            elseif rng <= 0.66 then
                monster_name = "hh_sharkboi"
            else
                monster_name = "hh_beru_dungeon"
            end
            multiplier = 3
        end
        count = 1
        TheNet:Announce("Hầm Ngục: BOSS ĐÃ XUẤT HIỆN ! HÃY TIÊU DIỆT NÓ VÀ NHẬN PHẨN THƯỞNG")
    else
        count = 10
        TheNet:Announce("Hầm Ngục: Bắt đầu Làn Sóng số " .. wave_num)
    end
    
    local cx, cz = self.dungeon_center_x, self.dungeon_center_z
    
    local shuffled_wave = {}
    if not is_boss_wave then
        shuffled_wave = GetMixedWave(self.max_waves)
    end
    
    self.pending_spawns = count
    self.spawn_tasks = self.spawn_tasks or {}
    
    local delays = {}
    if not is_boss_wave and count == 10 then
        delays = {0, 0.5, 1.0, 10, 10.5, 11.0, 20, 20.5, 21.0, 21.5}
    else
        for j = 1, count do table.insert(delays, 0) end
    end
    
    for i = 1, count do
        local delay = delays[i] or 0
        local t = self.inst:DoTaskInTime(delay, function()
            if self.run_epoch ~= run_epoch or self.state ~= "IN_PROGRESS" then
                return
            end
            self.pending_spawns = (self.pending_spawns or 1) - 1
            local angle = math.random() * 2 * PI
            local dist = math.random() * 10
            local mx = cx + math.cos(angle) * dist
            local mz = cz + math.sin(angle) * dist
            
            local prefab_to_spawn = is_boss_wave and monster_name or (shuffled_wave[i] or "spider")
            local monster = SpawnPrefab(prefab_to_spawn)
            if monster then
                monster.hh_is_dungeon_monster = true
                monster.hh_is_dungeon_boss = is_boss_wave
                monster.hh_dungeon_manager = self
                monster.hh_dungeon_run_epoch = run_epoch
                monster.hh_dungeon_difficulty = multiplier
                monster.hh_dungeon_reward_tier = is_boss_wave and 5 or (multiplier >= 3 and 2 or 1)
                self:TrackRunEntity(monster, run_epoch)
                monster.Transform:SetPosition(mx, 0, mz)
                ConfigureDungeonMonsterGameplay(monster, multiplier, is_boss_wave, mx, mz, self, run_epoch)
                
                if is_boss_wave and monster.components.lootdropper then
                    monster.boss_vanilla_loot = monster.components.lootdropper:GenerateLoot()
                    monster.components.lootdropper.DropLoot = function() end
                end
                
                monster:ListenForEvent("death", function()
                    if self.run_epoch ~= run_epoch then
                        return
                    end
                    self:RecordDungeonBossDeath(monster, run_epoch)
                    TheWorld:PushEvent("hh_dungeon_monster_death", monster)
                    if not is_boss_wave then
                        SpawnCustomLoot(self, monster, multiplier, self.max_waves, run_epoch, true)
                    end
                    self:OnMonsterDeath(monster)
                end)
                
                table.insert(self.monsters, monster)
            end
        end)
        table.insert(self.spawn_tasks, t)
    end
end

function DungeonManager:OnMonsterDeath(monster)
    if not self:IsSurfaceAuthority() or self.state ~= "IN_PROGRESS" or self.is_cleared
        or monster == nil or monster.hh_dungeon_run_epoch ~= self.run_epoch then
        return
    end

    local run_epoch = self.run_epoch
    local removed = false
    for i, v in ipairs(self.monsters) do
        if v == monster then
            table.remove(self.monsters, i)
            removed = true
            break
        end
    end
    if not removed then return end
    
    if #self.monsters == 0 and (self.pending_spawns or 0) <= 0 then
        if self.current_wave < self.max_waves then
            TheNet:Announce("Đã tiêu diệt sạch sẽ quái ở giai đoạn " .. self.current_wave .. ", hãy chuẩn bị cho đợt tiếp theo!")
            self:TrackLifecycleTask(self.inst:DoTaskInTime(10, function()
                if self.run_epoch == run_epoch and self.state == "IN_PROGRESS" and not self.is_cleared then
                    self:StartWave(self.current_wave + 1)
                end
            end))
        else
            TheNet:Announce("Hầm Ngục đã bị chinh phạt ! Cổng thoát sẽ đóng lại sau 3 phút.")
            self.boss_active = false
            local exit1 = TheSim:FindFirstEntityWithTag("dungeon_exit")
            if exit1 then
                exit1:RemoveTag("locked_by_boss")
            end
            
            local cx, cy, cz
            if monster and monster.Transform then
                cx, cy, cz = monster.Transform:GetWorldPosition()
            end
            if cx == nil or cz == nil then
                cx, cz = self.dungeon_center_x, self.dungeon_center_z
            end
            local chest = SpawnPrefab("minotaurchest")
            if chest then
                self:TrackRunEntity(chest, run_epoch)
                chest.Transform:SetPosition(cx, 0, cz)
                chest.SoundEmitter:PlaySound("dontstarve/common/ghost_spawn")

                local fx1 = SpawnPrefab("statue_transition_2")
                if fx1 ~= nil then
                    self:TrackRunEntity(fx1, run_epoch)
                    fx1.Transform:SetPosition(cx, 0, cz)
                    fx1.Transform:SetScale(1, 2, 1)
                end

                local fx2 = SpawnPrefab("statue_transition")
                if fx2 ~= nil then
                    self:TrackRunEntity(fx2, run_epoch)
                    fx2.Transform:SetPosition(cx, 0, cz)
                    fx2.Transform:SetScale(1, 1.5, 1)
                end
                
                local boss_items = {}
                if monster.boss_vanilla_loot then
                    for _, item_name in ipairs(monster.boss_vanilla_loot) do
                        table.insert(boss_items, item_name)
                    end
                end
                
                if self.max_waves <= 5 then
                    for i = 1, 4 do
                        table.insert(boss_items, "hh_effect_tally")
                        table.insert(boss_items, "hh_remove_stone")
                        table.insert(boss_items, "hh_essence")
                    end
                else
                    for i = 1, 5 do
                        table.insert(boss_items, "hh_effect_tally")
                        table.insert(boss_items, "hh_remove_stone")
                        table.insert(boss_items, "hh_essence")
                    end
                    local gems = {"redgem", "bluegem", "purplegem", "orangegem", "yellowgem", "greengem", "opalpreciousgem"}
                    for _, g in ipairs(gems) do table.insert(boss_items, g) end
                end
                
                if chest.components.container then
                    for _, item_name in ipairs(boss_items) do
                        local item = SpawnPrefab(item_name)
                        if item then
                            self:TrackRunEntity(item, run_epoch)
                            chest.components.container:GiveItem(item)
                        end
                    end
                end
                
                local killer = nil
                if monster.components.combat and monster.components.combat.target then
                    killer = monster.components.combat.target
                else
                    killer = FindClosestPlayerInRange(cx, 0, cz, 20, true)
                end
                
                if killer and killer.components.hh_player then
                    local function RollVirtualItem(chance, choice)
                        if math.random() < chance then
                            if choice == "RANDOM_RARE_GEM" then
                                local rare_gems = {"strideBead", "treasure_armor", "treasure_bj", "treasure_atk", "treasure_fireGem"}
                                killer.components.hh_player:AddItemsByKey(rare_gems[math.random(#rare_gems)], 1, true)
                            elseif choice == "RANDOM_SUPER_RARE_GEM" then
                                local super_rare = {"elementBead", "baconOmeletteTrueDamage", "baconOmeletteBlessAtk", "baconOmeletteBlessCritical", "baconOmeletteBlessArmor", "baconOmeletteFire", "baconOmeletteSpeed", "baconOmeletteAOE", "baconOmeletteDodge", "baconOmeletteKill"}
                                killer.components.hh_player:AddItemsByKey(super_rare[math.random(#super_rare)], 1, true)
                            elseif choice == "RANDOM_RARE_STONE" or choice == "RANDOM_SUPER_RARE_STONE" then
                                if _G.HHSpawnComEffectStone then
                                    local stone = _G.HHSpawnComEffectStone()
                                    if stone then
                                        if killer.components.inventory then
                                            killer.components.inventory:GiveItem(stone)
                                        else
                                            stone.Transform:SetPosition(killer.Transform:GetWorldPosition())
                                        end
                                    end
                                end
                            else
                                killer.components.hh_player:AddItemsByKey(choice, 1, true)
                            end
                        end
                    end
                    
                    if self.max_waves <= 5 then
                        RollVirtualItem(0.20, "RANDOM_RARE_GEM")
                        RollVirtualItem(0.20, "RANDOM_RARE_STONE")
                    else
                        RollVirtualItem(0.20, "RANDOM_SUPER_RARE_GEM")
                        RollVirtualItem(0.20, "RANDOM_SUPER_RARE_STONE")
                    end
                    
                    RollVirtualItem(0.40, "aa_punchStone")
                    RollVirtualItem(0.40, "ab_decoderStone")
                    RollVirtualItem(0.40, "ac_refreshStone")
                    RollVirtualItem(0.40, "ad_cleanStone")
                end
            end
            
            -- [SINH MẠCH KHOÁNG ROCK_TREASURE]
            local rock_count = (self.max_waves <= 5) and 6 or 12
            local rock_cx, rock_cz = self.dungeon_center_x, self.dungeon_center_z
            for i = 1, rock_count do
                self:TrackLifecycleTask(self.inst:DoTaskInTime(i * 0.5, function()
                    if self.run_epoch ~= run_epoch or not self.is_cleared then
                        return
                    end
                    for attempt = 1, 50 do
                        -- Giới hạn bán kính từ 5 đến 40
                        local dist = 5 + math.random() * 35
                        local angle = math.random() * 2 * PI
                        local rx = rock_cx + math.cos(angle) * dist
                        local rz = rock_cz + math.sin(angle) * dist
                        
                        -- Check 1: Không có vật cản (Rương, Người chơi, Đá khác) trong bán kính 2.5m
                        local obstacles = TheSim:FindEntities(rx, 0, rz, 2.5, nil, {"FX", "NOCLICK", "DECOR", "INANIMATE", "playerghost"})
                        -- Check 2: Địa hình có thể đi lại (Không rớt xuống vực/biển)
                        if #obstacles == 0 and TheWorld.Map:IsPassableAtPoint(rx, 0, rz) then
                            local rock = SpawnPrefab("rock_treasure")
                            if rock then
                                self:TrackRunEntity(rock, run_epoch)
                                rock.Transform:SetPosition(rx, 0, rz)
                                local fx = SpawnPrefab("spawn_fx_medium")
                                if fx then
                                    self:TrackRunEntity(fx, run_epoch)
                                    fx.Transform:SetPosition(rx, 0, rz)
                                end
                                if rock.SoundEmitter then
                                    rock.SoundEmitter:PlaySound("dontstarve/common/spawn/spawn")
                                end
                            end
                            break -- Thành công, thoát vòng lặp thử
                        end
                    end
                end))
            end
            
            TheNet:Announce("Hầm Ngục: BOSS ĐÃ BỊ TIÊU DIỆT ! Tổ đội sẽ được dịch chuyển sau 180 giây...")
            self.is_cleared = true
            self.cleared_end_time = GetTime() + 180
            -- Snapshot before callbacks: only this run's committed members share the clear.
            local completed_players = {}
            for player, member in pairs(self.players_in_dungeon) do
                if member and player:IsValid() and player:HasTag("player") then
                    table.insert(completed_players, player)
                end
            end
            for _, player in ipairs(completed_players) do
                player:PushEvent("hh_dungeon_completed", { run_epoch=run_epoch })
            end
            TheWorld:PushEvent("dungeon_state_changed", {state = "COOLDOWN"})

            self:TrackLifecycleTask(self.inst:DoTaskInTime(DUNGEON_SUCCESS_TIMEOUT, function()
                if self.run_epoch ~= run_epoch or not self.is_cleared then
                    return
                end

                self.cleared_end_time = nil
                local players_to_leave = {}
                for k, v in pairs(self.players_in_dungeon) do
                    if v then table.insert(players_to_leave, k) end
                end
                for _, p in ipairs(players_to_leave) do
                    self:LeaveDungeon(p, "success_timeout")
                end
                if CountPlayers(self.players_in_dungeon) == 0 then
                    self:FinalizeClearedRun()
                end
            end))
        end
    end
end



return DungeonManager
