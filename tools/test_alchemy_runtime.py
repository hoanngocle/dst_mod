"""Lua 5.1 behavior and source contracts for the approved Phàm Nhân pills.

Runtime checks require lupa.lua51 (the audit runtime can be set via PYTHONPATH).
"""

from pathlib import Path
import re
import unittest
import zipfile

import build_alchemy_defs as generator
from lupa.lua51 import LuaRuntime


ROOT = Path(__file__).resolve().parents[3]
MOD = ROOT / "mods" / "PhamNhanTuTien"
CATALOG = MOD / "scripts" / "alchemy" / "ttk_alchemy_defs.lua"
PREFAB = MOD / "scripts" / "prefabs" / "ttk_alchemy.lua"
EFFECTS = MOD / "scripts" / "components" / "ttk_alchemy_effects.lua"
MAIN = MOD / "main" / "ttk_alchemy.lua"
MODMAIN = MOD / "modmain.lua"
RULES = MOD / "scripts" / "alchemy" / "ttk_alchemy_rules.lua"
STATION = MOD / "scripts" / "components" / "ttk_alchemy_station.lua"

CULTIVATION = list(generator.CULTIVATION_PREFABS)
BUFFS = list(generator.BUFF_PREFABS)
ALL = [*CULTIVATION, "xd_danyao_bg", *BUFFS]
APPROVED = {
    "xd_dy_cyfxd_1": ("damage_mult", "multiplier = 1.4", "duration = 2400"),
    "xd_dy_dmhsd_1": ("health_regen", "immediate = 120", "interval = 6", "amount = 15", "duration = 2400"),
    "xd_dy_lmsqd_1": ("lightning_damage", "amount = 180", "duration = 2400"),
    "xd_dy_qxdhd_1": ("sanity_regen", "amount = 6.666666666666667", "duration = 2400"),
    "xd_dy_yfsxd_1": ("speed_mult", "multiplier = 1.25", "duration = 2400"),
    "xd_dy_pshsd_1": ("damage_reduction", "multiplier = 0.65", "duration = 2400"),
    "xd_dy_qjqsd_1": ("work_efficiency", "multiplier = 1.9", "duration = 2400"),
    "xd_dy_xynyd_1": ("cold_protection", "duration = 2400"),
    "xd_dy_hsphd_1": ("heat_protection", "duration = 2400"),
    "xd_dy_xttyd_1": ("lifesteal", "fraction = 0.5", "duration = 2400"),
    "xd_danyao_bg": ("hunger_rate", "multiplier = 0.2"),
}


class EffectModel:
    """A small independent model: refresh replaces one owned resource."""
    def __init__(self): self.active = {}
    def apply(self, prefab, deadline): self.active[prefab] = deadline
    def expire(self, prefab, now):
        if self.active.get(prefab, 0) <= now: self.active.pop(prefab, None)


class AttackModel:
    """Independent event model: lightning's nested hit is not a new credit."""
    def __init__(self):
        self.processing_auxiliary_hit = False
        self.bonus_hits = 0
        self.healing = 0

    def hit(self, damage, fail_auxiliary=False):
        if self.processing_auxiliary_hit:
            return
        self.healing += damage * .5
        self.processing_auxiliary_hit = True
        try:
            self.bonus_hits += 1
            if fail_auxiliary:
                raise RuntimeError("auxiliary damage failed")
            self.hit(180)
        finally:
            self.processing_auxiliary_hit = False

    @staticmethod
    def lifesteal(data):
        damage = data.get("damageresolved", data.get("damage"))
        return damage * .5 if isinstance(damage, (int, float)) and damage > 0 else 0


class FurnaceModel:
    """Independent contract model for deterministic furnace timing and delivery."""
    duration = 180

    @staticmethod
    def exact(items, recipe):
        totals = {}
        for prefab, amount in items:
            if (not isinstance(prefab, str) or not prefab or isinstance(amount, bool)
                    or not isinstance(amount, (int, float)) or amount <= 0
                    or amount != amount or amount in (float("inf"), float("-inf"))
                    or amount != int(amount)):
                return None
            totals[prefab] = totals.get(prefab, 0) + amount
        return "pill" if totals == recipe else None

    def __init__(self):
        self.output = None
        self.end = None
        self.consumed = 0
        self.deliveries = []

    def start(self, items, recipe, now):
        if self.output or self.exact(items, recipe) is None:
            return False
        self.consumed += 1
        self.output, self.end = "pill", now + self.duration
        return True

    def finish(self, give_item=True):
        if not self.output:
            return False
        output = self.output
        self.output = self.end = None
        self.deliveries.append((output, "container" if give_item else "ground"))
        return True

    def load(self, output, remaining, approved):
        if output not in approved or isinstance(remaining, bool) or not isinstance(remaining, (int, float)):
            return False
        self.output, self.end = output, max(0, remaining)
        return True


