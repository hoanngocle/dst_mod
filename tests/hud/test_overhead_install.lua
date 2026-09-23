package.path = "./scripts/?.lua;" .. package.path

-- Required modules do not receive a mod-environment GLOBAL binding in DST.
GLOBAL = nil
local callbacks = {}
local spawned = 0
local game = {
    TheNet = { GetIsServer = function() return true end },
    TUNING = { TTK_HUD = { OVERHEAD_BAR = true } },
    SpawnPrefab = function()
        spawned = spawned + 1
        return {
            entity = { SetParent = function() end },
            IsValid = function() return true end,
            Refresh = function() end,
        }
    end,
}
local env = {
    GLOBAL = game,
    AddComponentPostInit = function(name, fn) callbacks[name] = fn end,
}
require("ttk_hud/overhead").install(env)
assert(type(callbacks.combat) == "function", "combat post-init registered without module GLOBAL")

local listeners = {}
local inst = {
    entity = {}, _ttk_hud_overhead = nil,
    components = { health = { IsDead = function() return false end } },
    HasTag = function(_, tag) return tag == "epic" end,
    ListenForEvent = function(_, event, fn) listeners[event] = fn end,
}
callbacks.combat({ inst = inst })
listeners.attacked()
assert(spawned == 1, "server creates proxy even for epic-tagged target; client selection decides hiding")

local prefab_source = assert(io.open("scripts/prefabs/ttk_hud_overhead_proxy.lua", "r")):read("*all")
assert(prefab_source:find("if not TheNet:IsDedicated%(%) then"), "listen-server host joins client proxy registry")
assert(prefab_source:find("if not TheWorld.ismastersim then"), "remote-client early return remains")

local widget_source = assert(io.open("scripts/widgets/ttk_hud_overhead.lua", "r")):read("*all")
assert(widget_source:find("epic%.shown"), "boss suppression requires visible Epic widget")
assert(widget_source:find("epic%.active"), "boss suppression checks displayed/active state")
assert(widget_source:find("epic:IsMoving%(%)"), "boss suppression covers visible slide animation")

print("overhead integration: required-module env, host registry, and client boss gating passed")
