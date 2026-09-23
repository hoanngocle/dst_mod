-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local Prefab = Boss.Prefab
local XD_GETWOLRDLEVEL = Boss.XD_GETWOLRDLEVEL
local assets =
{
	Asset("ANIM", Boss.ArtPath("anim/daywalker_build.zip")),
	Asset("ANIM", Boss.ArtPath("anim/daywalker_pillar.zip")),
	Asset("ANIM", Boss.ArtPath("anim/daywalker_imprisoned.zip")),
	Asset("ANIM", Boss.ArtPath("anim/daywalker_phase1.zip")),
	Asset("ANIM", Boss.ArtPath("anim/daywalker_phase2.zip")),
	Asset("ANIM", Boss.ArtPath("anim/daywalker_defeat.zip")),
	Asset("ANIM", Boss.ArtPath("anim/xd_baihu.zip")),
	Asset("ANIM", Boss.ArtPath("anim/xd_baihu_actions.zip")),
}
local prefabs =
{
}
local brain = require("brains/ttk_boss_baihubrain")
local brain1 = require("brains/ttk_boss_baihu_noattackbrain")
local baihudrop = {
	{ "greengem",		1 },
	{ "greengem",		1 },
	{ "greengem",		1 },
}
for k = 1,4 do
	table.insert(baihudrop,{"orangegem",1})
end
for k = 1,4 do
	table.insert(baihudrop,{"yellowgem",1})
end
for k = 1,3 do
	table.insert(baihudrop,{"redgem",1})
end
for k = 1,15 do
	table.insert(baihudrop,{"goldnugget",1})
end
SetSharedLootTable("ttk_baihu",baihudrop)
local MASS = 1000
local function OnFacingModelDirty(inst)
	local numfacings = inst._facingmodel:value()
	if numfacings == 4 then
	elseif numfacings == 6 then
	elseif numfacings == 0 then
	end
end
local function SwitchToFacingModel(inst, numfacings)
	if numfacings == 6 then
		numfacings = 4
	end
	if numfacings == 0 then
		inst.Transform:SetNoFaced()
	elseif numfacings == 4 then
		inst.Transform:SetFourFaced()
	elseif numfacings == 6 then
		inst.Transform:SetFourFaced()
	else
		return
	end
	inst._facingmodel:set(numfacings)
end
local BLINDSPOT = 15
local function UpdateHead(inst)
    if inst.stalking == nil then
        return
    elseif not inst.stalking:IsValid() then
        inst.stalking = nil
        inst.lastfacing = nil
        inst.lastdir1 = nil
        inst.Transform:SetRotation(0)
        inst.Transform:SetFourFaced()
        return
    end
    local parent = inst.entity:GetParent()
    parent.AnimState:MakeFacingDirty()
    local dir1 = parent:GetAngleToPoint(inst.stalking.Transform:GetWorldPosition())
    local camdir = TheCamera:GetHeading()
    local facing = parent.AnimState:GetCurrentFacing()
    dir1 = ReduceAngle(dir1 + camdir)
    if facing == FACING_UP then
        if dir1 > -135 and dir1 < 135 then
            local diff = ReduceAngle(dir1 - 2)
            if math.abs(diff) < BLINDSPOT and facing == inst.lastfacing then
                dir1 = inst.lastdir1
            else
                dir1 = diff > 0 and 135 or -135
            end
        end
    elseif facing == FACING_DOWN then
        if dir1 < -45 or dir1 > 90 then
            local diff = ReduceAngle(dir1 + 178)
            if math.abs(diff) < BLINDSPOT and facing == inst.lastfacing then
                dir1 = inst.lastdir1
            else
                dir1 = diff < 0 and 90 or -45
            end
        end
    elseif facing == FACING_LEFT then
        if dir1 < -45 or dir1 > 135 then
            local diff = ReduceAngle(dir1 + 160)
            if math.abs(diff) < BLINDSPOT and facing == inst.lastfacing then
                dir1 = inst.lastdir1
            else
                dir1 = diff < 0 and 135 or -45
            end
        end
    elseif facing == FACING_RIGHT then
        if dir1 < -135 or dir1 > 45 then
            local diff = ReduceAngle(dir1 - 160)
            if math.abs(diff) < BLINDSPOT and facing == inst.lastfacing then
                dir1 = inst.lastdir1
            else
                dir1 = diff < 0 and 45 or -135
            end
        end
    end
    inst.lastfacing = facing
    inst.lastdir1 = dir1
    inst.AnimState:MakeFacingDirty()
