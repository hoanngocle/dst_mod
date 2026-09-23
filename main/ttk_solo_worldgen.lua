-- Solo Leveling Mod World Generation
--
-- The Dungeon ARENA is generated as part of the Forest map.  The map is
-- expanded once during world generation so the playable arena can live in a
-- physically isolated region without introducing a shard, cave, dimension,
-- or runtime terrain mutation.
GLOBAL.setmetatable(
    env,
    {
        __index = function(_, key)
            return GLOBAL.rawget(GLOBAL, key)
        end,
    }
)

local _G = GLOBAL
local require = _G.require

local forest_map = require("map/forest_map")
local blueprints = require("dungeon_blueprints")
local base64 = require("lib/base64")

local TILE_SIZE = _G.TILE_SCALE or 4
local MAP_HEADER_PREFIX = "VlJTTgABAAAA"
local MAP_HEADER_RAW = base64.decode(MAP_HEADER_PREFIX)
local MAP_HEADER_BYTES = #MAP_HEADER_RAW
local MAP_DATA_START_BYTE = MAP_HEADER_BYTES + 1

if MAP_HEADER_BYTES ~= 9 then
    error("Solo Leveling: unexpected encoded-map header length", 0)
end

-- These values describe the reserved map geometry, not Dungeon gameplay.
-- The gameplay footprint remains entirely defined by dungeon_blueprints.lua.
local ARENA_VOID_PADDING_TILES = 10
local ARENA_EDGE_MARGIN_TILES = 4
local ARENA_ISOLATION_GAP_TILES = 16

if not _G.WORLD_TILES.SOLO_ARENA_LAVA then
    AddTile(
        "SOLO_ARENA_LAVA",
        "NOISE",
        { ground_name = "Lava Arena" },
        {
            name = "rocky",
            noise_texture = "levels/textures/lavaarena_floor_noise.tex",
            runsound = "dontstarve/movement/run_dirt",
            walksound = "dontstarve/movement/walk_dirt",
            colors = {
                primary_color =         {0,  0,  0,  25},
                secondary_color =       {0,  20, 33, 0},
                secondary_color_dusk =  {0,  20, 33, 80},
                minimap_color =         {80, 20, 20, 255},
            },
            hard = true,
            cannotbedug = true,
        },
        {
            name = "map_edge",
            noise_texture = "levels/textures/lavaarena_floor_noise.tex",
        }
    )
end

