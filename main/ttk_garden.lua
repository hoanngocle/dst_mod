local G = GLOBAL
table.insert(PrefabFiles, "ttk_garden")
table.insert(PrefabFiles, "ttk_huapen")
table.insert(PrefabFiles, "ttk_luoshen_hua")
local definitions = {
    ttk_tree_df = {
        name = "Đan Phong", desc = "Cây phong giữ khí hậu ôn hòa, kết ngọc đỏ.",
        ingredients = {{"livinglog", 4}, {"redgem", 8}, {"ttk_lingshi1", 1}},
        tech = G.TECH.SCIENCE_TWO, spacing = 3, filters = {"STRUCTURES", "DECOR"}, map = true,
    },
    ttk_tree_yhs = {
        name = "Anh Đào Thụ", desc = "Cây anh đào giữ khí hậu ôn hòa, kết ngọc tím.",
        ingredients = {{"livinglog", 4}, {"purplegem", 4}, {"ttk_lingshi1", 1}},
        tech = G.TECH.SCIENCE_TWO, spacing = 3, filters = {"STRUCTURES", "DECOR"}, map = true,
    },
    ttk_tree_ls = {
        name = "Lam Sam", desc = "Cây giữ khí hậu ôn hòa, kết Ngọc Xanh Dương.",
        ingredients = {{"livinglog", 4}, {"bluegem", 2}, {"ttk_lingshi1", 1}},
        tech = G.TECH.SCIENCE_TWO, spacing = 3, filters = {"STRUCTURES", "DECOR"}, map = true,
    },
    ttk_tree_yxs = {
        name = "Ngân Hạnh", desc = "Cây giữ khí hậu ôn hòa, kết Ngọc Cam.",
        ingredients = {{"livinglog", 4}, {"orangegem", 2}, {"ttk_lingshi1", 1}},
        tech = G.TECH.SCIENCE_TWO, spacing = 3, filters = {"STRUCTURES", "DECOR"}, map = true,
    },
    ttk_flower_bh = {
        name = "Bách Hợp", desc = "Hoa thơm dưỡng thần, thu hút bướm.",
        ingredients = {{"butterfly", 2}, {"purplegem", 2}, {"ttk_lingshi1", 1}}, map = true,
    },
    ttk_flower_bmg = {
        name = "Bạch Mân Côi", desc = "Sắc hoa thanh nhã, làm dịu tinh thần.",
        ingredients = {{"butterfly", 2}, {"yellowgem", 2}, {"ttk_lingshi1", 1}}, map = true,
    },
    ttk_flower_pgy = {
        name = "Bồ Công Anh", desc = "Những cánh hoa nhẹ như bông.",
        ingredients = {{"butterfly", 2}, {"log", 12}, {"ttk_lingshi1", 1}}, map = true,
    },
    ttk_flower_ll = {
        name = "Linh Lan", desc = "Hoa thơm dưỡng thần, thu hút bướm.",
        ingredients = {{"butterfly", 2}, {"twigs", 15}, {"ttk_lingshi1", 1}}, map = true,
    },
    ttk_flower_md = {
        name = "Mẫu Đơn", desc = "Hoa thơm dưỡng thần, thu hút bướm.",
        ingredients = {{"butterfly", 2}, {"redgem", 3}, {"ttk_lingshi1", 1}}, map = true,
    },
    ttk_flower_mlh = {
        name = "Mộc Lê Hoa", desc = "Hoa thơm dưỡng thần, thu hút bướm.",
        ingredients = {{"butterfly", 2}, {"greengem", 1}, {"ttk_lingshi1", 1}}, map = true,
    },
    ttk_gj = {
        name = "Cam Tỉnh", desc = "Giếng nước để nạp đầy bình tưới.",
        ingredients = {{"rocks", 12}, {"rope", 1}, {"log", 11}, {"ttk_lingshi1", 1}},
        filters = {"STRUCTURES", "GARDENING"}, map = true,
    },
    ttk_huapen = {
        name = "Chậu Hoa Uẩn Linh", desc = "Trồng rau và dưỡng cây bằng linh thạch.",
        ingredients = {{"livinglog", 1}, {"cutstone", 2}, {"ttk_lingshi1", 3}},
        spacing = 1, filters = {"STRUCTURES", "GARDENING"}, no_deconstruction = true,
    },

}
for name, def in pairs(definitions) do
    local key = string.upper(name)
    G.STRINGS.NAMES[key] = def.name
    G.STRINGS.RECIPE_DESC[key] = def.desc
    G.STRINGS.CHARACTERS.GENERIC.DESCRIBE[key] = def.desc
    local atlas = "images/inventoryimages/" .. name .. ".xml"
    RegisterInventoryItemAtlas(atlas, name .. ".tex")
    if def.map then AddMinimapAtlas("images/map_icons/" .. name .. ".xml") end
    local ingredients = {}
    for _, ingredient in ipairs(def.ingredients) do
        table.insert(ingredients, G.Ingredient(ingredient[1], ingredient[2]))
    end
    AddRecipe2(name, ingredients, def.tech or G.TECH.SCIENCE_ONE, {
        atlas = atlas, image = name .. ".tex",
        placer = not def.inventory and name .. "_placer" or nil,
        min_spacing = def.spacing or 2,
        no_deconstruction = def.no_deconstruction,
    }, def.filters or {"DECOR", "GARDENING"})
