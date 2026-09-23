local defs = require("ttk_jitan_defs")
local native_loot = require("ttk_jitan_loot_tables")

local M = {}

local aliases = {
    xd_lingshi1 = "ttk_lingshi1",
    xd_lingshi2 = "ttk_lingshi2",
    xd_lingshi3 = "ttk_lingshi3",
    xd_lingshi4 = "ttk_lingshi4",
}

-- Encounter ids that use an installed-DST shared loot table. Entries retain
-- every repeated prefab and chance from the cited source table. Bosses whose
-- loot is dynamic or configured outside a complete audited table receive no
-- copied boss-loot bonus; their ordinary death loot remains untouched.
local loot_table_by_encounter = {
    shadow_chess = "shadow_chesspiece",
    celestial_champion = "alterguardian_phase3",
    twins_of_terror = "twinofterror2",
}

for name in pairs(native_loot) do
    loot_table_by_encounter[name] = loot_table_by_encounter[name] or name
end

M.boss_loot = native_loot

function M.Alias(prefab)
    return aliases[prefab] or prefab
end

local function Append(records, prefab, count)
    table.insert(records, { prefab = M.Alias(prefab), count = count or 1 })
end

local function WeightedChoice(entries, rng)
    local total = 0
    for _, entry in ipairs(entries) do total = total + entry.weight end
    local value = rng() * total
    for _, entry in ipairs(entries) do
        if value < entry.weight then return entry end
        value = value - entry.weight
    end
    return entries[#entries]
end

local function RewardTier(score, rng)
    local roll = rng()
    if score > 4 then return roll < .4 and 2 or 3 end
    if score == 4 then return roll > .9 and 3 or (roll > .2 and 2 or 1) end
    return roll < .8 and 1 or 2
end

function M.Roll(score, rng, boss_id)
    rng = rng or math.random
    local records = {}
    local table_name = loot_table_by_encounter[boss_id]
    local snapshot = table_name ~= nil and M.boss_loot[table_name] or nil
    local rounds = rng() > .66 and 2 or 3
    if snapshot ~= nil then
        for _ = 1, rounds do
            local generated = {}
            for _, entry in ipairs(snapshot.entries) do
                if entry.chance >= 1 or rng() <= entry.chance then
                    table.insert(generated, entry.prefab)
                end
            end
            if #generated > 0 then
                local index = math.min(#generated, math.max(1, math.floor(rng() * #generated) + 1))
                Append(records, generated[index], 1)
            end
        end
    end

    local choice = WeightedChoice(defs.reward_pools[RewardTier(score, rng)], rng)
    for _, record in ipairs(choice.records) do Append(records, record.prefab, record.count) end

    if score > 4 then
        if rng() < .15 then Append(records, "ttk_lingshi3") end
        if rng() < .05 then Append(records, "ttk_lingshi4") end
    elseif score == 4 then
        if rng() < .15 then Append(records, "ttk_lingshi3") end
    elseif rng() < .08 then
        Append(records, "ttk_lingshi3")
    end
    return records
end

function M.AllPrefabs()
    local seen, result = {}, {}
    local function Add(prefab)
        prefab = M.Alias(prefab)
        if not seen[prefab] then seen[prefab] = true; table.insert(result, prefab) end
    end
    for _, snapshot in pairs(M.boss_loot) do
        for _, entry in ipairs(snapshot.entries) do Add(entry.prefab) end
    end
    for _, pool in pairs(defs.reward_pools) do
        for _, choice in ipairs(pool) do for _, record in ipairs(choice.records) do Add(record.prefab) end end
    end
    Add("ttk_lingshi3"); Add("ttk_lingshi4")
    table.sort(result)
    return result
end

return M