end
local function CreateHead(boss)
	local inst = CreateEntity()
	inst:AddTag("FX")
	if not TheWorld.ismastersim then
		inst.entity:SetCanSleep(false)
	end
	inst.persists = false
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddFollower()
	inst.Transform:SetFourFaced()
	inst.AnimState:SetBank(Boss.Art("daywalker"))
	inst.AnimState:SetBuild(Boss.Art("xd_baihu"))
	inst.AnimState:PlayAnimation("xd_head", true)
	if boss and boss:HasTag("worldboss") then
		inst.AnimState:SetMultColour(0, 0, 0, 0.5)
	end
	inst:AddComponent("updatelooper")
	inst.isupdating = false
	inst.stalking = nil
	inst.lastfacing = nil
	inst.lastdir1 = nil
	return inst
end
local function OnStalkingDirty(inst)
	inst.head.stalking = inst._stalking:value()
	if inst.head.stalking ~= nil then
		if not inst.head.isupdating then
			inst.head.isupdating = true
			inst.head.components.updatelooper:AddPostUpdateFn(UpdateHead)
		end
	else
		if inst.head.isupdating then
			inst.head.isupdating = false
			inst.head.lastfacing = nil
			inst.head.lastdir1 = nil
			inst.head.components.updatelooper:RemovePostUpdateFn(UpdateHead)
			inst.head.Transform:SetRotation(0)
		end
	end
end
local function OnHeadTrackingDirty(inst)
	if inst._headtracking:value() then
		if inst.head == nil then
			inst.head = CreateHead(inst)
			inst.head.entity:SetParent(inst.entity)
			inst.head.Follower:FollowSymbol(inst.GUID, "HEAD_follow", nil, nil, nil, true, true)
			inst.highlightchildren = { inst.head }
			inst.head:ListenForEvent("stalkingdirty", OnStalkingDirty, inst)
			OnStalkingDirty(inst)
		end
	elseif inst.head ~= nil then
		inst.head:Remove()
		inst.head = nil
	end
end
local function SetHeadTracking(inst, track)
	track = track ~= false
	if inst._headtracking:value() ~= track then
		inst._headtracking:set(track)
		if not TheNet:IsDedicated() then
			OnHeadTrackingDirty(inst)
		end
	end
end
local function OnStalkingNewState(inst)
	if inst.sg:HasStateTag("stalking") then
	else
	end
end
local function SetStalking(inst, stalking)
	if stalking ~= nil and not stalking:HasTag("player") then
		stalking = nil
	end
	if stalking ~= inst._stalking:value() then
		if inst._stalking:value() ~= nil then
			inst:RemoveEventCallback("onremove", inst._onremovestalking, inst._stalking:value())
			if stalking == nil then
				inst:RemoveEventCallback("newstate", OnStalkingNewState)
			end
		elseif stalking ~= nil then
			inst:ListenForEvent("newstate", OnStalkingNewState)
		end
		inst._stalking:set(stalking)
		if stalking then
			inst:ListenForEvent("onremove", inst._onremovestalking, stalking)
			if not inst.nostalkcd then
				inst.components.timer:StopTimer("stalk_cd")
				inst.components.timer:StartTimer("stalk_cd", 20)
			end
		end
	end
end
local function GetStalking(inst)
	return inst._stalking:value()
end
local function IsLungeTarget(inst,target)
	return target:IsValid() and inst:IsNear(target,60) and not target.components.health:IsDead()
end
local function GetStalkingLunge(inst)
	if inst.lungeplayers then
		for _, v in ipairs(inst.lungeplayers) do
			if v and IsLungeTarget(inst,v) then
				return v
			end
		end
	end
end
local function IsStalking(inst)
	return inst._stalking:value() ~= nil
