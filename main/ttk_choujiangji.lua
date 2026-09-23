local G = GLOBAL
G.require("ttk_slot_bosses").Install(env)
table.insert(PrefabFiles, "ttk_choujiangji")
table.insert(Assets, G.Asset("SOUNDPACKAGE", "sound/ttk_choujiangji.fev"))
table.insert(Assets, G.Asset("SOUND", "sound/choujiangji_sound.fsb"))
AddMinimapAtlas("images/map_icons/ttk_choujiangji.xml")
RegisterInventoryItemAtlas("images/map_icons/ttk_choujiangji.xml", "ttk_choujiangji.tex")
G.STRINGS.NAMES.TTK_CHOUJIANGJI = "Máy Quay Thưởng Linh Thạch"
G.STRINGS.RECIPE_DESC.TTK_CHOUJIANGJI = "Mỗi lượt 1 Trung Phẩm Linh Thạch. Có thể gọi quái!"
G.STRINGS.CHARACTERS.GENERIC.DESCRIBE.TTK_CHOUJIANGJI = {
    GENERIC="Đưa 1 Trung Phẩm Linh Thạch để quay. Quà quý hoặc một trận chiến!",
    BUSY="Máy đang quay hoặc trả thưởng. Chờ xong lượt này đã.",
}
AddRecipe2("ttk_choujiangji", {
    G.Ingredient("cutstone",6), G.Ingredient("boards",4),
    G.Ingredient("gears",2), G.Ingredient("purplegem",1),
    G.Ingredient("ttk_lingshi1",30),
}, G.TECH.SCIENCE_TWO, {
    atlas="images/map_icons/ttk_choujiangji.xml", image="ttk_choujiangji.tex",
    placer="ttk_choujiangji_placer", min_spacing=3,
}, {"STRUCTURES", "MAGIC"})
