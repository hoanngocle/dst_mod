local assets = {
    Asset("ANIM", "anim/ttk_yunxiao_ymsz.zip"),
	Asset("ATLAS", "images/inventoryimages/ttk_yunxiao_ymsz.xml"),
    Asset("IMAGE", "images/inventoryimages/ttk_yunxiao_ymsz.tex"),
}

local function OnBlocked(owner)
    owner.SoundEmitter:PlaySound("dontstarve/wilson/hit_marble")
end

local usetime = 60

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "xd_yunxiao_ymsz", "swap_body")
    inst:ListenForEvent("blocked", OnBlocked, owner)
    if inst._light == nil or not inst._light:IsValid() then
        inst._light = SpawnPrefab("minerhatlight")
        inst._light.Light:SetRadius(5)
    end
    inst._light.entity:SetParent(owner.entity)
    inst.components.timer:ResumeTimer("use")
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
    inst:RemoveEventCallback("blocked", OnBlocked, owner)
    if inst._light ~= nil then
        if inst._light:IsValid() then
            inst._light:Remove()
        end
        inst._light = nil
    end
    inst.components.timer:PauseTimer("use")
end

local canlevelup = {
    ["sewing_kit"] = {
        usefn = function(inst,doer)
            inst.components.armor:Repair(inst.components.armor.maxcondition)
            if doer then
                doer:PushEvent("repair")
            end
        end,
    },
}
local function ShouldAcceptItem(inst, item)
    return canlevelup[item.prefab]
end

local function OnGetItemFromPlayer(inst, giver, item)
    if item and canlevelup[item.prefab] then
        if canlevelup[item.prefab].usefn then
            canlevelup[item.prefab].usefn(inst,giver)
        end
    end
end

local function ontimedone(inst,data)
    if data and data.name == "use" then
        inst.components.armor:TakeDamage(inst.components.armor.maxcondition * 0.0125)
        if inst:IsValid() then
            inst.components.timer:StartTimer("use",usetime)
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("xd_yunxiao_ymsz")
    inst.AnimState:SetBuild("xd_yunxiao_ymsz")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst)

    inst:AddTag("ttk_yunxiao_ymsz")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/ttk_yunxiao_ymsz.xml"

    inst:AddComponent("tradable")

    inst:AddComponent("armor")
    inst.components.armor:InitCondition(840, 0.85)

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst:AddComponent("timer")
    inst.components.timer:StartTimer("use",usetime)
    inst.components.timer:PauseTimer("use")

    inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(240)

    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.acceptnontradable = true

    inst:ListenForEvent("timerdone",ontimedone)

    -- A destroyed or removed coat must not leave a light attached to its owner.
    inst.OnRemoveEntity = function(coat)
        if coat._light ~= nil and coat._light:IsValid() then coat._light:Remove() end
        coat._light = nil
    end
    inst.components.equippable:SetOnEquipToModel(onunequip)
    MakeHauntableLaunch(inst)

    return inst
end

return  Prefab("ttk_yunxiao_ymsz", fn, assets, {"minerhatlight"})
