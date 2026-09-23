"""Kiểm tra tích hợp túi 45 ô bằng Lua 5.1 và mã game đang cài."""
from pathlib import Path
import sys
import zipfile

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parents[1]/'.superpowers/vinhhang-runtime'))
from lupa.lua51 import LuaRuntime

module=ROOT/'main/ttk_inventory45.lua'
assert module.is_file(), 'Chưa có phần tích hợp túi 45 ô'
with zipfile.ZipFile("C:/Program Files (x86)/Steam/steamapps/common/Don't Starve Together/data/databundles/scripts.zip") as z:
    classified=z.read('scripts/prefabs/inventory_classified.lua').decode()
    inv_source=z.read('scripts/components/inventory.lua').decode()
    replica_source=z.read('scripts/components/inventory_replica.lua').decode()
    slotutil=z.read('scripts/equipslotutil.lua').decode()

for size in (45,):
 for extras in (True,):
  lua=LuaRuntime(unpack_returned_tuples=True)
  lua.globals().size=size; lua.globals().extras=extras
  lua.execute(r'''
GLOBAL=_G; Assets={}; EQUIPSLOTS={HANDS='hands',BODY='body',HEAD='head',BEARD='beard',MODDED='modded'}
TheNet={GetServerGameMode=function() return 'survival' end, IsDedicated=function() return true end}
TheWorld={ismastersim=false}
function GetMaxItemSlots(mode) return mode=='quagmire' and 0 or 15 end
function Asset(a,b) return {a,b} end
function GetModConfigData(k) error('Inventory must not read removed config: '..k) end

hooks={}; classes={}
function AddPrefabPostInit(k,fn) hooks[k]=hooks[k] or {}; table.insert(hooks[k],fn) end
function AddComponentPostInit(k,fn) classes[k]=fn end
function AddStategraphPostInit() end
function AddClassPostConstruct() end
function modimport() end
function Class(ctor,base,props)
 local c={_ctor=ctor}; c.__index=c
 return setmetatable(c,{__call=function(_,...) local o=setmetatable({},c); ctor(o,...);return o end})
end
function noop() end
function CreateEntity()
 local e={GUID=1, components={}, replica={}, entity={AddNetwork=noop,AddTransform=noop,Hide=noop,SetPristine=noop}}
 function e:AddTag() end; function e:DoStaticTaskInTime() end
 function e:ListenForEvent() end
 return e
end
function Prefab(n,fn) return {fn=fn} end
function net_entity() local v; return {value=function() return v end,set=function(_,x) v=x end} end
net_bool=net_entity
SourceModifierList=setmetatable({}, {__call=function() return {} end})
function makereadonly() end
package.preload['equipslotutil']=function() return {} end
package.preload['components/spdamageutil']=function() return {} end
package.preload['util/sourcemodifierlist']=function() return {} end
''')
  lua.execute(module.read_text(encoding='utf-8'))
  lua.execute('assert(GetMaxItemSlots("survival")==size); assert(GetMaxItemSlots("quagmire")==0); assert(EQUIPSLOTS.MODDED=="modded")')
  lua.globals().Inventory=lua.execute(inv_source)
  lua.globals().Replica=lua.execute(replica_source)
  lua.execute('''
   local p=CreateEntity();p.replica.inventory={}
   inv=Inventory(p); p.components.inventory=inv
   if classes.inventory then classes.inventory(inv) end
   assert(inv:GetNumSlots()==size)
   assert(inv.ignorespoverflow==false and inv.opencontainerproxies~=nil)
   local remote=CreateEntity(); local r=Replica(remote)
   assert(r:GetNumSlots()==size)
  ''')
  prefab=lua.execute(classified)
  lua.globals().MakeNet=prefab['fn']
  lua.globals().netinv=prefab['fn']()
  lua.execute('''
   for _,fn in ipairs(hooks.inventory_classified or {}) do fn(netinv) end
   assert(#netinv._items==size)
   local item={prefab='log',replica={stackable={StackSize=function() return 1 end}},HasTag=function() return false end}
   netinv._items[size]:set(item)
   assert(netinv:GetItemInSlot(size)==item)
   local has,count=netinv:Has('log',1,false); assert(has and count==1)
   if extras then
     local bag={Has=function() return true,3 end}
     local bagitem={replica={container=bag}}
     netinv._equips.back:set(bagitem)
     assert(netinv:GetOverflowContainer()==bag)
     local has,count=netinv:Has('log',4,false); assert(has and count==4)
     netinv.ignoreoverflow=true; assert(netinv:GetOverflowContainer()==nil)
     netinv.ignoreoverflow=false
     local serverbag={canbeopened=true}
     inv.equipslots.back={components={container=serverbag}}
     assert(inv:GetOverflowContainer()==serverbag)
   end
   local second=MakeNet()
   for _,fn in ipairs(hooks.inventory_classified or {}) do fn(second) end
   assert(#second._items==size and second:GetOverflowContainer()==nil)
   TheWorld.ismastersim=true
   local server=MakeNet()
   assert(#server._items==size and server._equips.back and server._equips.neck)
   for name,slot in pairs({backpack='back',amulet='neck'}) do
       local item={components={equippable={equipslot='body'}}}
       for _,fn in ipairs(hooks[name]) do fn(item) end
       assert(item.components.equippable.equipslot==slot)
   end
  ''')
  print('Đạt:',size,'ô; ô trang bị riêng:',extras,'; máy chủ, máy khách và nguyên liệu trong ba lô')

