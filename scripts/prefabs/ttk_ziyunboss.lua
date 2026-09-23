-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local Prefab = Boss.Prefab
local XD_CanAttackTrget = Boss.XD_CanAttackTrget
local XD_GetDamageTargets = Boss.XD_GetDamageTargets
local XD_RANDOM_ANGLES = Boss.XD_RANDOM_ANGLES
local XD_RECORDCOMBAT = Boss.XD_RECORDCOMBAT
local Xd_CalcDamage = Boss.Xd_CalcDamage
local assets =
{
    Asset("ANIM", Boss.ArtPath("anim/xd_ziyunboss.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_ziyunboss_cloud.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_ziyunboss_weapon.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_ziyun_house.zip")),
	Asset("ANIM", Boss.ArtPath("anim/shadow_channeler.zip")),
}
local prefabs = {
	"ttk_zcmj_blueprint",
	"ttk_boss_stalker_ziyun",
	"ttk_boss_deerclops_ziyun_aux",
}
SetSharedLootTable( 'ttk_ziyunboss',
{
    {"shadowheart",  1.00},
    {'purplegem',  1.00},
	{'purplegem',  1.00},
	{'purplegem',  1.00},
    {'yellowgem',  1.00},
	{'yellowgem',  1.00},
	{'yellowgem',  1.00},
	{'yellowgem',  1.00},
    {'orangegem',  1.00},
	{'orangegem',  1.00},
	{'orangegem',  1.00},
	{'orangegem',  1.00},
	{'greengem',  1.00},
	{'greengem',  1.00},
	{'greengem',  1.00},
    {'ttk_boss_zcmy',  1.0},
})
local brain = require "brains/ttk_boss_ziyunbossbrain"
local KEEP_TARGET_DIST = 40
local SKILL_TARGET_DIST = 20
local function UpdatePlayerTargets(inst)
	local toadd = {}
	local toremove = {}
	local x, y, z = inst.Transform:GetWorldPosition()
	for k in pairs(inst.components.grouptargeter:GetTargets()) do
		toremove[k] = true
	end
	for i, v in ipairs(FindPlayersInRange(x, y, z, 30, true)) do
		if toremove[v] then
			toremove[v] = nil
		else
			table.insert(toadd, v)
		end
	end
	for k in pairs(toremove) do
		inst.components.grouptargeter:RemoveTarget(k)
	end
	for i, v in ipairs(toadd) do
		inst.components.grouptargeter:AddTarget(v)
	end
end
local function Retarget(inst)
	UpdatePlayerTargets(inst)
	local target = inst.components.combat.target
	local inrange = target ~= nil and inst:IsNear(target, 12 + target:GetPhysicsRadius(0))
	if target ~= nil and target:HasTag("player") then
		local newplayer = inst.components.grouptargeter:TryGetNewTarget()
		return newplayer ~= nil
			and newplayer:IsNear(inst, inrange and 12 + newplayer:GetPhysicsRadius(0) or 12)
			and newplayer
			or nil,
			true
	end
	local nearplayers = {}
	for k in pairs(inst.components.grouptargeter:GetTargets()) do
		if inst:IsNear(k, inrange and 6 + k:GetPhysicsRadius(0) or 12) then
			table.insert(nearplayers, k)
		end
	end
	return #nearplayers > 0 and nearplayers[math.random(#nearplayers)] or nil, true
end
local function ShouldKeepTarget(inst, target)
    return target and target:IsValid()
        and inst.components.combat:CanTarget(target)
        and inst:IsNear(target, KEEP_TARGET_DIST + target:GetPhysicsRadius(0))
end
local function OnAttacked(inst, data)
    if data and data.attacker ~= nil then
		local target = inst.components.combat.target
		if not (target ~= nil and
			target:HasTag("player") and
			target:IsNear(inst, 12 + target:GetPhysicsRadius(0))) then
			inst.components.combat:SetTarget(data.attacker)
		end
	end
end
local function settimeleft(inst,name,time)
	if not inst.components.timer:TimerExists(name) then
		inst.components.timer:StartTimer(name,time)
	else
		inst.components.timer:SetTimeLeft(name,time)
	end
