local M = {}
local BANK = "ttt_portal"
local ICON_ATLAS = "images/ttt_portal/icon.xml"
local ICON = "ttt_portal_icon.tex"
local ANCIENT_SKIN = "ttt_portal_gcsz"
local ANCIENT_ICON = "ttt_portal_gcsz.tex"

local function RefreshAppearance(inst, skin_name)
    local ancient = skin_name == ANCIENT_SKIN
    local burnt = inst:HasTag("burnt")
    inst._ttt_portal_ancient = ancient
    local bank = ancient and not burnt and ANCIENT_SKIN or BANK
    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(bank)
    inst.Transform:SetScale(ancient and not burnt and 1.25 or 1,
        ancient and not burnt and 1.25 or 1, ancient and not burnt and 1.25 or 1)
    local animation = burnt and "burnt"
        or ancient and inst._ttt_portal_near and "proximity_loop" or "idle"
    inst.AnimState:PlayAnimation(animation, not burnt)
    if inst.MiniMapEntity ~= nil then
        inst.MiniMapEntity:SetIcon(ancient and not burnt and ANCIENT_ICON or ICON)
    end
    local writeable = inst.components.writeable
    if burnt or writeable ~= nil and writeable:GetText() == nil then
        inst.AnimState:Hide("WRITING")
    else
        inst.AnimState:Show("WRITING")
    end
end

function M.ApplySkin(inst, skin_name)
    -- Skin callbacks also run for the local placement preview.
    if inst.components.placer == nil and not TheWorld.ismastersim then return end
    inst._ttt_portal_selected_skin = skin_name or false
    RefreshAppearance(inst, skin_name)
end

local function CurrentSkin(inst)
    if inst._ttt_portal_selected_skin ~= nil then
        return inst._ttt_portal_selected_skin or nil
    end
    return inst:GetSkinName()
end


local function CleanName(text)
    if type(text) ~= "string" then return "" end
    return text:gsub("[\r\n\t]", " "):utf8sub(1, 32)
end

local function UpdateLabel(inst)
    if not inst._ttt_portal_owns_label then return end
    local text = inst._ttt_portal_name:value()
    inst.Label:SetText(text)
    inst.Label:Enable(text ~= "" and not inst:HasTag("burnt"))
end

local function SyncName(inst)
    local writeable = inst.components.writeable
    local text = writeable ~= nil and CleanName(writeable:GetText()) or ""
    if inst:HasTag("burnt") then text = "" end
    inst._ttt_portal_name:set(text)
    UpdateLabel(inst)
end

function M.Apply(inst)
    RefreshAppearance(inst, CurrentSkin(inst))
    -- Created on both server and client, with a unique name and identical order.
    inst._ttt_portal_name = net_string(inst.GUID, "ttt_portal.name", "ttt_portal_name_dirty")
    if not TheNet:IsDedicated() and inst.Label == nil then
        inst.entity:AddLabel()
        inst._ttt_portal_owns_label = true
        inst.Label:SetFont(DEFAULTFONT)
        inst.Label:SetFontSize(22)
        inst.Label:SetWorldOffset(0, 3.1, 0)
        inst.Label:SetColour(0.91, 0.85, 0.72)
        inst.Label:Enable(false)
        inst:ListenForEvent("ttt_portal_name_dirty", UpdateLabel)
    end

    if not TheWorld.ismastersim then
        inst:DoTaskInTime(0, UpdateLabel)
        return
    end

    -- Track proximity even on the default skin, so switching skins nearby works.
    if inst.components.playerprox == nil then
        inst:AddComponent("playerprox")
        inst.components.playerprox:SetDist(4, 6)
        inst.components.playerprox:SetOnPlayerNear(function(entity)
            entity._ttt_portal_near = true
            if entity._ttt_portal_ancient and not entity:HasTag("burnt") then
                entity.AnimState:PlayAnimation("proximity_loop", true)
            end
        end)
        inst.components.playerprox:SetOnPlayerFar(function(entity)
            entity._ttt_portal_near = false
            if entity._ttt_portal_ancient and not entity:HasTag("burnt") then
                entity.AnimState:PlayAnimation("idle", true)
            end
        end)
    end

    local writeable = inst.components.writeable
    if writeable ~= nil then
        local old_set_text = writeable.SetText
        writeable.SetText = function(self, text, ...)
            old_set_text(self, text, ...)
            SyncName(inst)
        end
        if writeable:GetText() == nil then inst.AnimState:Hide("WRITING") end
    end
    local old_load = inst.OnLoad
    inst.OnLoad = function(entity, data, ...)
        if old_load ~= nil then old_load(entity, data, ...) end
        entity:DoTaskInTime(0, SyncName)
    end
    local burnable = inst.components.burnable
    if burnable ~= nil then
        local old_burnt = burnable.onburnt
        burnable:SetOnBurntFn(function(entity, ...)
            if old_burnt ~= nil then old_burnt(entity, ...) end
            if entity:IsValid() then
                RefreshAppearance(entity, CurrentSkin(entity))
                entity.AnimState:Hide("WRITING")
                SyncName(entity)
            end
        end)
    end
    inst:ListenForEvent("animover", function(entity)
        if not entity:HasTag("burnt") and entity.AnimState:IsCurrentAnimation("idle") then
            entity.AnimState:PlayAnimation(
                entity._ttt_portal_ancient and entity._ttt_portal_near and "proximity_loop" or "idle", true)
        end
    end)
    inst:DoTaskInTime(0, SyncName)
end

function M.ApplyPlacer(inst)
    RefreshAppearance(inst, CurrentSkin(inst))
end

function M.Register(env, points)
    local G = env.GLOBAL
    env.RegisterInventoryItemAtlas(ICON_ATLAS, ICON)
    env.AddMinimapAtlas(ICON_ATLAS)
    env.AddMinimapAtlas("images/inventoryimages/ttt_portal_gcsz.xml")
    for _, prefab in ipairs(points) do
        G.STRINGS.NAMES[string.upper(prefab)] = "Truyền Tống Trận"
        G.STRINGS.RECIPE_DESC[string.upper(prefab)] = "Đặt tên cổng và kết nối các điểm dịch chuyển."
        env.AddRecipePostInit(prefab, function(recipe)
            recipe.ingredients = { G.Ingredient("boards", 5), G.Ingredient("goldnugget", 5) }
            recipe.atlas = ICON_ATLAS
            recipe.image = ICON
        end)
        env.AddPrefabPostInit(prefab .. "_placer", M.ApplyPlacer)
    end
end

return M
