"""Save/recovery and owned-entity cleanup contracts for Tế Đàn."""
from pathlib import Path
import importlib.util

ROOT = Path(__file__).resolve().parents[1]
base_path = ROOT / "tools" / "test_jitan.py"
spec = importlib.util.spec_from_file_location("ttk_jitan_base_tests", base_path)
assert spec and spec.loader
base = importlib.util.module_from_spec(spec)
spec.loader.exec_module(base)
lua = base.lua

lua.execute(
    r'''
    local Trial = require("components/ttk_jitan_trial")

    local function Altar(guid)
        local inst = { GUID = guid, tags = {}, events = {}, components = {} }
        inst.Transform = { GetWorldPosition = function() return 0, 0, 0 end }
        function inst:AddTag(tag) self.tags[tag] = true end
        function inst:RemoveTag(tag) self.tags[tag] = nil end
        function inst:PushEvent(name, data) table.insert(self.events, { name = name, data = data }) end
        function inst:DoPeriodicTask() return { Cancel = function() end } end
        return inst
    end
    local function Entity(prefab)
        local entity = { prefab = prefab, valid = true, removed = 0, tags = {}, listeners = {}, persists = true,
            components = {} }
        function entity:IsValid() return self.valid end
        function entity:AddTag(tag) self.tags[tag] = true end
        function entity:HasTag(tag) return self.tags[tag] == true end
        function entity:ListenForEvent(name, fn) self.listeners[name] = fn end
        function entity:Remove() self.removed = self.removed + 1; self.valid = false end
        return entity
    end
    local owner = { userid = "KU_SAVE", valid = true, components = { health = {
        IsDead = function() return false end, maxhealth = 100, DoDelta = function() end,
    } } }
    function owner:IsValid() return self.valid end
    function owner:HasTag() return false end
    function owner:GetDistanceSqToInst() return 0 end

    -- Every run-owned entity is nonpersistent so an interrupted save cannot
    -- reload a boss or auxiliary after the authority resets to idle.
    local altar = Altar(1201)
    local trial = Trial(altar)
    trial.state, trial.run_id, trial.owner, trial.owner_userid = "active", "save:1", owner, owner.userid
    local required, auxiliary = Entity("deerclops"), Entity("hound")
    assert(trial:TrackEntity(trial.run_id, required, true))
    assert(trial:TrackEntity(trial.run_id, auxiliary, false))
    assert(required.persists == false and auxiliary.persists == false)

    -- Winning preserves the real boss/corpse timeline but immediately removes
    -- owned helpers. Removing the altar during a fight removes both.
    local queue_calls = 0
    trial.reward_chest = { IsValid = function() return true end, components = {
        ttk_jitan_rewards = { Queue = function() queue_calls = queue_calls + 1; return true end },
    } }
    trial.score, trial.boss_id = 2, "deerclops"
    trial.rng = function() return 0 end
    local original_remove = auxiliary.Remove
    auxiliary.Remove = function(self)
        assert(not trial:Finish("save:1", "won", "reentrant_onremove"))
        return original_remove(self)
    end
    assert(trial:Finish("save:1", "won", "bosses_defeated"))
    assert(required.removed == 0 and auxiliary.removed == 1)
    assert(queue_calls == 1)

    -- The twins manager must survive the last twin's death dispatch so its
    -- native listener can award the shield/sketch pair. It remains ordinary
    -- cleanup-owned state for cancellation and altar removal.
    local twins_altar = Altar(1210)
    local twins = Trial(twins_altar)
    twins.state, twins.run_id, twins.owner, twins.owner_userid = "active", "twins:1", owner, owner.userid
    twins.reward_chest = trial.reward_chest
    twins.score, twins.boss_id, twins.rng = 3, "twins_of_terror", function() return 0 end
    local twin, manager = Entity("twinofterror2"), Entity("twinmanager")
    manager._ttk_jitan_preserve_on_win = true
    assert(twins:TrackEntity("twins:1", twin, true))
    assert(twins:TrackEntity("twins:1", manager, false))
    assert(twins:MarkBossDefeated("twins:1", twin))
    assert(manager.removed == 0)

    local cancelled_twins = Trial(Altar(1211))
    cancelled_twins.state, cancelled_twins.run_id = "active", "twins:2"
    local cancelled_manager = Entity("twinmanager")
    cancelled_manager._ttk_jitan_preserve_on_win = true
    assert(cancelled_twins:TrackEntity("twins:2", cancelled_manager, false))
    assert(cancelled_twins:Finish("twins:2", "cancelled", "altar_removed"))
    assert(cancelled_manager.removed == 1)

    local altar2 = Altar(1202)
    local trial2 = Trial(altar2)
    trial2.state, trial2.run_id, trial2.owner, trial2.owner_userid = "active", "save:2", owner, owner.userid
    local boss2, minion2 = Entity("bearger"), Entity("hound")
    assert(trial2:TrackEntity("save:2", boss2, true))
    assert(trial2:TrackEntity("save:2", minion2, false))
    trial2:OnRemoveFromEntity()
    assert(boss2.removed == 1 and minion2.removed == 1)

    -- A required entity disappearing without a canonical defeat settles loss
    -- instead of leaving a permanently active trial.
    local altar3 = Altar(1203)
    local trial3 = Trial(altar3)
    trial3.state, trial3.run_id, trial3.owner, trial3.owner_userid = "active", "save:3", owner, owner.userid
    local vanished = Entity("dragonfly")
    assert(trial3:TrackEntity("save:3", vanished, true))
    vanished.valid = false
    assert(trial3:TickActive("save:3"))
    assert(trial3.state == "idle")
    assert(altar3.events[#altar3.events].data.reason == "boss_removed")

    -- Loading any in-flight state cancels it to idle without refund or reward;
    -- the monotonic run counter and altar creation identity remain stable.
    local altar4 = Altar(1204)
    local in_flight = Trial(altar4)
    in_flight.state, in_flight.run_id, in_flight.run_number = "countdown", "save-altar:7", 7
    in_flight.next_run_id, in_flight._paid = 8, true
    local record = in_flight:OnSave()
    local loaded = Trial(Altar(1204))
    loaded:OnLoad(record)
    assert(loaded.state == "idle" and loaded.next_run_id == 8 and loaded.run_id == "save-altar:7")
    assert(not loaded._paid and loaded._refunded == false)

    -- If the validated chest vanishes during settlement, authority keeps the
    -- fixed records across save/load and flushes them into a later chest once.
    local altar5 = Altar(1205)
    local fallback = Trial(altar5)
    fallback.state, fallback.run_id, fallback.owner, fallback.owner_userid = "active", "fallback:1", owner, owner.userid
    fallback.score, fallback.boss_id = 2, "deerclops"
    fallback.rng = function() return 0 end
    fallback.reward_chest = nil
    assert(fallback:Finish("fallback:1", "won", "bosses_defeated"))
    assert(#fallback.reward_backups == 1)
    local fallback_saved = fallback:OnSave()
    local fallback_loaded = Trial(Altar(1205))
    fallback_loaded:OnLoad(fallback_saved)
    local flushed = {}
    local replacement = { components = { ttk_jitan_rewards = {
        SetAuthority = function() end,
        Queue = function(self, run_id, userid, records)
            flushed[#flushed + 1] = { run_id, userid, records }; return true
        end,
    } } }
    assert(fallback_loaded:FlushRewardBackups(replacement) == 1)
    assert(#fallback_loaded.reward_backups == 0 and #flushed == 1)
    assert(fallback_loaded:FlushRewardBackups(replacement) == 0 and #flushed == 1)
    ''')

chest_source = (ROOT / "scripts" / "prefabs" / "ttk_llbx.lua").read_text(encoding="utf-8")
assert "MakeLargeBurnable" not in chest_source and "MakeMediumBurnable" not in chest_source
assert 'inst:AddTag("NOCLICK")' in chest_source
assert "doer.userid ~= inst._owner_userid" in chest_source
assert "HasPending()" in chest_source and "PrivateContainersEmpty" in chest_source

print("Đạt: boss/minion không persist; load lượt dở hủy về idle, giữ run counter")
print("Đạt: thắng giữ boss/corpse và dọn auxiliary; altar mất dọn toàn bộ owned")
print("Đạt: required biến mất kết thúc loss; rương không cháy/không tháo khi còn dữ liệu")
print("Đạt: settlement re-entry chỉ trả thưởng một lần; queue fallback sống qua save/load")
