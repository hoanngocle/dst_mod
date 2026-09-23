"""Contracts for the altar definitions, payment gate, rules and lifecycle."""
from __future__ import annotations

import importlib.util
import os
from pathlib import Path
import re
import sys
import tempfile
import unittest
import zipfile

from test_support import find_dst_root, find_workshop_root, find_workspace_root

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")

ROOT = Path(__file__).resolve().parents[1]
from lupa.lua51 import LuaRuntime


def lua_list(table):
    return [table[index] for index in range(1, len(table) + 1)]


lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute("package.path = ... .. package.path", str(ROOT / "scripts" / "?.lua;").replace("\\", "/"))
defs = lua.execute('return require("ttk_jitan_defs")')

# Offering odds and score-to-pool odds are hand-derived from the accepted design.
expected_offerings = {
    "ttk_lingshi2": [(2, 0.35), (3, 0.35), (4, 0.30)],
    "ttk_lingshi3": [(4, 0.10), (5, 0.45), (6, 0.45)],
}
for prefab, expected in expected_offerings.items():
    actual = [(entry.score, entry.chance) for entry in lua_list(defs.offerings[prefab])]
    assert actual == expected, (prefab, actual)

expected_groups = {
    2: [(1, 1.00)],
    3: [(1, 0.50), (2, 0.50)],
    4: [(1, 0.34), (3, 0.33), (2, 0.33)],
    5: [(2, 0.50), (3, 0.50)],
    6: [(3, 1.00)],
}
for score, expected in expected_groups.items():
    actual = [(entry.group, entry.chance) for entry in lua_list(defs.score_groups[score])]
    assert actual == expected, (score, actual)

expected_boss_pools = {
    1: ["spiderqueen", "minotaur", "bearger", "deerclops", "dragonfly"],
    2: ["sharkboi", "mutatedbearger", "beequeen", "daywalker", "shadow_thralls",
        "alterguardian_phase3", "mutateddeerclops", "mutatedwarg"],
    3: ["klaus", "shadow_chess"],
}
for group, expected in expected_boss_pools.items():
    actual = [entry.id for entry in lua_list(defs.boss_pools[group])]
    assert actual == expected, (group, actual)
all_encounters = [entry for group in (1, 2, 3) for entry in lua_list(defs.boss_pools[group])]
assert "shadow_thralls" in [entry.id for entry in all_encounters]
assert not {"xd_jfsn", "xd_qlch"} & {entry.id for entry in all_encounters}
boss_prefabs = {
    spawn.prefab
    for encounter in all_encounters
    for spawn in lua_list(encounter.spawns)
}
assert "shadowthrall_horns" in boss_prefabs and "shadow_knight" in boss_prefabs

expected_reward_pools = {
    1: [
        (1.0, [("perogies", 8), ("dragonpie", 8)]),
        (1.0, [("armormarble", 5)]),
        (1.0, [("armorruins", 5)]),
        (1.0, [("nightsword", 10)]),
        (0.5, [("amulet", 4)]),
        (1.0, [("armorsnurtleshell", 5)]),
    ],
    2: [
        (1.0, [("jellybean_spice_chili", 1), ("voltgoatjelly", 1)]),
        (1.0, [("voltgoatjelly", 4)]),
        (0.2, [("armorskeleton", 1), ("hivehat", 3), ("panflute", 1), ("alterguardianhat", 1)]),
        (1.0, [("armor_sanity", 7)]),
        (1.0, [("ruinshat", 7)]),
    ],
    3: [
        (0.2, [("armordreadstone", 1), ("dreadstonehat", 1)]),
        (1.0, [("lunarplant_kit", 3)]),
        (0.2, [("lunarplanthat", 1), ("armor_lunarplant", 1), ("lunarplant_kit", 2)]),
        (0.2, [("armor_voidcloth", 1), ("voidclothhat", 1), ("voidcloth_kit", 2)]),
        (1.0, [("voidcloth_kit", 3)]),
        (0.15, [("armorwagpunk", 1), ("wagpunkhat", 1), ("wagpunkbits_kit", 2)]),
        (0.75, [("wagpunkbits_kit", 3)]),
    ],
}
actual_reward_pools = {
    tier: [
        (entry.weight, [(record.prefab, record.count) for record in lua_list(entry.records)])
        for entry in lua_list(defs.reward_pools[tier])
    ]
    for tier in (1, 2, 3)
}
assert actual_reward_pools == expected_reward_pools, actual_reward_pools
reward_prefabs = {
    prefab
    for entries in actual_reward_pools.values()
    for _, records in entries
    for prefab, _ in records
}
assert all(not name.startswith("xd_") for name in reward_prefabs)

