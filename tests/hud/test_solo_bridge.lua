package.path = "./scripts/?.lua;" .. package.path

local Resolver = require("ttk_hud/resolver")
local forwarded = {}
local utils = {
    SpawnClientStrFx = function(_, target, text)
        forwarded[#forwarded + 1] = { target = target, text = text }
    end,
    SpawnClientLevelUpFx = function(_, target, text)
        forwarded[#forwarded + 1] = { target = target, text = text }
    end,
}
package.preload["utils/hh_utils"] = function() return utils end

local emitted = {}
TUNING = { HH_CAN_SHOW_TEXT_FX = true }
local resolver = Resolver.new(function(hit) emitted[#emitted + 1] = hit end)
local bridge = require("ttk_hud/solo_bridge")
assert(bridge.install(resolver) == true)

local target = { GUID = 9001 }
local hit = resolver:begin_hit({ GUID = 7 }, target.GUID, 100)
utils:SpawnClientStrFx(target, "chí mạng x3")
resolver:health_changed(target.GUID, 100, 60, "combat", { GUID = 7 })
resolver:finish_hit(hit, 60)

assert(#emitted == 1, "one resolved popup")
assert(emitted[1].kind == "crit", "known successful branch marks crit")
assert(emitted[1].critical_multiplier == 3, "exact multiplier retained")
assert(#forwarded == 0, "combat phrase is suppressed")

utils:SpawnClientStrFx(target, "+50 EXP")
utils:SpawnClientStrFx(target, "NHIỆM VỤ HOÀN THÀNH")
assert(#forwarded == 2, "non-combat Solo notifications are preserved")

TUNING.HH_CAN_SHOW_TEXT_FX = false
utils:SpawnClientStrFx(target, "+10 EXP")
utils:SpawnClientStrFx(target, "Xuyên Giáp")
assert(#forwarded == 3, "Solo OFF restores only informational text")
assert(TUNING.HH_CAN_SHOW_TEXT_FX == false, "Solo OFF flag is restored")
utils:SpawnClientLevelUpFx(target, "LÊN CẤP")
assert(#forwarded == 4 and TUNING.HH_CAN_SHOW_TEXT_FX == false, "dedicated level-up channel restored under Solo OFF")

-- The hook runs before Solo's HH_CAN_SHOW_TEXT_FX guard in the original
-- method, so metadata remains available even when Solo visual text is off.
hit = resolver:begin_hit({ GUID = 7 }, target.GUID, 60)
utils:SpawnClientStrFx(target, "chí mạng")
resolver:health_changed(target.GUID, 60, 55, "combat", { GUID = 7 })
resolver:finish_hit(hit, 55)
assert(emitted[2].kind == "crit", "crit metadata independent of Solo display setting")

print("solo bridge integration: crit metadata and Solo OFF filtering passed")
