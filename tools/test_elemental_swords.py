"""Deterministic behavior tests for the six Lục Nguyên elemental swords."""
from pathlib import Path
from zipfile import ZipFile
import sys
import unittest

sys.stdout.reconfigure(encoding="utf-8")
ROOT = Path(__file__).resolve().parents[1]
RUNTIME = ROOT.parents[1] / ".superpowers" / "lucnguyen-test-runtime"
sys.path.insert(0, str(RUNTIME))
from lupa.lua51 import LuaRuntime


lua = LuaRuntime(unpack_returned_tuples=True)
with ZipFile("C:/Program Files (x86)/Steam/steamapps/common/Don't Starve Together/data/databundles/scripts.zip") as game:
    lua.execute(game.read("scripts/class.lua").decode())
    lua.globals().FiniteUses = lua.execute(game.read("scripts/components/finiteuses.lua").decode())
    lua.globals().Trader = lua.execute(game.read("scripts/components/trader.lua").decode())

lua.globals().package.path = (
    str(ROOT / "scripts/?.lua").replace("\\", "/") + ";" + lua.globals().package.path
)

lua.execute(r'''
local now = 0
GetTime = function() return now end
SetTestTime = function(value) now = value end

local function entity(tags)
    local inst = {components={}, tags={}, events={}, tasks={}, removed=false}
    for _, tag in ipairs(tags or {}) do inst.tags[tag] = true end
    function inst:IsValid() return not self.removed end
    function inst:IsInLimbo() return false end
    function inst:HasTag(tag) return self.tags[tag] == true end
    function inst:AddTag(tag) self.tags[tag] = true end
    function inst:RemoveTag(tag) self.tags[tag] = nil end
    function inst:ListenForEvent(name, fn)
        self.events[name] = self.events[name] or {}
        table.insert(self.events[name], fn)
    end
    function inst:RemoveEventCallback(name, fn)
        local listeners = self.events[name] or {}
        for i=#listeners,1,-1 do if listeners[i] == fn then table.remove(listeners,i) end end
    end
    function inst:PushEvent(name, data)
        for _, fn in ipairs(self.events[name] or {}) do fn(self, data) end
    end
    function inst:DoTaskInTime(delay, fn)
        local task = {cancelled=false, delay=delay, fn=fn}
        function task:Cancel() self.cancelled = true end
        table.insert(self.tasks, task)
        return task
    end
    function inst:Remove() self.removed = true end
    inst.Transform={x=0,y=0,z=0}
    function inst.Transform:GetWorldPosition() return self.x,self.y,self.z end
    function inst.Transform:SetPosition(x,y,z) self.x,self.y,self.z=x,y,z end
    return inst
end
NewTestEntity = entity

local found = {}
TheSim = {FindEntities=function() return found end}
SetFoundEntities = function(value) found = value end

local Elements = require("ttk_elemental_combat")
local owner = entity({"player"})
owner.components.combat={
    target=nil,
    IsAlly=function(_,candidate) return candidate.isally == true end,
    CanTarget=function() return true end,
    GetAttacked=function() return true end,
}
local function enemy(tags)
    local inst=entity(tags or {"hostile","_combat"})
    inst.components.health={IsDead=function() return false end}
    inst.components.combat={target=owner}
    return inst
end

-- Slow refresh catches stacked modifiers or a stale expiry removing a refresh.
local slowed=enemy()
slowed.components.locomotor={multipliers={}}
function slowed.components.locomotor:SetExternalSpeedMultiplier(source,key,value)
    self.multipliers[key]=value
end
function slowed.components.locomotor:RemoveExternalSpeedMultiplier(source,key)
    self.multipliers[key]=nil
end
assert(Elements.ApplySlow(slowed,.25,3))
local first_task=slowed.tasks[#slowed.tasks]
assert(slowed.components.locomotor.multipliers.ttk_elemental_slow == .75)
assert(Elements.ApplySlow(slowed,.25,3))
local second_task=slowed.tasks[#slowed.tasks]
assert(first_task.cancelled and not second_task.cancelled)
second_task.fn(slowed)
assert(slowed.components.locomotor.multipliers.ttk_elemental_slow == nil)

-- Shield catches pre-defense interception, stacking, downgrade, and heal/revive deltas.
local shielded=entity({"player"})
local received={}
shielded.components.health={deltamodifierfn=function(inst,amount) return amount*.5 end}
shielded.components.combat={GetAttacked=function(self,attacker,damage,weapon,stimuli,spdamage)
    local combined=damage+(spdamage ~= nil and spdamage.planar or 0)
    local delta=-combined
    if shielded.components.health.deltamodifierfn ~= nil then
        delta=shielded.components.health.deltamodifierfn(shielded,delta,false,"combat",false,attacker,false)
    end
    -- Combat emits attacked/onhit callbacks after its health delta but before
    -- GetAttacked returns. This unrelated health cost must not use the shield.
    local unrelated={prefab="unrelated_cost"}
    local callback_delta=-10
    if shielded.components.health.deltamodifierfn ~= nil then
        callback_delta=shielded.components.health.deltamodifierfn(
            shielded,callback_delta,false,"callback",false,unrelated,false)
    end
    table.insert(received,{delta=delta,damage=damage,spdamage=spdamage,
        callback_delta=callback_delta})
    return true
end}
SetTestTime(10)
assert(Elements.ApplyShield(shielded,30,5))
shielded.components.combat:GetAttacked(enemy(),12,nil,nil,{planar=4})
assert(received[#received].delta == 0 and received[#received].damage == 12)
assert(received[#received].spdamage.planar == 4)
assert(received[#received].callback_delta == -5,
    "shield modifier must disarm before synchronous attacked callbacks")
assert(shielded._ttk_elemental_shield.remaining == 22,
    "shield must consume the final delta after the pre-existing defense modifier")
local old_expires=shielded._ttk_elemental_shield.expires
SetTestTime(11)
assert(Elements.ApplyShield(shielded,10,3))
assert(shielded._ttk_elemental_shield.remaining == 22)
assert(shielded._ttk_elemental_shield.expires == old_expires)
shielded.components.combat:GetAttacked(enemy(),50)
assert(received[#received].delta == -3 and shielded._ttk_elemental_shield == nil)
assert(shielded.components.health.deltamodifierfn ~= nil,
    "shield wrapper must restore the pre-existing health modifier")
shielded.components.health.deltamodifierfn(shielded,10)
assert(shielded._ttk_elemental_shield == nil, "positive heal/revive deltas cannot consume shield")

-- Hostile scans reject allies, neutrals and players; prevent accidental PvP.
local primary,hostile1,hostile2=enemy(),enemy(),enemy()
local neutral=enemy({"_combat"}); neutral.components.combat.target=nil
local ally=enemy(); ally.isally=true
local engaged_player=enemy({"player","_combat"})
local unrelated_player=enemy({"player","_combat"}); unrelated_player.components.combat.target=nil
SetFoundEntities({primary,hostile1,neutral,ally,unrelated_player,hostile2})
local candidates=Elements.CollectEnemies(owner,primary,6,primary,2)
assert(#candidates == 2 and candidates[1] == hostile1 and candidates[2] == hostile2)
SetFoundEntities({unrelated_player,engaged_player})
local pvp=Elements.CollectEnemies(owner,primary,6,primary)
assert(#pvp == 0, "secondary effects stay monster-focused and never create PvP splash")
SetFoundEntities({primary,hostile1,hostile2})

local function damage_target(inst)
    inst.hits={}
    inst.components.combat.GetAttacked=function(self,attacker,damage,weapon,stimuli,spdamage)
        table.insert(inst.hits,{attacker=attacker,damage=damage,weapon=weapon,
            stimuli=stimuli,spdamage=spdamage})
        return true
    end
end
damage_target(primary); damage_target(hostile1); damage_target(hostile2)
local weapon=entity(); weapon.components.weapon={GetDamage=function() return 100 end}
owner.components.health={healed=0,IsDead=function() return false end,
    DoDelta=function(self,amount) self.healed=self.healed+amount end}

-- Gun impacts catch wrong elemental values and recursion-prone extra hits.
SetTestTime(20)
assert(Elements.ApplySwordImpact(owner,primary,20,weapon,1,function() return 1 end))
assert(primary.hits[#primary.hits].damage == 20)
assert(primary.hits[#primary.hits].spdamage.planar == 10)

assert(Elements.ApplySwordImpact(owner,primary,20,weapon,2,function() return 1 end))
assert(owner.components.health.healed == 2)
Elements.ApplySwordImpact(owner,primary,20,weapon,2,function() return 1 end)
assert(owner.components.health.healed == 2)
SetTestTime(23)
Elements.ApplySwordImpact(owner,primary,20,weapon,2,function() return 1 end)
assert(owner.components.health.healed == 4)

primary.components.locomotor=slowed.components.locomotor; primary.tasks={}
Elements.ApplySwordImpact(owner,primary,20,weapon,3,function() return .19 end)
assert(primary.tasks[#primary.tasks].delay == 2)

local before_primary=#primary.hits
Elements.ApplySwordImpact(owner,primary,20,weapon,4,function() return 1 end)
assert(#primary.hits == before_primary+1)
assert(hostile1.hits[#hostile1.hits].damage == 10 and hostile2.hits[#hostile2.hits].damage == 10)

SetTestTime(30)
Elements.ApplySwordImpact(owner,primary,20,weapon,5,function() return 1 end)
assert(owner._ttk_elemental_shield.remaining == 10)
Elements.ApplySwordImpact(owner,primary,20,weapon,5,function() return 1 end)
assert(owner._ttk_elemental_shield.remaining == 10)

local h1,h2=#hostile1.hits,#hostile2.hits
Elements.ApplySwordImpact(owner,primary,20,weapon,6,function() return 1 end)
assert(#hostile1.hits == h1+1 and hostile1.hits[#hostile1.hits].damage == 10)
assert(#hostile2.hits == h2)

-- Held procs catch non-landed counting, wrong cadence/duration/damage and recursion.
assert(not Elements.IsLandedPrimary(owner,{target=primary,weapon=weapon,damageresolved=0},weapon))
assert(not Elements.IsLandedPrimary(owner,{target=primary,weapon=entity(),damageresolved=10},weapon))
assert(Elements.IsLandedPrimary(owner,{target=primary,weapon=weapon,damageresolved=10},weapon))

local spawned={}
local function spawn(name)
    local result=entity(); result.prefab=name
    function result:Launch(data) self.data=data; table.insert(spawned,self) end
    return result
end
for i=1,3 do Elements.HandleHeldHit(weapon,owner,
    {target=primary,weapon=weapon,damageresolved=10},2,function() return 1 end,spawn) end
assert(#spawned == 0)
Elements.HandleHeldHit(weapon,owner,{target=primary,weapon=weapon,damageresolved=10},2,
    function() return 1 end,spawn)
assert(#spawned == 1 and spawned[1].prefab == "ttk_lucnguyen_sword_2")
assert(spawned[1].data.damage == 40 and spawned[1].data.apply_impact == false)

primary.tasks={}
Elements.HandleHeldHit(weapon,owner,{target=primary,weapon=weapon,damageresolved=10},3,
    function() return .19 end)
assert(primary.tasks[#primary.tasks].delay == 3)

local p0,a0=#primary.hits,#hostile1.hits
Elements.HandleHeldHit(weapon,owner,{target=primary,weapon=weapon,damageresolved=10},4,
    function() return .14 end)
assert(#primary.hits == p0+1 and primary.hits[#primary.hits].damage == 30)
assert(#hostile1.hits == a0+1 and hostile1.hits[#hostile1.hits].damage == 30)

weapon._ttk_tho_hits=nil
for i=1,5 do Elements.HandleHeldHit(weapon,owner,
    {target=primary,weapon=weapon,damageresolved=10},5,function() return 1 end) end
assert(owner._ttk_elemental_shield.remaining == 30)

local l1,l2=#hostile1.hits,#hostile2.hits
Elements.HandleHeldHit(weapon,owner,{target=primary,weapon=weapon,damageresolved=10},6,
    function() return .19 end)
assert(#hostile1.hits == l1+1 and hostile1.hits[#hostile1.hits].damage == 35)
assert(#hostile2.hits == l2+1 and hostile2.hits[#hostile2.hits].damage == 35)
''')
print("PASS: elemental procs, hostile filtering, slow refresh, cooldowns, and shield absorption.")


