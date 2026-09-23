"""Execute installed achievement adapters and native action/plant/cook code in Lua 5.1."""
from pathlib import Path
from zipfile import ZipFile
import unittest
from lupa.lua51 import LuaRuntime

MOD = Path(__file__).resolve().parents[1]
GAME = Path("C:/Program Files (x86)/Steam/steamapps/common/Don't Starve Together/data/databundles/scripts.zip")


class ActivityReachability(unittest.TestCase):
    def setUp(self):
        self.lua = LuaRuntime(unpack_returned_tuples=True)
        self.lua.execute("package.path = ... .. package.path", (MOD / "scripts/?.lua").as_posix() + ";")
        self.lua.execute('''
            GLOBAL=_G; env={}; modname="test"; hooks={}; prefab_hooks={}; AllPlayers={}
            TheWorld={ismastersim=true,state={season="autumn",cycles=0,elapseddaysinseason=0,isnight=false,isday=true},
                Map={GetTileAtPoint=function(_,x) return x == 1 and 10 or 0 end}}
            WORLD_TILES={FARMING_SOIL=10}; TUNING={BASE_COOK_TIME=10}
            function Class(ctor) local c={}; c.__index=c
                return setmetatable(c,{__call=function(_,...) local s=setmetatable({},c); ctor(s,...); return s end}) end
            function AddReplicableComponent() end
            function AddPlayerPostInit(fn) player_init=fn end
            function AddComponentPostInit(name,fn) hooks[name]=fn end
            function AddPrefabPostInit(name,fn) prefab_hooks[name]=fn end
            rpc={}; function AddModRPCHandler(_,name,fn) rpc[name]=fn end
            function modimport() end
            function net_string() return {set=function() end} end
            function GetTime() return 0 end
            function FunctionOrValue(v,...) if type(v)=="function" then return v(...) end return v end
            package.loaded["achievement/ttk_perk_effects"]={Install=function() end,Apply=function() end}
            package.loaded.cooking={CalculateRecipe=function() return "meatballs",1 end,
                GetRecipe=function() return {perishtime=100} end}
            math.randomseed(18092026)
            function entity(prefab)
                local e={prefab=prefab,components={},events={},watch={},tasks={},tags={},valid=true,Transform={SetPosition=function() end}}
                function e:IsValid() return self.valid end
                function e:HasTag(t) return self.tags[t] == true end
                function e:AddTag(t) self.tags[t]=true end
                function e:RemoveTag(t) self.tags[t]=nil end
                function e:Remove() self.valid=false end
                function e:OnUsedAsItem() end
                function e:GetPosition() return {Get=function() return 1,0,0 end} end
                function e:ListenForEvent(n,fn) self.events[n]=self.events[n] or {}; table.insert(self.events[n],fn) end
                function e:PushEvent(n,d) for _,fn in ipairs(self.events[n] or {}) do fn(self,d) end end
                function e:WatchWorldState(n,fn) self.watch[n]=self.watch[n] or {}; table.insert(self.watch[n],fn) end
                function e:DoTaskInTime(t,fn,...)
                    local args={...}; local task={cancel=false,time=t}
                    function task:Cancel() self.cancel=true end
                    task.run=function() if not task.cancel then fn(self,unpack(args)) end end
                    table.insert(self.tasks,task); return task
                end
                function e:flush()
                    local tasks=self.tasks; self.tasks={}
                    for _,t in ipairs(tasks) do if t.time==0 then t.run() else table.insert(self.tasks,t) end end
                end
                return e
            end
            function SpawnPrefab(p) return entity(p) end
            function TheWorld:PushEvent() end
            local Progress=require("components/ttk_achievement_progress")
            function player(id,setup,defer)
                local p=entity("wilson"); p.userid=id; p.player_classified={}; p.tags.player=true
                p.components.health={IsDead=function() return p.dead == true end}
                p.components.temperature={current=20,overheattemp=70,IsFreezing=function(s) return s.current<0 end,
                    IsOverheating=function(s) return s.current>s.overheattemp end}
                p.components.inventory={itemslots={},equipslots={},GetOverflowContainer=function(s) return s.overflow end}
                p.components.ttk_achievement_progress=Progress(p)
                if setup then setup(p) end
                table.insert(AllPlayers,p); player_init(p); if not defer then p:flush() end; return p
            end
            function progress(p,id) local s=p.components.ttk_achievement_progress.core.achievements[id]; return s and s.progress or 0 end
            function world(n,v)
                TheWorld.state[n]=v
                for _,p in ipairs(AllPlayers) do for _,fn in ipairs(p.watch[n] or {}) do fn(p,v) end end
            end
            function temp(p,v) p.components.temperature.current=v; p:PushEvent("temperaturedelta",{new=999}) end
            function item(p,prefab,size)
                local i=entity(prefab); i.components.inventoryitem={inst=i,GetGrandOwner=function() return i.owner end}; i.owner=p
                i.components.stackable={inst=i,size=size,StackSize=function(s) return s.size end,Get=function() end,Put=function() end}
                hooks.inventoryitem(i.components.inventoryitem); hooks.stackable(i.components.stackable); return i
            end
        ''')
        with ZipFile(GAME) as archive:
            for name, var in (("bufferedaction", "NativeAction"), ("components/farmplantable", "Plantable"), ("components/stewer", "Stewer")):
                self.lua.execute(var + " = (function() " + archive.read("scripts/" + name + ".lua").decode() + " end)()")
        self.lua.execute((MOD / "main/ttk_achievement.lua").read_text(encoding="utf-8"))
        if getattr(self, "audit_routes", False):
            self.lua.execute('''
                audit_hits={}
                local catalog=require("achievement/ttk_achievement_catalog")
                local core=require("achievement/ttk_achievement_core")
                local advance=core.Advance
                function core:Advance(id,amount,evidence)
                    -- Observe the real route; do not replace its authority guard.
                    assert(TheWorld.ismastersim==true,id.." routed client evidence")
                    local before=self.achievements[id]
                    local value=before and before.progress or 0
                    local accepted,result=advance(self,id,amount,evidence)
                    local after=self.achievements[id]
                    if after and after.progress>value then audit_hits[catalog.ById(id).tracker]=true end
                    return accepted,result
                end
            ''')

    def test_pick_regrowth_fish_identity_and_two_actors(self):
        self.lua.execute('''
            a=player("a"); b=player("b"); bush=entity("grass"); d={object=bush}
            a:PushEvent("picksomething",d); a:PushEvent("picksomething",d)
            assert(progress(a,"labor_pick_grass")==1,"missing committed pick route")
            a:PushEvent("picksomething",{object=bush}); b:PushEvent("picksomething",{object=bush})
            assert(progress(a,"labor_pick_grass")==2 and progress(b,"labor_pick_grass")==1)
            f=entity("fish"); a:PushEvent("fishingcatch",{fish=f}); a:PushEvent("fishingcollect",{})
            a:PushEvent("fishingcollect",{fish=entity("oceanfish_small_1_inv")})
            assert(progress(a,"labor_fish_pond")==0)
            a:PushEvent("fishingcollect",{fish=f}); a:PushEvent("fishingcollect",{fish=f})
            a:PushEvent("fishingcollect",{fish=entity("eel")})
            assert(progress(a,"labor_fish_pond")==2 and progress(b,"labor_fish_pond")==0)
        ''')

    def test_native_plant_success_failure_and_explicit_map(self):
        self.lua.execute('''
            a=player("a"); b=player("b"); soil=entity("farm_soil"); soil.tags.soil=true
            function plant(seed,doer,target)
                local i=entity(seed); local c=Plantable(i); c.plant="farm_plant_carrot"; if hooks.farmplantable then hooks.farmplantable(c) end
                return c:Plant(target,doer)
            end
            assert(plant("carrot_seeds",a,entity("ground"))==false)
            assert(progress(a,"farming_plant_carrot")==0)
            assert(plant("carrot_seeds",a,soil)); assert(progress(a,"farming_plant_carrot")==1,"missing plant receipt")
            plant("invented_seeds",a,soil); plant("seeds",b,soil)
            assert(progress(a,"farming_plant_carrot")==1 and progress(b,"labor_plant_seeds")==1)
            for _,crop in ipairs({"pumpkin","eggplant","dragonfruit","asparagus","tomato","potato","garlic","onion","pepper","pomegranate"}) do
                plant(crop.."_seeds",a,soil); assert(progress(a,"farming_plant_"..crop)==1,crop)
            end
        ''')

    def test_native_success_callbacks_reject_failed_canceled_and_nonfarm(self):
        self.lua.execute('''
            a=player("a"); b=player("b"); farm=entity("farm_plant_carrot"); farm.tags.farm_plant=true
            function action(id,target,x,success,doer,inv)
                local act=setmetatable({doer=doer or a,target=target,invobject=inv,onsuccess={},onfail={},
                    action={id=id,fn=function() return success end}}, {__index=BufferedAction})
                function act:IsValid() return true end
                function act:GetActionPoint() return {Get=function() return x or 0,0,0 end} end
                a:PushEvent("performaction",{action=act}); a:PushEvent("performaction",{action=act}); return act
            end
            action("POUR_WATER",farm,0,false):Do()
            action("POUR_WATER",farm,0,true):Fail()
            action("POUR_WATER",entity("campfire"),1,true):Do()
            action("POUR_WATER_GROUNDTILE",nil,0,true):Do()
            action("POUR_WATER",farm,0,true,b):Do()
            assert(progress(a,"farming_water_plants")==0)
            action("POUR_WATER",farm,0,true):Do()
            action("POUR_WATER_GROUNDTILE",nil,1,true):Do()
            assert(progress(a,"farming_water_plants")==2,"missing farm success receipt")
            local manure=entity("poop"); manure.components.fertilizer={nutrients={1,1,1}}
            function manure:OnUsedAsItem() end
            action("DEPLOY",nil,0,true,a,manure):Do()
            action("DEPLOY_TILEARRIVE",nil,0,true,a,manure):Do()
            action("DEPLOY_TILEARRIVE",nil,1,false,a,manure):Do()
            action("DEPLOY_TILEARRIVE",nil,1,true,a,manure):Fail()
            action("DEPLOY_TILEARRIVE",nil,1,true,b,manure):Do()
            action("DEPLOY_TILEARRIVE",nil,1,true,a,entity("sapling")):Do()
            action("DEPLOY",nil,1,true,a,entity("sapling")):Do()
            action("FERTILIZE",entity("campfire"),1,true,a,manure):Do()
            assert(progress(a,"farming_fertilize_plants")==0)
            action("DEPLOY",nil,1,true,a,manure):Do()
            action("FERTILIZE",farm,0,true,a,manure):Do()
            assert(progress(a,"farming_fertilize_plants")==2)
            -- Native tile_deploy fertilizer uses this action ID on farming soil.
            action("DEPLOY_TILEARRIVE",nil,1,true,a,manure):Do()
            assert(progress(a,"farming_fertilize_plants")==3,"native tile fertilizer must credit its committing actor once")
            assert(progress(b,"farming_fertilize_plants")==0)
            a:PushEvent("tilling"); assert(progress(a,"farming_till_soil")==1)
        ''')

    def test_inventory_observes_partial_amount_overflow_and_transfers(self):
        self.lua.execute('''
            a=player("a"); b=player("b"); i=item(a,"ttk_lingshi4",4)
            a.components.inventory.itemslots[1]=i; a:PushEvent("itemget",{item=i}); a:flush()
            assert(progress(a,"collection_lingshi4")==4,"ownership must observe four, not jump to target")
            i.components.stackable.size=8; i:PushEvent("stacksizechange"); a:flush()
            assert(progress(a,"collection_lingshi4")==8)
            a.components.inventory.itemslots={}; i.owner=b; b.components.inventory.itemslots[1]=i
            a:PushEvent("itemlose",{prev_item=i}); b:PushEvent("itemget",{item=i}); a:flush(); b:flush()
            assert(progress(a,"collection_lingshi4")==8 and progress(b,"collection_lingshi4")==8)
            a.components.inventory.itemslots[1]=item(a,"ttk_lingshi4",3); a:PushEvent("itemget",{item=a.components.inventory.itemslots[1]}); a:flush()
            assert(progress(a,"collection_lingshi4")==8,"transfers must not accumulate ownership")
            a.components.inventory.overflow={slots={item(a,"ttk_lingshi4",90)}}
            a:PushEvent("equip"); a:flush(); assert(progress(a,"collection_lingshi4")==93)
            a.components.inventory.opencontainers={slots={item(a,"ttk_lingshi4",1000)}}
            a:PushEvent("itemlose"); a:flush(); assert(progress(a,"collection_lingshi4")==93)
            a.components.inventory.overflow.slots[1].components.stackable.size=97
            a.components.inventory.overflow.slots[1]:PushEvent("stacksizechange"); a:flush()
            assert(progress(a,"collection_lingshi4")==100)
        ''')

    def test_dropped_and_removed_items_do_not_retain_former_players(self):
        self.lua.execute('''
            kept_items={}; former_players=setmetatable({}, {__mode="v"})
            for index,event in ipairs({"ondropped","onremove"}) do
                local owner=player("owner_"..event)
                local held=item(owner,"ttk_lingshi4",4)
                kept_items[index]=held; former_players[index]=owner
                owner.components.inventory.itemslots[1]=held
                held:PushEvent("onputininventory"); owner:flush()
                assert(progress(owner,"collection_lingshi4")==4)
                held.owner=nil; owner.components.inventory.itemslots={}
                held:PushEvent(event)
                assert(owner._ttk_ownership_pending,"item lifecycle must still queue former-owner observation")
                owner:flush()
                assert(not owner._ttk_ownership_pending)
                assert(progress(owner,"collection_lingshi4")==4,"loss must preserve observed high-water progress")
            end
            AllPlayers={}
            collectgarbage("collect"); collectgarbage("collect")
            assert(former_players[1]==nil,"a surviving dropped item must not retain its former player")
            assert(former_players[2]==nil,"a referenced removed item must not retain its former player")
        ''')

    def test_native_cook_commit_chef_save_load_and_callback_preservation(self):
        self.lua.execute('''
            a=player("a"); b=player("b"); callbacks=0
            function pot(saved)
                local p=entity("cookpot")
                p.components.container={slots={},Close=function() end,DestroyContents=function() end}
                local s=Stewer(p); p.components.stewer=s
                if hooks.stewer then hooks.stewer(s) end
                s.ondonecooking=function() callbacks=callbacks+1 end
                if prefab_hooks.cookpot then prefab_hooks.cookpot(p) end
                if saved then s:OnLoad(saved) end
                return p,s
            end
            p,s=pot(); s:StartCooking(a)
            local saved=s:OnSave(); p,s=pot(saved)
            s.task.run()
            assert(progress(a,"labor_cook_meals")==0,"ondonecooking precedes done; award must defer")
            p:flush(); assert(progress(a,"labor_cook_meals")==1,"missing committed chef receipt")
            assert(callbacks==1 and progress(b,"labor_cook_meals")==0)
            s.ondonecooking(p); p:flush(); assert(progress(a,"labor_cook_meals")==1)
            saved=s:OnSave(); q,t=pot(saved); t.ondonecooking(q); q:flush()
            assert(progress(a,"labor_cook_meals")==1,"completed load must not award again")
            s.product=nil; s.done=nil; s.targettime=nil; s:StartCooking(b)
            s.task.run(); p:flush(); assert(progress(b,"labor_cook_meals")==1)
        ''')

    def test_all_survival_keys_in_solo_authoritative_state(self):
        self.lua.execute('''
            a=player("solo")
            for _,season in ipairs({"winter","spring","summer","autumn"}) do world("season",season); a:flush() end
            for _,season in ipairs({"autumn","winter","spring","summer"}) do assert(progress(a,"survive_"..season)==1,"season "..season) end
            for i=1,100 do world("cycles",i); world("cycles",i) end
            assert(progress(a,"survive_hundred_days")==100 and progress(a,"survive_rescue_friend")==30)
            world("isnight",true); world("isnight",false)
            assert(progress(a,"survive_night")==0)
            world("isday",true); assert(progress(a,"survive_night")==1)
            temp(a,75); assert(progress(a,"survive_heat")==0); temp(a,20)
            temp(a,-5); assert(progress(a,"survive_cold")==0); temp(a,20)
            assert(progress(a,"survive_heat")==1 and progress(a,"survive_cold")==1)
            a.dead=true; a:PushEvent("death"); a:PushEvent("ms_respawnedfromghost")
            assert(progress(a,"survive_revive")==0)
            a.dead=false; a:PushEvent("ms_respawnedfromghost"); assert(progress(a,"survive_revive")==1)
        ''')

    def test_death_reload_and_client_cannot_fabricate_receipts(self):
        self.lua.execute('''
            a=player("solo"); temp(a,80); world("isnight",true)
            a.dead=true; a:PushEvent("death"); temp(a,20); world("isday",true); world("cycles",1); world("season","winter")
            for _,id in ipairs({"heat","night","hundred_days","autumn"}) do assert(progress(a,"survive_"..id)==0,id) end
            a.dead=false; a:PushEvent("ms_respawnedfromghost"); world("cycles",2)
            assert(progress(a,"survive_hundred_days")==1)
            TheWorld.ismastersim=false; b=player("client")
            assert(b._ttk_achievement_installed==nil)
            a:PushEvent("picksomething",{object=entity("grass")}); a:PushEvent("fishingcollect",{fish=entity("fish")})
            temp(a,-10); temp(a,20); world("cycles",3)
            assert(progress(a,"labor_pick_grass")==0 and progress(a,"labor_fish_pond")==0 and progress(a,"survive_cold")==0)
        ''')

    def test_reload_baselines_inventory_day_night_temperature_and_ghost(self):
        self.lua.execute('''
            TheWorld.state.cycles=50; TheWorld.state.isnight=true; TheWorld.state.isday=false
            a=player("loaded",function(p)
                p.components.inventory.itemslots[1]=item(p,"ttk_lingshi3",17)
                p.components.inventory.overflow={slots={item(p,"ttk_lingshi3",23)}}
                p.components.temperature.current=80
            end)
            assert(progress(a,"collection_lingshi3")==40,"post-load ownership must count actual contents")
            assert(progress(a,"survive_hundred_days")==0 and progress(a,"survive_autumn")==0)
            world("cycles",50); world("isday",true); temp(a,20)
            assert(progress(a,"survive_hundred_days")==0 and progress(a,"survive_night")==0 and progress(a,"survive_heat")==0)
            world("cycles",51); world("isnight",false); world("isday",false); world("isnight",true); world("isday",true)
            temp(a,80); temp(a,20)
            assert(progress(a,"survive_hundred_days")==1 and progress(a,"survive_night")==1 and progress(a,"survive_heat")==1)
            b=player("ghost",function(p) p.tags.playerghost=true; p.dead=true end)
            b.tags.playerghost=nil; b.dead=false; b:PushEvent("ms_respawnedfromghost")
            assert(progress(b,"survive_revive")==1,"loaded ghost must use real respawn receipt")
            b:PushEvent("ms_respawnedfromghost"); assert(progress(b,"survive_revive")==1)
        ''')

    def test_every_new_component_route_is_master_only(self):
        self.lua.execute('''
            a=player("a"); TheWorld.ismastersim=false
            local seed=entity("carrot_seeds"); local c=Plantable(seed); c.plant="farm_plant_carrot"
            local old=c.Plant; hooks.farmplantable(c); assert(c.Plant==old)
            local soil=entity("soil"); soil.tags.soil=true; c:Plant(soil,a)
            assert(progress(a,"farming_plant_carrot")==0)
            local p=entity("cookpot"); local s=Stewer(p); old=s.StartCooking
            hooks.stewer(s); assert(s.StartCooking==old)
            assert(progress(a,"labor_cook_meals")==0)
            local i=item(a,"ttk_lingshi4",100); a.components.inventory.itemslots[1]=i
            a:PushEvent("itemget",{item=i}); a:flush(); assert(progress(a,"collection_lingshi4")==0)
            a:PushEvent("tilling"); assert(progress(a,"farming_till_soil")==0)
        ''')

    def test_late_ghost_load_and_overflow_loss_receipts(self):
        self.lua.execute('''
            a=player("loaded",nil,true); a.tags.playerghost=true; a.dead=true; a:flush()
            a.tags.playerghost=nil; a.dead=false; a:PushEvent("ms_respawnedfromghost")
            assert(progress(a,"survive_revive")==1,"ghost restoration occurs after player postinit")
            local bag=item(a,"backpack",1); bag.components.container={inst=bag,slots={}}
            a.components.inventory.overflow=bag.components.container
            if hooks.container then hooks.container(bag.components.container) end
            -- An overflow receipt schedules observation of the committed slots.
            bag.components.container.slots[1]=item(a,"ttk_lingshi4",9)
            bag:PushEvent("itemget",{item=bag.components.container.slots[1]}); a:flush()
            assert(progress(a,"collection_lingshi4")==9,"overflow receipt must observe its owner's inventory")
            bag.components.container.slots={}; bag:PushEvent("itemlose")
            assert(a._ttk_ownership_pending,"overflow loss must schedule recomputation")
            a:flush(); assert(progress(a,"collection_lingshi4")==9)
        ''')

    def test_cook_save_and_harvest_before_deferred_receipt(self):
        self.lua.execute('''
            a=player("chef"); b=player("harvester")
            local p=entity("cookpot"); p.components.container={slots={},Close=function() end,DestroyContents=function() end}
            local s=Stewer(p); p.components.stewer=s; hooks.stewer(s)
            s:StartCooking(a); local first=s.task
            s:StartCooking(b); assert(s.task==first,"native rejects a second start")
            first.run(); local saved=s:OnSave()
            assert(progress(a,"labor_cook_meals")==1 and saved.ttk_achievement_cook_awarded)
            p:flush(); assert(progress(a,"labor_cook_meals")==1 and progress(b,"labor_cook_meals")==0)
            s.product=nil; s.done=nil; s.targettime=nil; s:StartCooking(a); s:StopCooking(); p:flush()
            assert(progress(a,"labor_cook_meals")==1,"canceled cooking must not count")
            s:StartCooking(a); s.task.run()
            -- Native Harvest gives the item to the harvester, who is not the chef.
            b.components.inventory.GiveItem=function() end
            s:Harvest(b); p:flush()
            assert(progress(a,"labor_cook_meals")==2 and progress(b,"labor_cook_meals")==0)
        ''')


