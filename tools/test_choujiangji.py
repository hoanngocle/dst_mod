"""Lua 5.1 regression checks: payment gate, payout locking and save/resume."""
from pathlib import Path
from zipfile import ZipFile
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT.parents[1] / '.superpowers/luoshen-runtime'))
from lupa.lua51 import LuaRuntime

assert (ROOT / 'scripts/components/ttk_slotmachine.lua').exists(), 'Slot machine has not been ported'
lua = LuaRuntime(unpack_returned_tuples=True)
with ZipFile("C:/Program Files (x86)/Steam/steamapps/common/Don't Starve Together/data/databundles/scripts.zip") as archive:
    lua.execute(archive.read('scripts/class.lua').decode())
lua.execute("package.path = ... .. '/scripts/?.lua;' .. package.path", ROOT.as_posix())
lua.execute(r'''
TheWorld={ismastersim=true}
local actor={userid='paid-player',IsValid=function() return true end,HasTag=function(_,tag) return tag=='player' end,
    PushEvent=function() end}
AllPlayers={actor}
local Slot = require('components/ttk_slotmachine')
local function machine()
    local inst = {events={}, tasks={}, delivered={}}
    function inst:PushEvent(name, data)
        -- StateGraphInstance:PushEvent writes data.state; strings crash the real engine.
        assert(data == nil or type(data)=='table', 'Stategraph event data must be a table')
        self.events[#self.events+1]=name
    end
    function inst:DoTaskInTime(delay, fn)
        local task={fn=fn}; function task:Cancel() self.cancelled=true end
        self.tasks[#self.tasks+1]=task; return task
    end
    function inst:DispensePrize(name) self.delivered[#self.delivered+1]=name; return {prefab=name} end
    function inst:step()
        local t=table.remove(self.tasks,1)
        if t and not t.cancelled then t.fn(self) end
    end
    inst.components={ttk_slotmachine=Slot(inst)}
    return inst, inst.components.ttk_slotmachine
end
local inst, slot = machine()
assert(slot:CanAccept({prefab='ttk_lingshi2'}))
for _,name in ipairs({'ttk_lingshi1','ttk_lingshi3','ttk_lingshi4','goldnugget','xd_lingshi2'}) do
    assert(not slot:CanAccept({prefab=name}),name)
end
assert(not slot:CanAccept(nil))
slot:Start({category='ok',items={{prefab='goldnugget',count=3},{prefab='footballhat',count=1}}},actor)
assert(not slot:CanAccept({prefab='ttk_lingshi2'}))
assert(not slot:Start({category='good',items={{prefab='krampus_sack',count=1}}}))
local before=slot:OnSave()
assert(before and #inst.delivered==0)
slot:Pay()
inst:step()
assert(#inst.delivered==1 and slot.busy)
slot:Pay() -- duplicate animation callbacks must not create duplicate delivery tasks
local saved=slot:OnSave()
local restored, resumed=machine()
resumed:OnLoad(saved)
assert(resumed.busy)
for i=1,10 do restored:step() end
assert(#restored.delivered==3, 'Save/load must dispense only remaining items')
assert(restored.delivered[3]=='footballhat')
assert(not resumed.busy and resumed:OnSave().queue==nil and resumed:OnSave().sequence==1)
for i=1,10 do inst:step() end
assert(#inst.delivered==4, 'Repeated Pay must not duplicate a bundle')
local fresh, pending=machine(); pending:OnLoad(before)
for i=1,10 do fresh:step() end
assert(#fresh.delivered==4, 'Saving during spin must preserve the whole reward')

local prizes=require('ttk_slot_prizes')
local sawmod=false
for category,group in pairs(prizes.groups) do
    assert(group.weight>0 and #group.bundles>0)
    for _,bundle in ipairs(group.bundles) do
        local seen={}
        for _,item in ipairs(bundle.items) do
            assert(not seen[item.prefab], 'Repeated item in a bundle: '..item.prefab)
            seen[item.prefab]=true
            assert(not item.prefab:match('^xd_') or item.prefab=='xd_dy_cyfxd_1', 'Unported original prefab: '..item.prefab)
            assert(item.prefab~='panflute', 'User excluded the Pan Flute')
            assert(item.prefab~='armorwood' and item.prefab~='goldenpickaxe' and item.prefab~='meatballs',
                'Low-value starter rewards must be replaced with TTK items')
            assert(item.count>=1 and item.count==math.floor(item.count))
            if item.kind=='equipment' then assert(item.count==1,item.prefab) end
            if item.prefab=='vanhonphien' then sawmod=true end
        end
    end
end
assert(sawmod, 'Rare rewards should include an available Tu Tien Ky artifact')
local available={goldnugget=true,footballhat=true}
for i=1,20 do
    local prize=prizes.Pick(available)
    if prize then for _,item in ipairs(prize.items) do assert(available[item.prefab]) end end
end
assert(prizes.Pick({})==nil, 'No chargeable spin when no complete reward can spawn')
local bosses=require('ttk_slot_bosses')
local klaus={prefab='klaus',components={health={},knownlocations={RememberLocation=function(self,key,pos) self.pos=pos end}}}
function klaus:AddComponent(name) self.components[name]={} end
function klaus:SpawnDeer() self.deer=true end
local pos={x=1,z=2}
bosses.Prepare(klaus,pos)
assert(klaus.deer and klaus.components.knownlocations.pos==pos and klaus.components.ttk_slot_spawned)
local hook
bosses.Install({GLOBAL={},AddStategraphPostInit=function(name,fn) hook=fn end,
    AddPrefabPostInit=function() end})
local natural=0
local state={states={death={events={animover={fn=function() natural=natural+1 end}}}}}
hook(state)
state.states.death.events.animover.fn({components={}})
assert(natural==1, 'Natural boss death must keep its original handler')
local crown=0
local summoned={components={ttk_slot_spawned={},lootdropper={SpawnLootPrefab=function(_,name) assert(name=='alterguardianhat');crown=crown+1 end}}}
function summoned:Remove() self.removed=true end
state.states.death.events.animover.fn(summoned)
assert(summoned.removed and crown==1 and natural==1, 'Summoned champion must drop crown, not spawn its world-event orb')
''')
print('PASS: payment eligibility, payout locking, save/resume, no duplicate equipment, valid prize selection')
