"""Behavior contracts for the exhaustive Ji Tan encounter catalog and setup."""
from __future__ import annotations

from pathlib import Path
import sys
import zipfile

from test_support import find_dst_root


ROOT = Path(__file__).resolve().parents[1]
from lupa.lua51 import LuaRuntime


def lua_list(table):
    return [table[index] for index in range(1, len(table) + 1)]


lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute("package.path = ... .. package.path", str(ROOT / "scripts" / "?.lua;").replace("\\", "/"))
catalog = lua.execute('return require("ttk_jitan_encounter_catalog")')
setup = lua.execute('return require("ttk_jitan_encounter_setup")')

entries = lua_list(catalog.GetEntries())
ids = [entry.id for entry in entries]
assert len(ids) == len(set(ids)) == 51, (len(ids), len(set(ids)))
assert ids[:5] == ["minotaur", "antlion", "bearger", "mutatedbearger", "beequeen"]
assert ids[-3:] == ["solo_walrus_adc", "solo_treasure_kps", "solo_treasure_cat_you"]
assert catalog.GetById("crabking").position_kind == "ocean"
assert catalog.GetById("missing") is None

expected_native = {
    "minotaur", "antlion", "bearger", "mutatedbearger", "beequeen",
    "celestial_champion", "alterguardian_phase1_lunarrift",
    "alterguardian_phase4_lunarrift", "crabking", "deerclops",
    "mutateddeerclops", "dragonfly", "eyeofterror", "twins_of_terror",
    "klaus", "lordfruitfly", "malbatross", "moose", "daywalker",
    "daywalker2", "shadow_chess", "sharkboi", "spiderqueen", "toadstool",
    "toadstool_dark", "stalker", "stalker_atrium", "leif", "leif_sparse",
    "fruitdragon", "warg", "claywarg", "gingerbreadwarg", "mutatedwarg",
    "wagboss_robot", "worm_boss", "vault_pillar_guard",
}
expected_solo = {
    "solo_minotau", "solo_hh_sharkboi", "solo_hh_beetle_pig",
    "solo_hh_dual_wield_pig", "solo_hh_igris_dungeon", "solo_hh_beru_dungeon",
}
expected_treasure = {
    "solo_mutateddeerclops_boss", "solo_mutatedbearger_boss",
    "solo_mutatedwarg_boss", "solo_hh_sharkboi_boss", "solo_walrus_adc",
    "solo_treasure_kps", "solo_treasure_cat_you",
}
assert {entry.id for entry in entries if entry.source == "native"} == expected_native
assert {entry.id for entry in entries if entry.source == "solo"} == expected_solo
assert {entry.id for entry in entries if entry.source == "solo_treasure"} == expected_treasure
assert {entry.id for entry in entries if entry.source == "legacy"} == {"shadow_thralls"}

# Family records must represent the authored encounter rather than internal phases/proxies.
champion = catalog.GetById("celestial_champion")
assert champion.lifecycle == "phase_chain"
assert lua_list(champion.required_prefabs) == ["alterguardian_phase2", "alterguardian_phase3"]
assert [(s.prefab, s.count, s.required) for s in lua_list(champion.spawns)] == [
    ("alterguardian_phase1", 1, True)
]
twins = catalog.GetById("twins_of_terror")
assert twins.lifecycle == "twins"
assert lua_list(twins.required_prefabs) == ["twinofterror1", "twinofterror2"]
assert [(s.prefab, s.required) for s in lua_list(twins.spawns)] == [("twinmanager", False)]
assert catalog.GetById("alterguardian_phase1_lunarrift").lifecycle == "lunar_capture"
assert catalog.GetById("daywalker2").adapter == "target_owner"
assert not {"alterguardian_phase2", "alterguardian_phase3", "sharkboi_water"} & set(ids)
assert lua_list(catalog.GetById("spiderqueen").spawns)[0].count == 3
assert lua_list(catalog.GetById("mutatedwarg").spawns)[0].count == 2

# Native source prefabs resolve in the installed DST archive. Internal manager prefabs count.
game_zip = find_dst_root() / "data" / "databundles" / "scripts.zip"
with zipfile.ZipFile(game_zip) as archive:
    native_blob = b"\n".join(archive.read(name) for name in archive.namelist() if name.endswith(".lua"))
