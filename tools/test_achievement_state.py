"""Contract/model and Lua 5.1 behavior checks for authoritative Pham Nhan state.

Runtime checks require lupa.lua51 (the audit runtime can be set via PYTHONPATH).
"""
from __future__ import annotations

import math
import re
import unittest
from copy import deepcopy
from pathlib import Path

from lupa.lua51 import LuaRuntime


MOD = Path(__file__).resolve().parents[1]
PERKS = MOD / "scripts" / "achievement" / "ttk_perk_catalog.lua"
CORE = MOD / "scripts" / "achievement" / "ttk_achievement_core.lua"
COMPONENT = MOD / "scripts" / "components" / "ttk_achievement_progress.lua"
REPLICA = MOD / "scripts" / "components" / "ttk_achievement_progress_replica.lua"
ACHIEVEMENTS = MOD / "scripts" / "achievement" / "ttk_achievement_catalog.lua"

REPEATABLE = {
    "planar_defense": .5, "planar_damage": 1, "critical_hit": .01,
    "critical_damage": .02, "lifesteal": .01, "scale": .01,
    "xp_multiplier": .05,
}
ABILITIES = {
    "fast_worker": 8, "mine_faster": 6, "chop_faster": 6,
    "fish_faster": 6, "cook_faster": 6, "warly_chef": 8,
    "trinket_owner": 12, "double_healed": 15, "double_pick": 20,
    "double_drop": 30, "build_cheaper": 35, "eternal_cage": 5,
    "easy_farm": 12, "icy_weed": 10,
}
CRAFT = {
    "ancient_builder": 15, "lunar_knight": 10, "pearl_bff": 8,
    "benevolent_mind": 8, "mad_scientist": 10, "celebrate": 5,
    "festive": 5, "christmas_gift": 8, "legendary_smith": 15,
    "pokeball": 12, "antique_shop": 8, "inherit_luoshen": 20,
    "inherit_sanxiao": 14, "inherit_shiji": 16, "inherit_jingwei": 14,
    "inherit_sudaji": 10, "inherit_hantianzun": 8, "inherit_wangmazi": 20,
}
RECIPES = {
    "inherit_luoshen": ["fence_gate_luoshen_item", "xd_luoshen_jihuaze", "xd_luoshen_jiangren", "xd_luoshen_huazhong", "xd_luoshen_liuguanghuafen", "xd_luoshen_yin", "xd_luoshen_huaxia", "fence_luoshen_item", "wall_luoshen_item", "xd_luoshen_dinghunxianglu"],
    "inherit_sanxiao": ["xd_yunxiao_hyjditem", "xd_yunxiao_fgfq", "xd_yunxiao_fls", "xd_yunxiao_fysz", "xd_yunxiao_ymsz", "xd_yunxiao_hyjdyqd", "xd_yunxiao_portable_spicer"],
    "inherit_shiji": ["xd_sj_bglxp", "xd_sj_bgygp", "xd_sj_by_builder", "xd_sj_kls", "xd_sj_tlsq", "xd_sj_cy_builder", "xd_sj_sxz", "xd_sj_xsydz"],
    "inherit_jingwei": ["xd_xuanyu", "xd_jingwei_blowdart", "xd_jingwei_fenice_builder", "xd_jingwei_fan", "xd_jingwei_hat", "turf_jingweitile", "xd_qianyu"],
    "inherit_sudaji": ["xd_sudaji_redlantern", "xd_sudaji_ywfh", "xd_qwsk", "xd_sudaji_sjpn", "xd_sudaji_tsmd"],
    "inherit_hantianzun": ["xd_htz_xyzzl", "xd_htz_sjcx", "xd_htz_tlz"],
    "inherit_wangmazi": ["xd_wmz_kjb", "xd_wmz_slxj", "xd_wmz_md1", "xd_wmz_md2", "xd_wmz_md3", "xd_wmz_md4", "xd_wmz_md5", "xd_wmz_md6", "xd_wmz_md7", "xd_wmz_md8"],
}


