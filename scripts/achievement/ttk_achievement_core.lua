local AchievementCatalog = require("achievement/ttk_achievement_catalog")
local PerkCatalog = require("achievement/ttk_perk_catalog")
local SeasonalCatalog = require("achievement/ttk_seasonal_catalog")
local Rewards = require("achievement/ttk_seasonal_rewards")

local Core = {}
Core.__index = Core

local MAX_REPLAYS = 64
local MAX_REQUEST_ID = 96

local function IsFinite(value)
    return type(value) == "number" and value == value
        and value ~= math.huge and value ~= -math.huge
end

local function IsFiniteInteger(value)
    return IsFinite(value) and value == math.floor(value)
end

local function IsValidRequestId(request_id)
    return type(request_id) == "string" and #request_id > 0 and #request_id <= MAX_REQUEST_ID
end

local function Copy(value)
    if type(value) ~= "table" then return value end
    local copied = {}
    for key, child in pairs(value) do copied[key] = Copy(child) end
    return copied
end

local function NewResult(ok, code, extra)
    local result = { ok = ok == true, code = code }
    for key, value in pairs(extra or {}) do result[key] = value end
    return result
end

local function CanonicalPrefabs(definition, saved)
    local seen, count = {}, 0
    for _, prefab in ipairs(definition.params.prefabs) do
        if type(saved) == "table" and saved[prefab] == true and not seen[prefab] then
            seen[prefab], count = true, count + 1
        end
    end
    return seen, math.min(definition.target, count)
end

local function IsAllowedPrefab(definition, evidence)
    if type(evidence) ~= "string" then return false end
    for _, prefab in ipairs(definition.params.prefabs) do
        if evidence == prefab then return true end
    end
    return false
end

-- These former one-kill aliases now have explicit repeat conditions. Preserve
-- their already-claimed saves without granting the new target to unclaimed rows.
local LEGACY_SINGLE_KILL_CLAIMS = {
    combat_mactusk=true, boss_fuelweaver=true, boss_ttk_boss_ziyunshadow=true,
}

local function CanonicalAchievement(definition, saved)
    local progress = type(saved) == "table" and saved.progress or 0
    if not IsFinite(progress) or progress < 0 then progress = 0 end
    progress = math.min(definition.target, progress)
    local state = { progress = progress, status = "locked", claimed_reward = nil }
    if definition.distinct == "prefab" then
        state.seen_prefabs, progress = CanonicalPrefabs(definition,
            type(saved) == "table" and saved.seen_prefabs or nil)
        state.progress = progress
    end
    local status = type(saved) == "table" and saved.status or nil
    if status == "claimed" and LEGACY_SINGLE_KILL_CLAIMS[definition.id] and progress >= 1 then
        progress = definition.target
        state.progress = progress
    end
    if progress >= definition.target then
        state.status = status == "claimed" and "claimed" or "completed_unclaimed"
        if state.status == "claimed" then
            local reward = saved.claimed_reward
            state.claimed_reward = IsFiniteInteger(reward) and reward >= 0 and reward or definition.reward
        end
    end
    return state
end

function Core.New(inst, apply_effect)
    local self = setmetatable({}, Core)
    self.inst = inst
    self.apply_effect = apply_effect
    self.achievements = {}
    self.levels = {}
    self.unlocked = {}
    self.earned = 0
    self.spent = 0
    self.replays = {}
    self.replay_order = {}
    self.seasonal = nil
    self.seasonal_replays = {}
    self.seasonal_replay_order = {}
    self.seasonal_pending = {}
    self.seasonal_busy = false
    self.seasonal_xp = nil
    return self
end

local function IsServer()
    return TheWorld ~= nil and TheWorld.ismastersim == true
end

local function SlotStatus(slot, definition)
    return slot.claims >= definition.max_claims and "claimed"
        or slot.progress >= definition.target and "ready_to_claim" or "active"
end

function Core:SetSeasonalXPCallback(callback)
    self.seasonal_xp = type(callback) == "function" and callback or nil
end

function Core:SetSeasonalClaimCallback(callback)
    self.seasonal_claimed = type(callback) == "function" and callback or nil
end

local SettleSeason

