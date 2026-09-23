local QuestDefs = require("quests/hh_daily_quest_defs")
local HHUtils = require("utils/hh_utils")

local STATUS_NONE = 0
local STATUS_ACTIVE = 1
local STATUS_COMPLETED = 2
local STATUS_FAILED = 3

local TRACKED_EVENT_NAMES = {
    "builditem",
    "buildstructure",
    "oneat",
    "learncookbookrecipe",
    "feedmount",
    "deployitem",
    "tilling",
    "sanitymodechanged",
    "harvestsomething",
    "fishingcollect",
    "fishcaught",
    "catch",
    "repair",
    "learnrecipe",
    "itemget",
    "dropitem",
    "equip",
    "unequip",
    "gotosleep",
    "onwakeup",
    "onhitother",
    "attacked",
    "changearea",
    "mounted",
    "dismounted",
    "teleport_move",
}

local function GetPrefabName(value)
    if type(value) == "string" then
        return value
    end
    return value ~= nil and value.prefab or nil
end

local function GetRecipeName(recipe)
    if type(recipe) == "string" then
        return recipe
    end
    if type(recipe) == "table" then
        return recipe.name or recipe.recname or recipe.recipe
    end
    return nil
end

local function GetWorldSeconds()
    local cycles = TheWorld and TheWorld.state and TheWorld.state.cycles or 0
    local time = TheWorld and TheWorld.state and TheWorld.state.time or 0
    return math.floor((cycles + time) * TUNING.TOTAL_DAY_TIME)
end

local function GetPercent(component)
    return component ~= nil and component:GetPercent() or 0
end

local function GetFailurePenaltyValue(current)
    if current == nil then
        return nil
    end

    local reduced = math.max(
        TUNING.HH_DAILY_QUEST.FAILURE_VITAL_FLOOR,
        current * TUNING.HH_DAILY_QUEST.FAILURE_VITAL_MULT
    )
    -- Sàn 1 không được biến thành hồi phục nếu chỉ số vốn đã dưới 1.
    return math.min(current, reduced)
end

local function ApplyFailureVitalPenalty(inst)
    local health = inst.components.health
    if inst:HasTag('playerghost') or (health and health:IsDead()) then
        return
    end

    local health_target = GetFailurePenaltyValue(health and health.currenthealth)
    if health_target and health.maxhealth and health.maxhealth > 0 then
        health:SetPercent(health_target / health.maxhealth, true, 'hh_daily_quest_penalty')
    end

    local sanity = inst.components.sanity
    local sanity_target = GetFailurePenaltyValue(sanity and sanity.current)
    if sanity_target then
        sanity:SetCurrent(sanity_target)
    end

    local hunger = inst.components.hunger
    local hunger_target = GetFailurePenaltyValue(hunger and hunger.current)
    if hunger_target then
        hunger:SetCurrent(hunger_target, true)
    end
end

