local M = {}

M.SKINS = require("ttk_skin_data")
local BASES = {
    homesign = {bank = "ttt_portal", build = "ttt_portal"},
    -- Defaults whose build is not mechanically derivable from the prefab id.
    ttk_tree_yxs = {bank = "xd_tree_yxs", build = "xd_trees"},
    ttk_flower_md = {bank = "xd_flower_md", build = "xd_flowers"},
    ttk_tinhlakiem = {bank = "xd_xlj", build = "xd_xlj"},
    ttk_votuongkiem = {bank = "xd_wxj", build = "xd_wxj"},
    ttk_thanhtrucphongvankiem = {bank = "xd_htz_qzj", build = "xd_htz_qzj"},
    ttk_tienkiem = {bank = "xd_sword_red", build = "xd_sword_red"},
    ttk_makiem = {bank = "xd_sword_mo", build = "xd_sword_mo"},
    ttk_chuongthienbinh = {bank = "xd_ztp", build = "xd_ztp"},
    nhatvuphuonghoa = {bank = "xd_sudaji_ywfh", build = "xd_sudaji_ywfh"},
    ttk_ngulongdang = {bank = "xd_sudaji_redlantern", build = "xd_sudaji_redlantern", anim = "idle_loop"},
}
for _, skin in ipairs(M.SKINS) do
    if BASES[skin.base] == nil then
        local bank = string.gsub(skin.base, "^ttk_", "xd_")
        local build = string.find(skin.base, "ttk_tree_", 1, true) and "xd_trees"
            or string.find(skin.base, "ttk_flower_", 1, true) and "xd_flowers" or bank
        BASES[skin.base] = {bank = bank, build = build}
    end
end

local SKINS_BY_NAME = {}
for _, skin in ipairs(M.SKINS) do
    SKINS_BY_NAME[skin.name] = skin
end

function M.Get(name)
    return SKINS_BY_NAME[name]
end

function M.GetIconName(name)
    local skin = SKINS_BY_NAME[name]
    return skin ~= nil and (skin.icon_name or name) or nil
end

function M.GetEquipPresentation(inst, default_build, default_symbol)
    local skin_name = inst.GetSkinName ~= nil and inst:GetSkinName() or inst.skinname
    local skin = SKINS_BY_NAME[skin_name or ""]
    local skin_build = inst.GetSkinBuild ~= nil and inst:GetSkinBuild() or nil
    return skin ~= nil and (skin.equip_build or skin_build or skin.build) or skin_build or default_build,
        skin ~= nil and (skin.equip_symbol or default_symbol) or default_symbol
end

local function RefreshDecor(inst)
    if inst.TTKRefreshDecor ~= nil then
        inst:TTKRefreshDecor()
    end
end

function M.Apply(inst, skin_name)
    local skin = SKINS_BY_NAME[skin_name]
    if skin == nil or inst.AnimState == nil then
        return false
    end

    local prefab = string.gsub(inst.prefab or "", "_placer$", "")
    if prefab ~= skin.base then return false end

    -- A non-master world entity receives its replicated skin from the engine.
    -- The placer is local, so it must still apply the selected build client-side.
    if inst.components.placer == nil and not TheWorld.ismastersim then
        return false
    end

    if skin.base == "homesign" then
        require("ttt_portal_visuals").ApplySkin(inst, skin.name)
        return true
    end

    if inst.components.placer == nil and TheWorld.ismastersim then
        require("ttk_skin_effects").Clear(inst)
    end
    local base = BASES[skin.base]
    inst.AnimState:SetBank(skin.apply_ground == false and base.bank or skin.bank or skin.build)
    inst.AnimState:SetBuild(skin.apply_ground == false and base.build or skin.build)
    -- Stateful structures own their current animation. Equipment and weapons
    -- use idle only for their dropped representation.
    if skin.family ~= "staged_structure" and skin.apply_ground ~= false then
        inst.AnimState:PlayAnimation(skin.anim or "idle", true)
    end
    RefreshDecor(inst)
    if inst.components.placer == nil and TheWorld.ismastersim then
        require("ttk_skin_effects").Apply(inst, skin.name)
    end
    return true
end

