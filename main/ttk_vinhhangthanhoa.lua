local fire_prefabs = {
	"deluxe_firepit",
	"deluxe_firepit_fire",
	"endo_firepit",
	"endo_firepit_fire",
	"ice_star",
	"ice_star_flame",
	"heat_star",
	"heat_star_flame"
}

local fire_assets = {
	Asset("ATLAS", "images/inventoryimages/deluxe_firepit.xml"),
	Asset("IMAGE", "minimap/deluxe_firepit.tex"),
	Asset("ATLAS", "minimap/deluxe_firepit.xml"),
	Asset("ATLAS", "images/inventoryimages/endo_firepit.xml"),
	Asset("IMAGE", "minimap/endo_firepit.tex"),
	Asset("ATLAS", "minimap/endo_firepit.xml"),
	Asset("ATLAS", "images/inventoryimages/ice_star.xml"),
	Asset("IMAGE", "minimap/ice_star.tex"),
	Asset("ATLAS", "minimap/ice_star.xml"),
	Asset("ATLAS", "images/inventoryimages/heat_star.xml"),
	Asset("IMAGE", "minimap/heat_star.tex"),
	Asset("ATLAS", "minimap/heat_star.xml")
}
for _, name in ipairs(fire_prefabs) do table.insert(PrefabFiles, name) end
for _, asset in ipairs(fire_assets) do table.insert(Assets, asset) end

AddMinimapAtlas("minimap/deluxe_firepit.xml")
AddMinimapAtlas("minimap/endo_firepit.xml")
AddMinimapAtlas("minimap/ice_star.xml")
AddMinimapAtlas("minimap/heat_star.xml")

local STRINGS = GLOBAL.STRINGS
local RECIPETABS = GLOBAL.RECIPETABS
local Recipe = GLOBAL.Recipe
local Ingredient = GLOBAL.Ingredient
local TECH = GLOBAL.TECH

-- Thiết lập cố định của Phàm Nhân Tu Tiên; không đọc config cũ của thế giới.
-- Cả bốn công trình dùng chung các giá trị này; sanityBoost giữ mặc định nguồn.
GLOBAL.ttk_vhth_maxFuel = 10
GLOBAL.ttk_vhth_startFuel = 0.25
GLOBAL.ttk_vhth_efficiency = 0.75
GLOBAL.ttk_vhth_lightRange = 1.25
GLOBAL.ttk_vhth_structureSize = 1
GLOBAL.ttk_vhth_sanityBoost = 0.5
GLOBAL.ttk_vhth_dropLoot = 2
GLOBAL.ttk_vhth_starsSpawnHounds = "no"

-- DELUXE FIREPIT ---------------------------------------------------------------------------------

-- Deluxe Firepit fixed settings
GLOBAL.ttk_vhth_maxFuelFirepit = GLOBAL.ttk_vhth_maxFuel
GLOBAL.ttk_vhth_startFuelFirepit = GLOBAL.ttk_vhth_startFuel
GLOBAL.ttk_vhth_efficiencyFirepit = GLOBAL.ttk_vhth_efficiency
GLOBAL.ttk_vhth_lightRangeFirepit = GLOBAL.ttk_vhth_lightRange
GLOBAL.ttk_vhth_structureSizeFirepit = GLOBAL.ttk_vhth_structureSize
GLOBAL.ttk_vhth_dropLootFirepit = GLOBAL.ttk_vhth_dropLoot
GLOBAL.ttk_vhth_burnRateFirepit = 1

-- Deluxe Firepit recipe
local RecipeIngredients = {
		Ingredient("log", 6),
		Ingredient("goldnugget", 3),
		Ingredient("cutstone", 14)
	}
local techLevel = TECH.SCIENCE_TWO

AddRecipe2(
	"deluxe_firepit",
	RecipeIngredients,
	techLevel,
	{
		placer = "deluxe_firepit_placer",
		atlas = "images/inventoryimages/deluxe_firepit.xml",
		image = "deluxe_firepit.tex"
	},
	{"LIGHT", "STRUCTURES", "WINTER"}
)

-- DELUXE ENDOTHERMIC FIREPIT ---------------------------------------------------------------------

-- Endo Firepit fixed settings
GLOBAL.ttk_vhth_maxFuelEndoFirepit = GLOBAL.ttk_vhth_maxFuel
GLOBAL.ttk_vhth_startFuelEndoFirepit = GLOBAL.ttk_vhth_startFuel
GLOBAL.ttk_vhth_efficiencyEndoFirepit = GLOBAL.ttk_vhth_efficiency
GLOBAL.ttk_vhth_lightRangeEndoFirepit = GLOBAL.ttk_vhth_lightRange
GLOBAL.ttk_vhth_structureSizeEndoFirepit = GLOBAL.ttk_vhth_structureSize
GLOBAL.ttk_vhth_dropLootEndoFirepit = GLOBAL.ttk_vhth_dropLoot
GLOBAL.ttk_vhth_burnRateEndoFirepit = 1

