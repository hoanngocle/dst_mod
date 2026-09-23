-- One server-owned provider. Values are replacements, never accumulated deltas.
local M = {}
local Catalog = require("achievement/ttk_perk_catalog")
local Crafts = require("achievement/ttk_perk_crafts")
local HH_KEYS = { critical_hit="criticalHitRate", critical_damage="criticalHitEffect", lifesteal="bloodSuck" }

function M.Has(inst, id)
    return TheWorld ~= nil and TheWorld.ismastersim and inst ~= nil
        and inst._ttk_achievement_perks ~= nil and inst._ttk_achievement_perks[id] == 1
end

function M.GetXPMultiplier(inst)
    local level = inst._ttk_achievement_perks and inst._ttk_achievement_perks.xp_multiplier or 0
    return 1 + .05 * math.min(25, math.max(0, level))
end

function M.ApplyFertilizer(inst, pt, nutrients)
    if not M.Has(inst, "easy_farm") or nutrients == nil or pt == nil
        or not TheWorld.Map:IsFarmableSoilAtPoint(pt:Get()) then return end
    local manager = TheWorld.components.farming_manager
    if manager == nil then return end
    -- One additional native dose on this successfully fertilized tile improves
    -- nutrient stress for subsequent growth stages; native 0..100 caps remain.
    local x, z = TheWorld.Map:GetTileCoordsAtPoint(pt:Get())
    manager:AddTileNutrients(x, z, nutrients[1] or 0, nutrients[2] or 0, nutrients[3] or 0)
end

local function Seen(inst, kind, object)
    if object == nil then return true end
    local seen = inst._ttk_achievement_seen[kind]
    if seen[object] then return true end
    seen[object] = true
    return false
end

local function GiveBonus(inst, item, position)
    if item == nil or item.components.inventoryitem == nil then return end
    local bonus = SpawnPrefab(item.prefab)
    if bonus == nil then return end
    if item.components.stackable and bonus.components.stackable then
        bonus.components.stackable:SetStackSize(item.components.stackable:StackSize())
    end
    if item.components.perishable and bonus.components.perishable then
        bonus.components.perishable:SetPercent(item.components.perishable:GetPercent())
    end
    bonus.Transform:SetPosition(position:Get())
    inst.components.inventory:GiveItem(bonus, nil, position)
end

local function RefreshDiscount(inst)
    if not M.Has(inst, "build_cheaper") or inst.components.builder == nil then return end
    -- DST supports exactly .25/.5/1, replicates these, and rounds every positive
    -- ingredient to at least one in both HasIngredients and GetIngredients.
    local green = false
    for _, item in pairs(inst.components.inventory.equipslots) do
        if item.prefab == "greenamulet" then green = true; break end
    end
    inst.components.builder.ingredientmod = green and .25 or .5
end

function M.Install(inst)
    if not TheWorld.ismastersim or inst._ttk_achievement_perks ~= nil then return end
    inst._ttk_achievement_perks = {}
    inst.ttk_achievement_effects = {}
    inst._ttk_achievement_seen = {}
    for _, kind in ipairs({"picks", "kills", "work"}) do
        inst._ttk_achievement_seen[kind] = setmetatable({}, {__mode="k"})
    end
    for _, name in ipairs({"planardamage", "planardefense", "efficientuser", "workmultiplier"}) do
        if inst.components[name] == nil then inst:AddComponent(name) end
    end
    local work = inst.components.workmultiplier
    local previous = work.specialfn
    work:SetSpecialMultiplierFn(function(player, action, target, tool, amount, recoil)
        amount = previous ~= nil and previous(player, action, target, tool, amount, recoil) or amount
        if not recoil and amount > 0 and target ~= nil and target.components.workable ~= nil
            and (action == ACTIONS.MINE and M.Has(player, "mine_faster")
                or action == ACTIONS.CHOP and M.Has(player, "chop_faster")) then
            return math.max(amount, target.components.workable:GetWorkLeft())
        end
        return amount
    end)
    inst:ListenForEvent("picksomething", function(player, data)
        if not M.Has(player, "double_pick") or data == nil or data.object == nil
            or data.loot == nil or Seen(player, "picks", data) then return end
        local target = data.object
        if target.components.pickable == nil or target.components.trader ~= nil then return end
        local position = target:GetPosition()
        -- The native successful event carries either one entity or an array.
        if data.loot.prefab ~= nil then GiveBonus(player, data.loot, position)
        else for _, item in ipairs(data.loot) do GiveBonus(player, item, position) end end
    end)
    inst:ListenForEvent("killed", function(player, data)
        if not M.Has(player, "double_drop") or data == nil or data.victim == nil then return end
        local victim = data.victim
        if victim._ttk_achievement_double_drop or victim:HasTag("player") or victim:HasTag("INLIMBO") or victim.components.health == nil
            or not victim.components.health:IsDead() or victim.components.combat == nil
            or victim.components.lootdropper == nil or victim.components.follower ~= nil
                and victim.components.follower:GetLeader() ~= nil or Seen(player, "kills", victim) then return end
        victim._ttk_achievement_double_drop = true
        victim.components.lootdropper:DropLoot()
    end)
    inst:ListenForEvent("finishedwork", function(player, data)
        if not M.Has(player, "icy_weed") or not TheWorld.state.iswinter or data == nil
            or data.target == nil or Seen(player, "work", data) then return end
        if data.action == ACTIONS.DIG and data.target:HasTag("stump") and Prefabs.chasni_icyweed ~= nil then
            local weed = SpawnPrefab("chasni_icyweed")
            if weed ~= nil then weed.Transform:SetPosition(data.target.Transform:GetWorldPosition()) end
        end
    end)
    for _, event in ipairs({"equip", "unequip"}) do
        inst:ListenForEvent(event, function(player)
            player:DoTaskInTime(0, RefreshDiscount)
        end)
    end
