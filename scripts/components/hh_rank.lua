local RankDefs = require("guild/hh_rank_defs")
local ExamDefs = require("guild/hh_rank_exam_defs")
local Event = require("guild/hh_guild_event")
local IsSurfaceAuthority = require("utils/hh_dungeon_authority")

local STATUS_LOCKED = 0
local STATUS_AVAILABLE = 1
local STATUS_ACTIVE = 2
local STATUS_COMPLETED = 3
local STATUS_CLAIMED = 4

local function GetLevel(inst)
    local leveling = inst.components and inst.components.hh_leveling
    return leveling and leveling.level or 1
end

local function PlayRewardPresentation(inst)
    if inst.sg ~= nil then
        inst.sg:GoToState("emote", {
            anim = "emoteXL_happycheer",
            mounted = true,
            mountsound = "yell",
        })
    end

    local fx = SpawnPrefab("hh_guild_complete_fx")
    if fx ~= nil then
        fx.entity:SetParent(inst.entity)
        fx.Transform:SetPosition(0, 0, 0)
    end
end

local function GetItemDisplayName(prefab)
    local names = STRINGS and STRINGS.NAMES
    return names and names[string.upper(prefab)] or prefab
end

local function EncodeRewards(items, credit)
    local parts = {}
    for prefab, amount in pairs(items or {}) do
        table.insert(parts, GetItemDisplayName(prefab) .. " x" .. tostring(amount))
    end
    table.sort(parts)
    if (credit or 0) > 0 then
        table.insert(parts, 1, "Xu Hiệp Hội x" .. tostring(credit))
    end
    return table.concat(parts, ",")
end

local REWARD_CAPACITY_FAILURE = "Bạn không có đủ ô trống trong hành trang để nhận phần thưởng"
local REWARD_GENERIC_FAILURE = "Không thể nhận phần thưởng lúc này."
local MAX_PENDING_ITEM_AMOUNT = 2000000000

local function RemoveTemporaryEntity(inst)
    if inst ~= nil and inst.IsValid ~= nil and inst:IsValid() and inst.Remove ~= nil then
        pcall(inst.Remove, inst)
    end
end

local function NormalizeRewardAmount(value)
    if value == nil then
        return 0, true
    end
    local amount = tonumber(value)
    if amount == nil or amount ~= amount or amount <= 0 or amount == math.huge
        or amount > MAX_PENDING_ITEM_AMOUNT then
        return nil, false
    end
    return math.floor(amount), true
end

local function SafeSpawnPrefab(prefab)
    if type(SpawnPrefab) ~= "function" then
        return nil
    end
    local ok, item = pcall(SpawnPrefab, prefab)
    if not ok then
        return nil
    end
    return item
end

local function GetStackMetadata(item)
    local stackable = item ~= nil and item.components ~= nil and item.components.stackable or nil
    if stackable == nil then
        return nil, 1
    end
    local maxsize = tonumber(stackable.maxsize)
    if maxsize == nil or maxsize <= 0 then
        return nil, nil
    end
    if maxsize ~= math.huge then
        maxsize = math.max(1, math.floor(maxsize))
    end
    if type(stackable.StackSize) ~= "function" or type(stackable.SetStackSize) ~= "function" then
        return nil, nil
    end
    local ok, size = pcall(stackable.StackSize, stackable)
    if not ok or tonumber(size) == nil then
        return nil, nil
    end
    return stackable, maxsize
end

local function SafeGetItem(container, slot)
    if container == nil or type(container.GetItemInSlot) ~= "function" then
        return nil, false
    end
    local ok, item = pcall(container.GetItemInSlot, container, slot)
    return item, ok
end

local function SafeCanTakeItemInSlot(container, item, slot)
    if container == nil or type(container.CanTakeItemInSlot) ~= "function" then
        return false
    end
    local ok, can_take = pcall(container.CanTakeItemInSlot, container, item, slot)
    return ok and can_take == true
end

local function SafeContainerMethod(container, method_name, ...)
    if container == nil or type(container[method_name]) ~= "function" then
        return false, nil
    end
    return pcall(container[method_name], container, ...)
end

local function CanUseOverflowForItem(item, container)
    local inventoryitem = item ~= nil and item.components ~= nil and item.components.inventoryitem or nil
    if inventoryitem == nil or container == nil then
        return false
    end
    if inventoryitem.canonlygoinpocket then
        return false
    end
    if inventoryitem.canonlygoinpocketorpocketcontainers then
        local owner_item = container.inst ~= nil and container.inst.components ~= nil
            and container.inst.components.inventoryitem or nil
        return owner_item ~= nil and owner_item.canonlygoinpocket == true
    end
    return true
end

local function ContainerAcceptsStacks(container)
    if container == nil then
        return false
    end
    if type(container.AcceptsStacks) == "function" then
        local ok, accepts = pcall(container.AcceptsStacks, container)
        if ok then
            return accepts == true
        end
    end
    return container.acceptsstacks ~= false
