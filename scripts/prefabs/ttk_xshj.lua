local assets = {
    Asset("ANIM", "anim/ttk_xshj.zip"),
	Asset("ATLAS", "images/inventoryimages/ttk_xshj.xml"),
    Asset("IMAGE", "images/inventoryimages/ttk_xshj.tex"),
}

local RESISTANCES =
{
    "_combat",
    "explosive",
    "quakedebris",
    "lunarhaildebris",
    "caveindebris",
    "trapdamage",
}

local function OnBlocked(owner)
    owner.SoundEmitter:PlaySound("dontstarve/wilson/hit_marble")
end

local function onequip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner.AnimState:OverrideSymbol("swap_body", skin_build, "swap_body")
    else
        owner.AnimState:OverrideSymbol("swap_body", "xd_xshj", "swap_body")
    end

    inst:ListenForEvent("blocked", OnBlocked, owner)
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
    inst:RemoveEventCallback("blocked", OnBlocked, owner)
end

local function SetupEquippable(inst)
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.walkspeedmult = 1.1
end

local function OnRepaired(inst)
	if inst.components.equippable == nil then
		SetupEquippable(inst)
		inst:RemoveTag("broken")
		inst.components.inspectable.nameoverride = nil
	end
end

local function OnBroken(inst)
	if inst.components.equippable ~= nil then
		inst:RemoveComponent("equippable")
		inst:AddTag("broken")
		inst.components.inspectable.nameoverride = "BROKEN_FORGEDITEM"
	end
end

local function doheal(inst)
    if inst.components.armor:GetPercent() < 1 then
        inst.components.armor:Repair(inst.components.armor.maxcondition * 0.01)
        OnRepaired(inst)
    end 
end

local function OnShieldOver(inst, OnResistDamage)
    inst.task = nil
end
local function OnResistDamage(inst)
    local owner = inst.components.inventoryitem:GetGrandOwner() or inst

    if owner and owner.components.inventory ~= nil then
        owner.components.inventory:ConsumeByName("ttk_lingshi1",3)
    end
    if inst.task ~= nil then
        inst.task:Cancel()
    end
    inst.task = inst:DoTaskInTime(2, OnShieldOver, OnResistDamage)
    inst.components.rechargeable:Discharge(10)
end

local function ShouldResistFn(inst)
    if not inst.components.equippable:IsEquipped() then
        return false
    end
    if inst.task then
        return true
    end
    if not inst.components.rechargeable:IsCharged() then
        return false
    end
    local owner = inst.components.inventoryitem.owner
    return owner ~= nil
        and not (owner.components.inventory ~= nil and
                owner.components.inventory:EquipHasTag("forcefield"))
        and (owner.components.inventory ~= nil and
        owner.components.inventory:Has("ttk_lingshi1",3))
end

local canlevelup = {
    ["ttk_lingshi2"] = {
        usefn = function(inst,level)
            inst.components.armor:Repair(inst.components.armor.maxcondition * 0.2)
            OnRepaired(inst)
        end,
        fn = function(inst,level)
            
        end
    },
}
local function ShouldAcceptItem(inst, item, giver, count)
    return item ~= nil and item.prefab == "ttk_lingshi2"
        and (count == nil or count == 1) and inst.components.armor:GetPercent() < 1
end

local function OnGetItemFromPlayer(inst, giver, item)
    if item and canlevelup[item.prefab] then
        inst.levelup[item.prefab] = inst.levelup[item.prefab] + 1
        if canlevelup[item.prefab].usefn then
            canlevelup[item.prefab].usefn(inst, inst.levelup[item.prefab])
        end
        canlevelup[item.prefab].fn(inst, inst.levelup[item.prefab])
    end
end

FORGEMATERIALS.TTK_XSHJ = "ttk_xshj"

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("xd_xshj")
    inst.AnimState:SetBuild("xd_xshj")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst)

    inst:AddTag("show_broken_ui")
    inst:AddTag("ttk_xshj")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.levelup = {}
    for k, v in pairs(canlevelup) do
        inst.levelup[k] = 0
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/ttk_xshj.xml"

    inst:AddComponent("tradable")

    inst:AddComponent("armor")
    inst.components.armor:InitCondition(830, 0.9)
    inst.components.armor:AddWeakness("beaver", TUNING.BEAVER_WOOD_DAMAGE)

    SetupEquippable(inst)
    MakeForgeRepairable(inst, FORGEMATERIALS.TTK_XSHJ, OnBroken, OnRepaired)

    local planardefense = inst:AddComponent("planardefense")
    planardefense:SetBaseDefense(10)

    inst:DoPeriodicTask(10,function()
        doheal(inst)
    end,10)

    inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(ShouldAcceptItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.acceptnontradable = true

    inst:AddComponent("rechargeable")

    MakeHauntableLaunch(inst)

    return inst
end

return  Prefab("ttk_xshj", fn, assets)