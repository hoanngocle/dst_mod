-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local Prefab = Boss.Prefab
local XD_CanAttackTrget = Boss.XD_CanAttackTrget
local XD_GetDamageTargets = Boss.XD_GetDamageTargets
local XD_GetGroundPoints = Boss.XD_GetGroundPoints
local Xd_CalcDamage = Boss.Xd_CalcDamage
local function doanimownerremove(inst,anim)
	inst.AnimState:PlayAnimation(anim)
	inst:DoTaskInTime(2, inst.Remove)
	inst:ListenForEvent("animover", inst.Remove)
end
local function miaosha(inst,target)
	if inst.owner and inst.owner:IsValid() and target.components.health and not target.components.health:IsDead()
		and target.components.health:GetPercent() <= 0.07 then
			target.components.health:DoDelta(-target.components.health.currenthealth, nil, inst.owner.nameoverride or inst.owner.prefab, true, inst.owner,true)
			if target.components.health and target.components.health:IsDead() then
				inst.owner:PushEvent("killed", { victim = target })
			end
	end
end
local function addrot(base,add)
	local new = base + add
	if new > 180 then
		new = new - 360
	end
	return new
end
local function mo_doatatcl(inst)
	local findtargets = {}
	if inst.owner and inst.owner:IsValid() then
		local pos = inst:GetPosition()
		local ents = XD_GetDamageTargets(pos.x,pos.y, pos.z,12)
		for i,v in pairs(ents) do
			if v and v:IsValid() and v ~= inst.owner and XD_CanAttackTrget(inst.owner,v) then
				table.insert(findtargets,v)
			end
		end
		shuffleArray(findtargets)
		local targets = {}
		for k = 1, 3 do
			if findtargets[k] then
				table.insert(targets,findtargets[k])
			end
		end
		if next(targets) ~= nil then
			local hittargets = {}
			for _,target in ipairs(targets) do
				local x,y,z = target.Transform:GetWorldPosition()
				local r = 4
				local rd = math.random(-180,180)
				local striker = SpawnPrefab("ttk_boss_motishadow")
				target.mojian_lastrad = rd
				if striker then
					local targetpos = Vector3(x+ r*math.cos(rd*DEGREES),0,z+r*math.sin(rd*DEGREES))
					striker.Transform:SetPosition(targetpos:Get())
					striker.damage = 124.8
					striker:CopyFromPlayer(inst.owner,target,Vector3(x,0,z))
					striker:Lunge(hittargets)
					SpawnAt("ttk_boss_motidie_fx",striker)
				end
			end
		end
		inst:DoTaskInTime(0.2,function()
			local hittargets = {}
			for _,target in ipairs(targets) do
				if inst.owner and inst.owner:IsValid() and target:IsValid() and XD_CanAttackTrget(inst.owner,target) then
					local x,y,z = target.Transform:GetWorldPosition()
					local r = 4
					local rd = target.mojian_lastrad and addrot(target.mojian_lastrad,math.random(60,135)) or math.random(-180,180)
					local striker = SpawnPrefab("ttk_boss_motishadow")
					target.mojian_lastrad = nil
					if striker then
						local targetpos = Vector3(x+ r*math.cos(rd*DEGREES),0,z+r*math.sin(rd*DEGREES))
						striker.Transform:SetPosition(targetpos:Get())
						striker.damage = 138.6
						striker.damagefn  = miaosha
						striker:CopyFromPlayer(inst.owner,target,Vector3(x,0,z))
						striker:Lunge(hittargets)
						SpawnAt("ttk_boss_motidie_fx",striker)
					end
				end
			end
		end)
	end
end
local function SpawnIceImpactFX(inst, x, z)
	if x == nil then
		local y
		x, y, z = inst.Transform:GetWorldPosition()
	end
	local fx = SpawnPrefab("sharkboi_iceimpact_fx")
	fx.Transform:SetPosition(x, 0, z)
	fx.AnimState:SetMultColour(0/255,0/255,0/255,0.5)
