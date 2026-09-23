"""Rà soát độc lập cấu hình hạn chế, Lua, tài nguyên và phụ thuộc tĩnh."""
from pathlib import Path
import re
import sys
import xml.etree.ElementTree as ET
import zipfile

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parents[1]/'.superpowers/vinhhang-runtime'))
from lupa.lua51 import LuaRuntime
GAME=Path("C:/Program Files (x86)/Steam/steamapps/common/Don't Starve Together/data/databundles")
lua=LuaRuntime(unpack_returned_tuples=True)
metadata=(ROOT/'modinfo.lua').read_text(encoding='utf-8-sig')
env=lua.execute('local f=assert(loadstring(...)); local e={};setfenv(f,e);f();return e',metadata)
seen=set()
for _,option in env.configuration_options.items():
 assert option.name not in seen, 'Trùng cấu hình: '+option.name
 seen.add(option.name)
 assert any(item.data==option.default for _,item in option.options.items()), option.name
print('Đạt: modinfo nạp trong môi trường hạn chế của game,',len(seen),'cấu hình hợp lệ')

with zipfile.ZipFile(GAME/'scripts.zip') as archive:
 gamefiles=set(archive.namelist())
 sources={p:p.read_text(encoding='utf-8-sig') for p in ROOT.rglob('*.lua')}
 for p,s in sources.items():lua.execute('assert(loadstring(...))',s)
 missing=[]
 for p,s in sources.items():
  # Comment-only references are not runtime dependencies.
  s=re.sub(r'--\[\[.*?\]\]','',s,flags=re.S)
  s=re.sub(r'--[^\n]*','',s)
  for m in re.finditer(r'\brequire\s*\(?\s*["\']([^"\']+)["\']',s):
   rel='scripts/'+m[1].replace('.','/')+'.lua'
   if not (ROOT/rel).is_file() and rel not in gamefiles:missing.append((str(p.relative_to(ROOT)),rel))
  for m in re.finditer(r'modimport\s*\(?\s*["\']([^"\']+)["\']',s):
   if not (ROOT/m[1]).is_file():missing.append((str(p.relative_to(ROOT)),m[1]))
 assert not missing, missing
 print('Đạt:',len(sources),'tệp Lua; không thiếu require/modimport dạng tĩnh')

textures=0
for p in ROOT.rglob('*.xml'):
 tree=ET.parse(p)
 for texture in tree.iter('Texture'):
  name=texture.get('filename')
  assert (p.parent/name).is_file(),str(p)+': '+str(name)
  textures+=1
archives=0
for p in (ROOT/'anim').glob('*.zip'):
 with zipfile.ZipFile(p) as z: assert z.testzip() is None,p
 archives+=1
print('Đạt:',textures,'tham chiếu texture atlas;',archives,'gói hoạt ảnh không lỗi CRC')

for name in ('deluxe_firepit','endo_firepit','heat_star','ice_star'):
 s=(ROOT/'scripts/prefabs'/f'{name}.lua').read_text(encoding='utf-8')
 assert s.count('inst.entity:SetPristine()')==1,name
 assert s.index('inst.entity:SetPristine()') < s.index('if not TheWorld.ismastersim then'),name
print('Đạt: cả bốn bếp khởi tạo trạng thái mạng trước khi trả về máy khách')
