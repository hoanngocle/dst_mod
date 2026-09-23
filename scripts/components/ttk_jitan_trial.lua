local rules = require("ttk_jitan_rules")
local bosses = require("ttk_jitan_bosses")
local adapters = require("ttk_jitan_boss_adapters")
local rewards = require("ttk_jitan_rewards")

local VALID_OUTCOMES = { won = true, lost = true, cancelled = true }
local STATE_IDS = { idle = 0, countdown = 1, active = 2, settling = 3 }

local function Copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, item in pairs(value) do result[Copy(key)] = Copy(item) end
    return result
end

local function NewAltarId(inst)
    if type(inst._ttk_jitan_identity) == "string" and inst._ttk_jitan_identity ~= "" then
        return inst._ttk_jitan_identity
    end
    local meta = TheWorld ~= nil and TheWorld.meta or nil
    local world_key = meta ~= nil and (meta.session_identifier or meta.seed) or "world"
    local nonce = inst._ttk_jitan_identity_nonce or math.random(100000000, 999999999)
    return "altar-" .. tostring(world_key) .. "-" .. tostring(inst.GUID or 0) .. "-" .. tostring(nonce)
end

local TTKJitanTrial = Class(function(self, inst)
    self.inst = inst
    self.state = "idle"
    self.altar_id = NewAltarId(inst)
    self.run_id = nil
    self.run_number = 0
    self.next_run_id = 1
    self.owner_userid = nil
    self.owner = nil
    self.offering_prefab = nil
    self.score = nil
    self.boss_group = nil
    self.reward_chest = nil
    self.outside_ticks = 0
    self.countdown_task = nil
    self.check_task = nil
    self.rng = math.random
    self._pending_payment = nil
    self._paid = false
    self._refunded = false
    self.tracked_entities = {}
    self.boss_id = nil
    self.run_context = nil
    self._finishing = false
    self.reward_backups = {}
    self.recovery_sequence = 1
end)

local function IsLivingPlayer(player)
    return player ~= nil and player.IsValid ~= nil and player:IsValid()
        and type(player.userid) == "string" and player.userid ~= ""
        and (player.HasTag == nil or not player:HasTag("playerghost"))
        and (player.components == nil or player.components.health == nil or not player.components.health:IsDead())
end

function TTKJitanTrial:SetState(state)
    self.state = state
    if self.inst._ttk_trial_state ~= nil then self.inst._ttk_trial_state:set(STATE_IDS[state]) end
    if self.inst._ttk_trial_run ~= nil then self.inst._ttk_trial_run:set(self.run_number) end
end

function TTKJitanTrial:FindOwner()
    if self.owner ~= nil and self.owner.IsValid ~= nil and self.owner:IsValid()
        and self.owner.userid == self.owner_userid then
        return self.owner
    end
    for _, player in ipairs(AllPlayers or {}) do
        if player ~= nil and player.userid == self.owner_userid then
            self.owner = player
            return player
        end
    end
end

function TTKJitanTrial:CanStart(player, item)
    if self.state ~= "idle" then return false, rules.REASONS.BUSY end
    if not IsLivingPlayer(player) then
        local dead = player ~= nil and player.components ~= nil and player.components.health ~= nil
            and player.components.health:IsDead()
        return false, dead and rules.REASONS.DEAD or rules.REASONS.INVALID_PLAYER
    end
    if item == nil or rules.RollScore(item.prefab, function() return 0 end) == nil then
        return false, rules.REASONS.OFFERING
    end
    local valid, reason = rules.ValidateLocation(self.inst, player)
    if not valid then return false, reason end
    local chest = self.inst.FindRewardChest ~= nil and self.inst:FindRewardChest(player) or nil
    if chest == nil or chest.IsValid == nil or not chest:IsValid()
        or (chest.CanUse ~= nil and not chest:CanUse(player)) then
        return false, rules.REASONS.CHEST
    end
    local reward_component = chest.components ~= nil and chest.components.ttk_jitan_rewards or nil
    if reward_component ~= nil then
        if reward_component.SetAuthority ~= nil then reward_component:SetAuthority(self.altar_id, self) end
        self:FlushRewardBackups(chest)
    end
    local context = bosses.BuildContext(self)
    local supported, support_reason = bosses.ValidateOffering(item.prefab, context)
    if not supported then return false, support_reason end
    return true, nil, chest, context
end

function TTKJitanTrial:NewRecoveryRunId()
    local run_id = self.altar_id .. ":recovery-" .. tostring(self.recovery_sequence)
    self.recovery_sequence = self.recovery_sequence + 1
    return run_id
end

