local RankDefs = require("guild/hh_rank_defs")

local KING_AURA_PREFABS = {
    hh_igris_shadow = "hh_king_aura_igris_fx",
    hh_beru_shadow = "hh_king_aura_beru_fx",
    hh_fruitfly_shadow = "hh_king_aura_fruitfly_fx",
    hh_macanh_shadow = "hh_king_aura_macanh_fx",
    hh_hacanh_shadow = "hh_king_aura_hacanh_fx",
}
local MANA_REASON = "king"

local function GetKingTuning()
    return TUNING.HH_KING or {}
end

local function IsValidLivingHunter(inst)
    return inst ~= nil
        and inst:IsValid()
        and inst:HasTag("player")
        and not inst:HasTag("playerghost")
        and not inst:HasTag("INLIMBO")
        and inst.components ~= nil
        and inst.components.health ~= nil
        and not inst.components.health:IsDead()
end

local function IsValidSummonedShadow(owner, manager, shadow_data)
    if owner == nil or manager == nil or shadow_data == nil
        or not shadow_data.is_spawned then
        return false
    end

    local shadow = shadow_data.inst
    if shadow == nil or not shadow:IsValid()
        or shadow:HasTag("playerghost")
        or shadow:HasTag("INLIMBO") then
        return false
    end

    if manager.IsOwnedShadowInstance ~= nil
        and not manager:IsOwnedShadowInstance(shadow) then
        return false
    end

    local components = shadow.components
    local follower = components ~= nil and components.follower or nil
    local shadow_unit = components ~= nil and components.hh_shadow_unit or nil
    local health = components ~= nil and components.health or nil
    if follower == nil or follower.GetLeader == nil
        or follower:GetLeader() ~= owner
        or shadow_unit == nil
        or shadow_unit.owner ~= owner
        or health == nil
        or health:IsDead() then
        return false
    end

    return true
end

local HHKing = Class(function(self, inst)
    self.inst = inst
    self.ready_time = 0
    self.cooldown_total = 0
    self.active_until = 0
    self.buff_targets = {}
    self.aura_fx_by_shadow = {}
    self.shadow_aura_callbacks_by_shadow = {}
    self.presentation_end_task = nil
    self._removing = false

    self._on_player_invalid = function()
        self:EndActive()
    end
    inst:ListenForEvent("death", self._on_player_invalid)
    inst:ListenForEvent("makeplayerghost", self._on_player_invalid)
    inst:ListenForEvent("enterlimbo", self._on_player_invalid)
    inst:ListenForEvent("onremove", self._on_player_invalid)

    self._on_player_left = function(_, player)
        if player == inst then
            self:EndActive()
        end
    end
    if TheWorld ~= nil then
        TheWorld:ListenForEvent("ms_playerleft", self._on_player_left)
    end
end)

function HHKing:GetCooldown()
    local tuning = GetKingTuning()
    local leveling_tuning = TUNING.HH_LEVELING or {}
    local base_cooldown = tonumber(tuning.BASE_COOLDOWN) or 150
    local minimum_cooldown = tonumber(tuning.MIN_COOLDOWN) or 3
    local int = 0
    local leveling = self.inst.components ~= nil and self.inst.components.hh_leveling or nil
    if leveling ~= nil then
        int = math.max(0, tonumber(leveling.stat_int) or 0)
    end
    local reduction = tonumber(leveling_tuning.INT_CD_REDUCE) or 0
    return math.max(minimum_cooldown, base_cooldown - int * reduction)
end

function HHKing:GetRemainingCooldown(now)
    return math.max(0, math.ceil(self.ready_time - (now or GetTime())))
end

function HHKing:SyncCooldown(now)
    now = now or GetTime()
    if self.inst.hh_king_cd ~= nil then
        self.inst.hh_king_cd:set(self:GetRemainingCooldown(now))
    end
    if self.inst.hh_king_cd_total ~= nil then
        self.inst.hh_king_cd_total:set(self.ready_time > now and self.cooldown_total or 0)
    end
end

function HHKing:IsActive(now)
    return self.active_until > (now or GetTime())
end

