local G = GLOBAL
for _, file in ipairs({"ttk_qljq", "ttk_foodstores", "ttk_qwsk", "ttk_wsjx", "ttk_batch19_garden", "ttk_yunxiao_portable_spicer"}) do
    table.insert(PrefabFiles, file)
end
local containers = G.require("containers")
local params = containers.params
params.ttk_qljq = G.deepcopy(params.ttk_dc)
params.ttk_sgc = G.deepcopy(params.ttk_gjx)
params.ttk_crc = G.deepcopy(params.ttk_gjx)
params.ttk_sgc.itemtestfn = function(_, item)
    return not item:HasTag("preparedfood") and not item:HasTag("xd_ylxc_valid")
        and not item:HasTag("ttk_ylxc_valid")
        and (item:HasTag("xd_sgc_valid") or item:HasTag("ttk_sgc_valid")
            or item:HasTag("edible_VEGGIE") or item:HasTag("edible_SEEDS") or item:HasTag("edible_RAW"))
end
params.ttk_crc.itemtestfn = function(_, item)
    return not item:HasTag("preparedfood") and (item:HasTag("edible_MEAT")
        or item.prefab == "butter" or item.prefab == "milkywhites" or item.prefab == "goatmilk")
end
params.ttk_wsjx = G.deepcopy(params.ttk_lgzbh)
params.ttk_wsjx.itemtestfn = function(_, item) return item:HasTag("weapon") end
params.ttk_yunxiao_portable_spicer = G.deepcopy(params.portablespicer)
params.ttk_yunxiao_portable_spicer.acceptsstacks = true
params.ttk_yunxiao_portable_spicer.widget.slotbg[1] = {
    atlas = "images/inventoryimages/ttk_yunxiao_portableslot.xml", image = "ttk_yunxiao_portableslot.tex",
}
table.insert(Assets, G.Asset("ATLAS", "images/inventoryimages/ttk_yunxiao_portableslot.xml"))
table.insert(Assets, G.Asset("IMAGE", "images/inventoryimages/ttk_yunxiao_portableslot.tex"))
local function CopySpicerRecipes()
    local cooking = G.require("cooking")
    for _, recipe in pairs(cooking.recipes.portablespicer or {}) do
        local copy = G.deepcopy(recipe)
        -- Spiced dishes have no standalone cookbook artwork. Alias only the cooker.
        copy.no_cookbook = true
        AddCookerRecipe("ttk_yunxiao_portable_spicer", copy, cooking.IsModCookerFood(recipe.name))
    end
