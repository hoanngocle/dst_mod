"""Exercise ported armour callbacks, recipes, shield lifecycle and light dependency."""
from pathlib import Path
import sys
from zipfile import ZipFile

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT.parents[1] / '.superpowers/luoshen-runtime'))
from lupa.lua51 import LuaRuntime

module = ROOT / 'main/ttk_armor_set.lua'
assert module.exists(), 'Armour set registration is missing'
lua = LuaRuntime(unpack_returned_tuples=True)
with ZipFile("C:/Program Files (x86)/Steam/steamapps/common/Don't Starve Together/data/databundles/scripts.zip") as game:
    lua.execute(game.read('scripts/class.lua').decode())
    lua.globals().Trader = lua.execute(game.read('scripts/components/trader.lua').decode())
fixture = (ROOT / 'tools/test_nhatvuphuonghoa.py').read_text(encoding='utf-8').split("lua.execute(r'''")[1].split("''')")[0]
lua.execute(fixture)
lua.execute('''
EQUIPSLOTS={HEAD='head',BODY='body'}; FORGEMATERIALS={}; FRAMES=1/30
function MakeForgeRepairable(inst,material,broken,repaired) inst.broken=broken; inst.repaired=repaired end
local oldCreate=CreateEntity
function CreateEntity()
 local e=oldCreate()
 function e:RemoveEventCallback(n,f,owner) (owner or self).events[n]=nil end
 function e:ListenForEvent(n,f,owner) (owner or self).events[n]=f end
 function e:DoTaskInTime(t,f) local task={time=t,fn=f,Cancel=function(s) s.cancelled=true end}; self.lasttask=task; return task end
 function e:DoPeriodicTask(t,f) self.periodic={time=t,fn=f}; return {Cancel=function() end} end
 local oldAdd=e.AddComponent
 function e:AddComponent(n)
  oldAdd(self,n); local c=self.components[n]
  if n=='armor' then
   function c:InitCondition(v,a) self.maxcondition=v; self.condition=v; self.absorb_percent=a end
   function c:GetPercent() return self.condition/self.maxcondition end
   function c:Repair(v) self.condition=math.min(self.maxcondition,self.condition+v) end
   function c:TakeDamage(v) self.condition=math.max(0,self.condition-v) end
   function c:SetAbsorption(v) self.absorb_percent=v end
  elseif n=='planardefense' then
   function c:SetBaseDefense(v) self.base=v end
  elseif n=='insulator' then
   function c:SetInsulation(v) self.insulation=v end
  elseif n=='timer' then
   function c:PauseTimer() self.paused=true end
   function c:ResumeTimer() self.paused=false end
  end
  return self.components[n]
 end
 return e
end
function SpawnPrefab(name)
 local e=CreateEntity(); e.prefab=name; e.kill_fx=function(s) s:Remove() end
 e.Light={SetRadius=function(s,r) s.radius=r end}
 return e
end
''')
for name in ('ttk_zcmj', 'ttk_xshj', 'ttk_yunxiao_ymsz'):
    result = lua.execute((ROOT / f'scripts/prefabs/{name}.lua').read_text(encoding='utf-8'))
    lua.globals()[name] = result[0] if isinstance(result, tuple) else result
