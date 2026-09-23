"""Source-contract/model tests for Phàm Nhân's sequential cultivation state.

The standard test environment has no Lua runtime.  These tests model the
observable state-machine contract and audit the deliberately small Lua source;
they do not claim to execute the Lua component.
"""

from __future__ import annotations

import math
from pathlib import Path
import re
import unittest


ROOT = Path(__file__).resolve().parents[3]
DEFS = ROOT / "mods/PhamNhanTuTien/scripts/alchemy/ttk_alchemy_defs.lua"
COMPONENT = ROOT / "mods/PhamNhanTuTien/scripts/components/ttk_cultivation.lua"
ALCHEMY_MAIN = ROOT / "mods/PhamNhanTuTien/main/ttk_alchemy.lua"
MODMAIN = ROOT / "mods/PhamNhanTuTien/modmain.lua"


def cultivation_prefabs() -> list[str]:
    """Read the canonical ordered cultivation definitions used by the component."""
    rows = re.findall(
        r'M\.cultivation\[(\d+)\] = M\.by_prefab\["([^"]+)"\]',
        DEFS.read_text(encoding="utf-8"),
    )
    ordered = sorted((int(stage), prefab) for stage, prefab in rows)
    assert [stage for stage, _ in ordered] == list(range(1, 16))
    return [prefab for _, prefab in ordered]


CULTIVATION = cultivation_prefabs()


def valid_stage(value: object) -> bool:
    return (
        isinstance(value, (int, float))
        and not isinstance(value, bool)
        and math.isfinite(value)
        and value == math.floor(value)
    )


def load_stage(value: object) -> int:
    """Model the untrusted-save boundary: invalid is zero, valid is clamped."""
    if not valid_stage(value):
        return 0
    return max(0, min(15, int(value)))


def prefix_mask(stage: int) -> int:
    return (1 << stage) - 1


class CultivationModel:
    """A small model of the public component API, not a Lua execution harness."""

    def __init__(self) -> None:
        self.stage = 0
        self.consumed: set[str] = set()
        self.events: list[dict[str, object]] = []

    def can_consume(self, prefab: object) -> tuple[bool, str | None]:
        if not isinstance(prefab, str):
            return False, "invalid_prefab"
        if prefab in self.consumed:
            return False, "already_consumed"
        if self.stage == 15:
            return False, "max_stage"
        if prefab == CULTIVATION[self.stage]:
            return True, None
        if prefab in CULTIVATION:
            return False, "wrong_stage"
        return False, "invalid_prefab"

    def consume(self, prefab: object) -> tuple[bool, int | str]:
        allowed, reason = self.can_consume(prefab)
        if not allowed:
            return False, reason or "invalid_prefab"
        assert isinstance(prefab, str)
        self.stage += 1
        self.consumed.add(prefab)
        self.events.append({"stage": self.stage, "prefab": prefab})
        return True, self.stage

    def on_save(self) -> dict[str, int]:
        stage = load_stage(self.stage)
        return {"version": 1, "stage": stage, "consumed_mask": prefix_mask(stage)}

    def on_load(self, data: object) -> None:
        candidate = data.get("stage") if isinstance(data, dict) else None
        self.stage = load_stage(candidate)
        self.consumed = set(CULTIVATION[: self.stage])