class StrengthenSlotReachability(unittest.TestCase):
    def setUp(self):
        ActivityReachability.setUp(self)
        self.lua.globals().MOD_PATH = MOD.as_posix()
        self.lua.execute('''
            TheNet={Announce=function() end}; TheWorld.components={}; TheWorld.ismastershard=true
            function TheWorld:HasTag(t) return t=="forest" end
            local S=require("components/wb_strengthen")
            function strengthen(level,category)
                local i=entity("test_equipment"); i.components[category or "weapon"]={}
                local s=setmetatable({inst=i,level=level,do_mode="strengthen",original_name="Test",
                    buffs_status={},prize_buff_list={},manual_buff_list={}}, {__index=S})
                function s:Refresh() end
                i.components.wb_strengthen=s; return s
            end
            function actor(id)
                local p=player(id); p.name=id; p.components.talker={Say=function() end}
                p.components.inventory.stock={wb_enhancegem=100}
                function p.components.inventory:Has(n,c) return (self.stock[n] or 0)>=c end
                function p.components.inventory:ConsumeByName(n,c) self.stock[n]=self.stock[n]-c end
                function p.components.inventory:GiveItem() end
                return p
            end
            function machine()
                local i=entity("ttk_choujiangji"); i.GUID=123
                i.Transform.GetWorldPosition=function() return 0,0,0 end
                i.SoundEmitter={PlaySound=function() end}
                i.components.ttk_slotmachine=require("components/ttk_slotmachine")(i)
                function i:DispensePrize(n) local e=entity(n); return e end
                return i,i.components.ttk_slotmachine
            end
        ''')
        source = (MOD / "main/ttk_solo_source.lua").read_text(encoding="utf-8")
        block = source[source.index('nfcufCiki(\n    "hh_lo_ren",\n    "strengthen",'):]
        block = block[:block.index('AddPrefabPostInit("dragonfly"')]
        self.lua.execute('function nfcufCiki(_,_,fn) forge=fn end\n' + block)

    def test_gem_commit_and_success_threshold_wildcard(self):
        self.lua.execute('''
            local a=actor("a"); local b=actor("b"); local s=strengthen(2)
            local station=entity("hh_lo_ren"); station.components.container={openlist={[a]=true},GetItemInSlot=function() return s.inst end}
            station.UpdateContainerData=function() end; a.GetDistanceSqToInst=function() return 0 end
            forge(b,station,s.inst); assert(progress(b,"enhancement_bag_one")==0)
            a.components.inventory.stock.wb_enhancegem=0; forge(a,station,s.inst)
            assert(progress(a,"enhancement_bag_one")==0)
            a.components.inventory.stock.wb_enhancegem=100
            s.GetProbability=function() return 0 end; forge(a,station,s.inst)
            assert(progress(a,"enhancement_bag_one")==3,"committed failed attempt spends gems")
            assert(progress(a,"enhancement_relic_two")==0)
            s.GetProbability=function() return 1 end; forge(a,station,s.inst)
            assert(progress(a,"enhancement_bag_one")==6)
            assert(progress(a,"enhancement_weapon_two")==3,"one committed +3 completes the threshold")
            assert(progress(a,"enhancement_armor_two")==0)
            assert(progress(a,"enhancement_relic_two")==1,"any is a wildcard")
            assert(progress(a,"enhancement_relic_one")==1,"unavailable clear row must use first success")
            s:DoSuccess(a,"strengthen",6); assert(progress(a,"enhancement_weapon_three")==6)
            local armor=strengthen(0,"armor"); armor:DoSuccess(b,"strengthen",6)
            assert(progress(b,"enhancement_armor_three")==6 and progress(b,"enhancement_weapon_three")==0)
            s:SetLevel(0); s:OnLoad({level=6}); assert(progress(a,"enhancement_relic_two")==2)
            TheWorld.ismastersim=false; forge(a,station,s.inst); s:DoSuccess(a,"strengthen",7)
            assert(progress(a,"enhancement_relic_two")==2 and progress(a,"enhancement_bag_one")==6)
        ''')

    def test_slot_actor_save_load_repeat_payout_failed_spawn_and_classification(self):
        self.lua.execute('''
            local a=actor("a"); local b=actor("b"); local i,s=machine()
            assert(not s:Start(nil,a)); assert(progress(a,"gacha_shop_spin_ten")==0)
            assert(s:Start({category="good",items={{prefab="xd_dy_cyfxd_1",count=1},{prefab="ttk_spider_leg",count=1}}},a))
            assert(not s:Start({items={}},b)); assert(progress(a,"gacha_shop_spin_ten")==1 and progress(b,"gacha_shop_spin_ten")==0)
            local saved=s:OnSave(); assert(saved.actor_id=="a" and saved.receipt_id,"job must persist actor and receipt")
            local j,t=machine(); t:OnLoad(saved); t.task.run()
            assert(progress(a,"gacha_shop_buy_pill")==1 and progress(b,"gacha_shop_buy_pill")==0)
            local saved2=t:OnSave(); local k,u=machine(); u:OnLoad(saved2)
            local task=u.task; task.run(); task.run(); u:Pay()
            assert(progress(a,"gacha_shop_buy_material")==1 and progress(a,"gacha_shop_spin_ten")==1)
            assert(not u.busy)
            assert(u:Start({items={{prefab="krampus_sack",count=1}}},b))
            function k:DispensePrize() return nil end
            u:Pay(); u.task.run(); assert(progress(b,"gacha_shop_buy_relic")==0)
            function k:DispensePrize() return entity("ttk_lingshi2") end
            u:Pay(); if u.task then u.task.run() end
            assert(progress(b,"gacha_shop_buy_relic")==0,"requested rare is not received fallback")
            assert(progress(b,"gacha_shop_buy_lingshi")==1,"failed spawn remains pending; fallback uses actual prefab")
            TheWorld.ismastersim=false
            assert(not u:Start({items={{prefab="krampus_sack",count=1}}},a))
        ''')

    def test_real_prize_data_and_restock_committed_actor(self):
        GuildDungeonReachability.setUp(self)
        self.lua.execute('''
            local prizes=require("ttk_slot_prizes"); local pill=false
            for _,g in pairs(prizes.groups) do for _,b in ipairs(g.bundles) do for _,i in ipairs(b.items) do
                if i.prefab=="xd_dy_cyfxd_1" then pill=true end
            end end end
            assert(pill,"real pool must contain first grade buff pill")
            assert(prizes.Classify("xd_dy_cyfxd_1")=="pill")
            assert(prizes.Classify("krampus_sack")=="rare")
            assert(prizes.Classify("ttk_spider_leg")=="material")
            assert(prizes.Classify("good")==nil and prizes.Classify("beequeen")~="rare")
            local a=player("a"); local b=player("b")
            local shop=require("components/hh_dungeon_shop")(TheWorld); TheWorld.components.hh_dungeon_shop=shop
            shop:EnsureCycle(); for _,id in ipairs(shop.active) do shop.stock[id]=1 end
            local E=require("components/hh_dungeon_effects"); local effects=setmetatable({inst=a},{__index=E})
            assert(not effects:UseUtility("dq_stock_token")); assert(progress(a,"gacha_shop_shop_refresh")==0)
            shop.stock[shop.active[1]]=0; assert(effects:UseUtility("dq_stock_token"))
            assert(progress(a,"gacha_shop_shop_refresh")==1 and progress(b,"gacha_shop_shop_refresh")==0)
            shop.stock[shop.active[1]]=0; effects.inst=b; TheWorld.ismastersim=false
            assert(not effects:UseUtility("dq_stock_token")); assert(shop.stock[shop.active[1]]==0)
        ''')

    def test_protection_consumption_branches(self):
        source = (MOD / "main/ttk_solo_source.lua").read_text(encoding="utf-8")
        block = source[source.index('            self["DoFail"] ='):source.index('            self["GetProbability"] =', source.index('            self["DoFail"] ='))]
        self.lua.execute('ffiUgCiKi=require("util/wb_util"); function protect(self) ' + block + ' end')
        self.lua.execute('''
            local paper="wb_strengthen_strengthen_protectpaper"
            for _,case in ipairs({{9,true,true,1},{9,true,false,1},{5,true,false,0},{9,false,true,0},{0,true,true,0}}) do
                local a=actor("p"..#AllPlayers); local s=strengthen(case[1]); protect(s)
                a.components.inventory.stock[paper]=case[2] and 1 or 0
                a.components.inventory.stock.nn_magicpaper=case[3] and 1 or 0
                s:DoFail(a,"strengthen",case[1]+1,function() end)
                assert(progress(a,"enhancement_bag_two")==case[4],"only consumed protection counts")
                assert(a.components.inventory.stock[paper]==(case[2] and 1 or 0)-case[4])
            end
        ''')

    def test_level_paper_compatible_incompatible_return_and_zero(self):
        self.lua.execute('''
            function Asset() end; TUNING.SMALL_FUEL=1
            function Prefab(n,fn) return {name=n,fn=fn} end
            function MakeInventoryPhysics() end; function MakeInventoryFloatable() end; function MakeHauntableLaunch() end
            function CreateEntity()
                local i=entity("paper_bundle"); local noop=function() end
                i.entity={AddTransform=noop,AddAnimState=noop,AddNetwork=noop,SetPristine=noop}
                function i:AddComponent(n) self.components[n]={} end
                return i
            end
            papers={dofile(MOD_PATH.."/scripts/prefabs/wb_strengthen_levelpaper.lua")}
            function wrap(a,s,level)
                a.components.bundler={bundlinginst={mode="strengthen",level=level},itemprefab="wb_strengthen_strengthen_"..level.."_levelpaper"}
                local bundle=papers[2].fn(); bundle.components.unwrappable:WrapItems({s.inst},a)
            end
            local a=actor("a"); local s=strengthen(4)
            wrap(a,s,6); assert(s.level==4 and progress(a,"enhancement_ring_one")==0)
            s:SetLevel(5); wrap(a,s,6); assert(s.level==6 and progress(a,"enhancement_ring_one")==1,"compatible paper commits")
            assert(progress(a,"enhancement_relic_two")==0,"scroll is not a DoSuccess")
            local b=actor("b"); local v=strengthen(8); wrap(b,v,9)
            assert(v.level==9 and progress(b,"enhancement_ring_two")==1)
            wrap(b,v,0); assert(v.level==0 and progress(b,"enhancement_relic_one")==0)
            local c=actor("c"); local incompatible={inst=entity("twigs")}
            wrap(c,incompatible,6); assert(progress(c,"enhancement_ring_one")==0)
            local d=actor("d"); local wrong=strengthen(5); wrong.do_mode="other"
            wrap(d,wrong,6); assert(wrong.level==5 and progress(d,"enhancement_ring_one")==0)
        ''')

    def test_real_slot_accept_and_dispense_fallback(self):
        source = (MOD / "scripts/prefabs/ttk_choujiangji.lua").read_text(encoding="utf-8")
        start = source.index('local function DispensePrize(')
        stop = source.index('local function OnHammered(')
        self.lua.execute('local prizes=require("ttk_slot_prizes"); local bosses={}; ' + source[start:stop] + '\nSlotAccept=OnAccept; SlotDispense=DispensePrize')
        self.lua.execute('''
            PI=math.pi
            function SpawnPrefab(n)
                if n=="krampus_sack" or all_fail then return nil end
                local e=entity(n); e.components.inventoryitem={}; return e
            end
            local a=actor("a"); local b=actor("b"); local i,s=machine(); i.DispensePrize=SlotDispense
            local prize={category="good",items={{prefab="krampus_sack",count=1}}}
            i.pendingprize=prize; SlotAccept(i,a,entity("twigs"))
            assert(not s.busy and progress(a,"gacha_shop_spin_ten")==0)
            i.pendingprize=prize; SlotAccept(i,b,entity("ttk_lingshi2")); s:Pay(); s.task.run()
            assert(progress(b,"gacha_shop_spin_ten")==1 and progress(a,"gacha_shop_spin_ten")==0)
            assert(progress(b,"gacha_shop_buy_lingshi")==1 and progress(b,"gacha_shop_buy_relic")==0)
            all_fail=true; i.pendingprize=prize; SlotAccept(i,a,entity("ttk_lingshi2")); s:Pay(); s.task.run()
            assert(progress(a,"gacha_shop_buy_lingshi")==0 and progress(a,"gacha_shop_buy_relic")==0)
        ''')

    def test_native_trader_failed_payment_and_consumed_currency_before_spin(self):
        with ZipFile(GAME) as archive:
            self.lua.execute('Trader=(function() ' + archive.read('scripts/components/trader.lua').decode() + ' end)()')
        source = (MOD / "scripts/prefabs/ttk_choujiangji.lua").read_text(encoding="utf-8")
        block = source[source.index('local function ShouldAccept('):source.index('local function OnHammered(')]
        self.lua.execute('local prizes=require("ttk_slot_prizes"); ' + block + '\nSlotAccept=OnAccept; SlotTest=ShouldAccept')
        self.lua.execute('''
            Prefabs={krampus_sack=true,ttk_luoshen_qingshu=true}
            local a=actor("a"); local b=actor("b"); local i,s=machine(); local trader=Trader(i)
            trader.test=SlotTest; trader.onaccept=SlotAccept
            local coin=entity("ttk_lingshi2")
            coin.components.inventoryitem={RemoveFromOwner=function() coin.detached=true end}
            trader:Disable(); assert(not trader:AcceptGift(a,coin)); trader:Enable()
            assert(not trader:AcceptGift(a,entity("twigs")))
            assert(coin.valid and not coin.detached and progress(a,"gacha_shop_spin_ten")==0)
            a:ListenForEvent("ttk_slot_spin_committed",function() assert(not coin.valid and coin.detached) end)
            assert(trader:AcceptGift(a,coin)); assert(progress(a,"gacha_shop_spin_ten")==1)
            assert(not trader:AcceptGift(b,entity("ttk_lingshi2")))
            s:Pay(); s.task.run(); assert(progress(a,"gacha_shop_buy_relic")==1)
            assert(progress(b,"gacha_shop_spin_ten")==0)
        ''')

    def test_every_active_task17_tracker_rejects_client_receipts(self):
        self.lua.execute('''
            local a=actor("a"); TheWorld.ismastersim=false
            a:PushEvent("ttk_strengthen_gems_spent",{amount=10})
            a:PushEvent("ttk_strengthen_success",{category="weapon",level=6})
            a:PushEvent("ttk_strengthen_protection_used",{prefab="wb_strengthen_strengthen_protectpaper"})
            a:PushEvent("ttk_strengthen_scroll_used",{prefab="wb_strengthen_strengthen_6_levelpaper"})
            a:PushEvent("ttk_slot_spin_committed",{})
            a:PushEvent("ttk_slot_reward_committed",{prefab="ttk_lingshi2",source="ttk_choujiangji",kind="rare"})
            a:PushEvent("hh_dungeon_stock_token_used",{use_id="dq_stock_token"})
            local trackers={strengthen_success=true,strengthen_gem_spent=true,strengthen_protection_used=true,
                strengthen_scroll_used=true,slotmachine_spin=true,slotmachine_reward=true,dungeon_shop_restocked=true}
            for tracker in pairs(trackers) do
                local rows=require("achievement/ttk_achievement_catalog").ByEvent(tracker)
                assert(#rows>0,tracker)
                for _,row in ipairs(rows) do assert(progress(a,row.id)==0,row.id) end
            end
        ''')

    def test_catalog_runtime_totals_after_source_corrections(self):
        self.lua.execute('''
            local c=require("achievement/ttk_achievement_catalog"); assert(c.Validate())
            local groups={}; local stars=0
            for _,row in ipairs(c.All()) do groups[row.group]=true; stars=stars+row.reward end
            local n=0; for _ in pairs(groups) do n=n+1 end
            assert(#c.All()==231 and n==13 and stars==1000)
            assert(#c.ByEvent("strengthen_clear_used")==0,"no unavailable clear-scroll achievement")
        ''')


