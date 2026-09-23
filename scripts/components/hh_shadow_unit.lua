local ShadowDefs = require("enums/hh_shadow_progression_defs")

local PROGRESSION_MODIFIER_KEY = "hh_shadow_progression"
local LOW_HEALTH_MODIFIER_KEY = "hh_shadow_unyielding"
local ROYAL_GUARD_MODIFIER_KEY = "hh_shadow_royal_guard"
local OATH_MODIFIER_KEY = "hh_shadow_knights_oath"
local CORROSION_MODIFIER_KEY = "hh_beru_corrosion"

local INVALID_XP_TAGS = {
    "player", "playerghost", "companion", "shadowminion", "wall", "structure", "INLIMBO",
}

local HHShadowUnit = Class(function(self, inst)
    self.inst = inst
    self.owner = nil
    self.prefab = nil
    self.profile = nil
    self.base = nil
    self._bound = false
    self._oath_used = false
    self._hh_king_buff_active = false
    self._hh_dungeon_health_multiplier = 1
    self._hh_dungeon_attack_speed_multiplier = 1
    self._hh_dungeon_work_radius = nil
    self._guard_ready_time = 0
    self._defence_xp_ready_time = 0
    self._target_xp_times = {}
end)

local function IsAlive(inst)
    return inst ~= nil and inst:IsValid()
        and inst.components.health ~= nil
        and not inst.components.health:IsDead()
end

function HHShadowUnit:GetProgression()
    return self.owner ~= nil and self.owner:IsValid()
        and self.owner.components.hh_shadow_progression or nil
end

function HHShadowUnit:HasTalent(talent_id)
    local progression = self:GetProgression()
    return progression ~= nil and progression:HasTalent(self.prefab, talent_id)
end

function HHShadowUnit:GetKingMultiplier()
    if not self._hh_king_buff_active then
        return 1
    end
    return math.max(.1, tonumber((TUNING.HH_KING or {}).STAT_MULT) or 2)
end

function HHShadowUnit:SetKingBuffActive(active)
    active = active == true
    if self._hh_king_buff_active == active then
        return
    end
    self._hh_king_buff_active = active
    self:Refresh()
end

local function NormalizeDungeonMultiplier(value)
    return math.max(1, tonumber(value) or 1)
end

function HHShadowUnit:SetDungeonHealthMultiplier(multiplier)
    multiplier = NormalizeDungeonMultiplier(multiplier)
    if self._hh_dungeon_health_multiplier == multiplier then
        return
    end
    self._hh_dungeon_health_multiplier = multiplier
    -- Keep the existing dungeon health effect transition semantics: applying
    -- or removing shadow_health resets the shadow to the composed max health.
    self:Refresh(false)
end

function HHShadowUnit:SetDungeonAttackSpeedMultiplier(multiplier)
    multiplier = NormalizeDungeonMultiplier(multiplier)
    if self._hh_dungeon_attack_speed_multiplier == multiplier then
        return
    end
    self._hh_dungeon_attack_speed_multiplier = multiplier
    self:Refresh(true)
end

function HHShadowUnit:SetDungeonWorkRadius(radius)
    radius = tonumber(radius)
    if radius ~= nil and radius <= 0 then
        radius = nil
    end
    if self._hh_dungeon_work_radius == radius then
        return
    end
    self._hh_dungeon_work_radius = radius
    self:Refresh(true)
end

function HHShadowUnit:CaptureBaseStats()
    if self.base ~= nil then return end
    local health = self.inst.components.health
    local combat = self.inst.components.combat
    local locomotor = self.inst.components.locomotor
    local inventory = self.inst.components.inventory
    self.base = {
        max_health = health ~= nil and health.maxhealth or nil,
        min_health = health ~= nil and health.minhealth or 0,
        damage = combat ~= nil and combat.defaultdamage or nil,
        attack_period = combat ~= nil and combat.min_attack_period or nil,
        run_speed = locomotor ~= nil and locomotor.runspeed or nil,
        walk_speed = locomotor ~= nil and locomotor.walkspeed or nil,
        inventory_slots = inventory ~= nil and inventory.maxslots or nil,
    }
