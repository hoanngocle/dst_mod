"""Private reward queue, static roll and Tế Đàn loot-isolation contracts."""
from pathlib import Path
import json
import sys
import zipfile

from test_support import find_dst_root

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")

ROOT = Path(__file__).resolve().parents[1]
from lupa.lua51 import LuaRuntime

assert (ROOT / "scripts" / "prefabs" / "ttk_llbx.lua").is_file()

lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute("package.path = ... .. package.path", str(ROOT / "scripts" / "?.lua;").replace("\\", "/"))

def lua_list(table):
    return [table[index] for index in range(1, len(table) + 1)]

game_zip = find_dst_root() / "data" / "databundles" / "scripts.zip"
with zipfile.ZipFile(game_zip) as archive:
    lua.execute(archive.read("scripts/class.lua").decode())
    runtime_blob = b"\n".join(archive.read(name) for name in archive.namelist() if name.endswith(".lua"))
mod_prefab_blob = b"\n".join(path.read_bytes() for path in (ROOT / "scripts" / "prefabs").glob("*.lua"))

lua.execute(
    r'''
    deepcopy = function(value)
        if type(value) ~= "table" then return value end
        local copy = {}
        for key, item in pairs(value) do copy[deepcopy(key)] = deepcopy(item) end
        return copy
    end

    local Rewards = require("ttk_jitan_rewards")
    local RewardQueue = require("components/ttk_jitan_rewards")

    local function Sequence(values)
        local index = 0
        return function()
            index = index + 1
            assert(values[index] ~= nil, "RNG sequence exhausted")
            return values[index]
        end
    end

    -- Source score tiers, one static reward choice, optional spirit stones,
    -- and exactly two or three boss-snapshot draws are fixed at settlement.
    local low = Rewards.Roll(2, Sequence({ .70, 0, 0, 0, 0, .01 }), "deerclops")
    assert(#low == 5)
    assert(low[1].prefab == "meat" and low[2].prefab == "meat")
    assert(low[3].prefab == "perogies" and low[3].count == 8)
    assert(low[4].prefab == "dragonpie" and low[4].count == 8)
    assert(low[5].prefab == "ttk_lingshi3")
    local high = Rewards.Roll(6, Sequence({ 0, 0, 0, 0, 0, 0, .10, .01 }), "klaus")
    assert(#high == 4 and high[1].prefab == "jellybean_spice_chili")
    assert(Rewards.Alias("xd_lingshi3") == "ttk_lingshi3")
    assert(Rewards.Alias("xd_lingshi4") == "ttk_lingshi4")

    local created, restored = {}, {}
    local function Item(record)
        local item = { prefab = record.prefab, record = deepcopy(record), valid = true, components = {},
            stack = record.data ~= nil and record.data.stack or 1 }
        function item:IsValid() return self.valid end
        function item:Remove() self.valid = false end
        function item:GetSaveRecord()
            self.record.data = self.record.data or {}
            self.record.data.stack = self.stack
            return deepcopy(self.record)
        end
        return item
    end
    SpawnPrefab = function(prefab)
        local item = Item({ prefab = prefab, data = { enchant = "rolled-" .. tostring(#created + 1) } })
        table.insert(created, item)
        return item
    end
    SpawnSaveRecord = function(record)
        local item = Item(record)
        table.insert(restored, item)
        return item
    end

    local function Container(limit)
        local container = { limit = limit, slots = {} }
        function container:GiveItem(item, slot, src_pos, drop_on_fail)
            for _, existing in ipairs(self.slots) do
                if existing.prefab == item.prefab and existing.stack ~= nil and existing.stack < existing.maxstack then
                    local moved = math.min(item.stack or 1, existing.maxstack - existing.stack)
                    existing.stack = existing.stack + moved
                    item.stack = (item.stack or 1) - moved
                    if item.stack == 0 then item:Remove(); return true end
                end
            end
            if #self.slots >= self.limit then return false end
            table.insert(self.slots, item)
            return true
        end
        function container:IsEmpty() return #self.slots == 0 end
        function container:GetAllItems() return self.slots end
        return container
    end
    local function Chest(limit)
        local inst = { components = { container = Container(limit) }, private = {} }
        function inst:GetRewardContainer(player)
            if player.userid == "KU_A" then return self end
            if self.private[player.userid] == nil then
                self.private[player.userid] = { components = { container = Container(limit) } }
            end
            return self.private[player.userid]
        end
        return inst, RewardQueue(inst)
    end
    local A, B = { userid = "KU_A" }, { userid = "KU_B" }

    -- A owns the queue even if B dealt the kill; duplicate run IDs never reroll.
    local chest, queue = Chest(1)
    table.insert(chest.components.container.slots, Item({ prefab = "filler" }))
    assert(queue:Queue("altar-x:1", A.userid, { { prefab = "armorruins", count = 1 } }))
    assert(not queue:Queue("altar-x:1", A.userid, { { prefab = "nightsword", count = 1 } }))
    assert(queue:Claim(B) == 0 and queue:Claim(A) == 0 and queue:HasPending())
    assert(queue:Queue("altar-x:b1", B.userid, { { prefab = "nightsword", count = 1 } }))
    assert(queue:Claim(B) == 1 and not queue:HasPending(B.userid) and queue:HasPending(A.userid))
    assert(chest.private[B.userid].components.container.slots[1].prefab == "nightsword")

    -- A save/load while full retains the exact item record, including enchant.
    local saved = queue:OnSave()
    local loaded_chest, loaded = Chest(1)
    table.insert(loaded_chest.components.container.slots, Item({ prefab = "filler" }))
    loaded:OnLoad(saved)
    assert(loaded:Claim(A) == 0 and loaded:HasPending())
    loaded_chest.components.container.slots = {}
    assert(loaded:Claim(A) == 1 and not loaded:HasPending())
    assert(loaded_chest.components.container.slots[1].record.data.enchant == "rolled-1")

    -- Multiple wins queue independently. A nearly-full stack accepts one unit;
    -- the remaining fixed unit stays queued instead of being dropped/rerolled.
    local stack_chest, stack_queue = Chest(1)
    table.insert(stack_chest.components.container.slots, { prefab = "perogies", stack = 1, maxstack = 2 })
    assert(stack_queue:Queue("altar-x:2", A.userid, { { prefab = "perogies", count = 2 } }))
    assert(stack_queue:Queue("altar-x:3", A.userid, {
        { prefab = "solo_enchanted_sword", count = 1,
          save_record = { prefab = "solo_enchanted_sword", data = { enchant = 77, durability = .42 } } },
    }))
    assert(stack_queue:Claim(A) == 1 and stack_queue:HasPending())
    assert(stack_chest.components.container.slots[1].stack == 2)
    stack_chest.components.container.slots = {}
    stack_chest.components.container.limit = 2
    assert(stack_queue:Claim(A) == 2 and not stack_queue:HasPending())
    assert(stack_chest.components.container.slots[1].record.prefab == "perogies")
    assert(stack_chest.components.container.slots[2].record.data.enchant == 77)

    -- Native GiveItem can partially merge a saved stack and return false when
    -- all slots remain occupied. Only its exact remainder stays in the queue.
    local partial_chest, partial_queue = Chest(1)
    table.insert(partial_chest.components.container.slots, { prefab = "perogies", stack = 4, maxstack = 5 })
    assert(partial_queue:Queue("altar-x:4", A.userid, {{
        prefab = "perogies", save_record = { prefab = "perogies", data = { stack = 3, enchant = 91 } }
    }}))
    assert(partial_queue:Claim(A) == 0 and partial_queue:HasPending())
    assert(partial_chest.components.container.slots[1].stack == 5)
    local partial_save = partial_queue:OnSave()
    assert(partial_save.pending_by_userid[A.userid][1].items[1].data.stack == 2)
    partial_chest.components.container.slots = {}
    assert(partial_queue:Claim(A) == 1 and not partial_queue:HasPending())
    assert(partial_chest.components.container.slots[1].stack == 2)
    assert(partial_chest.components.container.slots[1].record.data.enchant == 91)

    -- Unexpected facade removal transfers every queue independently. A queue
    -- whose original altar is gone falls back to a surviving authority, and
    -- claimed private-container contents are snapshotted exactly once.
    local rescue_chest, rescue = Chest(4)
    assert(rescue:Queue("altar-rescue:1", A.userid, { { prefab = "armorruins" } }))
    assert(rescue:Queue("altar-gone:1", B.userid, { { prefab = "nightsword" } }))
    local backups, recovery = {}, 0
    local authority = {
        inst = { IsValid = function() return true end },
        AdoptRewardBackup = function(self, run_id, userid, records)
            backups[#backups + 1] = { run_id = run_id, userid = userid, records = deepcopy(records) }
            return true
        end,
        NewRecoveryRunId = function(self) recovery = recovery + 1; return "altar-rescue:recovery-" .. recovery end,
    }
    assert(rescue:SetAuthority("altar-rescue", authority))
    local invalid_called = false
    local invalid_authority = {
        inst = { IsValid = function() return false end },
        AdoptRewardBackup = function() invalid_called = true; return true end,
    }
    assert(rescue:SetAuthority("altar-gone", invalid_authority))
    local private = { valid = true, IsValid = function(self) return self.valid end,
        components = { container = Container(4) } }
    table.insert(private.components.container.slots, Item({ prefab = "solo_enchanted_sword", data = { enchant = 66 } }))
    assert(rescue:BackupToAuthorities({ [A.userid] = private }))
    assert(#backups == 3 and not rescue:HasPending())
    assert(not invalid_called)
    assert(backups[2].run_id == "altar-gone:1" and backups[2].userid == B.userid)
    assert(backups[3].records[1].save_record.data.enchant == 66)
    assert(not rescue:BackupToAuthorities({ [A.userid] = private }) and #backups == 3)

    -- Winner settlement queues to the submitter's chest and never asks for killer identity.
    local Trial = require("components/ttk_jitan_trial")
    local altar = { tags = {}, pushed = {}, GUID = 901 }
    function altar:AddTag(tag) self.tags[tag] = true end
    function altar:RemoveTag(tag) self.tags[tag] = nil end
    function altar:PushEvent(name, data) table.insert(self.pushed, { name = name, data = data }) end
    local trial = Trial(altar)
    local queued
    trial.state, trial.run_id, trial.run_number = "active", "altar-settle:1", 1
    trial.owner_userid, trial.score, trial.boss_id = A.userid, 2, "deerclops"
    trial.reward_chest = { valid = true, IsValid = function() return true end,
        components = { ttk_jitan_rewards = { Queue = function(_, run_id, userid, records)
            queued = { run_id = run_id, userid = userid, records = records }; return true
        end } } }
    trial.rng = Sequence({ .70, 0, 0, 0, 0, .50 })
    assert(trial:Finish(trial.run_id, "won", "bosses_defeated"))
    assert(queued.run_id == "altar-settle:1" and queued.userid == A.userid and #queued.records == 4)
    ''')

