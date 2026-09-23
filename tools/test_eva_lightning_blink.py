from pathlib import Path
import sys
import unittest


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT.parents[1] / ".superpowers/ttk-solo-integration/lua-runtime"))
from lupa.lua51 import LuaRuntime


class EvaLightningBlinkTests(unittest.TestCase):
    def setUp(self):
        self.lua = LuaRuntime(unpack_returned_tuples=True)
        self.lua.globals().package.path = (
            ROOT.joinpath("scripts/?.lua").as_posix()
            + ";"
            + self.lua.globals().package.path
        )
        self.lua.execute(
            r'''
function Class(constructor)
    local class = {}
    class.__index = class
    return setmetatable(class, {
        __call = function(_, ...)
            local instance = setmetatable({}, class)
            constructor(instance, ...)
            return instance
        end,
    })
end

package.preload["util/eva_skillpanel"] = function()
    return {IsAuthorizedNativeCast = function() return false end}
end

RADIANS = 180 / math.pi
TILE_SCALE = 4
now = 100
GetTime = function() return now end
Vector3 = function(x, y, z)
    return {x = x, y = y, z = z, Get = function(self) return self.x, self.y, self.z end}
end

map_state = {blocked = false, passable = true, ocean = false, platform = nil}
TheWorld = {
    ismastersim = true,
    Map = {
        GetSize = function() return 100, 100 end,
        IsGroundTargetBlocked = function() return map_state.blocked end,
        GetPlatformAtPoint = function() return map_state.platform end,
        IsPassableAtPoint = function() return map_state.passable end,
        IsOceanAtPoint = function() return map_state.ocean end,
    },
    HasTag = function() return false end,
}
teleport_permitted = true
IsTeleportingPermittedFromPointToPoint = function()
    return teleport_permitted
end
pvp_enabled = false
TheNet = {GetPVPEnabled = function() return pvp_enabled end}

find_results = {}
find_call = nil
TheSim = {
    FindEntities = function(_, x, y, z, radius, must, cant)
        find_call = {x = x, y = y, z = z, radius = radius, must = must, cant = cant}
        return find_results
    end,
}

spawned = {}
SpawnPrefab = function(name)
    local fx = {
        prefab = name,
        Transform = {
            SetPosition = function(self, x, y, z) self.position = {x, y, z} end,
            SetRotation = function(self, rotation) self.rotation = rotation end,
        },
        AnimState = {
            SetMultColour = function(self, ...) self.multcolour = {...} end,
        },
    }
    table.insert(spawned, fx)
    return fx
end

function tags(...)
    local result = {}
    for _, value in ipairs({...}) do result[value] = true end
    return result
end

function MakeTarget(name, x, z, target_tags)
    local target = {
        name = name,
        tags = target_tags or tags("hostile"),
        x = x,
        z = z,
        hits = {},
        components = {},
        entity = {IsVisible = function() return true end},
    }
    target.Transform = {GetWorldPosition = function() return target.x, 0, target.z end}
    target.components.health = {IsDead = function() return false end}
    target.components.combat = {
        target = nil,
        GetAttacked = function(_, owner, damage, weapon, stimuli)
            table.insert(target.hits, {
                owner = owner,
                damage = damage,
                weapon = weapon,
                stimuli = stimuli,
                ignorehitrange = owner.components.combat.ignorehitrange,
            })
            return true
        end,
    }
    function target:IsValid() return true end
    function target:IsInLimbo() return false end
    function target:HasTag(tag) return self.tags[tag] == true end
    function target:GetPhysicsRadius(default) return self.physics_radius or default end
    return target
end

function MakeOwner()
    local owner = {
        x = 0,
        z = 0,
        tags = tags("eva", "player"),
        tasks = {},
        hidden = 0,
        shown = 0,
        removed_tags = {},
        added_tags = {},
        components = {},
    }
    owner.Transform = {
        GetWorldPosition = function() return owner.x, 0, owner.z end,
    }
    owner.Physics = {
        Teleport = function(_, x, _, z)
            owner.x, owner.z = x, z
            owner.teleports = (owner.teleports or 0) + 1
        end,
    }
    owner.SoundEmitter = {
        PlaySound = function(_, sound)
            owner.sounds = owner.sounds or {}
            table.insert(owner.sounds, sound)
        end,
    }
    owner.components.health = {IsDead = function() return false end}
    owner.components.combat = {
        ignorehitrange = "outer",
        CanTarget = function(_, target) return target._can_target ~= false end,
        IsAlly = function(_, target) return target._ally == true end,
    }
    owner.sg = {
        currentstate = {name = "eva_skill_cast"},
        HasStateTag = function() return false end,
        GoToState = function(_, state) owner.goto_state = state end,
    }
    function owner:IsValid() return true end
    function owner:IsInLimbo() return false end
    function owner:HasTag(tag) return self.tags[tag] == true end
    function owner:AddTag(tag) self.tags[tag] = true; table.insert(self.added_tags, tag) end
    function owner:RemoveTag(tag) self.tags[tag] = nil; table.insert(self.removed_tags, tag) end
    function owner:Hide() self.hidden = self.hidden + 1 end
    function owner:Show() self.shown = self.shown + 1 end
    function owner:ListenForEvent() end
    function owner:RemoveEventCallback() end
    function owner:PushEvent(name, data)
        self.events = self.events or {}
        table.insert(self.events, {name = name, data = data})
    end
    function owner:DoTaskInTime(delay, fn)
        local task = {delay = delay, fn = fn, cancelled = false}
        function task:Cancel() self.cancelled = true end
        table.insert(self.tasks, task)
        return task
    end
    return owner
end

function RunTasks(owner, delay)
    for _, task in ipairs(owner.tasks) do
        if not task.cancelled and task.delay <= delay then
            task.cancelled = true
            task.fn()
        end
    end
end

EvaFoxBlink = require("components/eva_fox_blink")
'''
        )

    def execute(self, code):
        try:
            self.lua.execute(code)
        except Exception as error:
            self.fail(str(error))

    def test_valid_cast_blinks_after_quarter_second_and_hits_each_enemy_once(self):
        self.execute(
            r'''
local owner = MakeOwner()
local first = MakeTarget("first", 3, 0)
local second = MakeTarget("second", 9.5, 1.2)
local off_path = MakeTarget("off_path", 5, 1.6)
local ally = MakeTarget("ally", 5, 0); ally._ally = true
local player = MakeTarget("player", 5, 0, tags("hostile", "player"))
local companion = MakeTarget("companion", 5, 0, tags("companion"))
local follower = MakeTarget("follower", 5, 0, {})
follower.components.follower = {
    leader = {HasTag = function(_, tag) return tag == "player" end},
}
local grounded_bird = MakeTarget("grounded_bird", 5, 0, tags("bird"))
local flying_bird = MakeTarget("flying_bird", 5, 0, tags("bird", "flight"))
flying_bird.sg = {HasStateTag = function(_, tag) return tag == "flight" end}
flying_bird._can_target = false
find_results = {
    first, first, second, off_path, ally, player, companion, follower,
    grounded_bird, flying_bird,
}

local blink = EvaFoxBlink(owner)
local ok, reason = blink:CastAt(10, 0)
assert(ok and reason == "cast")
assert(blink.active == true and blink.cooldown_end == 0)
assert(owner.x == 0 and #first.hits == 0 and #spawned == 0)
assert(#owner.tasks == 1 and owner.tasks[1].delay == .25)

RunTasks(owner, .25)
assert(owner.x == 10 and owner.z == 0 and owner.teleports == 1)
assert(blink.active == false and blink.cooldown_end == 115)
assert(owner.hidden == 0 and owner.shown == 0, "EVA appearance must remain visible")
assert(#spawned == 2)
for _, fx in ipairs(spawned) do
    assert(fx.prefab == "spear_wathgrithr_lightning_lunge_fx")
    assert(math.abs(fx.Transform.rotation) < .00001)
    local colour = fx.AnimState.multcolour
    assert(math.abs(colour[1] - 216 / 255) < .00001)
    assert(math.abs(colour[2] - 239 / 255) < .00001)
    assert(colour[3] == 1 and colour[4] == 1)
end
assert(spawned[1].Transform.position[1] == 5 and spawned[1].Transform.position[3] == 0)
assert(spawned[2].Transform.position[1] == 10 and spawned[2].Transform.position[3] == 0)
assert(#owner.sounds == 1 and owner.sounds[1] == "meta3/wigfrid/spear_lighting_lunge")
assert(find_call.x == 5 and find_call.z == 0 and find_call.radius == 8)
assert(#first.hits == 1 and #second.hits == 1, "each eligible enemy needs exactly one hit")
assert(first.hits[1].damage == 600 and first.hits[1].stimuli == "eva_fox_blink")
assert(first.hits[1].ignorehitrange == true)
assert(#grounded_bird.hits == 1, "grounded attackable bird must be hit")
assert(grounded_bird.hits[1].damage == 600)
assert(#flying_bird.hits == 1, "flying bird on the path must also be hit")
assert(flying_bird.hits[1].damage == 600)
assert(#off_path.hits == 0 and #ally.hits == 0 and #player.hits == 0)
assert(#companion.hits == 0 and #follower.hits == 0,
    "companions and player followers must stay protected")
assert(owner.components.combat.ignorehitrange == "outer", "outer combat guard must be restored")
'''
        )

    def test_invalid_initial_destination_has_no_cast_side_effects(self):
        self.execute(
            r'''
for _, mode in ipairs({"range", "blocked", "teleport"}) do
    map_state.blocked = mode == "blocked"
    teleport_permitted = mode ~= "teleport"
    spawned, find_results = {}, {}
    local owner = MakeOwner()
    local blink = EvaFoxBlink(owner)
    local x = mode == "range" and 21 or 10
    local ok = blink:CastAt(x, 0)
    assert(not ok, mode)
    assert(not blink.active and blink.cooldown_end == 0, mode)
    assert(#owner.tasks == 0 and owner.teleports == nil, mode)
    assert(#spawned == 0 and owner.sounds == nil, mode)
end
'''
        )

    def test_destination_is_revalidated_before_any_damage_or_cooldown(self):
        self.execute(
            r'''
local owner = MakeOwner()
local enemy = MakeTarget("enemy", 5, 0)
find_results = {enemy}
local blink = EvaFoxBlink(owner)
assert(blink:CastAt(10, 0))
map_state.blocked = true
RunTasks(owner, .25)
assert(owner.teleports == nil and owner.x == 0)
assert(#enemy.hits == 0 and #spawned == 0 and owner.sounds == nil)
assert(blink.cooldown_end == 0 and not blink.active)
assert(owner.goto_state == "idle")
'''
        )

    def test_resolution_uses_the_current_origin_for_path_and_fx(self):
        self.execute(
            r'''
local owner = MakeOwner()
local enemy = MakeTarget("enemy", 6, 0)
find_results = {enemy}
local blink = EvaFoxBlink(owner)
assert(blink:CastAt(10, 0))
owner.x = 2
RunTasks(owner, .25)
assert(find_call.x == 6 and find_call.radius == 7)
assert(spawned[1].Transform.position[1] == 6)
assert(#enemy.hits == 1 and owner.teleports == 1)
'''
        )

    def test_interruption_before_resolution_cancels_without_side_effects(self):
        self.execute(
            r'''
local owner = MakeOwner()
local enemy = MakeTarget("enemy", 5, 0)
find_results = {enemy}
local blink = EvaFoxBlink(owner)
assert(blink:CastAt(10, 0))
owner.sg.currentstate = {name = "hit"}
blink._onnewstate()
RunTasks(owner, .25)
assert(not blink.active and blink.cooldown_end == 0)
assert(owner.teleports == nil and #enemy.hits == 0 and #spawned == 0)
'''
        )

    def test_client_simulation_cannot_start_the_server_cast(self):
        self.execute(
            r'''
TheWorld.ismastersim = false
local owner = MakeOwner()
local blink = EvaFoxBlink(owner)
local ok, reason = blink:CastAt(10, 0)
assert(not ok and reason == "not_master")
assert(not blink.active and blink.cooldown_end == 0 and #owner.tasks == 0)
'''
        )

    def test_all_six_solo_weapons_allow_the_blink_to_finish(self):
        self.execute(
            r'''
for _, prefab in ipairs({
    "hh_daogam", "hh_daogam2", "hh_daogam3",
    "hh_daogam4", "hh_daogam5", "hh_daogam6",
}) do
    local owner = MakeOwner()
    local weapon = {prefab = prefab}
    owner.components.inventory = {
        GetEquippedItem = function() return weapon end,
    }
    local blink = EvaFoxBlink(owner)
    local ok, reason = blink:CastAt(10, 0)
    assert(ok and reason == "cast", prefab)
    RunTasks(owner, .25)
    assert(owner.x == 10 and owner.teleports == 1, prefab)
    assert(not blink.active, prefab)
end
'''
        )

    def test_damage_error_restores_nested_guards_and_finishes_cast(self):
        self.execute(
            r'''
local owner = MakeOwner()
owner.components.hh_player = {}
owner.components.combat.ignorehitrange = false
owner._is_splashing_aoe = false
local enemy = MakeTarget("enemy", 5, 0)
enemy.components.combat.GetAttacked = function()
    assert(owner.components.combat.ignorehitrange == true)
    assert(owner._is_splashing_aoe == true)
    error("engine hit failure")
end
find_results = {enemy}
local blink = EvaFoxBlink(owner)
assert(blink:CastAt(10, 0))
local ok = pcall(function() RunTasks(owner, .25) end)
assert(ok, "scheduled cast must clean up an isolated hit failure")
assert(owner.components.combat.ignorehitrange == false)
assert(owner._is_splashing_aoe == false)
assert(not blink.active and not owner:HasTag("eva_fox_casting"))
assert(blink.cooldown_end == 115 and owner.teleports == 1)
'''
        )

    def test_save_load_uses_fifteen_second_cooldown_cap(self):
        self.execute(
            r'''
local owner = MakeOwner()
local blink = EvaFoxBlink(owner)
blink:OnLoad({cooldown = 99})
assert(blink.cooldown_end == 115)
now = 105
local saved = blink:OnSave()
assert(saved.cooldown == 10)
'''
        )


if __name__ == "__main__":
    unittest.main()
