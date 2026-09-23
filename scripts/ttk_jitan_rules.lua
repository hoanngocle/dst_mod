local defs = require("ttk_jitan_defs")
local TianjiMap = require("ttk_tianjimap")

local M = {}

M.REASONS = {
    BUSY = "Tế Đàn đang có một lượt thử luyện.",
    INVALID_PLAYER = "Người thử luyện không còn ở đây.",
    DEAD = "Không thể mở thử luyện khi đang gục ngã.",
    OFFERING = "Tế Đàn chỉ nhận Trung Phẩm hoặc Thượng Phẩm Linh Thạch.",
    CHEST = "Cần Linh Lung Bảo Sương hợp lệ trong phạm vi 32.",
    GROUND = "Vị trí Tế Đàn không đủ an toàn để sinh boss.",
    INTERIOR = "Không thể mở thử luyện bên trong Thiên Cơ Ốc.",
    DUNGEON = "Không thể mở thử luyện bên trong hầm ngục.",
    OVERLAP = "Một vùng thử luyện khác đang hoạt động quá gần.",
    COUNT = "Mỗi lượt chỉ nhận đúng một lễ vật.",
}

local function Roll(entries, rng, field)
    if entries == nil then return nil end
    local value = (rng or math.random)()
    local total = 0
    for _, entry in ipairs(entries) do
        total = total + entry.chance
        if value < total then return entry[field] end
    end
    return entries[#entries][field]
end

function M.RollScore(offering_prefab, rng)
    return Roll(defs.offerings[offering_prefab], rng, "score")
end

function M.RollGroup(score, rng)
    return Roll(defs.score_groups[score], rng, "group")
end

local function Position(inst)
    if inst == nil or inst.Transform == nil then return nil end
    local x, y, z = inst.Transform:GetWorldPosition()
    return x, y, z
end

function M.ValidateLocation(altar, player)
    local world = TheWorld
    local x, y, z = Position(altar)
    if world == nil or world.Map == nil or x == nil
        or not world.Map:IsPassableAtPoint(x, y, z)
        or (world.Map.IsGroundTargetBlocked ~= nil and world.Map:IsGroundTargetBlocked({ x = x, y = y, z = z }))
        or (world.Map.IsPointNearHole ~= nil and world.Map:IsPointNearHole({ x = x, y = y, z = z }))
    then
        return false, M.REASONS.GROUND
    end

    if TianjiMap.Contains(x, z) ~= nil then
        return false, M.REASONS.INTERIOR
    end

    local manager = world.components ~= nil and world.components.dungeon_manager or nil
    if (manager ~= nil and manager.players_in_dungeon ~= nil and manager.players_in_dungeon[player])
        or (manager ~= nil and manager.IsPointInsideDungeon ~= nil and manager:IsPointInsideDungeon(x, z))
        or (player ~= nil and player.HasTag ~= nil and player:HasTag("hh_dungeon_transition"))
    then
        return false, M.REASONS.DUNGEON
    end

    if TheSim ~= nil and TheSim.FindEntities ~= nil then
        local nearby = TheSim:FindEntities(x, y, z, 128, { "ttk_jitan_active" })
        for _, other in ipairs(nearby) do
            if other ~= altar then return false, M.REASONS.OVERLAP end
        end
    end
    return true
end

return M

