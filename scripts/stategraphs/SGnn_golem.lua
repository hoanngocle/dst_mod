require "stategraphs/commonstates"
local _bug_ = {
    EventHandler(
        "attacked",
        function(_b__Ug)
            if not _b__Ug["components"]["health"]:IsDead() and not _b__Ug["sg"]:HasStateTag "hit" then
                _b__Ug["sg"]:GoToState "hit"
            end
        end
    ),
    EventHandler(
        "death",
        function(__B_u_G)
            __B_u_G["sg"]:GoToState "death"
        end
    ),
    EventHandler(
        "doattack",
        function(__B__uG__, _b__U__G_)
            if
                not __B__uG__["components"]["health"]:IsDead() and
                    (__B__uG__["sg"]:HasStateTag "hit" or not __B__uG__["sg"]:HasStateTag "busy")
             then
                __B__uG__["sg"]:GoToState("attack", _b__U__G_["target"])
            end
        end
    )
}
local __b__U__g = {
    State {
        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(BU_G__, __B__u__G_)
            BU_G__["Physics"]:Stop()
            if __B__u__G_ then
                BU_G__["AnimState"]:PlayAnimation(__B__u__G_)
                BU_G__["AnimState"]:PushAnimation("idle", (282 - 128 * 146 - 324 == -18730))
            else
                BU_G__["AnimState"]:PlayAnimation("idle", (19 * 366 - 25 * 152 == 3154))
            end
            BU_G__["sg"]:SetTimeout(2 * math["random"]() + .5)
        end,
        events = {
            EventHandler(
                "animover",
                function(_b__u_g)
                    _b__u_g["sg"]:GoToState "idle"
                end
            )
        }
    },
    State {
        name = "attack",
        tags = {"attack", "busy"},
        onenter = function(_bUg_, B_u__g_)
            _bUg_["sg"]["statemem"]["target"] = B_u__g_
            _bUg_["Physics"]:Stop()
            _bUg_["components"]["combat"]:StartAttack()
            _bUg_["SoundEmitter"]:PlaySound "dontstarve/creatures/lava_arena/turtillus/attack1a"
            _bUg_["AnimState"]:PlayAnimation("attack", (213 - 332 + 20 * 286 + 197 ~= 5798))
        end,
        timeline = {
            TimeEvent(
                7 * FRAMES,
                function(__b__U__G_)
                    __b__U__G_["components"]["combat"]:DoAttack(__b__U__G_["sg"]["statemem"]["target"])
                end
            ),
            TimeEvent(
                17 * FRAMES,
                function(__BuG__)
                    __BuG__["components"]["combat"]:DoAttack(__BuG__["sg"]["statemem"]["target"])
                end
            )
        },
        events = {
            EventHandler(
                "animover",
                function(B__uG_)
                    B__uG_["sg"]:GoToState "idle"
                end
            )
        }
    },
    State {
        name = "hit",
        tags = {"busy", "hit"},
        onenter = function(_BU_g_)
            _BU_g_["Physics"]:Stop()
            _BU_g_["AnimState"]:PlayAnimation "hit"
            _BU_g_["SoundEmitter"]:PlaySound "dontstarve/impacts/lava_arena/fossilized_hit"
        end,
        events = {
            EventHandler(
                "animover",
                function(B_ug__)
                    B_ug__["sg"]:GoToState "idle"
                end
            )
        }
    },
    State {
        name = "spawn",
        tags = {"busy"},
        onenter = function(BU_g_)
            BU_g_["Physics"]:Stop()
            BU_g_["AnimState"]:PlayAnimation "spawn"
            BU_g_["SoundEmitter"]:PlaySound "dontstarve/common/staff_star_create"
        end,
        events = {
            EventHandler(
                "animover",
                function(b_Ug)
                    b_Ug["SoundEmitter"]:PlaySound("dontstarve/common/treefire", "ambsound")
                    b_Ug["sg"]:GoToState "idle"
                end
            )
        }
    },
    State {name = "death", tags = {"busy"}, onenter = function(_BUG)
            _BUG["SoundEmitter"]:KillSound "ambsound"
            _BUG["SoundEmitter"]:PlaySound "dontstarve/impacts/lava_arena/fossilized_break"
            _BUG["AnimState"]:PlayAnimation "death"
            _BUG["Physics"]:Stop()
            RemovePhysicsColliders(_BUG)
        end}
}
return StateGraph("SGnn_golem", __b__U__g, _bug_, "spawn")