function HHKing:CanCast()
    if TheWorld == nil or not TheWorld.ismastersim
        or not IsValidLivingHunter(self.inst) then
        return false
    end

    local rank = self.inst.components.hh_rank
    if rank == nil or rank:GetRank() < RankDefs.RANK.S then
        return false
    end

    return GetTime() >= self.ready_time
end

function HHKing:CollectSnapshot()
    local components = self.inst.components
    local manager = components ~= nil and components.hh_shadow_manager or nil
    if manager == nil or type(manager.shadows) ~= "table" then
        return {}
    end

    local snapshot = {}
    local seen = {}
    for _, shadow_data in ipairs(manager.shadows) do
        local shadow = shadow_data ~= nil and shadow_data.inst or nil
        if shadow ~= nil and not seen[shadow] and IsValidSummonedShadow(self.inst, manager, shadow_data) then
            seen[shadow] = true
            table.insert(snapshot, shadow)
        end
    end
    return snapshot
end

function HHKing:RemoveShadowAura(shadow)
    if shadow == nil then
        return
    end

    local aura_fx = self.aura_fx_by_shadow[shadow]
    self.aura_fx_by_shadow[shadow] = nil

    local lifecycle_callback = self.shadow_aura_callbacks_by_shadow[shadow]
    self.shadow_aura_callbacks_by_shadow[shadow] = nil
    if lifecycle_callback ~= nil and shadow:IsValid() then
        shadow:RemoveEventCallback("death", lifecycle_callback)
        shadow:RemoveEventCallback("onremove", lifecycle_callback)
        shadow:RemoveEventCallback("enterlimbo", lifecycle_callback)
    end

    if aura_fx ~= nil and aura_fx:IsValid() then
        aura_fx:Remove()
    end
end

function HHKing:SpawnShadowAura(shadow)
    if shadow == nil then
        return false
    end

    local aura_prefab = KING_AURA_PREFABS[shadow.prefab]
    if aura_prefab == nil or not shadow:IsValid() then
        return false
    end

    local existing_fx = self.aura_fx_by_shadow[shadow]
    if existing_fx ~= nil then
        if existing_fx:IsValid() then
            return true
        end
        self:RemoveShadowAura(shadow)
    end

    local aura_fx = SpawnPrefab(aura_prefab)
    if aura_fx == nil or not aura_fx:IsValid() then
        return false
    end

    self.aura_fx_by_shadow[shadow] = aura_fx
    aura_fx.entity:SetParent(shadow.entity)
    aura_fx.Transform:SetPosition(0, 0, 0)

    local lifecycle_callback = function()
        self:RemoveShadowAura(shadow)
    end
    self.shadow_aura_callbacks_by_shadow[shadow] = lifecycle_callback
    shadow:ListenForEvent("death", lifecycle_callback)
    shadow:ListenForEvent("onremove", lifecycle_callback)
    shadow:ListenForEvent("enterlimbo", lifecycle_callback)

    aura_fx:ListenForEvent("onremove", function(removed_fx)
        if self.aura_fx_by_shadow[shadow] == removed_fx then
            self:RemoveShadowAura(shadow)
        end
    end)

    return true
end

function HHKing:ClearBuffSnapshot()
    local previous_targets = self.buff_targets or {}
    self.buff_targets = {}
    for _, shadow in ipairs(previous_targets) do
        if shadow ~= nil and shadow:IsValid()
            and shadow.components ~= nil
            and shadow.components.hh_shadow_unit ~= nil then
            shadow.components.hh_shadow_unit:SetKingBuffActive(false)
        end
    end

    local aura_shadows = {}
    for shadow in pairs(self.aura_fx_by_shadow or {}) do
        table.insert(aura_shadows, shadow)
    end
    for _, shadow in ipairs(aura_shadows) do
        self:RemoveShadowAura(shadow)
    end
end

function HHKing:ApplyBuffSnapshot(snapshot)
    self:ClearBuffSnapshot()
    local components = self.inst.components
    local manager = components ~= nil and components.hh_shadow_manager or nil
    if manager == nil then
        return
    end

    for _, shadow in ipairs(snapshot or {}) do
        local accepted = false
        for _, shadow_data in ipairs(manager.shadows or {}) do
            if shadow_data ~= nil and shadow_data.inst == shadow
                and IsValidSummonedShadow(self.inst, manager, shadow_data) then
                accepted = true
                break
            end
        end
        if accepted and shadow.components ~= nil
            and shadow.components.hh_shadow_unit ~= nil then
            shadow.components.hh_shadow_unit:SetKingBuffActive(true)
            table.insert(self.buff_targets, shadow)
            self:SpawnShadowAura(shadow)
        end
    end
