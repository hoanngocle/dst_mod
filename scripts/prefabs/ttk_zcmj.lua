local assets ={
    Asset("ANIM", "anim/ttk_zcmj.zip"),
    Asset("ATLAS", "images/inventoryimages/ttk_zcmj.xml"),
    Asset("IMAGE", "images/inventoryimages/ttk_zcmj.tex"),
}

local function ruinshat_fxanim(inst)
    inst._fx.AnimState:PlayAnimation("hit")
    inst._fx.AnimState:PushAnimation("idle_loop")
end

local function ruinshat_oncooldown(inst)
    inst._task = nil
end
local function ruinshat_unproc(inst)
    if inst:HasTag("forcefield") then
        inst:RemoveTag("forcefield")
        inst:RemoveTag("ttk_avoid_damage")
        if inst._fx ~= nil then
            inst._fx:kill_fx()
            inst._fx = nil
        end
        inst:RemoveEventCallback("armordamaged", ruinshat_fxanim)
        inst.components.armor:SetAbsorption(.9)
        inst.components.armor.ontakedamage = nil
        if inst._task ~= nil then
            inst._task:Cancel()
        end
        inst._task = inst:DoTaskInTime(8, ruinshat_oncooldown)
    end
end

local function ruinshat_proc(inst, owner)
    inst:AddTag("forcefield")
    inst:AddTag("ttk_avoid_damage")
    if inst._fx ~= nil then
        inst._fx:kill_fx()
    end
    inst._fx = SpawnPrefab("ttk_zcmj_forcefield")
    inst._fx.entity:SetParent(owner.entity)
    inst._fx.Transform:SetPosition(0, 0.2, 0)
    inst:ListenForEvent("armordamaged", ruinshat_fxanim)
    inst.components.armor:SetAbsorption(1)

    if inst._task ~= nil then
        inst._task:Cancel()
    end
    inst._task = inst:DoTaskInTime(2, ruinshat_unproc)
end

local function tryproc(inst, owner, data)
    if inst._task == nil and
        data ~= nil and not data.redirected and
        (owner and owner.components.inventory and owner.components.inventory:EquipHasTag("ttk_xshj")) and 
        math.random() < 0.66 then
        ruinshat_proc(inst, owner)
    end
end

local function ruins_onremove(inst)
    if inst._fx ~= nil then
        inst._fx:kill_fx()
        inst._fx = nil
    end
end

local function onequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("headbase_hat")
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideSymbol("swap_hat", skin_build, "swap_hat")
    else
        owner.AnimState:OverrideSymbol("swap_hat", "xd_zcmj", "swap_hat")
    end

    if inst:HasTag("open_top_hat") then
        owner.AnimState:Show("HAT")
        owner.AnimState:Hide("HAIR_HAT")
        owner.AnimState:Show("HAIR_NOHAT")
        owner.AnimState:Show("HAIR")

        owner.AnimState:Show("HEAD")
        owner.AnimState:Hide("HEAD_HAT")
        owner.AnimState:Hide("HEAD_HAT_NOHELM")
        owner.AnimState:Hide("HEAD_HAT_HELM")
    else
        owner.AnimState:Show("HAT")
        owner.AnimState:Show("HAIR_HAT")
        owner.AnimState:Hide("HAIR_NOHAT")
        owner.AnimState:Hide("HAIR")

	    if owner.isplayer then
            owner.AnimState:Hide("HEAD")
            owner.AnimState:Show("HEAD_HAT")
	    	owner.AnimState:Show("HEAD_HAT_NOHELM")
	    	owner.AnimState:Hide("HEAD_HAT_HELM")
        end
    end

    if skin_build == "xd_yaohat" then
        owner.AnimState:Hide("HEAD_HAT")
    end

    if owner.components.combat ~= nil then
        owner.components.combat.externaldamagemultipliers:SetModifier(inst, 1.2)
    end
    inst.onattach(owner)
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("headbase_hat")
    if owner.components.skinner ~= nil then
        owner.components.skinner.base_change_cb = owner.old_base_change_cb
    end
    owner.AnimState:ClearOverrideSymbol("swap_hat")
    owner.AnimState:Hide("HAT")
    owner.AnimState:Hide("HAIR_HAT")
    owner.AnimState:Show("HAIR_NOHAT")
    owner.AnimState:Show("HAIR")

    if owner:HasTag("player") then
        owner.AnimState:Show("HEAD")
        owner.AnimState:Hide("HEAD_HAT")
        owner.AnimState:Hide("HEAD_HAT_NOHELM")
        owner.AnimState:Hide("HEAD_HAT_HELM")
    end

    if owner ~= nil and owner.components.combat ~= nil then
        owner.components.combat.externaldamagemultipliers:RemoveModifier(inst)
    end
    inst.ondetach()
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("unequipskinneditem", inst:GetSkinName())
    end

