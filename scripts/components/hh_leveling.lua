local HHUtils = require("utils/hh_utils")

local function GetWorldSeconds()
    if not TheWorld or not TheWorld.state then
        return 0
    end
    return math.floor(((TheWorld.state.cycles or 0) + (TheWorld.state.time or 0)) * TUNING.TOTAL_DAY_TIME)
end

local function GetFiniteNumber(value, fallback)
    value = tonumber(value)
    if value == nil or value ~= value or value == math.huge or value == -math.huge then
        return fallback
    end
    return value
end

local function GetNonNegativeInteger(value, fallback)
    return math.max(0, math.floor(GetFiniteNumber(value, fallback) or 0))
end

local function GetLoadedStat(value, cap)
    return math.min(GetNonNegativeInteger(value, 0), cap or math.huge)
end

local function SyncToClient(self)
    if self.inst.hh_lv_level then
        self.inst.hh_lv_level:set(self.level)
        self.inst.hh_lv_exp:set(self.exp)
        self.inst.hh_lv_exp_goal:set(self:GetExpGoal(self.level))
        self.inst.hh_lv_ap:set(self.ap)
        self.inst.hh_lv_str:set(self.stat_str)
        self.inst.hh_lv_agi:set(self.stat_agi)
        self.inst.hh_lv_vit:set(self.stat_vit)
        self.inst.hh_lv_sen:set(self.stat_sen)
        self.inst.hh_lv_int:set(self.stat_int)
        if self.inst.hh_exp_seal_deadline then
            self.inst.hh_exp_seal_deadline:set(math.ceil(self.exp_seal_deadline or 0))
        end
    end
end

local HHLeveling = Class(function(self, inst)
    self.inst = inst
    self.level = 1
    self.exp = 0
    self.ap = 0

    self.stat_str = 0
    self.stat_agi = 0
    self.stat_vit = 0
    self.stat_sen = 0
    self.stat_int = 0

    self.exp_seal_deadline = 0
    self.exp_seal_task = nil
    self.last_exp_block_notice = -math.huge
    self.restore_task = nil
    self.restore_ticks = 0
    self.restore_per_tick = nil
    
    -- Sync on init
    self.inst:DoTaskInTime(0, function() SyncToClient(self) end)
end)

function HHLeveling:GetExpGoal(level)
    level = math.max(1, tonumber(level) or 1)
    local n = level - 1
    return math.floor(100 + 25 * n + 5 * n * n)
end

function HHLeveling:GetExpSealRemaining()
    return math.max(0, (self.exp_seal_deadline or 0) - GetWorldSeconds())
end

function HHLeveling:IsExpSealed()
    if self:GetExpSealRemaining() > 0 then
        return true
    end

    if (self.exp_seal_deadline or 0) > 0 then
        self.exp_seal_deadline = 0
        if self.exp_seal_task then
            self.exp_seal_task:Cancel()
            self.exp_seal_task = nil
        end
        SyncToClient(self)
        self.inst:PushEvent('hh_exp_seal_expired')
    end
    return false
end

function HHLeveling:ScheduleExpSealExpiry()
    if self.exp_seal_task then
        self.exp_seal_task:Cancel()
        self.exp_seal_task = nil
    end

    local remaining = self:GetExpSealRemaining()
    if remaining <= 0 then
        self:IsExpSealed()
        return
    end

    self.exp_seal_task = self.inst:DoTaskInTime(remaining, function()
        self.exp_seal_task = nil
        self:IsExpSealed()
    end)
end

function HHLeveling:ApplyExpSeal(duration)
    duration = tonumber(duration) or 0
    if duration <= 0 then
        return self:GetExpSealRemaining()
    end

    self.exp_seal_deadline = math.max(self.exp_seal_deadline or 0, GetWorldSeconds() + duration)
    self:ScheduleExpSealExpiry()
    SyncToClient(self)
    self.inst:PushEvent('hh_exp_seal_applied', { deadline = self.exp_seal_deadline })
    return self:GetExpSealRemaining()
end