end

function HHShadowUnit:Bind(owner, prefab)
    if self._bound then
        self.owner = owner
        self.prefab = prefab
        self:Refresh()
        return
    end
    self.owner = owner
    self.prefab = prefab
    self._bound = true
    self:CaptureBaseStats()

    self._on_killed = function(_, data) self:OnKilled(data) end
    self._on_hit_other = function(_, data) self:OnHitOther(data) end
    self._on_attacked = function(_, data) self:OnAttacked(data) end
    self._on_health_delta = function(_, data) self:OnHealthDelta(data) end
    self._on_owner_attacked = function(_, data) self:OnOwnerAttacked(data) end

    self.inst:ListenForEvent("killed", self._on_killed)
    self.inst:ListenForEvent("onhitother", self._on_hit_other)
    self.inst:ListenForEvent("attacked", self._on_attacked)
    self.inst:ListenForEvent("healthdelta", self._on_health_delta)
    if owner ~= nil then
        self.inst:ListenForEvent("attacked", self._on_owner_attacked, owner)
    end

    self:InstallBonusDamageHook()
    self:InstallLevelHoverDescription()
    self:Refresh()
end

function HHShadowUnit:InstallLevelHoverDescription()
    if self._level_hover_description_installed then return end
    self._level_hover_description_installed = true

    -- hh_hoverer reads GetHHSpDesc06..99 on the server and renders each result
    -- as one extra tooltip row. Keep this data server-authoritative with the
    -- rest of the disciple progression profile.
    self.inst.GetHHSpDesc90 = function()
        local level = self.profile ~= nil and tonumber(self.profile.level) or 1
        return {
            title = "Cấp độ",
            desc = tostring(math.max(1, math.floor(level))),
        }
    end
end

function HHShadowUnit:InstallBonusDamageHook()
    local combat = self.inst.components.combat
    if combat == nil or self._bonus_hook_installed then return end
    self._bonus_hook_installed = true
    self._old_bonus_damage_fn = combat.bonusdamagefn
    combat.bonusdamagefn = function(attacker, target, damage, weapon)
        local bonus = 0
        if self._old_bonus_damage_fn ~= nil then
            bonus = self._old_bonus_damage_fn(attacker, target, damage, weapon) or 0
        end
        if self.prefab == "hh_beru_shadow" and target ~= nil
            and target.components.health ~= nil then
            local percent = target.components.health:GetPercent()
            if self:HasTalent("predator") and percent < .50 then
                bonus = bonus + damage * .20
            end
            if self:HasTalent("execute") and percent < .20 then
                bonus = bonus + damage * .30
            end
        end
        return bonus
    end
end

