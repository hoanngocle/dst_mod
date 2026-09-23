local G = GLOBAL
for _, name in ipairs({"ttk_yhsyz", "ttk_hyc", "ttk_hmsw"}) do table.insert(PrefabFiles, name) end
local definitions = {
    {"ttk_yhsyz", "Nguyệt Hoa Nhiếp Dược Chi", "Cầm để hái linh thảo an toàn; 75% trả hạt, 100 lượt dùng.",
        {{"twigs",12},{"petals",6},{"orangegem",2},{"ttk_lingshi2",1}}, "SCIENCE_ONE", false},
    {"ttk_hyc", "Hoán Nguyệt Trì", "Nuôi tối đa ba cá; sau bảy ngày mỗi cá cho bốn cá cùng loại.",
        {{"moonglass",10},{"yellowgem",3},{"marble",15},{"ttk_lingshi1",1}}, "SCIENCE_ONE", true},
    {"ttk_tree_xhs", "Hạnh Hoa Thụ", "Che chở, giữ nhiệt 19°C và kết một Ngọc Vàng mỗi khoảng bảy ngày.",
        {{"livinglog",4},{"yellowgem",2},{"ttk_lingshi1",1}}, "SCIENCE_TWO", true},
    {"ttk_hmsw", "Hoán Miêu Thụ Ốc", "Nhà Catcoon, tích quà mỗi ngày khi đủ thú và còn chỗ chứa.",
        {{"cutstone",3},{"log",10},{"coontail",3},{"ttk_lingshi1",10}}, "SCIENCE_ONE", true},
}
for _, def in ipairs(definitions) do
    local id, key = def[1], string.upper(def[1])
    G.STRINGS.NAMES[key] = def[2]
    G.STRINGS.RECIPE_DESC[key] = def[3]
    G.STRINGS.CHARACTERS.GENERIC.DESCRIBE[key] = def[3]
    local ingredients = {}
    for _, ingredient in ipairs(def[4]) do table.insert(ingredients, G.Ingredient(ingredient[1], ingredient[2])) end
    local atlas = "images/inventoryimages/" .. id .. ".xml"
    local options = {atlas = atlas, image = id .. ".tex"}
    if id == "ttk_yhsyz" then options.no_deconstruction = true end
    if def[6] then
        options.placer = id .. "_placer"
        options.min_spacing = id == "ttk_tree_xhs" and 3 or 2
        AddMinimapAtlas("images/map_icons/" .. id .. ".xml")
    end
    RegisterInventoryItemAtlas(atlas, id .. ".tex")
    AddRecipe2(id, ingredients, G.TECH[def[5]], options, def[6] and {"STRUCTURES", "GARDENING"} or {"TOOLS", "GARDENING"})
end
G.STRINGS.ACTIONS.ACTIVATE.TTK_HARVEST_FISH = "Thu hoạch cá"
G.STRINGS.ACTIONS.ACTIVATE.TTK_CAT_GIFTS = "Nhận quà"
G.STRINGS.CHARACTERS.GENERIC.ACTIONFAIL.ACTIVATE.TTK_FISH_NOT_READY = "Cá chưa sinh sản, hãy chờ đủ bảy ngày."
G.STRINGS.CHARACTERS.GENERIC.DESCRIBE.TTK_HYC = {
    GENERIC = "Hồ nuôi cá dưới ánh trăng.", EMPTY = "Có thể thả tối đa ba cá ao hoặc cá biển sống.",
    GROWING = "Cá đang lớn, chưa đến lúc thu hoạch.", READY = "Đã có cá để thu hoạch!",
}
