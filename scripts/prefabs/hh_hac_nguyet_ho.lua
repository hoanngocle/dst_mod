require "prefabutil"

local HHacNguyetHoItems = require("utils/hh_hac_nguyet_ho_items")

local assets =
{
    Asset("ANIM", "anim/hh_hac_nguyet_ho.zip"),
    Asset("ATLAS", "images/hh_hac_nguyet_ho.xml"),
    Asset("IMAGE", "images/hh_hac_nguyet_ho.tex"),
}

local prefabs =
{
    "collapse_small",
}

local DAILY_FRESHNESS_DELTA = 0.02

local function IsValidItem(item)
    return item ~= nil and item:IsValid()
end

local function GetServerStackable(item)
    return IsValidItem(item) and
        item.components ~= nil and
        item.components.stackable or nil
end

local function GetEmptySlotsForFishStack(container, count, preferred_slot)
    if container == nil or
        container.GetNumSlots == nil or
        container.GetItemInSlot == nil
    then
        return nil
    end

    local numslots = container:GetNumSlots()
    if type(numslots) ~= "number" then
        return nil
    end

    local slots = {}
    if preferred_slot ~= nil then
        if type(preferred_slot) ~= "number" or
            preferred_slot < 1 or
            preferred_slot > numslots or
            container:GetItemInSlot(preferred_slot) ~= nil
        then
            return nil
        end
        slots[1] = preferred_slot
    end

    for slot = 1, numslots do
        if slot ~= preferred_slot and container:GetItemInSlot(slot) == nil then
            slots[#slots + 1] = slot
            if #slots >= count then
                break
            end
        end
    end

    if #slots < count then
        return nil
    end

    return slots
end

local function GetValidatedFishStackSlots(container, item, count, preferred_slot)
    if container == nil or container.CanTakeItemInSlot == nil or
        not HHacNguyetHoItems.CanFitStack(container, item, preferred_slot) or
        not container:CanTakeItemInSlot(item, preferred_slot)
    then
        return nil
    end

    local slots = GetEmptySlotsForFishStack(container, count, preferred_slot)
    if slots == nil then
        return nil
    end

    for _, slot in ipairs(slots) do
        if not container:CanTakeItemInSlot(item, slot) then
            return nil
        end
    end
    return slots
end

local function RemoveSplitUnitFromContainer(container, unit)
    if not IsValidItem(unit) or unit.components == nil or
        unit.components.inventoryitem == nil
    then
        return
    end

    local inventoryitem = unit.components.inventoryitem
    if inventoryitem.owner == container.inst and container:GetItemSlot(unit) ~= nil then
        local removed = container:RemoveItem(unit, true)
        if removed ~= nil and IsValidItem(removed) then
            removed:Remove()
        end
    elseif inventoryitem.owner ~= nil then
        -- Stackable:Get(1) inherits the source owner's parent. A generated
        -- clone that was not inserted must be detached before cleanup.
        inventoryitem:OnRemoved()
        if IsValidItem(unit) then
            unit:Remove()
        end
    elseif IsValidItem(unit) then
        unit:Remove()
    end
end

local function RemoveOriginalIfInserted(container, item)
    if not IsValidItem(item) or item.components == nil or
        item.components.inventoryitem == nil or
        item.components.inventoryitem.owner ~= container.inst or
        container:GetItemSlot(item) == nil
    then
        return
    end

    -- Keep the original entity alive so its stack size can be restored.
    container:RemoveItem(item, true)
end

local function RollbackFishStackSplit(container, item, stackable, original_size, generated)
    for _, unit in ipairs(generated) do
        RemoveSplitUnitFromContainer(container, unit)
    end

    RemoveOriginalIfInserted(container, item)
    if IsValidItem(item) and stackable ~= nil then
        stackable:SetStackSize(original_size)
    end
end

local function GiveAquaticStackAtomically(container, item, slot, src_pos, base_giveitem)
    local stackable = GetServerStackable(item)
    local original_size = stackable ~= nil and stackable:StackSize() or 1
    local inventoryitem = item.components ~= nil and item.components.inventoryitem or nil
    if stackable == nil or original_size <= 1 or inventoryitem == nil or
        inventoryitem.owner == container.inst
    then
        return false
    end

    -- First validation is intentionally before Stackable:Get(1). It is pure
    -- and guarantees an all-or-nothing capacity decision for the full stack.
    local slots = GetValidatedFishStackSlots(container, item, original_size, slot)
    if slots == nil then
        return false
    end

    -- Revalidate immediately before the first server-side split. This closes
    -- the gap between the UI prediction and the authoritative mutation.
    if not IsValidItem(item) or
        not HHacNguyetHoItems.IsAquatic(item) or
        GetServerStackable(item) ~= stackable or
        stackable:StackSize() ~= original_size
    then
        return false
    end

    slots = GetValidatedFishStackSlots(container, item, original_size, slot)
    if slots == nil then
        return false
    end

    local generated = {}
    for _ = 1, original_size - 1 do
        local unit = stackable:Get(1)
        if unit == item or not IsValidItem(unit) then
            RollbackFishStackSplit(container, item, stackable, original_size, generated)
            if unit ~= item then
                RemoveSplitUnitFromContainer(container, unit)
            end
            return false
        end
        generated[#generated + 1] = unit
    end

    for index, unit in ipairs(generated) do
        local target_slot = slots[index]
        if not container:CanTakeItemInSlot(unit, target_slot) or
            not base_giveitem(container, unit, target_slot, src_pos, false) or
            container:GetItemInSlot(target_slot) ~= unit
        then
            RollbackFishStackSplit(container, item, stackable, original_size, generated)
            return false
        end
    end

    local final_slot = slots[original_size]
    if not container:CanTakeItemInSlot(item, final_slot) or
        not base_giveitem(container, item, final_slot, src_pos, false) or
        container:GetItemInSlot(final_slot) ~= item
    then
        RollbackFishStackSplit(container, item, stackable, original_size, generated)
        return false
    end

    return true
end

local function GiveAquaticUnitWithoutMerging(container, item, slot, src_pos, base_giveitem)
    local inventoryitem = item.components ~= nil and item.components.inventoryitem or nil
    if inventoryitem == nil or inventoryitem.owner == container.inst then
        return false
    end

    local target_slot = slot
    if target_slot == nil then
        for candidate = 1, container:GetNumSlots() do
            if container:GetItemInSlot(candidate) == nil and
                container:CanTakeItemInSlot(item, candidate)
            then
                target_slot = candidate
                break
            end
        end
    end

    if target_slot == nil or
        container:GetItemInSlot(target_slot) ~= nil or
        not container:CanTakeItemInSlot(item, target_slot)
    then
        return false
    end

    -- A concrete empty slot makes vanilla GiveItem skip its stack-merging
    -- loop. This path is only for one aquatic entity; food keeps vanilla.
    return base_giveitem(container, item, target_slot, src_pos, false) and
        container:GetItemInSlot(target_slot) == item
end

local function InstallAtomicFishInsertion(inst)
    local container = inst.components.container
    if container == nil or container._hh_hac_nguyet_ho_giveitem_wrapped then
        return
    end

    local base_giveitem = container.GiveItem
    local base_putall = container.PutAllOfActiveItemInSlot
    container._hh_hac_nguyet_ho_giveitem_wrapped = true
    container.GiveItem = function(self, item, slot, src_pos, drop_on_fail)
        local stackable = GetServerStackable(item)
        if TheWorld ~= nil and TheWorld.ismastersim and
            HHacNguyetHoItems.IsAquatic(item)
        then
            if stackable ~= nil and stackable:StackSize() > 1 then
                return GiveAquaticStackAtomically(self, item, slot, src_pos, base_giveitem)
            end
            return GiveAquaticUnitWithoutMerging(self, item, slot, src_pos, base_giveitem)
        end
        return base_giveitem(self, item, slot, src_pos, drop_on_fail)
    end

    -- Vanilla PutAll removes the active item before calling GiveItem and has
    -- no rollback branch. Handle aquatic items here so an undersized or
    -- changed destination can restore the original active item. PutOne
    -- remains vanilla and intentionally works with a single free slot.
    container.PutAllOfActiveItemInSlot = function(self, slot, opener)
        if TheWorld ~= nil and TheWorld.ismastersim and opener ~= nil and
            opener.components ~= nil and opener.components.inventory ~= nil
        then
            local active_item = opener.components.inventory:GetActiveItem()
            local stackable = GetServerStackable(active_item)
            if HHacNguyetHoItems.IsAquatic(active_item)
            then
                local count = stackable ~= nil and stackable:StackSize() or 1
                if GetValidatedFishStackSlots(self, active_item, count, slot) == nil then
                    return
                end

                local removed = opener.components.inventory:RemoveItem(active_item, true)
                if removed == nil then
                    return
                end

                self.currentuser = opener
                local success
                local removed_stackable = GetServerStackable(removed)
                if removed_stackable ~= nil and removed_stackable:StackSize() > 1 then
                    success = GiveAquaticStackAtomically(self, removed, slot, nil, base_giveitem)
                else
                    success = GiveAquaticUnitWithoutMerging(self, removed, slot, nil, base_giveitem)
                end
                self.currentuser = nil

                if not success and IsValidItem(removed) then
                    opener.components.inventory:GiveActiveItem(removed)
                end
                return
            end
        end
        return base_putall(self, slot, opener)
    end
end

local function RestoreFreshness(item)
    if item == nil or item.components == nil or
        item.components.perishable == nil
    then
        return
    end

    local perishable = item.components.perishable
    perishable:SetPercent(math.min(1, perishable:GetPercent() + DAILY_FRESHNESS_DELTA))
end

local function RestoreFoodFreshness(container)
    for slot = 1, container:GetNumSlots() do
        local item = container:GetItemInSlot(slot)
        if HHacNguyetHoItems.IsFood(item) then
            RestoreFreshness(item)
        end
    end
end

local function CollectAquaticItems(container)
    local aquatic = {}
    for slot = 1, container:GetNumSlots() do
        local item = container:GetItemInSlot(slot)
        if HHacNguyetHoItems.IsAquatic(item) then
            aquatic[#aquatic + 1] = item
        end
    end
    return aquatic
end

local function CollectFoodUnits(container)
    local entries = {}
    local total = 0
    for slot = 1, container:GetNumSlots() do
        local item = container:GetItemInSlot(slot)
        if HHacNguyetHoItems.IsFood(item) then
            local count = HHacNguyetHoItems.GetStackSize(item)
            if count > 0 then
                entries[#entries + 1] = { item = item, count = count }
                total = total + count
            end
        end
    end
    return entries, total
end

local function ConsumeRandomFoodUnit(container, entries, total)
    if total <= 0 then
        return false
    end

    local pick = math.random(total)
    for _, entry in ipairs(entries) do
        if entry.count > 0 then
            pick = pick - entry.count
            if pick <= 0 then
                local consumed = container:RemoveItem(entry.item)
                if consumed == nil then
                    return false
                end

                entry.count = entry.count - 1
                if IsValidItem(consumed) then
                    consumed:Remove()
                end
                return true
            end
        end
    end
    return false
end

local function FeedAquaticItems(container)
    local aquatic = CollectAquaticItems(container)
    local food_entries, food_units = CollectFoodUnits(container)
    local feed_count = math.min(#aquatic, food_units)

    for _ = 1, feed_count do
        if not ConsumeRandomFoodUnit(container, food_entries, food_units) then
            break
        end
        food_units = food_units - 1

        local aquatic_index = math.random(#aquatic)
        local target = table.remove(aquatic, aquatic_index)
        RestoreFreshness(target)
    end
end

local function ProcessDailyCycle(inst)
    local container = inst.components.container
    if container == nil then
        return
    end

    -- The order is part of the feature contract: restore accepted food first,
    -- then consume the weighted food pool for random aquatic feeding.
    RestoreFoodFreshness(container)
    FeedAquaticItems(container)
end

local function onopen(inst)
    inst.AnimState:PushAnimation("idle", true)
    inst.SoundEmitter:PlaySound("farming/common/soil_amender/stale_pre")
end

local function onclose(inst)
    inst.AnimState:PushAnimation("idle", true)
    inst.SoundEmitter:PlaySound("farming/common/soil_amender/stale_pre")
end

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
    end

    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("rock_break")
    inst:Remove()
end

local function onhit(inst, worker)
    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
        inst.components.container:Close()
    end

    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle", true)
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", true)
    inst.SoundEmitter:PlaySound("farming/common/farm/plow/collapse")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    -- Match the recipe spacing to the source physics radius without changing
    -- the source prefab's obstacle footprint.
    inst:SetDeploySmartRadius(1)
    MakeObstaclePhysics(inst, 1)
    inst.Transform:SetScale(1.6, 1.6, 1.6)
    inst.MiniMapEntity:SetIcon("hh_hac_nguyet_ho.tex")

    inst:AddTag("watersource")
    inst:AddTag("structure")
    inst:AddTag("cleanwaterproduction")

    -- The archive keeps the original internal bank/build names.
    inst.AnimState:SetBank("well_1")
    inst.AnimState:SetBuild("well_1")
    inst.AnimState:PlayAnimation("idle")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("lootdropper")

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("hh_hac_nguyet_ho")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    InstallAtomicFishInsertion(inst)

    inst:AddComponent("watersource")

    inst:AddComponent("preserver")
    inst.components.preserver:SetPerishRateMultiplier(0)

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(8)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    MakeSnowCovered(inst)
    AddHauntableDropItemOrWork(inst)
    inst:ListenForEvent("onbuilt", onbuilt)

    local function oncyclecomplete(_, _completed_cycles)
        if inst:IsValid() then
            ProcessDailyCycle(inst)
        end
    end
    inst:ListenForEvent("ms_cyclecomplete", oncyclecomplete, TheWorld)
    inst:ListenForEvent("onremove", function()
        inst:RemoveEventCallback("ms_cyclecomplete", oncyclecomplete, TheWorld)
    end)

    return inst
end

return Prefab("hh_hac_nguyet_ho", fn, assets, prefabs),
    MakePlacer("hh_hac_nguyet_ho_placer", "well_1", "well_1", "idle", nil, nil, nil, 1.6)