function TTKJitanTrial:AdoptRewardBackup(run_id, userid, records)
    if self.inst ~= nil and self.inst.IsValid ~= nil and not self.inst:IsValid() then return false end
    if type(run_id) ~= "string" or type(userid) ~= "string" or type(records) ~= "table" then return false end
    for _, backup in ipairs(self.reward_backups) do
        if backup.run_id == run_id then return true end
    end
    self.reward_backups[#self.reward_backups + 1] = {
        run_id = run_id, userid = userid, records = Copy(records),
    }
    return true
end

function TTKJitanTrial:FlushRewardBackups(chest)
    local component = chest ~= nil and chest.components ~= nil and chest.components.ttk_jitan_rewards or nil
    if component == nil then return 0 end
    if component.SetAuthority ~= nil then component:SetAuthority(self.altar_id, self) end
    local delivered, index = 0, 1
    while index <= #self.reward_backups do
        local backup = self.reward_backups[index]
        if component:Queue(backup.run_id, backup.userid, backup.records) then
            table.remove(self.reward_backups, index)
            delivered = delivered + 1
        else
            index = index + 1
        end
    end
    return delivered
end

function TTKJitanTrial:CanAcceptTrade(player, item, count)
    if (count or 1) ~= 1 then return false, rules.REASONS.COUNT end
    local valid, reason, chest, context = self:CanStart(player, item)
    if not valid then return false, reason end
    self._pending_payment = { userid = player.userid, prefab = item.prefab, chest = chest, context = context }
    return true
end

function TTKJitanTrial:RefundOffering(player, prefab)
    if self._refunded or not self._paid or prefab == nil then return false end
    self._refunded = true
    local item = SpawnPrefab(prefab)
    if item == nil then return false end
    if player ~= nil and player.components ~= nil and player.components.inventory ~= nil then
        player.components.inventory:GiveItem(item)
    elseif item.Transform ~= nil and self.inst.Transform ~= nil then
        item.Transform:SetPosition(self.inst.Transform:GetWorldPosition())
    end
    return true
end

function TTKJitanTrial:OnOfferingAccepted(player, item, count)
    local pending = self._pending_payment
    self._pending_payment = nil
    local prefab = item ~= nil and item.prefab or nil
    if pending == nil or player == nil or pending.userid ~= player.userid
        or pending.prefab ~= prefab or (count or 1) ~= 1 then
        return false
    end
    self._refunded = false
    self._paid = true
    local ok = self:Start(player, prefab, pending.chest, pending.context)
    if not ok then self:RefundOffering(player, prefab) end
    return ok
end

function TTKJitanTrial:Start(player, offering_prefab, validated_chest, validated_context)
    local valid, reason, chest, context = self:CanStart(player, { prefab = offering_prefab })
    if not valid then return false, reason end
    self.run_number = self.next_run_id
    self.next_run_id = self.next_run_id + 1
    self.run_id = self.altar_id .. ":" .. tostring(self.run_number)
    self.owner_userid = player.userid
    self.owner = player
    self.offering_prefab = offering_prefab
    self.score = rules.RollScore(offering_prefab, self.rng)
    self.boss_group = rules.RollGroup(self.score, self.rng)
    self.reward_chest = validated_chest or chest
    self.run_context = validated_context or context
    self.outside_ticks = 0
    self._refunded = false
    self._paid = true
    self.inst:AddTag("ttk_jitan_active")
    self:SetState("countdown")
    local run_id = self.run_id
    self.countdown_remaining = 5
    self.countdown_task = self.inst:DoPeriodicTask(1, function() self:TickCountdown(run_id) end)
    self.inst:PushEvent("ttk_jitan_started", { run_id = run_id, userid = self.owner_userid, score = self.score })
    return true
end

function TTKJitanTrial:TickCountdown(run_id)
    if self.state ~= "countdown" or run_id ~= self.run_id then return false end
    local owner = self:FindOwner()
    if not IsLivingPlayer(owner) or owner:GetDistanceSqToInst(self.inst) > 32 * 32 then
        return self:Finish(run_id, "cancelled", "countdown_owner_invalid")
    end
    self.countdown_remaining = self.countdown_remaining - 1
    if self.countdown_remaining <= 0 then
        if self.countdown_task ~= nil then self.countdown_task:Cancel(); self.countdown_task = nil end
        return self:BeginActive(run_id)
    end
    return true
end