lua.execute(r'''
local function noop() end
local dummy=setmetatable({}, {__index=function() return noop end})
TheWorld={ismastersim=true}; TheNet={IsDedicated=function() return true end}
Asset=function(...) return {...} end
Prefab=function(name,fn,assets,deps) return {name=name,fn=fn,assets=assets,deps=deps} end
MakeInventoryPhysics=noop; MakeInventoryFloatable=noop; MakeHauntableLaunch=noop
function CreateEntity()
 local e=NewTestEntity(); e.entity=dummy
 e.AnimState=setmetatable({}, {__index=function() return noop end})
 function e:AddTag(tag) self.tags[tag]=true end
 function e:AddComponent(name)
  local c={inst=self}; self.components[name]=c
  if name=="weapon" then
   function c:SetDamage(v) self.damage=v end; function c:GetDamage() return self.damage end
   function c:SetRange(v) self.range=v end
  elseif name=="finiteuses" then self.components[name]=FiniteUses(self)
  elseif name=="trader" then self.components[name]=Trader(self)
  elseif name=="planardamage" then function c:SetBaseDamage(v) self.basedamage=v end
  elseif name=="equippable" then
   function c:SetOnEquip(fn) self.onequip=fn end; function c:SetOnUnequip(fn) self.onunequip=fn end
   function c:SetOnEquipToModel(fn) self.onequiptomodel=fn end
  end
 end
 return e
end
''')