lua=LuaRuntime(unpack_returned_tuples=True)
layout=lua.execute((ROOT/'scripts/ttk_inventory45_layout.lua').read_text(encoding='utf-8'))
for size in (25,45):
 for first in (False,True):
  for spacing in (7,15):
   seen=set()
   for i in range(1,size+1):
    x,y=layout['Slot'](size,i,first,spacing)
    assert (x,y) not in seen
    seen.add((x,y))
   assert len(seen)==size
print('Đạt: bố cục 25/45 ô, hai thứ tự nhặt đồ, hai khoảng cách, không trùng ô')
lua.globals().layout=layout
lua.execute(r'''
GLOBAL=_G; EQUIPSLOTS={HANDS='hands',BODY='body',HEAD='head',BACK='back',NECK='neck'}
TheNet={GetServerGameMode=function() return 'survival' end}
function GetModConfigData(k) error('Inventory UI must not read removed config: '..k) end
function widget()
 local w={}
 function w:SetPosition(x,y,z) self.x=x;self.y=y end
 function w:GetPosition() return {x=self.x,y=self.y} end
 function w:AddChild(c) return c end
 function w:Hide() self.hidden=true end
 function w:SetScale() end; function w:SetVRegPoint() end;function w:MoveToBack() end
 return w
end
package.preload['widgets/image']=function() return function() return widget() end end
package.preload['ttk_inventory45_layout']=function() return layout end
function AddClassPostConstruct(_,fn) install=fn end
''')
lua.execute((ROOT/'main/ttk_inventory45_ui.lua').read_text(encoding='utf-8'))
lua.execute(r'''
for _,size in ipairs({15,25,45}) do
 for _,backpacksize in ipairs({0,8,40}) do
  local self={owner={replica={inventory={GetNumSlots=function() return size end}}},
      equipslotinfo={{slot='hands'},{slot='body'},{slot='head'}},root=widget(),bg=widget(),
      bgcover=widget(),hudcompass=widget(),hand_inv=widget(),openhint=widget(),
      actionstring=widget(),toprow=widget(),bottomrow=widget(),inspectcontrol=widget()}
  function self:AddEquipSlot(slot) table.insert(self.equipslotinfo,{slot=slot}) end
  function self:UpdateCursor() self.cursor_updated=true end
  function self:Rebuild()
   self.inv={};self.equip={};self.backpackinv={}
   for i=1,size do self.inv[i]=widget() end
   for _,v in ipairs(self.equipslotinfo) do self.equip[v.slot]=widget() end
   for i=1,backpacksize do self.backpackinv[i]=widget() end
   self.backpack=backpacksize>0 and {} or nil;self.integrated_backpack=backpacksize>0
  end
  function self:RefreshIntegratedContainer() self.refreshed=true end
  local original_action=self.actionstring
  install(self);self:Rebuild();self:RefreshIntegratedContainer()
  assert(#self.equipslotinfo==5 and #self.inv==size and #self.backpackinv==backpacksize)
  assert(self.actionstring==original_action and self.refreshed)
  if size>15 then
   assert(self.cursor_updated and self.bg.hidden)
   local used={}
   for _,slot in ipairs(self.inv) do
    local key=slot.x..':'..slot.y;assert(not used[key]);used[key]=true
   end
   for _,slot in pairs(self.equip) do
    assert(not used[slot.x..':'..slot.y], 'Trang bị chồng lên ô túi')
   end
  end
 end
end
''')
print('Đạt: giao diện thêm đúng ô trang bị, ba lô 8/40 ô, giữ chức năng giao diện gốc')
for path in ROOT.rglob('*.lua'):
 lua.execute('assert(loadstring(...))',path.read_text(encoding='utf-8-sig'))
print('Đạt: cú pháp toàn bộ Lua')
meta=LuaRuntime(unpack_returned_tuples=True)
meta.execute((ROOT/'modinfo.lua').read_text(encoding='utf-8-sig'))
opts={v.name:v.default for _,v in meta.globals().configuration_options.items()}
assert not any(name.startswith('ttk_inv45_') for name in opts)
assert 'ttk_inv45_extras' not in opts and 'MOREEQUIPSLOTS' not in opts
main=(ROOT/'modmain.lua').read_text(encoding='utf-8-sig')
assert main.index('modimport("main/ttk_inventory45.lua")') < main.index('modimport"main/lucmachthankiem.lua"')
print('Đạt: mặc định 45 ô, trang bị luôn bật và đúng thứ tự nạp')