end
local function DoAOEAttack(inst)
	if inst.owner and inst.owner:IsValid() then
		local x,y,z = inst.Transform:GetWorldPosition()
		local explosion = SpawnPrefab("ttk_boss_laser_explosion")
		explosion.Transform:SetPosition(x, y, z)
		explosion.AnimState:SetMultColour(0/255,0/255,0/255,0.5)
		explosion.Transform:SetScale(1.207,1.207,1.207)
		inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_explo")
		local ents = XD_GetDamageTargets(x, y, z,7)
		for i,v in pairs(ents) do
			if v and v:IsValid() and v:IsValid() and v ~= inst.owner and XD_CanAttackTrget(inst.owner,v) then
				local damage = 124.8
				if inst.owner:HasTag("player") then
					damage = Xd_CalcDamage(inst.owner,damage,v,nil,1)
				end
				v.components.combat:GetAttacked(inst.owner,damage)
				miaosha(inst,v)
			end
		end
	end
end
local sword_aoe = {
	ttk_boss_sword_green_skillfx = "ttk_boss_sword_green_explodefx",
	ttk_boss_sword_bigskill_redfx = "ttk_boss_sword_bigskill_redexplodefx",
	ttk_boss_sword_bigskill_bluefx = "ttk_boss_sword_bigskill_blueexplodefx",
}
local function swordfx(name,build,anim,bloom,applybuild,bank,onground,sound,four)
	local assets =
	{
    	Asset("ANIM", Boss.ArtPath("anim/"..build..".zip")),
		Asset("ANIM", Boss.ArtPath("anim/xd_ysb_swordfx.zip")),
		Asset("ANIM", Boss.ArtPath("anim/xd_ysb_boomfx.zip")),
	}
	if applybuild then
		table.insert(assets,Asset("ANIM", Boss.ArtPath("anim/"..applybuild..".zip")))
	end
	local function fn()
		local inst = CreateEntity()
		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.entity:AddNetwork()
		if four then
			inst.Transform:SetFourFaced(inst)
		end
		inst.AnimState:SetBank(Boss.Art(bank or build))
		inst.AnimState:SetBuild(Boss.Art(build))
		if applybuild then
			inst.AnimState:AddOverrideBuild(Boss.Art(applybuild))
		end
		inst.AnimState:PlayAnimation(anim or "attack")
		if bloom then
			inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
		end
		inst.AnimState:SetFinalOffset(name == "xd_sword_green_explodefx" and 2 or 1)
		if sound then
			inst.entity:AddSoundEmitter()
		else
			inst.AnimState:HideSymbol("png")
		end
		if onground then
			inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
			inst.AnimState:SetLayer(LAYER_BACKGROUND)
			inst.AnimState:SetSortOrder(3)
		end
		inst:AddTag("fx")
		inst.entity:SetPristine()
		if not TheWorld.ismastersim then
			return inst
		end
		inst.persists = false
		if sword_aoe[name] then
			local s  = 1.257
			inst.AnimState:SetScale(s, s, s)
			inst:AddComponent("colourtweener")
			inst:DoTaskInTime(1,function()
				if inst.damagefn then
					inst:damagefn()
				end
				local fx = SpawnAt(sword_aoe[name],inst)
				if fx then
					if	inst.explodefxbuild then
						fx.AnimState:SetBuild(Boss.Art(inst.explodefxbuild))
					end
					if inst.multcolour then
						fx.AnimState:SetMultColour(inst.multcolour[1],inst.multcolour[2],inst.multcolour[3],inst.multcolour[4])
					end
				end
				inst.SoundEmitter:PlaySound("xd_pog_sound/xd_pog_sound/green_skill2",nil,0.75)
			end)
			inst:DoTaskInTime(1.12,function()
				inst.components.colourtweener:StartTween({1, 1, 1, 0}, inst.AnimState:GetCurrentAnimationLength()-1.12, function()
					inst:Remove()
                end)
			end)
			inst:DoTaskInTime(3, inst.Remove)
			inst.skinsymbol = "charged_moonglass_rock"
			inst.SetSkin = function(inst,skin)
				if skin then
					inst.build = build
					inst.skin = skin
					inst.AnimState:OverrideSymbol(inst.skinsymbol, inst.build.."_"..skin, inst.skinsymbol)
				end
			end
		elseif name == "ttk_boss_sword_bigskill" then
			local s  = 1.257
			inst.AnimState:SetScale(s, s, s)
			inst:AddComponent("colourtweener")
			inst.AnimState:PushAnimation("idle")
			inst:DoTaskInTime(7,function()
				inst.components.colourtweener:StartTween({1, 1, 1, 0},0.5, function()
					inst:Remove()
                end)
			end)
			inst:DoTaskInTime(9, inst.Remove)
			inst:DoTaskInTime(0.48,function()
				inst.SoundEmitter:PlaySound("xd_pog_sound/xd_pog_sound/green_skill2",nil,0.75)
			end)
			inst:DoTaskInTime(0.6,function()
				if inst.damagefn then
					inst:damagefn()
				end
			end)
			inst:DoTaskInTime(0.84,function()
				if inst.damagefn then
					inst:damagefn()
				end
				local pt = inst:GetPosition()
				SpawnPrefab("groundpoundring_fx").Transform:SetPosition(pt:Get())
				local points = XD_GetGroundPoints(pt)
				local map = TheWorld.Map
				for i, v1 in ipairs(points) do
					for i,v in ipairs(v1) do
						if map:IsLandTileAtPoint(v:Get()) and not map:IsDockAtPoint(v:Get()) then
							SpawnPrefab("groundpound_fx").Transform:SetPosition(v.x, 0, v.z)
						end
					end
				end
				ShakeAllCameras(CAMERASHAKE.VERTICAL, 1, 0.02, 0.3, inst, 30)
			end)
		elseif name == "ttk_boss_sword_mo_meteorfx" then
			local s  = 1.257
			inst.AnimState:SetScale(s, s, s)
			inst.SoundEmitter:PlaySound("moonstorm/creatures/boss/alterguardian3/atk_traps")
			inst.AnimState:PushAnimation("meteor_idle")
			inst:DoTaskInTime(1,function()
				ShakeAllCameras(CAMERASHAKE.VERTICAL, 1, 0.02, 0.3, inst, 30)
				SpawnAt("ttk_boss_sword_mo_groundfx",inst)
				SpawnAt("ttk_boss_sword_mo_quanfx",inst)
			end)
			inst:DoTaskInTime(1+29* FRAMES,function()
				if inst.owner then
					inst.damagetask = inst:DoPeriodicTask(1,mo_doatatcl,0)
				end
			end)
			inst:DoTaskInTime(14.3,function()
				if inst.damagetask then
					inst.damagetask:Cancel()
				end
			end)
			inst:DoTaskInTime(14.9, function()
				doanimownerremove(inst,"meteor_pst")
				SpawnIceImpactFX(inst)
				DoAOEAttack(inst)
			end)
			inst.skinsymbol = "charged_moonglass_rock"
			inst.SetSkin = function(inst,skin)
				if skin then
					inst.build = build
					inst.skin = skin
					inst.AnimState:OverrideSymbol(inst.skinsymbol, inst.build.."_"..skin, inst.skinsymbol)
				end
			end
		elseif name == "ttk_boss_sword_mo_groundfx" then
			inst.AnimState:PushAnimation("meteorground_loop")
			inst:DoTaskInTime(14.9, function()
				doanimownerremove(inst,"meteorground_pst")
			end)
		elseif name == "ttk_boss_sword_mo_quanfx" then
			local s  = 2.3
			inst.Transform:SetScale(s, s, s)
			inst.SoundEmitter:PlaySound("meta2/voidcloth_umbrella/barrier_activate")
			inst.AnimState:PushAnimation("loop",false)
			inst:DoTaskInTime(14.9, function()
				doanimownerremove(inst,"pst")
			end)
			inst.DoRemove = function(inst,time)
				inst:DoTaskInTime(time or 5.1, function()
					doanimownerremove(inst,"pst")
				end)
			end
		else
			inst:ListenForEvent("animover", inst.Remove)
			inst:DoTaskInTime(2, inst.Remove)
		end
		return inst
	end
	return Prefab(name,fn,assets)