end

local function SafeCanStackWith(stack, probe)
    if stack == nil or stack.item == nil or probe == nil then
        return false
    end
    local stackable = stack.item.components ~= nil and stack.item.components.stackable or nil
    if stackable == nil or type(stackable.CanStackWith) ~= "function" then
        return false
    end
    local ok, can_stack = pcall(stackable.CanStackWith, stackable, probe)
    return ok and can_stack == true
end

local function AddVirtualSlot(state, kind, container, slot, item)
    local virtual_slot = {
        kind = kind,
        container = container,
        slot = slot,
        item = item,
        occupied = item ~= nil,
        stack = nil,
    }
    table.insert(state[kind .. "_slots"], virtual_slot)

    if item ~= nil and item.components ~= nil and item.components.stackable ~= nil then
        local stackable, maxsize = GetStackMetadata(item)
        if stackable ~= nil and maxsize ~= nil then
            local ok, size = pcall(stackable.StackSize, stackable)
            if ok and tonumber(size) ~= nil then
                virtual_slot.stack = {
                    item = item,
                    size = math.max(0, tonumber(size)),
                    maxsize = maxsize,
                    kind = kind,
                    container = container,
                    slot = virtual_slot,
                }
                table.insert(state.stacks, virtual_slot.stack)
            end
        end
    end
    return virtual_slot
end

local function BuildVirtualInventoryState(inventory)
    if inventory == nil or type(inventory.GetItemInSlot) ~= "function" then
        return nil
    end

    local state = {
        base_slots = {},
        overflow_slots = {},
        specialized_slots = {},
        specialized_entries = {},
        stacks = {},
        overflow = nil,
    }

    for slot = 1, tonumber(inventory.maxslots) or 0 do
        local item, ok = SafeGetItem(inventory, slot)
        if not ok then
            return nil
        end
        AddVirtualSlot(state, "base", inventory, slot, item)
    end

    local overflow_ok, overflow = SafeContainerMethod(inventory, "GetOverflowContainer")
    if overflow_ok and overflow ~= nil then
        state.overflow = overflow
        local get_num_slots = type(overflow.GetNumSlots) == "function"
            and overflow.GetNumSlots or nil
        local ok, num_slots = false, nil
        if get_num_slots ~= nil then
            ok, num_slots = pcall(get_num_slots, overflow)
        end
        if not ok or tonumber(num_slots) == nil then
            return nil
        end
        for slot = 1, tonumber(num_slots) do
            local item, item_ok = SafeGetItem(overflow, slot)
            if not item_ok then
                return nil
            end
            AddVirtualSlot(state, "overflow", overflow, slot, item)
        end
    end

    local specialized_ok, specialized = SafeContainerMethod(inventory, "GetSpecializedContainers")
    if specialized_ok then
        for _, container in ipairs(specialized or {}) do
            if container ~= nil then
                local entry = { container = container, slots = {} }
                table.insert(state.specialized_entries, entry)
                local get_num_slots = type(container.GetNumSlots) == "function"
                    and container.GetNumSlots or nil
                local ok, num_slots = false, nil
                if get_num_slots ~= nil then
                    ok, num_slots = pcall(get_num_slots, container)
                end
                if not ok or tonumber(num_slots) == nil then
                    return nil
                end
                for slot = 1, tonumber(num_slots) do
                    local item, item_ok = SafeGetItem(container, slot)
                    if not item_ok then
                        return nil
                    end
                    local virtual_slot = AddVirtualSlot(state, "specialized", container, slot, item)
                    table.insert(entry.slots, virtual_slot)
                end
            end
        end
    end

    for _, item in pairs(inventory.equipslots or {}) do
        local equippable = item ~= nil and item.components ~= nil and item.components.equippable or nil
        local stackable = item ~= nil and item.components ~= nil and item.components.stackable or nil
        if equippable ~= nil and equippable.equipstack and stackable ~= nil then
            local stack_component, maxsize = GetStackMetadata(item)
            if stack_component == nil or maxsize == nil then
                return nil
            end
            local ok, size = pcall(stack_component.StackSize, stack_component)
            if not ok or tonumber(size) == nil then
                return nil
            end
            table.insert(state.stacks, {
                item = item,
                size = math.max(0, tonumber(size)),
                maxsize = maxsize,
                kind = "equip",
                container = inventory,
                slot = nil,
            })
        end
    end

    return state
end

local function GetSpecializedForItem(state, probe)
    local selected = {}
    for _, entry in ipairs(state.specialized_entries or {}) do
        local ok, prioritized = SafeContainerMethod(entry.container, "ShouldPrioritizeContainer", probe)
        if ok and prioritized and CanUseOverflowForItem(probe, entry.container) then
            selected[entry.container] = true
        end
    end
    return selected
