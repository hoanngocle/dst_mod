-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local Prefab = Boss.Prefab
local XD_CanAttackTrget = Boss.XD_CanAttackTrget
local XD_GetDamageTargets = Boss.XD_GetDamageTargets
local XD_Get_OwnerCalcDamage = Boss.XD_Get_OwnerCalcDamage
local Xd_CalcDamage = Boss.Xd_CalcDamage
local assets =
{
    Asset("ANIM", Boss.ArtPath("anim/xd_ht.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_ht_cloudfx.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_ht_weapon.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_ht_swordskill.zip")),
	Asset("ANIM", Boss.ArtPath("anim/xd_ht_circle.zip")),
	Asset("ANIM", Boss.ArtPath("anim/xd_ht_sand_puff.zip")),
}
local prefabs = {}
local brain = require "brains/ttk_boss_htbrains"
local WagBossUtil = require("prefabs/wagboss_util")
local nottags = {"moonstorm_static","abigail","companion","player","INLIMBO","wall", "notarget", "noattack", "flight", "invisible", "playerghost"}
if TheNet:GetPVPEnabled() then
    nottags =  {"moonstorm_static","INLIMBO","wall", "notarget", "noattack", "flight", "invisible", "playerghost"}
end
local function RetargetFn(inst)
    local owner = inst.owner
    return owner ~= nil and FindEntity(inst, 10,
        function(guy)
            return owner:IsValid() and XD_CanAttackTrget(inst,guy)
                and (guy.components.combat:TargetIs(owner) or
                owner.components.combat:TargetIs(guy) or
                guy.components.combat:TargetIs(inst) )
        end,
        { "_combat","_health" },
        nottags
    ) or nil
end
local function OnHitOther(inst, other)
end
local function ondeath(inst)
end
local function KeepTarget(inst, target)
	return false
end
local function OnAttacked(inst, data)
    if data.attacker ~= nil and data.attacker ~= inst.owner then
        if data.attacker.components.combat ~= nil then
            inst.components.combat:SuggestTarget(data.attacker)
        end
    end
end
local function onfly(inst)
    local fly = inst._isflying:value()
    if fly then
        if not inst.flyfx then
            inst.flyfx = SpawnPrefab('ttk_boss_ht_flyerfx_cloud')
            inst.flyfx:config({})
            inst.flyfx:init()
            inst:AddChild(inst.flyfx)
        end
    else
        if inst.flyfx and inst.flyfx:IsValid() then
            inst.flyfx:Despawn(2)
            inst.flyfx = nil
        end
    end
end
local function spawncloud(inst)
    if not inst.flyfx then
        inst.flyfx = SpawnPrefab('ttk_boss_ht_flyerfx_cloud')
        inst.flyfx:config({})
        inst.flyfx:init()
        inst:AddChild(inst.flyfx)
		inst.Physics:SetCapsule(0.5, -2.5)
    end
end
local function UpdateHeight(inst)
	if inst.components.locomotor and inst.flyfx then
		local height_target = 2.5
		local a,b,c = inst.Physics:GetMotorVel()
		local y = inst:GetPosition().y
		inst.Physics:SetMotorVel(a, (height_target - y)*32, c)
	else
	end
end
local function ttk_boss_zhaohui(inst,owner)
    if inst and inst:IsValid() and not inst.components.health:IsDead() and owner and owner:IsValid() then
        if inst.components.combat and inst.components.combat.target then
            inst.components.combat:SetTarget(nil)
            inst.components.combat:BlankOutAttacks(1)
        end
        local x,y,z = owner.Transform:GetWorldPosition()
        local r = GetRandomMinMax(0.6,3)
        local rd = math.random(360)*DEGREES
        local pos = Vector3(x+ r*math.cos(rd),0,z+r*math.sin(rd))
        inst.Physics:Teleport(pos:Get())
        SpawnAt("ttk_boss_bigspawn_fx_medium_static_new",inst)
    end