for entry in entries:
    if entry.source in ("native", "legacy"):
        for spawn in lua_list(entry.spawns):
            assert (f'Prefab("{spawn.prefab}"'.encode() in native_blob
                    or f'MakeWarg({{'.encode() in native_blob and spawn.prefab.encode() in native_blob
                    or spawn.prefab.encode() in native_blob), (entry.id, spawn.prefab)

# Solo-derived prefabs and treasure ids resolve in Phàm Nhân's integrated source,
# not only in this catalog or in the historical Workshop source tree.
integrated_roots = [ROOT / "main", ROOT / "scripts" / "prefabs", ROOT / "scripts" / "enums",
                    ROOT / "scripts" / "components"]
solo_blob = b"\n".join(
    path.read_bytes()
    for source_root in integrated_roots
    for path in source_root.rglob("*.lua")
)
for entry in entries:
    if entry.source in ("solo", "solo_treasure"):
        for spawn in lua_list(entry.spawns):
            assert spawn.prefab.encode() in solo_blob or spawn.prefab.encode() in native_blob
        if entry.treasure_id is not None:
            assert entry.treasure_id.encode() in solo_blob
    for prefab in lua_list(entry.required_prefabs):
        assert prefab.encode() in native_blob or prefab.encode() in solo_blob, (entry.id, prefab)

# Availability is a pre-payment decision based only on explicit context tables.
lua.execute(
    r'''
    local Catalog = require("ttk_jitan_encounter_catalog")
    local Setup = require("ttk_jitan_encounter_setup")
    local function context_for(encounter)
        local prefabs = {}
        for _, spawn in ipairs(encounter.spawns) do prefabs[spawn.prefab] = true end
        for _, prefab in ipairs(encounter.required_prefabs or {}) do prefabs[prefab] = true end
        return {
            prefabs = prefabs,
            modflags = { solo_leveling = true },
            mapcapabilities = { ocean = true, water_adjacent = true },
            worldstate = { iswinter = true, isspring = true, iscave = false },
        }
    end

    local native = Catalog.GetById("deerclops")
    assert(Setup.IsAvailable(native, context_for(native)) == true)
    local runtime_prefabs = context_for(native)
    runtime_prefabs.prefabs.deerclops = { name = "deerclops" }
    assert(Setup.IsAvailable(native, runtime_prefabs) == true)
    local missing = context_for(native)
    missing.prefabs.deerclops = nil
    local ok, reason = Setup.IsAvailable(native, missing)
    assert(not ok and reason == "missing_prefab:deerclops")
    local summer = context_for(native)
    summer.worldstate.iswinter = false
    ok, reason = Setup.IsAvailable(native, summer)
    assert(not ok and reason == "missing_world_state:iswinter")

    local moose = Catalog.GetById("moose")
    local winter = context_for(moose)
    winter.worldstate.isspring = false
    ok, reason = Setup.IsAvailable(moose, winter)
    assert(not ok and reason == "missing_world_state:isspring")

    local solo = Catalog.GetById("solo_minotau")
    local no_solo = context_for(solo)
    no_solo.modflags.solo_leveling = false
    ok, reason = Setup.IsAvailable(solo, no_solo)
    assert(not ok and reason == "missing_dependency:solo_leveling")

    local champion = Catalog.GetById("celestial_champion")
    local incomplete_chain = context_for(champion)
    incomplete_chain.prefabs.alterguardian_phase2 = nil
    ok, reason = Setup.IsAvailable(champion, incomplete_chain)
    assert(not ok and reason == "missing_prefab:alterguardian_phase2")

    local super_krampus = Catalog.GetById("solo_treasure_kps")
    local incomplete_adds = context_for(super_krampus)
    incomplete_adds.prefabs.pigman = nil
    ok, reason = Setup.IsAvailable(super_krampus, incomplete_adds)
    assert(not ok and reason == "missing_prefab:pigman")

    local crab = Catalog.GetById("crabking")
    local no_ocean = context_for(crab)
    no_ocean.mapcapabilities.ocean = false
    ok, reason = Setup.IsAvailable(crab, no_ocean)
    assert(not ok and reason == "missing_map_capability:ocean")

    local malbatross = Catalog.GetById("malbatross")
    local no_shore = context_for(malbatross)
    no_shore.mapcapabilities.water_adjacent = false
    ok, reason = Setup.IsAvailable(malbatross, no_shore)
    assert(not ok and reason == "missing_map_capability:water_adjacent")

    local cramped = context_for(Catalog.GetById("spiderqueen"))
    cramped.spawn_capacity = { spiderqueen = false }
    ok, reason = Setup.IsAvailable(Catalog.GetById("spiderqueen"), cramped)
    assert(not ok and reason == "missing_spawn_capacity:spiderqueen")
    ''')

