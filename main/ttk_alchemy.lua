local G = GLOBAL
local containers = G.require("containers")
local Defs = G.require("alchemy/ttk_alchemy_defs")

for prefab, row in pairs(Defs.by_prefab) do
    local animation = prefab:match("^xd_dy_(%w+)_1$") or "dmhsd"
    local image = "xd_dy_" .. animation .. "_5"
    RegisterInventoryItemAtlas("images/inventoryimages/" .. image .. ".xml", image .. ".tex")
    G.STRINGS.NAMES[string.upper(prefab)] = row.name
end

local cultivation_pills = {}
for stage = 1, 15 do
    local row = Defs.GetCultivationStage(stage)
    cultivation_pills[row.prefab] = true
end

-- Both native CanEat (action eligibility) and PrefersToEat (Eat's final
-- pre-consumption check) call TestFood. A rejected pill must never reach
-- Edible:OnEaten or HandleEatRemove, which cannot veto consumption.
AddComponentPostInit("eater", function(self)
    if not TheWorld.ismastersim or self._ttk_cultivation_food_hook then return end
    self._ttk_cultivation_food_hook = true
    local test = self.TestFood
    self.TestFood = function(eater, food, ...)
        if food ~= nil and cultivation_pills[food.prefab] then
            local cultivation = eater.inst.components.ttk_cultivation
            if cultivation == nil or not cultivation:CanConsume(food.prefab) then return false end
        end
        return test(eater, food, ...)
    end
end)

table.insert(Assets, Asset("ANIM", "anim/ui_xd_liandanlu_1x4.zip"))

containers.params.xd_liandanlu = {
    widget = {
        slotpos = { G.Vector3(-55, 0, 0), G.Vector3(-18, 0, 0), G.Vector3(18, 0, 0), G.Vector3(55, 0, 0) },
        animbank = "ui_xd_liandanlu_1x4",
        animbuild = "ui_xd_liandanlu_1x4",
        pos = G.Vector3(0, 200, 0),
    },
    type = "chest",
}

G.STRINGS.NAMES.XD_LIANDANLU = "Đan Lô"
G.STRINGS.RECIPE_DESC.XD_LIANDANLU = "Luyện đan chính xác trong 180 giây."
G.STRINGS.CHARACTERS.GENERIC.DESCRIBE.XD_LIANDANLU = "Một lò luyện đan ổn định."

AddRecipe2("xd_liandanlu", {
    G.Ingredient("goldnugget", 5),
    G.Ingredient("cutstone", 3),
    G.Ingredient("flint", 3),
    G.Ingredient("ttk_lingshi1", 5),
}, G.TECH.SCIENCE_TWO, {
    atlas = "images/inventoryimages/xd_liandanlu.xml",
    image = "xd_liandanlu.tex",
    placer = "xd_liandanlu_placer",
    no_deconstruction = true,
}, { "STRUCTURES", "MAGIC" })

local refine = G.Action({ priority = 1, rmb = true, mount_valid = true })
refine.id = "TTK_ALCHEMY_REFINE"
refine.fn = function(action)
    if not TheWorld.ismastersim or action.target == nil or action.target.components == nil then return false end
    local station = action.target.components.ttk_alchemy_station
    return station ~= nil and station:Start(action.doer) or false
end
AddAction(refine)
G.STRINGS.ACTIONS.TTK_ALCHEMY_REFINE = "Luyện Đan"
AddComponentAction("SCENE", "container", function(inst, doer, actions, right)
    if right and inst:HasTag("ttk_alchemy_station") then table.insert(actions, refine) end
end)
for _, stategraph in ipairs({ "wilson", "wilson_client" }) do
    AddStategraphActionHandler(stategraph, G.ActionHandler(refine, "give"))
end

AddPlayerPostInit(function(inst)
    if not TheWorld.ismastersim then return end
    if inst.components.ttk_cultivation == nil then
        inst:AddComponent("ttk_cultivation")
    end
    if inst.components.ttk_alchemy_effects == nil then
        inst:AddComponent("ttk_alchemy_effects")
    end
end)