end
local function OnSpawnedBy(inst, stalker,rate)
    if stalker then
        inst.owner = stalker
		XD_Get_OwnerCalcDamage(inst)
        inst.components.locomotor.walkspeed = stalker.components.locomotor:GetRunSpeed()
        inst.components.locomotor.runspeed =  stalker.components.locomotor:GetRunSpeed()
        inst.components.follower:SetLeader(stalker)
        inst:ForceFacePoint(stalker.Transform:GetWorldPosition())
		inst:ListenForEvent("onattackother",function(owner,data)
			if not( inst:IsValid() and stalker:IsValid() and inst:IsNear(stalker,12)) then
				return
			end
			inst:PushEvent("do_ht_attack",data)
		end,stalker)
        inst:ListenForEvent("do_gongde_attack",function(_,data)
			if not( inst:IsValid() and stalker:IsValid() and inst:IsNear(stalker,12)) then
				return
			end
			if inst.skill1_time and GetTime() - inst.skill1_time <= 2 then
				return
			end
            if data and data.target and (not inst.skill1_time or GetTime() - inst.skill1_time > 2) then
                inst.skill1target = data.target
				inst.skill1_time = GetTime()
            end
        end,stalker)
        inst:ListenForEvent("do_skill_small",function(_,data)
			if not( inst:IsValid() and stalker:IsValid() and inst:IsNear(stalker,12)) then
				return
			end
            if data and data.pos then
                inst.skill2pos = data.pos
                inst.skill2_time = GetTime()
            end
        end,stalker)
        inst:ListenForEvent("do_skill_big",function(_,data)
			if not( inst:IsValid() and stalker:IsValid() and inst:IsNear(stalker,12)) then
				return
			end
            if data and data.pos then
                inst.skill3pos = data.pos
				inst.skill3_playerpos = inst.owner and inst.owner:IsValid() and inst.owner:GetPosition() or nil
                inst.skill3_time = GetTime()
            end
        end,stalker)
        inst:ListenForEvent("onremove", function()
            if inst and inst:IsValid() then
                inst:Remove()
            end
        end,stalker)
        inst:ListenForEvent("death", function()
			inst.shouldgoaway = true
        end,stalker)
		if stalker.isplayer then
			inst:DoTaskInTime(120,function()
				inst.shouldgoaway = true
			end)
		end
    end
end
local function dodespawn(inst)
	inst.shouldgoaway = true
end
local function Do_Ht_Attack(inst)
	inst.components.combat:RestartCooldown()
	local owner = inst.owner
	if owner and owner:IsValid() then
		local x,y,z = owner.Transform:GetWorldPosition()
		local targets =  XD_GetDamageTargets(x, y, z,8,inst.not_aoetags)
		local num = 0
		for i,target in ipairs(targets) do
			if XD_CanAttackTrget(owner,target) then
				SpawnAt("ttk_boss_sudaji_hitfx",target)
                local damage = inst.skill1_damage or 360
                damage = Xd_CalcDamage(owner,damage,target,nil,1)
                target.components.combat:GetAttacked(owner,damage)
				num = num + 1
				if num >= 6 then
					break
				end
			end
		end
	end
end
local function Do_Gd_Attack(inst,target)
	if target and target:IsValid() then
        local r = 2
        local pos = target:GetPosition()
        local rd = math.random(360)*DEGREES
        for k = 1,4 do
			local xx = rd
			inst:DoTaskInTime(k%2 == 0 and 0 or 1.2,function()
            	local striker = SpawnPrefab("ttk_boss_gongdeshadow")
            	if striker then
                	local targetpos = Vector3(pos.x+ r*math.cos(xx),0,pos.z+r*math.sin(xx))
					SpawnAt("ttk_boss_bianhua_fx",targetpos)
					striker.attack_count = 3
					striker.AnimState:OverrideSymbol("swap_object","xd_ht_weapon", "swap")
                	striker.Transform:SetPosition(targetpos:Get())
					striker:CopyFromPlayer(inst,target,targetpos)
					striker.attacker = inst.owner
					striker.sg:GoToState("ttk_boss_gongde_lunge_start",pos)
            	end
			end)
			rd = rd + 90
        end
	end