def band_price(level: int) -> int:
    if not 1 <= level <= 25:
        raise ValueError("level")
    return 2 if level <= 10 else 3 if level <= 15 else 4 if level <= 20 else 5


class Model:
    """Independent, deliberately tiny transaction oracle for edge cases."""
    def __init__(self, rewards={"a": 2, "b": 3}, apply=lambda *_: True):
        self.rewards, self.apply = rewards, apply
        self.ach = {key: {"progress": 0, "target": 1, "status": "locked"} for key in rewards}
        self.levels, self.unlocked, self.replays = {}, set(), {}
        self.earned = self.spent = 0

    def snapshot(self):
        return deepcopy((self.ach, self.levels, self.unlocked, self.replays, self.earned, self.spent))

    def advance(self, ident, amount):
        if ident not in self.ach or not isinstance(amount, (int, float)) or isinstance(amount, bool) or not math.isfinite(amount) or amount <= 0:
            return False, "invalid"
        row = self.ach[ident]
        if row["status"] == "claimed": return False, "claimed"
        row["progress"] = min(row["target"], row["progress"] + amount)
        if row["progress"] >= row["target"]: row["status"] = "completed_unclaimed"
        return True, row["status"]

    def claim(self, ident, request):
        if request in self.replays: return self.replays[request]
        if ident not in self.ach or self.ach[ident]["status"] != "completed_unclaimed": return False, "not_claimable"
        self.ach[ident]["status"] = "claimed"
        result = (True, self.rewards[ident])
        self.replays[request] = result
        self.earned += self.rewards[ident]
        return result

    def buy(self, ident, request):
        if request in self.replays: return self.replays[request]
        repeat = ident in REPEATABLE
        if not repeat and ident not in ABILITIES and ident not in CRAFT: return False, "unknown"
        level = self.levels.get(ident, 0)
        if repeat and level >= 25: return False, "max"
        if not repeat and ident in self.unlocked: return False, "owned"
        price = band_price(level + 1) if repeat else (ABILITIES | CRAFT)[ident]
        if self.earned - self.spent < price: return False, "balance"
        before = self.snapshot()
        try: ok = self.apply(ident, level + 1)
        except Exception: ok = False
        if not ok:
            self.ach, self.levels, self.unlocked, self.replays, self.earned, self.spent = before
            return False, "apply"
        if repeat: self.levels[ident] = level + 1
        else: self.unlocked.add(ident)
        self.spent += price
        result = (True, price)
        self.replays[request] = result
        return result


