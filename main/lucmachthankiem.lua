-- Independent lucmachthankiem namespace; register through this
-- mod's environment without replacing the table/stone registries or globals.
local G = GLOBAL
-- Thiết lập cố định của Phàm Nhân; không đọc config cũ.

for _, name in ipairs({"lucmachthankiem", "lucmachthankiem_ember_vfx", "lucmachthankiem_sparkle_vfx"}) do
    table.insert(PrefabFiles, name)
end
for _, asset in ipairs({
    G.Asset("ATLAS", "images/inventoryimages/lucmachthankiem.xml"),
    G.Asset("IMAGE", "images/inventoryimages/lucmachthankiem.tex"),
    -- Compiled FMOD bank/event names are resource ABI, not gameplay IDs.
    G.Asset("SOUNDPACKAGE", "sound/terraprisma_sfx.fev"),
    G.Asset("SOUND", "sound/terraprisma_sfx.fsb"),
}) do
    table.insert(Assets, asset)
end
RegisterInventoryItemAtlas("images/inventoryimages/lucmachthankiem.xml", "lucmachthankiem.tex")

local tuning = G.TUNING
tuning.LUCMACHTHANKIEM_LANGUAGE = false
tuning.LUCMACHTHANKIEM_DURABILITY = 1000
tuning.LUCMACHTHANKIEM_DAMAGE = 50
tuning.LUCMACHTHANKIEM_PLANARDAMAGE = 10
tuning.LUCMACHTHANKIEM_SLOT = 2
tuning.LUCMACHTHANKIEM_AOE_ATTACK = true
tuning.LUCMACHTHANKIEM_SPEED = 1.15
tuning.LUCMACHTHANKIEM_UPGRADE_NEED = 9

G.STRINGS.NAMES.LUCMACHTHANKIEM = "Lục Mạch Thần Kiếm"
G.STRINGS.NAMES.RAINBOW_LUCMACHTHANKIEM = "Lục Mạch Thần Kiếm · Cầu Vồng"
G.STRINGS.CHARACTERS.GENERIC.DESCRIBE.LUCMACHTHANKIEM = "Lục kiếm hộ thân, tùy tâm ngự địch."
G.STRINGS.RECIPE_DESC.LUCMACHTHANKIEM = "Triệu hồi phi kiếm hộ thân."
G.STRINGS.LUCMACHTHANKIEM_AUTOATTACK = {
    ENABLED = "Tự động tấn công: Bật",
    DISABLED = "Tự động tấn công: Tắt",
}
G.STRINGS.LUCMACHTHANKIEM_ENEMYSELECT = "Chỉ định mục tiêu"
G.STRINGS.LUCMACHTHANKIEM_RECHARGE = "Nạp Thần Kiếm"

AddRecipe2("lucmachthankiem", {
    G.Ingredient("glasscutter", 1),
    G.Ingredient("redgem", 6),
}, G.TECH.MAGIC_THREE, {
    atlas = "images/inventoryimages/lucmachthankiem.xml",
    image = "lucmachthankiem.tex",
    nounlock = false,
}, {"LIGHT", "WEAPONS", "MAGIC"})

modimport"main/lucmachthankiem_autoattack.lua"
modimport"main/lucmachthankiem_recharge.lua"
if tuning.LUCMACHTHANKIEM_SLOT ~= 0 then
    modimport"main/lucmachthankiem_enemyselect.lua"
end
