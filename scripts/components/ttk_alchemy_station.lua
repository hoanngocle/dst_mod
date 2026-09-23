local Rules = require("alchemy/ttk_alchemy_rules")
local Defs = require("alchemy/ttk_alchemy_defs")

local DURATION = 180

local AlchemyStation = Class(function(self, inst)
    self.inst = inst
    self.output = nil
    self.end_time = nil
    self.finish_task = nil
    self.finishing = false
end)

local function IsRemaining(value)
    return type(value) == "number"
        and value == value
        and value ~= math.huge
        and value ~= -math.huge
end

function AlchemyStation:IsBusy()
    return self.output ~= nil
end

-- DST prefabs/cursed_monkey_token.lua sets canonlygoinpocket; native Container
-- correctly rejects it. Only this canonical stage-10 requirement may be supplied
-- by the initiating player's actual pocket slots (never overflow/open containers).
local POCKET_TOKEN = "cursed_monkey_token"
local function PocketTokens(doer)
    local inventory = doer ~= nil and doer.components ~= nil and doer.components.inventory or nil
    if inventory == nil or inventory.inst ~= doer then return nil end
    local entries, total = {}, 0
    for slot, item in pairs(inventory.itemslots) do
        if item.prefab == POCKET_TOKEN then
            local invitem = item.components.inventoryitem
            local normalized = Rules.NormalizeStacks({ item })
            if not item:IsValid() or invitem == nil or invitem.owner ~= doer or normalized == nil then return nil end
            entries[#entries + 1] = { slot = slot, item = item, owner = inventory, size = normalized[POCKET_TOKEN] }
            total = total + normalized[POCKET_TOKEN]
        end
    end
    return entries, total
end

function AlchemyStation:GetRecipe(doer)
    local container = self.inst.components.container
    local items = container ~= nil and Rules.NormalizeStacks(container.slots) or nil
    if items == nil or items[POCKET_TOKEN] ~= nil then return nil end
    local recipe, output = Rules.FindExactRecipe(items)
    if recipe ~= nil then return recipe, output end
    local pockets, total = PocketTokens(doer)
    if pockets == nil or total < 5 then return nil end
    items[POCKET_TOKEN] = 5
    recipe, output = Rules.FindExactRecipe(items)
    if recipe == nil or output ~= Defs.GetCultivationStage(10).prefab then return nil end
    local remaining = 5
    local selected = {}
    for _, entry in ipairs(pockets) do
        entry.amount = math.min(remaining, entry.size)
        selected[#selected + 1] = entry
        remaining = remaining - entry.amount
        if remaining == 0 then break end
    end
    return recipe, output, selected
end

function AlchemyStation:CanStart(doer)
    if self:IsBusy() then return false end
    local recipe, output = self:GetRecipe(doer)
    return recipe ~= nil and Rules.IsApprovedOutput(output)
end

function AlchemyStation:CancelFinishTask()
    if self.finish_task ~= nil then
        self.finish_task:Cancel()
        self.finish_task = nil
    end
end

function AlchemyStation:ScheduleFinish(remaining)
    self:CancelFinishTask()
    self.finish_task = self.inst:DoTaskInTime(math.max(0, remaining), function()
        self.finish_task = nil
        self:Finish()
    end)
end

function AlchemyStation:Start(doer)
    if not TheWorld.ismastersim or self:IsBusy() then return false end
    local container = self.inst.components.container
    local recipe, output, pockets = self:GetRecipe(doer)
    if container == nil or recipe == nil or not Rules.IsApprovedOutput(output) then return false end

    -- Snapshot before mutation. Save records preserve stack/item component state if
    -- an engine callback raises after an earlier input has already been removed.
    local consumed = {}
    for slot, item in pairs(container.slots) do
        if item == nil then return false end
        local size = Rules.NormalizeStacks({ item })[item.prefab]
        consumed[#consumed + 1] = { slot = slot, item = item, owner = container, size = size, amount = size }
    end
    if #consumed == 0 then return false end
    for _, entry in ipairs(pockets or {}) do consumed[#consumed + 1] = entry end
    for _, entry in ipairs(consumed) do
        local ok, record = pcall(entry.item.GetSaveRecord, entry.item)
        if not ok or record == nil then return false end
        entry.record = record
        local cursed = entry.item.components.curseditem
        if entry.item.prefab == POCKET_TOKEN and cursed ~= nil then
            -- Native Curseditem does not save these fields. Returning a restored
            -- token without applied_curse would add its curse to the owner twice.
            entry.cursed = { CopyCursedFields = cursed.CopyCursedFields }
            cursed:CopyCursedFields(entry.cursed)
            entry.applied_curse = entry.item:HasTag("applied_curse")
        end
    end

    -- Mark busy before callbacks; scheduling/closing can fail without consuming.
    self.output = output
    self.starting = true
    local ok = pcall(function()
        self.end_time = GetTime() + DURATION
        self:ScheduleFinish(DURATION)
        if self.finish_task == nil then error("Unable to schedule alchemy") end
        container:Close()
        for _, entry in ipairs(consumed) do
            local slots = entry.owner.itemslots or entry.owner.slots
            local totals = Rules.NormalizeStacks({ entry.item })
            if slots[entry.slot] ~= entry.item or not entry.item:IsValid()
                or totals == nil or totals[entry.item.prefab] ~= entry.size then
                error("Alchemy input changed during start")
            end
        end
        for _, entry in ipairs(consumed) do
            entry.touched = true
            if entry.amount < entry.size then
                entry.item.components.stackable:SetStackSize(entry.size - entry.amount)
                if entry.item.components.stackable:StackSize() ~= entry.size - entry.amount then
                    error("Alchemy stack consumption failed")
                end
            else
                entry.item:Remove()
                if entry.item:IsValid() then error("Alchemy item consumption failed") end
            end
        end
    end)
    if not ok then
        self:CancelFinishTask()
        for _, entry in ipairs(consumed) do
            if entry.touched then
                local item = entry.item:IsValid() and entry.item or SpawnSaveRecord(entry.record)
                assert(item ~= nil, "Unable to restore alchemy input")
                if entry.cursed ~= nil then
                    entry.cursed:CopyCursedFields(item.components.curseditem)
                    if entry.applied_curse then item:AddTag("applied_curse") end
                end
                if item.components.stackable ~= nil and item.components.stackable:StackSize() ~= entry.size then
                    item.components.stackable:SetStackSize(entry.size)
                end
                local slots = entry.owner.itemslots or entry.owner.slots
                if slots[entry.slot] ~= item then
                    assert(entry.owner:GiveItem(item, entry.slot), "Unable to return alchemy input")
                end
            end
        end
        self.output = nil
        self.end_time = nil
    end
    self.starting = false
    if not ok then return false end
    return true
end

function AlchemyStation:Finish()
    if self.starting or self.finishing or not self:IsBusy() then return false end
    self.finishing = true
    local output = self.output
    -- Clear/cancel before creating an item so re-entry cannot duplicate output.
    self.output = nil
    self.end_time = nil
    self:CancelFinishTask()

    local item = SpawnPrefab(output)
    local container = self.inst.components.container
    local placed = item ~= nil and container ~= nil and container:GiveItem(item, nil, nil, false)
    if item ~= nil and not placed and item:IsValid() then
        item.Transform:SetPosition(self.inst.Transform:GetWorldPosition())
    end
    self.finishing = false
    return item ~= nil
end

function AlchemyStation:OnSave()
    if not self:IsBusy() or not Rules.IsApprovedOutput(self.output) then return nil end
    local remaining = self.end_time - GetTime()
    if not IsRemaining(remaining) then return nil end
    return { output = self.output, remaining = math.max(0, remaining) }
end

function AlchemyStation:OnLoad(data)
    self:CancelFinishTask()
    self.output = nil
    self.end_time = nil
    if type(data) ~= "table" or not Rules.IsApprovedOutput(data.output) or not IsRemaining(data.remaining) then return end
    self.output = data.output
    self.end_time = GetTime() + math.max(0, data.remaining)
    self:ScheduleFinish(data.remaining)
end

function AlchemyStation:OnRemoveFromEntity()
    self:CancelFinishTask()
end

return AlchemyStation