function HHLeveling:NotifyExpBlocked()
    local now = GetWorldSeconds()
    local cooldown = TUNING.HH_DAILY_QUEST.EXP_BLOCK_NOTICE_COOLDOWN or 3
    if now - self.last_exp_block_notice < cooldown then
        return
    end
    self.last_exp_block_notice = now

    if self.inst.components.talker then
        local strings = STRINGS.HH_DAILY_QUEST
        self.inst.components.talker:Say(strings.EXP_BLOCKED or 'EXP ĐANG BỊ PHONG ẤN')
    end
end

function HHLeveling:AddExp(amount)
    amount = tonumber(amount)
    if not amount or amount <= 0 then
        return false, 'invalid_amount'
    end
    if self:IsExpSealed() then
        self:NotifyExpBlocked()
        return false, 'sealed'
    end
    self.exp = self.exp + amount
    local goal = self:GetExpGoal(self.level)
    local levels_gained = 0
    local max_levels = TUNING.HH_LEVELING.MAX_LEVELS_PER_EXP_GRANT or 1000
    while self.exp >= goal and levels_gained < max_levels do
        self.exp = self.exp - goal
        self:LevelUp(true)
        levels_gained = levels_gained + 1
        goal = self:GetExpGoal(self.level)
    end
    if levels_gained > 0 then
        self:PlayLevelUpFeedback(self.level)
    end
    SyncToClient(self)
    return true
end

function HHLeveling:StartLevelRestore()
    if self.restore_task then
        self.restore_task:Cancel()
        self.restore_task = nil
    end

    local duration = TUNING.HH_LEVELING.LEVEL_UP_RESTORE_TIME or 10
    local interval = 0.5
    local ticks = math.max(1, math.floor(duration / interval + 0.5))
    local function Missing(component, current_key, max_key)
        if not component then return 0 end
        local current = component[current_key] or 0
        local maximum = component[max_key] or 0
        -- Chấp nhận sai số số thực nhỏ để coi chỉ số đã đạt 100%.
        return math.max(0, maximum - current) > 0.01 and math.max(0, maximum - current) or 0
    end

    self.restore_ticks = ticks
    self.restore_per_tick = {
        health = Missing(self.inst.components.health, "currenthealth", "maxhealth") / ticks,
        hunger = Missing(self.inst.components.hunger, "current", "max") / ticks,
        sanity = Missing(self.inst.components.sanity, "current", "max") / ticks,
        mana = Missing(self.inst.components.hh_mana, "current", "max") / ticks,
    }
    local function HasMissing(inst)
        return Missing(inst.components.health, "currenthealth", "maxhealth") > 0
            or Missing(inst.components.hunger, "current", "max") > 0
            or Missing(inst.components.sanity, "current", "max") > 0
            or Missing(inst.components.hh_mana, "current", "max") > 0
    end
    if not HasMissing(self.inst) then
        self.restore_ticks = 0
        return
    end

    self.restore_task = self.inst:DoPeriodicTask(interval, function(inst)
        if not inst:IsValid() or not inst.components.health or inst.components.health:IsDead() then
            if self.restore_task then self.restore_task:Cancel() end
            self.restore_task = nil
            return
        end
        if not HasMissing(inst) then
            self.restore_task:Cancel()
            self.restore_task = nil
            return
        end
        inst.components.health:DoDelta(self.restore_per_tick.health, true, "hh_level_restore")
        if inst.components.hunger then
            inst.components.hunger:DoDelta(self.restore_per_tick.hunger, true)
        end
        if inst.components.sanity then
            inst.components.sanity:DoDelta(self.restore_per_tick.sanity, true)
        end
        if inst.components.hh_mana then
            inst.components.hh_mana:DoDelta(self.restore_per_tick.mana)
        end

        -- Dừng ngay khi tick vừa đưa cả bốn chỉ số lên tối đa.
        if not HasMissing(inst) then
            self.restore_task:Cancel()
            self.restore_task = nil
            self.restore_ticks = 0
            return
        end

        if inst.SoundEmitter and (self.restore_per_tick.health > 0
            or self.restore_per_tick.hunger > 0
            or self.restore_per_tick.sanity > 0
            or self.restore_per_tick.mana > 0) then
            inst.SoundEmitter:PlaySound("dontstarve/HUD/health_up")
        end
        self.restore_ticks = self.restore_ticks - 1
        if self.restore_ticks <= 0 then
            self.restore_task:Cancel()
            self.restore_task = nil
        end
    end)
end

