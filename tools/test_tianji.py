"""Regression tests for persistent Tian Ji rooms, using Lua 5.1."""
from pathlib import Path
from zipfile import ZipFile
import sys
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parents[1]/'.superpowers/chuongthienbinh-runtime'))
from lupa.lua51 import LuaRuntime
lua=LuaRuntime(unpack_returned_tuples=True)
with ZipFile("C:/Program Files (x86)/Steam/steamapps/common/Don't Starve Together/data/databundles/scripts.zip") as z:
    lua.execute(z.read('scripts/class.lua').decode())
lua.execute("package.path = ... .. '/scripts/?.lua;' .. package.path", ROOT.as_posix())
lua.execute(r'''
function Vector3(x,y,z) return {x=x,y=y,z=z,Get=function(s) return s.x,s.y,s.z end} end
local Map={}
function Map:IsAboveGroundAtPoint() return false end
function Map:IsPassableAtPoint(x,y,z) return x==0 and z==0 end
function Map:IsPointNearHole() return false end
function Map:GetTileAtPoint() return 0 end
function Map:IsOceanAtPoint(x,y,z) return not (x==0 and z==0) end
function Map:GetTileCenterPoint(x,y,z) return x,y,z end
TheWorld={Map=setmetatable({}, {__index=Map}),components={}}
TheShard={GetShardId=function() return "1" end}
WORLD_TILES={WOODFLOOR=42}
TheSim={FindEntities=function() return {} end}
spawned={};failspawn=false
function SpawnPrefab(name)
 if failspawn then return nil end
 local e={prefab=name,AnimState={SetScale=function() end},Transform={SetScale=function() end},components={}}
 e.Transform.SetPosition=function(_,x,y,z) e.x=x;e.z=z end
 function e:Remove() self.removed=true end
 table.insert(spawned,e);return e
end
map=require("ttk_tianjimap");map.Install(TheWorld.Map)
Rooms=require("components/ttk_tianjirooms")
manager=Rooms(TheWorld);TheWorld.components.ttk_tianjirooms=manager
assert(not map.Contains(0,0))
room=assert(manager:GetRoom("owner-a"));assert(manager:GetRoom("owner-a")==room)
assert(map.Contains(room.x,room.z));assert(not map.Contains(room.x+15,room.z))
assert(TheWorld.Map:IsPassableAtPoint(room.x,0,room.z))
assert(not TheWorld.Map:IsOceanAtPoint(room.x,0,room.z))
assert(TheWorld.Map:IsPassableAtPoint(0,0,0))
room2=assert(manager:GetRoom("owner-b"));assert(room2.x~=room.x or room2.z~=room.z)
local saved=manager:OnSave();map.Reset();manager=Rooms(TheWorld);manager:OnLoad(saved)
assert(map.Contains(room.x,room.z));assert(manager:GetRoom("owner-a").x==room.x)
local count=#spawned;failspawn=true;assert(manager:GetRoom("failed")==nil);assert(manager.rooms.failed==nil);failspawn=false
assert(#spawned==count)
local restored=manager:GetRoom("owner-a");assert(restored.x==room.x)
Return=require("components/ttk_tianjireturn")
local ret=Return({});ret:Mark(0,0);local rs=ret:OnSave();local ret2=Return({});ret2:OnLoad(rs)
assert(ret2.pos.x==0 and ret2.pos.shard=="1")
print("PASS: allocation, owner isolation, scoped terrain, save/load and spawn failure")
''')
lua.execute(r'''
local oldfind=TheSim.FindEntities
TheSim.FindEntities=function() return {{}} end
assert(manager:GetRoom("no-space")==nil)
TheSim.FindEntities=oldfind
local moved
local player={userid="owner-a",components={}}
player.Transform={GetWorldPosition=function() return 0,0,0 end,SetPosition=function(_,x,y,z) moved={x=x,z=z} end}
player.components.ttk_tianjireturn=Return(player)
assert(manager:Enter({_ttk_owner="owner-a"},player));assert(moved.x==room.x+11.5)
local returnstate=player.components.ttk_tianjireturn:OnSave()
player.components.ttk_tianjireturn=Return(player);player.components.ttk_tianjireturn:OnLoad(returnstate)
assert(manager:Exit(player));assert(moved.x==0 and moved.z==0)
Ents={};player.components.ttk_tianjireturn.pos={x=999,z=999,shard="2"}
assert(not manager:Exit(player));assert(player.components.ttk_tianjireturn.pos~=nil)
Ents={{IsValid=function() return true end,HasTag=function(_,t) return t=="multiplayer_portal" end,Transform={GetWorldPosition=function() return 0,0,0 end}}}
assert(manager:Exit(player));assert(moved.x==0)
print("PASS: allocation exhaustion, indoor reload return, cross-shard rejection and portal fallback")
''')
lua.execute(r'''
package.preload.prefabutil=function() end
function noop() end
function api() return setmetatable({}, {__index=function() return noop end}) end
TheWorld.ismastersim=true
DEPLOYMODE={CUSTOM=1};DEPLOYSPACING={LARGE=1}
function Asset(k,p) return {k,p} end
function Prefab(n,fn,a,d) return {name=n,fn=fn,assets=a} end
function MakePlacer() return {} end
MakeInventoryPhysics=noop;MakeInventoryFloatable=noop;MakeHauntableLaunch=noop;MakeObstaclePhysics=noop
MakeSnowCoveredPristine=noop;MakeSnowCovered=noop
function CreateEntity()
 local e={components={},entity=api(),AnimState=api(),MiniMapEntity=api(),Transform=api(),tags={}}
 function e:AddTag(t) self.tags[t]=true end
 function e:HasTag(t) return self.tags[t] end
 function e:IsValid() return not self.removed end
 function e:SetDeployExtraSpacing() end
 function e:Remove() self.removed=true end
 function e:GetPosition() return Vector3(0,0,0) end
 function e:AddComponent(k)
  local c={};self.components[k]=c
  if k=="trader" then
   function c:SetAcceptTest(fn) self.test=fn end
   function c:Disable() self.disabled=true end
  elseif k=="deployable" then c.SetDeployMode=noop;c.SetDeploySpacing=noop
  elseif k=="inventoryitem" then c.ChangeImageName=noop end
 end
 return e
end
''')
prefabs=lua.execute((ROOT/'scripts/prefabs/ttk_tianji.lua').read_text(encoding='utf-8'))
for pref in prefabs[:3]: lua.globals()[pref.name]=pref
lua.execute(r'''
local received={}
local owner={userid="owner-a",components={inventory={GiveItem=function(_,item) table.insert(received,item) end}}}
local stranger={userid="other",components=owner.components}
local scroll=ttk_tianji_juanzhou.fn()
local token=ttk_tianji_lingpai.fn();token.prefab="ttk_tianji_lingpai"
local house=ttk_tianjiwu.fn();house._ttk_owner=owner.userid;house._ttk_shard="1"
assert(not house.components.trader.test(house,token,stranger))
assert(house.components.trader.test(house,token,owner))
local spawn=SpawnPrefab
SpawnPrefab=function(name)
 if failspawn then return nil end
 if name=="ttk_tianjiwu" then return ttk_tianjiwu.fn() end
 if name=="ttk_tianji_lingpai" then return ttk_tianji_lingpai.fn() end
 if name=="ttk_tianji_juanzhou" then return ttk_tianji_juanzhou.fn() end
 return spawn(name)
end
failspawn=true;house.components.trader.onaccept(house,owner,token)
assert(not house.removed and not token.removed and received[#received]==token)
failspawn=false;house.components.trader.onaccept(house,owner,token)
assert(house.removed and token.removed)
local packed=received[#received];local data={};packed.OnSave(packed,data)
local loaded=ttk_tianji_juanzhou.fn();loaded.OnLoad(loaded,data)
assert(loaded._ttk_owner==owner.userid and loaded._ttk_shard=="1")
TheWorld.Map.CanDeployAtPoint=function() return true end
local oldabove=TheWorld.Map.IsAboveGroundAtPoint
TheWorld.Map.IsAboveGroundAtPoint=function() return true end
assert(not loaded.components.deployable.ondeploy(loaded,Vector3(0,0,0),stranger))
assert(not loaded.removed)
loaded._ttk_shard="2";assert(not loaded.components.deployable.ondeploy(loaded,Vector3(0,0,0),owner));loaded._ttk_shard="1"
failspawn=true;assert(not loaded.components.deployable.ondeploy(loaded,Vector3(0,0,0),owner));assert(not loaded.removed)
failspawn=false;assert(loaded.components.deployable.ondeploy(loaded,Vector3(0,0,0),owner));assert(loaded.removed)
assert(not loaded.components.deployable.ondeploy(loaded,Vector3(0,0,0),owner))
TheWorld.Map.IsAboveGroundAtPoint=oldabove
TheWorld.ismastersim=false
assert(ttk_tianjiwu.fn().components.trader==nil)
assert(ttk_tianji_juanzhou.fn().components.deployable==nil)
print("PASS: ownership, recall/deploy failure rollback, token consumption, packed save/load, shard lock, repeat action and clients")
''')
lua.execute(r'''
TheWorld.ismastersim=true
local companion={components={},IsValid=function() return true end,Transform={SetPosition=function(_,x,y,z) followerx=x end}}
local player={userid="owner-a",Transform={GetWorldPosition=function() return 0,0,0 end,SetPosition=noop},components={}}
player.components.inventory={itemslots={},equipslots={},activeitem={components={leader={followers={[companion]=true}}}}}
player.components.ttk_tianjireturn=Return(player)
assert(manager:Enter({_ttk_owner="owner-a"},player));assert(followerx==room.x+11.5)
''')
interior=lua.execute((ROOT/'scripts/prefabs/ttk_tianji_interior.lua').read_text(encoding='utf-8'))
lua.globals().decalprefab=interior[-1]
lua.execute(r'''
local d=decalprefab.fn();d._ttk_mirror=true;local data={};d.OnSave(d,data)
local restored=decalprefab.fn();local sx
restored.Transform.SetScale=function(_,x) sx=x end
restored.OnLoad(restored,data);assert(sx==-1 and restored._ttk_mirror)
TheNet={IsDedicated=function() return true end}
function net_entity() return {value=function(s) return s.v end,set=function(s,v) s.v=v end} end
modenv={AddClassPostConstruct=noop,AddPlayerPostInit=function(fn) playerinit=fn end}
''')
lua.execute((ROOT/'scripts/ttk_tianjicamera.lua').read_text(encoding='utf-8'))(lua.globals().modenv)
lua.execute(r'''
local sources={external=true}
local p={GUID=1,Transform={GetWorldPosition=function() return room.x,0,room.z end},components={}}
p.components.rainimmunity={AddSource=function(_,r) sources[r]=true end,RemoveSource=function(_,r) sources[r]=nil end}
function p:DoPeriodicTask(t,fn) self.tick=fn end
playerinit(p)
local marker={Transform={GetWorldPosition=function() return room.x,0,room.z end}}
TheSim.FindEntities=function() return {marker} end
p.tick();assert(sources[marker] and sources.external)
TheSim.FindEntities=function() return {} end
p.tick();assert(not sources[marker] and sources.external)
print("PASS: cursor-held followers, mirrored decoration persistence and scoped rain immunity cleanup")
''')
lua.execute(r'''
TheNet.IsDedicated=function() return false end
weathercount=0;othercount=0
rainfn=function() weathercount=weathercount+1 end
weatherdata={updateFunc=rainfn}
otherdata={updateFunc=function() othercount=othercount+1 end}
EmitterManager={awakeEmitters={infiniteLifetimes={[{prefab="rain"}]=weatherdata,[{prefab="smoke"}]=otherdata}}}
EmitterManager.PostUpdate=function(self) for _,data in pairs(self.awakeEmitters.infiniteLifetimes) do data.updateFunc() end end
ThePlayer={_ttk_tianji_camera=net_entity()};ThePlayer._ttk_tianji_camera:set({})
''')
lua.execute((ROOT/'scripts/ttk_tianjicamera.lua').read_text(encoding='utf-8'))(lua.globals().modenv)
lua.execute(r'''
EmitterManager:PostUpdate();assert(weathercount==0 and othercount==1)
ThePlayer._ttk_tianji_camera:set(nil);EmitterManager:PostUpdate()
assert(weathercount==1 and othercount==2 and weatherdata.updateFunc==rainfn)
print("PASS: client precipitation pause/restore preserves unrelated emitters")
''')
for p in ROOT.rglob('*.lua'):
    lua.execute('assert(loadstring(...))',p.read_text(encoding='utf-8-sig'))
print('PASS: all mod Lua syntax')