# Prepare executes exported/source-owned instance APIs and fails closed after payment.
lua.execute(
    r'''
    local Catalog = require("ttk_jitan_encounter_catalog")
    local Setup = require("ttk_jitan_encounter_setup")
    local tracked = {}
    local owner = { name = "owner" }
    local trial = {
        owner = owner,
        inst = { GetPosition = function() return { x = 0, y = 0, z = 0 } end },
        TrackEntity = function(self, run_id, entity, required)
            table.insert(tracked, { entity = entity, required = required })
            return true
        end,
        FindOwner = function(self) return self.owner end,
    }
    local function entity(prefab)
        local inst = { prefab = prefab, components = {}, tags = {}, valid = true }
        function inst:IsValid() return self.valid end
        function inst:AddTag(tag) self.tags[tag] = true end
        function inst:GetPosition() return { x = 4, y = 0, z = 5 } end
        function inst:GetDistanceSqToInst() return 0 end
        function inst:ListenForEvent(name, fn)
            self.listeners = self.listeners or {}
            self.listeners[name] = fn
        end
        return inst
    end

    local antlion = entity("antlion")
    antlion.persists = false -- Trial:TrackEntity marks this before Prepare.
    antlion.StartCombat = function(self, target)
        if self.persists and self.components.combat == nil then
            self.components.combat = {}
            self.components.health = {}
            self.started_with = target
        end
    end
    assert(Setup.Prepare(antlion, Catalog.GetById("antlion"), trial, "run", 1))
    assert(antlion.started_with == owner and antlion.components.combat ~= nil)
    assert(antlion.components.health ~= nil and antlion.persists == false)

    local minotaur = entity("minotaur")
    minotaur.components.constructionsite = {
        Disable = function(self) self.disabled = true end,
        SetOnConstructedFn = function(self, value) self.onconstructed = value; self.cleared = value == nil end,
    }
    assert(Setup.Prepare(minotaur, Catalog.GetById("minotaur"), trial, "run", 1))
    assert(minotaur.components.constructionsite.disabled and minotaur.components.constructionsite.cleared)

    local fruitdragon = entity("fruitdragon")
    fruitdragon.components.combat = { SetTarget = function(self, target) self.target = target end }
    assert(Setup.Prepare(fruitdragon, Catalog.GetById("fruitdragon"), trial, "run", 1))
    assert(fruitdragon.components.combat.target == owner)

    local robot = entity("wagboss_robot")
    robot.ConfigureHostile = function(self) self.hostile_configured = true end
    assert(Setup.Prepare(robot, Catalog.GetById("wagboss_robot"), trial, "run", 1))
    assert(robot.hostile_configured)

    local treasure = entity("mutateddeerclops")
    local ok, reason = Setup.Prepare(treasure, Catalog.GetById("solo_mutateddeerclops_boss"), trial, "run", 1)
    assert(not ok and reason == "missing_component:hh_monster")
    treasure.components.hh_monster = {
        SetTreasureId = function(self, id) self.id = id end,
    }
    assert(Setup.Prepare(treasure, Catalog.GetById("solo_mutateddeerclops_boss"), trial, "run", 1))
    assert(treasure.components.hh_monster.id == "mutateddeerclops_boss")

    local spawned_gems = {}
    SpawnPrefab = function(prefab)
        local gem = { prefab = prefab, removed = false }
        function gem:Remove() self.removed = true end
        table.insert(spawned_gems, gem)
        return gem
    end
    local crab = entity("crabking")
    crab.SocketItem = function(self, gem)
        self.socketed = self.socketed or {}
        table.insert(self.socketed, gem.prefab)
        gem:Remove()
    end
    assert(Setup.Prepare(crab, Catalog.GetById("crabking"), trial, "run", 1))
    assert(table.concat(crab.socketed, ",") ==
        "redgem,bluegem,purplegem,orangegem,yellowgem,greengem,redgem,bluegem,purplegem")
    assert(#spawned_gems == 9)
    ''')

