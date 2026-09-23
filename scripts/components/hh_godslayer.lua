local RankDefs = require("guild/hh_rank_defs")

local MANA_REASON = "godslayer"
local GODSLAYER_AURA_PREFAB = "hh_godslayer_aura_fx"
local GODSLAYER_AURA_X_OFFSET = -0.1
local GODSLAYER_SOUND = "dontstarve/creatures/together/deer/fx/fire_circle_LP"

local function GetGodslayerTuning()
    return TUNING.HH_GODSLAYER or {}
end

local function SayNoMana(inst)
    local godslayer_strings = STRINGS ~= nil and STRINGS.HH_GODSLAYER or nil
    if inst ~= nil and inst.components ~= nil
        and inst.components.talker ~= nil
        and godslayer_strings ~= nil and godslayer_strings.NO_MANA ~= nil then
        inst.components.talker:Say(godslayer_strings.NO_MANA)
    end
end

local function IsValidLivingHunter(target)
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

local function IsValidCombatTarget(target, attacker)
    return target ~= nil
        and target:IsValid()
        and not target:HasTag("playerghost")
        and not target:HasTag("FX")
        and not target:HasTag("DECOR")
        and not target:HasTag("INLIMBO")
        and target.components ~= nil
        and target.components.combat ~= nil
        and target.components.health ~= nil
        and not target.components.health:IsDead()
        and target.replica ~= nil
        and target.replica.combat ~= nil
        and target.components.combat:CanBeAttacked(attacker)
end

local HHGodslayer = Class(function(self, inst)
    self.inst = inst
    self.ready_time = 0
    self.cooldown_total = 0
    self.active_until = 0
    self.aura_fx = nil
    self.presentation_end_task = nil
    self.presentation_restore_task = nil
    self.sound_active = false
    self.presentation_ending = false

    self._on_rank_changed = function(_, data)
        if data ~= nil
            and data.source == "claim_exam"
            and data.old_rank == RankDefs.RANK.D
            and data.new_rank == RankDefs.RANK.C then
            local godslayer_strings = STRINGS ~= nil and STRINGS.HH_GODSLAYER or nil
            local template = godslayer_strings ~= nil and godslayer_strings.ANNOUNCEMENT
                or "Thợ Săn %s đã mở khóa kỹ năng Diệt Thần"
            TheNet:Announce(string.format(template, self.inst:GetDisplayName()))
        end
    end
    inst:ListenForEvent("hh_rank_changed", self._on_rank_changed)

    self._on_inst_remove = function()
        self:RemovePresentationImmediately()
    end
    inst:ListenForEvent("onremove", self._on_inst_remove)
end)

function HHGodslayer:GetCooldown()
    local godslayer_tuning = GetGodslayerTuning()
    local leveling_tuning = TUNING.HH_LEVELING or {}
    local base_cooldown = tonumber(godslayer_tuning.BASE_COOLDOWN) or 0
    local minimum_cooldown = tonumber(godslayer_tuning.MIN_COOLDOWN) or 0
    local int = 0
    local leveling = self.inst.components ~= nil and self.inst.components.hh_leveling or nil
    if leveling ~= nil then
        int = math.max(0, tonumber(leveling.stat_int) or 0)
    end
    local reduction = tonumber(leveling_tuning.INT_CD_REDUCE) or 0
    return math.max(minimum_cooldown, base_cooldown - int * reduction)
end

function HHGodslayer:GetRemainingCooldown(now)
    return math.max(0, math.ceil(self.ready_time - (now or GetTime())))
end

function HHGodslayer:SyncCooldown(now)
    if self.inst.hh_godslayer_cd ~= nil then
        self.inst.hh_godslayer_cd:set(self:GetRemainingCooldown(now))
    end
    if self.inst.hh_godslayer_cd_total ~= nil then
        self.inst.hh_godslayer_cd_total:set(self.ready_time > (now or GetTime()) and self.cooldown_total or 0)
    end
