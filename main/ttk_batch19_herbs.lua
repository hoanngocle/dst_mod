local G = GLOBAL
local SEED_FOODS = G.require("ttk_seed_fooddefs")

for _, prefab in ipairs({"ttk_ylxc", "ttk_ylxq", "ttk_herbs"}) do
    table.insert(PrefabFiles, prefab)
end

local containers = G.require("containers")
local params = containers.params

params.ttk_ylxc = {
    widget = {
        slotpos = {},
        animbank = "ui_chest_3x3",
        animbuild = "xd_ui_6x6",
        pos = G.Vector3(0, 220, 0),
        side_align_tip = 160,
    },
    type = "chest",
}
for y = 4, -1, -1 do
    for x = -1, 4 do
        table.insert(params.ttk_ylxc.widget.slotpos, G.Vector3(80 * x - 120, 80 * y - 120, 0))
    end
end
params.ttk_ylxc.itemtestfn = function(container, item)
    return item ~= nil and item:HasTag("ttk_ylxc_valid")
end
containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, 36)

local structures = {
    ttk_ylxc = {
        name = "Ngọc Lộ Huyền Thương",
        desc = "Kho 36 ô dành cho linh thảo và hạt giống; vật phẩm bên trong không hư hỏng.",
        ingredients = {{"ttk_lingshi2", 3}, {"bluegem", 10}, {"cutstone", 10}, {"boards", 5}},
        filters = {"STRUCTURES", "CONTAINERS", "GARDENING"},
    },
    ttk_ylxq = {
        name = "Ngọc Lộ Tiên Khu",
        desc = "Ươm một hạt linh thảo theo mùa hoặc thời khắc thích hợp.",
        ingredients = {{"ttk_lingshi2", 3}, {"livinglog", 8}, {"cutstone", 5}, {"greengem", 1}},
        filters = {"STRUCTURES", "GARDENING"},
    },
}

local herbs = {
    hsc = {name = "Hàn Sương Thảo", crop_seed = "asparagus_seeds",
        desc = "Linh thảo mùa đông, ăn vào làm lạnh cơ thể."},
    dms = {name = "Địa Mạch Sâm", crop_seed = "carrot_seeds",
        desc = "Linh thảo ban ngày, hồi phục sinh lực từ từ khi ăn."},
    qfx = {name = "Thanh Phong Tiên", crop_seed = "garlic_seeds",
        desc = "Linh thảo chỉ sinh trưởng vào mùa thu."},
    cyh = {name = "Xích Viêm Hoa", crop_seed = "pepper_seeds",
        desc = "Linh thảo mùa hè, ăn vào làm ấm cơ thể."},
    lmg = {name = "Lôi Minh Quả", crop_seed = "pumpkin_seeds",
        desc = "Linh thảo mùa xuân mang theo điện khí."},
    yhh = {name = "U Hồn Hoa", crop_seed = "tomato_seeds",
        desc = "Linh thảo nở trong đêm, đánh đổi tinh thần lấy sinh lực."},
}

local function RegisterText(id, name, desc)
    local key = string.upper(id)
    G.STRINGS.NAMES[key] = name
    G.STRINGS.RECIPE_DESC[key] = desc
    G.STRINGS.CHARACTERS.GENERIC.DESCRIBE[key] = desc
end

for id, def in pairs(structures) do
    RegisterText(id, def.name, def.desc)
    local atlas = "images/inventoryimages/" .. id .. ".xml"
    RegisterInventoryItemAtlas(atlas, id .. ".tex")
    AddMinimapAtlas("images/map_icons/" .. id .. ".xml")
    local ingredients = {}
    for _, ingredient in ipairs(def.ingredients) do
        table.insert(ingredients, G.Ingredient(ingredient[1], ingredient[2]))
    end
    AddRecipe2(id, ingredients, G.TECH.SCIENCE_ONE, {
        atlas = atlas,
        image = id .. ".tex",
        placer = id .. "_placer",
        min_spacing = 2,
        no_deconstruction = true,
    }, def.filters)
end

for suffix, def in pairs(herbs) do
    local herb = "ttk_lc_" .. suffix
    local seed = herb .. "_seed"
    RegisterText(herb, def.name, def.desc)
    local food = SEED_FOODS[suffix]
    local recovery = food.health + food.hunger + food.sanity
    RegisterText(seed, food.name, "Ăn trực tiếp hồi " .. recovery .. " " .. food.stat
        .. ". Có thể gieo trong Ngọc Lộ Tiên Khu.")
    RegisterText("ttk_plant_" .. suffix, "Cây " .. def.name, "Linh thảo đang sinh trưởng trong tiên khu.")
    RegisterInventoryItemAtlas("images/inventoryimages/" .. herb .. ".xml", herb .. ".tex")
    RegisterInventoryItemAtlas("images/inventoryimages/" .. seed .. ".xml", seed .. ".tex")
    AddRecipe2(seed, {
        G.Ingredient(def.crop_seed, 1),
        G.Ingredient("ttk_lingshi1", 1),
    }, G.TECH.SCIENCE_TWO, {
        atlas = "images/inventoryimages/" .. seed .. ".xml",
        image = seed .. ".tex",
        no_deconstruction = true,
    }, {"GARDENING", "REFINE"})
end

local plant = G.Action({priority = -1, mount_valid = true})
plant.id = "TTK_LC_PLANT"
plant.str = "Gieo linh thảo"
plant.fn = function(act)
    local target, seed, doer = act.target, act.invobject, act.doer
    if target == nil or seed == nil or doer == nil
        or target.components.ttk_ylxq_grower == nil
        or doer.components.inventory == nil
        or doer:GetDistanceSqToInst(target) > 16
        or not seed:HasTag("ttk_lc_seed") then
        return false
    end
    seed = doer.components.inventory:RemoveItem(seed)
    if seed == nil then
        return false
    end
    if target.components.ttk_ylxq_grower:PlantItem(seed, doer) then
        return true
    end
    doer.components.inventory:GiveItem(seed)
    return false
end
AddAction(plant)

local infuse = G.Action({priority = -1, mount_valid = true})
infuse.id = "TTK_INFUSE_YLXQ"
infuse.str = "Nạp linh khí"
infuse.fn = function(act)
    local target, stone, doer = act.target, act.invobject, act.doer
    local grower = target ~= nil and target.components.ttk_ylxq_grower or nil
    if grower == nil or stone == nil or stone.prefab ~= "ttk_lingshi1" or doer == nil
        or doer.components.inventory == nil or doer:GetDistanceSqToInst(target) > 16
        or grower.current >= grower.max then
        return false
    end
    local removed = doer.components.inventory:RemoveItem(stone)
    if removed == nil then return false end
    grower:AddCharge(25)
    if removed.components.stackable ~= nil then
        removed.components.stackable:Get():Remove()
    else
        removed:Remove()
    end
    return true
end
AddAction(infuse)

AddComponentAction("USEITEM", "inventoryitem", function(inst, doer, target, actions)
    if target == nil then return end
    if inst:HasTag("ttk_lc_seed") and target:HasTag("ttk_ylxq_grower") then
        table.insert(actions, plant)
    elseif inst.prefab == "ttk_lingshi1" and target:HasTag("ttk_ylxq_chargeable") then
        table.insert(actions, infuse)
    end
end)
AddStategraphActionHandler("wilson", G.ActionHandler(plant, "give"))
AddStategraphActionHandler("wilson_client", G.ActionHandler(plant, "give"))
AddStategraphActionHandler("wilson", G.ActionHandler(infuse, "give"))
AddStategraphActionHandler("wilson_client", G.ActionHandler(infuse, "give"))
