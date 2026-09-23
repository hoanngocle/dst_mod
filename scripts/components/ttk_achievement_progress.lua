local AchievementCatalog = require("achievement/ttk_achievement_catalog")
local PerkCatalog = require("achievement/ttk_perk_catalog")
local SeasonalCatalog = require("achievement/ttk_seasonal_catalog")
local Core = require("achievement/ttk_achievement_core")

local MAX_SNAPSHOT_BYTES = 16384

local function StatusCode(status)
    return status == "claimed" and "c" or status == "completed_unclaimed" and "u" or "l"
end

local function FormatNumber(value)
    if type(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge then return "0" end
    return string.format("%.17g", value)
end

local function SerializeSnapshot(snapshot, revision)
    local achievements, perks, quotes, tasks, chests = {}, {}, {}, {}, {}
    for _, definition in ipairs(AchievementCatalog.All()) do
        local state = snapshot.achievements[definition.id] or { progress=0, status="locked" }
        table.insert(achievements, definition.id .. ":" .. FormatNumber(state.progress) .. ":" .. StatusCode(state.status))
    end
    for _, perk in ipairs(PerkCatalog.All()) do
        local level = perk.max_level ~= nil and (snapshot.perks.levels[perk.id] or 0)
            or (snapshot.perks.unlocked[perk.id] and 1 or 0)
        if level > 0 then table.insert(perks, perk.id .. ":" .. tostring(level)) end
        local capped = level >= (perk.max_level or 1)
        local current_cost = level > 0 and (perk.max_level and PerkCatalog.PriceForLevel(level) or perk.price) or 0
        local next_cost = not capped and PerkCatalog.NextPrice(perk, level) or 0
        local current_effect = perk.effect_per_level and perk.effect_per_level * level or level
        local next_effect = perk.effect_per_level and perk.effect_per_level * math.min(level + 1, perk.max_level) or 1
        quotes[#quotes + 1] = table.concat({perk.id, current_cost, next_cost,
            FormatNumber(current_effect), FormatNumber(next_effect),
            capped and "c" or snapshot.balance >= next_cost and "u" or "l"}, ":")
    end
    local seasonal = snapshot.seasonal
    if seasonal ~= nil then
        for _, slot in ipairs(seasonal.slots) do
            local definition = SeasonalCatalog.ById(slot.task_id)
            local status = slot.claims >= definition.max_claims and "c"
                or slot.progress >= definition.target and "u" or "l"
            tasks[#tasks + 1] = table.concat({slot.task_id, slot.progress, slot.claims, status}, ":")
        end
        for _, milestone in ipairs({5, 10, 15, 20}) do
            chests[#chests + 1] = tostring(milestone) .. ":" .. (seasonal.chest_claimed[milestone] and "c"
                or seasonal.first_claims >= milestone and "u" or "l")
        end
    end
    local encoded = table.concat({
        "v2", "r" .. tostring(revision), "e" .. tostring(snapshot.earned), "s" .. tostring(snapshot.spent),
        "a" .. table.concat(achievements, ","), "p" .. table.concat(perks, ","),
        "q" .. table.concat(quotes, ","),
        "t" .. (seasonal and seasonal.season .. ":" .. tostring(seasonal.first_claims) or ""),
        "u" .. table.concat(tasks, ","), "c" .. table.concat(chests, ","),
    }, ";")
    -- Keep the last valid state instead of publishing a false zero balance.
    return #encoded <= MAX_SNAPSHOT_BYTES and encoded or nil
end

local function CopyScalarTree(value, depth, budget)
    if budget.count <= 0 or depth > 4 then return nil end
    local kind = type(value)
    if kind == "string" then
        if #value > 128 then return nil end
        budget.count = budget.count - 1
        return value
    end
    if kind == "boolean" then budget.count = budget.count - 1; return value end
    if kind == "number" and value == value and value ~= math.huge and value ~= -math.huge then
        budget.count = budget.count - 1
        return value
    end
    if kind ~= "table" then return nil end
    local copy = {}
    for key, child in pairs(value) do
        if type(key) == "string" and #key <= 64 then
            local copied = CopyScalarTree(child, depth + 1, budget)
            if copied ~= nil then copy[key] = copied end
        end
    end
    return copy
end

local TtkAchievementProgress = Class(function(self, inst)
    self.inst = inst
    self.version = 1
    self.snapshot_revision = 0
    self.effect_callback = nil
    self.cultivation_reference = {}
    self.core = Core.New(inst, function(_, perk, level, mode)
        return self:ApplyPerk(perk, level, mode)
    end)
    inst:ListenForEvent("ms_respawnedfromghost", function() self:ReapplyPurchased() end)
    inst:ListenForEvent("ms_playeractivated", function() self:ReapplyPurchased() end)
end)

function TtkAchievementProgress:SetEffectCallback(callback)
    self.effect_callback = type(callback) == "function" and callback or nil
end

function TtkAchievementProgress:ApplyPerk(perk, level, mode)
    if self.effect_callback == nil then return true end
    return self.effect_callback(self.inst, perk, level, mode)
end

function TtkAchievementProgress:PushSnapshot()
    self.snapshot_revision = self.snapshot_revision + 1
    local encoded = SerializeSnapshot(self.core:GetSnapshot(), self.snapshot_revision)
    if encoded == nil then return nil end
    self.snapshot = encoded
    if self.inst._ttk_achievement_snapshot ~= nil then self.inst._ttk_achievement_snapshot:set(encoded) end
    self.inst:PushEvent("ttk_achievement_dirty", encoded)
    return encoded
end

function TtkAchievementProgress:Advance(id, amount, evidence)
    local ok, result = self.core:Advance(id, amount, evidence)
    if ok then self:PushSnapshot() end
    return ok, result
end

function TtkAchievementProgress:ClaimAchievement(id, request_id)
    local ok, result = self.core:ClaimAchievement(id, request_id)
    if type(request_id) == "string" and #request_id > 0 then self:PushSnapshot() end
    return ok, result
end

function TtkAchievementProgress:PurchasePerk(id, request_id)
    local ok, result = self.core:PurchasePerk(id, request_id)
    if type(request_id) == "string" and #request_id > 0 then self:PushSnapshot() end
    return ok, result
end

function TtkAchievementProgress:GetSnapshot()
    return self.core:GetSnapshot()
end

function TtkAchievementProgress:ReapplyPurchased()
    self.core:ReapplyPurchased()
    self:PushSnapshot()
end

function TtkAchievementProgress:SetCultivationReference(snapshot)
    self.cultivation_reference = CopyScalarTree(snapshot, 0, { count = 96 }) or {}
end

function TtkAchievementProgress:SetSeasonalXPCallback(callback)
    self.core:SetSeasonalXPCallback(callback)
end

function TtkAchievementProgress:StartSeason(season, epoch, random)
    local ok, result = self.core:StartSeason(season, epoch, random)
    if ok then self:PushSnapshot() end
    return ok, result
end

function TtkAchievementProgress:AdvanceSeasonal(id, amount, evidence)
    local ok, result = self.core:AdvanceSeasonal(id, amount, evidence)
    if ok then self:PushSnapshot() end
    return ok, result
end

function TtkAchievementProgress:ClaimSeasonal(id, request_id)
    local ok, result = self.core:ClaimSeasonal(id, request_id)
    if type(request_id) == "string" and #request_id > 0 then self:PushSnapshot() end
    return ok, result
end

function TtkAchievementProgress:ClaimChest(season, milestone, request_id)
    local ok, result = self.core:ClaimChest(self.inst, season, milestone, request_id)
    if type(request_id) == "string" and #request_id > 0 then self:PushSnapshot() end
    return ok, result
end

function TtkAchievementProgress:OnSave()
    local state = self.core:GetSaveData()
    state.version = self.version
    state.cultivation = CopyScalarTree(self.cultivation_reference, 0, { count = 96 }) or {}
    return state
end

function TtkAchievementProgress:OnLoad(data)
    local state = type(data) == "table" and data or {}
    self.cultivation_reference = CopyScalarTree(state.cultivation, 0, { count = 96 }) or {}
    self.core:Load(state)
    self:PushSnapshot()
end

return TtkAchievementProgress