end

local function IsVirtualStackEligible(stack, useoverflow, selected_specialized)
    if stack.kind == "overflow" then
        return useoverflow
    elseif stack.kind == "specialized" then
        return selected_specialized[stack.container] == true
    end
    return true
end

local function FindCompatibleVirtualStack(state, probe, useoverflow, selected_specialized)
    for _, stack in ipairs(state.stacks) do
        if stack.size < stack.maxsize
            and IsVirtualStackEligible(stack, useoverflow, selected_specialized)
            and SafeCanStackWith(stack, probe) then
            return stack
        end
    end
    return nil
end

local function FindFreeVirtualSlot(slots, item, container)
    for _, virtual_slot in ipairs(slots or {}) do
        if not virtual_slot.occupied and SafeCanTakeItemInSlot(container, item, virtual_slot.slot) then
            return virtual_slot
        end
    end
    return nil
end

local function PlaceVirtualChunk(state, inventory, descriptor, chunk)
    local probe = descriptor.probe
    local overflow = state.overflow
    local useoverflow = overflow ~= nil and CanUseOverflowForItem(probe, overflow)
    local overflow_prioritized = false
    if useoverflow then
        local ok, prioritized = SafeContainerMethod(overflow, "ShouldPrioritizeContainer", probe)
        overflow_prioritized = ok and prioritized == true
    end
    local selected_specialized = GetSpecializedForItem(state, probe)
    local remaining = chunk

    while remaining > 0 do
        local stack = FindCompatibleVirtualStack(state, probe, useoverflow, selected_specialized)
        if stack ~= nil then
            local room = math.max(0, stack.maxsize - stack.size)
            local accepted = math.min(remaining, room)
            if accepted <= 0 then
                return false
            end
            stack.size = stack.size + accepted
            remaining = remaining - accepted
        else
            local virtual_slot = nil
            if useoverflow and overflow_prioritized then
                virtual_slot = FindFreeVirtualSlot(state.overflow_slots, probe, overflow)
            end
            if virtual_slot == nil then
                for _, entry in ipairs(state.specialized_entries or {}) do
                    if selected_specialized[entry.container] then
                        virtual_slot = FindFreeVirtualSlot(entry.slots, probe, entry.container)
                        if virtual_slot ~= nil then
                            break
                        end
                    end
                end
            end
            if virtual_slot == nil then
                virtual_slot = FindFreeVirtualSlot(state.base_slots, probe, inventory)
            end
            if virtual_slot == nil and useoverflow and not overflow_prioritized then
                virtual_slot = FindFreeVirtualSlot(state.overflow_slots, probe, overflow)
            end
            if virtual_slot == nil then
                return false
            end
            if remaining > 1 and not ContainerAcceptsStacks(virtual_slot.container) then
                return false
            end
            virtual_slot.occupied = true
            virtual_slot.stack = {
                item = probe,
                size = remaining,
                maxsize = descriptor.maxsize,
                kind = virtual_slot.kind,
                container = virtual_slot.container,
                slot = virtual_slot,
            }
            table.insert(state.stacks, virtual_slot.stack)
            remaining = 0
        end
    end
    return true
end

local function BuildRewardDescriptors(items)
    local descriptors = {}
    for _, itemdata in ipairs(items or {}) do
        local amount, amount_valid = NormalizeRewardAmount(itemdata ~= nil and itemdata.amount or nil)
        if not amount_valid then
            for _, descriptor in ipairs(descriptors) do
                RemoveTemporaryEntity(descriptor.probe)
            end
            return nil, "invalid"
        end
        if amount > 0 then
            local prefab = itemdata.prefab
            if type(prefab) ~= "string" then
                for _, descriptor in ipairs(descriptors) do
                    RemoveTemporaryEntity(descriptor.probe)
                end
                return nil, "invalid"
            end
            local probe = SafeSpawnPrefab(prefab)
            if probe == nil or probe.prefab ~= prefab
                or probe.components == nil or probe.components.inventoryitem == nil then
                RemoveTemporaryEntity(probe)
                for _, descriptor in ipairs(descriptors) do
                    RemoveTemporaryEntity(descriptor.probe)
                end
                return nil, "invalid"
            end
            local _, maxsize = GetStackMetadata(probe)
            if maxsize == nil then
                RemoveTemporaryEntity(probe)
                for _, descriptor in ipairs(descriptors) do
                    RemoveTemporaryEntity(descriptor.probe)
                end
                return nil, "invalid"
            end
            table.insert(descriptors, {
                prefab = prefab,
                amount = amount,
                probe = probe,
                maxsize = maxsize,
            })
        end
    end
    return descriptors, nil
end