class GuildDungeonReachability(unittest.TestCase):
    def setUp(self):
        ActivityReachability.setUp(self)
        self.lua.execute('''
            TheWorld.ismastershard=true; TheWorld.components={}
            function TheWorld:HasTag(tag) return tag == "forest" and not self.cave end
            TUNING.TOTAL_DAY_TIME=480
            local basic_entity=entity
            function entity(prefab)
                local e=basic_entity(prefab)
                e.Transform.GetWorldPosition=function() return 0,0,0 end
                e.DoPeriodicTask=e.DoTaskInTime
                e.entity={SetParent=function() end}
                return e
            end
            function SpawnPrefab(prefab)
                if prefab=="minotaurchest" then return nil end
                local e=entity(prefab)
                e.components.inventoryitem={owner=nil}
                e.SetDungeonProduct=function() return true end
                return e
            end
            TheNet={Announce=function() end}
            exit_gate=entity("dungeon_exit")
            TheSim={FindFirstEntityWithTag=function(_,tag) if tag=="dungeon_exit" then return exit_gate end end}
            function inventory(p)
                local inv=p.components.inventory; inv.inst=p; inv.maxslots=40
                function inv:GetItemInSlot(slot) return self.itemslots[slot] end
                function inv:CanTakeItemInSlot() return true end
                function inv:CanAcceptCount(_,count) return count end
                function inv:GiveItem(item)
                    if self.fail then return nil end
                    for slot=1,self.maxslots do if not self.itemslots[slot] then
                        self.itemslots[slot]=item; item.components.inventoryitem.owner=p; return item
                    end end
                end
                function inv:RemoveItem(item)
                    for slot,v in pairs(self.itemslots) do if v==item then self.itemslots[slot]=nil end end
                    item.components.inventoryitem.owner=nil; return item
                end
                function inv:FindItems() local r={} for _,v in pairs(self.itemslots) do table.insert(r,v) end return r end
                return inv
            end
            function rank(p)
                local r=require("components/hh_rank")(p); p.components.hh_rank=r; inventory(p); return r
            end
            function manager()
                local w=entity("forest"); w.ismastersim=true; w.ismastershard=true; w.tags.forest=true
                local m=require("components/dungeon_manager")(w)
                m.state="READY"; m.run_epoch=1; m.active_gate=entity("dungeon_gate"); m.active_gate.tags.dungeon_gate=true
                TheWorld.components.dungeon_manager=m; return m
            end
            function counts(p,event)
                local result={n=0}
                p:ListenForEvent(event,function(_,data) result.n=result.n+1; result.data=data end)
                return result
            end
        ''')

    def test_entry_reentry_clear_snapshot_and_duplicate_final_death(self):
        self.lua.execute('''
            local m=manager(); local a=player("a"); local b=player("b"); local nearby=player("nearby")
            local entries=counts(a,"hh_dungeon_entered"); local clears=counts(a,"hh_dungeon_completed")
            assert(m:EnterDungeon(a)); assert(not m:EnterDungeon(a)); assert(m:EnterDungeon(b))
            m.players_in_dungeon[a]=nil; a:RemoveTag("in_solo_dungeon"); assert(m:EnterDungeon(a))
            assert(entries.n==1,"entry must emit once per actor per run")
            assert(progress(a,"dungeon_guild_enter_dungeon")==1 and progress(nearby,"dungeon_guild_enter_dungeon")==0)
            local stale=entity("hh_igris_dungeon"); stale.hh_dungeon_run_epoch=0
            m:OnMonsterDeath(stale); assert(not m.is_cleared)
            m.current_wave=m.max_waves
            local boss=entity("hh_beru_dungeon"); boss.hh_dungeon_run_epoch=1; m.monsters={boss}
            -- Removing B during A's receipt must not change the committed snapshot.
            a:ListenForEvent("hh_dungeon_completed",function() assert(m.is_cleared); m.players_in_dungeon[b]=nil end)
            m:OnMonsterDeath(boss); m:OnMonsterDeath(boss)
            assert(clears.n==1,"duplicate death must not replay final clear")
            assert(progress(a,"dungeon_guild_clear_dungeon")==1 and progress(b,"dungeon_guild_clear_dungeon")==1)
            assert(progress(nearby,"dungeon_guild_clear_dungeon")==0)
            m.run_epoch=2; m.is_cleared=false; m.state="READY"; m.current_wave=0; m.players_in_dungeon={}
            assert(m:EnterDungeon(a)); assert(entries.n==2)
        ''')

    def test_dungeon_kills_require_current_member_and_owned_run(self):
        self.lua.execute('''
            local m=manager(); local a=player("member"); local b=player("nearby"); assert(m:EnterDungeon(a))
            local function kill(p,prefab,epoch,owner)
                local v=entity(prefab); v.components.health={IsDead=function() return true end}
                v.hh_dungeon_manager=owner; v.hh_dungeon_run_epoch=epoch
                p:PushEvent("killed",{victim=v}); p:PushEvent("killed",{victim=v})
            end
            kill(b,"hh_igris_dungeon",1,m); kill(a,"hh_igris_dungeon",0,m); kill(a,"hh_igris_dungeon",1,{})
            assert(progress(a,"dungeon_guild_defeat_igris")==0 and progress(b,"dungeon_guild_defeat_igris")==0)
            kill(a,"hh_igris_dungeon",1,m); kill(a,"hh_beru_dungeon",1,m)
            assert(progress(a,"dungeon_guild_defeat_igris")==1 and progress(a,"dungeon_guild_defeat_beru")==1)
        ''')

    def test_coin_add_spend_load_and_dungeon_purchase_commit(self):
        self.lua.execute('''
            local a=player("a"); local b=player("b"); local inv=inventory(a)
            local wallet=require("components/hh_dungeon_coin")(a); a.components.hh_dungeon_coin=wallet
            wallet:OnLoad({coins=100000}); wallet:Spend(10); wallet:Add(0)
            assert(progress(a,"dungeon_guild_earn_dungeon_coin")==0)
            wallet:Add(40,"reward"); assert(progress(a,"dungeon_guild_earn_dungeon_coin")==40)
            local shop=require("components/hh_dungeon_shop")(TheWorld); shop:EnsureCycle()
            local id=shop.active[1]; local before=shop.stock[id]; local coins=wallet.coins
            local receipts=counts(a,"hh_dungeon_shop_purchased")
            a.tags.playerghost=true; assert(not shop:Purchase(a,id)); a.tags.playerghost=nil
            a.tags.hh_dungeon_transition=true; assert(not shop:Purchase(a,id)); a.tags.hh_dungeon_transition=nil
            assert(not shop:Purchase(a,"invalid")); inv.fail=true; assert(not shop:Purchase(a,id)); inv.fail=false
            local spend=wallet.Spend; wallet.Spend=function() return false end
            assert(not shop:Purchase(a,id)); wallet.Spend=spend
            assert(next(inv.itemslots)==nil and receipts.n==0 and shop.stock[id]==before and wallet.coins==coins)
            a:ListenForEvent("hh_dungeon_shop_purchased",function() assert(shop.stock[id]==before-1 and wallet.coins<coins) end)
            assert(shop:Purchase(a,id)); assert(receipts.n==1)
            assert(progress(a,"dungeon_guild_buy_dungeon_item")==1 and progress(a,"gacha_shop_shop_purchase")==1)
            assert(progress(b,"gacha_shop_shop_purchase")==0 and progress(a,"dungeon_guild_earn_dungeon_coin")==40)
        ''')

    def test_guild_quest_and_exam_commit_not_auto_promotion(self):
        self.lua.execute('''
            local a=player("a"); local r=rank(a)
            local q=require("components/hh_guild_quest")(a); a.components.hh_guild_quest=q
            q:EnsureOffers(); local id=q.offers[1]; assert(id)
            assert(not q:StartQuest(-99)); q:CompleteQuest()
            assert(progress(a,"dungeon_guild_accept_guild_quest")==0 and progress(a,"dungeon_guild_complete_guild_quest")==0)
            assert(q:StartQuest(id)); assert(progress(a,"dungeon_guild_accept_guild_quest")==1)
            q:AddProgress(q.target); q:CompleteQuest(); assert(progress(a,"dungeon_guild_complete_guild_quest")==1)
            assert(not r:ClaimExam()); r.rank=6; a.components.hh_leveling={level=70}; assert(r:ReconcileLevelPromotion())
            assert(r.rank==7 and progress(a,"dungeon_guild_pass_rank_exam")==0)
            a.components.hh_leveling.level=100; assert(r:ReconcileLevelPromotion()); assert(r.rank==8)
            assert(progress(a,"dungeon_guild_pass_rank_exam")==0)
            r.rank=1; r.exam_id=1; r.exam_status=3; assert(r:ClaimExam())
            assert(progress(a,"dungeon_guild_pass_rank_exam")==1)
        ''')

    def test_guild_staff_validation_and_shop_credit_rollback(self):
        self.lua.execute('''
            local a=player("a"); local r=rank(a); local ui=false
            a.hh_guild_ui_open={set=function(_,v) ui=v end}
            assert(not r:OpenInterface(nil)); assert(not ui and progress(a,"dungeon_guild_meet_guild")==0)
            local staff=entity("guild_staff"); staff.tags.hh_guild_employee=true
            staff.BeginGuildInteraction=function() end
            staff.valid=false; assert(not r:OpenInterface(staff)); staff.valid=true
            staff.tags.hh_guild_employee=nil; assert(not r:OpenInterface(staff)); staff.tags.hh_guild_employee=true
            a.tags.playerghost=true; assert(not r:OpenInterface(staff)); a.tags.playerghost=nil
            TheWorld.state.phase="night"; assert(not r:OpenInterface(staff)); TheWorld.state.phase="day"
            assert(r:OpenInterface(staff)); assert(ui and progress(a,"dungeon_guild_meet_guild")==1)
            local shop=require("components/hh_guild_shop")(a); a.components.hh_guild_shop=shop; r.credit=100000; r.rank=8
            local id=shop.active_products[1]; local before=shop.stock[id]; local inv=a.components.inventory
            local receipts=counts(a,"hh_guild_shop_purchased")
            inv.fail=true; assert(not shop:Purchase(id,1)); inv.fail=false
            local spend=r.SpendCredit; r.SpendCredit=function() return false end
            assert(not shop:Purchase(id,1)); r.SpendCredit=spend
            assert(next(inv.itemslots)==nil,"failed credit debit must roll delivery back")
            assert(receipts.n==0 and shop.stock[id]==before and r.credit==100000)
            -- The delivery transaction must also rollback a debit callback exception.
            r.SpendCredit=function(s) s.credit=s.credit-1; error("failed debit sync") end
            assert(not shop:Purchase(id,1)); r.SpendCredit=spend
            assert(next(inv.itemslots)==nil and receipts.n==0 and shop.stock[id]==before and r.credit==100000)
            a:ListenForEvent("hh_guild_shop_purchased",function() assert(shop.stock[id]==before-1 and r.credit<100000) end)
            assert(shop:Purchase(id,1)); assert(receipts.n==1)
            for _,id in ipairs({"dungeon_guild_spend_guild_credit","dungeon_guild_visit_guild_shop","gacha_shop_shop_discount"}) do
                assert(progress(a,id)==1,id)
            end
        ''')

    def test_component_methods_reject_non_surface_and_client_transactions(self):
        self.lua.execute('''
            local a=player("a"); local r=rank(a); r.rank=8; r.credit=100000
            local guild=require("components/hh_guild_shop")(a); local id=guild.active_products[1]
            local dungeon=require("components/hh_dungeon_shop")(TheWorld); dungeon:EnsureCycle()
            local wallet=require("components/hh_dungeon_coin")(a); a.components.hh_dungeon_coin=wallet; wallet.coins=100000
            local m=manager(); local w=m.inst
            for _,mode in ipairs({"client","cave","secondary"}) do
                TheWorld.ismastersim=mode~="client"; TheWorld.ismastershard=mode~="secondary"; TheWorld.cave=mode=="cave"
                w.ismastersim=TheWorld.ismastersim; w.ismastershard=TheWorld.ismastershard; w.tags.forest=not TheWorld.cave
                assert(not m:EnterDungeon(a)); assert(not guild:Purchase(id,1)); assert(not dungeon:Purchase(a,dungeon.active[1]))
                r.rank=1; r.exam_id=1; r.exam_status=3; assert(not r:ClaimExam())
                local q=require("components/hh_guild_quest")(a); a.components.hh_guild_quest=q
                q:EnsureOffers(); local quest=q.offers[1]; assert(q:StartQuest(quest)); q:AddProgress(q.target)
                assert(progress(a,"dungeon_guild_accept_guild_quest")==0 and progress(a,"dungeon_guild_complete_guild_quest")==0)
            end
            assert(next(a.components.inventory.itemslots)==nil and r.credit==100000 and wallet.coins==100000)
            assert(progress(a,"dungeon_guild_enter_dungeon")==0 and progress(a,"dungeon_guild_pass_rank_exam")==0)
        ''')

    def test_existing_dungeon_open_validation_and_surface_only_routes(self):
        # Execute the existing server validator/handler verbatim, without loading client UI.
        source=(MOD / "main/hh_dungeon_shop.lua").read_text(encoding="utf-8")
        block=source[source.index("local function CanOpen(player)"):source.index('AddModRPCHandler("hh_rpc", "hh_dungeon_shop_buy"')]
        self.lua.execute('function AddModRPCHandler(_,_,fn) open_shop=fn end')
        self.lua.execute(block)
        self.lua.execute('''
            local a=player("a"); local b=player("b")
            TheWorld.components.hh_dungeon_shop=require("components/hh_dungeon_shop")(TheWorld)
            a.tags.playerghost=true; open_shop(a); a.tags.playerghost=nil
            a.tags.hh_dungeon_transition=true; open_shop(a); a.tags.hh_dungeon_transition=nil
            TheWorld.cave=true; open_shop(a); TheWorld.cave=false
            assert(progress(a,"gacha_shop_shop_visit")==0)
            open_shop(a); assert(progress(a,"gacha_shop_shop_visit")==1 and progress(b,"gacha_shop_shop_visit")==0)
            TheWorld.ismastershard=false
            local wallet=require("components/hh_dungeon_coin")(b); wallet:Add(100,"reward"); open_shop(b)
            assert(progress(b,"dungeon_guild_earn_dungeon_coin")==0 and progress(b,"gacha_shop_shop_visit")==0)
            TheWorld.ismastershard=true; TheWorld.ismastersim=false; wallet:Add(100,"reward")
            assert(progress(b,"dungeon_guild_earn_dungeon_coin")==0)
        ''')


