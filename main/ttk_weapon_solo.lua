AddComponentPostInit("combat", function(combat)
    require("ttk_weapon_damage").InstallCommandFilter(combat)
end)
