"""Task 20 regressions: real Lua adapters, native Eater/Edible and Stewer."""
from zipfile import ZipFile
import re
import unittest

import test_achievement_reachability as reachability
from test_achievement_reachability import MOD, GAME


class NativeCorrectness(unittest.TestCase):
    setUp = reachability.ActivityReachability.setUp

    def native(self, name, variable):
        with ZipFile(GAME) as archive:
            self.lua.execute(variable + " = (function() " + archive.read("scripts/" + name + ".lua").decode() + " end)()")

    def test_corrected_kill_conditions_accept_registered_forms_not_aliases(self):
        cases = [
            ("combat_mactusk", "mactusk", ["walrus"], 2),
            ("combat_depths_worm", "depths_worm", ["worm"], 1),
            ("combat_shadow_creature", "shadow_creature", ["crawlinghorror", "terrorbeak"], 1),
            ("combat_clockwork", "clockwork", ["knight", "bishop", "rook", "knight_nightmare", "bishop_nightmare", "rook_nightmare"], 1),
            ("combat_treeguard", "treeguard", ["leif", "leif_sparse"], 1),
            ("boss_fuelweaver", "fuelweaver", ["stalker_atrium"], 2),
            ("boss_malbat", "malbat", ["malbatross"], 1),
            ("boss_guardian", "guardian", ["alterguardian_phase3"], 1),
            ("boss_ttk_boss_deerclops_ziyun", "ttk_boss_deerclops_ziyun", ["ttk_deerclops_ziyun"], 1),
            ("boss_ttk_boss_ziyunshadow", "ttk_boss_ziyunshadow", ["ttk_deerclops_ziyun"], 2),
            ("boss_ttk_boss_gongdeshadow", "ttk_boss_gongdeshadow", ["ttk_qxdx"], 1),
        ]
        for ident, alias, prefabs, target in cases:
            for prefab in prefabs:
                with self.subTest(achievement=ident, prefab=prefab):
                    self.lua.execute('''
                        local id,alias,prefab,target=...
                        local p=player(id..prefab)
                        local function kill(name)
                            local v=entity(name); v.components.health={IsDead=function() return true end}
                            p:PushEvent("killed",{victim=v}); p:PushEvent("killed",{victim=v})
                        end
                        kill(alias); kill("unrelated_prefab")
                        assert(progress(p,id)==0,"old alias must not credit "..id)
                        for n=1,target do kill(prefab); assert(progress(p,id)==n,"native prefab did not credit "..id) end
                        assert(p.components.ttk_achievement_progress.core.achievements[id].status=="completed_unclaimed")
                    ''', ident, alias, prefab, target)

    def test_registered_provider_evidence_for_corrected_conditions(self):
        # These are declarations in the installed native prefab factories, not
        # arbitrary mentions in loot/recipes/stategraphs.
        providers = {
            "walrus": ("Prefab", ["walrus"]), "worm": ("Prefab", ["worm"]),
            "leif": ("Prefab", ["leif", "leif_sparse"]),
            "knight": ("MakeKnight", ["knight", "knight_nightmare"]),
            "bishop": ("MakeBishop", ["bishop", "bishop_nightmare"]),
            "rook": ("MakeRook", ["rook", "rook_nightmare"]),
            "stalker": ("MakeStalker", ["stalker_atrium"]),
            "malbatross": ("Prefab", ["malbatross"]),
            "alterguardian_phase3": ("Prefab", ["alterguardian_phase3"]),
        }
        with ZipFile(GAME) as archive:
            loaded = archive.read("scripts/prefablist.lua").decode()
            for factory, (constructor, names) in providers.items():
                self.assertIn('"' + factory + '"', loaded)
                source = archive.read("scripts/prefabs/" + factory + ".lua").decode()
                for name in names:
                    self.assertRegex(source, rf'\b{constructor}\("{name}"\s*,')
                if constructor != "Prefab":
                    self.assertIn("return Prefab(name, fn,", source)
            shadows = archive.read("scripts/prefabs/shadowcreature.lua").decode()
            self.assertIn("return Prefab(data.name, fn,", shadows)
            self.assertIn("MakeShadowCreature(v)", shadows)
            for name in ("crawlinghorror", "terrorbeak"):
                self.assertRegex(shadows, rf'name\s*=\s*"{name}"')
        for factory, name in (("ttk_boss_deerclops_ziyun_aux", "ttk_deerclops_ziyun"),
                              ("ttk_qxdx", "ttk_qxdx")):
            source = (MOD / "scripts/prefabs" / (factory + ".lua")).read_text(encoding="utf-8")
            self.assertRegex(source, rf'Prefab\("{name}"\s*,')
            combat = (MOD / "main/ttk_boss_combat.lua").read_text(encoding="utf-8")
            self.assertIn('"' + factory + '"', combat)

    def test_repeat_boss_is_summonable_after_death_and_unique_boss_is_not(self):
        self.lua.execute('''
            local Registry=require("components/ttk_bossregistry")
            local catalog=require("achievement/ttk_achievement_catalog")
            local defs=require("ttk_boss_defs")
            local registry=Registry(entity("world"))
            local row=catalog.ById("boss_ttk_boss_ziyunshadow")
            assert(row.params.prefab=="ttk_deerclops_ziyun" and row.target==2)
            assert(defs.bosses.deerclops_ziyun.summon=="ttk_summon_deerclops_ziyun")
            for _,key in ipairs({"deerclops_ziyun","ziyunboss","qxdx"}) do
                local boss=entity(defs.bosses[key].prefab)
                boss.components.health={IsDead=function() return false end}
                assert(registry:Register(key,boss)); assert(registry:MarkDead(key,boss))
                assert(registry:CanSpawn(key,true)==(key=="deerclops_ziyun"))
            end
        ''')

    def test_dig_stump_uses_tag_after_native_finishedwork(self):
        self.lua.execute('ACTIONS={CHOP={id="CHOP"},DIG={id="DIG"}}')
        self.native("components/workable", "Workable")
        with ZipFile(GAME) as archive:
            source = archive.read("scripts/prefabs/evergreens.lua").decode()
        self.lua.execute(re.search(r'local function dig_up_stump\(.*?\nend', source, re.S)[0] + '\nNativeDig=dig_up_stump')
        self.lua.execute('''
            local p=player("digger"); EQUIPSLOTS={HANDS="hands"}
            p.components.inventory.GetEquippedItem=function() return nil end
            function dig(prefab,stump)
                local t=entity(prefab); t.tags.stump=stump; t.components.lootdropper={SpawnLootPrefab=function() end}
                t.components.workable=Workable(t); t.components.workable:SetWorkAction(ACTIONS.DIG)
                t.components.workable:SetWorkLeft(1); t.components.workable:SetOnFinishCallback(NativeDig)
                t.components.workable:WorkedBy(p,1)
                assert(not t:IsValid(),"native finish must remove target before player receipt")
            end
            dig("stump",false); dig("evergreen",false)
            assert(progress(p,"labor_dig_stumps")==0)
            dig("evergreen",true); dig("deciduoustree",true)
            assert(progress(p,"labor_dig_stumps")==2,"tagged removed stumps must credit")
        ''')

    def test_stewer_installs_both_real_postinits_in_registration_order(self):
        # Keep entity/scheduler fixtures, reload real registration including the
        # modimport (the old reachability harness skipped that import).
        self.lua.execute('''
            a=player("chef"); b=player("other")
            env={GLOBAL=_G}; hooks={}; PrefabFiles={}; AllRecipes={}; Prefabs={}; NUM_TRINKETS=0
            STRINGS={NAMES={},RECIPE_DESC={}}; TECH={NONE={}}; CHARACTER_INGREDIENT={SANITY="sanity"}
            Ingredient=function(name,n) return {type=name,amount=n} end
            AddRecipe2=function() end; env.AddRecipe2=AddRecipe2
            AddStategraphPostInit=function() end
            ACTIONS={STORE={fn=function() end},PICK={},TAKEITEM={},HARVEST={}}
            function AddComponentPostInit(name,fn)
                local previous=hooks[name]
                hooks[name]=function(component) if previous then previous(component) end; fn(component) end
            end
            package.loaded["achievement/ttk_perk_effects"]=nil
        ''')
        self.lua.globals().modimport = lambda path: self.lua.execute((MOD / path).read_text(encoding="utf-8"))
        self.lua.execute((MOD / "main/ttk_achievement.lua").read_text(encoding="utf-8"))
        # Reuse the native Stewer scenario, including save/load and callback retention.
        # Its player() calls use already-installed players to avoid requiring unrelated components.
        self.lua.execute('local oldplayer=player; player=function(id) return id=="a" and a or b end')
        reachability.ActivityReachability.test_native_cook_commit_chef_save_load_and_callback_preservation(self)
        self.lua.execute('''
            a._ttk_achievement_perks={cook_faster=1}
            local p,s=pot(); hooks.stewer(s); hooks.stewer(s)
            local before=progress(a,"labor_cook_meals"); local oldcallbacks=callbacks
            s:StartCooking(a); p:flush()
            assert(s.done and progress(a,"labor_cook_meals")==before+1,"both cook perk and receipt must run")
            assert(callbacks==oldcallbacks+1,"idempotent hooks must preserve native callback once")
        ''')

    def setup_native_pills(self):
        self.native("class", "UnusedClassReturn")
        self.lua.execute('''
            FOODTYPE={GENERIC="GENERIC",GOODIES="GOODIES"}; FOODGROUP={OMNI={name="OMNI",types={"GOODIES"}}}
            Asset=function() return {} end; Prefab=function(name,fn) return {name=name,fn=fn} end
            MakePlacer=function(name) return {name=name} end
            MakeInventoryPhysics=function() end
            function CreateEntity()
                local i=entity("pill"); i.removes=0
                function i:Remove() self.removes=self.removes+1; self.valid=false end
                i.entity={AddTransform=function() end,AddAnimState=function() end,AddNetwork=function() end,SetPristine=function() end}
                i.AnimState={SetBank=function() end,SetBuild=function() end,PlayAnimation=function() end}
                function i:AddComponent(name)
                    self.components[name]=name=="edible" and NativeEdible(self) or {}
                end
                return i
            end
            Assets={}; package.loaded.containers={params={}}
            Vector3=function() return {} end; Ingredient=function() return {} end
            STRINGS={NAMES={},RECIPE_DESC={},ACTIONS={},CHARACTERS={GENERIC={DESCRIBE={}}}}
            TECH={SCIENCE_TWO={}}; AddRecipe2=function() end; Action=function(v) return v end
            AddAction=function() end; AddComponentAction=function() end
            RegisterInventoryItemAtlas=function() end
            ActionHandler=function() end; AddStategraphActionHandler=function() end
        ''')
        self.native("components/eater", "NativeEater")
        self.native("components/edible", "NativeEdible")
        registered = self.lua.execute((MOD / "scripts/prefabs/ttk_alchemy.lua").read_text(encoding="utf-8"))
        self.lua.globals().pills = self.lua.table_from({row.name: row.fn for row in registered})
        self.lua.execute('saved_player_init=player_init')
        self.lua.execute((MOD / "main/ttk_alchemy.lua").read_text(encoding="utf-8"))
        self.lua.execute('''
            player_init=saved_player_init
            function pill(name) local i=pills[name](); i.prefab=name; return i end
            function pillplayer()
                local p=player("cultivator")
                p.components.health.DoDelta=function() end
                p.components.ttk_cultivation=require("components/ttk_cultivation")(p)
                p.components.eater=NativeEater(p)
                if hooks.eater then hooks.eater(p.components.eater) end
                p.advances=0; p:ListenForEvent("ttk_cultivation_advanced",function() p.advances=p.advances+1 end)
                return p
            end
        ''')

    def test_native_eater_rejects_pills_before_inventory_removal(self):
        self.setup_native_pills()
        self.lua.execute('''
            local p=pillplayer(); local c=p.components.ttk_cultivation; local e=p.components.eater
            local function reject(name)
                local i=pill(name); p.components.inventory.itemslots[1]=i
                local stage,events=c.stage,p.advances
                assert(not e:CanEat(i),"native action eligibility must reject "..name)
                assert(not e:Eat(i),"native Eater must reject "..name)
                assert(i:IsValid() and i.removes==0 and p.components.inventory.itemslots[1]==i)
                assert(c.stage==stage and p.advances==events)
            end
            reject("xd_danyao_dt")
            local i=pill("xd_danyao_jq")
            assert(e:CanEat(i) and e:Eat(i)==true)
            assert(not i:IsValid() and i.removes==1 and c.stage==1 and p.advances==1)
            reject("xd_danyao_jq")
            c.stage=-1; reject("xd_danyao_dt")
            c.stage=1.5; reject("xd_danyao_dt")
            c.stage="bad"; reject("xd_danyao_dt")
            c.stage=15; c.consumed={}; reject("xd_danyao_jq")
            c:OnLoad(nil)
            local defs=require("alchemy/ttk_alchemy_defs")
            for n=1,15 do
                local nextpill=pill(defs.GetCultivationStage(n).prefab)
                assert(e:Eat(nextpill)==true and nextpill.removes==1 and c.stage==n)
            end
            assert(p.advances==16)
        ''')

    def test_regeneration_saves_remaining_time_and_load_does_not_reheal(self):
        self.lua.execute('''
            local Effects=require("components/ttk_alchemy_effects")
            now=100; GetTime=function() return now end
            function owner()
                local p=entity("wilson"); p.healed=0; p.sanity=0
                p.components.health={IsDead=function() return false end,DoDelta=function(_,v) p.healed=p.healed+v end}
                p.components.sanity={DoDelta=function(_,v) p.sanity=p.sanity+v end}
                function p:DoPeriodicTask(t,fn) return self:DoTaskInTime(t,fn) end
                return p,Effects(p)
            end
            local h,s="xd_dy_dmhsd_1","xd_dy_qxdhd_1"
            local p,e=owner(); assert(e:Apply(h) and e:Apply(s))
            local immediate=p.healed; assert(immediate==120)
            local saved=e:OnSave(); assert(saved.effects[h]==2400 and saved.effects[s]==2400,"regen deadline missing")
            now=130; saved=e:OnSave(); assert(saved.effects[h]==2370 and saved.effects[s]==2370)
            local q,f=owner(); f:OnLoad(saved)
            assert(q.healed==0,"load must not replay immediate heal")
            assert(f:OnSave().effects[h]==2370 and f:OnSave().effects[s]==2370)
            f.tasks[h].run(); f.tasks[s].run()
            assert(q.healed==15 and math.abs(q.sanity-6.666666666666667)<.00001)
            local oldtick,oldexpiry=f.tasks[h],f.expiry_tasks[h]
            assert(f:Apply(h)); assert(oldtick.cancel and oldexpiry.cancel)
            assert(q.healed==135 and f:OnSave().effects[h]==2400)
            oldtick.run(); assert(q.healed==135)
            f.expiry_tasks[h].run(); assert(f.active[h]==nil and f.active[s]~=nil)
            f.expiry_tasks[s].run(); assert(next(f:OnSave().effects)==nil)
        ''')

    def test_historical_claim_amount_reconciles_earned_and_purchased_perks(self):
        self.lua.execute('''
            local Core=require("achievement/ttk_achievement_core")
            local catalog=require("achievement/ttk_achievement_catalog")
            local id="food_meatballs"; local def=catalog.ById(id); assert(def.reward==2)
            local function load(amount,status)
                local c=Core.New({},function() return true end)
                c:Load({achievements={[id]={progress=def.target,status=status or "claimed",claimed_reward=amount}},
                    perks={levels={planar_damage=3}},earned=999,spent=999})
                return c
            end
            local c=load(8); assert(c.earned==8 and c.spent==6 and c:Balance()==2,"historical Star was rewritten")
            assert(c.achievements[id].claimed_reward==8 and c.levels.planar_damage==3)
            assert(c:PurchasePerk("planar_damage","next")); assert(c.spent==8 and c:Balance()==0)
            c:Load(c:GetSaveData()); assert(c.earned==8 and c.spent==8 and c.levels.planar_damage==4)
            for _,bad in ipairs({-1,0/0,math.huge,-math.huge,"8",{},true,1.5}) do
                local d=load(bad); assert(d.earned==2 and d.achievements[id].claimed_reward==2)
                assert(d.spent==2 and d.levels.planar_damage==1)
            end
            assert(load(nil).earned==2)
            local fresh=load(8,"completed_unclaimed"); assert(fresh.earned==0 and fresh.spent==0)
            assert(fresh:ClaimAchievement(id,"new")); assert(fresh.earned==2)
        ''')

    def test_repeat_milestone_migration_preserves_only_previous_claims(self):
        self.lua.execute('''
            local Core=require("achievement/ttk_achievement_core")
            for _,id in ipairs({"combat_mactusk","boss_fuelweaver","boss_ttk_boss_ziyunshadow"}) do
                local c=Core.New({},function() return true end)
                c:Load({achievements={[id]={progress=1,status="claimed",claimed_reward=8}}})
                local a=c.achievements[id]
                assert(a.status=="claimed" and a.progress==2 and a.claimed_reward==8 and c.earned==8)
                c:Load(c:GetSaveData()); assert(c.earned==8)
                c:Load({achievements={[id]={progress=1,status="completed_unclaimed",claimed_reward=8}}})
                assert(c.achievements[id].status=="locked" and c.earned==0)
                assert(not c:ClaimAchievement(id,"unearned"))
                c:Load({achievements={[id]={progress=0,status="claimed",claimed_reward=8}}})
                assert(c.earned==0)
            end
        ''')


if __name__ == "__main__":
    unittest.main()