class AcceptanceRoutes(unittest.TestCase):
    setUp = ActivityReachability.setUp

    def test_client_player_receipts_cannot_advance(self):
        self.lua.execute('''
            local p=player("client-probe",function(p)
                p.components.eater={inst=p,Eat=function(s,food) s.inst:PushEvent("oneat",{food=food}); return true end}
                p.components.hh_leveling={level=100}
                p.components.hh_rank={GetRank=function() return 8 end}
            end,true)
            local crop=entity("farm_plant_carrot"); crop.tags.farm_plant=true
            local victim=entity("spider"); victim.components.health={IsDead=function() return true end}
            local boss=entity("deerclops"); boss.components.health={IsDead=function() return true end}
            TheWorld.ismastersim=false
            p.components.eater:Eat({prefab="meatballs"})
            for _,event in ipairs({
                {"builditem",{item=entity("xd_liandanlu")}},
                {"buildstructure",{item=entity("researchlab")}},
                {"finishedwork",{target=entity("evergreen"),action={id="CHOP"}}},
                {"picksomething",{object=crop}}, {"killed",{victim=victim}}, {"killed",{victim=boss}},
                {"hh_levelup",{level=100}}, {"hh_rank_changed",{source="claim_exam"}},
                {"hh_guild_quest_assigned",{}}, {"hh_guild_quest_completed",{}},
                {"hh_guild_opened",{}}, {"hh_guild_shop_purchased",{cost=10,count=1}},
                {"hh_dungeon_entered",{}}, {"hh_dungeon_completed",{}},
                {"hh_dungeon_coin_changed",{amount=100}}, {"hh_dungeon_shop_open_server",{}},
                {"hh_dungeon_shop_purchased",{}}, {"hh_dungeon_stock_token_used",{}},
                {"itemget",{item=item(p,"twigs",10)}},
                {"itemget",{item=item(p,"redgem",10)}},
                {"fishingcollect",{fish=entity("fish")}}, {"tilling",{}},
            }) do p:PushEvent(event[1],event[2]) end
            world("season","winter"); world("cycles",1); p:flush()
            assert(next(p.components.ttk_achievement_progress.core.achievements)==nil)
        ''')

    def test_basic_producers_distinct_save_and_canonical_level(self):
        self.lua.execute('''
            a=player("a",function(p)
                p.components.eater={inst=p,Eat=function(s,food)
                    s.inst:PushEvent("oneat",{food=food}); return not food.reject
                end}
                p.components.hh_leveling={level=1}
                p.components.levelsystem={level=100000} -- poison legacy authority
            end)
            b=player("b")
            assert(progress(a,"level_100")==0)
            local eater=a.components.eater
            eater:Eat({prefab="nn_liquidluck",reject=true})
            assert(progress(a,"food_liquid_luck_trinity")==0)
            for i=1,3 do eater:Eat({prefab="nn_liquidluck"}) end
            assert(progress(a,"food_liquid_luck_trinity")==1)
            local component=a.components.ttk_achievement_progress
            component:OnLoad(component:OnSave())
            eater:Eat({prefab="nn_liquidluck"}); eater:Eat({prefab="nn_liquidluck_2"})
            eater:Eat({prefab="nn_liquidluck_3"})
            assert(progress(a,"food_liquid_luck_trinity")==3)
            assert(component:ClaimAchievement("food_liquid_luck_trinity","distinct"))
            component:OnLoad(component:OnSave())
            assert(not component:ClaimAchievement("food_liquid_luck_trinity","distinct-again"))
            for _,prefab in ipairs({"twigs","redgem"}) do
                local i=item(a,prefab,2); a:PushEvent("itemget",{item=i}); a:PushEvent("itemget",{item=i})
            end
            assert(progress(a,"collection_twigs")==2 and progress(a,"collection_gems")==2)
            local catalog=require("achievement/ttk_achievement_catalog")
            for _,tracker in ipairs({"craft_prefab","crafting_event"}) do
                local row=catalog.ByEvent(tracker)[1]; local made=entity(row.params.prefab)
                a:PushEvent("builditem",{item=made}); a:PushEvent("buildstructure",{item=made})
                assert(progress(a,row.id)==1 and progress(b,row.id)==0)
            end
            local work={target=entity("evergreen"),action={id="CHOP"}}
            a:PushEvent("finishedwork",work); a:PushEvent("finishedwork",work)
            assert(progress(a,"labor_chop_trees")==1)
            local crop=entity("farm_plant_carrot"); crop.tags.farm_plant=true
            a:PushEvent("picksomething",{object=crop})
            assert(progress(a,"farming_harvest_crops")==1)
            local victim=entity("spider"); victim.components.health={IsDead=function() return true end}
            a:PushEvent("killed",{victim=victim,attacker=b}); assert(progress(a,"combat_spider")==0)
            a:PushEvent("killed",{victim=victim}); a:PushEvent("killed",{victim=victim})
            assert(progress(a,"combat_spider")==1 and progress(b,"combat_spider")==0)
            a.components.hh_leveling.level=70; a:PushEvent("hh_levelup",{level=100000})
            assert(progress(a,"level_50")==50 and progress(a,"level_100")==0)
            a.components.hh_leveling.level=100; a:PushEvent("hh_levelup")
            assert(progress(a,"level_100")==100)
            TheWorld.ismastersim=false
            eater:Eat({prefab="meatballs"}); a:PushEvent("itemget",{item=item(a,"twigs",10)})
            a:PushEvent("finishedwork",{target=entity("evergreen"),action={id="CHOP"}})
            a:PushEvent("picksomething",{object=crop})
            assert(progress(a,"food_meatballs")==0 and progress(a,"collection_twigs")==2)
            assert(progress(a,"labor_chop_trees")==1 and progress(a,"farming_harvest_crops")==1)
        ''')

    def test_seasonal_configuration_boundary_and_idempotent_real_rpc(self):
        self.lua.execute('''
            local catalog=require("achievement/ttk_seasonal_catalog")
            local function make(id,value)
                TUNING.TTK_SEASONAL_CLAIM_XP=value
                local p=player(id,function(p)
                    p.xp_calls=0; p.xp_total=0
                    p.components.hh_leveling={level=1,AddExp=function(_,amount)
                        p.xp_calls=p.xp_calls+1; p.xp_total=p.xp_total+amount; return true
                    end}
                end)
                local c=p.components.ttk_achievement_progress
                assert(c:StartSeason("autumn","audit:"..id,function(first) return first end))
                return p,c
            end
            local function ready(c,index)
                local slot=c.core.seasonal.slots[index]; local row=catalog.ById(slot.task_id)
                local evidence={event=row.event}
                for key,value in pairs(row.params) do evidence[key]=value end
                local ok,result=c:AdvanceSeasonal(row.id,row.target,evidence)
                assert(ok,result.code)
                return row,slot
            end
            -- The injected amount below is a fixture sentinel, never a production default.
            for index,value in ipairs({false,0,-1,0/0,math.huge,-math.huge,"7"}) do
                local p,c=make("invalid"..index,value~=false and value or nil)
                local row,slot=ready(c,1)
                local before=c:OnSave()
                local ok,result=c:ClaimSeasonal(row.id,"unavailable")
                assert(not ok and result.code=="xp_unavailable")
                rpc.AchievementSeasonal(p,"task",1,row.id,"rpc-unavailable")
                assert(slot.progress==row.target and slot.claims==0 and c.core.seasonal.first_claims==0)
                assert(next(c.core.seasonal_replays)==nil and next(c.core.seasonal_pending)==nil)
                assert(not c.core.seasonal_busy and next(c.core.seasonal.chest_claimed)==nil)
                assert(p.xp_calls==0 and c:OnSave().earned==before.earned)
                assert(progress(p,"season_claim_reward")==0)
            end
            local p,c=make("configured",7.25); local other=player("other")
            local row,slot=ready(c,1)
            rpc.AchievementSeasonal(p,"task",2,row.id,"wrong-slot")
            rpc.AchievementSeasonal(p,"task",1,row.id,"extra",{})
            TheWorld.ismastersim=false; rpc.AchievementSeasonal(p,"task",1,row.id,"client")
            assert(p.xp_calls==0 and slot.claims==0); TheWorld.ismastersim=true
            rpc.AchievementSeasonal(p,"task",1,row.id,"once")
            rpc.AchievementSeasonal(p,"task",1,row.id,"once")
            rpc.AchievementSeasonal(p,"task",1,row.id,"once-new-request")
            assert(p.xp_calls==1 and p.xp_total==7.25 and slot.claims==1)
            c:OnLoad(c:OnSave()); rpc.AchievementSeasonal(p,"task",1,row.id,"once")
            assert(p.xp_calls==1)
            local repeat_row=catalog.ById(c.core.seasonal.slots[17].task_id)
            assert(repeat_row.kind=="repeat")
            for number=1,5 do
                ready(c,17)
                rpc.AchievementSeasonal(p,"task",17,repeat_row.id,"repeat"..number)
                rpc.AchievementSeasonal(p,"task",17,repeat_row.id,"repeat"..number)
                assert(p.xp_calls==1+number)
            end
            assert(c.core.seasonal.first_claims==2 and p.xp_total==43.5)
            assert(progress(p,"season_first_mission")==1 and progress(p,"season_repeat")==1)
            assert(progress(p,"season_claim_reward")==1 and progress(other,"season_claim_reward")==0)
            TUNING.TTK_SEASONAL_CLAIM_XP=nil
        ''')


