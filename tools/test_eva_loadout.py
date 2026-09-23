from pathlib import Path
import sys
import unittest


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT.parents[1] / ".superpowers/ttk-solo-integration/lua-runtime"))
from lupa.lua51 import LuaRuntime


class EvaLoadoutTest(unittest.TestCase):
    def test_new_eva_starts_with_an_empty_inventory(self):
        lua = LuaRuntime(unpack_returned_tuples=True)
        lua.execute(
            r'''
GLOBAL = {
    require = function() return {DESCRIBE = {}} end,
    STRINGS = {
        CHARACTER_TITLES = {}, CHARACTER_NAMES = {}, CHARACTER_DESCRIPTIONS = {},
        CHARACTER_QUOTES = {}, CHARACTER_SURVIVABILITY = {},
        CHARACTERS = {GENERIC = {DESCRIBE = {}}, EVA = {DESCRIBE = {}}},
        NAMES = {}, SKIN_NAMES = {}, SKIN_DESCRIPTIONS = {}, RECIPE_DESC = {},
    },
}
STRINGS = GLOBAL.STRINGS
TUNING = {
    GAMEMODE_STARTING_ITEMS = {DEFAULT = {}},
    STARTING_ITEM_IMAGE_OVERRIDE = {},
    WILSON_HUNGER_RATE = 1,
}
function GetModConfigData() return true end
'''
        )
        lua.execute((ROOT / "scripts/util/eva_settings.lua").read_text(encoding="utf-8-sig"))
        lua.execute(
            r'''
assert(type(TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.EVA) == "table")
assert(next(TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.EVA) == nil)
assert(TUNING.STARTING_ITEM_IMAGE_OVERRIDE.eva_scythe == nil)
'''
        )

    def test_runtime_does_not_register_the_removed_weapon_or_alt_skin(self):
        lua = LuaRuntime(unpack_returned_tuples=True)
        lua.execute(
            r'''
imports = {}
function Asset(kind, file) return {kind = kind, file = file} end
function AddMinimapAtlas() end
function modimport(path) table.insert(imports, path) end
function AddAction() return {} end
function AddComponentPostInit() end
function AddModCharacter() end
function AddClassPostConstruct() end
function AddStategraphState() end
function AddStategraphPostInit() end
function AddStategraphActionHandler() end
function AddModRPCHandler() end
function SendModRPCToServer() end
function require(name)
    if name == "util/eva_skins" then return {Install = function() end} end
    if name == "util/eva_skillpanel" then
        return {Install = function() end, CastFoxAction = function() end,
            CanUseFoxShortcut = function() return false end}
    end
    if name == "util/eva_skillpanel_states" then return {Install = function() end} end
    error("unexpected require: " .. tostring(name))
end
GLOBAL = {
    TheNet = {IsDedicated = function() return true end},
    KEY_1 = 1, KEY_2 = 2, KEY_3 = 3, KEY_4 = 4, KEY_5 = 5,
}
TheNet = GLOBAL.TheNet
'''
        )
        lua.execute((ROOT / "main/ttk_eva_source.lua").read_text(encoding="utf-8-sig"))
        lua.execute(
            r'''
local prefab_set = {}
for _, name in ipairs(PrefabFiles) do prefab_set[name] = true end
assert(prefab_set.eva == true and prefab_set.eva_none == true)
assert(prefab_set.eva_purple == nil)
assert(prefab_set.eva_scythe == nil)

for _, path in ipairs(imports) do
    assert(path ~= "scripts/util/eva_recipes.lua")
end
for _, asset in ipairs(Assets) do
    assert(asset.file ~= "images/inventoryimages/eva_scythe_starting.tex")
    assert(asset.file ~= "images/inventoryimages/eva_scythe_starting.xml")
end
'''
        )


if __name__ == "__main__":
    unittest.main()
