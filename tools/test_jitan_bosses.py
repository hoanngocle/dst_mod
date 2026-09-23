"""Focused contracts for trial-owned DST boss spawning and defeat adapters."""
from pathlib import Path
import sys
import zipfile

from test_support import find_dst_root

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")

ROOT = Path(__file__).resolve().parents[1]
from lupa.lua51 import LuaRuntime

lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute("package.path = ... .. package.path", str(ROOT / "scripts" / "?.lua;").replace("\\", "/"))
game_zip = find_dst_root() / "data" / "databundles" / "scripts.zip"
with zipfile.ZipFile(game_zip) as archive:
    lua.execute(archive.read("scripts/class.lua").decode())

lua.execute(
    r'''
    local Bosses = require("ttk_jitan_bosses")
    local Adapters = require("ttk_jitan_boss_adapters")
    local Trial = require("components/ttk_jitan_trial")
    PI = math.pi
    Vector3 = function(x, y, z) return { x = x, y = y, z = z } end
    TheWorld = {
        Map = {
            IsPassableAtPoint = function() return true end,
            IsGroundTargetBlocked = function() return false end,
            IsPointNearHole = function() return false end,
        },
        pushed = {},
        PushEvent = function(self, name) table.insert(self.pushed, name) end,
    }
    table.contains = table.contains or function(list, value)
        for _, item in ipairs(list) do if item == value then return true end end
        return false
    end

    local guid = 200
    local spawned = {}
    local spawn_fail_at = nil
    local spawn_calls = 0

    local function Entity(prefab)
        guid = guid + 1
        local inst = {
            GUID = guid, prefab = prefab, valid = true, removed = false,
            components = {}, tags = {}, listeners = {}, pushed = {},
        }
        function inst:IsValid() return self.valid end
        function inst:GetDistanceSqToInst() return 0 end
        function inst:GetPosition() return { x = self.Transform.x, y = 0, z = self.Transform.z } end
        function inst:AddTag(tag) self.tags[tag] = true end
        function inst:RemoveTag(tag) self.tags[tag] = nil end
        function inst:HasTag(tag) return self.tags[tag] == true end
        function inst:ListenForEvent(name, fn) self.listeners[name] = self.listeners[name] or {}; table.insert(self.listeners[name], fn) end
        function inst:RemoveEventCallback(name, fn)
            local list = self.listeners[name] or {}
            for i = #list, 1, -1 do if list[i] == fn then table.remove(list, i) end end
        end
        function inst:PushEvent(name, data)
            table.insert(self.pushed, name)
            local copy = {}
            for i, fn in ipairs(self.listeners[name] or {}) do copy[i] = fn end
            for _, fn in ipairs(copy) do fn(self, data) end
        end
        function inst:Remove()
            self.removed = true; self.valid = false; self:PushEvent("onremove")
        end
        inst.Transform = {
            x = 0, z = 0,
            GetWorldPosition = function(self) return self.x, 0, self.z end,
            SetPosition = function(self, x, _, z) self.x, self.z = x, z end,
        }
        if prefab == "klaus" then
            inst.unchained = false
            inst.IsUnchained = function(self) return self.unchained end
            local soldiers = {}
            inst.components.commander = { GetAllSoldiers = function() return soldiers end }
            inst.components.knownlocations = {
                RememberLocation = function(self, name, position) self[name] = position end,
            }
            inst.SpawnDeer = function(self)
                self.spawn_deer_calls = (self.spawn_deer_calls or 0) + 1
                table.insert(soldiers, Entity("deer_red"))
                table.insert(soldiers, Entity("deer_blue"))
            end
        elseif prefab == "daywalker" then
            inst.hostile, inst.defeated = true, false
            inst.MakeDefeated = function(self)
                self.make_defeated_calls = (self.make_defeated_calls or 0) + 1
                self.defeated, self.hostile = true, false
            end
        elseif prefab == "sharkboi" then
            inst.components.health = { currenthealth = 100, minhealth = 10 }
            inst.MakeTrader = function(self)
                self.make_trader_calls = (self.make_trader_calls or 0) + 1
                self.components.trader = {}
            end
        elseif prefab == "minotaur" then
            inst.components.constructionsite = {
                enabled = true, onconstructedfn = function() error("Solo replacement must be disabled") end,
                Disable = function(self) self.enabled = false end,
                SetOnConstructedFn = function(self, fn) self.onconstructedfn = fn end,
            }
        end
        return inst
    end

    SpawnPrefab = function(prefab)
        spawn_calls = spawn_calls + 1
        if spawn_fail_at ~= nil and spawn_calls == spawn_fail_at then return nil end
        local inst = Entity(prefab)
        table.insert(spawned, inst)
        return inst
    end

    local altar = Entity("ttk_jitan")
    altar.Transform.x, altar.Transform.z = 20, 30
    local stub = { inst = altar, run_id = "altar-201:1", state = "active", tracked = {} }
    function stub:TrackEntity(run_id, entity, required)
        assert(run_id == self.run_id)
        entity._ttk_jitan_run_id = run_id
        entity:AddTag("ttk_jitan_boss")
        table.insert(self.tracked, { entity = entity, required = required ~= false })
        Adapters.Attach(entity, self, run_id)
        return true
    end
    function stub:MarkBossDefeated(run_id, entity)
        self.marks = (self.marks or 0) + 1
        self.last_mark = entity
        return run_id == self.run_id
    end

    -- All spawn points are validated before paying any entity creation cost.
    TheWorld.Map.IsPassableAtPoint = function() return false end
    stub.tracked, spawned, spawn_calls = {}, {}, 0
    local water_spawn, water_error = Bosses.Spawn(stub, "spiderqueen")
    assert(water_spawn == nil and water_error ~= nil and spawn_calls == 0)
    TheWorld.Map.IsPassableAtPoint = function() return true end
    TheWorld.Map.IsPointNearHole = function() return true end
    local hole_spawn, hole_error = Bosses.Spawn(stub, "spiderqueen")
    assert(hole_spawn == nil and hole_error ~= nil and spawn_calls == 0)
    TheWorld.Map.IsPointNearHole = function() return false end

    -- Encounter cardinalities come directly from the audited definitions.
    for id, expected in pairs({ spiderqueen = 3, mutatedwarg = 2, shadow_thralls = 3, shadow_chess = 3 }) do
        stub.tracked, spawned, spawn_calls = {}, {}, 0
        local entities, err = Bosses.Spawn(stub, id)
        assert(err == nil and #entities == expected and #stub.tracked == expected, id)
        for _, record in ipairs(stub.tracked) do assert(record.required and record.entity:HasTag("ttk_jitan_boss")) end
    end

    -- A partial spawn is removed directly, without death/killed synthesis.
    stub.tracked, spawned, spawn_calls, spawn_fail_at = {}, {}, 0, 3
    local failed, err = Bosses.Spawn(stub, "spiderqueen")
    assert(failed == nil and err ~= nil and #spawned == 2)
    for _, entity in ipairs(spawned) do
        assert(entity.removed and not table.contains(entity.pushed, "death") and not table.contains(entity.pushed, "killed"))
    end
    spawn_fail_at = nil

    -- Klaus summons are captured after the original SpawnDeer and are cleanup-only.
    stub.tracked, spawned, spawn_calls = {}, {}, 0
    local klaus_entities = assert(Bosses.Spawn(stub, "klaus"))
    local klaus = klaus_entities[1]
    assert(klaus.spawn_deer_calls == 1 and #stub.tracked == 3)
    assert(klaus.components.knownlocations.spawnpoint ~= nil)
    assert(stub.tracked[1].required and not stub.tracked[2].required and not stub.tracked[3].required)

    -- Solo's construction replacement is removed only from this trial Minotaur.
    stub.tracked, spawned, spawn_calls = {}, {}, 0
    local minotaur = assert(Bosses.Spawn(stub, "minotaur"))[1]
    assert(not minotaur.components.constructionsite.enabled)
    assert(minotaur.components.constructionsite.onconstructedfn == nil)

    -- Commander and child-spawner methods keep prior behavior, then capture
    -- the new summon as cleanup-only trial ownership.
    stub.tracked = {}
    local summoner = Entity("beequeen")
    local soldiers = {}
    summoner.components.commander = {
        AddSoldier = function(self, child) table.insert(soldiers, child) end,
        GetAllSoldiers = function() return soldiers end,
    }
    summoner.components.childspawner = {
        SpawnChild = function() return Entity("spider") end,
        SpawnEmergencyChild = function() return Entity("spider_warrior") end,
        childrenoutside = {}, emergencychildrenoutside = {},
    }
    summoner._ttk_jitan_run_id = stub.run_id; summoner:AddTag("ttk_jitan_boss")
    Adapters.Attach(summoner, stub, stub.run_id)
    local soldier = Entity("grumblebee"); summoner.components.commander:AddSoldier(soldier)
    local child = summoner.components.childspawner:SpawnChild()
    assert(#stub.tracked == 2 and not stub.tracked[1].required and not stub.tracked[2].required)
    assert(stub.tracked[1].entity == soldier and stub.tracked[2].entity == child)

    -- Normal death marks once; raw onremove never impersonates a kill.
    stub.marks = 0
    local normal = Entity("bearger")
    normal._ttk_jitan_run_id = stub.run_id; normal:AddTag("ttk_jitan_boss")
    assert(Adapters.Attach(normal, stub, stub.run_id))
    normal:PushEvent("death"); normal:PushEvent("onremove")
    assert(stub.marks == 1)
    local cleanup = Entity("deerclops")
    cleanup._ttk_jitan_run_id = stub.run_id; cleanup:AddTag("ttk_jitan_boss")
    Adapters.Attach(cleanup, stub, stub.run_id); cleanup:Remove()
    assert(stub.marks == 1)

    -- Klaus phase one is ignored; only the unchained death is final.
    stub.marks = 0
    klaus:PushEvent("death")
    assert(stub.marks == 0)
    klaus.unchained = true; klaus:PushEvent("death")
    assert(stub.marks == 1)

    -- Defeat-style bosses retain their original methods and settle afterward.
    stub.marks = 0
    local daywalker = Entity("daywalker")
    daywalker._ttk_jitan_run_id = stub.run_id; daywalker:AddTag("ttk_jitan_boss")
    Adapters.Attach(daywalker, stub, stub.run_id)
    daywalker:MakeDefeated()
    assert(daywalker.make_defeated_calls == 1 and daywalker.defeated and stub.marks == 1)
    local shark = Entity("sharkboi")
    shark._ttk_jitan_run_id = stub.run_id; shark:AddTag("ttk_jitan_boss")
    Adapters.Attach(shark, stub, stub.run_id)
    shark:MakeTrader()
    assert(shark.make_trader_calls == 1 and stub.marks == 1)
    shark.components.health.currenthealth = shark.components.health.minhealth
    shark:MakeTrader()
    assert(shark.make_trader_calls == 2 and stub.marks == 2)

    for _, prefab in ipairs({ "alterguardian_phase3", "shadowthrall_horns", "shadowthrall_hands", "shadowthrall_wings" }) do
        local entity = Entity(prefab)
        entity._ttk_jitan_run_id = stub.run_id; entity:AddTag("ttk_jitan_boss")
        Adapters.Attach(entity, stub, stub.run_id); entity:PushEvent("death")
    end
    assert(stub.marks == 6)

    -- The current AG3 death onenter is preserved except for its arena-invalid
    -- moonboss progression event. Existing animover wrappers remain untouched.
    local installed
    Adapters.Install({ AddStategraphPostInit = function(name, fn)
        assert(name == "alterguardian_phase3"); installed = fn
    end })
    local animover = { fn = function() end }
    local original_animover = animover.fn
    local death = {
        onenter = function(inst)
            inst.onenter_calls = (inst.onenter_calls or 0) + 1
            TheWorld:PushEvent("moonboss_defeated")
            TheWorld:PushEvent("arena_death_fx")
        end,
        events = { animover = animover },
    }
    installed({ states = { death = death } })
    assert(death.events.animover == animover and death.events.animover.fn ~= original_animover)
    TheWorld.pushed = {}
    local arena_ag = Entity("alterguardian_phase3")
    arena_ag._ttk_jitan_run_id = stub.run_id; arena_ag:AddTag("ttk_jitan_boss")
    arena_ag.components.locomotor = { StopMoving = function(self) self.stopped = true end }
    arena_ag.AnimState = {
        SetBuild = function(self, build) self.build = build end,
        SetBankAndPlayAnimation = function(self, bank, anim) self.bank, self.anim = bank, anim end,
    }
    arena_ag.Light = {
        SetIntensity = function(self, value) self.intensity = value end,
        SetRadius = function(self, value) self.radius = value end,
        SetFalloff = function(self, value) self.falloff = value end,
    }
    arena_ag.SetNoMusic = function(self, value) self.nomusic = value end
    RemovePhysicsColliders = function(inst) inst.colliders_removed = true end
    death.onenter(arena_ag)
    assert(arena_ag.onenter_calls == nil and #TheWorld.pushed == 0)
    assert(arena_ag.components.locomotor.stopped and arena_ag.colliders_removed and arena_ag.nomusic)
    assert(arena_ag.AnimState.anim == "phase3_death" and arena_ag.Light.radius == 4.5)
    death.events.animover.fn(arena_ag)
    assert(arena_ag.removed)
    local natural_ag = Entity("alterguardian_phase3")
    death.onenter(natural_ag)
    assert(natural_ag.onenter_calls == 1 and #TheWorld.pushed == 2)
    assert(TheWorld.pushed[1] == "moonboss_defeated" and TheWorld.pushed[2] == "arena_death_fx")

    -- Component group authority: auxiliaries and the first objective cannot win.
    local trial_altar = Entity("ttk_jitan")
    local trial = Trial(trial_altar)
    trial.state, trial.run_id, trial.run_number = "active", "altar-999:7", 7
    trial.score, trial.boss_id, trial.owner_userid = 2, "spiderqueen", "KU_group"
    trial.rng = function() return 0 end
    local first, second, minion = Entity("spiderqueen"), Entity("spiderqueen"), Entity("deer_red")
    assert(trial:TrackEntity(trial.run_id, first, true))
    assert(trial:TrackEntity(trial.run_id, second, true))
    assert(trial:TrackEntity(trial.run_id, minion, false))
    minion:PushEvent("death"); assert(trial.state == "active")
    first:PushEvent("death"); assert(trial.state == "active")
    second:PushEvent("death"); assert(trial.state == "idle")
    local finished = 0
    for _, name in ipairs(trial_altar.pushed) do if name == "ttk_jitan_finished" then finished = finished + 1 end end
    assert(finished == 1 and not first.removed and not second.removed)

    -- Loss cleanup only removes this run's living tracked entities.
    trial.state, trial.run_id, trial.run_number = "active", "altar-999:8", 8
    local owned, foreign = Entity("beequeen"), Entity("beequeen")
    trial:TrackEntity(trial.run_id, owned, true)
    foreign._ttk_jitan_run_id = "altar-other:1"
    assert(trial:Finish(trial.run_id, "lost", "owner_left"))
    assert(owned.removed and not foreign.removed)
    assert(not table.contains(owned.pushed, "death") and not table.contains(owned.pushed, "killed"))

    -- Spawn failure refunds the consumed offering once, even if Finish repeats.
    local refund_altar = Entity("ttk_jitan")
    local refund_trial = Trial(refund_altar)
    local owner = Entity("wilson")
    owner.userid = "KU_refund"
    owner.components.inventory = { given = {}, GiveItem = function(self, item) table.insert(self.given, item.prefab) end }
    owner.components.health = { IsDead = function() return false end }
    refund_trial.owner, refund_trial.owner_userid = owner, owner.userid
    refund_trial.state, refund_trial.run_id, refund_trial.run_number = "countdown", "altar-900:1", 1
    refund_trial.offering_prefab, refund_trial._paid, refund_trial.boss_group = "ttk_lingshi2", true, 1
    local old_spawn = Bosses.Spawn
    Bosses.Spawn = function() return nil, "forced failure" end
    assert(not refund_trial:BeginActive(refund_trial.run_id))
    assert(refund_trial.state == "idle" and #owner.components.inventory.given == 1)
    assert(not refund_trial:Finish("altar-900:1", "cancelled", "spawn_failed") and #owner.components.inventory.given == 1)
    Bosses.Spawn = old_spawn
    ''')

print("Đạt: đủ số boss cho mọi encounter nhiều mục tiêu; spawn lỗi dọn trực tiếp")
print("Đạt: death/defeat/Klaus hai pha chỉ kết thúc đúng thực thể thuộc lượt")
print("Đạt: nhóm chỉ thắng sau mục tiêu cuối; minion và onremove không giả kill")
print("Đạt: hủy lượt không phát death/killed; spawn lỗi hoàn phí đúng một lần")
