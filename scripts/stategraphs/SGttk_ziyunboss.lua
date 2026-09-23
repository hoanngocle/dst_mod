-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local XD_CanAttackTrget = Boss.XD_CanAttackTrget
local Xd_CalcDamage = Boss.Xd_CalcDamage
require("stategraphs/commonstates")
local hit_recovery_delay = CommonHandlers.HitRecoveryDelay
local heigh = 6
local actionhandlers =
{
}
local function onattacked(inst, data, hitreact_cooldown, max_hitreacts, skip_cooldown_fn)
    if inst.components.health ~= nil and not inst.components.health:IsDead()
		and not hit_recovery_delay(inst, hitreact_cooldown, max_hitreacts, skip_cooldown_fn)
        and not inst.sg:HasStateTag("skill")
        and (not inst.sg:HasStateTag("busy")
            or inst.sg:HasStateTag("caninterrupt")
            or inst.sg:HasStateTag("frozen")) then
        inst.sg:GoToState("hit")
    end
end
local function doaoe(inst,rang,damage,tbl)
    local pos = inst:GetPosition()
    local attacker = inst.owner or inst
    local ents = TheSim:FindEntities(pos.x,pos.y, pos.z,6, {"_combat","_health"},{"moonstorm_static","INLIMBO","wall", "notarget", "noattack", "flight", "invisible", "playerghost"})
    for i,v in pairs(ents) do
        if v and v:IsValid() and (not tbl or  not tbl[v]) and not v:HasTag("ttk_boss_xinmo") and XD_CanAttackTrget(attacker,v) then
            if tbl then
                tbl[v] = true
            end
            damage = Xd_CalcDamage(attacker,damage,v)
            v.components.combat:GetAttacked(attacker,damage)
        end
    end
end
local function GetCombatDuration(inst)
    if inst.ttk_boss_combatstarttime then
        return GetTime() - inst.ttk_boss_combatstarttime
    end
    return 0
end
local function resetphys(inst,remove)
	if remove then
		inst.sg.statemem.isphysicstoggle = true
		RemovePhysicsColliders(inst)
	else
		inst.sg.statemem.isphysicstoggle = false
		inst.Physics:ClearCollisionMask()
        inst.Physics:CollidesWith((TheWorld:CanFlyingCrossBarriers() and COLLISION.GROUND) or COLLISION.WORLD)
        inst.Physics:CollidesWith(COLLISION.CHARACTERS)
        inst.Physics:CollidesWith(COLLISION.GIANTS)
	end
