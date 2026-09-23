local __bU__G = require "utils/hh_utils"
local B__UG = require "enums/hh_enchant"
local _B_U_g_ = require "enums/hh_equip"
local BU_G_ = B__UG["HH_EQUIP_BUFF_LIST"]
local function b_U_G__(_b_UG, __bU__G__)
    if __bU__G__ then
        if not _b_UG["_bonusenabled"] then
            _b_UG["_bonusenabled"] = (317 + 305 * 339 * 320 + 271 == 33086988)
            if _b_UG["components"]["weapon"] ~= nil then
                _b_UG["components"]["weapon"]:SetDamage(
                    _b_UG["base_damage"] * TUNING["WEAPONS_VOIDCLOTH_SETBONUS_DAMAGE_MULT"]
                )
            end
            _b_UG["components"]["planardamage"]:AddBonus(
                _b_UG,
                TUNING["WEAPONS_VOIDCLOTH_SETBONUS_PLANAR_DAMAGE"],
                "setbonus"
            )
        end
    elseif _b_UG["_bonusenabled"] then
        _b_UG["_bonusenabled"] = nil
        if _b_UG["components"]["weapon"] ~= nil then
            _b_UG["components"]["weapon"]:SetDamage(_b_UG["base_damage"])
        end
        _b_UG["components"]["planardamage"]:RemoveBonus(_b_UG, "setbonus")
    end
end
local function __B_U__G__(_buG_, B_u__g_)
    if _buG_["_owner"] ~= B_u__g_ then
        if _buG_["_owner"] ~= nil then
            _buG_:RemoveEventCallback("equip", _buG_["_onownerequip"], _buG_["_owner"])
            _buG_:RemoveEventCallback("unequip", _buG_["_onownerunequip"], _buG_["_owner"])
            _buG_["_onownerequip"] = nil
            _buG_["_onownerunequip"] = nil
            b_U_G__(_buG_, (478 + 50 * 49 + 231 ~= 3159))
        end
        _buG_["_owner"] = B_u__g_
        if B_u__g_ ~= nil then
            _buG_["_onownerequip"] = function(B_u__g_, B__ug__)
                if B__ug__ ~= nil then
                    if B__ug__["item"] ~= nil and B__ug__["item"]["prefab"] == "voidclothhat" then
                        b_U_G__(_buG_, (131 * 230 - 417 == 29713))
                    elseif B__ug__["eslot"] == EQUIPSLOTS["HEAD"] then
                        b_U_G__(_buG_, (341 * 13 * 126 ~= 558558))
                    end
                end
            end
            _buG_["_onownerunequip"] = function(B_u__g_, B__u__g__)
                if B__u__g__ ~= nil and B__u__g__["eslot"] == EQUIPSLOTS["HEAD"] then
                    b_U_G__(_buG_, (388 + 193 * 271 + 154 ~= 52845))
                end
            end
            _buG_:ListenForEvent("equip", _buG_["_onownerequip"], B_u__g_)
            _buG_:ListenForEvent("unequip", _buG_["_onownerunequip"], B_u__g_)
            local _b_uG_ = B_u__g_["components"]["inventory"]:GetEquippedItem(EQUIPSLOTS["HEAD"])
            if _b_uG_ ~= nil and _b_uG_["prefab"] == "voidclothhat" then
                b_U_G__(_buG_, (148 - 290 - 82 == -224))
            end
        end
    end
end
local function B__U_g(__b_U_G__, bU_G__)
    if bU_G__ then
        if not __b_U_G__["_bonusenabled"] then
            __b_U_G__["_bonusenabled"] =
                (false or not true and not false and false and false or not true and true and false and false and false or
                not false)
            if __b_U_G__["components"]["weapon"] ~= nil then
                __b_U_G__["components"]["weapon"]:SetDamage(
                    __b_U_G__["base_damage"] * TUNING["WEAPONS_LUNARPLANT_SETBONUS_DAMAGE_MULT"]
                )
            end
            __b_U_G__["components"]["planardamage"]:AddBonus(
                __b_U_G__,
                TUNING["WEAPONS_LUNARPLANT_SETBONUS_PLANAR_DAMAGE"],
                "setbonus"
            )
        end
    elseif __b_U_G__["_bonusenabled"] then
        __b_U_G__["_bonusenabled"] = nil
        if __b_U_G__["components"]["weapon"] ~= nil then
            __b_U_G__["components"]["weapon"]:SetDamage(__b_U_G__["base_damage"])
        end
        __b_U_G__["components"]["planardamage"]:RemoveBonus(__b_U_G__, "setbonus")
    end
end
local function bU__G_(__B__u__g__, __B_ug)
    if __B__u__g__["_owner"] ~= __B_ug then
        if __B__u__g__["_owner"] ~= nil then
            __B__u__g__:RemoveEventCallback("equip", __B__u__g__["_onownerequip"], __B__u__g__["_owner"])
            __B__u__g__:RemoveEventCallback("unequip", __B__u__g__["_onownerunequip"], __B__u__g__["_owner"])
            __B__u__g__["_onownerequip"] = nil
            __B__u__g__["_onownerunequip"] = nil
            B__U_g(__B__u__g__, (331 - 492 + 393 ~= 232))
        end
        __B__u__g__["_owner"] = __B_ug
        if __B_ug ~= nil then
            __B__u__g__["_onownerequip"] = function(__B_ug, BuG_)
                if BuG_ ~= nil then
                    if BuG_["item"] ~= nil and BuG_["item"]["prefab"] == "lunarplanthat" then
                        B__U_g(__B__u__g__, (233 * 266 + 183 - 294 ~= 61876))
                    elseif BuG_["eslot"] == EQUIPSLOTS["HEAD"] then
                        B__U_g(__B__u__g__, (42 + 237 - 308 + 384 * 338 ~= 129763))
                    end
                end
            end
            __B__u__g__["_onownerunequip"] = function(__B_ug, _b_u_G_)
                if _b_u_G_ ~= nil and _b_u_G_["eslot"] == EQUIPSLOTS["HEAD"] then
                    B__U_g(
                        __B__u__g__,
                        (false or false or false and not false or
                            not false and not false and not false and not true and false)
                    )
                end
            end
            __B__u__g__:ListenForEvent("equip", __B__u__g__["_onownerequip"], __B_ug)
            __B__u__g__:ListenForEvent("unequip", __B__u__g__["_onownerunequip"], __B_ug)
            local _bu__G_ = __B_ug["components"]["inventory"]:GetEquippedItem(EQUIPSLOTS["HEAD"])
            if _bu__G_ ~= nil and _bu__G_["prefab"] == "lunarplanthat" then
                B__U_g(__B__u__g__, (336 + 235 - 155 ~= 421))
            end
        end
    end
end
local function b_u__g_(__B_U_g__, __B__UG)
    if
        not __bU__G:HasComponents(__B_U_g__["hh_ui_owner"], "hh_player") or not __B__UG or not __B__UG["item"] or
            not __B__UG["slot"]
     then
        return
    end
    if __B__UG["slot"] == 1 and __bU__G:HasComponents(__B__UG["item"], "hh_equip") then
        local __Bu__g_ = __B__UG["item"]["components"]["hh_equip"]["equip_buff_list"]
        __bU__G:HHClientRpc(__B_U_g__["hh_ui_owner"], "hh_forge_equip", __bU__G:TableToStr(__Bu__g_))
    end
    __bU__G:ForgeStoneClient(__B_U_g__)
    __B_U_g__.hh_ui_owner.components.hh_player:UpdateForgeState()
end
local function b__UG_(__b__u__G__, BU__g_)
    if
        not __bU__G:HasComponents(__b__u__G__["hh_ui_owner"], "hh_player") or not BU__g_ or not BU__g_["prev_item"] or
            not BU__g_["slot"]
     then
        return
    end
    if BU__g_["slot"] == 1 and __bU__G:HasComponents(BU__g_["prev_item"], "hh_equip") then
        __bU__G:HHClientRpc(__b__u__G__["hh_ui_owner"], "hh_forge_equip", __bU__G:TableToStr({}))
    end
    __bU__G:ForgeStoneClient(__b__u__G__)
    __b__u__G__.hh_ui_owner.components.hh_player:UpdateForgeState()
end
local function _buG__(__B__u__G_, b__uG, B_ug)
    local function __B_Ug_()
        local __b__uG_ = CreateEntity()
        __b__uG_["entity"]:AddTransform()
        __b__uG_["entity"]:AddAnimState()
        __b__uG_["entity"]:AddSoundEmitter()
        __b__uG_["entity"]:AddNetwork()
        if B_ug then
            __b__uG_:AddTag "fridge"
        end
        __b__uG_:AddTag "CLASSIFIED"
        __b__uG_:AddTag "NOCLICK"
        __b__uG_:AddTag "dcs2hm"
        if b__uG == "hh_forge_container" then
            __b__uG_.ttk_forge_mode = net_string(__b__uG_.GUID, "ttk_forge.mode", "ttk_forge_mode_dirty")
            if TheWorld.ismastersim then
                __b__uG_.ttk_forge_mode:set("cleanse")
            end
        end
        __b__uG_["entity"]:SetPristine()
        if not TheWorld["ismastersim"] then
            __b__uG_["OnEntityReplicated"] = function(__b__uG_)
                __b__uG_["replica"]["container"]:WidgetSetup(b__uG)
            end
            return __b__uG_
        end
        __b__uG_:AddComponent "container"
        __b__uG_["components"]["container"]:WidgetSetup(b__uG)
        __b__uG_["components"]["container"]["skipclosesnd"] =
            (true and not false and not true and false and false and not false and true or true or not false)
        __b__uG_["components"]["container"]["skipopensnd"] = (282 - 180 - 476 + 475 + 200 ~= 306)
        if b__uG == "hh_forge_container" then
            local container = __b__uG_.components.container
            local old_save, old_load = container.OnSave, container.OnLoad
            container.OnSave = function(self, ...)
                local data, refs = old_save(self, ...)
                data = data or {}
                data.ttk_forge_mode = require("utils/ttk_forge_rules").GetMode(self)
                return data, refs
            end
            container.OnLoad = function(self, data, ...)
                local rules = require("utils/ttk_forge_rules")
                local mode = data ~= nil and data.ttk_forge_mode or nil
                self.inst.ttk_forge_mode:set(rules.MODES[mode] and mode or "cleanse")
                -- Older saves used all five slots at once. Retain their contents
                -- during loading; OpenSuitContainer returns incompatible items.
                self.inst._ttk_forge_loading_legacy = mode == nil
                old_load(self, data or {}, ...)
                self.inst._ttk_forge_loading_legacy = nil
            end
            __b__uG_:ListenForEvent("itemget", b_u__g_)
            __b__uG_:ListenForEvent("itemlose", b__UG_)
        end
        return __b__uG_
    end
    return Prefab(__B__u__G_, __B_Ug_)
end

local MONARCH_STORAGE_PREFAB = "hh_monarch_storage_container"
local MONARCH_STORAGE_STACK_LIMIT = 99

local function IsMonarchSlotLocked(container, slot)
    local item = slot ~= nil and container.slots[slot] or nil
    return item ~= nil and item:IsValid()
        and item.components.inventoryitem ~= nil and item.components.inventoryitem.islockedinslot
end

