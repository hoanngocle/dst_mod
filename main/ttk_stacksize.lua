-- Increased Stack size (374550642), ChaosMind42: fixed 120 items per stack.
-- No configuration and no new stackable components on non-stackable items.
local G = GLOBAL
for _, name in ipairs({
    "STACK_SIZE_LARGEITEM", "STACK_SIZE_MEDITEM", "STACK_SIZE_SMALLITEM",
    "STACK_SIZE_TINYITEM", "STACK_SIZE_PELLET",
}) do
    G.TUNING[name] = 120
end

AddPrefabPostInitAny(function(inst)
    if not G.TheWorld.ismastersim then return end
    local stackable = inst.components.stackable
    if stackable ~= nil then
        -- Klei's property setter also updates the replica. While infinite stacking
        -- is enabled, it updates originalmaxsize and preserves maxsize = math.huge.
        stackable.maxsize = 120
    end
end)