end
local function OnHit(inst, attacker, target)
	local blast = SpawnPrefab("ttk_boss_sword_mo_boom")
	blast.SoundEmitter:PlaySound("xd_pog_sound/xd_pog_sound/mo_attack3",nil,0.75)
	local s  = 5
	local pt = target and target:IsValid() and target:GetPosition() or inst:GetPosition()
	blast.Transform:SetPosition((pt+Vector3(0,0.8,0)):Get())
	blast.Transform:SetScale(s, s, s)
	if inst.damagefn then
		inst:damagefn(pt)
	end
    inst:Remove()
end
local function OnThrown(inst, owner, target, attacker)
end
local function OnMiss(inst, attacker, target)
    inst:Remove()
end
local function fxfn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddPhysics()
	inst.entity:AddNetwork()
	MakeInventoryPhysics(inst)
	RemovePhysicsColliders(inst)
	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	inst.AnimState:SetBank(Boss.Art("xd_sword_mo"))
	inst.AnimState:SetBuild(Boss.Art("xd_sword_mo"))
	inst.AnimState:PlayAnimation("anyingqiu")
    inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
	local s  = 5
    inst.AnimState:SetScale(s, s, s)
	inst:AddTag("projectile")
	inst.entity:SetPristine()
	if not TheWorld.ismastersim then
		return inst
	end
	inst:AddComponent("projectile")
	inst.components.projectile:SetSpeed(16)
	inst.components.projectile:SetRange(35)
	inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile:SetOnThrownFn(OnThrown)
	inst.components.projectile:SetOnMissFn(OnMiss)
	inst.components.projectile:SetHitDist(2)
    inst.components.projectile:SetLaunchOffset(Vector3(4, 1.8, 0))
	inst.persists = false
	return inst
