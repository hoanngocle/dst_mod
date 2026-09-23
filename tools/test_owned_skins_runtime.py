"""Focused Lua smoke checks for the native owned-skin adapter."""
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / ".superpowers/luoshen-runtime"))
from lupa.lua51 import LuaRuntime

lua = LuaRuntime(unpack_returned_tuples=True)
scripts = (ROOT / "mods/PhamNhanTuTien/scripts").as_posix()
lua.execute(f'package.path = "{scripts}/?.lua;" .. package.path')
lua.execute(r'''
TheWorld = { ismastersim = true }
local effect = { clears = 0, applies = 0 }
function effect.Clear(inst) effect.clears = effect.clears + 1 end
function effect.Apply(inst, skin) effect.applies = effect.applies + 1 end
package.preload["ttk_skin_effects"] = function() return effect end
package.preload["ttt_portal_visuals"] = function()
    return { ApplySkin = function(inst, name) inst.portal_skin = name end }
end

local skins = require("ttk_skins")
local function Entity(prefab)
    local calls = {}
    local anim = {}
    function anim:SetBank(v) calls.bank = v end
    function anim:SetBuild(v) calls.build = v end
    function anim:PlayAnimation(v, loop) calls.animation = v; calls.loop = loop end
    return { prefab = prefab, AnimState = anim, components = {}, calls = calls }
end

local wrong = Entity("ttk_hmsw")
assert(skins.Apply(wrong, "ttk_tree_xhs_skins_lgs") == false)
assert(wrong.calls.build == nil)

local weapon = Entity("ttk_tinhlakiem")
assert(skins.Apply(weapon, "ttk_tinhlakiem_skins_hasaki") == true)
assert(weapon.calls.build == "xd_skin_hasaki" and weapon.calls.animation == "idle")
assert(effect.clears == 1 and effect.applies == 1)
assert(skins.Get("ttk_tinhlakiem_skins_hasaki").equip_symbol == "png")
assert(skins.Get("ttk_tinhlakiem_skins_ylxh").equip_symbol == "swap")
local held = {
    skinname = "ttk_tinhlakiem_skins_hasaki",
    GetSkinName = function(self) return self.skinname end,
    GetSkinBuild = function(self) return "xd_skin_hasaki" end,
}
local held_build, held_symbol = skins.GetEquipPresentation(held, "xd_xlj", "swap")
assert(held_build == "xd_skin_hasaki" and held_symbol == "png")
local builder = {
    skinname = "ttk_tienkiem_skins_wendao",
    GetSkinName = function(self) return self.skinname end,
    GetSkinBuild = function(self) return "xd_xianjian_builder_skins_wendao" end,
}
local builder_build, builder_symbol = skins.GetEquipPresentation(builder, "xd_sword_red", "png")
assert(builder_build == "xd_sword_red_wendao" and builder_symbol == "png")
local umbrella = {
    skinname = "nhatvuphuonghoa_skins_lxzy",
    GetSkinName = function(self) return self.skinname end,
    GetSkinBuild = function(self) return "xd_sudaji_ywfh_lxzy" end,
}
local umbrella_build, closed_symbol = skins.GetEquipPresentation(umbrella, "xd_sudaji_ywfh", "swap")
local _, open_symbol = skins.GetEquipPresentation(umbrella, "xd_sudaji_ywfh", "up_swap")
assert(umbrella_build == "xd_sudaji_ywfh_lxzy" and closed_symbol == "swap" and open_symbol == "swap")
assert(skins.GetIconName("ttk_tinhlakiem_skins_hasaki") == "ttk_shared_xd_skin_hasaki")
assert(skins.Get("ttk_xshj_skins_hyparmor").bank == "xd_xshj")
assert(skins.Get("ttk_zcmj_skins_yaohat").build == "xd_yaohat")

local staged = Entity("ttk_qwsk")
assert(skins.Apply(staged, "ttk_qwsk_skins_xznw") == true)
assert(staged.calls.build == "xd_qwsk_xznw" and staged.calls.animation == nil)

assert(skins.Clear(weapon) == true)
assert(weapon.calls.bank == "xd_xlj" and weapon.calls.build == "xd_xlj")

local portal = Entity("homesign")
assert(skins.Apply(portal, "ttt_portal_gcsz") == true and portal.portal_skin == "ttt_portal_gcsz")
assert(skins.Clear(portal) == true and portal.portal_skin == nil)
print("owned skin Lua smoke checks: ok")
''')

effects = LuaRuntime(unpack_returned_tuples=True)
effects.execute(f'package.path = "{scripts}/?.lua;" .. package.path')
effects.execute(r'''
local spawned
function SpawnPrefab(name)
    assert(name == "ttk_skin_hyys_fx")
    spawned = { valid = true, entity = {} }
    function spawned.entity:SetParent(parent) spawned.parent = parent end
    function spawned:IsValid() return self.valid end
    function spawned:Remove() self.valid = false end
    return spawned
end
local fx = require("ttk_skin_effects")
local inst = { entity = {}, components = {} }
fx.Apply(inst, "ttk_tinhlakiem_skins_hyys")
assert(inst._ttk_skin_cosmetic == spawned and spawned.parent == inst.entity)
fx.Clear(inst)
assert(spawned.valid == false and inst._ttk_skin_cosmetic == nil)
print("owned skin presentation FX smoke checks: ok")
''')
