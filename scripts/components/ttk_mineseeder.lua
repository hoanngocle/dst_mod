-- Seed on the surface after entities load, including existing worlds.
-- Persist the last processed season to avoid another batch on every restart.
local Seeder = Class(function(self, inst)
    self.inst = inst
    self.ready = false
    -- Closure also makes the callback independent of component-add ordering.
    inst:WatchWorldState("season", function(_, season)
        if self.ready then self:CheckSeason(season) end
    end)
    inst:DoTaskInTime(1, function()
        self.ready = true
        self:CheckSeason(inst.state.season)
    end)
end)

function Seeder:CheckSeason(season)
    if season == nil or self.season == season then return end
    local initial = self.season == nil
    self.season = season
    self:Seed(initial)
end

local function GetRegions()
    local rocky, other = {}, {}
    local topology = TheWorld.topology or {}
    for i, node in ipairs(topology.nodes or {}) do
        local id = string.lower((topology.ids and topology.ids[i]) or "")
        -- Surface mainland only: exclude special islands and ocean nodes.
        if node.x and node.y and not string.find(id, "moon")
            and not string.find(id, "island") and not string.find(id, "ocean")
            and TheWorld.Map:IsAboveGroundAtPoint(node.x, 0, node.y) then
            local list = (string.find(id, "rocky") or string.find(id, "dig that rock")) and rocky or other
            table.insert(list, node)
        end
    end
    return rocky, other
end

local function FreePoint(node)
    local angle = math.random() * 2 * math.pi
    local radius = 24 * math.sqrt(math.random())
    local x, z = node.x + radius * math.cos(angle), node.y + radius * math.sin(angle)
    local map = TheWorld.Map
    if not map:IsAboveGroundAtPoint(x, 0, z) or not map:IsPassableAtPoint(x, 0, z)
        or map:IsPointNearHole(Vector3(x, 0, z)) then return end
    -- Leave bases, portals and active players a generous clearance.
    if #TheSim:FindEntities(x, 0, z, 12, nil, {"INLIMBO"},
        {"structure", "multiplayer_portal", "player"}) > 0 then return end
    if #TheSim:FindEntities(x, 0, z, 4, nil, {"INLIMBO", "FX", "DECOR", "NOCLICK"}) > 0 then return end
    return x, z
end

function Seeder:Seed(initial)
    local rocky, scattered = GetRegions()
    if #rocky == 0 then rocky = scattered end
    if #scattered == 0 then scattered = rocky end
    if #rocky == 0 then
        print("[TuTienKy] No safe surface regions for spirit mines.")
        return
    end
    local count = initial and 24 or 12
    -- Each 12: 8 common, 3 rare, 1 supreme. Interleave rarities across locations.
    local tiers = {1, 1, 2, 1, 1, 2, 1, 3, 1, 2, 1, 1}
    for i = #tiers, 2, -1 do
        local j = math.random(i)
        tiers[i], tiers[j] = tiers[j], tiers[i]
    end
    local placed = 0
    for i = 1, count do
        local regions = i % 3 == 0 and scattered or rocky
        for attempt = 1, 80 do
            local node = regions[math.random(#regions)]
            local x, z = FreePoint(node)
            if x then
                local mine = SpawnPrefab("ttk_rock" .. tiers[(i - 1) % 12 + 1])
                if mine then
                    mine.Transform:SetPosition(x, 0, z)
                    placed = placed + 1
                end
                break
            end
        end
    end
    print(string.format("[TuTienKy] Spirit mines: %d/%d new natural mines (%s).", placed, count, self.inst.state.season or "unknown"))
end

function Seeder:OnSave()
    return {season = self.season}
end

function Seeder:OnLoad(data)
    self.season = data and data.season or nil
end

return Seeder