# Setup-owned lifecycle: deterministic phase replacement, Twins ownership, and lunar capture.
lua.execute(
    r'''
    local Catalog = require("ttk_jitan_encounter_catalog")
    local Setup = require("ttk_jitan_encounter_setup")
    local postinits, component_postinits = {}, {}
    assert(Setup.Install({
        AddPrefabPostInit = function(prefab, fn) postinits[prefab] = fn end,
        AddComponentPostInit = function(name, fn) component_postinits[name] = fn end,
    }))
    assert(next(postinits) == nil) -- no global adoption hook may claim an unrelated spawn
    assert(component_postinits.lunarriftmutationsmanager ~= nil)

    local mutation_calls = {}
    local mutation_manager = {
        SetMutationDefeated = function(self, ent)
            table.insert(mutation_calls, ent)
            self.changed = true
            return "native-result"
        end,
    }
    component_postinits.lunarriftmutationsmanager(mutation_manager)
    local natural_mutation = { HasTag = function() return false end }
    assert(mutation_manager:SetMutationDefeated(natural_mutation) == "native-result")
    assert(#mutation_calls == 1 and mutation_manager.changed)
    mutation_manager.changed = false
    local trial_mutation = { HasTag = function(self, tag) return tag == "ttk_jitan_boss" end }
    assert(mutation_manager:SetMutationDefeated(trial_mutation) == nil)
    assert(#mutation_calls == 1 and not mutation_manager.changed)

    local replaced, marked, tracked, order = {}, {}, {}, {}
    local trial = {
        state = "active", run_id = "run", owner = { name = "owner" },
        inst = { DoTaskInTime = function(self, delay, fn) return { fire = fn } end },
        FindOwner = function(self) return self.owner end,
        ReplaceRequired = function(self, old, new)
            table.insert(order, "replace")
            table.insert(replaced, { old, new }); return true
        end,
        TrackEntity = function(self, run_id, child, required)
            table.insert(tracked, { child, required }); return true
        end,
        MarkBossDefeated = function(self, run_id, entity)
            table.insert(marked, entity); return true
        end,
        Finish = function(self, run_id, outcome, reason)
            self.finished = { outcome, reason }; return true
        end,
    }
    local function phase(prefab, dead)
        local inst = { prefab = prefab, valid = true, tags = {}, listeners = {}, pushed = {} }
        function inst:IsValid() return self.valid end
        function inst:AddTag(tag) self.tags[tag] = true end
        function inst:ListenForEvent(name, fn) self.listeners[name] = fn end
        function inst:PushEvent(name, data) table.insert(self.pushed, { name, data }) end
        inst.Transform = {
            GetWorldPosition = function() return 11, 0, 13 end,
            GetRotation = function() return 27 end,
            SetPosition = function(self, x, y, z) self.position = { x, y, z } end,
            SetRotation = function(self, rot) self.rotation = rot end,
        }
        inst.AnimState = { MakeFacingDirty = function(self) self.dirty = true end }
        inst.sg = { GoToState = function(self, state) self.state = state end }
        inst.components = { health = { IsDead = function() return dead end } }
        inst.components.combat = {
            target = trial.owner,
            SuggestTarget = function(self, target) self.suggested = target end,
        }
        inst.Remove = function(self) table.insert(order, "remove"); self.valid = false end
        return inst
    end
    local spawned = {}
    SpawnPrefab = function(prefab)
        local inst = phase(prefab, false)
        table.insert(spawned, inst)
        return inst
    end
    local encounter = Catalog.GetById("celestial_champion")
    local p1 = phase("alterguardian_phase1", true)
    assert(Setup.AttachLifecycle(p1, encounter, trial, "run", 1))
    p1:PushEvent("attacked", { attacker = trial.owner })
    assert(#p1.pushed == 1 and p1.pushed[1][1] == "attacked")
    local unrelated = SpawnPrefab("alterguardian_phase2")
    assert(unrelated._ttk_jitan_run_id == nil and #replaced == 0)
    local cancelled = phase("alterguardian_phase1", true)
    assert(Setup.AttachLifecycle(cancelled, encounter, trial, "run", 1))
    local spawned_before_cancel = #spawned
    trial.state = "idle"
    cancelled:PushEvent("phasetransition")
    trial.state = "active"
    assert(#spawned == spawned_before_cancel and #cancelled.pushed == 1)
    p1:PushEvent("phasetransition")
    local p2 = spawned[#spawned]
    assert(#replaced == 1 and replaced[1][1] == p1 and replaced[1][2] == p2)
    assert(p2._ttk_jitan_run_id == "run" and p2.tags.ttk_jitan_boss)
    assert(order[1] == "replace" and order[2] == "remove")
    assert(p2.Transform.position[1] == 11 and p2.Transform.position[3] == 13)
    assert(p2.Transform.rotation == 27 and p2.AnimState.dirty and p2.sg.state == "spawn")
    assert(p2.components.combat.suggested == trial.owner)

    p2.components.health.IsDead = function() return true end
    p2:PushEvent("phasetransition")
    local p3 = spawned[#spawned]
    assert(#replaced == 2 and replaced[2][1] == p2 and replaced[2][2] == p3)
    p3.listeners.death(p3)
    assert(marked[#marked] == p3)

    local failed = phase("alterguardian_phase1", true)
    assert(Setup.AttachLifecycle(failed, encounter, trial, "run", 1))
    SpawnPrefab = function() return nil end
    failed:PushEvent("phasetransition")
    assert(trial.finished[1] == "cancelled" and trial.finished[2] == "spawn_failed")
    assert(failed.valid) -- Finish owns cleanup/refund; transition never removes first.

    local manager = phase("twinmanager", false)
    manager.components.health = nil
    manager.components.entitytracker = {
        entities = {},
        TrackEntity = function(self, key, child) self.entities[key] = child end,
        GetEntity = function(self, key) return self.entities[key] end,
    }
    function manager:PushEvent(name, owner)
        assert(name == "arrive" and owner == trial.owner)
        self.components.entitytracker:TrackEntity("twin1", phase("twinofterror1", false))
        self.components.entitytracker:TrackEntity("twin2", phase("twinofterror2", false))
    end
    assert(Setup.Prepare(manager, Catalog.GetById("twins_of_terror"), trial, "run", 1))
    assert(#tracked == 2 and tracked[1][2] and tracked[2][2])

    local lunar = phase("alterguardian_phase1_lunarrift", false)
    lunar.components.health.currenthealth = 1
    lunar.components.health.minhealth = 1
    lunar.DoTaskInTime = function(self, delay, fn) self.capture_delay = delay; self.capture_fn = fn; return {} end
    lunar.sg = { GoToState = function(self, state) self.state = state end }
    assert(Setup.AttachLifecycle(lunar, Catalog.GetById("alterguardian_phase1_lunarrift"), trial, "run", 1))
    lunar.listeners.minhealth(lunar)
    assert(lunar.capture_delay > 0)
    lunar.capture_fn(lunar)
    assert(lunar.sg.state == "captured" and marked[#marked] == lunar)
    ''')