class AchievementStateTests(unittest.TestCase):
    def test_exact_catalog_and_economics(self):
        source = PERKS.read_text(encoding="utf-8")
        self.assertEqual(39, len(re.findall(r'\bid\s*=\s*"', source)))
        self.assertEqual(7, source.count('group = "stats"'))
        self.assertEqual(14, source.count('group = "ability"'))
        self.assertEqual(18, source.count('group = "craft"'))
        for ident, value in REPEATABLE.items():
            self.assertIn(f'id = "{ident}"', source)
            self.assertIn(f'effect_per_level = {value}', source)
        for ident, price in ABILITIES.items() | CRAFT.items():
            self.assertRegex(source, rf'id = "{ident}"[\s\S]{{0,250}}price = {price}')
        self.assertEqual(80, sum(band_price(level) for level in range(1, 26)))
        self.assertEqual(560, 7 * 80)
        self.assertEqual(179, sum(ABILITIES.values()))
        self.assertEqual(206, sum(CRAFT.values()))
        self.assertEqual(945, 560 + 179 + 206)
        self.assertIn("function M.MaxCost()", source)
        self.assertIn("assert(M.MaxCost() == 945", source)

    def test_exact_inheritance_recipe_prefabs_and_tags(self):
        source = PERKS.read_text(encoding="utf-8")
        for ident, prefabs in RECIPES.items():
            block = source[source.index(f'id = "{ident}"'):]
            block = block[:block.index("},\n    {") if "},\n    {" in block else len(block)]
            self.assertRegex(block, r'builder_tag = "ttk_inheritance_[a-z]+"')
            self.assertEqual(prefabs, re.findall(r'"([a-z0-9_]+)"', re.search(r'recipes = \{([\s\S]*?)\n        \}', block).group(1)))
        self.assertIn('"xd_sj_kls"', source)
        self.assertNotIn("dai_thanh", source.lower())
        self.assertNotRegex(source.lower(), r"sinh.*diet|diet.*sinh")

    def test_price_bands_and_every_repeatable_cap(self):
        self.assertEqual([2] * 10 + [3] * 5 + [4] * 5 + [5] * 5, [band_price(level) for level in range(1, 26)])
        state = Model(); state.earned = 10000
        for ident in REPEATABLE:
            for number in range(25): self.assertTrue(state.buy(ident, f"{ident}-{number}")[0])
            self.assertEqual((False, "max"), state.buy(ident, f"{ident}-cap"))

    def test_progress_completion_claim_and_replay(self):
        state = Model()
        self.assertEqual((False, "not_claimable"), state.claim("a", "claim-a"))
        self.assertEqual((False, "invalid"), state.advance("missing", 1))
        self.assertEqual((False, "invalid"), state.advance("a", float("nan")))
        self.assertEqual((True, "completed_unclaimed"), state.advance("a", 3))
        self.assertEqual((True, 2), state.claim("a", "claim-a"))
        self.assertEqual((True, 2), state.claim("a", "claim-a"))
        self.assertEqual(2, state.earned)
        self.assertEqual((False, "not_claimable"), state.claim("a", "other-click"))

    def test_full_claim_economy_and_one_time_rules(self):
        state = Model({f"a{index}": 2 if index < 71 else 3 if index < 128 else 5 if index < 183 else 8 if index < 217 else 10 for index in range(231)})
        for ident in state.ach:
            state.advance(ident, 1); self.assertTrue(state.claim(ident, f"claim-{ident}")[0])
        self.assertEqual(1000, state.earned)
        self.assertEqual((False, "balance"), Model().buy("fast_worker", "low"))
        state.buy("fast_worker", "one"); self.assertEqual((False, "owned"), state.buy("fast_worker", "two"))

    def test_apply_failure_or_error_restores_exact_state(self):
        for apply in (lambda *_: False, lambda *_: (_ for _ in ()).throw(RuntimeError("boom"))):
            state = Model(apply=apply); state.earned = 100
            before = state.snapshot()
            self.assertEqual((False, "apply"), state.buy("fast_worker", "apply"))
            self.assertEqual(before, state.snapshot())

    def test_source_transaction_save_and_replica_contracts(self):
        core, component, replica = CORE.read_text(encoding="utf-8"), COMPONENT.read_text(encoding="utf-8"), REPLICA.read_text(encoding="utf-8")
        for signature in ("function Core:Advance(id, amount, evidence)", "function Core:ClaimAchievement(id, request_id)", "function Core:PurchasePerk(id, request_id)", "function Core:GetSnapshot()"):
            self.assertIn(signature, core)
        for required in ("IsFinite", "IsValidRequestId", "GetReplay", "StoreReplay", "pcall", "Restore", "ReapplyPurchased", "earned", "spent", "claimed_reward"):
            self.assertIn(required, core)
        self.assertIn("Catalog.ById(id)", core)
        self.assertNotIn("data.earned", core)
        self.assertNotIn("data.spent", core)
        self.assertIn("version = 1", component)
        self.assertIn("SerializeSnapshot", component)
        self.assertIn('PushEvent("ttk_achievement_dirty"', component)
        self.assertNotRegex(component, r"net_[a-z]+\([^\n]*achievement_[0-9]")
        self.assertIn("MAX_SNAPSHOT_BYTES", component)
        self.assertIn("DecodeSnapshot", replica)
        self.assertIn("MAX_SNAPSHOT_BYTES", replica)
        self.assertIn("function TtkAchievementProgressReplica:GetSnapshot()", replica)

    def test_achievement_catalog_is_the_only_reward_source(self):
        source = CORE.read_text(encoding="utf-8")
        self.assertIn('require("achievement/ttk_achievement_catalog")', source)
        self.assertNotRegex(source, r"reward\s*=\s*\d+")
        self.assertTrue(ACHIEVEMENTS.exists())

    def test_load_canonicalizes_malformed_nested_containers_without_indexing_them(self):
        """A corrupt nested table must not turn load into an indexing exception."""
        source = CORE.read_text(encoding="utf-8")
        self.assertIn('type(saved.levels) == "table"', source)
        self.assertIn('type(saved.unlocked) == "table"', source)
        self.assertIn('type(state.replays) == "table"', source)
        self.assertIn('type(state.achievements) == "table"', source)

    def test_replica_decodes_one_time_unlocks_and_repeatable_levels_by_catalog_shape(self):
        """A one-time perk must remain an unlock in the client shape, not level 1."""
        source = REPLICA.read_text(encoding="utf-8")
        self.assertIn('require("achievement/ttk_perk_catalog")', source)
        self.assertIn("PerkCatalog.ById(id)", source)
        self.assertIn("snapshot.perks.unlocked[id] = true", source)
        self.assertIn("snapshot.perks.levels[id] = level", source)

    def test_fractional_progress_round_trips_snapshot_replica_and_save_contract(self):
        """Finite fractional tracker amounts must not be truncated by either boundary."""
        state = Model()
        self.assertEqual((True, "locked"), state.advance("a", .25))
        self.assertEqual(.25, state.ach["a"]["progress"])
        core, component, replica = CORE.read_text(encoding="utf-8"), COMPONENT.read_text(encoding="utf-8"), REPLICA.read_text(encoding="utf-8")
        self.assertIn("IsFinite(progress)", core)
        self.assertIn("FormatNumber(state.progress)", component)
        self.assertIn("CanonicalNumber(value)", replica)
        self.assertNotIn("NonNegativeInteger(progress)", replica)


