"""Behavior tests for Lục Nguyên Kiếm Đồng rules and integration."""
from pathlib import Path
import math
import sys
from zipfile import ZipFile

sys.stdout.reconfigure(encoding="utf-8")
ROOT = Path(__file__).resolve().parents[1]
RUNTIME = ROOT.parents[1] / ".superpowers" / "lucnguyen-test-runtime"
sys.path.insert(0, str(RUNTIME))
from lupa.lua51 import LuaRuntime


lua = LuaRuntime(unpack_returned_tuples=True)
with ZipFile("C:/Program Files (x86)/Steam/steamapps/common/Don't Starve Together/data/databundles/scripts.zip") as game:
    lua.execute(game.read("scripts/class.lua").decode())
lua.globals().package.path = (
    str(ROOT / "scripts/?.lua").replace("\\", "/")
    + ";"
    + str(ROOT.parent / "mod_steam/3780347550/scripts/?.lua").replace("\\", "/")
    + ";"
    + lua.globals().package.path
)

# A missing module is the expected initial RED state.
lua.execute(
    r'''
local Rules = require("ttk_lucnguyen_rules")

local low = Rules.RollVolley(100, function(lo, hi) return lo end)
assert(#low == 1 and low[1].damage == 10 and low[1].element == 1)

local high = Rules.RollVolley(100, function(lo, hi) return hi end)
assert(#high == 6)
local seen = {}
for _, shot in ipairs(high) do
    assert(shot.damage == 20 and not seen[shot.element])
    seen[shot.element] = true
end

local values = {3, 1, 10, 1, 15, 1, 20}
local cursor = 0
local independent = Rules.RollVolley(100, function(lo, hi)
    cursor = cursor + 1
    local value = values[cursor]
    assert(value >= lo and value <= hi)
    return value
end)
assert(#independent == 3)
assert(independent[1].element == 1 and independent[1].damage == 10)
assert(independent[2].element == 2 and independent[2].damage == 15)
assert(independent[3].element == 3 and independent[3].damage == 20)
assert(cursor == 7, "each sword must roll its own percentage")

local function angle_delta(a, b)
    return (a - b + math.pi) % (2 * math.pi) - math.pi
end

-- Wraparound must turn across the -pi/pi seam, not take the long path.
local x, z, heading = Rules.Step(0, 0, math.pi - .05,
    -10, -.5, 1 / 30, 6, 3)
assert(math.abs(angle_delta(heading, -math.pi + .05)) < .1)
assert(x < 0, "wrapped heading must move toward the target")

-- A near target is reached exactly instead of overshooting.
local ax, az, ah, arrived = Rules.Step(0, 0, 0, .1, 0, 1 / 30, 12, 8)
assert(arrived and ax == .1 and az == 0 and ah == 0)

-- Different fan angles converge on a moving target under bounded turns.
for _, initial in ipairs({-1.2, -.5, .5, 1.2}) do
    local px, pz, ph = 0, 0, initial
    local reached = false
    for frame = 1, 180 do
        local tx, tz = 8, (frame / 30) * .35
        px, pz, ph, reached = Rules.Step(px, pz, ph, tx, tz, 1 / 30, 12, 8)
        if reached then break end
    end
    assert(reached, "homing sword must reach a moving target before timeout")
end

assert(not Rules.IsExpired(2.99, 3))
assert(Rules.IsExpired(3, 3))
'''
)

print("PASS: volley bounds/uniqueness/independent damage and bounded moving-target steering.")