local function PreflightReward(inventory, items)
    if inventory == nil then
        return false, nil, "invalid"
    end
    local descriptors, descriptor_reason = BuildRewardDescriptors(items)
    if descriptors == nil then
        return false, nil, descriptor_reason
    end
    local state = BuildVirtualInventoryState(inventory)
    if state == nil then
        for _, descriptor in ipairs(descriptors) do
            RemoveTemporaryEntity(descriptor.probe)
        end
        return false, nil, "invalid"
    end
    for _, descriptor in ipairs(descriptors) do
        local remaining = descriptor.amount
        while remaining > 0 do
            local chunk = math.min(remaining, descriptor.maxsize)
            if not PlaceVirtualChunk(state, inventory, descriptor, chunk) then
                for _, cleanup_descriptor in ipairs(descriptors) do
                    RemoveTemporaryEntity(cleanup_descriptor.probe)
                end
                return false, nil, "capacity"
            end
            remaining = remaining - chunk
        end
    end
    return true, descriptors, nil
end

local function CaptureInventorySnapshot(inventory)
    local snapshot = {}
    local seen = {}
    local function Capture(item)
        if item == nil or seen[item] or item.components == nil or item.components.stackable == nil then
            return
        end
        local stackable, maxsize = GetStackMetadata(item)
        if stackable == nil or maxsize == nil then
            return
        end
        local ok, size = pcall(stackable.StackSize, stackable)
        if ok and tonumber(size) ~= nil then
            seen[item] = true
            table.insert(snapshot, { item = item, size = math.max(0, tonumber(size)) })
        end
    end

    if type(inventory.FindItems) == "function" then
        local ok, items = pcall(inventory.FindItems, inventory, function(item)
            return item ~= nil
        end)
        if ok then
            for _, item in ipairs(items or {}) do
                Capture(item)
            end
        end
    end
    local specialized_ok, specialized = SafeContainerMethod(inventory, "GetSpecializedContainers")
    if specialized_ok then
        for _, container in ipairs(specialized or {}) do
            if container ~= nil and type(container.GetAllItems) == "function" then
                local ok, items = pcall(container.GetAllItems, container)
                if ok then
                    for _, item in ipairs(items or {}) do
                        Capture(item)
                    end
                end
            end
        end
    end
    return snapshot
end

local function IsOwnedByRewardInventory(item, inventory)
    if item == nil or item.components == nil or item.components.inventoryitem == nil then
        return false
    end
    local owner = item.components.inventoryitem.owner
    if owner == inventory.inst then
        return true
    end
    local overflow_ok, overflow = SafeContainerMethod(inventory, "GetOverflowContainer")
    if overflow_ok and overflow ~= nil and overflow.inst == owner then
        return true
    end
    local specialized_ok, specialized = SafeContainerMethod(inventory, "GetSpecializedContainers")
    if specialized_ok then
        for _, container in ipairs(specialized or {}) do
            if container ~= nil and container.inst == owner then
                return true
            end
        end
    end
    return false
end

local function RemoveCommittedRewardItem(item, inventory)
    if item == nil or item.IsValid == nil or not item:IsValid() then
        return
    end
    local inventoryitem = item.components ~= nil and item.components.inventoryitem or nil
    local owner = inventoryitem ~= nil and inventoryitem.owner or nil
    if owner ~= nil and owner.components ~= nil then
        if owner.components.container ~= nil and type(owner.components.container.RemoveItem) == "function" then
            pcall(owner.components.container.RemoveItem, owner.components.container, item, true)
        elseif owner.components.inventory ~= nil and type(owner.components.inventory.RemoveItem) == "function" then
            pcall(owner.components.inventory.RemoveItem, owner.components.inventory, item, true, true)
        elseif inventory ~= nil and type(inventory.RemoveItem) == "function" then
            pcall(inventory.RemoveItem, inventory, item, true, true)
        end
    end
    RemoveTemporaryEntity(item)
end

local function RollbackRewardCommit(inventory, prepared, snapshot)
    for _, item in ipairs(prepared or {}) do
        RemoveCommittedRewardItem(item, inventory)
    end
    for _, saved in ipairs(snapshot or {}) do
        local item = saved.item
        local stackable = item ~= nil and item.components ~= nil and item.components.stackable or nil
        if item ~= nil and item.IsValid ~= nil and item:IsValid()
            and stackable ~= nil and type(stackable.SetStackSize) == "function" then
            pcall(stackable.SetStackSize, stackable, saved.size)
        end
    end
end

