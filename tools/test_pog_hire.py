"""Exercise the real hire/save callbacks without loading the mob's rendering engine."""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[3] / '.superpowers/luoshen-runtime'))
from lupa.lua51 import LuaRuntime
root = Path(__file__).resolve().parents[1]
source = (root / 'scripts/prefabs/ttk_pog.lua').read_text(encoding='utf-8')
lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute('assert(loadstring(...))', source)
callbacks = source[source.index('local function OnGetItemFromPlayer'):source.index('local function OnRefuseItem')]
callbacks += source[source.index('local function OnSave'):source.index('local function fn()')]
lua.execute('''
houseutil={SetOwner=function(i,g) i.owner=g end,SaveOwner=function() end,LoadOwner=function() end}
'''+callbacks+'''
hire=OnGetItemFromPlayer; save=OnSave; load=OnLoad
''')
lua.execute('''
local function mob()
 return {meat_count=0,preparedfood_count=0,PushEvent=function() end,
 components={timer={StopTimer=function() end,StartTimer=function(s,n,t) s.remaining=t end},
 lootdropper={SetChanceLootTable=function() end}}}
end
local meat={prefab='meat',HasTag=function() return false end}
local dish={prefab='meatballs',HasTag=function(_,t) return t=='preparedfood' end}
local a=mob()
for i=1,9 do hire(a,'owner',meat); assert(not a._ttk_tamed) end
local data={}; save(a,data); a=mob(); load(a,data)
hire(a,'owner',meat); assert(a._ttk_tamed and a.components.timer.remaining==2400 and a.meat_count==0)
local b=mob()
for i=1,4 do hire(b,'owner',dish); assert(not b._ttk_tamed) end
data={};save(b,data);b=mob();load(b,data)
hire(b,'owner',dish);assert(b._ttk_tamed and b.components.timer.remaining==2400 and b.preparedfood_count==0)
b.components.timer.remaining=50
for i=1,4 do hire(b,'owner',dish);assert(b.components.timer.remaining==50) end
hire(b,'owner',dish);assert(b.components.timer.remaining==2400)
local old=mob();load(old,{meat_count=1});assert(old.preparedfood_count==0 and old.meat_count==1)
local empty=mob();load(empty,nil);assert(empty.preparedfood_count==0 and empty.meat_count==0)
''')
print('PASS: 10 raw meats / 5 meat dishes, 2400s hire, partial payment save/load, old saves and renewal')
