require("stategraphs/commonstates")
local states = {
    State {
        name = "idle", tags = {"idle", "canrotate"},
        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("idle_loop", true)
        end,
    },
}
CommonStates.AddWalkStates(states)
return StateGraph("ttk_skin_spirit", states, {CommonHandlers.OnLocomote(false, false)}, "idle")
