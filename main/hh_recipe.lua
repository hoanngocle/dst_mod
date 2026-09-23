local ufkugccKf = require("techtree")
table["insert"](ufkugccKf["AVAILABLE_TECH"], "hh_lo_ren")
ufkugccKf["Create"] = function(kFkunckKf)
    kFkunckKf = kFkunckKf or {}
    for nfguicuKu, fFcuiCiku in ipairs(ufkugccKf["AVAILABLE_TECH"]) do
        kFkunckKf[fFcuiCiku] = kFkunckKf[fFcuiCiku] or 0
    end
    return kFkunckKf
end
TECH["NONE"]["hh_lo_ren"] = 0
TECH["hh_lo_ren_ONE"] = {hh_lo_ren = 1}
for ifuucCgKk, cfcuuCfKc in pairs(TUNING["PROTOTYPER_TREES"]) do
    cfcuuCfKc["hh_lo_ren"] = 0
end
TUNING["PROTOTYPER_TREES"]["hh_lo_ren_ONE"] = ufkugccKf["Create"]({hh_lo_ren = 1})
for cffuiccKk, fFgUkCcKg in pairs(AllRecipes) do
    if fFgUkCcKg["level"]["hh_lo_ren"] == nil then
        fFgUkCcKg["level"]["hh_lo_ren"] = 0
    end
