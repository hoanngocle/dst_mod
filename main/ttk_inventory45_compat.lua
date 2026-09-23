-- Appearance priority for relocated equipment: BODY, then BACK, then NECK.
local G = GLOBAL

local function snapshot(anim, target)
    local build, symbol = anim:GetSymbolOverride(target)
    return {build = build, symbol = symbol, skin = build ~= nil and anim:IsSkinBuild(build)}
end

local function restore(anim, target, visual)
    if visual.build == nil then
        anim:ClearOverrideSymbol(target)
    elseif visual.skin then
        anim:OverrideSkinSymbol(target, visual.build, visual.symbol)
    else
        anim:OverrideSymbol(target, visual.build, visual.symbol)
    end
end

local function preservebody(callback, equipping)
    if callback == nil then return nil end
    return function(inst, owner, ...)
        local inventory = owner.components and owner.components.inventory
        local body = inventory and inventory:GetEquippedItem(G.EQUIPSLOTS.BODY)
        local anim = owner.AnimState
        local slot = inst.components.equippable.equipslot
        if anim == nil or (slot ~= G.EQUIPSLOTS.NECK and slot ~= G.EQUIPSLOTS.BACK) then
            return callback(inst, owner, ...)
        end
        local protected = body or (slot == G.EQUIPSLOTS.NECK and inventory
            and inventory:GetEquippedItem(G.EQUIPSLOTS.BACK))

        -- Snapshot actual appearance instead of invoking armor equip callbacks.
        -- Klei uses these APIs to preserve stage props and copy skinned symbols.
        local visual = protected and snapshot(anim, "swap_body")
        local tall = protected and snapshot(anim, "swap_body_tall")
        local ok, result = G.pcall(callback, inst, owner, ...)
        if ok and equipping then
            -- These vanilla amulets and packs write swap_body only. Do not cache
            -- an unchanged tall symbol belonging to the armor underneath.
            inst._ttk_body_visual = snapshot(anim, "swap_body")
        end
        if protected and inventory:GetEquippedItem(body and G.EQUIPSLOTS.BODY or G.EQUIPSLOTS.BACK) == protected then
            restore(anim, "swap_body", visual)
            restore(anim, "swap_body_tall", tall)
        end
        if not ok then G.error(result) end
        return result
    end
end

for _, prefab in ipairs({"amulet", "blueamulet", "purpleamulet", "orangeamulet", "greenamulet", "yellowamulet",
    "icepack", "backpack", "piggyback", "krampus_sack", "spicepack", "candybag", "seedpouch", "ttk_boss_back_xh"}) do
    AddPrefabPostInit(prefab, function(inst)
        if not G.TheWorld.ismastersim then return end
        local equippable = inst.components.equippable
        if equippable then
            equippable.onequipfn = preservebody(equippable.onequipfn, true)
            equippable.onunequipfn = preservebody(equippable.onunequipfn)
        end
    end)
end

AddComponentPostInit("inventory", function(inventory)
    inventory.inst:ListenForEvent("unequip", function(owner, data)
        if not data or (data.eslot ~= G.EQUIPSLOTS.BODY and data.eslot ~= G.EQUIPSLOTS.BACK)
            or inventory:GetEquippedItem(G.EQUIPSLOTS.BODY) ~= nil then return end
        local item = inventory:GetEquippedItem(G.EQUIPSLOTS.BACK)
            or inventory:GetEquippedItem(G.EQUIPSLOTS.NECK)
        if item and item._ttk_body_visual and owner.AnimState then
            restore(owner.AnimState, "swap_body", item._ttk_body_visual)
            owner.AnimState:ClearOverrideSymbol("swap_body_tall")
        end
    end)
end)

if G.TheNet:IsDedicated() then return end

-- These two vanilla UI methods use EQUIPSLOTS only to find the green amulet.
-- Give each method its own environment; never redirect the player's inventory
-- or change the shared EQUIPSLOTS table while crafting callbacks are running.
local function neckindicator(self, method)
    local fn = self[method]
    if fn == nil then return end
    local original = G.getfenv(fn)
    if G.rawget(original, "_ttk_neck_indicator") then return end
    local slots = {}
    for key, value in pairs(G.EQUIPSLOTS) do slots[key] = value end
    slots.BODY = G.EQUIPSLOTS.NECK
    G.setfenv(fn, G.setmetatable({
        EQUIPSLOTS = slots,
        _ttk_neck_indicator = true,
    }, {__index = original}))
    -- Constructors may already have rendered their initial recipe.
    if self.recipe then self[method](self, self.recipe) end
end

AddClassPostConstruct("widgets/redux/craftingmenu_ingredients", function(self)
    neckindicator(self, "SetRecipe")
end)
AddClassPostConstruct("widgets/recipepopup", function(self)
    neckindicator(self, "Refresh")
end)
