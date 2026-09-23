"""Exercise shipped prefab tags against installed DST detector/water code (Lua 5.1).

Usage: python test_flingomatic.py [path/to/scripts.zip]
Requires lupa (pip install lupa).
"""
from pathlib import Path
import sys
import zipfile

from test_support import find_dst_root

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT.parents[1] / '.superpowers/vinhhang-runtime'))
from lupa.lua51 import LuaRuntime

GAME = (Path(sys.argv[1]) if len(sys.argv) > 1 and Path(sys.argv[1]).suffix.lower() == ".zip"
        else find_dst_root() / "data" / "databundles" / "scripts.zip")
BOOT = r'''
function noop() end
local dummy = setmetatable({}, {__index=function() return noop end})
function CreateEntity()
    local inst = {tags={}, components={}, entity=dummy, AnimState=dummy,
        MiniMapEntity=dummy, Transform={GetWorldPosition=function() return 0,0,0 end}}
    function inst:AddTag(t) self.tags[t]=true end
    function inst:HasTag(t) return self.tags[t] or false end
    function inst:AddComponent(t) self.components[t]={} end
    function inst:IsValid() return true end
    function inst:GetPosition() return {} end
    function inst:DoTaskInTime() return {Cancel=noop} end
    function inst:RemoveEventCallback() end
    return inst
end
function Class(ctor)
    local c={}; c.__index=c
    return setmetatable(c, {__call=function(_, ...)
        local o=setmetatable({},c); ctor(o,...); return o
    end})
end
function Asset() return {} end
function Prefab(name, fn) return {name=name, fn=fn} end
function MakePlacer() return {} end
function Vector3() return {} end
MakeObstaclePhysics=noop
package.preload.prefabutil=function() return {} end
TheWorld={ismastersim=false, components={}}
TUNING=setmetatable({}, {__index=function() return 1 end})
FRAMES=1/30
ttk_vhth_structureSize=1
ttk_vhth_structureSizeFirepit=1; ttk_vhth_structureSizeEndo=1; ttk_vhth_structureSizeEndoFirepit=1
ttk_vhth_structureSizeHeatStar=1; ttk_vhth_structureSizeIceStar=1
function table.contains(t,v) for _,x in ipairs(t) do if x==v then return true end end return false end
TheSim={FindEntities=function(_,x,y,z,r,must,exclude,oneof)
    local result={}
    for _,e in ipairs(entities) do
        local ok=true
        for _,t in ipairs(exclude or {}) do if e:HasTag(t) then ok=false end end
        for _,t in ipairs(must or {}) do if not e:HasTag(t) then ok=false end end
        if oneof then
            local found=false
            for _,t in ipairs(oneof) do if e:HasTag(t) then found=true end end
            ok=ok and found
        end
        if ok then table.insert(result,e) end
    end
    return result
end}
function ignite(inst)
    inst:AddTag('fire')
    inst.fuel=100
    inst.components.burnable={IsBurning=function() return inst.fuel>0 end,
        IsSmoldering=function() return false end,
        Extinguish=function() inst.fuel=0 end}
end
'''

with zipfile.ZipFile(GAME) as archive:
    detector = archive.read('scripts/components/firedetector.lua').decode()
    water = archive.read('scripts/components/wateryprotection.lua').decode()
    for name in ('deluxe_firepit', 'endo_firepit', 'heat_star', 'ice_star'):
        lua = LuaRuntime(unpack_returned_tuples=True)
        lua.execute(BOOT)
        prefab = lua.execute((ROOT / 'scripts/prefabs' / (name+'.lua')).read_text(encoding='utf-8'))
        lua.globals().camp = prefab[0]['fn']()
        lua.globals().Detector = lua.execute(detector)
        lua.globals().Water = lua.execute(water)
        scenarios = r'''
            ignite(camp)
            local other=CreateEntity(); ignite(other)
            entities={camp,other}
            local machine=CreateEntity()
            local d=Detector(machine)
            d.detectTask={}; d.onfindfire=function() end
            d:DetectFire()
            assert(not d.detectedItems[camp], 'Flingomatic targets mod campfire')
            assert(d.detectedItems[other], 'Flingomatic must still target ordinary fires')
            d.detectedItems={}; d.emergency=true
            d:DetectFire()
            assert(not d.detectedItems[camp], 'Emergency mode targets mod campfire')
            assert(d.detectedItems[other], 'Emergency mode must still target ordinary fires')
            for _, source in ipairs({'snowball','firesuppressor'}) do
                ignite(other)
                local w=Water({prefab=source})
                w:AddIgnoreTag('player'); w:AddIgnoreTag('shadow_fire')
                w:SpreadProtectionAtPoint(0,0,0)
                assert(camp.fuel==100, source..' splash extinguished the mod campfire')
                assert(other.fuel==0, source..' must still extinguish ordinary fires')
            end
            camp.components.burnable:Extinguish()
            assert(camp.fuel==0, 'Normal extinguish remains available')
        '''
        lua.execute(scenarios)
        lua.globals().prefab_name = name
        lua.execute('''
            GLOBAL=_G
            function AddPrefabPostInit(name, fn)
                if name==prefab_name then fn(camp) end
            end
        ''')
        lua.execute((ROOT/'main/ttk_smarter_flingomatic.lua').read_text(encoding='utf-8'))
        lua.execute(scenarios)
        print('Đạt:', name, ': chống dập lửa riêng và khi kết hợp máy phóng băng thông minh')

lua = LuaRuntime(unpack_returned_tuples=True)
for path in ROOT.rglob('*.lua'):
    lua.execute('assert(loadstring(...))', path.read_text(encoding='utf-8-sig'))
print('Đạt: toàn bộ mã Lua đúng cú pháp Lua 5.1')