end
local function xifn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddPhysics()
	inst.entity:AddNetwork()
	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	inst.AnimState:SetBank(Boss.Art("xd_sword_mo"))
	inst.AnimState:SetBuild(Boss.Art("xd_sword_mo"))
	inst.AnimState:AddOverrideBuild(Boss.Art("xd_sword_mo_skill"))
	inst.Transform:SetFourFaced(inst)
	local s  = 4
    inst.AnimState:SetScale(s, s, s)
	inst.entity:SetPristine()
	if not TheWorld.ismastersim then
		return inst
	end
	inst:DoTaskInTime(0,function()
		inst.AnimState:PlayAnimation("skill1")
	end)
	inst.persists = false
	inst:ListenForEvent("animover", inst.Remove)
	inst:DoTaskInTime(3, inst.Remove)
	return inst
end
local function fn1()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddPhysics()
	inst.entity:AddNetwork()
	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	inst.AnimState:SetBank(Boss.Art("xd_sword_mo"))
	inst.AnimState:SetBuild(Boss.Art("xd_sword_mo"))
	inst.AnimState:AddOverrideBuild(Boss.Art("xd_sword_mo_skill"))
	inst.AnimState:AddOverrideBuild(Boss.Art("xd_sword_mo_bz"))
	inst.Transform:SetFourFaced(inst)
	local s  = 4
    inst.AnimState:SetScale(s, s, s)
	inst.entity:SetPristine()
	if not TheWorld.ismastersim then
		return inst
	end
	inst:DoTaskInTime(0,function()
		inst.AnimState:PlayAnimation("dazhao1")
	end)
	inst:ListenForEvent("animover", inst.Remove)
	inst.persists = false
	inst:DoTaskInTime(0.44,function()
		if inst.damagefn then
			inst:damagefn(inst:GetPosition())
		end
	end)
	inst:DoTaskInTime(3, inst.Remove)
	return inst
end
local function fn2()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddPhysics()
	inst.entity:AddNetwork()
	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	inst.AnimState:SetBank(Boss.Art("xd_sword_mo"))
	inst.AnimState:SetBuild(Boss.Art("xd_sword_mo"))
	inst.AnimState:AddOverrideBuild(Boss.Art("xd_sword_mo_skill"))
	inst.AnimState:AddOverrideBuild(Boss.Art("xd_sword_mo_bz"))
	inst.Transform:SetFourFaced(inst)
	local s  = 2.5
    inst.AnimState:SetScale(s, s, s)
	inst.entity:SetPristine()
	if not TheWorld.ismastersim then
		return inst
	end
	inst:DoTaskInTime(0,function()
		inst.AnimState:PlayAnimation("dazhao")
	end)
	inst.persists = false
	inst:ListenForEvent("animover", inst.Remove)
	inst:DoTaskInTime(0.56,function()
		if inst.damagefn then
			inst:damagefn(inst:GetPosition())
		end
	end)
	inst:DoTaskInTime(1.2,function()
		if inst.damagefn then
			inst:damagefn(inst:GetPosition())
		end
	end)
	inst:DoTaskInTime(1.84,function()
		if inst.damagefn then
			inst:damagefn(inst:GetPosition())
		end
	end)
	inst:DoTaskInTime(2.48,function()
		if inst.damagefn then
			inst:damagefn(inst:GetPosition())
		end
	end)
	inst:DoTaskInTime(3.12,function()
		if inst.damagefn then
			inst:damagefn(inst:GetPosition())
		end
	end)
	inst:DoTaskInTime(4, inst.Remove)
	return inst
