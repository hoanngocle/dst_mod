local G = GLOBAL
table.insert(PrefabFiles, "ttk_ngulongdang")
G.STRINGS.NAMES.TTK_NGULONGDANG = "Ngư Long Đăng"
G.STRINGS.RECIPE_DESC.TTK_NGULONGDANG = "Đèn chiếu sáng và điều hòa nhiệt độ."
G.STRINGS.CHARACTERS.GENERIC.DESCRIBE.TTK_NGULONGDANG = "Mỗi Hạ Phẩm Linh Thạch nạp 10% linh khí; đèn đầy không nhận thêm."
RegisterInventoryItemAtlas("images/inventoryimages/ttk_ngulongdang.xml", "ttk_ngulongdang.tex")
AddRecipe2("ttk_ngulongdang", {
    G.Ingredient("goldnugget", 3),
    G.Ingredient("log", 2),
    G.Ingredient("papyrus", 3),
    G.Ingredient("ttk_lingshi2", 1),
}, G.TECH.SCIENCE_ONE, {
    atlas = "images/inventoryimages/ttk_ngulongdang.xml",
    image = "ttk_ngulongdang.tex",
    no_deconstruction = true,
}, {"LIGHT", "MAGIC"})
