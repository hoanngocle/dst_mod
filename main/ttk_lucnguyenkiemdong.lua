local G = GLOBAL
local Bridge = require("ttk_lucnguyen_combat")

table.insert(PrefabFiles, "ttk_lucnguyenkiemdong")

G.STRINGS.NAMES.TTK_LUCNGUYENKIEMDONG = "Lục Nguyên Kiếm Đồng"
G.STRINGS.RECIPE_DESC.TTK_LUCNGUYENKIEMDONG =
    "Kiếm đồng dẫn sáu nguyên, chí mạng hóa vạn kiếm."
G.STRINGS.CHARACTERS.GENERIC.DESCRIBE.TTK_LUCNGUYENKIEMDONG =
    "50 sát thương, tầm 8, chứa 1.000 phát. Hạ Phẩm Linh Thạch nạp 100 phát."

RegisterInventoryItemAtlas(
    "images/inventoryimages/ttk_lucnguyenkiemdong.xml",
    "ttk_lucnguyenkiemdong.tex"
)

AddRecipe2("ttk_lucnguyenkiemdong", {
    G.Ingredient("ttk_votuongkiem", 1),
    G.Ingredient("ttk_thanhtrucphongvankiem", 1),
    G.Ingredient("ttk_tinhlakiem", 1),
    G.Ingredient("ttk_phanthienkiem", 1),
    G.Ingredient("ttk_tienkiem", 1),
    G.Ingredient("ttk_makiem", 1),
}, G.TECH.SCIENCE_TWO, {
    atlas = "images/inventoryimages/ttk_lucnguyenkiemdong.xml",
    image = "ttk_lucnguyenkiemdong.tex",
    no_deconstruction = true,
}, { "WEAPONS", "MAGIC" })

-- These post-inits are harmless when Solo is absent; they only run for
-- components which Solo actually creates.
AddComponentPostInit("hh_player", function(component)
    Bridge.InstallSoloComponent(component)
end)
AddComponentPostInit("hh_godslayer", function(component)
    Bridge.InstallGodslayerComponent(component)
end)
AddComponentPostInit("hh_world", function(component)
    Bridge.InstallWorldComponent(component)
end)

AddSimPostInit(function()
    local ok, utils = G.pcall(G.require, "utils/hh_utils")
    if ok then Bridge.InstallSoloObserver(utils) end
end)
