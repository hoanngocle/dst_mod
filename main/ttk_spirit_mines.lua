local G = GLOBAL
table.insert(PrefabFiles, "ttk_spirit_mines")
table.insert(PrefabFiles, "ttk_spirit_workshop")
local defs = G.require("ttk_mine_defs")
for tier, def in ipairs(defs) do
    local name = "ttk_rock" .. tier
    local key = string.upper(name)
    local atlas = "images/map_icons/" .. name .. ".xml"
    G.STRINGS.NAMES[key] = def.name
    G.STRINGS.CHARACTERS.GENERIC.DESCRIBE[key] = {
        GENERIC = "Mỏ tự nhiên. Khai thác hết sẽ biến mất; mùa mới lại có mỏ mới.",
        CRAFTED = "Linh mạch đã dựng. Khai thác hết sẽ tự hồi sau " .. def.days .. " ngày.",
        EXHAUSTED = "Linh mạch đang tích tụ linh khí, chưa thể khai thác.",
    }
    AddMinimapAtlas(atlas)
end

G.STRINGS.NAMES.TTK_SPIRIT_WORKSHOP = "Linh Tuyền Cực Phẩm"
G.STRINGS.RECIPE_DESC.TTK_SPIRIT_WORKSHOP = "Linh tuyền kết tinh linh thạch để thu hoạch mỗi 5 ngày."
G.STRINGS.CHARACTERS.GENERIC.DESCRIBE.TTK_SPIRIT_WORKSHOP = {
    READY = "Linh thạch đã kết tinh, có thể thu hoạch rồi!",
    GROWING = "Đang tụ linh khí. Mỗi đợt cần 5 ngày để kết tinh.",
}
local atlas = "images/ttk_spirit_workshop/icon.xml"
RegisterInventoryItemAtlas(atlas, "ttk_spirit_workshop.tex")
AddMinimapAtlas(atlas)
AddRecipe2("ttk_spirit_workshop", {
    G.Ingredient("cutstone", 20), G.Ingredient("boards", 6),
    G.Ingredient("purplegem", 2), G.Ingredient("ttk_lingshi2", 5), G.Ingredient("ttk_lingshi3", 1),
}, G.TECH.SCIENCE_TWO, {
    atlas = atlas, image = "ttk_spirit_workshop.tex", placer = "ttk_spirit_workshop_placer",
    min_spacing = 5, no_deconstruction = true,
}, {"STRUCTURES", "REFINE"})
AddPrefabPostInit("world", function(inst)
    if inst.ismastersim and not inst:HasTag("cave") then
        inst:AddComponent("ttk_mineseeder")
    end
end)
