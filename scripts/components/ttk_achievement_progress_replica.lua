local PerkCatalog = require("achievement/ttk_perk_catalog")
local AchievementCatalog = require("achievement/ttk_achievement_catalog")
local SeasonalCatalog = require("achievement/ttk_seasonal_catalog")

local MAX_SNAPSHOT_BYTES = 16384

local function Copy(value)
    if type(value) ~= "table" then return value end
    local copied = {}
    for key, child in pairs(value) do copied[key] = Copy(child) end
    return copied
end

local function NonNegativeInteger(value)
    local number = tonumber(value)
    return number ~= nil and number ~= math.huge and number == math.floor(number) and number >= 0 and number or nil
end

local function CanonicalNumber(value)
    if type(value) ~= "string" or not string.match(value, "^%d[%d%.eE%+%-]*$") then return nil end
    local number = tonumber(value)
    return number ~= nil and number == number and number ~= math.huge and number ~= -math.huge and number >= 0 and number or nil
end

local function DecodeSnapshot(encoded)
    if type(encoded) ~= "string" or #encoded == 0 or #encoded > MAX_SNAPSHOT_BYTES then return nil end
    local sections = {}
    for part in string.gmatch(encoded, "[^;]+") do
        local key, value = string.match(part, "^([vesaprqtuc])(.*)$")
        if key == nil or sections[key] ~= nil then return nil end
        sections[key] = value
    end
    if sections.v ~= "1" and sections.v ~= "2" then return nil end
    local earned, spent = NonNegativeInteger(sections.e), NonNegativeInteger(sections.s)
    if earned == nil or spent == nil or spent > earned or sections.a == nil or sections.p == nil then return nil end
    local snapshot = { version = 2, revision = 0, earned = earned, spent = spent, balance = earned - spent,
        achievements = {}, achievement_rows = {}, perk_rows = {}, perks = { levels = {}, unlocked = {} } }
    for entry in string.gmatch(sections.a, "[^,]+") do
        local id, progress, status = string.match(entry, "^([a-z][a-z0-9_]*):([^:]+):([luc])$")
        progress = CanonicalNumber(progress)
        local definition = id ~= nil and AchievementCatalog.ById(id) or nil
        if definition == nil or progress == nil or progress > definition.target or snapshot.achievements[id] ~= nil then return nil end
        local row = { id=id, group=definition.group, name=definition.name, description=definition.description,
            target=definition.target, reward=definition.reward, progress=progress,
            can_claim=status == "u", status = status == "c" and "claimed" or status == "u" and "completed_unclaimed" or "locked" }
        snapshot.achievements[id] = row
        snapshot.achievement_rows[#snapshot.achievement_rows + 1] = row
    end
    for entry in string.gmatch(sections.p, "[^,]+") do
        local id, level = string.match(entry, "^([a-z][a-z0-9_]*):(%d+)$")
        level = NonNegativeInteger(level)
        local perk = id ~= nil and PerkCatalog.ById(id) or nil
        if perk == nil or level == nil or level == 0 then return nil end
        if perk.max_level ~= nil then
            if level > perk.max_level or snapshot.perks.levels[id] ~= nil then return nil end
            snapshot.perks.levels[id] = level
        else
            if level ~= 1 or snapshot.perks.unlocked[id] ~= nil then return nil end
            snapshot.perks.unlocked[id] = true
        end
    end
    if sections.v == "2" then
        snapshot.revision = NonNegativeInteger(sections.r)
        if snapshot.revision == nil or sections.q == nil or sections.t == nil or sections.u == nil or sections.c == nil then return nil end
        local seen = {}
        for entry in string.gmatch(sections.q, "[^,]+") do
            local id, current_cost, next_cost, current_effect, next_effect, status =
                string.match(entry, "^([a-z][a-z0-9_]*):([^:]+):([^:]+):([^:]+):([^:]+):([luc])$")
            local definition = id ~= nil and PerkCatalog.ById(id) or nil
            current_cost, next_cost = NonNegativeInteger(current_cost), NonNegativeInteger(next_cost)
            current_effect, next_effect = CanonicalNumber(current_effect), CanonicalNumber(next_effect)
            if definition == nil or seen[id] or current_cost == nil or next_cost == nil or current_effect == nil or next_effect == nil then return nil end
            seen[id] = true
            snapshot.perk_rows[#snapshot.perk_rows + 1] = {id=id, group=definition.group, name=definition.name,
                current_cost=current_cost, next_cost=next_cost, current_effect=current_effect, next_effect=next_effect,
                level=snapshot.perks.levels[id] or (snapshot.perks.unlocked[id] and 1 or 0),
                max_level=definition.max_level or 1, repeatable=definition.max_level ~= nil,
                can_claim=status == "u", status=status == "c" and "claimed" or "locked"}
        end
        if #snapshot.perk_rows ~= #PerkCatalog.All() or #snapshot.achievement_rows ~= #AchievementCatalog.All() then return nil end
        if sections.t ~= "" then
            local season, first_claims = string.match(sections.t, "^([a-z]+):(%d+)$")
            first_claims = NonNegativeInteger(first_claims)
            if not SeasonalCatalog.IsSeason(season) or first_claims == nil or first_claims > 20 then return nil end
            snapshot.seasonal = {season=season, first_claims=first_claims, slots={}, chests={}}
            seen = {}
            for entry in string.gmatch(sections.u, "[^,]+") do
                local id, seasonal_progress, claims, status = string.match(entry, "^([a-z][a-z0-9_]*):(%d+):(%d+):([luc])$")
                local definition = id ~= nil and SeasonalCatalog.ById(id) or nil
                seasonal_progress, claims = NonNegativeInteger(seasonal_progress), NonNegativeInteger(claims)
                if definition == nil or seen[id] or definition.season ~= season or seasonal_progress == nil
                    or claims == nil or seasonal_progress > definition.target or claims > definition.max_claims then return nil end
                seen[id] = true
                local slot = #snapshot.seasonal.slots + 1
                snapshot.seasonal.slots[slot] = {id=id, slot=slot, name=definition.name, description=definition.description,
                    progress=seasonal_progress, target=definition.target, claims=claims, max_claims=definition.max_claims,
                    can_claim=status == "u", status=status == "c" and "claimed" or status == "u" and "ready_to_claim" or "active"}
            end
            if #snapshot.seasonal.slots ~= 20 then return nil end
            local milestones = {5, 10, 15, 20}
            for entry in string.gmatch(sections.c, "[^,]+") do
                local milestone, status = string.match(entry, "^(%d+):([luc])$")
                milestone = NonNegativeInteger(milestone)
                local slot = #snapshot.seasonal.chests + 1
                if milestone == nil or milestone ~= milestones[slot] then return nil end
                snapshot.seasonal.chests[slot] = {id="chest_" .. tostring(milestone), slot=slot, milestone=milestone,
                    can_claim=status == "u", status=status == "c" and "claimed" or "locked"}
            end
            if #snapshot.seasonal.chests ~= 4 then return nil end
        elseif sections.u ~= "" or sections.c ~= "" then return nil end
    end
    return snapshot
end

local TtkAchievementProgressReplica = Class(function(self, inst)
    self.inst = inst
    self.snapshot = { version = 1, earned = 0, spent = 0, balance = 0, achievements = {}, perks = { levels = {}, unlocked = {} } }
    inst:ListenForEvent("ttk_achievement_dirty", function(_, encoded) self:SetSnapshot(encoded) end)
    inst:ListenForEvent("ttk_achievement_netdirty", function() self:ReadNetworkSnapshot() end)
    -- Handles the initial net value arriving before the replica is attached.
    inst:DoTaskInTime(0, function() self:ReadNetworkSnapshot() end)
end)

function TtkAchievementProgressReplica:ReadNetworkSnapshot()
    local inst = self.inst
    if inst._ttk_achievement_snapshot ~= nil then self:SetSnapshot(inst._ttk_achievement_snapshot:value()) end
end

function TtkAchievementProgressReplica:SetSnapshot(encoded)
    local decoded = DecodeSnapshot(encoded)
    if decoded == nil then return false end
    if decoded.revision > 0 and decoded.revision <= (self.snapshot.revision or 0) then return false end
    self.snapshot = decoded
    self.inst:PushEvent("ttk_achievement_snapshot")
    return true
end

function TtkAchievementProgressReplica:GetSnapshot()
    return Copy(self.snapshot)
end

return TtkAchievementProgressReplica