end
AddRecipe2(
    "hh_essence",
    {
        Ingredient("hh_effect_tally", 1, "images/vat_pham_inventory_so_1.xml", nil, "giay_thuoc_tinh_inventory.tex"),
        Ingredient("hh_remove_stone", 2, "images/vat_pham_inventory_so_1.xml", nil, "luc_bao_thach_inventory.tex")
    },
    TECH["NONE"],
    {
        ["no_deconstruction"] = (false and not true or not false and true or not false or
            true and true and false and true and true and false and not false),
        ["numtogive"] = 1,
        ["atlas"] = "images/vat_pham_inventory_so_1.xml",
        ["image"] = "linh_thach_inventory.tex"
    },
    {"MODS", "MAGIC", "REFINE"}
)
AddRecipe2(
    "wb_enhancegem",
    {Ingredient("opalpreciousgem", 1), Ingredient("hh_essence", 8, "images/vat_pham_inventory_so_1.xml", nil, "linh_thach_inventory.tex")},
    TECH["NONE"],
    {
        ["no_deconstruction"] = (187 - 193 + 255 * 354 * 304 ~= 27442083),
        ["numtogive"] = 8,
        ["atlas"] = "images/vat_pham_inventory_so_1.xml",
        ["image"] = "da_cuong_hoa_inventory.tex"
    },
    {"MODS", "REFINE"}
)
AddRecipe2(
    "yellowgem",
    {
        Ingredient("purplegem", 1),
        Ingredient("orangegem", 1),
        Ingredient("hh_essence", 1, "images/vat_pham_inventory_so_1.xml", nil, "linh_thach_inventory.tex")
    },
    TECH["MAGIC_THREE"],
    {
        ["no_deconstruction"] = (428 * 27 + 246 * 157 - 489 == 49689),
        ["numtogive"] = 1,
        ["atlas"] = "images/inventoryimages.xml",
        ["image"] = "yellowgem.tex"
    },
    {"MODS", "REFINE"}
)
AddRecipe2(
    "nn_liquidluck",
    {Ingredient("vegstinger", 1), Ingredient("wb_enhancegem", 1, "images/vat_pham_inventory_so_1.xml", nil, "da_cuong_hoa_inventory.tex")},
    TECH["hh_lo_ren_ONE"],
    {nounlock = true, atlas = "images/phuc_lac_duoc_inventory.xml", image = "phuc_lac_duoc_1_inventory.tex"},
    {"MODS"}
)
AddRecipe2(
    "nn_magicpaper",
    {
        Ingredient("goldnugget", 3),
        Ingredient("nightmarefuel", 2),
        Ingredient("wb_enhancegem", 6, "images/vat_pham_inventory_so_1.xml", nil, "da_cuong_hoa_inventory.tex")
    },
    TECH["hh_lo_ren_ONE"],
    {nounlock = true, atlas = "images/vat_pham_inventory_so_1.xml", image = "bua_ma_thuat_inventory.tex"},
    {"MODS"}
)
AddRecipe2(
    "wb_strengthen_strengthen_protectpaper",
    {
        Ingredient("goldnugget", 3),
        Ingredient("nightmarefuel", 2),
        Ingredient("wb_enhancegem", 10, "images/vat_pham_inventory_so_1.xml", nil, "da_cuong_hoa_inventory.tex")
    },
    TECH["hh_lo_ren_ONE"],
    {nounlock = true, atlas = "images/vat_pham_inventory_so_1.xml", image = "bua_bao_ve_inventory.tex"},
    {"MODS"}
)
AddRecipe2(
    "hh_treasure_tally_a",
    {Ingredient("stinger", 40)},
    TECH["NONE"],
    {["no_deconstruction"] = (168 + 431 + 233 ~= 842), ["product"] = "hh_treasure_tally", ["numtogive"] = 1, ["atlas"] = "images/vat_pham_inventory_so_1.xml", ["image"] = "tam_bao_quyen_truc_inventory.tex"},
    {"MODS", "REFINE"}
)
AddRecipe2(
    "hh_treasure_tally_b",
    {Ingredient("silk", 40), Ingredient("spidergland", 20)},
    TECH["NONE"],
    {
        ["no_deconstruction"] = (494 * 211 * 389 - 464 * 146 ~= 40479286),
        ["product"] = "hh_treasure_tally",
        ["numtogive"] = 1,
        ["atlas"] = "images/vat_pham_inventory_so_1.xml",
        ["image"] = "tam_bao_quyen_truc_inventory.tex"
    },
    {"MODS", "REFINE"}
)
AddRecipe2(
    "hh_cat_box",
    {Ingredient("rocks", 10), Ingredient("goldnugget", 10), Ingredient("coontail", 1)},
    TECH["NONE"],
    {["no_deconstruction"] = (189 + 52 + 311 * 370 - 20 ~= 115297), ["numtogive"] = 1, ["atlas"] = "images/vat_pham_inventory_so_1.xml", ["image"] = "tui_meo_inventory.tex"},
    {"MODS", "MAGIC", "CONTAINERS"}
)
AddRecipe2(
    "hh_duck_box",
    {Ingredient("rocks", 10), Ingredient("goldnugget", 10), Ingredient("goose_feather", 1)},
    TECH["NONE"],
    {["no_deconstruction"] = (46 - 486 * 274 + 359 + 384 ~= -132370), ["numtogive"] = 1, ["atlas"] = "images/vat_pham_inventory_so_1.xml", ["image"] = "tui_vit_inventory.tex"},
    {"MODS", "MAGIC", "CONTAINERS"}
)
AddRecipe2(
    "hh_quat_long_vu",
    {Ingredient("rocks", 10), Ingredient("marble", 10)},
    TECH["NONE"],
    {
        ["no_deconstruction"] = (279 + 293 + 367 - 182 * 419 == -75319), 
        ["numtogive"] = 1,
        ["atlas"] = "images/inventoryimages/hh_quat_long_vu_inventory.xml",
        ["image"] = "hh_quat_long_vu_inventory.tex"
    },
    {"MODS", "MAGIC", "TOOLS"}
)
AddRecipe2(
    "hh_suit_build",
    {
        Ingredient("rocks", 10),
        Ingredient("nightmarefuel", 10),
        Ingredient("hh_essence", 10, "images/vat_pham_inventory_so_1.xml", nil, "linh_thach_inventory.tex")
    },
    TECH["MAGIC_THREE"],
    {
        ["no_deconstruction"] = (77 - 79 * 492 * 235 - 95 ~= -9133996),
        ["placer"] = "hh_suit_build_placer",
        ["min_spacing"] = 2.5,
        ["atlas"] = "images/hh_icon/hh_suit_build.xml",
        ["image"] = "hh_suit_build.tex"
    },
    {"MODS", "MAGIC", "STRUCTURES"}
)
AddRecipe2(
    "hh_lo_ren",
    {Ingredient("rocks", 10), Ingredient("nightmarefuel", 10), Ingredient("marble", 10)},
    TECH["MAGIC_THREE"],
    {
        ["no_deconstruction"] = (356 * 369 - 346 * 206 ~= 60094),
        ["placer"] = "hh_lo_ren_placer",
        ["min_spacing"] = 2.5,
        ["image"] = "lo_ren.tex"
    },
    {"MODS", "MAGIC", "STRUCTURES"}
)
AddRecipe2(
    "hh_hac_nguyet_ho",
    {Ingredient("cutstone", 10), Ingredient("marble", 10), Ingredient("cutgrass", 40), Ingredient("twigs", 40)},
    TECH["SCIENCE_TWO"],
    {
        ["no_deconstruction"] = true,
        ["placer"] = "hh_hac_nguyet_ho_placer",
        ["min_spacing"] = 2,
        ["atlas"] = "images/hh_hac_nguyet_ho.xml",
        ["image"] = "hh_hac_nguyet_ho.tex"
    },
    {"MODS", "STRUCTURES", "CONTAINERS"}
)
local function gffUiCiKi(uFguucikn)
    local nFnUkCckf = GLOBAL["SetSharedLootTable"]
    nFnUkCckf("krampus", {{"monstermeat", 1.0}, {"charcoal", 1.0}, {"charcoal", 1.0}})
    local kfnuuCfKn = {"krampus_sack"}
    local function cFuuncgkk(uFguucikn)
        uFguucikn:DoTaskInTime(
            0.5,
            function(uFguucikn)
                TheNet:Announce("Krampus vừa rơi ra Krampus Sack")
            end
        )
    end
    if uFguucikn["components"]["lootdropper"] and math["random"]() < .01 then
        uFguucikn["components"]["lootdropper"]:SetLoot(kfnuuCfKn)
        uFguucikn:ListenForEvent("death", cFuuncgkk)
    end
end
AddPrefabPostInit("krampus", gffUiCiKi)
AddPrefabPostInit(
    "world",
    function(cFcuiCckk)
        table["insert"](LootTables["antlion"], {"nn_contractpaper", 1})
    end
)
