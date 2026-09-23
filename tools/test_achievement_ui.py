"""Snapshot UI source contracts and an independent presentation oracle.

No DST/Lua runtime is installed here: these are deliberately NOT runtime UI
tests. Multiplayer networking and widget layout require an in-game smoke test.
"""
from copy import deepcopy
from pathlib import Path
import re
import unittest

MOD = Path(__file__).resolve().parents[1]
SCREEN = MOD / "scripts/screens/ttk_progression_screen.lua"
COMPONENT = MOD / "scripts/components/ttk_achievement_progress.lua"
REPLICA = MOD / "scripts/components/ttk_achievement_progress_replica.lua"
RUNTIME = MOD / "main/ttk_achievement.lua"


class PresentationOracle:
    """Specification for display-only pagination and one in-flight mutation."""
    def __init__(self, snapshot):
        self.snapshot = deepcopy(snapshot)
        self.pending = False

    def page(self, tab, group=None, page=1):
        rows = self.snapshot[tab]
        selected = [row for row in rows if group is None or row["group"] == group]
        pages = max(1, (len(selected) + 5) // 6)
        page = min(max(1, page), pages)
        return selected[(page - 1) * 6:page * 6], page, pages

    def click(self, rpc, *identifiers):
        if self.pending:
            return None
        self.pending = True
        return (rpc, *identifiers, "nonce")

    def receive(self, snapshot):
        self.snapshot = deepcopy(snapshot)
        self.pending = False


class AchievementUIContracts(unittest.TestCase):
    def setUp(self):
        self.screen = SCREEN.read_text(encoding="utf-8") if SCREEN.exists() else ""
        self.component = COMPONENT.read_text(encoding="utf-8")
        self.replica = REPLICA.read_text(encoding="utf-8")
        self.runtime = RUNTIME.read_text(encoding="utf-8")

    def test_three_tabs_and_fixed_row_pool(self):
        self.assertIn('local TABS = { "achievement", "seasonal", "perk" }', self.screen)
        self.assertIn('local PAGE_SIZE = 6', self.screen)
        self.assertIn('for index = 1, PAGE_SIZE do', self.screen)
        self.assertIn('function TtkProgressionScreen:SetPage', self.screen)
        self.assertIn('function TtkProgressionScreen:SetGroup', self.screen)
        self.assertNotIn('"level"', self.screen)
        groups = re.search(r'local ACHIEVEMENT_GROUPS = \{(.*?)\n\}', self.screen, re.S)
        self.assertIsNotNone(groups)
        self.assertEqual(13, len(re.findall(r'\{ "[a-z_]+",', groups.group(1))))

    def test_source_uses_only_replica_state_and_server_quotes(self):
        self.assertIn('replica.ttk_achievement_progress', self.screen)
        self.assertIn('replica:GetSnapshot()', self.screen)
        for field in ('current_cost', 'next_cost', 'current_effect', 'next_effect', 'balance', 'claims', 'max_claims'):
            self.assertIn(field, self.screen)
        for forbidden in ('owner.components', 'SpawnPrefab', 'GiveItem', 'NextPrice', 'PriceForLevel', 'earned -', 'math.random', 'Catalog.Draw'):
            self.assertNotIn(forbidden, self.screen)

    def test_exact_rpc_shapes_and_validated_slots(self):
        for shape in (
            'self:Send("AchievementClaim", row.id, nonce)',
            'self:Send("AchievementPerk", row.id, nonce)',
            'self:Send("AchievementSeasonal", "task", row.slot, row.id, nonce)',
            'self:Send("AchievementSeasonal", "chest", row.slot, row.id, nonce)',
            'self:Send("AchievementSnapshot", NewNonce())',
        ):
            self.assertIn(shape, self.screen)
        self.assertIn('ValidSlot(row.slot, 20)', self.screen)
        self.assertIn('ValidSlot(row.slot, 4)', self.screen)
        self.assertIn('self.snapshot.seasonal.slots[row.slot]', self.screen)
        self.assertIn('GetModRPC(self.owner._ttk_achievement_rpc_namespace, name)', self.screen)

    def test_pending_no_optimistic_economy_and_snapshot_event_order(self):
        self.assertIn('if self.pending or not row.can_claim then return end', self.screen)
        self.assertIn('self.pending = true', self.screen)
        self.assertIn('self.pending = false', self.screen)
        self.assertIn('"ttk_achievement_snapshot"', self.screen)
        self.assertIn('"ttk_achievement_snapshot"', self.replica)
        self.assertLess(self.replica.index('self.snapshot = decoded'), self.replica.index('PushEvent("ttk_achievement_snapshot"'))
        self.assertNotRegex(self.screen, r'self\.snapshot\.[\w.]+\s*=(?!=)')

    def test_network_replica_registration_and_repeated_snapshot_revision(self):
        self.assertIn('AddReplicableComponent("ttk_achievement_progress")', self.runtime)
        self.assertIn('G.net_string(inst.GUID, "ttk.achievement.snapshot", "ttk_achievement_netdirty")', self.runtime)
        self.assertIn('inst._ttk_achievement_rpc_namespace = modname', self.runtime)
        self.assertIn('self.snapshot_revision = self.snapshot_revision + 1', self.component)
        self.assertIn('self.inst._ttk_achievement_snapshot:set(encoded)', self.component)
        self.assertIn('"ttk_achievement_netdirty"', self.replica)
        self.assertIn('inst._ttk_achievement_snapshot:value()', self.replica)

    def test_seasonal_and_perk_projection_is_server_owned(self):
        for token in ('SeasonalCatalog.ById(slot.task_id)', 'snapshot.seasonal', 'first_claims', 'chest_claimed', 'PerkCatalog.NextPrice', 'current_cost', 'next_effect'):
            self.assertIn(token, self.component)
        for token in ('seasonal.slots', 'seasonal.chests', 'max_claims', 'current_cost', 'next_cost', 'current_effect', 'next_effect', 'can_claim'):
            self.assertIn(token, self.replica)
        self.assertNotIn('PerkCatalog.NextPrice', self.replica)
        self.assertIn('MAX_SNAPSHOT_BYTES', self.replica)

    def test_dedicated_guard_precedes_widget_import_and_lazy_open_path(self):
        self.assertIn('TheNet:IsDedicated()', self.screen)
        self.assertLess(self.screen.index('TheNet:IsDedicated()'), self.screen.index('require("widgets/screen")'))
        status = (MOD / 'scripts/widgets/hh_status_ui.lua').read_text(encoding='utf-8')
        self.assertIn('self.progression_btn:SetOnClick', status)
        start = status.index('self.progression_btn:SetOnClick')
        self.assertIn('require("screens/ttk_progression_screen")', status[start:])
        self.assertIn('TheNet:IsDedicated()', status[start:])

    def test_snapshot_projection_contract_preserves_fractional_progress(self):
        self.assertIn('CanonicalNumber(progress)', self.replica)
        self.assertIn('FormatNumber(state.progress)', self.component)
        self.assertIn('AchievementCatalog.ById(id)', self.replica)
        self.assertIn('version = 2', self.replica)
        self.assertIn('sections.v ~= "1" and sections.v ~= "2"', self.replica)
        self.assertIn('#snapshot.seasonal.slots ~= 20', self.replica)

    def test_loading_screen_has_safe_empty_rows_before_first_snapshot(self):
        constructor = self.screen.split('function TtkProgressionScreen:Send', 1)[0]
        self.assertIn('self:Render()\n    self:OnSnapshot()', constructor)
        self.assertIn('self.visible_rows = {}', self.screen)

    def test_rejected_mutations_still_publish_snapshot_and_stale_data_is_ignored(self):
        claim = self.runtime.split('AddModRPCHandler(modname, "AchievementClaim"', 1)[1].split('AddModRPCHandler', 1)[0]
        purchase = self.runtime.split('AddModRPCHandler(modname, "AchievementPerk"', 1)[1].split('AddModRPCHandler', 1)[0]
        for block in (claim, purchase):
            self.assertIn('component:PushSnapshot()', block)
            self.assertNotIn('if ok then component:PushSnapshot()', block)
        for action in ('ClaimSeasonal', 'ClaimChest'):
            block = self.component.split('function TtkAchievementProgress:' + action, 1)[1].split('\nfunction ', 1)[0]
            self.assertIn('type(request_id) == "string"', block)
        self.assertIn('decoded.revision <= (self.snapshot.revision or 0)', self.replica)

    def test_pages_filter_boundary_and_snapshot_values_are_not_derived(self):
        snapshot = {"achievement": [{"id": i, "group": 'food' if i < 40 else 'boss', "progress": .25} for i in range(231)]}
        model = PresentationOracle(snapshot)
        rows, page, pages = model.page('achievement', 'food', 99)
        self.assertEqual(([36, 37, 38, 39], 7, 7), ([r['id'] for r in rows], page, pages))
        self.assertEqual(.25, rows[0]['progress'])
        self.assertEqual(([], 1, 1), model.page('achievement', 'missing', -3))
        self.assertEqual((6, 1, 39), (len(model.page('achievement')[0]), *model.page('achievement')[1:]))

    def test_duplicate_click_stays_pending_until_snapshot_without_local_award(self):
        data = {'balance': 41, 'achievement': [{'id': 'a', 'group': 'food'}]}
        model = PresentationOracle(data)
        self.assertEqual(('AchievementClaim', 'a', 'nonce'), model.click('AchievementClaim', 'a'))
        self.assertIsNone(model.click('AchievementPerk', 'p'))
        self.assertEqual(data, model.snapshot)
        model.receive({'balance': 43, 'achievement': []})
        self.assertEqual(43, model.snapshot['balance'])
        self.assertFalse(model.pending)


if __name__ == '__main__':
    unittest.main(verbosity=2)