end
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
local function RetargetFn(inst)
	UpdatePlayerTargets(inst)
	local target = inst.components.combat.target
	local inrange = target ~= nil and inst:IsNear(target, 6 + target:GetPhysicsRadius(0))
	if target ~= nil and target:HasTag("player") then
		local newplayer = inst.components.grouptargeter:TryGetNewTarget()
		return newplayer ~= nil
			and newplayer:IsNear(inst, inrange and 6 + newplayer:GetPhysicsRadius(0) or 12)
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
local function KeepTargetFn(inst, target)
	return target and target:IsValid() and inst:IsValid() and  inst.components.combat:CanTarget(target)
		and target:IsNear(inst, 30)
end
local function OnAttacked(inst, data)
	if data.attacker ~= nil then
		local target = inst.components.combat.target
		if not (target ~= nil and
			target:HasTag("player") and
			target:IsNear(inst, 6 + target:GetPhysicsRadius(0))) then
			inst.components.combat:SetTarget(data.attacker)
		end
	end
end
local function OnNewTarget(inst, data)
	if data.target ~= nil then
		if inst.canstalk and inst:IsStalking() then
			inst:SetStalking(data.target)
		end
	end
end
local function StartAttackCooldown(inst)
	inst.components.combat:RestartCooldown()
end
local function OnSave(inst, data)
end
local function OnLoad(inst, data)
end
local function OnLoadPostPass(inst, ents, data)
end
local function OnEntitySleep(inst)
end
local function OnEntityWake(inst)
end
local function OnTalk(inst)
	if not inst.sg:HasStateTag("notalksound") then
		inst.SoundEmitter:PlaySound("daywalker/voice/speak_short")
	end
end
local function teleport_override_fn(inst)
	local pos = inst.components.knownlocations:GetLocation("spawnpoint")
	if pos ~= nil then
		local offset = FindWalkableOffset(pos, TWOPI * math.random(), 4, 8, true, false)
		return offset ~= nil and pos + offset or pos
	end
end
local function PushMusic(inst)
	if ThePlayer == nil or not inst:HasTag("hostile") then
		inst._playingmusic = false
	elseif ThePlayer:IsNear(inst, inst._playingmusic and 40 or 20) then
		inst._playingmusic = true
		ThePlayer:PushEvent("triggeredevent", { name = "daywalker" })
	elseif inst._playingmusic and not ThePlayer:IsNear(inst, 50) then
		inst._playingmusic = false
	end
end
local AOE_TARGET_MUSTHAVE_TAGS = { "_combat","player" }
local AOE_TARGET_CANT_TAGS = { "INLIMBO", "flight", "invisible", "notarget", "noattack" }
local function CheckShaodows(inst)
	if inst.shadow_count > 0 then
		if not inst.shadowtask then
			inst.shadowtask =  inst:DoPeriodicTask(5,function()
				if inst:IsValid() then
					inst.components.combat.ignorehitrange = true
					local damage = inst.shadow_count *4
					local x,y,z = inst.Transform:GetWorldPosition()
					local ents = TheSim:FindEntities(x, y, z, 28, AOE_TARGET_MUSTHAVE_TAGS, AOE_TARGET_CANT_TAGS)
					for i, v in ipairs(ents) do
						if v:IsValid() and not v:IsInLimbo() and not (v.components.health ~= nil and v.components.health:IsDead()) and inst.components.combat:CanTarget(v) then
							SpawnAt("ttk_boss_baihu_gzfx",v)
							v.components.combat:GetAttacked(inst,damage,nil,"ttk_boss_no_attackedsg")
						end
					end
					for fx, v in pairs(inst.shadowfxs) do
						if fx:IsValid() then
							SpawnAt("ttk_boss_baihu_gzfx",fx)
						end
					end
					inst.components.combat.ignorehitrange = false
				end
			end,5)
		end
	elseif inst.shadowtask then
		inst.shadowtask:Cancel()
		inst.shadowtask = nil
	end
end
local function AddShadowFx(inst,fx)
	inst.shadowfxs[fx] = true
	fx.owner = inst
	inst.shadow_count = inst.shadow_count + 1
	CheckShaodows(inst)
