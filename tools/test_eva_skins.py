from pathlib import Path
import sys
import unittest


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT.parents[1] / ".superpowers/ttk-solo-integration/lua-runtime"))
from lupa.lua51 import LuaRuntime


MODULE = ROOT / "scripts/util/eva_skins.lua"
PREFAB = ROOT / "scripts/prefabs/eva_none.lua"


class EvaSkinsTest(unittest.TestCase):
    def setUp(self):
        self.assertTrue(MODULE.exists(), "EVA skin registration module is missing")
        self.assertTrue(PREFAB.exists(), "EVA default skin prefab is missing")
        self.lua = LuaRuntime(unpack_returned_tuples=True)
        self.lua.execute(
            r'''
function table.contains(items, wanted)
    for _, value in ipairs(items or {}) do
        if value == wanted then return true end
    end
    return false
end

DST_CHARACTERLIST = {"wilson"}
MODCHARACTERLIST = {"eva", "othermod"}
MODCHARACTEREXCEPTIONS_DST = {}
PREFAB_SKINS = {eva = {"eva_none"}, wilson = {"wilson_none"}, othermod = {"othermod_none", "othermod_skin"}}
PREFAB_SKINS_IDS = {eva = {eva_none = 1}}
STRINGS = {SKIN_NAMES = {}, SKIN_DESCRIPTIONS = {}, SKIN_QUOTES = {}}

local InventoryMethods = {}
TheInventory = setmetatable({calls = {}}, {__index = InventoryMethods})
function InventoryMethods:CheckOwnership(name)
    table.insert(self.calls, "local:" .. tostring(name))
    return name == "official_owned"
end
function InventoryMethods:CheckOwnershipGetLatest(name)
    table.insert(self.calls, "latest:" .. tostring(name))
    return name == "official_owned", 1234
end
function InventoryMethods:CheckClientOwnership(userid, name)
    table.insert(self.calls, "client:" .. tostring(userid) .. ":" .. tostring(name))
    return name == "official_owned"
end

LoadoutSelect = {}
function LoadoutSelect._ctor(self, user_profile, character, marker)
    self.have_base_option = table.contains(DST_CHARACTERLIST, character)
    if marker == "explode" then error("native constructor failed") end
    return "first", nil, "third"
end

function require(name)
    if name == "widgets/redux/loadoutselect" then return LoadoutSelect end
    error("missing stub " .. tostring(name))
end

function ExceptionArrays(items, exceptions)
    local result = {}
    for _, value in ipairs(items) do
        if not table.contains(exceptions, value) then table.insert(result, value) end
    end
    return result
end

function ValidateSpawnPrefabRequest(userid, prefab, skin)
    local valid = ExceptionArrays(DST_CHARACTERLIST, MODCHARACTEREXCEPTIONS_DST)
    local in_mod = table.contains(MODCHARACTERLIST, prefab)
    if skin == "explode" then error("native validation failed") end
    if table.contains(valid, prefab) then
        if skin == prefab .. "_none" then return prefab, skin end
        if TheInventory:CheckClientOwnership(userid, skin)
            and table.contains(PREFAB_SKINS[prefab], skin) then
            return prefab, skin
        end
        return prefab, nil
    elseif in_mod then
        return prefab, nil
    end
    return valid[1], nil
end
'''
        )
        self.module = self.lua.execute(MODULE.read_text(encoding="utf-8-sig"))
        self.lua.globals().EvaSkins = self.module

    def install(self):
        self.lua.execute("EvaSkins.Install({GLOBAL = _G, require = require})")

    def test_registers_only_default_eva_skin_metadata(self):
        self.install()
        self.install()
        self.lua.execute(
            r'''
assert(#PREFAB_SKINS.eva == 1)
assert(PREFAB_SKINS.eva[1] == "eva_none")
assert(PREFAB_SKINS_IDS.eva.eva_none == 1)
assert(PREFAB_SKINS.wilson[1] == "wilson_none" and #PREFAB_SKINS.wilson == 1)
'''
        )

    def test_skin_installation_does_not_override_inventory_entitlements(self):
        self.install()
        self.lua.execute(
            r'''
assert(TheInventory:CheckOwnership("eva_purple") == false)
local owned, latest = TheInventory:CheckOwnershipGetLatest("eva_purple")
assert(owned == false and latest == 1234)
assert(TheInventory:CheckClientOwnership("KU_eva", "eva_purple") == false)

assert(TheInventory:CheckOwnership("locked_official") == false)
local other_owned, other_latest = TheInventory:CheckOwnershipGetLatest("locked_official")
assert(other_owned == false and other_latest == 1234)
assert(TheInventory:CheckClientOwnership("KU_other", "locked_official") == false)
assert(TheInventory:CheckOwnership("official_owned") == true)
'''
        )

    def test_eva_gets_native_base_panel_without_mutating_character_lists(self):
        self.install()
        self.lua.execute(
            r'''
local original_contains = table.contains
local eva = {}
local first, middle, third = LoadoutSelect._ctor(eva, {}, "eva")
assert(eva.have_base_option == true)
assert(first == "first" and middle == nil and third == "third")
assert(table.contains == original_contains)
assert(#DST_CHARACTERLIST == 1 and DST_CHARACTERLIST[1] == "wilson")

local other = {}
LoadoutSelect._ctor(other, {}, "othermod")
assert(other.have_base_option == false)

local ok = pcall(LoadoutSelect._ctor, {}, {}, "eva", "explode")
assert(ok == false and table.contains == original_contains,
    "temporary character-list adapter leaked after constructor error")
'''
        )

    def test_server_accepts_default_and_rejects_removed_skin(self):
        self.install()
        self.lua.execute(
            r'''
local original_exception_arrays = ExceptionArrays
local prefab, skin = ValidateSpawnPrefabRequest("KU_eva", "eva", "eva_purple")
assert(prefab == "eva" and skin == nil)
local reset_prefab, reset_skin = ValidateSpawnPrefabRequest(
    "KU_eva", "eva", "eva_none")
assert(reset_prefab == "eva" and reset_skin == "eva_none")
assert(ExceptionArrays == original_exception_arrays)
assert(#DST_CHARACTERLIST == 1 and DST_CHARACTERLIST[1] == "wilson")

local other_prefab, other_skin = ValidateSpawnPrefabRequest(
    "KU_other", "othermod", "othermod_skin")
assert(other_prefab == "othermod" and other_skin == nil,
    "another mod character skin was incorrectly unlocked")

local ok = pcall(ValidateSpawnPrefabRequest, "KU_eva", "eva", "explode")
assert(ok == false and ExceptionArrays == original_exception_arrays,
    "temporary server-validation adapter leaked after native error")
'''
        )

    def test_default_prefab_uses_the_default_eva_build(self):
        self.lua.execute(
            r'''
function Asset(kind, file) return {kind = kind, file = file} end
function CreatePrefabSkin(name, info) return {name = name, info = info} end
'''
        )
        prefab = self.lua.execute(PREFAB.read_text(encoding="utf-8-sig"))
        self.lua.globals().DefaultPrefab = prefab
        self.lua.execute(
            r'''
local prefab = DefaultPrefab
assert(prefab.name == "eva_none")
assert(prefab.info.base_prefab == "eva" and prefab.info.type == "base")
assert(prefab.info.build_name_override == "eva")
assert(prefab.info.skins.normal_skin == "eva")
assert(prefab.info.skins.ghost_skin == "ghost_eva_build")
assert(prefab.info.skip_item_gen == true and prefab.info.skip_giftable_gen == true)
assert(prefab.info.assets[1].kind == "ANIM"
    and prefab.info.assets[1].file == "anim/eva.zip")
'''
        )


if __name__ == "__main__":
    unittest.main()
