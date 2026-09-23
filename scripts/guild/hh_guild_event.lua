local M = {}

function M.GetTarget(data)
    if not data then
        return nil
    end
    return data.target or data.object or data.victim or data.item or data.food or data.fish or data.mount
end

function M.GetPrefab(value)
    if type(value) == "string" then
        return value
    end
    if type(value) ~= "table" then
        return nil
    end
    if value.prefab then
        return value.prefab
    end
    if value.name then
        return value.name
    end
    if value.recipe then
        return M.GetPrefab(value.recipe)
    end
    return nil
end

function M.GetActionId(data, target)
    local action = data and data.action
    if not action and target and target.components and target.components.workable then
        action = target.components.workable.action
    end
    if type(action) == "table" then
        return action.id or action.str
    end
    return action
end

function M.MatchesGroup(groups, group, prefab)
    return group ~= nil and prefab ~= nil and groups[group] ~= nil and groups[group][prefab] == true
end

function M.MatchesPrefabList(prefabs, prefab)
    return prefab ~= nil and prefabs ~= nil and prefabs[prefab] == true
end

return M
