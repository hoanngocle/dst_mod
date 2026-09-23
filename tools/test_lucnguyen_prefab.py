"""Headless component fixture for Lục Nguyên weapon/prefab lifecycle."""
from pathlib import Path
from zipfile import ZipFile
import sys

sys.stdout.reconfigure(encoding="utf-8")
ROOT = Path(__file__).resolve().parents[1]
RUNTIME = ROOT.parents[1] / ".superpowers/lucnguyen-test-runtime"
sys.path.insert(0, str(RUNTIME))
from lupa.lua51 import LuaRuntime

lua = LuaRuntime(unpack_returned_tuples=True)
with ZipFile("C:/Program Files (x86)/Steam/steamapps/common/Don't Starve Together/data/databundles/scripts.zip") as game:
    lua.execute(game.read("scripts/class.lua").decode())
    lua.globals().FiniteUses = lua.execute(game.read("scripts/components/finiteuses.lua").decode())
    lua.globals().Trader = lua.execute(game.read("scripts/components/trader.lua").decode())

lua.globals().package.path = (
    str(ROOT / "scripts/?.lua").replace("\\", "/")
    + ";"
    + lua.globals().package.path
)
lua.execute(r'''
local function noop() end
local dummy=setmetatable({}, {__index=function() return noop end})
FRAMES=1/30; DEGREES=math.pi/180
ACTIONS={ATTACK={id="ATTACK"}}
ANIM_ORIENTATION={OnGround=1}
BLENDMODE={Additive=1}; LAYER_GROUND=1
TheWorld={ismastersim=true}
TheNet={IsDedicated=function() return true end}
Asset=function(...) return {...} end
Prefab=function(name,fn,assets,deps) return {name=name,fn=fn,assets=assets,deps=deps} end
MakeInventoryPhysics=noop; MakeInventoryFloatable=noop; MakeHauntableLaunch=noop

function CreateEntity()
 local e={components={},tags={},events={},tasks={},removed=false}
 e.entity=dummy; e.SoundEmitter=dummy
 e.AnimState=setmetatable({}, {__index=function() return noop end})
 function e.AnimState:SetOrientation(value) self.orientation=value end
 e.Transform={x=0,y=0,z=0,rot=0}
 function e.Transform:SetPosition(x,y,z) self.x=x; self.y=y; self.z=z end
 function e.Transform:GetWorldPosition() return self.x,self.y,self.z end
 function e.Transform:SetRotation(v) self.rot=v end
 function e.Transform:SetFourFaced() end
 function e:AddTag(t) self.tags[t]=true end
 function e:RemoveTag(t) self.tags[t]=nil end
 function e:HasTag(t) return self.tags[t] or false end
 function e:IsValid() return not self.removed end
 function e:IsInLimbo() return false end
 function e:GetPhysicsRadius() return .5 end
 function e:Remove() self.removed=true end
 function e:GetPosition() return {x=self.Transform.x,y=self.Transform.y,z=self.Transform.z} end
 function e:ListenForEvent(name,fn)
  self.events[name]=self.events[name] or {}; table.insert(self.events[name],fn)
 end
 function e:PushEvent(name,data)
  for _,fn in ipairs(self.events[name] or {}) do fn(self,data) end
 end
 function e:DoTaskInTime(_,fn)
  local task={cancelled=false}; function task:Cancel() self.cancelled=true end
  table.insert(self.tasks,{task=task,fn=fn,periodic=false}); return task
 end
 function e:DoPeriodicTask(_,fn)
  local task={cancelled=false}; function task:Cancel() self.cancelled=true end
  table.insert(self.tasks,{task=task,fn=fn,periodic=true}); return task
 end
 function e:Tick()
  for _,entry in ipairs(self.tasks) do
   if not entry.task.cancelled then entry.fn(self) end
  end
 end
 function e:AddComponent(n)
  local c={inst=self}; self.components[n]=c
  if n=="weapon" then
   function c:SetDamage(v) self.damage=v end
   function c:GetDamage() return self.damage end
   function c:SetRange(a,h) self.attackrange=a; self.hitrange=h end
   function c:SetProjectile(v) self.projectile=v end
   function c:SetOnProjectileLaunched(fn) self.onprojectilelaunched=fn end
  elseif n=="finiteuses" then self.components[n]=FiniteUses(self)
  elseif n=="trader" then self.components[n]=Trader(self)
  elseif n=="projectile" then
   function c:SetSpeed(v) self.speed=v end
   function c:SetRange(v) self.range=v end
   function c:SetOnPreHitFn(fn) self.onprehit=fn end
   function c:SetOnHitFn(fn) self.onhit=fn end
   function c:SetOnMissFn(fn) self.onmiss=fn end
  elseif n=="equippable" then
   function c:SetOnEquip(fn) self.onequip=fn end
   function c:SetOnUnequip(fn) self.onunequip=fn end
  elseif n=="inventoryitem" or n=="inspectable" then
  else setmetatable(c,{__index=function() return noop end}) end
 end
 return e
end
''')

returned = lua.execute((ROOT / "scripts/prefabs/ttk_lucnguyenkiemdong.lua").read_text(encoding="utf-8"))
if not isinstance(returned, tuple):
    returned = (returned,)
for prefab in returned:
    lua.globals()[prefab["name"]] = prefab

