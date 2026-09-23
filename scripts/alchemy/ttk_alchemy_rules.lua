local AlchemyDefs = require("alchemy/ttk_alchemy_defs")

local M = {}

local function IsAmount(value)
    return type(value) == "number"
        and value > 0
        and value == value
        and value ~= math.huge
        and value ~= -math.huge
        and value == math.floor(value)
end

function M.NormalizeStacks(slots)
    if type(slots) ~= "table" then return nil end
    local totals = {}
    for _, item in pairs(slots) do
        local prefab = item ~= nil and item.prefab or nil
        local stack = item ~= nil and item.components ~= nil and item.components.stackable or nil
        local amount = stack ~= nil and stack:StackSize() or 1
        if type(prefab) ~= "string" or prefab == "" or not IsAmount(amount) then return nil end
        local total = (totals[prefab] or 0) + amount
        if not IsAmount(total) then return nil end
        totals[prefab] = total
    end
    return totals
end

-- items must already be normalized as { prefab = total_stack_amount }.
function M.FindExactRecipe(items)
    if type(items) ~= "table" then return nil end
    for prefab, amount in pairs(items) do
        if type(prefab) ~= "string" or prefab == "" or not IsAmount(amount) then return nil end
    end

    for output, row in pairs(AlchemyDefs.by_prefab) do
        local recipe = AlchemyDefs.GetRecipe(output)
        if recipe ~= nil and type(recipe.ingredients) == "table" then
            local expected = {}
            local valid = true
            for _, ingredient in ipairs(recipe.ingredients) do
                local prefab, amount = ingredient.prefab, ingredient.amount
                if type(prefab) ~= "string" or prefab == "" or not IsAmount(amount) or expected[prefab] ~= nil then
                    valid = false
                    break
                end
                expected[prefab] = amount
            end
            if valid then
                for prefab, amount in pairs(items) do
                    if expected[prefab] ~= amount then valid = false break end
                end
                for prefab in pairs(expected) do
                    if items[prefab] ~= expected[prefab] then valid = false break end
                end
            end
            if valid then return recipe, output end
        end
    end
    return nil
end

function M.IsApprovedOutput(output)
    return type(output) == "string" and AlchemyDefs.Get(output) ~= nil and AlchemyDefs.GetRecipe(output) ~= nil
end

return M
