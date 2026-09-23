local RankDefs = require("guild/hh_rank_defs")

local MANA_REASON = "ruler"
local RULER_CASTER_PREFAB = "hh_ruler_caster"
local RULER_SPELL_PREFAB = "hh_ruler_shadow_pillar_spell"

local function GetRulerTuning()
    return TUNING.HH_RULER or {}
end

local function SayNoMana(inst)
    local ruler_strings = STRINGS ~= nil and STRINGS.HH_RULER or nil
    if inst ~= nil and inst.components ~= nil
        and inst.components.talker ~= nil
        and ruler_strings ~= nil and ruler_strings.NO_MANA ~= nil then
        inst.components.talker:Say(ruler_strings.NO_MANA)
    end
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

local function IsFiniteNumber(value)
    return type(value) == "number"
        and value == value
        and value > -math.huge
        and value < math.huge
end

local function GetPointValues(pos)
    if pos == nil or pos.Get == nil then
        return nil
    end

    local x, y, z = pos:Get()
    if not IsFiniteNumber(x) or not IsFiniteNumber(y) or not IsFiniteNumber(z) then
        return nil
    end
    return x, y, z
end

local HHRuler = Class(function(self, inst)
    self.inst = inst
    self.ready_time = 0
    self.cooldown_total = 0
    self.target_caster = nil
    self._removing = false

    self._on_rank_changed = function(_, data)
        if data ~= nil
            and data.source == "claim_exam"
            and data.old_rank == RankDefs.RANK.C
            and data.new_rank == RankDefs.RANK.B then
            local ruler_strings = STRINGS ~= nil and STRINGS.HH_RULER or nil
            local template = ruler_strings ~= nil and ruler_strings.ANNOUNCEMENT
                or "Thợ Săn %s đã mở khóa kỹ năng Kẻ Thống Trị"
            TheNet:Announce(string.format(template, self.inst:GetDisplayName()))
        end
    end
    inst:ListenForEvent("hh_rank_changed", self._on_rank_changed)

    self._on_player_invalid = function()
        self:CancelTargeting()
    end
    inst:ListenForEvent("death", self._on_player_invalid)
    inst:ListenForEvent("makeplayerghost", self._on_player_invalid)
    inst:ListenForEvent("enterlimbo", self._on_player_invalid)
    inst:ListenForEvent("onremove", self._on_player_invalid)

    self._on_player_left = function(_, player)
        if player == inst then
            self:CancelTargeting()
        end
    end
    if TheWorld ~= nil then
        TheWorld:ListenForEvent("ms_playerleft", self._on_player_left)
    end
end)

function HHRuler:GetCooldown()
    local ruler_tuning = GetRulerTuning()
    local leveling_tuning = TUNING.HH_LEVELING or {}
    local base_cooldown = tonumber(ruler_tuning.BASE_COOLDOWN) or 80
    local minimum_cooldown = tonumber(ruler_tuning.MIN_COOLDOWN) or 3
    local int = 0
    local leveling = self.inst.components ~= nil and self.inst.components.hh_leveling or nil
    if leveling ~= nil then
        int = math.max(0, tonumber(leveling.stat_int) or 0)
    end
    local reduction = tonumber(leveling_tuning.INT_CD_REDUCE) or 0
    return math.max(minimum_cooldown, base_cooldown - int * reduction)
end

function HHRuler:GetRemainingCooldown(now)
    return math.max(0, math.ceil(self.ready_time - (now or GetTime())))
end

function HHRuler:SyncCooldown(now)
    if self.inst.hh_ruler_cd ~= nil then
        self.inst.hh_ruler_cd:set(self:GetRemainingCooldown(now))
    end
    if self.inst.hh_ruler_cd_total ~= nil then
        self.inst.hh_ruler_cd_total:set(self.ready_time > (now or GetTime()) and self.cooldown_total or 0)
    end
end

function HHRuler:IsTargeting()
    return self.target_caster ~= nil and self.target_caster:IsValid()
end