end
local function doxinmoattack(inst,data,damage)
	if data and data.target and data.target:IsValid() then
		local r = 6
		local pos = data.target:GetPosition()
		local pt = inst:GetPosition()
		local dx = pos.x - pt.x
		local dz = pos.z - pt.z
		local theta = math.atan2(dz, dx)
		local rd = theta * (180 / PI) - 90
		for k = 1,3 do
			local striker = SpawnPrefab("ttk_boss_ziyunboss_shadower")
			if striker then
				local targetpos = Vector3(pos.x+ r*math.cos(rd*DEGREES),0,pos.z+r*math.sin(rd*DEGREES))
				striker.Transform:SetPosition(targetpos:Get())
				striker.owner = inst
				striker.damage = damage or 15
				striker:SetLunge()
				striker.sg:GoToState("lunge_pre", data ~= nil and data.target or nil)
				rd = rd + 90
			else
				striker:Remove()
			end
		end
	end
end
local function OnAttack(inst,data)
    inst.attack_count = math.min(3,inst.attack_count + 1)
	if inst.attack_count == 3 then
		inst.attack_round =  math.min(3,inst.attack_round + 1)
		if inst.mode == 1 then
			doxinmoattack(inst,data)
		elseif inst.mode == 3 then
			if inst.attack_round == 1 then
				doxinmoattack(inst,data)
			elseif  inst.attack_round ==2 then
				if inst.sword and inst.sword:IsValid() then
					if data and data.target and data.target:IsValid() then
						inst.sword:PushEvent("attack",data.target)
					end
				end
			else
				if inst.sword and inst.sword:IsValid() then
					if data and data.target and data.target:IsValid() then
						inst.sword:PushEvent("spell2",data.target)
					end
				end
			end
		end
		if inst.attack_round >= 3 then
			inst.attack_round = 0
		end
		inst.attack_count = 0
		settimeleft(inst,"attack_cd",1.5)
	end
end
local function OnHitOther(inst,data)
	inst.lastattacktime = GetTime()
end
local function vortex_spawner(inst,data,skin)
    if inst._xd_weapon_fx == nil then
        inst._xd_weapon_fx = SpawnPrefab("ttk_boss_vortex_spawner")
        inst._xd_weapon_fx.entity:AddFollower()
    end
    inst._xd_weapon_fx.entity:SetParent(inst.entity)
    inst._xd_weapon_fx.Follower:FollowSymbol(inst.GUID, "swap_object", 40, -30, 0)
    inst._xd_weapon_fx.colour = skin
end
local TRAIL_FLAGS = { "shadowtrail" }
local function cane_do_trail(inst)
    local owner = inst
    if not owner.entity:IsVisible() then
        return
    end
    local x, y, z = owner.Transform:GetWorldPosition()
    if owner.sg ~= nil and owner.sg:HasStateTag("moving") then
        local theta = -owner.Transform:GetRotation() * DEGREES
        local speed = owner.components.locomotor:GetRunSpeed() * .1
        x = x + speed * math.cos(theta)
        z = z + speed * math.sin(theta)
    end
    local mounted = false
    local map = TheWorld.Map
    local offset = FindValidPositionByFan(
        math.random() * TWOPI,
        (mounted and 1 or .5) + math.random() * .5,
        4,
        function(offset)
            local pt = Vector3(x + offset.x, 0, z + offset.z)
            return map:IsPassableAtPoint(pt:Get())
                and not map:IsPointNearHole(pt)
                and #TheSim:FindEntities(pt.x, 0, pt.z, .7, TRAIL_FLAGS) <= 0
        end
    )
    if offset ~= nil then
        SpawnPrefab("cane_ancient_fx").Transform:SetPosition(x + offset.x, 0, z + offset.z)
    end
end
local function StopTalkSound(inst, instant)
    if not instant and inst.endtalksound ~= nil and inst.SoundEmitter:PlayingSound("talk") then
        inst.SoundEmitter:PlaySound(inst.endtalksound)
    end
    inst.SoundEmitter:KillSound("talk")
end
local function DoTalkSound(inst)
	StopTalkSound(inst)
    if inst.talksoundoverride ~= nil then
        inst.SoundEmitter:PlaySound(inst.talksoundoverride, "talk")
        return true
    elseif not inst:HasTag("mime") then
        inst.SoundEmitter:PlaySound((inst.talker_path_override or "dontstarve/characters/")..(inst.soundsname or inst.prefab).."/talk_LP","talk")
        return true
    end
end
local function DoTalk(inst,str)
	inst.components.talker:Say(str,nil,true,true)
	DoTalkSound(inst)
	if inst.talk_task then
		inst.talk_task:Cancel()
	end
	inst.talk_task =  inst:DoTaskInTime(2,function()
		inst.talk_task = nil
		StopTalkSound(inst)
	end)
