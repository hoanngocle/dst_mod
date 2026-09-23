"""Producer/harvest/save tests with real DST Pickable and Timer."""
from pathlib import Path
from zipfile import ZipFile

ROOT = Path(__file__).resolve().parents[1]
# Reuse the minimal engine fixture, but not the obsolete crafted mining tests.
exec((ROOT / 'tools/test_spirit_mines.py').read_text().split('source = ROOT')[0])
with ZipFile("C:/Program Files (x86)/Steam/steamapps/common/Don't Starve Together/data/databundles/scripts.zip") as z:
    lua.globals().Pickable = lua.execute(z.read('scripts/components/pickable.lua').decode())
    lua.globals().LootDropper = lua.execute(z.read('scripts/components/lootdropper.lua').decode())
lua.execute(r'''
EntityScript={is_instance=function() return false end}
TUNING.HAMMER_LOOT_PERCENT=0.5
AllRecipes={ttk_spirit_workshop={ingredients={{type='cutstone',amount=20},{type='ttk_lingshi2',amount=5}}}}
function SpringGrowthMod(t) return t end
function Vector3(x,y,z) return {x=x,y=y,z=z,Get=function() return x,y,z end} end
local create=CreateEntity
function CreateEntity()
 local e=create();e.prefab='ttk_spirit_workshop';e.Light=setmetatable({},{__index=function() return function() end end})
 local add=e.AddComponent
 function e:AddComponent(n)
  if n=='pickable' then self.components[n]=Pickable(self);return self.components[n] end
  local c=add(self,n)
  if n=='lootdropper' then
   c=LootDropper(self);self.components[n]=c
   c.SpawnLootPrefab=function(s,name)
    local item=CreateEntity();item.prefab=name;item.components.inventoryitem={};return item
   end
  end
  return c
 end
 return e
end
''')
path = ROOT / 'scripts/prefabs/ttk_spirit_workshop.lua'
assert path.exists(), 'Permanent harvestable spirit workshop not implemented'
workshop, placer = lua.execute(path.read_text(encoding='utf-8'))
lua.globals().workshop = workshop
lua.execute(r'''
local w=workshop.fn()
assert(w:HasTag('structure') and not w:HasTag('boulder'))
assert(w.components.workable==nil,'workshop must not require mining')
w:PushEvent('onbuilt')
assert(not w.components.pickable:CanBePicked(),'new building must produce before first harvest')
assert(w.components.timer:GetTimeLeft('produce')==5*480)
local picker=CreateEntity();local received={}
picker.components.inventory={GiveItem=function(_,item) received[item.prefab]=(received[item.prefab] or 0)+1 end}
assert(not w.components.pickable:Pick(picker));assert(next(received)==nil)
advance(w,480*2)
local td=w.components.timer:OnSave();local pd=w.components.pickable:OnSave()
local loaded=workshop.fn();loaded.components.timer:OnLoad(td);loaded.components.pickable:OnLoad(pd)
assert(not loaded.components.pickable:CanBePicked())
advance(loaded,480*3-1);assert(not loaded.components.pickable:CanBePicked())
advance(loaded,1);assert(loaded.components.pickable:CanBePicked())
assert(loaded.components.pickable:Pick(picker))
assert(received.ttk_lingshi1==20 and received.ttk_lingshi2==2)
assert(received.cutstone==nil,'harvest must never refund construction ingredients')
assert(loaded:IsValid() and not loaded.components.pickable:CanBePicked())
assert(not loaded.components.pickable:Pick(picker));assert(received.ttk_lingshi1==20)
loaded.components.timer:LongUpdate(5*480);advance(loaded,0)
assert(loaded.components.pickable:CanBePicked())
local ready=workshop.fn();ready.components.pickable:OnLoad(loaded.components.pickable:OnSave())
assert(ready.components.pickable:CanBePicked(),'ready batch must survive reload')
assert(ready.components.pickable:Pick(picker));assert(received.ttk_lingshi1==40)
TheWorld.ismastersim=false
assert(workshop.fn().components.pickable==nil)
print('PASS: build/wait/harvest, multi-tier products, no mining, repeat collection, no duplicate harvest, ready and producing save/load, client boundary')
''')
legacy = lua.execute((ROOT / 'scripts/prefabs/ttk_spirit_mines.lua').read_text())
lua.globals().legacy = lua.table_from([p for p in legacy if p.fn is not None])
lua.execute(r'''
TheWorld.ismastersim=true
local migrated={}
function SpawnPrefab(name)
 assert(name=='ttk_spirit_workshop')
 local e=workshop.fn();table.insert(migrated,e);return e
end
for _,p in ipairs(legacy) do
 local old=p.fn();old.OnLoad(old,{crafted=true,exhausted=true})
 old.components.timer:StartTimer('regrow',123)
 assert(not old.components.workable:CanBeWorked())
 advance(old,0)
 assert(old.removed and #migrated>0)
 local new=migrated[#migrated]
 assert(not new.components.pickable:CanBePicked())
 assert(new.components.timer:GetTimeLeft('produce')==123)
 local ready=p.fn();ready.OnLoad(ready,{crafted=true,exhausted=false});advance(ready,0)
 assert(ready.removed and migrated[#migrated].components.pickable:CanBePicked())
 local wild=p.fn();wild.OnLoad(wild,{crafted=false});advance(wild,0)
 assert(not wild.removed and wild.components.workable:CanBeWorked())
end
assert(#migrated==6,'exactly one replacement per old crafted mine')
print('PASS: all legacy crafted tiers migrate once, preserve remaining cooldown/readiness; natural mines stay unchanged')
''')
