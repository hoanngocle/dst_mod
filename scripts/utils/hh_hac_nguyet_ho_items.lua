local LIVE_WOBSTER_PREFABS =
{
    wobster_sheller_land = true,
    wobster_moonglass_land = true,
}

local FARM_SEED_PREFABS =
{
    seeds = true,
    carrot_seeds = true,
    corn_seeds = true,
    pumpkin_seeds = true,
    eggplant_seeds = true,
    durian_seeds = true,
    pomegranate_seeds = true,
    dragonfruit_seeds = true,
    watermelon_seeds = true,
    tomato_seeds = true,
    potato_seeds = true,
    asparagus_seeds = true,
    onion_seeds = true,
    garlic_seeds = true,
    pepper_seeds = true,
    acorn = true,
}

local RAW_PRODUCE_PREFABS =
{
    cave_banana = true,
    carrot = true,
    corn = true,
    pumpkin = true,
    eggplant = true,
    durian = true,
    pomegranate = true,
    dragonfruit = true,
    berries = true,
    berries_juicy = true,
    fig = true,
    cactus_meat = true,
    watermelon = true,
    kelp = true,
    tomato = true,
    potato = true,
    asparagus = true,
    onion = true,
    garlic = true,
    pepper = true,
}

local function HasTag(item, tag)
    return item ~= nil and item.HasTag ~= nil and item:HasTag(tag)
end

local function HasInventoryItem(item)
    if item == nil then
        return false
    end

    local components = item.components
    if components ~= nil and components.inventoryitem ~= nil then
        return true
    end

    local replica = item.replica
    return replica ~= nil and replica.inventoryitem ~= nil
end

local function GetStackable(item)
    if item == nil then
        return nil
    end

    local components = item.components
    if components ~= nil and components.stackable ~= nil then
        return components.stackable
    end

    local replica = item.replica
    return replica ~= nil and replica.stackable or nil
end

local HHItems = {}

function HHItems.IsFish(item)
    if not HasInventoryItem(item) then
        return false
    end

    -- Raw vanilla fish is the one fish prefab without the generic "fish" tag.
    if item.prefab == "fish" then
        return true
    end

    -- The two semantic fish groups are intentionally narrow. In particular,
    -- "fish" alone is not enough because cooked fish can retain other tags.
    return HasTag(item, "fish") and
        (HasTag(item, "pondfish") or HasTag(item, "oceanfish"))
end

function HHItems.IsWobster(item)
    return HasInventoryItem(item) and
        item.prefab ~= nil and
        LIVE_WOBSTER_PREFABS[item.prefab] == true
end

function HHItems.IsAquatic(item)
    return HHItems.IsFish(item) or HHItems.IsWobster(item)
end

function HHItems.IsFarmSeed(item)
    return HasInventoryItem(item) and
        item.prefab ~= nil and
        FARM_SEED_PREFABS[item.prefab] == true
end

function HHItems.IsRawProduce(item)
    return HasInventoryItem(item) and
        item.prefab ~= nil and
        RAW_PRODUCE_PREFABS[item.prefab] == true
end

function HHItems.IsFood(item)
    return HHItems.IsFarmSeed(item) or HHItems.IsRawProduce(item)
end

function HHItems.IsAllowed(item)
    return HHItems.IsAquatic(item) or HHItems.IsFood(item)
end

function HHItems.GetStackSize(item)
    local stackable = GetStackable(item)
    if stackable ~= nil and stackable.StackSize ~= nil then
        return stackable:StackSize()
    end
    return 1
end

-- Read-only and safe for both the server component and the client replica.
-- A nil result means the caller cannot inspect the container slots locally;
-- authoritative server code must then perform the definitive check.
function HHItems.CountEmptySlots(container)
    if container == nil or
        container.GetNumSlots == nil or
        container.GetItemInSlot == nil
    then
        return nil
    end

    local numslots = container:GetNumSlots()
    if type(numslots) ~= "number" then
        return nil
    end

    local empty = 0
    for slot = 1, numslots do
        if container:GetItemInSlot(slot) == nil then
            empty = empty + 1
        end
    end
    return empty
end

-- This function only validates. It never splits, removes, gives, or mutates
-- an item, so it is safe to use from the UI itemtestfn.
function HHItems.CanFitStack(container, item, slot)
    local stacksize = HHItems.GetStackSize(item)
    if stacksize <= 1 then
        return true
    end

    if container ~= nil and container.GetItemInSlot ~= nil and slot ~= nil and
        container:GetItemInSlot(slot) ~= nil
    then
        -- The server normalization path reserves one empty slot per fish and
        -- deliberately does not merge the incoming stack into an old stack.
        return false
    end

    local empty = HHItems.CountEmptySlots(container)
    return empty == nil or empty >= stacksize
end

-- The active-item "put one" action checks the full active stack before it
-- creates its one-unit clone. Keep that action usable with one free slot,
-- while preventing any aquatic unit from being merged back into an existing
-- aquatic slot. Food is intentionally left vanilla-stackable.
function HHItems.CanUseStackTarget(container, item, slot)
    if not HHItems.IsAquatic(item) or
        container == nil or
        container.GetItemInSlot == nil or
        slot == nil
    then
        return true
    end
    return container:GetItemInSlot(slot) == nil
end

return HHItems
