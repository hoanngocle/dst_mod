require("ttk_solo_guard").Check(GLOBAL, modname)
local modenv = env
modimport("main/ttk_weapon_solo.lua")

modimport("main/ttk_stacksize.lua")

-- Gift opening and grass morph prevention are always enabled.
modimport("main/ttk_qualityoflife.lua")
modimport("main/ttk_smarter_flingomatic.lua")
GLOBAL.ManifestManager:AddFileToModManifest(modname, "scripts/ttk_inventorysort.lua")
require("ttk_inventorysort").Install(modenv)
GLOBAL.ManifestManager:AddFileToModManifest(modname, "scripts/ttk_bossindicators.lua")
GLOBAL.ManifestManager:AddFileToModManifest(modname, "scripts/widgets/ttk_bossindicator.lua")
require("ttk_bossindicators").Install(modenv)


PrefabFiles = {

    "ttk_hhlmz",

    "ttk_hhlmz_skins",
    "ttk_skin_spirit",
    "ttk_skin_hyys_fx",

    "ttk_lingshi",

    "ttk_alchemy",

}



Assets = {

    Asset("ANIM", "anim/ttk_hhlmz.zip"),

    Asset("ANIM", "anim/ttk_hhlmz_skins_htjc.zip"),

    Asset("ANIM", "anim/ttk_hhlmz_skins_wfz.zip"),

    Asset("ANIM", "anim/ttk_lingshi.zip"),

    Asset("ANIM", "anim/ui_backpack_2x4.zip"),

    Asset("ATLAS", "images/inventoryimages/ttk_hhlmz.xml"),

    Asset("IMAGE", "images/inventoryimages/ttk_hhlmz.tex"),

    Asset("ATLAS", "images/inventoryimages/ttk_hhlmz_skins_htjc.xml"),

    Asset("IMAGE", "images/inventoryimages/ttk_hhlmz_skins_htjc.tex"),

    Asset("ATLAS", "images/inventoryimages/ttk_hhlmz_skins_wfz.xml"),

    Asset("IMAGE", "images/inventoryimages/ttk_hhlmz_skins_wfz.tex"),

    Asset("ATLAS", "images/inventoryimages/ttk_lingshi1.xml"),

    Asset("IMAGE", "images/inventoryimages/ttk_lingshi1.tex"),

    Asset("ATLAS", "images/inventoryimages/ttk_lingshi2.xml"),

    Asset("IMAGE", "images/inventoryimages/ttk_lingshi2.tex"),

    Asset("ATLAS", "images/inventoryimages/ttk_lingshi3.xml"),

    Asset("IMAGE", "images/inventoryimages/ttk_lingshi3.tex"),

    Asset("ATLAS", "images/inventoryimages/ttk_lingshi4.xml"),

    Asset("IMAGE", "images/inventoryimages/ttk_lingshi4.tex"),

    Asset("ATLAS", "images/map_icons/ttk_hhlmz.xml"),

    Asset("IMAGE", "images/map_icons/ttk_hhlmz.tex"),

    Asset("ATLAS", "images/ttk_bossindicators.xml"),

    Asset("IMAGE", "images/ttk_bossindicators.tex"),

}



-- Nạp ô ba lô và dây chuyền trước các pháp bảo đọc EQUIPSLOTS.
modimport("main/ttk_inventory45.lua")
modimport("main/ttk_inventory45_compat.lua")

require"ttk_skins".Install(modenv)

require"ttk_registration"(modenv)



modenv.AddPrefabPostInit("world", function(inst)

    require"ttk_loot".Install(inst)

end)



modimport"main/lucmachthankiem.lua"
modimport"main/vanhonphien.lua"
modimport"main/thanhiquangtruong.lua"
modimport("main/nhatvuphuonghoa.lua")
modimport("main/ttk_elemental_swords.lua")
modimport("main/ttk_tinhlakiem.lua")
modimport("main/ttk_lucnguyenkiemdong.lua")
modimport("main/ttk_ngulongdang.lua")
modimport("main/ttk_fsct.lua")
modimport"main/ttk_garden.lua"
modimport("main/ttk_luoshen_food.lua")
modimport"main/ttk_buildings.lua"
modimport"main/ttk_rituals.lua"
modimport("main/ttk_jitan.lua")
modimport"main/ttk_batch19_misc.lua"
modimport"main/ttk_batch19_herbs.lua"

-- Portal module is always part of Tu Tien Ky.
GLOBAL.ManifestManager:AddFileToModManifest(modname, "main/ttk_portal.lua")
modimport("main/ttk_portal.lua")

-- Vĩnh Hằng Thần Hỏa luôn được nạp cùng Tu Tiên Ký.
modimport("main/ttk_vinhhangthanhoa.lua")
modimport("main/ttk_chuongthienbinh.lua")
modimport("main/ttk_armor_set.lua")
modimport("main/ttk_tianji.lua")
modimport("main/ttk_batch19_houses.lua")
modimport("main/ttk_choujiangji.lua")
modimport("main/ttk_garden_expansion.lua")
modimport("main/ttk_spirit_mines.lua")

-- Phàm Nhân cultivation progression is server-authoritative.
modimport("main/ttk_alchemy.lua")

-- Solo is included and always loaded by this single mod.
GLOBAL.ManifestManager:AddFileToModManifest(modname, "scripts/ttk_hover_theme.lua")
for _, path in ipairs({ "scripts/ttk_eva_portraits.lua", "scripts/widgets/ttk_eva_portrait_picker.lua" }) do
    GLOBAL.ManifestManager:AddFileToModManifest(modname, path)
end
for i = 1, 4 do
    local base = "images/eva_portraits/eva_art_" .. i
    Assets[#Assets + 1] = Asset("ATLAS", base .. ".xml")
    Assets[#Assets + 1] = Asset("IMAGE", base .. ".tex")
end
modimport("main/ttk_solo_bootstrap.lua")
modimport("main/ttk_combat_hud.lua")
modimport("main/ttk_bosses.lua")

-- EVA character; progression comes from Achievement & Level.
modimport("main/ttk_eva.lua")

-- Achievement evidence adapters load after Phàm Nhân/Solo player systems.
modimport("main/ttk_achievement.lua")
