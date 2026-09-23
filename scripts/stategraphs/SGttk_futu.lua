-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
require("stategraphs/commonstates")
local function GetScalePercent(inst)
    return (inst.components.scaler.scale - TUNING.ROCKY_MIN_SCALE) / (TUNING.ROCKY_MAX_SCALE - TUNING.ROCKY_MIN_SCALE)
end
local function PlayLobSound(inst, sound)
    inst.SoundEmitter:PlaySoundWithParams(sound, {size=1})
end
local actionhandlers =
{
}
local function isinrange(inst,target,rad)
    local ang = inst.Transform:GetRotation()
    local x,y,z = target.Transform:GetWorldPosition()
    local angle = inst:GetAngleToPoint( x,0,z )
    local drot = math.abs( ang - angle )
    while drot > 180 do
        drot = math.abs(drot - 360)
    end
    return drot < rad
end
local function skilladd(inst,time)
	inst.components.timer:StopTimer("skill")
	inst.components.timer:StartTimer("skill", time or 12)
    if inst.skillmode then
        inst.skillmode = inst.skillmode%8 + 1
    end
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
local events =
{
    CommonHandlers.OnLocomote(false, true),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
    EventHandler("entershield", function(inst) inst.sg:GoToState("shield_start") end),
    EventHandler("exitshield", function(inst) inst.sg:GoToState("shield_end") end),
    EventHandler("locomote", function(inst)
        if inst.sg:HasStateTag("shield") then
            inst.sg:GoToState("shield_end")
            return
        end
        local can_run = false
        local can_walk = true
        local is_moving = inst.sg:HasStateTag("moving")
        local is_running = inst.sg:HasStateTag("running")
        local is_idling = inst.sg:HasStateTag("idle")
        local should_move = inst.components.locomotor:WantsToMoveForward()
        local should_run = inst.components.locomotor:WantsToRun()
        if is_moving and not should_move then
            inst.sg:GoToState(is_running and "run_stop" or "walk_stop")
        elseif (is_idling and should_move) or (is_moving and should_move and is_running ~= should_run and can_run and can_walk) then
            if can_run and (should_run or not can_walk) then
                inst.sg:GoToState("run_start")
            elseif can_walk then
                inst.sg:GoToState("walk_start")
            end
        end
    end)
}
local function pickrandomstate(inst, choiceA, choiceB, chance)
	if math.random() >= chance then
		inst.sg:GoToState(choiceA)
	else
		inst.sg:GoToState(choiceB)
	end
