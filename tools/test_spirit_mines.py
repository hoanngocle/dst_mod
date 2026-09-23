"""Mine lifecycle tests using DST's real Workable and Timer components."""
from pathlib import Path
from zipfile import ZipFile
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT.parents[1] / '.superpowers/luoshen-runtime'))
from lupa.lua51 import LuaRuntime

lua = LuaRuntime(unpack_returned_tuples=True)
with ZipFile("C:/Program Files (x86)/Steam/steamapps/common/Don't Starve Together/data/databundles/scripts.zip") as z:
    lua.execute(z.read('scripts/class.lua').decode())
    for name in ('workable', 'timer'):
        lua.globals()[name.title()] = lua.execute(z.read('scripts/components/' + name + '.lua').decode())
lua.execute(r'''
package.path = ROOT .. '/scripts/?.lua;' .. package.path
package.preload.prefabutil = function() end
ACTIONS={MINE={id='MINE'},CHOP={id='CHOP'}}
TUNING={TOTAL_DAY_TIME=480}; TheWorld={ismastersim=true}
NOW=0; function GetTime() return NOW end
function Asset(...) return {...} end
function Prefab(n,fn,a,p) return {name=n,fn=fn,assets=a,prefabs=p} end
function MakePlacer(n,...) return {name=n} end
function MakeObstaclePhysics() end
function MakeSnowCoveredPristine() end
function MakeSnowCovered() end
function MakeHauntableWork() end
function Vector3(x,y,z) return {x=x,y=y,z=z} end
function CreateEntity()
 local e={components={},tags={},events={},tasks={},drops=0}
 local noop=function() end
 e.entity=setmetatable({},{__index=function() return noop end})
 e.Transform={SetPosition=noop,GetWorldPosition=function() return 0,0,0 end}
 e.AnimState=setmetatable({},{__index=function() return noop end})
 e.MiniMapEntity={SetIcon=noop}
 function e:AddTag(t) self.tags[t]=true end
 function e:RemoveTag(t) self.tags[t]=nil end
 function e:HasTag(t) return self.tags[t] end
 function e:GetPosition() return Vector3(0,0,0) end
 function e:IsValid() return not self.removed end
 function e:Remove() self.removed=true end
 function e:ListenForEvent(n,fn) self.events[n]=fn end
 function e:PushEvent(n,d) if self.events[n] then self.events[n](self,d) end end
 function e:DoTaskInTime(dt,fn,...)
  local args={...}; local t={at=NOW+dt,Cancel=function(s) s.cancelled=true end}
  t.run=function() fn(self,unpack(args)) end;table.insert(self.tasks,t); return t
 end
 function e:AddComponent(n)
  if n=='workable' then self.components[n]=Workable(self)
  elseif n=='timer' then self.components[n]=Timer(self)
  elseif n=='lootdropper' then
   self.components[n]={SetLoot=function(s,v) s.loot=v end,
    DropLoot=function() self.drops=self.drops+1 end,
    AddChanceLoot=function() end}
  else self.components[n]={} end
  return self.components[n]
 end
 return e
end
function SpawnPrefab() return CreateEntity() end
function advance(e,dt)
 NOW=NOW+dt
 local tasks=e.tasks;e.tasks={}
 for _,t in ipairs(tasks) do
  if not t.cancelled then
   if t.at<=NOW then t.run() else table.insert(e.tasks,t) end
  end
 end
end
'''.replace('ROOT', repr(str(ROOT).replace('\\','/'))))
source = ROOT / 'scripts/prefabs/ttk_spirit_mines.lua'
assert source.exists(), 'Craftable/natural spirit mines have not been implemented'
prefabs = lua.execute(source.read_text(encoding='utf-8'))
lua.globals().mines = lua.table_from([p for p in prefabs if p.fn is not None])
lua.execute(r'''
for tier,p in ipairs(mines) do
 local natural=p.fn()
 local worker=CreateEntity()
 natural.components.workable:WorkedBy_Internal(worker,100)
 assert(natural.removed and natural.drops==1,'natural mine must be consumed')
 assert(not natural.components.timer:TimerExists('regrow'),'natural mine must not regrow')

end
TheWorld.ismastersim=false
for _,p in ipairs(mines) do assert(p.fn().components.workable==nil) end
print('PASS: 3 natural tiers, depletion without regeneration, client boundary')
''')
seeder = ROOT / 'scripts/components/ttk_mineseeder.lua'
assert seeder.exists(), 'Seasonal natural-mine spawning has not been implemented'
lua.globals().Seeder = lua.execute(seeder.read_text(encoding='utf-8'))
lua.execute(r'''
TheWorld.ismastersim=true
function makeworld()
 local world=CreateEntity();world.state={season='autumn'}
 function world:WatchWorldState(n,fn) self.watcher=fn end
 return world
end
local world=makeworld();local s=Seeder(world);local calls={}
s.Seed=function(self,initial) table.insert(calls,initial and 'initial' or 'season') end
advance(world,2);assert(#calls==1 and calls[1]=='initial')
world.watcher(world,'autumn');assert(#calls==1)
world.state.season='winter';world.watcher(world,'winter');assert(#calls==2)
world.watcher(world,'winter');assert(#calls==2,'duplicate season notification')
local saved=s:OnSave()
local reloaded=makeworld();reloaded.state.season='winter'
local s2=Seeder(reloaded);s2.Seed=s.Seed;s2:OnLoad(saved)
advance(reloaded,2);assert(#calls==2,'reload must not spawn more mines')
reloaded.state.season='spring';reloaded.watcher(reloaded,'spring')
assert(#calls==3 and calls[3]=='season')
print('PASS: initial seeding, season changes, duplicate notifications, save/reload')

local spawned={};local allow=true
TheSim={FindEntities=function() return {} end}
TheWorld.Map={IsPassableAtPoint=function() return allow end,
 IsAboveGroundAtPoint=function() return allow end,
 IsPointNearHole=function() return false end}
TheWorld.topology={ids={'Dig that rock:Rocky','Forest:Clearing'},
 nodes={{x=0,y=0},{x=200,y=200}}}
function SpawnPrefab(n)
 local e=CreateEntity();e.prefab=n
 e.Transform.SetPosition=function(_,x,y,z) e.x=x;e.z=z end
 table.insert(spawned,e);return e
end
local direct=Seeder(makeworld())
direct:Seed(true)
assert(#spawned==24,'initial population')
local near,far,tiers=0,0,{0,0,0}
for _,e in ipairs(spawned) do
 assert(not e._ttk_crafted,'natural spawning must not mark a crafted vein')
 if e.x<100 then near=near+1 else far=far+1 end
 local tier=tonumber(e.prefab:sub(-1));tiers[tier]=tiers[tier]+1
end
assert(near==16 and far==8,'clustered plus scattered distribution')
assert(tiers[1]==16 and tiers[2]==6 and tiers[3]==2)
direct:Seed(false);assert(#spawned==36,'fresh mines each season')
allow=false;direct:Seed(false);assert(#spawned==36,'reject water/invalid ground')
allow=true;TheSim.FindEntities=function() return {CreateEntity()} end
direct:Seed(false);assert(#spawned==36,'avoid occupied positions')
print('PASS: 24 initial/12 seasonal, rarity, rocky/scattered positions, unsafe and occupied ground')
''')