class CultivationContractTests(unittest.TestCase):
    def test_fresh_state_is_zero_with_no_consumed_pills(self) -> None:
        """Initializing above zero would grant progression without a cultivation pill."""
        state = CultivationModel()
        self.assertEqual(state.stage, 0)
        self.assertEqual(state.consumed, set())

    def test_exact_first_pill_advances_once_and_emits_once(self) -> None:
        """Skipping the first transition or emitting twice misreports advancement."""
        state = CultivationModel()
        self.assertEqual(state.consume(CULTIVATION[0]), (True, 1))
        self.assertEqual(state.stage, 1)
        self.assertEqual(state.consumed, {CULTIVATION[0]})
        self.assertEqual(state.events, [{"stage": 1, "prefab": CULTIVATION[0]}])

    def test_all_fifteen_pills_advance_in_order_and_stop(self) -> None:
        """An off-by-one stage limit would omit a pill or allow a sixteenth advance."""
        state = CultivationModel()
        for stage, prefab in enumerate(CULTIVATION, start=1):
            self.assertEqual(state.consume(prefab), (True, stage))
        self.assertEqual(state.stage, 15)
        self.assertEqual(len(state.events), 15)
        self.assertEqual(state.consume("not_another_cultivation_pill"), (False, "max_stage"))
        self.assertEqual(len(state.events), 15)

    def test_future_pill_rejects_without_mutating_state(self) -> None:
        """Allowing a known later pill would bypass the ordered progression contract."""
        state = CultivationModel()
        self.assertEqual(state.consume(CULTIVATION[1]), (False, "wrong_stage"))
        self.assertEqual((state.stage, state.consumed, state.events), (0, set(), []))

    def test_previous_pill_rejects_without_mutating_state(self) -> None:
        """Accepting a consumed pill would duplicate progression or advancement events."""
        state = CultivationModel()
        state.consume(CULTIVATION[0])
        self.assertEqual(state.consume(CULTIVATION[0]), (False, "already_consumed"))
        self.assertEqual((state.stage, state.consumed, len(state.events)), (1, {CULTIVATION[0]}, 1))

    def test_unknown_or_nonstring_prefab_is_invalid_without_mutation(self) -> None:
        """Treating buff or malformed values as progression corrupts cultivation state."""
        state = CultivationModel()
        for prefab in ("xd_dy_cyfxd_1", "not_a_pill", None, 7, True):
            self.assertEqual(state.consume(prefab), (False, "invalid_prefab"))
        self.assertEqual((state.stage, state.consumed, state.events), (0, set(), []))

    def test_save_uses_a_canonical_prefix_mask(self) -> None:
        """Unchecked in-memory stages would serialize corrupt or non-prefix save data."""
        state = CultivationModel()
        for prefab in CULTIVATION[:4]:
            state.consume(prefab)
        self.assertEqual(state.on_save(), {"version": 1, "stage": 4, "consumed_mask": 15})
        for stage, expected in (
            (1.5, 0),
            (float("nan"), 0),
            (float("inf"), 0),
            (float("-inf"), 0),
            (-3, 0),
            (True, 0),
            ("4", 0),
            (19, 15),
        ):
            state.stage = stage  # type: ignore[assignment]
            self.assertEqual(
                state.on_save(),
                {"version": 1, "stage": expected, "consumed_mask": prefix_mask(expected)},
                stage,
            )

    def test_save_load_preserves_every_canonical_prefix(self) -> None:
        """A load/save mismatch would lose or invent a valid completed prefix."""
        for stage in range(16):
            source = CultivationModel()
            for prefab in CULTIVATION[:stage]:
                source.consume(prefab)
            restored = CultivationModel()
            restored.on_load(source.on_save())
            self.assertEqual(restored.stage, stage)
            self.assertEqual(restored.consumed, set(CULTIVATION[:stage]))

    def test_load_clamps_valid_bounds_and_rejects_invalid_stage_values(self) -> None:
        """Trusting fractions, booleans, or non-finite saves would corrupt stage ordering."""
        for saved, expected in ((-3, 0), (19, 15), (0, 0), (15, 15)):
            state = CultivationModel()
            state.on_load({"stage": saved})
            self.assertEqual(state.stage, expected)
        for saved in (1.5, True, float("nan"), float("inf"), float("-inf"), "4", None):
            state = CultivationModel()
            state.on_load({"stage": saved})
            self.assertEqual(state.stage, 0, saved)

    def test_load_rebuilds_prefix_and_ignores_untrusted_consumed_claims(self) -> None:
        """Trusting saved IDs or bits would create an impossible non-prefix state."""
        state = CultivationModel()
        state.on_load({
            "stage": 3,
            "consumed": {CULTIVATION[12]: True},
            "consumed_mask": (1 << 14),
        })
        self.assertEqual(state.stage, 3)
        self.assertEqual(state.consumed, set(CULTIVATION[:3]))

    def test_lua_source_uses_canonical_defs_and_isolated_state(self) -> None:
        """Replacing ordered definitions or touching level state breaks cultivation isolation."""
        self.assertTrue(COMPONENT.is_file(), "missing ttk_cultivation component")
        source = COMPONENT.read_text(encoding="utf-8") if COMPONENT.exists() else ""
        self.assertRegex(source, r'local Defs = require\("alchemy/ttk_alchemy_defs"\)')
        self.assertRegex(source, r"Defs\.GetCultivationStage\(self\.stage \+ 1\)")
        for method in ("CanConsume", "Consume", "GetStage", "OnSave", "OnLoad"):
            self.assertRegex(source, rf"function TtkCultivation:{method}\(")
        self.assertRegex(source, r'PushEvent\("ttk_cultivation_advanced", \{stage=self\.stage, prefab=prefab\}\)')
        on_save = re.search(
            r"function TtkCultivation:OnSave\(\)(?P<body>.*?)\nend",
            source,
            re.DOTALL,
        )
        self.assertIsNotNone(on_save)
        self.assertRegex(on_save.group("body"), r"local stage = NormalizeStage\(self\.stage\)")
        self.assertRegex(on_save.group("body"), r"stage = stage,")
        self.assertRegex(on_save.group("body"), r"consumed_mask = PrefixMask\(stage\)")
        for forbidden in ("hh_leveling", "EXP", "AP", "Achievement & Level"):
            self.assertNotIn(forbidden, source)

    def test_registration_imports_once_and_adds_component_once_on_master(self) -> None:
        """Duplicate or client-side registration would desync player cultivation saves."""
        self.assertTrue(ALCHEMY_MAIN.is_file(), "missing cultivation registration module")
        main_source = ALCHEMY_MAIN.read_text(encoding="utf-8") if ALCHEMY_MAIN.exists() else ""
        modmain_source = MODMAIN.read_text(encoding="utf-8")
        self.assertEqual(modmain_source.count('modimport("main/ttk_alchemy.lua")'), 1)
        self.assertEqual(main_source.count("AddPlayerPostInit("), 1)
        self.assertEqual(main_source.count('inst:AddComponent("ttk_cultivation")'), 1)
        self.assertRegex(main_source, r"if not TheWorld\.ismastersim then\s*return\s*end")
        self.assertRegex(main_source, r"if inst\.components\.ttk_cultivation == nil then")


if __name__ == "__main__":
    unittest.main(verbosity=2)
