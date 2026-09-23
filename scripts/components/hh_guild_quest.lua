local QuestDefs = require("guild/hh_guild_quest_defs")
local Event = require("guild/hh_guild_event")

local STATUS_NONE = 0
local STATUS_ACTIVE = 1
local STATUS_COMPLETED = 2
local STATUS_FAILED = 3
local MIN_OFFER_COUNT = 3
local MAX_OFFER_COUNT = 8
local CANCEL_COOLDOWN_SECONDS = 480
local TIMEOUT_COOLDOWN_SECONDS = 240

local function IsInteger(value)
    return type(value) == "number" and value == math.floor(value)
end

local function GetDataPrefab(data)
    if not data then
        return nil
    end
    local target = Event.GetTarget(data)
    local prefab = Event.GetPrefab(target)
    if prefab then
        return prefab
    end
    if data.recipe then
        return Event.GetPrefab(data.recipe)
    end
    return data.prefab
end

local function MatchesQuestPrefab(quest, prefab)
    if prefab == nil then
        return false
    end
    if quest.prefabs and quest.prefabs[prefab] then
        return true
    end
    if quest.group and QuestDefs.MatchesGroup(quest.group, prefab) then
        return true
    end
    return quest.prefab ~= nil and quest.prefab == prefab
end

local function GetRequirementTarget(requirements)
    local target = 0
    for _ in ipairs(requirements or {}) do
        target = target + 1
    end
    return target
end

local function GetItemDisplayName(prefab)
    local names = STRINGS and STRINGS.NAMES
    return names and names[string.upper(prefab)] or prefab
end

local function IsPlayerSleepState(inst)
    return inst.sg ~= nil
        and (inst.sg:HasStateTag("bedroll") or inst.sg:HasStateTag("tent"))
end

local function HookPlayerSleepingBagUser(quest_component)
    local inst = quest_component.inst
    local sleepingbaguser = inst.components.sleepingbaguser
    if sleepingbaguser == nil
        or sleepingbaguser.DoSleep == nil
        or sleepingbaguser.DoWakeUp == nil
        or sleepingbaguser._hh_guild_quest_sleep_hooked then
        return
    end

    local original_dosleep = sleepingbaguser.DoSleep
    local original_dowakeup = sleepingbaguser.DoWakeUp

    sleepingbaguser.DoSleep = function(user, bed)
        original_dosleep(user, bed)

        local player = user.inst
        local sleep_started = bed ~= nil
            and user.bed == bed
            and player.sleepingbag == bed
            and IsPlayerSleepState(player)
        if not sleep_started or user._hh_sleep_session_active then
            return
        end

        user._hh_sleep_session_active = true
        player:PushEvent("gotosleep", { bed=bed })

        local quest = player.components.hh_guild_quest
        if quest == nil
            or quest.quest_id ~= 43
            or quest.status ~= STATUS_ACTIVE
            or quest._hh_quest43_sleep_session_counted
            or not IsPlayerSleepState(player)
            or user.bed ~= bed
            or player.sleepingbag ~= bed then
            return
        end

        quest._hh_quest43_sleep_session_counted = true
        quest:AddProgress(1)
    end

    sleepingbaguser.DoWakeUp = function(user, nostatechange)
        local player = user.inst
        local sleep_session_active = user._hh_sleep_session_active == true
        local bed = user.bed
        original_dowakeup(user, nostatechange)

        if sleep_session_active then
            user._hh_sleep_session_active = false
            player:PushEvent("onwakeup", { bed=bed, nostatechange=nostatechange })
        end

        local quest = player.components.hh_guild_quest
        if quest ~= nil then
            quest._hh_quest43_sleep_session_counted = false
        end
    end

    sleepingbaguser._hh_guild_quest_sleep_hooked = true
end

