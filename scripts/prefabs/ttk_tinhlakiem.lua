-- Tinh La Kiem, adapted from Tu Tien 19.7 xd_xlj; see docs/CREDITS.md.
local repairvalues = require("ttk_tinhlakiem_repair")
local Elements = require("ttk_elemental_combat")
local assets = {
    Asset("ANIM", "anim/ttk_tinhlakiem.zip"),
    Asset("ATLAS", "images/inventoryimages/ttk_tinhlakiem.xml"),
    Asset("IMAGE", "images/inventoryimages/ttk_tinhlakiem.tex"),
}
local prefabs = { "nightsword_sharp_fx" }

local function RemoveFX(inst)
    if inst._vfx_fx_inst ~= nil then
        inst._vfx_fx_inst:Remove()
        inst._vfx_fx_inst = nil
    end
end

local function OnEquip(inst, owner)
    local build, symbol = require("ttk_skins").GetEquipPresentation(inst, "xd_xlj", "swap")
    owner.AnimState:OverrideSymbol("swap_object", build, symbol)
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    RemoveFX(inst)
    local fx = SpawnPrefab("nightsword_sharp_fx")
    if fx ~= nil then
        inst._vfx_fx_inst = fx
        fx.entity:AddFollower()
        fx.entity:SetParent(owner.entity)
        fx.Follower:FollowSymbol(owner.GUID, "swap_object", 0, -100, 0)
    end
    Elements.Equip(inst, owner, 3)
end

local function OnUnequip(inst, owner)
    Elements.Unequip(inst)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    RemoveFX(inst)
end

local function OnEquipToModel(inst)
    Elements.Unequip(inst)
    RemoveFX(inst)
end

local function OnRemove(inst)
    Elements.Unequip(inst)
    RemoveFX(inst)
end

local function UpdateDamage(inst)
    require("ttk_weapon_damage").SetBase(inst, 100)
end

local function CanRepair(inst, item, giver, count)
    return item ~= nil and item ~= inst and repairvalues[item.prefab] ~= nil
        and (count == nil or count == 1)
        and inst.components.finiteuses:GetPercent() < 1
end

local function OnRepair(inst, giver, item)
    inst.components.finiteuses:Repair(repairvalues[item.prefab])
    if giver ~= nil and giver.SoundEmitter ~= nil then
        giver.SoundEmitter:PlaySound("dontstarve/common/nightmareAddFuel")
    end
end

local function Fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst)
    inst.AnimState:SetBank("xd_xlj")
    inst.AnimState:SetBuild("xd_xlj")
    inst.AnimState:PlayAnimation("idle")
    inst:AddTag("sharp")
    inst:AddTag("pointy")
    inst:AddTag("weapon")
    inst:AddTag("nosteal")
    inst:AddTag("allow_action_on_impassable")
    inst:AddTag("alltrader")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end

    inst.fxcolour = {63/255, 127/255, 176/255}
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(100)
    inst.components.weapon:SetRange(2)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(1000)
    inst.components.finiteuses:SetUses(300)
    inst.components.finiteuses:SetDoesNotStartFull(true)
    -- Damage stays at 100 even when empty; preserve Solo enhancement on repair/load.
    inst:ListenForEvent("percentusedchange", UpdateDamage)

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/ttk_tinhlakiem.xml"
    inst.components.inventoryitem.imagename = "ttk_tinhlakiem"
    inst.components.inventoryitem.keepondeath = true

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
    inst.components.equippable:SetOnEquipToModel(OnEquipToModel)

    inst:AddComponent("trader")
    inst.components.trader.acceptnontradable = true
    inst.components.trader:SetAbleToAcceptTest(CanRepair)
    inst.components.trader.onaccept = OnRepair
    inst.OnRemoveEntity = OnRemove
    MakeHauntableLaunch(inst)
    return inst
end

return Prefab("ttk_tinhlakiem", Fn, assets, prefabs)
