"""Catalog contract tests for the generated Phàm Nhân alchemy definitions."""

import copy
from collections import Counter
import json
import re
import unittest
from unittest.mock import patch

import build_alchemy_defs as generator
from test_support import MOD_ROOT


OUTPUT = MOD_ROOT / "scripts" / "alchemy" / "ttk_alchemy_defs.lua"

CULTIVATION = [
    "xd_danyao_jq", "xd_danyao_dt", "xd_danyao_zj", "xd_danyao_xs",
    "xd_danyao_hj", "xd_danyao_yz", "xd_danyao_sm", "xd_danyao_rl",
    "xd_danyao_jy", "xd_danyao_yx", "xd_danyao_ns", "xd_danyao_hs",
    "xd_danyao_hy", "xd_danyao_hl", "xd_danyao_kx",
]
BUFFS = [
    "xd_dy_cyfxd_1", "xd_dy_dmhsd_1", "xd_dy_lmsqd_1",
    "xd_dy_qxdhd_1", "xd_dy_yfsxd_1", "xd_dy_pshsd_1",
    "xd_dy_qjqsd_1", "xd_dy_xynyd_1", "xd_dy_hsphd_1",
    "xd_dy_xttyd_1",
]
FORBIDDEN = {"xd_dy_fd", "xd_dy_tsfhd"}
RUNTIME_KINDS = {
    "xd_dy_cyfxd_1": "damage_mult", "xd_dy_dmhsd_1": "health_regen",
    "xd_dy_lmsqd_1": "lightning_damage", "xd_dy_qxdhd_1": "sanity_regen",
    "xd_dy_yfsxd_1": "speed_mult", "xd_dy_pshsd_1": "damage_reduction",
    "xd_dy_qjqsd_1": "work_efficiency", "xd_dy_xynyd_1": "cold_protection",
    "xd_dy_hsphd_1": "heat_protection", "xd_dy_xttyd_1": "lifesteal",
    "xd_danyao_bg": "hunger_rate",
}

# Independently reviewed against the current factories, not inferred prefixes.
EXPECTED_RENAMES = {
    "xd_lingshi1": "ttk_lingshi1", "xd_lingshi2": "ttk_lingshi2", "xd_lingshi3": "ttk_lingshi3",
    "xd_lc_hsc": "ttk_lc_hsc", "xd_lc_dms": "ttk_lc_dms", "xd_lc_qfx": "ttk_lc_qfx",
    "xd_lc_cyh": "ttk_lc_cyh", "xd_lc_lmg": "ttk_lc_lmg", "xd_lc_yhh": "ttk_lc_yhh",
    "xd_npxsz": "ttk_npxsz", "xd_pog_tail": "ttk_pog_tail", "xd_spider_leg": "ttk_spider_leg",
}
# Task-19 controller-approved recipe changes; these are NOT identity aliases.
EXPECTED_SUBSTITUTIONS = {
    "xd_ayhx": "ttk_boss_core_stalke_fuben", "xd_aymg": "ttk_boss_core_stalke_fuben",
    "xd_baihu_skin": "ttk_boss_core_baihu", "xd_fs": "ttk_boss_core_jfsn",
    "xd_qlr": "ttk_boss_core_qlch", "xd_qianyu": "ttk_boss_core_deerclops_ziyun",
    "xd_mgqg": "ttk_boss_core_stalke_fuben", "xd_zcmy": "ttk_boss_core_deerclops_ziyun",
    "xd_dy_pshsd_2": "xd_dy_pshsd_1", "xd_dy_xttyd_2": "xd_dy_xttyd_1",
}
CURRENT_XD_INGREDIENTS = {"xd_dy_pshsd_1", "xd_dy_xttyd_1"}


