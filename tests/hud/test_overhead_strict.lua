-- Reproduce strict.lua on first spawn, before any registry exists.
for _, role in ipairs({ 'client', 'host', 'dedicated' }) do
    local game = {
        TheNet = { IsDedicated = function() return role == 'dedicated' end },
        TheWorld = { ismastersim = role ~= 'client' },
        Prefab = function(name, fn) return { fn = fn } end,
        net_float = function() return {} end,
        net_bool = function() return {} end,
        CreateEntity = function()
            local inst = { GUID = 1, callbacks = {},
                entity = { AddTransform = function() end, AddNetwork = function() end,
                    SetPristine = function() end },
                Transform = { SetPosition = function() end },
                AddTag = function() end,
                ListenForEvent = function(self, event, fn) self.callbacks[event] = fn end,
            }
            return inst
        end,
    }
    game._G = game
    setmetatable(game, {
        __index = function(_, key)
            local value = rawget(_G, key)
            if value ~= nil then return value end
            error("variable '" .. key .. "' is not declared", 2)
        end,
        __newindex = function(_, key)
            error("assign to undeclared variable '" .. key .. "'", 2)
        end,
    })
    local chunk = assert(loadfile('scripts/prefabs/ttk_hud_overhead_proxy.lua'))
    setfenv(chunk, game)
    local prefab = chunk()
    local first, second = prefab.fn(), prefab.fn()
    local registry = rawget(game, 'TTK_HUD_OVERHEAD_PROXIES')
    if role == 'dedicated' then
        assert(registry == nil)
    else
        assert(registry[first] and registry[second])
        assert(getmetatable(registry).__mode == 'k')
        first.callbacks.onremove()
        assert(registry[first] == nil and registry[second])
    end
end
print('overhead strict globals: client, host, dedicated and removal passed')
