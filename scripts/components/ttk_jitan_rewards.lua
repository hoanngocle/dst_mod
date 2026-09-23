local rewards_data = require("ttk_jitan_rewards")

local Rewards = Class(function(self, inst)
    self.inst = inst
    self.pending_by_userid = {}
    self.paid_run_ids = {}
    self.authorities = {}
    self.last_authority_id = nil
end)

local function Copy(value)
    return deepcopy(value)
end

local function SnapshotRecords(records)
    local snapshots = {}
    for _, record in ipairs(records or {}) do
        local count = math.max(1, math.floor(tonumber(record.count) or 1))
        for _ = 1, count do
            local saved = record.save_record ~= nil and Copy(record.save_record) or nil
            if saved == nil then
                local item = SpawnPrefab(rewards_data.Alias(record.prefab))
                if item == nil or item.GetSaveRecord == nil then
                    if item ~= nil and item.IsValid ~= nil and item:IsValid() then item:Remove() end
                    return nil
                end
                saved = item:GetSaveRecord()
                if item:IsValid() then item:Remove() end
            end
            if saved == nil then return nil end
            table.insert(snapshots, saved)
        end
    end
    return snapshots
end

function Rewards:CanUse(player)
    return player ~= nil and type(player.userid) == "string" and player.userid ~= ""
end

function Rewards:SetAuthority(altar_id, authority)
    if type(altar_id) ~= "string" or authority == nil
        or type(authority.AdoptRewardBackup) ~= "function" then return false end
    self.authorities[altar_id] = authority
    self.last_authority_id = altar_id
    return true
end

local function AltarIdFromRun(run_id)
    return type(run_id) == "string" and string.match(run_id, "^(.*):%d+$") or nil
end

local function IsValidAuthority(authority)
    if authority == nil or type(authority.AdoptRewardBackup) ~= "function" then return false end
    local inst = authority.inst
    return inst == nil or inst.IsValid == nil or inst:IsValid()
end

function Rewards:BackupToAuthorities(private_containers)
    if self.inst._ttk_reward_backup_done then return false end
    self.inst._ttk_reward_backup_done = true
    local backed_up = false
    local fallback = self.authorities[self.last_authority_id]
    if not IsValidAuthority(fallback) then fallback = nil end
    if fallback == nil then
        for _, candidate in pairs(self.authorities) do
            if IsValidAuthority(candidate) then fallback = candidate; break end
        end
    end
    for userid, queues in pairs(self.pending_by_userid) do
        local remaining = {}
        for _, queued in ipairs(queues) do
            local authority = self.authorities[AltarIdFromRun(queued.run_id)]
            if not IsValidAuthority(authority) then authority = fallback end
            local records = {}
            for _, saved in ipairs(queued.items) do records[#records + 1] = { save_record = Copy(saved) } end
            if authority ~= nil and authority:AdoptRewardBackup(queued.run_id, userid, records) then
                backed_up = true
            else
                remaining[#remaining + 1] = queued
            end
        end
        self.pending_by_userid[userid] = #remaining > 0 and remaining or nil
    end

    local authority = fallback
    if authority ~= nil then
        for userid, private in pairs(private_containers or {}) do
            local valid = private ~= nil and (private.IsValid == nil or private:IsValid())
            local container = valid and private.components ~= nil and private.components.container or nil
            local items = container ~= nil and container:GetAllItems() or nil
            local snapshots = {}
            for _, item in ipairs(items or {}) do
                local record = item.GetSaveRecord ~= nil and item:GetSaveRecord() or nil
                if record ~= nil then snapshots[#snapshots + 1] = Copy(record) end
            end
            if #snapshots > 0 then
                local run_id = authority:NewRecoveryRunId()
                local records = {}
                for _, saved in ipairs(snapshots) do records[#records + 1] = { save_record = saved } end
                authority:AdoptRewardBackup(run_id, userid, records)
                backed_up = true
            end
        end
    end
    return backed_up
end

function Rewards:Queue(run_id, userid, records)
    if type(run_id) ~= "string" or run_id == "" or self.paid_run_ids[run_id]
        or type(userid) ~= "string" or userid == "" then return false end
    local snapshots = SnapshotRecords(records)
    if snapshots == nil or #snapshots == 0 then return false end
    self.paid_run_ids[run_id] = true
    self.pending_by_userid[userid] = self.pending_by_userid[userid] or {}
    table.insert(self.pending_by_userid[userid], { run_id = run_id, items = snapshots })
    return true
end

function Rewards:Claim(player)
    if not self:CanUse(player) then return 0 end
    local private = self.inst.GetRewardContainer ~= nil and self.inst:GetRewardContainer(player, true) or self.inst
    local container = private ~= nil and private.components ~= nil and private.components.container or nil
    if container == nil then return 0 end
    local queue = self.pending_by_userid[player.userid] or {}
    local delivered = 0
    while #queue > 0 do
        local queued = queue[1]
        while #queued.items > 0 do
            local item = SpawnSaveRecord(Copy(queued.items[1]))
            if item == nil then return delivered end
            if not container:GiveItem(item, nil, nil, false) then
                -- Native GiveItem may merge part of a stack before reporting
                -- failure when no empty slot remains. Persist only the exact
                -- remainder and suppress the component's default world drop.
                if item.IsValid ~= nil and item:IsValid() and item.GetSaveRecord ~= nil then
                    local remainder = item:GetSaveRecord()
                    if remainder ~= nil then queued.items[1] = remainder end
                    item:Remove()
                end
                return delivered
            end
            table.remove(queued.items, 1)
            delivered = delivered + 1
        end
        table.remove(queue, 1)
    end
    if #queue == 0 then self.pending_by_userid[player.userid] = nil end
    return delivered
end

function Rewards:HasPending(userid)
    if userid ~= nil then
        return self.pending_by_userid[userid] ~= nil and #self.pending_by_userid[userid] > 0
    end
    return next(self.pending_by_userid) ~= nil
end

function Rewards:OnSave()
    return {
        version = 2,
        pending_by_userid = Copy(self.pending_by_userid),
        paid_run_ids = Copy(self.paid_run_ids),
    }
end

function Rewards:OnLoad(data)
    data = data or {}
    self.pending_by_userid = type(data.pending_by_userid) == "table" and Copy(data.pending_by_userid) or {}
    -- v1 stored one owner's queue directly; migrate without rerolling records.
    if next(self.pending_by_userid) == nil and type(data.owner_userid) == "string"
        and type(data.pending) == "table" and #data.pending > 0 then
        self.pending_by_userid[data.owner_userid] = Copy(data.pending)
    end
    self.paid_run_ids = type(data.paid_run_ids) == "table" and Copy(data.paid_run_ids) or {}
end

function Rewards:OnRemoveFromEntity()
    self:BackupToAuthorities(self.inst._ttk_private)
end

return Rewards