local function InstallMonarchServerRules(inst)
    local container = inst.components.container
    local OldGiveItem = container.GiveItem
    local OldRemoveItemInternal = container.RemoveItem_Internal

    -- Monarch Storage is an infinite-stack container internally, but it exposes a
    -- hard cap of 99. Never let a stale/removed entity participate in stack math:
    -- Stackable property setters always sync through inst.replica.stackable and
    -- will crash if the entity was already Remove()'d.
    local function IsLiveItem(item)
        return item ~= nil and item:IsValid()
    end

    local function HasUsableStackReplica(item)
        return item ~= nil and item.components.stackable ~= nil
            and item.replica ~= nil and item.replica.stackable ~= nil
    end

    local function GetLiveSlot(self, slot)
        if slot == nil then
            return nil
        end
        local item = self.slots[slot]
        if item ~= nil and not IsLiveItem(item) then
            self.slots[slot] = nil
            self.inst:PushEvent("itemlose", {slot = slot})
            return nil
        end
        return item
    end

    local function SanitizeSlots(self)
        for slot = 1, self.numslots do
            GetLiveSlot(self, slot)
        end
    end

    local function RestoreStackPiece(target, piece, src_pos)
        if not IsLiveItem(target) or not IsLiveItem(piece)
            or not HasUsableStackReplica(target) or not HasUsableStackReplica(piece)
            or not target.components.stackable:CanStackWith(piece) then
            return false
        end
        local targetstack = target.components.stackable
        local piecestack = piece.components.stackable
        local oldsize = targetstack:StackSize()
        local added = piecestack:StackSize()

        if target.components.perishable ~= nil and piece.components.perishable ~= nil then
            target.components.perishable:Dilute(added, piece.components.perishable.perishremainingtime)
        end
        if target.components.inventoryitem ~= nil then
            target.components.inventoryitem:DiluteMoisture(piece, added)
            if target.components.inventoryitem.DiluteTemperature ~= nil then
                target.components.inventoryitem:DiluteTemperature(piece, added)
            end
        end
        if target.components.edible ~= nil and piece.components.edible ~= nil then
            target.components.edible:DiluteChill(piece, added)
        end
        if target.components.curseditem ~= nil then
            target.skipspeech = true
        end

        if not IsLiveItem(target) or not HasUsableStackReplica(target)
            or not IsLiveItem(piece) or not HasUsableStackReplica(piece) then
            return false
        end

        targetstack.stacksize = oldsize + added
        target:PushEvent("stacksizechange", {
            stacksize = targetstack:StackSize(),
            oldstacksize = oldsize,
            src_pos = src_pos,
        })
        piece:Remove()
        return true
    end

    -- Storage-local equivalent of Stackable:Put. The important ordering difference
    -- is that the live destination is updated BEFORE the fully consumed source is
    -- removed. This avoids both crash classes observed in runtime:
    -- 1) SetIgnoreMaxSize() touching an already removed stack, and
    -- 2) Stackable:Put() updating stacksize through an invalid destination replica.
    local function MergeIntoSlot(self, item, slot, src_pos)
        if not IsLiveItem(item) then
            return nil
        end
        local existing = GetLiveSlot(self, slot)
        if existing == nil or existing == item or IsMonarchSlotLocked(self, slot)
            or existing.components.stackable == nil or item.components.stackable == nil
            or not HasUsableStackReplica(existing) or not HasUsableStackReplica(item)
            or not existing.components.stackable:CanStackWith(item) then
            return item
        end

        local existingstack = existing.components.stackable
        local itemstack = item.components.stackable
        local oldsize = existingstack:StackSize()
        local incoming = itemstack:StackSize()
        local room = math.max(0, MONARCH_STORAGE_STACK_LIMIT - oldsize)
        local amount = math.min(room, incoming)
        if amount <= 0 then
            return item
        end

        -- Preserve vanilla stack-merge state blending.
        if existing.components.perishable ~= nil and item.components.perishable ~= nil then
            existing.components.perishable:Dilute(amount, item.components.perishable.perishremainingtime)
        end
        if existing.components.inventoryitem ~= nil then
            existing.components.inventoryitem:DiluteMoisture(item, amount)
            if existing.components.inventoryitem.DiluteTemperature ~= nil then
                existing.components.inventoryitem:DiluteTemperature(item, amount)
            end
        end
        if existing.components.edible ~= nil and item.components.edible ~= nil then
            existing.components.edible:DiluteChill(item, amount)
        end
        if existing.components.curseditem ~= nil then
            existing.skipspeech = true
        end

        -- State blending may invoke prefab hooks. Revalidate immediately before
        -- touching stacksize so no callback can leave us mutating a dead entity.
        if not IsLiveItem(existing) or not HasUsableStackReplica(existing) then
            return IsLiveItem(item) and item or nil
        end
        if not IsLiveItem(item) or not HasUsableStackReplica(item) then
            return nil
        end

        -- Update the destination while both entities are still valid.
        existingstack.stacksize = oldsize + amount
        existing:PushEvent("stacksizechange", {
            stacksize = existingstack:StackSize(),
            oldstacksize = oldsize,
            src_pos = src_pos,
        })

        if amount >= incoming then
            item:Remove()
            return nil
        end

        local oldincoming = incoming
        itemstack.stacksize = incoming - amount
        item:PushEvent("stacksizechange", {
            stacksize = itemstack:StackSize(),
            oldstacksize = oldincoming,
            src_pos = src_pos,
        })
        return item
    end

    local function FindEmptySlot(self)
        for slot = 1, self.numslots do
            if GetLiveSlot(self, slot) == nil then
                return slot
            end
        end
    end

    local function DropFailedItem(self, item)
        if not IsLiveItem(item) or item.components.inventoryitem == nil then
            return
        end
        if item.components.stackable == nil or HasUsableStackReplica(item) then
            self:DropOverstackedExcess(item)
        end
        if IsLiveItem(item) then
            item.Transform:SetPosition(self.inst.Transform:GetWorldPosition())
            item.components.inventoryitem:OnDropped(true)
        end
    end

    container.excludefromcrafting = true

    container.CanTakeItemInSlot = function(self, item, slot)
        if not IsLiveItem(item) or item.components.inventoryitem == nil
            or self.readonlycontainer
            or (item.components.stackable ~= nil and not HasUsableStackReplica(item))
            or (GetGameModeProperty("non_item_equips") and item.components.equippable ~= nil) then
            return false
        end
        if slot ~= nil then
            if slot < 1 or slot > self.numslots then
                return false
            end
            local existing = GetLiveSlot(self, slot)
            if existing ~= nil then
                local stackable = existing.components.stackable
                if IsMonarchSlotLocked(self, slot) or stackable == nil
                    or not HasUsableStackReplica(existing)
                    or not stackable:CanStackWith(item)
                    or stackable:StackSize() >= MONARCH_STORAGE_STACK_LIMIT then
                    return false
                end
            end
        end
        return self.itemtestfn == nil or self:itemtestfn(item, slot)
    end

    container.CanAcceptCount = function(self, item, maxcount)
        SanitizeSlots(self)
        if not IsLiveItem(item) or not self:CanTakeItemInSlot(item) then
            return 0
        end
        local remaining = math.min(maxcount or math.huge,
            item.components.stackable ~= nil and item.components.stackable:StackSize() or 1)
        local accepted = 0
        for slot = 1, self.numslots do
            local existing = GetLiveSlot(self, slot)
            if existing == nil then
                local amount = item.components.stackable ~= nil and math.min(remaining, MONARCH_STORAGE_STACK_LIMIT) or 1
                accepted = accepted + amount
                remaining = remaining - amount
            elseif not IsMonarchSlotLocked(self, slot)
                and existing.components.stackable ~= nil
                and HasUsableStackReplica(existing)
                and existing.components.stackable:CanStackWith(item) then
                local amount = math.min(remaining,
                    math.max(0, MONARCH_STORAGE_STACK_LIMIT - existing.components.stackable:StackSize()))
                accepted = accepted + amount
                remaining = remaining - amount
            end
            if remaining <= 0 then
                break
            end
        end
        return accepted
    end

    container.GiveItem = function(self, item, slot, src_pos, drop_on_fail)
        SanitizeSlots(self)
        if not IsLiveItem(item) or not self:CanTakeItemInSlot(item, slot) then
            if item ~= nil and drop_on_fail ~= false then
                DropFailedItem(self, item)
            end
            return false
        end

        if item.components.stackable ~= nil and self.acceptsstacks then
            local preferred_empty_slot = slot ~= nil and GetLiveSlot(self, slot) == nil and slot or nil
            if slot ~= nil and GetLiveSlot(self, slot) ~= nil then
                item = MergeIntoSlot(self, item, slot, src_pos)
                if item == nil then
                    return true
                end
                slot = nil
            end

            if preferred_empty_slot == nil then
                for i = 1, self.numslots do
                    item = item ~= nil and MergeIntoSlot(self, item, i, src_pos) or nil
                    if item == nil then
                        return true
                    end
                end
            end

            while IsLiveItem(item) and item.components.stackable ~= nil
                and item.components.stackable:StackSize() > MONARCH_STORAGE_STACK_LIMIT do
                local empty = preferred_empty_slot or FindEmptySlot(self)
                if empty == nil then
                    break
                end
                preferred_empty_slot = nil
                local chunk = item.components.stackable:Get(MONARCH_STORAGE_STACK_LIMIT)
                if not IsLiveItem(chunk) or not OldGiveItem(self, chunk, empty, src_pos, false) then
                    if IsLiveItem(chunk) and chunk ~= item then
                        RestoreStackPiece(item, chunk, src_pos)
                    end
                    break
                end
            end
        end

        local empty = IsLiveItem(item)
            and (slot ~= nil and GetLiveSlot(self, slot) == nil and slot or FindEmptySlot(self)) or nil
        if empty ~= nil and self:CanTakeItemInSlot(item, empty) then
            return OldGiveItem(self, item, empty, src_pos, false)
        end
        if item ~= nil and drop_on_fail ~= false then
            DropFailedItem(self, item)
        end
        return false
    end

    container.RemoveItem_Internal = function(self, item, slot, ...)
        local live = GetLiveSlot(self, slot)
        if live == nil or live ~= item or not IsLiveItem(item) then
            return nil
        end
        if item.components.inventoryitem ~= nil and item.components.inventoryitem.islockedinslot then
            return nil
        end
        -- SetIgnoreMaxSize(false), Stackable:Get(), and the stacksize property
        -- all require a live stackable replica. A corrupt/transitional stack is
        -- left in place rather than risking item loss or a server crash.
        if item.components.stackable ~= nil and not HasUsableStackReplica(item) then
            return nil
        end
        return OldRemoveItemInternal(self, item, slot, ...)
    end

    -- Vanilla Add* methods call Stackable:Put directly and therefore bypass both
    -- the 99 cap and the stale-entity checks above. Route them through the same
    -- safe merge path used by GiveItem.
    container.AddOneOfActiveItemToSlot = function(self, slot, opener)
        local inventory = opener ~= nil and opener.components.inventory or nil
        local active_item = inventory ~= nil and inventory:GetActiveItem() or nil
        local existing = GetLiveSlot(self, slot)
        if existing == nil or not IsLiveItem(active_item)
            or not self:CanTakeItemInSlot(active_item, slot)
            or existing.components.stackable == nil
            or active_item.components.stackable == nil
            or not active_item.components.stackable:IsStack() then
            return
        end

        self.currentuser = opener
        local piece = active_item.components.stackable:Get(1)
        local leftover = IsLiveItem(piece) and MergeIntoSlot(self, piece, slot, nil) or piece
        if IsLiveItem(leftover) and leftover ~= active_item then
            RestoreStackPiece(active_item, leftover, nil)
        end
        self.currentuser = nil
    end

    container.AddAllOfActiveItemToSlot = function(self, slot, opener)
        local inventory = opener ~= nil and opener.components.inventory or nil
        local active_item = inventory ~= nil and inventory:GetActiveItem() or nil
        local existing = GetLiveSlot(self, slot)
        if existing == nil or not IsLiveItem(active_item)
            or not self:CanTakeItemInSlot(active_item, slot)
            or existing.components.stackable == nil
            or active_item.components.stackable == nil then
            return
        end

        self.currentuser = opener
        local leftovers = MergeIntoSlot(self, active_item, slot, nil)
        inventory:SetActiveItem(leftovers)
        self.currentuser = nil
    end

    -- Every slot action gets one final stale-slot/lock gate before vanilla or the
    -- custom Add* implementation runs. This covers mouse, controller, half-stack,
    -- all-stack, one-item, swap, and cross-container transfer paths.
    for _, method in ipairs({
        "PutOneOfActiveItemInSlot", "PutAllOfActiveItemInSlot",
        "TakeActiveItemFromHalfOfSlot", "TakeActiveItemFromCountOfSlot", "TakeActiveItemFromAllOfSlot",
        "AddOneOfActiveItemToSlot", "AddAllOfActiveItemToSlot",
        "SwapActiveItemWithSlot", "SwapOneOfActiveItemWithSlot",
        "MoveItemFromAllOfSlot", "MoveItemFromHalfOfSlot", "MoveItemFromCountOfSlot",
    }) do
        local OldMethod = container[method]
        if OldMethod ~= nil then
            container[method] = function(self, slot, ...)
                local existing = GetLiveSlot(self, slot)
                if existing ~= nil and IsMonarchSlotLocked(self, slot) then
                    return
                end
                return OldMethod(self, slot, ...)
            end
        end
    end
end
local function InstallMonarchClientRules(inst)
    local replica = inst.replica.container
    replica:WidgetSetup(MONARCH_STORAGE_PREFAB)
    replica.CanTakeItemInSlot = function(self, item, slot)
        local inventoryitem = item ~= nil and item:IsValid() and item.replica.inventoryitem or nil
        if inventoryitem == nil or self:IsReadOnlyContainer()
            or (GetGameModeProperty("non_item_equips") and item.replica.equippable ~= nil) then
            return false
        end
        if slot ~= nil then
            if slot < 1 or slot > self:GetNumSlots() then
                return false
            end
            local existing = self:GetItemInSlot(slot)
            if existing ~= nil and not existing:IsValid() then
                return false
            end
            local existing_inventoryitem = existing ~= nil and existing.replica.inventoryitem or nil
            if existing_inventoryitem ~= nil and existing_inventoryitem:IsLockedInSlot() then
                return false
            end
            if existing ~= nil then
                local stackable = existing.replica.stackable
                if stackable == nil or not stackable:CanStackWith(item)
                    or stackable:StackSize() >= MONARCH_STORAGE_STACK_LIMIT then
                    return false
                end
            end
        end
        return self.itemtestfn == nil or self:itemtestfn(item, slot)
    end
end

local function MonarchStorageFn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddNetwork()
    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")
    inst:AddTag("hh_monarch_storage")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        inst.OnEntityReplicated = InstallMonarchClientRules
        return inst
    end
    inst:AddComponent("container")
    inst.components.container:WidgetSetup(MONARCH_STORAGE_PREFAB)
    inst.components.container:EnableInfiniteStackSize(true)
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true
    InstallMonarchServerRules(inst)
    return inst
end

local MonarchStoragePrefab = Prefab(MONARCH_STORAGE_PREFAB, MonarchStorageFn)
local bU_g_ = {
    Asset("ANIM", "anim/hh_items.zip"),
    Asset("IMAGE", "images/hh_icon/hh_items.tex"),
    Asset("ATLAS", "images/hh_icon/hh_items.xml"),
    Asset("ATLAS_BUILD", "images/hh_icon/hh_items.xml", 256)
}
local function b__u_g_(__bug__, __bU__g_)
    __bU__g_["hh_effect"] = __bug__["hh_effect"]
end
local function __bU__G_(_BU__G_, __b_uG)
    if not __b_uG then
        return
    end
    _BU__G_["hh_effect"] = __b_uG["hh_effect"]
    if _BU__G_["HH_Update_Server"] then
        _BU__G_:HH_Update_Server()
    end
end
local function __BU__G_()
    local __Bu_g__ = CreateEntity()
    __Bu_g__["entity"]:AddTransform()
    __Bu_g__["entity"]:AddLabel()
    __Bu_g__:AddTag "CLASSIFIED"
    __Bu_g__:AddTag "NOCLICK"
    __Bu_g__["Label"]:SetFontSize(16)
    __Bu_g__["Label"]:SetFont(CODEFONT)
    __Bu_g__["Label"]:SetWorldOffset(0, 2, 0)
    __Bu_g__["Label"]:SetUIOffset(0, 2, 0)
    __Bu_g__["Label"]:Enable((366 - 120 - 26 * 147 * 357 ~= -1364208))
    __Bu_g__["Label"]:SetText "Null"
    __Bu_g__["persists"] = (161 + 73 - 279 - 116 - 345 ~= -506)
    return __Bu_g__
end
local function BU_G(_bU__G)
    if _bU__G and _bU__G["hh_child_str"] and _bU__G["hh_child"] and _bU__G["hh_child"]["Label"] then
        local __b__U_G__ = _bU__G["hh_child_str"]:value()
        local _B_U_g__ = _bU__G["hh_child"]["Label"]
        _B_U_g__:SetText(tostring(__b__U_G__))
        _B_U_g__:Enable((247 - 178 + 103 + 278 * 156 ~= 43548))
        local __b_uG_ = _bU__G["hh_client_effect"] and _bU__G["hh_client_effect"]:value() or nil
        if __b_uG_ and BU_G_[__b_uG_] then
            if BU_G_[__b_uG_]["client_color"] then
                local _Bu_G = BU_G_[__b_uG_]["client_color"]
                _B_U_g__:SetColour(_Bu_G[1] or 1, _Bu_G[2] or 1, _Bu_G[3] or 1)
            elseif BU_G_[__b_uG_]["can_add"] == (354 + 263 * 255 - 488 == 66936) then
                _B_U_g__:SetColour(255 / 255, 150 / 255, 0)
            end
        end
    end
end
local function Bu_G(bu_g__)
    if bu_g__ and bu_g__["hh_effect"] and BU_G_[bu_g__["hh_effect"]] and bu_g__["hh_child_str"] then
        if BU_G_[bu_g__["hh_effect"]]["is_suit"] then
            bu_g__:AddTag "hh_suit_stone"
        end
        local __bu__g__ = BU_G_[bu_g__["hh_effect"]]["name"]
        bu_g__["hh_child_str"]:set(tostring(__bu__g__) .. "\n↓")
        bu_g__["hh_client_effect"]:set(tostring(bu_g__["hh_effect"]))
    end
end
local function _B__u__G__(__bUG__, B__u__G_, b_U__G_)
    local function __b_U_g_()
        local __Bu__G = CreateEntity()
        __Bu__G["entity"]:AddTransform()
        __Bu__G["entity"]:AddAnimState()
        __Bu__G["entity"]:AddSoundEmitter()
        __Bu__G["entity"]:AddNetwork()
        local new_ground_animation = nil
        local new_inventory_image = __bUG__
        local new_inventory_atlas = "images/hh_icon/hh_items.xml"
        if __bUG__ == "hh_effect_tally" then
            new_ground_animation = "idle_giay_thuoc_tinh"
            new_inventory_image = "giay_thuoc_tinh_inventory"
            new_inventory_atlas = "images/vat_pham_inventory_so_1.xml"
        elseif __bUG__ == "hh_remove_stone" then
            new_ground_animation = "idle_luc_bao_thach"
            new_inventory_image = "luc_bao_thach_inventory"
            new_inventory_atlas = "images/vat_pham_inventory_so_1.xml"
        end
        if __bUG__ == "hh_effect_stone" then
            __Bu__G["hh_child_str"] = net_string(__Bu__G["GUID"], "hh_child_str", "hh_child_str")
            __Bu__G["hh_client_effect"] = net_string(__Bu__G["GUID"], "hh_client_effect", "hh_client_effect")
            __Bu__G["hh_child"] = __BU__G_()
            __Bu__G["hh_child"]["entity"]:SetParent(__Bu__G["entity"])
            __Bu__G:ListenForEvent("hh_child_str", BU_G)
        end
        if new_ground_animation ~= nil then
            __Bu__G["AnimState"]:SetBank "hh_vat_pham_ground_so_1"
            __Bu__G["AnimState"]:SetBuild "hh_vat_pham_ground_so_1"
            __Bu__G["AnimState"]:PlayAnimation(new_ground_animation)
        else
            __Bu__G["AnimState"]:SetBank "hh_items"
            __Bu__G["AnimState"]:SetBuild "hh_items"
            __Bu__G["AnimState"]:PlayAnimation "idle"
            if B__u__G_ then
                __Bu__G["AnimState"]:OverrideSymbol("hh_remove_stone", "hh_items", B__u__G_)
            end
        end
        __Bu__G:AddTag(b_U__G_)
        MakeInventoryPhysics(__Bu__G)
        MakeInventoryFloatable(__Bu__G, "med", 0.3, 0.8)
        __Bu__G["entity"]:SetPristine()
        if not TheWorld["ismastersim"] then
            return __Bu__G
        end
        __Bu__G:AddComponent "tradable"
        __Bu__G:AddComponent "inspectable"
        __Bu__G:AddComponent "inventoryitem"
        __Bu__G["components"]["inventoryitem"]["imagename"] = new_inventory_image
        __Bu__G["components"]["inventoryitem"]["atlasname"] = new_inventory_atlas
        if __bUG__ == "hh_effect_tally" or __bUG__ == "hh_remove_stone" then
            __Bu__G:AddComponent "stackable"
            __Bu__G["components"]["stackable"]["maxsize"] = TUNING["STACK_SIZE_SMALLITEM"]
        end
        if __bUG__ == "hh_effect_stone" then
            __Bu__G["hh_effect"] = nil
            __Bu__G["components"]["tradable"]["goldvalue"] = 5
            __Bu__G["HH_Update_Server"] = Bu_G
            __Bu__G["OnSave"] = b__u_g_
            __Bu__G["OnLoad"] = __bU__G_
        end
        if __bUG__ == "hh_essence" then
            __Bu__G:AddComponent "stackable"
            __Bu__G["components"]["stackable"]["maxsize"] = TUNING["STACK_SIZE_SMALLITEM"]
            __Bu__G["components"]["tradable"]["goldvalue"] = 5
            __Bu__G["GetHHSpDesc03"] = function(__Bu__G, B__UG_)
                return {["title"] = "Special", ["desc"] = "Special synthetic material"}
            end
        end
        return __Bu__G
    end
    if __bUG__ == "hh_effect_tally" then
        RegisterInventoryItemAtlas("images/vat_pham_inventory_so_1.xml", "giay_thuoc_tinh_inventory.tex")
    elseif __bUG__ == "hh_remove_stone" then
        RegisterInventoryItemAtlas("images/vat_pham_inventory_so_1.xml", "luc_bao_thach_inventory.tex")
    else
        RegisterInventoryItemAtlas("images/hh_icon/hh_items.xml", __bUG__ .. ".tex")
    end
    return Prefab(__bUG__, __b_U_g_, bU_g_)