end
local function ChangeMode(inst,mode)
    local old = inst.mode
    if mode then
        inst.mode = mode
    else
        inst.mode = inst.mode + 1
    end
    if inst.mode ~= old then
		inst.attack_count = 0
		inst.attack_round = 0
        if inst.mode == 1 then
			inst.components.health.nofadeout = true
			if inst._xd_weapon_fx then
				inst._xd_weapon_fx:Remove()
				inst._xd_weapon_fx = nil
			end
			if inst._trailtask ~= nil then
				inst._trailtask:Cancel()
				inst._trailtask = nil
			end
            inst._isflying:set(false)
            inst:RemoveTag("notarget")
            inst.components.health:SetInvincible(false)
        elseif inst.mode == 2 then
			inst.components.health.nofadeout = true
			DoTalk(inst,STRINGS.NAMES.XD_ZIYUNBOSS_TALKS[1])
			if inst._xd_weapon_fx then
				inst._xd_weapon_fx:Remove()
				inst._xd_weapon_fx = nil
			end
			if inst._trailtask ~= nil then
				inst._trailtask:Cancel()
				inst._trailtask = nil
			end
            inst._isflying:set(true)
            inst:AddTag("notarget")
            inst.components.health:SetInvincible(true)
        elseif inst.mode == 3 then
			inst.components.health.nofadeout = false
			DoTalk(inst,STRINGS.NAMES.XD_ZIYUNBOSS_TALKS[2])
			settimeleft(inst,"liedui",5)
            inst._isflying:set(false)
            inst:AddTag("notarget")
            inst.components.health:SetInvincible(true)
			vortex_spawner(inst,{},{204/255, 133/255, 255/255, 1})
			if inst._trailtask == nil then
				inst._trailtask = inst:DoPeriodicTask(6 * FRAMES, cane_do_trail, 2 * FRAMES)
			end
        end
    end
    inst:PushEvent("mode_change",{new = inst.mode ,old = old})
end
local function onfly(inst)
    local fly = inst._isflying:value()
    if fly then
        if not inst.flyfx then
            inst.flyfx = SpawnPrefab('ttk_boss_ziyunboss_flyerfx_cloud')
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
local function OnLieDui(inst,data)
	local target = data and data.target
	if target and target:IsValid() and inst:IsNear(target,SKILL_TARGET_DIST) and XD_CanAttackTrget(inst,target) then
		settimeleft(inst,"liedui",20)
		local rots = XD_RANDOM_ANGLES(2,60)
		for _,v in ipairs(rots) do
			local pos = target:GetPosition()
			local radius = 14
			local rot = v
			local offset = Vector3(pos.x+radius * math.cos(rot), 0, pos.z-radius * math.sin(rot))
			local fx = SpawnAt("ttk_boss_ziyunboss_shadowent",offset)
			fx:FacePoint(pos)
			for _,v in ipairs({1,3,5,7,9,11,-1,-3,-5,-7,-9,-11}) do
				local x1,y1,z1 = fx.entity:LocalToWorldSpace(0, 0, v)
				y1 = 0
				local shaodw = SpawnAt("ttk_boss_ziyunboss_shadower",Vector3(x1,y1,z1))
				shaodw:SetCanMove(inst,fx.Transform:GetRotation())
			end
		end
	end
end
local attacktag = {"_combat","_health"}
local noltags =  {"ttk_boss_ziyun","notarget", "noattack", "flight", "invisible", "playerghost"}
local function DoAoeAttck(inst,pt,range,damage,targets,knocker)
	inst.components.combat.ignorehitrange = true
	local dist = math.sqrt(inst:GetDistanceSqToPoint(pt))
	local ents =  TheSim:FindEntities(pt.x, 0, pt.z, range or 4, attacktag,noltags)
	for i, v in ipairs(ents) do
		if (not targets or not targets[v]) and v:IsValid() and not v:IsInLimbo() and not (v.components.health ~= nil and v.components.health:IsDead()) and XD_CanAttackTrget(inst,v) then
			if targets then
				targets[v] = true
			end
            local damage = damage or inst.components.combat.defaultdamage
            damage = Xd_CalcDamage(inst,damage,v)
			v.components.combat:GetAttacked(inst,damage)
			if knocker then
				v:PushEvent("knockback", { knocker = knocker, radius = 2})
			end
		end
	end
	inst.components.combat.ignorehitrange = false
end
local DEFAULT_TALKER_OFFSET = Vector3(0, -400, 0)
local function GetTalkerOffset(inst)
    return DEFAULT_TALKER_OFFSET
