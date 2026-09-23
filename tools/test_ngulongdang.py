"""Verify lantern recharge using DST's actual Trader and prefab callbacks."""
from pathlib import Path
import sys
from zipfile import ZipFile

sys.stdout.reconfigure(encoding='utf-8')
ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT.parents[1] / '.superpowers/luoshen-runtime'))
from lupa.lua51 import LuaRuntime

lua = LuaRuntime(unpack_returned_tuples=True)
with ZipFile("C:/Program Files (x86)/Steam/steamapps/common/Don't Starve Together/data/databundles/scripts.zip") as game:
    lua.execute(game.read('scripts/class.lua').decode())
    lua.globals().Trader = lua.execute(game.read('scripts/components/trader.lua').decode())
    lua.execute("package.preload['util/sourcemodifierlist']=assert(loadstring(...))", game.read('scripts/util/sourcemodifierlist.lua').decode())
    lua.globals().Fueled = lua.execute(game.read('scripts/components/fueled.lua').decode())
# Share the existing engine fixture, not its umbrella assertions.
fixture = (ROOT / 'tools/test_nhatvuphuonghoa.py').read_text(encoding='utf-8').split("lua.execute(r'''")[1].split("''')")[0]
lua.execute(fixture)
lua.execute('''
function Vector3(x,y,z) return {x=x,y=y,z=z} end
function MakeSmallBurnable(inst) inst:AddComponent('burnable') end
function MakeSmallPropagator() end
function GetTime() return 0 end
function math.clamp(v,a,b) return math.max(a,math.min(b,v)) end
FUELTYPE.USAGE='USAGE'; FUELTYPE.BURNABLE='BURNABLE'
TUNING.REDLANTERN_RAIN_RATE=1; TUNING.SMALL_FUEL=90
TheWorld.state.israining=false
local original=CreateEntity
function CreateEntity()
 local e=original()
 e.Light=e.entity; e.Follower=e.entity
 e.AnimState.GetCurrentAnimationNumFrames=function() return 10 end
 function e:RemoveEventCallback() end
 function e:DoPeriodicTask() return {Cancel=function() end} end
 function e:Show() end
 function e:Hide() end
 local add=e.AddComponent
 function e:AddComponent(n)
  add(self,n)
  if n=='fueled' then
   self.components[n]=Fueled(self)
  elseif n=='temperatureoverrider' then
   local c=self.components[n]
   function c:Enable() self.enabled=true end
   function c:Disable() self.enabled=false end
   function c:SetRadius(r) self.radius=r end
   function c:SetTemperature(t) self.temperature=t end
  end
 end
 return e
end
function SpawnPrefab() return CreateEntity() end
''')
prefabs = lua.execute((ROOT / 'scripts/prefabs/ttk_ngulongdang.lua').read_text(encoding='utf-8'))
lua.globals().lantern = prefabs[0]
lua.execute('''
local inst=lantern.fn(); local fuel=inst.components.fueled; local trader=inst.components.trader
assert(fuel.maxfuel==3360 and fuel:GetPercent()==1)
assert(fuel.accepting==false and trader~=nil)
local stone={prefab='ttk_lingshi1',components={stackable={stacksize=20}}}
local consumed=0
function stone.components.stackable:Get(count)
 self.stacksize=self.stacksize-count
 return {Remove=function() consumed=consumed+count end}
end
assert(not trader:AcceptGift(nil,stone) and consumed==0)
fuel:DoDelta(-fuel.maxfuel)
assert(inst:IsValid() and not fuel.consuming and not inst.components.temperatureoverrider.enabled)
assert(not trader.abletoaccepttest(inst,{prefab='ttk_lingshi2'}))
assert(not trader.abletoaccepttest(inst,{prefab='wortox_soul'}))
assert(not trader.abletoaccepttest(inst,stone,nil,2))
assert(trader:AcceptGift(nil,stone))
assert(consumed==1 and stone.components.stackable.stacksize==19)
assert(math.abs(fuel:GetPercent()-.1)<1e-9 and fuel.consuming)
assert(inst.components.temperatureoverrider.enabled)
assert(inst.components.temperatureoverrider.radius==10 and inst.components.temperatureoverrider.temperature==19)
fuel:DoDelta(fuel.maxfuel*.85)
assert(trader:AcceptGift(nil,stone) and fuel:GetPercent()==1 and consumed==2)
assert(not trader:AcceptGift(nil,stone) and consumed==2)
inst.components.inventoryitem.owner=CreateEntity()
inst.components.inventoryitem.onput(inst)
assert(not fuel.consuming)
fuel:DoDelta(-fuel.maxfuel)
assert(trader:AcceptGift(nil,stone) and not fuel.consuming, 'bag recharge must not turn on')
inst.components.inventoryitem.owner=nil
inst.components.inventoryitem.ondropped(inst)
assert(fuel.consuming)
fuel:DoDelta(-fuel.maxfuel); inst.OnLoad(inst)
assert(inst:IsValid() and not fuel.consuming)
local player=CreateEntity()
inst.components.inventoryitem.owner=player; inst.components.equippable.equipped=true
inst.components.equippable.onequip(inst,player)
assert(trader:AcceptGift(nil,stone) and fuel.consuming)
fuel:DoUpdate(100)
local saved=fuel:OnSave(); local restored=lantern.fn()
restored.components.fueled:OnLoad(saved); restored.OnLoad(restored)
assert(restored.components.fueled.currentfuel==fuel.currentfuel)
assert(restored.components.fueled.maxfuel==3360)
TheWorld.ismastersim=false
local client=lantern.fn(); assert(client.components.trader==nil and client.components.fueled==nil)
''')
lua.execute('''
GLOBAL=_G; PrefabFiles={}; STRINGS={NAMES={},RECIPE_DESC={},CHARACTERS={GENERIC={DESCRIBE={}}}}
TECH={SCIENCE_ONE=1}; Ingredient=function(n,c) return {n,c} end
RegisterInventoryItemAtlas=function() end
AddRecipe2=function(name,ingredients,tech,config)
 assert(name=='ttk_ngulongdang' and tech==1 and config.builder_tag==nil)
 assert(#ingredients==4 and ingredients[4][1]=='ttk_lingshi2')
end
''')
lua.execute((ROOT / 'main/ttk_ngulongdang.lua').read_text(encoding='utf-8'))
assert 'main/ttk_ngulongdang.lua' in (ROOT / 'modmain.lua').read_text(encoding='utf-8')
for path in ROOT.rglob('*.lua'):
    lua.execute('assert(loadstring(...))', path.read_text(encoding='utf-8-sig'))
print('PASS: real Trader/Fueled: 10% recharge, one stone, cap/full rejection, wrong fuel, empty recovery, bag/drop/equip, save/load, temperature, recipe, client and syntax')
