-- Shared authoritative effects for Lục Nguyên projectiles and held swords.
local Bridge = require("ttk_lucnguyen_combat")
local CombatContext = require("combat/hh_combat_context")

local M = {}
local SLOW_KEY = "ttk_elemental_slow"
local SECONDARY_CANT_TAGS = {
    "INLIMBO", "FX", "NOCLICK", "DECOR", "playerghost", "notarget", "noattack",
}

local function IsValid(inst)
    return inst ~= nil and (inst.IsValid == nil or inst:IsValid())
end

local function IsAlive(inst)
    return IsValid(inst)
        and (inst.IsInLimbo == nil or not inst:IsInLimbo())
        and inst.components ~= nil
        and inst.components.health ~= nil
        and not inst.components.health:IsDead()
end

local function IsHostile(owner, candidate)
    if not IsAlive(candidate) or candidate == owner
        or candidate.components.combat == nil
        or candidate.HasTag == nil
        or candidate:HasTag("player")
        or candidate:HasTag("playerghost")
        or candidate:HasTag("companion")
        or candidate:HasTag("critter")
        or candidate:HasTag("wall")
        or candidate:HasTag("structure") then
        return false
    end
    local combat = owner ~= nil and owner.components ~= nil and owner.components.combat or nil
    if combat ~= nil and combat.IsAlly ~= nil and combat:IsAlly(candidate) then return false end
    if combat ~= nil and combat.CanTarget ~= nil and not combat:CanTarget(candidate) then return false end
    local theirs = candidate.components.combat
    return candidate:HasTag("hostile")
        or candidate:HasTag("monster")
        or candidate:HasTag("epic")
        or candidate:HasTag("boss")
        or candidate:HasTag("shadowcreature")
        or theirs.target == owner
        or theirs.lastattacker == owner
        or (combat ~= nil and combat.target == candidate)
end

function M.CollectEnemies(owner, center, radius, exclude, limit)
    if not IsValid(center) or center.Transform == nil or TheSim == nil then return {} end
    local x, y, z = center.Transform:GetWorldPosition()
    local entities = TheSim:FindEntities(x, y, z, radius, { "_combat" }, SECONDARY_CANT_TAGS)
    local result = {}
    for _, candidate in ipairs(entities) do
        if candidate ~= exclude and IsHostile(owner, candidate) then
            table.insert(result, candidate)
            if limit ~= nil and #result >= limit then break end
        end
    end
    return result
end

function M.ApplySlow(target, amount, duration)
    local locomotor = IsValid(target) and target.components ~= nil
        and target.components.locomotor or nil
    if locomotor == nil or locomotor.SetExternalSpeedMultiplier == nil
        or locomotor.RemoveExternalSpeedMultiplier == nil then
        return false
    end
    locomotor:SetExternalSpeedMultiplier(target, SLOW_KEY, 1 - amount)
    if target._ttk_elemental_slow_task ~= nil then
        target._ttk_elemental_slow_task:Cancel()
    end
    target._ttk_elemental_slow_task = target:DoTaskInTime(duration, function(inst)
        inst._ttk_elemental_slow_task = nil
        if inst.components ~= nil and inst.components.locomotor ~= nil then
            inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, SLOW_KEY)
        end
    end)
    return true
end

local function ClearShield(owner)
    local shield = owner ~= nil and owner._ttk_elemental_shield or nil
    if shield ~= nil and shield.task ~= nil then shield.task:Cancel() end
    if owner ~= nil then owner._ttk_elemental_shield = nil end
end