end
local function zhansha(inst)
	if inst.sword and inst.sword:IsValid() and inst:IsValid() and not inst.components.health:IsDead() and not inst.components.timer:TimerExists("zhansha") then
		for i, v in ipairs(AllPlayers) do
			if v:IsValid() and inst:IsNear(v,20) and XD_CanAttackTrget(inst,v) and
				v.components.health and not v.components.health.ttk_boss_miansi_health then
				if v.components.health:GetPercent() < (inst.prefab == "ttk_boss_sudaji" and 0.05 or  0.05) then
					inst.sword:PushEvent("zhansha",v)
					settimeleft(inst,"zhansha",20)
					break
				end
			end
		end
	end
end
local function SetFxOwner(inst, owner)
    if owner ~= nil then
        inst.blade1.entity:SetParent(owner.entity)
        inst.blade2.entity:SetParent(owner.entity)
        inst.blade1.Follower:FollowSymbol(owner.GUID, "swap_fb_object", nil, nil, nil, true, nil, 0, 3)
        inst.blade2.Follower:FollowSymbol(owner.GUID, "swap_fb_object", nil, nil, nil, true, nil, 5, 8)
        inst.blade1.components.highlightchild:SetOwner(owner)
        inst.blade2.components.highlightchild:SetOwner(owner)
    else
        inst.blade1.entity:SetParent(inst.entity)
        inst.blade2.entity:SetParent(inst.entity)
        inst.blade1.Follower:FollowSymbol(inst.GUID, "swap_spear", nil, nil, nil, true, nil, 0, 3)
        inst.blade2.Follower:FollowSymbol(inst.GUID, "swap_spear", nil, nil, nil, true, nil, 5, 8)
        inst.blade1.components.highlightchild:SetOwner(inst)
        inst.blade2.components.highlightchild:SetOwner(inst)
    end
