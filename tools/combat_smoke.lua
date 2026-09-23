-- Disposable-server acceptance. No player save or persistent progression is used.
local Status = require("combat/hh_combat_status")
local Context = require("combat/hh_combat_context")
local entities, steps = {}, {}
local failed, cursor = false, 0
local player, defender, normal, boss, secondary, weapon
local poison_start, poison_health, poison_expiry, freeze_ready

local function Check(value, message)
    if not value then error(message, 2) end
    return value
end
local function Close(actual, expected, message)
    Check(math.abs(actual - expected) < .001,
        message .. ": got " .. tostring(actual) .. ", expected " .. tostring(expected))
end
local function Cleanup()
    for _, ent in ipairs(entities) do
        if ent:IsValid() then ent:Remove() end
    end
end
local function Fail(message)
    if failed then return end
    failed = true
    print("PHAM_NHAN_COMBAT_SMOKE_FAIL", tostring(message))
    Cleanup()
end
local function Spawn(prefab, x, z)
    local ent = Check(SpawnPrefab(prefab), "missing prefab " .. prefab)
    entities[#entities + 1] = ent
    ent.persists = false
    -- An offline audit has no connected client keeping nearby entities awake.
    -- Deerclops otherwise despawns on sleep outside winter before assertions.
    ent.entity:SetCanSleep(false)
    ent.Transform:SetPosition(x, 0, z)
    if ent.StopBrain ~= nil then ent:StopBrain() end
    if ent.components.locomotor ~= nil then ent.components.locomotor:Stop() end
    return ent
end
local function Effects(ent, values)
    local component = Check(ent.components.hh_player or ent.components.hh_monster,
        "missing Phàm Nhân component on " .. ent.prefab)
    for key in pairs(component.hh_effects) do component.hh_effects[key] = 0 end
    for key, value in pairs(values or {}) do
        Check(component.hh_effects[key] ~= nil, "unregistered test effect " .. key)
        component.hh_effects[key] = value
    end
    return component
end
local function Healthy(ent, maximum, current)
    Check(ent:IsValid(), "audit entity removed before health setup: " .. ent.prefab)
    Check(ent.replica.health ~= nil, "audit health replica missing: " .. ent.prefab)
    maximum = maximum or (ent:HasTag("player") and 10000 or 100000)
    ent.components.health:SetMaxHealth(maximum)
    ent.components.health:SetCurrentHealth(current or maximum)
    ent.components.health:SetInvincible(false)
end
local function Armored(ent)
    if ent.components.inventory == nil then ent:AddComponent("inventory") end
    for _, prefab in ipairs({"armorwood", "footballhat"}) do
        local armor = Spawn(prefab, 0, 0)
        armor.components.armor:InitCondition(10000, .8)
        ent.components.inventory:Equip(armor)
    end
end
local function Hit(target, damage, rolls)
    local attacker = player.components.hh_player
    local old_resolve = attacker.ResolvePrimaryHit
    local dodger = target.components.hh_player
    local old_dodge = dodger ~= nil and dodger.TryDodge or nil
    local used, trace, captured = 0, {}, nil
    local function Rng(kind)
        return function(low, high)
            Check(low == 1 and high == 100, "wrong percentage RNG domain")
            used = used + 1
            trace[#trace + 1] = kind
            return Check((rolls or {})[used], "unexpected offensive RNG " .. kind)
        end
    end
    attacker.ResolvePrimaryHit = function(self, other, amount, item)
        local normal_damage, piercing, metadata = old_resolve(self, other, amount, item, Rng("offense"))
        captured = metadata
        return normal_damage, piercing, metadata
    end
    if dodger ~= nil then
        dodger.TryDodge = function(self, other) return old_dodge(self, other, Rng("dodge")) end
    end
    local before = target.components.health.currenthealth
    local ok, result = xpcall(function()
        return target.components.combat:GetAttacked(player, damage, weapon)
    end, debug.traceback)
    attacker.ResolvePrimaryHit = old_resolve
    if dodger ~= nil then dodger.TryDodge = old_dodge end
    Check(ok, result)
    Check(Context.Current(player, target) == nil and Context.PacketKind() == nil, "hit context leaked")
    return before - target.components.health.currenthealth, trace, captured
end
local function Step(delay, fn)
    steps[#steps + 1] = {delay, fn}
end
local function Next()
    if failed then return end
    cursor = cursor + 1
    local row = steps[cursor]
    if row == nil then
        Cleanup()
        print("PHAM_NHAN_COMBAT_SMOKE_PASS")
        return
    end
    TheWorld:DoTaskInTime(row[1], function()
        local ok, message = xpcall(row[2], debug.traceback)
        if ok then Next() else Fail(message) end
    end)
end

Check(TheWorld ~= nil and TheWorld.ismastersim, "master simulation required")
local portal = Check(TheSim:FindFirstEntityWithTag("multiplayer_portal"), "portal missing")
local x, _, z = portal.Transform:GetWorldPosition()
player = Spawn("wilson", x, z)
player.userid = "KU_PHAM_NHAN_COMBAT_AUDIT"
defender = Spawn("wilson", x + 20, z)
defender.userid = "KU_PHAM_NHAN_COMBAT_DEFENDER"
normal = Spawn("hound", x + 10, z)
boss = Spawn("deerclops", x + 30, z)
secondary = Spawn("hound", x + 11, z)
weapon = Spawn("spear", x, z)

Step(1, function()
    for _, ent in ipairs({player, defender, normal, boss, secondary}) do
        Effects(ent)
        Healthy(ent)
        ent.components.combat:SetTarget(nil)
        if ent.StopBrain ~= nil then ent:StopBrain() end
    end
    Check(boss.components.hh_monster:GetMonsterType() == "boss_monster", "boss classification missing")
    Armored(defender)
    Armored(secondary)
    Effects(defender)
    Effects(secondary)

    Effects(player, {trueDamageNum=40, bloodSuck=100, atkAddPoisonChance=100})
    Effects(normal, {replaceDamageChance=100})
    Healthy(player, 1000, 500)
    player.components.hh_player._hh_lifesteal_budget = nil
    local lost = Hit(normal, 1000)
    Close(lost, 0, "monster full block normal plus piercing")
    Check(normal._hh_combat_poison == nil, "blocked piercing applied poison")
    Close(player.components.health.currenthealth, 500, "blocked piercing lifesteal")
    Check(player.components.hh_player._hh_lifesteal_budget == nil,
        "blocked piercing consumed lifesteal budget")
    Effects(player)
    Effects(normal)
    Healthy(player)
    Healthy(normal)
    print("PHAM_NHAN_COMBAT_CHECK", "real hh_monster full block zeros normal and piercing")

    Effects(player, {criticalHitRate=50, criticalHitEffect=150, moreDamage8To500=500})
    Effects(defender, {chanceDodgeAttack=70})
    local trace
    lost, trace = Hit(defender, 100, {70})
    Close(lost, 0, "dodge damage")
    Check(#trace == 1 and trace[1] == "dodge", "dodge consumed offensive RNG")
    print("PHAM_NHAN_COMBAT_CHECK", "dodge precedes offensive RNG")

    Effects(defender)
    Effects(player, {criticalHitRate=100, criticalHitEffect=150, moreDamage8To500=500, trueDamageNum=80})
    local metadata
    lost, trace, metadata = Hit(normal, 100, {1})
    Close(metadata.normal_final, 1750, "critical and burst product")
    Close(lost, 1790, "unarmored additive piercing")
    lost = Hit(defender, 100, {1})
    Close(lost, 390, "armored additive piercing")
    Effects(player)
    Close(Hit(defender, 1000), 200, "two vanilla armor pieces use highest absorption")
    Effects(defender, {absorbDamage=80})
    Close(Hit(defender, 1000), 40, "Pham Nhan pool times vanilla armor")
    Effects(player, {trueDamageNum=40})
    Close(Hit(defender, 1000), 440, "piercing bypasses player pool and armor")
    print("PHAM_NHAN_COMBAT_CHECK", "crit x17.5, additive 40% piercing, 96% normal mitigation")

    Effects(player, {addSplashDamageAOE=80})
    local side_before = secondary.components.health.currenthealth
    Close(Hit(normal, 1000), 1000, "primary splash source")
    Close(side_before - secondary.components.health.currenthealth, 120, "secondary capped splash and armor")
    Check(secondary._hh_combat_poison == nil, "splash applied poison")
    print("PHAM_NHAN_COMBAT_CHECK", "target-centered 60% splash resolves secondary armor")

    Effects(player, {bloodSuck=100})
    Healthy(player, 1000, 1)
    player.components.hh_player._hh_lifesteal_budget = nil
    Hit(normal, 10000)
    Close(player.components.health.currenthealth, 151, "15% lifesteal event cap")
    for index = 1, 6 do Hit(normal, 10000) end
    Close(player.components.health.currenthealth, 901, "90% lifesteal one-second cap")
    print("PHAM_NHAN_COMBAT_CHECK", "lifesteal 15% event and 90% second")

    Effects(player, {targetPercentDamage=3, killUnderThreshold=15})
    Healthy(normal, 100000)
    Healthy(boss, 100000)
    Close(Hit(normal, 100), 3097, "normal 3% current HP wound")
    Close(Hit(boss, 100), 1099, "boss 1% current HP wound")
    boss.components.health:SetCurrentHealth(10000)
    Status.TryExecute(player, boss)
    Close(boss.components.health.currenthealth, 10000, "boss execute exclusion")
    print("PHAM_NHAN_COMBAT_CHECK", "heavy wound 3%/1%, boss execute refused")

    Effects(player, {atkChanceAddFreeze=100})
    Hit(secondary, 1)
    Hit(boss, 1)
    Check(secondary.components.freezable:IsFrozen(), "normal target did not freeze")
    Check(not boss.components.freezable:IsFrozen(), "boss was frozen")
    Close(boss.components.locomotor.externalspeedmultiplier, .8, "boss slow multiplier")
    freeze_ready = boss._hh_freeze_ready_at
    Hit(boss, 1)
    Close(boss._hh_freeze_ready_at, freeze_ready, "freeze ICD retriggered")
    Effects(player, {atkAddPoisonChance=100})
    Healthy(normal, 100000)
    for index = 1, 6 do Hit(normal, 100) end
    Check(normal._hh_combat_poison.stacks == 5, "poison stack cap")
    poison_start = GetTime()
    poison_health = normal.components.health.currenthealth
    poison_expiry = normal._hh_combat_poison.expires_at
end)
Step(2.2, function()
    Check(not secondary.components.freezable:IsFrozen(), "normal freeze exceeded two seconds")
    Close(boss.components.locomotor.externalspeedmultiplier, 1, "boss slow did not expire")
    Close(poison_health - normal.components.health.currenthealth, 100, "five poison stacks tick")
    Effects(player, {atkChanceAddFreeze=100})
    Hit(boss, 1)
    Check(boss._hh_freeze_ready_at == freeze_ready, "ICD changed during lockout")
    Effects(player, {atkAddPoisonChance=100})
    Hit(normal, 100)
    Check(normal._hh_combat_poison.stacks == 5, "refresh added sixth stack")
    Check(normal._hh_combat_poison.expires_at > poison_expiry + 2, "poison duration not refreshed")
    poison_expiry = normal._hh_combat_poison.expires_at
    print("PHAM_NHAN_COMBAT_CHECK", "freeze/slow expires, target ICD, poison refresh")
end)
Step(3.1, function()
    Effects(player, {atkChanceAddFreeze=100})
    Hit(boss, 1)
    Check(boss._hh_freeze_ready_at > freeze_ready + 5, "freeze ICD did not reopen")
    Effects(player)
end)
Step(9.1, function()
    Check(GetTime() > poison_expiry, "expiry observation ran early")
    Check(normal._hh_combat_poison == nil, "poison task survived refreshed expiry")
    Close(boss.components.locomotor.externalspeedmultiplier, 1, "second slow did not clean up")
    print("PHAM_NHAN_COMBAT_CHECK", "five-stack poison expires after refreshed ten-second window")
end)
Next()