end
local function doremoveattack(inst,fx,damage)
	SpawnAt("ttk_boss_baihu_cjfx",fx,nil,Vector3(0,0.7,0))
	local x,y,z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, 28, AOE_TARGET_MUSTHAVE_TAGS, AOE_TARGET_CANT_TAGS)
	for i, v in ipairs(ents) do
		if v:IsValid() and not v:IsInLimbo() and not (v.components.health ~= nil and v.components.health:IsDead()) and inst.components.combat:CanTarget(v) then
			SpawnAt("ttk_boss_baihu_cjfx",v,nil,Vector3(0,0.7,0))
			v.components.combat:GetAttacked(inst,damage or 15,nil,"ttk_boss_no_attackedsg")
		end
	end
	local newfx = SpawnAt("ttk_boss_baihu_dotfx",fx)
	inst:AddDotFx(newfx)
	newfx.owner = inst
end
local function RemoveShaowFx(inst,fx)
	if inst.shadowfxs[fx] then
		inst.shadowfxs[fx] = nil
		fx.owner = nil
		SpawnAt("ttk_boss_baihu_cjfx",fx,nil,Vector3(0,0.7,0))
		doremoveattack(inst,fx)
		fx:Remove()
		inst.shadow_count = inst.shadow_count - 1
		CheckShaodows(inst)
	end
end
local function RemoveallShaowFx(inst,doattack,damage)
	for fx, v in pairs(inst.shadowfxs) do
		fx.owner = nil
		SpawnAt("ttk_boss_baihu_cjfx",fx,nil,Vector3(0,0.7,0))
		if doattack then
			doremoveattack(inst,fx,damage)
		end
		fx:Remove()
		inst.shadow_count = inst.shadow_count - 1
	end
	inst.shadowfxs = {}
	CheckShaodows(inst)
end
local function AddDotFx(inst,fx)
	inst.dotfxs[fx] = true
	fx:SetOwner(inst)
end
local function RemoveDotFx(inst,fx)
	if inst.dotfxs[fx] then
		inst.dotfxs[fx] = nil
		fx.owner = nil
		fx:OnTimeDone()
	end
end
local function RemoveallDotFx(inst)
	for fx, v in pairs(inst.dotfxs) do
		fx.owner = nil
		fx:OnTimeDone()
	end
	inst.dotfxs = {}
end
local function ReSet(inst,removepets)
    inst.skillmode = 1
	inst.components.timer:StopTimer("skill")
	inst.components.timer:StartTimer("skill", 15)
end
local function ondeath(inst)
	RemoveallDotFx(inst)
	RemoveallShaowFx(inst)
	local spawnpoint = inst.components.entitytracker:GetEntity("spawnpoint")
	if spawnpoint and spawnpoint.StartSpawning then
		spawnpoint:StartSpawning()
	end
end
local function GoHome(inst)
    inst:ReSet()
	inst.components.health:SetPercent(1)
    inst.sg:GoToState("gohome")
    if inst.components.combat ~= nil then
       inst.components.combat:SetTarget(nil)
        inst.components.combat:BlankOutAttacks(2)
    end
