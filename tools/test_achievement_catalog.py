"""Focused structural contract for the approved Pham Nhan achievement catalog."""
from __future__ import annotations

import re
import unittest
from collections import Counter
from pathlib import Path


MOD_ROOT = Path(__file__).resolve().parents[1]
CATALOG = MOD_ROOT / "scripts" / "achievement" / "ttk_achievement_catalog.lua"
GROUPS = [
    ("survival", 10), ("food", 40), ("collection", 33), ("labor", 11),
    ("crafting", 20), ("farming", 15), ("combat", 14), ("boss", 33),
    ("level_rank", 13), ("enhancement", 12), ("dungeon_guild", 12),
    ("seasonal", 8), ("gacha_shop", 10),
]
FOOD = {
    "food_liquid_luck_trinity": {"nn_liquidluck", "nn_liquidluck_2", "nn_liquidluck_3"},
    "food_cultivation_pill_path": {"xd_danyao_jq", "xd_danyao_dt", "xd_danyao_zj", "xd_danyao_xs", "xd_danyao_hj", "xd_danyao_yz", "xd_danyao_sm", "xd_danyao_rl", "xd_danyao_jy", "xd_danyao_yx", "xd_danyao_ns", "xd_danyao_hs", "xd_danyao_hy", "xd_danyao_hl", "xd_danyao_kx"},
    "food_fasting_pill": {"xd_danyao_bg"},
    "food_buff_cyfxd": {"xd_dy_cyfxd_1"}, "food_buff_dmhsd": {"xd_dy_dmhsd_1"},
    "food_buff_lmsqd": {"xd_dy_lmsqd_1"}, "food_buff_qxdhd": {"xd_dy_qxdhd_1"},
    "food_buff_yfsxd": {"xd_dy_yfsxd_1"}, "food_buff_pshsd": {"xd_dy_pshsd_1"},
    "food_buff_qjqsd": {"xd_dy_qjqsd_1"}, "food_buff_xynyd": {"xd_dy_xynyd_1"},
    "food_buff_hsphd": {"xd_dy_hsphd_1"}, "food_buff_xttyd": {"xd_dy_xttyd_1"},
    "food_boss_baihu": {"ttk_boss_core_baihu"}, "food_boss_jfsn": {"ttk_boss_core_jfsn"},
    "food_boss_qlch": {"ttk_boss_core_qlch"}, "food_boss_spiderqueen": {"ttk_boss_core_spiderqueen"},
    "food_boss_stalke": {"ttk_boss_core_stalke_fuben"}, "food_boss_deerclops": {"ttk_boss_core_deerclops_ziyun"},
}
REMOVED = [
    "season_all_missions", "Trọn Bộ Nhiệm Vụ Mùa", "Bàn Tay Xanh", "giant_crop",
    "dreadstone", "lunarplant", "voidcloth", "ice_bream", "scorching_sunfish",
    "bloomfin", "fallounder", "tame_beefalo", "khô lâu sơn", "kho_lau_son",
    "trap_kill", "burning_kill", "frozen_kill", "electric_kill", "bare_hand",
    "exploration", "caves", "ghost", "disciple", "maritime",
]


def balanced(text: str, start: int) -> tuple[str, int]:
    assert text[start] == "{"
    depth, quote, escaped = 0, None, False
    for index in range(start, len(text)):
        char = text[index]
        if quote:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == quote:
                quote = None
            continue
        if char in "\"'":
            quote = char
        elif char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
            if depth == 0:
                return text[start:index + 1], index + 1
    raise AssertionError("unbalanced Lua table")


def field(record: str, name: str) -> str:
    match = re.search(r"\b" + re.escape(name) + r"\s*=\s*(\"(?:\\.|[^\"])*\"|'(?:\\.|[^'])*'|-?\d+|true|false)", record)
    if not match:
        raise AssertionError(f"missing scalar {name}: {record[:100]}")
    return match.group(1).strip("\"'")


def param_text(record: str) -> str:
    match = re.search(r"\bparams\s*=\s*{", record)
    if not match:
        raise AssertionError("missing explicit params table")
    return balanced(record, match.end() - 1)[0]


def prefabs(params: str) -> set[str]:
    return set(re.findall(r"[\"']([A-Za-z0-9_]+)[\"']", params))


def records(source: str) -> list[dict[str, str]]:
    marker = source.index("local definitions = {")
    outer, _ = balanced(source, source.index("{", marker))
    result = []
    position = 1
    while position < len(outer) - 1:
        if outer[position] == "{":
            record, position = balanced(outer, position)
            if re.search(r"\bid\s*=", record):
                result.append({key: field(record, key) for key in ("id", "group", "name", "description", "tracker", "target", "reward", "status", "visibility")} | {"params": param_text(record)})
        else:
            position += 1
    return result


class AchievementCatalogTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.source = CATALOG.read_text(encoding="utf-8")
        cls.rows = records(cls.source)

    def test_exact_contract_totals_fields_and_distribution(self):
        self.assertEqual(231, len(self.rows))
        observed = [row["group"] for row in self.rows]
        self.assertEqual([name for name, _ in GROUPS], list(dict.fromkeys(observed)))
        self.assertEqual(sum(1 for before, after in zip(observed, observed[1:]) if before != after), len(GROUPS) - 1)
        self.assertEqual(dict(GROUPS), Counter(row["group"] for row in self.rows))
        self.assertEqual(Counter({"2": 71, "3": 57, "5": 55, "8": 34, "10": 14}), Counter(row["reward"] for row in self.rows))
        self.assertEqual(1000, sum(int(row["reward"]) for row in self.rows))
        for row in self.rows:
            self.assertRegex(row["id"], r"^[a-z][a-z0-9_]*$")
            self.assertGreater(int(row["target"]), 0)
            self.assertGreater(int(row["reward"]), 0)
            self.assertEqual("active", row["status"])
            self.assertEqual("visible", row["visibility"])
            self.assertGreater(len(row["name"].strip()), 3)
            self.assertGreater(len(row["description"].strip()), 8)

    def test_required_food_prefabs_are_exact(self):
        by_id = {row["id"]: row for row in self.rows}
        self.assertEqual(set(FOOD), set(identifier for identifier in by_id if identifier in FOOD))
        for identifier, expected in FOOD.items():
            self.assertEqual(expected, prefabs(by_id[identifier]["params"]), identifier)

    def test_progression_collection_and_crafting_milestones(self):
        by_id = {row["id"]: row for row in self.rows}
        self.assertEqual("xd_liandanlu", next(iter(prefabs(by_id["craft_alchemy_furnace"]["params"]))))
        expected_stones = {"ttk_lingshi1": 10000, "ttk_lingshi2": 10000, "ttk_lingshi3": 1000, "ttk_lingshi4": 100}
        owned = {next(iter(prefabs(row["params"]))): int(row["target"]) for row in self.rows if row["tracker"] == "own_prefab" and prefabs(row["params"]) & set(expected_stones)}
        self.assertEqual(expected_stones, owned)
        self.assertEqual({10, 20, 30, 50, 100}, {int(row["target"]) for row in self.rows if row["tracker"] == "level_reached"})
        expected_ranks = {"E": 1, "D": 10, "C": 20, "B": 30, "A": 40, "S": 50, "SS": 70, "SSS": 100}
        self.assertEqual(expected_ranks, {next(iter(prefabs(row["params"]))): int(row["target"]) for row in self.rows if row["tracker"] == "hunter_rank"})
        self.assertIn("season_first_mission", by_id)
        seasonal = [row for row in self.rows if row["group"] == "seasonal"]
        self.assertEqual({1, 5, 10, 15, 20}, {int(row["target"]) for row in seasonal if row["tracker"] == "season_mission_completed"})

    def test_no_placeholder_removed_or_duplicate_semantics(self):
        lowered = "\n".join(row["id"] + " " + row["name"] + " " + row["description"] + " " + row["params"] for row in self.rows).lower()
        for forbidden in REMOVED:
            self.assertNotIn(forbidden.lower(), lowered)
        for row in self.rows:
            self.assertNotRegex((row["id"] + row["name"] + row["description"]).lower(), r"todo|need|future|mục\\s*\\d+|placeholder")
            self.assertNotRegex((row["name"] + " " + row["description"]).lower(), r"\b(?:weapon|armor|bag|ring|relic|mission|shop|spin|buy)\s+(?:one|two|three|five|ten)\b")
        signatures = [(row["tracker"], re.sub(r"\\s+", "", row["params"]), row["target"]) for row in self.rows]
        self.assertEqual(len(signatures), len(set(signatures)))

    def test_runtime_lookup_and_validation_contracts_are_present(self):
        for contract in ("function Catalog.All()", "function Catalog.ById(id)", "function Catalog.ByEvent(event)", "function Catalog.Validate()"):
            self.assertIn(contract, self.source)
        self.assertIn("local seen,next_by_id,next_by_event", self.source)
        self.assertIn("by_id,by_event=next_by_id,next_by_event", self.source)
        self.assertNotRegex(self.source, r"(?:dofile|io\.|require)\s*\(?[^\n]*(?:achievement-level|AchievementLevel|2937640068)")

    def test_concrete_collection_crafting_and_farming_parameters_are_grounded(self):
        forbidden = {"grass", "gems", "moonrock", "prestihatitator", "shadow_manipulator", "cartographers_desk", "lightning_rod", "thermal_measurer", "football_hat", "endothermic_fire", "salt_box", "till_soil", "water_plants", "fertilize_plants", "harvest_crops"}
        by_id = {row["id"]: row for row in self.rows}
        for identifier in ("collection_grass", "collection_gems", "collection_moonrock", "crafting_prestihatitator", "crafting_shadow_manipulator", "crafting_cartographers_desk", "crafting_lightning_rod", "crafting_thermal_measurer", "crafting_football_hat", "crafting_endothermic_fire", "crafting_salt_box"):
            self.assertFalse(prefabs(by_id[identifier]["params"]) & forbidden, identifier)
        for row in self.rows:
            if row["group"] == "farming":
                self.assertNotIn("farming_event", row["tracker"])
                self.assertNotIn('prefab="plant_', row["params"])


if __name__ == "__main__":
    unittest.main(verbosity=2)