lua.execute(
    r'''
local Bridge = require("ttk_lucnguyen_combat")

local emitted = {}
local utils = {
    SpawnClientStrFx = function(self, target, text)
        table.insert(emitted, {target = target, text = text})
    end,
}
assert(Bridge.InstallSoloObserver(utils))
assert(Bridge.InstallSoloObserver(utils), "observer installation must be idempotent")

local function entity(name)
    local inst = {name = name, components = {}, events = {}}
    function inst:IsValid() return not self.removed end
    function inst:ListenForEvent(event, fn)
        self.events[event] = self.events[event] or {}
        table.insert(self.events[event], fn)
    end
    function inst:PushEvent(event, data)
        for _, fn in ipairs(self.events[event] or {}) do fn(self, data) end
    end
    return inst
end

local owner1, owner2 = entity("owner1"), entity("owner2")
local target1, target2 = entity("target1"), entity("target2")
local weapon1, weapon2 = entity("weapon1"), entity("weapon2")
local component1 = {inst=owner1}
component1.DoAttackDamage = function(self, attacker, target, damage)
    utils:SpawnClientStrFx(target, "chí mạng x1.5")
    return damage * 1.5
end
local component2 = {inst=owner2}
component2.DoAttackDamage = function(self, attacker, target, damage)
    utils:SpawnClientStrFx(target, "damage")
    return damage
end
assert(Bridge.InstallSoloComponent(component1))
assert(Bridge.InstallSoloComponent(component2))
local token1, token2 = {}, {}
Bridge.BeginPrimary(owner1, target1, weapon1, token1, 64)
Bridge.BeginPrimary(owner2, target2, weapon2, token2, 91)
component1:DoAttackDamage(owner1, target1, 64)
component2:DoAttackDamage(owner2, target2, 91)
Bridge.ObserveLanded(owner1, {target=target1, weapon=weapon1, damageresolved=12})
Bridge.ObserveLanded(owner2, {target=target2, weapon=weapon2, damageresolved=15})
local proc1 = Bridge.EndPrimary(token1)
assert(proc1 and proc1.owner == owner1 and proc1.target == target1 and proc1.base_damage == 64)
assert(Bridge.EndPrimary(token1) == nil, "one primary may resolve only once")
assert(Bridge.EndPrimary(token2) == nil, "ordinary Solo text must not count as a crit")
assert(#emitted == 2, "observer must preserve Solo's original text effect")

-- Crit text only belongs to the exact hh_player:DoAttackDamage call. A nested
-- unrelated attack on the same target must not mark the outer primary.
local nested_token = {}
Bridge.BeginPrimary(owner1, target1, weapon1, nested_token, 50)
local nested_component = {inst=owner2}
nested_component.DoAttackDamage = function(self, attacker, target, damage)
    utils:SpawnClientStrFx(target, "chí mạng")
    return damage * 2
end
Bridge.InstallSoloComponent(nested_component)
local outer_component = {inst=owner1}
outer_component.DoAttackDamage = function(self, attacker, target, damage)
    nested_component:DoAttackDamage(owner2, target, 7)
    return damage
end
Bridge.InstallSoloComponent(outer_component)
outer_component:DoAttackDamage(owner1, target1, 50)
Bridge.ObserveLanded(owner1, {target=target1, weapon=weapon1, damageresolved=50})
assert(Bridge.EndPrimary(nested_token) == nil,
    "a nested unrelated crit must not mark the outer primary")

local same_call_token = {}
Bridge.BeginPrimary(owner1, target1, weapon1, same_call_token, 50)
local recursing = false
local same_component = {inst=owner1}
same_component.DoAttackDamage = function(self, attacker, target, damage)
    if not recursing then
        recursing = true
        self:DoAttackDamage(attacker, target, 5)
        recursing = false
    else
        utils:SpawnClientStrFx(target, "chí mạng")
    end
    return damage
end
Bridge.InstallSoloComponent(same_component)
same_component:DoAttackDamage(owner1, target1, 50)
Bridge.ObserveLanded(owner1, {target=target1, weapon=weapon1, damageresolved=50})
assert(Bridge.EndPrimary(same_call_token) == nil,
    "a nested same-owner/same-target call must not mark the outer primary")

local exact_token = {}
Bridge.BeginPrimary(owner1, target1, weapon1, exact_token, 50)
outer_component.DoAttackDamage = function(self, attacker, target, damage)
    utils:SpawnClientStrFx(target, "chí mạng")
    return damage * 2
end
-- Re-installation keeps the wrapper while allowing the original implementation
-- to be replaced in this test fixture.
Bridge.InstallSoloComponent(outer_component, true)
outer_component:DoAttackDamage(owner1, target1, 50)
Bridge.ObserveLanded(owner1, {target=target1, weapon=weapon1, damageresolved=100})
assert(Bridge.EndPrimary(exact_token) ~= nil,
    "the exact Solo DoAttackDamage call must mark its primary")

local dodged = {}
Bridge.BeginPrimary(owner1, target1, weapon1, dodged, 50)
component1:DoAttackDamage(owner1, target1, 50)
Bridge.ObserveLanded(owner1, {target=target1, weapon=weapon1, damageresolved=0})
assert(Bridge.EndPrimary(dodged) == nil, "zero resolved damage must not proc")

local normal = {}
Bridge.BeginPrimary(owner1, target1, weapon1, normal, 50)
Bridge.ObserveLanded(owner1, {target=target1, weapon=weapon1, damageresolved=20})
assert(Bridge.EndPrimary(normal) == nil, "landed non-critical primary must not proc")

local spawned = {}
local values = {2, 1, 10, 1, 50}
local at = 0
local count = Bridge.LaunchVolley(owner1, target1, 80, function(lo, hi)
    at = at + 1
    return values[at]
end, function(data)
    table.insert(spawned, data)
end)
assert(count == 2 and #spawned == 2)
assert(spawned[1].damage == 8 and spawned[2].damage == 40)
assert(spawned[1].owner == owner1 and spawned[1].target == target1)
assert(spawned[1].element ~= spawned[2].element)

-- Auxiliary damage keeps defensive math and real owner kill credit while
-- suppressing attacker on-hit listeners/callbacks and all offensive rerolls.
local onhit_events, onhit_callbacks, kills = 0, 0, 0
owner1:ListenForEvent("onhitother", function() onhit_events = onhit_events + 1 end)
owner1:ListenForEvent("killed", function(_, data)
    assert(data.attacker == owner1)
    kills = kills + 1
end)
owner1.components.combat = {
    onhitotherfn = function(attacker)
        assert(attacker == owner1)
        onhit_callbacks = onhit_callbacks + 1
    end,
}
target1.components.hh_player = {
    GetBlockDamage = function(_, victim, attacker, damage)
        assert(victim == target1 and attacker == owner1)
        return damage * .5, false
    end,
}
target1.components.combat = {inst=target1}
target1.health = 15
local nested_offense = 0
local godslayer = {inst=owner1}
godslayer.GetBonusDamage = function() return 777 end
assert(Bridge.InstallGodslayerComponent(godslayer))
local worldrank = {}
worldrank.ResolveWorldRankDamageSource = function(self, attacker) return attacker end
assert(Bridge.InstallWorldComponent(worldrank))
local function vanilla_get_attacked(self, attacker, damage, weapon, stimuli)
    assert(self == target1.components.combat and attacker == owner1)
    assert(stimuli == "ttk_lucnguyen_auxiliary")
    -- A nested unrelated event from the same attacker must remain observable.
    attacker:PushEvent("onhitother", {
        target=target2, weapon=weapon2, damageresolved=3,
    })
    nested_offense = nested_offense + 1
    assert(godslayer:GetBonusDamage(target1) == 0,
        "Solo godslayer bonus must be bypassed for auxiliary swords")
    assert(worldrank:ResolveWorldRankDamageSource(attacker) == nil,
        "Solo world-rank outgoing multiplier must be bypassed for auxiliary swords")
    target1.health = target1.health - damage * .5
    attacker:PushEvent("onhitother", {
        target=target1, weapon=weapon, damageresolved=damage,
    })
    if attacker.components.combat.onhitotherfn then
        attacker.components.combat.onhitotherfn(attacker, target1, damage, stimuli, weapon, damage)
    end
    if target1.health <= 0 then
        attacker:PushEvent("killed", {victim=target1, attacker=attacker})
    end
    return true
end
local landed = Bridge.ApplyAuxiliary(owner1, target1, 40, weapon1, vanilla_get_attacked)
assert(landed and target1.health == -5, "victim defense must reduce the immutable damage")
assert(onhit_events == 1 and onhit_callbacks == 0,
    "only the unrelated nested hit may reach offense callbacks")
assert(kills == 1, "kill attribution must stay with the player")
assert(nested_offense == 1, "unrelated nested offense must not be globally suppressed")
assert(worldrank:ResolveWorldRankDamageSource(owner1) == owner1,
    "world-rank behavior must be restored outside the auxiliary call")

target2.components.hh_player = {
    GetBlockDamage = function() return 0, true end,
}
target2.components.combat = {inst=target2}
local called = false
assert(not Bridge.ApplyAuxiliary(owner2, target2, 30, weapon2, function(self, attacker, damage)
    local _, dodged = target2.components.hh_player:GetBlockDamage(target2, attacker, damage)
    if dodged then return false end
    called = true
    return true
end))
assert(not called, "the target's actual GetAttacked wrapper must preserve Solo dodge")
'''
)

