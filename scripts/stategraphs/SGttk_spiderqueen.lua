-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local XD_GetGroundPoints = Boss.XD_GetGroundPoints
require("stategraphs/commonstates")
local actionhandlers =
{
}
local events=
{
    EventHandler("attacked", function(inst)
        if not inst.components.health:IsDead() and not inst.sg:HasStateTag("nointerrupt") and not inst.sg:HasStateTag("attack")
        then inst.sg:GoToState("hit")
    end end),
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
    EventHandler("doattack", function(inst) if not inst.components.health:IsDead() and (inst.sg:HasStateTag("hit") or not inst.sg:HasStateTag("busy")) then inst.sg:GoToState("attack") end end),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnLocomote(false,true),
}
local function skilladd(inst,time)
	inst.components.timer:StopTimer("skill")
	inst.components.timer:StartTimer("skill", time or 12)
	inst.skillmode = inst.skillmode%4 + 1
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
	return targets
end
local function NoHoles(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
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
        inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
		inst.Physics:CollidesWith(COLLISION.CHARACTERS)
		inst.Physics:CollidesWith(COLLISION.GIANTS)
	end
end
local function GetDistanceToPoint(inst,x, y, z)
    if x and not y and not z then
        x, y, z = x:Get()
    end
    local x1, y1, z1 = inst.Transform:GetWorldPosition()
    if x1 == x and z1 == z then
        return 0
    end
    return math.sqrt((x - x1) ^ 2 + (y - y1) ^ 2 + (z - z1) ^ 2)
end
local states=
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(inst, playanim)
            inst.Physics:Stop()
			inst.AnimState:PlayAnimation("idle", true)
			if math.random() < .2 then
				inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/scream_short")
			end
        end,
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
    State{
        name = "attack",
        tags = {"attack", "nointerrupt"},
        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("atk")
        end,
        timeline=
        {
            TimeEvent(0*FRAMES, function(inst) inst:PerformBufferedAction() inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/attack") end),
            TimeEvent(25*FRAMES, function(inst) inst:PerformBufferedAction() inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/attack_grunt") end),
            TimeEvent(28*FRAMES, function(inst) inst:PerformBufferedAction() inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/swipe") end),
            TimeEvent(28*FRAMES, function(inst)
                inst.components.combat:DoAttack()
            end),
        },
        events=
        {
            EventHandler("animover", function(inst)inst.sg:GoToState("idle") end),
        },
    },
  	State{
		name = "hit",
        tags = {"busy", "hit"},
        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/hurt")
        end,
        events=
        {
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
	State{
		name = "taunt",
        tags = {"busy"},
        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/scream")
        end,
        events=
        {
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
	State{
		name = "skill1",
        tags = {"attack","busy"},
        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/scream")
        end,
		timeline =
		{
			FrameEvent(14, function(inst)
                skilladd(inst)
				local players = findlungeplayers(inst)
				for _, v in ipairs(players) do
                    v:AddDebuff("ttk_boss_spiderqueen_buff1","ttk_boss_spiderqueen_buff1")
                    local buff = v:GetDebuff("ttk_boss_spiderqueen_buff1")
                    if buff then
                        buff.owner = inst
                    end
				end
			end),
        },
        events=
        {
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
	State{
		name = "skill2",
        tags = {"attack","busy"},
        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/scream")
        end,
		timeline =
		{
			FrameEvent(14, function(inst)
                skilladd(inst)
				local players = findlungeplayers(inst,2)
				for _, v in ipairs(players) do
                    v:AddDebuff("ttk_boss_spiderqueen_buff2","ttk_boss_spiderqueen_buff2")
                    local buff = v:GetDebuff("ttk_boss_spiderqueen_buff2")
                    if buff then
                        buff.owner = inst
                    end
				end
			end),
        },
        events=
        {
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
	State{
		name = "skill3",
        tags = {"attack","busy"},
        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            inst.AnimState:PlayAnimation("enter")
			inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/emerge_voice")
			inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/emerge_foley")
            inst.AnimState:PushAnimation("poop_pre")
            inst.AnimState:PushAnimation("poop_loop")
            resetphys(inst,true)
            local target = inst.components.combat.target
            if target and target:IsValid() then
                inst:StopBrain()
                inst.sg.statemem.stopbrain = true
                local theta = math.random() * TWOPI
                local pt = target:GetPosition()
                local radius = math.random(3,4)
                local offset = FindWalkableOffset(pt, theta, radius, 12)
                local pos = pt + (offset or Vector3(0, 0, 0))
                inst:ForceFacePoint(pos)
                inst.sg.statemem.speed = GetDistanceToPoint(inst,pos)/(23* FRAMES)
                inst.Physics:SetMotorVel(inst.sg.statemem.speed, 0, 0)
            end
            skilladd(inst,20)
            inst.sg.statemem.players = {}
        end,
		onupdate = function(inst)
			if inst.sg.statemem.speed ~= nil then
				inst.Physics:SetMotorVel(inst.sg.statemem.speed, 0, 0)
			end
		end,
		timeline =
		{
			FrameEvent(23, function(inst)
                inst.sg.statemem.speed = 0
                if inst.sg.statemem.stopbrain then
                    inst:RestartBrain()
                end
                resetphys(inst)
                inst.Physics:Stop()
                local pt = inst:GetPosition()
                SpawnAt("groundpoundring_fx",pt)
                local points = XD_GetGroundPoints(pt,3)
                local map = TheWorld.Map
                for i, v1 in ipairs(points) do
                    for i,v in ipairs(v1) do
                        if map:IsLandTileAtPoint(v:Get()) and not map:IsDockAtPoint(v:Get()) then
                            SpawnPrefab("groundpound_fx").Transform:SetPosition(v.x, 0, v.z)
                        end
                    end
                end
                inst:DoAoeDamage(32,10,function(inst,target)
                    return target.isplayer
                end,function(inst,target)
                    if not IsEntityDeadOrGhost(target) then
                        target:AddDebuff("ttk_boss_spiderqueen_buff3","ttk_boss_spiderqueen_buff3")
                        table.insert(inst.sg.statemem.players,target)
                    end
                end)
                local max =  0
                for k = 1, 10 do
                    local theta = math.random() * 2 * PI
                    local radius = GetRandomMinMax(16,18)
                    local result_offset = FindValidPositionByFan(theta, radius, 24, function(offset)
                        local pos = pt + offset
                        return #TheSim:FindEntities(pos.x, 0, pos.z, 6, {"ttk_boss_spiderqueen_rock"}) <= 0
                            and TheWorld.Map:IsPassableAtPoint(pos:Get())
                            and NoHoles(pt)
                    end)
                    if result_offset then
                        local fx = SpawnAt("ttk_boss_spiderqueen_rock",result_offset+pt)
                        fx.AnimState:PlayAnimation("emerge")
						fx.AnimState:PushAnimation("full")
                        fx.owner = inst
                        max = max + 1
                        if max >= 2 then
                            return
                        end
                    end
                end
			end),
            FrameEvent(34, function(inst)
                inst.sg.statemem.fx = SpawnAt("ttk_boss_cl_tornadofx",inst)
                inst.sg.statemem.fx.Transform:SetScale(1, 1, 1)
                inst.sg.statemem.fx.AnimState:SetMultColour(255/255,255/255,255/255,0.7)
                inst.sg.statemem.fx:DoTaskInTime(5,inst.sg.statemem.fx.Remove)
			end),
            FrameEvent(166, function(inst)
                inst.AnimState:PlayAnimation("poop_pst")
                inst.AnimState:PushAnimation("taunt",false)
			end),
            FrameEvent(184, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/scream")
			end),
            FrameEvent(204, function(inst)
                for _, v in ipairs(inst.sg.statemem.players) do
                    if v and v:IsValid() and inst:IsNear(v,40) then
                        local fx = SpawnAt("ttk_boss_spiderqueen_pro",inst)
                        fx:DoThrow(inst,v)
                    end
				end
			end),
        },
        events =
        {
			EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() and inst.AnimState:IsCurrentAnimation("taunt") then
                    inst.sg:GoToState("skill3attack")
                end
            end),
        },
        onexit = function(inst)
            if inst.sg.statemem.fx and inst.sg.statemem.fx:IsValid() then
                inst.sg.statemem.fx:Remove()
            end
            if inst.sg.statemem.stopbrain then
                inst:RestartBrain()
            end
            if inst.sg.statemem.isphysicstoggle then
                resetphys(inst)
            end
        end,
    },
    State{
        name = "skill3attack",
        tags = {"attack","busy","nointerrupt"},
        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("atk")
        end,
        timeline=
        {
            TimeEvent(0*FRAMES, function(inst) inst:PerformBufferedAction() inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/attack") end),
            TimeEvent(25*FRAMES, function(inst) inst:PerformBufferedAction() inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/attack_grunt") end),
            TimeEvent(28*FRAMES, function(inst) inst:PerformBufferedAction() inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/swipe") end),
            TimeEvent(28*FRAMES, function(inst)
                inst:DoAoeDamage(6,235,function(inst,target)
                    return true
                end,function(inst,target)
                end)
            end),
        },
        events=
        {
            EventHandler("animover", function(inst)inst.sg:GoToState("idle") end),
        },
    },
	State{
		name = "gohome",
        tags = {"busy"},
        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/scream")
            inst.components.health:SetInvincible(true)
            inst:AddTag("notarget")
        end,
		timeline =
		{
			FrameEvent(14, function(inst)
                local pos = inst.components.knownlocations:GetLocation("spawnpoint")
                if pos then
                    if inst.Physics ~= nil then
                        inst.Physics:Teleport(pos.x, 0, pos.z)
                    elseif inst.Transform ~= nil then
                        inst.Transform:SetPosition(pos.x, 0, pos.z)
                    end
                end
			end),
        },
        events=
        {
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
        onexit = function(inst)
            inst:RemoveTag("notarget")
            inst.components.health:SetInvincible(false)
        end,
    },
	State{
		name = "makenest",
        tags = {"busy", "nointerrupt"},
        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("cocoon")
        end,
		timeline=
        {
            TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/scream") end),
        },
        events=
        {
			EventHandler("animover", function(inst)
				inst.Physics:ClearCollisionMask()
				inst:Remove()
				local den = SpawnPrefab("spiderden")
				den.AnimState:PlayAnimation("cocoon_small")
				den.Transform:SetPosition(inst.Transform:GetWorldPosition())
			end),
        },
    },
	State{
		name = "birth",
        tags = {"busy", "nointerrupt"},
        onenter = function(inst, cb)
            inst.AnimState:PlayAnimation("enter")
			inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/emerge_voice")
			inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/emerge_foley")
		end,
		timeline=
        {
        },
        events=
        {
			EventHandler("animover", function(inst)
				inst.sg:GoToState("idle")
			end),
        },
    },
	State{
		name = "poop_pre",
        tags = {"busy", "nointerrupt"},
        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("poop_pre")
        end,
        timeline=
        {
            TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/scream_short") end),
        },
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("poop_loop") end),
        },
    },
    State{
        name = "poop_loop",
        tags = {"busy", "nointerrupt"},
        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.components.locomotor:Stop()
            local angle = TheCamera:GetHeadingTarget()*DEGREES
            inst.Transform:SetRotation(angle / DEGREES)
            inst.AnimState:PlayAnimation("poop_loop")
        end,
        timeline=
        {
            TimeEvent(4*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/givebirth_voice") end),
            TimeEvent(8*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/givebirth_foley") end),
            TimeEvent(10*FRAMES, function(inst)
                if inst.components.incrementalproducer then
                    inst.components.incrementalproducer:TryProduce()
                end
            end),
        },
        events=
        {
            EventHandler("animover", function(inst)
                if inst.components.incrementalproducer and inst.components.incrementalproducer:CanProduce() then
                    inst.sg:GoToState("poop_loop")
                else
                    inst.sg:GoToState("poop_pst")
                end
            end),
        },
    },
    State{
        name = "poop_pst",
        tags = {"busy", "nointerrupt"},
        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.components.locomotor:Stop()
            local angle = TheCamera:GetHeadingTarget()*DEGREES
            inst.Transform:SetRotation(angle / DEGREES)
            inst.AnimState:PlayAnimation("poop_pst")
        end,
        events=
        {
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
	State{
        name = "death",
        tags = {"busy"},
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/die")
            inst.AnimState:PlayAnimation("death")
            inst.components.locomotor:StopMoving()
            RemovePhysicsColliders(inst)
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))
        end,
    },
}
CommonStates.AddWalkStates(states,
{
	walktimeline = {
		TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/walk_spiderqueen") end),
		TimeEvent(7*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/walk_spiderqueen") end),
		TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/walk_spiderqueen") end),
		TimeEvent(13*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/walk_spiderqueen") end),
		TimeEvent(17*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/walk_spiderqueen") end),
		TimeEvent(25*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/walk_spiderqueen") end),
		TimeEvent(32*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/walk_spiderqueen") end),
		TimeEvent(38*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/walk_spiderqueen") end),
	},
})
return StateGraph("ttk_spiderqueen", states, events, "idle", actionhandlers)