end
CopySpicerRecipes()
-- Include recipes registered by later-loading mods without changing their cookers.
AddSimPostInit(CopySpicerRecipes)
G.STRINGS.ACTIONS.ACTIVATE.TTK_GET_FOOD = "Nhận món ăn"
local definitions = {
    {"ttk_qljq", "Quỳnh Lâu Kim Khuyết", "Đèn bán kính 6; dùng Hạ Phẩm Linh Thạch, chỉ tiêu hao khi sáng ban đêm.", {{"marble",5},{"yellowgem",5},{"log",3},{"ttk_lingshi1",1}}, "SCIENCE_ONE", 2},
    {"ttk_sgc", "Sơ Quả Thương", "Kho 36 ô cho rau, quả và hạt; hồi độ tươi chậm.", {{"cutgrass",40},{"rope",10},{"ttk_lingshi1",10}}, "SCIENCE_ONE", 2},
    {"ttk_qwsk", "Thiên Vị Thực Khám", "Mỗi ngày tạo ngẫu nhiên 1–2 phần món ăn đã nêm gia vị.", {{"goldnugget",2},{"log",7},{"redgem",1},{"ttk_lingshi2",1}}, "SCIENCE_ONE", 1.5},
    {"ttk_flower_sfr", "Thủy Phù Dung", "Hoa trang trí hồi tinh thần; có thể sinh bướm vào bình minh.", {{"butterfly",2},{"bluegem",3},{"ttk_lingshi1",1}}, "SCIENCE_ONE", 2},
    {"ttk_flower_zyh", "Triều Dương Hoa", "Hoa trang trí hồi tinh thần; có thể sinh bướm vào bình minh.", {{"butterfly",2},{"livinglog",3},{"ttk_lingshi1",1}}, "SCIENCE_ONE", 2},
    {"ttk_crc", "Trữ Nhục Thương", "Kho 36 ô cho thịt sống và sản phẩm sữa; hồi độ tươi chậm.", {{"cutstone",10},{"boards",5},{"ttk_lingshi1",10}}, "SCIENCE_ONE", 2},
    {"ttk_flower_yl", "U Lan", "Hoa trang trí hồi tinh thần; có thể sinh bướm vào bình minh.", {{"butterfly",2},{"marble",3},{"ttk_lingshi1",1}}, "SCIENCE_ONE", 2},
    {"ttk_yunxiao_portable_spicer", "Vân Yên Hương Liệu Trạm", "Nêm món ăn theo chồng nguyên liệu; giữ lại phần nguyên liệu dư.", {{"goldnugget",2},{"cutstone",3},{"ttk_lingshi2",1}}, "NONE", 2},
    {"ttk_wsjx", "Vô Song Kiếm Hạp", "Hộp 20 ô tự nhặt vũ khí vô chủ trong bán kính 8.", {{"goldnugget",6},{"boards",2},{"gears",1},{"ttk_lingshi1",1}}, "SCIENCE_ONE", 2},
    {"ttk_tree_yls", "Yên Liễu Thụ", "Tạo Ngọc Lục định kỳ, che chở và điều hòa nhiệt độ xung quanh.", {{"livinglog",4},{"greengem",1},{"ttk_lingshi1",1}}, "SCIENCE_TWO", 3},
}
for _, def in ipairs(definitions) do
    local name, key = def[1], string.upper(def[1])
    G.STRINGS.NAMES[key] = def[2]
    G.STRINGS.RECIPE_DESC[key] = def[3]
    G.STRINGS.CHARACTERS.GENERIC.DESCRIBE[key] = def[3]
    local atlas = "images/inventoryimages/" .. name .. ".xml"
    RegisterInventoryItemAtlas(atlas, name .. ".tex")
    AddMinimapAtlas("images/map_icons/" .. name .. ".xml")
    local ingredients = {}
    for _, ingredient in ipairs(def[4]) do
        table.insert(ingredients, G.Ingredient(ingredient[1], ingredient[2]))
    end
    AddRecipe2(name, ingredients, G.TECH[def[5]], {
        atlas = atlas, image = name .. ".tex", placer = name .. "_placer", min_spacing = def[6],
        no_deconstruction = name == "ttk_qwsk" or name == "ttk_yunxiao_portable_spicer",
    }, {"STRUCTURES"})
end
-- Standalone access to native spices, retaining native ingredient/output amounts.
G.STRINGS.CHARACTERS.GENERIC.DESCRIBE.TTK_YUNXIAO_PORTABLE_SPICER = {
    GENERIC = "Nêm món ăn và gia vị theo từng mẻ.",
    EMPTY = "Cần một loại món ăn và một loại gia vị.",
    COOKING_LONG = "Đang nêm gia vị cho cả mẻ.",
    COOKING_SHORT = "Sắp hoàn thành rồi.",
    DONE = "Mẻ thức ăn đã sẵn sàng.",
    BURNT = "Trạm đã cháy rụi.",
}
for spice, ingredient in pairs({garlic="garlic", sugar="honey", chili="pepper", salt="saltrock"}) do
    local product, name = "spice_" .. spice, "ttk_spice_" .. spice
    G.STRINGS.NAMES[string.upper(name)] = G.STRINGS.NAMES[string.upper(product)]
    G.STRINGS.RECIPE_DESC[string.upper(name)] = "Gia vị dùng tại Vân Yên Hương Liệu Trạm."
    AddRecipe2(name, {G.Ingredient(ingredient, 3)}, G.TECH.SCIENCE_ONE,
        {product = product, numtogive = 2, atlas = "images/inventoryimages3.xml",
            image = product .. ".tex"}, {"COOKING"})
end
