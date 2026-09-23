local Resolver = require("ttk_hud/resolver")
local Bridge = require("ttk_hud/solo_bridge")

local M = {}
local snapshots = {}
local health_frames = {}
local function pack(...) return { n = select("#", ...), ... } end
local function invoke(fn, ...) return pcall(function(...) return pack(fn(...)) end, ...) end

local function source_player(attacker)
    if type(attacker) ~= "table" then return nil end
    local current = attacker
    local seen = {}
    while current ~= nil and not seen[current] do
        seen[current] = true
        if current.userid ~= nil and current:HasTag("player") then return current end
        local follower = current.components ~= nil and current.components.follower or nil
        current = follower ~= nil and follower:GetLeader() or current.sourceplayer
    end
end

local resolver = Resolver.new(function(hit)
    local player = source_player(hit.attacker)
    local victim = Ents[hit.victim]
    local stack = snapshots[hit.victim]
    local pos = stack ~= nil and stack[#stack] or nil
    if player == nil or player.userid == nil or (victim == nil and pos == nil) then return end
    local x, y, z = pos[1], pos[2], pos[3]
    if victim ~= nil and (victim.IsValid == nil or victim:IsValid()) then x, y, z = victim.Transform:GetWorldPosition() end
    SendModRPCToClient(CLIENT_MOD_RPC.ttk_hud.damage, player.userid,
        hit.victim, hit.amount, hit.kind, x, y, z)
    if TUNING ~= nil and TUNING.TTK_HUD ~= nil and TUNING.TTK_HUD.SHOW_OTHERS then
        for _, other in ipairs(AllPlayers) do
            if other ~= player and other.userid ~= nil and other:GetDistanceSqToPoint(x, y, z) <= 1225 then
                SendModRPCToClient(CLIENT_MOD_RPC.ttk_hud.damage, other.userid,
                    hit.victim, hit.amount, hit.kind, x, y, z)
            end
        end
    end
end)

function M.install(env)
    Bridge.install_component_hooks(resolver, env)
    env.AddComponentPostInit("health", function(self)
        local original = self.SetVal
        self.SetVal = function(component, value, cause, afflicter, ...)
            local before = component.currenthealth
            local guid = component.inst.GUID
            local stack = snapshots[guid] or {}
            snapshots[guid] = stack
            stack[#stack + 1] = { component.inst.Transform:GetWorldPosition() }
            local frames = health_frames[guid] or {}
            health_frames[guid] = frames
            local frame = { nested = 0 }
            frames[#frames + 1] = frame
            local ok, result = invoke(original, component, value, cause, afflicter, ...)
            local after = component.currenthealth
            local total_change = before ~= nil and after ~= nil and (before - after) or 0
            local own_change = total_change - frame.nested
            if own_change > 0 then
                resolver:health_changed(guid, before, before - own_change, cause, afflicter)
            end
            table.remove(frames)
            if #frames > 0 then frames[#frames].nested = frames[#frames].nested + total_change end
            if #frames == 0 then health_frames[guid] = nil end
            table.remove(stack)
            if #stack == 0 then snapshots[guid] = nil end
            if not ok then error(result, 0) end
            return unpack(result, 1, result.n)
        end
    end)

    env.AddComponentPostInit("combat", function(self)
        local original = self.GetAttacked
        self.GetAttacked = function(component, attacker, damage, ...)
            local health = component.inst.components.health
            if health == nil or health:IsDead() then return original(component, attacker, damage, ...) end
            local token = resolver:begin_hit(attacker, component.inst.GUID, health.currenthealth)
            local ok, result = invoke(original, component, attacker, damage, ...)
            resolver:finish_hit(token, health.currenthealth)
            if not ok then error(result, 0) end
            return unpack(result, 1, result.n)
        end
    end)

    env.AddSimPostInit(function() Bridge.install_text(resolver) end)
end

M.resolver = resolver
return M
