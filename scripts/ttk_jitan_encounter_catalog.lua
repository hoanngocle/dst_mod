local M = {}

local entries = {}
local by_id = {}

local function Spawn(prefab, required, count, treasure_id)
    return {
        prefab = prefab,
        count = count or 1,
        required = required ~= false,
        treasure_id = treasure_id,
    }
end

local function Add(id, group, source, spawns, opts)
    opts = opts or {}
    local entry = {
        id = id,
        group = group,
        source = source,
        spawns = spawns,
        adapter = opts.adapter,
        lifecycle = opts.lifecycle,
        dependencies = opts.dependencies or {},
        required_prefabs = opts.required_prefabs or {},
        position_kind = opts.position_kind or "land",
        treasure_id = opts.treasure_id,
        world_state = opts.world_state,
    }
    entries[#entries + 1] = entry
    by_id[id] = entry
end

-- Native Survival encounters. Multi-phase and paired fights are one record.
Add("minotaur", 1, "native", { Spawn("minotaur") }, { adapter = "minotaur" })
Add("antlion", 2, "native", { Spawn("antlion") }, { adapter = "antlion" })
Add("bearger", 1, "native", { Spawn("bearger") })
Add("mutatedbearger", 2, "native", { Spawn("mutatedbearger") })
Add("beequeen", 2, "native", { Spawn("beequeen") })
Add("celestial_champion", 3, "native", { Spawn("alterguardian_phase1") }, {
    lifecycle = "phase_chain",
    required_prefabs = { "alterguardian_phase2", "alterguardian_phase3" },
})
Add("alterguardian_phase1_lunarrift", 3, "native", {
    Spawn("alterguardian_phase1_lunarrift"),
}, { lifecycle = "lunar_capture" })
Add("alterguardian_phase4_lunarrift", 3, "native", {
    Spawn("alterguardian_phase4_lunarrift"),
})
Add("crabking", 3, "native", { Spawn("crabking") }, {
    adapter = "crabking",
    position_kind = "ocean",
    required_prefabs = {
        "redgem", "bluegem", "purplegem", "orangegem", "yellowgem", "greengem",
    },
})
Add("deerclops", 1, "native", { Spawn("deerclops") }, { world_state = { iswinter = true } })
Add("mutateddeerclops", 2, "native", { Spawn("mutateddeerclops") }, { world_state = { iswinter = true } })
Add("dragonfly", 1, "native", { Spawn("dragonfly") }, { adapter = "dragonfly" })
Add("eyeofterror", 2, "native", { Spawn("eyeofterror") }, { adapter = "spawnpoint" })
Add("twins_of_terror", 3, "native", { Spawn("twinmanager", false) }, {
    adapter = "twins",
    lifecycle = "twins",
    required_prefabs = { "twinofterror1", "twinofterror2" },
})
Add("klaus", 3, "native", { Spawn("klaus") }, {
    adapter = "klaus",
    required_prefabs = { "deer_red", "deer_blue" },
})
Add("lordfruitfly", 1, "native", { Spawn("lordfruitfly") })
Add("malbatross", 2, "native", { Spawn("malbatross") }, {
    adapter = "home",
    position_kind = "water_adjacent",
})
Add("moose", 1, "native", { Spawn("moose") }, {
    adapter = "moose", world_state = { isspring = true, iscave = false },
})
Add("daywalker", 2, "native", { Spawn("daywalker") })
Add("daywalker2", 3, "native", { Spawn("daywalker2") }, { adapter = "target_owner" })
Add("shadow_chess", 3, "native", {
    Spawn("shadow_knight"), Spawn("shadow_bishop"), Spawn("shadow_rook"),
})
Add("sharkboi", 2, "native", { Spawn("sharkboi") })
Add("spiderqueen", 1, "native", { Spawn("spiderqueen", true, 3) })
Add("toadstool", 2, "native", { Spawn("toadstool") }, { adapter = "toadstool" })
Add("toadstool_dark", 3, "native", { Spawn("toadstool_dark") }, { adapter = "toadstool" })
Add("stalker", 2, "native", { Spawn("stalker") })
Add("stalker_atrium", 3, "native", { Spawn("stalker_atrium") }, { adapter = "fuelweaver" })
Add("leif", 1, "native", { Spawn("leif") })
Add("leif_sparse", 1, "native", { Spawn("leif_sparse") })
Add("fruitdragon", 1, "native", { Spawn("fruitdragon") }, { adapter = "target_owner" })
Add("warg", 1, "native", { Spawn("warg") })
Add("claywarg", 1, "native", { Spawn("claywarg") })
Add("gingerbreadwarg", 1, "native", { Spawn("gingerbreadwarg") })
Add("mutatedwarg", 2, "native", { Spawn("mutatedwarg", true, 2) })
Add("wagboss_robot", 3, "native", { Spawn("wagboss_robot") }, { adapter = "wagboss_robot" })
Add("worm_boss", 3, "native", { Spawn("worm_boss") }, { adapter = "worm_boss" })
Add("vault_pillar_guard", 3, "native", { Spawn("vault_pillar_guard") }, { adapter = "spawnpoint" })

-- Existing authored elite encounter retained for compatibility with the old pool.
Add("shadow_thralls", 2, "legacy", {
    Spawn("shadowthrall_horns"), Spawn("shadowthrall_hands"), Spawn("shadowthrall_wings"),
})

-- Historical Solo Leveling provenance. In Phàm Nhân 2.0 this flag reports the
-- availability of the integrated subsystem; it is not a Workshop-mod check.
local SOLO = { "solo_leveling" }

-- Direct prefabs owned by Solo Leveling. These records are runtime-gated.
Add("solo_minotau", 3, "solo", { Spawn("minotau") }, { dependencies = SOLO })
Add("solo_hh_sharkboi", 3, "solo", { Spawn("hh_sharkboi") }, { dependencies = SOLO })
Add("solo_hh_beetle_pig", 2, "solo", { Spawn("hh_beetle_pig") }, { dependencies = SOLO })
Add("solo_hh_dual_wield_pig", 2, "solo", { Spawn("hh_dual_wield_pig") }, { dependencies = SOLO })
Add("solo_hh_igris_dungeon", 3, "solo", { Spawn("hh_igris_dungeon") }, { dependencies = SOLO })
Add("solo_hh_beru_dungeon", 3, "solo", { Spawn("hh_beru_dungeon") }, { dependencies = SOLO })

local function Treasure(id, group, prefab, treasure_id, opts)
    opts = opts or {}
    opts.dependencies = SOLO
    opts.adapter = opts.adapter or "treasure"
    opts.treasure_id = treasure_id
    Add(id, group, "solo_treasure", { Spawn(prefab, true, 1, treasure_id) }, opts)
end

Treasure("solo_mutateddeerclops_boss", 3, "mutateddeerclops", "mutateddeerclops_boss", {
    world_state = { iswinter = true },
})
Treasure("solo_mutatedbearger_boss", 3, "mutatedbearger", "mutatedbearger_boss")
Treasure("solo_mutatedwarg_boss", 3, "mutatedwarg", "mutatedwarg_boss")
Treasure("solo_hh_sharkboi_boss", 3, "hh_sharkboi", "hh_sharkboi_boss")
Treasure("solo_walrus_adc", 2, "walrus", "walrus_adc")
Treasure("solo_treasure_kps", 3, "krampus", "treasure_kps", {
    adapter = "treasure_krampus",
    required_prefabs = { "pigman" },
})
Treasure("solo_treasure_cat_you", 3, "catcoon", "treasure_cat_you")

function M.GetEntries()
    return entries
end

function M.GetById(id)
    return by_id[id]
end

return M
