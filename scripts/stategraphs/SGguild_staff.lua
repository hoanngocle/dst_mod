require("stategraphs/commonstates")

local events = {
    CommonHandlers.OnLocomote(false, true),
}

local states = {
    State {
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("idle_loop", true)
        end,
    },

    State {
        name = "sleep",
        tags = { "busy", "sleeping" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("dozy")
            inst.AnimState:PushAnimation("sleep_loop", true)
        end,
    },

    State {
        name = "wakeup",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("wakeup")
        end,

        events = {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },
}

CommonStates.AddWalkStates(states, nil, {
    startwalk = "run_pre",
    walk = "run_loop",
    stopwalk = "run_pst",
}, true)

return StateGraph("guild_staff", states, events, "idle")