end

-- Lạc Thần Hoa keeps the source's seed -> five growth stages -> daily flower
-- path. Both the imported bottle and Hạ Phẩm Linh Thạch can nurture it.
G.STRINGS.NAMES.TTK_LUOSHEN_HUA = "Lạc Thần Hoa"
G.STRINGS.RECIPE_DESC.TTK_LUOSHEN_HUA = "Dưỡng thành linh hoa năm tầng."
G.STRINGS.CHARACTERS.GENERIC.DESCRIBE.TTK_LUOSHEN_HUA = "Dưỡng bằng Chưởng Thiên Bình hoặc Hạ Phẩm Linh Thạch; hoa trưởng thành cho Hoa Nhân."
G.STRINGS.NAMES.TTK_LUOSHEN_HUAZHONG = "Hạt Giống Lạc Thần Hoa"
G.STRINGS.RECIPE_DESC.TTK_LUOSHEN_HUAZHONG = "Gieo để trồng Lạc Thần Hoa."
G.STRINGS.CHARACTERS.GENERIC.DESCRIBE.TTK_LUOSHEN_HUAZHONG = "Một hạt giống chứa linh khí."
G.STRINGS.NAMES.TTK_LUOSHEN_HUAYIN = "Lạc Thần Hoa Nhân"
G.STRINGS.CHARACTERS.GENERIC.DESCRIBE.TTK_LUOSHEN_HUAYIN = "Nấu không có thịt thành Thanh Sơ; nấu cùng thịt thành Lạc Hương Phanh Nhục."
RegisterInventoryItemAtlas("images/inventoryimages/ttk_luoshen_huazhong.xml", "ttk_luoshen_huazhong.tex")
RegisterInventoryItemAtlas("images/inventoryimages/ttk_luoshen_huayin.xml", "ttk_luoshen_huayin.tex")
AddMinimapAtlas("images/map_icons/ttk_luoshen_hua.xml")
AddRecipe2("ttk_luoshen_huazhong", {
    G.Ingredient("petals", 60),
    G.Ingredient("plantmeat", 3),
    G.Ingredient("ttk_lingshi2", 1),
}, G.TECH.SCIENCE_TWO, {
    atlas = "images/inventoryimages/ttk_luoshen_huazhong.xml",
    image = "ttk_luoshen_huazhong.tex",
    no_deconstruction = true,
}, {"GARDENING", "REFINE"})

local params = G.require("containers").params
params.ttk_luoshen_hua = {
    widget = {slotpos = {}, animbank = "ui_chest_3x3", animbuild = "ui_chest_3x3",
        pos = G.Vector3(0, 200, 0), side_align_tip = 160},
    type = "chest",
}
for y = 2, 0, -1 do
    for x = 0, 2 do
        table.insert(params.ttk_luoshen_hua.widget.slotpos, G.Vector3(80 * x - 80, 80 * y - 80, 0))
    end