# Each entry names executable producer tests, not event-name/source-text guesses.
# Seasonal XP and missing perks are external seams, never tracker exemptions.
PRODUCER_TESTS = {
    ActivityReachability: {
        "test_pick_regrowth_fish_identity_and_two_actors": {"pick_prefab", "fish_caught"},
        "test_native_plant_success_failure_and_explicit_map": {"plant_seed"},
        "test_native_success_callbacks_reject_failed_canceled_and_nonfarm": {"farm_action"},
        "test_inventory_observes_partial_amount_overflow_and_transfers": {"own_prefab"},
        "test_native_cook_commit_chef_save_load_and_callback_preservation": {"cook_product"},
        "test_all_survival_keys_in_solo_authoritative_state": {"survival_event", "season_mission_assigned"},
    },
    GuildDungeonReachability: {
        "test_entry_reentry_clear_snapshot_and_duplicate_final_death": {"dungeon_entered", "dungeon_completed"},
        "test_dungeon_kills_require_current_member_and_owned_run": {"kill_prefab"},
        "test_coin_add_spend_load_and_dungeon_purchase_commit": {"dungeon_coin_earned", "dungeon_shop_purchase"},
        "test_guild_quest_and_exam_commit_not_auto_promotion": {"guild_quest_assigned", "guild_quest_completed", "guild_rank_exam_passed", "hunter_rank"},
        "test_guild_staff_validation_and_shop_credit_rollback": {"guild_opened", "guild_shop_purchase", "guild_credit_spent"},
        "test_existing_dungeon_open_validation_and_surface_only_routes": {"dungeon_shop_opened"},
    },
    StrengthenSlotReachability: {
        "test_gem_commit_and_success_threshold_wildcard": {"strengthen_gem_spent", "strengthen_success"},
        "test_protection_consumption_branches": {"strengthen_protection_used"},
        "test_level_paper_compatible_incompatible_return_and_zero": {"strengthen_scroll_used"},
        "test_slot_actor_save_load_repeat_payout_failed_spawn_and_classification": {"slotmachine_spin", "slotmachine_reward"},
        "test_real_prize_data_and_restock_committed_actor": {"dungeon_shop_restocked"},
    },
    AcceptanceRoutes: {
        "test_basic_producers_distinct_save_and_canonical_level": {"eat_prefabs", "collect_prefab", "collect_prefabs", "craft_prefab", "crafting_event", "work_action", "harvest_crop", "combat_event", "level_reached"},
        "test_seasonal_configuration_boundary_and_idempotent_real_rpc": {"season_mission_completed", "season_mission_claimed", "season_mission_repeat"},
    },
}

