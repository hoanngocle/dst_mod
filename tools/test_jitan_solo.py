"""Phàm Nhân 2.0 integrated-Solo compatibility contracts for Tế Đàn."""
from pathlib import Path
import sys
import zipfile

from test_support import find_dst_root

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")

ROOT = Path(__file__).resolve().parents[1]
from lupa.lua51 import LuaRuntime

modmain = (ROOT / "modmain.lua").read_text(encoding="utf-8-sig")
bootstrap = (ROOT / "main" / "ttk_solo_bootstrap.lua").read_text(encoding="utf-8")
main_jitan = (ROOT / "main" / "ttk_jitan.lua").read_text(encoding="utf-8")
modinfo = (ROOT / "modinfo.lua").read_text(encoding="utf-8-sig")
assert modmain.index('modimport("main/ttk_jitan.lua")') < modmain.index('modimport("main/ttk_solo_bootstrap.lua")')
assert 'env._ttk_solo_loaded = true' in bootstrap
assert 'ttk_jitan_solo_bosses' not in main_jitan + modinfo
assert 'return rawget(MODENV, "_ttk_solo_loaded") == true' in main_jitan

trial_sources = "\n".join(
    (ROOT / relative).read_text(encoding="utf-8")
    for relative in (
        "scripts/ttk_jitan_bosses.lua",
        "scripts/ttk_jitan_boss_adapters.lua",
        "scripts/components/ttk_jitan_trial.lua",
    )
)
for forbidden in ('PushEvent("killed"', "PushEvent('killed'", 'PushEvent("death"', "PushEvent('death'"):
    assert forbidden not in trial_sources
assert 'AddComponent("hh_monster")' not in trial_sources
assert "maxhealth =" not in trial_sources and "SetMaxHealth(" not in trial_sources

# Exercise the real integrated hh_world component: the Tế Đàn ownership tag
# neither opts a boss out nor compounds world-rank scaling on repeated applies.
lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute("package.path = ... .. package.path", str(ROOT / "scripts" / "?.lua;").replace("\\", "/"))
game_zip = find_dst_root() / "data" / "databundles" / "scripts.zip"
with zipfile.ZipFile(game_zip) as archive:
    lua.execute(archive.read("scripts/class.lua").decode())
lua.execute(
    r'''
    math.clamp = math.clamp or function(value, low, high) return math.max(low, math.min(high, value)) end
    package.loaded["utils/hh_utils"] = {}
    package.loaded["guild/hh_rank_defs"] = {
        RANK = { B = 2, S = 4 }, IsValidRank = function(rank) return rank >= 0 end,
    }
    TUNING = { HH_MINIBOSS_PREFABS = {}, HH_BOSS_PREFABS = { deerclops = true } }
    local World = require("components/hh_world")
    local world_inst = { ismastersim = true, ismastershard = true, events = {} }
    function world_inst:PushEvent(name, data) self.events[#self.events + 1] = { name, data } end
    local world = World(world_inst)

    local function Boss(trial_owned)
        local inst = { prefab = "deerclops", valid = true, tags = {}, components = {} }
        function inst:IsValid() return self.valid end
        function inst:HasTag(tag) return self.tags[tag] == true end
        if trial_owned then inst.tags.ttk_jitan_boss = true end
        inst.components.combat = {}
        inst.components.health = { maxhealth = 1000, currenthealth = 500 }
        function inst.components.health:GetPercent() return self.currenthealth / self.maxhealth end
        function inst.components.health:SetPercent(percent) self.currenthealth = self.maxhealth * percent end
        return inst
    end

    local natural, trial = Boss(false), Boss(true)
    assert(not world:ApplyWorldRankToEntity(natural))
    assert(not world:ApplyWorldRankToEntity(trial))
    world.world_rank_stage = 1
    assert(world:ApplyWorldRankToEntity(natural) and world:ApplyWorldRankToEntity(trial))
    assert(natural.components.health.maxhealth == 1200 and trial.components.health.maxhealth == 1200)
    assert(natural.components.health.currenthealth == 600 and trial.components.health.currenthealth == 600)
    assert(not world:ApplyWorldRankToEntity(trial) and trial.components.health.maxhealth == 1200)
    world.world_rank_stage = 2
    assert(world:ApplyWorldRankToEntity(natural) and world:ApplyWorldRankToEntity(trial))
    assert(natural.components.health.maxhealth == 1500 and trial.components.health.maxhealth == 1500)
    assert(natural.hh_world_rank_base_maxhealth == 1000 and trial.hh_world_rank_base_maxhealth == 1000)
    ''')

# These are the real integrated hook locations that award monster death drops,
# scale after zero-delay initialization, and route enhanced combat. Trial code
# leaves those events/components intact, so killer attribution remains native.
hh_monster = (ROOT / "scripts" / "components" / "hh_monster.lua").read_text(encoding="utf-8")
hh_api = (ROOT / "main" / "hh_api.lua").read_text(encoding="utf-8")
world_rank = (ROOT / "main" / "hh_world_rank.lua").read_text(encoding="utf-8")
assert "StartDeadFn" in hh_monster and "DropEquipByDead" in hh_monster
assert "AddPrefabPostInitAny" in hh_api and 'AddComponentPostInit(' in hh_api
assert "DoAttackDamage" in hh_api and "GetBlockDamage" in hh_api
assert "DoTaskInTime(0" in world_rank and "ApplyWorldRankToEntity" in world_rank
assert "ttk_jitan_boss" not in hh_monster + hh_api + world_rank

print("Đạt: Phàm Nhân bootstrap chạy sau Tế Đàn; capability được đọc muộn trong cùng mod")
print("Đạt: world-rank thật cho boss tự nhiên/thử luyện giống nhau và không nhân lặp")
print("Đạt: Tế Đàn không thêm hh_monster, sửa máu, hoặc giả death/killed")
print("Đạt: hook kill/drop/combat tích hợp vẫn là nguồn duy nhất cho EXP, đồ và sát thương")