end

local nurture = G.Action({priority = 2, mount_valid = true})
nurture.id = "TTK_NURTURE_LUOSHEN"
nurture.str = "Dưỡng hoa"
nurture.fn = function(act)
    local flower, stone, doer = act.target, act.invobject, act.doer
    if flower == nil or flower.prefab ~= "ttk_luoshen_hua" or flower.Nurture == nil
        or stone == nil or stone.prefab ~= "ttk_lingshi1" or doer == nil
        or doer:GetDistanceSqToInst(flower) > 16 or not flower:Nurture(doer) then
        return false
    end
    if stone.components.stackable ~= nil then stone.components.stackable:Get():Remove() else stone:Remove() end
    return true
end
AddAction(nurture)
AddComponentAction("USEITEM", "inventoryitem", function(inst, doer, target, actions)
    if inst.prefab == "ttk_lingshi1" and target ~= nil and target:HasTag("ttk_luoshen_growing") then
        table.insert(actions, nurture)
    end
end)
AddStategraphActionHandler("wilson", G.ActionHandler(nurture, "give"))
AddStategraphActionHandler("wilson_client", G.ActionHandler(nurture, "give"))

-- All farm and stress changes are scoped to this pot or a crop linked to it.
AddComponentPostInit("farmplantable", function(self)
    local original = self.Plant
    self.Plant = function(component, target, planter, ...)
        if target ~= nil and target.prefab == "ttk_huapen" and target.PlantSeed ~= nil then
            return target:PlantSeed(component, planter)
        end
        return original(component, target, planter, ...)
    end
end)

AddComponentPostInit("farmplantstress", function(self)
    local original = self.CalcFinalStressState
    self.CalcFinalStressState = function(component, ...)
        local pot = component.inst._ttk_pot
        if pot ~= nil and pot:IsValid() and pot.components.finiteuses:GetUses() > 0 then
            component.inst.no_oversized = false
            component.final_stress_state = G.FARM_PLANT_STRESS.NONE
            return component.final_stress_state
        end
        return original(component, ...)
    end
end)

local refill = G.Action({priority = -1, mount_valid = true})
refill.id = "TTK_REFILL_FLOWERPOT"
refill.str = "Uẩn linh"
refill.fn = function(act)
    local target, stone = act.target, act.invobject
    local pot = target ~= nil and (target.prefab == "ttk_huapen" and target or target._ttk_pot) or nil
    if pot == nil or not pot:IsValid() or stone == nil or stone.prefab ~= "ttk_lingshi1"
        or pot.components.finiteuses:GetUses() > 0 then
        return false
    end
    pot:Refill()
    if stone.components.stackable ~= nil then stone.components.stackable:Get():Remove() else stone:Remove() end
    return true
end
AddAction(refill)
AddComponentAction("USEITEM", "inventoryitem", function(inst, doer, target, actions)
    if inst.prefab == "ttk_lingshi1" and target ~= nil and target:HasTag("ttk_huapen_empty") then
        table.insert(actions, refill)
    end
end)
AddStategraphActionHandler("wilson", G.ActionHandler(refill, "give"))
AddStategraphActionHandler("wilson_client", G.ActionHandler(refill, "give"))

-- Preserve the source pot's protection from lunar plant invasions, only for potted crops.
local function Potted(plant)
    return plant ~= nil and plant:HasTag("ttk_pottedplant")
end
AddComponentPostInit("lunarthrall_plantspawner", function(self)
    for _, name in ipairs({"SpawnPlant", "SpawnGestalt", "InvadeTarget"}) do
        local original = self[name]
        if original ~= nil then
            self[name] = function(component, target, ...)
                if not Potted(target) then return original(component, target, ...) end
                if component.targetedplants ~= nil then component.targetedplants[target.GUID] = nil end
            end
        end
    end
end)