function HHRuler:CanBeginTargeting()
    if TheWorld == nil or not TheWorld.ismastersim
        or not IsValidLivingHunter(self.inst) then
        return false
    end

    local rank = self.inst.components.hh_rank
    if rank == nil or rank:GetRank() < RankDefs.RANK.B then
        return false
    end

    if GetTime() < self.ready_time then
        return false
    end

    if self.target_caster ~= nil then
        if self.target_caster:IsValid() then
            return false
        end
        self.target_caster = nil
    end

    -- The proxy is deliberately not put in an inventory slot. Do not disturb
    -- an active item that the player is already carrying with the cursor.
    local inventory = self.inst.components.inventory
    if inventory ~= nil and inventory:GetActiveItem() ~= nil then
        return false
    end

    return true
end

function HHRuler:BeginTargeting()
    if not self:CanBeginTargeting() then
        return false
    end

    local tuning = GetRulerTuning()
    local mana = self.inst.components.hh_mana
    local cost = tonumber(tuning.BASE_COST) or 100
    if mana == nil then
        return false
    end
    if not mana:CanSpend(cost, MANA_REASON) then
        SayNoMana(self.inst)
        return false
    end

    local caster = SpawnPrefab(RULER_CASTER_PREFAB)
    if caster == nil or not caster:IsValid() then
        return false
    end

    if caster.components == nil
        or caster.components.inventoryitem == nil
        or caster.components.aoespell == nil
        or caster.components.aoetargeting == nil
        or caster.components.spellbook == nil
        or caster.hh_ruler_owner == nil
        or self.inst.hh_ruler_caster == nil then
        caster:Remove()
        return false
    end

    caster.caster = self.inst
    caster.persists = false
    caster.Transform:SetPosition(self.inst.Transform:GetWorldPosition())

    caster.hh_ruler_owner:set(self.inst)

    -- Pickup/container restrictions are established once in the prefab
    -- constructor. This exists only so the native server CASTAOE path can
    -- verify the owner; the proxy is never inserted into inventory.
    caster.components.inventoryitem:SetOwner(self.inst)

    self.target_caster = caster
    self.inst.hh_ruler_caster:set(caster)

    if TheNet ~= nil and not TheNet:IsDedicated()
        and ThePlayer ~= nil and ThePlayer == self.inst then
        self.inst:DoTaskInTime(0, function(player)
            if player:IsValid()
                and ThePlayer == player
                and player.hh_ruler_caster ~= nil
                and player.hh_ruler_caster:value() == caster then
                player:PushEvent("hh_ruler_targetingready")
            end
        end)
    end

    caster._hh_ruler_onremove = function()
        if self.target_caster == caster then
            self.target_caster = nil
            if self.inst:IsValid() and self.inst.hh_ruler_caster ~= nil then
                self.inst.hh_ruler_caster:set(nil)
            end
        end
    end
    caster:ListenForEvent("onremove", caster._hh_ruler_onremove)

    return true
end

function HHRuler:CancelTargeting(expected_caster)
    if expected_caster ~= nil and self.target_caster ~= expected_caster then
        return false
    end

    local caster = self.target_caster
    self.target_caster = nil

    if self.inst ~= nil and self.inst:IsValid() and self.inst.hh_ruler_caster ~= nil then
        self.inst.hh_ruler_caster:set(nil)
    end

    if caster ~= nil and caster:IsValid() then
        caster.caster = nil
        caster:Remove()
    end
    return caster ~= nil
end

function HHRuler:ValidateCastPosition(pos, caster)
    if caster == nil or caster ~= self.target_caster or not caster:IsValid() then
        return nil
    end
    if caster.caster ~= self.inst
        or caster.components == nil
        or caster.components.inventoryitem == nil
        or caster.components.aoespell == nil
        or caster.components.aoetargeting == nil
        or not caster.components.aoetargeting:IsEnabled()
        or caster.components.spellbook == nil
        or caster.components.spellbook:GetSelectedSpell() ~= 1
        or caster.components.inventoryitem:GetGrandOwner() ~= self.inst then
        return nil
    end
    if TheWorld == nil or not TheWorld.ismastersim or TheWorld.Map == nil then
        return nil
    end
    if not IsValidLivingHunter(self.inst) then
        return nil
    end

    local rank = self.inst.components.hh_rank
    if rank == nil or rank:GetRank() < RankDefs.RANK.B then
        return nil
    end

    local now = GetTime()
    if now < self.ready_time then
        return nil
    end

    local x, y, z = GetPointValues(pos)
    if x == nil then
        return nil
    end

    local tuning = GetRulerTuning()
    local cast_range = tonumber(tuning.CAST_RANGE) or 8
    if self.inst:GetDistanceSqToPoint(x, 0, z) > cast_range * cast_range then
        return nil
    end

    local point = Vector3(x, y, z)
    if not TheWorld.Map:CanCastAtPoint(point, false, true, 0) then
        return nil
    end

    return point