# Exact owned graphs are captured without radius scans or adopting combat targets.
lua.execute(
    r'''
    local Catalog = require("ttk_jitan_encounter_catalog")
    local Setup = require("ttk_jitan_encounter_setup")
    local tracked = {}
    local trial = {
        state = "active", run_id = "run",
        TrackEntity = function(self, run_id, entity, required)
            tracked[entity] = required
            return true
        end,
    }
    local function ent(prefab)
        local inst = { prefab = prefab, valid = true, components = {}, listeners = {} }
        function inst:IsValid() return self.valid end
        function inst:ListenForEvent(name, fn) self.listeners[name] = fn end
        return inst
    end

    local unrelated = ent("unrelated")

    local worm = ent("worm_boss")
    worm._ttk_jitan_run_id = "run"
    local head, tail, segment, pooled = ent("worm_boss_head"), ent("worm_boss_tail"),
        ent("worm_boss_segment"), ent("worm_boss_segment")
    local dirt1, dirt2, last = ent("worm_boss_dirt"), ent("worm_boss_dirt"), ent("worm_boss_segment")
    worm.head, worm.tail, worm.segment_pool = head, tail, { pooled }
    worm.chunks = {{ head = head, tail = tail, dirt_start = dirt1, dirt_end = dirt2,
        lastsegment = last, segments = { segment } }}
    assert(Setup.CaptureOwned(worm, Catalog.GetById("worm_boss"), trial, "run"))
    for _, owned in ipairs({ head, tail, segment, pooled, dirt1, dirt2, last }) do
        assert(tracked[owned] == false)
    end

    local crab = ent("crabking")
    crab._ttk_jitan_run_id = "run"
    local arm, tower, wall, geyser = ent("crabking_claw"), ent("crabking_cannontower"),
        ent("crabking_icewall"), ent("crabking_geyserspawner")
    crab.arms, crab.cannontowers = { arm, { task = {} } }, { tower, false }
    crab.keystones, crab.geysers = { wall }, { geyser }
    assert(Setup.CaptureOwned(crab, Catalog.GetById("crabking"), trial, "run"))
    for _, owned in ipairs({ arm, tower, wall, geyser }) do assert(tracked[owned] == false) end
    local projectile, spawned_tower, sea_stack = ent("crabking_mob"),
        ent("crabking_cannontower"), ent("seastack")
    crab.LaunchProjectile = function() return projectile end
    crab.SpawnCannonTower = function() return spawned_tower end
    crab.DoSpawnSeaStack = function() return sea_stack end
    crab.SocketItem = function(self, gem) gem:Remove() end
    SpawnPrefab = function(prefab)
        local gem = ent(prefab)
        function gem:Remove() self.valid = false end
        return gem
    end
    assert(Setup.Prepare(crab, Catalog.GetById("crabking"), trial, "run", 1))
    crab:LaunchProjectile()
    crab:SpawnCannonTower()
    crab:DoSpawnSeaStack()
    assert(tracked[projectile] == false and tracked[spawned_tower] == false and tracked[sea_stack] == false)

    local moose = ent("moose")
    moose._ttk_jitan_run_id = "run"
    local egg, mossling = ent("mooseegg"), ent("mossling")
    egg.components.herd = { members = { [mossling] = true } }
    moose.components.entitytracker = { GetEntity = function(self, key) return key == "egg" and egg or nil end }
    assert(Setup.CaptureOwned(moose, Catalog.GetById("moose"), trial, "run"))
    assert(tracked[egg] == false and tracked[mossling] == false)

    local toad = ent("toadstool")
    toad._ttk_jitan_run_id = "run"
    toad.DoSporeBomb = function(self, targets)
        for _, target in ipairs(targets) do target.spored = true end
    end
    assert(Setup.Prepare(toad, Catalog.GetById("toadstool"), trial, "run", 1))
    local sprout, player = ent("mushroomsprout"), ent("player")
    toad.listeners.linkmushroomsprout(toad, sprout)
    toad:DoSporeBomb({ player })
    tracked[sprout] = nil -- periodic capture can recover the exact linked child
    assert(Setup.CaptureOwned(toad, Catalog.GetById("toadstool"), trial, "run"))
    assert(tracked[sprout] == false and tracked[player] == nil and player.spored)

    local phase3 = ent("alterguardian_phase3")
    phase3._ttk_jitan_run_id = "run"
    local trap = ent("alterguardian_phase3trap")
    phase3._traps = { [trap] = true }
    assert(Setup.CaptureOwned(phase3, Catalog.GetById("celestial_champion"), trial, "run"))
    assert(tracked[trap] == false)

    local lunar = ent("alterguardian_phase1_lunarrift")
    lunar._ttk_jitan_run_id = "run"
    local gestalt = ent("alterguardian_phase1_lunarrift_gestalt")
    lunar.sg = { statemem = { gestalt = gestalt } }
    assert(Setup.CaptureOwned(lunar, Catalog.GetById("alterguardian_phase1_lunarrift"), trial, "run"))
    assert(tracked[gestalt] == false)
    assert(not Setup.CaptureOwned(unrelated, Catalog.GetById("worm_boss"), trial, "run"))
    assert(tracked[unrelated] == nil)
    ''')

print("Ji Tan encounter catalog/setup contracts passed")