end

function HHGodslayer:IsActive(now)
    return self.active_until > (now or GetTime())
end

function HHGodslayer:StartLoopSound()
    if TheWorld == nil or not TheWorld.ismastersim
        or self.sound_active
        or self.inst == nil
        or self.inst.SoundEmitter == nil then
        return
    end

    self.inst.SoundEmitter:PlaySound(GODSLAYER_SOUND, "hh_godslayer_loop")
    self.sound_active = true
end

function HHGodslayer:StopLoopSound()
    if self.sound_active
        and self.inst ~= nil
        and self.inst.SoundEmitter ~= nil then
        self.inst.SoundEmitter:KillSound("hh_godslayer_loop")
    end
    self.sound_active = false
end

function HHGodslayer:SchedulePresentationEnd(remaining)
    if self.presentation_end_task ~= nil then
        self.presentation_end_task:Cancel()
        self.presentation_end_task = nil
    end

    local delay = math.max(0, tonumber(remaining) or 0)
    if self.inst == nil or not self.inst:IsValid() then
        self:RemovePresentationImmediately()
        return
    end
    if delay <= 0 then
        self:StopPresentation(true)
        return
    end

    self.presentation_end_task = self.inst:DoTaskInTime(delay, function(inst)
        self.presentation_end_task = nil
        if inst:IsValid() then
            self:StopPresentation(true)
        else
            self:RemovePresentationImmediately()
        end
    end)
end

function HHGodslayer:StartPresentation(is_restore)
    if TheWorld == nil or not TheWorld.ismastersim
        or self.inst == nil
        or not self.inst:IsValid()
        or not self:IsActive() then
        return false
    end

    if self.presentation_restore_task ~= nil then
        self.presentation_restore_task:Cancel()
        self.presentation_restore_task = nil
    end

    local fx = self.aura_fx
    if fx ~= nil and not fx:IsValid() then
        self.aura_fx = nil
        fx = nil
    elseif fx ~= nil and self.presentation_ending then
        self.aura_fx = nil
        fx:Remove()
        fx = nil
    end

    self.presentation_ending = false
    if fx == nil then
        fx = SpawnPrefab(GODSLAYER_AURA_PREFAB)
        if fx ~= nil and fx:IsValid() then
            self.aura_fx = fx
            fx.entity:SetParent(self.inst.entity)
            fx.Transform:SetPosition(GODSLAYER_AURA_X_OFFSET, 0, 0)
            fx:ListenForEvent("onremove", function(removed_fx)
                if self.aura_fx == removed_fx then
                    self.aura_fx = nil
                end
            end)
            if is_restore then
                fx:StartRestore()
            else
                fx:StartFresh()
            end
        else
            fx = nil
        end
    end

    self:StartLoopSound()
    self:SchedulePresentationEnd(self.active_until - GetTime())
    return fx ~= nil
end

function HHGodslayer:StopPresentation(play_post)
    if self.presentation_ending then
        return
    end
    self.presentation_ending = true

    if self.presentation_end_task ~= nil then
        self.presentation_end_task:Cancel()
        self.presentation_end_task = nil
    end
    self:StopLoopSound()

    local fx = self.aura_fx
    if fx == nil or not fx:IsValid() then
        self.aura_fx = nil
        return
    end

    if play_post and fx.PlayPost ~= nil then
        fx:PlayPost()
    else
        self.aura_fx = nil
        fx:Remove()
    end
end

function HHGodslayer:RemovePresentationImmediately()
    if self.presentation_restore_task ~= nil then
        self.presentation_restore_task:Cancel()
        self.presentation_restore_task = nil
    end
    if self.presentation_end_task ~= nil then
        self.presentation_end_task:Cancel()
        self.presentation_end_task = nil
    end

    self.presentation_ending = true
    self:StopLoopSound()

    local fx = self.aura_fx
    self.aura_fx = nil
    if fx ~= nil and fx:IsValid() then
        fx:Remove()
    end
