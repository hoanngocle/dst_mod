-- Bố cục hai hàng và khoảng giữa cho trang bị, theo bản 3075429483.
local M = {}
function M.Dimensions(size)
    local bottom = (size + 5) / 2 + 1
    local top = size - bottom
    return bottom, top, math.floor(top / 2)
end
function M.Slot(size, index, first_top, spacing)
    local bottom, top, left = M.Dimensions(size)
    local upper, column
    if first_top then
        upper = index <= top
        column = upper and index - 1 or index - top - 1
    else
        upper = index > bottom
        column = upper and index - bottom - 1 or index - 1
    end
    if upper and column >= left then column = column + bottom - top end
    local function x(col) return col * 71 + math.floor(col / 5) * (spacing - 7) end
    return x(column) - x(bottom - 1) / 2, upper and 71 or 0
end
function M.Equipment(size, count, index, spacing)
    local bottom, top, left = M.Dimensions(size)
    local x1 = M.Slot(size, left + 1, false, spacing)
    local x2 = M.Slot(size, left + bottom - top, false, spacing)
    return (x1 + x2) / 2 + (index - (count + 1) / 2) * 71,
        count <= bottom - top and 71 or 142
end
return M