end
local states =
{
	State{
		name = "idle_tendril",
		tags = {"idle", "canrotate"},
        onenter = function(inst, playanim)
            if inst.sg:HasStateTag("shield") then
                inst.sg:GoToState("shield_end")
                return
            end
            inst.Physics:Stop()
            if playanim then
                inst.AnimState:PlayAnimation(playanim)
                inst.AnimState:PushAnimation("idle_tendrils")
            else
                inst.AnimState:PlayAnimation("idle_tendrils")
            end
        end,
        timeline =
        {
            TimeEvent(5*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/idle") end),
            TimeEvent(20*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/idle") end),
        },
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
	},
    State{
        name = "taunt1",
        tags = {"busy"},
        onenter = function(inst)
            if inst.sg:HasStateTag("shield") then
                inst.sg:GoToState("shield_end")
                return
            end
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley")
            PlayLobSound(inst, "dontstarve/creatures/rocklobster/taunt")
        end,
        timeline =
        {
            TimeEvent(10*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
            TimeEvent(30*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
        },
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
    State{
        name = "rocklick",
        tags = {"busy"},
        onenter = function(inst)
            if inst.sg:HasStateTag("shield") then
                inst.sg:GoToState("shield_end")
                return
            end
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("rocklick_pre")
            inst.AnimState:PushAnimation("rocklick_loop")
            inst.AnimState:PushAnimation("rocklick_pst", false)
        end,
        timeline =
        {
            TimeEvent(5*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
            TimeEvent(10*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/attack") end),
            TimeEvent(20*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
            TimeEvent(25*FRAMES, function(inst) inst:PerformBufferedAction() end ),
            TimeEvent(35*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
        },
        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
    State{
        name = "gohome",
        tags = {"busy", "hiding"},
        onenter = function(inst)
            inst:StopBrain()
            inst.AnimState:PlayAnimation("hide")
            PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley")
            PlayLobSound(inst, "dontstarve/creatures/rocklobster/hide")
            inst.Physics:Stop()
        end,
        timeline =
        {
            TimeEvent(2*FRAMES, function(inst)
                SpawnAt("ttk_boss_bigspawn_fx_medium_static",inst)
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
            EventHandler("animover", function(inst)
                inst:RestartBrain()
                inst.sg:GoToState("shield")
            end ),
        },
    },
    State{
        name = "shield_start",
        tags = {"busy", "hiding"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("hide")
            PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley")
            PlayLobSound(inst, "dontstarve/creatures/rocklobster/hide")
            inst.Physics:Stop()
        end,
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("shield") end ),
        },
    },
    State{
        name = "shield",
        tags = {"busy", "hiding","shield"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("hide_loop")
            inst.sg:SetTimeout(3)
        end,
        onexit = function(inst)
        end,
        ontimeout = function(inst)
            inst.sg:GoToState("shield")
        end,
        timeline =
        {
            TimeEvent(20*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/sleep") end),
        },
    },
    State{
        name = "shield_end",
        tags = {"busy", "hiding"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("unhide")
            PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley")
        end,
        timeline =
        {
            TimeEvent(10*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
        },
        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },
    State{
        name = "attack",
        tags = { "attack", "busy" },
        onenter = function(inst, target)
            if inst.sg:HasStateTag("shield") then
                inst.sg:GoToState("shield_end")
                return
            end
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("atk")
            inst.components.combat:StartAttack()
            inst.sg.statemem.target = target
        end,
        timeline =
        {
            TimeEvent(0*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
            TimeEvent(0*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/attack") end),
            TimeEvent(5*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
            TimeEvent(8*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/rocklobster/clawsnap_small") end),
            TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/rocklobster/clawsnap_small") end),
            TimeEvent(13*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/rocklobster/attack_whoosh") end),
            TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/rocklobster/clawsnap") end),
            TimeEvent(20*FRAMES, function(inst) inst.components.combat:DoAttack() end),
            TimeEvent(25*FRAMES, function(inst)
                if inst:HasTag("epic") then
                    local fx = SpawnAt("ttk_boss_ws_fx", inst)
                    fx.Transform:SetRotation(inst.Transform:GetRotation())
                    PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley")
                    inst:DoAoeDamage(5,40,function(inst,target)
                        return isinrange(inst,target,45)
                    end)
                end
            end),
            TimeEvent(30*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
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
        name = "hit",
        tags = { "hit", "busy" },
        onenter = function(inst)
            if inst.sg:HasStateTag("shield") then
                inst.sg:GoToState("shield_end")
                return
            end
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end
            local hitanim = "hit"
            if inst:HasTag("hiding") then
                hitanim = "hide_hit"
            end
            inst.AnimState:PlayAnimation(hitanim)
            inst._last_hitreact_time = GetTime()
        end,
        timeline = {
            TimeEvent(0*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/hurt") end),
            TimeEvent(0*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
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
        name = "death",
        tags = { "busy" },
        onenter = function(inst)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("death")
            RemovePhysicsColliders(inst)
            inst.components.lootdropper:DropLoot(inst:GetPosition())
        end,
        events =
        {
            EventHandler("animover", function(inst)
            end),
        },
        timeline = {
            TimeEvent(0*FRAMES, function(inst)
                PlayLobSound(inst, "dontstarve/creatures/rocklobster/death")
                PlayLobSound(inst, "dontstarve/creatures/rocklobster/explode")
            end),
        },
    },
    State{
        name = "parasite_revive",
        tags = {"busy"},
        onenter = function(inst)
            if inst.sg:HasStateTag("shield") then
                inst.sg:GoToState("shield_end")
                return
            end
            inst.AnimState:PlayAnimation("parasite_death_pst")
            inst.Physics:Stop()
        end,
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },
    State{
        name = "skill1",
        tags = {"busy"},
        onenter = function(inst)
            if inst.sg:HasStateTag("shield") then
                inst.sg:GoToState("shield_end")
                return
            end
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("curious")
            skilladd(inst,20)
        end,
        timeline =
        {
            TimeEvent(5*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
            TimeEvent(10*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/attack") end),
            TimeEvent(20*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
            TimeEvent(25*FRAMES, function(inst) inst:StartYunShi() end ),
            TimeEvent(35*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
        },
        events=
        {
            EventHandler("animover", function(inst)
                if inst.skillmode == 2 then
                    inst.sg:GoToState("skill3")
                elseif inst.skillmode == 6 then
                    inst.sg:GoToState("skill4")
                else
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },
    State{
        name = "skill2",
        tags = {"busy"},
        onenter = function(inst,target)
            if inst.sg:HasStateTag("shield") then
                inst.sg:GoToState("shield_end")
                return
            end
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            inst.AnimState:PushAnimation("atk",false)
            PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley")
            PlayLobSound(inst, "dontstarve/creatures/rocklobster/taunt")
            inst.sg.statemem.target = target
        end,
        timeline =
        {
            TimeEvent(10*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
            TimeEvent(30*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
            TimeEvent(61*FRAMES, function(inst)
                if inst.sg.statemem.target and inst.sg.statemem.target:IsValid() and inst.sg.statemem.target.Transform then
                    inst:ForceFacePoint(inst.sg.statemem.target.Transform:GetWorldPosition())
                end
                PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley")
            end),
            TimeEvent(61*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/attack") end),
            TimeEvent(66*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
            TimeEvent(69*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/rocklobster/clawsnap_small") end),
            TimeEvent(73*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/rocklobster/clawsnap_small") end),
            TimeEvent(74*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/rocklobster/attack_whoosh") end),
            TimeEvent(81*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/rocklobster/clawsnap") end),
            TimeEvent(81*FRAMES, function(inst) inst:SpawnSinkHole() end),
            TimeEvent(86*FRAMES, function(inst)  PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
            TimeEvent(91*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
        },
        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("skill2_pst",inst.sg.statemem.target) end),
        },
    },
    State{
        name = "skill2_pst",
        tags = {"busy" },
        onenter = function(inst, target)
            if inst.sg:HasStateTag("shield") then
                inst.sg:GoToState("shield_end")
                return
            end
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("atk")
            if target and target:IsValid() and target.Transform then
                inst.sg.statemem.target = target
                inst:ForceFacePoint(target.Transform:GetWorldPosition())
            end
            skilladd(inst,20)
        end,
        timeline =
        {
            TimeEvent(0*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
            TimeEvent(0*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/attack") end),
            TimeEvent(5*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
            TimeEvent(8*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/rocklobster/clawsnap_small") end),
            TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/rocklobster/clawsnap_small") end),
            TimeEvent(13*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/rocklobster/attack_whoosh") end),
            TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/rocklobster/clawsnap") end),
            TimeEvent(20*FRAMES, function(inst) inst:SpawnSinkHole() end),
            TimeEvent(30*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
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
        name = "skill3",
        tags = {"busy"},
        onenter = function(inst)
            if inst.sg:HasStateTag("shield") then
                inst.sg:GoToState("shield_end")
                return
            end
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley")
            PlayLobSound(inst, "dontstarve/creatures/rocklobster/taunt")
            skilladd(inst,20)
        end,
        timeline =
        {
            TimeEvent(10*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
            TimeEvent(0.8, function(inst)
                inst.sg.statemem.targets = findlungeplayers(inst,4)
            end),
            TimeEvent(30*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
            TimeEvent(1.32, function(inst)
                if inst.sg.statemem.targets and next(inst.sg.statemem.targets) ~= nil then
                    inst:SpawnSandSpike(inst.sg.statemem.targets)
                end
            end),
        },
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
    State{
        name = "skill4",
        tags = {"busy"},
        onenter = function(inst)
            if inst.sg:HasStateTag("shield") then
                inst.sg:GoToState("shield_end")
                return
            end
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley")
            PlayLobSound(inst, "dontstarve/creatures/rocklobster/taunt")
            skilladd(inst,20)
        end,
        timeline =
        {
            TimeEvent(10*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
            TimeEvent(0.8, function(inst)
                inst.sg.statemem.targets = findlungeplayers(inst,4)
            end),
            TimeEvent(30*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
            TimeEvent(1.32, function(inst)
                if inst.sg.statemem.targets and next(inst.sg.statemem.targets) ~= nil then
                    inst:SpawnRock(inst.sg.statemem.targets)
                end
            end),
        },
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
    State{
        name = "skill5",
        tags = {"busy"},
        onenter = function(inst)
            if inst.sg:HasStateTag("shield") then
                inst.sg:GoToState("shield_end")
                return
            end
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley")
            PlayLobSound(inst, "dontstarve/creatures/rocklobster/taunt")
            skilladd(inst,10)
        end,
        timeline =
        {
            TimeEvent(10*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
            TimeEvent(0.88, function(inst)
                inst.sg.statemem.targets = findlungeplayers(inst,4)
            end),
            TimeEvent(30*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
            TimeEvent(1.38, function(inst)
                if inst.sg.statemem.targets and next(inst.sg.statemem.targets) ~= nil then
                    inst:SpawnSandSpikeSmall(inst.sg.statemem.targets)
                end
            end),
        },
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
}
CommonStates.AddWalkStates(states,
{
    starttimeline =  {
        TimeEvent(0*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
    },
	walktimeline = {
        TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/rocklobster/footstep") end),
        TimeEvent(8*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/rocklobster/footstep") end),
        TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/rocklobster/footstep") end),
        TimeEvent(15*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
        TimeEvent(26*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/rocklobster/footstep") end),
        TimeEvent(30*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/rocklobster/footstep") end),
    },
    endtimeline = {
        TimeEvent(0*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
    },
})
CommonStates.AddIdle(states, "idle_tendril", nil ,
{
    TimeEvent(5*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
    TimeEvent(30*FRAMES, function(inst) PlayLobSound(inst,"dontstarve/creatures/rocklobster/foley") end),
})
return StateGraph("ttk_futu", states, events, "idle", actionhandlers)