local HHGuildQuest = Class(function(self, inst)
    self.inst = inst
    self.version = 1
    self.quest_id = 0
    self.status = STATUS_NONE
    self.progress = 0
    self.target = 0
    self.remaining_seconds = 0
    self.failure_reason = ""
    self.history = {}
    self.completed_count = 0
    self.failed_count = 0
    self.seen = {}
    self.offers = {}
    self.cancel_cooldown_seconds = 0
    self.online = true
    self.last_x = nil
    self.last_z = nil
    self.last_sample_time = GetTime()
    self._hh_quest43_sleep_session_counted = false

    HookPlayerSleepingBagUser(self)

    local tracked_events = {
        "picksomething",
        "finishedwork",
        "working",
        "killed",
        "builditem",
        "buildstructure",
        "deployitem",
        "harvestsomething",
        "oneat",
        "fishcaught",
        "mounted",
        "gotosleep",
        "onignite",
        "freeze",
        "lightningdamageavoided",
        "sanitymodechanged",
        "healthdelta",
    }
    for _, event_name in ipairs(tracked_events) do
        inst:ListenForEvent(event_name, function(_, data)
            self:OnTrackedEvent(event_name, data)
        end)
    end

    inst:ListenForEvent("hh_levelup", function()
        local rank = inst.components.hh_rank
        if rank then
            rank:RefreshExamAvailability()
        end
    end)

    inst:ListenForEvent("ms_playerleft", function(_, player)
        if player == inst then
            self.online = false
        end
    end, TheWorld)

    self.tick_task = inst:DoPeriodicTask(1, function()
        self:OnTick()
    end)

    inst:DoTaskInTime(0, function()
        local x, _, z = inst.Transform:GetWorldPosition()
        self.last_x, self.last_z = x, z
        self.last_sample_time = GetTime()
        self:Sync()
    end)
end)

function HHGuildQuest:GetQuest()
    return QuestDefs.Get(self.quest_id)
end

function HHGuildQuest:GetOffers()
    return self.offers
end

function HHGuildQuest:IsOffered(id)
    id = tonumber(id)
    for _, offer_id in ipairs(self.offers or {}) do
        if offer_id == id then
            return true
        end
    end
    return false
end

