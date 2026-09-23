-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local Prefab = Boss.Prefab
local XD_CanAttackTrget = Boss.XD_CanAttackTrget
local XD_GetDamageTargets = Boss.XD_GetDamageTargets
local assets =
{
    Asset("ANIM", Boss.ArtPath("anim/xd_hyf.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_hyf_spin.zip")),
    Asset("ANIM", Boss.ArtPath("anim/boomerang.zip")),
    Asset("ANIM", Boss.ArtPath("anim/moonbase_fx.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_lunar_fx.zip")),
    Asset("ANIM", Boss.ArtPath("anim/brilliance_projectile_fx.zip")),
	Asset("ATLAS", "images/inventoryimages/xd_hyf.xml"),
    Asset("IMAGE", "images/inventoryimages/xd_hyf.tex"),
}
local prefabs = {
    "ttk_boss_hyf_projectile_fx",
    "ttk_boss_hyf_projectile_blast_fx",
}
local function spinfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)
    inst.AnimState:SetBank(Boss.Art("boomerang"))
    inst.AnimState:SetBuild(Boss.Art("xd_hyf_spin"))
    inst.AnimState:PlayAnimation("spin_loop",true)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.SoundEmitter:PlaySound("dontstarve/wilson/boomerang_throw","spin_loop")
    inst:AddTag("projectile")
    inst:AddTag("fx")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst:AddComponent("ttk_boss_biu")
	inst.components.ttk_boss_biu:SetSpeed(12)
	inst.components.ttk_boss_biu:SetRange(20)
    inst.components.ttk_boss_biu:SetHitDist(1.5)
    inst.components.ttk_boss_biu:SetLaunchOffset(Vector3(1, 0.6, 0))
    inst.components.ttk_boss_biu:SetOnThrownFn(function(projectile, owner) projectile.owner = owner end)
    return inst
end
local SPEED = 15
local BOUNCE_RANGE = 12
local BOUNCE_SPEED = 10
local function PlayAnimAndRemove(inst, anim)
	inst.AnimState:PlayAnimation(anim)
	if not inst.removing then
		inst.removing = true
		inst:ListenForEvent("animover", inst.Remove)
	end
end
local function OnThrown(inst, owner, target, attacker)
	inst.owner = owner
	if inst.bounces == nil then
		inst.bounces = 8
		inst.initial_hostile = target ~= nil and target:IsValid() and target:HasTag("hostile")
	end
end
local function TryBounce(inst, x, z, attacker, target)
	if attacker.components.combat == nil or not attacker:IsValid() then
		inst:Remove()
		return
	end
	local newtarget
    if attacker:IsValid() then
        local ents = XD_GetDamageTargets(x, 0, z, BOUNCE_RANGE)
        for i,v in pairs(ents) do
            if not inst.targets[v] and v.entity:IsVisible() and XD_CanAttackTrget(attacker,v) then
                newtarget = v
                break
            end
        end
    end
	if newtarget ~= nil then
		inst.Physics:Teleport(x, 0, z)
		inst:Show()
		inst.components.projectile:SetSpeed(BOUNCE_SPEED)
		inst.components.projectile:SetBounced(true)
		inst.components.projectile.overridestartpos = Vector3(x, 0, z)
		inst.components.projectile:Throw(inst.owner, newtarget, attacker)
	else
		inst:Remove()
	end
end
local function OnHit(inst, attacker, target)
	local blast = SpawnPrefab("brilliance_projectile_blast_fx")
	local x, y, z
	if target:IsValid() then
        inst.targets[target]  = true
		local radius = target:GetPhysicsRadius(0) + .2
		local angle = (inst.Transform:GetRotation() + 180) * DEGREES
		x, y, z = target.Transform:GetWorldPosition()
		x = x + math.cos(angle) * radius + GetRandomMinMax(-.2, .2)
		y = GetRandomMinMax(.1, .3)
		z = z - math.sin(angle) * radius + GetRandomMinMax(-.2, .2)
		blast:PushFlash(target)
	else
		x, y, z = inst.Transform:GetWorldPosition()
	end
	blast.Transform:SetPosition(x, y, z)
    if inst.owner and inst.owner:IsValid() then
        inst.owner.instantdamage =  nil
    end
	if inst.bounces ~= nil and inst.bounces > 1 and attacker ~= nil and attacker.components.combat ~= nil and attacker:IsValid() then
        inst.bounces = inst.bounces - 1
		inst.Physics:Stop()
		inst:Hide()
		inst:DoTaskInTime(.1, TryBounce, x, z, attacker, target)
	else
		inst:Remove()
	end
end
local function OnMiss(inst, attacker, target)
	if not inst.AnimState:IsCurrentAnimation("disappear") then
		PlayAnimAndRemove(inst, "disappear")
	end
end
local function onprehit(inst, attacker, target)
    if inst.owner and inst.owner:IsValid() then
        inst.owner.instantdamage =  250
    end