local function PrepareRewardItems(descriptors)
    local prepared = {}
    for _, descriptor in ipairs(descriptors or {}) do
        local remaining = descriptor.amount
        while remaining > 0 do
            local stack_size = math.min(remaining, descriptor.maxsize)
            local item = SafeSpawnPrefab(descriptor.prefab)
            local inventoryitem = item ~= nil and item.components ~= nil and item.components.inventoryitem or nil
            if item == nil or item.prefab ~= descriptor.prefab or inventoryitem == nil then
                RemoveTemporaryEntity(item)
                for _, prepared_item in ipairs(prepared) do
                    RemoveTemporaryEntity(prepared_item)
                end
                return nil, "invalid"
            end

            local stackable, actual_maxsize = GetStackMetadata(item)
            local has_stack_component = item.components ~= nil and item.components.stackable ~= nil
            if (has_stack_component and (stackable == nil or actual_maxsize == nil))
                or (stack_size > 1 and (stackable == nil or actual_maxsize == nil or actual_maxsize < stack_size)) then
                RemoveTemporaryEntity(item)
                for _, prepared_item in ipairs(prepared) do
                    RemoveTemporaryEntity(prepared_item)
                end
                return nil, "invalid"
            end
            if stackable ~= nil then
                local ok = pcall(stackable.SetStackSize, stackable, stack_size)
                if not ok then
                    RemoveTemporaryEntity(item)
                    for _, prepared_item in ipairs(prepared) do
                        RemoveTemporaryEntity(prepared_item)
                    end
                    return nil, "invalid"
                end
            end
            table.insert(prepared, item)
            remaining = remaining - stack_size
        end
    end
    return prepared, nil
end

local HHRank = Class(function(self, inst)
    self.inst = inst
    self.version = 1
    self.rank = RankDefs.RANK.E
    self.credit = 0
    self.exam_states = {}
    self.exam_id = 0
    self.exam_status = STATUS_LOCKED
    self.exam_progress = 0
    self.exam_target = 0
    self.exam_seen = {}
    self.exam_notified = {}
    self.pending_items = {}
    self.pending_credit = 0
    self.pending_exam_reward = false
    self.notice = ""
    self.interface_staff = nil
    self.interface_monitor_task = nil

    inst:ListenForEvent("ms_becameghost", function()
        self:CloseInterface()
    end)

    inst:ListenForEvent("ms_playerleft", function(_, player)
        if player == inst then
            self:CloseInterface()
        end
    end, TheWorld)

    inst:ListenForEvent("hh_levelup", function()
        self:ReconcileLevelPromotion()
    end)

    for _, exam in ipairs(ExamDefs.list) do
        self.exam_states[exam.id] = STATUS_LOCKED
    end
    self:RefreshExamAvailability()
    self:Sync()
end)

function HHRank:Sync()
    local inst = self.inst
    if inst.hh_guild_rank then inst.hh_guild_rank:set(self.rank) end
    if inst.hh_guild_credit then inst.hh_guild_credit:set(math.floor(self.credit)) end
    if inst.hh_guild_exam_id then inst.hh_guild_exam_id:set(self.exam_id or 0) end
    if inst.hh_guild_exam_status then inst.hh_guild_exam_status:set(self.exam_status or STATUS_LOCKED) end
    if inst.hh_guild_exam_progress then inst.hh_guild_exam_progress:set(math.floor(math.min(self.exam_progress or 0, 65535))) end
    if inst.hh_guild_exam_target then inst.hh_guild_exam_target:set(math.floor(math.min(self.exam_target or 0, 65535))) end
    if inst.hh_guild_exam_states then
        local states = {}
        for id = 1, #ExamDefs.list do
            table.insert(states, tostring(self.exam_states[id] or STATUS_LOCKED))
        end
        inst.hh_guild_exam_states:set(table.concat(states, ","))
    end
    if inst.hh_guild_pending_reward then
        inst.hh_guild_pending_reward:set(EncodeRewards(self.pending_items, self.pending_credit))
    end
    if inst.hh_guild_notice then
        inst.hh_guild_notice:set(self.notice or "")
    end
end

function HHRank:SetNotice(message)
    self.notice = tostring(message or "")
    self:Sync()
end

function HHRank:AddCredit(amount)
    amount = math.max(0, math.floor(tonumber(amount) or 0))
    if amount > 0 then
        self.credit = math.min(2000000000, self.credit + amount)
    end
    self:Sync()
end

function HHRank:SpendCredit(amount)
    amount = math.max(0, math.floor(tonumber(amount) or 0))
    if amount <= 0 or self.credit < amount then
        return false
    end
    self.credit = self.credit - amount
    self:Sync()
    return true
end

function HHRank:GetRank()
    return self.rank
end

function HHRank:ReconcileLevelPromotion()
    local old_rank = self.rank
    if old_rank < RankDefs.RANK.S then
        return false
    end

    local level_rank = RankDefs.GetRankForLevel(GetLevel(self.inst))
    if level_rank <= self.rank then
        return false
    end

    self.rank = level_rank
    self.inst:PushEvent("hh_rank_changed", {
        old_rank = old_rank,
        new_rank = self.rank,
        source = "level_promotion",
    })
    local quest = self.inst.components.hh_guild_quest
    if quest then
        quest:RefreshOffers()
    end
    self:RefreshExamAvailability()
    self:Sync()
    return true
end