function Core:StartSeason(season, epoch, random)
    if not IsServer() then return false, NewResult(false, "not_server") end
    if not SeasonalCatalog.IsSeason(season) or not IsValidRequestId(epoch)
        or TheWorld.state == nil or TheWorld.state.season ~= season then
        return false, NewResult(false, "invalid_season")
    end
    if self.seasonal_busy then return false, NewResult(false, "pending") end
    if self.seasonal ~= nil and self.seasonal.season == season and self.seasonal.epoch == epoch
        and not self.seasonal.rollover_pending then
        return true, Copy(self.seasonal)
    end
    if self.seasonal ~= nil then
        -- Retain the outgoing pool as the durable settlement record. Committed
        -- slot/chest receipts survive retries; no new draw can erase unpaid work.
        self.seasonal.rollover_pending = true
        local ok, result = SettleSeason(self)
        if not ok then return false, result end
    end
    self.seasonal = {version=2, season=season, epoch=epoch, slots=SeasonalCatalog.Draw(season, random), first_claims=0, chest_claimed={}}
    return true, Copy(self.seasonal)
end

function Core:ActiveSeason(season)
    return IsServer() and self.seasonal ~= nil and self.seasonal.season == season
        and not self.seasonal.rollover_pending
        and TheWorld.state ~= nil and TheWorld.state.season == season
end

function Core:FindSeasonalSlot(id)
    if self.seasonal == nil or type(id) ~= "string" then return nil end
    for _, slot in ipairs(self.seasonal.slots) do
        if slot.task_id == id then return slot end
    end
end

-- Only the server's successful-action adapter calls this method. It supplies
-- normalized evidence; no RPC may supply progress or arbitrary event payloads.
function Core:AdvanceSeasonal(id, amount, evidence)
    local definition = SeasonalCatalog.ById(id)
    if definition == nil or not self:ActiveSeason(definition.season) then
        return false, NewResult(false, "inactive_task")
    end
    if self.seasonal_busy then return false, NewResult(false, "pending") end
    if not IsFiniteInteger(amount) or amount <= 0 then return false, NewResult(false, "invalid_amount") end
    local slot = self:FindSeasonalSlot(id)
    if slot == nil or SlotStatus(slot, definition) ~= "active" then return false, NewResult(false, "task_closed") end
    if type(evidence) ~= "table" or evidence.event ~= definition.event then return false, NewResult(false, "invalid_evidence") end
    for key, value in pairs(definition.params) do
        if evidence[key] ~= value then return false, NewResult(false, "invalid_evidence") end
    end
    slot.progress = math.min(definition.target, slot.progress + amount)
    return true, NewResult(true, SlotStatus(slot, definition), {id=id, progress=slot.progress})
end