local HHDailyQuest = Class(function(self, inst)
    self.inst = inst
    self.quest_id = 0
    self.progress = 0
    self.target = 0
    self.reward = 0
    self.status = STATUS_NONE
    self.deadline = 0
    self.failure_reason = ""
    self.last_quest_id = 0
    self.last_x = nil
    self.last_z = nil
    self.last_sample_time = GetTime()
    self.assign_after = 0
    self.completed_quest_count = 0
    self.unique_progress = {}

    inst:ListenForEvent("picksomething", function(_, data) self:OnPick(data) end)
    inst:ListenForEvent("finishedwork", function(_, data) self:OnFinishedWork(data) end)
    inst:ListenForEvent("working", function(_, data) self:OnWorking(data) end)
    inst:ListenForEvent("killed", function(_, data) self:OnKilled(data) end)
    inst:ListenForEvent("hungerdelta", function() self:ValidateStrictQuest() end)
    inst:ListenForEvent("sanitydelta", function() self:ValidateStrictQuest() end)
    inst:ListenForEvent("healthdelta", function(_, data)
        self:ValidateStrictQuest()
        self:OnTrackedEvent("healthdelta", data)
    end)

    local function ListenForTrackedEvent(event_name)
        inst:ListenForEvent(event_name, function(_, data)
            self:OnTrackedEvent(event_name, data)
        end)
    end
    for _, event_name in ipairs(TRACKED_EVENT_NAMES) do
        ListenForTrackedEvent(event_name)
    end

    self._world = TheWorld
    self._on_world_itemplanted = function(_, data)
        if data ~= nil and data.doer == self.inst then
            self:OnTrackedEvent("itemplanted", data)
        end
    end
    if self._world ~= nil then
        self._world:ListenForEvent("itemplanted", self._on_world_itemplanted)
    end
    self._on_inst_remove = function()
        self:OnRemoveFromEntity()
    end
    inst:ListenForEvent("onremove", self._on_inst_remove)

    self.tick_task = inst:DoPeriodicTask(TUNING.HH_DAILY_QUEST.SAMPLE_INTERVAL, function() self:OnTick() end)
    inst:DoTaskInTime(1, function()
        local now = GetWorldSeconds()
        if self.status == STATUS_NONE then
            self:AssignQuest()
        elseif now >= self.deadline and self.status == STATUS_ACTIVE then
            self:FailQuest("timeout")
            self.assign_after = now + 3
        elseif now >= self.deadline then
            self:AssignQuest()
        else
            self:Sync()
            self:ValidateStrictQuest()
        end
    end)
end)

function HHDailyQuest:GetQuest()
    return QuestDefs.Get(self.quest_id)
end

function HHDailyQuest:CanAssignQuest()
    local cycles = TheWorld and TheWorld.state and TheWorld.state.cycles or 0
    return cycles + 1 >= TUNING.HH_DAILY_QUEST.FIRST_DAY
end

function HHDailyQuest:Sync()
    local inst = self.inst
    if inst.hh_quest_id then
        inst.hh_quest_id:set(self.quest_id)
        inst.hh_quest_progress:set(math.floor(math.min(self.progress, 65535)))
        inst.hh_quest_target:set(math.floor(math.min(self.target, 65535)))
        inst.hh_quest_reward:set(self.reward)
        inst.hh_quest_status:set(self.status)
        inst.hh_quest_deadline:set(self.deadline)
        inst.hh_quest_failure:set(self.failure_reason or "")
    end
end

function HHDailyQuest:PassesHardEligibility(quest)
    if quest == nil then
        return false
    end

    local world_state = TheWorld and TheWorld.state or nil
    local cycles = world_state and world_state.cycles or 0
    if quest.min_cycle and cycles < quest.min_cycle then
        return false
    end
    if quest.cave_only and (TheWorld == nil or not TheWorld:HasTag("cave")) then
        return false
    end
    if quest.min_completed_quests ~= nil
        and self.completed_quest_count < quest.min_completed_quests then
        return false
    end
    if quest.allowed_seasons ~= nil then
        local season = world_state and world_state.season or nil
        if season == nil or not quest.allowed_seasons[season] then
            return false
        end
    end
    if quest.autumn_no_assign_last_days ~= nil
        and world_state ~= nil
        and world_state.season == "autumn"
        and (world_state.remainingdaysinseason == nil
            or world_state.remainingdaysinseason <= quest.autumn_no_assign_last_days) then
        return false
    end
    return true
end

function HHDailyQuest:IsEligible(quest)
    if not self:PassesHardEligibility(quest) then
        return false
    end

    if quest.tracker == "maintain" then
        if quest.hunger and GetPercent(self.inst.components.hunger) < quest.hunger then
            return false
        end
        if quest.sanity and GetPercent(self.inst.components.sanity) < quest.sanity then
            return false
        end
        if quest.health and GetPercent(self.inst.components.health) < quest.health then
            return false
        end
    end
    return quest.id ~= self.last_quest_id
end