end

local function SetupEquippable(inst)
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    
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

    inst.AnimState:SetBank("xd_zcmj")
    inst.AnimState:SetBuild("xd_zcmj")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst)

    inst:AddTag("show_broken_ui")
    inst:AddTag("ttk_zcmj")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.levelup = {}
    for k, v in pairs(canlevelup) do
        inst.levelup[k] = 0
    end

    inst:AddComponent("tradable")
    
    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/ttk_zcmj.xml"

	inst:AddComponent("armor")
	inst.components.armor:InitCondition(830, 0.9)

    SetupEquippable(inst)
    MakeForgeRepairable(inst, FORGEMATERIALS.TTK_XSHJ, OnBroken, OnRepaired)

    inst:AddComponent("planardefense")
	inst.components.planardefense:SetBaseDefense(10)

    inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(ShouldAcceptItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.acceptnontradable = true

    inst.OnRemoveEntity = ruins_onremove

    inst._fx = nil
    inst._task = nil
    inst._owner = nil
    inst.procfn = function(owner, data) tryproc(inst, owner, data) end
    inst.onattach = function(owner)
        if inst._owner ~= nil then
            inst:RemoveEventCallback("attacked", inst.procfn, inst._owner)
            inst:RemoveEventCallback("onremove", inst.ondetach, inst._owner)
        end
        inst:ListenForEvent("attacked", inst.procfn, owner)
        inst:ListenForEvent("onremove", inst.ondetach, owner)
        inst._owner = owner
        inst._fx = nil
    end
    inst.ondetach = function()
        ruinshat_unproc(inst)
        if inst._owner ~= nil then
            inst:RemoveEventCallback("attacked", inst.procfn, inst._owner)
            inst:RemoveEventCallback("onremove", inst.ondetach, inst._owner)
            inst._owner = nil
            inst._fx = nil
        end
    end

    inst:DoPeriodicTask(10,function()
        doheal(inst)
    end,10)

    MakeHauntableLaunch(inst)

    return inst
end

local fxassets =
{
   Asset("ANIM", "anim/forcefield.zip"),
   Asset("ANIM", "anim/ttk_zcmj_forcefield.zip"),
}

local MAX_LIGHT_FRAME = 6

local function OnUpdateLight(inst, dframes)
    if not inst:IsValid() then
        return
    end
    local done
    if inst._islighton:value() then
        local frame = inst._lightframe:value() + dframes
        done = frame >= MAX_LIGHT_FRAME
        inst._lightframe:set_local(done and MAX_LIGHT_FRAME or frame)
    else
        local frame = inst._lightframe:value() - dframes
        done = frame <= 0
        inst._lightframe:set_local(done and 0 or frame)
    end

    inst.Light:SetRadius(3 * inst._lightframe:value() / MAX_LIGHT_FRAME)

    if done then
        inst._lighttask:Cancel()
        inst._lighttask = nil
    end
end

local function OnLightDirty(inst)
    if inst._lighttask == nil then
        inst._lighttask = inst:DoPeriodicTask(FRAMES, OnUpdateLight, nil, 1)
    end
    OnUpdateLight(inst, 0)
end

local function kill_fx(inst)
    inst.AnimState:PlayAnimation("close")
    inst._islighton:set(false)
    inst._lightframe:set(inst._lightframe:value())
    OnLightDirty(inst)
    inst:DoTaskInTime(.6, inst.Remove)
end

local function fxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("forcefield")
    inst.AnimState:SetBuild("xd_zcmj_forcefield")
    inst.AnimState:PlayAnimation("open")
    inst.AnimState:PushAnimation("idle_loop", true)

    inst.SoundEmitter:PlaySound("dontstarve/wilson/forcefield_LP", "loop")

    inst.Light:SetRadius(0)
    inst.Light:SetIntensity(.9)
    inst.Light:SetFalloff(.9)
    inst.Light:SetColour(1, 1, 1)
    inst.Light:Enable(true)
    inst.Light:EnableClientModulation(true)

    inst._lightframe = net_tinybyte(inst.GUID, "ttk_zcmj_forcefield._lightframe", "lightdirty")
    inst._islighton = net_bool(inst.GUID, "ttk_zcmj_forcefield._islighton", "lightdirty")
    inst._lighttask = nil
    inst._islighton:set(true)

    inst.entity:SetPristine()

    OnLightDirty(inst)

    if not TheWorld.ismastersim then
        inst:ListenForEvent("lightdirty", OnLightDirty)

        return inst
    end

    inst.kill_fx = kill_fx

    return inst
end

return  Prefab("ttk_zcmj", fn, assets, {"ttk_zcmj_forcefield"}),
    Prefab("ttk_zcmj_forcefield", fxfn, fxassets)
