"""Kiểm tra đăng ký, cấu hình, tài nguyên và cú pháp phần Thần Hỏa."""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT.parents[1] / '.superpowers/vinhhang-runtime'))
from lupa.lua51 import LuaRuntime

module = ROOT / 'main/ttk_vinhhangthanhoa.lua'
assert module.is_file(), 'Chưa tích hợp mô-đun Vĩnh Hằng Thần Hỏa'
lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute((ROOT/'modinfo.lua').read_text(encoding='utf-8-sig'))
lua.execute('''
local function tree() return setmetatable({}, {__index=function(t,k)
    local v=tree(); rawset(t,k,v); return v end}) end
GLOBAL=_G; STRINGS=tree(); TECH=tree(); RECIPETABS={}
PrefabFiles={'existing_prefab'}; Assets={{'existing_asset'}}
configs={}; recipes={}; atlases={}
for _,v in ipairs(configuration_options) do
    assert(configs[v.name]==nil, 'Trùng cấu hình: '..v.name)
    configs[v.name]=v.default
end
function GetModConfigData(k) assert(configs[k]~=nil, 'Thiếu cấu hình: '..k); return configs[k] end
function Asset(kind,path) return {kind,path} end
function Ingredient(name,count) return {name,count} end
function AddMinimapAtlas(path) table.insert(atlases,path) end
function AddRecipe2(name,ingredients,tech,config,filters)
    assert(not recipes[name], 'Trùng công thức')
    recipes[name]={ingredients=ingredients,config=config}
end
''')
lua.execute(module.read_text(encoding='utf-8-sig'))
lua.execute('''
assert(PrefabFiles[1]=='existing_prefab' and Assets[1][1]=='existing_asset')
assert(#PrefabFiles==9 and #Assets==13)
for _,name in ipairs({'deluxe_firepit','endo_firepit','heat_star','ice_star'}) do
    assert(recipes[name] and #recipes[name].ingredients>=3, 'Thiếu công thức: '..name)
end
assert(maxFuel==nil and efficiency==nil, 'Rò rỉ biến cấu hình chung')
''')
for _, item in lua.globals().Assets.items():
    if item[1] != 'existing_asset':
        assert (ROOT/item[2]).is_file(), item[2]
for _, path in lua.globals().atlases.items():
    assert (ROOT/path).is_file(), path
for path in ROOT.rglob('*.lua'):
    lua.execute('assert(loadstring(...))',path.read_text(encoding='utf-8-sig'))
assert 'modimport("main/ttk_vinhhangthanhoa.lua")' in (ROOT/'modmain.lua').read_text(encoding='utf-8')
for path in [module, ROOT/'modinfo.lua']:
    assert not re.search('[\u0e00-\u0e7f]', path.read_text(encoding='utf-8-sig'))
print('Đạt: đăng ký 8 thực thể, 4 công thức, cấu hình riêng, tài nguyên và cú pháp Lua.')