end
local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddDynamicShadow()
	inst.entity:AddNetwork()
	inst.Transform:SetFourFaced()
	MakeGiantCharacterPhysics(inst, MASS, 1.3)
	inst:AddTag("epic")
	inst:AddTag("noepicmusic")
	inst:AddTag("monster")
	inst:AddTag("hostile")
	inst:AddTag("scarytoprey")
	inst:AddTag("largecreature")
	inst:AddTag("ttk_baihu")
	inst:AddTag("ignore_xd_time_st")
	inst.AnimState:SetBank(Boss.Art("daywalker"))
	inst.AnimState:SetBuild(Boss.Art("xd_baihu"))
	inst.AnimState:PlayAnimation("idle", true)
	inst.AnimState:Hide("ARM_CARRY")
	inst.AnimState:SetSymbolLightOverride("ww_armlower_red", .6)
	inst.AnimState:SetSymbolLightOverride("flake", .6)
	inst.DynamicShadow:SetSize(3.5, 1.5)
	local talker = inst:AddComponent("talker")
	talker.fontsize = 40
	talker.font = TALKINGFONT
	talker.colour = Vector3(255/255, 224/255, 133/255)
	talker.offset = Vector3(0, -600, 0)
	talker.symbol = "ww_hunch"
	talker.name_colour = Vector3(255/255, 224/255, 133/255)
	talker.chaticon = "npcchatflair_daywalker"
	talker:MakeChatter()
	inst._facingmodel = net_tinybyte(inst.GUID, "ttk_baihu._facingmodel", "facingmodeldirty")
	inst._headtracking = net_bool(inst.GUID, "ttk_baihu._headtracking", "headtrackingdirty")
	inst._stalking = net_entity(inst.GUID, "ttk_baihu._stalking", "stalkingdirty")
	inst:AddComponent("despawnfader")
	inst.entity:SetPristine()
	if not TheNet:IsDedicated() then
		inst._playingmusic = false
		inst:DoPeriodicTask(1, PushMusic, 0)
	end
	if not TheWorld.ismastersim then
		inst:ListenForEvent("facingmodeldirty", OnFacingModelDirty)
		inst:ListenForEvent("headtrackingdirty", OnHeadTrackingDirty)
		return inst
	end
	inst.footstep = "daywalker/action/step"
	inst.components.talker.ontalk = OnTalk
	inst:AddComponent("entitytracker")
	inst:AddComponent("inspectable")
	inst:AddComponent("locomotor")
	inst.components.locomotor.walkspeed = 2.7
	inst.components.locomotor.runspeed = 9
	inst:AddComponent("health")
	inst.components.health:SetMaxHealth(26000)
	inst.components.health.nofadeout = true
	-- Normal health persistence: registry encounters survive save/load.
	inst:AddComponent("combat")
	inst.components.combat:SetDefaultDamage(87.5)
	inst.components.combat:SetAttackPeriod(3)
	inst.components.combat:SetRange(5)
	inst.components.combat:SetRetargetFunction(3, RetargetFn)
	inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
	inst.components.combat.hiteffectsymbol = "ww_body"
	inst.components.combat.battlecryenabled = false
	inst.components.combat.forcefacing = false
	inst:AddComponent("healthtrigger")
	inst:AddComponent("knownlocations")
	inst:AddComponent("grouptargeter")
	inst:AddComponent("timer")
	inst:AddComponent("explosiveresist")
	inst:AddComponent("sanityaura")
	inst.components.sanityaura.aura = -TUNING.SANITYAURA_HUGE
	inst:AddComponent("epicscare")
	inst.components.epicscare:SetRange(TUNING.DAYWALKER_EPICSCARE_RANGE)
	inst:AddComponent("colourtweener")
	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetChanceLootTable("ttk_baihu")
	inst.components.lootdropper.min_speed = 1
	inst.components.lootdropper.max_speed = 3
	inst.components.lootdropper.y_speed = 14
	inst.components.lootdropper.y_speed_variance = 4
	inst.components.lootdropper.spawn_loot_inside_prefab = true
	inst:AddComponent("teleportedoverride")
	inst.components.teleportedoverride:SetDestPositionFn(teleport_override_fn)
	inst:AddComponent("ttk_boss_guaiwu_skills")
    inst.components.ttk_boss_guaiwu_skills.first = false
    inst.components.ttk_boss_guaiwu_skills.noskill =  true
    inst.components.ttk_boss_guaiwu_skills.by = 5
    inst.components.ttk_boss_guaiwu_skills.qx = 4
	inst.skillmode = 1
	inst.hit_recovery = 1
	inst._incoming_jumps = {}
	inst:ListenForEvent("attacked", OnAttacked)
	inst:ListenForEvent("newcombattarget", OnNewTarget)
	inst.ReSet = ReSet
	inst.GoHome = GoHome
	inst.nostalkcd = true
	inst.canstalk = true
	inst.shadowfxs = {}
	inst.shadow_count = 0
	inst.dotfxs = {}
	inst._onremovestalking = function(stalking) inst._stalking:set(nil) end
	inst.SwitchToFacingModel = SwitchToFacingModel
	inst.SetHeadTracking = SetHeadTracking
	inst.SetStalking = SetStalking
	inst.GetStalking = GetStalking
	inst.IsStalking = IsStalking
	inst.IsLungeTarget = IsLungeTarget
	inst.GetStalkingLunge = GetStalkingLunge
	inst.AddShadowFx = AddShadowFx
	inst.RemoveShaowFx = RemoveShaowFx
	inst.CheckShaodows = CheckShaodows
	inst.RemoveallShaowFx = RemoveallShaowFx
	inst.AddDotFx = AddDotFx
	inst.RemoveDotFx = RemoveDotFx
	inst.RemoveallDotFx = RemoveallDotFx
	inst.StartAttackCooldown = StartAttackCooldown
	inst.OnSave = OnSave
	inst.OnLoad = OnLoad
	inst.OnLoadPostPass = OnLoadPostPass
	inst.OnEntitySleep = OnEntitySleep
	inst.OnEntityWake = OnEntityWake
	inst:SetStateGraph("SGttk_baihu")
	inst:SetBrain(brain)
	inst:ListenForEvent("death",ondeath)
	return inst
