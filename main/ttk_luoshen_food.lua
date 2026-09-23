local G = GLOBAL
local foods = G.require("ttk_luoshen_fooddefs")
table.insert(PrefabFiles, "ttk_luoshen_food")
local names = {
    ttk_luoshen_qingshu = "Lạc Thần Thanh Sơ",
    ttk_luoxiang_pengrou = "Lạc Hương Phanh Nhục",
}
local descriptions = {
    ttk_luoshen_qingshu = "Hương hoa thanh u, giòn mềm và ngọt thanh.",
    ttk_luoxiang_pengrou = "Hương hoa quyện thịt; đánh mục tiêu còn sống hồi 2 máu trong 480 giây.",
}
AddIngredientValues({"ttk_luoshen_huayin"}, {inedible = 1})
for name, recipe in pairs(foods) do
    local atlas = "images/inventoryimages/" .. name .. ".xml"
    G.STRINGS.NAMES[string.upper(name)] = names[name]
    G.STRINGS.CHARACTERS.GENERIC.DESCRIBE[string.upper(name)] = descriptions[name]
    table.insert(Assets, G.Asset("ATLAS", atlas))
    table.insert(Assets, G.Asset("IMAGE", "images/inventoryimages/" .. name .. ".tex"))
    table.insert(Assets, G.Asset("ANIM", "anim/" .. recipe.overridebuild .. ".zip"))
    RegisterInventoryItemAtlas(atlas, name .. ".tex")
    for _, cooker in ipairs({"cookpot", "portablecookpot", "archive_cookpot"}) do
        AddCookerRecipe(cooker, recipe)
    end
end
