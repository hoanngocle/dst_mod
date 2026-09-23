package.path = "./scripts/?.lua;" .. package.path

local Resolver = require("ttk_hud/resolver")

local function eq(actual, expected, label)
    if actual ~= expected then error((label or "value") .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual), 2) end
end

local sent = {}
local resolver = Resolver.new(function(hit) sent[#sent + 1] = hit end)

-- The normal integration path brackets Combat:GetAttacked, records exact Solo
-- critical metadata during DoAttackDamage, then resolves against real health loss.
local token = resolver:begin_hit(101, 202, 100)
resolver:mark_critical(token, 2)
resolver:health_changed(202, 100, 63, "combat", 101)
resolver:finish_hit(token, 63)
eq(#sent, 1, "normal event count")
eq(sent[1].kind, "crit", "critical kind")
eq(sent[1].amount, 37, "actual loss")

-- A true-damage SetVal/healthdelta nested inside the attack is its own portion;
-- finish_hit must not emit the same loss again as normal damage.
token = resolver:begin_hit(101, 202, 63)
resolver:health_changed(202, 63, 53, "hh_true_damage", 101)
resolver:health_changed(202, 53, 38, "combat", 101)
resolver:finish_hit(token, 38)
eq(#sent, 3, "split event count")
eq(sent[2].kind, "true", "true portion")
eq(sent[2].amount, 10, "true portion amount")
eq(sent[3].kind, "normal", "remaining portion")
eq(sent[3].amount, 15, "remaining portion amount")

-- Blocked/dodged calls never create zero popups. Repeated identical real SetVal
-- transitions remain distinct hits (there is no event-listener duplication path).
token = resolver:begin_hit(101, 202, 38)
resolver:finish_hit(token, 38)
eq(#sent, 3, "blocked event count")
resolver:health_changed(202, 38, 30, "combat", 101)
resolver:health_changed(202, 38, 30, "combat", 101)
eq(#sent, 5, "repeated real transition count")
eq(sent[4].amount, 8, "outside event loss")

print("resolver integration: 12 assertions passed")
