"""Test Tinh La Kiem using real DST finiteuses/trader components."""
from pathlib import Path
from zipfile import ZipFile
import sys
import re
import unittest
from test_support import find_dst_root, find_workspace_root
sys.stdout.reconfigure(encoding='utf-8')
ROOT=Path(__file__).resolve().parents[1]
from lupa.lua51 import LuaRuntime
assert (ROOT/'scripts/prefabs/ttk_tinhlakiem.lua').exists(), 'Tinh La Kiem prefab missing'
lua=LuaRuntime(unpack_returned_tuples=True)
with ZipFile(find_dst_root()/'data/databundles/scripts.zip') as game:
    lua.execute(game.read('scripts/class.lua').decode())
    lua.globals().Trader=lua.execute(game.read('scripts/components/trader.lua').decode())
    lua.globals().FiniteUses=lua.execute(game.read('scripts/components/finiteuses.lua').decode())
fixture=(ROOT/'tools/test_nhatvuphuonghoa.py').read_text(encoding='utf-8').split("lua.execute(r'''")[1].split("''')")[0]
lua.execute(fixture)
lua.globals().package.path=str(ROOT/'scripts/?.lua').replace('\\','/')+';'+lua.globals().package.path
try:
    PROVENANCE_WORKSPACE=find_workspace_root(
        'tools/port_vanhonphien.py',
        'mods/mod_steam/.tu-tien-extraction/byte_mapping.json',
        'mods/mod_steam/3235319974/scripts/main/actions.lua',
    )
except FileNotFoundError:
    PROVENANCE_WORKSPACE=None


class TinhLaKiemProvenanceTest(unittest.TestCase):
    @unittest.skipUnless(PROVENANCE_WORKSPACE, 'original Tu Tiên 19.7 provenance files are unavailable')
    def test_repair_values_match_original_tu_tien(self):
        sys.path.insert(0,str(PROVENANCE_WORKSPACE/'tools'))
        from port_vanhonphien import MAPPING, SOURCE
        raw=(SOURCE/'scripts/main/actions.lua').read_bytes()
        decoded=''.join(chr(MAPPING[b]) if b in MAPPING else '<%02X>' % b for b in raw[::-1])
        source_table=re.search(r'local repairableitems\s*=\s*(\{.*?\})',decoded,re.S).group(1)
        expected=dict(lua.execute('return '+source_table).items())
        actual=dict(lua.eval('require("ttk_tinhlakiem_repair")').items())
        self.assertEqual(actual, expected, 'Donor values differ from original Tu Tien 19.7')


lua.execute('''
local oldCreate=CreateEntity
function CreateEntity()
 local e=oldCreate()
 function e:PushEvent(name,data) if self.events[name] then self.events[name](self,data) end end
 local add=e.AddComponent
 function e:AddComponent(n)
  if n=='finiteuses' then self.components[n]=FiniteUses(self)
  elseif n=='weapon' then
   self.components[n]={SetDamage=function(s,v) s.damage=v end,SetRange=function(s,v) s.range=v end}
  else add(self,n) end
 end
 return e
end
function SpawnPrefab(name)
 local e=CreateEntity(); e.Follower={FollowSymbol=function() end}; e.prefab=name; return e
end
''')
lua.globals().swordprefab=lua.execute((ROOT/'scripts/prefabs/ttk_tinhlakiem.lua').read_text(encoding='utf-8'))
lua.execute('''
local sword=swordprefab.fn(); local uses=sword.components.finiteuses
assert(uses.total==1000 and uses:GetUses()==300)
assert(sword.components.weapon.damage==100 and sword.components.weapon.range==2)
assert(sword.components.equippable.restrictedtag==nil and sword.components.xd_bd==nil)
assert(sword.components.xd_lingji==nil)
uses:Use(300)
assert(sword:IsValid() and uses:GetUses()==0 and sword.components.weapon.damage==100)
local consumed=0
local function donor(name,count)
 local item=CreateEntity(); item.prefab=name
 item.components.inventoryitem={RemoveFromOwner=function() end}
 function item:Remove() consumed=consumed+1; self.removed=true end
 if count then
  item.components.stackable={stacksize=count,Get=function(s,n) s.stacksize=s.stacksize-n; return donor(name) end}
 end
 return item
end
local trader=sword.components.trader
assert(not trader:AcceptGift(nil,donor('twigs')) and consumed==0)
assert(not trader:AcceptGift(nil,sword) and consumed==0)
local spear=donor('spear'); spear.components.finiteuses={GetPercent=function() return .01 end}
assert(trader:AcceptGift(nil,spear) and consumed==1 and uses:GetUses()==25)
assert(sword.components.weapon.damage==100)
assert(trader:AcceptGift(nil,donor('nightsword')) and uses:GetUses()==125)
assert(trader:AcceptGift(nil,donor('ruins_bat')) and uses:GetUses()==275)
local darts=donor('blowdart_pipe',3)
assert(not trader:AcceptGift(nil,darts,2) and darts.components.stackable.stacksize==3)
assert(trader:AcceptGift(nil,darts) and darts.components.stackable.stacksize==2 and uses:GetUses()==350)
uses:SetUses(999); assert(trader:AcceptGift(nil,donor('spear')) and uses:GetUses()==1000)
local before=consumed; assert(not trader:AcceptGift(nil,donor('spear')) and consumed==before)
local fullsave=uses:OnSave(); assert(fullsave.uses==1000)
local restored=swordprefab.fn(); restored.components.finiteuses:OnLoad(fullsave)
assert(restored.components.finiteuses:GetUses()==1000 and restored.components.weapon.damage==100)
uses:SetUses(0); restored.components.finiteuses:OnLoad(uses:OnSave())
assert(restored.components.weapon.damage==100 and restored:IsValid())
assert(restored.components.trader:AcceptGift(nil,donor('shieldofterror')))
assert(restored.components.finiteuses:GetUses()==300 and restored.components.weapon.damage==100)
local owner=CreateEntity(); owner.GUID=2
sword.components.equippable.onequip(sword,owner); local fx=sword._vfx_fx_inst; assert(fx)
sword.components.equippable.onunequip(sword,owner); assert(fx.removed and sword._vfx_fx_inst==nil)
sword.components.equippable.onequip(sword,owner); fx=sword._vfx_fx_inst; sword.OnRemoveEntity(sword); assert(fx.removed)
TheWorld.ismastersim=false; local client=swordprefab.fn()
assert(client.components.weapon==nil and client:HasTag('alltrader'))
GLOBAL=_G; PrefabFiles={}; STRINGS={NAMES={},RECIPE_DESC={},CHARACTERS={GENERIC={DESCRIBE={}}}}
TECH={SCIENCE_TWO=2}; Ingredient=function(n,c) return {n,c} end
RegisterInventoryItemAtlas=function() end
AddRecipe2=function(n,i,t,c)
 assert(n=='ttk_tinhlakiem' and #i==3 and c.builder_tag==nil and c.no_deconstruction)
 assert(i[1][1]=='ttk_lingshi2' and i[1][2]==1)
 assert(i[2][1]=='bluegem' and i[2][2]==3)
 assert(i[3][1]=='goldnugget' and i[3][2]==6)
end
''')
lua.execute((ROOT/'main/ttk_tinhlakiem.lua').read_text(encoding='utf-8'))
print('PASS: 100 damage/2 range/300 of 1000 uses; depletion=100 damage; real trader consumes exactly one donor; full rejection; save/load; FX cleanup; no character gate; client split.')
