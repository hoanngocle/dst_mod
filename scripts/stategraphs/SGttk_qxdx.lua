-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local XD_CanAttackTrget = Boss.XD_CanAttackTrget
local XD_GetGroundPoints = Boss.XD_GetGroundPoints
local Xd_CalcDamage = Boss.Xd_CalcDamage
require("stategraphs/commonstates")
local hit_recovery_delay = CommonHandlers.HitRecoveryDelay
local heigh = 6
local actionhandlers =
{
}
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
local function DoEatSound(inst, overrideexisting)
    if inst.sg.statemem.doeatingsfx and (overrideexisting or not inst.SoundEmitter:PlayingSound("eating")) then
        inst.SoundEmitter:PlaySound(inst.sg.statemem.isdrink and "dontstarve/wilson/sip" or "dontstarve/wilson/eat", "eating")
    end
end
local function DoTalkSound(inst)
    if inst.talksoundoverride ~= nil then
        inst.SoundEmitter:PlaySound(inst.talksoundoverride, "talk")
        return true
    elseif not inst:HasTag("mime") then
        inst.SoundEmitter:PlaySound((inst.talker_path_override or "dontstarve/characters/")..(inst.soundsname or inst.prefab).."/talk_LP", "talk")
        return true
    end
end
local function StopTalkSound(inst, instant)
    if not instant and inst.endtalksound ~= nil and inst.SoundEmitter:PlayingSound("talk") then
        inst.SoundEmitter:PlaySound(inst.endtalksound)
    end
    inst.SoundEmitter:KillSound("talk")
