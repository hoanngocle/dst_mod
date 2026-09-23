local G = GLOBAL
table.insert(PrefabFiles, "ttk_chuongthienbinh")
G.STRINGS.NAMES.TTK_CHUONGTHIENBINH = "Chưởng Thiên Bình"
G.STRINGS.RECIPE_DESC.TTK_CHUONGTHIENBINH = "Tích 200 linh khí ban đêm để thúc cây trồng."
G.STRINGS.CHARACTERS.GENERIC.DESCRIBE.TTK_CHUONGTHIENBINH = "Đặt ngoài trời ban đêm để nạp linh khí; mỗi lần thúc cây tốn 50."
RegisterInventoryItemAtlas("images/inventoryimages/ttk_chuongthienbinh.xml", "ttk_chuongthienbinh.tex")
AddRecipe2("ttk_chuongthienbinh", {
    G.Ingredient("livinglog", 2),
    G.Ingredient("moonglass", 6),
    G.Ingredient("bluegem", 3),
    G.Ingredient("ttk_lingshi1", 30),
}, G.TECH.MAGIC_TWO, {
    atlas = "images/inventoryimages/ttk_chuongthienbinh.xml",
    image = "ttk_chuongthienbinh.tex",
    no_deconstruction = true,
}, {"MAGIC", "GARDENING"})
