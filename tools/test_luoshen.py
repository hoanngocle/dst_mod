"""Lua 5.1 checks for the Luo Shen cooking and cultivation chain."""
from pathlib import Path
import runpy
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT.parents[1] / '.superpowers/luoshen-runtime'))
from lupa.lua51 import LuaRuntime

lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute('''
package.path = ... .. '/scripts/?.lua;' .. package.path
TUNING={TOTAL_DAY_TIME=480}; FOODTYPE={VEGGIE='VEGGIE',MEAT='MEAT'}
''', ROOT.as_posix())
lua.execute('''
local foods=require('ttk_luoshen_fooddefs')
local veg,meat=foods.ttk_luoshen_qingshu,foods.ttk_luoxiang_pengrou
assert(veg.test(nil,{ttk_luoshen_huayin=1},{}))
assert(not meat.test(nil,{ttk_luoshen_huayin=1},{}))
assert(not veg.test(nil,{ttk_luoshen_huayin=1},{meat=1}))
assert(meat.test(nil,{ttk_luoshen_huayin=1},{meat=1}))
assert(not veg.test(nil,{},{}))
assert(not meat.test(nil,{},{meat=1}))
assert(veg.health==200 and veg.hunger==42.5 and veg.sanity==80)
assert(meat.health==10 and meat.hunger==75 and meat.sanity==62.5)
assert(veg.perishtime==7200 and meat.perishtime==9600)
assert(veg.priority==10 and meat.priority==10)
GLOBAL=_G; PrefabFiles={}; Assets={}; STRINGS={NAMES={},CHARACTERS={GENERIC={DESCRIBE={}}}}
function Asset(...) return {...} end
registered={}; ingredients={}
function RegisterInventoryItemAtlas() end
function AddIngredientValues(names,tags) ingredients[names[1]]=tags end
function AddCookerRecipe(cooker,recipe) registered[cooker]=registered[cooker] or {}; registered[cooker][recipe.name]=recipe end
''')
lua.execute((ROOT / 'main/ttk_luoshen_food.lua').read_text(encoding='utf-8'))
lua.execute('''
assert(ingredients.ttk_luoshen_huayin.inedible==1)
for _,cooker in ipairs({'cookpot','portablecookpot','archive_cookpot'}) do
 assert(registered[cooker].ttk_luoshen_qingshu and registered[cooker].ttk_luoxiang_pengrou)
end
''')
assert 'main/ttk_luoshen_food.lua' in (ROOT / 'modmain.lua').read_text(encoding='utf-8')
lua.globals().MODROOT = ROOT.as_posix()
lua.execute((ROOT / 'tests/test_luoshen.lua').read_text(encoding='utf-8'))
for path in ROOT.rglob('*.lua'):
    lua.execute('assert(loadstring(...))', path.read_text(encoding='utf-8-sig'))
print('PASS: Lua syntax, recipe selection, nutrition, freshness, ingredient/cooker registration')

# Reuse the bottle suite's real DST finiteuses component and test its plant adapter.
bottle_lua = runpy.run_path(str(ROOT / 'tools/test_chuongthienbinh.py'))['lua']
bottle_lua.execute('''
TheWorld.ismastersim=true; TheWorld.HasTag=function() return false end
local bottleinst=bottle.fn()
local flower=CreateEntity(); flower:AddTag('xd_ztpuseable')
flower.stage=1
function flower:use_ztp(item,doer)
 assert(item==bottleinst and doer==caster)
 if self.stage==5 then return false end
 self.stage=self.stage+1; return true
end
local uses=bottleinst.components.finiteuses
uses:SetUses(99)
assert(not bottleinst.components.spellcaster.spell(bottleinst,flower,nil,caster))
assert(uses:GetUses()==99 and flower.stage==1)
for stage=2,5 do
 uses:SetUses(200)
 assert(bottleinst.components.spellcaster.spell(bottleinst,flower,nil,caster))
 assert(uses:GetUses()==100 and flower.stage==stage)
end
assert(not bottleinst.components.spellcaster.spell(bottleinst,flower,nil,caster))
assert(uses:GetUses()==100)
''')
print('PASS: bottle-to-flower callback, 100-point cost, insufficient-charge and mature guards')
