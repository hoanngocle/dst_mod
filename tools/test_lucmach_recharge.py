"""Exercise flying-sword recharge with DST finiteuses and the shipped prefab."""
from pathlib import Path
from zipfile import ZipFile
import sys

sys.stdout.reconfigure(encoding='utf-8')
ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT.parents[1] / '.superpowers/ttk-solo-integration/lua-runtime'))
from lupa.lua51 import LuaRuntime

lua = LuaRuntime(unpack_returned_tuples=True)
with ZipFile("C:/Program Files (x86)/Steam/steamapps/common/Don't Starve Together/data/databundles/scripts.zip") as game:
    lua.execute(game.read('scripts/class.lua').decode())
    lua.globals().FiniteUses = lua.execute(game.read('scripts/components/finiteuses.lua').decode())
fixture = (ROOT / 'tools/test_nhatvuphuonghoa.py').read_text(encoding='utf-8').split("lua.execute(r'''")[1].split("''')")[0]
lua.execute(fixture)
lua.globals().package.path = str(ROOT / 'scripts/?.lua').replace('\\', '/') + ';' + lua.globals().package.path
lua.execute('''
GLOBAL=_G; Assets={}; PrefabFiles={}; actions={}; hooks={}; ACTIONS={}
EQUIPSLOTS={HANDS='hands',BODY='body',NECK='neck'}
STRINGS={NAMES={},CHARACTERS={GENERIC={DESCRIBE={}}},RECIPE_DESC={}}
TECH={MAGIC_THREE={}}; FRAMES=1/30
DEGREES=math.pi/180
function noop() end
function EventHandler(...) return {...} end
function State(...) return {...} end
function TimeEvent(...) return {...} end
function StateGraph(...) return {...} end
function Ingredient(...) return {...} end
function GetModConfigData() error('Sword must not read removed config') end
RegisterInventoryItemAtlas=noop; AddRecipe2=noop; modimport=noop
function AddPrefabPostInit(name,fn) hooks[name]=fn end
function AddAction(name,label,fn) actions[name]=fn; ACTIONS[name]={} end
function AddComponentAction(_,_,fn) componentaction=fn end
AddStategraphActionHandler=noop; ActionHandler=noop
TheNet.GetIsClient=function() return false end
local oldCreate=CreateEntity
function CreateEntity()
 local inst=oldCreate()
 function inst:GetPosition() return {x=0,y=0,z=0} end
 inst.Light=setmetatable({}, {__index=function() return noop end})
 inst.AnimState=setmetatable({GetCurrentAnimationLength=function() return 1 end}, {__index=function()return noop end})
 function inst:PushEvent(name,data) if self.events[name] then self.events[name](self,data) end end
 local add=inst.AddComponent
 function inst:AddComponent(name)
  if name=='finiteuses' then self.components[name]=FiniteUses(self)
  else add(self,name) end
  return self.components[name]
 end
 return inst
end
''')
lua.execute((ROOT / 'main/lucmachthankiem.lua').read_text(encoding='utf-8'))
lua.execute((ROOT / 'main/lucmachthankiem_recharge.lua').read_text(encoding='utf-8'))
prefabs = lua.execute((ROOT / 'scripts/prefabs/lucmachthankiem.lua').read_text(encoding='utf-8'))
lua.globals().swordprefab = next(p for p in prefabs if p.name == 'lucmachthankiem')
lua.execute('''
local sword=swordprefab.fn()
local uses=sword.components.finiteuses
assert(uses.total==1000 and uses:GetUses()==1000)
assert(sword.components.equippable.equipslot=='neck')
assert(sword.components.equippable.walkspeedmult==1.15)
assert(TUNING.LUCMACHTHANKIEM_DAMAGE==50 and TUNING.LUCMACHTHANKIEM_UPGRADE_NEED==9)
local consumed=0
local function donor(name, stack)
 local item=CreateEntity(); item.prefab=name
 function item:Remove() consumed=consumed+1; self.removed=true end
 if stack then
  item.components.stackable={stacksize=stack,Get=function(self)
   self.stacksize=self.stacksize-1; return donor(name)
  end}
 end
 return item
end
local doer={}
local recharge=actions.LUCMACHTHANKIEM_RECHARGE
local function feed(item) return recharge({target=sword,invobject=item,doer=doer}) end
assert(hooks.spear and hooks.glasscutter, 'weapon donors registered on both peers')
assert(not feed(donor('spear')) and consumed==0, 'full sword must reject repair-only donors')
local unequipped,returned=0,0
local owner={components={inventory={}},GetPosition=function()return {x=0,y=0,z=0}end}
function owner.components.inventory:Unequip(slot)
 assert(slot=='neck'); unequipped=unequipped+1
 sword.components.equippable.isequipped=false
 return sword
end
function owner.components.inventory:GiveItem(item)
 assert(item==sword); returned=returned+1
end
sword.components.inventoryitem.owner=owner
sword.components.equippable.isequipped=true
uses:Use(1000)
assert(unequipped==1 and returned==1, 'empty equipped sword returns to inventory')
assert(sword:IsValid() and uses:GetUses()==0, 'empty sword survives')
assert(sword.components.equippable.restrictedtag=='RESTRICTED')
assert(feed(donor('spear')) and uses:GetUses()==25 and consumed==1)
assert(sword.components.equippable.restrictedtag==nil, 'repair restores equipping')
assert(not feed(donor('log')) and consumed==1)
uses:SetUses(990)
assert(feed(donor('glasscutter')) and uses:GetUses()==1000 and consumed==2)
assert(not feed(donor('opalpreciousgem')) or sword.rainbow_enable, 'opal may upgrade full sword')
local before=consumed
assert(not feed(donor('opalpreciousgem')) and consumed==before, 'full rainbow sword rejects extra opal')
uses:SetUses(0)
local saved=uses:OnSave()
local itemdata={}; sword:OnSave(itemdata)
uses:SetUses(1000); uses:OnLoad(saved)
sword:OnLoad(itemdata); sword:Flush()
assert(sword:IsValid() and uses:GetUses()==0)
local darts=donor('blowdart_pipe',3)
assert(feed(darts) and uses:GetUses()==75 and darts.components.stackable.stacksize==2)
uses:SetUses(1000)
local count=sword.summon_count
for i=1,8 do assert(feed(donor('bluegem'))) end
assert(sword.summon_count==count)
assert(feed(donor('bluegem')) and sword.summon_count==count+1, 'nine gems per upgrade')
assert(not feed(donor('bluegem')), 'wrong upgrade gem at full durability must be preserved')
''')
print('PASS: real prefab survives depletion/save-load, weapon recharge restores equipping, full/invalid donors are preserved, stacks consume one, nine gems upgrade.')
for path in [ROOT/'main/lucmachthankiem.lua', ROOT/'main/lucmachthankiem_recharge.lua', ROOT/'modinfo.lua']:
    lua.execute('assert(loadstring(...))', path.read_text(encoding='utf-8'))
print('PASS: Lua 5.1 syntax.')