end
local brain = require("brains/tornadobrain")
local tornadoassets =
{
    Asset("ANIM", Boss.ArtPath("anim/tornado.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_sword_mo_tornado.zip")),
	Asset("ANIM", Boss.ArtPath("anim/xd_sword_mo_attackbuild.zip")),
}
local function ontornadolifetime(inst)
    inst.task = nil
    inst.sg:GoToState("despawn")
end
local function SetDuration(inst, duration)
    if inst.task ~= nil then
        inst.task:Cancel()
    end
    inst.task = inst:DoTaskInTime(duration, ontornadolifetime)
end
local function tornado_fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.AnimState:SetFinalOffset(2)
    inst.AnimState:SetBank(Boss.Art("tornado"))
    inst.AnimState:SetBuild(Boss.Art("xd_sword_mo_tornado"))
    inst.AnimState:PlayAnimation("tornado_pre")
    inst.AnimState:PushAnimation("tornado_loop")
    inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/tornado", "spinLoop")
    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst:AddComponent("knownlocations")
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.TORNADO_WALK_SPEED * .33
    inst.components.locomotor.runspeed = TUNING.TORNADO_WALK_SPEED
    inst:SetStateGraph("SGttk_boss_sword_mo_tornado")
    inst:SetBrain(brain)
    inst.persists = false
    inst.SetDuration = SetDuration
    inst:SetDuration(5)
    return inst
end
local lightningassets =
{
    Asset("ANIM", Boss.ArtPath("anim/lightning.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_sword_mo_lightning.zip")),
}
local LIGHTNING_MAX_DIST_SQ = 140*140
local function PlayThunderSound(lighting)
	if not lighting:IsValid() or TheFocalPoint == nil then
		return
	end
    local pos = Vector3(lighting.Transform:GetWorldPosition())
    local pos0 = Vector3(TheFocalPoint.Transform:GetWorldPosition())
   	local diff = pos - pos0
    local distsq = diff:LengthSq()
	local k = math.max(0, math.min(1, distsq / LIGHTNING_MAX_DIST_SQ))
	local intensity = math.min(1, k * 1.1 * (k - 2) + 1.1)
	if intensity <= 0 then
		return
	end
    local minsounddist = 10
    local normpos = pos
   	if distsq > minsounddist * minsounddist then
        local normdiff = diff * (minsounddist / math.sqrt(distsq))
   	    normpos = pos0 + normdiff
    end
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.Transform:SetPosition(normpos:Get())
    inst.SoundEmitter:PlaySound("dontstarve/rain/thunder_close", nil, intensity*0.5, true)
    inst:Remove()
end
local function StartFX(inst)
	for i, v in ipairs(AllPlayers) do
		local distSq = v:GetDistanceSqToInst(inst)
		local k = math.max(0, math.min(1, distSq / LIGHTNING_MAX_DIST_SQ))
		local intensity = -(k-1)*(k-1)*(k-1)
		if intensity > 0 then
			v:ScreenFlash(intensity <= 0.05 and 0.05 or intensity)
			v:ShakeCamera(CAMERASHAKE.FULL, .7, .02, intensity / 3)
		end
	end
end
local function lightning_fn()
	local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()
    inst.Transform:SetScale(2, 2, 2)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetBank(Boss.Art("lightning"))
    inst.AnimState:SetBuild(Boss.Art("xd_sword_mo_lightning"))
    inst.AnimState:PlayAnimation("anim")
    inst.SoundEmitter:PlaySound("dontstarve/rain/thunder_close", nil, 0.5, true)
    inst:AddTag("FX")
    if not TheNet:IsDedicated() then
		inst:DoTaskInTime(0, PlayThunderSound)
	end
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.entity:SetCanSleep(false)
    inst.persists = false
    inst:DoTaskInTime(.5, inst.Remove)
    return inst
