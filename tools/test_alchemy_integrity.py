"""Execute the pill/furnace factory and verify its declared on-disk presentation."""
from pathlib import Path
import struct
import unittest
import xml.etree.ElementTree as ET
from zipfile import ZipFile

from lupa.lua51 import LuaRuntime

MOD = Path(__file__).resolve().parents[1]


def animation_clips(data):
    """Read ANIM v4 records and their bank hash dictionary."""
    pos = 24
    def read(fmt):
        nonlocal pos
        value = struct.unpack_from('<' + fmt, data, pos)
        pos += struct.calcsize('<' + fmt)
        return value
    def string():
        nonlocal pos
        size, = read('I')
        value = data[pos:pos + size].decode()
        pos += size
        return value
    assert data[:8] == b'ANIM\x04\x00\x00\x00'
    clips = []
    for _ in range(struct.unpack_from('<I', data, 20)[0]):
        name = string()
        _, bank, _, frames = read('BIfI')
        for _ in range(frames):
            read('ffff')
            for _ in range(read('I')[0]): read('I')
            for _ in range(read('I')[0]): read('IIIfffffff')
        clips.append((bank, name))
    names = {}
    for _ in range(read('I')[0]):
        key, = read('I')
        names[key] = string()
    assert pos == len(data)
    return {(names[bank], name) for bank, name in clips}