print("PASS: scoped actual-crit observation, shot isolation, positive landed damage, and auxiliary defense/callback rules.")

lua.execute(
    r'''
package.loaded["components/hh_player"] = nil
local solo_utils = {
    IsHHType = function(self, value, expected) return type(value) == expected end,
    HasComponents = function(self, inst, name)
        return inst ~= nil and inst.components ~= nil and inst.components[name] ~= nil
    end,
    SpawnClientStrFx = function() end,
    SpawnExplodeFx = function() end,
}
package.preload["utils/hh_utils"] = function() return solo_utils end
package.preload["guild/hh_rank_defs"] = function()
    return {RANK={A="A",B="B"}}
end
package.preload["enums/hh_effects"] = function() return {player={}} end
package.preload["enums/hh_items"] = function() return {} end
package.preload["enums/hh_enchant"] = function()
    return {HH_EQUIP_BUFF_LIST={},HH_GEM_BUFF_LIST={},HH_SUIT_LIST={},HH_SUIT_RECIPE={}}
end
package.preload["enums/hh_prefab_list"] = function()
    return {boss_monster={},endgameboss_monster={},elite_monster={}}
end
package.preload["utils/hh_monster_autostack"] = function()
    return {MarkMonsterLoot=function() end}
end
TUNING={HH_CHANCE_CONFIG={ATK_10s_HEALTH=0}}
TheWorld={state={isday=false,isdusk=false,isnight=false}}
DEGREES=math.pi/180
STRINGS={}
TheNet={Announce=function() end}
SpawnPrefab=function() return nil end

local HHPlayer = require("components/hh_player")
local Bridge = require("ttk_lucnguyen_combat")
assert(Bridge.InstallSoloObserver(solo_utils))

local function entity()
    local inst={components={},events={}}
    function inst:IsValid() return true end
    function inst:ListenForEvent(name, fn)
        self.events[name]=self.events[name] or {}
        table.insert(self.events[name],fn)
    end
    function inst:PushEvent(name,data)
        for _,fn in ipairs(self.events[name] or {}) do fn(self,data) end
    end
    return inst
end
local owner,target,weapon=entity(),entity(),entity()
owner.components.health={IsDead=function() return false end,GetPercent=function() return 1 end}
target.components.health={IsDead=function() return false end,GetPercent=function() return 1 end}
local component=setmetatable({inst=owner,hh_effects={criticalHitRate=100,criticalHitEffect=0}}, {__index=HHPlayer})
function component:GetEffectValueByKey(key) return self.hh_effects[key] or 0 end
function component:HasSpecialEffect() return false end
owner.components.hh_player=component
assert(Bridge.InstallSoloComponent(component))
local token={}
Bridge.BeginPrimary(owner,target,weapon,token,50)
local resolved=component:DoAttackDamage(owner,target,50)
assert(resolved==100, "installed Solo criticalHitRate=100 must use its real x2 branch")
Bridge.ObserveLanded(owner,{target=target,weapon=weapon,damageresolved=resolved})
assert(Bridge.EndPrimary(token) ~= nil, "real Solo critical branch must trigger the volley context")

component.hh_effects.criticalHitRate=0
local normal={}
Bridge.BeginPrimary(owner,target,weapon,normal,50)
assert(component:DoAttackDamage(owner,target,50)==50)
Bridge.ObserveLanded(owner,{target=target,weapon=weapon,damageresolved=50})
assert(Bridge.EndPrimary(normal)==nil, "real Solo zero critical chance must not proc")
'''
)
print("PASS: installed Solo hh_player:DoAttackDamage integration at deterministic 100% and 0% critical rate.")