class AlchemyCatalogTest(unittest.TestCase):
    def manual_items(self) -> dict:
        with generator.MANUAL_PATH.open(encoding="utf-8") as manual_file:
            return json.load(manual_file)["items"]

    def assert_manual_rejected(self, items: dict) -> None:
        with patch.object(generator.json, "load", return_value={"items": items}):
            with self.assertRaises(ValueError):
                generator.read_records()

    def assert_ingredients_valid(self, source: str) -> None:
        for prefab in [*CULTIVATION, *BUFFS, "xd_danyao_bg"]:
            match = re.search(
                rf'M\.by_prefab\["{prefab}"\] = \{{(?P<row>.*?)\n\}}',
                source,
                re.DOTALL,
            )
            self.assertIsNotNone(match, prefab)
            ingredient_block = re.search(
                r'ingredients = \{\n(?P<ingredients>.*?)\n    \},',
                match.group("row"),
                re.DOTALL,
            )
            self.assertIsNotNone(ingredient_block, prefab)
            ingredient_lines = [
                line.strip()
                for line in ingredient_block.group("ingredients").splitlines()
                if line.strip()
            ]
            ingredients = [
                re.fullmatch(r'\{ prefab="([^"]*)", amount=(-?\d+) \},', line)
                for line in ingredient_lines
            ]
            self.assertEqual(len(ingredients), len(ingredient_lines), prefab)
            self.assertGreaterEqual(len(ingredients), 1, prefab)
            self.assertLessEqual(len(ingredients), 4, prefab)
            for ingredient in ingredients:
                self.assertIsNotNone(ingredient, prefab)
                ingredient_prefab, amount = ingredient.groups()
                self.assertTrue(ingredient_prefab, prefab)
                self.assertGreater(int(amount), 0, prefab)

    def test_generated_catalog_has_only_approved_pills_and_valid_recipes(self):
        """Removing an approved pill or emitting a forbidden or empty recipe fails."""
        source = OUTPUT.read_text(encoding="utf-8")

        cultivation = re.findall(r'M\.cultivation\[\d+\] = M\.by_prefab\["([^"]+)"\]', source)
        buffs = re.findall(r'M\.buffs\["([^"]+)"\] = M\.by_prefab\["\1"\]', source)
        self.assertEqual(cultivation, CULTIVATION)
        self.assertEqual(buffs, BUFFS)
        self.assertIn('M.by_prefab["xd_danyao_bg"]', source)
        self.assertNotIn("xd_dy_fd", source)
        self.assertNotIn("xd_dy_tsfhd", source)

        self.assert_ingredients_valid(source)

    def test_every_historical_input_resolves_to_the_reviewed_current_ingredient(self):
        """A missing or guessed alias must not silently emit a non-existent ingredient."""
        expected = EXPECTED_RENAMES | EXPECTED_SUBSTITUTIONS
        historical = {row["id"].split(":", 1)[1]
                      for _, record in generator.read_records()
                      for row in record["recipe"]["ingredients"] if row["id"].startswith("tu_tien:xd_")}
        self.assertEqual(historical, set(expected))
        for source, current in expected.items():
            with self.subTest(source=source):
                self.assertEqual(generator.runtime_prefab("tu_tien:" + source), current)

    def test_generator_rejects_unmapped_historical_inputs(self):
        """A newly introduced source ingredient needs an explicit reviewed resolution."""
        for item_id in ("tu_tien:xd_unmapped", "base_game:xd_unmapped"):
            with self.subTest(item_id=item_id):
                items = self.manual_items()
                items["tu_tien:xd_danyao_jq"]["recipe"]["ingredients"][0]["id"] = item_id
                self.assert_manual_rejected(items)

    def test_generated_recipes_preserve_exact_mapped_amounts_and_outputs(self):
        """Mapping must neither lose ingredient amounts nor leave obsolete IDs behind."""
        source = generator.render(generator.read_records())
        expected_ids = EXPECTED_RENAMES | EXPECTED_SUBSTITUTIONS
        for output, record in generator.read_records():
            with self.subTest(output=output):
                row = re.search(rf'M\.by_prefab\["{output}"\] = \{{(.*?)\n\}}', source, re.S).group(1)
                emitted = re.findall(r'\{ prefab="([^"]+)", amount=(\d+) \}', row)
                expected = Counter()
                for ingredient in record["recipe"]["ingredients"]:
                    historical = ingredient["id"].split(":", 1)[1]
                    expected[expected_ids.get(historical, historical)] += ingredient["amount"]
                self.assertEqual(dict(emitted), {name: str(amount) for name, amount in expected.items()})
                self.assertEqual(len(emitted), len(expected))
                self.assertFalse({name for name, _ in emitted if name.startswith("xd_")} - CURRENT_XD_INGREDIENTS)
                self.assertFalse({name for name, _ in emitted} & {"ttk_boss_mgqg", "ttk_boss_zcmy"})
                self.assertIn(f"output_count = {record['recipe']['outputCount']},", row)
        self.assertEqual(source, generator.render(generator.read_records()))

    def test_committed_catalog_exactly_matches_generator_and_manual(self):
        """A stale checked-in Lua catalog must differ from fresh manual generation."""
        self.assertEqual(
            OUTPUT.read_text(encoding="utf-8"),
            generator.render(generator.read_records()),
        )

    def test_approved_runtime_metadata_is_machine_readable(self):
        """Replacing effect kinds with prose or omitting an approved kind must fail."""
        source = OUTPUT.read_text(encoding="utf-8")
        for prefab, kind in RUNTIME_KINDS.items():
            row = re.search(rf'M\.by_prefab\["{prefab}"\] = \{{(?P<row>.*?)\n\}}', source, re.DOTALL)
            self.assertIsNotNone(row, prefab)
            self.assertIn(f'effect = {{ kind = "{kind}"', row.group("row"), prefab)

    def test_generator_rejects_malformed_manual_scalars(self):
        """Malformed JSON scalars cannot reach Lua interpolation."""
        target = "tu_tien:xd_danyao_jq"
        cases = [
            ("boolean output count", lambda item: item["recipe"].__setitem__("outputCount", True)),
            ("zero output count", lambda item: item["recipe"].__setitem__("outputCount", 0)),
            ("string output count", lambda item: item["recipe"].__setitem__("outputCount", "1")),
            ("boolean amount", lambda item: item["recipe"]["ingredients"][0].__setitem__("amount", True)),
            ("zero amount", lambda item: item["recipe"]["ingredients"][0].__setitem__("amount", 0)),
            ("string amount", lambda item: item["recipe"]["ingredients"][0].__setitem__("amount", "1")),
            ("empty ingredient prefab", lambda item: item["recipe"]["ingredients"][0].__setitem__("id", "")),
            ("missing crafting note", lambda item: item["recipe"].__setitem__("craftingNote", None)),
            ("non-string crafting note", lambda item: item["recipe"].__setitem__("craftingNote", 1)),
            ("non-list effects", lambda item: item["usage"].__setitem__("effects", {})),
            ("non-mapping effect", lambda item: item["usage"].__setitem__("effects", ["bad"])),
            ("non-string trigger", lambda item: item["usage"]["effects"][0].__setitem__("trigger", 1)),
            ("non-string text", lambda item: item["usage"]["effects"][0].__setitem__("text", None)),
        ]
        for label, mutate in cases:
            with self.subTest(label=label):
                items = copy.deepcopy(self.manual_items())
                mutate(items[target])
                self.assert_manual_rejected(items)

    def test_lua_string_escapes_lua_control_characters(self):
        """Control characters must be emitted as Lua-safe escape sequences."""
        value = 'quote" slash\\ newline\n tab\t backspace\b formfeed\f vertical\v bell\a unit\x1f null\0 delete\x7f'
        expected = '"quote\\" slash\\\\ newline\\n tab\\t backspace\\b formfeed\\f vertical\\v bell\\a unit\\031 null\\000 delete\\127"'
        self.assertEqual(generator.lua_string(value), expected)

    def test_runtime_prefab_rejects_noncanonical_manual_ids(self):
        """Only one approved namespace and one canonical prefab segment are valid."""
        invalid_ids = (
            "bogus:spidergland",
            "base_game: spidergland ",
            "base_game:spidergland ",
            " base_game:spidergland",
            "base_game:foo:bar",
        )
        for item_id in invalid_ids:
            with self.subTest(item_id=item_id):
                with self.assertRaises(ValueError):
                    generator.runtime_prefab(item_id)

    def test_runtime_prefab_rejects_invalid_dst_prefab_characters(self):
        """Runtime prefabs only permit lowercase ASCII letters, digits, and underscores."""
        invalid_ids = (
            "base_game:spider gland",
            "base_game:spider\ngland",
            "base_game:spider\0gland",
            "base_game:Spidergland",
            "base_game:spider-gland",
            "base_game:spider.gland",
        )
        for item_id in invalid_ids:
            with self.subTest(item_id=item_id):
                with self.assertRaises(ValueError):
                    generator.runtime_prefab(item_id)

    def test_runtime_prefab_accepts_every_manual_ingredient_id(self):
        """The current manual catalog contains only valid DST runtime prefabs."""
        for prefab, record in generator.read_records():
            for ingredient in record["recipe"]["ingredients"]:
                with self.subTest(catalog_prefab=prefab, item_id=ingredient["id"]):
                    self.assertRegex(generator.runtime_prefab(ingredient["id"]), r"^[a-z0-9_]+$")

    def test_invalid_ingredient_row_is_rejected(self):
        """A malformed emitted row cannot be skipped by ingredient validation."""
        source = OUTPUT.read_text(encoding="utf-8")
        malformed = source.replace(
            '{ prefab="spidergland", amount=5 }',
            '{ prefab="", amount=0 }',
            1,
        )

        with self.assertRaises(AssertionError):
            self.assert_ingredients_valid(malformed)


if __name__ == "__main__":
    unittest.main()
