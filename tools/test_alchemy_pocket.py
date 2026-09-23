"""Furnace pocket-token regression using installed DST Container admission."""
from pathlib import Path
from zipfile import ZipFile
import unittest

from lupa.lua51 import LuaRuntime

MOD = Path(__file__).resolve().parents[1]
GAME = next(Path("C:/Program Files (x86)/Steam/steamapps/common").glob("Don*/data/databundles/scripts.zip"))


class PocketAlchemy(unittest.TestCase):
    def setUp(self):
        self.lua = LuaRuntime(unpack_returned_tuples=True)
        self.lua.execute('package.path=... .. package.path', (MOD / 'scripts/?.lua').as_posix() + ';')
        self.lua.execute('''
            function Class(ctor) local c={}; c.__index=c
                return setmetatable(c,{__call=function(_,...) local s=setmetatable({},c); ctor(s,...); return s end}) end
            package.loaded.containers={}; package.loaded.equipslotutil={}; package.loaded["components/spdamageutil"]={}
            package.loaded.curse_monkey_util={docurse=function() end,uncurse=function() end}
            makereadonly=function() end; GetGameModeProperty=function() return false end
            TheWorld={ismastersim=true}; GetTime=function() return 100 end
        ''')
        with ZipFile(GAME) as archive:
            for module, name in [('container', 'NativeContainer'), ('inventory', 'NativeInventory'),
                                 ('curseditem', 'NativeCursedItem'), ('cursable', 'NativeCursable')]:
                self.lua.execute(name + '=(function() ' + archive.read('scripts/components/' + module + '.lua').decode() + ' end)()')
            self.assertIn('inst.components.inventoryitem.canonlygoinpocket = true', archive.read('scripts/prefabs/cursed_monkey_token.lua').decode())
        self.lua.execute('''
            function item(name,n)
                local i={prefab=name,valid=true,components={},removes=0,tags={}}
                function i:AddTag(tag) self.tags[tag]=true end
                function i:HasTag(tag) return self.tags[tag]==true end
                function i:ListenForEvent() end
                function i:StartUpdatingComponent() end
                function i:IsValid() return self.valid end
                function i:Remove()
                    self.removes=self.removes+1
                    if self.failremove then error("remove failed") end
                    local inv=self.components.inventoryitem
                    if inv.owner then
                        local c=inv.owner.components.container or inv.owner.components.inventory
                        c:RemoveItem(self,true)
                    end
                    self.valid=false
                    if self.failafterremove then error("removed then failed") end
                end
                function i:GetSaveRecord() return {prefab=self.prefab,amount=self.components.stackable:StackSize(),marker=self.marker} end
                i.components.stackable={n=n,StackSize=function(s) return s.n end,
                    SetStackSize=function(s,v) s.n=v; if i.failstack then i.failstack=false; error("stack failed") end end}
                i.components.inventoryitem={cangoincontainer=true,canonlygoinpocket=name=="cursed_monkey_token",
                    GetSlotNum=function() return nil end,OnRemoved=function(s) s.owner=nil end}
                if name=="cursed_monkey_token" then
                    i.components.curseditem=NativeCursedItem(i); i.components.curseditem.curse="MONKEY"
                end
                return i
            end
            function SpawnSaveRecord(record) local i=item(record.prefab,record.amount); i.marker=record.marker; return i end
            function SpawnPrefab(name) return item(name,1) end
            function owner(inventory)
                local p={components={},ListenForEvent=function() end,PushEvent=function() end}
                local c=inventory and setmetatable({itemslots={},equipslots={}},NativeInventory) or NativeContainer(p)
                c.inst=p; c.numslots=12; c.GetOverflowContainer=function() return nil end
                p.components[inventory and "inventory" or "container"]=c
                if inventory then p.components.cursable=NativeCursable(p) end
                local slots=inventory and c.itemslots or c.slots
                function c:GiveItem(i,slot)
                    slot=slot or #slots+1
                    assert(slots[slot]==nil,"rollback overwrote a slot")
                    slots[slot]=i; i.components.inventoryitem.owner=p
                    if i.components.curseditem then i.components.curseditem:Given(i,{owner=p}) end
                    return i
                end
                if not inventory then
                    function c:RemoveItem(i)
                        for slot,v in pairs(slots) do if v==i then slots[slot]=nil end end
                        i.components.inventoryitem:OnRemoved(); return i
                    end
                end
                function c:Close() if self.failclose then error("close failed") end end
                function p:IsValid() return true end
                function p:DoTaskInTime(_,fn)
                    if self.failschedule then error("schedule failed") end
                    self.task={fn=fn,Cancel=function(s) s.cancelled=true end}; return self.task
                end
                return p,c
            end
            function setup(n,stage)
                local p,inv=owner(true); local f,c=owner(false)
                local defs=require("alchemy/ttk_alchemy_defs"); local row=defs.GetCultivationStage(stage or 10)
                for _,v in ipairs(row.recipe.ingredients) do
                    if v.prefab~="cursed_monkey_token" then c:GiveItem(item(v.prefab,v.amount)) end
                end
                if n>0 then inv:GiveItem(item("cursed_monkey_token",n)) end
                local s=require("components/ttk_alchemy_station")(f)
                return p,inv,f,c,s,row.prefab
            end
            function count(c,name)
                local n=0; for _,i in pairs(c.itemslots or c.slots) do
                    if not name or i.prefab==name then assert(i:IsValid()); n=n+i.components.stackable:StackSize() end
                end; return n
            end
        ''')

    def test_native_admission_rejects_but_actor_pockets_start_and_reload_once(self):
        self.lua.execute('''
            local p,inv,f,c,s,output=setup(5)
            local token=inv.itemslots[1]
            assert(not c:CanTakeItemInSlot(token,1),"native token must never enter a container")
            assert(s:Start(p),"five actor-pocket tokens must start canonical stage 10")
            assert(count(inv)==0 and count(c)==0 and token.removes==1)
            assert(not s:Start(p) and token.removes==1)
            local saved=s:OnSave(); assert(saved.output==output and saved.remaining==180)
            s:OnLoad(saved); assert(s:Finish() and not s:Finish())
            assert(count(c,output)==1 and count(inv)==0 and token.removes==1)
            local cultivation=require("components/ttk_cultivation")(p)
            cultivation.stage=9
            assert(cultivation:Consume(output))
            for stage=11,15 do
                local a,b,d,e,station,pill=setup(0,stage)
                assert(station:Start(a) and station:Finish())
                assert(cultivation:Consume(pill),"later cultivation must remain possible")
            end
            assert(cultivation.stage==15)
        ''')

    def test_consumes_five_across_split_stacks_leaves_surplus_and_other_pockets(self):
        self.lua.execute('''
            local p,inv,f,c,s=setup(2)
            local a=inv.itemslots[1]; local b=item("cursed_monkey_token",6); inv:GiveItem(b)
            local other,otherinv=owner(true); otherinv:GiveItem(item("cursed_monkey_token",9))
            inv:GiveItem(item("twigs",7))
            assert(s:Start(p),"split actor stacks must count")
            assert(count(inv,"cursed_monkey_token")==3 and count(inv,"twigs")==7)
            assert(count(otherinv)==9 and count(c)==0)
        ''')

    def test_stage_ten_exact_recipe_still_requires_five_native_tokens(self):
        self.lua.execute('''
            local rules=require("alchemy/ttk_alchemy_rules")
            local ingredients={cursed_monkey_token=5,rabbitkingspear=1,voidcloth=8,ttk_lingshi3=1}
            local recipe,output=rules.FindExactRecipe(ingredients)
            assert(recipe and output=="xd_danyao_yx")
            ingredients.cursed_monkey_token=4; assert(rules.FindExactRecipe(ingredients)==nil)
            ingredients.cursed_monkey_token=6; assert(rules.FindExactRecipe(ingredients)==nil)
            ingredients.cursed_monkey_token=5; ingredients.twigs=1
            assert(rules.FindExactRecipe(ingredients)==nil)
        ''')

    def test_rejects_short_other_player_extra_container_and_wrong_pocket_inputs(self):
        self.lua.execute('''
            for _,mode in ipairs({"short","other","extra","wrong","client","busy","nilactor","container_token","foreign_owner","overflow"}) do
                local p,inv,f,c,s=setup(mode=="short" and 4 or 5)
                local actor=p
                if mode=="other" then actor=owner(true) end
                if mode=="extra" then c:GiveItem(item("twigs",1)) end
                if mode=="wrong" then
                    local first=c.slots[1]; c:RemoveItem(first); inv:GiveItem(first)
                end
                if mode=="client" then TheWorld.ismastersim=false end
                if mode=="busy" then s:OnLoad({output="xd_danyao_jq",remaining=10}) end
                if mode=="nilactor" then actor=nil end
                if mode=="container_token" then c:GiveItem(item("cursed_monkey_token",5)) end
                if mode=="foreign_owner" then inv.itemslots[1].components.inventoryitem.owner=owner(true) end
                if mode=="overflow" then
                    local token=inv.itemslots[1]; inv:RemoveItem(token,true)
                    inv.overflow={slots={token}}
                end
                local pockets,contents=count(inv),count(c)
                assert(not s:Start(actor),"unexpected start: "..mode)
                assert(count(inv)==pockets and count(c)==contents,"consumed invalid start: "..mode)
                TheWorld.ismastersim=true
            end
        ''')

    def test_failure_rolls_back_all_inputs_and_cancels_job(self):
        self.lua.execute('''
            for _,mode in ipairs({"schedule","close","remove","afterremove","partial"}) do
                local p,inv,f,c,s=setup(mode=="partial" and 8 or 5)
                local token=inv.itemslots[1]; token.marker="persisted-token-state"
                if mode=="schedule" then f.failschedule=true end
                if mode=="close" then c.failclose=true end
                if mode=="remove" then token.failremove=true end
                if mode=="afterremove" then token.failafterremove=true end
                if mode=="partial" then token.failstack=true end
                local pockets,contents=count(inv),count(c)
                assert(not s:Start(p),"failure must return false: "..mode)
                assert(count(inv)==pockets and count(c)==contents,"failed transaction lost ingredients: "..mode)
                assert(inv.itemslots[1].marker=="persisted-token-state")
                assert(not s:IsBusy() and s:OnSave()==nil)
                assert(f.task==nil or f.task.cancelled)
            end
        ''')

    def test_rollback_does_not_apply_native_monkey_curse_twice(self):
        self.lua.execute('''
            local p,inv,f,c,s=setup(5)
            assert(p.components.cursable.curses.MONKEY==5)
            inv.itemslots[1].failafterremove=true
            assert(not s:Start(p))
            assert(p.components.cursable.curses.MONKEY==5,"rollback applied native curse twice")
            local restored=inv.itemslots[1]
            assert(restored:HasTag("applied_curse") and restored.components.curseditem.cursed_target==p)
        ''')


if __name__ == '__main__':
    unittest.main()