function HHShadowUnit:Refresh(preserve_health_percent)
    local progression = self:GetProgression()
    if progression == nil then return end
    local profile = progression:GetProfile(self.prefab)
    if profile == nil then return end
    self.profile = profile
    self:CaptureBaseStats()
    local stats = progression:GetStats(self.prefab)
    local health = self.inst.components.health
    local combat = self.inst.components.combat
    local locomotor = self.inst.components.locomotor
    local king_mult = self:GetKingMultiplier()
    local dungeon_health_mult = self._hh_dungeon_health_multiplier or 1
    local dungeon_attack_speed_mult = self._hh_dungeon_attack_speed_multiplier or 1

    if health ~= nil and self.base.max_health ~= nil then
        local percent = preserve_health_percent ~= false and health:GetPercent() or nil
        local progression_max_health = self.base.max_health * stats.health_mult + (stats.max_health_bonus or 0)
        local composed_max_health = progression_max_health * king_mult * dungeon_health_mult
        health:SetMaxHealth(math.max(1, math.floor(composed_max_health + .5)))
        if percent ~= nil then
            health:SetPercent(percent)
        end
        health.externalabsorbmodifiers:SetModifier(
            self.inst,
            math.min(.80, (stats.absorb or 0) * king_mult),
            PROGRESSION_MODIFIER_KEY
        )
        if self.prefab == "hh_igris_shadow" and self:HasTalent("knights_oath") and not self._oath_used then
            health.minhealth = math.max(self.base.min_health or 0, 1)
        else
            health.minhealth = self.base.min_health or 0
        end
    end

    if combat ~= nil then
        if self.base.damage ~= nil then
            self.inst._hh_expected_damage = math.max(0, self.base.damage * stats.damage_mult * king_mult)
            combat:SetDefaultDamage(self.inst._hh_expected_damage)
        end
        if self.base.attack_period ~= nil then
            local attack_period_floor = dungeon_attack_speed_mult > 1 and .2 or .1
            combat:SetAttackPeriod(math.max(attack_period_floor,
                self.base.attack_period * stats.attack_period_mult
                    / king_mult / dungeon_attack_speed_mult))
        end
        combat.externaldamagemultipliers:SetModifier(
            self.inst,
            stats.talent_damage_mult,
            PROGRESSION_MODIFIER_KEY
        )
    end

    if locomotor ~= nil then
        if self.base.run_speed ~= nil then
            locomotor.runspeed = self.base.run_speed * stats.speed_mult * king_mult
        end
        if self.base.walk_speed ~= nil then
            locomotor.walkspeed = self.base.walk_speed * stats.speed_mult * king_mult
        end
    end

    local base_radius = self.prefab == "hh_fruitfly_shadow"
        and ((TUNING.HH_SHADOW_PROGRESSION or {}).FRUITFLY_BASE_WORK_RADIUS or 20)
        or (TUNING.HH_MACANH_SHADOW ~= nil and TUNING.HH_MACANH_SHADOW.WORK_RADIUS or 25)
    local progression_radius = base_radius + (stats.work_radius_bonus or 0)
    local composed_radius = self._hh_dungeon_work_radius ~= nil
        and self._hh_dungeon_work_radius or progression_radius
    self.inst._hh_work_radius = composed_radius * king_mult
    self.inst._hh_care_speed_mult = (stats.care_speed_mult or 1) * king_mult
    self.inst._hh_pick_speed_mult = (stats.pick_speed_mult or 1) * king_mult

    if self.prefab == "hh_macanh_shadow" then
        if self.inst.components.workmultiplier == nil then
            self.inst:AddComponent("workmultiplier")
        end
        for _, action in ipairs({ ACTIONS.CHOP, ACTIONS.MINE, ACTIONS.DIG }) do
            self.inst.components.workmultiplier:AddMultiplier(action, stats.work_mult * king_mult, self.inst)
        end
        if self.inst.components.inventory ~= nil and self.base.inventory_slots ~= nil then
            self.inst.components.inventory.maxslots = self.base.inventory_slots
        end
        self.inst._hh_double_loot_chance = stats.double_loot_chance or 0
    end

    local base_name = STRINGS.NAMES[string.upper(self.prefab)] or ""
    local num_stars = math.floor(self.profile.level / 5)
    local star_str = ""
    if num_stars > 0 then
        star_str = " " .. string.rep("☆", num_stars)
    end
    self.inst.name = base_name .. star_str

    self:UpdateLowHealthBonuses()
end

