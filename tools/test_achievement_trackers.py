"""Server adapter source contracts and independent evidence model (not a Lua VM).

These tests catch boundary regressions; DST multiplayer smoke testing is still
required. Native/Lupa route coverage lives in test_achievement_reachability.py.
Event shapes were checked against the installed DST scripts.zip.
"""
from pathlib import Path
import re
import unittest

from test_achievement_catalog import records, FOOD
from test_seasonal_rewards import rows

MOD = Path(__file__).resolve().parents[1]
RUNTIME = MOD / "main/ttk_achievement.lua"


def valid_id(value, limit=96):
    return isinstance(value, str) and 0 < len(value) <= limit


class EvidenceModel:
    """Independent specification: identities, committed state, strict requests."""
    def __init__(self):
        self.progress, self.seen, self.awards = {}, set(), set()

    def eat(self, identity, prefab, *, success=True, committed=False):
        if not success or identity in self.seen:
            return
        self.seen.add(identity)
        for key, allowed in FOOD.items():
            if prefab in allowed and (key != "food_cultivation_pill_path" or committed):
                self.progress[key] = self.progress.get(key, 0) + 1

    def rpc(self, sender, owner, task_id, slot, request, *extra):
        return (sender is owner and valid_id(task_id, 80) and valid_id(request)
                and type(slot) is int and 1 <= slot <= 20 and not extra)

    def award(self, epoch, task, kind, number, key):
        if kind not in ("once", "repeat") or type(number) is not int:
            return False
        if not 1 <= number <= (1 if kind == "once" else 5):
            return False
        if key != f"{epoch}:{task}:{number}":
            return False
        self.awards.add(key)
        return True


