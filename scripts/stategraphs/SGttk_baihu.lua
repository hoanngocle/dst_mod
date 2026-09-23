-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local XD_GetGroundPoints = Boss.XD_GetGroundPoints
local XD_RANDOM_ANGLES = Boss.XD_RANDOM_ANGLES
local XD_TELE_PLAYER = Boss.XD_TELE_PLAYER
require("stategraphs/commonstates")
local SGDaywalkerCommon = require("stategraphs/SGdaywalker_common")
local function ChooseAttack(inst)
	local running = inst.sg:HasStateTag("running")
		inst.sg:GoToState("attack_pounce_pre", {
			running = running,
			target = inst.components.combat.target,
		})
	return true
end
local function IsPlayerMelee(data)
	return data ~= nil
		and data.attacker ~= nil
		and data.attacker:HasTag("player")
		and (data.damage or 0) > 0
		and (data.weapon == nil or (
				(data.weapon.components.weapon == nil or data.weapon.components.weapon.projectile == nil) and
				data.weapon.components.projectile == nil
			))
end
local events =
{
	CommonHandlers.OnLocomote(true, true),
	CommonHandlers.OnDeath(),
	EventHandler("doattack", function(inst)
		if not inst.sg:HasStateTag("busy") and not inst.components.health:IsDead() then
			ChooseAttack(inst)
		end
	end),
	EventHandler("attacked", function(inst, data)
		local playermelee = IsPlayerMelee(data)
		if  not inst.components.health:IsDead() and (not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("caninterrupt")) and
			not CommonHandlers.HitRecoveryDelay(inst)
			and not inst.sg:HasStateTag("skill") then
			inst.sg:GoToState("hit", playermelee or inst.sg.statemem.trytired)
		end
	end),
	EventHandler("teleported", function(inst)
		if not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("caninterrupt") then
			inst.sg:GoToState("hit", inst.sg.statemem.trytired)
		end
	end),
	EventHandler("skill_taunt", function(inst)
		if not inst.sg:HasStateTag("busy") and not inst.components.health:IsDead() then
			inst.sg:GoToState("skill_taunt")
		end
	end),
	EventHandler("skill_lunge", function(inst,targets)
		if not inst.sg:HasStateTag("busy") and not inst.components.health:IsDead() then
			local newtarget = {}
			for i,v in ipairs(targets) do
				if v and inst:IsLungeTarget(v) then
					table.insert(newtarget,v)
				end
			end
			if #newtarget > 0 then
				inst.sg:GoToState("lunge", newtarget)
			end
		end
	end),
	EventHandler("skill_tele", function(inst,targets)
		if not inst.sg:HasStateTag("busy") and not inst.components.health:IsDead() then
			local newtarget = {}
			for i,v in ipairs(targets) do
				if v and inst:IsLungeTarget(v) then
					table.insert(newtarget,v)
				end
			end
			if #newtarget > 0 then
				inst.sg:GoToState("tele", newtarget)
			end
		end
	end),
	EventHandler("skill_3", function(inst,targets)
		if not inst.sg:HasStateTag("busy") and not inst.components.health:IsDead() then
			inst.sg:GoToState("skill_3")
		end
	end),
}
local AOE_RANGE_PADDING = 3
local AOE_TARGET_MUSTHAVE_TAGS = { "_combat" }
local AOE_TARGET_CANT_TAGS = { "INLIMBO", "flight", "invisible", "notarget", "noattack" }
local MAX_SIDE_TOSS_STR = 0.8
local function DoAOEAttack(inst, dist, radius, heavymult, mult, forcelanded, targets,forcedammage,damagefn,damageapplyfn,postarget)
	if not inst:IsValid() then
		return
	end
	local changedamage = false
	inst.components.combat.ignorehitrange = true
	if forcedammage then
		changedamage = true
		inst.components.combat:SetDefaultDamage(forcedammage)
	end
	local x, y, z = inst.Transform:GetWorldPosition()
	if postarget then
		x, y, z = postarget.Transform:GetWorldPosition()
	end
	local rot0, x0, z0
	if dist ~= 0 then
		if dist > 0 and ((mult ~= nil and mult > 1) or (heavymult ~= nil and heavymult > 1)) then
			x0, z0 = x, z
		end
		rot0 = (postarget or inst).Transform:GetRotation() * DEGREES
		x = x + dist * math.cos(rot0)
		z = z - dist * math.sin(rot0)
	end
	for i, v in ipairs(TheSim:FindEntities(x, y, z, radius + AOE_RANGE_PADDING, AOE_TARGET_MUSTHAVE_TAGS, AOE_TARGET_CANT_TAGS)) do
		if v ~= inst and
			not (targets ~= nil and targets[v]) and
			v:IsValid() and not v:IsInLimbo()
			and not (v.components.health ~= nil and v.components.health:IsDead()) then
			local range = radius + v:GetPhysicsRadius(0)
			if v:GetDistanceSqToPoint(x, y, z) < range * range and inst.components.combat:CanTarget(v) then
				local damagemult = 1
				if damageapplyfn then
					damagemult = damageapplyfn(inst,v)
				end
				inst.components.combat:DoAttack(v,nil,nil,nil,damagemult)
				if damagefn then
					damagefn(inst,v)
				end
				if mult ~= nil then
					local strengthmult = (v.components.inventory ~= nil and v.components.inventory:ArmorHasTag("heavyarmor") or v:HasTag("heavybody")) and heavymult or mult
					if strengthmult > MAX_SIDE_TOSS_STR and x0 ~= nil then
						local rot1 = (v:GetAngleToPoint(x0, 0, z0) + 180) * DEGREES
						local k = math.max(0, math.cos(math.min(PI, DiffAngleRad(rot1, rot0) * 2)))
						strengthmult = MAX_SIDE_TOSS_STR + (strengthmult - MAX_SIDE_TOSS_STR) * k * k
					end
					v:PushEvent("knockback", { knocker = inst, radius = radius + dist + 3, strengthmult = strengthmult, forcelanded = forcelanded })
				end
				if targets ~= nil then
					targets[v] = true
				end
			end
		end
	end
	inst.components.combat.ignorehitrange = false
	if changedamage then
		inst.components.combat:SetDefaultDamage(87.5)
	end
