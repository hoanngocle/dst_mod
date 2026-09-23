-- All durations are game time; cooldowns pause when the server is stopped.
return {
    {name = "Mỏ Linh Thạch", days = 5, hits = 6,
        loot = {"rocks", "rocks", "rocks", "flint", "ttk_lingshi1", "ttk_lingshi1", "ttk_lingshi1"},
        chance = {"ttk_lingshi1", 0.5},
        ingredients = {{"cutstone", 10}, {"goldnugget", 6}, {"ttk_lingshi1", 20}}},
    {name = "Mỏ Linh Thạch Hiếm", days = 10, hits = 6,
        loot = {"rocks", "rocks", "rocks", "flint", "ttk_lingshi2"},
        ingredients = {{"cutstone", 15}, {"purplegem", 2}, {"ttk_lingshi2", 10}}},
    {name = "Mỏ Tuyệt Phẩm Linh Thạch", days = 20, hits = 12,
        loot = {"rocks", "rocks", "rocks", "ttk_lingshi3"},
        ingredients = {{"cutstone", 20}, {"thulecite", 6}, {"ttk_lingshi3", 5}}},
}
