"""Exercise native food/build names through the installed Lua achievement adapter."""
import unittest

import test_achievement_reachability as reachability


class NativeFoodConditions(unittest.TestCase):
    def setUp(self):
        reachability.ActivityReachability.setUp(self)
        self.lua.execute('''
            function food_player(id)
                return player(id,function(p)
                    p.components.eater={inst=p,Eat=function(s,food)
                        s.inst:PushEvent("oneat",{food=food}); return true
                    end}
                end)
            end
            function choose_task(p,id,selected)
                local catalog=require("achievement/ttk_seasonal_catalog")
                local row=catalog.ById(id)
                local index=0
                for _,candidate in ipairs(catalog.All()) do
                    if candidate.season==row.season and candidate.kind==row.kind then
                        index=index+1
                        if candidate.id==id then break end
                    end
                end
                local pool_size=row.kind=="once" and 40 or 10
                local c=p.components.ttk_achievement_progress
                TheWorld.state.season=row.season
                local ok,result=c:StartSeason(row.season,"native-food:"..p.userid,function(first,last)
                    if last==pool_size then
                        if selected and first==1 then return index end
                        if not selected and first==index then return last end
                    end
                    return first
                end)
                assert(ok,result.code)
                local found
                for _,slot in ipairs(c.core.seasonal.slots) do
                    if slot.task_id==id then found=slot end
                end
                assert((found~=nil)==selected,"fixture must draw the requested selection")
                return found,c
            end
            function receipt(p,event,prefab)
                if event=="oneat" then p.components.eater:Eat(entity(prefab))
                else p:PushEvent(event,{item=entity(prefab)}) end
            end
        ''')

    def assert_food_condition(self, task_id, actual, obsolete):
        # Reverting a catalog prefab must break real progress, not a text assertion.
        self.lua.execute('''
            local id,actual,obsolete=...
            local p=food_player("eater"); local other=food_player("other")
            receipt(p,"oneat",obsolete)
            assert(progress(p,id)==0,id..": obsolete alias must not advance")
            receipt(p,"oneat",actual)
            assert(progress(p,id)==1,id..": native food must advance")
            assert(progress(other,id)==0,id..": receipt belongs to eater")
            for i=2,5 do receipt(p,"oneat",actual) end
            assert(progress(p,id)==5,id..": five native foods must complete")
        ''', task_id, actual, obsolete)

    def assert_seasonal_condition(self, task_id, event, actual, obsolete, target):
        self.lua.execute('''
            local id,event,actual,obsolete,target=...
            local p=food_player("selected"); local unselected=food_player("unselected")
            local slot=choose_task(p,id,true)
            local _,other=choose_task(unselected,id,false)
            receipt(p,event,obsolete)
            assert(slot.progress==0,id..": obsolete alias must not advance")
            receipt(p,event,actual)
            assert(slot.progress==1,id..": native receipt must advance selected task")
            for i=2,target do receipt(p,event,actual) end
            assert(slot.progress==target,id..": native receipts must complete task")
            receipt(unselected,event,actual)
            receipt(unselected,event,obsolete)
            for _,other_slot in ipairs(other.core.seasonal.slots) do
                assert(other_slot.progress==0,id..": unselected task must not route progress")
            end
        ''', task_id, event, actual, obsolete, target)

    def test_pierogi_achievement_accepts_perogies(self):
        self.assert_food_condition("food_pierogi", "perogies", "pierogi")

    def test_spicychili_achievement_accepts_hotchili(self):
        self.assert_food_condition("food_spicychili", "hotchili", "spicychili")

    def test_selected_spring_frogglebun_accepts_frogglebunwich(self):
        self.assert_seasonal_condition("spring_frogglebun", "oneat", "frogglebunwich", "frogglebun", 3)

    def test_selected_summer_coldfire_accepts_coldfirepit(self):
        self.assert_seasonal_condition("summer_coldfire", "buildstructure", "coldfirepit", "endothermicfirepit", 1)

    def test_selected_summer_pierogi_accepts_perogies(self):
        self.assert_seasonal_condition("summer_pierogi", "oneat", "perogies", "pierogi", 3)


if __name__ == "__main__":
    unittest.main()