end

function HHKing:ScheduleActiveEnd()
    if self.presentation_end_task ~= nil then
        self.presentation_end_task:Cancel()
        self.presentation_end_task = nil
    end

    local delay = math.max(0, self.active_until - GetTime())
    if self.inst == nil or not self.inst:IsValid() then
        self:EndActive()
        return
    end
    if delay <= 0 then
        self:EndActive()
        return
    end

    self.presentation_end_task = self.inst:DoTaskInTime(delay, function()
        self.presentation_end_task = nil
        self:EndActive()
    end)
end

function HHKing:EndActive()
    if self.presentation_end_task ~= nil then
        self.presentation_end_task:Cancel()
        self.presentation_end_task = nil
    end
    self.active_until = 0
    self:ClearBuffSnapshot()
end

local function SayNoMana(inst)
    local strings = STRINGS ~= nil and STRINGS.HH_KING or nil
    if inst ~= nil and inst.components ~= nil
        and inst.components.talker ~= nil
        and strings ~= nil and strings.NO_MANA ~= nil then
        inst.components.talker:Say(strings.NO_MANA)
    end
end

local function SayNoActiveShadow(inst)
    local strings = STRINGS ~= nil and STRINGS.HH_KING or nil
    if inst ~= nil and inst.components ~= nil
        and inst.components.talker ~= nil
        and strings ~= nil and strings.NO_ACTIVE_SHADOW ~= nil then
        inst.components.talker:Say(strings.NO_ACTIVE_SHADOW)
    end
end

function HHKing:Cast()
    if not self:CanCast() then
        return false
    end

    -- Capture live entities before checking or spending mana. Recasts replace
    -- the old snapshot, so shadows summoned later never inherit this cast.
    local snapshot = self:CollectSnapshot()
    if #snapshot == 0 then
        SayNoActiveShadow(self.inst)
        return false
    end

    local tuning = GetKingTuning()
    local mana = self.inst.components.hh_mana
    local cost = tonumber(tuning.BASE_COST) or 100
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
    self.cooldown_total = self:GetCooldown()
    self.ready_time = now + self.cooldown_total
    self.active_until = now + (tonumber(tuning.ACTIVE_DURATION) or 30)
    self:SyncCooldown(now)
    self:ApplyBuffSnapshot(snapshot)
    self:ScheduleActiveEnd()
    return true
end

function HHKing:OnSave()
    local remaining = math.max(0, self.ready_time - GetTime())
    if remaining > 0 then
        return {
            cooldown_remaining = remaining,
            cooldown_total = self.cooldown_total,
        }
    end
    return nil
end

function HHKing:OnLoad(data)
    self:EndActive()
    self.ready_time = 0
    self.cooldown_total = 0
    if type(data) == "table" then
        local remaining = math.max(0, tonumber(data.cooldown_remaining) or 0)
        self.cooldown_total = remaining > 0
            and math.max(remaining, tonumber(data.cooldown_total) or self:GetCooldown()) or 0
        self.ready_time = GetTime() + remaining
    end
    self:SyncCooldown()
end

function HHKing:OnRemoveFromEntity()
    if self._removing then
        return
    end
    self._removing = true
    if self.inst ~= nil and self._on_player_invalid ~= nil then
        self.inst:RemoveEventCallback("death", self._on_player_invalid)
        self.inst:RemoveEventCallback("makeplayerghost", self._on_player_invalid)
        self.inst:RemoveEventCallback("enterlimbo", self._on_player_invalid)
        self.inst:RemoveEventCallback("onremove", self._on_player_invalid)
    end
    if TheWorld ~= nil and self._on_player_left ~= nil then
        TheWorld:RemoveEventCallback("ms_playerleft", self._on_player_left)
    end
    self:EndActive()
    self._on_player_invalid = nil
    self._on_player_left = nil
end

return HHKing