end
local events=
{
    CommonHandlers.OnLocomote(true, false),
    CommonHandlers.OnDeath(),
	EventHandler("doattack", function(inst, data)
		if inst.components.health ~= nil and not inst.components.health:IsDead() and not inst.sg:HasStateTag("busy") then
            inst.sg:GoToState("attack", data ~= nil and data.target or nil)
		end
	end),
 	EventHandler("transform", function(inst, data)
		if inst.components.health ~= nil and not inst.components.health:IsDead() and not inst.sg:HasStateTag("busy") then
            inst.sg:GoToState("eat")
		end
	end),
    EventHandler("superjump", function(inst,data)
        if inst.components.health ~= nil and not inst.components.health:IsDead() and not inst.sg:HasStateTag("busy") then
            inst.sg:GoToState("superjump_start")
        end
    end),
    EventHandler("spike", function(inst,data)
        if inst.components.health ~= nil and not inst.components.health:IsDead() and not inst.sg:HasStateTag("busy") then
            inst.sg:GoToState("spike")
        end
    end),
    EventHandler("goaway", function(inst,data)
        if inst.components.health ~= nil and not inst.components.health:IsDead() and not inst.sg:HasStateTag("busy") then
            inst.sg:GoToState("goaway")
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
local function doringfx(inst,pt,points,fx1,fx2)
    SpawnPrefab(fx1 or "firering_fx").Transform:SetPosition(pt:Get())
    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/buttstomp")
    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/buttstomp_voice")
    local map = TheWorld.Map
    for i, v1 in ipairs(points) do
        for i,v in ipairs(v1) do
            if map:IsLandTileAtPoint(v:Get()) and not map:IsDockAtPoint(v:Get()) then
                SpawnPrefab(fx2 or "firesplash_fx").Transform:SetPosition(v.x, 0, v.z)
            end
        end
    end
end
local function Spawn17Pattern(inst)
    local cx = inst:GetPosition().x
    local cy = 0
    local cz = inst:GetPosition().z
    local base_rot = 0
    local outer_r = 6
    local inner_r = 3
    local scale = 1
    local points = XD_GetGroundPoints(Vector3(cx,cy,cz))
    inst:DoAoe(8,175,Vector3(cx,cy,cz))
    doringfx(inst,Vector3(cx,cy,cz),points)
    inst:DoTaskInTime(0.3,function()
        inst:DoAoe(8,175,Vector3(cx,cy,cz))
        doringfx(inst,Vector3(cx,cy,cz),points)
    end)
    inst:DoTaskInTime(0.4,function()
        inst:DoAoe(8,175,Vector3(cx,cy,cz))
        doringfx(inst,Vector3(cx,cy,cz),points)
    end)
    local cfx = SpawnPrefab("ttk_boss_jfsn_fire")
    if cfx then
        cfx.Transform:SetPosition(cx, cy, cz)
        cfx.owner = inst
        cfx.doattackfn = function(_,x,y,z)
            inst:DoAoe(3,65,Vector3(x,y,z))
        end
    end
    for i = 0, 7 do
        local angle = base_rot + i * 45
        local rad = angle * DEGREES
        local ox = cx + outer_r * math.cos(rad)
        local oz = cz - outer_r * math.sin(rad)
        local ofx = SpawnPrefab("ttk_boss_jfsn_fire")
        if ofx then
            ofx.Transform:SetPosition(ox, cy, oz)
            ofx.owner = inst
            ofx.doattackfn = function(_,x,y,z)
                inst:DoAoe(3,65,Vector3(x,y,z))
            end
        end
        local ix = cx + inner_r * math.cos(rad)
        local iz = cz - inner_r * math.sin(rad)
        local ifx = SpawnPrefab("ttk_boss_jfsn_fire")
        if ifx then
            ifx.Transform:SetPosition(ix, cy, iz)
            ifx.owner = inst
            ifx.doattackfn = function(_,x,y,z)
                inst:DoAoe(3,65,Vector3(x,y,z))
            end
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
        name = "eat",
		tags = { "busy", "nodangle", "keep_pocket_rummage" },
        onenter = function(inst, foodinfo)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("eat_pre")
            inst.AnimState:PushAnimation("eat", false)
            inst.sg.statemem.doeatingsfx = true
            inst:DoTalk(STRINGS.NAMES.XD_QXDX_TALKS[5])
        end,
        timeline =
        {
			FrameEvent(6, DoEatSound),
        },
        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
					inst.sg:GoToState("transform")
                end
            end),
        },
        onexit = function(inst)
			if inst.sg.statemem.doeatingsfx then
				inst.SoundEmitter:KillSound("eating")
			end
        end,
    },
    State{
        name = "transform",
        tags = {"busy",},
        onenter = function(inst,force)
            SpawnAt("lightning",inst)
            inst.AnimState:OverrideSymbol("shadow_hands", "shadow_skinchangefx", "shadow_hands")
            inst.AnimState:OverrideSymbol("shadow_ball", "shadow_skinchangefx", "shadow_ball")
            inst.AnimState:OverrideSymbol("splode", "shadow_skinchangefx", "splode")
            inst.AnimState:PlayAnimation("skin_change")
        end,
        timeline = {
            TimeEvent(0 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/together/skin_change")
            end),
            TimeEvent(1.5,function(inst)
                if inst.ChangeMode then
                    inst:ChangeMode()
                end
            end)
        },
        events = {
            EventHandler("animover",function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end)
        },
        onexit = function(inst)
        end
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
            inst.components.ttk_boss_sword_controller:DeSummon()
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
	State{
        name = "superjump_start",
        tags = { "attack", "doing", "busy", "nointerrupt", "nomorph","skill" },
        onenter = function(inst,target)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("superjump_pre")
            inst.sg.statemem.target = inst.components.combat.target
            if inst.replica.ttk_boss_xuetiao then
                inst.replica.ttk_boss_xuetiao:SetShow(false)
            end
        end,
        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.AnimState:IsCurrentAnimation("superjump_pre") and inst.sg.statemem.target then
                        inst.AnimState:PlayAnimation("superjump_lag")
                        inst.sg:GoToState("superjump", inst.sg.statemem.target)
                    else
                        inst.sg:GoToState("idle")
                    end
                end
            end),
        },
    },
	State{
        name = "superjump",
        tags = { "attack", "doing", "busy", "nointerrupt", "nopredict", "nomorph" ,"skill"},
        onenter = function(inst, target)
            if target ~= nil and inst.AnimState:IsCurrentAnimation("superjump_lag") then
                inst.AnimState:PlayAnimation("superjump")
                inst.sg.statemem.startingpos = inst:GetPosition()
                inst.sg.statemem.target = target
                inst.components.timer:StartTimer("superjump_cd",18)
                inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt", nil, .4)
                inst.SoundEmitter:PlaySound("dontstarve/common/deathpoof")
                inst.sg:SetTimeout(1)
                inst.components.health:SetInvincible(true)
                return
            end
            inst.sg:GoToState("idle", true)
        end,
        timeline =
        {
             TimeEvent(FRAMES, function(inst)
                 inst.components.health:SetInvincible(true)
             end),
            TimeEvent(7.5 * FRAMES, function(inst)
                local pos
                if inst.sg.statemem.target and inst.sg.statemem.target:IsValid() then
                    pos = inst.sg.statemem.target:GetPosition()
                else
                    pos = inst:GetPosition()
                end
                inst.Physics:Teleport(pos.x, 0, pos.z)
            end),
        },
        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst:Hide()
                end
            end),
        },
        ontimeout = function(inst)
            inst.sg.statemem.superjump = true
            inst.sg:GoToState("superjump_pst")
        end,
        onexit = function(inst)
             if not inst.sg.statemem.superjump then
                inst.components.health:SetInvincible(false)
            end
            inst:Show()
        end,
    },
	State{
        name = "superjump_pst",
        tags = { "attack", "doing", "busy", "nopredict", "nomorph","skill" },
        onenter = function(inst, data)
            inst.AnimState:PlayAnimation("superjump_land")
            inst.components.health:SetInvincible(true)
            inst.sg:SetTimeout(22 * FRAMES)
        end,
        timeline =
        {
            TimeEvent(FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
            end),
            TimeEvent(2 * FRAMES, function(inst)
            end),
            TimeEvent(3 * FRAMES, function(inst)
            end),
            TimeEvent(4 * FRAMES, function(inst)
                ShakeAllCameras(CAMERASHAKE.VERTICAL, .7, .015, .8, inst, 20)
                inst.components.health:SetInvincible(false)
                Spawn17Pattern(inst)
            end),
            TimeEvent(8 * FRAMES, function(inst)
            end),
            TimeEvent(19 * FRAMES, PlayFootstep),
        },
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
        onexit = function(inst)
            inst.components.health:SetInvincible(false)
        end,
    },
	State{
        name = "spike",
        tags = { "busy", "flying", "busy" },
        onenter = function(inst, data)
            inst.AnimState:PlayAnimation("staff_pre")
            inst.AnimState:PushAnimation("staff", false)
            inst.components.locomotor:Stop()
            local colour = { 201/255, 67/255, 30/255 }
            inst.sg.statemem.stafffx = SpawnPrefab("staffcastfx")
            inst.sg.statemem.stafffx.entity:SetParent(inst.entity)
            inst.sg.statemem.stafffx:SetUp(colour)
            inst.sg.statemem.stafflight = SpawnPrefab("staff_castinglight")
            inst.sg.statemem.stafflight.Transform:SetPosition(inst.Transform:GetWorldPosition())
            inst.sg.statemem.stafflight:SetUp(colour, 1.9, .33)
            inst.sg.statemem.castsound = "dontstarve/wilson/use_gemstaff"
        end,
        timeline =
        {
            TimeEvent(13 * FRAMES, function(inst)
                inst:SpawnSpike()
                inst.SoundEmitter:PlaySound(inst.sg.statemem.castsound)
            end),
            TimeEvent(13 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sg.statemem.castsound)
            end),
            TimeEvent(53 * FRAMES, function(inst)
                inst.sg.statemem.stafffx = nil
                inst.sg.statemem.stafflight = nil
            end),
			TimeEvent(69 * FRAMES, function(inst)
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
            if inst.sg.statemem.stafffx ~= nil and inst.sg.statemem.stafffx:IsValid() then
                inst.sg.statemem.stafffx:Remove()
            end
            if inst.sg.statemem.stafflight ~= nil and inst.sg.statemem.stafflight:IsValid() then
                inst.sg.statemem.stafflight:Remove()
            end
        end,
    },
    State{
        name = "talk",
        tags = { "idle", "talking" },
        onenter = function(inst, noanim)
            if not noanim then
                inst.AnimState:PlayAnimation("dial_loop", true)
            end
            DoTalkSound(inst)
            inst.sg:SetTimeout(1.5 + math.random() * .5)
        end,
        ontimeout = function(inst)
            inst.sg:GoToState("idle")
        end,
        events =
        {
            EventHandler("donetalking", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
        onexit = StopTalkSound,
    },
    State{
        name = "goaway",
        tags = { "idle", "talking" },
        onenter = function(inst, noanim)
            -- Encounter reset must retain the registry's original entity.
            inst:ChangeMode(1)
            inst.components.health:SetPercent(1)
            inst.components.combat:SetTarget(nil)
            inst.sg:GoToState("idle")
        end,
    },
}
return StateGraph("ttk_qxdx", states, events, "idle", actionhandlers)
