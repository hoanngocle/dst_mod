package.path = "./scripts/?.lua;" .. package.path

Ents = {}
CLIENT_MOD_RPC = { ttk_hud = { damage = "damage_rpc" } }
local calls = {}
function SendModRPCToClient(rpc, userid, guid, amount, kind, x, y, z)
    calls[#calls + 1] = { rpc, userid, guid, amount, kind, x, y, z }
end

local post = {}
local env = {
    AddComponentPostInit = function(name, fn) post[name] = fn end,
    AddSimPostInit = function(fn) fn() end,
}

local target = {
    GUID = 22,
    Transform = { GetWorldPosition = function() return 1, 2, 3 end },
    components = {},
}
Ents[target.GUID] = target
local player = {
    GUID = 11, userid = "KU_test", components = {},
    HasTag = function(_, tag) return tag == "player" end,
}

local server_damage = require("ttk_hud/server_damage")
server_damage.install(env)

local health = {
    inst = target, currenthealth = 12, maxhealth = 12,
    IsDead = function(self) return self.currenthealth <= 0 end,
    SetVal = function(self, value)
        self.currenthealth = math.max(0, value)
        if self.currenthealth == 0 then Ents[self.inst.GUID] = nil end
        return "set-return"
    end,
}
target.components.health = health
post.health(health)

local combat = {
    inst = target,
    GetAttacked = function(self, attacker, damage)
        local returned = self.inst.components.health:SetVal(self.inst.components.health.currenthealth - damage, "combat", attacker)
        return true, returned
    end,
}
target.components.combat = combat
post.combat(combat)

local accepted, returned = combat:GetAttacked(player, 999)
assert(accepted == true and returned == "set-return", "combat return values preserved")
assert(#calls == 1, "one RPC from the sole SetVal collector")
assert(calls[1][2] == "KU_test", "popup routed to attacking player")
assert(calls[1][4] == 12, "lethal popup uses actual health lost")
assert(calls[1][5] == "normal", "normal type retained")
assert(calls[1][6] == 1 and calls[1][7] == 2 and calls[1][8] == 3, "lethal snapshot position retained")

health.currenthealth = 5
health.SetVal = function(self, value) self.currenthealth = value; return nil, "middle", nil end
post.health(health)
local tuple = { n = 0 }
local function capture(... ) tuple.n = select("#", ...); for i = 1, tuple.n do tuple[i] = select(i, ...) end end
capture(health:SetVal(5, "heal", player))
assert(tuple.n == 3 and tuple[1] == nil and tuple[2] == "middle" and tuple[3] == nil, "SetVal nil holes retained")

combat.GetAttacked = function() return false, "dodged" end
-- Reinstalling a fresh combat component is how DST invokes the post-init.
local dodge = { inst = target, GetAttacked = combat.GetAttacked }
post.combat(dodge)
health.currenthealth = 12
accepted, returned = dodge:GetAttacked(player, 50)
assert(accepted == false and returned == "dodged", "dodge return values preserved")
assert(#calls == 1, "dodge creates no popup")

local broken = { inst = target, GetAttacked = function() error("expected combat failure") end }
post.combat(broken)
local ok = pcall(function() broken:GetAttacked(player, 1) end)
assert(not ok and #server_damage.resolver.stack == 0, "failed combat unwinds resolver transaction")

-- Nested SetVal emits only the child loss plus the outer method's own loss.
Ents[target.GUID] = target
health.currenthealth = 100
local nested_once = false
health.SetVal = function(self, value, cause, afflicter)
    if not nested_once then
        nested_once = true
        self.currenthealth = 90
        self:SetVal(80, cause, afflicter)
    else
        self.currenthealth = value
    end
end
post.health(health)
local before_calls = #calls
health:SetVal(80, "combat", player)
local total = 0
for i = before_calls + 1, #calls do total = total + calls[i][4] end
assert(total == 20, "nested SetVal portions equal actual total loss")

print("server damage integration: lethal removal, tuple arity, and dodge passed")