end
local function doattack(inst,damage,range,aoepos,fn)
    if inst and inst:IsValid() and inst.owner and inst.owner:IsValid() then
        local x,y,z = inst.Transform:GetWorldPosition()
        if aoepos then
            x,y,z = aoepos:Get()
        end
        local ents = XD_GetDamageTargets(x, 0, z,range or 3,inst.not_aoetags)
        for i,v in pairs(ents) do
            if v and v:IsValid() and v ~= inst.owner and XD_CanAttackTrget(inst.owner,v)
                and (not fn or fn(inst,v,inst)) then
                local damage = damage or 10
                damage = Xd_CalcDamage(inst.owner,damage,v,nil,1)
                v.components.combat:GetAttacked(inst.owner,damage)
            end
        end
    end
end
local function DoSkill2Cast(inst,pos)
	if pos then
		local fx = SpawnAt("ttk_boss_ht_swordfx",pos)
		fx.owner = inst
	end
end
local TILE_SIZE = 4
local DIAG_TILE_SIZE = math.sqrt(2 * TILE_SIZE * TILE_SIZE)
local function SnapTo45s(angle)
	return math.floor(angle / 45 + 0.5) * 45
end
local function DoFissuresLocal(inst, offset, attempt)
	offset = offset or 1
	attempt = attempt or 0
	if attempt > 2 then
		return {}
	end
	local map = TheWorld.Map
	local x, _, z = inst.Transform:GetWorldPosition()
	local tx0, ty0 = map:GetTileCoordsAtPoint(x, 0, z)
	if tx0 == nil or ty0 == nil then
		return {}
	end
	local tospawn = {}
	local numtospawn = 0
	local numvalidrows = 0
	local max_rows = 8
	local max_tiles = 64
	local rot = SnapTo45s(inst.Transform:GetRotation())
	local theta = rot * DEGREES
	if bit.band(math.floor(rot / 45 + 0.5), 1) == 0 then
		local dx = TILE_SIZE * math.cos(theta)
		local dz = -TILE_SIZE * math.sin(theta)
		x = x + offset * dx
		z = z + offset * dz
		local w = 1
		while true do
			local x1, z1 = x, z
			x = x + w * dz
			z = z - w * dx
			local inarena = false
			for i = -w, w do
				local tx, ty = map:GetTileCoordsAtPoint(x, 0, z)
				if tx and ty then
					local id = WagBossUtil.TileCoordsToId(tx, ty)
					tospawn[id] = true
					numtospawn = numtospawn + 1
					inarena = true
					if numtospawn >= max_tiles then break end
				end
				x = x - dz
				z = z + dx
			end
			if not inarena then
				break
			end
			numvalidrows = numvalidrows + 1
			if numvalidrows >= max_rows or numtospawn >= max_tiles then
				break
			end
			w = w == 1 and 3 or w + 1
			x = x1 + dx
			z = z1 + dz
		end
	else
		local dx = DIAG_TILE_SIZE * math.cos(theta)
		local dz = -DIAG_TILE_SIZE * math.sin(theta)
		x = x + dx * offset / 2
		z = z + dz * offset / 2
		local w = bit.band(offset, 1) == 0 and 1 or 0.5
		while true do
			local x1, z1 = x, z
			x = x + w * dz
			z = z - w * dx
			local inarena = false
			for i = -w, w do
				local tx, ty = map:GetTileCoordsAtPoint(x, 0, z)
				if tx and ty then
					local id = WagBossUtil.TileCoordsToId(tx, ty)
					tospawn[id] = true
					numtospawn = numtospawn + 1
					inarena = true
					if numtospawn >= max_tiles then break end
				end
				x = x - dz
				z = z + dx
			end
			if not inarena then
				break
			end
			numvalidrows = numvalidrows + 1
			if numvalidrows >= max_rows or numtospawn >= max_tiles then
				break
			end
			w = w == 0.5 and 2 or w + 0.5
			x = x1 + dx / 2
			z = z1 + dz / 2
		end
	end
	if (numvalidrows < 2 or (numvalidrows < 3 and numtospawn < numvalidrows)) and offset >= 0 then
		for k in pairs(tospawn) do tospawn[k] = nil end
		return DoFissuresLocal(inst, offset - 1, attempt + 1)
	end
	local fissures = {}
	for id in pairs(tospawn) do
		local tx, ty = WagBossUtil.IdToTileCoords(id)
		local fx, _, fz = map:GetTileCenterPoint(tx, ty)
		tospawn[id] = nil
		if fx and fz then
			local fissure = SpawnPrefab("ttk_boss_ht_fissure_custom")
			if fissure then
				fissure.Transform:SetPosition(fx, 0, fz)
				if fissure.StartTrackingBoss then
					fissure:StartTrackingBoss(inst,id)
				else
					fissure.owner = inst
				end
				table.insert(fissures, fissure)
			end
		end
	end
	return fissures