function HHDailyQuest:AssignQuest()
    if not self:CanAssignQuest() then
        self:Sync()
        return
    end
    local eligible = {}
    for _, quest in ipairs(QuestDefs.list) do
        if self:IsEligible(quest) then
            table.insert(eligible, quest)
        end
    end
    if #eligible == 0 then
        for _, quest in ipairs(QuestDefs.list) do
            if quest.id ~= self.last_quest_id
                and self:PassesHardEligibility(quest)
                and quest.tracker ~= "maintain" then
                table.insert(eligible, quest)
            end
        end
    end
    if #eligible == 0 then
        return
    end

    local quest = eligible[math.random(#eligible)]
    self.quest_id = quest.id
    self.progress = 0
    self.target = quest.target
    self.reward = quest.reward
    self.status = STATUS_ACTIVE
    self.deadline = GetWorldSeconds() + TUNING.HH_DAILY_QUEST.DURATION_DAYS * TUNING.TOTAL_DAY_TIME
    self.failure_reason = ""
    self.unique_progress = {}
    local start_x, start_y, start_z = self.inst.Transform:GetWorldPosition()
    self.last_x, self.last_z = start_x, start_z
    self.last_sample_time = GetTime()
    self:Sync()

    if self.inst.components.talker then
        self.inst.components.talker:Say("[NHIỆM VỤ MỚI]\n" .. quest.title .. "\n" .. quest.description, 6)
    end
    self.inst:PushEvent("hh_daily_quest_assigned", { quest_id=quest.id, deadline=self.deadline })
end

function HHDailyQuest:AddProgress(amount)
    if self.status ~= STATUS_ACTIVE or amount == nil or amount <= 0 then
        return
    end
    self.progress = math.min(self.target, self.progress + amount)
    if self.progress >= self.target then
        self:CompleteQuest()
    else
        self:Sync()
    end
end

function HHDailyQuest:AddUniqueProgress(key)
    if key == nil then
        return
    end
    key = tostring(key)
    self.unique_progress = self.unique_progress or {}
    if self.unique_progress[key] then
        return
    end
    self.unique_progress[key] = true
    self:AddProgress(1)
end

function HHDailyQuest:GetUniqueEventKey(quest, data)
    if quest == nil or quest.unique_field == nil or data == nil then
        return nil
    end

    if quest.unique_field == "recipe" then
        return GetRecipeName(data.recipe) or GetPrefabName(data.item)
    elseif quest.unique_field == "food" then
        return GetPrefabName(data.food)
    elseif quest.unique_field == "product" then
        return type(data.product) == "string" and data.product or GetPrefabName(data.product)
    elseif quest.unique_field == "area" then
        return data.id
    end
    return nil
end

function HHDailyQuest:OnTrackedEvent(event_name, data)
    local quest = self:GetQuest()
    if self.status ~= STATUS_ACTIVE or not quest
        or quest.tracker ~= "event" or quest.event ~= event_name then
        return
    end

    if (event_name == "builditem" or event_name == "buildstructure")
        and (data == nil or data.item == nil) then
        return
    elseif event_name == "oneat" and (data == nil or data.food == nil) then
        return
    elseif event_name == "learncookbookrecipe" and (data == nil or data.product == nil) then
        return
    elseif event_name == "feedmount" and (data == nil or data.eater == nil) then
        return
    elseif event_name == "deployitem" then
        local prefab = data and data.prefab
        if prefab == nil or (quest.group ~= nil and not QuestDefs.Matches(quest.group, prefab)) then
            return
        end
    elseif event_name == "healthdelta" then
        local amount = tonumber(data and data.amount) or 0
        if amount <= 0 then
            return
        end
        self:AddProgress(amount)
        return
    elseif event_name == "sanitymodechanged" and (data == nil or data.mode == nil) then
        return
    elseif event_name == "harvestsomething" and (data == nil or data.object == nil) then
        return
    elseif (event_name == "fishingcollect" or event_name == "fishcaught")
        and (data == nil or data.fish == nil) then
        return
    elseif event_name == "catch" and (data == nil or data.projectile == nil) then
        return
    elseif event_name == "learnrecipe" and (data == nil or data.recipe == nil) then
        return
    elseif event_name == "learnrecipe" and quest.source_prefab ~= nil
        and GetPrefabName(data and data.teacher) ~= quest.source_prefab then
        return
    elseif (event_name == "itemget" or event_name == "dropitem"
        or event_name == "equip" or event_name == "unequip")
        and (data == nil or data.item == nil) then
        return
    elseif event_name == "onhitother" then
        local target = data and data.target
        if target == nil or not target:IsValid()
            or target.components == nil or target.components.combat == nil then
            return
        end
    elseif event_name == "attacked" then
        local damage = data and (data.damageresolved or data.damage)
        if (tonumber(damage) or 0) <= 0 then
            return
        end
    elseif event_name == "changearea" and (data == nil or data.id == nil) then
        return
    elseif (event_name == "mounted" or event_name == "dismounted")
        and (data == nil or data.target == nil) then
        return
    end

    if quest.unique_field ~= nil then
        self:AddUniqueProgress(self:GetUniqueEventKey(quest, data))
    else
        self:AddProgress(1)
    end
end

function HHDailyQuest:CompleteQuest()
    if self.status ~= STATUS_ACTIVE then
        return
    end
    local quest = self:GetQuest()
    self.status = STATUS_COMPLETED
    self.progress = self.target
    self.last_quest_id = self.quest_id
    self.unique_progress = {}
    self.completed_quest_count = self.completed_quest_count + 1
    self.assign_after = 0
    -- Sau khi hoàn thành, deadline trở thành thời điểm cấp nhiệm vụ kế tiếp.
    self.deadline = GetWorldSeconds() + TUNING.HH_DAILY_QUEST.DURATION_DAYS * TUNING.TOTAL_DAY_TIME
    self:Sync()

    local exp_granted = false
    local exp_reason = nil
    if self.inst.components.hh_leveling then
        exp_granted, exp_reason = self.inst.components.hh_leveling:AddExp(self.reward)
    end
    if exp_granted then
        HHUtils:SpawnClientStrFx(self.inst, "+" .. tostring(self.reward) .. " EXP")
    end
    HHUtils:SpawnClientLevelUpFx(self.inst, "Đã hoàn thành nhiệm vụ ngày !")
    if self.inst.SoundEmitter then
        self.inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_lvl1_ding")
    end
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local fx1 = SpawnPrefab("statue_transition")
    local fx2 = SpawnPrefab("fx_book_light")
    if fx1 then fx1.Transform:SetPosition(x, y, z) end
    if fx2 then fx2.Transform:SetPosition(x, y, z) end
    if self.inst.components.talker and quest then
        local exp_line = exp_granted
            and ("\n+" .. tostring(self.reward) .. " EXP")
            or ("\n" .. STRINGS.HH_DAILY_QUEST.EXP_BLOCKED)
        self.inst.components.talker:Say("[NHIỆM VỤ HOÀN THÀNH]\n" .. quest.title .. exp_line, 6)
    end
    self.inst:PushEvent("hh_daily_quest_completed", {
        quest_id=self.quest_id,
        reward=self.reward,
        reward_granted=exp_granted,
        exp_reason=exp_reason,
    })
end

function HHDailyQuest:GetFailureMessage(reason)
    local quest = self:GetQuest()
    local title = quest and quest.title or "Không xác định"
    if reason == "hunger_below_threshold" then
        return "Bạn đã để chỉ số Đói giảm xuống dưới mức yêu cầu."
    elseif reason == "sanity_below_threshold" then
        return "Bạn đã để chỉ số Tinh thần giảm xuống dưới mức yêu cầu."
    elseif reason == "health_below_threshold" then
        return "Bạn đã để Máu giảm xuống dưới mức yêu cầu."
    end
    return "Đã hết thời gian hoàn thành nhiệm vụ: " .. title .. "."
end

function HHDailyQuest:FailQuest(reason)
    if self.status ~= STATUS_ACTIVE then
        return
    end
    self.status = STATUS_FAILED
    self.assign_after = 0
    -- Nhiệm vụ kế tiếp chỉ được cấp sau đủ hai ngày kể từ lúc thất bại.
    self.deadline = GetWorldSeconds() + TUNING.HH_DAILY_QUEST.DURATION_DAYS * TUNING.TOTAL_DAY_TIME
    self.failure_reason = reason or "timeout"
    self.last_quest_id = self.quest_id
    self.unique_progress = {}
    self:Sync()

    local leveling = self.inst.components.hh_leveling
    if leveling then
        local seal_duration = TUNING.HH_DAILY_QUEST.EXP_SEAL_DAYS * TUNING.TOTAL_DAY_TIME
        leveling:ApplyExpSeal(seal_duration)
    end
    ApplyFailureVitalPenalty(self.inst)

    local slot_lock = self.inst.components.hh_slot_lock_penalty
    local slot_lock_applied, slot_lock_result = false, nil
    if slot_lock then
        local lock_duration = TUNING.HH_DAILY_QUEST.SLOT_LOCK_DAYS * TUNING.TOTAL_DAY_TIME
        slot_lock_applied, slot_lock_result = slot_lock:ApplyRandomLock(lock_duration)
    end

    local message = self:GetFailureMessage(self.failure_reason)
    if slot_lock_applied then
        local strings = STRINGS.HH_DAILY_QUEST
        local slot_name = strings.SLOT_NAMES[slot_lock_result] or tostring(slot_lock_result)
        message = message .. '\n' .. string.format(strings.SLOT_LOCK_APPLIED, slot_name)
    elseif slot_lock then
        message = message .. '\n' .. STRINGS.HH_DAILY_QUEST.SLOT_LOCK_FAILED
        print('[Solo Leveling] Daily quest slot lock skipped for '
            .. tostring(self.inst.userid) .. ': ' .. tostring(slot_lock_result))
    end
    local player_name = self.inst.name
    if not player_name or player_name == "" then
        player_name = self.inst.GetDisplayName and self.inst:GetDisplayName() or "Không xác định"
    end
    local announcement = "Thợ săn " .. player_name .. " đã không hoàn thành nhiệm vụ ngày"
    HHUtils:NetSay(announcement)
    HHUtils:SpawnClientStrFx(self.inst, "NHIỆM VỤ THẤT BẠI")
    if self.inst.SoundEmitter then
        self.inst.SoundEmitter:PlaySound("dontstarve/HUD/health_down")
    end
    if self.inst.components.talker then
        self.inst.components.talker:Say("[NHIỆM VỤ THẤT BẠI]\n" .. message, 8)
    end
    self.inst:PushEvent("hh_daily_quest_failed", {
        quest_id=self.quest_id,
        reason=self.failure_reason,
        locked_slot=slot_lock_applied and slot_lock_result or nil,
    })
end

function HHDailyQuest:ValidateStrictQuest()
    if self.status ~= STATUS_ACTIVE then
        return
    end
    local quest = self:GetQuest()
    if not quest or quest.tracker ~= "maintain" then
        return
    end
    if quest.hunger and GetPercent(self.inst.components.hunger) < quest.hunger then
        self:FailQuest("hunger_below_threshold")
    elseif quest.sanity and GetPercent(self.inst.components.sanity) < quest.sanity then
        self:FailQuest("sanity_below_threshold")
    elseif quest.health and GetPercent(self.inst.components.health) < quest.health then
        self:FailQuest("health_below_threshold")
    end
end

function HHDailyQuest:OnPick(data)
    local quest = self:GetQuest()
    if self.status ~= STATUS_ACTIVE or not quest then
        return
    end
    local target = data and (data.object or data.target)
    if quest.tracker ~= "pick" then
        return
    end
    if target and QuestDefs.Matches(quest.group, target.prefab) then
        self:AddProgress(1)
    end
end

function HHDailyQuest:GetActionId(data, target)
    local action = data and data.action
    if not action and target and target.components and target.components.workable then
        action = target.components.workable.action
    end
    return action and (action.id or action.str) or nil
end

function HHDailyQuest:OnFinishedWork(data)
    local quest = self:GetQuest()
    if self.status ~= STATUS_ACTIVE or not quest or quest.tracker ~= "finishedwork" then
        return
    end
    local target = data and (data.target or data.object)
    local action_id = self:GetActionId(data, target)
    if target and action_id == quest.action and QuestDefs.Matches(quest.group, target.prefab) then
        self:AddProgress(1)
    end
end

function HHDailyQuest:OnWorking(data)
    local quest = self:GetQuest()
    if self.status ~= STATUS_ACTIVE or not quest or quest.tracker ~= "work" then
        return
    end
    local target = data and (data.target or data.object)
    local action_id = self:GetActionId(data, target)
    if action_id == "CHOP" or action_id == "MINE" or action_id == "HAMMER" then
        self:AddProgress(1)
    end
end

function HHDailyQuest:OnKilled(data)
    local quest = self:GetQuest()
    if self.status ~= STATUS_ACTIVE or not quest or quest.tracker ~= "kill" then
        return
    end
    local victim = data and data.victim
    if not victim or not QuestDefs.Matches(quest.group, victim.prefab) then
        return
    end
    -- DST pushes "killed" on the actual attacker before it pushes "onhitother".
    -- Receiving this event on the player is therefore the authoritative direct-kill signal.
    if data.attacker ~= nil and data.attacker ~= self.inst then
        return
    end
    self:AddProgress(1)
end

function HHDailyQuest:IsDistanceSampleValid(dt, distance, quest)
    local inst = self.inst
    if inst:HasTag("playerghost") or inst:HasTag("INLIMBO") then
        return false
    end
    if inst.components.health and inst.components.health:IsDead() then
        return false
    end
    if inst.components.rider and inst.components.rider:IsRiding() then
        return false
    end
    if inst.GetCurrentPlatform and inst:GetCurrentPlatform() ~= nil then
        return false
    end
    local locomotor = inst.components.locomotor
    local moving = locomotor and (locomotor.wantstomoveforward or (inst.sg and inst.sg:HasStateTag("moving")))
    if not moving then
        return false
    end
    if quest.night_only and not TheWorld.state.isnight then
        return false
    end
    local hunger = GetPercent(inst.components.hunger)
    if quest.hunger_min and hunger < quest.hunger_min then
        return false
    end
    if quest.hunger_max and hunger > quest.hunger_max then
        return false
    end
    local speed = locomotor.GetRunSpeed and locomotor:GetRunSpeed() or locomotor.runspeed or 6
    local max_delta = math.max(TUNING.HH_DAILY_QUEST.MIN_MAX_SPEED, speed * TUNING.HH_DAILY_QUEST.SPEED_TOLERANCE) * dt
    return distance <= max_delta
end

function HHDailyQuest:TrackDistance(quest, now)
    local x, _, z = self.inst.Transform:GetWorldPosition()
    local dt = math.max(0.01, now - self.last_sample_time)
    if self.last_x ~= nil and self.last_z ~= nil then
        local dx, dz = x - self.last_x, z - self.last_z
        local distance = math.sqrt(dx * dx + dz * dz)
        if distance > 0 and self:IsDistanceSampleValid(dt, distance, quest) then
            self:AddProgress(distance)
        end
    end
    self.last_x, self.last_z = x, z
    self.last_sample_time = now
end

function HHDailyQuest:OnTick()
    local now_world = GetWorldSeconds()
    if self.status == STATUS_NONE then
        if self:CanAssignQuest() then
            self:AssignQuest()
        end
        return
    end
    if self.deadline > 0 and now_world >= self.deadline then
        if self.status == STATUS_ACTIVE then
            self:FailQuest("timeout")
            self.assign_after = now_world + 3
            return
        end
        if self.assign_after > 0 and now_world < self.assign_after then
            return
        end
        self:AssignQuest()
        return
    end
    if self.status ~= STATUS_ACTIVE then
        return
    end
    local quest = self:GetQuest()
    if not quest then
        return
    end
    local now = GetTime()
    if quest.tracker == "distance" then
        self:TrackDistance(quest, now)
    elseif quest.tracker == "maintain" then
        self:ValidateStrictQuest()
        if self.status == STATUS_ACTIVE then
            self:AddProgress(TUNING.HH_DAILY_QUEST.SAMPLE_INTERVAL)
        end
    end
end

function HHDailyQuest:OnSave()
    local quest = self:GetQuest()
    local data = {
        quest_id=self.quest_id,
        quest_definition_key=quest and quest.definition_key or nil,
        progress=self.progress,
        target=self.target,
        reward=self.reward,
        status=self.status,
        deadline=self.deadline,
        failure_reason=self.failure_reason,
        last_quest_id=self.last_quest_id,
        completed_quest_count=self.completed_quest_count,
    }
    local unique_progress = {}
    for key, value in pairs(self.unique_progress or {}) do
        if value then
            table.insert(unique_progress, key)
        end
    end
    if #unique_progress > 0 then
        data.unique_progress = unique_progress
    end
    return data
end

function HHDailyQuest:OnLoad(data)
    if not data then
        return
    end
    local saved_quest_id = tonumber(data.quest_id) or 0
    local quest = QuestDefs.Get(saved_quest_id)
    local definition_changed = quest ~= nil
        and quest.definition_key ~= nil
        and data.quest_definition_key ~= quest.definition_key

    if definition_changed then
        -- Các nhiệm vụ có definition_key đã thay đổi nội dung.
        -- Save cũ không có khóa định nghĩa mới nên phải bỏ tiến độ cũ,
        -- tránh chuyển tiến độ của nhiệm vụ đã bị loại sang nhiệm vụ thay thế.
        self.quest_id = 0
        self.progress = 0
        self.target = 0
        self.reward = 0
        self.status = STATUS_NONE
        self.deadline = 0
        self.failure_reason = ""
        self.last_quest_id = 0
    else
        self.quest_id = saved_quest_id
        self.progress = data.progress or 0
        -- Đồng bộ save cũ với target/reward hiện tại trong bảng định nghĩa.
        self.target = quest and quest.target or data.target or 0
        self.reward = quest and quest.reward or data.reward or 0
        self.status = data.status or STATUS_NONE
        self.deadline = data.deadline or 0
        self.failure_reason = data.failure_reason or ""
        self.last_quest_id = data.last_quest_id or 0
    end
    self.completed_quest_count = math.max(0, tonumber(data.completed_quest_count) or 0)
    self.unique_progress = {}
    if not definition_changed and type(data.unique_progress) == "table" then
        for key, value in pairs(data.unique_progress) do
            if type(key) == "number" and type(value) == "string" then
                self.unique_progress[value] = true
            elseif type(key) == "string" and value == true then
                self.unique_progress[key] = true
            end
        end
    end
    local load_x, load_y, load_z = self.inst.Transform:GetWorldPosition()
    self.last_x, self.last_z = load_x, load_z
    local manager = self.inst.components.hh_shadow_manager
    if manager ~= nil and manager.ReconcileMacanhUnlock ~= nil then
        self.inst:DoTaskInTime(0, function(inst)
            if not inst:IsValid() then
                return
            end
            local loaded_manager = inst.components.hh_shadow_manager
            if loaded_manager ~= nil and loaded_manager.ReconcileMacanhUnlock ~= nil then
                loaded_manager:ReconcileMacanhUnlock()
            end
        end)
    end
    self.last_sample_time = GetTime()
    self:Sync()
end

function HHDailyQuest:OnRemoveFromEntity()
    if self._on_inst_remove ~= nil then
        self.inst:RemoveEventCallback("onremove", self._on_inst_remove)
    end
    self._on_inst_remove = nil
    if self._world ~= nil and self._on_world_itemplanted ~= nil then
        self._world:RemoveEventCallback("itemplanted", self._on_world_itemplanted)
    end
    self._world = nil
    self._on_world_itemplanted = nil
    if self.tick_task ~= nil then
        self.tick_task:Cancel()
        self.tick_task = nil
    end
end

function HHDailyQuest:GetDebugString()
    return string.format("quest=%d status=%d progress=%.1f/%d deadline=%d", self.quest_id, self.status, self.progress, self.target, self.deadline)
end

return HHDailyQuest
