"""Behavior tests for Phàm Nhân pure combat math and hit context."""
from pathlib import Path
import sys
import unittest


ROOT = Path(__file__).resolve().parents[1]
RUNTIME = ROOT.parents[1] / ".superpowers" / "solo-combat-audit" / "lua-runtime"
sys.path.insert(0, str(RUNTIME))
from lupa.lua51 import LuaRuntime


class CombatMathTests(unittest.TestCase):
    def setUp(self):
        self.lua = LuaRuntime(unpack_returned_tuples=True)
        self.lua.globals().package.path = (
            str(ROOT / "scripts/?.lua").replace("\\", "/")
            + ";"
            + self.lua.globals().package.path
        )
        self.math = self.lua.eval('require("combat/hh_combat_math")')
        self.context = self.lua.eval('require("combat/hh_combat_context")')

    def test_primary_resolution_applies_critical_and_single_burst_tier(self):
        # Changing either multiplier or the independent burst roll must fail this.
        rolls = iter((8,))
        result = self.math.ResolvePrimary(
            100,
            20,
            50,
            100,
            150,
            self.lua.table_from({"chance": 8, "multiplier": 5}),
            lambda low, high: next(rolls),
        )
        self.assertEqual(result["pre_crit"], 180)
        self.assertEqual(result["final"], 3150)
        self.assertEqual(result["critical"], True)
        self.assertEqual(result["critical_multiplier"], 3.5)
        self.assertEqual(result["burst"], True)
        self.assertEqual(result["burst_multiplier"], 5)

    def test_armor_pierce_and_reduction_respect_their_caps(self):
        # Changing either cap incorrectly changes a player-visible damage packet.
        self.assertTrue(callable(self.math.CalculateArmorPierce), "missing additive armor-pierce calculation")
        self.assertEqual(self.math.CalculateArmorPierce(1000, 40), 400)
        self.assertEqual(self.math.CalculateArmorPierce(1000, 90), 400)
        self.assertEqual(self.math.CalculateArmorPierce(1000, -5), 0)
        self.assertEqual(self.math.CalculateArmorPierce(1000, 0), 0)
        self.assertEqual(self.math.ApplyReduction(1000, 95), 200)

    def test_roll_percent_uses_the_boundary_and_only_rolls_when_needed(self):
        # A wrong inclusive boundary or eager RNG invocation changes proc outcomes.
        calls = []

        def rng(low, high):
            calls.append((low, high))
            return 1

        self.assertEqual(self.math.RollPercent(0, rng), False)
        self.assertEqual(calls, [])
        self.assertEqual(self.math.RollPercent(1, rng), True)
        self.assertEqual(calls, [(1, 100)])

        calls.clear()

        def misses_one_percent(low, high):
            calls.append((low, high))
            return 2

        self.assertEqual(self.math.RollPercent(1, misses_one_percent), False)
        self.assertEqual(calls, [(1, 100)])
        calls.clear()
        self.assertEqual(self.math.RollPercent(100, rng), True)
        self.assertEqual(calls, [])

    def test_lifesteal_budget_caps_each_event_and_rolling_second(self):
        # Omitting either cap permits excessive healing from one landed hit.
        state = self.lua.table()
        self.assertEqual(self.math.TakeLifestealBudget(state, 10, 500, 1000), 150)

        state = self.lua.table_from({"started_at": 10, "used": 850})
        self.assertEqual(self.math.TakeLifestealBudget(state, 10.5, 800, 1000), 50)

    def test_context_restores_nested_hits_and_removes_exact_tokens(self):
        # A shared flag or top-only pop would leak A→X and A→Y metadata.
        a = self.lua.table()
        x = self.lua.table()
        y = self.lua.table()
        outer = self.lua.table_from({"label": "outer"})
        inner = self.lua.table_from({"label": "inner"})

        outer_token = self.context.Begin(a, x, outer)
        self.assertEqual(self.context.Current(a, x)["label"], "outer")
        inner_token = self.context.Begin(a, y, inner)
        self.assertEqual(self.context.Current(a, y)["label"], "inner")
        self.assertEqual(self.context.Finish(inner_token)["label"], "inner")
        self.assertEqual(self.context.Current(a, x)["label"], "outer")

        inner_token = self.context.Begin(a, y, inner)
        self.assertEqual(self.context.Finish(outer_token)["label"], "outer")
        self.assertIsNone(self.context.Current(a, x))
        self.assertEqual(self.context.Current(a, y)["label"], "inner")
        self.assertEqual(self.context.Finish(inner_token)["label"], "inner")
        self.assertIsNone(self.context.Finish(outer_token))
        self.assertIsNone(self.context.Current(a, y))

    def test_packet_kind_is_scoped_through_success_and_error(self):
        # Failing to restore the packet kind would suppress unrelated later hits.
        self.lua.execute(
            r'''
local Context = require("combat/hh_combat_context")
assert(Context.PacketKind() == nil)
local first, second = Context.WithPacket("primary", function(a, b)
    assert(Context.PacketKind() == "primary")
    return a + b, "complete"
end, 2, 3)
assert(first == 5 and second == "complete")
assert(Context.PacketKind() == nil)

local ok, err = pcall(function()
    Context.WithPacket("poison", function()
        assert(Context.PacketKind() == "poison")
        error("packet boom")
    end)
end)
assert(not ok and string.find(err, "packet boom", 1, true) ~= nil)
assert(Context.PacketKind() == nil)
'''
        )


if __name__ == "__main__":
    unittest.main(verbosity=2)