function HHLeveling:PlayLevelUpFeedback(level)
    self:StartLevelRestore()
    HHUtils:SpawnClientLevelUpFx(self.inst, "LEVEL UP! Lv." .. tostring(level))
    for i = 0, 2 do
        self.inst:DoTaskInTime(i * 1.5, function(inst)
            if inst.SoundEmitter then
                inst.SoundEmitter:PlaySound("dontstarve/HUD/get_gold")
            end
            local function SpawnAttachedFx(prefab)
                local fx = SpawnPrefab(prefab)
                if fx and fx.entity and inst.entity and fx.Transform then
                    fx.entity:SetParent(inst.entity)
                    fx.Transform:SetPosition(0, 0, 0)
                end
            end
            SpawnAttachedFx('statue_transition')
            SpawnAttachedFx('fx_book_light')
        end)
    end
end

function HHLeveling:LevelUp(suppress_feedback)
    self.level = self.level + 1
    self.ap = self.ap + TUNING.HH_LEVELING.AP_PER_LEVEL
    local current_level = self.level
    local interval = TUNING.HH_LEVELING.AP_BONUS_INTERVAL or 10
    if interval > 0 and current_level % interval == 0 then
        self.ap = self.ap + (TUNING.HH_LEVELING.AP_BONUS_AMOUNT or 0)
    end
    
    if not suppress_feedback then
        self:PlayLevelUpFeedback(current_level)
    end
    
    self.inst:PushEvent("hh_levelup")
end

function HHLeveling:PickStat(stat_name)
    if self.ap <= 0 then return end
    local caps = TUNING.HH_LEVELING.STAT_CAPS or {}
    local cap = caps[string.upper(tostring(stat_name))]
    local current = self["stat_" .. tostring(stat_name)]
    if cap and current and current >= cap then return end

    if stat_name == "str" then
        self.stat_str = self.stat_str + 1
    elseif stat_name == "agi" then
        self.stat_agi = self.stat_agi + 1
    elseif stat_name == "vit" then
        self.stat_vit = self.stat_vit + 1
    elseif stat_name == "sen" then
        self.stat_sen = self.stat_sen + 1
    elseif stat_name == "int" then
        self.stat_int = self.stat_int + 1
    else
        return
    end
    
    self.ap = self.ap - 1
    self:ApplyStat(stat_name)
    if stat_name == "int" and self.inst.components.hh_mana then
        self.inst.components.hh_mana:RecalculateMax(false)
    end
    if self.inst.SoundEmitter then
        self.inst.SoundEmitter:PlaySound("dontstarve/HUD/get_gold")
    end
    local fx = SpawnPrefab("fx_book_light")
    if fx and fx.entity and self.inst.entity and fx.Transform then
        fx.entity:SetParent(self.inst.entity)
        fx.Transform:SetPosition(0, 0, 0)
    end
    SyncToClient(self)
end

function HHLeveling:ApplyStat(stat_name)
    local T = TUNING.HH_LEVELING
    local player = self.inst.components.hh_player
    if not player then return end

    if stat_name == "str" then
        local current = math.min(math.max(self.stat_str, 0) * T.STR_GAIN, 20)
        local previous = math.min(math.max(self.stat_str - 1, 0) * T.STR_GAIN, 20)
        player:AddEffectValueByKey("trueDamageNum", current - previous)
    elseif stat_name == "agi" then
        player:AddEffectValueByKey("chanceDodgeAttack", T.AGI_GAIN)
    elseif stat_name == "vit" then
        player:AddEffectValueByKey("absorbDamage", T.VIT_GAIN)
    elseif stat_name == "sen" then
        player:AddEffectValueByKey("criticalHitRate", T.SEN_CRIT_RATE)
        player:AddEffectValueByKey("criticalHitEffect", T.SEN_CRIT_DMG)
    elseif stat_name == "int" then
        self:ApplyIntCooldown()
    end
end

