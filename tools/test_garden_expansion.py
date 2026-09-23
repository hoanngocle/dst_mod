"""Behavior checks with DST Timer and FiniteUses; no game process is started."""
from pathlib import Path
from zipfile import ZipFile
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT.parents[1] / '.superpowers/luoshen-runtime'))
from lupa.lua51 import LuaRuntime

assert (ROOT/'scripts/components/ttk_fishpond.lua').exists(), 'Missing standalone fish breeding component'
lua = LuaRuntime(unpack_returned_tuples=True)
with ZipFile("C:/Program Files (x86)/Steam/steamapps/common/Don't Starve Together/data/databundles/scripts.zip") as z:
    lua.execute(z.read('scripts/class.lua').decode())
    lua.globals().Timer = lua.execute(z.read('scripts/components/timer.lua').decode())
    lua.globals().FiniteUses = lua.execute(z.read('scripts/components/finiteuses.lua').decode())
    lua.globals().Trader = lua.execute(z.read('scripts/components/trader.lua').decode())
lua.execute("package.path = ... .. '/scripts/?.lua;' .. package.path", ROOT.as_posix())
lua.execute('''
now=0; function GetTime() return now end
EQUIPSLOTS={HANDS='hands'}; TUNING={TOTAL_DAY_TIME=480}
function entity()
 local e={components={},events={},Transform={GetWorldPosition=function() return 0,0,0 end,SetPosition=function() end}}
 function e:DoTaskInTime(dt,fn,...) return {Cancel=function() end} end
 function e:ListenForEvent(n,fn) self.events[n]=fn end
 function e:PushEvent(n,data) if self.events[n] then self.events[n](self,data) end end
 function e:AddTag() end; function e:RemoveTag() end
 function e:Remove() self.removed=true end
 function e:GetPosition() return {} end
 return e
end
spawned={}; function SpawnPrefab(id)
 local e=entity(); e.prefab=id; table.insert(spawned,e); return e
end
local Pond=require('components/ttk_fishpond')
function pond()
 local e=entity(); e.components.timer=Timer(e); e.components.ttk_fishpond=Pond(e)
 return e,e.components.ttk_fishpond
end
local e,p=pond()
assert(p:AddFish('oceanfish_small_1_inv'))
now=100
assert(p:AddFish('pondfish')); assert(p:AddFish('oceanfish_medium_1_inv'))
assert(not p:HasSpace()); assert(not p:AddFish('pondfish'))
assert(not p:Harvest(nil)); assert(#spawned==0)
local saved=p:OnSave(); local timers=e.components.timer:OnSave()
local e2,p2=pond(); e2.components.timer:OnLoad(timers); p2:OnLoad(saved)
assert(not p2:HasSpace())
now=3360
assert(p2:Harvest(nil)); assert(#spawned==4)
assert(spawned[1].prefab=='oceanfish_small_1_inv'); assert(p2:HasSpace())
assert(not p2:Harvest(nil)); assert(#spawned==4)
-- Demolition returns the two immature brood fish, without duplication.
p2:ReleaseAll(); assert(#spawned==6); p2:ReleaseAll(); assert(#spawned==6)
-- All three occupied slots can mature and be harvested together.
now=0; local e3,p3=pond()
for i=1,3 do assert(p3:AddFish('pondfish')) end
now=3360; assert(p3:Harvest(nil)); assert(#spawned==18)
local e4,p4=pond(); e4.components.timer:OnLoad(e3.components.timer:OnSave() or {})
p4:OnLoad(p3:OnSave()); assert(not p4:Harvest(nil)); assert(#spawned==18)
local protect=require('ttk_herbtool')
local tool=entity(); tool.components.finiteuses=FiniteUses(tool)
tool.components.finiteuses:SetMaxUses(100); tool.components.finiteuses:SetUses(100)
tool.components.finiteuses:SetOnFinished(function(inst) inst:Remove() end)
function tool:HasTag(t) return t=='ttk_herbtool' end
local player={components={inventory={GetEquippedItem=function() return tool end,EquipHasTag=function() return false end}}}
for i=1,100 do assert(protect(player)) end
assert(tool.removed and tool.components.finiteuses:GetUses()==0)
assert(not protect(player)); assert(not protect(nil))
player.components.inventory.GetEquippedItem=function() return nil end
assert(not protect(player))
player.components.inventory.EquipHasTag=function(_,t) return t=='xd_yhsyz' end
assert(protect(player)) -- Existing optional source-mod compatibility survives.
''')
print('PASS: fish capacity, staggered maturity, save/load, harvest once, demolition, 100 protected herb harvests.')
lua.globals().MODROOT = ROOT.as_posix()
lua.execute('''
function noop() end
function api()
 return setmetatable({}, {__index=function(self,k)
  return function(_,...) self['called_'..k]={...} end
 end})
end
function Asset(...) return {...} end
function Prefab(name,fn,assets,deps) return {name=name,fn=fn,assets=assets,deps=deps} end
function MakePlacer(name) return {name=name} end
MakeInventoryPhysics=noop; MakeInventoryFloatable=noop; MakeObstaclePhysics=noop
MakeSnowCoveredPristine=noop; MakeSnowCovered=noop; MakeHauntable=noop
MakeHauntableLaunch=noop; AddHauntableDropItemOrWork=noop
TheWorld={ismastersim=true,state={isnight=true},HasTag=function() return false end}
TheWorld.components={worldstate={GetWorldAge=function() return 100 end}}
TUNING.CATCOONDEN_INV_SIZE=6; TUNING.CATCOONDEN_RELEASE_TIME=10;TUNING.SANITYAURA_TINY=1
ACTIONS={HAMMER={}}; function GetRandomItem(t) return t[1] end
function CreateEntity()
 local e=entity(); e.entity=api(); e.AnimState=api(); e.SoundEmitter=api()
 e.MiniMapEntity=api(); e.Light=api();e.tags={};e.watchers={}
 function e:AddTag(t) self.tags[t]=true end
 function e:HasTag(t) return self.tags[t] or false end
 function e:WatchWorldState(k,fn) self.watchers[k]=fn end
 function e:AddComponent(k)
  if k=='timer' then self.components[k]=Timer(self)
  elseif k=='ttk_fishpond' then self.components[k]=require('components/ttk_fishpond')(self)
  elseif k=='trader' then self.components[k]=Trader(self)
  elseif k=='finiteuses' then self.components[k]=FiniteUses(self)
  else self.components[k]=api() end
 end
 return e
end
local pondPrefab=dofile(MODROOT..'/scripts/prefabs/ttk_hyc.lua')
now=0;local pond=pondPrefab.fn()
assert(pond.Light.called_Enable[1]==true)
TheWorld.state.isnight=false; pond.watchers.isnight(); assert(pond.Light.called_Enable[1]==false)
function fishitem()
 local f=entity();f.prefab='pondfish';f.components.inventoryitem={RemoveFromOwner=noop}
 function f:HasTag(t) return t=='pondfish' end
 return f
end
local f=fishitem();assert(not pond.components.trader:AcceptGift(nil,f,2));assert(not f.removed)
for i=1,3 do local f=fishitem();assert(pond.components.trader:AcceptGift(nil,f));assert(f.removed) end
local f=fishitem();assert(not pond.components.trader:AcceptGift(nil,f));assert(not f.removed)
assert(not pond.components.activatable.OnActivate(pond,nil))
now=3360;assert(pond.components.activatable.OnActivate(pond,nil))
assert(pond.components.activatable.inactive)
local toolPrefab=dofile(MODROOT..'/scripts/prefabs/ttk_yhsyz.lua')
local tool=toolPrefab.fn();assert(tool:HasTag('ttk_herbtool'))
assert(tool.components.finiteuses:GetUses()==100)
TheWorld.ismastersim=false
assert(pondPrefab.fn().components.trader==nil)
assert(toolPrefab.fn().components.finiteuses==nil)
TheWorld.ismastersim=true
local cats=dofile(MODROOT..'/scripts/prefabs/ttk_hmsw.lua')
local house=cats.fn();local inv=house.components.inventory
assert(house:HasTag('structure'));assert(house.components.childspawner.called_SetMaxChildren[1]==1)
assert(house.components.childspawner.called_SetRegenPeriod[1]==480)
inv.itemslots={};local gifts=0;inv.GiveItem=function() gifts=gifts+1 end
house.components.childspawner.IsFull=function() return false end
house.watchers.cycles(house);assert(gifts==0)
house.components.childspawner.IsFull=function() return true end
house.watchers.cycles(house);assert(gifts==2 or gifts==3)
gifts=0;for i=1,inv.maxslots do inv.itemslots[i]={} end
house.watchers.cycles(house);assert(gifts==0)
local trees={dofile(MODROOT..'/scripts/prefabs/ttk_garden.lua')};local tree
for _,p in ipairs(trees) do if p.name=='ttk_tree_xhs' then tree=p.fn() end end
assert(tree and tree:HasTag('shelter'))
assert(tree.components.temperatureoverrider.called_SetTemperature[1]==19)
assert(tree.components.temperatureoverrider.called_SetRadius[1]==6)
assert(tree.components.periodicspawner.called_SetRandomTimes[1]==3360)
tree.components.periodicspawner.inst=tree
tree.components.periodicspawner:TrySpawn()
assert(tree.components.lootdropper.called_SpawnLootPrefab[1]=='yellowgem')
''')
print('PASS: prefab/server/client integration, real Trader, fish rejection, night lighting, Catcoon gifts, yellow-gem tree.')
lua.execute('''
local create=CreateEntity
function CreateEntity()
 local e=create();e.SetDeploySmartRadius=noop;e.SetPhysicsRadiusOverride=noop
 e.IsAsleep=function() return true end
 return e
end
FOODTYPE={GOODIES='goodies',SEEDS='seeds'}
local prefabs={dofile(MODROOT..'/scripts/prefabs/ttk_herbs.lua')}
local factories={};for _,p in ipairs(prefabs) do factories[p.name]=p.fn end
local toolPrefab=dofile(MODROOT..'/scripts/prefabs/ttk_yhsyz.lua')
local oldrandom=math.random;math.random=function() return .5 end
for _,suffix in ipairs({'hsc','dms','qfx','cyh','lmg','yhh'}) do
 local tool=toolPrefab.fn();tool.components.finiteuses:SetUses(1)
 local rewards={};local player={components={inventory={}}}
 player.components.inventory.GetEquippedItem=function() return tool end
 player.components.inventory.EquipHasTag=function() return false end
 player.components.inventory.GiveItem=function(_,item) table.insert(rewards,item.prefab) end
 player.AddDebuff=function() error('Protected harvest burned the player') end
 player.components.freezable={AddColdness=function() error('Protected harvest froze player') end}
 player.components.health={IsDead=function() return false end,IsInvincible=function() return false end,
  DoDelta=function() error('Protected harvest damaged player') end}
 player.components.grogginess={AddGrogginess=function() error('Protected harvest caused sleep') end}
 player.components.sanity={DoDelta=function() error('Protected harvest cost sanity') end}
 local plant=factories['ttk_plant_'..suffix]()
 local stages=plant.components.growable.stages;stages[#stages].fn(plant)
 plant.components.pickable.onpickedfn(plant,player)
 assert(#rewards==2 and rewards[1]=='ttk_lc_'..suffix and rewards[2]=='ttk_lc_'..suffix..'_seed')
 assert(tool.removed and tool.components.finiteuses:GetUses()==0)
end
math.random=oldrandom
GLOBAL=_G;PrefabFiles={};STRINGS={NAMES={},RECIPE_DESC={},ACTIONS={ACTIVATE={}},
 CHARACTERS={GENERIC={DESCRIBE={},ACTIONFAIL={ACTIVATE={}}}}}
TECH={SCIENCE_ONE=1,SCIENCE_TWO=2};recipes={}
function Ingredient(name,amount) return {name=name,amount=amount} end
function AddRecipe2(id,ingredients,tech,options,filters)
 recipes[id]={ingredients=ingredients,tech=tech,options=options,filters=filters}
end
AddMinimapAtlas=noop;RegisterInventoryItemAtlas=noop
dofile(MODROOT..'/main/ttk_garden_expansion.lua')
for _,id in ipairs({'ttk_yhsyz','ttk_hyc','ttk_tree_xhs','ttk_hmsw'}) do
 assert(recipes[id] and not recipes[id].options.builder_tag)
 assert(#recipes[id].ingredients>2)
end
assert(recipes.ttk_yhsyz.options.no_deconstruction)
assert(recipes.ttk_tree_xhs.tech==2 and recipes.ttk_hmsw.tech==1)
''')
print('PASS: all six mature herb callbacks protect the last use and return seeds; four unrestricted recipes registered.')
