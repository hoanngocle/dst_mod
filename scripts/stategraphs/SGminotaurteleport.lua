require "stategraphs/commonstates"
local b_u__g__ = {}
local __BU_g_ = {
    State {
        name = "idle",
        tags = {"idle"},
        onenter = function(_Bu_g__, b_u__g)
        end,
        timeline = {},
        ontimeout = function(_B_U_g__)
        end,
        events = {
            EventHandler(
                "animover",
                function(_B__u_g__)
                    _B__u_g__:Remove()
                end
            )
        }
    }
}
return StateGraph("minotaurteleport_fx", __BU_g_, b_u__g__, "idle")
