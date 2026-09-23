"""Rollover regressions executing the registered server watcher and Lua core."""
import unittest

import test_achievement_reachability as reachability


class SeasonalRollover(unittest.TestCase):
    def setUp(self):
        reachability.ActivityReachability.setUp(self)
        self.lua.execute('''
            catalog=require("achievement/ttk_seasonal_catalog")
            TUNING.TTK_SEASONAL_CLAIM_XP=10
            Prefabs={ttk_lc_qfx_seed={},ttk_lingshi1={}}
            spawned={}; grants={}; xp=0; xp_calls=0
            function SpawnPrefab(name)
                if name==fail_spawn then return nil end
                local i=entity(name); i.components.inventoryitem={}
                i.components.stackable={maxsize=40,size=1,
                    SetStackSize=function(s,n) s.size=n end,StackSize=function(s) return s.size end}
                spawned[#spawned+1]=i; return i
            end
            Vector3=function(x,y,z) return {x=x,y=y,z=z} end
            function setup(p)
                p.Transform.GetWorldPosition=function() return 10,0,20 end
                p.components.hh_leveling={level=1,AddExp=function(_,amount)
                    assert(p.components.ttk_achievement_progress.core.seasonal.season=="autumn",
                        "XP must settle before the new pool")
                    xp=xp+amount; xp_calls=xp_calls+1; return true
                end}
                local inv=p.components.inventory
                inv.GetNumSlots=function() return 20 end
                inv.CanAcceptCount=function(_,i,n) return n end
                inv.GiveItem=function(_,i)
                    assert(p.components.ttk_achievement_progress.core.seasonal.season=="autumn",
                        "bundle must settle before the new pool")
                    i.components.inventoryitem.owner=p
                    grants[i.prefab]=(grants[i.prefab] or 0)+i.components.stackable:StackSize()
                end
            end
            function ready(p,index)
                local c=p.components.ttk_achievement_progress
                local s=c.core.seasonal.slots[index]; local r=catalog.ById(s.task_id)
                local e={event=r.event}; for k,v in pairs(r.params) do e[k]=v end
                assert(c:AdvanceSeasonal(r.id,r.target,e)); return s,r
            end
            function claimed(p,n)
                for i=1,n do
                    local s=ready(p,i)
                    rpc.AchievementSeasonal(p,"task",i,s.task_id,"manual:"..i)
                    assert(s.claims==1)
                end
            end
            function winter(p)
                world("cycles",21); world("season","winter")
                TheWorld.state.elapseddaysinseason=0
                p:flush()
            end
            function reload(p)
                local saved=p.components.ttk_achievement_progress:OnSave()
                AllPlayers={}
                local q=player("restored",setup,true)
                q.components.ttk_achievement_progress:OnLoad(saved)
                q:flush(); return q
            end
            function checkwinter(p)
                local s=p.components.ttk_achievement_progress.core.seasonal
                assert(s.season=="winter" and s.epoch=="winter:21" and #s.slots==20)
                assert(s.first_claims==0 and next(s.chest_claimed)==nil)
                local once,repeatable=0,0
                for _,slot in ipairs(s.slots) do
                    if catalog.ById(slot.task_id).kind=="once" then once=once+1 else repeatable=repeatable+1 end
                end
                assert(once==16 and repeatable==4)
            end
        ''')

    def test_watcher_settles_old_xp_and_chest_once_before_drawing(self):
        self.lua.execute('''
            local p=player("rollover",setup); claimed(p,5); ready(p,6)
            assert(xp==50 and grants.ttk_lc_qfx_seed==nil)
            winter(p)
            assert(xp==60 and xp_calls==6,"sixth outgoing task XP was lost")
            assert(grants.ttk_lc_qfx_seed==3,"outgoing milestone chest was lost")
            checkwinter(p)
            world("season","winter"); world("season","winter"); p:flush()
            p=reload(p); world("season","winter"); p:flush(); checkwinter(p)
            assert(xp==60 and xp_calls==6 and grants.ttk_lc_qfx_seed==3)
        ''')

    def test_invalid_xp_persists_outgoing_ready_task_and_retries_after_load(self):
        for value in ("nil", "0", "-1", "0/0", "math.huge", "-math.huge"):
            with self.subTest(value=value):
                self.setUp()
                self.lua.execute('''
                    TUNING.TTK_SEASONAL_CLAIM_XP=''' + value + '''
                    local p=player("no-xp",setup); local slot,row=ready(p,1)
                    winter(p)
                    local c=p.components.ttk_achievement_progress
                    assert(c.core.seasonal.season=="autumn","invalid XP destroyed outgoing pool")
                    assert(c:OnSave().seasonal.rollover_pending==true,"pending settlement must be durable")
                    assert(slot.progress==row.target and slot.claims==0 and xp==0)
                    p=reload(p)
                    assert(p.components.ttk_achievement_progress.core.seasonal.season=="autumn" and xp==0)
                    TUNING.TTK_SEASONAL_CLAIM_XP=10
                    world("season","winter"); p:flush(); checkwinter(p)
                    p=reload(p); checkwinter(p); assert(xp==10 and xp_calls==1)
                ''')

    def test_failed_bundle_preflight_or_staging_retries_without_partial_grant(self):
        for failure in ('Prefabs.ttk_lingshi1=nil', 'fail_spawn="ttk_lingshi1"'):
            with self.subTest(failure=failure):
                self.setUp()
                self.lua.execute('''
                    local p=player("bundle",setup); claimed(p,9); ready(p,10)
                    local c=p.components.ttk_achievement_progress
                    assert(c:ClaimChest("autumn",5,"old-five"))
                ''' + failure + '''
                    winter(p)
                    assert(xp==100 and xp_calls==10,"ready tenth task must commit once")
                    assert(c.core.seasonal.season=="autumn" and c:OnSave().seasonal.rollover_pending)
                    assert(grants.ttk_lc_qfx_seed==3 and grants.ttk_lingshi1==nil,"partial bundle escaped")
                    for _,i in ipairs(spawned) do assert(not i:IsValid() or i.components.inventoryitem.owner) end
                    p=reload(p)
                    assert(xp==100 and grants.ttk_lc_qfx_seed==3)
                    Prefabs.ttk_lingshi1={}; fail_spawn=nil
                    world("season","winter"); p:flush(); checkwinter(p)
                    p=reload(p); checkwinter(p)
                    assert(xp==100 and xp_calls==10 and grants.ttk_lc_qfx_seed==8 and grants.ttk_lingshi1==10)
                ''')

    def test_manual_claims_and_client_rollover_cannot_bypass_season_authority(self):
        self.lua.execute('''
            local p=player("authority",setup); claimed(p,5); local slot=ready(p,6)
            local c=p.components.ttk_achievement_progress
            world("season","winter")
            assert(not c:ClaimSeasonal(slot.task_id,"stale-task"))
            assert(not c:ClaimChest("autumn",5,"stale-chest"))
            TheWorld.ismastersim=false; p:flush()
            assert(not c:StartSeason("winter","winter:0"))
            assert(c.core.seasonal.season=="autumn" and xp==50 and next(grants)==nil)
            TheWorld.ismastersim=true; winter(p); checkwinter(p)
            assert(xp==60 and grants.ttk_lc_qfx_seed==3)
        ''')

    def test_daily_retry_preserves_repeat_count(self):
        self.lua.execute('''
            local p=player("repeat",setup)
            local c=p.components.ttk_achievement_progress
            for n=1,2 do
                local s=ready(p,17)
                assert(c:ClaimSeasonal(s.task_id,"repeat:"..n))
            end
            local slot,row=ready(p,17)
            -- An explicit XP rejection must leave the repeat's next award ready.
            local addexp=p.components.hh_leveling.AddExp
            p.components.hh_leveling.AddExp=function() return false end
            winter(p)
            assert(xp==20 and slot.claims==2 and slot.progress==row.target)
            assert(c.core.seasonal.rollover_pending and c.core.seasonal.first_claims==1)
            p.components.hh_leveling.AddExp=addexp
            TheWorld.state.elapseddaysinseason=1; world("cycles",22); p:flush()
            checkwinter(p); assert(xp==30 and xp_calls==3 and next(grants)==nil)
            p=reload(p); assert(xp==30)
        ''')

    def test_paid_chest_is_not_repeated_when_xp_remains_pending(self):
        self.lua.execute('''
            local p=player("mixed",setup); claimed(p,5); ready(p,6)
            TUNING.TTK_SEASONAL_CLAIM_XP=0
            winter(p)
            local s=p.components.ttk_achievement_progress.core.seasonal
            assert(s.season=="autumn" and s.rollover_pending and s.chest_claimed[5])
            assert(xp==50 and grants.ttk_lc_qfx_seed==3)
            p=reload(p); assert(xp==50 and grants.ttk_lc_qfx_seed==3)
            TUNING.TTK_SEASONAL_CLAIM_XP=10
            p=reload(p); checkwinter(p)
            assert(xp==60 and xp_calls==6 and grants.ttk_lc_qfx_seed==3)
        ''')

    def test_every_newly_eligible_milestone_and_reentrant_refresh_settle_once(self):
        self.lua.execute('''
            Prefabs.ttk_lingshi2={}; Prefabs.greengem={}; Prefabs.ttk_lingshi3={}; Prefabs.bearger_fur={}
            local p=player("all",setup); local c=p.components.ttk_achievement_progress
            for i=1,20 do ready(p,i) end
            local addexp=p.components.hh_leveling.AddExp
            p.components.hh_leveling.AddExp=function(self,amount)
                local ok,result=c:StartSeason("winter","winter:21")
                assert(not ok and result.code=="pending","reentrant refresh must not replace outgoing state")
                return addexp(self,amount)
            end
            winter(p); checkwinter(p)
            assert(xp==200 and xp_calls==20)
            assert(grants.ttk_lc_qfx_seed==8 and grants.ttk_lingshi1==10 and grants.ttk_lingshi2==2
                and grants.greengem==1 and grants.ttk_lingshi3==1 and grants.bearger_fur==1)
            p=reload(p); world("season","winter"); p:flush()
            assert(xp==200 and grants.ttk_lc_qfx_seed==8 and grants.bearger_fur==1)
        ''')

    def test_uncertain_xp_callback_reservation_survives_load_without_double_award(self):
        self.lua.execute('''
            local p=player("uncertain",setup); local slot=ready(p,1)
            local addexp=p.components.hh_leveling.AddExp
            p.components.hh_leveling.AddExp=function(self,amount)
                addexp(self,amount); error("after XP changed")
            end
            winter(p)
            assert(xp==10 and xp_calls==1 and slot.xp_receipt=="pending")
            p=reload(p); world("season","winter"); p:flush()
            local s=p.components.ttk_achievement_progress.core.seasonal
            assert(xp==10 and xp_calls==1 and s.season=="autumn" and s.rollover_pending)
            assert(s.slots[1].xp_receipt=="pending" and s.slots[1].claims==0)
        ''')

    def test_automatic_claims_credit_all_season_achievements_once(self):
        self.lua.execute('''
            Prefabs.ttk_lingshi2={}; Prefabs.greengem={}; Prefabs.ttk_lingshi3={}; Prefabs.bearger_fur={}
            local Core=require("achievement/ttk_achievement_core")
            local configure=Core.SetSeasonalClaimCallback
            local receipts={}; local delivered=0
            Core.SetSeasonalClaimCallback=function(core,fn)
                configure(core,function(player,receipt,state)
                    assert(not receipts[receipt.claim_key],"duplicate committed claim receipt")
                    receipts[receipt.claim_key]=true; delivered=delivered+1
                    return fn(player,receipt,state)
                end)
            end
            local p=player("achievements",setup); local c=p.components.ttk_achievement_progress
            local s=ready(p,17); assert(c:ClaimSeasonal(s.task_id,"first-repeat"))
            for i=1,20 do ready(p,i) end
            local advances=0; local advance=c.core.Advance
            c.core.Advance=function(core,id,...)
                if id:match("^season_") then advances=advances+1 end
                return advance(core,id,...)
            end
            winter(p); checkwinter(p)
            local function check(q)
                for id,target in pairs({season_first_mission=1,season_mission_five=5,season_mission_ten=10,
                    season_mission_fifteen=15,season_mission_twenty=20,season_participate=1,
                    season_repeat=1,season_claim_reward=1}) do
                    assert(progress(q,id)==target,"automatic settlement omitted "..id)
                end
            end
            check(p); assert(xp==210 and xp_calls==21 and grants.bearger_fur==1)
            local before=advances
            world("season","winter"); world("season","winter"); p:flush()
            assert(advances==before,"duplicate watcher repeated achievement credit")
            p=reload(p); world("season","winter"); p:flush(); check(p)
            assert(xp==210 and xp_calls==21 and grants.bearger_fur==1 and delivered==21)
        ''')

    def test_manual_receipts_replay_and_pending_rollover_reload_share_one_boundary(self):
        self.lua.execute('''
            local p=player("manual-replay",setup); local c=p.components.ttk_achievement_progress
            local slot=ready(p,17)
            local addexp=p.components.hh_leveling.AddExp
            p.components.hh_leveling.AddExp=function() return false end
            rpc.AchievementSeasonal(p,"task",17,slot.task_id,"rejected")
            assert(slot.claims==0 and progress(p,"season_claim_reward")==0)
            rpc.AchievementSeasonal(p,"task",1,slot.task_id,"wrong-slot")
            assert(slot.claims==0 and progress(p,"season_first_mission")==0)
            p.components.hh_leveling.AddExp=addexp
            rpc.AchievementSeasonal(p,"task",17,slot.task_id,"manual-repeat")
            assert(slot.claims==1 and progress(p,"season_claim_reward")==1)
            local receipts=0; local callback=c.core.seasonal_claimed
            c.core.seasonal_claimed=function(...) receipts=receipts+1; return callback(...) end
            ready(p,17)
            rpc.AchievementSeasonal(p,"task",17,slot.task_id,"manual-repeat")
            assert(slot.claims==1 and receipts==0 and progress(p,"season_repeat")==0)
            for i=1,9 do ready(p,i) end
            Prefabs.ttk_lingshi1=nil
            winter(p)
            assert(c.core.seasonal.rollover_pending and receipts==10 and xp==110)
            assert(progress(p,"season_repeat")==1 and progress(p,"season_mission_ten")==10)
            p=reload(p); c=p.components.ttk_achievement_progress
            receipts=0; callback=c.core.seasonal_claimed
            c.core.seasonal_claimed=function(...) receipts=receipts+1; return callback(...) end
            world("season","winter"); p:flush()
            assert(receipts==0 and xp==110 and grants.ttk_lc_qfx_seed==3)
            Prefabs.ttk_lingshi1={}; world("season","winter"); p:flush(); checkwinter(p)
            assert(receipts==0 and xp==110 and grants.ttk_lc_qfx_seed==8 and grants.ttk_lingshi1==10)
            assert(progress(p,"season_repeat")==1 and progress(p,"season_mission_ten")==10)
        ''')


if __name__ == "__main__":
    unittest.main()
