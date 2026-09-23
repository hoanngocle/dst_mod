"""Stdlib contracts and independent transaction model; no DST/Lua VM required.

The model checks ordering and failure semantics, not execution of shipped Lua.
Source contracts bind those boundaries to Lua; an in-game smoke test is still needed.
"""
from collections import Counter, OrderedDict
from copy import deepcopy
from pathlib import Path
import random
import re
import unittest

from test_achievement_catalog import balanced, field, param_text

MOD = Path(__file__).resolve().parents[1]
CATALOG = MOD / "scripts/achievement/ttk_seasonal_catalog.lua"
REWARDS = MOD / "scripts/achievement/ttk_seasonal_rewards.lua"
CORE = MOD / "scripts/achievement/ttk_achievement_core.lua"
COMPONENT = MOD / "scripts/components/ttk_achievement_progress.lua"
SEASONS = ("spring", "summer", "autumn", "winter")
EXPECTED = {
    "spring": {5: [("ttk_lc_lmg_seed", 3)], 10: [("ttk_lc_lmg_seed", 5), ("ttk_lingshi1", 10)], 15: [("ttk_lingshi2", 2), ("yellowgem", 1)], 20: [("ttk_lingshi3", 1), ("goose_feather", 1)]},
    "summer": {5: [("ttk_lc_cyh_seed", 3)], 10: [("ttk_lc_cyh_seed", 5), ("ttk_lingshi1", 10)], 15: [("ttk_lingshi2", 2), ("orangegem", 1)], 20: [("ttk_lingshi3", 1), ("dragon_scales", 1)]},
    "autumn": {5: [("ttk_lc_qfx_seed", 3)], 10: [("ttk_lc_qfx_seed", 5), ("ttk_lingshi1", 10)], 15: [("ttk_lingshi2", 2), ("greengem", 1)], 20: [("ttk_lingshi3", 1), ("bearger_fur", 1)]},
    "winter": {5: [("ttk_lc_hsc_seed", 3)], 10: [("ttk_lc_hsc_seed", 5), ("ttk_lingshi1", 10)], 15: [("ttk_lingshi2", 2), ("bluegem", 1)], 20: [("ttk_lingshi3", 1), ("deerclops_eyeball", 1)]},
}


def rows(source):
    start = source.index("local definitions = {")
    outer, _ = balanced(source, source.index("{", start))
    result, index = [], 1
    while index < len(outer) - 1:
        if outer[index] == "{":
            record, index = balanced(outer, index)
            result.append({key: field(record, key) for key in ("id", "season", "kind", "name", "description", "event", "target", "max_claims")} | {"params": param_text(record)})
        else:
            index += 1
    return result


