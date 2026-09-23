"""Compatibility regressions against Pham Nhan integrated strengthening damage."""
from pathlib import Path
from zipfile import ZipFile
import sys
sys.stdout.reconfigure(encoding='utf-8')
ROOT=Path(__file__).resolve().parents[1]
SOLO=ROOT.parent/'mod_steam/3780347550'
sys.path.insert(0,str(ROOT.parents[1]/'.superpowers/ttk-solo-integration/lua-runtime'))
from lupa.lua51 import LuaRuntime
lua=LuaRuntime(unpack_returned_tuples=True)
with ZipFile("C:/Program Files (x86)/Steam/steamapps/common/Don't Starve Together/data/databundles/scripts.zip") as game:
    lua.execute(game.read('scripts/class.lua').decode())
    lua.globals().Trader=lua.execute(game.read('scripts/components/trader.lua').decode())
    lua.globals().FiniteUses=lua.execute(game.read('scripts/components/finiteuses.lua').decode())
fixture=(ROOT/'tools/test_nhatvuphuonghoa.py').read_text(encoding='utf-8').split("lua.execute(r'''")[1].split("''')")[0]
lua.execute(fixture)
lua.globals().package.path=';'.join(str(p).replace('\\','/') for p in [ROOT/'scripts/?.lua',SOLO/'scripts/?.lua'])+';'+lua.globals().package.path
lua.execute('''
Solo=require('components/wb_strengthen')
local oldCreate=CreateEntity
function CreateEntity()
 local e=oldCreate()
 function e:PushEvent(n,d) if self.events[n] then self.events[n](self,d) end end
 local add=e.AddComponent
 function e:AddComponent(n)
  if n=='finiteuses' then self.components[n]=FiniteUses(self)
  elseif n=='weapon' then
   self.components[n]={inst=self,SetDamage=function(s,d) s.damage=d end,
    SetRange=function(s,d) s.range=d end,CanRangedAttack=function() return false end,
    GetDamage=function(s) return s.damage, nil end,
    OnAttack=function(s) s.nativeattacks=(s.nativeattacks or 0)+1 end}
  else add(self,n) end
 end
 return e
end
function BindDamage(inst, level)
 inst.prefab=inst.prefab or 'test_weapon'
 local s=setmetatable({inst=inst,level=level,do_mode='strengthen',buffs_status={},manual_buff_list={}}, {__index=Solo})
 function s:Refresh() self.refreshes=(self.refreshes or 0)+1 end
 inst.components.wb_strengthen=s
 s:BindBuff('damage'); s.refreshes=0
 return s
end
function Expected(base,level)
 local bonus=4*2^(level/2)
 return math.floor(math.max(bonus,base+bonus/2)*10)/10
end
function Near(a,b) assert(math.abs(a-b)<1e-6, tostring(a)..' != '..tostring(b)) end
''')
lua.globals().sword=lua.execute((ROOT/'scripts/prefabs/ttk_tinhlakiem.lua').read_text(encoding='utf-8'))
lua.execute('''
local item=sword.fn(); local s=BindDamage(item,2)
Near(item.components.weapon.damage,Expected(100,2))
item.components.finiteuses:SetUses(0)
Near(item.components.weapon.damage,Expected(100,2))
item.components.finiteuses:Repair(25)
Near(item.components.weapon.damage,Expected(100,2))
assert(s.refreshes==0,'native state must not unequip/re-equip')
for i=1,20 do item.components.finiteuses:Use(1) end
Near(item.components.weapon.damage,Expected(100,2))
s:UnBindBuff('damage'); assert(item.components.weapon.damage==100)
local high=sword.fn(); local boost=BindDamage(high,13)
Near(high.components.weapon.damage,Expected(100,13))
for i=1,5 do high.components.finiteuses:SetUses(0); high.components.finiteuses:Repair(25) end
Near(high.components.weapon.damage,Expected(100,13))
assert(boost.buffs_status.damage.original_damage==100)
''')
print('PASS: actual Solo damage binding survives depletion/repair and maximum level without drift or Refresh.')
lua.execute('''
local bridge=require('ttk_weapon_damage')
local banner=require('vanhonphien_damage')
local item=CreateEntity(); banner.Install(item)
local s=BindDamage(item,13)
local hits=0
local callback=function(inst,level,status,cfg,attacker,target,projectile)
 hits=hits+1; Near(inst.components.weapon:GetDamage(),Expected(20,13)*1.45)
end
s.buffs_status.test={level=3}; Solo.BUFFS_CONFIG.test={onattackfn=callback}
item.components.weapon.__onattackfn_map={test=callback}
item._ttk_ritual_level=9
local attacking={GetDamage=function() return banner.Get(item) end}
bridge.ForwardAttack(item,attacking,{}, {})
assert(hits==1); assert(item.components.weapon:GetDamage()==0)
function s:OnSave() return {level=self.level,buffs_status=self.buffs_status} end
local data={}; banner.Save(item,data)
local ground=CreateEntity(); banner.Load(ground,data)
attacking.GetDamage=function() return banner.Get(ground) end
bridge.ForwardAttack(ground,attacking,{}, {})
assert(hits==2 and ground.components.weapon==nil)
Solo.BUFFS_CONFIG.test.onattackfn=function() error('expected proc failure') end
assert(not pcall(bridge.ForwardAttack,ground,attacking,{},{}))
assert(ground.components.weapon==nil and not ground._ttk_forwarding_attack)
Solo.BUFFS_CONFIG.test=nil
local commands, attacks=0,0
local held={_ttk_attack_command=function() commands=commands+1 end}
local combat={inst={}, GetWeapon=function()return held end,
 CanHitTarget=function()return true end, DoAttack=function()attacks=attacks+1 end}
bridge.InstallCommandFilter(combat)
combat:DoAttack(CreateEntity()); assert(commands==1 and attacks==0)
combat:DoAttack(CreateEntity(),{components={}}); assert(attacks==1)
combat:DoAttack(CreateEntity(),held,{}); assert(attacks==2)
''')
print('PASS: live/deployed banner proc damage, ritual multiplier, error cleanup and command filtering.')
lua.execute('''
TUNING.LUCMACHTHANKIEM_DAMAGE=34
local item=CreateEntity(); item:AddComponent('weapon')
item.real_weapon=CreateEntity(); item.real_weapon:AddComponent('weapon')
item.real_weapon.components.weapon:SetDamage(17)
item.RainbowEffect=function(self,on)self.rainbow_enable=on end
item.OnLoad=function()end
local list=require('util/lucmachthankiem_solo').WrapPrefabs({{name='lucmachthankiem',fn=function()return item end}})
list[1].fn()
local s=BindDamage(item,20)
Near(item.real_weapon.components.weapon:GetDamage(),Expected(34,20)/2)
item:RainbowEffect(true)
Near(item.real_weapon.components.weapon:GetDamage(),Expected(68,20)/2)
assert(s.refreshes==0)
for i=1,5 do item:OnLoad({}); item:Flush() end
Near(item.real_weapon.components.weapon:GetDamage(),Expected(68,20)/2)
assert(s.buffs_status.damage.original_damage==68)
local procs=0
Solo.BUFFS_CONFIG.test={}
s.buffs_status.test={level=1}
item.components.weapon.__onattackfn_map={test=function(inst)
 procs=procs+1; Near(inst.components.weapon:GetDamage(),Expected(68,20)/2)
end}
item._ttk_attack_command(item,{},{}); assert(procs==0)
item.real_weapon.components.weapon:OnAttack({},{}); assert(procs==1)
assert(item.components.weapon:GetDamage()==0)
''')
print('PASS: flying sword Solo enhancement, rainbow/load stability and impact-only procs.')