class AlchemyIntegrity(unittest.TestCase):
    def setUp(self):
        self.lua = LuaRuntime(unpack_returned_tuples=True)
        self.lua.execute('package.path=... .. package.path', (MOD / 'scripts/?.lua').as_posix() + ';')
        self.lua.execute('''
            GLOBAL=_G; TheWorld={ismastersim=true}; FOODTYPE={GOODIES="GOODIES"}
            ACTIONS={HAMMER={}}; Assets={}; mappings={}; factories={}
            function Class(ctor) local c={}; c.__index=c
                return setmetatable(c,{__call=function(_,...) local s=setmetatable({},c); ctor(s,...); return s end}) end
            function Asset(kind,path) return {kind=kind,path=path} end
            function Prefab(name,fn,assets) local p={name=name,fn=fn,assets=assets}; factories[name]=p; return p end
            function MakePlacer() end
            function MakeInventoryPhysics() end; function MakeObstaclePhysics() end; function MakeHauntableWork() end
            function GetTime() return 0 end
            function CreateEntity()
                local i={components={},removed=false,tasks={}}
                i.entity={AddTransform=function() end,AddAnimState=function() end,AddNetwork=function() end,
                    AddSoundEmitter=function() end,SetPristine=function() end}
                i.Transform={GetWorldPosition=function() return 10,0,20 end,SetPosition=function() end}
                i.AnimState={SetBank=function(s,v) s.bank=v end,SetBuild=function(s,v) s.build=v end,
                    PlayAnimation=function(s,v) s.animation=v end}
                function i:AddTag() end
                function i:Remove()
                    self.removed=true
                    if self.components.ttk_alchemy_station then self.components.ttk_alchemy_station:OnRemoveFromEntity() end
                end
                function i:DoTaskInTime(_,fn)
                    local t={fn=fn,Cancel=function(s) s.cancelled=true end}; self.tasks[#self.tasks+1]=t; return t
                end
                function i:AddComponent(name)
                    local c={}; self.components[name]=c
                    if name=="container" then
                        c.slots={}; c.drops=0
                        c.WidgetSetup=function() end; c.Open=function() return true end
                        c.DropEverything=function(s)
                            assert(not i.removed,"drop must happen before entity removal")
                            s.drops=s.drops+1
                            for slot,item in pairs(s.slots) do item.recovered=(item.recovered or 0)+1; s.slots[slot]=nil end
                        end
                        c.GiveItem=function(s,item) s.slots[#s.slots+1]=item; return true end
                    elseif name=="ttk_alchemy_station" then self.components[name]=require("components/ttk_alchemy_station")(self)
                    elseif name=="workable" then
                        c.SetWorkAction=function() end; c.SetWorkLeft=function(s,n) s.left=n end
                        c.SetOnWorkCallback=function(s,fn) s.hit=fn end
                        c.SetOnFinishCallback=function(s,fn) s.finish=fn end
                    elseif name=="edible" then c.SetOnEatenFn=function() end end
                end
                return i
            end
            function SpawnPrefab(name) local i=CreateEntity(); i.prefab=name; return i end
            package.loaded.containers={params={}}
            Vector3=function() return {} end; Ingredient=function() return {} end
            STRINGS={NAMES={},RECIPE_DESC={},ACTIONS={},CHARACTERS={GENERIC={DESCRIBE={}}}}
            TECH={SCIENCE_TWO={}}; AddRecipe2=function() end; Action=function(v) return v end
            AddAction=function() end; AddComponentAction=function() end; AddComponentPostInit=function() end
            ActionHandler=function() end; AddStategraphActionHandler=function() end; AddPlayerPostInit=function() end
            RegisterInventoryItemAtlas=function(atlas,image) mappings[image]=atlas end
        ''')
        self.lua.execute((MOD / 'scripts/prefabs/ttk_alchemy.lua').read_text(encoding='utf-8'))
        self.lua.execute((MOD / 'main/ttk_alchemy.lua').read_text(encoding='utf-8'))

    def test_idle_hammer_recovers_each_deposit_and_uncollected_output_once(self):
        self.lua.execute('''
            local f=factories.xd_liandanlu.fn(); local c=f.components.container
            local herb={prefab="spidergland"}; local stone={prefab="ttk_lingshi1"}
            c.slots={herb,stone}
            f.components.workable.finish(f)
            assert(herb.recovered==1 and stone.recovered==1,"idle hammer lost deposited ingredients")
            assert(f.removed and next(c.slots)==nil and c.drops==1)
            f=factories.xd_liandanlu.fn(); c=f.components.container
            local s=f.components.ttk_alchemy_station
            s:OnLoad({output="xd_danyao_jq",remaining=0}); assert(s:Finish())
            local pill=c.slots[1]; assert(pill.prefab=="xd_danyao_jq")
            f.components.workable.finish(f)
            assert(pill.recovered==1 and f.removed and c.drops==1,"finished pill lost or duplicated")
            assert(not s:Finish())
        ''')

    def test_busy_hammer_preserves_contents_timer_and_single_finished_output(self):
        self.lua.execute('''
            local f=factories.xd_liandanlu.fn(); local c=f.components.container
            local extra={prefab="twigs"}; c.slots={extra}
            local s=f.components.ttk_alchemy_station
            s:OnLoad({output="xd_danyao_jq",remaining=90}); local task=s.finish_task
            f.components.workable.hit(f); f.components.workable.finish(f)
            assert(not f.removed and c.slots[1]==extra and extra.recovered==nil and c.drops==0)
            assert(s:IsBusy() and s.finish_task==task and not task.cancelled and f.components.workable.left==3)
            task.fn(); assert(not s:IsBusy() and #c.slots==2)
            local pill=c.slots[2]; assert(pill.prefab=="xd_danyao_jq" and not s:Finish())
            f.components.workable.finish(f)
            assert(extra.recovered==1 and pill.recovered==1 and c.drops==1)
        ''')

    def test_every_pill_declares_valid_animation_icon_and_catalog_name(self):
        rows = self.lua.eval('require("alchemy/ttk_alchemy_defs").by_prefab')
        self.assertEqual(len(list(rows)), 26)
        g = self.lua.globals()
        for prefab, row in rows.items():
            with self.subTest(prefab=prefab):
                factory = g.factories[prefab]
                inst = factory.fn()
                self.assertEqual(g.STRINGS.NAMES[prefab.upper()], row.name)
                self.assertTrue(row.name and 'Nhất Phẩm' not in row.name)
                self.assertIsNotNone(factory.assets, 'pill has no declared visual assets')
                assets = {(a.kind, a.path) for a in factory.assets.values()}
                for _, path in assets: self.assertTrue((MOD / path).is_file(), path)
                clips, builds = set(), set()
                for kind, path in assets:
                    if kind == 'ANIM':
                        with ZipFile(MOD / path) as archive:
                            self.assertIsNone(archive.testzip())
                            clips.update(animation_clips(archive.read('anim.bin')))
                            build = archive.read('build.bin')
                            size = struct.unpack_from('<I', build, 16)[0]
                            builds.add(build[20:20+size].decode())
                            self.assertIn('atlas-0.tex', archive.namelist())
                self.assertIn((inst.AnimState.bank, inst.AnimState.animation), clips)
                self.assertIn(inst.AnimState.build, builds)
                inventory = inst.components.inventoryitem
                self.assertTrue(inventory.atlasname and inventory.imagename, 'nil inventory presentation')
                atlas, image = inventory.atlasname, inventory.imagename + '.tex'
                self.assertEqual(g.mappings[image], atlas)
                self.assertIn(('ATLAS', atlas), assets)
                xml = ET.parse(MOD / atlas).getroot()
                self.assertIn(image, [e.attrib['name'] for e in xml.findall('./Elements/Element')])
                texture = (Path(atlas).parent / xml.find('Texture').attrib['filename']).as_posix()
                self.assertIn(('IMAGE', texture), assets)
                self.assertTrue((MOD / texture).is_file())
                g.TheWorld.ismastersim = False
                client = factory.fn()
                g.TheWorld.ismastersim = True
                self.assertIn((client.AnimState.bank, client.AnimState.animation), clips)


if __name__ == '__main__':
    unittest.main()
