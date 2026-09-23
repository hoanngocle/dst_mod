require "stategraphs/commonstates"
local __BU_g_ = {}
local _Bu_g__ = {"INLIMBO", "notarget", "noattack", "invisible", "playerghost", "minotaur"}
local b_u__g = {
    State {
        name = "idle",
        tags = {"idle"},
        onenter = function(_B_U_g__)
            _B_U_g__["SoundEmitter"]:PlaySound "dontstarve/creatures/together/stalker/hit"
        end,
        timeline = {
            TimeEvent(
                0 * FRAMES,
                function(_B__u_g__)
                    local _BU_g_ = SpawnPrefab "shadowpoundring_fx"
                    _BU_g_["Transform"]:SetPosition(_B__u_g__["Transform"]:GetWorldPosition())
                    _BU_g_["Transform"]:SetScale(0.7, 0.7, 0.7)
                    _B__u_g__["components"]["combat"]:DoAreaAttack(_B__u_g__, 6, nil, nil, nil, _Bu_g__)
                end
            ),
            TimeEvent(
                10 * FRAMES,
                function(_B_U__g__)
                    if _B_U__g__["level"] > 1 then
                        local _B__u_g = SpawnPrefab "minotaur_deadlyshockwave"
                        _B__u_g["_hh_world_rank_source"] = _B_U__g__["_hh_world_rank_source"] or _B_U__g__
                        local bUg_, __B__U_g__, buG = _B_U__g__["Transform"]:GetWorldPosition()
                        local __b_uG = TUNING["MINOTAUR_DSW_RANGE"] * 2
                        _B__u_g["Transform"]:SetPosition(
                            bUg_ + _B_U__g__["dir"]["x"] * __b_uG,
                            __B__U_g__,
                            buG + _B_U__g__["dir"]["z"] * __b_uG
                        )
                        _B__u_g:SetWaveInfo(_B_U__g__["level"] - 1, _B_U__g__["dir"])
                    end
                end
            )
        },
        ontimeout = function(_b_U__G__)
        end,
        events = {
            EventHandler(
                "animover",
                function(_B_U_G_)
                    _B_U_G_:Remove()
                end
            )
        }
    }
}
return StateGraph("minotaur_deathshockwave", b_u__g, __BU_g_, "idle")