end
local function checklevel(inst,force)
	local level = XD_GETWOLRDLEVEL()
	if  level >= 9 or force then
		local boss = SpawnAt("ttk_baihu",inst)
		local spawnpoint = inst.components.entitytracker:GetEntity("spawnpoint")
		if spawnpoint and boss.components.entitytracker then
			boss.components.entitytracker:TrackEntity("spawnpoint", spawnpoint)
			if boss.components.knownlocations then
				local pos = inst.components.knownlocations:GetLocation("spawnpoint") or inst:GetPosition()
				boss.components.knownlocations:RememberLocation("spawnpoint", pos,true)
			end
		end
		local bank,anim = inst.AnimState:GetHistoryData()
        if anim then
            inst.AnimState:PlayAnimation(anim)
            inst.AnimState:SetTime(inst.AnimState:GetCurrentAnimationTime())
		end
		inst:Remove()
	end
end
local function onnear(inst,player)
	if player and player.components.ttk_boss_level and player.components.ttk_boss_level.level >= 9 then
		checklevel(inst,true)
		return
	end
	if not inst.components.timer:TimerExists("talk_cd") then
		inst.components.timer:StartTimer("talk_cd",240)
		inst.components.talker:Say("Uy thế của Bạch Hổ đang trỗi dậy.",nil,true,true)
	end