function HHLeveling:ApplyAllStats()
    local T = TUNING.HH_LEVELING
    local player = self.inst.components.hh_player
    if not player then return end

    -- Re-apply all stats
    player:AddEffectValueByKey("trueDamageNum", math.min(math.max(self.stat_str, 0) * T.STR_GAIN, 20))
    player:AddEffectValueByKey("chanceDodgeAttack", self.stat_agi * T.AGI_GAIN)
    player:AddEffectValueByKey("absorbDamage", self.stat_vit * T.VIT_GAIN)
    player:AddEffectValueByKey("criticalHitRate", self.stat_sen * T.SEN_CRIT_RATE)
    player:AddEffectValueByKey("criticalHitEffect", self.stat_sen * T.SEN_CRIT_DMG)
    
    self:ApplyIntCooldown()
end

function HHLeveling:ApplyIntCooldown()
    local T = TUNING.HH_LEVELING
    local sm = self.inst.components.hh_shadow_manager
    if sm then
        local cd_reduce = self.stat_int * T.INT_CD_REDUCE
        sm.arise_cooldown  = math.max(5, 10 - cd_reduce)
        sm.recall_cooldown = math.max(3, 10 - cd_reduce)
        if sm.RefreshShadowRecoveryForInt ~= nil then
            sm:RefreshShadowRecoveryForInt()
        end
    end
end

function HHLeveling:OnSave()
    local exp_seal_remaining = math.max(0, self:GetExpSealRemaining())
    return {
        level = self.level,
        exp = self.exp,
        ap = self.ap,
        stat_str = self.stat_str,
        stat_agi = self.stat_agi,
        stat_vit = self.stat_vit,
        stat_sen = self.stat_sen,
        stat_int = self.stat_int,
        exp_seal_remaining = exp_seal_remaining,
    }
end

function HHLeveling:OnLoad(data)
    if data then
        local caps = TUNING.HH_LEVELING.STAT_CAPS or {}
        self.level = math.max(1, GetNonNegativeInteger(data.level, 1))
        self.exp = GetNonNegativeInteger(data.exp, 0)
        self.ap = GetNonNegativeInteger(data.ap, 0)
        self.stat_str = GetLoadedStat(data.stat_str, caps.STR)
        self.stat_agi = GetLoadedStat(data.stat_agi, caps.AGI)
        self.stat_vit = GetLoadedStat(data.stat_vit, caps.VIT)
        self.stat_sen = GetLoadedStat(data.stat_sen, caps.SEN)
        self.stat_int = GetLoadedStat(data.stat_int, caps.INT)
        if data.exp_seal_remaining ~= nil then
            local remaining = math.max(0, tonumber(data.exp_seal_remaining) or 0)
            self.exp_seal_deadline = remaining > 0 and GetWorldSeconds() + remaining or 0
        elseif data.exp_seal_deadline ~= nil then
            -- Legacy saves stored a shard-local absolute deadline. Keep this
            -- fallback for compatibility; new saves never write this field.
            self.exp_seal_deadline = math.max(0, tonumber(data.exp_seal_deadline) or 0)
        else
            self.exp_seal_deadline = 0
        end
        self:ScheduleExpSealExpiry()
        SyncToClient(self)
        
        self.inst:DoTaskInTime(0.1, function() 
            self:ApplyAllStats()
            SyncToClient(self)
        end)
    end
end

function HHLeveling:TransferComponent(newinst)
    local target = newinst and newinst.components and newinst.components.hh_leveling
    if not target then
        return
    end

    target.level = self.level
    target.exp = self.exp
    target.ap = self.ap
    target.stat_str = self.stat_str
    target.stat_agi = self.stat_agi
    target.stat_vit = self.stat_vit
    target.stat_sen = self.stat_sen
    target.stat_int = self.stat_int

    local exp_seal_remaining = self:GetExpSealRemaining()
    target.exp_seal_deadline = exp_seal_remaining > 0
        and GetWorldSeconds() + exp_seal_remaining
        or 0
    target:ScheduleExpSealExpiry()

    newinst:DoTaskInTime(0, function(inst)
        if not inst:IsValid() or inst.components.hh_leveling ~= target then
            return
        end
        target:ApplyAllStats()
        if inst.components.hh_mana then
            inst.components.hh_mana:RecalculateMax(false)
        end
        SyncToClient(target)
    end)
end

function HHLeveling:OnRemoveFromEntity()
    if self.exp_seal_task then
        self.exp_seal_task:Cancel()
        self.exp_seal_task = nil
    end
    if self.restore_task then
        self.restore_task:Cancel()
        self.restore_task = nil
    end
end

return HHLeveling