function HHRank:AddPendingItems(items)
    for _, item in ipairs(items or {}) do
        local amount = math.max(0, math.floor(tonumber(item.amount) or 0))
        if item.prefab and amount > 0 then
            self.pending_items[item.prefab] = (self.pending_items[item.prefab] or 0) + amount
        end
    end
    self:Sync()
end

function HHRank:AddPendingCredit(amount)
    amount = math.max(0, math.floor(tonumber(amount) or 0))
    if amount > 0 then
        self.pending_credit = math.min(2000000000, (self.pending_credit or 0) + amount)
    end
    self:Sync()
end

function HHRank:CanReceiveItems(items)
    local inventory = self.inst.components.inventory
    local ok, descriptors = PreflightReward(inventory, items)
    for _, descriptor in ipairs(descriptors or {}) do
        RemoveTemporaryEntity(descriptor.probe)
    end
    return ok
end

function HHRank:GiveItems(items, commit)
    local inventory = self.inst.components.inventory
    local preflight_ok, descriptors, preflight_reason = PreflightReward(inventory, items)
    if not preflight_ok then
        return false, preflight_reason
    end

    local prepared, prepare_reason = PrepareRewardItems(descriptors)
    for _, descriptor in ipairs(descriptors or {}) do
        RemoveTemporaryEntity(descriptor.probe)
    end
    if prepared == nil then
        return false, prepare_reason
    end

    local snapshot = CaptureInventorySnapshot(inventory)
    local previous_ignorefull = inventory.ignorefull
    inventory.ignorefull = true
    local committed = true
    for _, item in ipairs(prepared) do
        local give_item = inventory.GiveItem
        local call_ok, placed = false, nil
        if type(give_item) == "function" then
            call_ok, placed = pcall(give_item, inventory, item)
        end
        if not call_ok or placed == nil or placed == false then
            committed = false
            break
        end
        local still_valid = item ~= nil and item.IsValid ~= nil and item:IsValid()
        if still_valid and not IsOwnedByRewardInventory(item, inventory) then
            committed = false
            break
        end
    end
    inventory.ignorefull = previous_ignorefull

    -- Purchases keep the delivery snapshot until their debit succeeds.
    if committed and commit ~= nil then
        local ok, result = pcall(commit)
        committed = ok and result == true
    end
    if not committed then
        RollbackRewardCommit(inventory, prepared, snapshot)
        return false, "commit"
    end
    return true, nil
end