function TTKJitanTrial:BeginActive(run_id)
    if self.state ~= "countdown" or run_id ~= self.run_id then return false end
    local owner = self:FindOwner()
    if not IsLivingPlayer(owner) or owner:GetDistanceSqToInst(self.inst) > 32 * 32 then
        return self:Finish(run_id, "cancelled", "countdown_owner_invalid")
    end
    self:SetState("active")
    -- Revalidate after the five-second countdown: a season transition or
    -- newly blocked arena must not use the stale prepayment snapshot.
    self.run_context = bosses.BuildContext(self)
    local choose_error
    self.boss_id, choose_error = bosses.Choose(self.boss_group, self.rng, self.run_context)
    if self.boss_id == nil then
        self:Finish(run_id, "cancelled", "spawn_failed")
        return false, choose_error
    end
    local entities, error_message = bosses.Spawn(self, self.boss_id)
    if entities == nil then
        self:Finish(run_id, "cancelled", "spawn_failed")
        return false, error_message
    end
    self.check_task = self.inst:DoPeriodicTask(1, function() self:TickActive(run_id) end)
    self.inst:PushEvent("ttk_jitan_active", { run_id = run_id, boss_id = self.boss_id, entities = entities })
    return true
end

function TTKJitanTrial:ReplaceRequired(old_entity, new_entity)
    if self.state ~= "active" or old_entity == nil or new_entity == nil then return false end
    local record = self.tracked_entities[old_entity]
    if record == nil or not record.required then return false end
    record.required = false
    record.defeated = true
    return self:TrackEntity(self.run_id, new_entity, true, { skip_adapter = true })
end

function TTKJitanTrial:TrackEntity(run_id, entity, required, opts)
    if self.state ~= "active" or run_id ~= self.run_id or entity == nil
        or entity.IsValid == nil or not entity:IsValid() then return false end
    local existing = self.tracked_entities[entity]
    if existing ~= nil then
        if required ~= false then existing.required = true end
        return true
    end
    entity._ttk_jitan_run_id = run_id
    if opts == nil or not opts.defer_nonpersistent then entity.persists = false end
    entity:AddTag("ttk_jitan_boss")
    self.tracked_entities[entity] = { required = required ~= false, defeated = false }
    if opts == nil or not opts.skip_adapter then adapters.Attach(entity, self, run_id) end
    return true
end

function TTKJitanTrial:MarkBossDefeated(run_id, entity)
    if self.state ~= "active" or run_id ~= self.run_id or entity == nil
        or entity._ttk_jitan_run_id ~= run_id then return false end
    local record = self.tracked_entities[entity]
    if record == nil or record.defeated then return false end
    record.defeated = true
    local has_required, remaining = false, 0
    for _, tracked in pairs(self.tracked_entities) do
        if tracked.required then
            has_required = true
            if not tracked.defeated then remaining = remaining + 1 end
        end
    end
    if has_required and remaining == 0 then self:Finish(run_id, "won", "bosses_defeated") end
    return true
end

