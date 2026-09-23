-- Adapted from DJPaul's Sort Inventory 1.9d, Paul Gibbs (DJPaul).
-- CC BY-NC-SA 4.0; see licenses/DJPaul-Sort-Inventory-license.txt.
-- Each storage is sorted independently: never transfer items to another owner.
local M = {}
local resources = {}
for _, name in ipairs({"twigs", "nightmarefuel", "rope", "goldnugget", "boards",
    "silk", "papyrus", "cutgrass", "thulecite", "cutstone", "flint", "log",
    "livinglog", "pigskin", "thulecite_pieces", "rocks", "nitre"}) do
    resources[name] = true
end

local function number(value)
    return type(value) == "number" and value == value and value or 0
end

local function rank(item, hurt, lights, maxlights)
    local c = item.components
    if c.inventoryitem.canonlygoinpocket then return 1, 0, false end
    if c.armor then return 6, number(c.armor:GetPercent()), false end
    if c.edible and (c.perishable or c.edible.foodtype == "GEARS") then
        return 5, number(hurt and c.edible.healthvalue or c.edible.hungervalue), false
    end
    if c.fueled and (c.lighter or item:HasTag("light")) then
        return lights < maxlights and 2 or 8, number(c.fueled:GetPercent()), true
    end
    if resources[item.prefab] then return 7, 0, false end
    if c.equippable and c.finiteuses and (c.tool or c.terraformer) then
        return 3, number(c.finiteuses:GetUses()), false
    end
    -- Do not call GetDamage(player, nil): modded weapons may require a target.
    if c.weapon then return 4, number(c.weapon.damage), false end
    return 8, 0, false
end

local function busy(c)
    if c.itemslots then
        return c.activeitem ~= nil or c.inst:HasTag("playerghost")
    end
    for player in pairs(c.openlist or {}) do
        local inv = player.components.inventory
        if inv and inv.activeitem then return true end
    end
    return false
end

local function eligible(c)
    return c.inst:IsValid() and not c.readonlycontainer and not c.usespecificslotsforitems
        and c:GetNumSlots() > 1
        and ((c.itemslots ~= nil and c.inst:HasTag("player"))
            or (c.itemslots == nil and (c.type == "chest" or c.type == "pack")))
end

local function sort(c, maxlights)
    if not eligible(c) or busy(c) then return false end
    local slots = c.itemslots or c.slots
    local movable, entries = {}, {}
    local health = c.inst.components.health
    local hurt = health ~= nil and health:GetPercent() <= 0.3
    local lights = 0
    for slot = 1, c:GetNumSlots() do
        local item = slots[slot]
        local ii = item and item.components.inventoryitem
        if item == nil or (ii ~= nil and not ii.islockedinslot) then
            movable[#movable + 1] = slot
            if item then
                local group, value, light = rank(item, hurt, lights, maxlights)
                lights = lights + (light and 1 or 0)
                entries[#entries + 1] = {item = item, slot = slot, group = group, value = value,
                    name = type(item.name) == "string" and item.name or item.prefab or ""}
            end
        end
    end
    -- Some modded chests have slot-dependent filters without usespecificslotsforitems.
    -- Validate before stacking or changing any slots; keep their layout intact.
    for _, entry in ipairs(entries) do
        for _, slot in ipairs(movable) do
            if not c:CanTakeItemInSlot(entry.item, slot) then return false end
        end
    end
    table.sort(entries, function(a, b)
        if a.group ~= b.group then return a.group < b.group end
        local byname = a.group == 3 or a.group == 7 or a.group == 8
        if byname and a.name ~= b.name then return a.name < b.name end
        if a.value ~= b.value then return a.value > b.value end
        if a.name ~= b.name then return a.name < b.name end
        return a.slot < b.slot
    end)

    -- Stack in place using Klei's API (preserves skins, freshness and moisture).
    -- Consumed items remove themselves from the owner through OnRemoveEntity.
    local kept = {}
    for _, entry in ipairs(entries) do
        local item = entry.item
        if c.acceptsstacks ~= false and item.components.stackable then
            for _, previous in ipairs(kept) do
                local stack = previous.item.components.stackable
                if stack and not stack:IsFull() and stack:CanStackWith(item) then
                    item = stack:Put(item)
                    if item == nil then
                        if slots[entry.slot] == entry.item then
                            slots[entry.slot] = nil
                            c.inst:PushEvent("itemlose", {slot = entry.slot, prev_item = entry.item})
                        end
                        break
                    end
                end
            end
        end
        if item then kept[#kept + 1] = entry end
    end

    local changed, planned = {}, {}
    for i, slot in ipairs(movable) do
        planned[slot] = kept[i] and kept[i].item or nil
        if slots[slot] ~= planned[slot] then
            changed[#changed + 1] = {slot = slot, previous = slots[slot]}
        end
    end
    -- Permute the same table without detaching ownership or toggling infinite stacks.
    -- Replica components and Da Bao Cac's display consume itemlose/itemget events.
    for _, change in ipairs(changed) do slots[change.slot] = planned[change.slot] end
    for _, change in ipairs(changed) do
        if change.previous then
            c.inst:PushEvent("itemlose", {slot = change.slot, prev_item = change.previous})
        end
    end
    for _, change in ipairs(changed) do
        local item = planned[change.slot]
        if item then c.inst:PushEvent("itemget", {slot = change.slot, item = item}) end
    end
    return true
end

function M.Sort(c, maxlights)
    if c == nil or c._ttk_sorting then return false end
    c._ttk_sorting = true
    local ok, result = pcall(sort, c, maxlights or 2)
    c._ttk_sorting = nil
    if not ok then error(result) end
    return result
end

function M.Install(env, options)
    local G = env.GLOBAL
    if rawget(G, "TTK_INVENTORYSORT_INSTALLED") then return end
    rawset(G, "TTK_INVENTORYSORT_INSTALLED", true)
    options = options or {}
    local maxlights = tonumber(options.maxLights) or 2
    local function sortplayer(player)
        if player == nil or not player:IsValid() or player:HasTag("playerghost") then return end
        local inv = player.components.inventory
        if inv == nil or inv.activeitem ~= nil then return end
        local now = G.GetTime()
        if player._ttk_lastsort and now - player._ttk_lastsort < 0.25 then return end
        player._ttk_lastsort = now
        local backpack = inv:GetOverflowContainer()
        local has_open_chest = false
        for inst in pairs(inv.opencontainers or {}) do
            local c = inst.components.container
            if c and c ~= backpack and c.type ~= "pack" and c:IsOpenedBy(player) then
                has_open_chest = true
                M.Sort(c, maxlights)
            end
        end
        if not has_open_chest then
            M.Sort(inv, maxlights)
            M.Sort(backpack, maxlights)
        end
    end
    env.AddModRPCHandler(env.modname, "ttk_sort_inventory", sortplayer)
    if not G.TheNet:IsDedicated() and G.TheInput then
        G.TheInput:AddKeyDownHandler(tonumber(options.keybind) or G.KEY_G, function()
            local screen = G.TheFrontEnd:GetActiveScreen()
            local player = G.ThePlayer
            if screen == nil or screen.name ~= "HUD" or player == nil
                or player:HasTag("playerghost") then return end
            if G.TheWorld.ismastersim then
                sortplayer(player)
            else
                env.SendModRPCToServer(env.MOD_RPC[env.modname].ttk_sort_inventory)
            end
            if options.funMode == "yes" and player.SoundEmitter then
                player.SoundEmitter:PlaySound("dontstarve/creatures/perd/gobble")
            end
        end)
    end
end

return M
