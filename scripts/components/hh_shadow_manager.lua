local ShadowProgressionDefs = require("enums/hh_shadow_progression_defs")
local HH_UTILS = require("utils/hh_utils")

local FRUITFLY_UPKEEP_INTERVAL = 3
local FRUITFLY_RECALL_RECOVERY = 480
local FRUITFLY_COMMAND_RATE_LIMIT = 0.5
local FRUITFLY_NO_MANA_SPEECH = "FruitFly đã bị thu hồi vì mình hết Mana rồi !"
local FRUITFLY_BAD_SWAP_SPEECH = "Không thể Hoán Đổi vì FruitFly đang ở vị trí khá xấu ~~"
local FRUITFLY_NO_ACTIVE_SWAP_SPEECH = "Cần triệu hồi đệ tử FruitFly để sử dụng kỹ năng này !"
local MACANH_PREFAB = "hh_macanh_shadow"
local HACANH_PREFAB = "hh_hacanh_shadow"
local FRUITFLY_PREFAB = "hh_fruitfly_shadow"
local DUNGEON_RECALL_SHADOWS = {
    hh_igris_shadow = true,
    hh_beru_shadow = true,
    hh_macanh_shadow = true,
    hh_hacanh_shadow = true,
}
local DUNGEON_REBIND_SHADOWS = {
    [FRUITFLY_PREFAB] = true,
}
local HACANH_UPKEEP_INTERVAL = TUNING.HH_HACANH_SHADOW.MANA_UPKEEP_INTERVAL
local HACANH_RECOVERY = TUNING.HH_HACANH_SHADOW.RECOVERY
local MACANH_UPKEEP_INTERVAL = TUNING.HH_MACANH_SHADOW.MANA_UPKEEP_INTERVAL
local MACANH_RECOVERY = TUNING.HH_MACANH_SHADOW.RECOVERY

local function IsDungeonTeleportEntity(inst)
    if inst == nil then
        return false
    end
    if inst:HasTag("in_solo_dungeon")
        or inst.hh_is_dungeon_monster == true
        or inst:HasTag("hh_dungeon_mob") then
        return true
    end
    local follower = inst.components ~= nil and inst.components.follower or nil
    local leader = follower ~= nil and follower:GetLeader() or nil
    return leader ~= nil and leader:HasTag("in_solo_dungeon")
end

local function IsTeleportPathClear(inst, x, z)
    -- Blink/Swap are overworld abilities too. Keep their existing overworld
    -- behavior and apply the dynamic-wall check only to dungeon-bound actors.
    if not IsDungeonTeleportEntity(inst) then
        return true
    end
    if TheWorld == nil or TheWorld.Pathfinder == nil then
        return false
    end
    local px, py, pz = inst.Transform:GetWorldPosition()
    return TheWorld.Pathfinder:IsClear(px, py, pz, x, 0, z)
end

local function IsValidDungeonDestination(inst, x, z)
    if not IsDungeonTeleportEntity(inst) then
        return true
    end
    if TheWorld == nil or TheWorld.Map == nil
        or not TheWorld.Map:IsPassableAtPoint(x, 0, z)
        or TheWorld.Map:IsGroundTargetBlocked(Vector3(x, 0, z)) then
        return false
    end
    return IsTeleportPathClear(inst, x, z)
end

local function ResolveAriseSpawnPoint(inst, origin_x, origin_z, preferred_x, preferred_z)
    if IsValidDungeonDestination(inst, preferred_x, preferred_z) then
        return preferred_x, preferred_z
    end

    -- Keep the summon radius/visual behavior, but search a bounded set of
    -- nearby points when a dynamic arena wall occupies the random point.
    for i = 0, 11 do
        local angle = i * PI / 6
        local radius = 2 + (i % 3)
        local x = origin_x + math.cos(angle) * radius
        local z = origin_z + math.sin(angle) * radius
        if IsValidDungeonDestination(inst, x, z) then
            return x, z
        end
    end

    if IsValidDungeonDestination(inst, origin_x, origin_z) then
        return origin_x, origin_z
    end
    return nil, nil
end

local HHShadowManager = Class(function(self, inst)
    self.inst = inst
    
    -- Mảng lưu trữ các bóng ma: { prefab = "hh_igris_shadow", ready_time = 0, is_spawned = false, inst = nil }
    self.shadows = {}
    
    self.max_shadows = #ShadowProgressionDefs.ORDER
    self.arise_cooldown = 0 -- Không có thời gian hồi cho kỹ năng Trỗi Dậy
    self.arise_ready_time = 0
    self.arise_cooldown_total = 0
    self.recall_cooldown = 10
    self.recall_ready_time = 0
    self.recall_cooldown_total = 0
    self.swap_cooldown = TUNING.HH_MANA.SWAP_COOLDOWN or 480
    self.swap_ready_time = 0
    self.swap_cooldown_total = 0
    self._macanh_unlock_pending = false
    self._hacanh_unlock_pending = false
    self._macanh_owner_pick_action = nil

    if TheWorld.ismastersim then
        self:SyncShadowCount()

        self.inst:ListenForEvent("ms_playerleft", function(world, player)
            if player == self.inst then
                -- Disconnect must not apply the 480s recovery penalty. This
                -- matches the established mod behaviour and only removes the
                -- live/pending entity state before the player entity leaves.
                self:DespawnAll(false)
            end
        end, TheWorld)

        self.inst:ListenForEvent("onremove", function()
            self:DespawnAll(false)
        end)
        self.inst:ListenForEvent("death", function()
            self:DespawnAll(true)
        end)
        self.inst:ListenForEvent("makeplayerghost", function()
            self:DespawnAll(true)
        end)

        self.inst:ListenForEvent("working", function(_, data)
            self:OnOwnerWorking(data)
        end)
        self.inst:ListenForEvent("picksomething", function(_, data)
            self:OnOwnerPick(data)
        end)
        self.inst:ListenForEvent("performaction", function(_, data)
            self:OnOwnerPerformAction(data)
        end)
        self.inst:ListenForEvent("onattackother", function(_, data)
            self:OnOwnerAttackOther(data)
        end)
        self.inst:ListenForEvent("hh_daily_quest_completed", function()
            self:ReconcileMacanhUnlock()
            self:ReconcileHacanhUnlock()
        end)
        
        self.inst:DoPeriodicTask(1, function()
            local t = GetTime()
            
            -- Kiểm tra hết hạn (Lifespan 3 phút)
            for _, s in ipairs(self.shadows) do
                if s.prefab ~= HACANH_PREFAB and s.is_spawned
                    and s.lifespan_end_time and t >= s.lifespan_end_time then
                    self:OnShadowExpired(s)
                end
            end

            self:UpdateFruitFlyMana(t)
            self:UpdateMacanhMana(t)
            self:UpdateHacanhMana(t)
            self:RefreshShadowRecoveryForInt()
            
            self:SyncSkillWheelCooldowns(t)
            if self.inst.hh_sanctuary_cd then
                local sanctuary = self.inst.components ~= nil and self.inst.components.hh_sanctuary or nil
                if sanctuary ~= nil then
                    sanctuary:SyncCooldown(t)
                else
                    self.inst.hh_sanctuary_cd:set(0)
                end
            end
            if self.inst.hh_godslayer_cd then
                local godslayer = self.inst.components ~= nil and self.inst.components.hh_godslayer or nil
                if godslayer ~= nil then
                    godslayer:SyncCooldown(t)
                else
                    self.inst.hh_godslayer_cd:set(0)
                end
            end
            if self.inst.hh_ruler_cd then
                local ruler = self.inst.components ~= nil and self.inst.components.hh_ruler or nil
                if ruler ~= nil then
                    ruler:SyncCooldown(t)
                else
                    self.inst.hh_ruler_cd:set(0)
                end
            end
            if self.inst.hh_king_cd then
                local king = self.inst.components ~= nil and self.inst.components.hh_king or nil
                if king ~= nil then
                    king:SyncCooldown(t)
                else
                    self.inst.hh_king_cd:set(0)
                    if self.inst.hh_king_cd_total then
                        self.inst.hh_king_cd_total:set(0)
                    end
                end
            end
            if self.inst.hh_death_threshold_cd then
                local death_threshold = self.inst.components ~= nil
                    and self.inst.components.hh_death_threshold or nil
                if death_threshold ~= nil then
                    death_threshold:SyncCooldown(t)
                else
                    self.inst.hh_death_threshold_cd:set(0)
                end
            end
            if self.inst.hh_shadows_cd then
                local strs = {}
                local has_active = false
                for _, s in ipairs(self.shadows) do
                    if not s.is_spawned then
                        local cd = math.max(0, math.ceil(s.ready_time - t))
                        table.insert(strs, s.prefab .. ":" .. cd)
                    else
                        has_active = true
                        table.insert(strs, s.prefab .. ":-1")
                    end
                end
                self.inst.hh_shadows_cd:set(table.concat(strs, "|"))
                if self.inst.hh_has_shadows then
                    self.inst.hh_has_shadows:set(has_active)
                end
            end
        end)
    end
end)