class SeasonModel:
    """Independent executable specification of first claims and item transactions."""
    def __init__(self, definitions, season="spring", epoch="spring:1"):
        self.definitions = {r["id"]: r for r in definitions}
        self.season, self.epoch = season, epoch
        rng = random.Random(7)
        self.slots = []
        for kind, count in (("once", 16), ("repeat", 4)):
            pool = [r for r in definitions if r["season"] == season and r["kind"] == kind]
            for row in rng.sample(pool, count):
                self.slots.append({"task_id": row["id"], "progress": 0, "claims": 0})
        self.chests, self.replays, self.pending = set(), OrderedDict(), set()
        self.delivered, self.removed, self.xp = [], [], []

    @property
    def first_claims(self):
        return sum(s["claims"] > 0 for s in self.slots)

    def store(self, key, result):
        self.replays[key] = deepcopy(result)
        while len(self.replays) > 64:
            self.replays.popitem(last=False)
        return result

    def claim_task(self, index, request):
        if request in self.replays:
            return deepcopy(self.replays[request])
        slot = self.slots[index]
        definition = self.definitions[slot["task_id"]]
        if slot["claims"] >= int(definition["max_claims"]) or slot["progress"] < int(definition["target"]):
            return False
        slot["claims"] += 1
        slot["progress"] = 0
        self.xp.append((slot["task_id"], slot["claims"]))
        return self.store(request, True)

    def claim(self, season, milestone, request, *, master=True, missing=None, bundle=None,
              fail_stage=None, accept=True, callback=None):
        if not master or not isinstance(request, str) or not 0 < len(request) <= 96:
            return "invalid"
        if request in self.replays:
            return deepcopy(self.replays[request])
        if request in self.pending or self.pending:
            return "pending"
        if season != self.season or milestone not in (5, 10, 15, 20):
            return "invalid"
        if milestone in self.chests or self.first_claims < milestone:
            return "not_claimable"
        exact = EXPECTED[season][milestone]
        bundle = deepcopy(exact if bundle is None else bundle)
        if bundle != exact or any(p == missing or type(n) is not int or n <= 0 for p, n in bundle):
            return "preflight_failed"
        self.pending.add(request)
        staged = []
        for index, item in enumerate(bundle):
            if index == fail_stage:
                self.removed.extend(staged)
                self.pending.remove(request)
                return "staging_failed"
            staged.append(item)
        result = {"season": season, "milestone": milestone, "bundle": bundle}
        self.chests.add(milestone)
        self.store(request, result)
        for item in staged:
            if callback:
                callback()
            self.delivered.append(("inventory" if accept else (10, 0, 20), item))
        self.pending.remove(request)
        return deepcopy(result)

    def save(self):
        return deepcopy({"season": self.season, "epoch": self.epoch, "slots": self.slots,
                         "chests": self.chests, "replays": list(self.replays.items())})

    def load(self, saved):
        if not isinstance(saved, dict) or saved.get("season") not in SEASONS:
            return False
        slots, seen, counts = [], set(), Counter()
        for slot in saved.get("slots", []) if isinstance(saved.get("slots"), list) else []:
            if not isinstance(slot, dict): return False
            row = self.definitions.get(slot.get("task_id"))
            if row is None or row["season"] != saved["season"] or row["id"] in seen: return False
            seen.add(row["id"]); counts[row["kind"]] += 1
            claims = slot.get("claims", 0)
            progress = slot.get("progress", 0)
            claims = min(claims, int(row["max_claims"])) if type(claims) is int and claims >= 0 else 0
            progress = min(progress, int(row["target"])) if type(progress) in (int, float) and 0 <= progress < float("inf") else 0
            slots.append({"task_id": row["id"], "claims": claims, "progress": progress})
        if counts != {"once": 16, "repeat": 4}: return False
        self.season, self.epoch, self.slots = saved["season"], saved["epoch"], slots
        self.chests = {m for m in saved.get("chests", set()) if m in (5, 10, 15, 20) and m <= self.first_claims}
        self.replays = OrderedDict()
        for request, result in saved.get("replays", []):
            if isinstance(request, str) and 0 < len(request) <= 96:
                self.store(request, result)
        return True