recipes = {
    name: [(entry.prefab, entry.count) for entry in lua_list(defs.recipe_ingredients[name])]
    for name in ("ttk_jitan", "ttk_llbx")
}
assert recipes == {
    "ttk_jitan": [("cutstone", 12), ("goldnugget", 6), ("ttk_lingshi3", 2)],
    "ttk_llbx": [("boards", 6), ("goldnugget", 4), ("ttk_lingshi3", 1)],
}

# Every DST boss/reward identifier must occur in the installed runtime sources.
game_zip = find_dst_root() / "data" / "databundles" / "scripts.zip"
with zipfile.ZipFile(game_zip) as archive:
    lua.execute(archive.read("scripts/class.lua").decode())
    lua.globals().Trader = lua.execute(archive.read("scripts/components/trader.lua").decode())
    lua_sources = [archive.read(name) for name in archive.namelist() if name.endswith(".lua")]
runtime_blob = b"\n".join(lua_sources)
for prefab in sorted(boss_prefabs | reward_prefabs | {"cutstone", "goldnugget", "boards"}):
    assert prefab.encode() in runtime_blob, f"Prefab DST chưa resolve: {prefab}"

# Rules use injected random values, so exact source boundaries are deterministic.
rules = lua.execute('return require("ttk_jitan_rules")')
assert rules.RollScore("ttk_lingshi2", lambda: 0.0) == 2
assert rules.RollScore("ttk_lingshi2", lambda: 0.35) == 3
assert rules.RollScore("ttk_lingshi2", lambda: 0.70) == 4
assert rules.RollScore("ttk_lingshi3", lambda: 0.099999) == 4
assert rules.RollScore("ttk_lingshi3", lambda: 0.10) == 5
assert rules.RollScore("ttk_lingshi3", lambda: 0.55) == 6
assert rules.RollGroup(4, lambda: 0.339999) == 1
assert rules.RollGroup(4, lambda: 0.34) == 3
assert rules.RollGroup(4, lambda: 0.67) == 2