class AchievementLuaStateTests(unittest.TestCase):
    def setUp(self):
        self.lua = LuaRuntime(unpack_returned_tuples=True)
        self.lua.execute("package.path = ... .. package.path", (MOD / "scripts/?.lua").as_posix() + ";")
        self.lua.execute('''
            Core = require("achievement/ttk_achievement_core")
            Catalog = require("achievement/ttk_achievement_catalog")
            id = "food_liquid_luck_trinity"
            state = Core.New({})
        ''')

    def test_eater_adapter_normalizes_only_distinct_prefab_evidence(self):
        """Real Eat -> Route -> component -> Core must credit each luck tier once."""
        self.lua.execute('''
            GLOBAL = _G
            env = {}
            TheWorld = {ismastersim=true, state={season="spring"}}
            function Class(ctor)
                local cls = {}; cls.__index = cls
                return setmetatable(cls, {__call=function(_, inst)
                    local self = setmetatable({}, cls); ctor(self, inst); return self
                end})
            end
            function AddReplicableComponent() end
            function AddPlayerPostInit(fn) player_init = fn end
            function AddComponentPostInit() end
            function AddModRPCHandler() end
            function modimport() end
            function net_string() return {set=function() end} end
            local Progress = require("components/ttk_achievement_progress")
            player = {components={}, events={}, _ttk_achievement_perks={}}
            function player:IsValid() return true end
            function player:HasTag(tag) return tag == "player" end
            function player:ListenForEvent(event, fn)
                self.events[event] = self.events[event] or {}
                table.insert(self.events[event], fn)
            end
            function player:PushEvent(event, data)
                for _, fn in ipairs(self.events[event] or {}) do fn(self, data) end
            end
            function player:WatchWorldState() end
            function player:DoTaskInTime() end
            player.components.hunger = {IsStarving=function() return true end}
            player.components.eater = {inst=player, Eat=function(self, food)
                if food.reject then return false end
                self.inst:PushEvent("oneat", {food=food})
                self.inst:PushEvent("oneat", {food=food})
                food.prefab = nil -- removal must not discard the captured prefab
                return true
            end}
            progress = Progress(player)
            player.components.ttk_achievement_progress = progress
            local advance = progress.Advance
            ordinary_evidence = {}
            function progress:Advance(ident, amount, evidence)
                if ident ~= id then ordinary_evidence[ident] = evidence end
                return advance(self, ident, amount, evidence)
            end
        ''')
        self.lua.execute((MOD / "main/ttk_achievement.lua").read_text(encoding="utf-8"))
        self.lua.execute('''
            player_init(player)
            local eater = player.components.eater
            assert(not eater:Eat({prefab="nn_liquidluck_3", reject=true}))
            assert(progress.core.achievements[id] == nil)
            for _ = 1, 3 do assert(eater:Eat({prefab="nn_liquidluck"})) end
            local row = progress.core.achievements[id]
            assert(row ~= nil and row.progress == 1, "Eat luck I three times must credit one tier")
            assert(not progress:ClaimAchievement(id, "early-adapter"))
            assert(eater:Eat({prefab="nn_liquidluck_2"}))
            assert(progress.core.achievements[id].progress == 2)
            progress:OnLoad(progress:OnSave())
            assert(eater:Eat({prefab="nn_liquidluck_3"}))
            assert(progress.core.achievements[id].progress == 3, "Eat I+II+III must complete trinity")
            assert(progress:ClaimAchievement(id, "adapter-claim"))
            progress:OnLoad(progress:OnSave())
            assert(not progress:ClaimAchievement(id, "adapter-claim-again"))
            for _ = 1, 3 do assert(eater:Eat({prefab="meatballs"})) end
            assert(progress.core.achievements.food_meatballs.progress == 3)
            local evidence = ordinary_evidence.food_meatballs
            assert(type(evidence) == "table" and evidence.prefab == "meatballs" and evidence.starving)
            assert(eater:Eat({prefab="xd_danyao_jq"}))
            assert(progress.core.achievements.food_cultivation_pill_path == nil)
        ''')

    def test_distinct_food_evidence_round_trips_and_claims_once(self):
        self.lua.execute('''
            for _ = 1, 3 do state:Advance(id, 1, "nn_liquidluck") end
            assert(state.achievements[id].progress == 1, "luck I repeated must count once")
            assert(not state:ClaimAchievement(id, "early"))
            state:Advance(id, 1, "nn_liquidluck_2")
            assert(state.achievements[id].progress == 2)
            local saved = state:GetSaveData()
            assert(saved.achievements[id].seen_prefabs.nn_liquidluck == true)
            state = Core.New({}); state:Load(saved)
            assert(state.achievements[id].progress == 2)
            state:Advance(id, 1, "nn_liquidluck_3")
            assert(state.achievements[id].progress == 3)
            assert(state:ClaimAchievement(id, "claim"))
            assert(state.earned == 2)
            saved = state:GetSaveData()
            state = Core.New({}); state:Load(saved)
            assert(state.achievements[id].status == "claimed")
            assert(state:ClaimAchievement(id, "claim"))
            assert(not state:ClaimAchievement(id, "claim-again"))
            assert(not state:Advance(id, 100, "nn_liquidluck"))
            assert(state.earned == 2)
        ''')

    def test_bad_evidence_and_large_amount_cannot_inflate_distinct_progress(self):
        self.lua.execute('''
            assert(state:Advance(id, 100, "nn_liquidluck"))
            assert(state.achievements[id].progress == 1, "amount cannot multiply evidence")
            for _, evidence in ipairs({"unknown", false, 42, {}, {prefab="nn_liquidluck_2"},
                {nn_liquidluck_2=true}, {nn_liquidluck_2=false}, {nn_liquidluck_2={}}}) do
                assert(not state:Advance(id, 100, evidence), "bad evidence accepted")
                assert(state.achievements[id].progress == 1)
            end
            assert(not state:Advance(id, 100, nil))
            for _, amount in ipairs({0, -1, false, "100", {}, math.huge, 0/0}) do
                assert(not state:Advance(id, amount, "nn_liquidluck_2"))
            end
            state:Advance(id, 100, "nn_liquidluck")
            assert(state.achievements[id].progress == 1)
            state:Advance(id, 100, "nn_liquidluck_2")
            assert(state.achievements[id].progress == 2)
        ''')

    def test_load_uses_only_allowlisted_true_evidence_not_scalar_progress(self):
        self.lua.execute('''
            state:Load({achievements={[id]={progress=100, status="claimed", seen_prefabs={
                nn_liquidluck=true, nn_liquidluck_2=false, nn_liquidluck_3={nested=true},
                unknown=true, [1]=true}}}})
            local row = state:GetSaveData().achievements[id]
            assert(row.progress == 1 and row.status == "locked", "load must derive evidence count")
            assert(row.seen_prefabs.nn_liquidluck == true)
            local count = 0; for _ in pairs(row.seen_prefabs) do count = count + 1 end
            assert(count == 1 and state.earned == 0)
            for _, evidence in ipairs({false, 3, "nn_liquidluck", {}}) do
                state:Load({achievements={[id]={progress=3, status="claimed", seen_prefabs=evidence}}})
                assert(state.achievements[id] == nil or state.achievements[id].progress == 0)
                assert(state.earned == 0)
            end
            state:Load({achievements={[id]={progress=3, status="completed_unclaimed"}}})
            assert(not state:ClaimAchievement(id, "legacy"))
            state:Advance(id, 1, "nn_liquidluck_3")
            assert(state.achievements[id].progress == 1)
        ''')

    def test_quantity_objectives_keep_quantity_semantics(self):
        self.lua.execute('''
            state:Advance("collection_gems", 2, "redgem")
            state:Advance("collection_gems", 2, "redgem")
            assert(state.achievements.collection_gems.progress == 4)
            local saved = state:GetSaveData()
            state:Load(saved)
            assert(state.achievements.collection_gems.progress == 4)
            for _, row in ipairs(Catalog.All()) do
                assert(row.distinct == nil or row.id == id)
            end
        ''')

    def test_distinct_evidence_stays_off_snapshot_wire(self):
        self.lua.execute('''
            function Class(ctor)
                local cls = {}; cls.__index = cls
                return setmetatable(cls, {__call=function(_, inst)
                    local self = setmetatable({}, cls); ctor(self, inst); return self
                end})
            end
            local Progress = require("components/ttk_achievement_progress")
            local player = {ListenForEvent=function() end, PushEvent=function() end}
            local component = Progress(player)
            component:Advance(id, 1, "nn_liquidluck")
            local wire = component:PushSnapshot()
            assert(wire:find("food_liquid_luck_trinity:1:l", 1, true))
            assert(not wire:find("seen_prefabs", 1, true))
            assert(not wire:find("nn_liquidluck", 1, true))
            local achievements = wire:match(";a([^;]+)")
            for row in achievements:gmatch("[^,]+") do
                assert(row:match("^[%w_]+:[%d.]+:[lcu]$"), "achievement wire shape changed")
            end
        ''')