lua.execute(r'''
local item=ttk_lucnguyenkiemdong.fn()
assert(item.components.weapon.damage==50)
assert(item.components.weapon.attackrange==8 and item.components.weapon.hitrange==10)
assert(item.components.weapon.projectile=="ttk_lucnguyen_primary_projectile")
local uses=item.components.finiteuses
assert(uses.total==1000 and uses:GetUses()==1000)
uses:SetUses(2)
local attacker,target=CreateEntity(),CreateEntity()
local shot1=ttk_lucnguyen_primary_projectile.fn()
item.components.weapon.onprojectilelaunched(item,attacker,target,shot1)
assert(uses:GetUses()==1 and not item:HasTag("usesdepleted"))
assert(shot1.components.projectile.owner==attacker,
 "in-flight primary must retain its original attacker across weapon transfer/drop")
local shot2=ttk_lucnguyen_primary_projectile.fn()
item.components.weapon.onprojectilelaunched(item,attacker,target,shot2)
assert(uses:GetUses()==0 and item:HasTag("usesdepleted") and item:IsValid())
local shot3=ttk_lucnguyen_primary_projectile.fn()
item.components.weapon.onprojectilelaunched(item,attacker,target,shot3)
assert(uses:GetUses()==0 and shot3.removed,
 "a queued empty launch must not create a shot or consume below zero")

local stone={prefab="ttk_lingshi1",components={}}
stone.components.stackable={stacksize=3}
function stone.components.stackable:Get(count)
 self.stacksize=self.stacksize-count
 return {Remove=function() end}
end
assert(item.components.trader:AcceptGift(nil,stone))
assert(uses:GetUses()==100 and stone.components.stackable.stacksize==2)
local saved=uses:OnSave()
local loaded=ttk_lucnguyenkiemdong.fn()
loaded.components.finiteuses:OnLoad(saved)
assert(loaded.components.finiteuses:GetUses()==100, "finiteuses save/load must preserve charges")
loaded.components.finiteuses:SetUses(1000)
assert(not loaded.components.trader:AcceptGift(nil,stone), "full weapon rejects repair stone")

item.components.weapon:SetDamage(73)
local projectile=ttk_lucnguyen_primary_projectile.fn()
item.components.weapon.onprojectilelaunched(item,CreateEntity(),CreateEntity(),projectile)
assert(projectile._base_damage==73 and projectile.components.weapon.damage==73,
 "in-flight primary must carry its immutable enhanced damage snapshot")

for i=1,6 do
 local sword=_G["ttk_lucnguyen_sword_"..i].fn()
 assert(sword.Launch ~= nil and sword._trail_prefab=="ttk_lucnguyen_trail_"..i)
 assert(sword.AnimState.orientation==ANIM_ORIENTATION.OnGround,
  "flying sword art must use continuous on-ground orientation")
 local owner,target=CreateEntity(),CreateEntity()
 owner.Transform:SetPosition(0,0,0); target.Transform:SetPosition(8,0,0)
 target.components.health={IsDead=function() return false end}
 local hits=0
 target.components.combat={GetAttacked=function(self,attacker,damage,weapon,stimuli)
  assert(attacker==owner and damage==10 and stimuli=="ttk_lucnguyen_auxiliary")
  hits=hits+1; return true
 end}
 sword:Launch({owner=owner,target=target,weapon=item,damage=10,element=i,index=1,count=1,
  apply_impact=false})
 assert(math.abs(sword._heading)>=.64,
  "single/center sword must begin with a visible lateral fan angle")
 local sx,_,sz=sword.Transform:GetWorldPosition()
 sword:Tick()
 local mx,_,mz=sword.Transform:GetWorldPosition()
 local cross=(8-sx)*(mz-sz)-(0-sz)*(mx-sx)
 assert(math.abs(cross)>.01,
  "first trajectory segment must arc away from the direct launch-target line")
 for frame=1,180 do if not sword.removed then sword:Tick() end end
 assert(sword.removed and hits==1,
  "each fanned sword must converge, damage exactly once, and clean itself up")
end

local dead_owner,target=CreateEntity(),CreateEntity()
dead_owner.dead=false
dead_owner.components.health={IsDead=function() return dead_owner.dead end}
target.Transform:SetPosition(8,0,0)
target.components.health={IsDead=function() return false end}
local dead_owner_hits=0
target.components.combat={GetAttacked=function() dead_owner_hits=dead_owner_hits+1; return true end}
local abandoned=ttk_lucnguyen_sword_1.fn()
abandoned:Launch({owner=dead_owner,target=target,weapon=item,damage=10,element=1,index=1,count=1,
 apply_impact=false})
dead_owner.dead=true
abandoned:Tick()
assert(abandoned.removed and dead_owner_hits==0,
 "owner death mid-flight must remove the sword without auxiliary damage")

TheWorld.ismastersim=false
local client=ttk_lucnguyenkiemdong.fn()
assert(client.components.weapon==nil and client.components.finiteuses==nil and client.components.trader==nil)
assert(client:HasTag("alltrader"), "remote clients need the pristine alltrader tag for GIVE")
''')

for path in ROOT.rglob("*.lua"):
    lua.execute("assert(loadstring(...))", path.read_text(encoding="utf-8-sig"))

print("PASS: 1000/last charge, one-stone +100 refill/cap, save-load, enhanced shot snapshot, six swords, client/server split, and Lua 5.1 syntax.")
