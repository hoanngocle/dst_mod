local skin_support = require("ttk_skins")

local prefabs = {}

for _, skin_data in ipairs(skin_support.SKINS) do
    local skin = skin_data
    local asset_name = skin.asset_name or skin.name
    local assets = {
        Asset("ANIM", "anim/" .. asset_name .. ".zip"),
        Asset("ATLAS", "images/inventoryimages/" .. (skin.icon_name or asset_name) .. ".xml"),
        Asset("IMAGE", "images/inventoryimages/" .. (skin.icon_name or asset_name) .. ".tex"),
    }
    for _, extra in ipairs(skin.extra_anims or {}) do
        table.insert(assets, Asset("ANIM", "anim/" .. extra .. ".zip"))
    end

    local function InitSkin(inst)
        skin_support.Apply(inst, skin.name)
    end

    table.insert(prefabs, CreatePrefabSkin(skin.name, {
        base_prefab = skin.base,
        type = "item",
        rarity = "Loyal",
        skin_tags = { "CRAFTABLE" },
        build_name_override = skin.build,
        assets = assets,
        init_fn = InitSkin,
    }))
end

return unpack(prefabs)
