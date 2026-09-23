local Rules = require("ttk_lucnguyen_rules")

local M = {}
local active = {}
local finished = setmetatable({}, { __mode = "k" })
local unpack_values = unpack or table.unpack
local solo_frames = {}

local function IsValid(inst)
    return inst ~= nil and (inst.IsValid == nil or inst:IsValid())
end

local function IsCriticalText(text)
    local prefix = "chí mạng"
    return type(text) == "string" and string.sub(text, 1, #prefix) == prefix
end

local function FindActive(owner, target)
    for i = #active, 1, -1 do
        local context = active[i]
        if context.owner == owner and context.target == target
            and not context.solo_entered then
            return context
        end
    end
end

function M.ObserveSoloText(target, text)
    if not IsCriticalText(text) then return end
    local frame = solo_frames[#solo_frames]
    if frame ~= nil and frame.target == target and frame.context ~= nil then
        frame.context.critical = true
    end
end

function M.InstallSoloObserver(utils)
    if type(utils) ~= "table" or type(utils.SpawnClientStrFx) ~= "function" then
        return false
    end
    if utils._ttk_lucnguyen_crit_observer then return true end
    local original = utils.SpawnClientStrFx
    utils.SpawnClientStrFx = function(self, target, text, ...)
        local results = { original(self, target, text, ...) }
        M.ObserveSoloText(target, text)
        return unpack_values(results)
    end
    utils._ttk_lucnguyen_crit_observer = true
    return true
end

-- Solo emits its critical text synchronously from hh_player:DoAttackDamage.
-- Scope the text observer to that exact attacker/target call so nested attacks
-- and simultaneous projectiles cannot claim one another's critical result.
function M.InstallSoloComponent(component)
    if type(component) ~= "table" or type(component.DoAttackDamage) ~= "function" then
        return false
    end
    if component.DoAttackDamage == component._ttk_lucnguyen_damage_wrapper then
        return true
    end
    local original = component.DoAttackDamage
    local wrapper = function(self, attacker, target, damage, ...)
        local aux = attacker ~= nil and attacker._ttk_lucnguyen_aux_stack or nil
        local aux_frame = aux ~= nil and aux[#aux] or nil
        if aux_frame ~= nil and aux_frame.target == target then
            return damage
        end
        local frame = {
            target = target,
            context = FindActive(attacker, target),
        }
        if frame.context ~= nil then
            frame.context.solo_entered = true
        end
        table.insert(solo_frames, frame)
        local results = { pcall(original, self, attacker, target, damage, ...) }
        table.remove(solo_frames)
        local ok = table.remove(results, 1)
        if not ok then error(results[1], 0) end
        return unpack_values(results)
    end
    component._ttk_lucnguyen_damage_wrapper = wrapper
    component.DoAttackDamage = wrapper
    return true
end

function M.IsAuxiliaryAttack(attacker, target)
    local stack = attacker ~= nil and attacker._ttk_lucnguyen_aux_stack or nil
    local frame = stack ~= nil and stack[#stack] or nil
    return frame ~= nil and (target == nil or frame.target == target)
end

function M.InstallWorldComponent(component)
    if type(component) ~= "table"
        or type(component.ResolveWorldRankDamageSource) ~= "function" then
        return false
    end
    if component.ResolveWorldRankDamageSource == component._ttk_lucnguyen_source_wrapper then
        return true
    end
    local original = component.ResolveWorldRankDamageSource
    local wrapper = function(self, attacker, ...)
        if M.IsAuxiliaryAttack(attacker) then return nil end
        return original(self, attacker, ...)
    end
    component._ttk_lucnguyen_source_wrapper = wrapper
    component.ResolveWorldRankDamageSource = wrapper
    return true
end

-- Solo adds godslayer planar damage after DoAttackDamage. Suppress that exact
-- attacker-side bonus for auxiliary swords while leaving the target's normal
-- GetAttacked/armor path intact.
function M.InstallGodslayerComponent(component)
    if type(component) ~= "table" or type(component.GetBonusDamage) ~= "function" then
        return false
    end
    if component.GetBonusDamage == component._ttk_lucnguyen_bonus_wrapper then
        return true
    end
    local original = component.GetBonusDamage
    local wrapper = function(self, target, ...)
        if M.IsAuxiliaryAttack(self.inst, target) then return 0 end
        return original(self, target, ...)
    end
    component._ttk_lucnguyen_bonus_wrapper = wrapper
    component.GetBonusDamage = wrapper
    return true
end

local function IsAuxEvent(owner, target, weapon, stimuli)
    local stack = owner ~= nil and owner._ttk_lucnguyen_aux_stack or nil
    local frame = stack ~= nil and stack[#stack] or nil
    return frame ~= nil and frame.target == target and frame.weapon == weapon
        and (stimuli == nil or stimuli == "ttk_lucnguyen_auxiliary")
end

local function EnsureCombatCallbackFilter(owner)
    local combat = owner.components ~= nil and owner.components.combat or nil
    if combat == nil then return end
    if combat.onhitotherfn ~= owner._ttk_lucnguyen_onhitother_wrapper then
        owner._ttk_lucnguyen_onhitother_original = combat.onhitotherfn
        local wrapper = function(attacker, target, damage, stimuli, weapon, ...)
            if IsAuxEvent(attacker, target, weapon, stimuli) then return end
            local fn = owner._ttk_lucnguyen_onhitother_original
            if fn ~= nil then
                return fn(attacker, target, damage, stimuli, weapon, ...)
            end
        end
        owner._ttk_lucnguyen_onhitother_wrapper = wrapper
        combat.onhitotherfn = wrapper
    end
end

function M.InstallOwner(owner)
    if owner == nil then return false end
    if not owner._ttk_lucnguyen_event_filter then
        local original_push = owner.PushEvent
        if type(original_push) ~= "function" then return false end
        owner.PushEvent = function(self, event, data, ...)
            if event == "onhitother" and type(data) == "table"
                and IsAuxEvent(self, data.target, data.weapon, data.stimuli) then
                return
            end
            return original_push(self, event, data, ...)
        end
        owner._ttk_lucnguyen_event_filter = true
        if type(owner.ListenForEvent) == "function" then
            owner:ListenForEvent("onhitother", function(inst, data)
                M.ObserveLanded(inst, data)
            end)
        end
    end
    EnsureCombatCallbackFilter(owner)
    return true
end

function M.BeginPrimary(owner, target, weapon, token, base_damage)
    if token == nil or finished[token] then return nil end
    M.InstallOwner(owner)
    local context = {
        owner = owner,
        target = target,
        weapon = weapon,
        token = token,
        base_damage = base_damage,
        critical = false,
        landed = false,
    }
    table.insert(active, context)
    return context
end

function M.ObserveLanded(owner, data)
    if type(data) ~= "table" or type(data.damageresolved) ~= "number"
        or data.damageresolved <= 0 then
        return
    end
    for i = #active, 1, -1 do
        local context = active[i]
        if context.owner == owner and context.target == data.target
            and context.weapon == data.weapon then
            context.landed = true
            return
        end
    end
end

function M.EndPrimary(token)
    if token == nil or finished[token] then return nil end
    finished[token] = true
    for i = #active, 1, -1 do
        local context = active[i]
        if context.token == token then
            table.remove(active, i)
            if context.critical and context.landed and IsValid(context.owner)
                and IsValid(context.target) then
                return context
            end
            return nil
        end
    end
    return nil
end

function M.CancelPrimary(token)
    if token == nil or finished[token] then return end
    finished[token] = true
    for i = #active, 1, -1 do
        if active[i].token == token then
            table.remove(active, i)
            return
        end
    end
end

function M.DamageSnapshot(weapon, owner, target)
    local component = weapon ~= nil and weapon.components ~= nil
        and weapon.components.weapon or nil
    if component == nil then return 0 end
    if type(component.GetDamage) == "function" then
        local damage = component:GetDamage(owner, target)
        return type(damage) == "number" and damage or 0
    end
    return type(component.damage) == "number" and component.damage or 0
end

function M.LaunchVolley(owner, target, base_damage, random, spawn)
    if not IsValid(owner) or not IsValid(target) then return 0 end
    local volley = Rules.RollVolley(base_damage, random)
    for index, shot in ipairs(volley) do
        local data = {
            owner = owner,
            target = target,
            damage = shot.damage,
            element = shot.element,
            index = index,
            count = #volley,
        }
        if spawn ~= nil then
            spawn(data)
        else
            local projectile = SpawnPrefab("ttk_lucnguyen_sword_" .. tostring(shot.element))
            if projectile ~= nil and projectile.Launch ~= nil then
                projectile:Launch(data)
            elseif projectile ~= nil then
                projectile:Remove()
            end
        end
    end
    return #volley
end

function M.ApplyAuxiliary(owner, target, damage, weapon, base_get_attacked, spdamage)
    if not IsValid(owner) or not IsValid(target) or type(damage) ~= "number"
        or damage <= 0 or target.components == nil or target.components.combat == nil then
        return false
    end
    if base_get_attacked == nil then
        base_get_attacked = target.components.combat.GetAttacked
    end
    if type(base_get_attacked) ~= "function" then return false end

    M.InstallOwner(owner)
    EnsureCombatCallbackFilter(owner)
    owner._ttk_lucnguyen_aux_stack = owner._ttk_lucnguyen_aux_stack or {}
    table.insert(owner._ttk_lucnguyen_aux_stack, {
        target = target,
        weapon = weapon,
    })
    local results = { pcall(base_get_attacked, target.components.combat,
        owner, damage, weapon, "ttk_lucnguyen_auxiliary", spdamage) }
    table.remove(owner._ttk_lucnguyen_aux_stack)
    if #owner._ttk_lucnguyen_aux_stack == 0 then
        owner._ttk_lucnguyen_aux_stack = nil
    end
    local ok = table.remove(results, 1)
    if not ok then error(results[1], 0) end
    return results[1] ~= false
end

return M
