from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT.parents[1] / ".superpowers/ttk-solo-integration/lua-runtime"))
try:
    from lupa.lua51 import LuaRuntime
except ImportError:
    from lupa import LuaRuntime


lua = LuaRuntime(unpack_returned_tuples=True)
lua.globals().package.path = str(ROOT / "scripts/?.lua").replace("\\", "/") + ";" + lua.globals().package.path
lua.execute(r'''
package.preload["util/eva_progression"] = function()
    return {
        IsUnlocked = function() return true end,
        RequiredLevel = function() return 1 end,
        Check = function() return true end,
    }
end
local test_now = 1
GetTime = function() return test_now end
ACTIONS = {EVA_FOX_BLINK = {id = "EVA_FOX_BLINK"}}
Vector3 = function(x, y, z) return {x = x, y = y, z = z} end
BufferedAction = function(owner, target, action, invobject, point)
    return {
        doer = owner,
        target = target,
        action = action,
        invobject = invobject,
        GetActionPoint = function() return point end,
    }
end

local Panel = require("util/eva_skillpanel")
local expected = {"life", "harvest", "wings", "daydu", "array"}
local expected_spell_indexes = {1, 4, 2, 5, 3}
assert(#Panel.HOTKEY_ORDER == 5)
for index, skill in ipairs(expected) do
    assert(Panel.HOTKEY_ORDER[index] == skill)
    assert(Panel.DISPLAY_ORDER[index] == skill)
end

local selected, executed, handlers, rpc_handlers = {}, {}, {}, {}
local fox_rpc = nil
local fox_cast = nil
local server_action = nil
local controller_busy = false
local equipped_prefab = nil
local player = {
    prefab = "eva",
    components = {
        playercontroller = {
            IsAOETargeting = function() return false end,
            IsBusy = function() return controller_busy end,
            DoAction = function(_, action) server_action = action end,
        },
        eva_fox_blink = {
            CastAt = function(_, x, z)
                fox_cast = {x = x, z = z}
                return true, "cast"
            end,
        },
    },
    replica = {
        inventory = {
            GetActiveItem = function() return nil end,
            GetEquippedItem = function()
                return equipped_prefab ~= nil and {prefab = equipped_prefab} or nil
            end,
        },
        rider = {IsRiding = function() return false end},
    },
    HUD = {HasInputFocus = function() return false end},
    IsValid = function() return true end,
    HasTag = function(_, tag) return tag == "eva" end,
    PushBufferedAction = function()
        error("server must route Thuấn Ảnh through PlayerController:DoAction")
    end,
}
local spellbook = {items = {}}
function spellbook:SelectSpell(index)
    selected[#selected + 1] = index
    return true
end
for index = 1, 5 do
    spellbook.items[index] = {execute = function() executed[#executed + 1] = index end}
end
local book = {
    components = {spellbook = spellbook},
    IsValid = function() return true end,
    GetEvaOwner = function() return player end,
}
player._eva_skillbook_entity = book
local frontend = {
    IsControlsDisabled = function() return false end,
    GetActiveScreen = function() return {name = "HUD"} end,
}

Panel.Install({
    add_rpc = function(namespace, name, fn)
        assert(namespace == Panel.NAMESPACE)
        rpc_handlers[name] = fn
    end,
    send_rpc = function(namespace, name, ...)
        fox_rpc = {namespace = namespace, name = name, args = {...}}
    end,
    keys = {49, 50, 51, 52, 53},
    add_key_handler = function(key, fn) handlers[key] = fn end,
    get_player = function() return player end,
    get_frontend = function() return frontend end,
    fox_key = 82,
    get_world_position = function() return {x = 7, z = 9} end,
})
for key = 49, 53 do
    assert(type(handlers[key]) == "function", "missing top-row handler " .. tostring(key))
    handlers[key]()
end
assert(#selected == 5 and #executed == 5)
for index = 1, 5 do
    assert(selected[index] == expected_spell_indexes[index])
    assert(executed[index] == expected_spell_indexes[index])
end
assert(type(handlers[82]) == "function", "missing Thuấn Ảnh R-key handler")
for _, prefab in ipairs({
    "hh_daogam", "hh_daogam2", "hh_daogam3",
    "hh_daogam4", "hh_daogam5", "hh_daogam6",
}) do
    equipped_prefab = prefab
    fox_rpc = nil
    handlers[82]()
    assert(server_action == nil,
        "client R handler must send RPC without executing DoAction locally")
    assert(fox_rpc ~= nil and fox_rpc.namespace == Panel.NAMESPACE
            and fox_rpc.name == Panel.FOX_RPC_NAME,
        "R did not request Thuấn Ảnh while holding " .. prefab)
    assert(fox_rpc.args[1] == 7 and fox_rpc.args[2] == 9,
        "Thuấn Ảnh RPC did not preserve the selected world point for " .. prefab)
end

assert(type(rpc_handlers[Panel.FOX_RPC_NAME]) == "function",
    "missing server handler for the Thuấn Ảnh RPC")
fox_cast = nil
server_action = nil
test_now = 10
local ok, reason = rpc_handlers[Panel.FOX_RPC_NAME](player, 7, 9)
assert(ok == true and reason == "queued", "server rejected a valid Thuấn Ảnh RPC")
assert(fox_cast == nil, "RPC bypassed the EVA_FOX_BLINK action/stategraph")
assert(server_action ~= nil and server_action.doer == player
        and server_action.action == ACTIONS.EVA_FOX_BLINK,
    "server did not route EVA_FOX_BLINK through PlayerController:DoAction")
ok, reason = Panel.CastFoxAction(server_action)
assert(ok == true and reason == "cast", "server action rejected a valid Thuấn Ảnh cast")
assert(fox_cast ~= nil and fox_cast.x == 7 and fox_cast.z == 9,
    "EVA_FOX_BLINK did not route coordinates to eva_fox_blink")

controller_busy = true
server_action = nil
test_now = 11
ok, reason = rpc_handlers[Panel.FOX_RPC_NAME](player, 8, 10)
assert(ok == false and reason == "busy",
    "busy server player must reject Thuấn Ảnh without changing state")
assert(server_action == nil, "busy Thuấn Ảnh request queued an action")
print("PASS: EVA skills use fixed top-row keys 1-5 and Thuấn Ảnh uses R")
''')

main_source = (ROOT / "main/ttk_eva_source.lua").read_text(encoding="utf-8")
assert "fox_key = GLOBAL.KEY_R" in main_source, "runtime does not bind Thuấn Ảnh to GLOBAL.KEY_R"
assert "make_fox_action" not in main_source, "runtime still creates the unsafe client BufferedAction"
assert "playeractionpicker" not in main_source, "runtime still injects Thuấn Ảnh into right-click"
assert "fox_action.rmb" not in main_source, "Thuấn Ảnh still declares itself as a right-click action"
