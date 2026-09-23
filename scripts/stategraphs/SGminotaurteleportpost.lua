require "stategraphs/commonstates"
local b_u__g__ = {}
local __BU_g_ = {
    State {
        name = "idle",
        tags = {"idle"},
        onenter = function(_Bu_g__, b_u__g)
            if b_u__g ~= nil then
                _Bu_g__["sg"]["statemem"]["count"] = b_u__g
            else
                _Bu_g__["sg"]["statemem"]["count"] = 3
            end
            if _Bu_g__["sg"]["statemem"]["count"] == 3 then
                _Bu_g__["AnimState"]:PlayAnimation "overload_pre"
            elseif _Bu_g__["sg"]["statemem"]["count"] == 2 then
                _Bu_g__["AnimState"]:PlayAnimation "overload_pulse"
            else
                _Bu_g__["AnimState"]:PlayAnimation "overload_loop"
                ErodeAway(_Bu_g__, _Bu_g__["AnimState"]:GetCurrentAnimationLength() * 0.5)
            end
        end,
        timeline = {},
        ontimeout = function(_B_U_g__)
        end,
        events = {
            EventHandler(
                "animover",
                function(_B__u_g__)
                    if _B__u_g__["sg"]["statemem"]["count"] ~= 1 then
                        _B__u_g__["sg"]:GoToState("idle", _B__u_g__["sg"]["statemem"]["count"] - 1)
                    else
                        _B__u_g__:Remove()
                    end
                end
            )
        }
    }
}
return StateGraph("minotaurteleportpost_fx", __BU_g_, b_u__g__, "idle")