end
local function onfar(inst)
end
local function noattackfn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddDynamicShadow()
	inst.entity:AddNetwork()
	inst.Transform:SetFourFaced()
	MakeGiantCharacterPhysics(inst, MASS, 1.3)
	inst:AddTag("epic")
	inst:AddTag("monster")
	inst:AddTag("hostile")
	inst:AddTag("scarytoprey")
	inst:AddTag("largecreature")
	inst:AddTag("ttk_baihu")
	inst:AddTag("ignore_xd_time_st")
	inst.AnimState:SetBank(Boss.Art("daywalker"))
	inst.AnimState:SetBuild(Boss.Art("xd_baihu"))
	inst.AnimState:PlayAnimation("idle", true)
	inst.AnimState:Hide("ARM_CARRY")
	inst.AnimState:SetSymbolLightOverride("ww_armlower_red", .6)
	inst.AnimState:SetSymbolLightOverride("flake", .6)
	inst:SetPrefabNameOverride("ttk_baihu")
	inst.DynamicShadow:SetSize(3.5, 1.5)
	local talker = inst:AddComponent("talker")
	talker.fontsize = 40
	talker.font = TALKINGFONT
	talker.colour = Vector3(255/255, 224/255, 133/255)
	talker.offset = Vector3(0, -600, 0)
	talker.symbol = "ww_hunch"
	talker.name_colour = Vector3(255/255, 224/255, 133/255)
	talker.chaticon = "npcchatflair_daywalker"
	talker:MakeChatter()
	inst._facingmodel = net_tinybyte(inst.GUID, "ttk_boss_baihu_noattack._facingmodel", "facingmodeldirty")
	inst._headtracking = net_bool(inst.GUID, "ttk_boss_baihu_noattack._headtracking", "headtrackingdirty")
	inst._stalking = net_entity(inst.GUID, "ttk_boss_baihu_noattack._stalking", "stalkingdirty")
	inst:AddComponent("despawnfader")
	inst.entity:SetPristine()
	if not TheWorld.ismastersim then
		inst:ListenForEvent("facingmodeldirty", OnFacingModelDirty)
		inst:ListenForEvent("headtrackingdirty", OnHeadTrackingDirty)
		return inst
	end
	inst.footstep = "daywalker/action/step"
	inst.components.talker.ontalk = OnTalk
	inst:AddComponent("entitytracker")
	inst:AddComponent("inspectable")
	inst:AddComponent("locomotor")
	inst.components.locomotor.walkspeed = 2.7
	inst.components.locomotor.runspeed = 9
	inst:AddComponent("knownlocations")
	inst:AddComponent("grouptargeter")
	inst:AddComponent("timer")
	inst:AddComponent("sanityaura")
	inst.components.sanityaura.aura = -TUNING.SANITYAURA_HUGE
	inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(8, 10)
    inst.components.playerprox:SetOnPlayerNear(onnear)
    inst.components.playerprox:SetOnPlayerFar(onfar)
	inst:AddComponent("epicscare")
	inst.components.epicscare:SetRange(TUNING.DAYWALKER_EPICSCARE_RANGE)
	inst:AddComponent("colourtweener")
	inst:AddComponent("lootdropper")
	inst:AddComponent("teleportedoverride")
	inst.components.teleportedoverride:SetDestPositionFn(teleport_override_fn)
	inst.skillmode = 1
	inst.SwitchToFacingModel = SwitchToFacingModel
	inst.SetHeadTracking = SetHeadTracking
	inst.SetStalking = SetStalking
	inst.GetStalking = GetStalking
	inst.IsStalking = IsStalking
	inst:SetStateGraph("SGttk_baihu")
	inst:SetBrain(brain1)
	inst:DoTaskInTime(0,checklevel)
	inst:ListenForEvent("ttk_boss_worldlevel_change",function(_,data)
		checklevel(inst)
	end,TheWorld)
	return inst
end
local TRAIL_FLAGS = { "ttk_boss_baihu_shadow_fx" }
local function cane_do_trail(inst)
    local owner = inst
    if not owner.entity:IsVisible() then
        return
    end
    local x, y, z = owner.Transform:GetWorldPosition()
    if true then
        local theta = -owner.Transform:GetRotation() * DEGREES
        local speed = 12 * .1
        x = x + speed * math.cos(theta)
        z = z + speed * math.sin(theta)
    end
    local map = TheWorld.Map
    local offset = FindValidPositionByFan(math.random() * TWOPI,0.5 + math.random() * .5,4,function(offset)
        local pt = Vector3(x + offset.x, 0, z + offset.z)
        return  not map:IsPointNearHole(pt)
            and #TheSim:FindEntities(pt.x, 0, pt.z, .7, TRAIL_FLAGS) <= 0
    end)
    if offset ~= nil then
        SpawnPrefab("ttk_boss_baihu_shadow_fx").Transform:SetPosition(x + offset.x, 0, z + offset.z)
    end
end
local function playsound(inst,volume)
	inst.SoundEmitter:PlaySound(inst.footstep, nil, volume)
end
local function dodamage(inst)
	if inst.dodamage then
		inst:dodamage()
	end
end
local function Lunge(inst,pos,owner)
	inst.owner = owner
	inst:ForceFacePoint(pos:Get())
	inst.Physics:SetMotorVel(12, 0, 0)
	inst.fxtask = inst:DoPeriodicTask(6 * FRAMES, cane_do_trail, 2 * FRAMES)
	inst.soundtask = inst:DoPeriodicTask(9 * FRAMES, playsound, FRAMES)
	inst.damagetask = inst:DoPeriodicTask(0.1, dodamage, FRAMES)
	inst:DoTaskInTime(22/12,function()
		inst.AnimState:PlayAnimation("atk3")
	end)
	inst:DoTaskInTime(28/12,function()
		inst.Physics:Stop()
		if inst.fxtask then
			inst.fxtask:Cancel()
			inst.fxtask = nil
		end
		if inst.soundtask then
			inst.soundtask:Cancel()
			inst.soundtask = nil
		end
		inst.SoundEmitter:PlaySound("daywalker/voice/speak_short")
		inst.SoundEmitter:PlaySound("daywalker/action/attack3")
		inst:DoTaskInTime(10 * FRAMES,function() inst.SoundEmitter:PlaySound(inst.footstep) end)
		inst:DoTaskInTime(14 * FRAMES,function()
			if inst.damagetask then
				inst.damagetask:Cancel()
				inst.damagetask = nil
			end
			inst.components.colourtweener:StartTween({1, 1, 1, 0}, 13 * FRAMES, function()
				inst:Remove()
			end)
		end)
	end)
