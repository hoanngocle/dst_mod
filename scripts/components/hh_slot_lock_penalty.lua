local SLOT_NAMES = { "hands", "body", "head" }
local PREFAB_PREFIX = "hh_daily_slot_lock_"

local function GetWorldSeconds()
    local cycles = TheWorld and TheWorld.state and TheWorld.state.cycles or 0
    local time = TheWorld and TheWorld.state and TheWorld.state.time or 0
    return math.floor((cycles + time) * TUNING.TOTAL_DAY_TIME)
end

local function GetEquipSlot(slot_name)
    return slot_name and EQUIPSLOTS[string.upper(slot_name)] or nil
end

local function IsSlotLockPrefab(item, slot_name)
    return item ~= nil
        and item:IsValid()
        and item:HasTag("hh_daily_slot_lock")
        and type(slot_name) == "string"
        and item.prefab == PREFAB_PREFIX .. slot_name
end

local function IsAnySlotLockPrefab(item)
    return item ~= nil
        and item:IsValid()
        and item:HasTag("hh_daily_slot_lock")
        and type(item.prefab) == "string"
        and string.sub(item.prefab, 1, #PREFAB_PREFIX) == PREFAB_PREFIX
end

local function IsPhysicalLockOwnedBy(player, item, slot_name)
    if player == nil or player.userid == nil
        or not IsSlotLockPrefab(item, slot_name)
        or item.hh_slot_lock_owner_userid ~= player.userid then
        return false
    end

    local inventoryitem = item.components ~= nil and item.components.inventoryitem or nil
    local grand_owner = inventoryitem ~= nil
        and inventoryitem.GetGrandOwner ~= nil
        and inventoryitem:GetGrandOwner() or nil
    return grand_owner == player
end

local function IsAlivePlayer(inst)
    return inst:IsValid()
        and not inst:HasTag("playerghost")
        and not (inst.components.health and inst.components.health:IsDead())
end

local HHSlotLockPenalty = Class(function(self, inst)
    self.inst = inst
    self.locked_slot = nil
    self.deadline = 0
    self.lock_item = nil
    self._reincarnation_detaching = false
    self._reincarnation_remaining = nil

    self.tick_task = inst:DoPeriodicTask(1, function()
        self:OnTick()
    end)

    inst:ListenForEvent("ms_respawnedfromghost", function()
        inst:DoTaskInTime(0, function()
            self:EnsureLock()
        end)
    end)
end)

function HHSlotLockPenalty:GetRemaining()
    return math.max(0, (self.deadline or 0) - GetWorldSeconds())
end

function HHSlotLockPenalty:IsActive()
    return self.locked_slot ~= nil and self:GetRemaining() > 0
end

function HHSlotLockPenalty:IsOwnedLockItem(item)
    return self:IsActive()
        and IsPhysicalLockOwnedBy(self.inst, item, self.locked_slot)
end

function HHSlotLockPenalty:CollectPhysicalLockItems(slot_name)
    local items = {}
    local seen = {}
    local inventory = self.inst.components.inventory

    local function collect(item)
        if item ~= nil and not seen[item]
            and IsAnySlotLockPrefab(item)
            and (slot_name == nil or IsSlotLockPrefab(item, slot_name)) then
            seen[item] = true
            table.insert(items, item)
        end
    end

    if inventory ~= nil then
        -- ForEachItem covers item slots, equipped slots, active item, and the
        -- equipped overflow container.  Collect first; remove only afterward.
        inventory:ForEachItem(collect)
    end
    collect(self.lock_item)
    return items
end

function HHSlotLockPenalty:RemovePhysicalLockItem(item)
    if item == nil or not item:IsValid() then
        return
    end

    local inventory = self.inst.components.inventory
    local equippable = item.components ~= nil and item.components.equippable or nil
    if inventory ~= nil and equippable ~= nil then
        local equipped = inventory:GetEquippedItem(equippable.equipslot) == item
        if equipped or equippable:IsEquipped() then
            -- Force only the equipment transition; item:Remove() below is the
            -- destructive no-drop disposal path.
            inventory:Unequip(equippable.equipslot, nil, true)
        end
    end

    if item:IsValid() then
        item:Remove()
    end
end

function HHSlotLockPenalty:FindLockItem()
    local inventory = self.inst.components.inventory
    if not inventory then
        return nil
    end

    local slot = GetEquipSlot(self.locked_slot)
    local equipped = slot and inventory:GetEquippedItem(slot) or nil
    if self:IsOwnedLockItem(equipped) then
        return equipped
    end

    return inventory:FindItem(function(item)
        return self:IsOwnedLockItem(item)
            and item.prefab == PREFAB_PREFIX .. tostring(self.locked_slot)
    end)
end

function HHSlotLockPenalty:IsSlotAvailable(slot_name)
    local inventory = self.inst.components.inventory
    local slot = GetEquipSlot(slot_name)
    if not inventory or not slot then
        return false
    end

    local item = inventory:GetEquippedItem(slot)
    if item and item.components.equippable
        and item.components.equippable:ShouldPreventUnequipping()
        and not self:IsOwnedLockItem(item) then
        return false
    end
    return true
end

function HHSlotLockPenalty:ChooseSlot()
    local eligible = {}
    for _, slot_name in ipairs(SLOT_NAMES) do
        if self:IsSlotAvailable(slot_name) then
            table.insert(eligible, slot_name)
        end
    end
    return #eligible > 0 and eligible[math.random(#eligible)] or nil
end

function HHSlotLockPenalty:EquipLockItem(item)
    local inventory = self.inst.components.inventory
    local slot = GetEquipSlot(self.locked_slot)
    if not inventory or not slot or not item or not item:IsValid() then
        return false
    end

    local current = inventory:GetEquippedItem(slot)
    if current == item then
        item.hh_slot_lock_owner_userid = self.inst.userid
        item.hh_slot_lock_owner = self.inst
        item.components.equippable:SetPreventUnequipping(true)
        self.lock_item = item
        return true
    end
    if current and current.components.equippable
        and current.components.equippable:ShouldPreventUnequipping() then
        return false
    end

    item.hh_slot_lock_owner_userid = self.inst.userid
    item.hh_slot_lock_owner = self.inst
    inventory:Equip(item)
    if inventory:GetEquippedItem(slot) == item then
        item.components.equippable:SetPreventUnequipping(true)
        self.lock_item = item
        return true
    end
    return false
end

function HHSlotLockPenalty:EnsureLock()
    if self._reincarnation_detaching then
        return false
    end
    if not self:IsActive() or not IsAlivePlayer(self.inst) then
        return false
    end

    local item = self:FindLockItem()
    local spawned = false
    if not item then
        item = SpawnPrefab(PREFAB_PREFIX .. self.locked_slot)
        spawned = item ~= nil
    end
    if not item then
        return false
    end

    if self:EquipLockItem(item) then
        -- A broken/legacy save may contain more than one matching artifact.
        -- Keep the one now managed by this component and dispose of every
        -- duplicate without passing through the drop path.
        for _, duplicate in ipairs(self:CollectPhysicalLockItems(self.locked_slot)) do
            if duplicate ~= item then
                self:RemovePhysicalLockItem(duplicate)
            end
        end
        return true
    end

    if item:IsValid() and (spawned or self:IsOwnedLockItem(item)) then
        self:RemovePhysicalLockItem(item)
    end
    return false
end

function HHSlotLockPenalty:ApplyRandomLock(duration)
    if self._reincarnation_detaching then
        return false, "reincarnation_detaching"
    end
    duration = tonumber(duration) or 0
    if duration <= 0 then
        return false, "invalid_duration"
    end

    if self:IsActive() then
        self.deadline = math.max(self.deadline, GetWorldSeconds() + duration)
        self:EnsureLock()
        return true, self.locked_slot
    end

    local slot_name = self:ChooseSlot()
    if not slot_name then
        return false, "no_available_slot"
    end

    self.locked_slot = slot_name
    self.deadline = GetWorldSeconds() + duration
    -- Player death/ghost state is temporary. Keep the persisted punishment and
    -- let the respawn listener/periodic tick equip the lock when possible.
    if not IsAlivePlayer(self.inst) then
        return true, self.locked_slot
    end
    if not self:EnsureLock() then
        self.locked_slot = nil
        self.deadline = 0
        return false, "equip_failed"
    end

    self.inst:PushEvent("hh_daily_slot_lock_applied", {
        slot = self.locked_slot,
        deadline = self.deadline,
    })
    return true, self.locked_slot
end

function HHSlotLockPenalty:ClearLock()
    if self._reincarnation_detaching then
        return
    end

    local old_slot = self.locked_slot
    for _, item in ipairs(self:CollectPhysicalLockItems(old_slot)) do
        if item.components ~= nil and item.components.equippable ~= nil then
            item.components.equippable:SetPreventUnequipping(false)
        end
        self:RemovePhysicalLockItem(item)
    end

    self.lock_item = nil
    self.locked_slot = nil
    self.deadline = 0
    self.inst:PushEvent("hh_daily_slot_lock_cleared", { slot = old_slot })
end

function HHSlotLockPenalty:OnTick()
    if self._reincarnation_detaching or self.locked_slot == nil then
        return
    end
    if self:GetRemaining() <= 0 then
        self:ClearLock()
    else
        self:EnsureLock()
    end
end

function HHSlotLockPenalty:PrepareForReincarnation()
    -- Capture the logical punishment before touching any physical entity.  The
    -- component state, not a GUID or an item entity, is the reroll source of
    -- truth and remains intact through vanilla DropEverything().
    local locked_slot = self.locked_slot
    local deadline = self.deadline
    local remaining = self:GetRemaining()

    self._reincarnation_detaching = true
    self._reincarnation_remaining = remaining

    -- Defensive duplicate cleanup includes equipped slots, normal inventory,
    -- active item, overflow, and a stale self.lock_item reference.  Never use
    -- ClearLock(), DropItem(), or GiveItem(): all would alter or expose state.
    for _, item in ipairs(self:CollectPhysicalLockItems()) do
        if item.components ~= nil and item.components.equippable ~= nil then
            item.components.equippable:SetPreventUnequipping(false)
        end
        self:RemovePhysicalLockItem(item)
    end
    self.lock_item = nil

    -- Keep the exact logical state for CaptureReincarnationState()->OnSave().
    self.locked_slot = locked_slot
    self.deadline = deadline

    if locked_slot ~= nil and remaining > 0 then
        return {
            locked_slot = locked_slot,
            remaining = remaining,
        }
    end
end

function HHSlotLockPenalty:OnSave()
    local remaining = self._reincarnation_detaching
        and self._reincarnation_remaining or self:GetRemaining()
    if self.locked_slot == nil or remaining <= 0 then
        return nil
    end
    return {
        locked_slot = self.locked_slot,
        remaining = remaining,
    }
end

function HHSlotLockPenalty:OnLoad(data)
    self._reincarnation_detaching = false
    self._reincarnation_remaining = nil
    if not data or not table.contains(SLOT_NAMES, data.locked_slot) then
        for _, item in ipairs(self:CollectPhysicalLockItems()) do
            if item.components ~= nil and item.components.equippable ~= nil then
                item.components.equippable:SetPreventUnequipping(false)
            end
            self:RemovePhysicalLockItem(item)
        end
        self.lock_item = nil
        self.locked_slot = nil
        self.deadline = 0
        return
    end

    local remaining = tonumber(data.remaining) or 0
    if remaining <= 0 then
        for _, item in ipairs(self:CollectPhysicalLockItems(data.locked_slot)) do
            if item.components ~= nil and item.components.equippable ~= nil then
                item.components.equippable:SetPreventUnequipping(false)
            end
            self:RemovePhysicalLockItem(item)
        end
        self.lock_item = nil
        self.locked_slot = nil
        self.deadline = 0
        return
    end

    self.locked_slot = data.locked_slot
    self.deadline = GetWorldSeconds() + remaining
    self.inst:DoTaskInTime(0, function()
        self:EnsureLock()
    end)
end

function HHSlotLockPenalty:OnRemoveFromEntity()
    if self.tick_task ~= nil then
        self.tick_task:Cancel()
        self.tick_task = nil
    end
end

function HHSlotLockPenalty:GetDebugString()
    return string.format("slot=%s remaining=%d", tostring(self.locked_slot), self:GetRemaining())
end

return HHSlotLockPenalty
