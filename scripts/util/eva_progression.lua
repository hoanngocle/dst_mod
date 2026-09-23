local Progression = {}
local LEVELS = {fox = 1, wave = 1, life = 10, harvest = 20, wings = 30, daydu = 50, array = 100}

function Progression.RequiredLevel(skill)
    return LEVELS[skill]
end

function Progression.GetLevel(player)
    if player == nil then return 1 end
    if TheWorld == nil or TheWorld.ismastersim then
        local souls = player.components ~= nil and player.components.eva_souls or nil
        return souls ~= nil and souls.level or 1
    end
    return player.eva_level ~= nil and math.max(1, player.eva_level:value()) or 1
end

function Progression.IsUnlocked(player, skill)
    local required = LEVELS[skill]
    return required ~= nil and Progression.GetLevel(player) >= required
end

function Progression.Check(player, skill)
    if Progression.IsUnlocked(player, skill) then return true end
    local talker = player ~= nil and player.components ~= nil and player.components.talker or nil
    if talker ~= nil then
        talker:Say("Kỹ năng mở ở cấp EVA " .. tostring(LEVELS[skill]) .. ".")
    end
    return false, "level_locked"
end

return Progression