end
local function MakeNoPhysics(inst, mass, rad)
    local physics = inst.entity:AddPhysics()
    physics:SetMass(mass)
    physics:SetCapsule(rad, 1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(5)
    inst.Physics:ClearCollisionMask()
end
local function shadowfn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddDynamicShadow()
	inst.entity:AddNetwork()
	inst.Transform:SetFourFaced()
	MakeNoPhysics(inst, 10, 1.5)
	inst:AddTag("fx")
	inst.AnimState:SetBank(Boss.Art("daywalker"))
	inst.AnimState:SetBuild(Boss.Art("xd_baihu"))
	inst.AnimState:PlayAnimation("run_loop", true)
	inst.AnimState:Hide("ARM_CARRY")
	inst.AnimState:SetAddColour(250/255,250/255, 180/255, 1)
	inst.nohighlight = true
	inst.entity:SetPristine()
	if not TheWorld.ismastersim then
		return inst
	end
	inst:AddComponent("colourtweener")
	inst.footstep = "daywalker/action/step"
	inst.Lunge = Lunge
	inst.persists = false
	inst:DoTaskInTime(5,inst.Remove)
	return inst
end
local function deathfn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddDynamicShadow()
	inst.entity:AddNetwork()
	MakeObstaclePhysics(inst, 1.3)
	inst.AnimState:SetBank(Boss.Art("daywalker"))
	inst.AnimState:SetBuild(Boss.Art("xd_baihu"))
	inst.AnimState:PlayAnimation("defeat_idle_pre")
	inst.AnimState:PushAnimation("defeat_idle_loop")
	inst.AnimState:Hide("ARM_CARRY")
	inst.AnimState:SetSymbolLightOverride("ww_armlower_red", .6)
	inst.AnimState:SetSymbolLightOverride("flake", .6)
	inst.DynamicShadow:SetSize(3.5, 1.5)
	inst:AddTag("fx")
	inst.entity:SetPristine()
	if not TheWorld.ismastersim then
		return inst
	end
	inst.persists = false
	inst:DoTaskInTime(60,inst.Remove)
	inst.OnEntitySleep = inst.remove
	return inst
end
local DRAGONFLY_SPAWNTIMER = "ttk_boss_baidu"
local function StartSpawning(inst)
    inst.components.timer:StartTimer(DRAGONFLY_SPAWNTIMER, TUNING.XD_BOSS_BAIHU_RESPAWNTIME)
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
    inst.components.childspawner.childname = "ttk_boss_baihu_noattack"
    inst.components.childspawner:SetMaxChildren(1)
    inst.components.childspawner:SetSpawnPeriod(1, 0)
    inst.components.childspawner:StartSpawning()
    inst.components.childspawner:StopRegen()
    inst.components.childspawner:SetSpawnedFn(onspawned)
	local old_DoSpawnChild = inst.components.childspawner.DoSpawnChild
	inst.components.childspawner.DoSpawnChild =  function(self,target, prefab, radius)
		local level = XD_GETWOLRDLEVEL()
        if  level >= 9 then
			prefab = "ttk_baihu"
		end
		return  old_DoSpawnChild(self,target, prefab, radius)
	end
	inst.StartSpawning = StartSpawning
    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", ontimerdone)
    return inst
end
return Prefab("ttk_baihu", fn, assets, prefabs),
	Prefab("ttk_boss_baihu_noattack", noattackfn, assets, prefabs),
	Prefab("ttk_boss_shadowbaihu", shadowfn),
	Prefab("ttk_boss_deathbaihu", deathfn)
