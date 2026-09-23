"""Exercise the bottle with DST's actual finiteuses component (Lua 5.1)."""
from pathlib import Path
import sys
from zipfile import ZipFile

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT.parents[1] / '.superpowers/chuongthienbinh-runtime'))
from lupa.lua51 import LuaRuntime

lua = LuaRuntime(unpack_returned_tuples=True)
with ZipFile("C:/Program Files (x86)/Steam/steamapps/common/Don't Starve Together/data/databundles/scripts.zip") as z:
    lua.execute(z.read('scripts/class.lua').decode())
    lua.globals().FiniteUses = lua.execute(z.read('scripts/components/finiteuses.lua').decode())
lua.execute('''
function noop() end
function api() return setmetatable({}, {__index=function() return noop end}) end
TheWorld={ismastersim=true, state={phase="night"}, HasTag=function() return false end}
function Asset(kind,path) return {kind,path} end
function Prefab(name,fn,assets) return {name=name,fn=fn,assets=assets} end
function MakeInventoryPhysics() end
function MakeInventoryFloatable() end
function MakeHauntableLaunch() end
function Remap(v,a,b,c,d) return c+(v-a)/(b-a)*(d-c) end
function CreateEntity()
 local e={components={}, tags={}, listeners={}, watchers={}, tasks={}, entity=api(),
  AnimState=api(), Transform=api(), Light=api()}
 function e:AddTag(t) self.tags[t]=true end
 function e:RemoveTag(t) self.tags[t]=nil end
 function e:HasTag(t) return self.tags[t] end
 function e:GetSkinBuild() return nil end
 function e:IsValid() return not self.removed end
 function e:IsInLimbo() return false end
 function e:Remove() self.removed=true end
 function e:SpawnChild() return CreateEntity() end
 function e:ListenForEvent(k,fn) self.listeners[k]=fn end
 function e:PushEvent(k,data) if self.listeners[k] then self.listeners[k](self,data) end end
 function e:WatchWorldState(k,fn) self.watchers[k]=fn end
 function e:DoPeriodicTask(t,fn) self.tick=fn end
 function e:DoTaskInTime(t,fn) fn(self) end
 function e:AddComponent(k)
  local c={}
  if k=="finiteuses" then c=FiniteUses(self)
  elseif k=="inventoryitem" then c.ChangeImageName=noop; function c:SetOnPutInInventoryFn(fn) self.onpickup=fn end
  elseif k=="equippable" then c.SetOnEquip=noop;c.SetOnUnequip=noop
  elseif k=="spellcaster" then function c:SetSpellFn(fn) self.spell=fn end end
  self.components[k]=c
 end
 return e
end
function SpawnPrefab() return CreateEntity() end
TheSim={FindEntities=function() return crops end}
caster={components={talker={Say=noop}}}
function crop()
 local c=CreateEntity(); c:AddTag("farm_plant")
 c.Transform.GetWorldPosition=function() return 0,0,0 end
 c.components.growable={magicgrowable=true, DoGrowth=function() grown=grown+1;return true end}
 return c
end
''')
prefab = ROOT / 'scripts/prefabs/ttk_chuongthienbinh.lua'
assert prefab.is_file(), 'Missing craftable Chưởng Thiên Bình prefab'
lua.globals().bottle = lua.execute(prefab.read_text(encoding='utf-8'))
lua.execute('''
inst=bottle.fn(); f=inst.components.finiteuses
assert(f.total==200 and f:GetUses()==0)
inst.tick(inst); assert(math.abs(f:GetUses()-0.6)<0.00001)
inst.components.inventoryitem.owner=caster; inst.tick(inst); assert(f:GetUses()==0.6)
inst.components.inventoryitem.owner=nil; TheWorld.state.phase="day"; inst.tick(inst); assert(f:GetUses()==0.6)
TheWorld.state.phase="night"; f:SetUses(199.9); inst.tick(inst); assert(f:GetUses()==200)
grown=0; crops={crop(),crop(),crop(),crop()}
for i=1,4 do assert(inst.components.spellcaster.spell(inst,crops[1],nil,caster)) end
assert(f:GetUses()==0 and grown==12 and not inst.removed)
assert(not inst.components.spellcaster.spell(inst,crops[1],nil,caster)); assert(grown==12)
f:SetUses(50); crops={}; assert(not inst.components.spellcaster.spell(inst,crop(),nil,caster)); assert(f:GetUses()==50)
assert(not inst.components.spellcaster.spell(inst,nil,nil,caster))
for _,amount in ipairs({0,73.4,200}) do
 f:SetUses(amount); local saved=f:OnSave(); local other=bottle.fn();other.components.finiteuses:OnLoad(saved)
 assert(other.components.finiteuses:GetUses()==amount)
end
TheWorld.HasTag=function() return true end; assert(bottle.fn().tick==nil)
TheWorld.ismastersim=false; assert(bottle.fn().components.finiteuses==nil)
''')
lua.execute('''
GLOBAL=_G; STRINGS={NAMES={},RECIPE_DESC={},CHARACTERS={GENERIC={DESCRIBE={}}}}
TECH={MAGIC_TWO={}}; PrefabFiles={}; recipes={}
function Ingredient(name,count) return {name=name,count=count} end
function RegisterInventoryItemAtlas() end
function AddRecipe2(name,ingredients,tech,config) recipes[name]={ingredients=ingredients,config=config} end
''')
lua.execute((ROOT/'main/ttk_chuongthienbinh.lua').read_text(encoding='utf-8'))
lua.execute('assert(recipes.ttk_chuongthienbinh and not recipes.ttk_chuongthienbinh.config.builder_tag)')
for _, asset in lua.globals().bottle.assets.items():
    assert (ROOT / asset[2]).is_file(), asset[2]
for path in ROOT.rglob('*.lua'):
    lua.execute('assert(loadstring(...))', path.read_text(encoding='utf-8-sig'))
assert 'modimport("main/ttk_chuongthienbinh.lua")' in (ROOT/'modmain.lua').read_text(encoding='utf-8')
print('PASS: capacity, recharge, four casts, empty/no-target guards, save/load, caves, client, recipe, assets and Lua syntax.')
