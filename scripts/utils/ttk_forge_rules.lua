-- Shared server/replica rules for Thần Binh Phổ. Slot numbers remain save compatible.
local Rules = {}
Rules.MODES = { cleanse = true, stone_change = true, equip_inherit = true }

function Rules.GetMode(container)
    local inst = container ~= nil and (container.inst or container) or nil
    local mode = inst ~= nil and inst.ttk_forge_mode ~= nil and inst.ttk_forge_mode:value() or nil
    return Rules.MODES[mode] and mode or "cleanse"
end

local function IsGear(item)
    return item ~= nil and item:HasTag("hh_equip")
        and ((item.components ~= nil and item.components.equippable ~= nil)
            or (item.replica ~= nil and item.replica.equippable ~= nil)) or false
end

function Rules.ItemTest(container, item, slot)
    if item == nil or slot == nil then return false end
    local inst = container ~= nil and (container.inst or container) or nil
    if inst ~= nil and inst._ttk_forge_loading_legacy then return true end
    local mode = Rules.GetMode(container)
    if mode == "cleanse" then
        return slot == 1 and IsGear(item)
    elseif mode == "stone_change" then
        return (slot == 2 and item.prefab == "hh_effect_stone")
            or (slot == 3 and item.prefab == "hh_essence")
    end
    return ((slot == 2 or slot == 3) and IsGear(item))
        or (slot == 4 and item.prefab == "hh_essence")
        or (slot == 5 and item.prefab == "nightmarefuel")
end

return Rules