returned=lua.execute((ROOT/"scripts/prefabs/ttk_elemental_swords.lua").read_text(encoding="utf-8"))
if not isinstance(returned, tuple): returned=(returned,)
prefabs={prefab["name"]:prefab for prefab in returned}
expected={"ttk_votuongkiem":10,"ttk_thanhtrucphongvankiem":None,
          "ttk_phanthienkiem":None,"ttk_tienkiem":None,"ttk_makiem":None}
assert set(prefabs)==set(expected),prefabs.keys()
for name,planar in expected.items():
    sword=prefabs[name]["fn"]()
    assert sword["components"]["weapon"]["damage"]==100
    assert sword["components"]["weapon"]["range"]==2
    uses=sword["components"]["finiteuses"]
    assert uses["total"]==1000 and uses.GetUses(uses)==1000
    assert sword["components"]["equippable"]["restrictedtag"] is None
    if planar is not None: assert sword["components"]["planardamage"]["basedamage"]==planar
    uses.Use(uses,1000)
    assert not sword.IsValid(sword),f"{name} must disappear at zero durability"

moc=prefabs["ttk_thanhtrucphongvankiem"]["fn"]()
moc["_ttk_moc_hits"]=3
moc_save=lua.table()
moc.OnSave(moc,moc_save)
moc_loaded=prefabs["ttk_thanhtrucphongvankiem"]["fn"]()
moc_loaded.OnLoad(moc_loaded,moc_save)
assert moc_loaded["_ttk_moc_hits"]==3