# The production component is exercised through DST's real Trader. Trader
# removes the paid split before onaccept; the component must rely on the
# prepayment gate and consume exactly one item from a 120-stack.
lua.execute(
    r'''
    local Trial = require("components/ttk_jitan_trial")
    local Rules = require("ttk_jitan_rules")
    Vector3 = function(x, y, z) return { x = x, y = y, z = z } end

    TheWorld = {
        ismastersim = true,
        Map = {
            IsPassableAtPoint = function() return true end,
            IsGroundTargetBlocked = function() return false end,
            IsPointNearHole = function() return false end,
        },
        components = {},
    }
    TheSim = { FindEntities = function() return {} end }
    AllPlayers = {}

    local function Task(fn)
        return { fn = fn, cancelled = false, Cancel = function(self) self.cancelled = true end }
    end
    local altar_guid = 100
    local function Altar()
        altar_guid = altar_guid + 1
        local inst = { GUID = altar_guid, _ttk_jitan_identity = "altar-" .. altar_guid,
            components = {}, tags = {}, events = {}, valid = true, x = 0, z = 0 }
        function inst:IsValid() return self.valid end
        function inst:AddTag(tag) self.tags[tag] = true end
        function inst:RemoveTag(tag) self.tags[tag] = nil end
        function inst:HasTag(tag) return self.tags[tag] == true end
        function inst:GetPosition() return { x = self.x, y = 0, z = self.z } end
        inst.Transform = { GetWorldPosition = function() return inst.x, 0, inst.z end }
        function inst:PushEvent(name, data) table.insert(self.events, { name = name, data = data }) end
        function inst:DoTaskInTime(_, fn) self.delayed = Task(fn); return self.delayed end
        function inst:DoPeriodicTask(_, fn) self.periodic = Task(fn); return self.periodic end
        function inst:FindRewardChest() return self.chest end
        return inst
    end
    local function Player(userid)
        local player = { userid = userid, valid = true, ghost = false, distance = 0, refunds = {} }
        function player:IsValid() return self.valid end
        function player:HasTag(tag) return tag == "playerghost" and self.ghost or false end
        function player:GetDistanceSqToInst() return self.distance * self.distance end
        player.components = {
            health = {
                dead = false, maxhealth = 100, deltas = {},
                IsDead = function(self) return self.dead end,
                DoDelta = function(self, value, overtime, cause) table.insert(self.deltas, { value, cause }) end,
            },
            inventory = { GiveItem = function(self, item) table.insert(player.refunds, item.prefab) end },
        }
        return player
    end
    local function Stone(prefab, size)
        local consumed = { count = 0 }
        local function Item(stacksize)
            local item = { prefab = prefab, valid = true, components = {} }
            item.components.inventoryitem = { RemoveFromOwner = function() end }
            item.components.stackable = { stacksize = stacksize }
            function item.components.stackable:Get(count)
                self.stacksize = self.stacksize - count
                return Item(count)
            end
            function item:Remove() self.valid = false; consumed.count = consumed.count + 1 end
            return item
        end
        return Item(size), consumed
    end
    local function FinishCountdown(altar)
        for _ = 1, 5 do altar.periodic.fn() end
    end
    SpawnPrefab = function(prefab)
        local entity = { prefab = prefab, valid = true, tags = {}, listeners = {} }
        entity.Transform = { SetPosition = function() end }
        function entity:IsValid() return self.valid end
        function entity:AddTag(tag) self.tags[tag] = true end
        function entity:HasTag(tag) return self.tags[tag] == true end
        function entity:ListenForEvent(name, fn)
            self.listeners[name] = self.listeners[name] or {}
            table.insert(self.listeners[name], fn)
        end
        function entity:PushEvent(name, data)
            for _, fn in ipairs(self.listeners[name] or {}) do fn(self, data) end
        end
        function entity:Remove() self.valid = false; self:PushEvent("onremove") end
        return entity
    end

    -- Location gates use verified Tu Tien Ky and Solo authority markers.
    local altar = Altar()
    local owner = Player("KU_owner")
    local ok, reason = Rules.ValidateLocation(altar, owner)
    assert(ok and reason == nil)
    TheWorld.Map.IsPassableAtPoint = function() return false end
    assert(not Rules.ValidateLocation(altar, owner))
    TheWorld.Map.IsPassableAtPoint = function() return true end
    TheWorld.components.dungeon_manager = { players_in_dungeon = { [owner] = true } }
    local dungeon_ok, dungeon_reason = Rules.ValidateLocation(altar, owner)
    assert(not dungeon_ok and dungeon_reason == Rules.REASONS.DUNGEON)
    TheWorld.components.dungeon_manager = nil
    local TianjiMap = require("ttk_tianjimap")
    TianjiMap.Reset(); TianjiMap.Register(0, 0)
    local room_ok, room_reason = Rules.ValidateLocation(altar, owner)
    assert(not room_ok and room_reason == Rules.REASONS.INTERIOR)
    TianjiMap.Reset()
    TheSim.FindEntities = function() return { { HasTag = function() return true end } } end
    local overlap_ok, overlap_reason = Rules.ValidateLocation(altar, owner)
    assert(not overlap_ok and overlap_reason == Rules.REASONS.OVERLAP)
    TheSim.FindEntities = function() return {} end

    altar.chest = { valid = true, IsValid = function(self) return self.valid end }
    local trial = Trial(altar)
    trial.rng = function() return 0 end
    local trader = Trader(altar)
    altar.components.trader = trader
    altar.components.ttk_jitan_trial = trial
    trader:SetAbleToAcceptTest(function(_, item, giver, count)
        return trial:CanAcceptTrade(giver, item, count)
    end)
    trader:SetOnAccept(function(_, giver, item, count)
        trial:OnOfferingAccepted(giver, item, count)
    end)

    local wrong, wrong_consumed = Stone("flint", 120)
    assert(not trader:AcceptGift(owner, wrong) and wrong_consumed.count == 0)
    altar.chest = nil
    local missing = Stone("ttk_lingshi2", 120)
    assert(not trader:AcceptGift(owner, missing))
    altar.chest = { valid = true, IsValid = function(self) return self.valid end }
    owner.components.health.dead = true
    assert(not trial:CanStart(owner, { prefab = "ttk_lingshi2" }))
    owner.components.health.dead = false
    local stone, consumed = Stone("ttk_lingshi2", 120)
    assert(trader:AcceptGift(owner, stone))
    assert(consumed.count == 1 and stone.components.stackable.stacksize == 119)
    assert(trial.state == "countdown" and trial.owner_userid == owner.userid)
    assert(trial.run_id == "altar-101:1")
    local other = Player("KU_other")
    local second, second_consumed = Stone("ttk_lingshi2", 120)
    assert(not trader:AcceptGift(other, second) and second_consumed.count == 0)
    local run = trial.run_id
    assert(trial:Finish(run, "lost", "owner_left"))
    assert(not trial:Finish(run, "won", "late_death") and trial.state == "idle")

    -- Explicit multi-item trade is rejected; normal stack trade still pays one.
    local explicit, explicit_consumed = Stone("ttk_lingshi2", 120)
    assert(not trader:AcceptGift(owner, explicit, 2) and explicit_consumed.count == 0)

    -- Every countdown second validates the owner, so leaving and returning
    -- before the fifth second cannot bypass the 32-unit gate.
    assert(trial:Start(owner, "ttk_lingshi2"))
    local escaped_run = trial.run_id
    owner.distance = 33
    altar.periodic.fn()
    assert(trial.state == "idle" and not trial:Finish(escaped_run, "won", "late"))

    -- Run keys are altar-scoped, so two altar counters cannot collide in a
    -- shared reward chest's Queue deduplication set.
    owner.distance = 0
    local other_altar = Altar()
    other_altar.chest = altar.chest
    local other_trial = Trial(other_altar)
    other_trial.rng = function() return 0 end
    assert(other_trial:Start(owner, "ttk_lingshi2"))
    assert(other_trial.run_id ~= trial.run_id and other_trial.run_id == "altar-102:1")
    assert(other_trial:Finish(other_trial.run_id, "cancelled", "test_cleanup"))

    -- Countdown activates after five valid one-second checks. Eleven cumulative out-of-range
    -- checks settle once and apply the specified 40% max-health penalty.
    assert(trial:Start(owner, "ttk_lingshi3"))
    local active_run = trial.run_id
    owner.distance = 0
    FinishCountdown(altar)
    assert(trial.state == "active")
    owner.distance = 61
    for _ = 1, 10 do altar.periodic.fn(); assert(trial.state == "active") end
    altar.periodic.fn()
    assert(trial.state == "idle" and #owner.components.health.deltas == 1)
    assert(owner.components.health.deltas[1][1] == -40 and owner.components.health.deltas[1][2] == "ttk_jitan_out_of_range")
    assert(not trial:Finish(active_run, "won", "late"))

    -- Death and disconnect settle as losses without an out-of-range penalty.
    owner.distance = 0
    assert(trial:Start(owner, "ttk_lingshi2")); FinishCountdown(altar)
    owner.components.health.dead = true; altar.periodic.fn()
    assert(trial.state == "idle" and #owner.components.health.deltas == 1)
    owner.components.health.dead = false
    assert(trial:Start(owner, "ttk_lingshi2")); FinishCountdown(altar)
    owner.valid = false; altar.periodic.fn()
    assert(trial.state == "idle")
    owner.valid = true
    assert(trial.run_id == "altar-101:5")

    -- Identity persists with the altar, while a newly built altar reusing the
    -- same process GUID receives a distinct settlement namespace.
    local saved = trial:OnSave()
    local loaded_altar = Altar()
    local loaded_trial = Trial(loaded_altar)
    loaded_trial:OnLoad(saved)
    assert(loaded_trial.altar_id == trial.altar_id and loaded_trial.next_run_id == trial.next_run_id)
    local reused_a, reused_b = Altar(), Altar()
    reused_a.GUID, reused_b.GUID = 777, 777
    reused_a._ttk_jitan_identity, reused_b._ttk_jitan_identity = nil, nil
    reused_a._ttk_jitan_identity_nonce, reused_b._ttk_jitan_identity_nonce = 111, 222
    assert(Trial(reused_a).altar_id ~= Trial(reused_b).altar_id)
    ''')