end
local function DoShadowAttack(inst,dist, radius)
	local x, y, z = inst.Transform:GetWorldPosition()
	local rot0
	if dist ~= 0 then
		rot0 = inst.Transform:GetRotation() * DEGREES
		x = x + dist * math.cos(rot0)
		z = z - dist * math.sin(rot0)
	end
	for i, v in ipairs(TheSim:FindEntities(x, y, z, radius,{"ttk_boss_baihu_shadowplayer","NOBLOCK"}, AOE_TARGET_CANT_TAGS)) do
		if v then
			inst:RemoveShaowFx(v)
		end
	end
end
local COLLAPSIBLE_WORK_ACTIONS =
{
	CHOP = true,
	HAMMER = true,
	MINE = true,
}
local COLLAPSIBLE_TAGS = { "NPC_workable" }
for k, v in pairs(COLLAPSIBLE_WORK_ACTIONS) do
	table.insert(COLLAPSIBLE_TAGS, k.."_workable")
end
local NON_COLLAPSIBLE_TAGS = { "FX",  "DECOR", "INLIMBO" }
local function DoAOEWork(inst, dist, radius, targets)
	local x, y, z = inst.Transform:GetWorldPosition()
	if dist ~= 0 then
		local rot = inst.Transform:GetRotation() * DEGREES
		x = x + dist * math.cos(rot)
		z = z - dist * math.sin(rot)
	end
	for i, v in ipairs(TheSim:FindEntities(x, y, z, radius, nil, NON_COLLAPSIBLE_TAGS, COLLAPSIBLE_TAGS)) do
		if not (targets ~= nil and targets[v]) and v:IsValid() and not v:IsInLimbo() and v.components.workable ~= nil then
			local work_action = v.components.workable:GetWorkAction()
			if (work_action == nil and v:HasTag("NPC_workable")) or
				(v.components.workable:CanBeWorked() and work_action ~= nil and COLLAPSIBLE_WORK_ACTIONS[work_action.id]) then
				v.components.workable:Destroy(inst)
			end
		end
	end
end
local SLAM_DETECT_MAX_ROT = 60
local SLAM_DETECT_RANGE_SQ = 9 * 9
local WAKEUP_SLAM_DETECT_RANGE_SQ = 6 * 6
local function IsSlamTarget(x, z, guy, rangesq, checkrot)
	if guy:IsValid() and
		not (guy.components.health ~= nil and
			guy.components.health:IsDead() or
			guy:HasTag("playerghost")) and
		guy.entity:IsVisible()
		then
		local x1, y1, z1 = guy.Transform:GetWorldPosition()
		local dx = x1 - x
		local dz = z1 - z
		return dx * dx + dz * dz < SLAM_DETECT_RANGE_SQ
			and (checkrot == nil or DiffAngle(checkrot, math.atan2(-dz, dx) * RADIANS) < SLAM_DETECT_MAX_ROT)
			and TheWorld.Map:IsAboveGroundAtPoint(x1, y1, z1)
	end
	return false
