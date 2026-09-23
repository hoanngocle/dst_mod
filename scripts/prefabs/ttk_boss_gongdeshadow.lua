-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local Prefab = Boss.Prefab
local XD_CanAttackTrget = Boss.XD_CanAttackTrget
local XD_GetDamageTargets = Boss.XD_GetDamageTargets
local Xd_CalcDamage = Boss.Xd_CalcDamage
local  shadowassets = {
	Asset("ANIM", Boss.ArtPath("anim/lavaarena_shadow_lunge.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_tssyq.zip")),
	Asset("ANIM", Boss.ArtPath("anim/waxwell_minion_idle.zip")),
	Asset("ANIM", Boss.ArtPath("anim/swap_nightmaresword_shadow.zip")),
}
local channelerassets =
{
    Asset("ANIM", Boss.ArtPath("anim/shadow_channeler.zip")),
}
local mychars = {"xd_longtaizi","xd_sudaji","xd_wukong","xd_zhouwang"}
local function CopyFromPlayer(inst,owner,target,pos,xianjun)
	if xianjun then
		inst.AnimState:SetBuild(mychars[math.random(#mychars)])
	else
    	inst:DoTaskInTime(0,function()
			if owner.components.skinner then
    	    	inst.components.skinner:CopySkinsFromPlayer(owner)
			else
				local build = owner.AnimState:GetBuild()
				if build then
					inst.AnimState:SetBuild(Boss.Art(build))
				end
			end
    	end)
	end
    inst.owner = owner
    inst.target = target
    inst.startpos = pos
end
local function shadowfn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	MakeInventoryPhysics(inst)
	RemovePhysicsColliders(inst)
	inst.Transform:SetFourFaced(inst)
	inst.AnimState:SetBank(Boss.Art("wilson"))
	inst.AnimState:SetBuild(Boss.Art("wilson"))
	inst.AnimState:OverrideSymbol("fx_wipe", "wilson_fx", "fx_wipe")
	inst.AnimState:PlayAnimation("minion_spawn")
	inst.AnimState:SetAddColour(255/255, 250/255, 180/255, .85)
	inst.AnimState:UsePointFiltering(true)
    inst.AnimState:AddOverrideBuild(Boss.Art("player_lunge"))
	inst.AnimState:AddOverrideBuild(Boss.Art("waxwell_minion_spawn"))
	inst.AnimState:AddOverrideBuild(Boss.Art("waxwell_minion_appear"))
	inst.AnimState:AddOverrideBuild(Boss.Art("lavaarena_shadow_lunge"))
    inst.AnimState:OverrideSymbol("swap_object", "spear_wathgrithr_lightning", "swap_spear_wathgrithr_lightning")
	inst.AnimState:Hide("ARM_normal")
	inst.AnimState:Hide("HAT")
	inst.AnimState:Hide("HAIR_HAT")
	inst:AddTag("fx")
	inst:AddTag("NOBLOCK")
	inst.entity:SetPristine()
	if not TheWorld.ismastersim then
		return inst
	end
    inst.attack_count = 0
    inst:AddComponent("locomotor")
	inst:AddComponent("skinner")
	inst.components.skinner:SetupNonPlayerData()
	inst.persists = false
	inst:DoTaskInTime(15, inst.Remove)
    inst.CopyFromPlayer = CopyFromPlayer
    inst:SetStateGraph("SGttk_boss_gongdeshadow")
	return inst
end
local function ondone(inst)
	inst:RemoveEventCallback("animover",ondone)
	inst.AnimState:PlayAnimation("lunge_loop")
	inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_nightsword")
	inst.SoundEmitter:PlaySound("dontstarve/impacts/impact_shadow_med_sharp")
	inst.Physics:SetMotorVelOverride(35, 0, 0)
	inst:DoTaskInTime(7 * FRAMES,function()
		inst.AnimState:PlayAnimation("lunge_pst")
		inst.Physics:SetMotorVelOverride(12, 0, 0)
        inst.AnimState:SetMultColour(43/255, 0/255, 3/255, .85)
		inst.gotoremove = true
		inst:ListenForEvent("animover",inst.Remove)
	end)
end
local function lunge(inst,targets)
	if targets then
		inst.targets = targets
	end
	inst.AnimState:SetBankAndPlayAnimation("lavaarena_shadow_lunge", "lunge_pre")
	inst:ListenForEvent("animover",ondone)
	inst:ForceFacePoint(inst.startpos)
	inst:DoPeriodicTask(0,function()
		if inst.gotoremove then
			inst.Physics:SetMotorVelOverride(inst.Physics:GetMotorVel() * .8, 0, 0)
			return
		end
		if inst.owner and inst.owner:IsValid() then
			local pos = inst:GetPosition()
			local ents = XD_GetDamageTargets(pos.x,pos.y, pos.z,3)
			for i,v in pairs(ents) do
				if v and v:IsValid() and not inst.targets[v] and v ~= inst.owner and XD_CanAttackTrget(inst.owner,v) then
					inst.targets[v] = true
					local damage = inst.damage or 416.7 * 0.7
					damage = Xd_CalcDamage(inst.owner,damage,v,nil,1)
					local stimuli = inst._xd_damage_record_category == "weapon"
						and "ttk_boss_weapon_skill_damage" or nil
					v.components.combat:GetAttacked(inst.owner,damage,nil,stimuli)
					if inst.damagefn then
						inst.damagefn(inst,v)
					end
				end
			end
		end
	end)
end
local function shadowfn1()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	MakeInventoryPhysics(inst)
	RemovePhysicsColliders(inst)
	inst.Transform:SetFourFaced(inst)
	inst.AnimState:SetBank(Boss.Art("wilson"))
	inst.AnimState:SetBuild(Boss.Art("wilson"))
	inst.AnimState:OverrideSymbol("fx_wipe", "wilson_fx", "fx_wipe")
	inst.AnimState:PlayAnimation("minion_spawn")
	inst.AnimState:SetMultColour(0, 0, 0, .5)
	inst.AnimState:UsePointFiltering(true)
	inst.AnimState:AddOverrideBuild(Boss.Art("waxwell_minion_spawn"))
	inst.AnimState:AddOverrideBuild(Boss.Art("waxwell_minion_appear"))
	inst.AnimState:AddOverrideBuild(Boss.Art("lavaarena_shadow_lunge"))
    inst.AnimState:OverrideSymbol("swap_object", "swap_nightmaresword_shadow","swap_nightmaresword_shadow")
	inst.AnimState:Hide("ARM_normal")
	inst.AnimState:Hide("HAT")
	inst.AnimState:Hide("HAIR_HAT")
	inst:AddTag("fx")
	inst:AddTag("NOBLOCK")
	inst.entity:SetPristine()
	if not TheWorld.ismastersim then
		return inst
	end
	inst:AddComponent("skinner")
	inst.components.skinner:SetupNonPlayerData()
	inst.persists = false
	inst:DoTaskInTime(3, inst.Remove)
	inst.Lunge = lunge
    inst.CopyFromPlayer = CopyFromPlayer
    inst.targets = {}
	return inst
end
local function OnAppear(inst)
    inst:RemoveEventCallback("animover", OnAppear)
    if not inst.killed then
        inst:RemoveTag("notarget")
        inst.components.health:SetInvincible(false)
        inst.AnimState:PlayAnimation("idle", true)
    end
end
local function OnDeath(inst)
    if not inst.killed then
		if inst.damages and inst.damages.damage > 0 and inst.owner and inst.owner:IsValid() and not IsEntityDeadOrGhost(inst.owner, true) then
			inst.owner.components.combat:GetAttacked(inst.owner,inst.damages.damage)
		end
        inst.killed = true
		inst:AddTag("notarget")
        inst:AddTag("NOCLICK")
        inst.persists = false
        inst:RemoveEventCallback("animover", OnAppear)
        inst:RemoveEventCallback("death", OnDeath)
        inst:ListenForEvent("animover", inst.Remove)
        inst.AnimState:PlayAnimation("disappear")
        inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + FRAMES, inst.Remove)
    end
end
local function nodebrisdmg(inst, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
	return false
end
local function KeepTargetFn()
    return false
end
local function CopyFromPlayerChanneler(inst,owner,damages)
    inst.owner = owner
	inst.damages = damages
	local base = 1
    if owner and owner.components.ttk_boss_yslevel and TUNING.XD_YSHEALTHRATE and owner.components.ttk_boss_yslevel.level > TUNING.XD_YSHEALTHRATE then
        base = owner.components.ttk_boss_yslevel.level/TUNING.XD_YSHEALTHRATE
    end
	inst.components.health:SetMaxHealth(math.floor(owner.components.health.maxhealth*10*base))
end
local function OnAttacked(inst,data)
	if inst.damages and data and data.damage then
		inst.damages.damage = inst.damages.damage +data.damage
	end
end
local function channelerfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    MakeObstaclePhysics(inst, .2)
    RemovePhysicsColliders(inst)
    inst.Physics:SetCollisionGroup(COLLISION.SANITY)
    inst.Physics:CollidesWith(COLLISION.SANITY)
    inst.Transform:SetTwoFaced()
    inst:AddTag("notraptrigger")
	inst:AddTag("no_dtexp")
	inst:AddTag("companion")
    inst.AnimState:SetBank(Boss.Art("shadow_channeler"))
    inst.AnimState:SetBuild(Boss.Art("shadow_channeler"))
    inst.AnimState:PlayAnimation("appear")
    inst.AnimState:SetMultColour(1, 1, 1, .5)
	inst:SetPrefabNameOverride("shadowchanneler")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(1)
    inst.components.health:SetInvincible(true)
    inst.components.health.nofadeout = true
    inst.components.health.redirect = nodebrisdmg
    inst:AddComponent("combat")
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst:AddComponent("savedrotation")
    inst:AddComponent("entitytracker")
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("animover", OnAppear)
    inst:ListenForEvent("death", OnDeath)
	inst.CopyFromPlayer = CopyFromPlayerChanneler
	inst.persists = false
	inst:DoTaskInTime(30.3,OnDeath)
    return inst
end
local function ondone2(inst)
	inst.AnimState:PlayAnimation("lunge_loop")
	inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_nightsword")
	inst.SoundEmitter:PlaySound("dontstarve/impacts/impact_shadow_med_sharp")
	inst.Physics:SetMotorVelOverride(35, 0, 0)
	inst:DoTaskInTime(7 * FRAMES,function()
		inst.AnimState:PlayAnimation("lunge_pst")
		if inst.attack_count > 0 then
			if inst.target and inst.target:IsValid() and inst.owner and inst.owner:IsValid() then
				inst.Physics:ClearMotorVelOverride()
				inst.Physics:Stop()
				inst:Lunge(inst.target:GetPosition())
			else
				inst.Physics:SetMotorVelOverride(12, 0, 0)
				inst.AnimState:SetMultColour(43/255, 0/255, 3/255, .85)
				inst.gotoremove = true
				inst:ListenForEvent("animover",inst.Remove)
			end
		else
			inst.Physics:SetMotorVelOverride(12, 0, 0)
        	inst.AnimState:SetMultColour(43/255, 0/255, 3/255, .85)
			inst.gotoremove = true
			inst:ListenForEvent("animover",inst.Remove)
		end
	end)
end
local function lunge2(inst,pos)
	inst.attack_count = inst.attack_count - 1
	inst.gotoremove = false
	inst.targets = {}
	inst.AnimState:SetBankAndPlayAnimation("lavaarena_shadow_lunge", "lunge_pre")
	inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength(),ondone2)
	inst:ForceFacePoint(pos)
	inst:DoPeriodicTask(0,function()
		if inst.gotoremove then
			inst.Physics:SetMotorVelOverride(inst.Physics:GetMotorVel() * .8, 0, 0)
			return
		end
		if inst.owner and inst.owner:IsValid() then
			local pos = inst:GetPosition()
			local ents = XD_GetDamageTargets(pos.x,pos.y, pos.z,3)
			for i,v in pairs(ents) do
				if v and v:IsValid() and not inst.targets[v] and v ~= inst.owner and XD_CanAttackTrget(inst.owner,v) then
					inst.targets[v] = true
					local damage = 124.4
					damage = Xd_CalcDamage(inst.owner,damage,v,nil,1)
					v.components.combat:GetAttacked(inst.owner,damage)
				end
			end
		end
	end)
end
local function CopyFromPlayer2(inst,doer,target)
	inst:DoTaskInTime(0,function()
        inst.components.skinner:CopySkinsFromPlayer(doer)
    end)
	inst.owner = doer
	inst.target = target
	inst:Lunge(inst.target:GetPosition())
end
local function shadowfn2()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	MakeInventoryPhysics(inst)
	RemovePhysicsColliders(inst)
	inst.Transform:SetFourFaced(inst)
	inst.AnimState:SetBank(Boss.Art("wilson"))
	inst.AnimState:SetBuild(Boss.Art("wilson"))
	inst.AnimState:OverrideSymbol("fx_wipe", "wilson_fx", "fx_wipe")
	inst.AnimState:PlayAnimation("minion_spawn")
	inst.AnimState:SetMultColour(0, 0, 0, .5)
	inst.AnimState:UsePointFiltering(true)
	inst.AnimState:AddOverrideBuild(Boss.Art("waxwell_minion_spawn"))
	inst.AnimState:AddOverrideBuild(Boss.Art("waxwell_minion_appear"))
	inst.AnimState:AddOverrideBuild(Boss.Art("lavaarena_shadow_lunge"))
    inst.AnimState:OverrideSymbol("swap_object", "xd_tssyq","swap")
	inst.AnimState:Hide("ARM_normal")
	inst.AnimState:Hide("HAT")
	inst.AnimState:Hide("HAIR_HAT")
	inst:AddTag("fx")
	inst:AddTag("NOBLOCK")
	inst.entity:SetPristine()
	if not TheWorld.ismastersim then
		return inst
	end
	inst:AddComponent("skinner")
	inst.components.skinner:SetupNonPlayerData()
	inst.persists = false
	inst:DoTaskInTime(20, inst.Remove)
	inst.attack_count = 3
	inst.Lunge = lunge2
    inst.CopyFromPlayer = CopyFromPlayer2
    inst.targets = {}
	return inst
end
return Prefab("ttk_boss_gongdeshadow", shadowfn, shadowassets),
	Prefab("ttk_boss_motishadow", shadowfn1, shadowassets),
	Prefab("ttk_boss_tssyqshadow", shadowfn2, shadowassets),
	Prefab("ttk_boss_channeler", channelerfn, channelerassets)
