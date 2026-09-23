local assets = {
    Asset("ANIM", "anim/ttk_yhsyz.zip"),
    Asset("ATLAS", "images/inventoryimages/ttk_yhsyz.xml"),
}

local function onequip(inst, owner)

    local skin_build = inst:GetSkinBuild()
    owner.AnimState:OverrideSymbol("swap_object", skin_build or "xd_yhsyz", "swap")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_object")
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function onattack(inst, owner, target)
    if target ~= nil and target.components.combat ~= nil and target:IsValid() then
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("xd_yhsyz")
    inst.AnimState:SetBuild("xd_yhsyz")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst)
    inst:AddTag("nopunch")
    inst:AddTag("ttk_herbtool")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/ttk_yhsyz.xml"

    inst:AddComponent("tradable")

    -- Mature TTK herbs consume one use through their standard PICK callback.

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(100)
    inst.components.finiteuses:SetUses(100)
    inst.components.finiteuses:SetOnFinished(inst.Remove)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("ttk_yhsyz", fn, assets)