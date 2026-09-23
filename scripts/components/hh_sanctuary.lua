local RankDefs = require("guild/hh_rank_defs")

local HEAL_MUST_TAGS = { "player" }
local SLEEP_NOPVP_MUST_TAGS = { "sleeper" }
local SLEEP_PVP_ONEOF_TAGS = { "sleeper", "player" }
local TARGET_CANT_TAGS = { "playerghost", "FX", "DECOR", "INLIMBO" }
local MANA_REASON = "sanctuary"

local function GetSanctuaryTuning()
    return TUNING.HH_SANCTUARY or {}
end

local function SayNoMana(inst)
    local sanctuary_strings = STRINGS ~= nil and STRINGS.HH_SANCTUARY or nil
    if inst ~= nil and inst.components ~= nil
        and inst.components.talker ~= nil
        and sanctuary_strings ~= nil and sanctuary_strings.NO_MANA ~= nil then
        inst.components.talker:Say(sanctuary_strings.NO_MANA)
    end
end

local function IsValidLivingPlayerTarget(target)
    return target ~= nil
        and target:IsValid()
        and target:HasTag("player")
        and not target:HasTag("playerghost")
        and not target:HasTag("FX")
        and not target:HasTag("DECOR")
        and not target:HasTag("INLIMBO")
        and target.components ~= nil
        and target.components.health ~= nil
        and not target.components.health:IsDead()
end

local function IsPlayerOwnedSoloShadow(target, owner)
    if target == nil or owner == nil then
        return false
    end

    local target_components = target.components
    local shadow_unit = target_components ~= nil and target_components.hh_shadow_unit or nil
    if shadow_unit ~= nil and shadow_unit.owner == owner then
        return true
    end

    -- Fallback to the manager's live ownership table for a shadow that has
    -- not been rebound by progression yet. This deliberately avoids a
    -- hardcoded prefab list and never treats ordinary vanilla companions as
    -- Solo Leveling shadows.
    local owner_components = owner.components
    local manager = owner_components ~= nil and owner_components.hh_shadow_manager or nil
    if manager ~= nil and manager.shadows ~= nil then
        for _, shadow_data in ipairs(manager.shadows) do
            if shadow_data ~= nil and shadow_data.inst == target then
                return true
            end
        end
    end

    return false
end

local function IsValidSleepTarget(target, caster)
    if target == nil
        or not target:IsValid()
        or target == caster
        or target:HasTag("playerghost")
        or target:HasTag("FX")
        or target:HasTag("DECOR")
        or target:HasTag("INLIMBO")
        or IsPlayerOwnedSoloShadow(target, caster) then
        return false
    end

    local components = target.components
    if components ~= nil then
        if components.freezable ~= nil and components.freezable:IsFrozen() then
            return false
        end
        if components.pinnable ~= nil and components.pinnable:IsStuck() then
            return false
        end
        if components.fossilizable ~= nil and components.fossilizable:IsFossilized() then
            return false
        end
    end

    return true
end

local function FindTargets(caster)
    local tuning = GetSanctuaryTuning()
    local radius = tonumber(tuning.RADIUS) or 15
    local x, y, z = caster.Transform:GetWorldPosition()

    local heal_targets = {}
    local heal_candidates = TheSim:FindEntities(
        x, y, z, radius, HEAL_MUST_TAGS, TARGET_CANT_TAGS)
    for _, target in ipairs(heal_candidates) do
        if IsValidLivingPlayerTarget(target) then
            table.insert(heal_targets, target)
        end
    end

    local pvp_enabled = TheNet:GetPVPEnabled()
    local sleep_must_tags = pvp_enabled and nil or SLEEP_NOPVP_MUST_TAGS
    local sleep_oneof_tags = pvp_enabled and SLEEP_PVP_ONEOF_TAGS or nil
    local sleep_candidates = TheSim:FindEntities(
        x, y, z, radius, sleep_must_tags, TARGET_CANT_TAGS, sleep_oneof_tags)

    local sleep_targets = {}
    for _, target in ipairs(sleep_candidates) do
        if IsValidSleepTarget(target, caster) then
            local ismount, mount
            if target.components ~= nil and target.components.rider ~= nil then
                ismount = target.components.rider:IsRiding()
                mount = target.components.rider:GetMount()
            end
            table.insert(sleep_targets, {
                inst = target,
                ismount = ismount,
                mount = mount,
            })
        end
    end

    return heal_targets, sleep_targets
end

local function SpawnAttachedFx(prefab, target)
    if target == nil or not target:IsValid() then
        return
    end
    local fx = SpawnPrefab(prefab)
    if fx ~= nil then
        fx.entity:SetParent(target.entity)
    end
end

local function SpawnSleepFx(target_data)
    local target = target_data ~= nil and target_data.inst or nil
    if target == nil or not target:IsValid() then
        return
    end

    local prefab = target_data.ismount and "fx_book_sleep_mount" or "fx_book_sleep"
    local fx = SpawnPrefab(prefab)
    if fx ~= nil then
        fx.Transform:SetPosition(target.Transform:GetWorldPosition())
        fx.Transform:SetRotation(target.Transform:GetRotation())
    end
end

