local prefabs = {}

table.insert(prefabs, CreatePrefabSkin("eva_none",
{
	base_prefab = "eva",
	build_name_override = "eva",
	type = "base",
	rarity = "Character",
	skip_item_gen = true,
	skip_giftable_gen = true,
	skin_tags = {"BASE","eva"},
	skins = {
		normal_skin = "eva",
		ghost_skin = "ghost_eva_build",
	}, 
	assets = {
		Asset( "ANIM", "anim/eva.zip" ),
		Asset( "ANIM", "anim/ghost_eva_build.zip" ),
	},
}))

return unpack(prefabs)