function HHShadowUnit:UpdateLowHealthBonuses()
    if self.prefab ~= "hh_igris_shadow" then return end
    local health = self.inst.components.health
    local locomotor = self.inst.components.locomotor
    if health == nil then return end
    local active = self:HasTalent("unyielding") and health:GetPercent() < .30
    if active then
        health.externalabsorbmodifiers:SetModifier(self.inst, .25, LOW_HEALTH_MODIFIER_KEY)
    else
        health.externalabsorbmodifiers:RemoveModifier(self.inst, LOW_HEALTH_MODIFIER_KEY)
    end
    if locomotor ~= nil and self.base ~= nil then
        local stats = self:GetProgression() ~= nil and self:GetProgression():GetStats(self.prefab) or nil
        local speed_mult = stats ~= nil and stats.speed_mult or 1
        local king_mult = self:GetKingMultiplier()
        local low_mult = active and 1.25 or 1
        if self.base.run_speed ~= nil then locomotor.runspeed = self.base.run_speed * speed_mult * king_mult * low_mult end
        if self.base.walk_speed ~= nil then locomotor.walkspeed = self.base.walk_speed * speed_mult * king_mult * low_mult end
    end
end

function HHShadowUnit:IsValidCombatVictim(victim)
    if victim == nil or not victim:IsValid() or victim.components.health == nil then
        return false
    end
    for _, tag in ipairs(INVALID_XP_TAGS) do
        if victim:HasTag(tag) then return false end
    end
    local follower = victim.components.follower
    if follower ~= nil and follower:GetLeader() == self.owner then
        return false
    end
    return true
end

function HHShadowUnit:GetKillExp(victim)
    local max_health = victim.components.health.maxhealth or 1
    local config = TUNING.HH_SHADOW_PROGRESSION or {}
    local amount = math.floor(math.sqrt(math.max(1, max_health)) * (config.COMBAT_XP_HEALTH_SCALE or 2))
    amount = math.max(config.COMBAT_XP_MIN or 5, math.min(config.COMBAT_XP_MAX or 250, amount))
    if victim:HasTag("epic") or victim:HasTag("boss") then
        amount = math.floor(amount * (config.EPIC_XP_MULT or 2))
    end
    return amount
end

function HHShadowUnit:AwardExp(amount, reason)
    local progression = self:GetProgression()
    return progression ~= nil and progression:AwardExp(self.prefab, amount, reason)
end

function HHShadowUnit:OnKilled(data)
    local victim = data ~= nil and data.victim or nil
    if not self:IsValidCombatVictim(victim) then return end
    self:AwardExp(self:GetKillExp(victim), "kill")
    if self.prefab == "hh_beru_shadow" and self:HasTalent("king_regen")
        and (victim:HasTag("epic") or victim:HasTag("boss"))
        and IsAlive(self.inst) then
        self.inst.components.health:DoDelta(self.inst.components.health.maxhealth * .30)
    end
end

function HHShadowUnit:OnHitOther(data)
    local target = data ~= nil and data.target or nil
    if not self:IsValidCombatVictim(target) then return end
    local damage = math.max(0, tonumber(data.damageresolved or data.damage) or 0)

    if self.prefab == "hh_igris_shadow" and self:HasTalent("provoking_arc")
        and not target:HasTag("epic") and target.components.combat ~= nil
        and target.components.combat:CanTarget(self.inst) then
        target.components.combat:SetTarget(self.inst)
    elseif self.prefab == "hh_beru_shadow" then
        if self:HasTalent("lifesteal") and IsAlive(self.inst) and damage > 0 then
            self.inst.components.health:DoDelta(math.min(20, damage * .05))
        end
        if self:HasTalent("corrosion") and target.components.combat ~= nil then
            target.components.combat.externaldamagetakenmultipliers:SetModifier(
                self.inst,
                1.10,
                CORROSION_MODIFIER_KEY
            )
            target._hh_beru_corrosion_tasks = target._hh_beru_corrosion_tasks or {}
            local old_task = target._hh_beru_corrosion_tasks[self.inst]
            if old_task ~= nil then old_task:Cancel() end
            target._hh_beru_corrosion_tasks[self.inst] = target:DoTaskInTime(5, function(victim)
                if victim.components.combat ~= nil then
                    victim.components.combat.externaldamagetakenmultipliers:RemoveModifier(
                        self.inst,
                        CORROSION_MODIFIER_KEY
                    )
                end
                if victim._hh_beru_corrosion_tasks ~= nil then
                    victim._hh_beru_corrosion_tasks[self.inst] = nil
                end
            end)
        end
        if target:HasTag("epic") or target:HasTag("boss") then
            local now = GetTime()
            local ready = self._target_xp_times[target.GUID] or 0
            if now >= ready then
                self._target_xp_times[target.GUID] = now + 5
                self:AwardExp(math.max(1, math.min(15, math.floor(damage * .03))), "boss_damage")
            end
        end
    elseif self.prefab == "hh_hacanh_shadow" and target.components.combat ~= nil
        and target.components.combat.target == self.owner then
        local now = GetTime()
        local ready = self._target_xp_times[target.GUID] or 0
        if now >= ready then
            self._target_xp_times[target.GUID] = now + 5
            self:AwardExp(3, "protect_owner")
        end
    end