local HHSanctuary = Class(function(self, inst)
    self.inst = inst
    self.ready_time = 0
    self.cooldown_total = 0

    self._on_rank_changed = function(_, data)
        if data ~= nil
            and data.source == "claim_exam"
            and data.old_rank == RankDefs.RANK.E
            and data.new_rank == RankDefs.RANK.D then
            local sanctuary_strings = STRINGS ~= nil and STRINGS.HH_SANCTUARY or nil
            local template = sanctuary_strings ~= nil and sanctuary_strings.ANNOUNCEMENT
                or "Thợ Săn %s đã mở khóa kỹ năng Thánh Vực Hồi Phục"
            TheNet:Announce(string.format(template, self.inst:GetDisplayName()))
        end
    end
    inst:ListenForEvent("hh_rank_changed", self._on_rank_changed)
end)

function HHSanctuary:GetCooldown()
    local sanctuary_tuning = GetSanctuaryTuning()
    local leveling_tuning = TUNING.HH_LEVELING or {}
    local base_cooldown = tonumber(sanctuary_tuning.BASE_COOLDOWN) or 30
    local minimum_cooldown = tonumber(sanctuary_tuning.MIN_COOLDOWN) or 3
    local int = 0
    local leveling = self.inst.components ~= nil and self.inst.components.hh_leveling or nil
    if leveling ~= nil then
        int = math.max(0, tonumber(leveling.stat_int) or 0)
    end
    local reduction = tonumber(leveling_tuning.INT_CD_REDUCE) or 0
    return math.max(minimum_cooldown, base_cooldown - int * reduction)
end

function HHSanctuary:GetRemainingCooldown(now)
    return math.max(0, math.ceil(self.ready_time - (now or GetTime())))
end

function HHSanctuary:SyncCooldown(now)
    if self.inst.hh_sanctuary_cd ~= nil then
        self.inst.hh_sanctuary_cd:set(self:GetRemainingCooldown(now))
    end
    if self.inst.hh_sanctuary_cd_total ~= nil then
        self.inst.hh_sanctuary_cd_total:set(self.ready_time > (now or GetTime()) and self.cooldown_total or 0)
    end
end

function HHSanctuary:CanCast()
    if TheWorld == nil or not TheWorld.ismastersim
        or not IsValidLivingPlayerTarget(self.inst) then
        return false
    end

    local rank = self.inst.components.hh_rank
    if rank == nil or rank:GetRank() < RankDefs.RANK.D then
        return false
    end

    return GetTime() >= self.ready_time
end

function HHSanctuary:Cast()
    if not self:CanCast() then
        return false
    end

    local tuning = GetSanctuaryTuning()
    local mana = self.inst.components.hh_mana
    local cost = tonumber(tuning.BASE_COST) or 30
    if mana == nil then
        return false
    end
    if not mana:CanSpend(cost, MANA_REASON) then
        SayNoMana(self.inst)
        return false
    end

    local heal_targets, sleep_targets = FindTargets(self.inst)
    if #heal_targets == 0 and #sleep_targets == 0 then
        return false
    end

    if not mana:Spend(cost, MANA_REASON) then
        return false
    end

    -- Mana and cooldown are committed only after rank, cooldown, target and
    -- effective mana-cost validation have all passed.
    self.cooldown_total = self:GetCooldown()
    self.ready_time = GetTime() + self.cooldown_total
    self:SyncCooldown()

    local heal_base = tonumber(tuning.HEAL_BASE) or 30
    local heal_ratio = tonumber(tuning.HEAL_MAX_HEALTH_RATIO) or 0.20
    for _, target in ipairs(heal_targets) do
        if IsValidLivingPlayerTarget(target) then
            local health = target.components.health
            local max_health = tonumber(health.maxhealth) or 0
            if max_health > 0 then
                -- Health:DoDelta performs the vanilla upper clamp.
                health:DoDelta(heal_base + max_health * heal_ratio, false, MANA_REASON)
            end
        end
    end

    for _, target_data in ipairs(sleep_targets) do
        local target = target_data.inst
        if IsValidSleepTarget(target, self.inst) then
            local mount = target_data.mount
            if mount ~= nil and mount:IsValid() then
                mount:PushEvent("ridersleep", { sleepiness = 10, sleeptime = 20 })
            end

            local components = target.components
            if components ~= nil and components.sleeper ~= nil then
                components.sleeper:AddSleepiness(10, 20)
            elseif components ~= nil and components.grogginess ~= nil then
                components.grogginess:AddGrogginess(10, 20)
            else
                target:PushEvent("knockedout")
            end
        end
    end

    -- Keep presentation after the gameplay effects: heal, sleep/grogginess,
    -- then the vanilla FX and spell audio.
    for _, target in ipairs(heal_targets) do
        SpawnAttachedFx("ghostlyelixir_retaliation_fx", target)
    end
    for _, target_data in ipairs(sleep_targets) do
        SpawnSleepFx(target_data)
    end
    if self.inst.SoundEmitter ~= nil then
        self.inst.SoundEmitter:PlaySound("wickerbottom_rework/book_spells/sleep")
    end

    return true
end

function HHSanctuary:OnSave()
    local remaining = math.max(0, self.ready_time - GetTime())
    if remaining > 0 then
        return { cooldown_remaining = remaining, cooldown_total = self.cooldown_total }
    end
    return nil
end

function HHSanctuary:OnLoad(data)
    if type(data) ~= "table" then
        return
    end
    local remaining = math.max(0, tonumber(data.cooldown_remaining) or 0)
    self.cooldown_total = remaining > 0 and math.max(remaining, tonumber(data.cooldown_total) or self:GetCooldown()) or 0
    self.ready_time = GetTime() + remaining
    self:SyncCooldown()
end

return HHSanctuary