CLIENT_GUARD_TESTS = {
    ActivityReachability: {
        "test_death_reload_and_client_cannot_fabricate_receipts": {"survival_event", "pick_prefab", "fish_caught", "season_mission_assigned"},
        "test_every_new_component_route_is_master_only": {"plant_seed", "cook_product", "own_prefab", "farm_action"},
    },
    StrengthenSlotReachability: {
        "test_every_active_task17_tracker_rejects_client_receipts": {"strengthen_gem_spent", "strengthen_success", "strengthen_protection_used", "strengthen_scroll_used", "slotmachine_spin", "slotmachine_reward", "dungeon_shop_restocked"},
    },
    AcceptanceRoutes: {
        "test_client_player_receipts_cannot_advance": {"eat_prefabs", "collect_prefab", "collect_prefabs", "craft_prefab", "crafting_event", "work_action", "harvest_crop", "combat_event", "kill_prefab", "level_reached", "hunter_rank", "guild_rank_exam_passed", "guild_quest_assigned", "guild_quest_completed", "guild_opened", "guild_shop_purchase", "guild_credit_spent", "dungeon_entered", "dungeon_completed", "dungeon_coin_earned", "dungeon_shop_opened", "dungeon_shop_purchase"},
        "test_seasonal_configuration_boundary_and_idempotent_real_rpc": {"season_mission_completed", "season_mission_claimed", "season_mission_repeat"},
    },
}