function M.Clear(inst)
    if inst.AnimState == nil then
        return false
    end

    if inst.components.placer == nil and not TheWorld.ismastersim then
        return false
    end

    if string.gsub(inst.prefab, "_placer$", "") == "homesign" then
        require("ttt_portal_visuals").ApplySkin(inst, nil)
        return true
    end

    local base = BASES[string.gsub(inst.prefab, "_placer$", "")]
    if base == nil then return false end
    inst.AnimState:SetBank(base.bank)
    inst.AnimState:SetBuild(base.build)
    local current = SKINS_BY_NAME[inst.skinname or ""]
    if current == nil or current.family ~= "staged_structure" then
        inst.AnimState:PlayAnimation(base.anim or "idle", true)
    end
    RefreshDecor(inst)
    if inst.components.placer == nil and TheWorld.ismastersim then
        require("ttk_skin_effects").Clear(inst)
    end
    return true
end

local function AddUnique(list, value)
    for _, current in ipairs(list) do
        if current == value then
            return
        end
    end
    table.insert(list, value)
end

local function RegisterSkinMetadata(env, G)
    for _, skin in ipairs(M.SKINS) do
        G.PREFAB_SKINS[skin.base] = G.PREFAB_SKINS[skin.base] or {}
        G.PREFAB_SKINS_IDS[skin.base] = G.PREFAB_SKINS_IDS[skin.base] or {}
        G.STRINGS.SKIN_NAMES[skin.name] = skin.display_name
        G.STRINGS.SKIN_DESCRIPTIONS[skin.name] = "Skin của Tu Tiên Ký; chọn khi chế tạo hoặc đổi bằng Chổi Sạch."
        AddUnique(G.PREFAB_SKINS[skin.base], skin.name)
        for index, name in ipairs(G.PREFAB_SKINS[skin.base]) do
            G.PREFAB_SKINS_IDS[skin.base][name] = index
        end
        env.RegisterInventoryItemAtlas(
            "images/inventoryimages/" .. (skin.icon_name or skin.name) .. ".xml",
            (skin.icon_name or skin.name) .. ".tex"
        )
    end

    -- CreatePrefabSkin resolves this callback by the base prefab name.
    for base in pairs(BASES) do rawset(G, base .. "_clear_fn", M.Clear) end
end

local function InstallOwnershipAdapters(G)
    local inventory = G.TheInventory
    local mt = inventory ~= nil and getmetatable(inventory) or nil
    local index = mt ~= nil and mt.__index or nil
    if type(index) ~= "table" then
        return
    end

    local old_check_ownership = index.CheckOwnership
    local old_check_latest = index.CheckOwnershipGetLatest
    local old_check_client = index.CheckClientOwnership

    index.CheckOwnership = function(self, name, ...)
        if SKINS_BY_NAME[name] ~= nil then
            return true
        end
        return old_check_ownership(self, name, ...)
    end

    index.CheckOwnershipGetLatest = function(self, name, ...)
        if SKINS_BY_NAME[name] ~= nil then
            return true, 0
        end
        return old_check_latest(self, name, ...)
    end

    index.CheckClientOwnership = function(self, userid, name, ...)
        if SKINS_BY_NAME[name] ~= nil then
            return true
        end
        return old_check_client(self, userid, name, ...)
    end
end

local function InstallIconAdapter(G)
    local old_get_skin_icon = G.GetSkinInvIconName
    G.GetSkinInvIconName = function(item, ...)
        if SKINS_BY_NAME[item] ~= nil then
            return M.GetIconName(item)
        end
        return old_get_skin_icon(item, ...)
    end
end

local function InstallSpawnAdapter(G)
    local old_spawn_prefab = G.SpawnPrefab
    G.SpawnPrefab = function(prefab, skin, skin_id, creator, ...)
        local data = SKINS_BY_NAME[skin]
        if data ~= nil and (prefab == data.base or prefab == data.base .. "_placer") then
            skin_id = 0
        end
        return old_spawn_prefab(prefab, skin, skin_id, creator, ...)
    end
end

function M.Install(env)
    local G = env.GLOBAL
    RegisterSkinMetadata(env, G)

    if rawget(G, "__TTK_SKIN_ADAPTERS_INSTALLED") then
        return
    end
    rawset(G, "__TTK_SKIN_ADAPTERS_INSTALLED", true)

    InstallOwnershipAdapters(G)
    InstallIconAdapter(G)
    InstallSpawnAdapter(G)
end

return M