end
local function DoSkill3Cast(inst)
	local pos = inst:GetPosition()
	for i = 1, 2 do
		inst:DoTaskInTime((i - 1) * 0.2, function()
			local fx = SpawnPrefab("alterguardian_phase4_lunarrift_slam_fx")
			if fx then
				fx.Transform:SetPosition(pos.x, pos.y, pos.z)
			end
		end)
	end
	local count = 8
	local radius = 2
	for i = 1, count do
		local ang = (i - 1) * (2 * PI / count)
		inst:DoTaskInTime(0.1 + (i - 1) * 0.05, function()
			local ex = pos.x + radius * math.cos(ang)
			local ez = pos.z + radius * math.sin(ang)
			local ef = SpawnPrefab("alterguardian_phase4_lunarrift_erupt_fx")
			if ef then
				ef.Transform:SetPosition(ex, pos.y, ez)
			end
		end)
	end
	if DoFissuresLocal ~= nil then
		DoFissuresLocal(inst, 1)
	end
end
local function MakeNoPhysics(inst, mass, rad)
	mass = mass or 1
    rad = rad or .5
    local physics = inst.entity:AddPhysics()
	physics:SetMass(mass)
    physics:SetCapsule(0.5, 1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(5)
    inst.Physics:ClearCollisionMask()
	inst.Physics:SetCollisionMask(COLLISION.GROUND)
end
local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.entity:AddDynamicShadow()
    inst:SetPhysicsRadiusOverride(.5)
	MakeNoPhysics(inst, 1, 0.5)
    inst.DynamicShadow:SetSize(1.3, .6)
    inst:AddTag("scarytoprey")
    inst:AddTag("character")
    inst:AddTag("companion")
	inst:AddTag("notraptrigger")
    inst:AddTag("ttk_boss_skill_pet")
    inst:AddTag("no_drop_xdlingshi")
    inst:AddTag("notarget")
    inst:AddTag("NOBLOCK")
    inst.Transform:SetFourFaced()
    inst.AnimState:SetBank(Boss.Art("wilson"))
    inst.AnimState:SetBuild(Boss.Art("xd_ht"))
    inst.AnimState:PlayAnimation("idle_loop")
    inst.AnimState:OverrideSymbol("fx_wipe", "wilson_fx", "fx_wipe")
    inst.AnimState:AddOverrideBuild(Boss.Art("waxwell_minion_spawn"))
    inst.AnimState:AddOverrideBuild(Boss.Art("waxwell_minion_appear"))
    inst.AnimState:AddOverrideBuild(Boss.Art("lavaarena_shadow_lunge"))
    inst.AnimState:AddOverrideBuild(Boss.Art("player_lunge"))
    inst.AnimState:AddOverrideBuild(Boss.Art("player_attack_leap"))
    inst.AnimState:AddOverrideBuild(Boss.Art("player_superjump"))
	inst.AnimState:SetSymbolExchange( "hairfront", "swap_hat" )
    inst.AnimState:Hide("HAT")
    inst.AnimState:Hide("HAIR_HAT")
    inst.AnimState:OverrideSymbol("swap_object","xd_ht_weapon", "swap")
    inst.AnimState:Hide("ARM_normal")
    inst.AnimState:OverrideSymbol("xd_atkfx","xd_sudaji_attackfx", "atk")
    inst.AnimState:OverrideSymbol("fx1","xdswhs_tiaopi_fx", "fx1")
    inst.AnimState:OverrideSymbol("fx2","xdswhs_tiaopi_fx", "fx2")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
	spawncloud(inst)
	inst.MIN_FOLLOW_LEADER = 0
	inst.TARGET_FOLLOW_LEADER = 4
	inst.MAX_FOLLOW_LEADER = 6
	inst.noattack =  true
	inst.faceentity = true
	inst.level =  1
	inst:AddComponent("locomotor")
	inst.components.locomotor.walkspeed = 8
	inst.components.locomotor.runspeed = 8
    inst.components.locomotor.pathcaps = { allowocean = true, ignorecreep = true }
    inst.components.locomotor:SetTriggersCreep(false)
	local old_GetRunSpeed = inst.components.locomotor.GetRunSpeed
	inst.components.locomotor.GetRunSpeed = function(self, ...)
		if inst.owner and inst.owner:IsValid() and inst.owner.components.locomotor then
			return math.max(8,inst.owner.components.locomotor:GetRunSpeed())
		end
		return old_GetRunSpeed(self, ...)
	end
	inst:SetStateGraph("SGttk_boss_swhs")
	inst:SetBrain(brain)
	inst:AddComponent("health")
    inst.components.health:SetMaxHealth(100)
    inst.components.health.minhealth = 1
    inst.components.health:SetInvincible(true)
	inst.attackdamage = 390
	inst:AddComponent("combat")
	inst.components.combat:SetDefaultDamage(360)
	inst.components.combat:SetRange(4, 4)
	inst.components.combat:SetAttackPeriod(3)
	inst.components.combat:SetKeepTargetFunction(KeepTarget)
	inst:AddComponent("lootdropper")
	inst:AddComponent("inspectable")
    inst:AddComponent("timer")
	inst:AddComponent("colourtweener")
	inst:AddComponent("knownlocations")
	inst:AddComponent("follower")
    inst.components.follower:KeepLeaderOnAttacked()
    inst.components.follower.keepdeadleader = true
    inst.components.follower.keepleaderduringminigame = true
	inst:AddComponent("updatelooper")
	inst.persists = false
	inst:ListenForEvent("attacked", OnAttacked)
	inst:ListenForEvent("death", ondeath)
	inst.ttk_boss_zhaohui = ttk_boss_zhaohui
	inst.OnSpawnedBy = OnSpawnedBy
	inst.Do_Ht_Attack =  Do_Ht_Attack
	inst.Do_Gd_Attack =  Do_Gd_Attack
	inst.DoSkill2Cast = DoSkill2Cast
	inst.DoSkill3Cast = DoSkill3Cast
	inst.dodespawn = dodespawn
	return inst
end
local function Root()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddNetwork()
	inst.persists = false
	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	inst:AddTag("NOBLOCK")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
	return inst
end
local function SingleCloud()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	inst.AnimState:SetBank(Boss.Art("xd_ht_cloudfx"))
	inst.AnimState:SetBuild(Boss.Art("xd_ht_cloudfx"))
	inst.AnimState:PlayAnimation("anim_loop", true)
	inst.AnimState:SetTime(math.random())
	inst.AnimState:SetFinalOffset(-1)
	inst.persists = false
	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	inst:AddTag("NOBLOCK")
	inst.entity:SetPristine()
	if not TheWorld.ismastersim then
		return inst
	end
	return inst
end
local function cloud_update(inst)
	local base = math.sin((GetTime()+inst.timeoffset)*inst.scalespeed)
	local scale = inst.scale + inst.scale_v*base
	scale = scale * inst.scale_mult
	inst.Transform:SetScale(scale, scale, scale)
end
local function cloud_config(inst, data)
	inst.scale = data.scale or 1
	inst.scale_v = data.scale_v or 0.3
	inst.scalespeed = data.scalespeed or 1
	inst.scalespeed_v = data.scalespeed_v or 0.2
	inst.animspeed = data.animspeed or 1
	inst.animspeed_v = data.animspeed_v or 0
	inst.radius = data.radius or 0.6
	inst.build = "xd_ht_cloudfx"
	if  data.owner ~= nil then
		inst.owner = data.owner
	end
	inst.base_alpha = data.base_alpha or 1
end
local function applyconfig(inst, other)
	other.scale = inst.scale
	other.scale_v = inst.scale_v
	other.scale_mult = 1
	other.scalespeed = GetRandomWithVariance(inst.scalespeed, inst.scalespeed_v)
	other.timeoffset = 2*PI*math.random()/other.scalespeed
	other.AnimState:SetDeltaTimeMultiplier(GetRandomWithVariance(inst.animspeed, inst.animspeed_v))
	other.base_alpha = inst.base_alpha
	local a = other.base_alpha
	other.AnimState:SetMultColour(a,a,a,a)
end
local function cloud_init(inst)
	for i = 1,7 do
		local r = i == 7 and 0 or inst.radius
		local a = i* PI/3
		local offset = Vector3(math.cos(a)*r, 0, math.sin(a)*r)
		local fx = SpawnPrefab("ttk_boss_ht_single_cloud")
		inst:applyconfig(fx)
		inst:AddChild(fx)
		inst.fx[fx] = true
		fx.Transform:SetPosition(offset:Get())
		fx:DoPeriodicTask(0, cloud_update)
	end
end
local function Despawn(inst, time)
	time = time or 1
	local progress = 1
	inst:DoPeriodicTask(0, function()
		for k in pairs(inst.fx)do
			if k:IsValid() then
				k.scale_mult = progress
				local a = progress * inst.base_alpha
				k.AnimState:SetMultColour(a, a, a, a)
			end
		end
		progress = progress - FRAMES/time
		if progress < 0 then
			inst:Remove()
		end
	end)
end
local function CloudFx()
	local inst = Root()
	local s = 0.7
	inst.Transform:SetScale(s,s,s)
	inst.fx = {}
	inst.config = cloud_config
	inst.applyconfig = applyconfig
	inst.init = cloud_init
	inst.Despawn = Despawn
	return inst
end
local function swordfn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	inst.AnimState:SetBank(Boss.Art("xd_sword_green_skillfx"))
	inst.AnimState:SetBuild(Boss.Art("xd_ht_swordskill"))
	inst.AnimState:PlayAnimation("meteor_pre")
	local s  = 1.257
	inst.AnimState:SetScale(s, s, s)
	inst:AddTag("fx")
	inst.entity:SetPristine()
	if not TheWorld.ismastersim then
		return inst
	end
	inst.persists = false
    inst:AddComponent("colourtweener")
	inst:DoTaskInTime(1,function()
		inst.SoundEmitter:PlaySound("xd_pog_sound/xd_pog_sound/green_skill2",nil,0.75)
	end)
	inst:DoTaskInTime(1.3,function()
        inst.groundfx = SpawnAt("ttk_boss_ht_groundfx",inst)
        inst.groundfx.components.colourtweener:StartTween({1, 1, 1, 1}, 0.5, function() end)
        inst.damagetask = inst:DoPeriodicTask(0.5,function()
			local damage = inst.owner and  inst.owner.skill2_damage or 240
            doattack(inst.owner,damage,5,inst:GetPosition())
        end,0.5)
	end)
	inst:DoTaskInTime(1.3 + 4 + 0.1,function()
        if inst.damagetask then
            inst.damagetask:Cancel()
        end
        inst.components.colourtweener:StartTween({1, 1, 1, 0}, 0.5, function()
            inst:Remove()
        end)
        if inst.groundfx and inst.groundfx:IsValid() then
            inst.groundfx.components.colourtweener:StartTween({1, 1, 1, 0}, 0.5, function()
                inst.groundfx:Remove()
            end)
        end
	end)
	inst:DoTaskInTime(10, inst.Remove)
	return inst
end
local function custom_fissure_fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	inst.entity:SetCanSleep(false)
	inst.AnimState:SetBank(Boss.Art("wagboss_fissure"))
	inst.AnimState:SetBuild(Boss.Art("wagboss_fissure"))
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(2)
	inst.entity:SetPristine()
	if not TheWorld.ismastersim then
		return inst
	end
	inst.persists = false
	inst:AddComponent("updatelooper")
	inst:AddComponent("colourtweener")
	inst.variation = math.random(4)
	inst.StartTrackingBoss = function(inst, boss, id)
		inst.owner = boss
		inst.AnimState:PlayAnimation("tile" .. tostring(inst.variation) .. "_pre")
		inst.AnimState:PushAnimation("tile" .. tostring(inst.variation) .. "_loop", true)
		inst:DoTaskInTime(16*FRAMES,function()
			inst.damagetask = inst:DoPeriodicTask(1, function()
				if inst and inst:IsValid() and inst.owner then
					local pos = inst:GetPosition()
					local damage = inst.owner and inst.owner.skill3_damage or 1210
					doattack(inst.owner, damage, 4, pos,function(_inst,v)
						local owner = inst.owner.owner or inst.owner or inst
						local key = (owner.userid or owner.prefab) .. "_xd_ht_fissure_damage"
						if not v[key] or v[key] + 1 < GetTime() then
							v[key] = GetTime()
							return true
						end
					end)
				end
			end)
		end)
	end
	inst.StartTrackingFx = function(inst, time)
		inst.AnimState:PlayAnimation("tile" .. tostring(inst.variation) .. "_pre")
		inst.AnimState:PushAnimation("tile" .. tostring(inst.variation) .. "_loop", true)
		inst:DoTaskInTime(time,function()
			local anim = "tile" .. tostring(inst.variation or 1)
			inst.AnimState:PlayAnimation(anim .. "_pst")
			inst:ListenForEvent("animover", function() inst:Remove() end)
		end)
	end
	inst:DoTaskInTime(10+17*FRAMES,function()
		if inst.damagetask then
			inst.damagetask:Cancel()
			inst.damagetask = nil
		end
		local anim = "tile" .. tostring(inst.variation or 1)
		inst.AnimState:PlayAnimation(anim .. "_pst")
		inst:ListenForEvent("animover", function() inst:Remove() end)
	end)
	return inst
end
local function groundfn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	inst.AnimState:SetBank(Boss.Art("xd_ht_circle"))
	inst.AnimState:SetBuild(Boss.Art("xd_ht_circle"))
	inst.AnimState:PlayAnimation("idle",true)
	local s  = 6
	inst.AnimState:SetScale(s, s, s)
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetMultColour(1, 1, 1, 0)
	inst:AddTag("fx")
	inst.entity:SetPristine()
	if not TheWorld.ismastersim then
		return inst
	end
	inst.persists = false
    inst:AddComponent("colourtweener")
	inst.remove_ysak = inst:DoTaskInTime(10, inst.Remove)
	inst.Set_RemoveTime = function(inst, time)
		if inst.remove_ysak then
			inst.remove_ysak:Cancel()
		end
		inst.components.colourtweener:StartTween({1, 1, 1, 1}, 0.5, function() end)
		inst.remove_ysak = inst:DoTaskInTime(time, function()
	        inst.components.colourtweener:StartTween({1, 1, 1, 0}, 0.5, function()
                inst:Remove()
            end)
		end)
	end
	return inst
end
return Prefab("ttk_boss_ht", fn, assets, prefabs),
	Prefab("ttk_boss_ht_flyerfx_cloud", CloudFx, assets),
	Prefab("ttk_boss_ht_single_cloud", SingleCloud, assets),
	Prefab("ttk_boss_ht_swordfx", swordfn),
	Prefab("ttk_boss_ht_groundfx", groundfn),
	Prefab("ttk_boss_ht_fissure_custom", custom_fissure_fn)