end
local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst:SetPhysicsRadiusOverride(.5)
    MakeGhostPhysics(inst, 1, inst.physicsradiusoverride)
    inst:AddTag("scarytoprey")
    inst:AddTag("character")
    inst:AddTag("hostile")
	inst:AddTag("notraptrigger")
    inst:AddTag("ttk_boss_ziyun")
	inst:AddTag("epic")
	inst:AddTag("ignore_xd_time_st")
	inst:AddTag("ttk_boss_zhenxian")
    inst.Transform:SetFourFaced()
    inst.AnimState:SetBank(Boss.Art("wilson"))
    inst.AnimState:SetBuild(Boss.Art("xd_ziyunboss"))
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
    inst.AnimState:OverrideSymbol("swap_object","xd_ziyunboss_weapon", "swap")
    inst.AnimState:Hide("ARM_normal")
    inst._isflying = net_bool(inst.GUID, "ttk_ziyunboss._isflying", "isflying")
    if not TheNet:IsDedicated() then
        inst:ListenForEvent("isflying",onfly)
    end
	inst:AddComponent("talker")
    inst.components.talker:SetOffsetFn(GetTalkerOffset)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
	inst.soundsname = "wortox"
	inst:DoStaticPeriodicTask(1,zhansha,1)
	inst:DoTaskInTime(0,function()
        if inst._vfx_fx_inst == nil then
            inst._vfx_fx_inst = SpawnPrefab("ttk_boss_xjs_curve_fx")
            inst._vfx_fx_inst.entity:AddFollower()
        end
        inst._vfx_fx_inst.entity:SetParent(inst.entity)
        inst._vfx_fx_inst.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -100, 0)
    end)
	local frame = 0
    inst.AnimState:SetFrame(frame)
    inst.blade1 = SpawnPrefab("ttk_boss_ftj_fx")
    inst.blade2 = SpawnPrefab("ttk_boss_ftj_fx")
    inst.blade1.AnimState:SetFrame(frame)
    inst.blade2.AnimState:SetFrame(frame)
	SetFxOwner(inst)
    inst.attack_count = 0
	inst.attack_round = 0
    inst.mode = 1
    inst.ChangeMode = ChangeMode
    inst:AddComponent("grouptargeter")
    inst:AddComponent("bloomer")
    inst:AddComponent("colouradder")
    inst:AddComponent("debuffable")
    inst.components.debuffable:SetFollowSymbol("headbase", 0, -200, 0)
    inst:AddComponent("locomotor")
    inst.components.locomotor.runspeed = 6
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = {  allowocean = true, ignorecreep = true }
    inst.components.locomotor:SetSlowMultiplier(.6)
    inst:AddComponent("leader")
    -- Sword/phase helpers are transient and rebuilt from saved encounter phase.
    inst.components.leader.OnSave = function() return {} end
    inst:AddComponent("knownlocations")
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(9750)
    inst.components.health.nofadeout = true
	-- Normal health persistence: registry encounters survive save/load.
    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(30)
    inst.components.combat:SetKeepTargetFunction(ShouldKeepTarget)
    inst.components.combat:SetAttackPeriod(TUNING.WILSON_ATTACK_PERIOD)
    inst.components.combat:SetRange(3.5)
    inst.components.combat.hiteffectsymbol = "torso"
    inst.components.combat:SetRetargetFunction(2, Retarget)
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('ttk_ziyunboss')
    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -2
    inst:AddComponent("inspectable")
	inst:AddComponent("teleportedoverride")
	inst.components.teleportedoverride:SetDestPositionFn(function(inst)
        local pos = inst.components.knownlocations:GetLocation("spawnpoint")
        if pos ~= nil then
            local offset = FindWalkableOffset(pos, TWOPI * math.random(), 4, 8, true, false)
            return offset ~= nil and pos + offset or pos
        end
    end)
    XD_RECORDCOMBAT(inst,20)
    inst:SetStateGraph("SGttk_ziyunboss")
    inst:SetBrain(brain)
    inst:AddComponent("colourtweener")
    inst:AddComponent("entitytracker")
    inst:AddComponent("timer")
	inst:ListenForEvent("liedui", OnLieDui)
    inst:ListenForEvent("onattackother", OnAttack)
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("onhitother", OnHitOther)
	inst:DoTaskInTime(0,function()
		if not inst.sword then
			local theta = math.random() * TWOPI
			local pt = inst:GetPosition()
			local radius = 2
			local offset = FindWalkableOffset(pt, theta, radius, 12)
			if offset ~= nil then
				pt.x = pt.x + offset.x
				pt.z = pt.z + offset.z
			end
			inst.sword = SpawnAt("ttk_boss_ziyunboss_sword",pt)
			inst.sword:Hide()
			inst.sword.owner =  inst
			inst.sword.SoundEmitter:PlaySound("dontstarve/common/spawn/spawnportal_spawnplayer", nil, 0.5)
            inst.sword:DoSpawn()
			inst.components.leader:AddFollower(inst.sword)
		end
	end)
	inst.DoAoeAttck = DoAoeAttck
	inst.DoTalk = DoTalk
	TUNING.XD_ZIYUNBOSS_COUNT  = TUNING.XD_ZIYUNBOSS_COUNT + 1
	inst:ListenForEvent("onremove",function()
		TUNING.XD_ZIYUNBOSS_COUNT  = TUNING.XD_ZIYUNBOSS_COUNT - 1
	end)
	inst:AddComponent("ttk_boss_guaiwu_skills")
	inst.components.ttk_boss_guaiwu_skills.first = false
	inst.components.ttk_boss_guaiwu_skills.noskill =  true
	inst.components.ttk_boss_guaiwu_skills.by = 6
	inst.components.ttk_boss_guaiwu_skills.qx = 4
    return inst
end
local function Root()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.persists = false
	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	inst:AddTag("NOBLOCK")
	return inst
end
local function SingleCloud()
	local inst = CreateEntity()
	inst.entity:AddTransform()
    inst.entity:AddAnimState()
	inst.AnimState:SetBank(Boss.Art("xd_ziyunboss_cloud"))
    inst.AnimState:SetBuild(Boss.Art("xd_ziyunboss_cloud"))
    inst.AnimState:PlayAnimation("anim_loop", true)
    inst.AnimState:SetTime(math.random())
	inst.AnimState:SetFinalOffset(-1)
	inst.persists = false
	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	inst:AddTag("NOBLOCK")
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
	inst.build = "xd_ziyunboss_cloud"
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
		local fx = SingleCloud()
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
local function OnDeath(inst)
	if inst.owner and inst.owner:IsValid() and  inst.owner.mode3_pet == inst and not inst.owner.components.health:IsDead() then
		inst.owner.mode3_pet = nil
		inst.owner.components.health:SetInvincible(false)
		inst.owner.components.health:Kill()
	end
	if not inst.killed then
		inst.AnimState:PlayAnimation("disappear")
		inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + FRAMES, inst.Remove)
	end
end
local function OnAppear(inst)
    inst:RemoveEventCallback("animover", OnAppear)
    if not inst.killed then
        inst:RemoveTag("notarget")
        inst.components.health:SetInvincible(false)
        inst.AnimState:PlayAnimation("idle", true)
    end