lua.execute('''
local hat=ttk_zcmj.fn(); local body=ttk_xshj.fn(); local coat=ttk_yunxiao_ymsz.fn()
assert(hat.components.armor.maxcondition==830 and hat.components.armor.absorb_percent==.9)
assert(body.components.armor.maxcondition==830 and body.components.equippable.walkspeedmult==1.1)
assert(hat.components.planardefense.base==10 and body.components.planardefense.base==10)
for _,inst in ipairs({hat,body}) do
 inst.components.armor:TakeDamage(83); inst.periodic.fn(inst)
 assert(math.abs(inst.components.armor:GetPercent()-.91)<1e-9)
 assert(not inst.components.trader.abletoaccepttest(inst,{prefab='ttk_lingshi1'}))
 inst.components.trader.onaccept(inst,nil,{prefab='ttk_lingshi2'})
 assert(inst.components.armor:GetPercent()==1)
 assert(not inst.components.trader.abletoaccepttest(inst,{prefab='ttk_lingshi2'}))
 inst.components.armor:TakeDamage(400)
 local consumed=0
 local stone={prefab='ttk_lingshi2',components={stackable={stacksize=3}}}
 function stone.components.stackable:Get(count)
  self.stacksize=self.stacksize-count
  return {Remove=function() consumed=consumed+count end}
 end
 assert(inst.components.trader:AcceptGift(nil,stone))
 assert(consumed==1 and stone.components.stackable.stacksize==2)
 assert(not inst.components.trader.abletoaccepttest(inst,stone,nil,2))
 inst.broken(inst); assert(not inst.components.equippable)
 inst.components.armor.condition=0; inst.periodic.fn(inst)
 assert(inst.components.equippable and not inst:HasTag('broken'))
end
local owner=CreateEntity(); owner.components.inventory={EquipHasTag=function() return false end}
owner.components.combat={externaldamagemultipliers={SetModifier=function(s,k,v) s.value=v end,RemoveModifier=function(s) s.value=nil end}}
hat.components.equippable.onequip(hat,owner)
assert(owner.components.combat.externaldamagemultipliers.value==1.2)
local random=math.random; math.random=function() return 0 end
owner.events.attacked(owner,{})
assert(not hat:HasTag('forcefield'), 'hat alone must not proc')
owner.components.inventory.EquipHasTag=function() return true end
owner.events.attacked(owner,{redirected=true}); assert(not hat:HasTag('forcefield'))
owner.events.attacked(owner,{})
assert(hat:HasTag('ttk_avoid_damage') and hat.components.armor.absorb_percent==1 and hat.lasttask.time==2)
local effect=hat._fx; hat.lasttask.fn(hat)
assert(effect.removed and not hat:HasTag('forcefield') and hat.lasttask.time==8)
owner.events.attacked(owner,{}); assert(not hat:HasTag('forcefield'))
hat.lasttask.fn(hat); owner.events.attacked(owner,{})
assert(hat:HasTag('forcefield'))
hat.components.equippable.onunequip(hat,owner)
assert(not hat:HasTag('ttk_avoid_damage') and not owner.events.attacked)
assert(owner.components.combat.externaldamagemultipliers.value==nil)
-- Exclusive Yao hat build must hide HEAD_HAT while equipped and restore all
-- head/hair channels on clear; this was previously compared to the wrong ttk_ id.
local skinowner=CreateEntity(); skinowner.isplayer=true; skinowner:AddTag('player')
skinowner.components.inventory={EquipHasTag=function() return false end}
skinowner.components.combat={externaldamagemultipliers={SetModifier=function() end,RemoveModifier=function() end}}
skinowner.AnimState={hidden={},shown={}}
function skinowner.AnimState:Hide(name) self.hidden[name]=true; self.shown[name]=nil end
function skinowner.AnimState:Show(name) self.shown[name]=true; self.hidden[name]=nil end
function skinowner.AnimState:OverrideSymbol(name,build,symbol) self.override={name,build,symbol} end
function skinowner.AnimState:ClearOverrideSymbol(name) self.cleared=name end
hat.GetSkinBuild=function() return 'xd_yaohat' end
hat.GetSkinName=function() return 'ttk_zcmj_skins_yaohat' end
hat.components.equippable.onequip(hat,skinowner)
assert(skinowner.AnimState.hidden.HEAD_HAT and skinowner.AnimState.override[2]=='xd_yaohat')
hat.components.equippable.onunequip(hat,skinowner)
assert(skinowner.AnimState.shown.HEAD and skinowner.AnimState.shown.HAIR and skinowner.AnimState.cleared=='swap_hat')
math.random=random
assert(coat.components.armor.maxcondition==840 and coat.components.insulator.insulation==240)
assert(coat.components.timer.paused)
coat.components.equippable.onequip(coat,owner)
assert(coat._light.prefab=='minerhatlight' and not coat.components.timer.paused)
assert(coat._light.Light.radius==5)
coat.events.timerdone(coat,{name='use'})
assert(math.abs(coat.components.armor:GetPercent()-.9875)<1e-9)
local light=coat._light; coat.components.equippable.onunequip(coat,owner)
assert(light.removed and coat.components.timer.paused)
coat.components.equippable.onequip(coat,owner); light=coat._light
coat.OnRemoveEntity(coat); assert(light.removed)
TheWorld.ismastersim=false
for _,p in ipairs({ttk_zcmj,ttk_xshj,ttk_yunxiao_ymsz}) do assert(p.fn().components.armor==nil) end
TheWorld.ismastersim=true
GLOBAL=_G; PrefabFiles={}; Assets={}
STRINGS={NAMES={},RECIPE_DESC={},CHARACTERS={GENERIC={DESCRIBE={}}}}
TECH={NONE=0,LOST=10}; Ingredient=function(n,c) return {name=n,amount=c} end
RegisterInventoryItemAtlas=function() end
recipes={}; AddRecipe2=function(n,i,t,c) recipes[n]={ingredients=i,tech=t,config=c} end
AddComponentPostInit=function(n,f) assert(n=='inventory'); inventoryHook=f end
''')
lua.execute(module.read_text(encoding='utf-8'))
lua.execute('''
for _,name in ipairs({'ttk_zcmj','ttk_xshj','ttk_yunxiao_ymsz'}) do
 local r=assert(recipes[name]); local expected=name=='ttk_yunxiao_ymsz' and TECH.NONE or TECH.LOST
 assert(r.tech==expected and not r.config.builder_tag and not r.config.nounlock, 'armour must require its blueprint; coat stays unlocked')
 for _,i in ipairs(r.ingredients) do assert(not string.find(i.name,'^xd_')) end
end
local inv={ApplyDamage=function() return 17,{planar=5} end,EquipHasTag=function() return false end}
inventoryHook(inv); local d,s=inv:ApplyDamage(100); assert(d==17 and s.planar==5)
inv.EquipHasTag=function(_,tag) return tag=='ttk_avoid_damage' end
d,s=inv:ApplyDamage(100); assert(d==0 and s==nil)
''')
for p in (ROOT / 'scripts/prefabs').glob('ttk_*.lua'):
    lua.execute('assert(loadstring(...))', p.read_text(encoding='utf-8-sig'))
print('PASS: armour stats, repair/broken recovery, set-only shield/cooldown/cleanup, original damage hook, miner light lifecycle, client split and blueprint-locked armour recipes')