class TrackerContracts(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.source = RUNTIME.read_text(encoding="utf-8") if RUNTIME.exists() else ""

    def block(self, name, next_name):
        self.assertIn("local function " + name, self.source)
        return self.source.split("local function " + name, 1)[1].split("local function " + next_name, 1)[0]

    def test_master_once_and_load_order(self):
        self.assertIn("_ttk_achievement_installed", self.source)
        self.assertIn("_ttk_achievement_registered", self.source)
        self.assertIn("TheWorld.ismastersim", self.source)
        self.assertEqual(self.source.count('AddComponent("ttk_achievement_progress")'), 1)
        self.assertNotIn('AddComponent("ttk_cultivation")', self.source)
        modmain = (MOD / "modmain.lua").read_text(encoding="utf-8")
        self.assertEqual(modmain.count('modimport("main/ttk_achievement.lua")'), 1)
        self.assertGreater(modmain.index('modimport("main/ttk_achievement.lua")'), modmain.index('modimport("main/ttk_solo_bootstrap.lua")'))

    def test_evidence_params_and_committed_cultivation(self):
        self.assertIn("AchievementCatalog.ByEvent(tracker)", self.source)
        self.assertIn("Matches(row.params, evidence)", self.source)
        cultivation = self.block("OnCultivation", "OnProgression")
        self.assertIn("cultivation:GetStage()", cultivation)
        self.assertIn("cultivation.consumed[row.prefab]", cultivation)
        self.assertIn('"food_cultivation_pill_path"', cultivation)
        self.assertIn("stage - progress", cultivation)
        eat = self.block("OnEat", "InstallEater")
        self.assertIn("data.food ~= context.food", eat)
        self.assertIn("context.observed", eat)
        wrapper = self.block("InstallEater", "OnCultivation")
        self.assertLess(wrapper.index("IsStarving()"), wrapper.index("pcall(previous"))
        self.assertIn("result == true and context.observed", wrapper)
        self.assertIn('row.id ~= "food_cultivation_pill_path"', self.source)

    def test_actual_level_and_rank_ignore_payload(self):
        body = self.block("OnProgression", "OnKilled")
        self.assertIn("leveling.level", body)
        self.assertIn("rank:GetRank()", body)
        self.assertNotIn("data.", body)
        self.assertIn("RankDefs.RANK", self.source)

    def test_completed_build_work_farm_item_and_owned_kills(self):
        for event in ("builditem", "buildstructure", "finishedwork", "picksomething", "tilling", "itemget", "death"):
            self.assertIn('"' + event + '"', self.source)
        self.assertIn("victim.components.health:IsDead()", self.source)
        self.assertIn("data.attacker ~= nil and data.attacker ~= killer", self.source)
        self.assertIn("follower:GetLeader()", self.source)
        self.assertIn("state.kills[victim]", self.source)
        self.assertIn("state.dead", self.source)
        self.assertIn("data.item.prefab", self.source)
        self.assertIn("data.action.id", self.source)

    def test_seasonal_params_epoch_and_xp_policy(self):
        self.assertIn("component:AdvanceSeasonal(row.id, amount, evidence)", self.source)
        self.assertIn("Matches(row.params, evidence)", self.source)
        self.assertIn("state.cycles - state.elapseddaysinseason", self.source)
        self.assertIn('WatchWorldState("season"', self.source)
        xp = self.block("ConfigureXP", "RefreshSeason")
        for contract in ("SetSeasonalXPCallback", "player ~= inst", "row.kind ~= kind", "slot.claims + 1", "claim_key ~= expected", "leveling:AddExp(SEASONAL_CLAIM_XP)"):
            self.assertIn(contract, xp)
        self.assertIn("local SEASONAL_CLAIM_XP = G.TUNING and G.TUNING.TTK_SEASONAL_CLAIM_XP", xp)
        self.assertIn('type(SEASONAL_CLAIM_XP) ~= "number"', xp)
        self.assertIn("SEASONAL_CLAIM_XP ~= SEASONAL_CLAIM_XP", xp)
        self.assertIn("SEASONAL_CLAIM_XP <= 0", xp)
        # Invalid configuration and durable XP idempotency are exercised through
        # the registered adapter in test_seasonal_rollover, including save/load.
        self.assertNotRegex(xp, r"SEASONAL_CLAIM_XP\s*=\s*\d|TTK_SEASONAL_CLAIM_XP\s+or\s+\d")
        self.assertEqual(self.source.count(":AddExp("), 1)

    def test_four_strict_rpc_boundaries(self):
        self.assertEqual(self.source.count("AddModRPCHandler("), 4)
        rpc = self.source.split("-- RPC boundary", 1)[-1]
        for contract in ('select("#", ...) ~= 0', "ResolveSender(sender)", "ValidRequest(request_id)", "ValidID(id)", "slot.task_id ~= id", "Integer(slot_index, 1, 20)", "CHEST_MILESTONES[slot_index]", "component.core:ClaimAchievement(id, request_id)", "component.core:PurchasePerk(id, request_id)", "component:ClaimSeasonal(slot.task_id, request_id)", "component:ClaimChest(seasonal.season, milestone, request_id)"):
            self.assertIn(contract, rpc)
        for forbidden in (":Advance(", ":AddExp(", "SpawnPrefab", "AddStar", "data.level", "data.reward"):
            self.assertNotIn(forbidden, rpc)
        self.assertIn("component.inst ~= sender", self.source)

    def test_inventory_receipts_follow_units_through_merges_and_splits(self):
        self.assertIn("local function CreditInventoryItem", self.source)
        self.assertIn("inventoryitem:GetGrandOwner()", self.source)
        self.assertIn("inventory.isloading", self.source)
        self.assertIn("amount - credited", self.source)
        self.assertIn('AddComponentPostInit("stackable"', self.source)
        self.assertIn("self.Get = function", self.source)
        self.assertIn("self.Put = function", self.source)
        self.assertIn('ListenForEvent("stacksizechange"', self.source)
        self.assertIn("CreditInventoryItem(data.item)", self.source)
        self.assertNotIn('Seen(state, "items", data)', self.source)

    def test_activity_receipts_do_not_use_animation_or_target_jumps(self):
        self.assertNotIn('ListenForEvent("fishingcatch"', self.source)
        self.assertIn('ListenForEvent("fishingcollect"', self.source)
        self.assertEqual(self.source.count('ListenForEvent("performaction"'), 1)
        ownership = self.block("ObserveOwnership", "QueueOwnership")
        self.assertIn('AchievementCatalog.ByEvent("own_prefab")', ownership)
        self.assertIn("amounts[row.params.prefab] or 0", ownership)
        self.assertNotIn("row.target,", ownership)
        self.assertNotIn("opencontainers", ownership)


class ReceiptModel:
    """Unit receipts survive stack entity replacement; no event-table identity."""
    def __init__(self, size, credited=0):
        self.size, self.credited = size, credited

    def receive(self, loading=False):
        delta = max(0, self.size - self.credited)
        self.credited = self.size
        return 0 if loading else delta

    def split(self, size):
        moved = min(self.credited, size)
        self.size -= size
        self.credited -= moved
        return ReceiptModel(size, moved)

    def merge(self, donor, room):
        moved = min(room, donor.size)
        received = min(donor.credited, moved)
        self.size += moved
        self.credited += received
        donor.size -= moved
        donor.credited -= received
        return self.receive()


class InventoryReceiptModels(unittest.TestCase):
    def test_new_slot_repeated_events_and_internal_transfers(self):
        item = ReceiptModel(10)
        self.assertEqual(item.receive(), 10)
        self.assertEqual(item.receive(), 0)  # fresh itemget table, same units
        self.assertEqual(item.receive(), 0)  # active slot -> bag -> slot
        split = item.split(4)
        self.assertEqual(split.receive(), 0)
        self.assertEqual(item.merge(split, 10), 0)

    def test_merge_new_units_partial_acceptance_and_leftovers(self):
        held, incoming = ReceiptModel(18, 18), ReceiptModel(7)
        self.assertEqual(held.merge(incoming, 2), 2)
        self.assertEqual((held.size, incoming.size), (20, 5))
        self.assertEqual(incoming.receive(), 5)
        self.assertEqual(held.receive(), 0)
        self.assertEqual(incoming.receive(), 0)

    def test_failed_pickup_loaded_inventory_and_consumed_units(self):
        item = ReceiptModel(12)
        self.assertEqual(item.receive(loading=True), 0)
        self.assertEqual(item.receive(), 0)
        # Eating/removing units clamps surviving receipts before a later merge.
        item.size = item.credited = 9
        self.assertEqual(item.merge(ReceiptModel(3), 11), 3)
        rejected = ReceiptModel(4)
        self.assertEqual(item.merge(rejected, 0), 0)
        self.assertEqual((rejected.size, rejected.credited), (4, 0))


class EvidenceModels(unittest.TestCase):
    def test_level_70_100_and_extended_rank_milestones(self):
        catalog = records((MOD / "scripts/achievement/ttk_achievement_catalog.lua").read_text(encoding="utf-8"))
        levels = {r["id"]: int(re.search(r"level\s*=\s*(\d+)", r["params"])[1])
                  for r in catalog if r["tracker"] == "level_reached"}
        # The approved catalog has five level rows, no separate level_70 row.
        self.assertEqual({key for key, threshold in levels.items() if threshold <= 70},
                         {"level_10", "level_20", "level_30", "level_50"})
        self.assertIn("level_100", {key for key, threshold in levels.items() if threshold <= 100})
        ranks = {r["id"]: int(r["target"]) for r in catalog if r["tracker"] == "hunter_rank"}
        self.assertEqual((ranks["rank_ss"], ranks["rank_sss"]), (70, 100))

    def test_kill_identity_owner_and_death_episode_dedupe(self):
        seen, player, other, victim = set(), object(), object(), object()
        def killed(source, attacker, target, dead, leader=None):
            if attacker is not None and attacker is not source:
                return False
            owner = source if source is player else leader
            if owner is not player or not dead or target in seen:
                return False
            seen.add(target)
            return True
        self.assertFalse(killed(other, other, victim, True))
        self.assertFalse(killed(player, other, victim, True))
        self.assertFalse(killed(player, None, victim, False))
        self.assertTrue(killed(other, other, victim, True, leader=player))
        self.assertFalse(killed(player, None, victim, True))
        self.assertFalse(killed(other, other, victim, True, leader=player))
        self.assertTrue(killed(player, None, object(), True))

    def test_slot_pair_and_seasonal_params_fail_closed(self):
        definitions = rows((MOD / "scripts/achievement/ttk_seasonal_catalog.lua").read_text(encoding="utf-8"))
        spider = next(row for row in definitions if row["id"] == "spring_spider")
        self.assertEqual(spider["event"], "killed")
        self.assertEqual(spider["params"], '{prefab="spider"}')
        slots = ["spring_spider", "spring_bee"]
        def claim_pair(index, task):
            return type(index) is int and 1 <= index <= len(slots) and slots[index - 1] == task
        self.assertTrue(claim_pair(1, "spring_spider"))
        self.assertFalse(claim_pair(2, "spring_spider"))
        self.assertFalse(claim_pair(1, "winter_pengull"))
        self.assertFalse(claim_pair(0, "spring_spider"))
        def matches(expected, observed):
            return all(observed.get(k) == v for k, v in expected.items())
        self.assertFalse(matches({"prefab": "spider"}, {"prefab": "spider_warrior"}))
        self.assertFalse(matches({"starving": True}, {"prefab": "meatballs", "starving": False}))
        self.assertTrue(matches({"action": "MINE", "prefab": "rock_ice"}, {"action": "MINE", "prefab": "rock_ice"}))

    def test_epoch_stays_locked_across_days_and_changes_on_transition(self):
        epoch = lambda season, cycle, elapsed: f"{season}:{max(0, cycle - elapsed)}"
        self.assertEqual(epoch("spring", 36, 1), "spring:35")
        self.assertEqual(epoch("spring", 41, 6), "spring:35")
        self.assertEqual(epoch("summer", 55, 0), "summer:55")
        self.assertNotEqual(epoch("spring", 106, 1), "spring:35")

    def test_all_exact_food_prefabs_and_consumption_replay(self):
        model = EvidenceModel()
        for key, allowed in FOOD.items():
            for prefab in allowed:
                token = object()
                model.eat(token, prefab, committed=True)
                model.eat(token, prefab, committed=True)
            self.assertEqual(model.progress[key], len(allowed))
        self.assertEqual(model.progress["food_cultivation_pill_path"], 15)
        self.assertEqual(sum(k.startswith("food_boss_") for k in model.progress), 6)
        model.eat(object(), "xd_dy_cyfxd_5")
        self.assertEqual(model.progress["food_buff_cyfxd"], 1)

    def test_uncommitted_and_failed_consumption_do_not_credit(self):
        model = EvidenceModel()
        model.eat(object(), "xd_danyao_jq")
        model.eat(object(), "xd_danyao_bg", success=False)
        self.assertEqual(model.progress, {})

    def test_forged_rpc_scalars_owner_and_extras_rejected(self):
        model, owner = EvidenceModel(), object()
        self.assertTrue(model.rpc(owner, owner, "spring_spider", 1, "opaque:1"))
        for bad in (None, {}, [], "", "a" * 97, float("nan"), True):
            self.assertFalse(model.rpc(owner, owner, "spring_spider", 1, bad))
        for bad in (0, 21, 1.5, "1", True, {}):
            self.assertFalse(model.rpc(owner, owner, "spring_spider", bad, "r"))
        self.assertFalse(model.rpc(object(), owner, "spring_spider", 1, "r"))
        for field in ("reward", "price", "progress", "target", "level", "player"):
            self.assertFalse(model.rpc(owner, owner, "spring_spider", 1, "r", {field: 999}))
        self.assertEqual(model.progress, {})

    def test_repeat_xp_stable_keys(self):
        model = EvidenceModel()
        for _ in range(2):
            self.assertTrue(model.award("spring:20", "spring_bee", "repeat", 1, "spring:20:spring_bee:1"))
        self.assertEqual(len(model.awards), 1)
        self.assertFalse(model.award("spring:20", "spring_bee", "repeat", 2, "forged"))
        self.assertFalse(model.award("spring:20", "spring_bee", "repeat", 6, "spring:20:spring_bee:6"))

    def test_catalog_evidence_has_no_unimplemented_seasonal_shapes(self):
        definitions = rows((MOD / "scripts/achievement/ttk_seasonal_catalog.lua").read_text(encoding="utf-8"))
        self.assertEqual({r["event"] for r in definitions}, {"oneat", "killed", "builditem", "buildstructure", "picksomething", "finishedwork", "tilling", "itemget", "deployitem", "rowing"})
        for row in definitions:
            self.assertLessEqual(set(re.findall(r"(\w+)\s*=", row["params"])), {"prefab", "action", "starving"})


if __name__ == "__main__":
    unittest.main()