tho=prefabs["ttk_tienkiem"]["fn"]()
tho["_ttk_tho_hits"]=4
tho_save=lua.table()
tho.OnSave(tho,tho_save)
tho_loaded=prefabs["ttk_tienkiem"]["fn"]()
tho_loaded.OnLoad(tho_loaded,tho_save)
assert tho_loaded["_ttk_tho_hits"]==4

new_names=set(expected)
for name in new_names:
    assert (ROOT/f"images/inventoryimages/{name}.xml").is_file()
    assert (ROOT/f"images/inventoryimages/{name}.tex").is_file()

# Catch equip builds that exist but do not expose the symbol selected by the
# held override. Red/purple are adapted from autonomous sword builds (`png`).
swap_symbols={
    "ttk_lucnguyen_kim.zip":b"swap",
    "ttk_lucnguyen_moc.zip":b"swap",
    "ttk_lucnguyen_hoa.zip":b"png",
    "ttk_lucnguyen_tho.zip":b"png",
    "ttk_lucnguyen_loi.zip":b"png",
}
for archive_name,symbol in swap_symbols.items():
    with ZipFile(ROOT/"anim"/archive_name) as archive:
        assert symbol in archive.read("build.bin"),(archive_name,symbol)

lua.execute(r'''
GLOBAL=_G; PrefabFiles={}; STRINGS={NAMES={},RECIPE_DESC={},CHARACTERS={GENERIC={DESCRIBE={}}}}
TECH={SCIENCE_TWO=2}; Ingredient=function(name,count) return {name=name,count=count} end
RECIPES={}; RegisterInventoryItemAtlas=function() end
AddRecipe2=function(name,ingredients,tech,config,filters)
 RECIPES[name]={ingredients=ingredients,tech=tech,config=config,filters=filters}
end
AddComponentPostInit=function() end; AddSimPostInit=function() end
''')
lua.execute((ROOT/"main/ttk_elemental_swords.lua").read_text(encoding="utf-8"))
lua.execute((ROOT/"main/ttk_tinhlakiem.lua").read_text(encoding="utf-8"))
lua.execute((ROOT/"main/ttk_lucnguyenkiemdong.lua").read_text(encoding="utf-8"))
recipes=lua.globals().RECIPES
costs={
 "ttk_votuongkiem":{"ttk_lingshi2":1,"goldnugget":12,"flint":6},
 "ttk_thanhtrucphongvankiem":{"ttk_lingshi2":1,"livinglog":6,"twigs":12},
 "ttk_tinhlakiem":{"ttk_lingshi2":1,"bluegem":3,"goldnugget":6},
 "ttk_phanthienkiem":{"ttk_lingshi2":1,"redgem":3,"charcoal":6},
 "ttk_tienkiem":{"ttk_lingshi2":1,"thulecite":6,"rocks":12},
 "ttk_makiem":{"ttk_lingshi2":1,"purplegem":3,"nightmarefuel":6},
}
for name,expected_cost in costs.items():
    recipe=recipes[name]
    actual={ingredient["name"]:ingredient["count"] for ingredient in recipe["ingredients"].values()}
    assert actual==expected_cost,(name,actual)
    assert recipe["tech"]==2 and recipe["config"]["no_deconstruction"] is True