end
local events=
{
    CommonHandlers.OnLocomote(true, false),
    CommonHandlers.OnDeath(),
	EventHandler("attacked", function(inst, data)
        onattacked(inst, data, 2.5, 3)
	end),
	EventHandler("doattack", function(inst, data)
		if inst.components.health ~= nil and not inst.components.health:IsDead() and not inst.sg:HasStateTag("busy") then
            local time = GetCombatDuration(inst)
            if time >= 5 and not inst.components.timer:TimerExists("skill1") and inst.mode == 1
                and not (inst.mode1_pet and inst.mode1_pet:IsValid()) then
                inst.sg:GoToState("skill1")
            else
                inst.sg:GoToState("attack", data ~= nil and data.target or nil)
			end
		end
	end),
}
local function TrySplashFX(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	if TheWorld.Map:IsOceanAtPoint(x, 0, z) then
		SpawnPrefab("ocean_splash_small"..tostring(math.random(2))).Transform:SetPosition(x, 0, z)
	end
end
local function TryStepSplash(inst)
	local t = GetTime()
	if (inst.sg.mem.laststepsplash == nil or inst.sg.mem.laststepsplash + .1 < t) and TrySplashFX(inst) then
		inst.sg.mem.laststepsplash = t
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
local function spawanfx(inst,colour)
    if inst then
        local fx = SpawnPrefab("ttk_boss_hyf_fullfx")
        fx.entity:SetParent(inst.entity)
        fx.entity:AddFollower()
        fx.Follower:FollowSymbol(inst.GUID, "swap_object", 30, -200, 0)
        if colour then
            fx.AnimState:SetMultColour(colour[1],colour[2],colour[3],1)
        end
        local fx = SpawnPrefab("ttk_boss_hyf_frontfx")
        fx.entity:SetParent(inst.entity)
        fx.entity:AddFollower()
        fx.Follower:FollowSymbol(inst.GUID, "swap_object", 30, -200, 0)
        if colour then
            fx.AnimState:SetMultColour(colour[1],colour[2],colour[3],1)
        end
    end
end
local states = {
    State{
        name = "idle",
        tags = { "idle", "canrotate" },
        onenter = function(inst, pushanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle_loop")
        end,
        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },
    State{
        name = "idle_fly",
        tags = {"busy","flying" },
        onenter = function(inst, pushanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle_loop",true)
            resetphys(inst,true)
            inst.sg.statemem.alltime = 0
        end,
	    onupdate = function(inst, dt)
            local height_target = heigh * 1
            local y = inst:GetPosition().y
            inst.Physics:SetMotorVel(0, (height_target - y)*32, 0)
            if inst.mode2_pet and inst.mode2_pet:IsValid() then
                local target = inst.mode2_pet.components.combat.target
                if target and target:IsValid() then
                    inst:ForceFacePoint(target:GetPosition())
                    inst.sg.statemem.alltime = 0
                else
                    inst.sg.statemem.alltime = inst.sg.statemem.alltime + dt
                end
            else
                inst.sg.statemem.alltime = inst.sg.statemem.alltime + dt
            end
            if inst.sg.statemem.alltime >= 20 then
                inst.sg:GoToState("fly_down_false")
            end
	    end,
        events =
        {
            EventHandler("animover", function(inst)
            end),
            EventHandler("gotophase3", function(inst)
                inst.sg:GoToState("fly_down")
            end),
            EventHandler("zhaohuan1", function(inst)
                inst.sg:GoToState("idle_fly_spell1")
            end),
            EventHandler("zhaohuan2", function(inst)
                inst.sg:GoToState("idle_fly_spell2")
            end),
        },
        onexit = function(inst)
            resetphys(inst)
		end,
    },
    State{
        name = "fly_down_false",
        tags = {"busy","flying" },
        onenter = function(inst, pushanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle_loop",true)
            inst:ChangeMode(1)
            inst.components.health:SetPercent(1)
            resetphys(inst,true)
            inst.sg.statemem.downtime = 1
            inst.sg:SetTimeout(1)
        end,
	    onupdate = function(inst, dt)
            inst.sg.statemem.downtime = inst.sg.statemem.downtime - dt
            local height_target = heigh * inst.sg.statemem.downtime
            local y = inst:GetPosition().y
            inst.Physics:SetMotorVel(0, (height_target - y)*32, 0)
	    end,
        timeline =
        {
        },
        ontimeout = function(inst)
            inst.sg:GoToState("idle")
        end,
        events =
        {
        },
        onexit = function(inst)
            resetphys(inst)
		end,
    },
    State{
        name = "fly_down",
        tags = {"busy","flying" },
        onenter = function(inst, pushanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle_loop",true)
            inst:ChangeMode()
            resetphys(inst,true)
            inst.sg.statemem.downtime = 1
            inst.sg:SetTimeout(1)
        end,
	    onupdate = function(inst, dt)
            inst.sg.statemem.downtime = inst.sg.statemem.downtime - dt
            local height_target = heigh * inst.sg.statemem.downtime
            local y = inst:GetPosition().y
            inst.Physics:SetMotorVel(0, (height_target - y)*32, 0)
	    end,
        timeline =
        {
			TimeEvent(1 * FRAMES, function(inst)
                local pos = inst:GetPosition()
                local fx = SpawnAt("ttk_boss_ziyunboss_channeler",Vector3(pos.x,0,pos.z))
                fx:OnSpawnedBy(inst)
            end),
        },
        ontimeout = function(inst)
            inst.sg:GoToState("idle")
        end,
        events =
        {
        },
        onexit = function(inst)
            resetphys(inst)
		end,
    },
    State{
        name = "run_start",
        tags = {"moving", "running", "canrotate"},
        onenter = function(inst)
            inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("run_pre")
        end,
        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("run")
                end
            end),
        },
        timeline =
        {
			TimeEvent(1 * FRAMES, TryStepSplash),
			TimeEvent(3 * FRAMES, function(inst)
                PlayFootstep(inst)
            end),
        },
    },
    State{
        name = "run",
        tags = {"moving", "running", "canrotate"},
        onenter = function(inst)
            inst.components.locomotor:RunForward()
            if not inst.AnimState:IsCurrentAnimation("run_loop") then
                inst.AnimState:PlayAnimation("run_loop", true)
            end
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,
        timeline =
        {
			TimeEvent(5 * FRAMES, TryStepSplash),
            TimeEvent(7 * FRAMES, function(inst)
                PlayFootstep(inst)
				inst.sg.mem.laststepsplash = GetTime()
            end),
			TimeEvent(13 * FRAMES, TryStepSplash),
            TimeEvent(15 * FRAMES, function(inst)
                PlayFootstep(inst)
				inst.sg.mem.laststepsplash = GetTime()
            end),
        },
        ontimeout = function(inst)
			inst.sg.statemem.running = true
            inst.sg:GoToState("run")
        end,
		onexit = function(inst)
			if not inst.sg.statemem.running then
				TryStepSplash(inst)
			end
		end,
    },
    State{
        name = "run_stop",
        tags = {"canrotate", "idle"},
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("run_pst")
        end,
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
        name = "attack",
		tags = {"attack", "abouttoattack"},
		onenter = function(inst, target)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("atk_pre")
			inst.AnimState:PushAnimation("atk", false)
			inst.components.combat:StartAttack()
			if target == nil then
				target = inst.components.combat.target
			end
			if target ~= nil and target:IsValid() then
				inst.sg.statemem.target = target
				inst:ForceFacePoint(target.Transform:GetWorldPosition())
			else
				target = nil
			end
        end,
        timeline =
        {
			TimeEvent(6 * FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
			end),
			TimeEvent(8*FRAMES, function(inst)
				inst.sg:RemoveStateTag("abouttoattack")
				local target = inst.sg.statemem.target
				inst.components.combat:DoAttack(target)
			end),
            TimeEvent(12*FRAMES, function(inst)
            end),
            TimeEvent(13*FRAMES, function(inst)
                inst.sg:RemoveStateTag("attack")
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
		onexit = function(inst)
			if inst.sg:HasStateTag("abouttoattack") then
				inst.components.combat:CancelAttack()
			end
		end,
    },
    State{
        name = "hit",
        tags = { "busy", "pausepredict" },
        onenter = function(inst, frozen)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("hit")
            if frozen == "noimpactsound" then
                frozen = nil
            else
                inst.SoundEmitter:PlaySound("dontstarve/wilson/hit")
            end
			local stun_frames = math.min(inst.AnimState:GetCurrentAnimationNumFrames(), frozen and 10 or 6)
            inst.sg:SetTimeout(stun_frames * FRAMES)
            CommonHandlers.UpdateHitRecoveryDelay(inst)
        end,
        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,
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
        name = "death",
        tags = { "busy", "dead", "pausepredict", "nomorph" },
        onenter = function(inst)
            if inst.mode == 1 then
                inst.sg:GoToState("resurrect")
                return
            end
            inst:DoTalk(STRINGS.NAMES.XD_ZIYUNBOSS_TALKS[3])
            if inst.sword and inst.sword:IsValid() then
                inst.sword:DoDespawn()
            end
            local spawnpoint = inst.components.entitytracker:GetEntity("spawnpoint")
            if spawnpoint and spawnpoint.StartSpawning then
                spawnpoint:StartSpawning()
            end
            inst.components.locomotor:Stop()
            inst.components.locomotor:Clear()
            inst:ClearBufferedAction()
            if inst.components.inventory then
                inst.components.inventory:DropEverything(true)
            end
            inst.AnimState:PlayAnimation(inst.deathanimoverride or "death")
            inst.AnimState:Hide("swap_arm_carry")
            if inst.components.lootdropper then
                inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))
            end
            inst.sg:ClearBufferedEvents()
        end,
        timeline =
        {
        },
        onexit = function(inst)
        end,
        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.dodespawn then
                        inst:dodespawn(true)
                    else
                        inst:Remove()
                    end
                end
            end),
        },
    },
    State{
        name = "resurrect",
        tags = { "busy", "dead", "pausepredict", "nomorph","flying" },
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.components.locomotor:Clear()
            resetphys(inst,true)
            inst:ClearBufferedAction()
            inst:ChangeMode()
            inst.AnimState:PlayAnimation("xf_fb_item_out")
            inst.AnimState:PushAnimation("xd_fb_staff_pre", false)
            inst.AnimState:PushAnimation("xd_fb_staff", false)
            inst.AnimState:OverrideSymbol("swap_fb_object", "xd_zhf", "swap")
            inst.AnimState:Show("ARM_fb_carry")
            inst.AnimState:Hide("ARM_fb_normal")
            inst.sg.statemem.castsound = "dontstarve/wilson/use_gemstaff"
            inst.sg.statemem.up = true
            inst.sg.statemem.time = 0
            inst.Physics:SetMotorVel(0, 3.1, 0)
        end,
        timeline = {
            TimeEvent(16 * FRAMES, function(inst)
                local colour = inst.sg.statemem.staff ~= nil and inst.sg.statemem.staff.fxcolour or {167/255,60/255,162/255}
                inst.sg.statemem.stafffx = SpawnPrefab("staffcastfx")
                inst.sg.statemem.stafffx.entity:SetParent(inst.entity)
                inst.sg.statemem.stafffx:SetUp(colour)
                inst.sg.statemem.colour = colour
                inst.sg.statemem.stafflight = SpawnPrefab("staff_castinglight")
                inst.sg.statemem.stafflight.Transform:SetPosition(inst.Transform:GetWorldPosition())
                inst.sg.statemem.stafflight:SetUp(colour, 1.9, .33)
            end),
            TimeEvent((13 +16) * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sg.statemem.castsound)
            end),
            TimeEvent((53 +16)  * FRAMES, function(inst)
                local pos = inst:GetPosition()
                pos.y = 0
                local theta = math.random() * 2 * PI
                local radius = 3.5
                local offset = FindWalkableOffset(pos, theta,radius,12, true)
                if offset == nil then
                    offset = Vector3(0,0,0)
                end
                local projectile = SpawnPrefab("ttk_boss_deerclops_ziyun_aux")
                projectile.Transform:SetPosition((pos+offset):Get())
                projectile:ForceFacePoint(pos)
                projectile:OnSpawnedBy(inst)
            end),
            TimeEvent((69 +16)  * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },
	    onupdate = function(inst, dt)
            local height_target = heigh * 1
            local y = inst:GetPosition().y
            if y < 6 and inst.sg.statemem.up then
                inst.Physics:SetMotorVel(0,3, 0)
            else
                inst.sg.statemem.up = false
                inst.Physics:SetMotorVel(0, (height_target - y)*32, 0)
            end
	    end,
        events = {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle_fly")
                end
            end),
        },
        onexit = function(inst)
            spawanfx(inst,inst.sg.statemem.colour)
            inst.AnimState:ClearOverrideSymbol("swap_fb_object")
            inst.AnimState:Hide("ARM_fb_carry")
            inst.AnimState:Show("ARM_fb_normal")
            resetphys(inst)
            if inst.sg.statemem.stafffx ~= nil and inst.sg.statemem.stafffx:IsValid() then
                inst.sg.statemem.stafffx:Remove()
            end
            if inst.sg.statemem.stafflight ~= nil and inst.sg.statemem.stafflight:IsValid() then
                inst.sg.statemem.stafflight:Remove()
            end
            inst.components.health:SetCurrentHealth(1)
            inst._ttk_boss_phase_transition = nil
        end,
    },
	State{
        name = "skill1",
        tags = { "attack", "doing", "busy","nomorph","skill" },
        onenter = function(inst, data)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("xf_fb_item_out")
            inst.AnimState:PushAnimation("xd_fb_staff_pre", false)
            inst.AnimState:PushAnimation("xd_fb_staff", false)
            inst.AnimState:OverrideSymbol("swap_fb_object", "xd_zhf", "swap")
            inst.AnimState:Show("ARM_fb_carry")
            inst.AnimState:Hide("ARM_fb_normal")
            inst.sg.statemem.castsound = "dontstarve/wilson/use_gemstaff"
        end,
        timeline =
        {
            TimeEvent(16 * FRAMES, function(inst)
                local colour = inst.sg.statemem.staff ~= nil and inst.sg.statemem.staff.fxcolour or {167/255,60/255,162/255}
                inst.sg.statemem.stafffx = SpawnPrefab("staffcastfx")
                inst.sg.statemem.stafffx.entity:SetParent(inst.entity)
                inst.sg.statemem.stafffx:SetUp(colour)
                inst.sg.statemem.colour = colour
                inst.sg.statemem.stafflight = SpawnPrefab("staff_castinglight")
                inst.sg.statemem.stafflight.Transform:SetPosition(inst.Transform:GetWorldPosition())
                inst.sg.statemem.stafflight:SetUp(colour, 1.9, .33)
            end),
            TimeEvent((13 +16) * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sg.statemem.castsound)
            end),
            TimeEvent((53 +16)  * FRAMES, function(inst)
                local pos = inst:GetPosition()
                local theta = math.random() * 2 * PI
                local radius = 3.5
                local offset = FindWalkableOffset(pos, theta,radius,12, true)
                if offset == nil then
                    offset = Vector3(0,0,0)
                end
                local projectile = SpawnPrefab("ttk_boss_stalker_ziyunfx")
                projectile.Transform:SetPosition((pos+offset):Get())
                projectile:ForceFacePoint(pos)
                projectile:DoSpawn(inst)
                inst.components.timer:StartTimer("skill1",10)
            end),
            TimeEvent((69 +16)  * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
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
        onexit = function(inst)
            spawanfx(inst,inst.sg.statemem.colour)
            inst.AnimState:ClearOverrideSymbol("swap_fb_object")
            inst.AnimState:Hide("ARM_fb_carry")
            inst.AnimState:Show("ARM_fb_normal")
            if inst.sg.statemem.stafffx ~= nil and inst.sg.statemem.stafffx:IsValid() then
                inst.sg.statemem.stafffx:Remove()
            end
            if inst.sg.statemem.stafflight ~= nil and inst.sg.statemem.stafflight:IsValid() then
                inst.sg.statemem.stafflight:Remove()
            end
        end,
    },
	State{
        name = "idle_fly_spell1",
        tags = { "busy", "flying", },
        onenter = function(inst, data)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("xf_fb_item_out")
            inst.AnimState:PushAnimation("xd_fb_staff_pre", false)
            inst.AnimState:PushAnimation("xd_fb_staff", false)
            inst.AnimState:OverrideSymbol("swap_fb_object", "xd_zhf", "swap")
            inst.AnimState:Show("ARM_fb_carry")
            inst.AnimState:Hide("ARM_fb_normal")
            resetphys(inst,true)
            inst.sg.statemem.staff = nil
            inst.sg.statemem.castsound = "dontstarve/wilson/use_gemstaff"
        end,
        onupdate = function(inst, dt)
            local height_target = heigh * 1
            local y = inst:GetPosition().y
            inst.Physics:SetMotorVel(0, (height_target - y)*32, 0)
        end,
        timeline =
        {
            TimeEvent(16 * FRAMES, function(inst)
                local colour = inst.sg.statemem.staff ~= nil and inst.sg.statemem.staff.fxcolour or {167/255,60/255,162/255}
                inst.sg.statemem.stafffx = SpawnPrefab("staffcastfx")
                inst.sg.statemem.stafffx.entity:SetParent(inst.entity)
                inst.sg.statemem.stafffx:SetUp(colour)
                inst.sg.statemem.colour = colour
                inst.sg.statemem.stafflight = SpawnPrefab("staff_castinglight")
                inst.sg.statemem.stafflight.Transform:SetPosition(inst.Transform:GetWorldPosition())
                inst.sg.statemem.stafflight:SetUp(colour, 1.9, .33)
            end),
            TimeEvent((13 +16) * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sg.statemem.castsound)
            end),
            TimeEvent((53 +16)  * FRAMES, function(inst)
                inst.sg.statemem.stafffx = nil
                inst.sg.statemem.stafflight = nil
                for i, v in ipairs(AllPlayers) do
                    if v:IsValid() and inst:IsNear(v,20) and XD_CanAttackTrget(inst,v) then
                        local pos = v:GetPosition()
                        inst:StartThread(function()
                            for k= 1, 2  do
                                local rad = math.random(-180,180)
                                local targetpos = Vector3(pos.x+ 4*math.cos(rad*DEGREES),0,pos.z+4*math.sin(rad*DEGREES))
                                local fx = SpawnAt("ttk_boss_ziyunwarg",targetpos)
                                fx:ForceFacePoint(pos)
                                fx.owner = inst
                                fx.target = v
                                fx.targetpos = pos
                                Sleep(0.8)
                            end
                        end)
                    end
                end
            end),
            TimeEvent((69 +16)  * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },
        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle_fly")
                end
            end),
            EventHandler("gotophase3", function(inst)
                inst.sg:GoToState("fly_down")
            end),
        },
        onexit = function(inst)
            spawanfx(inst,inst.sg.statemem.colour)
            inst.AnimState:ClearOverrideSymbol("swap_fb_object")
            inst.AnimState:Hide("ARM_fb_carry")
            inst.AnimState:Show("ARM_fb_normal")
            if inst.sg.statemem.stafffx ~= nil and inst.sg.statemem.stafffx:IsValid() then
                inst.sg.statemem.stafffx:Remove()
            end
            if inst.sg.statemem.stafflight ~= nil and inst.sg.statemem.stafflight:IsValid() then
                inst.sg.statemem.stafflight:Remove()
            end
            resetphys(inst)
        end,
    },
	State{
        name = "idle_fly_spell2",
        tags = { "busy", "flying", },
        onenter = function(inst, data)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("xf_fb_item_out")
            inst.AnimState:PushAnimation("xd_fb_staff_pre", false)
            inst.AnimState:PushAnimation("xd_fb_staff", false)
            inst.AnimState:Show("ARM_fb_carry")
            inst.AnimState:Hide("ARM_fb_normal")
            SetFxOwner(inst,inst)
            resetphys(inst,true)
            inst.sg.statemem.staff = nil
            inst.sg.statemem.castsound = "dontstarve/wilson/use_gemstaff"
        end,
        onupdate = function(inst, dt)
            local height_target = heigh * 1
            local y = inst:GetPosition().y
            inst.Physics:SetMotorVel(0, (height_target - y)*32, 0)
        end,
        timeline =
        {
            TimeEvent(16 * FRAMES, function(inst)
                local colour = inst.sg.statemem.staff ~= nil and inst.sg.statemem.staff.fxcolour or {230/255,133/255,53/255}
                inst.sg.statemem.stafffx = SpawnPrefab("staffcastfx")
                inst.sg.statemem.stafffx.entity:SetParent(inst.entity)
                inst.sg.statemem.stafffx:SetUp(colour)
                inst.sg.statemem.colour = colour
                inst.sg.statemem.stafflight = SpawnPrefab("staff_castinglight")
                inst.sg.statemem.stafflight.Transform:SetPosition(inst.Transform:GetWorldPosition())
                inst.sg.statemem.stafflight:SetUp(colour, 1.9, .33)
            end),
            TimeEvent((13 +16) * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sg.statemem.castsound)
            end),
            TimeEvent((53 +16)  * FRAMES, function(inst)
                inst.sg.statemem.stafffx = nil
                inst.sg.statemem.stafflight = nil
                for i, v in ipairs(AllPlayers) do
                    if v:IsValid() and inst:IsNear(v,20) and XD_CanAttackTrget(inst,v) then
                        local fx = SpawnAt("ttk_boss_ziyunjfsn_meteor",v)
                        fx.iscanying = true
                        fx:OnSpawnedBy(inst)
                    end
                end
            end),
            TimeEvent((69 +16)  * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },
        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle_fly")
                end
            end),
            EventHandler("gotophase3", function(inst)
                inst.sg:GoToState("fly_down")
            end),
        },
        onexit = function(inst)
            spawanfx(inst,inst.sg.statemem.colour)
            inst.AnimState:Hide("ARM_fb_carry")
            inst.AnimState:Show("ARM_fb_normal")
            SetFxOwner(inst)
            if inst.sg.statemem.stafffx ~= nil and inst.sg.statemem.stafffx:IsValid() then
                inst.sg.statemem.stafffx:Remove()
            end
            if inst.sg.statemem.stafflight ~= nil and inst.sg.statemem.stafflight:IsValid() then
                inst.sg.statemem.stafflight:Remove()
            end
            resetphys(inst)
        end,
    },
}
return StateGraph("ttk_ziyunboss", states, events, "idle", actionhandlers)
