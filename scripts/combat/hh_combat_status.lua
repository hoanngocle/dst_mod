local Context = require("combat/hh_combat_context")
local Math = require("combat/hh_combat_math")
local Prefabs = require("enums/hh_prefab_list")
local Utils = require("utils/hh_utils")
local ElementalCombat = require("ttk_elemental_combat")
local Status = {}

local function Alive(inst)
    return inst ~= nil and inst:IsValid() and inst.components.health ~= nil
        and not inst.components.health:IsDead()
end

local function Boss(target)
    local monster = target.components.hh_monster
    local kind = monster ~= nil and monster:GetMonsterType() or nil
    return kind == "boss_monster" or kind == "endgameboss_monster"
        or (Prefabs.boss_monster or {})[target.prefab] == true
        or (Prefabs.endgameboss_monster or {})[target.prefab] == true
end

local function Immune(target, key)
    local effects = target.components.hh_monster or target.components.hh_player
    return effects ~= nil and effects:HasSpecialEffect(key)
end

local function Packet(kind, attacker, target, damage, weapon, special)
    if not Alive(target) or target.components.combat == nil then return end
    return Context.WithPacket(kind, function()
        return target.components.combat:GetAttacked(attacker, damage, weapon, nil, special)
    end)
end

function Status.ApplyPoison(attacker, target, base_damage)
    if not Alive(target) or Immune(target, "immunePoison") or base_damage <= 0 then return end
    local state = target._hh_combat_poison
    if state ~= nil and state.expires_at < GetTime() then
        state.task:Cancel()
        state = nil
    end
    if state == nil then
        state = {stacks = 0, damage_per_stack = {}}
        target._hh_combat_poison = state
        state.task = target:DoPeriodicTask(2, function()
            if not Alive(target) or GetTime() > state.expires_at then
                state.task:Cancel()
                target._hh_combat_poison = nil
                return
            end
            local total = 0
            for _, damage in ipairs(state.damage_per_stack) do total = total + damage end
            Packet("poison", state.attacker, target, 0, nil, {hh_poison = total})
            if GetTime() >= state.expires_at then
                state.task:Cancel()
                target._hh_combat_poison = nil
            end
        end)
    end
    if state.stacks < 5 then
        state.stacks = state.stacks + 1
        state.damage_per_stack[state.stacks] = base_damage * .2
    end
    state.attacker = attacker
    state.expires_at = GetTime() + 10
end

function Status.ApplyHealReduction(target)
    if not Alive(target) or target.components.hh_buff == nil then return end
    local name = target.components.hh_monster ~= nil and "monster_healthSuppressNum"
        or target.components.hh_player ~= nil and "player_healthSuppressNum" or nil
    if name ~= nil then target.components.hh_buff:AddBuff(name, 5) end
end

function Status.ApplyFreezeOrSlow(target)
    if not Alive(target) or Immune(target, "immuneFreeze")
        or (target._hh_freeze_ready_at or 0) > GetTime() then return end
    if Boss(target) then
        local locomotor = target.components.locomotor
        if locomotor == nil then return end
        locomotor:SetExternalSpeedMultiplier(target, "hh_combat_freeze", .8)
        target:DoTaskInTime(2, function()
            if target:IsValid() and target.components.locomotor ~= nil then
                target.components.locomotor:RemoveExternalSpeedMultiplier(target, "hh_combat_freeze")
            end
        end)
    elseif target.components.freezable ~= nil then
        local freezable = target.components.freezable
        freezable:Freeze(2)
        if freezable:IsFrozen() then
            -- Native Freeze(2) starts a second THAWING period after two seconds.
            -- Own the native expiry handle so later vanilla Freeze/AddColdness
            -- and OnRemoveFromEntity can cancel this timer normally.
            if freezable.wearofftask ~= nil then freezable.wearofftask:Cancel() end
            local expiry
            expiry = target:DoTaskInTime(2, function()
                if target:IsValid() and target.components.freezable == freezable
                    and freezable.wearofftask == expiry then
                    freezable.wearofftask = nil
                    freezable:Unfreeze()
                end
            end)
            freezable.wearofftask = expiry
        end
    else
        return
    end
    target._hh_freeze_ready_at = GetTime() + 5
end

local SPLASH_EXCLUDE = {"player", "companion", "INLIMBO", "wall", "structure"}
function Status.ApplySplash(metadata)
    local attacker, target = metadata.attacker, metadata.target
    local player = attacker.components.hh_player
    local percent = Math.Clamp(player:GetEffectValueByKey("addSplashDamageAOE"), 0, 60)
    local weapon = metadata.weapon
    local damage = metadata.splash_final or 0
    if percent <= 0 or damage <= 0 then return end
    for _, other in ipairs(ElementalCombat.CollectEnemies(attacker, target, 3, target)) do
        local eligible = other ~= attacker and other ~= target and Alive(other)
        local owner = Utils:GetTopFollowerOwner(other)
        if owner == attacker or (owner ~= nil and owner:HasTag("player"))
            or Utils:GetKillCreditPlayer(other) ~= nil then eligible = false end
        for _, tag in ipairs(SPLASH_EXCLUDE) do
            if other:HasTag(tag) then eligible = false end
        end
        if eligible then Packet("splash", attacker, other, damage * percent / 100, weapon) end
    end
end

function Status.TryExecute(attacker, target)
    if not Alive(target) or Boss(target) or target.components.health:IsInvincible() then return end
    local enabled = (attacker.components.hh_player:GetEffectValueByKey("killUnderThreshold") or 0) > 0
    local health = target.components.health
    if enabled and health.currenthealth <= health.maxhealth * .15 then
        Context.WithPacket("execute", function()
            health:DoDelta(-health.currenthealth, false, "hh_execute", nil, attacker)
        end)
    end
end

function Status.AfterPrimary(metadata, resolved)
    if Context.PacketKind() ~= nil or metadata == nil or metadata.status_processed
        or (resolved or 0) <= 0 then return end
    local attacker, target = metadata.attacker, metadata.target
    if not Alive(attacker) or target == nil or attacker.components.hh_player == nil then return end
    metadata.status_processed = true
    local player = attacker.components.hh_player
    local event = metadata.event or {}
    local total = event.damage or resolved
    local piercing = event.spdamage ~= nil and event.spdamage.hh_armor_pierce or 0
    if piercing > 0 and target.components.damagetyperesist ~= nil then
        piercing = piercing * target.components.damagetyperesist:GetResist(attacker, metadata.weapon)
    end
    local eligible = total > 0 and resolved * math.max(0, total - piercing) / total or 0
    player:HandleBloodSuck(eligible, "primary")
    if Alive(target) then
        if Math.RollPercent(player:GetEffectValueByKey("atkAddPoisonChance"), math.random) then
            Status.ApplyPoison(attacker, target, metadata.poison_base or 0)
        end
        if Math.RollPercent(player:GetEffectValueByKey("addSuppressAddHealth"), math.random) then
            Status.ApplyHealReduction(target)
        end
        if Math.RollPercent(player:GetEffectValueByKey("atkChanceAddFreeze"), math.random) then
            Status.ApplyFreezeOrSlow(target)
        end
        local wound = player:GetEffectValueByKey("targetPercentDamage") or 0
        if wound > 0 and not Immune(target, "immuneTearing") then
            Packet("heavy_wound", attacker, target,
                target.components.health.currenthealth * math.min(wound, Boss(target) and 1 or 3) / 100,
                metadata.weapon)
        end
    end
    Status.ApplySplash(metadata)
    if not metadata.death_threshold_prevented then Status.TryExecute(attacker, target) end
end

return Status
