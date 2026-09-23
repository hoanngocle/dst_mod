local G = GLOBAL
local MODENV = getfenv(1)
require("ttk_jitan_boss_adapters").Install({ AddStategraphPostInit = AddStategraphPostInit })
require("ttk_jitan_encounter_setup").Install({ AddComponentPostInit = AddComponentPostInit })
require("ttk_jitan_bosses").SetSoloCapabilityProvider(function()
    return rawget(MODENV, "_ttk_solo_loaded") == true
end)

local prefab_files = { "ttk_jitan", "ttk_llbx" }
for _, name in ipairs(prefab_files) do
    table.insert(PrefabFiles, name)
end

local assets = {
    Asset("ANIM", "anim/ttk_jitan.zip"),
    Asset("ANIM", "anim/ttk_llbx.zip"),
    Asset("ANIM", "anim/ttk_ui_llbx.zip"),
    Asset("ATLAS", "images/map_icons/ttk_jitan.xml"),
    Asset("IMAGE", "images/map_icons/ttk_jitan.tex"),
    Asset("ATLAS", "images/map_icons/ttk_llbx.xml"),
    Asset("IMAGE", "images/map_icons/ttk_llbx.tex"),
}
for _, asset in ipairs(assets) do
    table.insert(Assets, asset)
end

RegisterInventoryItemAtlas("images/map_icons/ttk_jitan.xml", "ttk_jitan.tex")
AddMinimapAtlas("images/map_icons/ttk_jitan.xml")
RegisterInventoryItemAtlas("images/map_icons/ttk_llbx.xml", "ttk_llbx.tex")
AddMinimapAtlas("images/map_icons/ttk_llbx.xml")

local containers = G.require("containers")
containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, 36)
containers.params.ttk_llbx = {
    widget = {
        slotpos = {},
        animbank = "ui_chest_3x3",
        animbuild = "xd_ui_llbx",
        pos = G.Vector3(0, 220, 0),
        side_align_tip = 160,
    },
    type = "chest",
    itemtestfn = function() return false end,
}
containers.params.ttk_llbx_private = {
    widget = containers.params.ttk_llbx.widget,
    type = "chest",
}
for y = 4, -1, -1 do
    for x = -1, 4 do
        table.insert(containers.params.ttk_llbx.widget.slotpos, G.Vector3(80 * x - 120, 80 * y - 120, 0))
    end
end

G.STRINGS.NAMES.TTK_JITAN = "Tế Đàn"
G.STRINGS.RECIPE_DESC.TTK_JITAN = "Mở thử luyện mọi boss tương thích của Phàm Nhân."
G.STRINGS.CHARACTERS.GENERIC.DESCRIBE.TTK_JITAN = "Một nơi thử đạo bằng những trận chiến khốc liệt."
G.STRINGS.NAMES.TTK_LLBX = "Linh Lung Bảo Sương"
G.STRINGS.RECIPE_DESC.TTK_LLBX = "Giữ phần thưởng thử luyện riêng cho từng người."
G.STRINGS.CHARACTERS.GENERIC.DESCRIBE.TTK_LLBX = "Chiến lợi phẩm của mỗi người đều có chỗ riêng."

local defs = require("ttk_jitan_defs")
local function RecipeIngredients(name)
    local ingredients = {}
    for _, entry in ipairs(defs.recipe_ingredients[name]) do
        table.insert(ingredients, G.Ingredient(entry.prefab, entry.count))
    end
    return ingredients
end
AddRecipe2("ttk_jitan", RecipeIngredients("ttk_jitan"), G.TECH.SCIENCE_TWO, {
    atlas = "images/map_icons/ttk_jitan.xml",
    image = "ttk_jitan.tex",
    placer = "ttk_jitan_placer",
    min_spacing = 4,
    no_deconstruction = true,
}, { "STRUCTURES", "MAGIC" })

AddRecipe2("ttk_llbx", RecipeIngredients("ttk_llbx"), G.TECH.SCIENCE_TWO, {
    atlas = "images/map_icons/ttk_llbx.xml",
    image = "ttk_llbx.tex",
    placer = "ttk_llbx_placer",
    min_spacing = 2,
    no_deconstruction = true,
}, { "STRUCTURES", "CONTAINERS" })