# Every static reward/bonus prefab must resolve in the installed DST runtime or this mod.
reward_source = (ROOT / "scripts" / "ttk_jitan_rewards.lua").read_text(encoding="utf-8")
assert "GenerateLoot" not in reward_source
for name in lua_list(lua.eval('function() local r=require("ttk_jitan_rewards"); return r.AllPrefabs() end')()):
    encoded = name.encode()
    assert encoded in runtime_blob or encoded in mod_prefab_blob \
        or (name.startswith("ttk_lingshi") and b"ttk_lingshi" in mod_prefab_blob), name

# Generated Lua data must stay byte-for-value equivalent to the installed-DST
# audit evidence, including duplicate entries, probabilities and source lines.
audit = json.loads((ROOT / "tools" / "fixtures" / "native-boss-loot-tables.json").read_text(encoding="utf-8"))
loot_tables = lua.eval('require("ttk_jitan_loot_tables")')
for table in audit:
    actual = loot_tables[table["table"]]
    assert actual.source == f'{table["source"]}:{table["line"]}'
    assert [(entry.prefab, entry.chance) for entry in lua_list(actual.entries)] == [
        (entry["prefab"], entry["chance"]) for entry in table["entries"]
    ]

# The global spirit-stone hook must skip trial bosses before touching its paid latch.
lua.execute('package.loaded["ttk_defs"] = { drop_min = 2, drop_max = 2 }')
lua.execute('package.loaded["ttk_enemy_rules"] = { Classify = function() return "boss" end }')
loot_path = str(ROOT / "scripts" / "ttk_loot.lua").replace("\\", "/")
lua.execute(
    f'''
    local Loot = assert(loadfile("{loot_path}"))()
    local callback
    local world = {{ ismastersim = true, ListenForEvent = function(_, _, fn) callback = fn end }}
    Loot.Install(world)
    local function Boss(is_trial)
        local inst = {{ spawned = 0, listeners = {{}}, components = {{}} }}
        inst.HasTag = function(_, tag) return is_trial and tag == "ttk_jitan_boss" end
        inst.ListenForEvent = function(self, name, fn) self.listeners[name] = fn end
        inst.components.lootdropper = {{ SpawnLootPrefab = function() inst.spawned = inst.spawned + 1 end }}
        return inst
    end
    local trial_boss = Boss(true)
    callback(world, {{ inst = trial_boss }})
    assert(trial_boss.spawned == 0 and trial_boss._ttk_death_paid == nil)
    local natural = Boss(false)
    callback(world, {{ inst = natural }})
    assert(natural.spawned == 2 and natural._ttk_death_paid == true)
    ''')

print("Đạt: roll tĩnh theo điểm + snapshot boss, không gọi GenerateLoot")
print("Đạt: queue riêng userid, chống lặp run_id, đầy rương và nhiều lượt không mất")
print("Đạt: save record giữ phụ ma và remainder stack; người nộp nhận thưởng bất kể người kết liễu")
print("Đạt: boss thử luyện không rơi linh thạch hook chung; boss tự nhiên vẫn rơi")
