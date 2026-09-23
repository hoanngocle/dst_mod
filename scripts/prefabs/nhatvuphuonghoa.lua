-- Adapted from Tu Tien 19.7; see docs/CREDITS.md.

local assets =
{
    Asset("ANIM", "anim/nhatvuphuonghoa.zip"),
    Asset("ANIM", "anim/umbrella_voidcloth.zip"),
    Asset("ANIM", "anim/nhatvuphuonghoa_fx.zip"),
	Asset("ATLAS", "images/inventoryimages/nhatvuphuonghoa.xml"),
    Asset("IMAGE", "images/inventoryimages/nhatvuphuonghoa.tex"),
}
local prefabs = { "nhatvuphuonghoa_buff" }
local function OnIsAcidRaining(inst, isacidraining)
    if isacidraining then
        inst.components.fueled.rate_modifiers:SetModifier(inst, -1, "acidrain")
    else
        inst.components.fueled.rate_modifiers:RemoveModifier(inst, "acidrain")
    end
end

local function setanim(inst,owner)
	if owner and owner.AnimState then
        local default_symbol = inst.tunrn_on and "up_swap" or "swap"
        local build, symbol = require("ttk_skins").GetEquipPresentation(inst, "xd_sudaji_ywfh", default_symbol)
		owner.AnimState:OverrideSymbol("swap_object", build, symbol)
	end
end

local function onequip(inst, owner)
	setanim(inst,owner)
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    if owner.DynamicShadow then
        owner.DynamicShadow:SetSize(2.2, 1.4)
    end

    inst.components.fueled:StartConsuming()
    inst:WatchWorldState("isacidraining", inst.OnIsAcidRaining)
    inst:OnIsAcidRaining(TheWorld.state.isacidraining)
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    if owner.DynamicShadow then
         owner.DynamicShadow:SetSize(1.3, 0.6)
    end
    inst.components.fueled:StopConsuming()
    inst:StopWatchingWorldState("isacidraining", inst.OnIsAcidRaining)
	inst:OnIsAcidRaining(false)
end

local function OnEquipToModel(inst, owner, from_ground)
    if inst.components.fueled then
        inst.components.fueled:StopConsuming()
    end
    inst:StopWatchingWorldState("isacidraining", inst.OnIsAcidRaining)
	inst:OnIsAcidRaining(false)
end

local WAVE_FX_LEN = 0.5
local function WaveFxOnUpdate(inst, dt)
	inst.t = inst.t + dt

	if inst.t < WAVE_FX_LEN then
		local k = 1 - inst.t / WAVE_FX_LEN
		k = k * k
		inst.AnimState:SetMultColour(1, 1, 1, k)
		k = (2 - 1.7 * k) * (inst.scalemult or 1)
		inst.AnimState:SetScale(k, k)
	else
		inst:Remove()
	end
end

local function CreateWaveFX()
	local inst = CreateEntity()

	inst:AddTag("FX")
	
	inst.entity:SetCanSleep(false)
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	inst.AnimState:SetBank("umbrella_voidcloth")
	inst.AnimState:SetBuild("xd_sudaji_ywfh_fx")
	inst.AnimState:PlayAnimation("barrier_rim")
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(3)

	inst:AddComponent("updatelooper")
	inst.components.updatelooper:AddOnUpdateFn(WaveFxOnUpdate)
	inst.t = 0
	inst.scalemult = .75
	WaveFxOnUpdate(inst, 0)

	return inst
end

local function CreateDomeFX()
	local inst = CreateEntity()

	inst:AddTag("FX")
	
	inst.entity:SetCanSleep(false)
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()

	inst.AnimState:SetBank("umbrella_voidcloth")
	inst.AnimState:SetBuild("xd_sudaji_ywfh_fx")
	inst.AnimState:PlayAnimation("barrier_dome")
	inst.AnimState:SetFinalOffset(7)

	inst:AddComponent("updatelooper")
	inst.components.updatelooper:AddOnUpdateFn(WaveFxOnUpdate)
	inst.t = 0
	WaveFxOnUpdate(inst, 0)

	return inst