end
local function OnSpawnedBy(inst, stalker)
    if stalker then
        inst.owner = stalker
		stalker.mode3_pet = inst
		inst:ForceFacePoint(stalker.Transform:GetWorldPosition())
        inst:ListenForEvent("onremove", function()
            if inst and inst:IsValid() then
                inst:Remove()
            end
        end,stalker)
        inst:ListenForEvent("mode_change", function(_,data)
            if data and data.new ~= 3 and not inst.components.health:IsDead() then
                inst.components.health:Kill()
            end
        end,stalker)
    end
end
local function OnAttacked_Heart(inst, data)
    if data and data.attacker ~= nil and data.attacker:IsValid() and data.attacker:IsValid() then
		if not inst.lastattackedtime or (GetTime() - inst.lastattackedtime )  > 2.5 then
			inst.lastattackedtime =  GetTime()
			if inst.owner and inst.owner:IsValid() and inst.owner.components.combat and XD_CanAttackTrget(inst.owner,data.attacker) then
				if inst.owner.components.combat.target ~= data.attacker then
					inst.owner.components.combat:SetTarget(data.attacker)
				end
			end
		end
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
	inst:AddTag("hostile")
    inst:AddTag("scarytoprey")
	inst:AddTag("notarget")
    inst:AddTag("ttk_boss_ziyun")
	inst:AddTag("notraptrigger")
	inst:AddTag("epic")
	inst:AddTag("ttk_boss_zhenxian")
    inst.AnimState:SetBank(Boss.Art("shadow_channeler"))
    inst.AnimState:SetBuild(Boss.Art("shadow_channeler"))
    inst.AnimState:PlayAnimation("appear")
    inst.AnimState:SetMultColour(1, 1, 1, .5)
	local s  = 1.7
    inst.Transform:SetScale(s, s, s)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
	inst:AddComponent("inspectable")
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(9750)
	inst.components.health:SetInvincible(true)
    inst:AddComponent("combat")
    inst:AddComponent("savedrotation")
    inst:ListenForEvent("animover", OnAppear)
    inst:ListenForEvent("death", OnDeath)
	inst:ListenForEvent("attacked", OnAttacked_Heart)
    inst.OnSpawnedBy = OnSpawnedBy
	inst.persists = false
	inst:AddComponent("teleportedoverride")
	inst.components.teleportedoverride:SetDestPositionFn(function(inst)
        local pos = inst.components.knownlocations:GetLocation("spawnpoint")
        if pos ~= nil then
            local offset = FindWalkableOffset(pos, TWOPI * math.random(), 4, 8, true, false)
            return offset ~= nil and pos + offset or pos
        end
    end)
	inst:AddComponent("ttk_boss_guaiwu_skills")
	inst.components.ttk_boss_guaiwu_skills.first = false
	inst.components.ttk_boss_guaiwu_skills.noskill =  true
	inst.components.ttk_boss_guaiwu_skills.by = 6
	inst.components.ttk_boss_guaiwu_skills.qx = 4
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
local function lunge(inst,targets,damage,knock)
	inst.Physics:Stop()
	if inst.removetask  then
		inst.removetask:Cancel()
		inst.removetask = nil
	end
	if inst.soundtask  then
		inst.soundtask:Cancel()
		inst.soundtask = nil
	end
	if inst.checktask  then
		inst.checktask:Cancel()
		inst.checktask = nil
	end
	if inst.owner and inst.owner.isplayer then
		inst.components.skinner:CopySkinsFromPlayer(inst.owner)
	end
	inst.dolunge = true
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
			if inst.owner.DoAoeAttck then
				inst.owner:DoAoeAttck(pos,3,damage,inst.targets,knock and inst or nil)
			else
				local ents = XD_GetDamageTargets(pos.x,0,pos.z, 3)
				for i,v in pairs(ents) do
					if  v:IsValid() and  XD_CanAttackTrget(inst.owner,v) and  (not inst.targets or  not inst.targets[v]) then
						if inst.targets then
							inst.targets[v] = true
						end
						damage = Xd_CalcDamage(inst.owner,damage,v)
						v.components.combat:GetAttacked(inst.owner,damage)
					end
				end
			end
		end
	end)
end
local function playsound(inst,volume)
	PlayFootstep(inst, .6, true)
