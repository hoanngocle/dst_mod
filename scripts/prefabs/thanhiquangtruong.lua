-- Standalone adaptation of xd_yunxiao_fysz, Tu Tien 19.7. See docs/CREDITS.md.
local common = require("thanhiquangtruong_common")
local assets = {
    Asset("ANIM", "anim/thanhiquangtruong.zip"),
    Asset("ATLAS", "images/inventoryimages/thanhiquangtruong.xml"),
    Asset("IMAGE", "images/inventoryimages/thanhiquangtruong.tex"),
}
local prefabs = { "thanhiquangtruongfx", "sand_puff_large_front", "sand_puff_large_back" }

local function RemoveFX(inst)
    if inst.fx ~= nil then
        inst.fx:Remove()
        inst.fx = nil
    end
end

local function OnEquip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "xd_yunxiao_fysz", "swap")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    RemoveFX(inst)
    inst.fx = SpawnPrefab("thanhiquangtruongfx")
    if inst.fx ~= nil then
        inst.fx.entity:AddFollower()
        inst.fx.entity:SetParent(owner.entity)
        inst.fx.Follower:FollowSymbol(owner.GUID, "swap_object", 0, -100, 0)
    end
end

local function OnUnequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    RemoveFX(inst)
end

local function OnDischarged(inst)
    inst:RemoveTag(common.READY_TAG)
end

local function OnCharged(inst)
    inst:AddTag(common.READY_TAG)
end

local function CanAccept(inst, item)
    return item ~= nil and item.prefab == "townportaltalisman"
        and inst.components.finiteuses:GetPercent() < 1
end

local function OnAccept(inst)
    inst.components.finiteuses:Repair(15)
end

local function ReticuleTarget()
    return ControllerReticle_Blink_GetPosition(ThePlayer, function(point)
        return not TheWorld.Map:IsGroundTargetBlocked(point)
    end)
end

local function Fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst)
    inst.AnimState:SetBank("xd_yunxiao_fysz")
    inst.AnimState:SetBuild("xd_yunxiao_fysz")
    inst.AnimState:PlayAnimation("idle")
    inst:AddTag("weapon")
    inst:AddTag(common.READY_TAG)

    inst:AddComponent("reticule")
    inst.components.reticule.targetfn = ReticuleTarget
    inst.components.reticule.ease = true
    inst.components.reticule.twinstickcheckscheme = true
    inst.components.reticule.twinstickmode = 1
    inst.components.reticule.twinstickrange = 15
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/thanhiquangtruong.xml"

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(30)
    inst.components.finiteuses:SetUses(30)
    inst.components.finiteuses:SetOnFinished(inst.Remove)
    inst.components.finiteuses:SetIgnoreCombatDurabilityLoss(true)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.CANE_DAMAGE)
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
    inst.components.equippable.walkspeedmult = 1.3

    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(CanAccept)
    inst.components.trader.onaccept = OnAccept
    inst.components.trader.acceptnontradable = true

    inst:AddComponent("rechargeable")
    inst.components.rechargeable:SetOnDischargedFn(OnDischarged)
    inst.components.rechargeable:SetOnChargedFn(OnCharged)

    inst:AddComponent("blinkstaff")
    inst.components.blinkstaff:SetFX("sand_puff_large_front", "sand_puff_large_back")
    local original_blink = inst.components.blinkstaff.Blink
    inst.components.blinkstaff.Blink = function(self, point, caster, onmap)
        local cost = onmap and 3 or 1
        if common.EquippedStaff(caster) ~= inst
            or not inst.components.rechargeable:IsCharged()
            or inst.components.finiteuses:GetUses() < cost
            or not common.ValidPoint(caster, point, onmap) then
            return false
        end
        -- Use the game's blink state, physics and destination safeguards.
        -- Unlike Lazy Explorer, this staff does not charge sanity.
        if not original_blink(self, point, caster) then
            return false
        end
        inst.components.rechargeable:Discharge(30)
        inst.components.finiteuses:Use(cost)
        return true
    end
    inst.OnRemoveEntity = RemoveFX
    MakeHauntableLaunch(inst)
    return inst
end

return Prefab("thanhiquangtruong", Fn, assets, prefabs)
