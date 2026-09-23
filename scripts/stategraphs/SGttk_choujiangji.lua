local soundpath = "choujiangji_sound/choujiangji_sound/"
local events = {
    EventHandler("ttk_slot_spin", function(inst) inst.sg:GoToState("spinning") end),
    EventHandler("ttk_slot_done", function(inst) inst.sg:GoToState("idle") end),
}
local states = {
    State{
        name="idle", tags={"idle"},
        onenter=function(inst) inst.AnimState:PlayAnimation("idle") end,
    },
    State{
        name="spinning", tags={"busy"},
        onenter=function(inst) inst.AnimState:PlayAnimation("use") end,
        timeline={
            TimeEvent(0, function(inst) inst.SoundEmitter:PlaySound(soundpath.."slotmachine_coinslot") end),
            TimeEvent(2*FRAMES, function(inst) inst.SoundEmitter:PlaySound(soundpath.."slotmachine_leverpull") end),
            TimeEvent(11*FRAMES, function(inst) inst.SoundEmitter:PlaySound(soundpath.."slotmachine_jumpup") end),
            TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound(soundpath.."slotmachine_spin", "slotspin") end),
        },
        events={EventHandler("animover", function(inst) inst.sg:GoToState("result") end)},
    },
    State{
        name="result", tags={"busy"},
        onenter=function(inst)
            local category=inst.components.ttk_slotmachine.category
            local anim=category == "good" and "good" or (category == "bad" or category == "bad2") and "bad" or "ok"
            inst.sg.statemem.result=anim
            inst.AnimState:PlayAnimation(anim)
        end,
        timeline={TimeEvent(33*FRAMES, function(inst)
            inst.SoundEmitter:KillSound("slotspin")
            local result=inst.sg.statemem.result
            inst.SoundEmitter:PlaySound(soundpath.."slotmachine_"..(result == "ok" and "medium" or result).."result")
        end)},
        events={EventHandler("animover", function(inst)
            inst.SoundEmitter:KillSound("slotspin")
            inst.sg:GoToState("paying")
        end)},
    },
    State{
        name="paying", tags={"busy"},
        onenter=function(inst)
            inst.AnimState:PlayAnimation("idle")
            inst.components.ttk_slotmachine:Pay()
        end,
    },
}
return StateGraph("ttk_choujiangji", states, events, "idle")