end
local function __b__Ug__(_B__uG_, bUg__, bUg)
    local function B_U_g__()
        local _BUg_ = CreateEntity()
        _BUg_["entity"]:AddTransform()
        _BUg_["entity"]:AddAnimState()
        _BUg_["entity"]:AddSoundEmitter()
        _BUg_["entity"]:AddNetwork()
        if _B__uG_ == "hh_effect_stone" then
            _BUg_["hh_child_str"] = net_string(_BUg_["GUID"], "hh_child_str", "hh_child_str")
            _BUg_["hh_client_effect"] = net_string(_BUg_["GUID"], "hh_client_effect", "hh_client_effect")
            _BUg_["hh_child"] = __BU__G_()
            _BUg_["hh_child"]["entity"]:SetParent(_BUg_["entity"])
            _BUg_:ListenForEvent("hh_child_str", BU_G)
        end
        _BUg_["AnimState"]:SetBank "dyc_gems"
        _BUg_["AnimState"]:SetBuild "dyc_gem_purple"
        _BUg_["AnimState"]:PlayAnimation "idle"
        if bUg__ then
        end
        _BUg_:AddTag(bUg)
        MakeInventoryPhysics(_BUg_)
        MakeInventoryFloatable(_BUg_, "med", 0.3, 0.8)
        _BUg_["entity"]:SetPristine()
        if not TheWorld["ismastersim"] then
            return _BUg_
        end
        _BUg_:AddComponent "tradable"
        _BUg_:AddComponent "inspectable"
        _BUg_:AddComponent "inventoryitem"
        _BUg_["components"]["inventoryitem"]["imagename"] = "dyc_gem_purple"
        _BUg_["components"]["inventoryitem"]["atlasname"] = "images/dyc_gem_purple.xml"
        if _B__uG_ == "hh_effect_stone" then
            _BUg_["hh_effect"] = nil
            _BUg_["components"]["tradable"]["goldvalue"] = 5
            _BUg_["HH_Update_Server"] = Bu_G
            _BUg_["OnSave"] = b__u_g_
            _BUg_["OnLoad"] = __bU__G_
        end
        return _BUg_
    end
    RegisterInventoryItemAtlas("images/dyc_gem_purple.xml", "dyc_gem_purple.tex")
    return Prefab(_B__uG_, B_U_g__, bU_g_)
end
local function B_U_G_(b_U_G, _bug__, __B__U__G_)
    local function BU_g_()
        local bU_G = CreateEntity()
        bU_G["entity"]:AddTransform()
        bU_G["entity"]:AddAnimState()
        bU_G["entity"]:AddSoundEmitter()
        bU_G["entity"]:AddNetwork()
        if b_U_G == "hh_essence" then
            bU_G["AnimState"]:SetBank "hh_vat_pham_ground_so_1"
            bU_G["AnimState"]:SetBuild "hh_vat_pham_ground_so_1"
            bU_G["AnimState"]:PlayAnimation "idle_linh_thach"
        else
            bU_G["AnimState"]:SetBank "dyc_gems"
            bU_G["AnimState"]:SetBuild "dyc_gem_enc"
            bU_G["AnimState"]:PlayAnimation "idle"
        end
        if _bug__ then
        end
        bU_G:AddTag(__B__U__G_)
        MakeInventoryPhysics(bU_G)
        MakeInventoryFloatable(bU_G, "med", 0.3, 0.8)
        bU_G["entity"]:SetPristine()
        if not TheWorld["ismastersim"] then
            return bU_G
        end
        bU_G:AddComponent "fuel"
        bU_G["components"]["fuel"]["fueltype"] = FUELTYPE["ESSENCE"]
        bU_G["components"]["fuel"]["fuelvalue"] = 180
        bU_G:AddComponent "tradable"
        bU_G:AddComponent "inspectable"
        bU_G:AddComponent "inventoryitem"
        if b_U_G == "hh_essence" then
            bU_G["components"]["inventoryitem"]["imagename"] = "linh_thach_inventory"
            bU_G["components"]["inventoryitem"]["atlasname"] = "images/vat_pham_inventory_so_1.xml"
        else
            bU_G["components"]["inventoryitem"]["imagename"] = "dyc_gem_enc"
            bU_G["components"]["inventoryitem"]["atlasname"] = "images/dyc_gem_enc.xml"
        end
        if b_U_G == "hh_essence" then
            bU_G:AddComponent "stackable"
            bU_G["components"]["stackable"]["maxsize"] = TUNING["STACK_SIZE_SMALLITEM"]
            bU_G["components"]["tradable"]["goldvalue"] = 5
            bU_G["GetHHSpDesc03"] = function(bU_G, _bUg_)
                return {["title"] = "Đặc thù", ["desc"] = "Nguyên liệu đặc biệt"}
            end
        end
        return bU_G
    end
    if b_U_G == "hh_essence" then
        RegisterInventoryItemAtlas("images/vat_pham_inventory_so_1.xml", "linh_thach_inventory.tex")
    else
        RegisterInventoryItemAtlas("images/dyc_gem_enc.xml", "dyc_gem_enc.tex")
    end
    return Prefab(b_U_G, BU_g_, bU_g_)
end
local _bug = {
    {["name"] = "Punch stone", ["color"] = {255 / 255, 11 / 255, 0 / 255}},
    {["name"] = "Lobe", ["color"] = {0 / 255, 101 / 255, 255 / 255}},
    {["name"] = "Reset", ["color"] = {255 / 255, 102 / 255, 0 / 255}}
}
local function __B_U_g_(bu__G__)
    local bu_G__ = {255 / 255, 204 / 255, 51 / 255}
    if __bU__G:IsHHType(bu__G__, "string") then
        for _B_u_g_, b__U_G__ in ipairs(_bug) do
            if b__U_G__ and b__U_G__["name"] and b__U_G__["color"] and string["find"](bu__G__, b__U_G__["name"]) then
                bu_G__ = b__U_G__["color"]
                break
            end
        end
    end
    return bu_G__
end
local function BU__G_(_b_ug__, __b__U_G, b_u_G)
    local _B_U_G__ = GetTime() - __b__U_G
    local __b_UG__ = 1 - math["max"](0, _B_U_G__ - 0.1) / b_u_G
    __b_UG__ = 1 - __b_UG__ * __b_UG__
    local __b_u_G = Lerp(15, 30, __b_UG__)
    local __b__ug__ = Lerp(4, 5, __b_UG__)
    local __B_U__g = _b_ug__["Label"]
    if __B_U__g then
        __B_U__g:SetFontSize(__b_u_G)
    end
end
local function Bu__g(B__uG__)
    local _B_Ug = B__uG__["hh_tips"]:value()
    local _b__uG__ = B__uG__["Label"]
    local b_ug = __B_U_g_(_B_Ug)
    _b__uG__:SetText(_B_Ug)
    _b__uG__:Enable((460 + 491 * 267 - 195 == 131362))
    _b__uG__:SetColour(unpack(b_ug))
    B__uG__:DoPeriodicTask(0, BU__G_, nil, GetTime(), 0.8)