end
local function FindSlamTarget(inst, rangesq)
	local x, y, z = inst.Transform:GetWorldPosition()
	local target = inst.components.combat.target
	if target ~= nil and IsSlamTarget(x, z, target, rangesq, nil) then
		return target
	end
	local targets = {}
	for k in pairs(inst.components.grouptargeter:GetTargets()) do
		if k ~= target then
			table.insert(targets, k)
		end
	end
	for i = 1, #targets do
		local rnd = math.random(#targets)
		target = targets[rnd]
		if IsSlamTarget(x, z, target, rangesq, nil) then
			return target
		end
		targets[rnd] = targets[#targets]
		targets[#targets] = nil
	end
	return nil
end
local NO_TAGS = { "INLIMBO", "notarget", "noattack", "flight", "invisible", "playerghost" }
local function findlungeplayers(inst,max,range)
	max = max or 4
	local targets = {}
	local count = 0
	local x, y, z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z,range or  20, {"player"}, NO_TAGS)
	for i,v in ipairs(ents) do
		if v:IsValid() and not v.components.health:IsDead() then
			table.insert(targets,v)
			count = count + 1
			if count >= max then
				break
			end
		end
	end
	if max ~=  999 then
		inst.sg.mem.targetcount = #targets
	end
	return targets
end
local function teleplayer(player,pos,radius)
	SpawnAt("lightning",player)
	if player.baihu_teletask then
		player.baihu_teletask:Cancel()
	end
	player.baihu_teletask = player:DoTaskInTime(0.5,function()
		player.baihu_teletask = nil
		local pt = pos
		local theta = math.random() * TWOPI
		local radius = radius
		local offset = FindWalkableOffset(pt, theta, radius, 12)
		local endpos = pt + (offset or Vector3(0,0,0))
		SpawnAt("lightning",endpos)
		XD_TELE_PLAYER(player,endpos)
	end)
end
local function findnextlungetarget(inst)
	while inst.sg.statemem.lungenumber < inst.sg.statemem.maxlungenumber do
		inst.sg.statemem.lungenumber = inst.sg.statemem.lungenumber + 1
		local target = inst.sg.statemem.targets[inst.sg.statemem.lungenumber]
		if inst:IsLungeTarget(target) then
			return target
		end
	end
end
local function skilladd(inst)
	inst.components.timer:StopTimer("skill")
	inst.components.timer:StartTimer("skill", 15)
	inst.skillmode = inst.skillmode%5 + 1
end
local function resetphys(inst,remove)
	if remove then
		inst.sg.statemem.isphysicstoggle = true
		RemovePhysicsColliders(inst)
	else
		inst.sg.statemem.isphysicstoggle = false
		inst.Physics:ClearCollisionMask()
		inst.Physics:CollidesWith(COLLISION.WORLD)
		inst.Physics:CollidesWith(COLLISION.OBSTACLES)
		inst.Physics:CollidesWith(COLLISION.CHARACTERS)
		inst.Physics:CollidesWith(COLLISION.GIANTS)
	end
end
local function CanSlamTarget(inst)
	local target = inst.sg.statemem.targets[inst.sg.statemem.lungenumber]
	if not (target and target:IsValid() and inst:IsLungeTarget(target)) then
		local newtarget = findnextlungetarget(inst)
		if newtarget then
			target = newtarget
		else
			return false
		end
	end
	if target then
		local x, y, z = target.Transform:GetWorldPosition()
		local rot0 = target.Transform:GetRotation() * DEGREES
		inst.Physics:Teleport(x - 2 * math.cos(rot0), 0, z + 2 * math.sin(rot0))
		inst:ForceFacePoint(x, y, z)
	end
	return true
end
local function removerocks(inst)
	if inst.rocks then
		for i, v1 in ipairs(inst.rocks) do
			if v1:IsValid() then
				SpawnAt("rock_break_fx",v1)
				local fx11 = SpawnAt("collapse_small",v1)
				fx11:SetMaterial("none")
				v1:Remove()
			end
		end
		inst.rocks = nil
	end
end
local function skill1damagefn(inst,target)
	if inst:IsValid() and target and target:HasTag("player") and  inst.components.combat:CanTarget(target) then
		if not target.ttk_boss_baihu_buff1 then
			target.ttk_boss_baihu_buff1 =  SpawnPrefab("ttk_boss_baihu_buff1")
			target.ttk_boss_baihu_buff1:SetOwner(target)
		else
			if target.ttk_boss_baihu_buff1.count == 2 then
				target.ttk_boss_baihu_buff1:OnTimeDone()
			else
				target.ttk_boss_baihu_buff1:AddCount()
			end
		end
	end
end
local function skill1damageapplyfn(inst,target)
	if target and target:HasTag("player") then
		if target.ttk_boss_baihu_buff1 then
			return  target.ttk_boss_baihu_buff1:GetDamageMult()
		end
	end
end
local function skill2addbuff(inst,target)
	if target and target:HasTag("player") then
		if not target.ttk_boss_baihu_buff2 then
			target.ttk_boss_baihu_buff2 =  SpawnPrefab("ttk_boss_baihu_buff2")
			target.ttk_boss_baihu_buff2:SetOwner(target)
		end
	end
end
local function skill2damagefn(inst,target)
	if inst:IsValid() and target and target:HasTag("player") and  inst.components.combat:CanTarget(target) then
		local fx = SpawnAt("ttk_boss_baihu_shadowplayer",target)
		fx:CopyFromPlayer(inst,target)
		inst:AddShadowFx(fx)
		if not target.ttk_boss_baihu_buff2 then
			target.ttk_boss_baihu_buff2 =  SpawnPrefab("ttk_boss_baihu_buff2")
			target.ttk_boss_baihu_buff2:SetOwner(target,2)
		else
			target.ttk_boss_baihu_buff2:AddCount()
		end
	end
end
local function skill2damageapplyfn(inst,target)
	if target and target:HasTag("player") then
		if target.ttk_boss_baihu_buff2 and target.ttk_boss_baihu_buff2.count == 2 then
			return  5
		else
			return 1
		end
	end
end
local function skill3addbuff(inst,target)
	if target and target:HasTag("player") then
		if not target.ttk_boss_baihu_buff3 then
			target.ttk_boss_baihu_buff3 =  SpawnPrefab("ttk_boss_baihu_buff3")
			target.ttk_boss_baihu_buff3:SetOwner(target)
		end
	end
end
local states =
{
	State{
		name = "skill_taunt",
		tags = { "taunt", "busy","skill" },
		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("taunt")
			inst:SetStalking(nil)
			inst.canlungestalk = true
			skilladd(inst)
			inst.components.combat:RestartCooldown()
		end,
		timeline =
		{
			FrameEvent(4, function(inst) inst.SoundEmitter:PlaySound("daywalker/voice/chainbreak_break_2") end),
			FrameEvent(18, function(inst)
			end),
			FrameEvent(19, function(inst)
				inst.SoundEmitter:PlaySound(inst.footstep, nil, 0.3)
				SGDaywalkerCommon.DoRoarShake(inst)
				local iskill1 = inst.skillmode == 2 or inst.skillmode == 4
				local max = iskill1 and  4
					or inst.sg.mem.targetcount
					or 4
				inst.lungeplayers = findlungeplayers(inst,max)
				for _, v in ipairs(inst.lungeplayers) do
					if iskill1 then
						skill2addbuff(inst,v)
					else
						skill3addbuff(inst,v)
					end
				end
			end),
			FrameEvent(47, function(inst) inst.SoundEmitter:PlaySound(inst.footstep, nil, 0.2) end),
		},
		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},
	},
	State{
		name = "lunge",
		tags = {"busy","jumping","skill"},
		onenter = function(inst,targets)
			inst.components.locomotor:Stop()
			resetphys(inst,true)
			inst.AnimState:PlayAnimation("run_pre")
			inst.AnimState:PushAnimation("run_loop")
			inst:SetStalking(nil)
			inst.sg.statemem.lungenumber = 1
			inst.sg.statemem.maxlungenumber = #targets
			inst.sg.statemem.targets = targets
			inst.sg.statemem.hittargets = {}
			inst.components.locomotor:EnableGroundSpeedMultiplier(false)
			local target = targets[inst.sg.statemem.lungenumber]
			if target and target:IsValid() and inst:IsLungeTarget(target) then
				inst:ForceFacePoint(target:GetPosition())
				inst.Physics:SetMotorVel(24, 0, 0)
			end
			inst.sg:SetTimeout(10)
		end,
		onupdate = function(inst,dt)
			if not inst.sg.statemem.doattack then
				local target = inst.sg.statemem.targets[inst.sg.statemem.lungenumber]
				if not (target and target:IsValid() and inst:IsLungeTarget(target)) then
					local newtarget = findnextlungetarget(inst)
					if newtarget then
						inst:ForceFacePoint(newtarget:GetPosition())
						inst.Physics:SetMotorVel(24, 0, 0)
						inst.sg.statemem.hittargets = {}
					else
						inst.sg:GoToState("idle")
					end
				else
					if inst:IsValid() and inst:IsNear(target,3) then
						inst.components.locomotor:Stop()
						inst.sg.statemem.doattack = true
						inst.AnimState:PlayAnimation("atk3")
						inst.SoundEmitter:PlaySound("daywalker/voice/speak_short")
						inst.SoundEmitter:PlaySound("daywalker/action/attack3")
						inst.sg.statemem.attacktime = 0
					else
						inst:ForceFacePoint(target:GetPosition())
						inst.Physics:SetMotorVel(24, 0, 0)
						DoAOEAttack(inst, 0, 2, 1, 1, false,inst.sg.statemem.hittargets,35,skill2damagefn,skill2damageapplyfn)
					end
				end
			elseif inst.sg.statemem.attacktime then
				inst.sg.statemem.attacktime = inst.sg.statemem.attacktime + dt
				if inst.sg.statemem.attacktime >= 12* FRAMES then
					DoAOEAttack(inst, 3, 4, 1, 1, false,inst.sg.statemem.hittargets,35,skill2damagefn,skill2damageapplyfn)
				end
			end
		end,
		timeline =
		{
		},
        ontimeout = function(inst)
			inst.sg:GoToState("idle")
        end,
		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() and inst.AnimState:IsCurrentAnimation("atk3") then
					local newtarget = findnextlungetarget(inst)
					if newtarget then
						inst.AnimState:PlayAnimation("run_loop",true)
						inst.sg.statemem.doattack = false
						inst:ForceFacePoint(newtarget:GetPosition())
						inst.Physics:SetMotorVel(24, 0, 0)
						inst.sg.statemem.hittargets = {}
					else
						inst.sg:GoToState("idle")
					end
				end
			end),
		},
		onexit = function(inst)
			resetphys(inst)
			inst.components.combat:OverrideCooldown(1)
			inst.components.locomotor:EnableGroundSpeedMultiplier(true)
		end,
	},
	State{
		name = "tele",
		tags = {"busy","jumping","skill"},
		onenter = function(inst,targets)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("atk_slam_pre")
			inst.AnimState:PushAnimation("atk_slam")
			inst:SetStalking(nil)
			inst.sg.statemem.lungenumber = 1
			inst.sg.statemem.maxlungenumber = #targets
			inst.sg.statemem.targets = targets
			inst.sg:SetTimeout(15)
			local target = targets[inst.sg.statemem.lungenumber]
			if target and target:IsValid() and inst:IsLungeTarget(target) then
				inst.sg.statemem.target = target
				inst:ForceFacePoint(target.Transform:GetWorldPosition())
			end
		end,
		timeline =
		{
			FrameEvent(0, function(inst)
				inst.SoundEmitter:PlaySound("daywalker/voice/hurt")
				inst.SoundEmitter:PlaySound(inst.footstep, nil, 0.3)
			end),
			FrameEvent(21, function(inst) inst.SoundEmitter:PlaySound("daywalker/action/attack_slam_whoosh") end),
			FrameEvent(22, function(inst)
				inst.SoundEmitter:PlaySound("daywalker/voice/attack_big")
				inst.SoundEmitter:PlaySound(inst.footstep)
			end),
			FrameEvent(43, function(inst)
				if not CanSlamTarget(inst) then
					inst.sg:GoToState("idle")
				end
			end),
			FrameEvent(45, function(inst) inst.SoundEmitter:PlaySound("daywalker/action/attack_slam_down") end),
			FrameEvent(46, function(inst)
				local sinkhole = SpawnPrefab("ttk_boss_sinkhole")
				local x, y, z = inst.Transform:GetWorldPosition()
				local rot0 = inst.Transform:GetRotation() * DEGREES
				sinkhole.Transform:SetPosition(x + 2 * math.cos(rot0), 0, z - 2 * math.sin(rot0))
                sinkhole:SetFx(1)
				DoAOEAttack(inst, 2, 3, nil, nil, nil,nil,15)
				DoShadowAttack(inst, 2, 3)
			end),
			FrameEvent(90, function(inst)
				local newtarget = findnextlungetarget(inst)
				if newtarget then
					inst.AnimState:PlayAnimation("atk_slam_pre")
					inst.AnimState:PushAnimation("atk_slam")
				else
					inst.sg:GoToState("idle")
				end
			end),
			FrameEvent(91, function(inst)
				inst.SoundEmitter:PlaySound("daywalker/voice/hurt")
				inst.SoundEmitter:PlaySound(inst.footstep, nil, 0.3)
			end),
			FrameEvent(111, function(inst) inst.SoundEmitter:PlaySound("daywalker/action/attack_slam_whoosh") end),
			FrameEvent(112, function(inst)
				inst.SoundEmitter:PlaySound("daywalker/voice/attack_big")
				inst.SoundEmitter:PlaySound(inst.footstep)
			end),
			FrameEvent(133, function(inst)
				if not CanSlamTarget(inst) then
					inst.sg:GoToState("idle")
				end
			end),
			FrameEvent(135, function(inst) inst.SoundEmitter:PlaySound("daywalker/action/attack_slam_down") end),
			FrameEvent(136, function(inst)
				local sinkhole = SpawnPrefab("ttk_boss_sinkhole")
				local x, y, z = inst.Transform:GetWorldPosition()
				local rot0 = inst.Transform:GetRotation() * DEGREES
				sinkhole.Transform:SetPosition(x + 2 * math.cos(rot0), 0, z - 2 * math.sin(rot0))
                sinkhole:SetFx(1)
				DoAOEAttack(inst, 2, 3, nil, nil, nil,nil,15)
			end),
			FrameEvent(180, function(inst)
				local newtarget = findnextlungetarget(inst)
				if newtarget then
					inst.AnimState:PlayAnimation("atk_slam_pre")
					inst.AnimState:PushAnimation("atk_slam")
				else
					inst.sg:GoToState("idle")
				end
			end),
			FrameEvent(181, function(inst)
				inst.SoundEmitter:PlaySound("daywalker/voice/hurt")
				inst.SoundEmitter:PlaySound(inst.footstep, nil, 0.3)
			end),
			FrameEvent(201, function(inst) inst.SoundEmitter:PlaySound("daywalker/action/attack_slam_whoosh") end),
			FrameEvent(202, function(inst)
				inst.SoundEmitter:PlaySound("daywalker/voice/attack_big")
				inst.SoundEmitter:PlaySound(inst.footstep)
			end),
			FrameEvent(223, function(inst)
				if not CanSlamTarget(inst) then
					inst.sg:GoToState("idle")
				end
			end),
			FrameEvent(225, function(inst) inst.SoundEmitter:PlaySound("daywalker/action/attack_slam_down") end),
			FrameEvent(226, function(inst)
				local sinkhole = SpawnPrefab("ttk_boss_sinkhole")
				local x, y, z = inst.Transform:GetWorldPosition()
				local rot0 = inst.Transform:GetRotation() * DEGREES
				sinkhole.Transform:SetPosition(x + 2 * math.cos(rot0), 0, z - 2 * math.sin(rot0))
                sinkhole:SetFx(1)
				DoAOEAttack(inst, 2, 3, nil, nil, nil,nil,15)
			end),
			FrameEvent(270, function(inst)
				local newtarget = findnextlungetarget(inst)
				if newtarget then
					inst.AnimState:PlayAnimation("atk_slam_pre")
					inst.AnimState:PushAnimation("atk_slam")
				else
					inst.sg:GoToState("idle")
				end
			end),
			FrameEvent(271, function(inst)
				inst.SoundEmitter:PlaySound("daywalker/voice/hurt")
				inst.SoundEmitter:PlaySound(inst.footstep, nil, 0.3)
			end),
			FrameEvent(291, function(inst) inst.SoundEmitter:PlaySound("daywalker/action/attack_slam_whoosh") end),
			FrameEvent(292, function(inst)
				inst.SoundEmitter:PlaySound("daywalker/voice/attack_big")
				inst.SoundEmitter:PlaySound(inst.footstep)
			end),
			FrameEvent(313, function(inst)
				if not CanSlamTarget(inst) then
					inst.sg:GoToState("idle")
				end
			end),
			FrameEvent(315, function(inst) inst.SoundEmitter:PlaySound("daywalker/action/attack_slam_down") end),
			FrameEvent(316, function(inst)
				local sinkhole = SpawnPrefab("ttk_boss_sinkhole")
				local x, y, z = inst.Transform:GetWorldPosition()
				local rot0 = inst.Transform:GetRotation() * DEGREES
				sinkhole.Transform:SetPosition(x + 2 * math.cos(rot0), 0, z - 2 * math.sin(rot0))
                sinkhole:SetFx(1)
				DoAOEAttack(inst, 2, 3, nil, nil, nil,nil,15)
			end),
			FrameEvent(360, function(inst)
				inst.sg:GoToState("idle")
			end),
		},
        ontimeout = function(inst)
			inst.sg:GoToState("idle")
        end,
		events =
		{
			EventHandler("animover", function(inst)
			end),
		},
		onexit = function(inst)
			inst.components.combat:OverrideCooldown(1)
		end,
	},
	State{
		name = "skill_3",
		tags = {"busy","jumping","skill"},
		onenter = function(inst,targets)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("tired_pre")
			inst.AnimState:PushAnimation("chained_idle",true)
			inst:SetStalking(nil)
			local target = inst.components.combat.target
			if target ~= nil and target:IsValid() then
				inst:ForceFacePoint(target.Transform:GetWorldPosition())
			end
			inst.sg.statemem.hittargets = {}
			inst.sg:SetTimeout(15)
		end,
        ontimeout = function(inst)
			inst.sg:GoToState("idle")
        end,
		timeline =
		{
			FrameEvent(8, function(inst) inst.SoundEmitter:PlaySound(inst.footstep, nil, 0.3) end),
			FrameEvent(10, function(inst) inst.SoundEmitter:PlaySound(inst.footstep, nil, 0.3) end),
            TimeEvent(5.24, function(inst)
				inst.AnimState:PlayAnimation("taunt")
            end),
			TimeEvent(5.37, function(inst) inst.SoundEmitter:PlaySound("daywalker/voice/chainbreak_break_2") end),
			TimeEvent(5.87, function(inst)
				inst.SoundEmitter:PlaySound(inst.footstep, nil, 0.3)
				SGDaywalkerCommon.DoRoarShake(inst)
			end),
            TimeEvent(6, function(inst)
				SpawnAt("ttk_boss_ring_fx",inst)
				DoAOEAttack(inst, 0, 12, 2, 2, false,inst.sg.statemem.hittargets,175)
            end),
            TimeEvent(6.35, function(inst)
				SpawnAt("ttk_boss_ring_fx",inst)
				DoAOEAttack(inst, 0, 12, 2, 2, false,inst.sg.statemem.hittargets,175)
            end),
			TimeEvent(6.7, function(inst)
				SpawnAt("ttk_boss_ring_fx",inst)
				DoAOEAttack(inst, 0, 12, 2, 2, false,inst.sg.statemem.hittargets,175)
            end),
			TimeEvent(7.17, function(inst)
				if inst.sg.statemem.struggling then
					inst:SwitchToFacingModel(6)
				else
					inst:SwitchToFacingModel(4)
				end
				inst.AnimState:PlayAnimation("atk_slam_pre")
				inst.AnimState:PushAnimation("atk_slam",false)
            end),
			TimeEvent(7.2, function(inst)
				inst.SoundEmitter:PlaySound("daywalker/voice/hurt")
				inst.SoundEmitter:PlaySound(inst.footstep, nil, 0.3)
			end),
			TimeEvent(7.87, function(inst) inst.SoundEmitter:PlaySound("daywalker/action/attack_slam_whoosh") end),
			TimeEvent(7.88, function(inst)
				inst.SoundEmitter:PlaySound("daywalker/voice/attack_big")
				inst.SoundEmitter:PlaySound(inst.footstep)
			end),
			TimeEvent(8.8, function(inst)
				SpawnAt("lightning",inst)
				inst.rocks = {}
				local pos = inst:GetPosition()
				local angle = 0
				local radius = 12
				local number = 30
				for i=1,number do
					local offset = Vector3(radius * math.cos( angle ), 0, -radius * math.sin( angle ))
					local newpt = pos + offset
					inst:DoTaskInTime(math.random()*0.3, function()
						if inst.rocks then
							local rock = SpawnPrefab("ttk_boss_baihu_rock")
							rock.AnimState:PlayAnimation("emerge")
							rock.AnimState:PushAnimation("full")
							rock.Transform:SetPosition(newpt.x,newpt.y,newpt.z)
							rock:ListenForEvent("onremove",function()
								if rock:IsValid() then
									rock:Remove()
								end
							end,inst)
							table.insert(inst.rocks,rock)
						end
					end)
					angle = angle + (PI*2/number)
				end
				local players = findlungeplayers(inst,999,32)
				for _, v in ipairs(players) do
					teleplayer(v,pos,math.random(0,6))
				end
				inst.sg:GoToState("chongci",{players =players,pos = pos})
			end),
		},
		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() and inst.AnimState:IsCurrentAnimation("tired_pre") then
					inst:SwitchToFacingModel(0)
				end
			end),
		},
		onexit = function(inst)
		end,
	},
	State{
		name = "chongci",
		tags = {"busy","jumping","skill"},
		onenter = function(inst,data)
			SpawnAt("ttk_boss_baihu_fsfx",inst,nil,Vector3(0,2,0))
			resetphys(inst,true)
			inst:Hide()
			inst.DynamicShadow:Enable(false)
			inst.components.health:SetInvincible(true)
			inst.sg.statemem.startpos = data.pos
			inst.sg.statemem.players = data.players
			inst.sg.statemem.num = 1
			inst.sg.statemem.hittargets = {}
			inst:SetStalking(nil)
			inst.sg.statemem.cstime = 1.8
			inst.sg.statemem.playerchecktime = 0.5
			inst.sg.statemem.starttime =  GetTime()
		end,
		onupdate = function(inst,dt)
			if inst.sg.statemem.playerchecktime then
				inst.sg.statemem.playerchecktime = inst.sg.statemem.playerchecktime  -dt
				if inst.sg.statemem.playerchecktime <= 0 then
					for i,v in ipairs(inst.sg.statemem.players) do
						if v:IsValid() and not IsEntityDeadOrGhost(v) then
							local pos = v:GetPosition()
							if pos.x ~= inst.sg.statemem.startpos.x and pos.z ~= inst.sg.statemem.startpos.z then
								if v:GetDistanceSqToPoint(inst.sg.statemem.startpos) >= 11*11 then
									teleplayer(v,inst.sg.statemem.startpos,math.random(0,10))
								end
							end
						end
					end
					inst.sg.statemem.playerchecktime = 0.5
				end
			end
			if inst.sg.statemem.cstime then
				if inst.sg.statemem.cstime <= 0 then
					if inst.sg.statemem.num < 6 then
						inst.sg.statemem.cstime = 28/14 + 26 * FRAMES
						local rands = XD_RANDOM_ANGLES(inst.sg.statemem.num < 4 and 2 or 3, 45)
						inst:StartThread(function()
							for _ , v in ipairs(rands) do
								local radius = 14
								local offset = Vector3(radius * math.cos( v ), 0, -radius * math.sin( v ))
								if inst.sg.statemem.startpos and offset then
									local fx = SpawnAt("ttk_boss_shadowbaihu",inst.sg.statemem.startpos+offset)
									fx.hittargets = {}
									fx.dodamage = function(fx)
										DoAOEAttack(inst, 2, 2, 1, 1, false,fx.hittargets,125,nil,nil,fx)
									end
									fx:Lunge(inst.sg.statemem.startpos,inst)
									SpawnAt("ttk_boss_baihu_fsfx",inst.sg.statemem.startpos+offset,nil,Vector3(0,2,0))
								end
								Sleep(0.5)
							end
						end)
					else
						inst.sg.statemem.cstime = nil
					end
					inst.sg.statemem.num = inst.sg.statemem.num + 1
				else
					inst.sg.statemem.cstime = inst.sg.statemem.cstime -dt
				end
			end
		end,
		timeline = {
			TimeEvent(16, function(inst)
			 	inst.sg.statemem.chuiji = true
			 	inst.sg:GoToState("chuiji",{pos = inst.sg.statemem.startpos})
			end),
		},
		onexit = function(inst)
			if not inst.sg.statemem.chuiji then
				inst:Show()
				inst.DynamicShadow:Enable(true)
				inst.components.health:SetInvincible(false)
				resetphys(inst)
				removerocks(inst)
			end
			skilladd(inst)
		end,
	},
	State{
		name = "chuiji",
		tags = {"busy","jumping","skill"},
		onenter = function(inst,data)
			inst:Show()
			inst.DynamicShadow:Enable(true)
			inst.components.health:SetInvincible(false)
			resetphys(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("atk_slam_pre")
			inst.AnimState:PushAnimation("atk_slam",false)
			inst:SetStalking(nil)
			SpawnAt("ttk_boss_baihu_fsfx",inst,nil,Vector3(0,2,0))
		end,
		timeline =
		{
			FrameEvent(0, function(inst)
				inst.SoundEmitter:PlaySound("daywalker/voice/hurt")
				inst.SoundEmitter:PlaySound(inst.footstep, nil, 0.3)
			end),
			FrameEvent(21, function(inst) inst.SoundEmitter:PlaySound("daywalker/action/attack_slam_whoosh") end),
			FrameEvent(22, function(inst)
				inst.SoundEmitter:PlaySound("daywalker/voice/attack_big")
				inst.SoundEmitter:PlaySound(inst.footstep)
			end),
			FrameEvent(45, function(inst) inst.SoundEmitter:PlaySound("daywalker/action/attack_slam_down") end),
			FrameEvent(46, function(inst)
				inst:RemoveallShaowFx(true,150)
				removerocks(inst)
				local pos = inst:GetPosition()
				local rot0 = inst.Transform:GetRotation() * DEGREES
				local points = XD_GetGroundPoints(Vector3(pos.x + 2 * math.cos(rot0), 0, pos.z - 2 * math.sin(rot0)),3)
				local map = TheWorld.Map
				for i, v1 in ipairs(points) do
					for i,v in ipairs(v1) do
						if map:IsLandTileAtPoint(v:Get()) and not map:IsDockAtPoint(v:Get()) then
							SpawnPrefab("groundpound_fx").Transform:SetPosition(v.x, 0, v.z)
						end
					end
				end
			end),
		},
		events =
		{
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
		},
	},
	State{
		name = "idle",
		tags = { "idle", "canrotate" },
		onenter = function(inst)
			inst.components.locomotor:Stop()
			if inst:IsStalking() then
				inst.sg:AddStateTag("stalking")
				inst:SetHeadTracking(true)
				inst.AnimState:PlayAnimation("idlewalk", true)
			else
				inst.AnimState:PlayAnimation("idle", true)
			end
		end,
	},
	State{
		name = "hit",
		tags = { "hit", "busy" },
		onenter = function(inst, trytired)
			if inst:IsStalking() then
				inst:SetStalking(nil)
			end
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("hit")
			inst.SoundEmitter:PlaySound("daywalker/voice/hurt")
			CommonHandlers.UpdateHitRecoveryDelay(inst)
			inst.sg.statemem.trytired = trytired
		end,
		timeline =
		{
			FrameEvent(9, function(inst) inst.SoundEmitter:PlaySound(inst.footstep, nil, 0.4) end),
			FrameEvent(13, function(inst)
				if not inst.defeated and not (inst.sg.statemem.doattack and ChooseAttack(inst)) then
					inst.sg:RemoveStateTag("busy")
				end
			end),
		},
		events =
		{
			EventHandler("doattack", function(inst)
				inst.sg.statemem.doattack = true
				return inst.sg:HasStateTag("busy")
			end),
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},
	},
	State{
		name = "attack_pounce_pre",
		tags = { "attack", "busy", "jumping" },
		onenter = function(inst, data)
			inst:SetStalking(nil)
			inst.components.locomotor:Stop()
			inst.components.locomotor:EnableGroundSpeedMultiplier(false)
			inst.AnimState:PlayAnimation("run_pre")
			inst.SoundEmitter:PlaySound(inst.footstep)
			if data ~= nil then
				if data.target ~= nil and data.target:IsValid() then
					inst:ForceFacePoint(data.target.Transform:GetWorldPosition())
				end
				inst.sg.statemem.speedmult = not data.running and 0.8 or nil
			end
			inst.Physics:SetMotorVelOverride(11 * (inst.sg.statemem.speedmult or 1), 0, 0)
		end,
		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.pouncing = true
					inst.sg:GoToState("attack_pounce", inst.sg.statemem.speedmult)
				end
			end),
		},
		onexit = function(inst)
			if not inst.sg.statemem.pouncing then
				inst.Physics:ClearMotorVelOverride()
				inst.Physics:Stop()
				inst.components.locomotor:EnableGroundSpeedMultiplier(true)
			end
		end,
	},
	State{
		name = "attack_pounce",
		tags = { "attack", "busy", "jumping", "nointerrupt", "notalksound" },
		onenter = function(inst, speedmult)
			inst:SetStalking(nil)
			inst.components.locomotor:EnableGroundSpeedMultiplier(false)
			inst:StartAttackCooldown()
			inst.AnimState:PlayAnimation("atk3")
			inst.SoundEmitter:PlaySound("daywalker/voice/speak_short")
			inst.SoundEmitter:PlaySound("daywalker/action/attack3")
			inst.sg.statemem.speedmult = speedmult or 1
			inst.Physics:SetMotorVelOverride(11 * inst.sg.statemem.speedmult, 0, 0)
		end,
		onupdate = function(inst)
			if inst.sg.statemem.speed ~= nil then
				inst.sg.statemem.speed = inst.sg.statemem.speed * 0.75
				inst.Physics:SetMotorVelOverride(inst.sg.statemem.speed * inst.sg.statemem.speedmult, 0, 0)
			end
			if inst.sg.statemem.collides ~= nil then
				DoAOEAttack(inst, 0.2, 1.4, nil, nil, nil, inst.sg.statemem.collides)
			end
		end,
		timeline =
		{
			FrameEvent(0, function(inst)
				inst.sg.statemem.collides = {}
			end),
			FrameEvent(5, function(inst)
				inst.sg.statemem.collides = nil
			end),
			FrameEvent(10, function(inst) inst.SoundEmitter:PlaySound(inst.footstep) end),
			FrameEvent(11, SGDaywalkerCommon.DoPounceShake),
			FrameEvent(12, function(inst)
				inst.sg:AddStateTag("pounce_recovery")
				local targets = {}
				inst.sg.statemem.targets = targets
				DoAOEAttack(inst, 3, 3+0.5, nil, nil, nil, targets,nil,skill1damagefn,skill1damageapplyfn)
				DoAOEAttack(inst, 0.4, 1.6+0.5, nil, nil, nil, targets,nil,skill1damagefn,skill1damageapplyfn)
				for k in pairs(targets) do
					if k:IsValid() and k:HasTag("smallcreature") then
						targets[k] = nil
					end
				end
			end),
			FrameEvent(14, function(inst)
				inst.sg:RemoveStateTag("nointerrupt")
			end),
			FrameEvent(15, function(inst)
				inst.sg.statemem.speed = 8
			end),
		},
		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					if inst.sg.statemem.targets ~= nil and next(inst.sg.statemem.targets) ~= nil then
						local target = inst.components.combat.target
						local targethit = target ~= nil and inst.sg.statemem.targets[target]
						inst.sg:GoToState("attack_pounce_pst", targethit)
					else
						inst.sg:GoToState("attack_pounce_pst")
					end
				end
			end),
		},
		onexit = function(inst)
			inst.Physics:ClearMotorVelOverride()
			inst.Physics:Stop()
			inst.components.locomotor:EnableGroundSpeedMultiplier(true)
		end,
	},
	State{
		name = "attack_pounce_pst",
		tags = { "busy", "caninterrupt", "pounce_recovery" },
		onenter = function(inst, targethit)
			inst.AnimState:PlayAnimation("atk3_pst")
			inst.sg.statemem.trystalk = targethit
		end,
		timeline =
		{
			FrameEvent(1, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
		},
		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					if inst.canstalk and (inst.sg.statemem.trystalk or inst.nostalkcd) and not (inst:IsStalking() or inst.components.timer:TimerExists("stalk_cd")) then
						inst:SetStalking(inst.components.combat.target)
					end
					inst.sg:GoToState("idle")
				end
			end),
		},
	},
	State{
		name = "gohome",
		tags = { "taunt", "busy","jumping" },
		onenter = function(inst, target)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("taunt")
			inst.components.health:SetInvincible(true)
            inst:AddTag("notarget")
			if target ~= nil and target:IsValid() then
				inst:ForceFacePoint(target.Transform:GetWorldPosition())
			end
			inst:SetStalking(nil)
		end,
		timeline =
		{
			FrameEvent(4, function(inst) inst.SoundEmitter:PlaySound("daywalker/voice/chainbreak_break_2") end),
			FrameEvent(19, function(inst)
				inst.SoundEmitter:PlaySound(inst.footstep, nil, 0.3)
				SGDaywalkerCommon.DoRoarShake(inst)
				SpawnAt("ttk_boss_baihu_fsfx",inst,nil,Vector3(0,2,0))
                local pos = inst.components.knownlocations:GetLocation("spawnpoint")
                if pos then
                    if inst.Physics ~= nil then
                        inst.Physics:Teleport(pos.x, 0, pos.z)
                    elseif inst.Transform ~= nil then
                        inst.Transform:SetPosition(pos.x, 0, pos.z)
                    end
                end
			end),
			FrameEvent(47, function(inst) inst.SoundEmitter:PlaySound(inst.footstep, nil, 0.2) end),
		},
		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},
        onexit = function(inst)
            inst:RemoveTag("notarget")
            inst.components.health:SetInvincible(false)
        end,
	},
	State{
		name = "death",
		tags = {  "dead", "busy", "noattack" },
		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst:SwitchToFacingModel(0)
			inst.AnimState:PlayAnimation("defeat")
		end,
		timeline =
		{
			FrameEvent(0, function(inst) inst.SoundEmitter:PlaySound("daywalker/voice/hurt") end),
			FrameEvent(7, function(inst) inst.SoundEmitter:PlaySound(inst.footstep, nil, 0.4) end),
			FrameEvent(23, function(inst) inst.SoundEmitter:PlaySound("daywalker/voice/speak_short") end),
			FrameEvent(33, function(inst) inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt") end),
			FrameEvent(34, SGDaywalkerCommon.DoDefeatShake),
			FrameEvent(36, function(inst)
				inst.components.lootdropper:DropLoot(inst:GetPosition())
			end),
			FrameEvent(76, function(inst) inst.SoundEmitter:PlaySound("daywalker/voice/speak_short") end),
		},
		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					local pos = inst:GetPosition()
					local rot = inst.Transform:GetRotation()
					inst:Remove()
					if not inst.components.ttk_boss_choujiang_creature then
						local fx  = SpawnAt("ttk_boss_deathbaihu",pos)
						fx.Transform:SetRotation(rot)
					end
				end
			end),
		},
		onexit = function(inst)
		end,
	},
}
SGDaywalkerCommon.AddWalkStates(states)
SGDaywalkerCommon.AddRunStates(states, nil,
{
	runonenter = function(inst)
	end,
})
return StateGraph("ttk_baihu", states, events, "idle")
