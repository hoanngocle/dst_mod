require("stategraphs/commonstates")

local actionhandlers =
{
    
    ActionHandler(ACTIONS.GOHOME, function(inst) return "gohome" end),
}

local function go_to_idle(inst)
    inst.sg:GoToState("idle")
end

local events=
{
    CommonHandlers.OnStep(),
    CommonHandlers.OnLocomote(true,true),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    EventHandler("death", function(inst)
        inst.sg:GoToState("death")
    end),
    EventHandler("attacked", function(inst) if not inst.components.health:IsDead() and not inst.sg:HasStateTag("attack") then inst.sg:GoToState("hit") end end),
}

local states=
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},

        onenter = function(inst, pushanim)
            inst.components.locomotor:StopMoving()
            if pushanim then
                inst.AnimState:PushAnimation("idle_loop", true)
            else
                inst.AnimState:PlayAnimation("idle_loop", true)
            end
            local time = 1 + 1*math.random()
            inst.sg:SetTimeout(time)
        end,

        timeline = {
            TimeEvent(5*FRAMES, function(inst) inst.didalertnoise = nil end),
        },

        ontimeout = function(inst)
            local rand = math.random()
            if inst:HasTag("hitched") then
                if rand < 0.75 then
                    inst.sg:GoToState("shake")
                elseif rand < 0.25 and (not TheWorld.components.yotb_stagemanager or not TheWorld.components.yotb_stagemanager:IsContestActive()) then
                    inst.sg:GoToState("bellow")
                else
                    inst.sg:GoToState("idle")
                end
            else
                if rand < 0.5 then
                    inst.sg:GoToState("graze_empty")
                elseif rand < 0.75 then
                    inst.sg:GoToState("shake")
                else
                    inst.sg:GoToState("bellow")
                end
            end
        end,
    },

    State{
        name = "shake",
        tags = {"idle", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("shake")
        end,

        events=
        {
            EventHandler("animover", go_to_idle),
        },
    },

    State{
        name = "badfood",
        tags = {"busy"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("intestinal_cramp")
        end,

        events=
        {
            EventHandler("animover", go_to_idle),
        },
    },

    State{
        name = "pleased",
        tags = {"canrotate"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("brush")
            inst.SoundEmitter:PlaySound("dontstarve/beefalo/positive")
        end,

        events=
        {
            EventHandler("animover", go_to_idle),
        },
    },

    State{
        name = "meh",
        tags = {"canrotate"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("shake")
        end,

        events=
        {
            EventHandler("animover", go_to_idle),
        },
    },

    State{
        name = "beg",
        tags = {"canrotate"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("beg_pre")
            inst.AnimState:PushAnimation("beg_loop")
            inst.AnimState:PushAnimation("beg_loop")
            inst.AnimState:PushAnimation("beg_pst", false)
        end,

        timeline=
        {
            TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/beefalo/beg") end),
        },

        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("actual_alert") end),
        },
    },

    State{
        name = "bellow",
        tags = {"canrotate"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("bellow")
            inst.SoundEmitter:PlaySound(inst.sounds.grunt)
        end,

        events=
        {
            EventHandler("animover", go_to_idle),
        },
    },

    State{
        name = "matingcall",
        tags = {},
        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("mating_taunt1")
            inst.SoundEmitter:PlaySound(inst.sounds.yell)
        end,
        events=
        {
            EventHandler("animover", go_to_idle),
        },
    },

    State{
        name = "tailswish",
        tags = {},
        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("mating_taunt2")
        end,

        timeline=
        {
            TimeEvent(22*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.swish) end),
            TimeEvent(32*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.swish) end),
        },

        events=
        {
            EventHandler("animover", go_to_idle),
        },
    },

    State{
        name = "idle_carrat",
        tags = {},
        onenter = function(inst)
            inst.AnimState:AddOverrideBuild("carrat_build")
            inst.setcarratart(inst)
            inst.components.locomotor:StopMoving()
            if math.random() < 0.5 then
                inst.AnimState:PlayAnimation("carrat_idle1")
                inst.sg.statemem.idlenum = 1
            else
                inst.AnimState:PlayAnimation("carrat_idle_2")
                inst.sg.statemem.idlenum = 2
            end
        end,

        onexit = function(inst)
            inst.AnimState:ClearOverrideBuild("carrat_build")
        end,

        timeline=
        {
            
            TimeEvent(41*FRAMES, function(inst) if inst.sg.statemem.idlenum == 1 then inst.SoundEmitter:PlaySound("turnoftides/creatures/together/carrat/reaction") end end),
            TimeEvent(99*FRAMES, function(inst) if inst.sg.statemem.idlenum == 1 then inst.SoundEmitter:PlaySound("turnoftides/creatures/together/carrat/reaction") end end),
            TimeEvent(119*FRAMES, function(inst) if inst.sg.statemem.idlenum == 1 then inst.SoundEmitter:PlaySound("turnoftides/creatures/together/carrat/reaction") end end),
            TimeEvent(174*FRAMES, function(inst) if inst.sg.statemem.idlenum == 1 then inst.SoundEmitter:PlaySound("dontstarve/beefalo/hairgrow_vocal") end end),
            
            TimeEvent(45*FRAMES, function(inst) if inst.sg.statemem.idlenum == 2 then inst.SoundEmitter:PlaySound("turnoftides/creatures/together/carrat/eat") end end),
            TimeEvent(81*FRAMES, function(inst) if inst.sg.statemem.idlenum == 2 then inst.SoundEmitter:PlaySound("turnoftides/creatures/together/carrat/eat") end end),
            TimeEvent(130*FRAMES, function(inst) if inst.sg.statemem.idlenum == 2 then inst.SoundEmitter:PlaySound("turnoftides/creatures/together/carrat/reaction") end end),

        },

        events=
        {
            EventHandler("animover", function(inst)
                inst.testforcarratexit(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name="graze",
        tags = {"canrotate"},

        onenter = function(inst, data)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("graze_loop", true)
            inst.sg:SetTimeout(1+math.random()*5)
        end,

        ontimeout = go_to_idle,

    },

    State{
        name="graze_empty",
        tags = {"canrotate"},

        onenter = function(inst, data)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("graze2_pre")
            inst.AnimState:PushAnimation("graze2_loop")
            inst.sg:SetTimeout(1+math.random()*5)
        end,

        ontimeout= function(inst)
            inst.AnimState:PlayAnimation("graze2_pst")
            inst.sg:GoToState("idle", true)
        end,

    },

    State{
        name="flatulate",
        tags = {"busy"},

        onenter = function(inst, data)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("fart")
        end,

        timeline =
        {
            TimeEvent(9*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/beefalo/fart") end),
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/beefalo/tail_swish_fast") end),
        },

        events=
        {
            EventHandler("animqueueover", go_to_idle),
        },

    },

    State{
        name = "death",
        tags = {"busy"},

        onenter = function(inst)
            inst.SoundEmitter:PlaySound(inst.sounds.yell)
            inst.AnimState:PlayAnimation("death")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)
            inst.components.lootdropper:DropLoot(inst:GetPosition())

            inst:DoTaskInTime(2, ErodeAway)
        end,
    },

    State{
        name = "refuse",
        tags = {"busy"},

        onenter = function (inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("shake")
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
        name = "run_start",
        tags = { "moving", "running", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:RunForward()
            local hastarget = inst.components.combat ~= nil and inst.components.combat:HasTarget()
            inst.AnimState:PlayAnimation(hastarget and "run_pre" or "run2_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("run")
            end),
        },
    },

    State{
        name = "run",
        tags = { "moving", "running", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:RunForward()
            local hastarget = inst.components.combat ~= nil and inst.components.combat:HasTarget()
            inst.AnimState:PlayAnimation(hastarget and "run_loop" or "run2_loop", true)
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        timeline = {
            TimeEvent(1*FRAMES, function(inst) inst.didalertnoise = nil end),
            TimeEvent(5*FRAMES, PlayFootstep),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("run")
        end,
    },

    State{
        name = "run_stop",
        tags = { "idle" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            local hastarget = inst.components.combat ~= nil and inst.components.combat:HasTarget()
            inst.AnimState:PlayAnimation(hastarget and "run_pst" or "run2_pst")
        end,

        events =
        {
            EventHandler("animover", go_to_idle),
        },
    },

    State{
        name = "gohome",
		tags = {"busy"},
        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("idle")
            inst.SoundEmitter:PlaySound(inst.sounds.grunt)
        end,

        timeline =
        {
            TimeEvent(0.5, function(inst) 
                inst.SoundEmitter:PlaySound("dontstarve/common/pighouse_door")
                inst:PerformBufferedAction() 
                inst.sg:GoToState("idle") end),
        },
    },
    State{
        name = "shaved",
        tags = {"busy", "sleeping"},

        onenter = function(inst)
            inst:ApplyBuildOverrides(inst.AnimState)
            inst.AnimState:PlayAnimation("shave")
        end,

        events=
        {
            EventHandler("animover", function(inst)
                if inst.components.sleeper and inst.components.sleeper:IsAsleep() then
                    inst.sg:GoToState("sleeping")
                else
                    inst.sg:GoToState("wake")
                end
            end),
        },
    },
}

CommonStates.AddWalkStates(
    states,
    {
        walktimeline =
        {
            TimeEvent(1*FRAMES, function(inst) inst.didalertnoise = nil end),
            TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.walk) end),
            TimeEvent(40*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.walk) end),
        }
    })

CommonStates.AddSimpleState(states,"hit", "hit")
CommonStates.AddFrozenStates(states)
CommonStates.AddSleepStates(states,
{
    sleeptimeline =
    {
        TimeEvent(46*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.sleep) end)
    },
})

return StateGraph("ttk_beefalo", states, events, "idle", actionhandlers)

