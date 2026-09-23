local Rewards = {}
local bundles = {
    spring = {
        [5] = {{prefab="ttk_lc_lmg_seed",amount=3}},
        [10] = {{prefab="ttk_lc_lmg_seed",amount=5},{prefab="ttk_lingshi1",amount=10}},
        [15] = {{prefab="ttk_lingshi2",amount=2},{prefab="yellowgem",amount=1}},
        [20] = {{prefab="ttk_lingshi3",amount=1},{prefab="goose_feather",amount=1}},
    },
    summer = {
        [5] = {{prefab="ttk_lc_cyh_seed",amount=3}},
        [10] = {{prefab="ttk_lc_cyh_seed",amount=5},{prefab="ttk_lingshi1",amount=10}},
        [15] = {{prefab="ttk_lingshi2",amount=2},{prefab="orangegem",amount=1}},
        [20] = {{prefab="ttk_lingshi3",amount=1},{prefab="dragon_scales",amount=1}},
    },
    autumn = {
        [5] = {{prefab="ttk_lc_qfx_seed",amount=3}},
        [10] = {{prefab="ttk_lc_qfx_seed",amount=5},{prefab="ttk_lingshi1",amount=10}},
        [15] = {{prefab="ttk_lingshi2",amount=2},{prefab="greengem",amount=1}},
        [20] = {{prefab="ttk_lingshi3",amount=1},{prefab="bearger_fur",amount=1}},
    },
    winter = {
        [5] = {{prefab="ttk_lc_hsc_seed",amount=3}},
        [10] = {{prefab="ttk_lc_hsc_seed",amount=5},{prefab="ttk_lingshi1",amount=10}},
        [15] = {{prefab="ttk_lingshi2",amount=2},{prefab="bluegem",amount=1}},
        [20] = {{prefab="ttk_lingshi3",amount=1},{prefab="deerclops_eyeball",amount=1}},
    },
}

local function Copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, child in pairs(value) do result[key] = Copy(child) end
    return result
end

local function Finite(value)
    return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end

local function PositiveInteger(value)
    return Finite(value) and value > 0 and value == math.floor(value)
end

function Rewards.GetBundle(season, milestone)
    if type(season) ~= "string" or type(milestone) ~= "number" then return nil end
    return Copy(bundles[season] ~= nil and bundles[season][milestone] or nil)
end

function Rewards.Preflight(player, season, milestone, bundle)
    local exact = Rewards.GetBundle(season, milestone)
    if exact == nil or type(bundle) ~= "table" or #bundle ~= #exact then return nil, "invalid_bundle" end
    if type(SpawnPrefab) ~= "function" or type(Prefabs) ~= "table" then return nil, "prefabs_unavailable" end
    for index, expected in ipairs(exact) do
        local item = bundle[index]
        if type(item) ~= "table" or type(item.prefab) ~= "string" or not PositiveInteger(item.amount)
            or item.prefab ~= expected.prefab or item.amount ~= expected.amount then return nil, "invalid_bundle" end
        if Prefabs[item.prefab] == nil then return nil, "missing_prefab" end
    end
    if player == nil or player.Transform == nil then return nil, "missing_position" end
    local ok, x, y, z = pcall(function() return player.Transform:GetWorldPosition() end)
    if not ok or not Finite(x) or not Finite(y) or not Finite(z) then return nil, "missing_position" end
    -- One captured position for the entire transaction, even if a callback moves the player.
    return {x=x, y=y, z=z, inventory=player.components ~= nil and player.components.inventory or nil}
end

function Rewards.Rollback(staged)
    for _, item in ipairs(staged or {}) do
        pcall(function() if item:IsValid() then item:Remove() end end)
    end
end

function Rewards.Stage(bundle, plan)
    local staged = {}
    local ok = pcall(function()
        for _, entry in ipairs(bundle) do
            assert(PositiveInteger(entry.amount), "invalid amount")
            local remaining = entry.amount
            while remaining > 0 do
                local item = SpawnPrefab(entry.prefab)
                assert(item ~= nil, "prefab did not spawn")
                staged[#staged + 1] = item
                assert(item:IsValid() and item.prefab == entry.prefab and item.Transform ~= nil
                    and item.components ~= nil and item.components.inventoryitem ~= nil, "invalid reward entity")
                local stackable = item.components.stackable
                local amount = 1
                if stackable ~= nil then
                    assert(PositiveInteger(stackable.maxsize), "invalid stack capacity")
                    amount = math.min(remaining, stackable.maxsize)
                    stackable:SetStackSize(amount)
                    assert(stackable:StackSize() == amount, "incorrect staged amount")
                end
                -- Establish every fallback before committing; failed placement
                -- remains a staging failure and rolls the whole bundle back.
                item.Transform:SetPosition(plan.x, plan.y, plan.z)
                remaining = remaining - amount
            end
        end
    end)
    if not ok then Rewards.Rollback(staged); return nil, "staging_failed" end
    return staged
end

function Rewards.PlanDelivery(plan, staged)
    local inventory = plan.inventory
    plan.to_inventory = false
    if inventory == nil or type(inventory.CanAcceptCount) ~= "function"
        or type(inventory.GiveItem) ~= "function" then return plan end
    local ok, accepts = pcall(function()
        -- Reserve enough independent empty slots conservatively. CanAcceptCount
        -- alone would double-count the same free slot for two different prefabs.
        if type(inventory.GetNumSlots) ~= "function" or type(inventory.itemslots) ~= "table" then return false end
        local empty = 0
        for slot = 1, inventory:GetNumSlots() do
            if inventory.itemslots[slot] == nil then empty = empty + 1 end
        end
        if empty < #staged then return false end
        for _, item in ipairs(staged) do
            local stack = item.components.stackable
            local count = stack ~= nil and stack:StackSize() or 1
            local accepted = inventory:CanAcceptCount(item, count)
            if not Finite(accepted) or accepted < count then return false end
        end
        return true
    end)
    plan.to_inventory = ok and accepts == true
    return plan
end

function Rewards.Deliver(plan, staged)
    for _, item in ipairs(staged) do
        -- All items already occupy the captured fallback point. Never delete
        -- items after delivery begins, even when an inventory callback throws.
        if plan.to_inventory then
            pcall(function() plan.inventory:GiveItem(item, nil, Vector3(plan.x, plan.y, plan.z)) end)
            -- GiveItem may merge only part of a stack before returning false.
            -- Reposition only a surviving unowned remainder, never recreate it.
            pcall(function()
                if item:IsValid() and item.components.inventoryitem.owner == nil then
                    item.Transform:SetPosition(plan.x, plan.y, plan.z)
                end
            end)
        end
    end
end

return Rewards