function HHGuildQuest:RefreshOffers()
    if self.status == STATUS_ACTIVE or self.status == STATUS_COMPLETED
        or (self.cancel_cooldown_seconds or 0) > 0 then
        self.offers = {}
        self:Sync()
        return
    end

    local pool = {}
    for _, quest in ipairs(self:GetEligibleQuests()) do
        table.insert(pool, quest)
    end

    local rank_component = self.inst.components.hh_rank
    local rank = rank_component and rank_component:GetRank() or 1
    local offer_count = math.min(MAX_OFFER_COUNT, MIN_OFFER_COUNT + math.max(0, rank - 1))
    self.offers = {}
    while #self.offers < math.min(offer_count, #pool) do
        local index = math.random(#pool)
        table.insert(self.offers, pool[index].id)
        table.remove(pool, index)
    end
    self:Sync()
end

function HHGuildQuest:EnsureOffers()
    if self.status == STATUS_ACTIVE or self.status == STATUS_COMPLETED
        or (self.cancel_cooldown_seconds or 0) > 0 then
        return
    end
    if #(self.offers or {}) == 0 then
        self:RefreshOffers()
    end
end

function HHGuildQuest:Sync()
    local inst = self.inst
    local quest = self:GetQuest()
    if inst.hh_guild_quest_id then inst.hh_guild_quest_id:set(self.quest_id or 0) end
    if inst.hh_guild_quest_status then inst.hh_guild_quest_status:set(self.status or STATUS_NONE) end
    if inst.hh_guild_quest_progress then inst.hh_guild_quest_progress:set(math.floor(math.min(self.progress or 0, 65535))) end
    if inst.hh_guild_quest_target then inst.hh_guild_quest_target:set(math.floor(math.min(self.target or 0, 65535))) end
    if inst.hh_guild_quest_remaining then inst.hh_guild_quest_remaining:set(math.floor(math.max(0, self.remaining_seconds or 0))) end
    if inst.hh_guild_quest_reward then inst.hh_guild_quest_reward:set(quest and quest.reward_credit or 0) end
    if inst.hh_guild_quest_failure then inst.hh_guild_quest_failure:set(self.failure_reason or "") end
    if inst.hh_guild_quest_completed_count then inst.hh_guild_quest_completed_count:set(self.completed_count or 0) end
    if inst.hh_guild_quest_failed_count then inst.hh_guild_quest_failed_count:set(self.failed_count or 0) end
    if inst.hh_guild_quest_offers then
        local offer_ids = {}
        for _, id in ipairs(self.offers or {}) do
            table.insert(offer_ids, tostring(id))
        end
        inst.hh_guild_quest_offers:set(table.concat(offer_ids, ","))
    end
    if inst.hh_guild_quest_cooldown then
        inst.hh_guild_quest_cooldown:set(math.floor(math.max(0, self.cancel_cooldown_seconds or 0)))
    end
end

function HHGuildQuest:CanStartQuest()
    return self.status ~= STATUS_ACTIVE and self.status ~= STATUS_COMPLETED
        and (self.cancel_cooldown_seconds or 0) <= 0
end

function HHGuildQuest:GetEligibleQuests()
    local result = {}
    local rank_component = self.inst.components.hh_rank
    local rank = rank_component and rank_component:GetRank() or 1
    local blocked = {}
    for _, id in ipairs(self.history) do
        blocked[id] = true
    end

    for _, quest in ipairs(QuestDefs.list) do
        if quest.rank <= rank and not blocked[quest.id] then
            table.insert(result, quest)
        end
    end
    if #result == 0 then
        for _, quest in ipairs(QuestDefs.list) do
            if quest.rank <= rank then
                table.insert(result, quest)
            end
        end
    end
    return result
end

function HHGuildQuest:StartRandomQuest()
    if not self:CanStartQuest() then
        local rank = self.inst.components.hh_rank
        if rank then
            rank:SetNotice((self.cancel_cooldown_seconds or 0) > 0
                and ("Bạn phải chờ " .. tostring(math.ceil(self.cancel_cooldown_seconds)) .. " giây sau khi hủy Quest.")
                or "Bạn chỉ có thể nhận một Guild Quest tại một thời điểm.")
        end
        return false
    end

    self:EnsureOffers()
    if #(self.offers or {}) == 0 then
        local rank = self.inst.components.hh_rank
        if rank then rank:SetNotice("Không có Guild Quest phù hợp với Rank hiện tại.") end
        return false
    end
    return self:StartQuest(self.offers[1])
end

function HHGuildQuest:StartQuest(id)
    id = tonumber(id)
    if not IsInteger(id) or not self:CanStartQuest() then
        local rank = self.inst.components.hh_rank
        if rank and (self.cancel_cooldown_seconds or 0) > 0 then
            rank:SetNotice("Bạn phải chờ " .. tostring(math.ceil(self.cancel_cooldown_seconds)) .. " giây sau khi hủy Quest.")
        end
        return false
    end
    self:EnsureOffers()
    if not self:IsOffered(id) then
        local rank = self.inst.components.hh_rank
        if rank then rank:SetNotice("Quest này không nằm trong danh sách Guild Quest hôm nay.") end
        return false
    end
    local quest = QuestDefs.Get(id)
    local rank_component = self.inst.components.hh_rank
    if quest == nil or rank_component == nil or quest.rank > rank_component:GetRank() then
        if rank_component then rank_component:SetNotice("Guild Quest không hợp lệ với Rank hiện tại.") end
        return false
    end

    self.quest_id = quest.id
    self.status = STATUS_ACTIVE
    self.progress = 0
    self.target = quest.tracker == "delivery" and GetRequirementTarget(quest.requirements) or quest.target
    self.remaining_seconds = math.max(1, math.floor((quest.duration_days or 3) * TUNING.TOTAL_DAY_TIME))
    self.failure_reason = ""
    self.seen = {}
    self.offers = {}
    local x, _, z = self.inst.Transform:GetWorldPosition()
    self.last_x, self.last_z = x, z
    self.last_sample_time = GetTime()
    self:Sync()
    rank_component:SetNotice("Đã nhận Guild Quest: " .. quest.title .. ".")
    self.inst:PushEvent("hh_guild_quest_assigned", { quest_id=quest.id })
    return true
end

function HHGuildQuest:AddProgress(amount)
    if self.status ~= STATUS_ACTIVE then
        return
    end
    amount = tonumber(amount) or 0
    if amount <= 0 then
        return
    end
    self.progress = math.min(self.target, self.progress + amount)
    if self.progress >= self.target then
        self:CompleteQuest()
    else
        self:Sync()
    end
end

function HHGuildQuest:CompleteQuest()
    if self.status ~= STATUS_ACTIVE then
        return
    end
    local quest = self:GetQuest()
    if quest == nil then
        return
    end

    self.status = STATUS_COMPLETED
    self.completed_count = math.min(2000000000, self.completed_count + 1)
    self.offers = {}
    self.progress = self.target
    self.remaining_seconds = 0
    table.insert(self.history, 1, quest.id)
    while #self.history > 3 do
        table.remove(self.history)
    end

    local rank = self.inst.components.hh_rank
    if rank then
        rank:AddPendingCredit(quest.reward_credit or 0)
        rank:AddPendingItems(quest.reward_items or {})
        rank:SetNotice("Hoàn thành " .. quest.title .. "! Hãy quay lại Nhân Viên Hiệp Hội để nhận phần thưởng.")
    end
    local fx = SpawnPrefab("hh_guild_complete_fx")
    if fx then
        fx.entity:SetParent(self.inst.entity)
        fx.Transform:SetPosition(0, 0, 0)
    end
    if self.inst.components.talker then
        self.inst.components.talker:Say("Guild Quest đã hoàn thành! Hãy trở về Hiệp Hội.")
    end
    self:Sync()
    self.inst:PushEvent("hh_guild_quest_completed", {
        quest_id=quest.id,
        reward_credit=quest.reward_credit or 0,
    })
end

function HHGuildQuest:OnRewardClaimed()
    if self.status ~= STATUS_COMPLETED then
        return false
    end
    self.quest_id = 0
    self.status = STATUS_NONE
    self.progress = 0
    self.target = 0
    self.remaining_seconds = 0
    self.failure_reason = "reward_cooldown"
    self.offers = {}
    self.cancel_cooldown_seconds = CANCEL_COOLDOWN_SECONDS
    self:Sync()
    self.inst:PushEvent("hh_guild_quest_reward_claimed")
    return true
end

function HHGuildQuest:FailQuest(reason)
    if self.status ~= STATUS_ACTIVE then
        return
    end
    local quest = self:GetQuest()
    self.status = STATUS_FAILED
    self.failed_count = math.min(2000000000, self.failed_count + 1)
    self.offers = {}
    self.cancel_cooldown_seconds = reason == "abandoned" and CANCEL_COOLDOWN_SECONDS or TIMEOUT_COOLDOWN_SECONDS
    self.remaining_seconds = 0
    self.failure_reason = reason or "timeout"
    if quest then
        table.insert(self.history, 1, quest.id)
        while #self.history > 3 do table.remove(self.history) end
    end
    local rank = self.inst.components.hh_rank
    if rank then
        rank:SetNotice(self.failure_reason == "abandoned"
            and "Bạn đã hủy Guild Quest."
            or "Guild Quest đã thất bại vì hết thời gian.")
    end
    self:Sync()
    if self.cancel_cooldown_seconds <= 0 then
        self:RefreshOffers()
    end
    self.inst:PushEvent("hh_guild_quest_failed", {
        quest_id=self.quest_id,
        reason=self.failure_reason,
    })
end

function HHGuildQuest:AbandonQuest()
    if self.status ~= STATUS_ACTIVE then
        return false
    end
    self:FailQuest("abandoned")
    return true
end

function HHGuildQuest:TrySubmitDelivery()
    local quest = self:GetQuest()
    if self.status ~= STATUS_ACTIVE or quest == nil or quest.tracker ~= "delivery" then
        local rank = self.inst.components.hh_rank
        if rank then rank:SetNotice("Guild Quest hiện tại không yêu cầu giao vật phẩm.") end
        return false
    end
    local inventory = self.inst.components.inventory
    if inventory == nil then
        return false
    end

    local missing = {}
    for _, requirement in ipairs(quest.requirements or {}) do
        local total = 0
        local items = inventory:FindItems(function(item)
            return item ~= nil
                and item.prefab == requirement.prefab
                and inventory:IsItemEquipped(item) == nil
        end)
        for _, item in ipairs(items or {}) do
            total = total + (item.components.stackable and item.components.stackable.stacksize or 1)
        end
        if total < requirement.amount then
            table.insert(missing, GetItemDisplayName(requirement.prefab) .. " x" .. tostring(requirement.amount - total))
        end
    end
    if #missing > 0 then
        local rank = self.inst.components.hh_rank
        if rank then
            rank:SetNotice("Thiếu vật phẩm: " .. table.concat(missing, ", ") .. ". Hãy giao tại Nhân Viên Hiệp Hội.")
        end
        return false
    end

    for _, requirement in ipairs(quest.requirements or {}) do
        inventory:ConsumeByName(requirement.prefab, requirement.amount)
    end
    self.progress = self.target
    self:CompleteQuest()
    return true
end

function HHGuildQuest:OnTrackedEvent(event_name, data)
    local rank = self.inst.components.hh_rank
    if rank then
        rank:TryProgressFromEvent(event_name, data, QuestDefs)
    end

    if self.quest_id == 43 and event_name == "gotosleep" then
        return
    end

    local quest = self:GetQuest()
    if self.status ~= STATUS_ACTIVE or quest == nil then
        return
    end

    local tracker = quest.tracker
    local prefab = GetDataPrefab(data)
    local amount = 0

    if tracker == "killed" and event_name == "killed" then
        if data and data.attacker ~= nil and data.attacker ~= self.inst then
            return
        end
        if MatchesQuestPrefab(quest, prefab) then amount = 1 end
    elseif tracker == "finishedwork" and event_name == "finishedwork" then
        local target = Event.GetTarget(data)
        local action_id = Event.GetActionId(data, target)
        if (quest.action == nil or action_id == quest.action)
            and (quest.group == nil or MatchesQuestPrefab(quest, prefab)) then
            amount = 1
        end
    elseif tracker == "work" and event_name == "working" then
        local action_id = Event.GetActionId(data, Event.GetTarget(data))
        if action_id == "CHOP" or action_id == "MINE" or action_id == "HAMMER" then
            amount = 1
        end
    elseif tracker == event_name then
        if quest.condition == "lunar"
            and (data == nil or data.mode ~= SANITY_MODE_LUNACY) then
            return
        end
        if quest.prefabs or quest.group or quest.prefab then
            if MatchesQuestPrefab(quest, prefab) then
                amount = 1
            end
        else
            amount = 1
        end
    elseif tracker == "condition" and quest.conditions then
        for _, condition in ipairs(quest.conditions) do
            if condition == event_name then
                amount = 1
                break
            end
        end
    end

    if amount <= 0 then
        return
    end

    if quest.distinct and prefab then
        if self.seen[prefab] then
            return
        end
        self.seen[prefab] = true
    elseif tracker == "healthdelta" then
        local delta = data and tonumber(data.amount or data.delta) or 0
        if delta <= 0 then
            return
        end
        amount = delta
    end

    self:AddProgress(amount)

end

function HHGuildQuest:TrackDistance()
    local quest = self:GetQuest()
    if self.status ~= STATUS_ACTIVE or quest == nil or quest.tracker ~= "distance" then
        return
    end
    if self.inst:HasTag("playerghost") or self.inst:HasTag("INLIMBO") then
        return
    end

    local x, _, z = self.inst.Transform:GetWorldPosition()
    if self.last_x ~= nil and self.last_z ~= nil then
        local dx, dz = x - self.last_x, z - self.last_z
        local distance = math.sqrt(dx * dx + dz * dz)
        if distance > 0 and distance <= 25 then
            self:AddProgress(distance)
        end
    end
    self.last_x, self.last_z = x, z
end

function HHGuildQuest:OnTick()
    if not self.online then
        return
    end

    local rank = self.inst.components.hh_rank
    if rank then
        rank:RefreshExamAvailability()
    end

    if (self.cancel_cooldown_seconds or 0) > 0 then
        self.cancel_cooldown_seconds = math.max(0, self.cancel_cooldown_seconds - 1)
        if self.cancel_cooldown_seconds <= 0 then
            if self.failure_reason == "reward_cooldown" then
                self.failure_reason = ""
            end
            self:RefreshOffers()
        else
            self:Sync()
        end
    end

    if self.status ~= STATUS_ACTIVE then
        return
    end

    self.remaining_seconds = math.max(0, self.remaining_seconds - 1)
    self:TrackDistance()
    if self.remaining_seconds <= 0 then
        self:FailQuest("timeout")
    else
        self:Sync()
    end
end

function HHGuildQuest:OnSave()
    return {
        version=self.version,
        quest_id=self.quest_id,
        status=self.status,
        progress=self.progress,
        target=self.target,
        remaining_seconds=self.remaining_seconds,
        failure_reason=self.failure_reason,
        history=self.history,
        seen=self.seen,
        offers=self.offers,
        cancel_cooldown_seconds=self.cancel_cooldown_seconds,
        completed_count=self.completed_count,
        failed_count=self.failed_count,
    }
end

function HHGuildQuest:OnLoad(data)
    if not data then
        return
    end
    self.quest_id = tonumber(data.quest_id) or 0
    self.status = tonumber(data.status) or STATUS_NONE
    self.progress = math.max(0, tonumber(data.progress) or 0)
    local quest = self:GetQuest()
    self.target = quest and (quest.tracker == "delivery" and GetRequirementTarget(quest.requirements) or quest.target)
        or math.max(0, tonumber(data.target) or 0)
    self.remaining_seconds = math.max(0, tonumber(data.remaining_seconds) or 0)
    self.failure_reason = tostring(data.failure_reason or "")
    self.completed_count = math.min(2000000000, math.max(0, math.floor(tonumber(data.completed_count) or 0)))
    self.failed_count = math.min(2000000000, math.max(0, math.floor(tonumber(data.failed_count) or 0)))
    self.history = {}
    for _, id in ipairs(data.history or {}) do
        if QuestDefs.Get(id) then
            table.insert(self.history, id)
        end
        if #self.history >= 3 then break end
    end
    self.seen = type(data.seen) == "table" and data.seen or {}
    self.offers = {}
    for _, id in ipairs(data.offers or {}) do
        if #self.offers >= MAX_OFFER_COUNT then break end
        id = tonumber(id)
        if IsInteger(id) and QuestDefs.Get(id) and not self:IsOffered(id) then
            table.insert(self.offers, id)
        end
    end
    self.cancel_cooldown_seconds = math.max(0, tonumber(data.cancel_cooldown_seconds) or 0)
    self.online = true
    self:EnsureOffers()
    self:Sync()
end

return HHGuildQuest