-- Endo Firepit recipe
local RecipeIngredients = {
		Ingredient("nitre", 5),
		Ingredient("cutstone", 14),
		Ingredient("transistor", 2)
	}
local techLevel = TECH.SCIENCE_TWO

AddRecipe2(
	"endo_firepit",
	RecipeIngredients,
	techLevel,
	{
		placer = "endo_firepit_placer",
		atlas = "images/inventoryimages/endo_firepit.xml",
		image = "endo_firepit.tex"
	},
	{"LIGHT", "STRUCTURES", "SUMMER"}
)

-- HEAT STAR --------------------------------------------------------------------------------------

-- Heat Star fixed settings
GLOBAL.ttk_vhth_efficiencyHeatStar = GLOBAL.ttk_vhth_efficiency
GLOBAL.ttk_vhth_maxFuelHeatStar = GLOBAL.ttk_vhth_maxFuel
GLOBAL.ttk_vhth_startFuelHeatStar = GLOBAL.ttk_vhth_startFuel
GLOBAL.ttk_vhth_lightRangeHeatStar = GLOBAL.ttk_vhth_lightRange
GLOBAL.ttk_vhth_structureSizeHeatStar = GLOBAL.ttk_vhth_structureSize
GLOBAL.ttk_vhth_sanityBoostHeatStar = GLOBAL.ttk_vhth_sanityBoost
GLOBAL.ttk_vhth_dropLootHeatStar = GLOBAL.ttk_vhth_dropLoot
GLOBAL.ttk_vhth_burnRateHeatStar = 1

-- Heat Star recipe
local RecipeIngredients = {
		Ingredient("cutstone", 30),
		Ingredient("transistor", 3),
		Ingredient("redgem", 2)
	}
local techLevel = TECH.MAGIC_TWO

AddRecipe2(
	"heat_star",
	RecipeIngredients,
	techLevel,
	{
		placer = "heat_star_placer",
		atlas = "images/inventoryimages/heat_star.xml",
		image = "heat_star.tex"
	},
	{"LIGHT", "STRUCTURES", "WINTER"}
)

--ICE STAR ----------------------------------------------------------------------------------------

-- Ice Star fixed settings
GLOBAL.ttk_vhth_efficiencyIceStar = GLOBAL.ttk_vhth_efficiency
GLOBAL.ttk_vhth_maxFuelIceStar = GLOBAL.ttk_vhth_maxFuel
GLOBAL.ttk_vhth_startFuelIceStar = GLOBAL.ttk_vhth_startFuel
GLOBAL.ttk_vhth_lightRangeIceStar = GLOBAL.ttk_vhth_lightRange
GLOBAL.ttk_vhth_structureSizeIceStar = GLOBAL.ttk_vhth_structureSize
GLOBAL.ttk_vhth_sanityBoostIceStar = GLOBAL.ttk_vhth_sanityBoost
GLOBAL.ttk_vhth_dropLootIceStar = GLOBAL.ttk_vhth_dropLoot
GLOBAL.ttk_vhth_burnRateIceStar = 1

-- Ice Star recipe
local RecipeIngredients = {
		Ingredient("cutstone", 30),
		Ingredient("transistor", 3),
		Ingredient("bluegem", 2)
	}
local techLevel = TECH.MAGIC_TWO

AddRecipe2(
	"ice_star",
	RecipeIngredients,
	techLevel,
	{
		placer = "ice_star_placer",
		atlas = "images/inventoryimages/ice_star.xml",
		image = "ice_star.tex"
	},
	{"LIGHT", "STRUCTURES", "SUMMER"}
)

-- Tên và lời mô tả hiển thị bằng tiếng Việt.
local fire_names = {
    DELUXE_FIREPIT = {"Bếp Thần Hỏa", "Bếp lửa bền bỉ, không bị máy phóng băng dập tắt."},
    ENDO_FIREPIT = {"Bếp Hàn Hỏa", "Ngọn lửa lạnh giúp xua tan cái nóng."},
    HEAT_STAR = {"Vĩnh Hằng Thần Hỏa", "Linh hỏa tỏa sáng và sưởi ấm một vùng rộng lớn."},
    ICE_STAR = {"Vĩnh Hằng Hàn Hỏa", "Linh hỏa lạnh soi sáng và làm mát xung quanh."},
}
for key, info in pairs(fire_names) do
    STRINGS.NAMES[key] = info[1]
    STRINGS.RECIPE_DESC[key] = info[2]
    for _, character in pairs(STRINGS.CHARACTERS) do
        if character.DESCRIBE then
            character.DESCRIBE[key] = {
                OUT = "Linh hỏa đã tắt. Cần thêm nhiên liệu.",
                EMBERS = "Chỉ còn chút ánh lửa le lói.",
                LOW = "Linh hỏa đang cháy nhẹ.",
                NORMAL = "Linh hỏa tỏa sáng ổn định.",
                HIGH = "Linh hỏa đang bừng sáng!",
            }
        end
    end
end