function Core:StoreSeasonalReplay(request_id, result)
    if self.seasonal_replays[request_id] == nil then
        self.seasonal_replay_order[#self.seasonal_replay_order + 1] = request_id
    end
    self.seasonal_replays[request_id] = Copy(result)
    while #self.seasonal_replay_order > MAX_REPLAYS do
        self.seasonal_replays[table.remove(self.seasonal_replay_order, 1)] = nil
    end
end

local function CommitSeasonal(self, definition, slot, request_id)
    if self.seasonal_xp == nil then return false, NewResult(false, "xp_unavailable") end
    local id, state = definition.id, self.seasonal
    local number = slot.claims + 1
    local claim_key = state.epoch .. ":" .. id .. ":" .. tostring(number)
    self.seasonal_busy = true
    -- The progression adapter owns XP tuning and idempotency for claim_key.
    -- Retrying after an adapter exception uses this same key, never a new award.
    local called, awarded = pcall(self.seasonal_xp, self.inst, id, definition.kind, number, claim_key, state)
    if not called or awarded ~= true then
        self.seasonal_busy = false
        return false, NewResult(false, "xp_failed")
    end
    if slot.claims == 0 then state.first_claims = state.first_claims + 1 end
    slot.claims, slot.progress = number, 0
    slot.xp_receipt = nil
    local result = NewResult(true, "seasonal_claimed", {
        id=id, season=definition.season, epoch=state.epoch, claims=number,
        first_claims=state.first_claims, claim_key=claim_key,
    })
    if request_id ~= nil then self:StoreSeasonalReplay(request_id, result) end
    -- Both manual and rollover claims cross this boundary exactly once. The
    -- saved slot.claims is the durable receipt for epoch:task:claim_number;
    -- replay lookups and already committed slots never invoke the callback.
    if self.seasonal_claimed ~= nil then self.seasonal_claimed(self.inst, Copy(result), state) end
    self.seasonal_busy = false
    return true, Copy(result)
end

function Core:ClaimSeasonal(id, request_id)
    if not IsServer() then return false, NewResult(false, "not_server") end
    if not IsValidRequestId(request_id) then return false, NewResult(false, "invalid_request") end
    local replay = self.seasonal_replays[request_id]
    if replay ~= nil then return replay.ok, Copy(replay) end
    if self.seasonal_busy or self.seasonal_pending[request_id] then return false, NewResult(false, "pending") end
    local definition = SeasonalCatalog.ById(id)
    if definition == nil or not self:ActiveSeason(definition.season) then return false, NewResult(false, "inactive_task") end
    local slot = self:FindSeasonalSlot(id)
    if slot == nil or SlotStatus(slot, definition) ~= "ready_to_claim" then return false, NewResult(false, "not_claimable") end
    return CommitSeasonal(self, definition, slot, request_id)
end

local function CommitChest(self, player, season, milestone, bundle, request_id)
    local state = self.seasonal
    if state.chest_claimed[milestone] or state.first_claims < milestone then
        return false, NewResult(false, "not_claimable")
    end
    local plan, error_code = Rewards.Preflight(player, season, milestone, bundle)
    if plan == nil then return false, NewResult(false, error_code) end
    self.seasonal_busy = true
    local staged
    staged, error_code = Rewards.Stage(bundle, plan)
    if staged == nil then
        self.seasonal_busy = false
        return false, NewResult(false, error_code)
    end
    plan = Rewards.PlanDelivery(plan, staged)
    local result = NewResult(true, "chest_claimed", {season=season, epoch=state.epoch, milestone=milestone, bundle=bundle})
    -- Commit before the first inventory callback. Reentrant requests return this
    -- exact result, and a different request cannot pay the same chest again.
    state.chest_claimed[milestone] = true
    if request_id ~= nil then self:StoreSeasonalReplay(request_id, result) end
    Rewards.Deliver(plan, staged)
    self.seasonal_busy = false
    return true, Copy(result)
end

function Core:ClaimChest(player, season, milestone, request_id)
    if not IsServer() or player ~= self.inst then return false, NewResult(false, "not_server") end
    if not IsValidRequestId(request_id) then return false, NewResult(false, "invalid_request") end
    local replay = self.seasonal_replays[request_id]
    if replay ~= nil then return replay.ok, Copy(replay) end
    if self.seasonal_busy or self.seasonal_pending[request_id] then return false, NewResult(false, "pending") end
    local bundle = Rewards.GetBundle(season, milestone)
    if bundle == nil then return false, NewResult(false, "invalid_chest") end
    if not self:ActiveSeason(season) then return false, NewResult(false, "inactive_season") end
    return CommitChest(self, player, season, milestone, bundle, request_id)
end

SettleSeason = function(self)
    local state, failure = self.seasonal, nil
    for _, slot in ipairs(state.slots) do
        local definition = SeasonalCatalog.ById(slot.task_id)
        if SlotStatus(slot, definition) == "ready_to_claim" then
            local ok, result = CommitSeasonal(self, definition, slot)
            if not ok then failure = failure or result end
        end
    end
    -- First claims above may unlock another milestone. Resolve every eligible
    -- outgoing chest through the same atomic transaction as a manual claim.
    for _, milestone in ipairs({5, 10, 15, 20}) do
        if state.first_claims >= milestone and not state.chest_claimed[milestone] then
            local ok, result = CommitChest(self, self.inst, state.season, milestone,
                Rewards.GetBundle(state.season, milestone))
            if not ok then failure = failure or result end
        end
    end
    return failure == nil, failure
end

function Core:LoadSeasonal(saved, requests)
    self.seasonal, self.seasonal_replays, self.seasonal_replay_order = nil, {}, {}
    self.seasonal_pending, self.seasonal_busy = {}, false
    if type(saved) == "table" and SeasonalCatalog.IsSeason(saved.season) and IsValidRequestId(saved.epoch)
        and type(saved.slots) == "table" then
        local slots, seen, counts, valid, first_claims = {}, {}, {once=0, repeatable=0}, true, 0
        for key in pairs(saved.slots) do
            if not IsFiniteInteger(key) or key < 1 or key > 20 then valid = false end
        end
        for index = 1, 20 do
            local raw = saved.slots[index]
            local definition = type(raw) == "table" and SeasonalCatalog.ById(raw.task_id) or nil
            if definition == nil or definition.season ~= saved.season or seen[definition.id] then
                valid = false
                break
            end
            seen[definition.id] = true
            local kind = definition.kind == "once" and "once" or "repeatable"
            counts[kind] = counts[kind] + 1
            local claims, progress = raw.claims, raw.progress
            if not IsFiniteInteger(claims) or claims < 0 or claims > definition.max_claims then claims = 0 end
            if not IsFiniteInteger(progress) or progress < 0 then progress = 0 end
            progress = claims == definition.max_claims and 0 or math.min(progress, definition.target)
            slots[index] = {task_id=definition.id, progress=progress, claims=claims}
            if progress >= definition.target and claims < definition.max_claims
                and (raw.xp_receipt == "pending" or raw.xp_receipt == "awarded") then
                slots[index].xp_receipt = raw.xp_receipt
            end
            if claims > 0 then first_claims = first_claims + 1 end
        end
        if valid and counts.once == 16 and counts.repeatable == 4 then
            local chest_claimed = {}
            local raw_chests = type(saved.chest_claimed) == "table" and saved.chest_claimed or {}
            for _, milestone in ipairs({5, 10, 15, 20}) do
                if raw_chests[milestone] == true and first_claims >= milestone then chest_claimed[milestone] = true end
            end
            self.seasonal = {version=2, season=saved.season, epoch=saved.epoch, slots=slots, first_claims=first_claims, chest_claimed=chest_claimed}
            if saved.rollover_pending == true then self.seasonal.rollover_pending = true end
        end
    end
    -- Keep only small canonical success records. Saved client payloads, arbitrary
    -- item tables, pending reservations and false results never become authority.
    for _, entry in ipairs(type(requests) == "table" and requests or {}) do
        local raw = type(entry) == "table" and entry.result or nil
        if type(entry) == "table" and IsValidRequestId(entry.id) and type(raw) == "table"
            and raw.ok == true and SeasonalCatalog.IsSeason(raw.season) and IsValidRequestId(raw.epoch) then
            local result = nil
            local current = self.seasonal ~= nil and self.seasonal.epoch == raw.epoch and self.seasonal.season == raw.season
            if raw.code == "chest_claimed" then
                local bundle = Rewards.GetBundle(raw.season, raw.milestone)
                if bundle ~= nil and (not current or self.seasonal.chest_claimed[raw.milestone]) then
                    result = NewResult(true, "chest_claimed", {season=raw.season, epoch=raw.epoch, milestone=raw.milestone, bundle=bundle})
                end
            elseif raw.code == "seasonal_claimed" then
                local definition = SeasonalCatalog.ById(raw.id)
                local slot = current and self:FindSeasonalSlot(raw.id) or nil
                if definition ~= nil and definition.season == raw.season and IsFiniteInteger(raw.claims)
                    and raw.claims >= 1 and raw.claims <= definition.max_claims and IsFiniteInteger(raw.first_claims)
                    and raw.first_claims >= 1 and raw.first_claims <= 20
                    and (not current or slot ~= nil and slot.claims >= raw.claims and self.seasonal.first_claims >= raw.first_claims) then
                    result = NewResult(true, "seasonal_claimed", {id=raw.id, season=raw.season, epoch=raw.epoch,
                        claims=raw.claims, first_claims=raw.first_claims, claim_key=raw.epoch .. ":" .. raw.id .. ":" .. tostring(raw.claims)})
                end
            end
            if result ~= nil then self:StoreSeasonalReplay(entry.id, result) end
        end
    end
end

function Core:GetReplay(request_id)
    return self.replays[request_id] and Copy(self.replays[request_id]) or nil
end

function Core:StoreReplay(request_id, result)
    if not IsValidRequestId(request_id) then return end
    if self.replays[request_id] == nil then table.insert(self.replay_order, request_id) end
    self.replays[request_id] = Copy(result)
    while #self.replay_order > MAX_REPLAYS do
        local dropped = table.remove(self.replay_order, 1)
        self.replays[dropped] = nil
    end
end

function Core:Balance()
    return math.max(0, self.earned - self.spent)
end

function Core:EnsureAchievement(definition)
    local state = self.achievements[definition.id]
    if state == nil then
        state = { progress = 0, status = "locked", claimed_reward = nil }
        self.achievements[definition.id] = state
    end
    return state
end

function Core:Advance(id, amount, evidence)
    local definition = AchievementCatalog.ById(id)
    if definition == nil or definition.status ~= "active" or definition.visibility ~= "visible" then
        return false, NewResult(false, "unknown_achievement")
    end
    if not IsFinite(amount) or amount <= 0 then
        return false, NewResult(false, "invalid_amount")
    end
    if definition.distinct == "prefab" and not IsAllowedPrefab(definition, evidence) then
        return false, NewResult(false, "invalid_evidence")
    end
    local state = self:EnsureAchievement(definition)
    if state.status == "claimed" then return false, NewResult(false, "already_claimed") end
    if definition.distinct == "prefab" then
        state.seen_prefabs = CanonicalPrefabs(definition, state.seen_prefabs)
        state.seen_prefabs[evidence] = true
        state.seen_prefabs, state.progress = CanonicalPrefabs(definition, state.seen_prefabs)
    else
        state.progress = math.min(definition.target, state.progress + amount)
    end
    if state.progress >= definition.target then state.status = "completed_unclaimed" end
    return true, NewResult(true, state.status, { id = id, progress = state.progress })
end

function Core:ClaimAchievement(id, request_id)
    if not IsValidRequestId(request_id) then return false, NewResult(false, "invalid_request") end
    local replay = self:GetReplay(request_id)
    if replay ~= nil then return replay.ok, replay end
    local definition = AchievementCatalog.ById(id)
    if definition == nil or definition.status ~= "active" or definition.visibility ~= "visible" then
        local result = NewResult(false, "unknown_achievement")
        self:StoreReplay(request_id, result)
        return false, result
    end
    local state = self:EnsureAchievement(definition)
    if state.status ~= "completed_unclaimed" then
        local result = NewResult(false, "not_claimable")
        self:StoreReplay(request_id, result)
        return false, result
    end
    state.status = "claimed"
    state.claimed_reward = definition.reward
    self.earned = self.earned + definition.reward
    local result = NewResult(true, "claimed", { id = id, reward = definition.reward, earned = self.earned })
    self:StoreReplay(request_id, result)
    return true, result
end

function Core:Capture()
    return {
        achievements = Copy(self.achievements), levels = Copy(self.levels), unlocked = Copy(self.unlocked),
        earned = self.earned, spent = self.spent, replays = Copy(self.replays), replay_order = Copy(self.replay_order),
    }
end

function Core:Restore(snapshot)
    self.achievements = Copy(snapshot.achievements)
    self.levels = Copy(snapshot.levels)
    self.unlocked = Copy(snapshot.unlocked)
    self.earned = snapshot.earned
    self.spent = snapshot.spent
    self.replays = Copy(snapshot.replays)
    self.replay_order = Copy(snapshot.replay_order)
end

function Core:Apply(perk, level, mode)
    if self.apply_effect == nil then return true end
    local called, applied = pcall(self.apply_effect, self.inst, perk, level, mode)
    return called and applied ~= false
end

function Core:PurchasePerk(id, request_id)
    if not IsValidRequestId(request_id) then return false, NewResult(false, "invalid_request") end
    local replay = self:GetReplay(request_id)
    if replay ~= nil then return replay.ok, replay end
    local perk = PerkCatalog.ById(id)
    if perk == nil then
        local result = NewResult(false, "unknown_perk")
        self:StoreReplay(request_id, result)
        return false, result
    end
    local current_level = self.levels[id] or 0
    if perk.max_level ~= nil and current_level >= perk.max_level then
        local result = NewResult(false, "max_level")
        self:StoreReplay(request_id, result)
        return false, result
    end
    if perk.max_level == nil and self.unlocked[id] then
        local result = NewResult(false, "already_unlocked")
        self:StoreReplay(request_id, result)
        return false, result
    end
    local next_level = perk.max_level ~= nil and current_level + 1 or 1
    local price = PerkCatalog.NextPrice(perk, current_level)
    if price == nil or self:Balance() < price then
        local result = NewResult(false, "insufficient_stars")
        self:StoreReplay(request_id, result)
        return false, result
    end
    local before = self:Capture()
    if not self:Apply(perk, next_level, "purchase") then
        self:Restore(before)
        return false, NewResult(false, "apply_failed")
    end
    if perk.max_level ~= nil then self.levels[id] = next_level else self.unlocked[id] = true end
    self.spent = self.spent + price
    local result = NewResult(true, "purchased", { id = id, level = next_level, price = price, spent = self.spent })
    self:StoreReplay(request_id, result)
    return true, result
end

function Core:ReapplyPurchased()
    local applied = true
    for _, perk in ipairs(PerkCatalog.All()) do
        local level = perk.max_level ~= nil and (self.levels[perk.id] or 0) or (self.unlocked[perk.id] and 1 or 0)
        if level > 0 and not self:Apply(perk, level, "reapply") then applied = false end
    end
    return applied
end

function Core:CanonicalizePerks(saved)
    self.levels, self.unlocked, self.spent = {}, {}, 0
    saved = type(saved) == "table" and saved or {}
    local saved_levels = type(saved.levels) == "table" and saved.levels or {}
    local saved_unlocked = type(saved.unlocked) == "table" and saved.unlocked or {}
    for _, perk in ipairs(PerkCatalog.All()) do
        if perk.max_level ~= nil then
            local level = saved_levels[perk.id]
            if not IsFiniteInteger(level) or level < 0 then level = 0 end
            level = math.min(level, perk.max_level)
            for purchased = 1, level do
                local price = PerkCatalog.PriceForLevel(purchased)
                if self.earned - self.spent < price then break end
                self.levels[perk.id] = purchased
                self.spent = self.spent + price
            end
        elseif saved_unlocked[perk.id] == true and self.earned - self.spent >= perk.price then
            self.unlocked[perk.id] = true
            self.spent = self.spent + perk.price
        end
    end
end

function Core:Load(data)
    local state = type(data) == "table" and data or {}
    self:LoadSeasonal(state.seasonal, state.seasonal_requests)
    self.achievements, self.replays, self.replay_order = {}, {}, {}
    local saved_achievements = type(state.achievements) == "table" and state.achievements or {}
    self.earned = 0
    for _, definition in ipairs(AchievementCatalog.All()) do
        local achievement = CanonicalAchievement(definition, saved_achievements[definition.id])
        if achievement.progress > 0 or achievement.status ~= "locked" then self.achievements[definition.id] = achievement end
        if achievement.status == "claimed" then self.earned = self.earned + achievement.claimed_reward end
    end
    self:CanonicalizePerks(state.perks)
    local saved_replays = type(state.replays) == "table" and state.replays or {}
    for _, entry in ipairs(saved_replays) do
        if type(entry) == "table" and IsValidRequestId(entry.id) and type(entry.result) == "table"
            and type(entry.result.ok) == "boolean" and type(entry.result.code) == "string" then
            self:StoreReplay(entry.id, entry.result)
        end
    end
    self:ReapplyPurchased()
end

function Core:GetSaveData()
    local replays = {}
    for _, request_id in ipairs(self.replay_order) do
        table.insert(replays, { id = request_id, result = Copy(self.replays[request_id]) })
    end
    local seasonal_requests = {}
    for _, request_id in ipairs(self.seasonal_replay_order) do
        seasonal_requests[#seasonal_requests + 1] = {id=request_id, result=Copy(self.seasonal_replays[request_id])}
    end
    return {
        version = 1, achievements = Copy(self.achievements),
        perks = { levels = Copy(self.levels), unlocked = Copy(self.unlocked) }, replays = replays,
        seasonal = Copy(self.seasonal), seasonal_requests = seasonal_requests,
    }
end

function Core:GetSnapshot()
    return {
        version = 1, achievements = Copy(self.achievements),
        seasonal = Copy(self.seasonal),
        perks = { levels = Copy(self.levels), unlocked = Copy(self.unlocked) },
        earned = self.earned, spent = self.spent, balance = self:Balance(),
    }
end

return Core
