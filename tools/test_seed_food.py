"""Check edible seed prefabs and preserve the separate harvested herbs."""
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT.parents[1] / '.superpowers/chuongthienbinh-runtime'))
from lupa.lua51 import LuaRuntime

lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute("package.path = ... .. '/scripts/?.lua;' .. package.path", ROOT.as_posix())
lua.execute('''
function noop() end
function api() return setmetatable({}, {__index=function() return noop end}) end
function Asset() return {} end
function Prefab(name,fn) return {name=name,fn=fn} end
MakeInventoryPhysics=noop;MakeInventoryFloatable=noop;MakeHauntableLaunchAndPerish=noop
TheWorld={ismastersim=true}
FOODTYPE={SEEDS="SEEDS",GOODIES="GOODIES"}
TUNING={STACK_SIZE_SMALLITEM=40,TOTAL_DAY_TIME=480}
function CreateEntity()
 local e={entity=api(),AnimState=api(),components={},tags={}}
 function e:AddTag(t) self.tags[t]=true end
 function e:AddComponent(k)
  local c={};self.components[k]=c
  if k=="edible" then function c:SetOnEatenFn(fn) self.oneaten=fn end
  elseif k=="perishable" then c.SetPerishTime=noop;c.StartPerishing=noop end
 end
 return e
end
''')
prefabs = lua.execute((ROOT/'scripts/prefabs/ttk_herbs.lua').read_text(encoding='utf-8'))
factories = {p.name: p.fn for p in prefabs}
expected = {
    'hsc': (50, 0, 0), 'dms': (50, 0, 0),
    'qfx': (0, 50, 0), 'cyh': (0, 50, 0),
    'lmg': (0, 0, 50), 'yhh': (0, 0, 50),
}
for suffix, values in expected.items():
    item = factories[f'ttk_lc_{suffix}_seed']()
    food = item.components.edible
    actual = (food.healthvalue, food.hungervalue, food.sanityvalue)
    assert actual == values, (suffix, actual, values)
    assert food.oneaten is None and food.temperaturedelta is None, suffix
    assert item.ttk_lc_plant == f'ttk_plant_{suffix}', suffix
    assert item.tags.ttk_lc_seed and item.tags.ttk_ylxc_valid
# Editing seeds must not silently change the harvested items or their effects.
assert factories['ttk_lc_lmg']().components.edible.sanityvalue == -45
assert factories['ttk_lc_dms']().components.edible.oneaten is not None
lua.globals().TheWorld.ismastersim = False
assert factories['ttk_lc_hsc_seed']().components.edible is None
for path in [ROOT/'scripts/prefabs/ttk_herbs.lua', ROOT/'main/ttk_batch19_herbs.lua']:
    lua.execute('assert(loadstring(...))', path.read_text(encoding='utf-8-sig'))
print('PASS: six seeds, exactly two per stat, no eating side effects, planting and client behavior preserved.')
