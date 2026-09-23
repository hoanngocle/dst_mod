"""Regression tests for Pham Nhan's integrated Solo progression components."""
from __future__ import annotations

from pathlib import Path
import sys
import unittest


ROOT = Path(__file__).resolve().parents[3]
MOD = ROOT / "mods" / "PhamNhanTuTien"
sys.path.insert(0, str(ROOT / ".superpowers/ttk-solo-integration/lua-runtime"))

from lupa.lua51 import LuaRuntime


def progression_runtime():
    lua = LuaRuntime(unpack_returned_tuples=True)
    lua.globals().root = MOD.as_posix()
    lua.execute(
        r'''
        package.path = root .. "/scripts/?.lua;" .. package.path
        package.preload["utils/hh_utils"] = function()
            return { SpawnClientLevelUpFx = function() end }
        end

        function Class(constructor)
            local cls = {}
            setmetatable(cls, {
                __call = function(_, ...)
                    local obj = setmetatable({}, { __index = cls })
                    constructor(obj, ...)
                    return obj
                end,
            })
            return cls
        end

        now = 10
        GetTime = function() return now end
        TheWorld = { ismastersim = true, state = { cycles = 2, time = 0 } }
        TUNING = {
            TOTAL_DAY_TIME = 480,
            HH_LEVELING = {
                AP_PER_LEVEL = 2, AP_BONUS_INTERVAL = 10, AP_BONUS_AMOUNT = 2,
                LEVEL_UP_RESTORE_TIME = 10, MAX_LEVELS_PER_EXP_GRANT = 1000,
                STAT_CAPS = { STR = 200, AGI = 50, VIT = 40, SEN = 50, INT = 15 },
                STR_GAIN = 1, AGI_GAIN = 1, VIT_GAIN = 1,
                SEN_CRIT_RATE = 1, SEN_CRIT_DMG = 2,
                INT_CD_REDUCE = 1, INT_SHADOW_REDUCE = 10,
            },
            HH_MANA = {
                BASE_MAX = 100, MAX_PER_INT = 20,
                BASE_REGEN = 1, REGEN_PER_INT = .15,
                REGEN_INTERVAL = .5, REGEN_DELAY = 3,
            },
            HH_DAILY_QUEST = { EXP_BLOCK_NOTICE_COOLDOWN = 3 },
        }
        STRINGS = { HH_DAILY_QUEST = { EXP_BLOCKED = "blocked" } }
        SpawnPrefab = function() return nil end

        function NewInst()
            local inst = {
                components = {},
                tasks = {},
                events = {},
                valid = true,
            }
            function inst:IsValid() return self.valid end
            function inst:HasTag() return false end
            function inst:PushEvent(name, data) self.events[name] = data or true end
            function inst:DoTaskInTime(delay, fn)
                local task = { cancelled = false }
                function task:Cancel() self.cancelled = true end
                table.insert(self.tasks, { delay = delay, fn = fn, task = task })
                return task
            end
            function inst:DoPeriodicTask(_, fn)
                local task = { cancelled = false, fn = fn }
                function task:Cancel() self.cancelled = true end
                return task
            end
            function inst:RunTasks()
                local tasks = self.tasks
                self.tasks = {}
                for _, entry in ipairs(tasks) do
                    if not entry.task.cancelled then entry.fn(self) end
                end
            end
            return inst
        end

        HHLeveling = assert(loadfile(root .. "/scripts/components/hh_leveling.lua"))()
        HHMana = assert(loadfile(root .. "/scripts/components/hh_mana.lua"))()
        '''
    )
    return lua


class SoloProgressionTests(unittest.TestCase):
    def test_mana_waits_for_configured_delay_after_spend(self):
        lua = progression_runtime()
        lua.execute(
            r'''
            local inst = NewInst()
            inst.components.health = { IsDead = function() return false end }
            inst.components.hh_leveling = { stat_int = 0 }
            local mana = HHMana(inst)
            inst.components.hh_mana = mana
            mana.current = 50
            assert(mana:Spend(10, "test"))
            now = 12.9
            mana:RegenTick()
            assert(mana.current == 40, "mana regenerated before the delay elapsed")
            now = 13
            mana:RegenTick()
            assert(mana.current == 40.5, "mana did not resume after the delay")
            '''
        )

    def test_body_transfer_preserves_level_stats_and_mana(self):
        lua = progression_runtime()
        lua.execute(
            r'''
            local old = NewInst()
            local new = NewInst()
            old.components.hh_player = { hh_effects = {} }
            new.components.hh_player = { hh_effects = {} }
            function old.components.hh_player:AddEffectValueByKey() end
            function new.components.hh_player:AddEffectValueByKey() end
            old.components.hh_shadow_manager = {}
            new.components.hh_shadow_manager = {}
            old.components.hh_leveling = HHLeveling(old)
            new.components.hh_leveling = HHLeveling(new)
            old.components.hh_mana = HHMana(old)
            new.components.hh_mana = HHMana(new)

            local level = old.components.hh_leveling
            level.level, level.exp, level.ap = 47, 321, 9
            level.stat_str, level.stat_agi, level.stat_vit = 20, 11, 8
            level.stat_sen, level.stat_int = 7, 6
            old.components.hh_mana.current = 137

            level:TransferComponent(new)
            old.components.hh_mana:TransferComponent(new)
            new:RunTasks()

            local copied = new.components.hh_leveling
            assert(copied.level == 47 and copied.exp == 321 and copied.ap == 9)
            assert(copied.stat_str == 20 and copied.stat_agi == 11 and copied.stat_vit == 8)
            assert(copied.stat_sen == 7 and copied.stat_int == 6)
            assert(new.components.hh_mana.max == 220)
            assert(new.components.hh_mana.current == 137)
            '''
        )

    def test_load_sanitizes_malformed_progression_values(self):
        lua = progression_runtime()
        lua.execute(
            r'''
            local inst = NewInst()
            inst.components.hh_player = { AddEffectValueByKey = function() end }
            inst.components.hh_shadow_manager = {}
            local level = HHLeveling(inst)
            inst.components.hh_leveling = level
            level:OnLoad({
                level = "bad", exp = -50, ap = -2,
                stat_str = 999, stat_agi = -1, stat_vit = "12",
                stat_sen = math.huge, stat_int = 99,
            })
            assert(level.level == 1 and level.exp == 0 and level.ap == 0)
            assert(level.stat_str == 200 and level.stat_agi == 0)
            assert(level.stat_vit == 12 and level.stat_sen == 0 and level.stat_int == 15)
            '''
        )


if __name__ == "__main__":
    unittest.main(verbosity=2)