class SeasonalTests(unittest.TestCase):
    def setUp(self):
        self.assertTrue(CATALOG.exists(), "missing canonical 200-row seasonal catalog")
        self.assertTrue(REWARDS.exists(), "missing fixed seasonal reward transactions")
        self.catalog = CATALOG.read_text(encoding="utf-8")
        self.rows = rows(self.catalog)

    def model(self, count=0):
        model = SeasonModel(self.rows)
        for slot in model.slots[:count]: slot["claims"] = 1
        return model

    def test_200_explicit_grounded_unique_rows(self):
        self.assertEqual(200, len(self.rows))
        self.assertEqual(list(SEASONS), list(dict.fromkeys(r["season"] for r in self.rows)))
        self.assertEqual(200, len({r["id"] for r in self.rows}))
        signatures = [(r["event"], re.sub(r"\s+", "", r["params"])) for r in self.rows]
        self.assertEqual(200, len(set(signatures)), "threshold-only variants are not different activities")
        for season in SEASONS:
            self.assertEqual(Counter(once=40, repeat=10), Counter(r["kind"] for r in self.rows if r["season"] == season))
        for row in self.rows:
            self.assertEqual("1" if row["kind"] == "once" else "5", row["max_claims"])
            self.assertGreater(int(row["target"]), 0)
            self.assertGreater(len(row["name"]), 3)
            self.assertGreater(len(row["description"]), 12)
            self.assertRegex(row["params"], r"prefab|action|starving")
            self.assertNotRegex(str(row).lower(), r"placeholder|generic|character|reviveplayer|givealltoplayer|task_\d+|mục \d+")
        self.assertEqual(200, len(re.findall(r'\bid\s*=\s*"', self.catalog)))

    def test_repeat_seed_activities_preserved(self):
        required = {
            "spring": ["wetgoop", "starving", "bee", "killerbee", "frog", "crawlinghorror", "butterfly", "NET", "flower", "TILL"],
            "summer": ["jammypreserves", "perogies", "mosquito", "rock_avocado_fruit", "HAMMER", "cave_banana_tree", "monkeytail", "cactus", "oasis_cactus", "ROW"],
            "autumn": ["honeyham", "honeynuggets", "trailmix", "crow", "robin", "deciduoustree", "CHOP", "grass", "sapling", "acorn"],
            "winter": ["kabobs", "meatballs", "bonestew", "robin_winter", "puffin", "penguin", "evergreen", "evergreen_sparse", "rock_ice", "lichen"],
        }
        for season, tokens in required.items():
            params = " ".join(r["params"] for r in self.rows if r["season"] == season and r["kind"] == "repeat")
            for token in tokens: self.assertRegex(params, rf'"{token}"|\b{token}\s*=')

    def test_draw_is_unique_16_4_and_reload_locked(self):
        for season in SEASONS:
            model = SeasonModel(self.rows, season)
            self.assertEqual(20, len({s["task_id"] for s in model.slots}))
            self.assertEqual(Counter(once=16, repeat=4), Counter(model.definitions[s["task_id"]]["kind"] for s in model.slots))
            saved = model.save()
            self.assertTrue(model.load(saved))
            self.assertEqual(saved, model.save())

    def test_all_16_exact_bundles_and_copy_boundary(self):
        source = REWARDS.read_text(encoding="utf-8")
        for season, milestones in EXPECTED.items():
            start = re.search(r"\b" + season + r"\s*=\s*{", source).end() - 1
            block, _ = balanced(source, start)
            for milestone, expected in milestones.items():
                start = re.search(r"\[" + str(milestone) + r"\]\s*=\s*{", block).end() - 1
                bundle, _ = balanced(block, start)
                self.assertEqual(expected, [(p, int(n)) for p, n in re.findall(r'prefab\s*=\s*"([a-z0-9_]+)"\s*,\s*amount\s*=\s*(\d+)', bundle)])
        self.assertRegex(source, r"function Rewards.GetBundle\(season, milestone\)[\s\S]*?return Copy\(")

    def test_repeat_five_xp_claims_only_one_chest_increment(self):
        model = self.model()
        for number in range(1, 6):
            model.slots[16]["progress"] = int(model.definitions[model.slots[16]["task_id"]]["target"])
            self.assertTrue(model.claim_task(16, f"xp-{number}"))
            self.assertTrue(model.claim_task(16, f"xp-{number}"))
            self.assertEqual(1, model.first_claims)
        self.assertFalse(model.claim_task(16, "sixth"))
        self.assertEqual(5, len(model.xp))

    def test_milestones_authority_validation_and_double_click(self):
        for milestone in (5, 10, 15, 20):
            model = self.model(milestone - 1)
            self.assertEqual("not_claimable", model.claim("spring", milestone, "early"))
            model.slots[milestone - 1]["claims"] = 1
            for season, mark, request, master in (("winter", milestone, "x", True), ("spring", 6, "x", True), ("spring", milestone, "", True), ("spring", milestone, "x", False)):
                self.assertEqual("invalid", model.claim(season, mark, request, master=master))
            result = model.claim("spring", milestone, "first")
            self.assertIsInstance(result, dict)
            self.assertEqual(result, model.claim("spring", milestone, "first"))
            self.assertEqual("not_claimable", model.claim("spring", milestone, "double"))
            self.assertEqual(len(EXPECTED["spring"][milestone]), len(model.delivered))

    def test_preflight_missing_prefab_invalid_amount_no_state_change(self):
        for options in ({"missing": "ttk_lingshi1"}, {"bundle": [("ttk_lc_lmg_seed", 0)]}, {"bundle": [("ttk_lc_lmg_seed", 999)]}):
            model = self.model(10); before = model.save()
            self.assertEqual("preflight_failed", model.claim("spring", 10, "request", **options))
            self.assertEqual(before, model.save()); self.assertFalse(model.delivered)

    def test_rollback_then_retry_and_full_inventory_fallback(self):
        model = self.model(10)
        self.assertEqual("staging_failed", model.claim("spring", 10, "request", fail_stage=1))
        self.assertEqual([("ttk_lc_lmg_seed", 5)], model.removed)
        self.assertFalse(model.chests or model.replays or model.pending or model.delivered)
        result = model.claim("spring", 10, "request", accept=False)
        self.assertEqual(result, model.claim("spring", 10, "request", accept=False))
        self.assertEqual([((10, 0, 20), ("ttk_lc_lmg_seed", 5)), ((10, 0, 20), ("ttk_lingshi1", 10))], model.delivered)

    def test_delivery_callback_cannot_duplicate_same_or_different_request(self):
        model = self.model(10); nested = []
        result = model.claim("spring", 10, "first", callback=lambda: nested.append((model.claim("spring", 10, "first"), model.claim("spring", 10, "second"))))
        self.assertEqual(2, len(model.delivered))
        self.assertTrue(all(a == result and b == "pending" for a, b in nested))

    def test_partial_save_load_and_malformed_canonicalization(self):
        model = self.model(10)
        model.claim("spring", 10, "saved")
        model.slots[16].update(claims=3, progress=2)
        saved = model.save(); restored = self.model()
        self.assertTrue(restored.load(saved)); self.assertEqual(saved, restored.save())
        self.assertEqual(model.replays["saved"], restored.claim("spring", 10, "saved"))
        corrupt = deepcopy(saved); corrupt["slots"][0]["task_id"] = "forged"
        self.assertFalse(restored.load(corrupt))
        corrupt = deepcopy(saved); corrupt["slots"][1] = corrupt["slots"][0]
        self.assertFalse(restored.load(corrupt))
        corrupt = deepcopy(saved); corrupt["slots"][0].update(progress=float("nan"), claims="5")
        self.assertTrue(restored.load(corrupt)); self.assertEqual(0, restored.slots[0]["claims"])
        self.assertEqual(0, restored.slots[0]["progress"])
        for index in range(100): restored.store(str(index), True)
        self.assertEqual(64, len(restored.replays))

    def test_lua_boundaries_transactions_and_canonical_save(self):
        core, rewards, component = (path.read_text(encoding="utf-8") for path in (CORE, REWARDS, COMPONENT))
        for signature in ("function Core:StartSeason(", "function Core:AdvanceSeasonal(", "function Core:ClaimSeasonal(", "function Core:ClaimChest(player, season, milestone, request_id)", "function Core:LoadSeasonal("):
            self.assertIn(signature, core)
        for marker in ("first_claims", "chest_claimed", "SeasonalCatalog.ById", "SeasonalCatalog.Draw", "self.seasonal_busy", "self.seasonal_pending", "xp_unavailable"):
            self.assertIn(marker, core)
        claim = core[core.index("local function CommitChest("):core.index("function Core:ClaimChest(")]
        self.assertLess(claim.index("Rewards.Preflight"), claim.index("self.seasonal_busy = true"))
        self.assertLess(claim.index("Rewards.Stage"), claim.index("state.chest_claimed[milestone] = true"))
        self.assertLess(claim.index("self:StoreSeasonalReplay"), claim.index("Rewards.Deliver"))
        for marker in ("function Rewards.Preflight", "function Rewards.Stage", "function Rewards.Deliver", "CanAcceptCount", "GiveItem", "SetPosition", "item:Remove()", "pcall"):
            self.assertIn(marker, rewards)
        self.assertIn("TheWorld.ismastersim", core)
        self.assertIn("player ~= self.inst", core)
        self.assertIn("self.core:ClaimChest(self.inst, season, milestone, request_id)", component)
        self.assertNotIn("CopyScalarTree(state.seasonal", component)
        self.assertIn("seasonal = Copy(self.seasonal)", core)
        for source in (self.catalog, core, rewards, component):
            self.assertNotRegex(source, r"AchievementLevel|seasonaltaskdata|allachiv_event|taskslot[1-6]|levelsystem")

    def test_fallback_position_is_prepared_before_commit_and_no_delivery_deletion(self):
        """A throwing first inventory callback must not strand later staged items at the origin."""
        source = REWARDS.read_text(encoding="utf-8")
        stage = source[source.index("function Rewards.Stage"):source.index("function Rewards.PlanDelivery")]
        self.assertIn("item.Transform:SetPosition(plan.x, plan.y, plan.z)", stage)
        deliver = source[source.index("function Rewards.Deliver"):]
        self.assertNotIn("item:Remove()", deliver)
        self.assertIn("pcall(function()", deliver)

    def test_live_fish_storage_uses_structure_build_evidence(self):
        row = next(r for r in self.rows if 'prefab="fish_box"' in r["params"])
        self.assertEqual("buildstructure", row["event"])
        self.assertIn("cá sống", row["description"])


if __name__ == "__main__":
    unittest.main(verbosity=2)
