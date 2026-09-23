-- Namespaced subset of Epic Healthbar's helper runtime. This intentionally
-- avoids its package.path rotation and does not merge into the global Tykvesh.
local C = { Empty = {}, Dummy = function() end, True = function() return true end }
local memo = setmetatable({}, { __mode = "k" })

local function parallel(root, key, fn, after)
    if type(root) ~= "table" then return end
    local old = root[key]
    if old == nil then root[key] = fn return end
    root[key] = after
        and function(...) old(...); return fn(...) end
        or function(...) fn(...); return old(...) end
end

C.Parallel = parallel
C.Before = function(root, key, fn) return parallel(root, key, fn, false) end
C.After = function(root, key, fn) return parallel(root, key, fn, true) end
C.Init = function(root, fn) return C.After(root, "_ctor", fn) end
C.Remap = function(v, a, b, c, d) return Remap(Clamp(v, a, b), a, b, c, d) end
C.Browse = function(value, ...)
    for i = 1, select("#", ...) do
        if type(value) ~= "table" then return nil end
        value = value[select(i, ...)]
    end
    return value
end
C.Sequence = function(root, key, fn)
    local old = root[key] or C.Dummy
    root[key] = function(...)
        local result = { old(...) }
        local changed = { fn(result[1], ...) }
        for i, v in pairs(changed) do result[i] = v end
        return unpack(result)
    end
end
C.Branch = function(root, key, fn)
    local old = root[key]
    if old ~= nil then root[key] = function(...) return fn(old, ...) end end
end
C.GetUpvalue = function(fn, ...)
    local parent, index
    for n = 1, select("#", ...) do
        local wanted = select(n, ...)
        for i = 1, math.huge do
            local name, value = debug.getupvalue(fn, i)
            if name == nil then return nil end
            if name == wanted then parent, index, fn = fn, i, value break end
        end
    end
    return fn, index, parent
end

return C