gun=recipes["ttk_lucnguyenkiemdong"]
gun_cost={ingredient["name"]:ingredient["count"] for ingredient in gun["ingredients"].values()}
assert gun_cost=={name:1 for name in costs}
assert gun["config"]["no_deconstruction"] is True
modmain=(ROOT/"modmain.lua").read_text(encoding="utf-8")
assert 'modimport("main/ttk_elemental_swords.lua")' in modmain
print("PASS: independent prefabs, native Kim planar, exact recipes, namespaced icons.")

for path in ROOT.rglob("*.lua"):
    lua.execute("assert(loadstring(...))",path.read_text(encoding="utf-8-sig"))
print("PASS: all TuTienKy Lua parses as Lua 5.1.")


class PhamNhanPacketBoundaryTests(unittest.TestCase):
    """Exercise real elemental listeners against the installed DST combat hook."""

    def setUp(self):
        from test_combat_pipeline import PipelineTests

        self.pipeline = PipelineTests()
        self.pipeline.setUp()
        self.lua = self.pipeline.lua
        self.lua.execute(r'''
Elements=require('ttk_elemental_combat')
utils.GetTopFollowerOwner=function() return nil end
function listenable(inst)
 inst.listeners={}
 function inst:ListenForEvent(name,fn)
  self.listeners[name]=self.listeners[name] or {}
  table.insert(self.listeners[name],fn)
 end
 function inst:RemoveEventCallback(name,fn)
  for i=#(self.listeners[name] or {}),1,-1 do
   if self.listeners[name][i]==fn then table.remove(self.listeners[name],i) end
  end
 end
 function inst:PushEvent(name,data)
  self.events[name]=data
  for _,fn in ipairs(self.listeners[name] or {}) do fn(self,data) end
 end
end
''')

    def test_primary_with_actual_splash_advances_equipped_counter_once(self):
        # If splash passes the primary guard, Mộc counts twice and procs early.
        self.pipeline.check(r'''
for _,start in ipairs({0,2}) do
 local a=entity('hh_player',{addSplashDamageAOE=20})
 local target,secondary=entity(),entity()
 secondary.HasTag=function(_,tag) return tag=='hostile' end
 local weapon={components={weapon={GetDamage=function() return 100 end}},_ttk_moc_hits=start}
 listenable(a)
 a:ListenForEvent('onhitother',player_onhitother)
 Elements.Equip(weapon,a,2)
 local spawned=0
 SpawnPrefab=function()
  spawned=spawned+1
  return {Launch=function() end}
 end
 TheSim={FindEntities=function() return {target,secondary} end}
 local direct,splash=install(target),install(secondary)
 direct:GetAttacked(a,100,weapon)
 assert(target.components.health.currenthealth==9900 and secondary.components.health.currenthealth==9980,
  'the real primary and real Pham Nhan splash must both land')
 assert(direct.calls==1 and splash.calls==1)
 assert(weapon._ttk_moc_hits==start+1,'one direct hit plus splash must advance Moc only once')
 assert(spawned==0,'splash must not trigger an early elemental projectile')
 assert(Context.PacketKind()==nil)
 Elements.Unequip(weapon)
end
''')

    def test_each_auxiliary_packet_rejects_all_held_elemental_effects(self):
        # Any missing packet guard leaks counters or consumes elemental RNG.
        for kind in ('splash', 'poison', 'heavy_wound', 'execute'):
            with self.subTest(kind=kind):
                self.lua.globals().test_packet_kind = kind
                self.pipeline.check(r'''
local a,target=entity('hh_player'),entity()
local weapon={components={weapon={GetDamage=function() return 100 end}},_ttk_moc_hits=3,_ttk_tho_hits=4}
local data={target=target,weapon=weapon,damageresolved=10}
local rng_calls,spawn_calls=0,0
local function rng() rng_calls=rng_calls+1; return 1 end
local function spawn() spawn_calls=spawn_calls+1; return {Launch=function() end} end
local landed,handled
local results={}
Context.WithPacket(test_packet_kind,function()
 landed=Elements.IsLandedPrimary(a,data,weapon)
 for element=2,6 do results[element]=Elements.HandleHeldHit(weapon,a,data,element,rng,spawn) end
end)
assert(landed==false,test_packet_kind..' is not a primary event')
for element=2,6 do assert(results[element]==false,'auxiliary event must not handle any held element') end
assert(weapon._ttk_moc_hits==3 and weapon._ttk_tho_hits==4,'auxiliary event must not advance counters')
assert(rng_calls==0 and spawn_calls==0 and a._ttk_elemental_shield==nil,
 'auxiliary event must not roll, spawn, or activate elemental effects')
assert(Context.PacketKind()==nil)
''')

    def test_packet_error_restores_context_for_the_next_primary(self):
        self.pipeline.check(r'''
local a,target=entity('hh_player'),entity()
local weapon={components={weapon={GetDamage=function() return 100 end}}}
local data={target=target,weapon=weapon,damageresolved=10}
Context.WithPacket('splash',function()
 local ok,err=pcall(function()
  Context.WithPacket('poison',function() error('packet callback failure') end)
 end)
 assert(not ok and string.find(err,'packet callback failure'))
 assert(Context.PacketKind()=='splash','inner error must restore outer packet context')
 assert(not Elements.IsLandedPrimary(a,data,weapon))
end)
assert(Context.PacketKind()==nil)
assert(Elements.IsLandedPrimary(a,data,weapon))
assert(Elements.HandleHeldHit(weapon,a,data,2))
assert(weapon._ttk_moc_hits==1,'a primary after error must still advance exactly once')
local Bridge=require('ttk_lucnguyen_combat')
listenable(a)
install(target)
assert(Bridge.ApplyAuxiliary(a,target,10,weapon,function()
 assert(not Elements.IsLandedPrimary(a,data,weapon),'the original Luc Nguyen guard must remain active')
 return true
end))
''')


if __name__ == '__main__':
    unittest.main()