function TTKJitanTrial:CaptureOwnedEntities(run_id)
    local snapshot = {}
    for entity in pairs(self.tracked_entities) do snapshot[#snapshot + 1] = entity end
    for _, entity in ipairs(snapshot) do
        adapters.CaptureOwned(entity, self, run_id)
        if type(bosses.CaptureOwned) == "function" then
            bosses.CaptureOwned(entity, self.boss_id, self, run_id)
        end
    end
end

function TTKJitanTrial:CleanupEntities(run_id, already_captured)
    if not already_captured then self:CaptureOwnedEntities(run_id) end
    for entity, _ in pairs(self.tracked_entities) do
        if entity ~= nil and entity._ttk_jitan_run_id == run_id
            and entity.IsValid ~= nil and entity:IsValid() then
            entity:Remove()
        end
    end
    self.tracked_entities = {}
end

function TTKJitanTrial:CleanupAuxiliaries(run_id, already_captured)
    if not already_captured then self:CaptureOwnedEntities(run_id) end
    for entity, record in pairs(self.tracked_entities) do
        if not record.required and not entity._ttk_jitan_preserve_on_win then
            if entity ~= nil and entity._ttk_jitan_run_id == run_id
                and entity.IsValid ~= nil and entity:IsValid() then
                entity:Remove()
            end
            self.tracked_entities[entity] = nil
        end
    end
end

function TTKJitanTrial:TickActive(run_id)
    if self.state ~= "active" or run_id ~= self.run_id then return false end
    self:CaptureOwnedEntities(run_id)
    for entity, record in pairs(self.tracked_entities) do
        if record.required and not record.defeated
            and (entity == nil or entity.IsValid == nil or not entity:IsValid()) then
            return self:Finish(run_id, "lost", "boss_removed")
        end
    end
    local owner = self:FindOwner()
    if owner == nil or owner.IsValid == nil or not owner:IsValid() then
        return self:Finish(run_id, "lost", "owner_left")
    end
    if owner.HasTag ~= nil and owner:HasTag("playerghost")
        or owner.components ~= nil and owner.components.health ~= nil and owner.components.health:IsDead() then
        return self:Finish(run_id, "lost", "owner_dead")
    end
    if owner:GetDistanceSqToInst(self.inst) > 60 * 60 then
        self.outside_ticks = self.outside_ticks + 1
        if self.outside_ticks >= 11 then return self:Finish(run_id, "lost", "out_of_range") end
    end
    return true
end

function TTKJitanTrial:CancelTasks()
    for _, key in ipairs({ "countdown_task", "check_task" }) do
        local task = self[key]
        if task ~= nil then task:Cancel(); self[key] = nil end
    end
end

function TTKJitanTrial:Finish(run_id, outcome, reason)
    if self._finishing or run_id ~= self.run_id or self.state == "idle" or self.state == "settling"
        or not VALID_OUTCOMES[outcome] then return false end
    self._finishing = true
    -- Capture helpers while TrackEntity still accepts them, then enter the
    -- terminal state before Remove/Queue/health callbacks can re-enter Finish.
    self:CaptureOwnedEntities(run_id)
    self:SetState("settling")
    self:CancelTasks()
    if outcome == "won" then self:CleanupAuxiliaries(run_id, true) else self:CleanupEntities(run_id, true) end
    local owner = self:FindOwner()
    if outcome == "won" then
        local chest = self.reward_chest
        local component = chest ~= nil and chest.IsValid ~= nil and chest:IsValid()
            and chest.components ~= nil and chest.components.ttk_jitan_rewards or nil
        local records = rewards.Roll(self.score, self.rng, self.boss_id)
        if component ~= nil and component.SetAuthority ~= nil then component:SetAuthority(self.altar_id, self) end
        if component == nil or not component:Queue(run_id, self.owner_userid, records) then
            self:AdoptRewardBackup(run_id, self.owner_userid, records)
        end
    elseif outcome == "lost" and reason == "out_of_range" and IsLivingPlayer(owner)
        and owner.components ~= nil and owner.components.health ~= nil then
        owner.components.health:DoDelta(-owner.components.health.maxhealth * 0.4, false, "ttk_jitan_out_of_range")
    elseif outcome == "cancelled" and reason == "spawn_failed" then
        self:RefundOffering(owner, self.offering_prefab)
    end
    self.inst:PushEvent("ttk_jitan_finished", {
        run_id = run_id, userid = self.owner_userid, outcome = outcome, reason = reason,
        score = self.score, boss_group = self.boss_group, reward_chest = self.reward_chest,
    })
    self.inst:RemoveTag("ttk_jitan_active")
    self.owner = nil
    self.owner_userid = nil
    self.offering_prefab = nil
    self.score = nil
    self.boss_group = nil
    self.boss_id = nil
    self.reward_chest = nil
    self.run_context = nil
    self.outside_ticks = 0
    self._paid = false
    self.tracked_entities = {}
    self:SetState("idle")
    self._finishing = false
    return true
end

function TTKJitanTrial:OnSave()
    return {
        altar_id = self.altar_id,
        run_id = self.run_id,
        run_number = self.run_number,
        next_run_id = self.next_run_id,
        state = self.state,
        paid = self._paid,
        reward_backups = Copy(self.reward_backups),
        recovery_sequence = self.recovery_sequence,
    }
end

function TTKJitanTrial:OnLoad(data)
    data = data or {}
    if type(data.altar_id) == "string" and data.altar_id ~= "" then self.altar_id = data.altar_id end
    local previous = tonumber(data.run_number) or tonumber(data.run_id)
        or tonumber(type(data.run_id) == "string" and string.match(data.run_id, ":(%d+)$")) or 0
    self.run_number = previous
    self.run_id = type(data.run_id) == "string" and data.run_id
        or (previous > 0 and self.altar_id .. ":" .. tostring(previous) or nil)
    self.next_run_id = math.max(tonumber(data.next_run_id) or 1, previous + 1)
    self.reward_backups = type(data.reward_backups) == "table" and Copy(data.reward_backups) or {}
    self.recovery_sequence = math.max(tonumber(data.recovery_sequence) or 1, 1)
    self._paid = false
    self._refunded = false
    self.tracked_entities = {}
    self.inst:RemoveTag("ttk_jitan_active")
    self:SetState("idle")
end

function TTKJitanTrial:OnRemoveFromEntity()
    self:CancelTasks()
    if self.run_id ~= nil and next(self.tracked_entities) ~= nil then self:CleanupEntities(self.run_id) end
    self.inst:RemoveTag("ttk_jitan_active")
end

return TTKJitanTrial
