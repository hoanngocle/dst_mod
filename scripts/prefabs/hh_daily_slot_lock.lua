local SLOT_DATA = {
    hands = {
        slot = EQUIPSLOTS.HANDS,
        atlas = "images/hh_slot_lock_hands.xml",
        image = "hh_slot_lock_hands",
    },
    body = {
        slot = EQUIPSLOTS.BODY,
        atlas = "images/hh_slot_lock_body.xml",
        image = "hh_slot_lock_body",
    },
    head = {
        slot = EQUIPSLOTS.HEAD,
        atlas = "images/hh_slot_lock_head.xml",
        image = "hh_slot_lock_head",
    },
}

for _, data in pairs(SLOT_DATA) do
    RegisterInventoryItemAtlas(data.atlas, data.image .. '.tex')
end

local assets = {
    Asset("ANIM", "anim/cursed_beads.zip"),
    Asset("ATLAS", "images/hh_slot_lock_hands.xml"),
    Asset("IMAGE", "images/hh_slot_lock_hands.tex"),
    Asset("ATLAS", "images/hh_slot_lock_body.xml"),
    Asset("IMAGE", "images/hh_slot_lock_body.tex"),
    Asset("ATLAS", "images/hh_slot_lock_head.xml"),
    Asset("IMAGE", "images/hh_slot_lock_head.tex"),
}

local function OnSave(inst, data)
    data.hh_slot_lock_owner_userid = inst.hh_slot_lock_owner_userid
end

local function OnLoad(inst, data)
    if data then
        inst.hh_slot_lock_owner_userid = data.hh_slot_lock_owner_userid
    end
end

local function IsValidLockOwner(inst, owner, slot_name)
    local components = owner ~= nil and owner.components or nil
    local penalty = components ~= nil and components.hh_slot_lock_penalty or nil
    return owner ~= nil
        and owner.userid ~= nil
        and penalty ~= nil
        and not penalty._reincarnation_detaching
        and penalty:IsActive()
        and penalty.locked_slot == slot_name
        and inst.hh_slot_lock_owner_userid == owner.userid
end

local function OnPutInInventory(inst, owner, slot_name)
    if not IsValidLockOwner(inst, owner, slot_name) then
        if owner ~= nil then
            owner:DoTaskInTime(0, function()
                if inst:IsValid()
                    and inst.components.inventoryitem ~= nil
                    and inst.components.inventoryitem.owner == owner then
                    inst:Remove()
                end
            end)
        elseif inst:IsValid() then
            inst:Remove()
        end
    end
end

local function GetRemainingSeconds(inst)
    local owner = inst.components.inventoryitem ~= nil
        and inst.components.inventoryitem.owner or nil
    local penalty = owner ~= nil and owner.components ~= nil
        and owner.components.hh_slot_lock_penalty or nil

    return penalty ~= nil and math.ceil(penalty:GetRemaining()) or 0
end

local function MakeSlotLock(slot_name, data)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("cursedbeads")
        inst.AnimState:SetBuild("cursed_beads")
        inst.AnimState:PlayAnimation("idle1")

        inst:AddTag("hh_daily_slot_lock")
        inst:AddTag("nosteal")
        inst:AddTag("cursed")

        MakeInventoryFloatable(inst, "med", 0.05, 0.68)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")
        inst.components.inspectable.descriptionfn = function(inst)
            local format = STRINGS.HH_DAILY_SLOT_LOCK_DESCRIPTIONS[slot_name]
            return string.format(format, GetRemainingSeconds(inst))
        end

        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.atlasname = data.atlas
        inst.components.inventoryitem:ChangeImageName(data.image)
        inst.components.inventoryitem.keepondeath = true
        inst.components.inventoryitem.keepondrown = true
        inst.components.inventoryitem.canonlygoinpocket = true
        -- This is an internal state artifact, never a loot item.  These are
        -- the same vanilla-supported controls used by internal WX-78 items;
        -- the dropped callback is the final no-ground-copy guard.
        inst.components.inventoryitem.canbepickedup = false
        inst.components.inventoryitem.cangoincontainer = false
        inst.components.inventoryitem:SetOnDroppedFn(function(dropped)
            if dropped:IsValid() then
                dropped:Remove()
            end
        end)
        inst.components.inventoryitem:SetOnPutInInventoryFn(function(item, owner)
            OnPutInInventory(item, owner, slot_name)
        end)

        inst:AddComponent("equippable")
        inst.components.equippable.equipslot = data.slot

        inst.OnSave = OnSave
        inst.OnLoad = OnLoad

        MakeHauntableLaunch(inst)

        -- A legacy serialized ground copy has no OnDropped event to invoke.
        -- Remove it on the next simulation tick; freshly spawned valid locks
        -- are equipped synchronously and therefore already have an owner.
        inst:DoTaskInTime(0, function(item)
            if item:IsValid()
                and item.components.inventoryitem ~= nil
                and item.components.inventoryitem.owner == nil then
                item:Remove()
            end
        end)

        return inst
    end

    return Prefab("hh_daily_slot_lock_" .. slot_name, fn, assets)
end

local prefabs = {}
for slot_name, data in pairs(SLOT_DATA) do
    table.insert(prefabs, MakeSlotLock(slot_name, data))
end

return unpack(prefabs)