end
local function projectilefn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddPhysics()
	inst.entity:AddNetwork()
	MakeInventoryPhysics(inst)
	RemovePhysicsColliders(inst)
	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	inst.AnimState:SetBank(Boss.Art("brilliance_projectile_fx"))
	inst.AnimState:SetBuild(Boss.Art("brilliance_projectile_fx"))
	inst.AnimState:PlayAnimation("idle_loop", true)
	inst.AnimState:SetSymbolMultColour("light_bar", 1, 1, 1, .5)
	inst.AnimState:SetSymbolBloom("light_bar")
	inst.AnimState:SetSymbolBloom("glow")
	inst.AnimState:SetLightOverride(.5)
    inst.AnimState:SetMultColour(255/255,238/255,144/255,1)
	inst:AddTag("projectile")
	inst.entity:SetPristine()
	if not TheWorld.ismastersim then
		return inst
	end
    inst.targets = {}
	inst:AddComponent("projectile")
	inst.components.projectile:SetSpeed(SPEED)
	inst.components.projectile:SetRange(25)
	inst.components.projectile:SetOnThrownFn(OnThrown)
	inst.components.projectile:SetOnHitFn(OnHit)
	inst.components.projectile:SetOnMissFn(OnMiss)
    inst.components.projectile.onprehit = onprehit
	inst.persists = false
	return inst
end
local function PushColour(inst, r, g, b)
	if inst.target:IsValid() then
		if inst.target.components.colouradder == nil then
			inst.target:AddComponent("colouradder")
		end
		inst.target.components.colouradder:PushColour(inst, r, g, b, 0)
	end
end
local function PopColour(inst)
	inst.OnRemoveEntity = nil
	if inst.target.components.colouradder ~= nil and inst.target:IsValid() then
		inst.target.components.colouradder:PopColour(inst)
	end
end
local function PushFlash(inst, target)
	inst.target = target
	PushColour(inst, .1, .1, .1)
	inst:DoTaskInTime(4 * FRAMES, PushColour, .075, .075, .075)
	inst:DoTaskInTime(7 * FRAMES, PushColour, .05, .05, .05)
	inst:DoTaskInTime(9 * FRAMES, PushColour, .025, .025, .025)
	inst:DoTaskInTime(10 * FRAMES, PopColour)
	inst.OnRemoveEntity = PopColour
end
local function blastfn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	inst.AnimState:SetBank(Boss.Art("brilliance_projectile_fx"))
	inst.AnimState:SetBuild(Boss.Art("brilliance_projectile_fx"))
	inst.AnimState:PlayAnimation("blast1")
	inst.AnimState:SetSymbolMultColour("light_bar", 1, 1, 1, .5)
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	inst.AnimState:SetLightOverride(.5)
    inst.AnimState:SetMultColour(255/255,238/255,144/255,1)
	if not TheWorld.ismastersim then
		return inst
	end
	if math.random() < 0.5 then
		inst.AnimState:PlayAnimation("blast2")
	end
	inst:ListenForEvent("animover", inst.Remove)
	inst.persists = false
	inst.PushFlash = PushFlash
	return inst
end
local function fullfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.AnimState:SetBank(Boss.Art("xd_lunar_fx"))
    inst.AnimState:SetBuild(Boss.Art("moonbase_fx"))
    inst.AnimState:PlayAnimation("lunar_full_pst")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetFinalOffset(2)
    inst.AnimState:SetMultColour(255/255,238/255,144/255,1)
    inst:AddTag("FX")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.persists = false
    inst:ListenForEvent("animover", inst.Remove)
    return inst
end
local function frontfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.AnimState:SetBank(Boss.Art("xd_lunar_fx"))
    inst.AnimState:SetBuild(Boss.Art("moonbase_fx"))
    inst.AnimState:PlayAnimation("lunar_front_pst")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetFinalOffset(3)
    inst.AnimState:SetMultColour(255/255,238/255,144/255,1)
    inst:AddTag("FX")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst:DoTaskInTime(0,function()
        if not inst.nosound then
            inst.SoundEmitter:PlaySound("dontstarve/common/together/moonbase/beam_stop_fail",nil,inst.soundsize or 1)
        end
    end)
    inst.persists = false
    inst:ListenForEvent("animover", inst.Remove)
    return inst
end
local function frontsmallfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.AnimState:SetBank(Boss.Art("xd_lunar_fx"))
    inst.AnimState:SetBuild(Boss.Art("moonbase_fx"))
    inst.AnimState:PlayAnimation("lunar_front_pst")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetFinalOffset(3)
    inst.AnimState:SetMultColour(255/255,238/255,144/255,1)
    inst.SoundEmitter:PlaySound("dontstarve/common/together/moonbase/beam_stop_fail",nil,0.3)
    inst:AddTag("FX")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.persists = false
    inst:ListenForEvent("animover", inst.Remove)
    return inst
end
return 
    Prefab("ttk_boss_hyf_fx", spinfn, assets),
    Prefab("ttk_boss_hyf_fullfx", fullfn, assets),
    Prefab("ttk_boss_hyf_frontfx", frontfn, assets),
    Prefab("ttk_boss_hyf_frontfx_small", frontsmallfn, assets),
    Prefab("ttk_boss_hyf_projectile_fx", projectilefn, assets),
	Prefab("ttk_boss_hyf_projectile_blast_fx", blastfn, assets)