class SoulAuthorityTests(unittest.TestCase):
    def test_unified_level_load_orders_events_and_death_reload(self):
        lua = LuaRuntime(unpack_returned_tuples=True)
        lua.execute("package.path = ... .. package.path", (MOD / "scripts/?.lua").as_posix() + ";")
        lua.execute('''
            function Class(ctor)
                local cls = {}; cls.__index = cls
                return setmetatable(cls, {__call=function(_, inst)
                    local self = setmetatable({}, cls); ctor(self, inst); return self
                end})
            end
            local Souls = require("components/eva_souls")
            local function net()
                return {set=function(self, v) self.value = v end}
            end
            local function player()
                local p = {components={hh_leveling={level=1}, levelsystem={level=999},
                    health={IsDead=function() return false end}}, events={}, tasks={},
                    eva_level=net(), maxsouls=net(), currentsouls=net()}
                function p:ListenForEvent(event, fn) self.events[event] = fn end
                function p:RemoveEventCallback(event, fn)
                    if self.events[event] == fn then self.events[event] = nil end
                end
                function p:PushEvent(event, data)
                    if self.events[event] then self.events[event](self, data) end
                end
                function p:HasTag(tag) return tag == "playerghost" and self.ghost == true end
                function p:DoTaskInTime(_, fn)
                    local task = {fn=fn, Cancel=function(t) t.cancelled=true end}
                    table.insert(self.tasks, task); return task
                end
                function p:DoPeriodicTask(_, fn) return self:DoTaskInTime(1, fn) end
                function p:FlushTasks()
                    local tasks = self.tasks; self.tasks = {}
                    for _, t in ipairs(tasks) do if not t.cancelled then t.fn(self) end end
                end
                return p
            end
            for _, souls_first in ipairs({true, false}) do
                local p = player(); local souls = Souls(p)
                local saved = {level=151, current=400, maxsouls=1000, death_applied=false}
                if not souls_first then p.components.hh_leveling.level = 70 end
                souls:OnLoad(saved)
                if souls_first then p.components.hh_leveling.level = 70 end
                p:FlushTasks()
                assert(souls.level == 70 and souls:GetLevel() == 70, "saved soul level must not override hh_leveling")
                assert(souls.max == 514 and souls.current == 400)
                assert(p.eva_level.value == 70 and p.maxsouls.value == 514 and p.currentsouls.value == 400)
                p.components.hh_leveling.level = 71; p:PushEvent("hh_levelup")
                assert(souls.level == 71 and souls.max == 520, "hh_levelup must refresh immediately")
                p.components.levelsystem.level = 1000; p:PushEvent("chasni_levelup")
                assert(souls.level == 71)
                p.components.hh_leveling.level = 151; p:PushEvent("hh_levelup")
                assert(souls.max == 1000)
                souls.current = 257; souls:UpdateProgression(); assert(souls.current == 258)
                souls.current = 257; p:PushEvent("death"); p.ghost = true
                assert(souls.current == 25)
                local dead = souls:OnSave()
                assert(dead.level == 151 and dead.current == 25 and dead.death_applied)
                local restored = player(); restored.ghost = true
                restored.components.hh_leveling.level = 151
                local reloaded = Souls(restored); reloaded:OnLoad(dead); restored:FlushTasks()
                restored:PushEvent("death"); reloaded:UpdateProgression()
                assert(reloaded.current == 25 and reloaded._death_applied)
                restored.ghost = false; restored:PushEvent("ms_respawnedfromghost")
                reloaded:UpdateProgression(); assert(reloaded.current == 26)
                restored.components.hh_leveling.level = 70; restored:PushEvent("hh_levelup")
                assert(reloaded.level == 70 and reloaded.max == 514)
                reloaded:OnRemoveFromEntity()
                restored.components.hh_leveling.level = 80; restored:PushEvent("hh_levelup")
                assert(reloaded.level == 70)
            end
        ''')


if __name__ == "__main__":
    unittest.main(verbosity=2)