end

function HHRuler:CastAt(pos, caster)
    local point = self:ValidateCastPosition(pos, caster)
    if point == nil then
        self:CancelTargeting(caster)
        return false
    end

    local tuning = GetRulerTuning()
    local mana = self.inst.components.hh_mana
    local cost = tonumber(tuning.BASE_COST) or 100
    if mana == nil then
        self:CancelTargeting(caster)
        return false
    end
    if not mana:CanSpend(cost, MANA_REASON) then
        SayNoMana(self.inst)
        self:CancelTargeting(caster)
        return false
    end

    -- Spawn the vanilla-parity spell controller before committing resources so
    -- a missing registration cannot consume mana and leave no spell behind.
    local spell = SpawnPrefab(RULER_SPELL_PREFAB)
    if spell == nil or not spell:IsValid() then
        self:CancelTargeting(caster)
        return false
    end

    spell.caster = self.inst
    spell.item = caster
    local platform = TheWorld.Map:GetPlatformAtPoint(point.x, point.z)
    if platform ~= nil and platform:IsValid() then
        spell.entity:SetParent(platform.entity)
        spell.Transform:SetPosition(platform.entity:WorldToLocalSpace(point:Get()))
    else
        spell.Transform:SetPosition(point:Get())
    end

    if not mana:Spend(cost, MANA_REASON) then
        if spell:IsValid() then
            spell:Remove()
        end
        self:CancelTargeting(caster)
        return false
    end

    local now = GetTime()
    self.cooldown_total = self:GetCooldown()
    self.ready_time = now + self.cooldown_total
    self:SyncCooldown(now)

    -- Let the CASTAOE action finish using its proxy before removing the proxy.
    self.inst:DoTaskInTime(0, function(inst)
        if inst:IsValid() and inst.components.hh_ruler == self then
            self:CancelTargeting(caster)
        end
    end)

    return true
end

function HHRuler:OnSave()
    local remaining = math.max(0, self.ready_time - GetTime())
    if remaining > 0 then
        return { cooldown_remaining = remaining, cooldown_total = self.cooldown_total }
    end
    return nil
end

function HHRuler:OnLoad(data)
    self:CancelTargeting()
    self.ready_time = 0
    self.cooldown_total = 0
    if type(data) == "table" then
        local remaining = math.max(0, tonumber(data.cooldown_remaining) or 0)
        self.cooldown_total = remaining > 0 and math.max(remaining, tonumber(data.cooldown_total) or self:GetCooldown()) or 0
        self.ready_time = GetTime() + remaining
    end
    self:SyncCooldown()
end

function HHRuler:OnRemoveFromEntity()
    if self._removing then
        return
    end
    self._removing = true

    if self.inst ~= nil then
        if self._on_rank_changed ~= nil then
            self.inst:RemoveEventCallback("hh_rank_changed", self._on_rank_changed)
        end
        if self._on_player_invalid ~= nil then
            self.inst:RemoveEventCallback("death", self._on_player_invalid)
            self.inst:RemoveEventCallback("makeplayerghost", self._on_player_invalid)
            self.inst:RemoveEventCallback("enterlimbo", self._on_player_invalid)
            self.inst:RemoveEventCallback("onremove", self._on_player_invalid)
        end
    end
    if TheWorld ~= nil and self._on_player_left ~= nil then
        TheWorld:RemoveEventCallback("ms_playerleft", self._on_player_left)
    end

    self:CancelTargeting()
    self._on_rank_changed = nil
    self._on_player_invalid = nil
    self._on_player_left = nil
end

return HHRuler