end
local function aoefn()
	local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()
    inst:AddTag("FX")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
	inst.count = 1
	inst.damagetask = inst:DoPeriodicTask(0.25,function()
		if inst.damagefn then
			inst.damagefn(inst,inst:GetPosition())
			if inst.count == 1 or inst.count == 6 or inst.count == 11 or inst.count == 16 then
				SpawnAt("ttk_boss_sword_mo_lightning",inst)
			end
			inst.count = inst.count + 1
		end
	end,0.25)
	inst.damagetask.limit = 19
    inst.entity:SetCanSleep(false)
    inst.persists = false
    inst:DoTaskInTime(5.2, inst.Remove)
    return inst
end
local function firefn()
	local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()
	inst.AnimState:SetBank(Boss.Art("warg_mutated_breath_fx"))
	inst.AnimState:SetBuild(Boss.Art("warg_mutated_breath_fx"))
	inst.AnimState:PlayAnimation("flame2_pre")
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	inst.AnimState:SetLightOverride(0.1)
	inst.AnimState:SetMultColour(0, 0, 0, .85)
	inst.AnimState:SetFinalOffset(3)
	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
	inst.AnimState:PushAnimation("flame2_loop", true)
	inst:DoTaskInTime(2.5,function()
		inst.AnimState:PlayAnimation("flame2_pst")
		inst:ListenForEvent("animover", inst.Remove)
	end)
    inst.persists = false
    inst:DoTaskInTime(4, inst.Remove)
    return inst
end
return Prefab("ttk_boss_sword_ayq",fxfn),
	Prefab("ttk_boss_sword_xi",xifn),
	Prefab("ttk_boss_sword_mofx1",fn1),
	Prefab("ttk_boss_sword_mofx2",fn2),
	Prefab("ttk_boss_sword_mo_tornado",tornado_fn,tornadoassets),
	Prefab("ttk_boss_sword_mo_lightning",lightning_fn,lightningassets),
	Prefab("ttk_boss_sword_mo_aoe",aoefn),
	Prefab("ttk_boss_weapon_jjfirefx",firefn),
	swordfx("ttk_boss_sword_red_attackfx","ttk_boss_sword_red",nil,nil,nil,nil,nil,nil,true),
	swordfx("ttk_boss_sword_red_skillfx","ttk_boss_sword_red_skillfx","fx"),
	swordfx("ttk_boss_sword_white_skillfx","ttk_boss_sword_white_skillfx","fx"),
	swordfx("ttk_boss_sword_blue_skillfx","ttk_boss_sword_blue","hit"),
	swordfx("ttk_boss_sword_green_skillfx","ttk_boss_sword_green_skillfx","meteor_pre",false,nil,nil,nil,true),
	swordfx("ttk_boss_sword_green_explodefx","ttk_boss_sword_green","explode",false,nil,nil,nil,true),
	swordfx("ttk_boss_sword_bigskill_redfx","ttk_boss_sword_bigskill_redfx","meteor_pre",false,nil,"ttk_boss_sword_green_skillfx",nil,true),
	swordfx("ttk_boss_sword_bigskill_redexplodefx","ttk_boss_sword_green","explode",false,"ttk_boss_sword_bigskill_redexplodefx"),
	swordfx("ttk_boss_sword_bigskill_bluefx","ttk_boss_sword_bigskill_bluefx","meteor_pre",false,nil,"ttk_boss_sword_green_skillfx",nil,true),
	swordfx("ttk_boss_sword_bigskill_blueexplodefx","ttk_boss_sword_green","explode",false,"ttk_boss_sword_bigskill_blueexplodefx"),
	swordfx("ttk_boss_sword_bigskill","ttk_boss_sword_bigskill","luoxia",false,nil,nil,nil,true),
	swordfx("ttk_boss_sword_mo_meteorfx","ttk_boss_sword_mo_meteorfx","meteor_pre",false,nil,nil,nil,true),
	swordfx("ttk_boss_sword_mo_groundfx","ttk_boss_sword_mo_meteorfx","meteorground_pre",false,nil,nil,true),
	swordfx("ttk_boss_sword_mo_quanfx","ttk_boss_sword_mo_quanfx","pre",false,nil,nil,true,true),
	swordfx("ttk_boss_sword_green_upfx","ttk_boss_sword_green","upfx"),
	swordfx("ttk_boss_sword_mo_skillfx","ttk_boss_sword_mo_skillfx","fx",nil,nil,"ttk_boss_sword_red_skillfx"),
	swordfx("ttk_boss_sword_mo_boom","ttk_boss_sword_mo","baozha",nil,"ttk_boss_sword_mo_bz",nil,nil,true)
