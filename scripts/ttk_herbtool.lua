-- Called exactly once by a successful mature-herb harvest, on the server.
return function(doer)
    local inventory = doer ~= nil and doer.components.inventory or nil
    if inventory == nil then return false end
    local tool = inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    if tool ~= nil and tool:HasTag("ttk_herbtool") then
        local uses = tool.components.finiteuses
        if uses ~= nil and uses:GetUses() > 0 then
            uses:Use(1)
            return true
        end
        return false
    end
    return inventory:EquipHasTag("xd_yhsyz")
end