# The registration module may declare existing assets and strings, but Task 1
# must not register the prefabs implemented by Tasks 2 and 4.
lua.execute(
    """
    GLOBAL = {
        STRINGS = { NAMES = {}, RECIPE_DESC = {}, CHARACTERS = { GENERIC = { DESCRIBE = {} } } },
        TECH = { SCIENCE_ONE = 1, SCIENCE_TWO = 2 },
        Ingredient = function(prefab, count) return { prefab = prefab, count = count } end,
        require = require,
        Vector3 = function(x, y, z) return { x = x, y = y, z = z } end,
    }
    PrefabFiles = {}
    Assets = {}
    recipes = {}
    Asset = function(kind, file) return { kind = kind, file = file } end
    RegisterInventoryItemAtlas = function(atlas, image) end
    AddMinimapAtlas = function(atlas) end
    AddStategraphPostInit = function(name, fn) end
    AddPrefabPostInit = function(name, fn) end
    AddComponentPostInit = function(name, fn) end
    package.loaded["containers"] = { params = {}, MAXITEMSLOTS = 0 }
    AddRecipe2 = function(name, ingredients, tech, config, filters)
        recipes[name] = { ingredients = ingredients, tech = tech, config = config, filters = filters }
    end
    modimport = function(path)
        local f = assert(loadfile(__root .. "/" .. path))
        setfenv(f, getfenv(1))
        return f()
    end
    """
)
lua.globals().__root = str(ROOT).replace("\\", "/")
lua.execute(f'assert(loadfile("{str(ROOT / "main" / "ttk_jitan.lua").replace(os.sep, "/")}"))()')
assert lua_list(lua.globals().PrefabFiles) == ["ttk_jitan", "ttk_llbx"]
assets = {(entry.kind, entry.file) for entry in lua_list(lua.globals().Assets)}
assert assets == {
    ("ANIM", "anim/ttk_jitan.zip"),
    ("ANIM", "anim/ttk_llbx.zip"),
    ("ANIM", "anim/ttk_ui_llbx.zip"),
    ("ATLAS", "images/map_icons/ttk_jitan.xml"),
    ("IMAGE", "images/map_icons/ttk_jitan.tex"),
    ("ATLAS", "images/map_icons/ttk_llbx.xml"),
    ("IMAGE", "images/map_icons/ttk_llbx.tex"),
}
strings = lua.globals().GLOBAL.STRINGS
assert strings.NAMES.TTK_JITAN == "Tế Đàn"
assert strings.NAMES.TTK_LLBX == "Linh Lung Bảo Sương"
assert "<" not in strings.CHARACTERS.GENERIC.DESCRIBE.TTK_JITAN
recipe = lua.globals().recipes.ttk_jitan
assert [(entry.prefab, entry.count) for entry in lua_list(recipe.ingredients)] == recipes["ttk_jitan"]
assert recipe.config.placer == "ttk_jitan_placer"
assert recipe.tech == 2
chest_recipe = lua.globals().recipes.ttk_llbx
assert [(entry.prefab, entry.count) for entry in lua_list(chest_recipe.ingredients)] == recipes["ttk_llbx"]
assert chest_recipe.config.placer == "ttk_llbx_placer" and chest_recipe.tech == 2
containers = lua.eval('require("containers")')
assert containers.MAXITEMSLOTS == 36
assert len(containers.params.ttk_llbx.widget.slotpos) == 36
assert containers.params.ttk_llbx.widget.animbuild == "xd_ui_llbx"
assert containers.params.ttk_llbx.itemtestfn() is False