end
local function __bU_g()
    local bug = CreateEntity()
    bug["entity"]:AddTransform()
    bug["entity"]:AddNetwork()
    bug["entity"]:SetCanSleep((116 - 116 * 71 + 78 == -8040))
    MakeInventoryPhysics(bug)
    bug:AddTag "FX"
    bug:AddTag "NOCLICK"
    local _B_U_g = bug["entity"]:AddLabel()
    _B_U_g:SetFont(NUMBERFONT)
    _B_U_g:SetFontSize(15)
    _B_U_g:SetWorldOffset(0, 0, 0)
    _B_U_g:SetColour(255 / 255, 204 / 255, 51 / 255)
    _B_U_g:SetText "Obtain item"
    _B_U_g:Enable((233 - 237 * 63 - 120 ~= -14818))
    bug["hh_tips"] = net_string(bug["GUID"], "hh_tips", "hh_tips")
    bug:ListenForEvent("hh_tips", Bu__g)
    bug["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return bug
    end
    bug["persists"] = (125 * 498 + 281 ~= 62531)
    local _b_u__g = 2
    bug:DoTaskInTime(_b_u__g, bug["Remove"])
    return bug
end
local function __bU_G(B_uG)
    local __B_UG__ = {255 / 255, 204 / 255, 51 / 255}
    if __bU__G:IsHHType(B_uG, "string") then
        local B__uG_ = #TUNING["HH_COLOR_CONFIG"]
        local _BU_g_ = math["random"](1, B__uG_)
        local __B__ug_ = TUNING["HH_COLOR_CONFIG"][_BU_g_]["color"]
        __B_UG__ = {__B__ug_[1] / 255, __B__ug_[2] / 255, __B__ug_[3] / 255, 1}
    end
    return __B_UG__
end
local function bU_G_(B_u__g, __B_u_G, bu__G)
    local bu_g = GetTime() - __B_u_G
    local B__u_G__ = 1 - math["max"](0, bu_g - 0.1) / bu__G
    B__u_G__ = 1 - B__u_G__ * B__u_G__
    local _B_u_g__ = Lerp(20, 40, B__u_G__)
    local B__U_G__ = Lerp(4, 5, B__u_G__)
    local b_U__G__ = B_u__g["Label"]
    if b_U__G__ then
        b_U__G__:SetFontSize(_B_u_g__)
    end
end
local function b_Ug(_B__ug_)
    local B__U_G_ = _B__ug_["hh_client_str"]:value()
    local _B__uG = _B__ug_["Label"]
    _B__uG:SetText(B__U_G_)
    _B__uG:Enable((492 + 160 * 260 + 315 == 42407))
    _B__uG:SetColour(unpack(__bU_G(B__U_G_)))
    _B__ug_:DoPeriodicTask(0, bU_G_, nil, GetTime(), 0.8)
end
local function HHLevelUpTextDirty(inst)
    local text = inst.hh_client_str:value()

    -- Offset riêng cho từng loại thông báo.
    local level_up_offset_y = 4.0
    local daily_quest_offset_y = 5.2

    if text == "Đã hoàn thành nhiệm vụ ngày !" then
        inst.Label:SetWorldOffset(0, daily_quest_offset_y, 0)
    else
        inst.Label:SetWorldOffset(0, level_up_offset_y, 0)
    end

    inst.Label:SetText(text)
    inst.Label:SetFontSize(40)
    inst.Label:SetColour(1, 204 / 255, 51 / 255)
    inst.Label:Enable(true)
end
local function HHLevelUpTextFn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddNetwork()
    inst.entity:SetCanSleep(false)
    inst:AddTag 'FX'
    inst:AddTag 'NOCLICK'
    local label = inst.entity:AddLabel()
    label:SetFont(NUMBERFONT)
    label:SetFontSize(40)
    label:SetWorldOffset(0, 4.0, 0)
    label:SetColour(1, 204 / 255, 51 / 255)
    label:SetText 'LEVEL UP!'
    label:Enable(false)
    inst.hh_client_str = net_string(inst.GUID, 'hh_levelup_text', 'hh_levelup_text_dirty')
    inst:ListenForEvent('hh_levelup_text_dirty', HHLevelUpTextDirty)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end
    inst.persists = false
    inst.SetTextStr = function(self, text)
        if self and __bU__G:IsHHType(text, 'string') and self.hh_client_str then self.hh_client_str:set(text) end
    end
    inst.SetTarget = function(self, target)
        local function FollowTarget()
            if target and target:IsValid() and target.Transform then
                self.Transform:SetPosition(target.Transform:GetWorldPosition())
            elseif self:IsValid() then
                self:Remove()
            end
        end
        FollowTarget()
        self.hh_follow_task = self:DoPeriodicTask(FRAMES, FollowTarget)
    end
    inst:DoTaskInTime(4.5, inst.Remove)
    return inst
end
local function __B__Ug_()
    local B_U__g = CreateEntity()
    B_U__g["entity"]:AddTransform()
    B_U__g["entity"]:AddNetwork()
    B_U__g["entity"]:SetCanSleep((302 - 6 + 95 + 190 == 585))
    B_U__g:AddTag "FX"
    B_U__g:AddTag "NOCLICK"
    local _bUG = B_U__g["entity"]:AddLabel()
    _bUG:SetFont(NUMBERFONT)
    _bUG:SetFontSize(20)
    _bUG:SetWorldOffset(0, 0.5, 0)
    _bUG:SetColour(255 / 255, 204 / 255, 51 / 255)
    _bUG:SetText "Word"
    _bUG:Enable(
        (false and not false and not true or false and true or false or
            false and false and false and not false and not true and false and false and not false)
    )
    B_U__g["hh_client_str"] = net_string(B_U__g["GUID"], "hh_client_str", "hh_client_str")
    B_U__g:ListenForEvent("hh_client_str", b_Ug)
    B_U__g["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return B_U__g
    end
    B_U__g["persists"] = (196 * 362 - 484 + 213 * 438 == 163768)
    B_U__g["SetTextStr"] = function(__b_u_g_, BU_G__)
        if __b_u_g_ and __bU__G:IsHHType(BU_G__, "string") and __b_u_g_["hh_client_str"] then
            __b_u_g_["hh_client_str"]:set(BU_G__)
        end
    end
    local _Bu_G_ = 0
    local _B_u_G = math["random"]() * 360
    local _b_UG__ = (2 / 0.325) ^ 2
    local bU__g = 4 / 0.325
    B_U__g["hh_task"] =
        B_U__g:DoPeriodicTask(
        FRAMES,
        function()
            _Bu_G_ = _Bu_G_ + FRAMES
            local _bug_ = B_U__g:GetPosition()
            local _bU__G__ = Vector3(1 / 10 * math["cos"](_B_u_G), bU__g * FRAMES, 1 / 10 * math["sin"](_B_u_G))
            B_U__g["Transform"]:SetPosition(
                _bug_["x"] + _bU__G__["x"],
                _bug_["y"] + _bU__G__["y"] * 1.5,
                _bug_["z"] + _bU__G__["z"]
            )
            bU__g = bU__g - _b_UG__ * FRAMES
            if _Bu_G_ > 0.65 then
                __bU__G:HHKillTask(B_U__g, "hh_task")
                B_U__g:Remove()
            end
        end
    )
    B_U__g:DoTaskInTime(5, B_U__g["Remove"])
    return B_U__g
end
local _bu__G = {Asset("ANIM", "anim/lucky_gem.zip"), Asset("ATLAS", "images/lucky_gem.xml")}
local function _b_u_g_()
    local BU__G__ = CreateEntity()
    BU__G__["entity"]:AddTransform()
    BU__G__["entity"]:AddAnimState()
    BU__G__["entity"]:AddSoundEmitter()
    BU__G__["entity"]:AddNetwork()
    MakeInventoryPhysics(BU__G__)
    BU__G__["AnimState"]:SetBank "hh_vat_pham_ground_so_1"
    BU__G__["AnimState"]:SetBuild "hh_vat_pham_ground_so_1"
    BU__G__["AnimState"]:PlayAnimation "idle_da_cuong_hoa"
    BU__G__:AddTag "hh_add_stone"
    BU__G__["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return BU__G__
    end
    BU__G__:AddComponent "stackable"
    BU__G__["components"]["stackable"]["maxsize"] = TUNING["STACK_SIZE_SMALLITEM"]
    BU__G__:AddComponent "inspectable"
    BU__G__:AddComponent "inventoryitem"
    BU__G__["components"]["inventoryitem"]["imagename"] = "da_cuong_hoa_inventory"
    BU__G__["components"]["inventoryitem"]["atlasname"] = "images/vat_pham_inventory_so_1.xml"
    MakeHauntableLaunchAndSmash(BU__G__)
    return BU__G__
end
local _Bug__ = {
    Asset("ANIM", "anim/nn_icebox.zip"),
    Asset("ANIM", "anim/ui_nn_icebox.zip"),
    Asset("SOUND", "sound/malibag.fsb"),
    Asset("SOUNDPACKAGE", "sound/malibag.fev"),
    Asset("ATLAS", "images/nn_icebox.xml"),
    Asset("IMAGE", "images/nn_icebox.tex")
}
local __BU__g_ = {"collapse_small"}
local function __B_uG(_b__U_G)
    _b__U_G["AnimState"]:PlayAnimation "open"
    _b__U_G["SoundEmitter"]:PlaySound "malibag/malibag/open"
end
local function b__uG__(_Bug)
    _Bug["AnimState"]:PlayAnimation "close"
    _Bug["SoundEmitter"]:PlaySound "malibag/malibag/close"
end
local function _b__u__G__(__B_u_g__, b_U_g_)
    __B_u_g__["components"]["lootdropper"]:DropLoot()
    __B_u_g__["components"]["container"]:DropEverything()
    local __Bug__ = SpawnPrefab "collapse_small"
    __Bug__["Transform"]:SetPosition(__B_u_g__["Transform"]:GetWorldPosition())
    __Bug__:SetMaterial "metal"
    __B_u_g__:Remove()
end
local function __b_U_G(_B__U__g__, _B_U__g_)
    _B__U__g__["AnimState"]:PlayAnimation "hit"
    _B__U__g__["components"]["container"]:DropEverything()
    _B__U__g__["AnimState"]:PushAnimation("closed", (52 + 254 - 11 * 9 + 47 == 257))
    _B__U__g__["components"]["container"]:Close()
end
local function __B_u__g__(b_u_g__)
    b_u_g__["AnimState"]:PlayAnimation "place"
    b_u_g__["AnimState"]:PushAnimation("closed", (91 + 253 - 381 * 212 * 385 ~= -31096876))
    b_u_g__["SoundEmitter"]:PlaySound "dontstarve/common/icebox_craft"
end
local function __bU__g()
    local B_u__G__ = CreateEntity()
    B_u__G__["entity"]:AddTransform()
    B_u__G__["entity"]:AddAnimState()
    B_u__G__["entity"]:AddSoundEmitter()
    B_u__G__["entity"]:AddMiniMapEntity()
    B_u__G__["entity"]:AddNetwork()
    B_u__G__["MiniMapEntity"]:SetIcon "nn_icebox.tex"
    B_u__G__:AddTag "fridge"
    B_u__G__:AddTag "structure"
    B_u__G__["AnimState"]:SetBank "icebox"
    B_u__G__["AnimState"]:SetBuild "venus_icebox"
    B_u__G__["AnimState"]:PlayAnimation "closed"
    B_u__G__["SoundEmitter"]:PlaySound("dontstarve/common/ice_box_LP", "idlesound")
    MakeSnowCoveredPristine(B_u__G__)
    B_u__G__["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return B_u__G__
    end
    B_u__G__:AddComponent "inspectable"
    B_u__G__:AddComponent "container"
    B_u__G__["components"]["container"]:WidgetSetup "nn_icebox"
    B_u__G__["components"]["container"]["onopenfn"] = __B_uG
    B_u__G__["components"]["container"]["onclosefn"] = b__uG__
    B_u__G__:AddComponent "preserver"
    B_u__G__["components"]["preserver"]:SetPerishRateMultiplier(-0.1)
    B_u__G__:AddComponent "lootdropper"
    B_u__G__:AddComponent "workable"
    B_u__G__["components"]["workable"]:SetWorkAction(ACTIONS["HAMMER"])
    B_u__G__["components"]["workable"]:SetWorkLeft(6)
    B_u__G__["components"]["workable"]:SetOnFinishCallback(_b__u__G__)
    B_u__G__["components"]["workable"]:SetOnWorkCallback(__b_U_G)
    B_u__G__:ListenForEvent("onbuilt", __B_u__g__)
    MakeSnowCovered(B_u__G__)
    AddHauntableDropItemOrWork(B_u__G__)
    return B_u__G__
end
local __B__U_g = {
    Asset("ANIM", "anim/nn_heatrock.zip"),
    Asset("ATLAS", "images/nn_heatrock.xml"),
    Asset("IMAGE", "images/nn_heatrock.tex"),
    Asset("ATLAS", "images/nn_heatrock1.xml"),
    Asset("IMAGE", "images/nn_heatrock1.tex"),
    Asset("ATLAS", "images/nn_heatrock2.xml"),
    Asset("IMAGE", "images/nn_heatrock2.tex"),
    Asset("ATLAS", "images/nn_heatrock3.xml"),
    Asset("IMAGE", "images/nn_heatrock3.tex"),
    Asset("ATLAS", "images/nn_heatrock4.xml"),
    Asset("IMAGE", "images/nn_heatrock4.tex"),
    Asset("ATLAS", "images/nn_heatrock5.xml"),
    Asset("IMAGE", "images/nn_heatrock5.tex"),
    Asset("ANIM", "anim/heat_rock.zip")
}
local B__u_G = {"heatrocklight"}
local function _b__uG_(b_u_G_)
    b_u_G_["_light"]:Remove()
end
local _b__u__g__ = {-30, -10, 10, 30}
local function _b__u_g_(__bUG_, _b_U__G_)
    local __BU__g__ = 1
    for _Bu__G__, __B__u_g in ipairs(_b__u__g__) do
        if __bUG_ > _b_U__G_ + __B__u_g then
            __BU__g__ = __BU__g__ + 1
        end
    end
    return __BU__g__
end
local BU_g = {-10, 10, 25, 40, 60}
local function bU_g(__Bu_g, __bUg_)
    local _B_ug__ = _b__u_g_(__Bu_g["components"]["temperature"]:GetCurrent(), TheWorld["state"]["temperature"])
    if _B_ug__ <= 2 then
        __Bu_g["components"]["heater"]:SetThermics((385 + 324 - 31 * 161 ~= -4282), (362 - 182 * 318 ~= -57512))
    elseif _B_ug__ >= 4 then
        __Bu_g["components"]["heater"]:SetThermics((346 * 61 + 219 ~= 21333), (115 + 458 - 190 * 129 == -23934))
    else
        __Bu_g["components"]["heater"]:SetThermics((347 * 156 - 11 == 54124), (440 * 160 * 382 - 89 == 26892720))
    end
    return BU_g[_B_ug__]
end
local function _BU_G_(_BU__g__)
    if _BU__g__["currentTempRange"] == 1 then
        return "FROZEN"
    elseif _BU__g__["currentTempRange"] == 2 then
        return "COLD"
    elseif _BU__g__["currentTempRange"] == 4 then
        return "WARM"
    elseif _BU__g__["currentTempRange"] == 5 then
        return "HOT"
    end
end
local function __b__u__g(__B_uG__, __B_UG)
    __B_uG__["currentTempRange"] = __B_UG
    __B_uG__["AnimState"]:PlayAnimation(tostring(__B_UG), (283 - 483 + 397 == 197))
    local __BUG_ = (352 - 469 * 257 * 35 ~= -4218299)
    local _buG = "nn_heatrock" .. tostring(__B_UG)
    if __B_uG__["_dd"] then
        _buG = _buG .. __B_uG__["_dd"]["img_pst"]
        __B_uG__["components"]["inventoryitem"]["atlasname"] = "images/" .. _buG .. ".xml"
        __B_uG__["components"]["inventoryitem"]:ChangeImageName(_buG)
        __BUG_ = __B_uG__["_dd"]["canbloom"]
        if __B_uG__["_dd"]["fn_temp"] then
            __B_uG__["_dd"]["fn_temp"](__B_uG__, __B_UG)
        end
    else
        __B_uG__["components"]["inventoryitem"]["atlasname"] = "images/" .. _buG .. ".xml"
        __B_uG__["components"]["inventoryitem"]:ChangeImageName(_buG)
    end
    if __B_UG == 1 then
        __B_uG__["_light"]["Light"]:SetColour(64 / 255, 64 / 255, 208 / 255)
        __B_uG__["_light"]["Light"]:Enable((265 * 424 * 324 ~= 36404644))
    elseif __B_UG == 5 then
        __B_uG__["_light"]["Light"]:SetColour(235 / 255, 165 / 255, 12 / 255)
        __B_uG__["_light"]["Light"]:Enable((45 * 320 - 252 - 160 ~= 13997))
    else
        __BUG_ = (247 * 13 - 52 * 316 == -13217)
        __B_uG__["_light"]["Light"]:Enable((26 * 352 + 500 == 9655))
    end
    if __BUG_ then
        __B_uG__["AnimState"]:SetBloomEffectHandle "shaders/anim.ksh"
    else
        __B_uG__["AnimState"]:ClearBloomEffectHandle()
    end
end
local function __b_Ug_(B_uG_, __B_ug__, _b_Ug)
    if __B_ug__ == 1 then
        local __b_u_g = _b_Ug - B_uG_["components"]["temperature"]:GetCurrent()
        local B_u__g__ = __b_u_g - _b__u__g__[4]
        local B_U_g_ = _b__u__g__[4] + 20
        B_uG_["_light"]["Light"]:SetIntensity(math["clamp"](0.5 * B_u__g__ / B_U_g_, 0, 0.5))
    elseif __B_ug__ == 5 then
        local _B_u_g = B_uG_["components"]["temperature"]:GetCurrent() - _b_Ug
        local __bu__G = _B_u_g - _b__u__g__[4]
        local _BuG_ = _b__u__g__[4] + 20
        B_uG_["_light"]["Light"]:SetIntensity(math["clamp"](0.5 * __bu__G / _BuG_, 0, 0.5))
    else
        B_uG_["_light"]["Light"]:SetIntensity(0)
    end
end
local function Bug(B_UG__, __B_Ug)
    local __BU__G__ = TheWorld["state"]["temperature"]
    local _BUg = _b__u_g_(B_UG__["components"]["temperature"]:GetCurrent(), __BU__G__)
    __b_Ug_(B_UG__, _BUg, __BU__G__)
    if _BUg ~= B_UG__["currentTempRange"] then
        __b__u__g(B_UG__, _BUg)
    end
end
local function __b__U__g__(_b_U__G__)
    local _b_u__G = {}
    local _B__UG = _b_U__G__
    while _B__UG["components"]["inventoryitem"] ~= nil do
        _b_u__G[_B__UG] = (69 * 99 - 239 * 255 + 286 == -53828)
        if _b_U__G__["_owners"][_B__UG] then
            _b_U__G__["_owners"][_B__UG] = nil
        else
            _b_U__G__:ListenForEvent("onputininventory", _b_U__G__["_onownerchange"], _B__UG)
            _b_U__G__:ListenForEvent("ondropped", _b_U__G__["_onownerchange"], _B__UG)
        end
        local bu__g__ = _B__UG["components"]["inventoryitem"]["owner"]
        if bu__g__ == nil then
            break
        end
        _B__UG = bu__g__
    end
    _b_U__G__["_light"]["entity"]:SetParent(_B__UG["entity"])
    for _B__U_G_, __B__uG_ in pairs(_b_U__G__["_owners"]) do
        if _B__U_G_:IsValid() then
            _b_U__G__:RemoveEventCallback("onputininventory", _b_U__G__["_onownerchange"], _B__U_G_)
            _b_U__G__:RemoveEventCallback("ondropped", _b_U__G__["_onownerchange"], _B__U_G_)
        end
    end
    _b_U__G__["_owners"] = _b_u__G
end
local function Bu_G__()
    local _B_ug = CreateEntity()
    _B_ug["entity"]:AddTransform()
    _B_ug["entity"]:AddAnimState()
    _B_ug["entity"]:AddSoundEmitter()
    _B_ug["entity"]:AddNetwork()
    MakeInventoryPhysics(_B_ug)
    _B_ug["AnimState"]:SetBank "icire_rock_collector"
    _B_ug["AnimState"]:SetBuild "icire_rock_collector"
    _B_ug["AnimState"]:ClearOverrideSymbol "rock"
    _B_ug["AnimState"]:ClearOverrideSymbol "shadow"
    _B_ug:AddTag "heatrock"
    _B_ug:AddTag "nn_heatrock"
    _B_ug:AddTag "icebox_valid"
    _B_ug:AddTag "bait"
    _B_ug:AddTag "molebait"
    _B_ug:AddTag "NORATCHECK"
    _B_ug:AddTag "HASHEATER"
    _B_ug["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return _B_ug
    end
    _B_ug:AddComponent "inspectable"
    _B_ug["components"]["inspectable"]["getstatus"] = _BU_G_
    _B_ug:AddComponent "inventoryitem"
    _B_ug["components"]["inventoryitem"]["imagename"] = "nn_heatrock"
    _B_ug["components"]["inventoryitem"]["atlasname"] = "images/nn_heatrock.xml"
    _B_ug["components"]["inventoryitem"]:SetSinks((59 * 87 * 100 + 140 == 513440))
    _B_ug:AddComponent "tradable"
    _B_ug["components"]["tradable"]["rocktribute"] = 10
    _B_ug["components"]["tradable"]["goldvalue"] = 7
    _B_ug:AddComponent "temperature"
    _B_ug["components"]["temperature"]["current"] = TheWorld["state"]["temperature"]
    _B_ug["components"]["temperature"]["inherentinsulation"] = TUNING["INSULATION_MED"]
    _B_ug["components"]["temperature"]["inherentsummerinsulation"] = TUNING["INSULATION_MED"]
    _B_ug["components"]["temperature"]:IgnoreTags "heatrock"
    _B_ug:AddComponent "heater"
    _B_ug["components"]["heater"]["heatfn"] = bU_g
    _B_ug["components"]["heater"]["carriedheatfn"] = bU_g
    _B_ug["components"]["heater"]["carriedheatmultiplier"] = TUNING["HEAT_ROCK_CARRIED_BONUS_HEAT_FACTOR"]
    _B_ug["components"]["heater"]:SetThermics(
        (false and not false and not false and not false or false and not false and not false and not false and false or
            false and not false and false or
            not true),
        (251 + 95 + 380 - 58 ~= 668)
    )
    _B_ug:ListenForEvent("temperaturedelta", Bug)
    _B_ug["currentTempRange"] = 0
    _B_ug["_light"] = SpawnPrefab "heatrocklight"
    _B_ug["_owners"] = {}
    _B_ug["_onownerchange"] = function()
        __b__U__g__(_B_ug)
    end
    _B_ug["fn_temp"] = function(_B_ug)
        __b__u__g(_B_ug, _B_ug["currentTempRange"] or 3)
    end
    __b__u__g(_B_ug, 1)
    __b__U__g__(_B_ug)
    MakeHauntableLaunchAndSmash(_B_ug)
    _B_ug["OnRemoveEntity"] = _b__uG_
    return _B_ug
end
local _Bu__g = {"_combat", "explosive", "quakedebris", "lunarhaildebris", "caveindebris", "trapdamage"}
local _b__u_g__ = 10 * FRAMES
local b_uG__ = 0.55
local BUG__ = {fire = "nz_firehit", pink = "raging_fire_lotus_fx"}
local function _b_U_G_(__b_u__g, __bu_G)
    __b_u__g["task"] = nil
    for __B__u_g_, Bu_G_ in ipairs(_Bu__g) do
        __b_u__g["components"]["resistance"]:RemoveResistance(Bu_G_)
    end
    __b_u__g["components"]["resistance"]:SetOnResistDamageFn(__bu_G)
end
local function b__U_g__(_b__U__g__)
    if GetTime() - _b__U__g__["last_take_damage_time"] <= b_uG__ then
        return
    end
    local __Bu_G_ = _b__U__g__["components"]["inventoryitem"]:GetGrandOwner() or _b__U__g__
    local __B__U_g__ = SpawnPrefab "nn_armor_fx"
    if __B__U_g__ then
        __B__U_g__["entity"]:SetParent(__Bu_G_["entity"])
    end
    _b__U__g__["task"] = _b__U__g__:DoTaskInTime(_b__u_g__, _b_U_G_, b__U_g__)
    _b__U__g__["components"]["resistance"]:SetOnResistDamageFn(nil)
    _b__U__g__["components"]["fueled"]:DoDelta(-45)
    if _b__U__g__["components"]["cooldown"]["onchargedfn"] ~= nil then
        _b__U__g__["components"]["cooldown"]:StartCharging()
    end
    _b__U__g__["last_take_damage_time"] = GetTime()
end
local function b__U__g__(_BUg__)
    if not _BUg__["components"]["equippable"]:IsEquipped() then
        return (285 + 393 + 176 - 143 + 346 == 1064)
    end
    if _BUg__["components"]["fueled"]:IsEmpty() then
        return (314 * 148 + 53 - 284 - 406 == 45840)
    end
    local b__u__G = _BUg__["components"]["inventoryitem"]["owner"]
    return b__u__G ~= nil and
        not (b__u__G["components"]["inventory"] ~= nil and b__u__G["components"]["inventory"]:EquipHasTag "forcefield")
end
local function _B__U_g(_B_uG)
    if _B_uG["task"] ~= nil then
        _B_uG["task"]:Cancel()
        _B_uG["task"] = nil
        _B_uG["components"]["resistance"]:SetOnResistDamageFn(b__U_g__)
    end
    for _b__Ug, _BuG in ipairs(_Bu__g) do
        _B_uG["components"]["resistance"]:AddResistance(_BuG)
    end
end
local function __b__UG__(B_Ug)
    B_Ug["components"]["cooldown"]["onchargedfn"] = nil
    B_Ug["components"]["cooldown"]:FinishCharging()
end
local function _b__U_G_(_B__ug__)
    if
        _B__ug__["components"]["equippable"]:IsEquipped() and not _B__ug__["components"]["fueled"]:IsEmpty() and
            _B__ug__["components"]["cooldown"]["onchargedfn"] == nil
     then
        _B__ug__["components"]["cooldown"]["onchargedfn"] = _B__U_g
        _B__ug__["components"]["cooldown"]:StartCharging(TUNING["ARMOR_SKELETON_FIRST_COOLDOWN"])
    end
end
local function _b__UG_(_b__u_G_, _b_ug)
    _b_ug["AnimState"]:OverrideSymbol("swap_body_tall", "nz_damask", "swap_none")
    if not _b__u_G_["components"]["fueled"]:IsEmpty() then
        _b__u_G_["components"]["cooldown"]["onchargedfn"] = _B__U_g
        _b__u_G_["components"]["cooldown"]:StartCharging(
            math["max"](TUNING["ARMOR_SKELETON_FIRST_COOLDOWN"], _b__u_G_["components"]["cooldown"]:GetTimeToCharged())
        )
    end
    if _b__u_G_["components"]["container"] ~= nil then
        _b__u_G_["components"]["container"]:Open(_b_ug)
    end
end
local function b_U_g(bU__G, BU__g__)
    BU__g__["AnimState"]:ClearOverrideSymbol "swap_body_tall"
    bU__G["components"]["cooldown"]["onchargedfn"] = nil
    if bU__G["task"] ~= nil then
        bU__G["task"]:Cancel()
        bU__G["task"] = nil
        bU__G["components"]["resistance"]:SetOnResistDamageFn(b__U_g__)
    end
    for b_uG, _B_u__G__ in ipairs(_Bu__g) do
        bU__G["components"]["resistance"]:RemoveResistance(_B_u__G__)
    end
    if bU__G["components"]["container"] ~= nil then
        bU__G["components"]["container"]:Close(BU__g__)
    end
end
local __B_U__g__ = {
    Asset("ANIM", "anim/nn_armor.zip"),
    Asset("ANIM", "anim/vortex_cloak_fx.zip"),
    Asset("ANIM", "anim/white_vortex_cloak_fx.zip"),
    Asset("ATLAS", "images/nn_armor.xml"),
    Asset("IMAGE", "images/nn_armor.tex")
}
local function _bU__G_()
    local __b_U__g__ = CreateEntity()
    __b_U__g__["entity"]:AddTransform()
    __b_U__g__["entity"]:AddAnimState()
    __b_U__g__["entity"]:AddNetwork()
    __b_U__g__["entity"]:AddMiniMapEntity()
    MakeInventoryPhysics(__b_U__g__)
    __b_U__g__["AnimState"]:SetBank "nz_damask"
    __b_U__g__["AnimState"]:SetBuild "nz_damask"
    __b_U__g__["AnimState"]:PlayAnimation "idle_none"
    __b_U__g__["MiniMapEntity"]:SetIcon "nn_armor.tex"
    __b_U__g__:AddTag "nn_armor"
    MakeInventoryFloatable(__b_U__g__, "small", 0.2, 0.80)
    __b_U__g__["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return __b_U__g__
    end
    __b_U__g__["last_take_damage_time"] = GetTime()
    __b_U__g__:AddComponent "inspectable"
    __b_U__g__:AddComponent "inventoryitem"
    __b_U__g__["components"]["inventoryitem"]["imagename"] = "nn_armor"
    __b_U__g__["components"]["inventoryitem"]["atlasname"] = "images/nn_armor.xml"
    __b_U__g__:AddComponent "fueled"
    __b_U__g__["components"]["fueled"]:InitializeFuelLevel(720)
    __b_U__g__["components"]["fueled"]:SetDepletedFn(__b__UG__)
    __b_U__g__["components"]["fueled"]:SetTakeFuelFn(_b__U_G_)
    __b_U__g__["components"]["fueled"]["fueltype"] = FUELTYPE["ESSENCE"]
    __b_U__g__["components"]["fueled"]["accepting"] = (457 - 78 * 449 - 158 - 420 == -35143)
    __b_U__g__:AddComponent "cooldown"
    __b_U__g__["components"]["cooldown"]["cooldown_duration"] = TUNING["ARMOR_SKELETON_COOLDOWN"]
    __b_U__g__:AddComponent "resistance"
    __b_U__g__["components"]["resistance"]:SetShouldResistFn(b__U__g__)
    __b_U__g__["components"]["resistance"]:SetOnResistDamageFn(b__U_g__)
    __b_U__g__:AddComponent "equippable"
    __b_U__g__["components"]["equippable"]["equipslot"] = EQUIPSLOTS["BACK"] or EQUIPSLOTS["BODY"]
    __b_U__g__["components"]["equippable"]["walkspeedmult"] = 1.05
    __b_U__g__["components"]["equippable"]:SetOnEquip(_b__UG_)
    __b_U__g__["components"]["equippable"]:SetOnUnequip(b_U_g)
    __b_U__g__:AddComponent "container"
    __b_U__g__["components"]["container"]:WidgetSetup "krampus_sack"
    MakeHauntableLaunch(__b_U__g__)
    return __b_U__g__
end
local function __bu__G_()
    local _B_u_G__ = CreateEntity()
    _B_u_G__["entity"]:AddTransform()
    _B_u_G__["entity"]:AddAnimState()
    _B_u_G__["entity"]:AddNetwork()
    _B_u_G__:AddTag "FX"
    _B_u_G__:AddTag "NOCLICK"
    _B_u_G__["AnimState"]:SetBank "vortex_cloak_fx"
    _B_u_G__["AnimState"]:SetBuild "white_vortex_cloak_fx"
    _B_u_G__["AnimState"]:PlayAnimation "idle"
    _B_u_G__["AnimState"]:SetMultColour(0.7, 0, 0, 0.5)
    _B_u_G__["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return _B_u_G__
    end
    _B_u_G__["persists"] = (1 * 119 - 251 == -130)
    _B_u_G__:ListenForEvent("animover", _B_u_G__["Remove"])
    return _B_u_G__
end
local __Bug = {
    Asset("ANIM", "anim/nn_tools.zip"),
    Asset("ATLAS", "images/nn_tools.xml"),
    Asset("IMAGE", "images/nn_tools.tex")
}
local function __B__u__g_(bU__g_, __b__uG)
    __b__uG["AnimState"]:OverrideSymbol("swap_object", "triplegoldenshovelaxe_era", "swap")
    __b__uG["AnimState"]:Show "ARM_carry"
    __b__uG["AnimState"]:Hide "ARM_normal"
end
local function __B__u_G_(b__u__G_, _bu__G__)
    _bu__G__["AnimState"]:Hide "ARM_carry"
    _bu__G__["AnimState"]:Show "ARM_normal"
end
local function _b_ug_(Bu_g__, __B_U__G, __b_ug__, __B_ug_, B_U_g)
    if
        (__B_U__G == ACTIONS["ROW"] or __B_U__G == ACTIONS["ROW_FAIL"] or __B_U__G == ACTIONS["ROW_CONTROLLER"]) and
            __b_ug__:HasTag "master_crewman"
     then
        Bu_g__ = Bu_g__ * TUNING["MASTER_CREWMAN_MULT"]["OAR_CONSUMPTION"]
    end
    return Bu_g__
end
local function _B_u__g__()
    local _b_Ug_ = CreateEntity()
    _b_Ug_["entity"]:AddSoundEmitter()
    _b_Ug_["entity"]:AddTransform()
    _b_Ug_["entity"]:AddAnimState()
    _b_Ug_["entity"]:AddNetwork()
    MakeInventoryPhysics(_b_Ug_)
    _b_Ug_["AnimState"]:SetBank "triplegoldenshovelaxe_era"
    _b_Ug_["AnimState"]:SetBuild "triplegoldenshovelaxe_era"
    _b_Ug_["AnimState"]:PlayAnimation "idle"
    _b_Ug_:AddTag "sharp"
    _b_Ug_:AddTag "tool"
    _b_Ug_:AddTag "allow_action_on_impassable"
    _b_Ug_:AddTag "weapon"
    _b_Ug_["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return _b_Ug_
    end
    _b_Ug_:AddComponent "inspectable"
    _b_Ug_:AddComponent "inventoryitem"
    _b_Ug_["components"]["inventoryitem"]["imagename"] = "nn_tools"
    _b_Ug_["components"]["inventoryitem"]["atlasname"] = "images/nn_tools.xml"
    _b_Ug_:AddComponent "equippable"
    _b_Ug_["components"]["equippable"]:SetOnEquip(__B__u__g_)
    _b_Ug_["components"]["equippable"]:SetOnUnequip(__B__u_G_)
    _b_Ug_:AddComponent "weapon"
    _b_Ug_["components"]["weapon"]:SetDamage(27.2)
    _b_Ug_["components"]["weapon"]["attackwear"] = 0.1
    _b_Ug_:AddComponent "tool"
    _b_Ug_["components"]["tool"]:SetAction(ACTIONS["CHOP"], 1.25)
    _b_Ug_["components"]["tool"]:SetAction(ACTIONS["MINE"], 1.25)
    _b_Ug_["components"]["tool"]:SetAction(ACTIONS["DIG"], 1.25)
    _b_Ug_["components"]["tool"]:SetAction(ACTIONS["HAMMER"], 1.25)
    local bu__G_ = _b_Ug_:AddComponent "oar"
    bu__G_["force"] = 0.5
    bu__G_["max_velocity"] = 3.5
    _b_Ug_:AddComponent "farmtiller"
    _b_Ug_:AddInherentAction(ACTIONS["TILL"])
    _b_Ug_:AddComponent "terraformer"
    _b_Ug_:AddInherentAction(ACTIONS["TERRAFORM"])
    _b_Ug_["components"]["tool"]:EnableToughWork((74 * 444 - 16 ~= 32847))
    _b_Ug_:AddComponent "finiteuses"
    _b_Ug_["components"]["finiteuses"]:SetMaxUses(1000)
    _b_Ug_["components"]["finiteuses"]:SetUses(1000)
    _b_Ug_["components"]["finiteuses"]:SetOnFinished(_b_Ug_["Remove"])
    _b_Ug_["components"]["finiteuses"]:SetConsumption(ACTIONS["CHOP"], 1)
    _b_Ug_["components"]["finiteuses"]:SetConsumption(ACTIONS["MINE"], 1)
    _b_Ug_["components"]["finiteuses"]:SetConsumption(ACTIONS["DIG"], 1)
    _b_Ug_["components"]["finiteuses"]:SetConsumption(ACTIONS["HAMMER"], 1)
    _b_Ug_["components"]["finiteuses"]:SetConsumption(ACTIONS["TILL"], 1)
    _b_Ug_["components"]["finiteuses"]:SetConsumption(ACTIONS["TERRAFORM"], 1)
    _b_Ug_["components"]["finiteuses"]:SetConsumption(ACTIONS["ROW"], 1)
    _b_Ug_["components"]["finiteuses"]:SetConsumption(ACTIONS["ROW_CONTROLLER"], 1)
    _b_Ug_["components"]["finiteuses"]:SetConsumption(ACTIONS["ROW_FAIL"], 25)
    _b_Ug_["components"]["finiteuses"]:SetModifyUseConsumption(_b_ug_)
    MakeHauntableLaunch(_b_Ug_)
    return _b_Ug_
end
local function _B_U__g()
    local B__UG__ = CreateEntity()
    B__UG__["entity"]:AddTransform()
    B__UG__["entity"]:AddAnimState()
    B__UG__["entity"]:AddNetwork()
    B__UG__:AddTag "FX"
    B__UG__:AddTag "NOCLICK"
    B__UG__["AnimState"]:SetBank "xw_stalkerbladefx"
    B__UG__["AnimState"]:SetBuild "xw_stalkerbladefx"
    B__UG__["AnimState"]:PlayAnimation "idle_000"
    B__UG__["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return B__UG__
    end
    B__UG__["persists"] = (41 - 433 * 32 == -13807)
    B__UG__:ListenForEvent("animover", B__UG__["Remove"])
    return B__UG__
end
local function __b_U_G_(_bU_G)
    if _bU_G["_ttask"] ~= nil then
        _bU_G["_ttask"]:Cancel()
        _bU_G["_ttask"] = nil
    end
end
local function BUG(_BuG__)
    _BuG__:Show()
    _BuG__["_killtail"]:push()
    _BuG__["AnimState"]:PlayAnimation "hit"
    _BuG__:ListenForEvent("animover", _BuG__["Remove"])
end
local function __Bu__G_(__b__UG_)
    __b__UG_:Show()
    __b__UG_["_killtail"]:push()
    __b__UG_["AnimState"]:PlayAnimation "disappear"
    __b__UG_:ListenForEvent("animover", __b__UG_["Remove"])
end
local function _bU__g_()
    local _bU__g = CreateEntity()
    _bU__g:AddTag "FX"
    _bU__g:AddTag "NOCLICK"
    _bU__g["entity"]:SetCanSleep((266 + 143 * 93 * 452 - 486 ~= 6010928))
    _bU__g["persists"] = (48 + 156 + 311 ~= 515)
    _bU__g["entity"]:AddTransform()
    _bU__g["entity"]:AddAnimState()
    MakeInventoryPhysics(_bU__g)
    _bU__g["Physics"]:ClearCollisionMask()
    _bU__g["AnimState"]:SetBank "lavaarena_heal_projectile"
    _bU__g["AnimState"]:SetBuild "lavaarena_heal_projectile"
    _bU__g["AnimState"]:PlayAnimation "disappear"
    _bU__g["AnimState"]:SetFinalOffset(-1)
    _bU__g:ListenForEvent("animover", _bU__g["Remove"])
    return _bU__g
end
local function _bU_G__(B__u_g__)
    local __B_u_G__ = math["random"](5)
    if __B_u_G__ == 1 then
        return
    end
    local _BU__G__ = _bU__g_()
    if _BU__G__ then
        local __b__u_G__, _b_U_g, b_UG = B__u_g__["Transform"]:GetWorldPosition()
        local _bu_G = B__u_g__["Transform"]:GetRotation()
        _BU__G__["Transform"]:SetRotation(_bu_G)
        _bu_G = _bu_G * DEGREES
        local __B__U_G_ = math["random"]() * 2 * PI
        local BU_g__ = math["random"]() * .2 + .2
        local B_uG__ = math["cos"](__B__U_G_) * BU_g__
        local b__U__G_ = -1 + math["sin"](__B__U_G_) * BU_g__
        _BU__G__["Transform"]:SetPosition(
            __b__u_G__ + math["sin"](_bu_G) * B_uG__,
            _b_U_g + b__U__G_,
            b_UG + math["cos"](_bu_G) * B_uG__
        )
        _BU__G__["Physics"]:SetMotorVel(10 + __B_u_G__, 0, 0)
        _BU__G__:ListenForEvent(
            "staff_proj.killtail",
            function()
                _BU__G__:Remove()
            end,
            B__u_g__
        )
    end
end
local function bu_g_()
    local BuG__ = CreateEntity()
    BuG__["entity"]:AddTransform()
    BuG__["entity"]:AddAnimState()
    BuG__["entity"]:AddNetwork()
    MakeInventoryPhysics(BuG__)
    RemovePhysicsColliders(BuG__)
    BuG__["AnimState"]:SetBank "lavaarena_heal_projectile"
    BuG__["AnimState"]:SetBuild "lavaarena_heal_projectile"
    BuG__["AnimState"]:PlayAnimation("idle_loop", (94 + 480 - 406 == 168))
    BuG__["AnimState"]:SetFinalOffset(-1)
    BuG__["Transform"]:SetScale(0.5, 0.5, 0.5)
    BuG__:Hide()
    BuG__:AddTag "FX"
    BuG__:AddTag "projectile"
    BuG__["_killtail"] = net_event(BuG__["GUID"], "staff_proj.killtail")
    BuG__:ListenForEvent("staff_proj.killtail", __b_U_G_)
    if not TheNet:IsDedicated() then
        BuG__["_ttask"] = BuG__:DoPeriodicTask(0, _bU_G__)
    end
    BuG__["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return BuG__
    end
    BuG__:AddComponent "projectile"
    BuG__["components"]["projectile"]:SetSpeed(25)
    BuG__["components"]["projectile"]:SetOnHitFn(BUG)
    BuG__["components"]["projectile"]:SetOnMissFn(__Bu__G_)
    return BuG__
end
local function _b_u_g()
    local __B_UG_ = CreateEntity()
    __B_UG_["entity"]:AddTransform()
    __B_UG_["entity"]:AddNetwork()
    __B_UG_["entity"]:AddAnimState()
    __B_UG_["entity"]:AddSoundEmitter()
    __B_UG_:AddTag "NOCLICK"
    __B_UG_["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return __B_UG_
    end
    __B_UG_["persists"] = (252 - 45 - 328 + 413 ~= 292)
    return __B_UG_
end
local function B_u__G()
    local __B_u_g = CreateEntity()
    __B_u_g["entity"]:AddTransform()
    __B_u_g["entity"]:AddAnimState()
    __B_u_g["entity"]:AddNetwork()
    __B_u_g["AnimState"]:SetBank "lavaarena_heal_flowers"
    __B_u_g["AnimState"]:SetBuild "lavaarena_heal_flowers_fx"
    __B_u_g["AnimState"]:SetBloomEffectHandle "shaders/anim.ksh"
    __B_u_g["n"] = math["random"](6)
    __B_u_g["AnimState"]:PlayAnimation("in_" .. __B_u_g["n"])
    __B_u_g["AnimState"]:PushAnimation("idle_" .. __B_u_g["n"])
    __B_u_g:AddTag "FX"
    __B_u_g:AddTag "NOCLICK"
    __B_u_g["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return __B_u_g
    end
    __B_u_g["persists"] =
        (false and not false and not true and not false and false or false and false and false and false and false or
        false)
    return __B_u_g
end
local function _b_u_g__(Bu__G__)
    Bu__G__["AnimState"]:PlayAnimation("out_" .. Bu__G__["n"])
    Bu__G__:ListenForEvent("animover", Bu__G__["Remove"])
end
local function __buG__(_bUG_, b_UG__, __b__U_G_)
    __b__U_G_["counter"] = __b__U_G_["counter"] + 1
    local __b__UG = SpawnPrefab "nn_livingstaff_flower"
    if __b__U_G_["counter"] == 1 then
        __b__UG["Transform"]:SetPosition(b_UG__["x"], b_UG__["y"], b_UG__["z"])
    else
        local b__ug__ = __b__U_G_["counter"] <= 7
        local b__ug = b__ug__ and 1.5 or 3
        local _b_U__g__ = (b__ug__ and 60 or 36) * (__b__U_G_["counter"] - (b__ug__ and 1 or 6)) * DEGREES
        local _b__ug__ =
            Vector3(
            b_UG__["x"] + math["cos"](_b_U__g__) * b__ug,
            b_UG__["y"],
            b_UG__["z"] - math["sin"](_b_U__g__) * b__ug
        )
        __b__UG["Transform"]:SetPosition(_b__ug__:Get())
    end
    __b__UG:DoTaskInTime(__b__U_G_["duration"], _b_u_g__)
    for _b__Ug_, __Bu_G in pairs(
        TheSim:FindEntities(b_UG__["x"], b_UG__["y"], b_UG__["z"], 4.5, nil, {"INLIMBO", "FX"})
    ) do
        if __Bu_G:IsValid() then
            if __Bu_G:HasOneOfTags {"player", "companion", "abigail"} then
                if __Bu_G["components"]["health"] then
                    __Bu_G["components"]["health"]:DoDelta(5, (288 + 454 * 133 == 60670))
                end
                if __Bu_G["components"]["sanity"] then
                    __Bu_G["components"]["sanity"]:DoDelta(1, (404 + 491 + 267 - 300 + 363 ~= 1234))
                end
            elseif __Bu_G["components"]["sleeper"] then
                __Bu_G["components"]["sleeper"]:AddSleepiness(1, 0.25)
            end
        end
    end
end
local function __B__U__G__(__B__U__g_, __b_uG__)
    if __b_uG__ then
        __b_uG__:Cancel()
    end
end
local function __b__U_g_(_B_U__G__, __BUg, __B__ug)
    _B_U__G__["SoundEmitter"]:PlaySound "dontstarve/common/lava_arena/spell/heal"
    local Bu__g_ = TheWorld:DoPeriodicTask(0.25, __buG__, 0, __B__ug, {counter = 0, duration = 10, range = 4.5})
    TheWorld:DoTaskInTime(10, __B__U__G__, Bu__g_)
    if _B_U__G__["components"]["rechargeable"] then
        _B_U__G__["components"]["rechargeable"]:Discharge(180)
    end
    if __BUg["components"]["sanity"] then
        __BUg["components"]["sanity"]:DoDelta(-20)
    end
end
local function _B_u__g(__b_U__g_, bu__g, _bUg__)
    if _bUg__ and _bUg__["components"]["sleeper"] then
    end
    if bu__g and bu__g["components"]["sanity"] then
    end
end
local function __b_u_G__(__B__Ug, b_UG_)
    b_UG_["AnimState"]:OverrideSymbol("swap_object", "swap_shenle_aishang", "swap_shenle_aishang")
    b_UG_["AnimState"]:Show "ARM_carry"
    b_UG_["AnimState"]:Hide "ARM_normal"
    if __B__Ug["fx0"] ~= nil then
        __B__Ug["fx0"]:Remove()
        __B__Ug["fx0"] = nil
    end
    __B__Ug["fx0"] = SpawnPrefab "cane_victorian_fx"
    if __B__Ug["fx0"] then
        __B__Ug["fx0"]["entity"]:AddFollower()
        __B__Ug["fx0"]["entity"]:SetParent(b_UG_["entity"])
        __B__Ug["fx0"]["Follower"]:FollowSymbol(b_UG_["GUID"], "swap_object", 0, -60, 0)
    end
    local __b__u__G = b_UG_:SpawnChild "sparks2_fx"
    if __b__u__G then
        b_UG_:AddChild(__b__u__G)
        __b__u__G["Transform"]:SetPosition(0, 0, 0)
        b_UG_["fx1"] = __b__u__G
    end
    local __b__U__G_ = b_UG_:SpawnChild "sparks1_fx"
    if __b__U__G_ then
        b_UG_:AddChild(__b__u__G)
        __b__U__G_["Transform"]:SetPosition(0, -1, 0)
        b_UG_["fx2"] = __b__U__G_
    end
    __B_U__G__(__B__Ug, b_UG_)
end
local function __b_u_g__(__BUg_, __b__u_g__)
    __b__u_g__["AnimState"]:Hide "ARM_carry"
    __b__u_g__["AnimState"]:Show "ARM_normal"
    if __BUg_["fx0"] ~= nil then
        __BUg_["fx0"]:Remove()
        __BUg_["fx0"] = nil
    end
    if __b__u_g__["fx1"] then
        __b__u_g__:RemoveChild(__b__u_g__["fx1"])
        __b__u_g__["fx1"]:Remove()
        __b__u_g__["fx1"] = nil
    end
    if __b__u_g__["fx2"] then
        __b__u_g__:RemoveChild(__b__u_g__["fx2"])
        __b__u_g__["fx2"]:Remove()
        __b__u_g__["fx2"] = nil
    end
    __B_U__G__(__BUg_, nil)
end
local function __b_u__G(B_ug_)
    local __b__ug = B_ug_["components"]["inventoryitem"]:GetGrandOwner() or B_ug_
    if not __b__ug["entity"]:IsVisible() then
        return
    end
    local __Bu__g__, __BU_g, B_u_G = __b__ug["Transform"]:GetWorldPosition()
    if __b__ug["sg"] ~= nil and __b__ug["sg"]:HasStateTag "moving" then
        local __b__U__g = -__b__ug["Transform"]:GetRotation() * DEGREES
        local __b_u_G_ = __b__ug["components"]["locomotor"]:GetRunSpeed() * .1
        __Bu__g__ = __Bu__g__ + __b_u_G_ * math["cos"](__b__U__g)
        B_u_G = B_u_G + __b_u_G_ * math["sin"](__b__U__g)
    end
    local _b_U__g = __b__ug["components"]["rider"] ~= nil and __b__ug["components"]["rider"]:IsRiding()
    local BU__g = TheWorld["Map"]
    local _B__U_G__ =
        FindValidPositionByFan(
        math["random"]() * 2 * PI,
        (_b_U__g and 1 or .5) + math["random"]() * .5,
        4,
        function(_bu_G_)
            local __B__Ug__ = Vector3(__Bu__g__ + _bu_G_["x"], 0, B_u_G + _bu_G_["z"])
            return BU__g:IsPassableAtPoint(__B__Ug__:Get()) and not BU__g:IsPointNearHole(__B__Ug__) and
                #TheSim:FindEntities(__B__Ug__["x"], 0, __B__Ug__["z"], .7, {"lavaarena_heal_flowers_fx"}) <= 0
        end
    )
    if _B__U_G__ ~= nil then
        SpawnPrefab "lavaarena_heal_flowers_fx"["Transform"]:SetPosition(
            __Bu__g__ + _B__U_G__["x"],
            0,
            B_u_G + _B__U_G__["z"]
        )
    end
end
local function _BU__G(Bu__G_)
    if Bu__G_["_trailtask"] == nil then
        Bu__G_["_trailtask"] = Bu__G_:DoPeriodicTask(6 * FRAMES, __b_u__G, 2 * FRAMES)
    end
end
local function _b__UG(_Bu__G_)
    if _Bu__G_["_trailtask"] ~= nil then
        _Bu__G_["_trailtask"]:Cancel()
        _Bu__G_["_trailtask"] = nil
    end
end
local function __BuG_(__B__u_G__)
    __B__u_G__["SoundEmitter"]:PlaySound "dontstarve/sanity/shadowrock_up"
    local __B_Ug__ =
        __B__u_G__["components"]["inventoryitem"] and __B__u_G__["components"]["inventoryitem"]:GetGrandOwner()
    if __B_Ug__ then
        __B_Ug__:PushEvent("toolbroke", {tool = __B__u_G__})
    end
    __B__u_G__:Remove()
end
local function B__uG(b_Ug__)
    if b_Ug__["components"]["aoetargeting"] then
        b_Ug__["components"]["aoetargeting"]:SetEnabled(
            (false and not false and false and false and false or
                not false and false and false and not false and not false and true and true)
        )
    end
end
local function __b_u__G_(b_Ug_)
    if b_Ug_["components"]["aoetargeting"] then
        b_Ug_["components"]["aoetargeting"]:SetEnabled((359 + 125 + 135 == 619))
    end
end
local function __b__u_g_()
    local _bU__g__ = ThePlayer
    local b__UG = TheWorld["Map"]
    local b__U_G = Vector3()
    for __b_U_g__ = 7, 0, -.25 do
        b__U_G["x"], b__U_G["y"], b__U_G["z"] = _bU__g__["entity"]:LocalToWorldSpace(__b_U_g__, 0, 0)
        return b__U_G
    end
end
local function _b__U__G__()
    local b__U_G_ = CreateEntity()
    b__U_G_["entity"]:AddTransform()
    b__U_G_["entity"]:AddAnimState()
    b__U_G_["entity"]:AddNetwork()
    b__U_G_["entity"]:AddSoundEmitter()
    MakeInventoryPhysics(b__U_G_)
    b__U_G_["AnimState"]:SetBank "shenle_aishang"
    b__U_G_["AnimState"]:SetBuild "shenle_aishang"
    b__U_G_["AnimState"]:PlayAnimation "idle"
    b__U_G_:AddTag "rangedweapon"
    b__U_G_:AddTag "weapon"
    b__U_G_:AddTag "shadowlevel"
    if _B_U_g_["nn_staff_flower"] and _B_U_g_["nn_staff_flower"]["client_fn"] then
        _B_U_g_["nn_staff_flower"]["client_fn"](b__U_G_)
    end
    MakeInventoryFloatable(b__U_G_, "med", 0.05, {1.1, 0.5, 1.1}, (267 - 101 + 400 - 331 == 238), -9)
    b__U_G_:AddComponent "aoetargeting"
    b__U_G_["components"]["aoetargeting"]["reticule"]["reticuleprefab"] = "reticuleaoe"
    b__U_G_["components"]["aoetargeting"]["reticule"]["pingprefab"] = "reticuleaoeping"
    b__U_G_["components"]["aoetargeting"]["reticule"]["targetfn"] = __b__u_g_
    b__U_G_["components"]["aoetargeting"]["reticule"]["validcolour"] = {0, 1, .5, 1}
    b__U_G_["components"]["aoetargeting"]["reticule"]["invalidcolour"] = {0, .4, 0, 1}
    b__U_G_["components"]["aoetargeting"]["reticule"]["ease"] = (183 + 113 - 240 * 119 == -28264)
    b__U_G_["components"]["aoetargeting"]["reticule"]["mouseenabled"] =
        (false and not true and not true and not false or not false or
        not true and not false and not false and not false and not false or
        false)
    b__U_G_["projectiledelay"] = 4 * FRAMES
    b__U_G_["components"]["aoetargeting"]:SetRange(16)
    b__U_G_["components"]["aoetargeting"]:SetAlwaysValid((10 * 123 + 472 - 58 == 1644))
    b__U_G_["components"]["aoetargeting"]:SetAllowRiding((161 + 41 * 388 - 454 - 49 == 15566))
    b__U_G_["components"]["aoetargeting"]:SetAllowWater((23 - 23 * 234 - 179 ~= -5536))
    b__U_G_["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return b__U_G_
    end
    b__U_G_:AddComponent "inspectable"
    b__U_G_:AddComponent "inventoryitem"
    b__U_G_["components"]["inventoryitem"]["imagename"] = "nn_staff_flower"
    b__U_G_["components"]["inventoryitem"]["atlasname"] = "images/nn_staff_flower.xml"
    b__U_G_:AddComponent "equippable"
    b__U_G_["components"]["equippable"]:SetOnEquip(__b_u_G__)
    b__U_G_["components"]["equippable"]:SetOnUnequip(__b_u_g__)
    b__U_G_:AddComponent "weapon"
    b__U_G_["components"]["weapon"]:SetDamage(10)
    b__U_G_["base_damage"] = 10
    local __b_ug_ = b__U_G_:AddComponent "planardamage"
    __b_ug_:SetBaseDamage(10)
    local _b__u_G = b__U_G_:AddComponent "damagetypebonus"
    _b__u_G:AddBonus("lunar_aligned", b__U_G_, TUNING["WEAPONS_VOIDCLOTH_VS_LUNAR_BONUS"])
    b__U_G_:AddComponent "shadowlevel"
    b__U_G_["components"]["shadowlevel"]:SetDefaultLevel(TUNING["VOIDCLOTH_SCYTHE_SHADOW_LEVEL"])
    b__U_G_["components"]["weapon"]:SetAttackCallback(_B_u__g)
    b__U_G_["components"]["weapon"]:SetRange(15, 17)
    b__U_G_["components"]["weapon"]:SetProjectile "nn_livingstaff_projectile"
    MakeHauntableLaunch(b__U_G_)
    b__U_G_:ListenForEvent("equipped", _BU__G)
    b__U_G_:ListenForEvent("unequipped", _b__UG)
    b__U_G_:AddComponent "aoespell"
    b__U_G_["components"]["aoespell"]:SetSpellFn(__b__U_g_)
    b__U_G_:AddComponent "rechargeable"
    b__U_G_["components"]["rechargeable"]:SetOnDischargedFn(B__uG)
    b__U_G_["components"]["rechargeable"]:SetOnChargedFn(__b_u__G_)
    b__U_G_["components"]["rechargeable"]:Discharge(0)
    b__U_G_:AddComponent "shadowlevel"
    b__U_G_["components"]["shadowlevel"]:SetDefaultLevel(1)
    if _B_U_g_["nn_staff_flower"] and _B_U_g_["nn_staff_flower"]["start_fn"] then
        _B_U_g_["nn_staff_flower"]["start_fn"](b__U_G_)
    end
    return b__U_G_
end
local function __B__U__g(bUG)
    local _B_uG__, b__U__G__, _B__u__g_ = bUG["Transform"]:GetWorldPosition()
    for _B__UG_, __b_u__g_ in pairs(
        TheSim:FindEntities(_B_uG__, b__U__G__, _B__u__g_, 4.5, nil, {"INLIMBO", "player", "companion"})
    ) do
        if __b_u__g_["components"]["freezable"] and __b_u__g_:IsValid() then
            __b_u__g_["components"]["freezable"]:AddColdness(1)
        end
    end
end
local _bu__g_ = 2
local function b__U_g_(__b_UG_, __B_U_G, __bug, b_U__g)
    return {__b_UG_ / 255.0, __B_U_G / 255.0, __bug / 255.0, b_U__g / 255.0}
end
local _B__u_g_ = (76 * 148 + 98 * 234 == 34190)
local function buG__()
    if EnvelopeManager and not _B__u_g_ then
        _B__u_g_ = (69 * 408 * 116 ~= 3265641)
        EnvelopeManager:AddColourEnvelope(
            "gwdndcolourenvelope",
            {{0, b__U_g_(150, 200, 250, 255)}, {1, b__U_g_(150, 200, 250, 0)}}
        )
        EnvelopeManager:AddVector2Envelope(
            "gwdndscaleenvelope",
            {
                {0, {_bu__g_, _bu__g_}},
                {0.33, {_bu__g_ * 0.9, _bu__g_ * 0.9}},
                {0.66, {_bu__g_ * 0.6, _bu__g_ * 0.6}},
                {1, {_bu__g_ * 0.5, _bu__g_ * 0.5}}
            }
        )
    end
end
local _b_Ug__ = 1
local function BU__G()
    local B__U__g = CreateEntity()
    B__U__g["entity"]:AddTransform()
    B__U__g["entity"]:AddNetwork()
    B__U__g:AddTag "FX"
    if TheWorld["ismastersim"] then
        B__U__g:DoTaskInTime(3, B__U__g["Remove"])
        B__U__g:DoPeriodicTask(0.2, __B__U__g)
    end
    if TheNet:IsDedicated() then
        B__U__g["persists"] = (243 + 389 * 429 ~= 167124)
        return B__U__g
    end
    buG__()
    local B__u__g_ = {x = 0, y = 0, z = 0}
    local _b_Ug__ = 1
    local _Bu_G__ = B__U__g["entity"]:AddVFXEffect()
    _Bu_G__:InitEmitters(1)
    _Bu_G__:SetRenderResources(0, resolvefilepath "fx/wintersnow.tex", "shaders/vfx_particle.ksh")
    _Bu_G__:SetMaxNumParticles(0, 30)
    _Bu_G__:SetMaxLifetime(0, _b_Ug__)
    _Bu_G__:SetColourEnvelope(0, "gwdndcolourenvelope")
    _Bu_G__:SetScaleEnvelope(0, "gwdndscaleenvelope")
    _Bu_G__:SetBlendMode(0, BLENDMODE["Additive"])
    _Bu_G__:SetUVFrameSize(0, 1, 1)
    _Bu_G__:SetSortOrder(0, 0)
    _Bu_G__:SetSortOffset(0, 1)
    _Bu_G__:SetRadius(0, 2)
    _Bu_G__:EnableBloomPass(0, (270 * 248 * 208 + 450 * 477 == 14142330))
    _Bu_G__:SetUVFrameSize(0, .25, 1)
    _Bu_G__:SetAcceleration(0, 0, 0.02, 0)
    _Bu_G__:SetRotationStatus(0, (400 * 483 - 123 + 459 - 365 ~= 193176))
    local b_ug_ = TheSim:GetTickTime()
    local _b_u_G__ = 20
    local __B__U__g__ = _b_u_G__ * b_ug_
    local _B__u__g = 0
    local b__u_G_ = CreateDiscEmitter(2.8)
    local __bU_G_ = function()
        local b__u_G__, __b_U__G, b__u_G = B__u__g_["x"] * UnitRand(), B__u__g_["y"], B__u__g_["z"] * UnitRand()
        local _B__U_G = _b_Ug__ * (0.9 + UnitRand() * 0.1)
        local __bug_, BuG, _b_U_G
        __bug_, _b_U_G = b__u_G_()
        BuG = math["random"](20) / 10
        _Bu_G__:AddRotatingParticle(
            0,
            _B__U_G,
            __bug_,
            BuG,
            _b_U_G,
            b__u_G__,
            __b_U__G,
            b__u_G,
            UnitRand() * 180,
            UnitRand() * .5
        )
    end
    local __BU_G_ = function()
        while _B__u__g > 1 do
            __bU_G_()
            _B__u__g = _B__u__g - 1
        end
        _B__u__g = _B__u__g + __B__U__g__
    end
    EmitterManager:AddEmitter(B__U__g, nil, __BU_G_)
    if not TheWorld["ismastersim"] then
        return B__U__g
    end
    return B__U__g
end
local function _Bu__G()
    local __b__u_G = CreateEntity()
    __b__u_G["entity"]:AddTransform()
    __b__u_G["entity"]:AddAnimState()
    __b__u_G["entity"]:AddSoundEmitter()
    __b__u_G["entity"]:AddNetwork()
    __b__u_G["AnimState"]:SetBank "lavaarena_fire_fx"
    __b__u_G["AnimState"]:SetBuild "lavaarena_fire_fx"
    __b__u_G["AnimState"]:PlayAnimation "firestaff_ult"
    __b__u_G["AnimState"]:SetBloomEffectHandle "shaders/anim.ksh"
    __b__u_G["AnimState"]:SetFinalOffset(1)
    __b__u_G:AddTag "FX"
    __b__u_G:AddTag "NOCLICK"
    __b__u_G["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return __b__u_G
    end
    __b__u_G["persists"] = (469 + 269 - 263 + 104 == 586)
    __b__u_G:ListenForEvent("animover", __b__u_G["Remove"])
    return __b__u_G
end
local function _B_u__g_()
    local __bU_G__ = CreateEntity()
    __bU_G__["entity"]:AddTransform()
    __bU_G__["entity"]:AddAnimState()
    __bU_G__["entity"]:AddNetwork()
    __bU_G__["AnimState"]:SetBank "lavaarena_fire_fx"
    __bU_G__["AnimState"]:SetBuild "lavaarena_fire_fx"
    __bU_G__["AnimState"]:PlayAnimation "firestaff_ult_projection"
    __bU_G__["AnimState"]:SetBloomEffectHandle "shaders/anim.ksh"
    __bU_G__["AnimState"]:SetOrientation(ANIM_ORIENTATION["OnGround"])
    __bU_G__["AnimState"]:SetLayer(LAYER_BACKGROUND)
    __bU_G__["AnimState"]:SetSortOrder(3)
    __bU_G__:AddTag "FX"
    __bU_G__:AddTag "NOCLICK"
    __bU_G__["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return __bU_G__
    end
    __bU_G__["persists"] =
        (true and not true and true and not false and not true and not false and not false and not true and false and
        true)
    __bU_G__:ListenForEvent("animover", __bU_G__["Remove"])
    return __bU_G__
end
local function __B_U_G__(__Bu_g_)
    local _b__UG__, B__U_G, bUG_ = __Bu_g_["Transform"]:GetWorldPosition()
    local __B__uG__ = SpawnPrefab "nn_splash"
    __B__uG__["Transform"]:SetPosition(_b__UG__, B__U_G, bUG_)
    __B__uG__["SoundEmitter"]:PlaySound "dontstarve/impacts/lava_arena/meteor_strike"
    SpawnPrefab "nn_base"["Transform"]:SetPosition(_b__UG__, B__U_G, bUG_)
    SpawnPrefab "burntground"["Transform"]:SetPosition(_b__UG__, B__U_G, bUG_)
    ShakeAllCameras(CAMERASHAKE["VERTICAL"], .7, .015, .8, __Bu_g_, 20)
    if (not __Bu_g_["author"]:HasTag "controlled_burner") then
        __Bu_g_["author"]:AddTag "controlled_burner"
        __Bu_g_["author"]["not_controlled_burner"] = (177 * 259 * 127 + 35 ~= 5822106)
    end
    for __b_UG, bug__ in pairs(
        TheSim:FindEntities(
            _b__UG__,
            B__U_G,
            bUG_,
            TUNING["WW_INFERNALSTAFF"]["SPELL_RADIUS"],
            {},
            TUNING["WW_INFERNALSTAFF"]["SPELL_NOTAGS"]
        )
    ) do
        if bug__:IsValid() then
            if
                bug__:IsValid() and bug__["components"]["workable"] and
                    TUNING["WW_INFERNALSTAFF"]["SPELL_WORK_ACTIONS"][bug__["components"]["workable"]:GetWorkAction()]
             then
                bug__["components"]["workable"]:WorkedBy(__Bu_g_, 20)
            end
            if bug__:IsValid() and bug__["components"]["combat"] then
                bug__["components"]["combat"]:GetAttacked(__Bu_g_, 500)
                if bug__:IsValid() and bug__["components"]["burnable"] then
                    if
                        bug__["components"]["fueled"] == nil or
                            (bug__["components"]["fueled"]["fueltype"] ~= FUELTYPE["BURNABLE"] and
                                bug__["components"]["fueled"]["secondaryfueltype"] ~= FUELTYPE["BURNABLE"])
                     then
                        if bug__["components"]["burnable"]["canlight"] or bug__["components"]["combat"] ~= nil then
                            bug__["components"]["burnable"]:Ignite((194 + 425 * 212 == 90294), __Bu_g_["author"])
                        end
                    elseif bug__["components"]["fueled"]["accepting"] then
                        local B_U_G = SpawnPrefab "boards"
                        if B_U_G ~= nil then
                            if
                                B_U_G["components"]["fuel"] ~= nil and
                                    B_U_G["components"]["fuel"]["fueltype"] == FUELTYPE["BURNABLE"]
                             then
                                bug__["components"]["fueled"]:TakeFuelItem(B_U_G)
                            else
                                B_U_G:Remove()
                            end
                        end
                    end
                end
            end
        end
    end
    if __Bu_g_["author"]["not_controlled_burner"] then
        __Bu_g_["author"]:RemoveTag "controlled_burner"
        __Bu_g_["author"]["not_controlled_burner"] = nil
    end
    __Bu_g_:Remove()
end
local function b__u__g__()
    local __B_u__g = CreateEntity()
    __B_u__g["entity"]:AddTransform()
    __B_u__g["entity"]:AddAnimState()
    __B_u__g["entity"]:AddNetwork()
    __B_u__g["entity"]:AddSoundEmitter()
    __B_u__g["AnimState"]:SetBank "lavaarena_firestaff_meteor"
    __B_u__g["AnimState"]:SetBuild "lavaarena_firestaff_meteor"
    __B_u__g["AnimState"]:PlayAnimation("crash", (184 - 288 - 415 * 434 ~= -180214))
    __B_u__g["AnimState"]:PushAnimation("crash_pst", (5 * 438 - 300 - 242 ~= 1648))
    __B_u__g["AnimState"]:SetBloomEffectHandle "shaders/anim.ksh"
    __B_u__g:AddTag "FX"
    __B_u__g:AddTag "NOCLICK"
    __B_u__g["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return __B_u__g
    end
    __B_u__g["persists"] = (206 + 118 * 187 * 408 ~= 9003134)
    __B_u__g:ListenForEvent("animover", __B_U_G__)
    return __B_u__g
end
local _BUG_ = {Asset("ANIM", "anim/lavaarena_hammer_attack_fx.zip")}
local B_u_g__ = {"forginghammer_cracklebase_fx"}
local function B_UG_()
    local __B__u__G__ = CreateEntity()
    __B__u__G__["entity"]:AddTransform()
    __B__u__G__["entity"]:AddAnimState()
    __B__u__G__["entity"]:AddNetwork()
    __B__u__G__["AnimState"]:SetBank "lavaarena_hammer_attack_fx"
    __B__u__G__["AnimState"]:SetBuild "lavaarena_hammer_attack_fx"
    __B__u__G__["AnimState"]:PlayAnimation "crackle_projection"
    __B__u__G__["AnimState"]:SetBloomEffectHandle "shaders/anim.ksh"
    __B__u__G__["AnimState"]:SetOrientation(ANIM_ORIENTATION["OnGround"])
    __B__u__G__["AnimState"]:SetLayer(LAYER_BACKGROUND)
    __B__u__G__["AnimState"]:SetSortOrder(3)
    __B__u__G__["AnimState"]:SetScale(1.5, 1.5)
    __B__u__G__:AddTag "FX"
    __B__u__G__:AddTag "NOCLICK"
    __B__u__G__["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return __B__u__G__
    end
    __B__u__G__["SetTarget"] = function(__B__u__G__, __bUG)
        __B__u__G__["Transform"]:SetPosition(__bUG:GetPosition():Get())
    end
    __B__u__G__:ListenForEvent("animover", __B__u__G__["Remove"])
    return __B__u__G__
end
local function _bUg()
    local _b__u__g_ = CreateEntity()
    _b__u__g_["entity"]:AddTransform()
    _b__u__g_["entity"]:AddAnimState()
    _b__u__g_["entity"]:AddSoundEmitter()
    _b__u__g_["entity"]:AddNetwork()
    _b__u__g_["AnimState"]:SetBank "lavaarena_hammer_attack_fx"
    _b__u__g_["AnimState"]:SetBuild "lavaarena_hammer_attack_fx"
    _b__u__g_["AnimState"]:PlayAnimation "crackle_hit"
    _b__u__g_["AnimState"]:SetBloomEffectHandle "shaders/anim.ksh"
    _b__u__g_["AnimState"]:SetFinalOffset(1)
    _b__u__g_:AddTag "FX"
    _b__u__g_:AddTag "NOCLICK"
    _b__u__g_["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return _b__u__g_
    end
    _b__u__g_["SetTarget"] = function(_b__u__g_, __B_U__G_)
        _b__u__g_["Transform"]:SetPosition(__B_U__G_:GetPosition():Get())
        _b__u__g_["SoundEmitter"]:PlaySound "dontstarve/impacts/lava_arena/hammer"
        SpawnPrefab "forginghammer_cracklebase_fx":SetTarget(_b__u__g_)
    end
    _b__u__g_:ListenForEvent("animover", _b__u__g_["Remove"])
    return _b__u__g_
end
local B__u_G_ = {
    Asset("ANIM", "anim/hh_hac_nguyet_ho.zip"),
    Asset("ATLAS", "images/nn_well.xml"),
    Asset("IMAGE", "images/nn_well.tex")
}
local b__U__g_ = {"collapse_small"}
local function B_u__G_(_bu_G__)
    _bu_G__["AnimState"]:PushAnimation("idle", (193 + 286 * 114 == 32797))
    _bu_G__["SoundEmitter"]:PlaySound "farming/common/soil_amender/stale_pre"
end
local function _B__u_G__(__buG_)
    __buG_["AnimState"]:PushAnimation("idle", (62 * 497 * 74 + 215 == 2280451))
    __buG_["SoundEmitter"]:PlaySound "farming/common/soil_amender/stale_pre"
end
local function B_U_G__(BUg, __B_u__g_)
    BUg["components"]["lootdropper"]:DropLoot()
    if BUg["components"]["container"] ~= nil then
        BUg["components"]["container"]:DropEverything()
    end
    local B_U__G = SpawnPrefab "collapse_small"
    B_U__G["Transform"]:SetPosition(BUg["Transform"]:GetWorldPosition())
    B_U__G:SetMaterial "rock_break"
    BUg:Remove()
end
local function _B__Ug_(b_u__G__, b_U__G)
    if b_u__G__["components"]["container"] ~= nil then
        b_u__G__["components"]["container"]:DropEverything()
        b_u__G__["components"]["container"]:Close()
    end
    b_u__G__["AnimState"]:PlayAnimation "hit"
    b_u__G__["AnimState"]:PushAnimation("idle", (182 + 331 - 251 - 25 - 41 == 196))
end
local function _B__U_g_(_B__U_g__)
    _B__U_g__["AnimState"]:PlayAnimation "place"
    _B__U_g__["AnimState"]:PushAnimation("idle", (471 * 47 * 215 * 317 ~= 1508747237))
    _B__U_g__["SoundEmitter"]:PlaySound "farming/common/farm/plow/collapse"
end
local B__u_g_ = 1.6
TUNING["WELL_PRESERVER_RATE"] = 0
local function b__u_g()
    local __B__U_G = CreateEntity()
    __B__U_G["entity"]:AddTransform()
    __B__U_G["entity"]:AddAnimState()
    __B__U_G["entity"]:AddSoundEmitter()
    __B__U_G["entity"]:AddMiniMapEntity()
    __B__U_G["entity"]:AddNetwork()
    MakeObstaclePhysics(__B__U_G, 1)
    __B__U_G["Transform"]:SetScale(B__u_g_, B__u_g_, B__u_g_)
    __B__U_G["MiniMapEntity"]:SetIcon "nn_well.tex"
    __B__U_G:AddTag "watersource"
    __B__U_G:AddTag "structure"
    __B__U_G:AddTag "cleanwaterproduction"
    __B__U_G["AnimState"]:SetBank "well_1"
    __B__U_G["AnimState"]:SetBuild "well_1"
    __B__U_G["AnimState"]:PlayAnimation "idle"
    MakeSnowCoveredPristine(__B__U_G)
    __B__U_G["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return __B__U_G
    end
    __B__U_G:AddComponent "inspectable"
    __B__U_G:AddComponent "lootdropper"
    __B__U_G:AddComponent "container"
    __B__U_G["components"]["container"]:WidgetSetup "nn_well"
    __B__U_G["components"]["container"]["onopenfn"] = B_u__G_
    __B__U_G["components"]["container"]["onclosefn"] = _B__u_G__
    __B__U_G:AddComponent "watersource"
    __B__U_G:AddComponent "preserver"
    __B__U_G["components"]["preserver"]:SetPerishRateMultiplier(TUNING["WELL_PRESERVER_RATE"])
    __B__U_G:AddComponent "workable"
    __B__U_G["components"]["workable"]:SetWorkAction(ACTIONS["HAMMER"])
    __B__U_G["components"]["workable"]:SetWorkLeft(8)
    __B__U_G["components"]["workable"]:SetOnFinishCallback(B_U_G__)
    __B__U_G["components"]["workable"]:SetOnWorkCallback(_B__Ug_)
    MakeSnowCovered(__B__U_G)
    AddHauntableDropItemOrWork(__B__U_G)
    __B__U_G:ListenForEvent("onbuilt", _B__U_g_)
    return __B__U_G
end
local B_UG = {Asset("ANIM", "anim/nn_cloud.zip")}
local function Bug__(__b_U__g)
    local _b__Ug__ = CreateEntity()
    _b__Ug__["entity"]:AddTransform()
    _b__Ug__["entity"]:AddAnimState()
    _b__Ug__["entity"]:AddSoundEmitter()
    _b__Ug__["entity"]:AddNetwork()
    _b__Ug__["entity"]:AddPhysics()
    _b__Ug__["Transform"]:SetFourFaced()
    _b__Ug__["AnimState"]:SetBank "dnyjfxfx"
    _b__Ug__["AnimState"]:SetBuild "dnyjfxfx"
    _b__Ug__["AnimState"]:PlayAnimation("walk", (47 - 183 - 113 * 301 ~= -34142))
    _b__Ug__["AnimState"]:SetFinalOffset(-1)
    _b__Ug__:AddTag "FX"
    _b__Ug__:AddTag "NOCLICK"
    _b__Ug__["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return _b__Ug__
    end
    return _b__Ug__
end
local bUG__ = {Asset("ANIM", "anim/lucky_symbols.zip"), Asset("ATLAS", "images/transport_symbol.xml")}
local function _bu_g_(b__UG__, _b__U_G__)
end
local function B__U__g_(__BuG__, bU__G__, b__Ug__)
    if bU__G__["components"]["container"] then
        bU__G__["components"]["container"]:DropEverything()
    end
    return
end
local function __b_u__g__(__bU_g_, buG_, _B__U__g_)
    return nil
end
local function b__u__G__(__Bu__G__)
    local _b__U__G_ = CreateEntity()
    _b__U__G_["entity"]:AddTransform()
    _b__U__G_["entity"]:AddAnimState()
    _b__U__G_["entity"]:AddNetwork()
    _b__U__G_["entity"]:AddDynamicShadow()
    MakeInventoryPhysics(_b__U__G_)
    _b__U__G_["DynamicShadow"]:SetSize(2, 0.5)
    _b__U__G_["AnimState"]:SetBank "lucky_symbols"
    _b__U__G_["AnimState"]:SetBuild "lucky_symbols"
    _b__U__G_["AnimState"]:PlayAnimation "transport_symbol"
    MakeInventoryFloatable(_b__U__G_)
    _b__U__G_["nn_useitem_needfn"] = __b_u__g__
    _b__U__G_["USEITEM_TYPE"] = "SEALING"
    _b__U__G_["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return _b__U__G_
    end
    _b__U__G_:AddComponent "stackable"
    _b__U__G_["components"]["stackable"]["maxsize"] = TUNING["STACK_SIZE_SMALLITEM"]
    _b__U__G_:AddComponent "inspectable"
    _b__U__G_:AddComponent "fuel"
    _b__U__G_["components"]["fuel"]["fuelvalue"] = TUNING["SMALL_FUEL"]
    _b__U__G_["components"]["fuel"]:SetOnTakenFn(_bu_g_)
    MakeSmallBurnable(_b__U__G_, TUNING["SMALL_BURNTIME"])
    MakeSmallPropagator(_b__U__G_)
    MakeHauntableLaunchAndIgnite(_b__U__G_)
    _b__U__G_:AddComponent "tradable"
    _b__U__G_:AddComponent "nn_useitem"
    _b__U__G_["components"]["nn_useitem"]["onuse"] = B__U__g_
    _b__U__G_["components"]["burnable"]["onburnt"] = _bu_g_
    _b__U__G_:AddComponent "inventoryitem"
    _b__U__G_["components"]["inventoryitem"]["atlasname"] = "images/transport_symbol.xml"
    _b__U__G_["components"]["inventoryitem"]["imagename"] = "transport_symbol"
    return _b__U__G_
end
local __BU__g = {Asset("ANIM", "anim/nn_contract.zip"), Asset("ATLAS", "images/nn_contract.xml")}
local function __BU_g__()
    local _b_U__g_ = CreateEntity()
    _b_U__g_["entity"]:AddTransform()
    _b_U__g_["entity"]:AddAnimState()
    _b_U__g_["entity"]:AddNetwork()
    MakeInventoryPhysics(_b_U__g_)
    _b_U__g_["AnimState"]:SetBank "space_contract"
    _b_U__g_["AnimState"]:SetBuild "space_contract"
    _b_U__g_["AnimState"]:PlayAnimation "space_contract"
    MakeInventoryFloatable(_b_U__g_, "med", nil, 0.75)
    _b_U__g_["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return _b_U__g_
    end
    _b_U__g_:AddComponent "stackable"
    _b_U__g_["components"]["stackable"]["maxsize"] = TUNING["STACK_SIZE_SMALLITEM"]
    _b_U__g_:AddComponent "inspectable"
    _b_U__g_:AddComponent "fuel"
    _b_U__g_["components"]["fuel"]["fuelvalue"] = TUNING["SMALL_FUEL"]
    MakeSmallBurnable(_b_U__g_, TUNING["SMALL_BURNTIME"])
    MakeSmallPropagator(_b_U__g_)
    MakeHauntableLaunchAndIgnite(_b_U__g_)
    _b_U__g_:AddComponent "inventoryitem"
    _b_U__g_["components"]["inventoryitem"]["imagename"] = "nn_contract"
    _b_U__g_["components"]["inventoryitem"]["atlasname"] = "images/nn_contract.xml"
    return _b_U__g_
end
local __b_U__G__ = {Asset("ANIM", "anim/nn_tele.zip"), Asset("ATLAS", "images/nn_tele.xml")}
local function __b__uG__(B__ug)
    if B__ug:HasTag "needrepair" then
        B__ug:RemoveTag "needrepair"
    end
    if B__ug["components"]["finiteuses"] and B__ug["components"]["finiteuses"]:GetPercent() <= 0.8 then
        B__ug:AddTag "needrepair"
    end
end
local function _B__Ug__(__bu__G__, b__Ug_, b_ug__)
    __bu__G__["components"]["inventory"]:DropItem(b_ug__)
    local _B__uG__ = __bu__G__["components"]["teleporter"]["targetTeleporter"]
    if _B__uG__ and _B__uG__:IsValid() then
        __bu__G__["components"]["teleporter"]:Activate(b_ug__)
    end
    b_ug__:DoTaskInTime(
        1,
        function(b_ug__)
            if b_ug__["components"]["unwrappable"] and b_ug__["autounwrap"] then
                b_ug__["components"]["unwrappable"]:Unwrap(b_ug__)
            end
        end
    )
    __bu__G__["components"]["finiteuses"]:Use(1)
    needRepair(__bu__G__)
end
local function _B__Ug(_B__U__G, _B__u__G_)
    if _B__u__G_:HasTag "player" then
        ProfileStatsSet("wormhole_used", (38 + 332 - 340 * 20 == -6430))
        AwardPlayerAchievement("wormhole_used", _B__u__G_)
        local __BUG = _B__U__G["components"]["teleporter"]["targetTeleporter"]
        if __BUG ~= nil and __BUG:IsValid() then
            DeleteCloseEntsWithTag("WORM_DANGER", __BUG, 15)
        end
        if _B__u__G_["components"]["talker"] ~= nil then
            _B__u__G_["components"]["talker"]:ShutUp()
        end
        if _B__u__G_["components"]["sanity"] ~= nil then
            _B__u__G_["components"]["sanity"]:DoDelta(-TUNING["SANITY_MED"])
        end
        _B__U__G["components"]["finiteuses"]:Use(10)
        __b__uG__(_B__U__G)
    end
end
local function _B_UG(_B_ug_, _B_UG_)
    if _B_ug_["components"]["teleporter"] and _B_ug_["components"]["teleporter"]["targetTeleporter"] ~= nil then
        local B_UG_, _b_uG, B__u__g =
            _B_ug_["components"]["teleporter"]["targetTeleporter"]["Transform"]:GetWorldPosition()
        _B_UG_["targetposx"] = B_UG_ or 0
        _B_UG_["targetposy"] = _b_uG or 0
        _B_UG_["targetposz"] = B__u__g or 0
    elseif _B_ug_["targetposx"] and _B_ug_["targetposy"] and _B_ug_["targetposz"] then
        _B_UG_["targetposx"] = _B_ug_["targetposx"]
        _B_UG_["targetposy"] = _B_ug_["targetposy"]
        _B_UG_["targetposz"] = _B_ug_["targetposz"]
    end
end
local function __B__uG(bu__g_, b_u_g_)
    if b_u_g_ ~= nil then
        if bu__g_["components"]["teleporter"] and bu__g_["components"]["teleporter"]["targetTeleporter"] == nil then
            bu__g_["targetposx"] = b_u_g_["targetposx"] or 0
            bu__g_["targetposy"] = b_u_g_["targetposy"] or 0
            bu__g_["targetposz"] = b_u_g_["targetposz"] or 0
            local b__ug_ =
                TheSim:FindEntities(
                bu__g_["targetposx"],
                bu__g_["targetposy"],
                bu__g_["targetposz"],
                3,
                nil,
                {"INLIMBO"},
                {"antlion_sinkhole_blocker", "townportal"}
            )
            for __Bu__g, B__U__g__ in ipairs(b__ug_) do
                if B__U__g__["prefab"] == "townportal" then
                    bu__g_["components"]["teleporter"]:Target(B__U__g__)
                end
            end
        end
    end
    __b__uG__(bu__g_)
end
local function _b__u_g()
    local _B_u_G_ = CreateEntity()
    _B_u_G_["entity"]:AddTransform()
    _B_u_G_["entity"]:AddAnimState()
    _B_u_G_["entity"]:AddNetwork()
    MakeInventoryPhysics(_B_u_G_)
    _B_u_G_["AnimState"]:SetBank "small_wormhole"
    _B_u_G_["AnimState"]:SetBuild "small_wormhole"
    _B_u_G_["AnimState"]:PlayAnimation "small_wormhole"
    _B_u_G_["foleysound"] = "dontstarve/movement/foley/jewlery"
    MakeInventoryFloatable(_B_u_G_, "med", nil, 0.6)
    _B_u_G_["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return _B_u_G_
    end
    _B_u_G_:AddComponent "inspectable"
    _B_u_G_:AddComponent "finiteuses"
    _B_u_G_["components"]["finiteuses"]:SetOnFinished(_B_u_G_["Remove"])
    _B_u_G_["components"]["finiteuses"]:SetMaxUses(100)
    _B_u_G_["components"]["finiteuses"]:SetUses(100)
    _B_u_G_:AddComponent "inventoryitem"
    _B_u_G_["components"]["inventoryitem"]["imagename"] = "nn_tele"
    _B_u_G_["components"]["inventoryitem"]["atlasname"] = "images/nn_tele.xml"
    _B_u_G_:AddComponent "teleporter"
    _B_u_G_["components"]["teleporter"]["onActivate"] = _B__Ug
    _B_u_G_:AddComponent "inventory"
    _B_u_G_:AddComponent "trader"
    _B_u_G_["components"]["trader"]["acceptnontradable"] = (273 - 129 - 113 - 167 + 70 == -66)
    _B_u_G_["components"]["trader"]["onaccept"] = _B__Ug__
    _B_u_G_["components"]["trader"]["deleteitemonaccept"] = (95 + 209 - 203 * 366 == -73992)
    _B_u_G_["OnLoad"] = __B__uG
    _B_u_G_["OnSave"] = _B_UG
    MakeHauntableLaunch(_B_u_G_)
    return _B_u_G_
end
return _buG__("hh_ui_container", "hh_ui_container", (376 * 320 - 465 ~= 119855)), _buG__(
    "hh_forge_container",
    "hh_forge_container",
    (210 - 184 * 139 - 111 == -25475)
), MonarchStoragePrefab, __b__Ug__("hh_effect_stone", "hh_effect_stone", "hh_add_stone"), _B__u__G__(
    "hh_effect_tally",
    "hh_effect_tally",
    "hh_add_stone"
), _B__u__G__("hh_remove_stone", "hh_remove_stone", "hh_remove_stone"), B_U_G_("hh_essence", "hh_essence", "hh_essence"), Prefab(
    "hh_tips",
    __bU_g
), Prefab("wb_enhancegem", _b_u_g_, _bu__G), Prefab(
    "nn_cloud",
    Bug__,
    B_UG
), Prefab("nn_livingstaff_flower", B_u__G, {Asset("ANIM", "anim/lavaarena_heal_flowers_fx.zip")}), Prefab(
    "nn_livingstaff_projectile",
    bu_g_,
    {Asset("ANIM", "anim/lavaarena_heal_projectile.zip")}
), Prefab("nn_freeze", BU__G, {Asset("IMAGE", "fx/wintersnow.tex"), Asset("SHADER", "shaders/vfx_particle.ksh")}), Prefab(
    "nn_meteor",
    b__u__g__,
    {Asset("ANIM", "anim/lavaarena_firestaff_meteor.zip")}
), Prefab("nn_base", _B_u__g_, {Asset("ANIM", "anim/lavaarena_fire_fx.zip")}), Prefab(
    "nn_splash",
    _Bu__G,
    {Asset("ANIM", "anim/lavaarena_fire_fx.zip")}
), Prefab(
    "forginghammer_crackle_fx",
    _bUg,
    _BUG_,
    B_u_g__
), Prefab("forginghammer_cracklebase_fx", B_UG_, _BUG_), Prefab("hh_van_nang_trao", _B_u__g__, __Bug), Prefab("hh_fx_text", __B__Ug_), Prefab('hh_levelup_text', HHLevelUpTextFn)