class AlchemyRuntimeTest(unittest.TestCase):
    def read(self, path): return path.read_text(encoding="utf-8")

    def alchemy_runtime(self):
        lua = LuaRuntime(unpack_returned_tuples=True)
        lua.execute("package.path = ... .. package.path", (MOD / "scripts" / "?.lua;").as_posix())
        defs = lua.eval('require("alchemy/ttk_alchemy_defs")')
        rules = lua.eval('require("alchemy/ttk_alchemy_rules")')
        return lua, defs, rules

    def test_all_26_recipes_match_current_inputs_and_reject_historical_inputs(self):
        """An obsolete generated ingredient makes its historical-input form craftable."""
        lua, defs, rules = self.alchemy_runtime()
        records = generator.read_records()
        self.assertEqual(len(records), 26)
        for output, record in records:
            with self.subTest(output=output):
                recipe = defs.GetRecipe(output)
                current = {row.prefab: row.amount for row in recipe.ingredients.values()}
                matched, actual = rules.FindExactRecipe(lua.table_from(current))
                self.assertEqual(actual, output)
                self.assertEqual(matched.output_count, record["recipe"]["outputCount"])
                historical = {}
                for row in record["recipe"]["ingredients"]:
                    prefab = row["id"].split(":", 1)[1]
                    historical[prefab] = historical.get(prefab, 0) + row["amount"]
                self.assertIsNone(rules.FindExactRecipe(lua.table_from(historical)))

    def test_stage_15_consumes_only_registered_first_grade_buffers(self):
        """Second-grade source pills are unavailable; stage 15 must use approved grade one."""
        lua, defs, _ = self.alchemy_runtime()
        ingredients = {row.prefab: row.amount for row in defs.GetCultivationStage(15).recipe.ingredients.values()}
        self.assertEqual(ingredients.get("xd_dy_pshsd_1"), 1)
        self.assertEqual(ingredients.get("xd_dy_xttyd_1"), 1)
        self.assertNotIn("xd_dy_pshsd_2", ingredients)
        self.assertNotIn("xd_dy_xttyd_2", ingredients)
        # Capture the names emitted by the real factory, without creating entities.
        lua.execute('Asset = function(...) return {} end; Prefab = function(name) return name end; MakePlacer = Prefab')
        registered = set(lua.execute(self.read(PREFAB)))
        self.assertTrue({"xd_dy_pshsd_1", "xd_dy_xttyd_1"} <= registered)
        self.assertFalse({"xd_dy_pshsd_2", "xd_dy_xttyd_2"} & registered)

    def test_every_emitted_ingredient_has_a_current_registered_provider(self):
        """A renamed ingredient must be exported by a loaded factory or supplied by DST."""
        lua, defs, _ = self.alchemy_runtime()
        lua.execute('Asset = function(...) return {} end; Prefab = function(name) return name end; MakePlacer = Prefab')
        providers = {
            "ttk_lingshi": ("modmain.lua",),
            "ttk_alchemy": ("modmain.lua",),
            "ttk_herbs": ("modmain.lua", "main/ttk_batch19_herbs.lua"),
            "ttk_batch19_houseitems": ("modmain.lua", "main/ttk_batch19_houses.lua"),
            "ttk_boss_cores": ("modmain.lua", "main/ttk_bosses.lua", "main/ttk_boss_food.lua"),
        }
        registered = set()
        for factory, chain in providers.items():
            # Protect the load path as well as the factory's actual return values.
            for parent, child in zip(chain, chain[1:]):
                self.assertRegex(self.read(MOD / parent), rf'modimport\s*\(?\s*"{re.escape(child)}"')
            self.assertIn('"' + factory + '"', self.read(MOD / chain[-1]))
            self.assertIn("PrefabFiles", self.read(MOD / chain[-1]))
            registered.update(lua.execute(self.read(MOD / "scripts" / "prefabs" / (factory + ".lua"))))

        # Native providers are audited against the installed game's loaded prefab
        # files, not references in arbitrary source, assets, loot, or recipe text.
        game = Path("C:/Program Files (x86)/Steam/steamapps/common/Don't Starve Together/data/databundles/scripts.zip")
        with zipfile.ZipFile(game) as archive:
            prefab_files = re.findall(r'"([a-z0-9_]+)"', archive.read("scripts/prefablist.lua").decode())
            sources = {name: archive.read(f"scripts/prefabs/{name}.lua").decode("utf-8-sig") for name in prefab_files}
        for source in sources.values():
            registered.update(re.findall(r'\bPrefab\(\s*["\']([a-z0-9_]+)["\']', source))
        # Three native families declare names through data-driven factories.
        veggies = sources["veggies"]
        self.assertRegex(veggies, r'Prefab\(name,\s*fn,')
        self.assertRegex(veggies, r'for veggiename,veggiedata in pairs\(VEGGIES\) do\s+local veggies = MakeVeggie\(veggiename,')
        registered.update(re.findall(r'\b([a-z0-9_]+)\s*=\s*MakeVegStats\(', veggies))
        mushrooms = sources["mushrooms"]
        self.assertIn("Prefab(data.pickloot, capfn", mushrooms)
        self.assertIn("MakeMushroom(v)", mushrooms)
        registered.update(re.findall(r'pickloot\s*=\s*"([a-z0-9_]+)"', mushrooms))
        gems = sources["gem"]
        self.assertIn('Prefab(colour..(precious and "preciousgem" or "gem")', gems)
        registered.update(colour + "gem" for colour in re.findall(r'buildgem\("([a-z]+)"\)', gems))

        for output, row in defs.by_prefab.items():
            for ingredient in row.recipe.ingredients.values():
                with self.subTest(output=output, ingredient=ingredient.prefab):
                    self.assertTrue(ingredient.prefab in registered, f"No registered provider for {ingredient.prefab}")
        for ingredient in defs.furnace.ingredients.values():
            self.assertIn(ingredient.prefab, registered)

    def test_exact_pills_are_registered_once_and_share_factory(self):
        """Omitting, duplicating, or registering an unapproved pill must fail."""
        source = self.read(PREFAB)
        self.assertEqual(re.findall(r'MakePill\("(xd_(?:danyao|dy)_[a-z0-9_]+)"', source), ALL)
        self.assertNotIn("xd_dy_fd", source)
        self.assertNotIn("xd_dy_tsfhd", source)
        self.assertEqual(source.count("MakePill"), 1 + len(ALL))
        self.assertIn('inst:AddTag("xd_danyao")', source)
        self.assertEqual(self.read(MODMAIN).count('"ttk_alchemy"'), 1)

    def test_catalog_has_explicit_approved_runtime_metadata_and_is_stable(self):
        """Changing effect values or reverting to prose-only effects must fail."""
        source = self.read(CATALOG)
        self.assertEqual(source, generator.render(generator.read_records()))
        for prefab, expected in APPROVED.items():
            row = re.search(rf'M\.by_prefab\["{prefab}"\] = \{{(?P<row>.*?)\n\}}', source, re.S)
            self.assertIsNotNone(row, prefab)
            for item in expected:
                self.assertIn(item, row.group("row"), prefab)

    def test_buff_dispatch_is_server_only_and_uses_owned_effect_component(self):
        """Client-side effects or bypassing the owned component must fail."""
        source = self.read(PREFAB)
        self.assertIn('not TheWorld.ismastersim', source)
        self.assertIn('ttk_alchemy_effects:Apply', source)
        self.assertIn('inst:AddComponent("ttk_alchemy_effects")', self.read(MAIN))

    def test_effect_source_has_idempotent_refresh_and_scoped_cleanup(self):
        """Stacking timers/listeners or clearing another pill's state must fail."""
        source = self.read(EFFECTS)
        self.assertIn('self:Remove(prefab)', source)
        self.assertIn('self.tasks[prefab]', source)
        self.assertIn('self.expiry_tasks[prefab]', source)
        self.assertIn('self.deadlines[prefab]', source)
        self.assertIn('self.listeners[prefab]', source)
        self.assertIn('RemoveEventCallback("onhitother", listener)', source)
        model = EffectModel(); model.apply("a", 10); model.apply("a", 20); model.apply("b", 10)
        self.assertEqual(model.active, {"a": 20, "b": 10})
        model.expire("a", 20); self.assertEqual(model.active, {"b": 10})

    def test_regen_combat_work_and_fasting_guards_are_present(self):
        """Applying after expiry, invalid damage, extra work actions, or stacked fasting fails."""
        source = self.read(EFFECTS)
        for token in ('IsDead()', 'damage <= 0', 'CHOP', 'MINE', 'HAMMER',
                      'burnratemodifiers:SetModifier', 'OnSave', 'OnLoad',
                      'VALID_KINDS', 'type(enabled) == "number"', 'math.min', 'math.max'):
            self.assertIn(token, source)
        self.assertNotIn('DIG', re.search(r'work_efficiency.*?end', source, re.S).group(0))

    def test_lightning_nested_hit_is_guarded_and_never_lifesteals_twice(self):
        """Removing the shared guard would recurse and heal from its own +180 hit."""
        source = self.read(EFFECTS)
        self.assertIn('self.processing_auxiliary_hit', source)
        self.assertIn('pcall(target.components.combat.GetAttacked', source)
        self.assertRegex(source, r'(?s)pcall\(target\.components\.combat\.GetAttacked.*?self\.processing_auxiliary_hit = false')
        model = AttackModel()
        model.hit(100)
        self.assertEqual(model.bonus_hits, 1)
        self.assertEqual(model.healing, 50)
        with self.assertRaises(RuntimeError):
            model.hit(100, fail_auxiliary=True)
        self.assertFalse(model.processing_auxiliary_hit)

    def test_lifesteal_uses_positive_resolved_damage_once(self):
        """Using pre-mitigation damage would over-heal through armor or resistance."""
        source = self.read(EFFECTS)
        self.assertIn('local damage = data.damageresolved or data.damage', source)
        self.assertIn('components.health:DoDelta(damage * effect.fraction)', source)
        self.assertEqual(AttackModel.lifesteal({"damage": 100, "damageresolved": 40}), 20)
        self.assertEqual(AttackModel.lifesteal({"damage": 100, "damageresolved": 0}), 0)
        self.assertEqual(AttackModel.lifesteal({"damage": -10}), 0)

    def test_furnace_exact_recipe_normalizes_duplicate_stacks_only(self):
        """Removing exact matching would let incomplete, extra, or malformed inputs refine."""
        recipe = {"spidergland": 5, "stinger": 10}
        self.assertEqual(FurnaceModel.exact([("spidergland", 2), ("spidergland", 3), ("stinger", 10)], recipe), "pill")
        for items in ([('spidergland', 5)], [('spidergland', 5), ('stinger', 10), ('twigs', 1)],
                      [('unknown', 1), ('spidergland', 5), ('stinger', 10)], [('spidergland', 0), ('stinger', 10)],
                      [('spidergland', -1), ('stinger', 10)], [('spidergland', 1.5), ('stinger', 10)],
                      [('spidergland', float('inf')), ('stinger', 10)]):
            self.assertIsNone(FurnaceModel.exact(items, recipe))

    def test_furnace_start_is_atomic_busy_and_consumes_once(self):
        """Removing the busy guard or preflight would double-consume or accept an invalid job."""
        furnace = FurnaceModel()
        recipe = {"spidergland": 5, "stinger": 10}
        self.assertFalse(furnace.start([("spidergland", 5)], recipe, 0))
        self.assertEqual(furnace.consumed, 0)
        self.assertTrue(furnace.start([("spidergland", 5), ("stinger", 10)], recipe, 0))
        self.assertFalse(furnace.start([("spidergland", 5), ("stinger", 10)], recipe, 1))
        self.assertEqual((furnace.consumed, furnace.end), (1, 180))

    def test_furnace_finish_is_one_shot_and_falls_back_to_ground(self):
        """Delivering before clearing job state would allow duplicate/reentrant output."""
        furnace = FurnaceModel()
        self.assertTrue(furnace.start([("spidergland", 5), ("stinger", 10)], {"spidergland": 5, "stinger": 10}, 0))
        self.assertTrue(furnace.finish())
        self.assertEqual(furnace.deliveries, [("pill", "container")])
        furnace = FurnaceModel()
        self.assertTrue(furnace.start([("spidergland", 5), ("stinger", 10)], {"spidergland": 5, "stinger": 10}, 0))
        self.assertTrue(furnace.finish(give_item=False))
        self.assertFalse(furnace.finish(give_item=False))
        self.assertEqual(furnace.deliveries, [("pill", "ground")])

    def test_furnace_timing_save_load_and_expiry_are_deterministic(self):
        """Changing the 180-second boundary or trusting an invalid save output breaks recovery."""
        furnace = FurnaceModel()
        self.assertTrue(furnace.start([("spidergland", 5), ("stinger", 10)], {"spidergland": 5, "stinger": 10}, 0))
        self.assertEqual((furnace.end - 0, furnace.end - 1), (180, 179))
        loaded = FurnaceModel()
        self.assertTrue(loaded.load("pill", 90, {"pill"}))
        self.assertEqual((loaded.output, loaded.end), ("pill", 90))
        self.assertTrue(loaded.load("pill", -1, {"pill"}))
        self.assertEqual(loaded.end, 0)
        self.assertFalse(loaded.load("attacker_prefab", 90, {"pill"}))

    def test_furnace_source_contract_registers_server_validated_deterministic_station(self):
        """Omitting the station or moving validation to a client action leaves refining exploitable."""
        rules = self.read(RULES)
        station = self.read(STATION)
        prefab = self.read(PREFAB)
        main = self.read(MAIN)
        self.assertIn("FindExactRecipe", rules)
        self.assertIn("AlchemyDefs.GetRecipe", rules)
        self.assertIn("math.floor", rules)
        self.assertNotIn("math.random", rules)
        self.assertNotIn("xd_dy_fd", rules + station + prefab)
        for token in ("function AlchemyStation:Start", "function AlchemyStation:Finish", "OnSave", "OnLoad",
                      "DoTaskInTime", "remaining", "container:Close"):
            self.assertIn(token, station)
        self.assertIn('return { output = self.output, remaining = math.max(0, remaining) }', station)
        self.assertIn("OnFurnaceHammered", prefab)
        self.assertIn("station:IsBusy()", prefab)
        self.assertNotIn("HasSpaceFor", station)
        self.assertIn("container:GiveItem(item, nil, nil, false)", station)
        self.assertRegex(station, r'(?s)self\.output = nil.*?container:GiveItem\(item, nil, nil, false\)')
        self.assertIn('Prefab("xd_liandanlu"', prefab)
        self.assertIn('MakePlacer("xd_liandanlu_placer"', prefab)
        self.assertEqual(prefab.count('Prefab("xd_liandanlu"'), 1)
        self.assertEqual(prefab.count('MakePlacer("xd_liandanlu_placer"'), 1)
        self.assertIn('WidgetSetup("xd_liandanlu")', prefab)
        self.assertIn('containers.params.xd_liandanlu', main)
        self.assertIn('"anim/ui_xd_liandanlu_1x4.zip"', main)
        self.assertIn('AddRecipe2("xd_liandanlu"', main)
        for ingredient in ('Ingredient("goldnugget", 5)', 'Ingredient("cutstone", 3)',
                           'Ingredient("flint", 3)', 'Ingredient("ttk_lingshi1", 5)'):
            self.assertIn(ingredient, main)
        self.assertIn('not TheWorld.ismastersim', main)
        self.assertIn('station:Start(action.doer)', main)
        self.assertIn('function AlchemyStation:CanStart(doer)', station)
        self.assertIn('if not TheWorld.ismastersim or self:IsBusy() then return false end', station)
        self.assertIn('local recipe, output, pockets = self:GetRecipe(doer)', station)
        self.assertIn('AddComponentAction("SCENE", "container"', main)
        self.assertIn('inst:HasTag("ttk_alchemy_station")', main)
        self.assertIn('if right and inst:HasTag("ttk_alchemy_station") then table.insert(actions, refine) end', main)


if __name__ == "__main__":
    unittest.main(verbosity=2)
