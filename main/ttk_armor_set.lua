local G = GLOBAL
local definitions = {
    {"ttk_zcmj", "Tử Xá Diện Giáp", "Giáp 90%, tăng 20% sát thương; kết giới khi mặc cùng Tà Sát Hộ Giáp.",
        {{"ttk_boss_zcmy",1},{"purplegem",2},{"yellowgem",2},{"ttk_lingshi3",1}}, {"ARMOUR","MAGIC"}, G.TECH.LOST},
    {"ttk_xshj", "Tà Sát Hộ Giáp", "Giáp 90%, tăng 10% tốc độ; tự phục hồi độ bền.",
        {{"ttk_boss_mgqg",1},{"armor_skeleton",1},{"orangegem",2},{"greengem",2}}, {"ARMOUR","MAGIC"}, G.TECH.LOST},
    {"ttk_yunxiao_ymsz", "Vân Mạc Thượng Trang", "Giáp 85%, giữ ấm 240; phát sáng bán kính 5.",
        {{"beefalowool",8},{"goldnugget",10},{"ttk_lingshi2",2}}, {"ARMOUR","CLOTHING","WINTER","LIGHT"}},
}
for _, def in ipairs(definitions) do
    local name, key = def[1], string.upper(def[1])
    table.insert(PrefabFiles, name)
    G.STRINGS.NAMES[key] = def[2]
    G.STRINGS.RECIPE_DESC[key] = def[3]
    G.STRINGS.CHARACTERS.GENERIC.DESCRIBE[key] = def[3]
    local atlas = "images/inventoryimages/" .. name .. ".xml"
    RegisterInventoryItemAtlas(atlas, name .. ".tex")
    local ingredients = {}
    for _, ingredient in ipairs(def[4]) do
        table.insert(ingredients, G.Ingredient(ingredient[1], ingredient[2]))
    end
    AddRecipe2(name, ingredients, def[6] or G.TECH.NONE, {
        atlas = atlas, image = name .. ".tex", no_deconstruction = true,
    }, def[5])
end

-- Original set shield blocks inventory-routed normal and special damage while active.
-- Wrap once for this component and delegate normally outside our own shield window.
AddComponentPostInit("inventory", function(self)
    local original = self.ApplyDamage
    self.ApplyDamage = function(inventory, ...)
        if inventory:EquipHasTag("ttk_avoid_damage") then
            return 0, nil
        end
        return original(inventory, ...)
    end
end)