end

function M.Apply(inst, perk, level)
    if not TheWorld.ismastersim or inst._ttk_achievement_perks == nil
        or perk == nil or Catalog.ById(perk.id) ~= perk or type(level) ~= "number"
        or level ~= level or level < 0 or level == math.huge then return false end
    local id = perk.id
    level = math.min(25, math.floor(level))
    if perk.group == "stats" then
        local amount = perk.effect_per_level * level
        local key = HH_KEYS[id]
        if key ~= nil then
            if inst.components.hh_player == nil then return false end
            -- hh_player consumes percentages, not fractions. A dedicated source
            -- map survives its equipment/base-effect table being rebuilt.
            inst.ttk_achievement_effects[key] = amount * 100
        elseif id == "planar_damage" or id == "planar_defense" then
            local component = inst.components[id == "planar_damage" and "planardamage" or "planardefense"]
            if component == nil then return false end
            component:AddBonus(inst, amount, "ttk_achievement_" .. id)
        elseif id == "scale" then
            if inst.prefab ~= "eva" then return false end
            inst.AnimState:SetScale(1 + amount, 1 + amount)
        elseif id ~= "xp_multiplier" then return false end
    elseif perk.group == "craft" then
        if inst.prefab ~= "eva" or not Crafts.CanUnlock(perk) then return false end
        inst:AddTag(perk.builder_tag)
        for _, name in ipairs(Crafts.GetRecipes(id)) do inst.components.builder:AddRecipe(name) end
        inst.components.builder:EvaluateTechTrees()
        inst:PushEvent("refreshcrafting")
    elseif perk.group == "ability" then
        -- Source-only capabilities cannot charge Star until their prefab/component
        -- ports are available. There is no runtime dependency on another mod.
        if id == "trinket_owner" then
            if inst.components.trinketowner == nil then return false end
            inst.components.trinketowner:UpdateInventory()
        elseif id == "icy_weed" then
            if Prefabs.chasni_icyweed == nil then return false end
        elseif id == "fast_worker" then
            inst:AddTag("fastbuilder")
        elseif id == "warly_chef" then
            inst:AddTag("masterchef")
            inst:AddTag("professionalchef")
        elseif id == "double_healed" then
            inst.components.efficientuser:AddMultiplier(ACTIONS.HEAL, 2, inst, "ttk_achievement_double_healed")
        elseif id == "build_cheaper" then
            if inst.components.builder == nil or inst.components.inventory == nil then return false end
        elseif id ~= "mine_faster" and id ~= "chop_faster" and id ~= "fish_faster"
            and id ~= "cook_faster" and id ~= "double_pick" and id ~= "double_drop"
            and id ~= "eternal_cage" and id ~= "easy_farm" then return false end
        level = level > 0 and 1 or 0
    else return false end
    inst._ttk_achievement_perks[id] = level
    if id == "build_cheaper" then RefreshDiscount(inst) end
    return true
end

return M