local function InstallShieldHook(owner)
    local combat = owner ~= nil and owner.components ~= nil and owner.components.combat or nil
    if combat == nil or type(combat.GetAttacked) ~= "function" then return false end
    if combat.GetAttacked == combat._ttk_elemental_shield_wrapper then return true end
    local original = combat.GetAttacked
    local wrapper = function(self, attacker, damage, weapon, stimuli, spdamage, ...)
        local shield = owner._ttk_elemental_shield
        local health = owner.components ~= nil and owner.components.health or nil
        if shield == nil or shield.remaining <= 0 or health == nil
            or owner._ttk_elemental_shield_resolving then
            return original(self, attacker, damage, weapon, stimuli, spdamage, ...)
        end
        owner._ttk_elemental_shield_resolving = true
        local previous = health.deltamodifierfn
        local expected_afflicter = attacker == owner and weapon or attacker
        local resolved_combat_delta = false
        local modifier
        modifier = function(inst, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
            if previous ~= nil then
                local changed = previous(inst, amount, overtime, cause,
                    ignore_invincible, afflicter, ignore_absorb)
                if type(changed) == "number" then amount = changed end
            end
            if not resolved_combat_delta and afflicter == expected_afflicter
                and type(amount) == "number" and amount <= 0 then
                resolved_combat_delta = true
                -- Combat emits synchronous callbacks after Health:DoDelta. Stop
                -- intercepting immediately so their unrelated health costs do
                -- not spend this shield.
                if health.deltamodifierfn == modifier then
                    health.deltamodifierfn = previous
                end
                local current = owner._ttk_elemental_shield
                if current ~= nil and amount < 0 then
                    local absorbed = math.min(-amount, current.remaining)
                    current.remaining = current.remaining - absorbed
                    amount = amount + absorbed
                    if current.remaining <= 0 then ClearShield(owner) end
                end
            end
            return amount
        end
        health.deltamodifierfn = modifier
        local results = { pcall(original, self, attacker, damage, weapon, stimuli, spdamage, ...) }
        if health.deltamodifierfn == modifier then health.deltamodifierfn = previous end
        owner._ttk_elemental_shield_resolving = nil
        local ok = table.remove(results, 1)
        if not ok then error(results[1], 0) end
        return unpack(results)
    end
    combat._ttk_elemental_shield_wrapper = wrapper
    combat.GetAttacked = wrapper
    return true
end

function M.ApplyShield(owner, amount, duration)
    if not IsValid(owner) or amount <= 0 or duration <= 0 or not InstallShieldHook(owner) then
        return false
    end
    local now = GetTime()
    local shield = owner._ttk_elemental_shield
    local expires = now + duration
    if shield == nil then
        shield = { remaining = amount, expires = expires }
        owner._ttk_elemental_shield = shield
    else
        shield.remaining = math.max(shield.remaining, amount)
        shield.expires = math.max(shield.expires, expires)
        if shield.task ~= nil then shield.task:Cancel() end
    end
    shield.task = owner:DoTaskInTime(math.max(0, shield.expires - now), function(inst)
        if inst._ttk_elemental_shield == shield then ClearShield(inst) end
    end)
    return true
end

local function TryCooldown(owner, key, seconds, fn)
    if not IsValid(owner) then return false end
    owner._ttk_elemental_cooldowns = owner._ttk_elemental_cooldowns or {}
    local now = GetTime()
    if (owner._ttk_elemental_cooldowns[key] or -math.huge) > now then return false end
    owner._ttk_elemental_cooldowns[key] = now + seconds
    fn()
    return true
end

local function Heal(owner, amount)
    local health = owner.components ~= nil and owner.components.health or nil
    if health ~= nil and not health:IsDead() then
        health:DoDelta(amount, false, "ttk_lucnguyen_moc")
    end
end

local function ApplyDamage(owner, target, damage, weapon, planar)
    local spdamage = planar ~= nil and { planar = planar } or nil
    return Bridge.ApplyAuxiliary(owner, target, damage, weapon, nil, spdamage)
end

local function DamageBasis(weapon, owner, target)
    return Bridge.DamageSnapshot(weapon, owner, target)
end

function M.ApplySwordImpact(owner, target, damage, weapon, element, random)
    random = random or math.random
    local hit = ApplyDamage(owner, target, damage, weapon, element == 1 and 10 or nil)
    if not hit then return false end
    if element == 2 then
        TryCooldown(owner, "moc_heal", 3, function() Heal(owner, 2) end)
    elseif element == 3 and random() < .2 then
        M.ApplySlow(target, .25, 2)
    elseif element == 4 then
        for _, other in ipairs(M.CollectEnemies(owner, target, 2, target)) do
            ApplyDamage(owner, other, damage * .5, weapon)
        end
    elseif element == 5 then
        TryCooldown(owner, "tho_shield", 3, function() M.ApplyShield(owner, 10, 3) end)
    elseif element == 6 then
        local others = M.CollectEnemies(owner, target, 6, target, 1)
        if others[1] ~= nil then ApplyDamage(owner, others[1], damage * .5, weapon) end
    end
    return true
end

function M.IsLandedPrimary(owner, data, weapon)
    return type(data) == "table"
        and data.weapon == weapon
        and data.projectile == nil
        and type(data.damageresolved) == "number"
        and data.damageresolved > 0
        and IsValid(data.target)
        and CombatContext.PacketKind() == nil
        and not Bridge.IsAuxiliaryAttack(owner, data.target)
end

local function LaunchMoc(weapon, owner, target, spawn)
    local sword = (spawn or SpawnPrefab)("ttk_lucnguyen_sword_2")
    if sword == nil or sword.Launch == nil then return end
    sword:Launch({
        owner = owner,
        target = target,
        weapon = weapon,
        damage = DamageBasis(weapon, owner, target) * .4,
        element = 2,
        index = 1,
        count = 1,
        apply_impact = false,
    })
end

function M.HandleHeldHit(weapon, owner, data, element, random, spawn)
    if not M.IsLandedPrimary(owner, data, weapon) then return false end
    random = random or math.random
    local target = data.target
    local damage = DamageBasis(weapon, owner, target)
    if element == 2 then
        weapon._ttk_moc_hits = (weapon._ttk_moc_hits or 0) + 1
        if weapon._ttk_moc_hits >= 4 then
            weapon._ttk_moc_hits = 0
            LaunchMoc(weapon, owner, target, spawn)
        end
    elseif element == 3 and random() < .2 then
        M.ApplySlow(target, .25, 3)
    elseif element == 4 and random() < .15 then
        ApplyDamage(owner, target, damage * .3, weapon)
        for _, other in ipairs(M.CollectEnemies(owner, target, 3, target)) do
            ApplyDamage(owner, other, damage * .3, weapon)
        end
    elseif element == 5 then
        weapon._ttk_tho_hits = (weapon._ttk_tho_hits or 0) + 1
        if weapon._ttk_tho_hits >= 5 then
            weapon._ttk_tho_hits = 0
            M.ApplyShield(owner, 30, 5)
        end
    elseif element == 6 and random() < .2 then
        for _, other in ipairs(M.CollectEnemies(owner, target, 6, target, 2)) do
            ApplyDamage(owner, other, damage * .35, weapon)
        end
    end
    return true
end

function M.Equip(weapon, owner, element)
    M.Unequip(weapon)
    local listener = function(inst, data)
        M.HandleHeldHit(weapon, inst, data, element)
    end
    weapon._ttk_elemental_owner = owner
    weapon._ttk_elemental_listener = listener
    owner:ListenForEvent("onhitother", listener)
end

function M.Unequip(weapon)
    local owner = weapon ~= nil and weapon._ttk_elemental_owner or nil
    local listener = weapon ~= nil and weapon._ttk_elemental_listener or nil
    if owner ~= nil and listener ~= nil and owner.RemoveEventCallback ~= nil then
        owner:RemoveEventCallback("onhitother", listener)
    end
    if weapon ~= nil then
        weapon._ttk_elemental_owner = nil
        weapon._ttk_elemental_listener = nil
    end
end

return M