end
local function CLIENT_TriggerFX(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	CreateWaveFX().Transform:SetPosition(x, 0, z)
	local fx = CreateDomeFX()
	fx.Transform:SetPosition(x, 0, z)
	fx.SoundEmitter:PlaySound("meta2/voidcloth_umbrella/barrier_activate")
end

local function SERVER_TriggerFX(inst)
	inst.triggerfx:push()
	if not TheNet:IsDedicated() then
		CLIENT_TriggerFX(inst)
	end
end

local function turnon(inst)
	inst:DoTaskInTime(0,function()
		if inst:IsValid() and not (inst.components.equippable and inst.components.equippable:IsEquipped()) and inst.components.inventoryitem.owner == nil then
			if not inst.components.fueled:IsEmpty() and not inst.turn_on then
				inst.turn_on = true
				inst.components.fueled.rate = TUNING.VOIDCLOTH_UMBRELLA_DOME_RATE
				inst.components.fueled:StartConsuming()
				inst.components.raindome:Enable()
				inst.DynamicShadow:Enable(true)
				if inst.components.sanityaura == nil then
					inst:AddComponent("sanityaura")
					inst.components.sanityaura.aura = -TUNING.SANITYAURA_SMALL
					inst.components.sanityaura.max_distsq = TUNING.VOIDCLOTH_UMBRELLA_DOME_RADIUS * TUNING.VOIDCLOTH_UMBRELLA_DOME_RADIUS
				end
				inst.SoundEmitter:PlaySound("meta2/voidcloth_umbrella/barrier_lp", "loop")
				if inst:IsAsleep() or POPULATING then
				else
					SERVER_TriggerFX(inst)
				end
			end
		end
	end)
end

local function turnoff(inst)
    if inst.turn_on then
        inst.turn_on = false
        inst.components.fueled:StopConsuming()
        inst.components.fueled.rate = 1
        inst.components.raindome:Disable()
        
	    if inst.components.sanityaura ~= nil then
		    inst:RemoveComponent("sanityaura")
	    end
        inst.DynamicShadow:Enable(false)
        if inst.SoundEmitter:PlayingSound("loop") then
            inst.SoundEmitter:KillSound("loop")
        end
    end
end

local function topocket(inst)
    turnoff(inst)
end

local function ondropped(inst)
    turnoff(inst)
    turnon(inst)
end

local function OnExitLimbo(inst)
	if not inst.turn_on then
		inst.DynamicShadow:Enable(false)
	end
end

local function OnLoad(inst, data)
    if inst.components.fueled:IsEmpty() then
        turnoff(inst)
        inst:RemoveComponent("equippable")
		inst:AddTag("broken")
    end
end

local function SetupEquippable(inst)
    inst:AddComponent("equippable")
	inst.components.equippable.is_magic_dapperness = true
	inst.components.equippable:SetOnEquip(onequip)
	inst.components.equippable:SetOnUnequip(onunequip)
	inst.components.equippable:SetOnEquipToModel(OnEquipToModel)
end

local function OnPerish(inst)
    inst:AddTag("broken")
	if inst.turn_on then
        turnoff(inst)
	end
    local equippable = inst.components.equippable
	if equippable ~= nil then
		if equippable:IsEquipped() then
			local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
			if owner ~= nil then
				local data =
				{
					prefab = inst.prefab,
					equipslot = equippable.equipslot,
				}
				if owner.components.inventory ~= nil then
					local item = owner.components.inventory:Unequip(equippable.equipslot)
					if item ~= nil then
						owner.components.inventory:GiveItem(item, nil, owner:GetPosition())
					end
				end
				inst:RemoveComponent("equippable")
				owner:PushEvent("umbrellaranout", data)
				return
			end
		end
		inst:RemoveComponent("equippable")
		inst:AddTag("broken")
    end
end

local function OnAddFuelItem(inst, item, fuelvalue, doer)
    if doer and doer.SoundEmitter then
        doer.SoundEmitter:PlaySound("dontstarve/characters/wortox/soul/spawn", nil, .3)
    end
	if inst.components.equippable == nil then
		SetupEquippable(inst)
		inst:RemoveTag("broken")
	end
    if not inst.components.inventoryitem.owner then
        if not inst.components.fueled.consuming then
            turnon(inst)
        end
    end
end

local function onuse(inst, target, pos, caster)
    if not (target and caster) then
        return
    end
    if inst.components.fueled:GetPercent() < 0.25 then
        if caster then
            if caster.components.talker then caster.components.talker:Say("Ô cần ít nhất 25% độ bền.") end
        end
        return
    end
    if target.components.moisture and target.components.moisture.moisture > 0  then
        target.components.moisture:DoDelta(-target.components.moisture.moisture)
    end
    inst.components.fueled:DoDelta(-inst.components.fueled.maxfuel * 0.25)
    target:AddDebuff("nhatvuphuonghoa_buff", "nhatvuphuonghoa_buff")
end

local  function can_cast_fn(doer, target, pos)
    return target and target:HasTag("player") and not target:HasTag("playerghost")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddDynamicShadow()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
	MakeInventoryFloatable(inst)

    inst.DynamicShadow:SetSize(1.1, .7)
	inst.DynamicShadow:Enable(false)

    inst.AnimState:SetBank("xd_sudaji_ywfh")
    inst.AnimState:SetBuild("xd_sudaji_ywfh")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("nopunch")
    inst:AddTag("umbrella")
    inst:AddTag("acidrainimmune")
	inst:AddTag("show_broken_ui")
	inst:AddTag("lunarhailprotection")

    inst:AddComponent("raindome")

    inst.spelltype = "NHATVU_KEEPDRY"

    inst:AddTag("waterproofer")

    inst.triggerfx = net_event(inst.GUID, "nhatvuphuonghoa.triggerfx")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
		
		inst:DoTaskInTime(0, inst.ListenForEvent, "nhatvuphuonghoa.triggerfx", CLIENT_TriggerFX)
        return inst
    end

    inst.fxcolour = {232/255,96/255,108/255}

    inst.components.raindome:SetRadius(TUNING.VOIDCLOTH_UMBRELLA_DOME_RADIUS)

    inst:AddComponent("inspectable")

    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_ABSOLUTE)

    inst:AddComponent("insulator")
    inst.components.insulator:SetSummer()
    inst.components.insulator:SetInsulation(TUNING.INSULATION_LARGE)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnDroppedFn(ondropped)
    inst.components.inventoryitem:SetOnPutInInventoryFn(turnoff)
    inst.components.inventoryitem.imagename = "nhatvuphuonghoa"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/nhatvuphuonghoa.xml"
	
    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.MAGIC
    inst.components.fueled:InitializeFuelLevel(7*480)

    SetupEquippable(inst)

    inst.OnIsAcidRaining = OnIsAcidRaining 
	inst:ListenForEvent("exitlimbo", OnExitLimbo)

    inst.components.fueled:SetDepletedFn(OnPerish)
    inst.components.fueled.fueltype = "NHATVU_DURABILITY"
	inst.components.fueled:SetDepletedFn(OnPerish)
    inst.components.fueled:SetTakeFuelItemFn(OnAddFuelItem)
    inst.components.fueled.accepting = false

    inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(function(item, stone, giver, count)
        return stone ~= nil and stone.prefab == "ttk_lingshi1"
            and (count == nil or count == 1)
            and item.components.fueled:GetPercent() < 1
    end)
    inst.components.trader.onaccept = function(item, giver)
        item.components.fueled:DoDelta(item.components.fueled.maxfuel * 0.05)
        OnAddFuelItem(item, nil, nil, giver)
    end

    inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(onuse)
    inst.components.spellcaster.canuseontargets = true
    inst.components.spellcaster.can_cast_fn = can_cast_fn

    turnon(inst)

	inst.OnSave = function(inst,data)
		
	end
	inst.OnLoad = OnLoad
    MakeHauntableLaunch(inst)
    return inst
end

return  Prefab("nhatvuphuonghoa", fn, assets, prefabs)
