"""Stdlib integration contracts; these do not execute Lua or simulate DST."""
from pathlib import Path
import re
import unittest

MOD = Path(__file__).resolve().parents[1]


class PerkRuntimeTests(unittest.TestCase):
    def source(self, relative):
        path = MOD / relative
        self.assertTrue(path.is_file(), f"missing perk integration: {relative}")
        return path.read_text(encoding="utf-8")

    def test_provider_is_installed_before_reapply_on_master(self):
        src = self.source("main/ttk_achievement.lua")
        self.assertIn("PerkEffects.Install(inst)", src)
        self.assertIn("component:SetEffectCallback(PerkEffects.Apply)", src)
        self.assertIn("component:ReapplyPurchased()", src)

    def test_all_seven_stats_replace_provider_contributions(self):
        src = self.source("scripts/achievement/ttk_perk_effects.lua")
        for key in ("criticalHitRate", "criticalHitEffect", "bloodSuck", "planardefense", "planardamage", "xp_multiplier"):
            self.assertIn(key, src)
        self.assertIn("math.min(25", src)
        self.assertIn("AddBonus(inst,", src)
        self.assertIn("AnimState:SetScale", src)
        self.assertNotIn("Transform:SetScale", src)
        self.assertNotIn("SetRange", src)
        self.assertNotIn("SetCapsule", src)
        self.assertIn("ttk_achievement_", src)

    def test_hh_effects_provider_survives_equipment_recalculation(self):
        src = self.source("scripts/components/hh_player.lua")
        self.assertIn("ttk_achievement_effects", src)
        self.assertIn("GetEffectValueByKey", src)

    def test_kill_xp_has_one_rounding_after_all_factors(self):
        src = self.source("main/hh_api.lua")
        award = src.split("local function HHAwardKillExp", 1)[1].split("local function HHResolveSharkboi", 1)[0]
        self.assertIn("GetXPMultiplier(player)", award)
        self.assertIn("* rank_multiplier * exp_multiplier * achievement_multiplier / #recipients", award)
        self.assertEqual(1, award.count("math.floor"))
        self.assertNotIn("math.min", award)
        effects = self.source("scripts/components/hh_dungeon_effects.lua")
        exp = effects.split("function HHDungeonEffects:GetExpMultiplier", 1)[1].split("function HHDungeonEffects:GetMana", 1)[0]
        self.assertNotIn("math.min", exp)

    def test_ability_adapters_are_server_scoped_and_guard_duplicates(self):
        src = self.source("scripts/achievement/ttk_perk_effects.lua")
        hooks = self.source("main/ttk_achievement_perks.lua")
        for key in ("fast_worker", "mine_faster", "chop_faster", "fish_faster", "cook_faster", "warly_chef", "trinket_owner", "double_healed", "double_pick", "double_drop", "build_cheaper", "eternal_cage", "easy_farm", "icy_weed"):
            self.assertIn(key, src + hooks)
        self.assertIn("ismastersim", hooks)
        self.assertIn("_ttk_achievement_hook", hooks)
        self.assertIn("Seen", src)
        self.assertIn("efficientuser", src)
        self.assertNotIn("allachivcoin", src + hooks)

    def test_craft_packages_use_eva_only_catalog_tags_and_refresh(self):
        src = self.source("scripts/achievement/ttk_perk_effects.lua")
        self.assertIn('inst.prefab ~= "eva"', src)
        self.assertIn("perk.builder_tag", src)
        self.assertIn('PushEvent("refreshcrafting")', src)
        self.assertIn("CanUnlock", src)

    def test_modern_farm_bonus_uses_successful_deploy_and_actual_soil_api(self):
        src = self.source("main/ttk_achievement.lua")
        provider = self.source("scripts/achievement/ttk_perk_effects.lua")
        self.assertIn("PerkEffects.ApplyFertilizer", src)
        self.assertIn("AddTileNutrients", provider)
        self.assertIn("IsFarmableSoilAtPoint", provider)

    def test_recipe_ports_preserve_eight_safe_mappings_and_no_wangmazi_guess(self):
        src = self.source("scripts/achievement/ttk_perk_crafts.lua")
        aliases = src.split("local aliases = {", 1)[1].split("}", 1)[0]
        pairs = re.findall(r'(\w+) = "(\w+)"', aliases)
        self.assertEqual(8, len(pairs))
        self.assertIn(("xd_sj_kls", "ttk_sj_kls"), pairs)
        self.assertNotRegex(aliases, r"xd_wmz_|xd_jingwei_|xd_htz_")
        self.assertIn("Prefabs[recipe.product] == nil", src)

    def test_each_positive_ingredient_uses_native_discount_minimum(self):
        self.assertIn("green and .25 or .5", self.source("scripts/achievement/ttk_perk_effects.lua"))

    def test_skill_gated_native_recipes_are_rejected_before_any_alias_clone(self):
        """Walter's lunar ammo/frame must not become unusable EVA aliases."""
        src = self.source("scripts/achievement/ttk_perk_crafts.lua")
        clone = src.split("local function Clone(id, name, source)", 1)[1].split("-- Snapshot native", 1)[0]
        self.assertIn("if source.builder_skill ~= nil then return end", clone)
        self.assertLess(clone.index("source.builder_skill"), clone.index("G.deepcopy(source)"))
        self.assertNotIn("config.builder_skill = nil", clone)
        preflight = src.split("function M.CanUnlock", 1)[1].split("function M.Register", 1)[0]
        self.assertIn("recipe.builder_skill ~= nil", preflight)

    def test_structure_recipes_have_native_art_placement_prefabs(self):
        src = self.source("scripts/prefabs/ttk_achievement_placers.lua")
        names = re.findall(r'MakePlacer\("([^"]+)"', src)
        self.assertEqual(13, len(names))
        self.assertEqual(13, len(set(names)))
        self.assertIn('table.insert(PrefabFiles, "ttk_achievement_placers")', self.source("main/ttk_achievement_perks.lua"))

    def test_repeat_load_respawn_replace_same_source_not_additive_delta(self):
        src = self.source("scripts/achievement/ttk_perk_effects.lua")
        self.assertIn("inst.ttk_achievement_effects[key] = amount * 100", src)
        self.assertIn('component:AddBonus(inst, amount, "ttk_achievement_" .. id)', src)
        self.assertIn("inst._ttk_achievement_perks[id] = level", src)
        self.assertIn("inst._ttk_achievement_perks ~= nil then return end", src)
        component = self.source("scripts/components/ttk_achievement_progress.lua")
        self.assertIn('"ms_respawnedfromghost", function() self:ReapplyPurchased()', component)
        self.assertIn("self.core:Load(state)", component)

    def test_unavailable_content_cannot_take_star_and_all_catalog_ids_remain(self):
        src = self.source("scripts/achievement/ttk_perk_effects.lua")
        self.assertIn("if inst.components.trinketowner == nil then return false end", src)
        self.assertIn("if Prefabs.chasni_icyweed == nil then return false end", src)
        catalog = self.source("scripts/achievement/ttk_perk_catalog.lua")
        recipes = re.findall(r'recipes = \{(.*?)\n        \}', catalog, re.S)
        source_ids = re.findall(r'"(\w+)"', "".join(recipes))
        aliases = self.source("scripts/achievement/ttk_perk_crafts.lua").split("local aliases = {", 1)[1].split("}", 1)[0]
        enabled = dict(re.findall(r'(\w+) = "(\w+)"', aliases))
        self.assertEqual(50, len(source_ids))
        self.assertEqual(42, len(set(source_ids) - enabled.keys()))
        self.assertTrue(all(f"xd_wmz_md{i}" not in enabled for i in range(1, 9)))

    def test_success_evidence_recoil_and_duplicate_death_are_guarded(self):
        src = self.source("scripts/achievement/ttk_perk_effects.lua")
        hooks = self.source("main/ttk_achievement_perks.lua")
        self.assertIn("if not recoil and amount > 0", src)
        self.assertIn("victim._ttk_achievement_double_drop = true", src)
        self.assertIn('Seen(player, "picks", data)', src)
        self.assertIn("not was_cooking and stewer:IsCooking()", hooks)
        self.assertIn("if result == true and bonus > 0", hooks)
        self.assertIn("if Master() and ok == true", hooks)

    def test_fixed_daily_reward_and_overlevel_reduction_are_preserved(self):
        daily = self.source("scripts/components/hh_daily_quest.lua")
        self.assertNotIn("achievement_multiplier", daily)
        self.assertNotIn("GetXPMultiplier", daily)
        api = self.source("main/hh_api.lua")
        self.assertIn("HHGetLevelFactor(player, meta)", api)
        self.assertIn("LEVEL_FACTORS", api)
        self.assertIn('meta.class == "boss" or meta.class == "superboss"', api)


if __name__ == "__main__":
    unittest.main(verbosity=2)