end
local function checkplayer(inst)
	if inst.doremove then
		return
	end
	local dist = 3
	local x, y, z = inst.Transform:GetWorldPosition()
	local rot0 = inst.Transform:GetRotation() * DEGREES
	x = x + dist * math.cos(rot0)
	z = z - dist * math.sin(rot0)
	for i, v in ipairs(TheSim:FindEntities(x, 0, z, 3, {"player"},  {"INLIMBO","playerghost","flight", "invisible", "notarget", "noattack"})) do
		if v and v:IsValid() and not (v.components.health ~= nil and v.components.health:IsDead())
			and XD_CanAttackTrget(inst.owner,v) and not v.ziyun_motitask  then
				inst.startpos = v:GetPosition()
				v.ziyun_motitask = v:DoTaskInTime(3,function()
					v.ziyun_motitask = nil
				end)
				lunge(inst,nil,175,true)
			return
		end
	end
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
	inst.AnimState:SetBuild(Boss.Art("xd_ziyunboss"))
	inst.AnimState:OverrideSymbol("fx_wipe", "wilson_fx", "fx_wipe")
	inst.AnimState:PlayAnimation("minion_spawn")
	inst.AnimState:SetMultColour(0, 0, 0, .5)
	inst.AnimState:UsePointFiltering(true)
	inst.AnimState:AddOverrideBuild(Boss.Art("waxwell_minion_spawn"))
	inst.AnimState:AddOverrideBuild(Boss.Art("waxwell_minion_appear"))
	inst.AnimState:AddOverrideBuild(Boss.Art("lavaarena_shadow_lunge"))
    inst.AnimState:OverrideSymbol("swap_object", "xd_ziyunboss_weapon","swap")
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
	inst.removetask = inst:DoTaskInTime(3, inst.Remove)
	inst.Lunge = lunge
    inst.targets = {}
	inst.SetCanMove = function(inst,owner,rot)
		inst.AnimState:PlayAnimation("appear")
		inst.owner = owner
		inst.Transform:SetRotation(rot)
		inst:DoTaskInTime(0.7,function()
			inst.AnimState:PlayAnimation("run_pre")
			inst.AnimState:PushAnimation("run_loop")
			if inst.removetask  then
				inst.removetask:Cancel()
			end
			inst.Physics:SetMotorVelOverride(6, 0, 0)
			inst.soundtask = inst:DoPeriodicTask(7 * FRAMES, playsound)
			inst.checktask = inst:DoPeriodicTask(1, checkplayer,0)
			inst.removetask = inst:DoTaskInTime(5.5, function()
				inst.Physics:Stop()
				inst.doremove = true
				if inst.soundtask  then
					inst.soundtask:Cancel()
					inst.soundtask = nil
				end
				inst.AnimState:PlayAnimation("disappear")
				inst:DoTaskInTime(1,inst.Remove)
			end)
		end)
	end
	inst.SetLunge = function(inst)
		if inst.removetask  then
			inst.removetask:Cancel()
		end
		inst:SetStateGraph("SGttk_boss_ziyunshadow")
	end
	return inst
end
local function entfn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddNetwork()
	inst:AddTag("CLASSIFIED")
	inst.persists = false
	if not TheWorld.ismastersim then
		return inst
	end
	inst:DoTaskInTime(0, inst.Remove)
	return inst
end
local function DoSpawn(inst)
	SpawnAt("ttk_boss_spawn_fx_medium_static",inst)
	inst:DoTaskInTime(0.2,function()
		inst:Show()
	end)
end
local function DoSpawn(inst)
	SpawnAt("ttk_boss_spawn_fx_medium_static",inst)
	inst:DoTaskInTime(0.2,function()
		inst:Show()
	end)
end
local TWEEN_TARGET = {1, 1, 1, 0}
local TWEEN_TIME = 0.2
local function dodespawn(inst)
    if not inst.doremove then
		SpawnAt("ttk_boss_spawn_fx_medium_static",inst)
        inst.doremove = true
        inst.components.colourtweener:StartTween(TWEEN_TARGET, TWEEN_TIME, inst.Remove)
    end