end

function HHGodslayer:CanCast()
    if TheWorld == nil or not TheWorld.ismastersim
        or not IsValidLivingHunter(self.inst) then
        return false
    end

    local rank = self.inst.components.hh_rank
    if rank == nil or rank:GetRank() < RankDefs.RANK.C then
        return false
    end

    return GetTime() >= self.ready_time
end

function HHGodslayer:Cast()
    if not self:CanCast() then
        return false
    end

    local tuning = GetGodslayerTuning()
    local mana = self.inst.components.hh_mana
    local cost = tonumber(tuning.BASE_COST) or 0
    if mana == nil then
        return false
    end
    if not mana:CanSpend(cost, MANA_REASON) then
        SayNoMana(self.inst)
        return false
    end
    if not mana:Spend(cost, MANA_REASON) then
        return false
    end

    local now = GetTime()
    self.active_until = now + (tonumber(tuning.ACTIVE_DURATION) or 0)
    self.cooldown_total = self:GetCooldown()
    self.ready_time = now + self.cooldown_total
    self:SyncCooldown(now)
    self:StartPresentation(false)
    return true
end

function HHGodslayer:GetBonusDamage(target)
    if TheWorld == nil or not TheWorld.ismastersim
        or not self:IsActive()
        or not IsValidCombatTarget(target, self.inst) then
        return 0
    end

    local current_health = tonumber(target.components.health.currenthealth) or 0
    local ratio = tonumber(GetGodslayerTuning().CURRENT_HEALTH_DAMAGE_RATIO) or 0
    if current_health <= 0 or ratio <= 0 then
        return 0
    end

    -- Reuse vanilla combat validation so PvP and target restrictions remain
    -- unchanged; this does not create a new friendly-fire rule.
    return current_health * ratio
end

function HHGodslayer:OnSave()
    local now = GetTime()
    local cooldown_remaining = math.max(0, self.ready_time - now)
    local active_remaining = math.max(0, self.active_until - now)
    if cooldown_remaining > 0 or active_remaining > 0 then
        return {
            cooldown_remaining = cooldown_remaining,
            cooldown_total = self.cooldown_total,
            active_remaining = active_remaining,
        }
    end
    return nil
end

function HHGodslayer:OnLoad(data)
    self:RemovePresentationImmediately()

    self.ready_time = 0
    self.cooldown_total = 0
    self.active_until = 0
    if type(data) ~= "table" then
        self:SyncCooldown()
        return
    end

    local now = GetTime()
    local cooldown_remaining = math.max(0, tonumber(data.cooldown_remaining) or 0)
    local active_remaining = math.max(0, tonumber(data.active_remaining) or 0)
    self.ready_time = now + cooldown_remaining
    self.cooldown_total = cooldown_remaining > 0 and math.max(cooldown_remaining, tonumber(data.cooldown_total) or self:GetCooldown()) or 0
    self.active_until = now + active_remaining
    self:SyncCooldown(now)

    if active_remaining > 0 and self.inst ~= nil and self.inst:IsValid() then
        self.presentation_restore_task = self.inst:DoTaskInTime(0, function(inst)
            self.presentation_restore_task = nil
            if inst:IsValid() and self:IsActive() then
                self:StartPresentation(true)
            end
        end)
    end
end

function HHGodslayer:OnRemoveFromEntity()
    if self.inst ~= nil then
        if self._on_rank_changed ~= nil then
            self.inst:RemoveEventCallback("hh_rank_changed", self._on_rank_changed)
        end
        if self._on_inst_remove ~= nil then
            self.inst:RemoveEventCallback("onremove", self._on_inst_remove)
        end
    end
    self._on_rank_changed = nil
    self._on_inst_remove = nil
    self:RemovePresentationImmediately()
end

return HHGodslayer
