local G = GLOBAL
table.insert(PrefabFiles, "nhatvuphuonghoa")
table.insert(PrefabFiles, "nhatvuphuonghoa_buff")
G.STRINGS.NAMES.NHATVUPHUONGHOA = "Nhất Vũ Phương Hoa"
G.STRINGS.RECIPE_DESC.NHATVUPHUONGHOA = "Ô che mưa, chống nóng và giữ thân khô ráo."
G.STRINGS.CHARACTERS.GENERIC.DESCRIBE.NHATVUPHUONGHOA = "Hạ Phẩm Linh Thạch hồi 5% độ bền. Phép làm khô tốn 25%, chống ướt trong 4 phút."
G.STRINGS.ACTIONS.CASTSPELL.NHATVU_KEEPDRY = "Giữ Khô"
RegisterInventoryItemAtlas("images/inventoryimages/nhatvuphuonghoa.xml", "nhatvuphuonghoa.tex")
AddRecipe2("nhatvuphuonghoa", {
    G.Ingredient("papyrus", 6),
    G.Ingredient("silk", 3),
    G.Ingredient("ttk_lingshi2", 2),
    G.Ingredient("livinglog", 2),
}, G.TECH.SCIENCE_TWO, {
    atlas = "images/inventoryimages/nhatvuphuonghoa.xml",
    image = "nhatvuphuonghoa.tex",
    no_deconstruction = true,
}, {"CLOTHING", "TOOLS", "MAGIC"})
