-- Pure trial data adapted from Tu Tien 19.7. Runtime behavior lives in later modules.
local M = {}

M.offerings = {
    ttk_lingshi2 = {
        { score = 2, chance = 0.35 },
        { score = 3, chance = 0.35 },
        { score = 4, chance = 0.30 },
    },
    ttk_lingshi3 = {
        { score = 4, chance = 0.10 },
        { score = 5, chance = 0.45 },
        { score = 6, chance = 0.45 },
    },
}

M.score_groups = {
    [2] = { { group = 1, chance = 1.00 } },
    [3] = { { group = 1, chance = 0.50 }, { group = 2, chance = 0.50 } },
    [4] = {
        { group = 1, chance = 0.34 },
        { group = 3, chance = 0.33 },
        { group = 2, chance = 0.33 },
    },
    [5] = { { group = 2, chance = 0.50 }, { group = 3, chance = 0.50 } },
    [6] = { { group = 3, chance = 1.00 } },
}

local function Single(id, prefab, count)
    return { id = id, spawns = { { prefab = prefab, count = count or 1 } } }
end

M.boss_pools = {
    [1] = {
        Single("spiderqueen", "spiderqueen", 3),
        Single("minotaur", "minotaur"),
        Single("bearger", "bearger"),
        Single("deerclops", "deerclops"),
        Single("dragonfly", "dragonfly"),
    },
    [2] = {
        Single("sharkboi", "sharkboi"),
        Single("mutatedbearger", "mutatedbearger"),
        Single("beequeen", "beequeen"),
        Single("daywalker", "daywalker"),
        {
            id = "shadow_thralls",
            spawns = {
                { prefab = "shadowthrall_horns", count = 1 },
                { prefab = "shadowthrall_hands", count = 1 },
                { prefab = "shadowthrall_wings", count = 1 },
            },
        },
        Single("alterguardian_phase3", "alterguardian_phase3"),
        Single("mutateddeerclops", "mutateddeerclops"),
        Single("mutatedwarg", "mutatedwarg", 2),
    },
    [3] = {
        Single("klaus", "klaus"),
        {
            id = "shadow_chess",
            spawns = {
                { prefab = "shadow_knight", count = 1 },
                { prefab = "shadow_bishop", count = 1 },
                { prefab = "shadow_rook", count = 1 },
            },
        },
    },
}

local function Reward(weight, records)
    return { weight = weight, records = records }
end
local function Item(prefab, count)
    return { prefab = prefab, count = count or 1 }
end

M.reward_pools = {
    [1] = {
        Reward(1.0, { Item("perogies", 8), Item("dragonpie", 8) }),
        Reward(1.0, { Item("armormarble", 5) }),
        Reward(1.0, { Item("armorruins", 5) }),
        Reward(1.0, { Item("nightsword", 10) }),
        Reward(0.5, { Item("amulet", 4) }),
        Reward(1.0, { Item("armorsnurtleshell", 5) }),
    },
    [2] = {
        Reward(1.0, { Item("jellybean_spice_chili"), Item("voltgoatjelly") }),
        Reward(1.0, { Item("voltgoatjelly", 4) }),
        Reward(0.2, { Item("armorskeleton"), Item("hivehat", 3), Item("panflute"), Item("alterguardianhat") }),
        Reward(1.0, { Item("armor_sanity", 7) }),
        Reward(1.0, { Item("ruinshat", 7) }),
    },
    [3] = {
        Reward(0.2, { Item("armordreadstone"), Item("dreadstonehat") }),
        Reward(1.0, { Item("lunarplant_kit", 3) }),
        Reward(0.2, { Item("lunarplanthat"), Item("armor_lunarplant"), Item("lunarplant_kit", 2) }),
        Reward(0.2, { Item("armor_voidcloth"), Item("voidclothhat"), Item("voidcloth_kit", 2) }),
        Reward(1.0, { Item("voidcloth_kit", 3) }),
        Reward(0.15, { Item("armorwagpunk"), Item("wagpunkhat"), Item("wagpunkbits_kit", 2) }),
        Reward(0.75, { Item("wagpunkbits_kit", 3) }),
    },
}

M.recipe_ingredients = {
    ttk_jitan = {
        { prefab = "cutstone", count = 12 },
        { prefab = "goldnugget", count = 6 },
        { prefab = "ttk_lingshi3", count = 2 },
    },
    ttk_llbx = {
        { prefab = "boards", count = 6 },
        { prefab = "goldnugget", count = 4 },
        { prefab = "ttk_lingshi3", count = 1 },
    },
}

return M
