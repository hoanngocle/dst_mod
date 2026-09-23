-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local Prefab = Boss.Prefab
local XD_CanAttackTrget = Boss.XD_CanAttackTrget
local XD_GetDamageTargets = Boss.XD_GetDamageTargets
local Xd_CalcDamage = Boss.Xd_CalcDamage
local function doanimownerremove(inst,anim)
	inst.AnimState:PlayAnimation(anim)
	inst:DoTaskInTime(2, inst.Remove)
	inst:ListenForEvent("animover", inst.Remove)
end
local function addrot(base,add)
	local new = base + add
	if new > 180 then
		new = new - 360
	end
	return new
end
local attacktag = {"_combat","_health"}
local noltags =  {"ttk_boss_ziyun","notarget", "noattack", "flight", "invisible", "playerghost"}
local function mo_doatatcl(inst)
	local findtargets = {}
	if inst.owner and inst.owner:IsValid() then
		local pos = inst:GetPosition()
		local ents =  TheSim:FindEntities(pos.x,0,pos.z, 8, attacktag,noltags)
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
				local striker = SpawnPrefab("ttk_boss_ziyunboss_shadower")
				target.ziyuansword_lastrad = rd
				if striker then
					local targetpos = Vector3(x+ r*math.cos(rd*DEGREES),0,z+r*math.sin(rd*DEGREES))
					striker.Transform:SetPosition(targetpos:Get())
					striker.startpos = Vector3(x,0,z)
					striker.owner = inst.owner
					striker:Lunge(hittargets,inst.damage or 25)
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
					local rd = target.ziyuansword_lastrad and addrot(target.ziyuansword_lastrad,math.random(60,135)) or math.random(-180,180)
					local striker = SpawnPrefab("ttk_boss_ziyunboss_shadower")
					target.ziyuansword_lastrad = nil
					if striker then
						local targetpos = Vector3(x+ r*math.cos(rd*DEGREES),0,z+r*math.sin(rd*DEGREES))
						striker.Transform:SetPosition(targetpos:Get())
						striker.owner = inst.owner
						striker.startpos = Vector3(x,0,z)
						striker:Lunge(hittargets,inst.damage or 25)
						SpawnAt("ttk_boss_motidie_fx",striker)
					end
				end
			end
		end)
	end
end
local function DoAOEAttack(inst)
	if inst.owner and inst.owner:IsValid() then
		local x,y,z = inst.Transform:GetWorldPosition()
		local explosion = SpawnPrefab("ttk_boss_laser_explosion")
		explosion.Transform:SetPosition(x, y, z)
		explosion.AnimState:SetMultColour(0/255,0/255,0/255,0.5)
		explosion.Transform:SetScale(1.207,1.207,1.207)
		inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_explo")
		if inst.owner.DoAoeAttck then
			inst.owner:DoAoeAttck(Vector3(x, 0, z),4,25)
		else
			local ents = XD_GetDamageTargets(x, 0, z, 4)
			for i,v in pairs(ents) do
				if  v:IsValid() and  XD_CanAttackTrget(inst.owner,v) then
					local damage = Xd_CalcDamage(inst.owner,40,v)
					v.components.combat:GetAttacked(inst.owner,damage)
				end
			end
		end
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
local function swordfx(name,build,anim,bloom,applybuild,bank,onground,sound)
	local assets =
	{
    	Asset("ANIM", Boss.ArtPath("anim/"..build..".zip")),
	}
	local function fn()
		local inst = CreateEntity()
		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.entity:AddNetwork()
		inst.AnimState:SetBank(Boss.Art(bank or build))
		inst.AnimState:SetBuild(Boss.Art(build))
		if applybuild then
			inst.AnimState:AddOverrideBuild(Boss.Art(applybuild))
		end
		inst.AnimState:PlayAnimation(anim or "attack")
		if bloom then
			inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
		end
		if sound then
			inst.entity:AddSoundEmitter()
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
		if name == "ttk_boss_ziyunsword_meteorfx" then
			local s  = 1.257
			inst.AnimState:SetScale(s, s, s)
			inst.SoundEmitter:PlaySound("moonstorm/creatures/boss/alterguardian3/atk_traps")
			inst.AnimState:PushAnimation("meteor_idle")
			inst:DoTaskInTime(1,function()
				ShakeAllCameras(CAMERASHAKE.VERTICAL, 1, 0.02, 0.3, inst, 30)
				SpawnAt("ttk_boss_ziyunsword_groundfx",inst)
				SpawnAt("ttk_boss_ziyunsword_quanfx",inst)
			end)
			inst:DoTaskInTime(1+29* FRAMES,function()
				if inst.owner then
					inst.damagetask = inst:DoPeriodicTask(1,mo_doatatcl,0)
				end
			end)
			inst:DoTaskInTime(8.3,function()
				if inst.damagetask then
					inst.damagetask:Cancel()
				end
			end)
			inst:DoTaskInTime(8.9, function()
				doanimownerremove(inst,"meteor_pst")
				SpawnIceImpactFX(inst)
				DoAOEAttack(inst)
			end)
		elseif name == "ttk_boss_ziyunsword_groundfx" then
			inst.AnimState:PushAnimation("meteorground_loop")
			inst:DoTaskInTime(8.9, function()
				doanimownerremove(inst,"meteorground_pst")
			end)
		elseif name == "ttk_boss_ziyunsword_quanfx" then
			local s  = 1.8
			inst.Transform:SetScale(s, s, s)
			inst.SoundEmitter:PlaySound("meta2/voidcloth_umbrella/barrier_activate")
			inst.AnimState:PushAnimation("loop",false)
			inst:DoTaskInTime(8.9, function()
				doanimownerremove(inst,"pst")
			end)
			inst.DoRemove = function(inst,time)
				inst:DoTaskInTime(time or 5.1, function()
					doanimownerremove(inst,"pst")
				end)
			end
		end
		return inst
	end
	return Prefab(name,fn,assets)
end
return swordfx("ttk_boss_ziyunsword_meteorfx","ttk_boss_sword_mo_meteorfx","meteor_pre",false,nil,nil,nil,true),
	swordfx("ttk_boss_ziyunsword_groundfx","ttk_boss_sword_mo_meteorfx","meteorground_pre",false,nil,nil,true),
	swordfx("ttk_boss_ziyunsword_quanfx","ttk_boss_sword_mo_quanfx","pre",false,nil,nil,true,true)