function HHShadowManager:SyncSkillWheelCooldowns(now)
    now = now or GetTime()
    local cooldowns = {
        { "hh_arise_cd", "hh_arise_cd_total", self.arise_ready_time, self.arise_cooldown_total },
        { "hh_recall_cd", "hh_recall_cd_total", self.recall_ready_time, self.recall_cooldown_total },
        { "hh_swap_cd", "hh_swap_cd_total", self.swap_ready_time, self.swap_cooldown_total },
    }
    for _, cooldown in ipairs(cooldowns) do
        local remaining = math.max(0, math.ceil(cooldown[3] - now))
        local remaining_netvar = self.inst[cooldown[1]]
        local total_netvar = self.inst[cooldown[2]]
        if remaining_netvar ~= nil then
            remaining_netvar:set(remaining)
        end
        if total_netvar ~= nil then
            total_netvar:set(remaining > 0 and cooldown[4] or 0)
        end
    end
end

function HHShadowManager:ReconcileHacanhUnlock()
    local quest = self.inst.components.hh_daily_quest
    local completed = quest ~= nil and quest.completed_quest_count or 0
    if completed < TUNING.HH_HACANH_SHADOW.UNLOCK_COMPLETED_DAILY_QUESTS or self:HasShadowPrefab(HACANH_PREFAB) then
        return false
    end
    if not self:CanExtract() then
        self._hacanh_unlock_pending = true
        return false
    end
    if self:ExtractShadow(HACANH_PREFAB) then
        self._hacanh_unlock_pending = false
        if self.inst.components.talker ~= nil then
            self.inst.components.talker:Say(STRINGS.HH_HACANH_SHADOW.UNLOCKED, nil, true, true)
        end
        return true
    end
    return false
end

function HHShadowManager:GetProgression()
    return self.inst.components.hh_shadow_progression
end

function HHShadowManager:ShouldWaiveShadowMana(prefab, shadow_data)
    local progression = self:GetProgression()
    return progression ~= nil and progression:ShouldWaiveMana(prefab, shadow_data)
end

function HHShadowManager:GetShadowUpkeepInterval(prefab, base)
    local progression = self:GetProgression()
    return progression ~= nil and progression:GetUpkeepInterval(prefab, base) or base
end

function HHShadowManager:GetHacanhAttacksPerMana()
    local base = TUNING.HH_HACANH_SHADOW.ATTACKS_PER_MANA
    local progression = self:GetProgression()
    return progression ~= nil and progression:GetHacanhAttacksPerMana(base) or base
end

function HHShadowManager:AwardShadowActionExp(prefab, amount, reason)
    local progression = self:GetProgression()
    return progression ~= nil and progression:AwardExp(prefab, amount, reason) or false
end

function HHShadowManager:TrySpendHacanhMana(shadow, amount, reason)
    for _, s in ipairs(self.shadows) do
        if s.prefab == HACANH_PREFAB and s.is_spawned and s.inst == shadow and shadow:IsValid()
            and shadow.components.follower ~= nil and shadow.components.follower:GetLeader() == self.inst then
            local mana = self.inst.components.hh_mana
            if mana == nil then
                return false
            end
            if mana:GetCurrent() <= 0 then
                self:RecallHacanhForMana(s)
                return false
            end
            if self:ShouldWaiveShadowMana(HACANH_PREFAB, s) then
                return true
            end
            if not mana:CanSpend(amount, reason or "hacanh") then
                return false
            end
            if not mana:Spend(amount, reason or "hacanh") then
                if mana:GetCurrent() <= 0 then
                    self:RecallHacanhForMana(s)
                end
                return false
            end
            if mana:GetCurrent() <= 0 then
                self:RecallHacanhForMana(s)
                return false
            end
            return true
        end
    end
    return false
end

function HHShadowManager:RecallHacanhForMana(s)
    if s == nil or s._mana_recalling or not s.is_spawned then return false end
    s._mana_recalling = true
    local shadow = s.inst
    self:StartShadowRecovery(s, HACANH_RECOVERY, 0)
    local recall_ready_time = GetTime() + self.recall_cooldown
    if recall_ready_time > self.recall_ready_time then
        self.recall_ready_time = recall_ready_time
        self.recall_cooldown_total = self.recall_cooldown
        self:SyncSkillWheelCooldowns()
    end
    if shadow ~= nil and shadow:IsValid() then
        local fx = SpawnPrefab("statue_transition")
        if fx ~= nil then fx.Transform:SetPosition(shadow.Transform:GetWorldPosition()) end
        shadow:Remove()
    end
    if self.inst.components.talker ~= nil then
        self.inst.components.talker:Say(STRINGS.HH_HACANH_SHADOW.RECALL_MANA)
    end
    s._mana_recalling = nil
    return true
end

function HHShadowManager:UpdateHacanhMana(t)
    for _, s in ipairs(self.shadows) do
        if s.prefab == HACANH_PREFAB and s.is_spawned and not s.is_spawning then
            if s.inst == nil or not s.inst:IsValid() then
                self:OnShadowDied(s)
            elseif self.inst.components.hh_mana ~= nil
                and self.inst.components.hh_mana:GetCurrent() <= 0 then
                self:RecallHacanhForMana(s)
            elseif t >= (s.next_hacanh_mana_time or t + HACANH_UPKEEP_INTERVAL) then
                s.next_hacanh_mana_time = t + HACANH_UPKEEP_INTERVAL
                self:TrySpendHacanhMana(s.inst, 1, "hacanh_upkeep")
            end
        end
    end
end

function HHShadowManager:OnOwnerAttackOther(data)
    local target = data ~= nil and data.target or nil
    if target ~= nil and target ~= self.inst
        and HH_UTILS:IsShadowOwnerAlly(self.inst, target) then
        -- onattackother is emitted by Combat:DoAttack only after the
        -- canonical CanHitTarget() check. The marker is target-bound; its
        -- current combat target is validated lazily by CanShadowDamageTarget.
        self:SetIntentionalAllyTarget(target)
    else
        -- Any ordinary attack supersedes the previous ally exception.
        self:ClearIntentionalAllyTarget()
    end
end

function HHShadowManager:ClearIntentionalAllyTarget()
    local target = self._intentional_ally_target
    local callbacks = self._intentional_ally_target_callbacks
    self._intentional_ally_target = nil
    self._intentional_ally_target_callbacks = nil
    self.inst._hh_intentional_ally_target = nil

    if target ~= nil and callbacks ~= nil
        and target.IsValid ~= nil and target:IsValid() then
        if callbacks.onremove ~= nil then
            target:RemoveEventCallback("onremove", callbacks.onremove)
        end
        if callbacks.death ~= nil then
            target:RemoveEventCallback("death", callbacks.death)
        end
    end
end

function HHShadowManager:SetIntentionalAllyTarget(target)
    self:ClearIntentionalAllyTarget()
    if target == nil then
        return
    end

    self.inst._hh_intentional_ally_target = target
    if target.ListenForEvent == nil then
        return
    end

    local function clear_if_current()
        if self.inst._hh_intentional_ally_target == target then
            self:ClearIntentionalAllyTarget()
        end
    end
    self._intentional_ally_target = target
    self._intentional_ally_target_callbacks = {
        onremove = clear_if_current,
        death = clear_if_current,
    }
    target:ListenForEvent("onremove", clear_if_current)
    target:ListenForEvent("death", clear_if_current)
end

function HHShadowManager:IsOwnedShadowInstance(entity)
    if entity == nil then
        return false
    end
    for _, shadow_data in ipairs(self.shadows) do
        if shadow_data ~= nil
            and shadow_data.is_spawned
            and shadow_data.inst == entity then
            return true
        end
    end
    return false
end

