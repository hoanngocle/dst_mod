-- Smarter Ice Flingomatic (1845106626), v1.3.0, by 辣椒小皇纸.
-- Always enabled. Keep vanilla fuel capacity (the source's default x1).
local tuning = GLOBAL.TUNING
tuning.EMERGENCY_BURNT_NUMBER = 1
tuning.EMERGENCY_BURNING_NUMBER = 1
tuning.EMERGENCY_WARNING_TIME = 1
tuning.EMERGENCY_RESPONSE_TIME = 3
tuning.EMERGENCY_SHUT_OFF_TIME = 30

-- Preserve the source's exclusion mechanism: fire detectors ignore "burnt".
-- Register optional prefabs by name so local ports work without Workshop IDs.
local protected_fires = {
    "campfire",
    "firepit",
    "coldfire",
    "coldfirepit",
    "nightlight",
    "pigtorch",
    -- Deluxe Campfires / Vinh Hang Than Hoa.
    "deluxe_firepit",
    "deluxe_firepit_fire",
    "endo_firepit",
    "endo_firepit_fire",
    "ice_star",
    "ice_star_flame",
    "heat_star",
    "heat_star_flame",
    -- Tropical Experience.
    "obsidianfirepit",
}

for _, prefab in ipairs(protected_fires) do
    AddPrefabPostInit(prefab, function(inst)
        inst:AddTag("burnt")
    end)
end
