local G = GLOBAL
table.insert(PrefabFiles, "ttk_fsct")
G.STRINGS.NAMES.TTK_FSCT = "Luân Hồi Đài"
G.STRINGS.RECIPE_DESC.TTK_FSCT = "Dựng đài tái tạo nhục thân, hồi sinh không giới hạn."
G.STRINGS.CHARACTERS.GENERIC.DESCRIBE.TTK_FSCT = "Hồn ma ám vào để hồi sinh. Không giới hạn lượt, không cần nạp hay chờ hồi."
AddMinimapAtlas("images/map_icons/ttk_fsct.xml")
RegisterInventoryItemAtlas("images/map_icons/ttk_fsct.xml", "ttk_fsct.tex")
AddRecipe2("ttk_fsct", {
    G.Ingredient("cutstone", 10),
    G.Ingredient("goldnugget", 6),
    G.Ingredient("reviver", 2),
    G.Ingredient("ttk_lingshi3", 2),
}, G.TECH.SCIENCE_TWO, {
    atlas = "images/map_icons/ttk_fsct.xml",
    image = "ttk_fsct.tex",
    placer = "ttk_fsct_placer",
    min_spacing = 3,
    no_deconstruction = true,
}, {"STRUCTURES", "MAGIC"})
