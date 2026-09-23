local G = GLOBAL

table.insert(PrefabFiles, "ttk_elemental_swords")

local DEFINITIONS = {
    {
        prefab = "ttk_votuongkiem",
        name = "Vô Tướng Kiếm",
        recipe = { { "ttk_lingshi2", 1 }, { "goldnugget", 12 }, { "flint", 6 } },
        description = "Kim: mỗi đòn đánh thêm 10 sát thương vị diện.",
    },
    {
        prefab = "ttk_thanhtrucphongvankiem",
        name = "Thanh Trúc Phong Vân Kiếm",
        recipe = { { "ttk_lingshi2", 1 }, { "livinglog", 6 }, { "twigs", 12 } },
        description = "Mộc: mỗi đòn trúng thứ tư gọi một phi kiếm truy kích.",
    },
    {
        prefab = "ttk_phanthienkiem",
        name = "Phần Thiên Kiếm",
        recipe = { { "ttk_lingshi2", 1 }, { "redgem", 3 }, { "charcoal", 6 } },
        description = "Hỏa: có thể tạo chấn động sát thương quanh mục tiêu.",
    },
    {
        prefab = "ttk_tienkiem",
        name = "Tiên Kiếm",
        recipe = { { "ttk_lingshi2", 1 }, { "thulecite", 6 }, { "rocks", 12 } },
        description = "Thổ: mỗi đòn trúng thứ năm tạo khiên hộ thể.",
    },
    {
        prefab = "ttk_makiem",
        name = "Ma Kiếm",
        recipe = { { "ttk_lingshi2", 1 }, { "purplegem", 3 }, { "nightmarefuel", 6 } },
        description = "Lôi: có thể truyền sát thương sang hai kẻ địch khác.",
    },
}

for _, def in ipairs(DEFINITIONS) do
    local upper = string.upper(def.prefab)
    G.STRINGS.NAMES[upper] = def.name
    G.STRINGS.RECIPE_DESC[upper] = def.description
    G.STRINGS.CHARACTERS.GENERIC.DESCRIBE[upper] =
        "100 sát thương, tầm 2, 1.000 độ bền. " .. def.description
    RegisterInventoryItemAtlas(
        "images/inventoryimages/" .. def.prefab .. ".xml",
        def.prefab .. ".tex"
    )
    local ingredients = {}
    for _, ingredient in ipairs(def.recipe) do
        table.insert(ingredients, G.Ingredient(ingredient[1], ingredient[2]))
    end
    AddRecipe2(def.prefab, ingredients, G.TECH.SCIENCE_TWO, {
        atlas = "images/inventoryimages/" .. def.prefab .. ".xml",
        image = def.prefab .. ".tex",
        no_deconstruction = true,
    }, { "WEAPONS", "MAGIC" })
end
