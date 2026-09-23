local G = GLOBAL
table.insert(PrefabFiles, "ttk_tinhlakiem")
G.STRINGS.NAMES.TTK_TINHLAKIEM = "Tinh La Kiếm"
G.STRINGS.RECIPE_DESC.TTK_TINHLAKIEM = "Tinh quang kết kiếm, dưỡng bằng binh khí."
G.STRINGS.CHARACTERS.GENERIC.DESCRIBE.TTK_TINHLAKIEM = "100 sát thương, 1.000 độ bền. Tiêu thụ vũ khí khác để nạp; sát thương không đổi khi hết độ bền."
RegisterInventoryItemAtlas("images/inventoryimages/ttk_tinhlakiem.xml", "ttk_tinhlakiem.tex")
AddRecipe2("ttk_tinhlakiem", {
    G.Ingredient("ttk_lingshi2", 1),
    G.Ingredient("bluegem", 3),
    G.Ingredient("goldnugget", 6),
}, G.TECH.SCIENCE_TWO, {
    atlas = "images/inventoryimages/ttk_tinhlakiem.xml",
    image = "ttk_tinhlakiem.tex",
    no_deconstruction = true,
}, {"WEAPONS", "MAGIC"})
