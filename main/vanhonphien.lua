local G = GLOBAL
table.insert(PrefabFiles, "vanhonphien")
table.insert(PrefabFiles, "vanhonphien_vortexfx")

G.STRINGS.NAMES.VANHONPHIEN = "Cửu Thiên Tinh Thần Phiên"
G.STRINGS.NAMES.VANHONPHIEN_GROUND = "Cửu Thiên Tinh Thần Phiên"
G.STRINGS.NAMES.VANHONPHIEN_SOUL = "Hồn Vệ"
G.STRINGS.RECIPE_DESC.VANHONPHIEN = "Dựng phiên thu hồn, triệu Hồn Vệ trợ chiến."
G.STRINGS.CHARACTERS.GENERIC.DESCRIBE.VANHONPHIEN = "Dựng xuống đất để gọi Hồn Vệ. Thu lại sẽ giữ hồn tích lũy và hồi chiêu."
G.STRINGS.CHARACTERS.GENERIC.DESCRIBE.VANHONPHIEN_GROUND = "Thu hồn quanh đây, bảo vệ người dựng phiên."
G.STRINGS.CHARACTERS.GENERIC.DESCRIBE.VANHONPHIEN_SOUL = "Một Hồn Vệ đang chờ lệnh."

RegisterInventoryItemAtlas("images/inventoryimages/vanhonphien.xml", "vanhonphien.tex")
AddRecipe2("vanhonphien", {
    G.Ingredient("livinglog", 6),
    G.Ingredient("nightmarefuel", 12),
    G.Ingredient("purplegem", 2),
    G.Ingredient("ttk_lingshi2", 6),
}, G.TECH.MAGIC_THREE, {
    atlas = "images/inventoryimages/vanhonphien.xml",
    image = "vanhonphien.tex",
}, { "MAGIC", "WEAPONS" })
