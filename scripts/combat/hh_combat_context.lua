local Context = {}

local active = {}
local packet_kind = nil
local unpack_values = unpack or table.unpack

local function Pack(...)
    return { n = select("#", ...), ... }
end

function Context.Begin(attacker, target, data)
    local token = {}
    table.insert(active, {
        token = token,
        attacker = attacker,
        target = target,
        data = data,
    })
    return token
end

function Context.Current(attacker, target)
    for index = #active, 1, -1 do
        local entry = active[index]
        if entry.attacker == attacker and entry.target == target then
            return entry.data
        end
    end
    return nil
end

function Context.Finish(token)
    for index = #active, 1, -1 do
        local entry = active[index]
        if entry.token == token then
            table.remove(active, index)
            return entry.data
        end
    end
    return nil
end

function Context.PacketKind()
    return packet_kind
end

function Context.WithPacket(kind, fn, ...)
    local previous = packet_kind
    local args = Pack(...)
    packet_kind = kind
    local results = Pack(xpcall(function()
        return fn(unpack_values(args, 1, args.n))
    end, function(err)
        return err
    end))
    packet_kind = previous
    if not results[1] then error(results[2], 0) end
    return unpack_values(results, 2, results.n)
end

return Context