function HHShadowManager:SyncShadowCount()
    if not TheWorld.ismastersim then return end
    if self.inst.hh_shadow_count then
        self.inst.hh_shadow_count:set(#self.shadows)
    end
    if self.inst.hh_shadow_max then
        self.inst.hh_shadow_max:set(self.max_shadows)
    end
end

function HHShadowManager:GetIntShadowReduction()
    local leveling = self.inst ~= nil and self.inst.components ~= nil
        and self.inst.components.hh_leveling or nil
    local stat_int = leveling ~= nil and leveling.stat_int or 0
    return stat_int * (TUNING.HH_LEVELING.INT_SHADOW_REDUCE or 0)
end

function HHShadowManager:GetShadowRecoveryDuration(base, minimum)
    return math.max(minimum or 0, (base or MACANH_RECOVERY) - self:GetIntShadowReduction())
end

function HHShadowManager:ResetShadowSpawnState(shadow_data)
    if shadow_data == nil then
        return
    end
    if shadow_data._arise_task ~= nil then
        shadow_data._arise_task:Cancel()
        shadow_data._arise_task = nil
    end
    if shadow_data._macanh_recall_task ~= nil then
        shadow_data._macanh_recall_task:Cancel()
        shadow_data._macanh_recall_task = nil
    end
    shadow_data.is_spawned = false
    shadow_data.is_spawning = false
    shadow_data.inst = nil
    shadow_data.lifespan_end_time = nil
    shadow_data.next_fruitfly_mana_time = nil
    shadow_data.next_macanh_mana_time = nil
    shadow_data.next_hacanh_mana_time = nil
    shadow_data._hh_progression_mana_counter = nil
    shadow_data.recovery_start_time = nil
    shadow_data.recovery_base_duration = nil
    shadow_data.recovery_min_duration = nil
end

function HHShadowManager:StartShadowRecovery(shadow_data, base, minimum)
    local now = GetTime()
    self:ResetShadowSpawnState(shadow_data)
    shadow_data.recovery_start_time = now
    shadow_data.recovery_base_duration = base or MACANH_RECOVERY
    shadow_data.recovery_min_duration = minimum or 0
    shadow_data.ready_time = now + self:GetShadowRecoveryDuration(
        shadow_data.recovery_base_duration,
        shadow_data.recovery_min_duration
    )
end

function HHShadowManager:RefreshShadowRecoveryForInt()
    local now = GetTime()
    for _, shadow_data in ipairs(self.shadows) do
        if not shadow_data.is_spawned and shadow_data.recovery_start_time ~= nil then
            shadow_data.ready_time = shadow_data.recovery_start_time
                + self:GetShadowRecoveryDuration(
                    shadow_data.recovery_base_duration,
                    shadow_data.recovery_min_duration
                )
            if shadow_data.ready_time < now then
                shadow_data.ready_time = now
            end
        end
    end
end

function HHShadowManager:ReconcileMacanhUnlock()
    local quest = self.inst.components.hh_daily_quest
    local completed = quest ~= nil and quest.completed_quest_count or 0
    if completed < TUNING.HH_MACANH_SHADOW.UNLOCK_COMPLETED_DAILY_QUESTS
        or self:HasShadowPrefab(MACANH_PREFAB) then
        return false
    end
    if not self:CanExtract() then
        self._macanh_unlock_pending = true
        return false
    end
    if self:ExtractShadow(MACANH_PREFAB) then
        self._macanh_unlock_pending = false
        self.inst:DoTaskInTime(0, function(inst)
            if inst:IsValid() and inst.components.talker ~= nil then
                inst.components.talker:Say(
                    STRINGS.HH_MACANH_SHADOW.UNLOCKED,
                    nil,
                    true,
                    true
                )
            end
        end)
        return true
    end
    return false
end

function HHShadowManager:OnOwnerWorking(data)
    local target = data ~= nil and (data.target or data.object) or nil
    local action = data ~= nil and data.action or nil
    if action == nil and target ~= nil and target.components ~= nil and target.components.workable ~= nil then
        action = target.components.workable:GetWorkAction()
    end
    local action_id = action ~= nil and (action.id or action.str) or nil
    if target == nil or target.prefab == nil
        or (action_id ~= "CHOP" and action_id ~= "MINE" and action_id ~= "DIG") then
        return
    end
    for _, shadow_data in ipairs(self.shadows) do
        if shadow_data.prefab == MACANH_PREFAB and shadow_data.is_spawned
            and shadow_data.inst ~= nil and shadow_data.inst:IsValid()
            and shadow_data.inst.SetHHWorkCommand ~= nil then
            shadow_data.inst:SetHHWorkCommand(action_id, target.prefab)
        end
    end
end

function HHShadowManager:OnOwnerPick(data)
    local target = data ~= nil and (data.object or data.target) or nil
    local tracking = self._macanh_owner_pick_action
    if target == nil or tracking == nil or tracking.action == nil
        or tracking.action.action ~= ACTIONS.PICK or tracking.target ~= target then
        return false
    end

    -- This is only an auxiliary signal. It is intentionally not the success
    -- source of truth because droppicked/no-loot pickables may not emit it.
    tracking.picksomething_seen = true
    return true
end

function HHShadowManager:ClearOwnerPickTracking(tracking)
    if tracking == nil or self._macanh_owner_pick_action ~= tracking then
        return false
    end

    self._macanh_owner_pick_action = nil

    local target = tracking.target
    if target ~= nil then
        if tracking.picked_listener ~= nil then
            target:RemoveEventCallback("picked", tracking.picked_listener)
        end
        if tracking.remove_listener ~= nil then
            target:RemoveEventCallback("onremove", tracking.remove_listener)
        end
    end

    tracking.action = nil
    tracking.target = nil
    tracking.prefab = nil
    tracking.owner = nil
    tracking.picksomething_seen = nil
    tracking.picked_listener = nil
    tracking.remove_listener = nil
    return true
end

function HHShadowManager:CommitOwnerPick(tracking)
    if tracking == nil or self._macanh_owner_pick_action ~= tracking
        or tracking.committed or not tracking.actual_pick_completed then
        return false
    end

    local prefab = tracking.prefab
    tracking.committed = true
    self:ClearOwnerPickTracking(tracking)
    if type(prefab) ~= "string" or prefab == "" then
        return false
    end

    for _, shadow_data in ipairs(self.shadows) do
        if shadow_data.prefab == MACANH_PREFAB and shadow_data.is_spawned
            and shadow_data.inst ~= nil and shadow_data.inst:IsValid()
            and shadow_data.inst.SetHHWorkCommand ~= nil then
            shadow_data.inst:SetHHWorkCommand("PICK", prefab)
        end
    end
    return true
end

function HHShadowManager:OnOwnerPerformAction(data)
    local action = data ~= nil and data.action or nil
    -- A newer action supersedes an older pending PICK. Remove both target
    -- listeners before replacing the identity so late callbacks cannot retain
    -- the old BufferedAction or mirror stale intent.
    self:ClearOwnerPickTracking(self._macanh_owner_pick_action)

    if action ~= nil and action.action == ACTIONS.PICKUP
        and action.doer == self.inst
        and action.target ~= nil and action.target:IsValid()
        and action.target.components ~= nil
        and action.target.components.inventoryitem ~= nil
        and (action.IsValid == nil or action:IsValid()) then
        for _, shadow_data in ipairs(self.shadows) do
            if shadow_data.prefab == MACANH_PREFAB and shadow_data.is_spawned
                and shadow_data.inst ~= nil and shadow_data.inst:IsValid()
                and shadow_data.inst.CancelHHWorkCommand ~= nil then
                local shadow = shadow_data.inst
                local has_stale_work_command = shadow._hh_work_action ~= nil
                    or shadow._hh_work_prefab ~= nil
                    or shadow._hh_pending_work_action ~= nil
                    or shadow._hh_pending_work_prefab ~= nil
                if has_stale_work_command then
                    -- Repeated owner PICKUP actions must not stop Macanh's
                    -- own batch pickup or delivery after the old work mode
                    -- has already been cleared.
                    shadow:CancelHHWorkCommand()
                end
            end
        end
        return
    end

    if action == nil or action.action ~= ACTIONS.PICK
        or action.target == nil or action.target.components == nil
        or action.target.components.pickable == nil
        or type(action.target.prefab) ~= "string" or action.target.prefab == ""
        or (action.IsValid ~= nil and not action:IsValid()) then
        return
    end

    local tracking = {
        action = action,
        target = action.target,
        prefab = action.target.prefab,
        owner = self.inst,
        actual_pick_completed = false,
        committed = false,
        picksomething_seen = false,
    }
    self._macanh_owner_pick_action = tracking

    tracking.picked_listener = function(target, picked_data)
        if self._macanh_owner_pick_action ~= tracking
            or target ~= tracking.target
            or picked_data == nil
            or picked_data.picker ~= self.inst then
            return
        end

        tracking.actual_pick_completed = true
        self:CommitOwnerPick(tracking)
    end

    tracking.remove_listener = function(target)
        if self._macanh_owner_pick_action == tracking then
            self:ClearOwnerPickTracking(tracking)
        end
    end

    tracking.target:ListenForEvent("picked", tracking.picked_listener)
    tracking.target:ListenForEvent("onremove", tracking.remove_listener)

    action:AddSuccessAction(function()
        if self._macanh_owner_pick_action == tracking
            and not tracking.actual_pick_completed then
            -- ACTIONS.PICK.fn() returns success without propagating
            -- Pickable:Pick()'s return value. No exact "picked" event means
            -- no harvest confirmation and therefore no mirror command.
            self:ClearOwnerPickTracking(tracking)
        end
    end)
    action:AddFailAction(function()
        if self._macanh_owner_pick_action == tracking then
            self:ClearOwnerPickTracking(tracking)
        end
    end)
end

function HHShadowManager:TrySpendMacanhMana(shadow, amount, reason)
    for _, shadow_data in ipairs(self.shadows) do
        if shadow_data.prefab == MACANH_PREFAB and shadow_data.is_spawned
            and shadow_data.inst == shadow and shadow ~= nil and shadow:IsValid()
            and shadow.components.follower ~= nil
            and shadow.components.follower:GetLeader() == self.inst then
            local mana = self.inst.components.hh_mana
            local function RecallForMana()
                if reason == "macanh_target" then
                    if shadow_data._macanh_recall_task == nil then
                        shadow_data._macanh_recall_task = self.inst:DoTaskInTime(0, function()
                            shadow_data._macanh_recall_task = nil
                            self:RecallMacanhForMana(shadow_data)
                        end)
                    end
                else
                    self:RecallMacanhForMana(shadow_data)
                end
            end
            if self:ShouldWaiveShadowMana(MACANH_PREFAB, shadow_data) then
                return true
            end
            if mana == nil or not mana:CanSpend(amount, reason or "macanh") then
                RecallForMana()
                return false
            end
            if not mana:Spend(amount, reason or "macanh") then
                RecallForMana()
                return false
            end
            if mana:GetCurrent() <= 0 then
                RecallForMana()
            end
            return true
        end
    end
    return false
end

function HHShadowManager:RecallMacanhForMana(shadow_data)
    if shadow_data == nil or shadow_data._mana_recalling or not shadow_data.is_spawned then
        return false
    end
    shadow_data._mana_recalling = true
    local shadow = shadow_data.inst
    self:StartShadowRecovery(shadow_data, MACANH_RECOVERY, 0)
    local recall_ready_time = GetTime() + self.recall_cooldown
    if recall_ready_time > self.recall_ready_time then
        self.recall_ready_time = recall_ready_time
        self.recall_cooldown_total = self.recall_cooldown
        self:SyncSkillWheelCooldowns()
    end
    if shadow ~= nil and shadow:IsValid() then
        local fx = SpawnPrefab("statue_transition")
        if fx ~= nil then fx.Transform:SetPosition(shadow.Transform:GetWorldPosition()) end
        shadow:Remove()
    end
    if self.inst.components.talker ~= nil then
        self.inst.components.talker:Say("Mặc Ảnh đã bị thu hồi vì chủ nhân hết Mana.")
    end
    shadow_data._mana_recalling = nil
    return true
end

function HHShadowManager:UpdateMacanhMana(t)
    for _, shadow_data in ipairs(self.shadows) do
        if shadow_data.prefab == MACANH_PREFAB and shadow_data.is_spawned and not shadow_data.is_spawning then
            if shadow_data.inst == nil or not shadow_data.inst:IsValid() then
                self:OnShadowDied(shadow_data)
            elseif t >= (shadow_data.next_macanh_mana_time or t + MACANH_UPKEEP_INTERVAL) then
                shadow_data.next_macanh_mana_time = t + MACANH_UPKEEP_INTERVAL
                self:TrySpendMacanhMana(shadow_data.inst, 1, "macanh_upkeep")
            end
        end
    end
end

function HHShadowManager:OnMacanhTargetCompleted(shadow, data, completed_action)
    local target = data ~= nil and (data.target or data.object) or nil
    if target == nil then
        return false
    end
    -- finishedwork supplies data.action; picksomething passes ACTIONS.PICK
    -- explicitly. Do not infer PICK/searchable context from target.workable.
    local action = completed_action or (data ~= nil and data.action or nil)
    if action == nil then
        return false
    end
    local action_id = action ~= nil and (action.id or action.str) or nil
    if action_id == nil then
        return false
    end
    local mana_cost = (action_id == "CHOP" or action_id == "MINE") and 5
        or TUNING.HH_MACANH_SHADOW.MANA_PER_COMPLETED_TARGET
    local paid = self:TrySpendMacanhMana(shadow, mana_cost, "macanh_target")
    if paid then
        self:AwardShadowActionExp(MACANH_PREFAB, action_id == "PICK" and 3 or 6, "work_" .. tostring(action_id))
    end
    return paid
end

function HHShadowManager:OnMacanhGroundPickupCompleted(shadow, action)
    if shadow == nil or not shadow:IsValid()
        or action == nil or action.action ~= ACTIONS.PICKUP
        or action.doer ~= shadow
        or action.target == nil then
        return false
    end

    local follower = shadow.components ~= nil and shadow.components.follower or nil
    if follower == nil or follower:GetLeader() ~= self.inst then
        return false
    end

    if action._hh_macanh_ground_pickup_exp_awarded then
        return false
    end
    action._hh_macanh_ground_pickup_exp_awarded = true

    -- braincommon_pickup_success is emitted once for the successful
    -- BufferedAction. Keep this separate from OnMacanhTargetCompleted():
    -- ground pickup grants EXP but has no per-action Mana cost.
    self:AwardShadowActionExp(MACANH_PREFAB, 3, "ground_pickup")
    return true
end

function HHShadowManager:DespawnAll(apply_recovery_penalty)
    apply_recovery_penalty = apply_recovery_penalty ~= false
    self:ClearIntentionalAllyTarget()
    self:ClearOwnerPickTracking(self._macanh_owner_pick_action)
    for _, s in ipairs(self.shadows) do
        local shadow = s.inst
        local was_spawned = s.is_spawned or s.is_spawning or s._arise_task ~= nil
        if was_spawned then
            if apply_recovery_penalty then
                -- Death/ghost keeps the normal 480s penalty.
                self:StartShadowRecovery(s, 480, 0)
            else
                -- Disconnect clears active and delayed-spawn state without a
                -- recovery cooldown, matching the established behaviour.
                self:ResetShadowSpawnState(s)
                s.ready_time = GetTime()
            end

            -- Hiệu ứng biến mất
            if shadow ~= nil and shadow:IsValid() then
                local fx = SpawnPrefab("statue_transition")
                if fx then fx.Transform:SetPosition(shadow.Transform:GetWorldPosition()) end
                shadow:Remove()
            end
        end
    end
end

function HHShadowManager:PrepareForReincarnation()
    if not TheWorld.ismastersim then
        return 0
    end

    -- Reincarnation removes the old body without treating the deliberate
    -- follower cleanup as a death or a disconnect. Preserve all persisted
    -- roster/cooldown/recovery fields while clearing only live entity state.
    self:ClearIntentionalAllyTarget()
    self:ClearOwnerPickTracking(self._macanh_owner_pick_action)

    local now = GetTime()
    local recalled = 0
    for _, shadow_data in ipairs(self.shadows) do
        local shadow = shadow_data.inst
        local was_spawned = shadow_data.is_spawned
            or shadow_data.is_spawning
            or shadow_data._arise_task ~= nil
        if was_spawned then
            local ready_time = shadow_data.ready_time
            local recovery_start_time = shadow_data.recovery_start_time
            local recovery_base_duration = shadow_data.recovery_base_duration
            local recovery_min_duration = shadow_data.recovery_min_duration

            self:ResetShadowSpawnState(shadow_data)
            shadow_data.ready_time = ready_time or now
            shadow_data.recovery_start_time = recovery_start_time
            shadow_data.recovery_base_duration = recovery_base_duration
            shadow_data.recovery_min_duration = recovery_min_duration
            recalled = recalled + 1

            if shadow ~= nil and shadow:IsValid() then
                local fx = SpawnPrefab("statue_transition")
                if fx ~= nil then
                    fx.Transform:SetPosition(shadow.Transform:GetWorldPosition())
                end
                shadow:Remove()
            end
        end
    end
    self:SyncShadowCount()
    return recalled
end

local function IsDungeonFruitflyForLeave(self, shadow_data)
    if shadow_data == nil
        or shadow_data.prefab ~= FRUITFLY_PREFAB
        or self.inst == nil
        or not self.inst:IsValid()
        or not self.inst:HasTag("in_solo_dungeon") then
        return false
    end

    local dungeon_manager = TheWorld ~= nil
        and TheWorld.components ~= nil
        and TheWorld.components.dungeon_manager or nil
    if dungeon_manager == nil
        or dungeon_manager.players_in_dungeon == nil
        or not dungeon_manager.players_in_dungeon[self.inst] then
        return false
    end

    -- A pending Arise has no entity yet. The leave call is made while this
    -- owner is still tracked in the dungeon, so its pending Fruitfly belongs
    -- to this transition.
    if shadow_data.is_spawning or shadow_data._arise_task ~= nil then
        return true
    end

    local shadow = shadow_data.inst
    return shadow_data.is_spawned
        and shadow ~= nil
        and shadow:IsValid()
        and shadow.components ~= nil
        and shadow.components.follower ~= nil
        and shadow.components.follower:GetLeader() == self.inst
end

function HHShadowManager:PrepareForDungeonTransition(direction)
    if not TheWorld.ismastersim then
        return 0
    end

    local now = GetTime()
    local recalled = 0
    for _, shadow_data in ipairs(self.shadows) do
        local should_recall = DUNGEON_RECALL_SHADOWS[shadow_data.prefab]
        if direction == "leave"
            and IsDungeonFruitflyForLeave(self, shadow_data) then
            should_recall = true
        end

        if should_recall
            and (shadow_data.is_spawned
                or shadow_data.is_spawning
                or shadow_data._arise_task ~= nil) then
            local shadow = shadow_data.inst

            -- Clear manager state before Remove(), so the shadow's onremove
            -- listener cannot turn this intentional recall into a death.
            self:ResetShadowSpawnState(shadow_data)
            shadow_data.ready_time = now
            recalled = recalled + 1

            if shadow ~= nil and shadow:IsValid() then
                local fx = SpawnPrefab("statue_transition")
                if fx ~= nil then
                    fx.Transform:SetPosition(shadow.Transform:GetWorldPosition())
                end
                shadow:Remove()
            end
        end
    end
    return recalled
end

function HHShadowManager:PrepareForDungeonEntry()
    return self:PrepareForDungeonTransition("enter")
end

function HHShadowManager:RebindOwnedFollowers()
    if not TheWorld.ismastersim
        or self.inst == nil
        or not self.inst:IsValid()
        or self.inst.components == nil
        or self.inst.components.leader == nil then
        return 0
    end

    local leader_component = self.inst.components.leader
    local rebound = 0
    for _, shadow_data in ipairs(self.shadows) do
        local shadow = shadow_data.inst
        if DUNGEON_REBIND_SHADOWS[shadow_data.prefab]
            and shadow_data.is_spawned
            and not shadow_data.is_spawning
            and shadow ~= nil
            and shadow.prefab == shadow_data.prefab
            and shadow:IsValid()
            and not shadow:IsInLimbo()
            and shadow.components ~= nil
            and shadow.components.follower ~= nil
            and shadow.components.health ~= nil
            and not shadow.components.health:IsDead() then
            local follower = shadow.components.follower
            local current_leader = follower:GetLeader()
            if current_leader == nil then
                follower:SetLeader(self.inst)
                rebound = rebound + 1
            elseif current_leader == self.inst
                and leader_component.followers ~= nil
                and leader_component.followers[shadow] == nil then
                leader_component:AddFollower(shadow)
                rebound = rebound + 1
            end
        end
    end
    return rebound
end

function HHShadowManager:CanExtract()
    return #self.shadows < self.max_shadows
end

function HHShadowManager:HasShadowPrefab(prefab)
    for _, shadow_data in ipairs(self.shadows) do
        if shadow_data.prefab == prefab then
            return true
        end
    end
    return false
end

function HHShadowManager:ExtractShadow(prefab)
    if not TheWorld.ismastersim or not ShadowProgressionDefs.IsSupported(prefab) then
        return false
    end

    if self:HasShadowPrefab(prefab) then
        if self.inst.components.talker then
            local def = ShadowProgressionDefs.Get(prefab)
            self.inst.components.talker:Say("Ta đã sở hữu " .. (def ~= nil and def.name or prefab) .. "!")
        end
        return false
    end

    if self:CanExtract() then
        table.insert(self.shadows, { prefab = prefab, ready_time = 0, is_spawned = false })
        local progression = self:GetProgression()
        if progression ~= nil and ShadowProgressionDefs.IsSupported(prefab) then
            progression:EnsureProfile(prefab)
        end
        self:SyncShadowCount()
        return true
    end
    return false
end

function HHShadowManager:GetShadowData(prefab)
    if type(prefab) ~= "string" then
        return nil
    end
    for _, shadow_data in ipairs(self.shadows) do
        if shadow_data.prefab == prefab then
            return shadow_data
        end
    end
    return nil
end

function HHShadowManager:IsAriseReady()
    return GetTime() >= self.arise_ready_time
end

function HHShadowManager:Arise(prefab)
    local t = GetTime()
    if t < self.arise_ready_time then
        if self.inst.components.talker then
            local remain = math.ceil(self.arise_ready_time - t)
            self.inst.components.talker:Say("Kỹ năng Trỗi Dậy chưa hồi (" .. remain .. "s)")
        end
        return false
    end
    
    if self.inst == nil or not self.inst:IsValid()
        or self.inst.components.health == nil
        or self.inst.components.health:IsDead()
        or self.inst:HasTag("playerghost") then
        return false
    end

    local selected_shadow = self:GetShadowData(prefab)
    local ready_shadows = {}
    if selected_shadow ~= nil
        and not selected_shadow.is_spawned
        and t >= selected_shadow.ready_time then
        table.insert(ready_shadows, selected_shadow)
    end
    if selected_shadow == nil then
        if self.inst.components.talker then
            if #self.shadows == 0 then
                self.inst.components.talker:Say('Tôi chưa có bóng ma nào!')
            else
                self.inst.components.talker:Say(STRINGS.HH_SHADOW_SUMMON.INVALID)
            end
        end
        return false
    end
    if selected_shadow.is_spawned then
        if self.inst.components.talker then
            self.inst.components.talker:Say(STRINGS.HH_SHADOW_SUMMON.ACTIVE_SERVER)
        end
        return false
    end
    if t < selected_shadow.ready_time then
        if self.inst.components.talker then
            local remain = math.ceil(selected_shadow.ready_time - t)
            local name = STRINGS.NAMES[string.upper(selected_shadow.prefab)] or 'Đệ tử'
            self.inst.components.talker:Say(name .. ' đang trong trạng thái hồi phục (' .. remain .. 's).')
        end
        return false
    end
    if #ready_shadows == 0 then
        if self.inst.components.talker then
            if #self.shadows == 0 then
                self.inst.components.talker:Say("Tôi chưa có bóng ma nào!")
            else
                local recovering_names = {}
                for i, shadow_data in ipairs(self.shadows) do
                    if not shadow_data.is_spawned then
                        local name = STRINGS.NAMES[string.upper(shadow_data.prefab)] or "Bóng ma"
                        table.insert(recovering_names, name)
                    end
                end
                self.inst.components.talker:Say(table.concat(recovering_names, ", ") .. " đang trong trạng thái hồi phục!")
            end
        end
        return false
    end
    -- Triệu hồi bóng ma
    local summoned_count = 0
    for i, shadow_data in ipairs(ready_shadows) do
        local summon_cost = (TUNING.HH_MANA.ARISE_COSTS ~= nil and
            TUNING.HH_MANA.ARISE_COSTS[shadow_data.prefab]) or TUNING.HH_MANA.ARISE_COST or 40
        local mana = self.inst.components.hh_mana
        -- Không đủ 20 não thì chặn không triệu hồi đệ tử đang chọn.
        local sanity = self.inst.components.sanity
        local has_sanity = sanity ~= nil and sanity.current >= 20
        local paid = has_sanity and mana ~= nil and mana:CanSpend(summon_cost, "arise") and mana:Spend(summon_cost, "arise")
        if paid then
            -- Tính vị trí random xung quanh người chơi TRƯỚC khi spawn
            local x, y, z = self.inst.Transform:GetWorldPosition()
            local angle = math.random() * 2 * PI
            local radius = 2 + math.random() * 2
            local target_x = x + math.cos(angle) * radius
            local target_y = y
            local target_z = z + math.sin(angle) * radius
            target_x, target_z = ResolveAriseSpawnPoint(self.inst, x, z, target_x, target_z)
            if target_x == nil then
                if mana ~= nil then
                    mana:DoDelta(summon_cost)
                end
                return false
            end

            -- Spawn hiệu ứng fx3 NGAY LẬP TỨC tại vị trí đệ tử sẽ xuất hiện
            local fx3_inst = SpawnPrefab("fx3")
            if fx3_inst then
                fx3_inst.Transform:SetPosition(target_x, target_y, target_z)
            end

            -- Đánh dấu trước để không bị triệu hồi trùng lặp
            shadow_data.is_spawned = true
            shadow_data.is_spawning = true
            summoned_count = summoned_count + 1

            -- Capture các biến cần thiết cho closure
            local captured_prefab = shadow_data.prefab
            local captured_summon_cost = summon_cost
            local captured_shadow_data = shadow_data

            -- Trì hoãn việc spawn đệ tử đến frame thứ 17 (40 FPS → 17/40 = 0.425 giây)
            shadow_data._arise_task = self.inst:DoTaskInTime(17 / 40, function()
                captured_shadow_data._arise_task = nil

                -- Recall/death/disconnect may have cancelled this task in the
                -- same tick. Do not resurrect a cancelled summon.
                if not captured_shadow_data.is_spawned or not captured_shadow_data.is_spawning then
                    return
                end

                -- Kiểm tra player còn valid không (có thể đã thoát game/chết trong lúc chờ)
                if self.inst == nil or not self.inst:IsValid()
                    or self.inst.components.health == nil
                    or self.inst.components.health:IsDead()
                    or self.inst:HasTag("playerghost") then
                    self:StartShadowRecovery(captured_shadow_data, 480, 0)
                    return
                end

                local current_x, _, current_z = self.inst.Transform:GetWorldPosition()
                target_x, target_z = ResolveAriseSpawnPoint(
                    self.inst,
                    current_x,
                    current_z,
                    target_x,
                    target_z
                )
                if target_x == nil then
                    if mana ~= nil then
                        mana:DoDelta(captured_summon_cost)
                    end
                    captured_shadow_data.is_spawned = false
                    captured_shadow_data.is_spawning = false
                    return
                end

                captured_shadow_data.is_spawning = false
                local shadow_inst = SpawnPrefab(captured_prefab)
                if shadow_inst then
                    -- Summoned shadows are reconstructed exclusively from this manager.
                    -- Never serialize the live entity into the world save, otherwise it
                    -- can reload without its manager/leader and become an orphan.
                    shadow_inst.persists = false
                    shadow_inst.Transform:SetPosition(target_x, target_y, target_z)

                    -- Gắn người chơi làm chủ nhân
                    if shadow_inst.components.follower then
                        shadow_inst.components.follower:SetLeader(self.inst)
                    end

                    local progression = self:GetProgression()
                    if progression ~= nil then
                        progression:BindShadow(shadow_inst, captured_prefab)
                    end

                    if captured_prefab == "hh_fruitfly_shadow" and
                        shadow_inst.components.globaltrackingicon ~= nil then
                        shadow_inst.components.globaltrackingicon:StartTracking(self.inst, "hh_fruitfly_shadow")
                    end

                    if captured_prefab == MACANH_PREFAB and
                        shadow_inst.components.globaltrackingicon ~= nil then
                        shadow_inst.components.globaltrackingicon:StartTracking(self.inst, MACANH_PREFAB)
                    end

                    if captured_prefab == HACANH_PREFAB and shadow_inst.components.globaltrackingicon ~= nil then
                        shadow_inst.components.globaltrackingicon:StartTracking(self.inst, HACANH_PREFAB)
                    end

                    if captured_prefab == "hh_fruitfly_shadow" and shadow_inst.SetHHWorkPosition ~= nil then
                        shadow_inst:SetHHWorkPosition(target_x, target_y, target_z)
                    end

                    captured_shadow_data.inst = shadow_inst
                    if self.inst.components.hh_dungeon_effects ~= nil then
                        self.inst.components.hh_dungeon_effects:RefreshTargets()
                    end
                    captured_shadow_data.recovery_start_time = nil
                    captured_shadow_data.recovery_base_duration = nil
                    captured_shadow_data.recovery_min_duration = nil

                    if captured_prefab == "hh_fruitfly_shadow" then
                        captured_shadow_data.lifespan_end_time = nil
                        captured_shadow_data.next_fruitfly_mana_time = GetTime()
                            + self:GetShadowUpkeepInterval("hh_fruitfly_shadow", FRUITFLY_UPKEEP_INTERVAL)
                    elseif captured_prefab == MACANH_PREFAB then
                        captured_shadow_data.lifespan_end_time = nil
                        captured_shadow_data.next_macanh_mana_time = GetTime() + MACANH_UPKEEP_INTERVAL
                    elseif captured_prefab == HACANH_PREFAB then
                        captured_shadow_data.lifespan_end_time = nil
                        captured_shadow_data.next_hacanh_mana_time = GetTime() + HACANH_UPKEEP_INTERVAL
                    else
                        captured_shadow_data.lifespan_end_time = GetTime() + 180 -- Tồn tại 3 phút
                    end

                    -- Lắng nghe sự kiện tử vong để bắt đầu tính cooldown
                    self.inst:ListenForEvent("death", function(shadow, data)
                        self:OnShadowDied(captured_shadow_data)
                    end, shadow_inst)

                    -- Reconcile removals that do not emit death. Intentional
                    -- removes set is_spawned=false before Remove(), so they do
                    -- not get a duplicate recovery penalty.
                    self.inst:ListenForEvent("onremove", function(shadow)
                        if captured_shadow_data.is_spawned
                            and captured_shadow_data.inst == shadow then
                            self:OnShadowDied(captured_shadow_data)
                        end
                    end, shadow_inst)

                    -- Hiệu ứng lúc xuất hiện (tại vị trí đệ tử)
                    local fx = SpawnPrefab("statue_transition")
                    if fx then fx.Transform:SetPosition(target_x, target_y, target_z) end
                    local smoke = SpawnPrefab("spawn_fx_huge")
                    if smoke then
                        smoke.Transform:SetPosition(target_x, target_y, target_z)
                        if smoke.AnimState then
                            smoke.AnimState:SetMultColour(0, 0, 0, 1)
                        end
                    end
                    local fire = SpawnPrefab("warly_camp_fire_fx")
                    if fire then
                        fire.Transform:SetPosition(target_x, target_y, target_z)
                        if fire.AnimState then
                            fire.AnimState:SetMultColour(0, 0.3, 1, 1) -- Lửa bóng tối
                        end
                        fire:DoTaskInTime(1, function(inst) inst:Remove() end)
                    end

                    -- Trừ 20 não của người chơi khi triệu hồi thành công 1 đệ tử
                    if self.inst.components.sanity then
                        self.inst.components.sanity:DoDelta(-20)
                    end
                else
                    -- Spawn đệ tử thất bại → hoàn mana lại cho người chơi
                    if mana ~= nil then
                        mana:DoDelta(captured_summon_cost)
                    end
                    captured_shadow_data.is_spawned = false
                end
            end)
        elseif paid and mana ~= nil then
            mana:DoDelta(summon_cost)
        end
    end
    
    if summoned_count == 0 then
        if self.inst.components.talker ~= nil then
            self.inst.components.talker:Say("Không đủ Mana để triệu hồi bất kỳ đệ tử nào đang sẵn sàng.")
        end
        return false
    end

    -- Đặt cooldown cho kĩ năng Trỗi Dậy
    self.arise_cooldown_total = self.arise_cooldown
    self.arise_ready_time = t + self.arise_cooldown_total
    self:SyncSkillWheelCooldowns(t)
    
    -- Hoạt ảnh người chơi
    self.inst.AnimState:PlayAnimation("mindcontrol_pre")
    self.inst.AnimState:PushAnimation("mindcontrol_loop", false)
    self.inst.AnimState:PushAnimation("mindcontrol_pst", false)
    
    -- VFX Sóng bóng tối dưới chân người chơi
    local cx, cy, cz = self.inst.Transform:GetWorldPosition()
    local aura = SpawnPrefab("shadow_despawn")
    if aura then
        aura.Transform:SetPosition(cx, cy, cz)
        if aura.AnimState then
            aura.AnimState:SetMultColour(0, 0, 0, 1)
        end
    end
    local crack = SpawnPrefab("deerclops_laserscorch")
    if crack then
        crack.Transform:SetPosition(cx, cy, cz)
    end

    if self.inst.SoundEmitter then
        -- Âm thanh hầm ngục
        self.inst.SoundEmitter:PlaySound("dontstarve/common/ghost_spawn")
    end
    if self.inst.components.talker then
        self.inst.components.talker:Say("TRỖI DẬY!")
    end
    
    return true
end

function HHShadowManager:OnShadowDied(shadow_data)
    if shadow_data == nil or not shadow_data.is_spawned then
        return false
    end
    local minimum = shadow_data.prefab == MACANH_PREFAB and 0 or 60
    self:StartShadowRecovery(shadow_data, 480, minimum)
    
    if self.inst.components.talker then
        self.inst.components.talker:Say("Một bóng ma đã gục ngã và đang hồi phục.")
    end
    return true
end

function HHShadowManager:OnShadowExpired(shadow_data)
    if shadow_data == nil or shadow_data.prefab == HACANH_PREFAB then
        return false
    end
    if shadow_data.is_spawned then
        local shadow = shadow_data.inst
        
        -- Phạt nhẹ 60s
        self:StartShadowRecovery(shadow_data, 60, 10)
        
        if shadow ~= nil and shadow:IsValid() then
            local fx = SpawnPrefab("statue_transition")
            if fx then fx.Transform:SetPosition(shadow.Transform:GetWorldPosition()) end
            shadow:Remove()
        end
        
        if self.inst.components.talker then
            self.inst.components.talker:Say("Đệ tử đã hết năng lượng và rút lui.")
        end
        return true
    end
    return false
end

function HHShadowManager:RecallFruitFlyForMana(s)
    if s == nil or s._mana_recalling or not s.is_spawned then return false end
    s._mana_recalling = true
    local shadow = s.inst
    self:StartShadowRecovery(s, FRUITFLY_RECALL_RECOVERY, 0)
    local recall_ready_time = GetTime() + self.recall_cooldown
    if recall_ready_time > self.recall_ready_time then
        self.recall_ready_time = recall_ready_time
        self.recall_cooldown_total = self.recall_cooldown
        self:SyncSkillWheelCooldowns()
    end
    if shadow ~= nil and shadow:IsValid() then
        local fx = SpawnPrefab("statue_transition")
        if fx ~= nil then fx.Transform:SetPosition(shadow.Transform:GetWorldPosition()) end
        shadow:Remove()
    end
    if self.inst.components.talker ~= nil then self.inst.components.talker:Say(FRUITFLY_NO_MANA_SPEECH) end
    s._mana_recalling = nil
    return true
end

function HHShadowManager:TrySpendFruitFlyMana(shadow, amount, reason)
    for _, s in ipairs(self.shadows) do
        if s.prefab == "hh_fruitfly_shadow" and s.is_spawned and s.inst == shadow and
            shadow ~= nil and shadow:IsValid() and shadow.components.follower ~= nil and
            shadow.components.follower:GetLeader() == self.inst then
            if self:ShouldWaiveShadowMana("hh_fruitfly_shadow", s) then
                return true
            end
            local mana = self.inst.components.hh_mana
            if mana == nil or not mana:CanSpend(amount, reason or "fruitfly") then
                if not (s._hh_swap_in_progress and s._hh_swap_defer_zero_mana_recall) then
                    self:RecallFruitFlyForMana(s)
                end
                return false
            end
            if not mana:Spend(amount, reason) or mana:GetCurrent() <= 0 then
                if not (s._hh_swap_in_progress and s._hh_swap_defer_zero_mana_recall) then
                    self:RecallFruitFlyForMana(s)
                end
                return false
            end
            return true
        end
    end
    return false
end

function HHShadowManager:UpdateFruitFlyMana(t)
    for _, s in ipairs(self.shadows) do
        if s.prefab == "hh_fruitfly_shadow" and s.is_spawned and not s.is_spawning then
            if s.inst == nil or not s.inst:IsValid() then
                self:OnShadowDied(s)
            elseif self.inst.components.hh_mana == nil or self.inst.components.hh_mana:GetCurrent() <= 0 then
                if not (s._hh_swap_in_progress and s._hh_swap_defer_zero_mana_recall) then
                    self:RecallFruitFlyForMana(s)
                end
            elseif t >= (s.next_fruitfly_mana_time or t + FRUITFLY_UPKEEP_INTERVAL) then
                s.next_fruitfly_mana_time = t
                    + self:GetShadowUpkeepInterval("hh_fruitfly_shadow", FRUITFLY_UPKEEP_INTERVAL)
                self:TrySpendFruitFlyMana(s.inst, 1, "fruitfly_upkeep")
            end
        end
    end
end

function HHShadowManager:OnSave()
    local t = GetTime()
    local data = {
        shadows = {},
        arise_ready_time = math.max(0, self.arise_ready_time - t),
        recall_ready_time = math.max(0, self.recall_ready_time - t),
        swap_ready_time = math.max(0, self.swap_ready_time - t),
        arise_cooldown_total = self.arise_cooldown_total,
        recall_cooldown_total = self.recall_cooldown_total,
        swap_cooldown_total = self.swap_cooldown_total,
    }
    for i, s in ipairs(self.shadows) do
        table.insert(data.shadows, {
            prefab = s.prefab,
            remaining_cooldown = math.max(0, s.ready_time - t),
            recovery_elapsed = s.recovery_start_time ~= nil and math.max(0, t - s.recovery_start_time) or nil,
            recovery_base_duration = s.recovery_base_duration,
            recovery_min_duration = s.recovery_min_duration,
        })
    end
    return data
end

function HHShadowManager:OnLoad(data)
    if data then
        local t = GetTime()
        local arise_remaining = math.max(0, tonumber(data.arise_ready_time) or 0)
        local recall_remaining = math.max(0, tonumber(data.recall_ready_time) or 0)
        local swap_remaining = math.max(0, tonumber(data.swap_ready_time) or 0)
        self.arise_cooldown_total = arise_remaining > 0 and math.max(arise_remaining, tonumber(data.arise_cooldown_total) or self.arise_cooldown) or 0
        self.recall_cooldown_total = recall_remaining > 0 and math.max(recall_remaining, tonumber(data.recall_cooldown_total) or self.recall_cooldown) or 0
        self.swap_cooldown_total = swap_remaining > 0 and math.max(swap_remaining, tonumber(data.swap_cooldown_total) or self.swap_cooldown) or 0
        self.arise_ready_time = t + arise_remaining
        self.recall_ready_time = t + recall_remaining
        self.swap_ready_time = t + swap_remaining
        if type(data.shadows) == "table" then
            self.shadows = {}
            local loaded_unique = {}
            for i, s in ipairs(data.shadows) do
                if #self.shadows >= self.max_shadows then
                    break
                end
                if type(s) == "table" and type(s.prefab) == "string" and s.prefab ~= ""
                    and ShadowProgressionDefs.IsSupported(s.prefab)
                    and not loaded_unique[s.prefab] then
                        local remaining_cooldown = math.max(0, tonumber(s.remaining_cooldown) or 0)
                        local recovery_base_duration = tonumber(s.recovery_base_duration)
                        local recovery_min_duration = math.max(0, tonumber(s.recovery_min_duration) or 0)
                        local shadow_data = {
                            prefab = s.prefab,
                            ready_time = t + remaining_cooldown,
                            is_spawned = false
                        }
                        if recovery_base_duration ~= nil then
                            shadow_data.recovery_start_time = t - math.max(0, tonumber(s.recovery_elapsed) or 0)
                            shadow_data.recovery_base_duration = math.max(0, recovery_base_duration)
                            shadow_data.recovery_min_duration = recovery_min_duration
                        end
                        table.insert(self.shadows, shadow_data)
                        loaded_unique[s.prefab] = true
                    end
                end
            end
        self:RefreshShadowRecoveryForInt()
        self:SyncShadowCount()
        self.inst:DoTaskInTime(0, function()
            self:ReconcileMacanhUnlock()
            self:ReconcileHacanhUnlock()
            local progression = self:GetProgression()
            if progression ~= nil then
                progression:ReconcileOwnedProfiles()
                progression:SyncAll()
            end
        end)
    end
end

function HHShadowManager:CommandFruitFly(x, y, z)
    if type(x) ~= "number" or type(y) ~= "number" or type(z) ~= "number" or
        x ~= x or y ~= y or z ~= z or
        x == math.huge or x == -math.huge or z == math.huge or z == -math.huge then
        return false
    end

    local t = GetTime()
    if t < (self._fruitfly_command_ready_time or 0) then return false end
    local classified = self.inst.player_classified
    local explorer = classified ~= nil and classified.MapExplorer or nil
    if TheWorld.Map == nil or explorer == nil then return false end
    local tx, ty = TheWorld.Map:GetTileXYAtPoint(x, 0, z)
    if not explorer:IsTileSeeable(tx, ty) then
        if self.inst.components.talker then
            self.inst.components.talker:Say("Không thể ra lệnh FruitFly tới khu vực chưa được khám phá!")
        end
        return false
    end

    if not TheWorld.Map:IsPassableAtPoint(x, 0, z, true) then
        if self.inst.components.talker then
            self.inst.components.talker:Say("Không thể ra lệnh FruitFly tới vị trí đó!")
        end
        return false
    end

    for _, shadow_data in ipairs(self.shadows) do
        local shadow = shadow_data.inst
        if shadow_data.prefab == "hh_fruitfly_shadow" and shadow_data.is_spawned and
            shadow ~= nil and shadow:IsValid() and shadow.CommandToPosition ~= nil and
            shadow.components.follower ~= nil and shadow.components.follower:GetLeader() == self.inst then
            if shadow:CommandToPosition(x, 0, z) then
                self._fruitfly_command_ready_time = t + FRUITFLY_COMMAND_RATE_LIMIT
                if self.inst.components.talker then
                    self.inst.components.talker:Say("Đã ra lệnh cho FruitFly di chuyển đến vị trí mới !")
                end
                return true
            end
            return false
        end
    end

    if self.inst.components.talker then
        self.inst.components.talker:Say("Không có Fruitfly đang được triệu hồi!")
    end
    return false
end

function HHShadowManager:Recall(prefab)
    if prefab ~= nil and type(prefab) ~= "string" then
        return false
    end

    local t = GetTime()
    if t < self.recall_ready_time then
        if self.inst.components.talker then
            local remain = math.ceil(self.recall_ready_time - t)
            self.inst.components.talker:Say("Kỹ năng Thu Hồi chưa hồi (" .. remain .. "s)")
        end
        return false
    end

    -- Bấm B là dính cooldown 10s luôn, để chặn spam nút B
    self.recall_cooldown_total = self.recall_cooldown
    self.recall_ready_time = GetTime() + self.recall_cooldown_total
    self:SyncSkillWheelCooldowns()

    local has_spawned = false
    
    for _, s in ipairs(self.shadows) do
        local pending_or_spawned = s.is_spawned or s.is_spawning or s._arise_task ~= nil
        if pending_or_spawned and (prefab == nil or s.prefab == prefab) then
            has_spawned = true
            local shadow = s.inst

            -- Phạt 480s (8 phút) cho nhóm A bị thu hồi
            self:StartShadowRecovery(s, 480, 0)

            -- Hiệu ứng biến mất
            if shadow ~= nil and shadow:IsValid() then
                local fx = SpawnPrefab("statue_transition")
                if fx then fx.Transform:SetPosition(shadow.Transform:GetWorldPosition()) end
                shadow:Remove()
            end

            if prefab ~= nil then break end
        end
    end
    
    if has_spawned then
        -- Hoạt ảnh người chơi thu hồi
        self.inst.AnimState:PlayAnimation("castspell")
        if self.inst.SoundEmitter then
            self.inst.SoundEmitter:PlaySound("dontstarve/common/ghost_spawn")
        end
        if self.inst.components.talker then
            self.inst.components.talker:Say("THU HỒI!")
        end
    else
        if self.inst.components.talker then
            self.inst.components.talker:Say("Không có bóng ma nào đang chiến đấu!")
        end
    end
    
    return true
end

function HHShadowManager:GetOwnedSpawnedFruitFly()
    for _, s in ipairs(self.shadows) do
        local shadow = s.inst
        if s.prefab == "hh_fruitfly_shadow" and s.is_spawned
            and shadow ~= nil and shadow:IsValid() and not shadow:IsInLimbo()
            and shadow.components.follower ~= nil
            and shadow.components.follower:GetLeader() == self.inst then
            return s, shadow
        end
    end
    return nil, nil
end

function HHShadowManager:IsValidSwapDestination(x, z)
    if x == nil or z == nil or TheWorld == nil or TheWorld.Map == nil then
        return false
    end
    if not TheWorld.Map:IsPassableAtPoint(x, 0, z)
        or TheWorld.Map:IsGroundTargetBlocked(Vector3(x, 0, z)) then
        return false
    end
    return IsTeleportPathClear(self.inst, x, z)
end

function HHShadowManager:SwapToFruitFly()
    local now = GetTime()
    if now < self.swap_ready_time then
        if self.inst.components.talker then
            local remain = math.ceil(self.swap_ready_time - now)
            self.inst.components.talker:Say("Kỹ năng Hoán Đổi chưa hồi (" .. remain .. "s)")
        end
        return false
    end
    if self.inst.sg == nil or self.inst.sg:HasStateTag("busy")
        or self.inst.components.health == nil or self.inst.components.health:IsDead()
        or self.inst:HasTag("playerghost")
        or (self.inst.components.rider ~= nil and self.inst.components.rider:IsRiding()) then
        return false
    end

    local shadow_data, shadow = self:GetOwnedSpawnedFruitFly()
    if shadow_data == nil then
        if self.inst.components.talker ~= nil then
            self.inst.components.talker:Say(FRUITFLY_NO_ACTIVE_SWAP_SPEECH)
        end
        return false
    end

    local x, y, z = shadow.Transform:GetWorldPosition()
    if not self:IsValidSwapDestination(x, z) then
        if self.inst.components.talker ~= nil then
            self.inst.components.talker:Say(FRUITFLY_BAD_SWAP_SPEECH)
        end
        return false
    end

    local mana = self.inst.components.hh_mana
    local cost = TUNING.HH_MANA.SWAP_COST or 100
    if mana == nil or not mana:CanSpend(cost, "shadow_swap") then
        if mana ~= nil then
            mana:Spend(cost, "shadow_swap")
        end
        return false
    end

    shadow_data._hh_swap_in_progress = true
    shadow_data._hh_swap_defer_zero_mana_recall = mana:GetCurrent() == mana:GetFinalCost(cost, "shadow_swap")
    if not mana:Spend(cost, "shadow_swap") then
        shadow_data._hh_swap_in_progress = nil
        shadow_data._hh_swap_defer_zero_mana_recall = nil
        return false
    end

    self.swap_cooldown_total = self.swap_cooldown
    self.swap_ready_time = now + self.swap_cooldown_total
    self:SyncSkillWheelCooldowns(now)
    self.inst.sg:GoToState("hh_shadow_swap", {
        shadow_data = shadow_data,
        shadow = shadow,
        destination = Vector3(x, 0, z),
    })
    return true
end

function HHShadowManager:PerformSwapTeleport(data)
    if data == nil or data.teleported or data.shadow_data == nil
        or data.shadow == nil or not data.shadow:IsValid()
        or data.shadow_data.inst ~= data.shadow or not data.shadow_data.is_spawned
        or data.shadow.components.follower == nil
        or data.shadow.components.follower:GetLeader() ~= self.inst
        or data.destination == nil
        or not self:IsValidSwapDestination(data.destination.x, data.destination.z) then
        return false
    end

    local x, y, z = data.destination.x, data.destination.y or 0, data.destination.z
    if self.inst.Physics ~= nil then
        self.inst.Physics:Teleport(x, y, z)
    else
        self.inst.Transform:SetPosition(x, y, z)
    end

    local fx = SpawnPrefab("hh_shadow_swap_grab_fx")
    if fx ~= nil then
        fx.Transform:SetPosition(x, y, z)
    end
    data.teleported = true
    return true
end

function HHShadowManager:FinishSwap(data)
    if data == nil or data.finished then
        return
    end
    data.finished = true

    local s = data.shadow_data
    if s == nil then
        return
    end
    local defer_recall = s._hh_swap_defer_zero_mana_recall
    s._hh_swap_in_progress = nil
    s._hh_swap_defer_zero_mana_recall = nil

    local mana = self.inst.components.hh_mana
    if defer_recall and s.is_spawned and s.inst ~= nil and s.inst:IsValid()
        and (mana == nil or mana:GetCurrent() <= 0) then
        self:RecallFruitFlyForMana(s)
    end
end

return HHShadowManager





