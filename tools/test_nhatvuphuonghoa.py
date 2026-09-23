"""Exercise the actual prefab callbacks with a minimal DST engine fixture."""
from pathlib import Path
import sys
from zipfile import ZipFile
sys.stdout.reconfigure(encoding='utf-8')
ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parents[1]/'.superpowers/vinhhang-runtime'))
from lupa.lua51 import LuaRuntime
lua=LuaRuntime(unpack_returned_tuples=True)
with ZipFile("C:/Program Files (x86)/Steam/steamapps/common/Don't Starve Together/data/databundles/scripts.zip") as game:
    lua.execute(game.read('scripts/class.lua').decode())
    lua.globals().Trader = lua.execute(game.read('scripts/components/trader.lua').decode())
lua.execute(r'''
local function noop() end
local dummy=setmetatable({}, {__index=function() return noop end})
TUNING={VOIDCLOTH_UMBRELLA_DOME_RADIUS=4,VOIDCLOTH_UMBRELLA_DOME_RATE=2,
 SANITYAURA_SMALL=5,WATERPROOFNESS_ABSOLUTE=1,INSULATION_LARGE=240}
FUELTYPE={MAGIC="MAGIC"}; TheWorld={ismastersim=true,state={isacidraining=false}}
TheNet={IsDedicated=function() return true end}
Asset=function(...) return {...} end; Prefab=function(name,fn,assets,deps) return {name=name,fn=fn,assets=assets,deps=deps} end
MakeInventoryPhysics=noop; MakeInventoryFloatable=noop; MakeHauntableLaunch=noop
net_event=function() return dummy end
function CreateEntity()
 local e={entity=dummy,AnimState=dummy,DynamicShadow=dummy,SoundEmitter=dummy,
 Transform=dummy,components={},tags={},tasks={},events={}}
 function e:AddTag(t) self.tags[t]=true end
 function e:RemoveTag(t) self.tags[t]=nil end
 function e:HasTag(t) return self.tags[t] or false end
 function e:IsValid() return not self.removed end
 function e:IsAsleep() return true end
 function e:Remove() self.removed=true end
 function e:GetSkinBuild() return nil end
 function e:DoTaskInTime(_,f) table.insert(self.tasks,f) end
 function e:Flush() local q=self.tasks; self.tasks={}; for _,f in ipairs(q) do f(self) end end
 function e:WatchWorldState() end
 function e:StopWatchingWorldState() end
 function e:ListenForEvent(name,f) self.events[name]=f end
 function e:PushEvent() end
 function e:RemoveComponent(n) self.components[n]=nil end
 function e:AddDebuff(_,name) self.buffname=name end
 function e:AddComponent(n)
  local c={inst=self}; self.components[n]=c
  if n=='fueled' then
   c.rate_modifiers=dummy
   function c:InitializeFuelLevel(v) self.maxfuel=v; self.currentfuel=v end
   function c:GetPercent() return self.currentfuel/self.maxfuel end
   function c:IsEmpty() return self.currentfuel<=0 end
   function c:DoDelta(v) self.currentfuel=math.max(0,math.min(self.maxfuel,self.currentfuel+v)); if self:IsEmpty() then self.depleted(self.inst) end end
   function c:SetDepletedFn(f) self.depleted=f end
   function c:SetTakeFuelItemFn(f) self.onfuel=f end
   function c:StartConsuming() self.consuming=true end
   function c:StopConsuming() self.consuming=false end
  elseif n=='equippable' then
   function c:SetOnEquip(f) self.onequip=f end
   function c:SetOnUnequip(f) self.onunequip=f end
   function c:SetOnEquipToModel(f) self.tomodel=f end
   function c:IsEquipped() return self.equipped or false end
  elseif n=='inventoryitem' then
   function c:SetOnDroppedFn(f) self.ondropped=f end
   function c:SetOnPutInInventoryFn(f) self.onput=f end
  elseif n=='trader' then
   self.components[n]=Trader(self)
  elseif n=='spellcaster' then
   function c:SetSpellFn(f) self.spell=f end
  elseif n=='raindome' then
   c.SetRadius=noop
   function c:Enable() self.enabled=true end
   function c:Disable() self.enabled=false end
  elseif n=='debuff' then
   function c:SetAttachedFn(f) self.attach=f end
   function c:SetDetachedFn(f) self.detach=f end
   function c:SetExtendedFn(f) self.extend=f end
   function c:Stop() self.stopped=true end
  elseif n=='timer' then
   function c:StartTimer(_,v) self.remaining=v end
   c.StopTimer=noop
  elseif n=='moistureimmunity' then
   c.sources={}
   function c:AddSource(s) self.sources[s]=true end
   function c:RemoveSource(s) self.sources[s]=nil end
  else setmetatable(c,{__index=function() return noop end}) end
 end
 return e
end
''')
lua.globals().prefab=lua.execute((ROOT/'scripts/prefabs/nhatvuphuonghoa.lua').read_text(encoding='utf-8'))
lua.globals().buffprefab=lua.execute((ROOT/'scripts/prefabs/nhatvuphuonghoa_buff.lua').read_text(encoding='utf-8'))
lua.execute('''
local u=prefab.fn(); local fuel=u.components.fueled; local trader=u.components.trader
local accept=trader.abletoaccepttest
local stone={prefab='ttk_lingshi1'}
assert(not accept(u,stone), 'full umbrella rejects stone')
fuel:DoDelta(-fuel.maxfuel)
assert(u:IsValid() and u:HasTag('broken') and not u.components.equippable)
assert(accept(u,stone) and not accept(u,{prefab='ttk_lingshi2'}))
assert(not accept(u,stone,nil,2), 'must not consume multiple stones for one charge')
local consumed=0
stone.components={stackable={stacksize=3}}
function stone.components.stackable:Get(count)
 self.stacksize=self.stacksize-count
 return {Remove=function() consumed=consumed+count end}
end
assert(trader:AcceptGift(nil,stone))
assert(consumed==1 and stone.components.stackable.stacksize==2, 'real trader consumes one stone')
assert(math.abs(fuel:GetPercent()-.05)<1e-9)
assert(u.components.equippable and not u:HasTag('broken'))
u:Flush(); assert(u.components.raindome.enabled)
fuel:DoDelta(fuel.maxfuel*.94); trader.onaccept(u); assert(fuel:GetPercent()==1)
assert(not trader:AcceptGift(nil,stone) and consumed==1, 'full item does not consume stone')
local player=CreateEntity(); player:AddTag('player')
player.components.moisture={moisture=50,DoDelta=function(self,v) self.moisture=self.moisture+v end}
assert(u.components.spellcaster.can_cast_fn(player,player))
player:AddTag('playerghost'); assert(not u.components.spellcaster.can_cast_fn(player,player)); player:RemoveTag('playerghost')
u.components.spellcaster.spell(u,player,nil,player)
assert(player.components.moisture.moisture==0 and player.buffname=='nhatvuphuonghoa_buff')
assert(fuel:GetPercent()==.75)
fuel:DoDelta(-fuel.maxfuel*.6)
u.components.spellcaster.spell(u,player,nil,player)
assert(math.abs(fuel:GetPercent()-.15)<1e-9, 'insufficient fuel must not be consumed')
fuel:DoDelta(-fuel.maxfuel); u.OnLoad(u); assert(not u.components.equippable)
trader.onaccept(u); assert(u.components.equippable)
u.components.inventoryitem.owner=player
u.components.equippable.equipped=true
function player:GetPosition() return {} end
player.components.inventory={
 Unequip=function() u.components.equippable.onunequip(u,player); return u end,
 GiveItem=function() end,
}
fuel:DoDelta(-fuel.maxfuel)
assert(u:IsValid() and u:HasTag('broken') and not u.components.equippable, 'equipped depletion preserves repairable item')
trader.onaccept(u); assert(u.components.equippable and not u:HasTag('broken'))
local b=buffprefab.fn(); b.components.debuff.attach(b,player)
assert(b.components.timer.remaining==240 and player.components.moistureimmunity.sources[b])
local other={}; player.components.moistureimmunity:AddSource(other)
b.components.timer.remaining=1; b.components.debuff.extend(b,player); assert(b.components.timer.remaining==240)
b.components.debuff.detach(b,player)
assert(not player.components.moistureimmunity.sources[b] and player.components.moistureimmunity.sources[other])
assert(b.removed)
TheWorld.ismastersim=false
local client=prefab.fn(); assert(client.components.fueled==nil and client.components.trader==nil)
''')
lua.execute('''
GLOBAL=_G; PrefabFiles={}; STRINGS={NAMES={},RECIPE_DESC={},CHARACTERS={GENERIC={DESCRIBE={}}},ACTIONS={CASTSPELL={}}}
TECH={SCIENCE_TWO=2}; Ingredient=function(n,c) return {n,c} end
RegisterInventoryItemAtlas=function() end
AddRecipe2=function(name,ingredients,tech,config) assert(name=='nhatvuphuonghoa' and config.builder_tag==nil); assert(#ingredients==4) end
''')
lua.execute((ROOT/'main/nhatvuphuonghoa.lua').read_text(encoding='utf-8'))
for path in ROOT.rglob('*.lua'):
    lua.execute('assert(loadstring(...))',path.read_text(encoding='utf-8-sig'))
print('PASS: recharge 5%, cap/rejection, empty recovery, spell cost/target, 240s buff cleanup, client/server split, unrestricted recipe and all mod Lua syntax.')