function HHRank:ClaimPendingRewards()
    local items = {}
    for prefab, amount in pairs(self.pending_items or {}) do
        table.insert(items, { prefab=prefab, amount=amount })
    end
    local credit = math.max(0, math.floor(tonumber(self.pending_credit) or 0))
    local had_pending_exam_reward = self.pending_exam_reward == true
    if #items == 0 and credit <= 0 then
        self:SetNotice("Hiện không có phần thưởng chờ nhận.")
        return false
    end

    if (credit > 0 or #items > 0) and self.inst.components.inventory == nil then
        self:SetNotice(REWARD_GENERIC_FAILURE)
        return false
    end

    if #items > 0 then
        local claimed, failure_reason = self:GiveItems(items)
        if not claimed then
            if failure_reason == "capacity" then
                local talker = self.inst.components.talker
                if talker ~= nil and type(talker.Say) == "function" then
                    talker:Say(REWARD_CAPACITY_FAILURE)
                end
                self:SetNotice(REWARD_CAPACITY_FAILURE)
            else
                self:SetNotice(REWARD_GENERIC_FAILURE)
            end
            return false
        end
    end
    self.pending_items = {}
    self.pending_credit = 0
    if had_pending_exam_reward then
        self.pending_exam_reward = false
    end
    if credit > 0 then
        self.credit = math.min(2000000000, self.credit + credit)
    end
    local quest = self.inst.components.hh_guild_quest
    if quest then
        quest:OnRewardClaimed()
    end
    PlayRewardPresentation(self.inst)
    TheNet:Announce("Thợ Săn " .. self.inst:GetDisplayName() .. " đã hoàn thành một nhiệm vụ hiệp hội !")
    self:SetNotice("Đã nhận toàn bộ phần thưởng Guild và " .. tostring(credit) .. " Xu Hiệp Hội.")
    if had_pending_exam_reward then
        self:RefreshExamAvailability()
    end
    return true
end

function HHRank:NotifyExamAvailable(exam)
    if self.exam_notified[exam.id] then
        return
    end
    self.exam_notified[exam.id] = true
    local message = "Bạn đã đủ điều kiện để bắt đầu làm nhiệm vụ thăng hạng !"
    self.notice = message
    self.inst:PushEvent("hh_guild_rank_exam_available", { exam_id=exam.id, rank=exam.rank })
    if self.inst.components.talker then
        self.inst:DoTaskInTime(0, function()
            if self.inst:IsValid() and self.inst.components.talker then
                self.inst.components.talker:Say(message)
            end
        end)
    end
end

function HHRank:RefreshExamAvailability()
    if self.pending_exam_reward then
        self:Sync()
        return
    end

    local next_rank = RankDefs.GetNextRank(self.rank)
    if next_rank == nil then
        self.exam_id = 0
        self.exam_status = STATUS_CLAIMED
        self.exam_progress = 0
        self.exam_target = 0
        self:Sync()
        return
    end

    local exam = nil
    for _, candidate in ipairs(ExamDefs.list) do
        if candidate.rank == next_rank then
            exam = candidate
            break
        end
    end
    if exam == nil then
        self.exam_id = 0
        self.exam_status = STATUS_CLAIMED
        self.exam_progress = 0
        self.exam_target = 0
        self:Sync()
        return
    end

    local state = self.exam_states[exam.id] or STATUS_LOCKED
    if state == STATUS_CLAIMED then
        self.exam_id = exam.id
        self.exam_status = STATUS_CLAIMED
        self.exam_target = exam.target
        self:Sync()
        return
    end

    if GetLevel(self.inst) >= RankDefs.GetRequiredLevel(next_rank) then
        if state == STATUS_LOCKED then
            state = STATUS_AVAILABLE
            self.exam_states[exam.id] = state
        end
    end
    if state == STATUS_AVAILABLE then
        self:NotifyExamAvailable(exam)
    end
    self.exam_id = exam.id
    self.exam_status = state
    self.exam_target = exam.target
    self:Sync()
end

function HHRank:StartExam()
    if self.pending_exam_reward then
        self:SetNotice("Bạn phải nhận phần thưởng Rank trước khi nhận Rank Exam tiếp theo.")
        return false
    end

    self:RefreshExamAvailability()
    local exam = ExamDefs.Get(self.exam_id)
    if exam == nil or self.exam_status ~= STATUS_AVAILABLE then
        self:SetNotice("Bạn chưa đủ điều kiện nhận Rank Exam kế tiếp.")
        return false
    end
    self.exam_status = STATUS_ACTIVE
    self.exam_states[exam.id] = STATUS_ACTIVE
    self.exam_progress = 0
    self.exam_target = exam.target
    self.exam_seen = {}
    self:SetNotice("Đã nhận " .. exam.title .. ".")
    return true
end

function HHRank:CompleteExam()
    local exam = ExamDefs.Get(self.exam_id)
    if exam == nil or self.exam_status ~= STATUS_ACTIVE then
        return
    end
    self.exam_progress = self.exam_target
    self.exam_status = STATUS_COMPLETED
    self.exam_states[exam.id] = STATUS_COMPLETED
    local fx = SpawnPrefab("hh_guild_complete_fx")
    if fx then
        fx.entity:SetParent(self.inst.entity)
        fx.Transform:SetPosition(0, 0, 0)
    end
    if self.inst.components.talker then
        self.inst.components.talker:Say("Rank Exam đã hoàn thành! Hãy trở về Hiệp Hội.")
    end
    self:SetNotice("Đã hoàn thành Rank Exam. Hãy quay lại Nhân Viên Hiệp Hội để xác nhận Rank.")
end

function HHRank:ClaimExam()
    if not IsSurfaceAuthority(TheWorld) then return false end
    local exam = ExamDefs.Get(self.exam_id)
    if exam == nil or self.exam_status ~= STATUS_COMPLETED then
        self:SetNotice("Rank Exam chưa hoàn thành.")
        return false
    end
    if exam.rank ~= self.rank + 1 then
        self:SetNotice("Rank Exam không hợp lệ với Rank hiện tại.")
        return false
    end

    local old_rank = self.rank
    self.rank = exam.rank
    self.exam_states[exam.id] = STATUS_CLAIMED
    self.exam_status = STATUS_CLAIMED
    self.inst:PushEvent("hh_rank_changed", {
        old_rank = old_rank,
        new_rank = self.rank,
        source = "claim_exam",
    })
    local fx = SpawnPrefab("hh_guild_complete_fx")
    if fx then
        fx.entity:SetParent(self.inst.entity)
        fx.Transform:SetPosition(0, 0, 0)
    end
    self:AddCredit(exam.reward_credit)
    self:AddPendingItems(exam.reward_items)
    self.pending_exam_reward = true
    local level_promoted = self:ReconcileLevelPromotion()
    if not level_promoted then
        self:RefreshExamAvailability()
    end
    if not level_promoted then
        local quest = self.inst.components.hh_guild_quest
        if quest then
            quest:RefreshOffers()
        end
    end
    if self.inst.components.talker then
        self.inst.components.talker:Say("Thăng hạng thành công! Rank " .. RankDefs.GetName(self.rank) .. ".")
    end
    self:SetNotice("Chúc mừng! Bạn đã đạt Rank " .. RankDefs.GetName(self.rank) .. ".")
    return true
end

function HHRank:TryProgressFromEvent(event_name, data, quest_defs)
    local exam = ExamDefs.Get(self.exam_id)
    if exam == nil or self.exam_status ~= STATUS_ACTIVE then
        return
    end

    local tracker = exam.tracker
    local target = Event.GetTarget(data)
    local prefab = Event.GetPrefab(target) or (data and data.prefab)
    local matched = false

    if tracker == "killed" and event_name == "killed" then
        if data and data.attacker ~= nil and data.attacker ~= self.inst then
            return
        end
        matched = quest_defs.MatchesGroup(exam.group, prefab)
    end

    if matched then
        self.exam_progress = math.min(self.exam_target, self.exam_progress + 1)
        if self.exam_progress >= self.exam_target then
            self:CompleteExam()
        else
            self:Sync()
        end
    end
end

function HHRank:OpenInterface(staff)
    if not IsSurfaceAuthority(TheWorld) or not self.inst:IsValid()
        or not self.inst:HasTag("player") or self.inst:HasTag("playerghost")
        or TheWorld.state.phase == "night" or staff == nil or not staff:IsValid()
        or staff.prefab ~= "guild_staff" or not staff:HasTag("hh_guild_employee")
        or staff.BeginGuildInteraction == nil or self.inst.hh_guild_ui_open == nil then
        return false
    end
    if self.interface_staff ~= nil
        and self.interface_staff ~= staff
        and self.interface_staff:IsValid()
        and self.interface_staff.EndGuildInteraction ~= nil then
        self.interface_staff:EndGuildInteraction(self.inst)
    end
    self.interface_staff = staff
    if staff ~= nil and staff:IsValid() and staff.BeginGuildInteraction ~= nil then
        staff:BeginGuildInteraction(self.inst)
    end
    if self.inst.hh_guild_ui_open then
        self.inst.hh_guild_ui_open:set(true)
    end
    if self.interface_monitor_task then
        self.interface_monitor_task:Cancel()
    end
    self.interface_monitor_task = self.inst:DoPeriodicTask(.25, function()
        if self.inst:HasTag("playerghost") or TheWorld.state.phase == "night" then
            self:CloseInterface()
        end
    end)
    self.inst:PushEvent("hh_guild_opened", { staff=staff })
    return true
end

function HHRank:CloseInterface()
    if self.interface_monitor_task then
        self.interface_monitor_task:Cancel()
        self.interface_monitor_task = nil
    end
    local staff = self.interface_staff
    self.interface_staff = nil
    if staff ~= nil and staff:IsValid() and staff.EndGuildInteraction ~= nil then
        staff:EndGuildInteraction(self.inst)
    end
    if self.inst.hh_guild_ui_open then
        self.inst.hh_guild_ui_open:set(false)
    end
end

function HHRank:OnSave()
    local exam_states = {}
    for id, state in pairs(self.exam_states) do
        exam_states[id] = state
    end
    return {
        version = self.version,
        rank = self.rank,
        credit = self.credit,
        exam_states = exam_states,
        exam_id = self.exam_id,
        exam_status = self.exam_status,
        exam_progress = self.exam_progress,
        exam_target = self.exam_target,
        pending_items = self.pending_items,
        pending_credit = self.pending_credit,
        pending_exam_reward = self.pending_exam_reward == true,
    }
end

function HHRank:OnLoad(data)
    if not data then
        return
    end
    self.rank = RankDefs.IsValidRank(data.rank) and data.rank or RankDefs.RANK.E
    self.credit = math.max(0, math.floor(tonumber(data.credit) or 0))
    self.exam_states = {}
    for _, exam in ipairs(ExamDefs.list) do
        self.exam_states[exam.id] = tonumber(data.exam_states and data.exam_states[exam.id]) or STATUS_LOCKED
    end
    self.exam_id = tonumber(data.exam_id) or 0
    self.exam_status = tonumber(data.exam_status) or STATUS_LOCKED
    self.exam_progress = math.max(0, tonumber(data.exam_progress) or 0)
    self.exam_target = math.max(0, tonumber(data.exam_target) or 0)
    self.pending_items = {}
    for prefab, amount in pairs(data.pending_items or {}) do
        if type(prefab) == "string" and tonumber(amount) and tonumber(amount) > 0 then
            self.pending_items[prefab] = math.floor(amount)
        end
    end
    self.pending_credit = math.max(0, math.floor(tonumber(data.pending_credit) or 0))
    self.pending_exam_reward = data.pending_exam_reward == true
    self:ReconcileLevelPromotion()
    self:RefreshExamAvailability()
    self:Sync()
    self.inst:DoTaskInTime(0, function(inst)
        if inst:IsValid() and inst.components.hh_rank == self then
            self:ReconcileLevelPromotion()
        end
    end)
end

return HHRank