# The reproducible asset tool must copy only the audited manifest and rewrite
# atlas filenames for the ttk_ namespace.
class JitanAssetProvenanceTest(unittest.TestCase):
    def test_audited_assets_can_be_reproduced_from_a_donor(self):
        try:
            workspace = find_workspace_root("tools/port_ttk_jitan_assets.py")
        except FileNotFoundError:
            self.skipTest("Tế Đàn provenance tool is unavailable")

        tool_path = workspace / "tools" / "port_ttk_jitan_assets.py"
        spec = importlib.util.spec_from_file_location("port_ttk_jitan_assets", tool_path)
        self.assertIsNotNone(spec)
        self.assertIsNotNone(spec.loader)
        port = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(port)

        configured_source = os.environ.get("TU_TIEN_SOURCE_ROOT")
        source_candidates = [Path(configured_source)] if configured_source else []
        source_candidates.append(port.SOURCE)
        workshop_root = find_workshop_root()
        if workshop_root.is_dir():
            source_candidates.extend(path for path in workshop_root.iterdir() if path.is_dir())
        source = next((candidate for candidate in source_candidates if all(
            (candidate / source_name).is_file()
            for source_name, _ in port.MANIFEST.values()
        )), None)
        if source is None:
            self.skipTest("audited Tu Tiên donor assets are unavailable")

        port.SOURCE = source
        with tempfile.TemporaryDirectory() as temp:
            copied = port.port_assets(Path(temp))
            self.assertEqual(set(copied), set(port.MANIFEST))
            for relative in port.MANIFEST:
                self.assertTrue((Path(temp) / relative).is_file(), relative)
            for name in ("ttk_jitan", "ttk_llbx"):
                atlas = (Path(temp) / "images" / "map_icons" / f"{name}.xml").read_text(encoding="utf-8")
                self.assertIn(f'{name}.tex', atlas)
                self.assertNotIn("xd_", atlas)

# No original global helpers, leveling system, decoded placeholders, or Solo imports.
ported_text = "\n".join(
    path.read_text(encoding="utf-8-sig")
    for path in (ROOT / "main" / "ttk_jitan.lua", ROOT / "scripts" / "ttk_jitan_defs.lua")
)
for forbidden in ("XD_GETWOLRDLEVEL", "XD_GONGGAO", "xd_level", "<XX>"):
    assert forbidden not in ported_text, forbidden
assert not re.search(r'(?:require|modimport)\s*\(?\s*["\'][^"\']*(?:solo|hh_)', ported_text, re.I)

print("Đạt: định nghĩa Tế Đàn thuần dữ liệu, 2 lễ vật, 3 nhóm boss và 3 bảng thưởng")
print("Đạt: Trader thật thu đúng một lễ vật; lifecycle countdown/active/finish idempotent")
print("Đạt: 7 tài nguyên đã audit; đăng ký Tế Đàn + rương riêng ở Máy Luyện Kim")
print("Đạt: mọi boss/loot DST đã resolve; không có phụ thuộc Tu Tiên/Solo bị cấm")