end
local ttk_boss_swordbrain = require "brains/ttk_boss_swordbrain"
local function swordfn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	MakeInventoryPhysics(inst)
	RemovePhysicsColliders(inst)
	inst.Transform:SetFourFaced(inst)
	inst.AnimState:SetBank(Boss.Art("xd_sword_mo"))
	inst.AnimState:SetBuild(Boss.Art("xd_sword_mo"))
	inst.AnimState:PlayAnimation("idle")
	inst.AnimState:AddOverrideBuild(Boss.Art("xd_sword_mo_bz"))
	inst.AnimState:AddOverrideBuild(Boss.Art("xd_sword_mo_skill"))
	inst.AnimState:SetScale(1.257, 1.257, 1.257)
	inst:AddTag("fx")
	inst:AddTag("NOBLOCK")
	inst.entity:SetPristine()
	if not TheWorld.ismastersim then
		return inst
	end
	inst:SetStateGraph("SGttk_boss_ziyunsword")
	inst.persists = false
	inst:AddComponent("knownlocations")
	local follower = inst:AddComponent("follower")
	follower:KeepLeaderOnAttacked()
	follower.keepdeadleader = true
	follower.keepleaderduringminigame = true
	inst:AddComponent("locomotor")
	inst.components.locomotor.runspeed = TUNING.SHADOWWAXWELL_SPEED
	inst.components.locomotor:SetTriggersCreep(false)
	inst.components.locomotor.pathcaps = {  allowocean = true, ignorecreep = true }
	inst.components.locomotor:SetSlowMultiplier(.6)
	inst:SetBrain(ttk_boss_swordbrain)
	inst:AddComponent("colourtweener")
	inst.DoSpawn = DoSpawn
	inst.DoDespawn = dodespawn
	return inst
end
local function onhammered(inst, worker)
	local str = STRINGS.NAMES.XD_ZIYUNBOSS_TALKS[4]
	local boss = SpawnAt("ttk_ziyunboss",inst)
	boss.components.talker:Say(str[math.random(#str)],nil,true,true)
	local spawnpoint = inst.components.entitytracker:GetEntity("spawnpoint")
	if spawnpoint and boss.components.entitytracker then
		boss.components.entitytracker:TrackEntity("spawnpoint", spawnpoint)
		if boss.components.knownlocations then
			boss.components.knownlocations:RememberLocation("spawnpoint", inst:GetPosition(),true)
		end
	end
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")
    inst:Remove()
end
local function onhit(inst, worker)
end
local function housefn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
	inst:SetDeploySmartRadius(2)
	MakeObstaclePhysics(inst, 1)
    inst.MiniMapEntity:SetIcon("ttk_boss_ziyun_house.tex")
    inst:AddTag("structure")
    inst.AnimState:SetBank(Boss.Art("xd_ziyun_house"))
    inst.AnimState:SetBuild(Boss.Art("xd_ziyun_house"))
    inst.AnimState:PlayAnimation("idle")
    MakeSnowCoveredPristine(inst)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
	inst:AddComponent("entitytracker")
    inst:AddComponent("inspectable")
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
	inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -2
    MakeSnowCovered(inst)
	MakeHauntableWork(inst)
	TUNING.XD_ZIYUNBOSS_COUNT  = TUNING.XD_ZIYUNBOSS_COUNT + 1
	inst:ListenForEvent("onremove",function()
		TUNING.XD_ZIYUNBOSS_COUNT  = TUNING.XD_ZIYUNBOSS_COUNT - 1
	end)
    return inst
end
local DRAGONFLY_SPAWNTIMER = "ttk_ziyunboss"
local function StartSpawning(inst)
    inst.components.timer:StartTimer(DRAGONFLY_SPAWNTIMER, TUNING.XD_BOSS_ZIYUN_RESPAWNTIME)
end
local function GenerateNewDragon(inst)
    inst.components.childspawner:AddChildrenInside(1)
    inst.components.childspawner:StartSpawning()
end
local function ontimerdone(inst, data)
    if data.name == DRAGONFLY_SPAWNTIMER then
        GenerateNewDragon(inst)
    end
end
local function onspawned(inst, child)
    if child and child.components.entitytracker then
		child.components.entitytracker:TrackEntity("spawnpoint", inst)
    end
end
local function spawnerfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst:AddTag("CLASSIFIED")
    inst:AddComponent("childspawner")
    inst.components.childspawner.childname = "ttk_boss_ziyun_house"
    inst.components.childspawner:SetMaxChildren(1)
    inst.components.childspawner:SetSpawnPeriod(1, 0)
    inst.components.childspawner:StartSpawning()
    inst.components.childspawner:StopRegen()
    inst.components.childspawner:SetSpawnedFn(onspawned)
	inst.StartSpawning = StartSpawning
    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", ontimerdone)
    return inst
end
return Prefab("ttk_ziyunboss", fn, assets, prefabs),
    Prefab("ttk_boss_ziyunboss_flyerfx_cloud", CloudFx, assets),
    Prefab("ttk_boss_ziyunboss_channeler", channelerfn, assets),
    Prefab("ttk_boss_ziyunboss_shadower", shadowfn, assets),
	Prefab("ttk_boss_ziyunboss_shadowent", entfn),
	Prefab("ttk_boss_ziyunboss_sword", swordfn),
	Prefab("ttk_boss_ziyun_house", housefn)
