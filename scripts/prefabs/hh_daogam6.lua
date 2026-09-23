local HHDaogamDurability = require("utils/hh_daogam_durability")

local assets = {
    Asset("ANIM", "anim/hh_daogam6.zip"),
    Asset("ANIM", "anim/hh_daogam6_ground.zip"),
    Asset("ANIM", "anim/hh_purple_electric_fx.zip"),
    Asset("ANIM", "anim/hh_purple_mosling_spin_fx.zip"),
    Asset("ANIM", "anim/hh_purple_deer_ice_charge.zip"),
    Asset("ATLAS", "images/hh_daogam6_inventory.xml"),
    Asset("IMAGE", "images/hh_daogam6_inventory.tex"),
    Asset("ANIM", "anim/hh_daogam6fx.zip"),
}

local function fxfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("hh_daogam6fx")
    inst.AnimState:SetBuild("hh_daogam6fx")
    inst.AnimState:PlayAnimation("idle_000") -- Or the correct animation name inside the zip

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end

    inst.persists = false
    inst:ListenForEvent("animover", inst.Remove)
    inst:DoTaskInTime(2, inst.Remove) -- Fallback

    return inst
end

local function onattack(inst, attacker, target)
    if target and target:IsValid() then
        if inst.components.hh_morphweapon and inst.components.hh_morphweapon.current_mode == "sword" then
            local x, y, z = target.Transform:GetWorldPosition()
            local fx = SpawnPrefab("hh_daogam6fx")
            if fx then
                fx.Transform:SetPosition(x, y + 1.5, z)
            end

            -- AOE cho dang sword
            if attacker and attacker.components.combat then
                local ents = TheSim:FindEntities(x, y, z, 4, {"_combat"}, {"INLIMBO", "NOCLICK", "notarget", "player", "companion", "wall", "structure", "playerghost", "shadowminion", "abigail"})
                local damage = inst.components.weapon.damage * 0.3
                for _, ent in ipairs(ents) do
                    if ent ~= target and ent:IsValid() and ent.components.health and not ent.components.health:IsDead() and attacker.components.combat:IsValidTarget(ent) then
                        ent.components.combat:GetAttacked(attacker, damage, inst)
                    end
                end
            end
        end
    end
end

local function MakeEquipFn()
    return function(inst, owner)
        local symbol_name = inst.components.hh_morphweapon and inst.components.hh_morphweapon.current_mode or "sword"
        owner.AnimState:OverrideSymbol("swap_object", "hh_daogam6", symbol_name)
        owner.AnimState:Show("ARM_carry")
        owner.AnimState:Hide("ARM_normal")

        if inst.fx0 ~= nil then
            inst.fx0:Remove()
            inst.fx0 = nil
        end
        inst.fx0 = SpawnPrefab("hh_daogam_sparkle_fx")
        if inst.fx0 then
            inst.fx0.entity:AddFollower()
            inst.fx0.entity:SetParent(owner.entity)
            inst.fx0.Follower:FollowSymbol(owner.GUID, "swap_object", 0, -60, 0)
        end
        
        local sparks2 = owner:SpawnChild("sparks2_fx")
        if sparks2 then
            sparks2.AnimState:SetBuild("hh_purple_mosling_spin_fx")
            owner:AddChild(sparks2)
            sparks2.Transform:SetPosition(0, 0, 0)
            owner.fx1 = sparks2
        end
        
        local sparks1 = owner:SpawnChild("sparks1_fx")
        if sparks1 then
            sparks1.AnimState:SetBuild("hh_purple_electric_fx")
            owner:AddChild(sparks1)
            sparks1.Transform:SetPosition(0, -1, 0)
            owner.fx2 = sparks1
        end

        owner:AddTag("stronggrip")
    end
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    if inst.fx0 ~= nil then
        inst.fx0:Remove()
        inst.fx0 = nil
    end
    if owner.fx1 then
        owner:RemoveChild(owner.fx1)
        owner.fx1:Remove()
        owner.fx1 = nil
    end
    if owner.fx2 then
        owner:RemoveChild(owner.fx2)
        owner.fx2:Remove()
        owner.fx2 = nil
    end

    owner:RemoveTag("stronggrip")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("hh_daogam6_sword_ground")
    inst.AnimState:SetBuild("xw_stalkerblade")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("sharp")
    inst:AddTag("nosteal")
    inst:AddTag("hh_daogam_item")
    inst:AddTag("hh_equip")

    inst.GetHHSpDesc01 = function(inst, viewer)
        return {["title"] = "Bị động", ["desc"] = "Ở dạng vũ khí, đòn đánh gây 30% sát thương lan (AOE) cho các mục tiêu xung quanh"}
    end
    inst.GetHHSpDesc02 = function(inst, viewer)
        return {["title"] = "Chủ động", ["desc"] = "Nhấn " .. (STRINGS["RMB"] or "chuột phải") .. " lên thực vật, tài nguyên hoặc người chơi để biến đổi hình dạng"}
    end
    inst.GetHHSpDesc03 = function(inst, viewer)
        return {["title"] = "Sửa chữa", ["desc"] = HHDaogamDurability.GetRepairDescription()}
    end
    inst.GetHHSpDesc04 = function() return {title = "Hệ đồ", desc = "Tối Thượng", rainbow = true} end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst:AddComponent("damagetypebonus")
    inst.components.damagetypebonus:AddBonus("lunar_aligned", inst, TUNING.WEAPONS_VOIDCLOTH_VS_LUNAR_BONUS)
    inst.components.damagetypebonus:AddBonus("shadow_aligned", inst, TUNING.WEAPONS_LUNARPLANT_VS_SHADOW_BONUS)
    inst.components.weapon:SetDamage(74)
    inst.components.weapon:SetOnAttack(onattack)

    HHDaogamDurability.AddTo(inst, nil)


    inst:AddComponent("inspectable")

    inst:AddComponent("named")
    inst.components.named:SetName(STRINGS.NAMES.HH_DAOGAM6_SWORD or "Tà Thuật Đen - Vũ Khí")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "hh_daogam6_sword"
    inst.components.inventoryitem.atlasname = "images/hh_daogam6_inventory.xml"
    inst.components.inventoryitem.keepondrown = true
    inst.components.inventoryitem.keepondeath = true

    inst.components.inventoryitem:SetOnDroppedFn(function(inst)
        if inst.components.hh_morphweapon and inst.components.hh_morphweapon.current_mode ~= "sword" then
            inst.components.hh_morphweapon:SetMode("sword")
        end
    end)

    inst:AddComponent("hh_morphweapon")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(MakeEquipFn())
    inst.components.equippable:SetOnUnequip(onunequip)

    return inst
end

return Prefab("hh_daogam6", fn, assets),
       Prefab("hh_daogam6fx", fxfn, {Asset("ANIM", "anim/hh_daogam6fx.zip")})