required = [
    ROOT / "scripts/prefabs/ttk_lucnguyenkiemdong.lua",
    ROOT / "main/ttk_lucnguyenkiemdong.lua",
    ROOT / "anim/ttk_lucnguyen_weapon.zip",
    ROOT / "anim/ttk_lucnguyen_kim.zip",
    ROOT / "anim/ttk_lucnguyen_moc.zip",
    ROOT / "anim/ttk_lucnguyen_thuy.zip",
    ROOT / "anim/ttk_lucnguyen_hoa.zip",
    ROOT / "anim/ttk_lucnguyen_tho.zip",
    ROOT / "anim/ttk_lucnguyen_loi.zip",
    ROOT / "images/inventoryimages/ttk_lucnguyenkiemdong.xml",
    ROOT / "images/inventoryimages/ttk_lucnguyenkiemdong.tex",
]
missing = [str(path.relative_to(ROOT)) for path in required if not path.is_file()]
assert not missing, f"missing Lục Nguyên integration files: {missing}"

modmain = (ROOT / "modmain.lua").read_text(encoding="utf-8")
assert 'modimport("main/ttk_lucnguyenkiemdong.lua")' in modmain
main = (ROOT / "main/ttk_lucnguyenkiemdong.lua").read_text(encoding="utf-8")
assert 'AddRecipe2("ttk_lucnguyenkiemdong"' in main
assert 'G.TECH.SCIENCE_TWO' in main
assert all(token in main for token in (
    'G.Ingredient("ttk_votuongkiem", 1)',
    'G.Ingredient("ttk_thanhtrucphongvankiem", 1)',
    'G.Ingredient("ttk_tinhlakiem", 1)',
    'G.Ingredient("ttk_phanthienkiem", 1)',
    'G.Ingredient("ttk_tienkiem", 1)',
    'G.Ingredient("ttk_makiem", 1)',
))
print("PASS: feature files, registration, recipe and namespaced assets are present.")