def validate_tracker_coverage(active, observed):
    """Fail closed for new/dead types; no exception list can hide a dead route."""
    missing = sorted(set(active) - {tracker for tracker, routes in observed.items() if routes})
    if missing:
        raise AssertionError("No tested master-only producer route: " + ", ".join(missing))


class AcceptanceAudit(unittest.TestCase):
    def test_every_active_tracker_has_an_executed_master_only_producer(self):
        observed = {}
        active = set()
        for fixture, cases in PRODUCER_TESTS.items():
            for method, expected in cases.items():
                with self.subTest(route=fixture.__name__ + "." + method):
                    case = fixture(method)
                    case.audit_routes = True
                    case.setUp()
                    try:
                        getattr(case, method)()
                        hits = set(case.lua.globals().audit_hits.keys())
                        self.assertFalse(expected - hits, "Producer did not advance: " + str(sorted(expected - hits)))
                        for tracker in expected & hits:
                            observed.setdefault(tracker, set()).add(fixture.__name__ + "." + method)
                        catalog = case.lua.eval('require("achievement/ttk_achievement_catalog").All()')
                        active.update(row.tracker for row in catalog.values() if row.status == "active")
                    finally:
                        case.tearDown()
        validate_tracker_coverage(active, observed)
        guarded = {}
        for fixture, cases in CLIENT_GUARD_TESTS.items():
            for method, trackers in cases.items():
                with self.subTest(client_guard=fixture.__name__ + "." + method):
                    case = fixture(method)
                    case.audit_routes = True
                    case.setUp()
                    try:
                        getattr(case, method)()
                        for tracker in trackers:
                            guarded.setdefault(tracker, set()).add(fixture.__name__ + "." + method)
                    finally:
                        case.tearDown()
        validate_tracker_coverage(active, guarded)
        self.assertEqual(len(active), 40)
        # Negative controls prove that stale map entries and new types fail closed.
        for tracker in sorted(active):
            with self.subTest(dead_type=tracker), self.assertRaisesRegex(AssertionError, tracker):
                validate_tracker_coverage(active, {key: value for key, value in observed.items() if key != tracker})
        with self.assertRaisesRegex(AssertionError, "unrouted_future_type"):
            validate_tracker_coverage(active | {"unrouted_future_type"}, observed)


if __name__ == "__main__":
    unittest.main()