end

function HHShadowUnit:OnAttacked(data)
    if self.prefab ~= "hh_igris_shadow" or GetTime() < self._defence_xp_ready_time then
        return
    end
    local attacker = data ~= nil and data.attacker or nil
    if attacker == nil or not attacker:IsValid() or attacker:HasTag("player") then return end
    local damage = math.max(0, tonumber(data.damage) or 0)
    if damage > 0 then
        self._defence_xp_ready_time = GetTime() + 5
        self:AwardExp(math.max(1, math.min(10, math.floor(damage / 20))), "guard")
    end
end

function HHShadowUnit:OnOwnerAttacked(data)
    if not IsAlive(self.inst) then return end
    local attacker = data ~= nil and data.attacker or nil
    local combat = self.inst.components.combat
    if attacker == nil or not attacker:IsValid() or combat == nil or not combat:CanTarget(attacker) then
        return
    end
    if self.prefab == "hh_igris_shadow" and self:HasTalent("royal_guard") then
        combat:SetTarget(attacker)
        if GetTime() >= self._guard_ready_time and self.inst.components.health ~= nil then
            self._guard_ready_time = GetTime() + 15
            self.inst.components.health.externalabsorbmodifiers:SetModifier(
                self.inst,
                .50,
                ROYAL_GUARD_MODIFIER_KEY
            )
            self.inst:DoTaskInTime(15, function(inst)
                if inst.components.health ~= nil then
                    inst.components.health.externalabsorbmodifiers:RemoveModifier(
                        inst,
                        ROYAL_GUARD_MODIFIER_KEY
                    )
                end
            end)
        end
    elseif self.prefab == "hh_hacanh_shadow" and self:HasTalent("protector") then
        combat:SetTarget(attacker)
    end
end

function HHShadowUnit:OnHealthDelta()
    if self.prefab ~= "hh_igris_shadow" or self.inst.components.health == nil then return end
    local health = self.inst.components.health
    if self:HasTalent("knights_oath") and not self._oath_used
        and health.currenthealth <= 1 and health.minhealth >= 1 then
        self._oath_used = true
        health.minhealth = self.base ~= nil and self.base.min_health or 0
        health:DoDelta(math.max(1, health.maxhealth * .80), nil, "hh_knights_oath", true)
        health.externalabsorbmodifiers:SetModifier(self.inst, 1, OATH_MODIFIER_KEY)
        self.inst:DoTaskInTime(2, function(inst)
            if inst.components.health ~= nil then
                inst.components.health.externalabsorbmodifiers:RemoveModifier(
                    inst,
                    OATH_MODIFIER_KEY
                )
            end
        end)
    end
    self:UpdateLowHealthBonuses()
end

function HHShadowUnit:OnRemoveFromEntity()
    if self.owner ~= nil and self._on_owner_attacked ~= nil then
        self.inst:RemoveEventCallback("attacked", self._on_owner_attacked, self.owner)
    end
end

function HHShadowUnit:GetDebugString()
    local profile = self.profile
    return string.format("%s L%d %dXP",
        tostring(self.prefab),
        profile ~= nil and profile.level or 0,
        profile ~= nil and profile.exp or 0)
end

return HHShadowUnit
