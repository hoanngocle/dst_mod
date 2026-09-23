-- Client-only popup palette. Keep item/rank hues and the original Solo
-- background opacity while lifting dark text colours for readability.
local Theme = {
    background = {0.065, 0.045, 0.105, 0.5},
    frame = {0.78, 0.66, 1, 1},
    corner = {0.96, 0.93, 1, 1},
    label = {0.84, 0.78, 0.96, 1},
    text = {0.97, 0.96, 1, 1},
}

function Theme.Readable(color)
    if type(color) ~= "table" then return Theme.text end
    local result = {1, 1, 1, 1}
    for i = 1, 3 do
        local value = math.max(0, math.min(1, tonumber(color[i]) or 1))
        result[i] = 0.65 + 0.35 * value
    end
    return result
end

return Theme