local function EncodeU16(values)
    local chunks = {}
    for i = 1, #values do
        local value = values[i] or 0
        if type(value) ~= "number" or value < 0 or value > 0xFFFF
            or value ~= math.floor(value) then
            error("Solo Leveling: node id is outside the U16 range", 0)
        end
        chunks[#chunks + 1] = string.char(value % 256, math.floor(value / 256))
    end
    return MAP_HEADER_PREFIX .. base64.encode(table.concat(chunks))
end

local function DecodeU16(encoded)
    if encoded == nil then
        return {}
    end

    if encoded:sub(1, #MAP_HEADER_PREFIX) ~= MAP_HEADER_PREFIX then
        error("Solo Leveling: encoded map is missing the expected prefix", 0)
    end
    local decoded = base64.decode(encoded)
    if decoded:sub(1, MAP_HEADER_BYTES) ~= MAP_HEADER_RAW then
        error("Solo Leveling: encoded map has an unexpected header", 0)
    end

    local payload_bytes = #decoded - MAP_HEADER_BYTES
    if payload_bytes % 2 ~= 0 then
        error("Solo Leveling: encoded U16 map payload has an odd byte count", 0)
    end

    local values = {}
    for i = MAP_DATA_START_BYTE, #decoded, 2 do
        local lo = decoded:byte(i)
        local hi = decoded:byte(i + 1)
        values[#values + 1] = lo + hi * 0x100
    end
    return values
end

local function GetBlueprintDimensions(layout)
    if type(layout) ~= "table" or #layout == 0 or type(layout[1]) ~= "string" then
        error("Solo Leveling: dungeon arena blueprint is empty", 0)
    end

    local width = #layout[1]
    if width == 0 then
        error("Solo Leveling: dungeon arena blueprint has zero width", 0)
    end
    for row, line in ipairs(layout) do
        if type(line) ~= "string" or #line ~= width then
            error("Solo Leveling: dungeon arena blueprint rows have inconsistent widths", 0)
        end
    end
    return width, #layout
end

local function PickBlueprint()
    local keys = {}
    for key in pairs(blueprints) do
        keys[#keys + 1] = key
    end
    table.sort(keys)
    return blueprints[keys[math.random(1, #keys)]]
end

local function EnsureEntityList(entities, prefab)
    if entities[prefab] == nil then
        entities[prefab] = {}
    end
    return entities[prefab]
end

local function ShiftTopology(topology, shift_x, shift_z)
    if topology == nil or topology.nodes == nil then
        return
    end

    for _, node in ipairs(topology.nodes) do
        node.x = (node.x or 0) - shift_x
        node.y = (node.y or 0) - shift_z

        if node.cent ~= nil then
            node.cent[1] = node.cent[1] - shift_x
            node.cent[2] = node.cent[2] - shift_z
        end

        if node.poly ~= nil then
            for _, point in ipairs(node.poly) do
                point[1] = point[1] - shift_x
                point[2] = point[2] - shift_z
            end
        end
    end
end

local function ShiftEntities(entities, shift_x, shift_z)
    for _, prefab_entities in pairs(entities or {}) do
        for _, entity in ipairs(prefab_entities) do
            if entity.x ~= nil then
                entity.x = entity.x - shift_x
            end
            if entity.z ~= nil then
                entity.z = entity.z - shift_z
            end
        end
    end
end

local function ShiftRoads(roads, shift_x, shift_z)
    for _, road in pairs(roads or {}) do
        for _, point in ipairs(road) do
            -- forest_map stores the road weight as the first table entry
            -- ({road_weight}); only coordinate pairs should be shifted.
            if type(point) == "table" and point[1] ~= nil and point[2] ~= nil then
                point[1] = point[1] - shift_x
                point[2] = point[2] - shift_z
            end
        end
    end
end

local function AddArenaTopology(topology, min_x, min_z, span_x, span_z)
    topology.ids = topology.ids or {}
    topology.story_depths = topology.story_depths or {}
    topology.nodes = topology.nodes or {}

    local node_id = #topology.nodes + 1
    local max_x = min_x + span_x
    local max_z = min_z + span_z
    local center_x = min_x + span_x / 2
    local center_z = min_z + span_z / 2

    topology.ids[node_id] = "SoloLeveling:DungeonArena"
    topology.story_depths[node_id] = 0
    topology.nodes[node_id] = {
        area = span_x * span_z,
        c = 1,
        cent = {center_x, center_z},
        neighbours = {},
        poly = {
            {min_x, min_z},
            {max_x, min_z},
            {max_x, max_z},
            {min_x, max_z},
        },
        tags = {
            "ForceDisconnected",
            "RoadPoison",
            "not_mainland",
            "solo_dungeon_arena",
            "nocavein",
            "noquaker",
        },
        type = _G.NODE_TYPE and _G.NODE_TYPE.Default or 0,
        validedges = {},
        x = center_x,
        y = center_z,
    }

    return node_id
end

local function AddArenaToWorldSim(worldsim, generated, layout, old_width, old_height, new_width, new_height)
    local layout_width, layout_height = GetBlueprintDimensions(layout)
    local offset_x = math.floor(layout_width / 2)
    local offset_z = math.floor(layout_height / 2)

    local reserved_span_x = layout_width + 2 * (ARENA_VOID_PADDING_TILES + ARENA_EDGE_MARGIN_TILES)
    local reserved_span_z = layout_height + 2 * (ARENA_VOID_PADDING_TILES + ARENA_EDGE_MARGIN_TILES)

    local arena_origin_x = old_width + ARENA_ISOLATION_GAP_TILES
        + ARENA_EDGE_MARGIN_TILES + ARENA_VOID_PADDING_TILES
    local arena_origin_z = old_height + ARENA_ISOLATION_GAP_TILES
        + ARENA_EDGE_MARGIN_TILES + ARENA_VOID_PADDING_TILES

    local reserved_min_x = arena_origin_x - ARENA_VOID_PADDING_TILES - ARENA_EDGE_MARGIN_TILES
    local reserved_min_z = arena_origin_z - ARENA_VOID_PADDING_TILES - ARENA_EDGE_MARGIN_TILES

    local arena_node_id = AddArenaTopology(
        generated.map.topology,
        (reserved_min_x - new_width / 2) * TILE_SIZE,
        (reserved_min_z - new_height / 2) * TILE_SIZE,
        reserved_span_x * TILE_SIZE,
        reserved_span_z * TILE_SIZE
    )

    for ty = reserved_min_z, reserved_min_z + reserved_span_z - 1 do
        for tx = reserved_min_x, reserved_min_x + reserved_span_x - 1 do
            worldsim:SetTileNodeId(tx, ty, arena_node_id)
        end
    end

    -- Terrain cells use a zero-based origin, while blueprint rows/columns are
    -- addressed from 1. Keep blueprint cell (1, 1) on terrain cell
    -- (arena_origin_x, arena_origin_z) so generated entities share the exact
    -- same tile centers as the layout and GetTileChar mapping.
    local center_world_x = (arena_origin_x + offset_x - 1 - new_width / 2) * TILE_SIZE
    local center_world_z = (arena_origin_z + offset_z - 1 - new_height / 2) * TILE_SIZE
    local lava_tile = _G.WORLD_TILES.SOLO_ARENA_LAVA
    local impassable_tile = _G.WORLD_TILES.IMPASSABLE

    for row = -ARENA_VOID_PADDING_TILES - ARENA_EDGE_MARGIN_TILES,
        layout_height + ARENA_VOID_PADDING_TILES + ARENA_EDGE_MARGIN_TILES - 1 do
        for col = -ARENA_VOID_PADDING_TILES - ARENA_EDGE_MARGIN_TILES,
            layout_width + ARENA_VOID_PADDING_TILES + ARENA_EDGE_MARGIN_TILES - 1 do
            local tx = arena_origin_x + col
            local ty = arena_origin_z + row
            local char = " "
            if row >= 0 and row < layout_height and col >= 0 and col < layout_width then
                char = string.sub(layout[row + 1], col + 1, col + 1)
            end
            worldsim:SetTile(tx, ty, char ~= " " and lava_tile or impassable_tile)
        end
    end

    local function InReservedBounds(x, z)
        return x >= reserved_min_x and x < reserved_min_x + reserved_span_x
            and z >= reserved_min_z and z < reserved_min_z + reserved_span_z
    end

    -- The expanded area is empty by construction, but filtering the first
    -- generation result keeps the invariant true if another worldgen step
    -- placed an entity there before this wrapper runs.
    for prefab, prefab_entities in pairs(generated.ents or {}) do
        local kept = {}
        for _, entity in ipairs(prefab_entities) do
            if entity.x == nil or entity.z == nil or not InReservedBounds(
                math.floor(entity.x / TILE_SIZE + new_width / 2),
                math.floor(entity.z / TILE_SIZE + new_height / 2)
            ) then
                kept[#kept + 1] = entity
            end
        end
        generated.ents[prefab] = kept
    end

    local function BlueprintCellToWorld(col, row)
        return center_world_x + (col - offset_x) * TILE_SIZE,
            center_world_z + (row - offset_z) * TILE_SIZE
    end

    local function AddEntity(prefab, col, row)
        local list = EnsureEntityList(generated.ents, prefab)
        local x, z = BlueprintCellToWorld(col, row)
        list[#list + 1] = {
            x = x,
            z = z,
        }
    end

    for row = 1, layout_height do
        local line = layout[row]
        for col = 1, layout_width do
            local char = string.sub(line, col, col)
            if char == "X" then
                AddEntity("pillar_ruins", col, row)
            elseif char == "E" then
                AddEntity("dungeon_exit", col, row)
            elseif char == "A" then
                AddEntity("hh_arena_lava_pond", col, row)
            elseif char == "S" then
                AddEntity("hh_decor_scorched_skeleton", col, row)
            elseif char == "D" then
                AddEntity("hh_decor_skeleton_pig", col, row)
            elseif char == "F" then
                AddEntity("hh_decor_skeleton_merm", col, row)
            end
        end
    end

    local function GetTileChar(world_x, world_z)
        local col = math.floor((world_x - center_world_x + 2) / TILE_SIZE) + offset_x
        local row = math.floor((world_z - center_world_z + 2) / TILE_SIZE) + offset_z
        if row >= 1 and row <= layout_height and col >= 1 and col <= layout_width then
            return string.sub(layout[row], col, col)
        end
        return " "
    end

    local walls = EnsureEntityList(generated.ents, "dungeon_wall_ruins")
    local min_world_x = center_world_x - offset_x * TILE_SIZE - TILE_SIZE
    local max_world_x = center_world_x + (layout_width - offset_x) * TILE_SIZE + TILE_SIZE
    local min_world_z = center_world_z - offset_z * TILE_SIZE - TILE_SIZE
    local max_world_z = center_world_z + (layout_height - offset_z) * TILE_SIZE + TILE_SIZE

    for world_x = min_world_x + 0.5, max_world_x - 0.5, 1 do
        for world_z = min_world_z + 0.5, max_world_z - 0.5, 1 do
            if GetTileChar(world_x, world_z) == " " then
                local touches_wall = false
                for dx = -1, 1 do
                    for dz = -1, 1 do
                        if (dx ~= 0 or dz ~= 0)
                            and GetTileChar(world_x + dx, world_z + dz) == "W" then
                            touches_wall = true
                            break
                        end
                    end
                    if touches_wall then
                        break
                    end
                end
                if touches_wall then
                    walls[#walls + 1] = {x = world_x, z = world_z}
                end
            end
        end
    end

    return arena_node_id, reserved_min_x, reserved_min_z, reserved_span_x, reserved_span_z
end

local old_Generate = forest_map.Generate
forest_map.Generate = function(name, ...)
    local generated = old_Generate(name, ...)

    if generated == nil or name ~= "forest" then
        return generated
    end

    local old_width = generated.map.width
    local old_height = generated.map.height
    if old_width == nil or old_height == nil or old_width ~= old_height then
        error("Solo Leveling: Forest WorldSim map must be square for ConvertToTileMap", 0)
    end
    generated.ents = generated.ents or {}
    generated.map.roads = generated.map.roads or {}
    local old_tiles = DecodeU16(generated.map.tiles)
    local old_nodeids = DecodeU16(generated.map.nodeidtilemap)
    local layout = PickBlueprint()
    local layout_width, layout_height = GetBlueprintDimensions(layout)

    if #old_tiles ~= old_width * old_height then
        error("Solo Leveling: encoded tile count does not match the source map", 0)
    end
    if #old_nodeids ~= old_width * old_height then
        error("Solo Leveling: encoded node-id count does not match the source map", 0)
    end

    local reserved_span_x = layout_width + 2 * (ARENA_VOID_PADDING_TILES + ARENA_EDGE_MARGIN_TILES)
    local reserved_span_z = layout_height + 2 * (ARENA_VOID_PADDING_TILES + ARENA_EDGE_MARGIN_TILES)
    -- The reserved region starts at old_width + ARENA_ISOLATION_GAP_TILES
    -- and occupies reserved_span_* tiles.  A second isolation gap after the
    -- region was never addressed by topology, terrain, or entity placement;
    -- it only extended the outer IMPASSABLE map edge.
    local expanded_width = old_width + ARENA_ISOLATION_GAP_TILES + reserved_span_x
    local expanded_height = old_height + ARENA_ISOLATION_GAP_TILES + reserved_span_z
    -- Vanilla Forest calls ConvertToTileMap(size), so the final WorldSim
    -- surface is square.  A rectangular blueprint is valid; the shorter
    -- axis receives the remaining reserved padding.
    local new_size = math.max(expanded_width, expanded_height)
    local new_width = new_size
    local new_height = new_size
    if new_width ~= new_height then
        error("Solo Leveling: expanded Forest map dimensions are not square", 0)
    end
    local shift_x = (new_width - old_width) / 2 * TILE_SIZE
    local shift_z = (new_height - old_height) / 2 * TILE_SIZE

    ShiftTopology(generated.map.topology, shift_x, shift_z)
    ShiftEntities(generated.ents, shift_x, shift_z)
    ShiftRoads(generated.map.roads, shift_x, shift_z)

    local nodeid_values = {}
    for ty = 0, new_height - 1 do
        for tx = 0, new_width - 1 do
            local index = new_width * ty + tx + 1
            if tx < old_width and ty < old_height then
                nodeid_values[index] = old_nodeids[old_width * ty + tx + 1] or 0
            else
                nodeid_values[index] = 0
            end
        end
    end

    local worldsim = _G.WorldSim
    if worldsim == nil then
        error("Solo Leveling: WorldSim is unavailable during Forest generation", 0)
    end
    worldsim:ResetAll()

    local worldsim_metatable = getmetatable(worldsim)
    local worldsim_meta = worldsim_metatable ~= nil and worldsim_metatable.__index or nil
    if type(worldsim_meta) ~= "table" then
        error("Solo Leveling: WorldSim metatable is unavailable", 0)
    end
    local old_convert_to_tile_map = worldsim_meta.ConvertToTileMap
    local old_get_encoded_map = worldsim_meta.GetEncodedMap
    if type(old_convert_to_tile_map) ~= "function" or type(old_get_encoded_map) ~= "function" then
        error("Solo Leveling: WorldSim map methods are unavailable", 0)
    end
    local arena_applied = false
    local arena_node_id = nil

    local function RestoreWorldSimHooks()
        worldsim_meta.GetEncodedMap = old_get_encoded_map
        worldsim_meta.ConvertToTileMap = old_convert_to_tile_map
    end

    local install_ok, install_error = pcall(function()
        worldsim_meta.ConvertToTileMap = function(self, _)
            return old_convert_to_tile_map(self, new_width)
        end

        worldsim_meta.GetEncodedMap = function(self, shared_string)
            for ty = 0, new_height - 1 do
                for tx = 0, new_width - 1 do
                    local tile = _G.WORLD_TILES.IMPASSABLE
                    if tx < old_width and ty < old_height then
                        tile = old_tiles[old_width * ty + tx + 1] or tile
                    end
                    self:SetTile(tx, ty, tile)
                end
            end

            if not arena_applied then
                arena_applied = true
                arena_node_id = AddArenaToWorldSim(
                    self,
                    generated,
                    layout,
                    old_width,
                    old_height,
                    new_width,
                    new_height
                )

                local arena_origin_x = old_width + ARENA_ISOLATION_GAP_TILES
                    + ARENA_EDGE_MARGIN_TILES + ARENA_VOID_PADDING_TILES
                local arena_origin_z = old_height + ARENA_ISOLATION_GAP_TILES
                    + ARENA_EDGE_MARGIN_TILES + ARENA_VOID_PADDING_TILES
                local min_x = arena_origin_x - ARENA_VOID_PADDING_TILES - ARENA_EDGE_MARGIN_TILES
                local min_z = arena_origin_z - ARENA_VOID_PADDING_TILES - ARENA_EDGE_MARGIN_TILES
                for ty = min_z, min_z + reserved_span_z - 1 do
                    for tx = min_x, min_x + reserved_span_x - 1 do
                        nodeid_values[new_width * ty + tx + 1] = arena_node_id
                    end
                end
            end

            return old_get_encoded_map(self, shared_string)
        end
    end)

    if not install_ok then
        local restore_ok, restore_error = pcall(RestoreWorldSimHooks)
        if not restore_ok then
            error(restore_error, 0)
        end
        error(install_error, 0)
    end

    local ok_second, regenerated = pcall(old_Generate, name, ...)
    local restore_ok, restore_error = pcall(RestoreWorldSimHooks)
    if not restore_ok then
        error(restore_error, 0)
    end

    if not ok_second then
        error(regenerated, 0)
    end
    if regenerated == nil then
        return nil
    end

    generated.map.tiles = regenerated.map.tiles
    generated.map.tiledata = regenerated.map.tiledata
    generated.map.nav = regenerated.map.nav
    generated.map.adj = regenerated.map.adj
    generated.map.world_tile_map = regenerated.map.world_tile_map
    generated.map.nodeidtilemap = EncodeU16(nodeid_values)
    generated.map.width = new_width
    generated.map.height = new_height

    return generated
end
