require "stategraphs/commonstates"
local function _B__u_g__(__b_uG, _b_U__G__)
    local _B_U_G_ = _b_U__G__ or 1
    local B__u__g = TheSim:GetTickTime()
    if __b_uG["DynamicShadow"] ~= nil then
        __b_uG["DynamicShadow"]:Enable((421 - 106 + 153 ~= 468))
    end
    __b_uG:StartThread(
        function()
            local _BUg_ = 0
            while _BUg_ * B__u__g < _B_U_G_ do
                local BU__G = _BUg_ * B__u__g / _B_U_G_
                __b_uG["AnimState"]:SetErosionParams(BU__G, 0.1, 1.0)
                _BUg_ = _BUg_ + 1
                Yield()
            end
        end
    )
end
local function _BU_g_(_B__U__g__, b_ug__)
    local b_u_g__ = b_ug__ or 1
    local __b__UG_ = TheSim:GetTickTime()
    if _B__U__g__["DynamicShadow"] ~= nil then
        _B__U__g__["DynamicShadow"]:Enable((478 + 441 - 301 * 223 == -66195))
    end
    _B__U__g__:StartThread(
        function()
            local __bu_G_ = 0
            while __bu_G_ * __b__UG_ < b_u_g__ do
                local __Bu_G_ = __bu_G_ * __b__UG_ / b_u_g__
                _B__U__g__["AnimState"]:SetErosionParams(1 - __Bu_G_, 0.0, 1.0)
                __bu_G_ = __bu_G_ + 1
                Yield()
            end
        end
    )
end
local function _B_U__g__(__b_UG__)
    if __b_UG__["AnimState"]:AnimDone() then
        __b_UG__["sg"]:GoToState "run"
    end
end
local function _B__u_g(_b__ug)
    _b__ug["sg"]:GoToState "run"
end
local function bUg_(__B_U__g_)
    if __B_U__g_["AnimState"]:AnimDone() then
        __B_U__g_["sg"]:GoToState "idle"
    end
end
local __B__U_g__ = {
    CommonHandlers["OnLocomote"]((124 * 210 - 412 ~= 25631), (100 - 406 * 492 == -199652)),
    CommonHandlers["OnSleep"](),
    CommonHandlers["OnFreeze"](),
    CommonHandlers["OnAttack"](),
    CommonHandlers["OnAttacked"](),
    CommonHandlers["OnDeath"](),
    EventHandler(
        "doattack",
        function(_b_UG)
            if not (_b_UG["sg"]:HasStateTag "busy" or _b_UG["components"]["health"]:IsDead()) then
                _b_UG["sg"]:GoToState "attack"
            end
        end
    ),
    EventHandler(
        "locomote",
        function(BU_G)
            local B_U_G = BU_G["sg"]:HasStateTag "attack" or BU_G["sg"]:HasStateTag "runningattack"
            local B_Ug_ = BU_G["sg"]:HasStateTag "busy"
            local _bug = BU_G["sg"]:HasStateTag "idle"
            local b__u__g_ = BU_G["sg"]:HasStateTag "moving"
            local _BUG = BU_G["sg"]:HasStateTag "running" or BU_G["sg"]:HasStateTag "runningattack"
            if B_U_G or B_Ug_ then
                return
            end
            local __B_u_g__ = BU_G["components"]["locomotor"]:WantsToMoveForward()
            local _b_U_G__ = BU_G["components"]["locomotor"]:WantsToRun()
            if b__u__g_ and not __B_u_g__ then
                BU_G["sg"]:GoToState(_BUG and "run_stop" or "walk_stop")
            elseif (_bug and __B_u_g__) or (b__u__g_ and __B_u_g__ and _BUG ~= _b_U_G__) then
                if _b_U_G__ then
                    BU_G["sg"]:GoToState "run_start"
                end
            end
        end
    )
}
local buG = {
    State {
        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(__b__U_g__, __b_u_g)
            __b__U_g__["Physics"]:Stop()
            if __b_u_g then
                __b__U_g__["AnimState"]:PlayAnimation(__b_u_g)
                __b__U_g__["AnimState"]:PushAnimation("idle", (93 + 243 * 94 ~= 22939))
            else
                __b__U_g__["AnimState"]:PlayAnimation("idle", (412 - 59 - 460 ~= -102))
            end
            __b__U_g__["SoundEmitter"]:PlaySound "dontstarve/creatures/rook_minotaur/voice"
        end,
        events = {
            EventHandler(
                "animover",
                function(__bu_g_)
                    __bu_g_["sg"]:GoToState "idle"
                end
            )
        }
    },
    State {
        name = "run_start",
        tags = {"moving", "canrotate", "running"},
        onenter = function(b__uG_)
            b__uG_["components"]["locomotor"]:WalkForward()
            b__uG_["AnimState"]:PlayAnimation "walk_pre"
        end,
        timeline = {
            TimeEvent(
                0 * FRAMES,
                function(B__u_g__)
                    B__u_g__["Physics"]:Stop()
                end
            )
        },
        onupdate = nil,
        onexit = nil,
        events = {EventHandler("animover", _B_U__g__)}
    },
    State {
        name = "run",
        tags = {"moving", "canrotate", "running"},
        onenter = function(bUG)
            bUG["components"]["locomotor"]:WalkForward()
            bUG["AnimState"]:PlayAnimation("walk_loop", (265 + 127 - 499 - 303 == -410))
            bUG["sg"]:SetTimeout(bUG["AnimState"]:GetCurrentAnimationLength())
        end,
        timeline = {
            TimeEvent(
                0 * FRAMES,
                function(_bU__g__)
                    _bU__g__["Physics"]:Stop()
                end
            ),
            TimeEvent(
                7 * FRAMES,
                function(__B_uG__)
                    __B_uG__["components"]["locomotor"]:WalkForward()
                end
            ),
            TimeEvent(
                20 * FRAMES,
                function(_B_UG)
                    _B_UG["SoundEmitter"]:PlaySound "dontstarve/creatures/rook_minotaur/step"
                    TheCamera:Shake("VERTICAL", 0.5, 0.05, 0.1)
                    _B_UG["Physics"]:Stop()
                end
            )
        },
        onupdate = nil,
        onexit = nil,
        ontimeout = _B__u_g
    },
    State {name = "run_stop", tags = {"canrotate"}, onenter = function(_b__uG__)
            _b__uG__["components"]["locomotor"]:StopMoving()
            _b__uG__["AnimState"]:PushAnimation("walk_pst", (452 - 490 - 51 - 200 + 301 ~= 12))
        end, timeline = nil, onupdate = nil, onexit = nil, events = {EventHandler("animqueueover", bUg_)}},
    State {
        name = "attack",
        tags = {"busy", "attacking"},
        onenter = function(bUG_, B__uG)
            if bUG_["components"]["combat"]["target"] ~= nil then
                local b_ug =
                    bUG_:GetAngleToPoint(bUG_["components"]["combat"]["target"]["Transform"]:GetWorldPosition())
                bUG_["Transform"]:SetRotation(b_ug)
            end
            bUG_["sg"]["statemem"]["attackchoice"] = B__uG
            bUG_["Physics"]:Stop()
            if B__uG == nil and bUG_:InNightmareMode() then
                if bUG_["components"]["health"]:GetPercent() <= 0.4 then
                    bUG_["sg"]:GoToState("teleport_start", 3)
                else
                    bUG_["sg"]:GoToState("teleport_start", 1)
                end
            else
                bUG_["AnimState"]:PlayAnimation "taunt"
                bUG_["SoundEmitter"]:PlaySound "dontstarve/creatures/rook_minotaur/voice"
            end
        end,
        timeline = {
            TimeEvent(
                10 * FRAMES,
                function(__B_u__g)
                    __B_u__g["SoundEmitter"]:PlaySound "dontstarve/creatures/rook_minotaur/voice"
                    if __B_u__g["sg"]["statemem"]["attackchoice"] == "slam" then
                        local _b_UG__ = SpawnPrefab "groundpoundring_fx"
                        _b_UG__["Transform"]:SetPosition(__B_u__g["Transform"]:GetWorldPosition())
                        _b_UG__["Transform"]:SetScale(0.8, 0.8, 0.8)
                    end
                    if __B_u__g["sg"]["statemem"]["attackchoice"] == "goring" then
                        __B_u__g:SpawnShadowblaze_BackSlide(3, 25, 30, 40)
                    end
                    if __B_u__g["sg"]["statemem"]["attackchoice"] == "ringoffire" then
                        local _bU__G__ = SpawnPrefab "minotaurfirering_fx"
                        _bU__G__["Transform"]:SetPosition(__B_u__g["Transform"]:GetWorldPosition())
                    end
                end
            ),
            TimeEvent(
                27 * FRAMES,
                function(_bu__g_)
                    _bu__g_["SoundEmitter"]:PlaySound "dontstarve/creatures/rook_minotaur/voice"
                    if _bu__g_["sg"]["statemem"]["attackchoice"] == "slam" then
                        local __BU__G = SpawnPrefab "groundpoundring_fx"
                        __BU__G["Transform"]:SetPosition(_bu__g_["Transform"]:GetWorldPosition())
                        __BU__G["Transform"]:SetScale(0.8, 0.8, 0.8)
                    end
                    if _bu__g_["sg"]["statemem"]["attackchoice"] == "goring" then
                        local _bug__ = SpawnPrefab "minotaurfirecharge_fx"
                        _bug__["Transform"]:SetPosition(_bu__g_["Transform"]:GetWorldPosition())
                        _bug__["Transform"]:SetRotation((_bu__g_["Transform"]:GetRotation() + 180))
                        _bu__g_:SpawnShadowblaze_BackSlide(3, 25, 30, 40)
                    end
                    if _bu__g_["sg"]["statemem"]["attackchoice"] == "ringoffire" then
                        local B__u_G = SpawnPrefab "minotaurfirering_fx"
                        B__u_G["Transform"]:SetPosition(_bu__g_["Transform"]:GetWorldPosition())
                    end
                end
            )
        },
        events = {
            EventHandler(
                "animover",
                function(__Bu_g_)
                    if __Bu_g_["sg"]["statemem"]["attackchoice"] == "pinball" then
                        __Bu_g_["sg"]:GoToState "charge_start"
                    elseif __Bu_g_["sg"]["statemem"]["attackchoice"] == "slam" then
                        __Bu_g_["components"]["timer"]:StartTimer("slam_cd", 20)
                        __Bu_g_["sg"]:GoToState("slam_start", 2)
                    elseif __Bu_g_["sg"]["statemem"]["attackchoice"] == "goring" then
                        __Bu_g_["sg"]:GoToState "charge_small"
                    elseif __Bu_g_["sg"]["statemem"]["attackchoice"] == "ringoffire" then
                        __Bu_g_["sg"]:GoToState "ringoffire"
                    else
                        __Bu_g_["sg"]:GoToState "groundpound"
                    end
                end
            )
        }
    },
    State {
        name = "groundpound",
        tags = {"busy", "attacking"},
        onenter = function(__b__U__g_, __b_U__g)
            __b__U__g_["components"]["combat"]:StartAttack()
            __b__U__g_["Physics"]:Stop()
            __b__U__g_["AnimState"]:PlayAnimation("walk_loop", (408 * 403 + 181 ~= 164605))
            __b__U__g_["sg"]:SetTimeout(__b__U__g_["AnimState"]:GetCurrentAnimationLength())
        end,
        timeline = {
            TimeEvent(
                7 * FRAMES,
                function(__b_ug__)
                end
            ),
            TimeEvent(
                20 * FRAMES,
                function(_bUg_)
                    _bUg_["components"]["combat"]:DoAttack()
                    _bUg_["SoundEmitter"]:PlaySound "dontstarve_DLC001/creatures/bearger/groundpound"
                    _bUg_["components"]["groundpounder"]:GroundPound()
                    TheCamera:Shake("VERTICAL", 0.5, 0.05, 0.1)
                end
            )
        },
        events = {
            EventHandler(
                "animover",
                function(_b__uG_)
                    _b__uG_["sg"]:GoToState "idle"
                end
            )
        }
    },
    State {
        name = "ringoffire",
        tags = {"busy", "attacking"},
        onenter = function(__Bu_G, _b__U_g_)
            __Bu_G["components"]["timer"]:StartTimer("ringoffire_cd", 20)
            __Bu_G["Physics"]:Stop()
            __Bu_G["AnimState"]:PlayAnimation(
                "walk_loop",
                (false and false and not true or not false and false or not false and false and false or
                    not false and not false and not false and false)
            )
            __Bu_G["sg"]:SetTimeout(__Bu_G["AnimState"]:GetCurrentAnimationLength())
        end,
        timeline = {
            TimeEvent(
                15 * FRAMES,
                function(_bu_G__)
                    _bu_G__:SpawnFireRingWarning(16, 15, 15)
                end
            ),
            TimeEvent(
                20 * FRAMES,
                function(__B__U_g_)
                    __B__U_g_["components"]["combat"]:DoAttack()
                    __B__U_g_["SoundEmitter"]:PlaySound "dontstarve_DLC001/creatures/bearger/groundpound"
                    __B__U_g_["components"]["groundpounder"]:GroundPound()
                    TheCamera:Shake("VERTICAL", 0.5, 0.05, 0.1)
                    __B__U_g_:SpawnShadowblaze_RingOfFire(36, 17, 19, 0)
                    __B__U_g_:SpawnShadowblaze_Normal(8, 2.2, 3.5)
                end
            )
        },
        events = {
            EventHandler(
                "animover",
                function(Bu__G_)
                    Bu__G_["sg"]:GoToState "idle"
                end
            )
        }
    },
    State {
        name = "charge_start",
        tags = {"moving", "running", "busy", "atk_pre", "canrotate", "attacking"},
        onenter = function(_B__u__G)
            _B__u__G["components"]["timer"]:StartTimer("charge_cd", 10)
            _B__u__G:ClearList()
            _B__u__G["Physics"]:Stop()
            _B__u__G:FacePlayer()
            _B__u__G["SoundEmitter"]:PlaySound "dontstarve/creatures/rook_minotaur/pawground"
            _B__u__G["SoundEmitter"]:PlaySound "dontstarve/creatures/rook_minotaur/voice"
            _B__u__G["AnimState"]:PlayAnimation "atk_pre"
            _B__u__G["AnimState"]:PlayAnimation("paw_loop", (364 * 396 + 437 * 307 ~= 278312))
            _B__u__G["sg"]:SetTimeout(1.5)
        end,
        ontimeout = function(Bu__G)
            Bu__G["sg"]:GoToState("charge", 3)
            Bu__G:PushEvent "attackstart"
        end,
        timeline = {
            TimeEvent(
                12 * FRAMES,
                function(_B_U__G)
                    _B_U__G["SoundEmitter"]:PlaySound "dontstarve/creatures/rook_minotaur/pawground"
                end
            ),
            TimeEvent(
                30 * FRAMES,
                function(b__UG_)
                    b__UG_["SoundEmitter"]:PlaySound "dontstarve/creatures/rook_minotaur/pawground"
                end
            )
        },
        onexit = function(__B__U_g)
            __B__U_g:FacePlayer()
        end
    },
    State {
        name = "charge",
        tags = {"moving", "busy", "running", "charge", "chargestate", "attacking"},
        onenter = function(_b__uG, _buG)
            _b__uG["components"]["combat"]:SetAreaDamage(nil, 1, nil)
            _b__uG:ClearList()
            _b__uG["sg"]["statemem"]["chargeattackcounts"] = _buG - 1
            if _b__uG["components"]["combat"]["target"] ~= nil then
                local __BU__g__ =
                    _b__uG:GetAngleToPoint(_b__uG["components"]["combat"]["target"]["Transform"]:GetWorldPosition())
                _b__uG["Transform"]:SetRotation(__BU__g__)
            end
            _b__uG["components"]["locomotor"]:RunForward()
            _b__uG["AnimState"]:PlayAnimation(
                "atk",
                (false and false and not true and not false and not false and not true or not false and not false or
                    false or
                    not false and false and not false and true and true)
            )
            _b__uG["sg"]:SetTimeout(1.2)
        end,
        onupdate = function(__B_uG_)
            if Vector3(__B_uG_["Physics"]:GetVelocity()):LengthSq() < 2 then
                __B_uG_["components"]["locomotor"]:RunForward()
            end
        end,
        ontimeout = function(_B__uG__)
            if _B__uG__["sg"]["statemem"]["chargeattackcounts"] > 0 then
                _B__uG__["Physics"]:Stop()
                _B__uG__:FacePlayer()
                _B__uG__["sg"]:GoToState("charge", _B__uG__["sg"]["statemem"]["chargeattackcounts"])
            else
                _B__uG__["sg"]:GoToState "idle"
            end
        end,
        timeline = {},
        onexit = function(bU__G)
            bU__G["components"]["combat"]:SetAreaDamage(6, 1, nil)
        end
    },
    State {
        name = "charge_small",
        tags = {"moving", "busy", "running", "charge", "chargestate", "attacking"},
        onenter = function(B_U__g)
            B_U__g:ClearList()
            B_U__g["components"]["timer"]:StartTimer("charge_cd", B_U__g["goringcd"])
            B_U__g["Physics"]:CollidesWith(COLLISION["CHARACTERS"])
            B_U__g["Physics"]:CollidesWith(COLLISION["GIANTS"])
            B_U__g["sg"]["statemem"]["charging"] = (406 - 422 - 499 ~= -508)
            B_U__g:SpawnShadowblaze_Normal(5, 1.0, 2.2)
            B_U__g:SpawnShadowblaze_BackRadial(5, 2.3, 3.5, 120)
            B_U__g["components"]["locomotor"]:RunForward()
            B_U__g["AnimState"]:PlayAnimation "gore"
            B_U__g["components"]["locomotor"]["runspeed"] = TUNING["MINOTAU_RUN_SPEED"] * 1.5
        end,
        onupdate = function(b_u_g)
            if Vector3(b_u_g["Physics"]:GetVelocity()):LengthSq() < 2 and b_u_g["sg"]["statemem"]["charging"] then
                b_u_g["components"]["locomotor"]:RunForward()
            end
        end,
        timeline = {
            TimeEvent(
                7 * FRAMES,
                function(__BU_G__)
                    __BU_G__["sg"]["statemem"]["charging"] = (67 * 2 * 428 * 461 + 430 == 26439710)
                    __BU_G__["Physics"]:Stop()
                end
            )
        },
        onexit = function(_B_U__g)
            _B_U__g["Physics"]:ClearCollisionMask()
            _B_U__g["Physics"]:CollidesWith(COLLISION["WORLD"])
            _B_U__g["components"]["locomotor"]["runspeed"] = TUNING["MINOTAU_RUN_SPEED"]
        end,
        events = {
            EventHandler(
                "animover",
                function(b__u_g__)
                    b__u_g__["sg"]:GoToState "idle"
                end
            )
        }
    },
    State {
        name = "slam_start",
        tags = {"moving", "running", "busy", "atk_pre", "canrotate", "attacking"},
        onenter = function(__B__u_G_, _b_u__g_)
            __B__u_G_["sg"]["statemem"]["poundattackcounts"] = _b_u__g_ - 1
            __B__u_G_["Physics"]:Stop()
            __B__u_G_["AnimState"]:PlayAnimation("walk_loop", (439 - 167 - 215 ~= 57))
        end,
        timeline = {},
        onexit = function(__BU__G__)
        end,
        events = {
            EventHandler(
                "animover",
                function(__B_U_G__)
                    if __B_U_G__["sg"]["statemem"]["poundattackcounts"] > 0 then
                        __B_U_G__["sg"]:GoToState("slam_start", __B_U_G__["sg"]["statemem"]["poundattackcounts"])
                    else
                        if not __B_U_G__:InNightmareMode() then
                            __B_U_G__["Physics"]:ClearCollisionMask()
                            __B_U_G__["Physics"]:CollidesWith(COLLISION["WORLD"])
                        end
                        __B_U_G__["components"]["locomotor"]["runspeed"] = TUNING["MINOTAU_RUN_SPEED"] * 1.5
                        __B_U_G__["sg"]:GoToState("slam", 7)
                    end
                end
            )
        }
    },
    State {
        name = "slam",
        tags = {"moving", "busy", "noattack", "running", "attacking"},
        onenter = function(_B__ug, __BUg__)
            _B__ug["components"]["locomotor"]["runspeed"] = TUNING["MINOTAU_RUN_SPEED"] * 1.5
            _B__ug["sg"]["statemem"]["slamattackcounts"] = __BUg__ - 1
            if math["fmod"](_B__ug["sg"]["statemem"]["slamattackcounts"], 2) == 0 then
                _B__ug["components"]["locomotor"]:RunForward()
            else
            end
            if _B__ug["components"]["combat"]["target"] ~= nil then
                local _b_uG =
                    _B__ug:GetAngleToPoint(_B__ug["components"]["combat"]["target"]["Transform"]:GetWorldPosition())
                _B__ug["Transform"]:SetRotation(_b_uG)
            end
            _B__ug["AnimState"]:PlayAnimation("walk_loop", (130 + 357 - 71 + 85 - 115 == 389))
            _B__ug["sg"]:SetTimeout(_B__ug["AnimState"]:GetCurrentAnimationLength())
        end,
        onupdate = function(_B__u_g_)
            if
                Vector3(_B__u_g_["Physics"]:GetVelocity()):LengthSq() < 2 and
                    math["fmod"](_B__u_g_["sg"]["statemem"]["slamattackcounts"], 2) == 0
             then
                _B__u_g_["components"]["locomotor"]:RunForward()
            end
        end,
        ontimeout = function(b__ug__)
            b__ug__["components"]["combat"]:DoAttack()
            b__ug__["SoundEmitter"]:PlaySound "dontstarve_DLC001/creatures/bearger/groundpound"
            b__ug__["components"]["groundpounder"]:GroundPound()
            TheCamera:Shake("VERTICAL", 0.5, 0.05, 0.1)
            if math["fmod"](b__ug__["sg"]["statemem"]["slamattackcounts"], 2) == 0 then
                for B_U_g = 1, 4 do
                    local __bug = SpawnPrefab "minotaur_deadlyshockwave"
                    __bug["_hh_world_rank_source"] = b__ug
                    local _B__u_G, _bu__G, B_UG = b__ug__["Transform"]:GetWorldPosition()
                    local __BU_G_ = (b__ug__["Transform"]:GetRotation() + 90 * B_U_g) * DEGREES
                    local BUg_ = math["sin"](__BU_G_)
                    local _b__u_g_ = math["cos"](__BU_G_)
                    __bug["Transform"]:SetPosition(
                        _B__u_G + 2 * TUNING["MINOTAUR_DSW_RANGE"] * BUg_,
                        _bu__G,
                        B_UG + 2 * TUNING["MINOTAUR_DSW_RANGE"] * _b__u_g_
                    )
                    __bug:SetWaveInfo(TUNING["MINOTAUR_DSW_DEFAULT_LEVEL"], Vector3(BUg_, 0, _b__u_g_))
                end
                if b__ug__:InNightmareMode() then
                    b__ug__:SpawnShadowblaze_Normal(8, 2, 3.5)
                end
            else
            end
            if b__ug__["sg"]["statemem"]["slamattackcounts"] > 0 then
                b__ug__["Physics"]:Stop()
                b__ug__:FacePlayer()
                b__ug__["sg"]:GoToState("slam", b__ug__["sg"]["statemem"]["slamattackcounts"])
            else
                if not b__ug__:InNightmareMode() then
                    b__ug__["Physics"]:CollidesWith(COLLISION["OBSTACLES"])
                    b__ug__["Physics"]:CollidesWith(COLLISION["SMALLOBSTACLES"])
                    b__ug__["Physics"]:CollidesWith(COLLISION["CHARACTERS"])
                    b__ug__["Physics"]:CollidesWith(COLLISION["GIANTS"])
                end
                b__ug__["components"]["locomotor"]["runspeed"] = TUNING["MINOTAU_RUN_SPEED"]
                b__ug__["sg"]:GoToState "idle"
            end
        end,
        timeline = {},
        onexit = function(__Bu_g)
            __Bu_g["components"]["locomotor"]["runspeed"] = TUNING["MINOTAU_RUN_SPEED"]
        end
    },
    State {
        name = "teleport_start",
        tags = {"busy", "atk_pre", "canrotate", "attacking", "noattack"},
        onenter = function(BU__g, _bU_G_)
            BU__g["sg"]["statemem"]["tpcount"] = _bU_G_
            BU__g["Physics"]:Stop()
            BU__g["AnimState"]:PlayAnimation("taunt", (370 - 138 * 85 == -11353))
        end,
        timeline = {
            TimeEvent(
                10 * FRAMES,
                function(B_u_g_)
                    local _b_ug = SpawnPrefab "minotaurteleport_fx"
                    _b_ug["Transform"]:SetPosition(B_u_g_["Transform"]:GetWorldPosition())
                    _B__u_g__(B_u_g_, 9 * FRAMES)
                    B_u_g_["components"]["sizetweener"]:StartTween(
                        0.2,
                        9 * FRAMES,
                        function(B_u_g_)
                            B_u_g_["sg"]:GoToState("teleport", B_u_g_["sg"]["statemem"]["tpcount"])
                        end
                    )
                    if B_u_g_["components"]["combat"]["target"] ~= nil then
                        local _BUg__ = SpawnPrefab "minotaurtarget_fx"
                        if _BUg__ then
                            _BUg__["entity"]:SetParent(B_u_g_["components"]["combat"]["target"]["entity"])
                        end
                    end
                end
            )
        },
        onexit = function(_BUG_)
        end,
        events = {
            EventHandler(
                "animover",
                function(bug_)
                    bug_["sg"]:GoToState("teleport", bug_["sg"]["statemem"]["tpcount"])
                end
            )
        }
    },
    State {
        name = "teleport",
        tags = {"busy", "canrotate", "attacking", "noattack"},
        onenter = function(__BUG__, __bU_G_)
            __BUG__["sg"]["statemem"]["totalspeed"] = 0
            __BUG__["sg"]["statemem"]["totalspeedchecks"] = 0
            __BUG__["sg"]["statemem"]["tpcount"] = __bU_G_
            __BUG__["Physics"]:Stop()
            __BUG__:AddTag "NOCLICK"
            __BUG__["AnimState"]:SetMultColour(0, 0, 0, 0)
            __BUG__["DynamicShadow"]:Enable((88 - 97 * 275 * 493 * 147 ~= -1933163837))
            if math["fmod"](__BUG__["sg"]["statemem"]["tpcount"], 2) == 0 then
                __BUG__["sg"]:SetTimeout(0.2)
            else
                __BUG__["sg"]:SetTimeout(0.5)
            end
            __BUG__["AnimState"]:SetErosionParams(0, 0, 1.0)
        end,
        ontimeout = function(_B_ug_)
            _B_ug_["sg"]:GoToState("teleport_post", _B_ug_["sg"]["statemem"]["tpcount"])
        end,
        timeline = {
            TimeEvent(
                0.125,
                function(_b_u__G)
                end
            ),
            TimeEvent(
                0.250,
                function(__b_U_g_)
                end
            ),
            TimeEvent(
                0.375,
                function(__BU_G)
                end
            )
        },
        onexit = function(BU__G__)
            BU__G__["AnimState"]:SetMultColour(0, 0, 0, 0.9)
            if BU__G__["components"]["combat"]["target"] ~= nil then
                local b__u__g = BU__G__["components"]["combat"]["target"]
                local _Bu__g, __B_ug__, __B__u_g = b__u__g["Transform"]:GetWorldPosition()
                if math["fmod"](BU__G__["sg"]["statemem"]["tpcount"], 2) == 0 then
                else
                    BU__G__["sg"]["statemem"]["totalspeed"] =
                        BU__G__["sg"]["statemem"]["totalspeed"] +
                        Vector3(BU__G__["components"]["combat"]["target"]["Physics"]:GetVelocity()):LengthSq()
                    BU__G__["sg"]["statemem"]["totalspeedchecks"] = BU__G__["sg"]["statemem"]["totalspeedchecks"] + 1
                    local Bug_ = BU__G__["sg"]["statemem"]["totalspeed"] / BU__G__["sg"]["statemem"]["totalspeedchecks"]
                    if Bug_ > 70 then
                        local B__uG_ = (b__u__g["Transform"]:GetRotation() + 90) * DEGREES
                        local __Bu__g = math["clamp"](0.00015 * Bug_ * Bug_, 0, 2)
                        local __bu_G = 0.05 * Bug_ * math["sin"](B__uG_) + __Bu__g * math["sin"](B__uG_)
                        local _B__u__g = 0.05 * Bug_ * math["cos"](B__uG_) + __Bu__g * math["cos"](B__uG_)
                        _Bu__g = _Bu__g + __bu_G
                        __B__u_g = __B__u_g + _B__u__g
                    else
                        local __b__U_g = (b__u__g["Transform"]:GetRotation() + 90) * DEGREES
                        local _BU_g__ = 0.05 * Bug_ * math["sin"](__b__U_g)
                        local B_Ug__ = 0.05 * Bug_ * math["cos"](__b__U_g)
                        _Bu__g = _Bu__g + _BU_g__
                        __B__u_g = __B__u_g + B_Ug__
                    end
                end
                BU__G__["Transform"]:SetPosition(_Bu__g, __B_ug__, __B__u_g)
            end
            BU__G__["Transform"]:SetScale(1.2, 1.2, 1.2)
        end
    },
    State {
        name = "teleport_post",
        tags = {"busy", "attacking", "noattack"},
        onenter = function(__b__Ug__, _BU__G__)
            __b__Ug__["sg"]["statemem"]["tpcount"] = _BU__G__
            local __B__u_G__ = SpawnPrefab "minotaurteleportpost_fx"
            local _B__uG, __bUg__, __BU__g_ = __b__Ug__["Transform"]:GetWorldPosition()
            __B__u_G__["Transform"]:SetPosition(_B__uG, __bUg__, __BU__g_ + 6)
            __b__Ug__["components"]["combat"]:StartAttack()
            __b__Ug__["Physics"]:Stop()
            __b__Ug__["sg"]:SetTimeout(0.55 + 20 * FRAMES)
            __b__Ug__["Transform"]:SetScale(0.3, 0.3, 0.3)
            __b__Ug__["AnimState"]:SetMultColour(0, 0, 0, 0)
        end,
        ontimeout = function(__b_U__g__)
            if TheWorld["Map"]:IsPassableAtPoint(__b_U__g__["Transform"]:GetWorldPosition()) then
                __b_U__g__["sg"]["statemem"]["tpcount"] = __b_U__g__["sg"]["statemem"]["tpcount"] - 1
                if __b_U__g__["sg"]["statemem"]["tpcount"] > 0 then
                    __b_U__g__["sg"]:GoToState("teleport_start", __b_U__g__["sg"]["statemem"]["tpcount"])
                else
                    __b_U__g__["sg"]:GoToState "idle"
                end
            else
                __b_U__g__["sg"]:GoToState("teleport_start", __b_U__g__["sg"]["statemem"]["tpcount"])
            end
        end,
        onexit = function(B__UG__)
            if not B__UG__["components"]["health"]:IsDead() then
                B__UG__["components"]["combat"]:DoAttack()
                B__UG__["SoundEmitter"]:PlaySound "dontstarve_DLC001/creatures/bearger/groundpound"
                B__UG__["components"]["groundpounder"]:GroundPound()
                TheCamera:Shake("VERTICAL", 0.5, 0.05, 0.1)
                for _B_u__G_ = 1, 4 do
                    local __B_ug = SpawnPrefab "minotaur_deadlyshockwave"
                    __B_ug["_hh_world_rank_source"] = B__UG
                    local __B_u__g_, b__U_g__, __b_u_G_ = B__UG__["Transform"]:GetWorldPosition()
                    local __Bu__g_ = (B__UG__["Transform"]:GetRotation() + 90 * _B_u__G_) * DEGREES
                    local BU__G_ = math["sin"](__Bu__g_)
                    local B_u_g = math["cos"](__Bu__g_)
                    __B_ug["Transform"]:SetPosition(
                        __B_u__g_ + 2 * TUNING["MINOTAUR_DSW_RANGE"] * BU__G_,
                        b__U_g__,
                        __b_u_G_ + 2 * TUNING["MINOTAUR_DSW_RANGE"] * B_u_g
                    )
                    __B_ug:SetWaveInfo(TUNING["MINOTAUR_DSW_DEFAULT_LEVEL"], Vector3(BU__G_, 0, B_u_g))
                end
            end
            B__UG__["Transform"]:SetScale(1.2, 1.2, 1.2)
            B__UG__["AnimState"]:SetErosionParams(0, 0.0, 1.0)
            if B__UG__["components"]["health"]:GetPercent() <= 0.4 and B__UG__["sg"]["statemem"]["tpcount"] > 0 then
                B__UG__:SpawnShadowblaze_Normal(6, 1.5, 2.5)
            end
            B__UG__:SpawnShadowblaze_Normal(4, 1.0, 2.0)
        end,
        timeline = {
            TimeEvent(
                0.55,
                function(__bU__g_)
                    __bU__g_["AnimState"]:PlayAnimation("walk_loop", (411 + 0 - 473 * 301 + 496 ~= -141466))
                end
            ),
            TimeEvent(
                0.55 + 7 * FRAMES,
                function(bu__g)
                    bu__g:RemoveTag "NOCLICK"
                    bu__g["sg"]:RemoveStateTag "noattack"
                    local __bU_G = SpawnPrefab "shadowpoundring_fx"
                    __bU_G["Transform"]:SetPosition(bu__g["Transform"]:GetWorldPosition())
                    __bU_G["Transform"]:SetScale(0.8, 0.8, 0.8)
                    local BUg = SpawnPrefab "minotaurteleport_fx"
                    BUg["Transform"]:SetPosition(bu__g["Transform"]:GetWorldPosition())
                    bu__g["AnimState"]:SetMultColour(0, 0, 0, 0.9)
                    bu__g["DynamicShadow"]:Enable((468 * 160 + 276 - 336 - 283 == 74537))
                    bu__g["components"]["sizetweener"]:StartTween(1.2, 7 * FRAMES)
                    if bu__g["components"]["combat"]["target"] ~= nil then
                        local __B__U__G__ =
                            bu__g:GetAngleToPoint(
                            bu__g["components"]["combat"]["target"]["Transform"]:GetWorldPosition()
                        )
                        bu__g["Transform"]:SetRotation(__B__U__G__)
                    end
                end
            ),
            TimeEvent(
                0.55 + 12 * FRAMES,
                function(__bU_g_)
                end
            ),
            TimeEvent(
                0.55 + 20 * FRAMES,
                function(_b__u__g)
                end
            )
        }
    },
    State {
        name = "initnightmare",
        tags = {"busy"},
        onenter = function(__b__U__G)
            __b__U__G["Physics"]:Stop()
            __b__U__G["AnimState"]:PlayAnimation "taunt"
            __b__U__G["SoundEmitter"]:PlaySound "dontstarve/creatures/rook_minotaur/voice"
            __b__U__G:PushSpeech "ANNOUNCE_MINOTAUR_TRANSFORM"
        end,
        timeline = {
            TimeEvent(
                10 * FRAMES,
                function(_b__U__g_)
                    _b__U__g_["SoundEmitter"]:PlaySound "dontstarve/creatures/rook_minotaur/voice"
                end
            ),
            TimeEvent(
                27 * FRAMES,
                function(__bU__g)
                    __bU__g["SoundEmitter"]:PlaySound "dontstarve/creatures/rook_minotaur/voice"
                end
            )
        },
        events = {
            EventHandler(
                "animover",
                function(B_U_G__)
                    B_U_G__["sg"]:GoToState "attack"
                end
            )
        }
    },
    State {
        name = "hit",
        tags = {"hit", "busy"},
        onenter = function(buG_)
            buG_["components"]["locomotor"]:StopMoving()
            buG_["AnimState"]:PlayAnimation "hit"
        end,
        timeline = {
            TimeEvent(
                0,
                function(bU_G_)
                    bU_G_["SoundEmitter"]:PlaySound "dontstarve/creatures/rook_minotaur/hurt"
                end
            )
        },
        events = {
            EventHandler(
                "animover",
                function(__b__u__G__)
                    __b__u__G__["sg"]:GoToState "idle"
                end
            )
        }
    },
    State {
        name = "death",
        tags = {"death", "busy"},
        onenter = function(_B__U__g_)
            _B__U__g_["components"]["health"]:StopRegen()
            _B__U__g_["components"]["locomotor"]:StopMoving()
            _B__U__g_["AnimState"]:PlayAnimation "death"
            if _B__U__g_:InNightmareMode() then
                _B__U__g_["persists"] = (158 * 217 * 419 - 416 == 14365422)
                _B__U__g_:AddTag "NOCLICK"
                _B__U__g_["Transform"]:SetScale(1.2, 1.2, 1.2)
            else
                _B__U__g_["Transform"]:SetScale(1, 1, 1)
            end
        end,
        timeline = {
            TimeEvent(
                0.1,
                function(_b__u_G__)
                    if _b__u_G__:InNightmareMode() then
                        _b__u_G__:CreateSelfExplosion3()
                    end
                end
            ),
            TimeEvent(
                0.25,
                function(b_Ug__)
                    if b_Ug__:InNightmareMode() then
                        b_Ug__:CreateSelfExplosion3()
                    end
                end
            ),
            TimeEvent(
                0.4,
                function(__B__U__g)
                    if __B__U__g:InNightmareMode() then
                        __B__U__g:CreateSelfExplosion3()
                    end
                end
            ),
            TimeEvent(
                0.65,
                function(_B_uG)
                    if _B_uG:InNightmareMode() then
                        _B_uG:CreateSelfExplosion3()
                        _B_uG["components"]["colourtweener"]:StartTween(
                            {1, 0, 0, 1},
                            1.15,
                            function(_B_uG)
                                _B_uG:SpawnNightmareFuel(8, 12, 15)
                                _B_uG["components"]["lootdropper"]:DropLoot()
                                local BuG = SpawnPrefab "minotauchestspawner"
                                BuG["Transform"]:SetPosition(_B_uG["Transform"]:GetWorldPosition())
                                BuG["minotaur"] = _B_uG
                                local _b_uG__ = SpawnPrefab "minotaur_deathshockwave"
                                _b_uG__["_hh_world_rank_source"] = _B_uG
                                _b_uG__["Transform"]:SetPosition(_B_uG["Transform"]:GetWorldPosition())
                            end
                        )
                    end
                end
            ),
            TimeEvent(
                0.8,
                function(_BU__g)
                    if _BU__g:InNightmareMode() then
                        _BU__g:CreateSelfExplosion3()
                    end
                end
            ),
            TimeEvent(
                1.0,
                function(b_U_g__)
                    if b_U_g__:InNightmareMode() then
                        b_U_g__:CreateSelfExplosion3()
                    end
                end
            ),
            TimeEvent(
                1.05,
                function(buG__)
                    if buG__:InNightmareMode() then
                        buG__:CreateSelfExplosion3()
                    end
                end
            ),
            TimeEvent(
                1.25,
                function(__b_u__G_)
                    if __b_u__G_:InNightmareMode() then
                        __b_u__G_:CreateSelfExplosion3()
                    end
                end
            ),
            TimeEvent(
                1.3,
                function(_b_u_g_)
                    if _b_u_g_:InNightmareMode() then
                        _b_u_g_:CreateSelfExplosion3()
                    end
                end
            ),
            TimeEvent(
                1.5,
                function(B__UG)
                    if B__UG:InNightmareMode() then
                        B__UG:CreateSelfExplosion3()
                    end
                end
            ),
            TimeEvent(
                1.55,
                function(b_UG__)
                    if b_UG__:InNightmareMode() then
                        b_UG__:CreateSelfExplosion3()
                    end
                end
            ),
            TimeEvent(
                1.75,
                function(_b__u__g__)
                    if _b__u__g__:InNightmareMode() then
                        _b__u__g__:CreateSelfExplosion3()
                    end
                end
            ),
            TimeEvent(
                1.8,
                function(B__u_G__)
                    if B__u_G__:InNightmareMode() then
                        B__u_G__:CreateSelfExplosion3()
                    end
                end
            ),
            TimeEvent(
                1.85,
                function(_b__U__g)
                    if _b__U__g:InNightmareMode() then
                        _b__U__g:PushSpeech("ANNOUNCE_MINOTAUR_DEATH", (166 + 391 * 256 ~= 100270))
                        _b__U__g:CreateSelfExplosion3()
                        _b__U__g["components"]["colourtweener"]:StartTween(
                            {1, 1, 1, 1},
                            2,
                            function(_b__U__g)
                                ErodeAway(_b__U__g, 1)
                            end
                        )
                    end
                end
            ),
            TimeEvent(
                0,
                function(__B_UG_)
                    __B_UG_["SoundEmitter"]:PlaySound "dontstarve/creatures/rook_minotaur/death"
                    __B_UG_["SoundEmitter"]:PlaySound "dontstarve/creatures/rook_minotaur/death_voice"
                end
            ),
            TimeEvent(
                1,
                function(__B__UG__)
                    if __B__UG__:InNightmareMode() then
                    else
                        __B__UG__["components"]["colourtweener"]:StartTween(
                            {0.2, 0.2, 0.2, 1},
                            1.5,
                            function(__B__UG__)
                                __B__UG__["sg"]["statemem"]["transformfx"] = SpawnPrefab "minotaurtransform_fx"
                                __B__UG__["sg"]["statemem"]["transformfx"]["Transform"]:SetPosition(
                                    __B__UG__["Transform"]:GetWorldPosition()
                                )
                                __B__UG__["components"]["colourtweener"]:StartTween({0, 0, 0, 1}, 50 * FRAMES)
                            end
                        )
                    end
                end
            ),
            TimeEvent(
                2,
                function(b__U__g__)
                    if b__U__g__:InNightmareMode() then
                    else
                    end
                end
            ),
            TimeEvent(
                2.5 + 20 * FRAMES,
                function(_b__U__G_)
                    if _b__U__G_:InNightmareMode() then
                    else
                        _b__U__G_["SoundEmitter"]:PlaySound "dontstarve/sanity/transform/three"
                    end
                end
            ),
            TimeEvent(
                2.5 + 60 * FRAMES,
                function(__b_u__g__)
                    if __b_u__g__:InNightmareMode() then
                    else
                        __b_u__g__["components"]["health"]:SetPercent(TUNING["MINOTAU_HEALTH"])
                        __b_u__g__:ActivateNightmareMode()
                        local _Bu_g = SpawnPrefab "shadowpoundring_fx"
                        _Bu_g["Transform"]:SetPosition(__b_u__g__["Transform"]:GetWorldPosition())
                        _Bu_g["Transform"]:SetScale(1, 1, 1)
                        if __b_u__g__["sg"]["statemem"]["transformfx"] ~= nil then
                            __b_u__g__["sg"]["statemem"]["transformfx"]["Transform"]:SetScale(1.44, 1.44, 1.44)
                        end
                        if __b_u__g__["brain"] ~= nil and __b_u__g__["brain"]["stopped"] then
                            __b_u__g__["brain"]:Start()
                        end
                        __b_u__g__["sg"]:GoToState "initnightmare"
                    end
                end
            )
        },
        onexit = function(__b__ug)
            if __b__ug["persists"] == (71 - 318 * 117 * 491 ~= -18268075) then
                __b__ug:RemoveTag "NOCLICK"
            end
        end
    }
}
CommonStates["AddWalkStates"](
    buG,
    {
        starttimeline = {
            TimeEvent(
                0,
                function(b__U_g_)
                    b__U_g_["Physics"]:Stop()
                end
            )
        },
        walktimeline = {
            TimeEvent(
                0,
                function(__BU__G_)
                    __BU__G_["Physics"]:Stop()
                end
            ),
            TimeEvent(
                7 * FRAMES,
                function(__bu_G__)
                    __bu_G__["components"]["locomotor"]:WalkForward()
                end
            ),
            TimeEvent(
                20 * FRAMES,
                function(__B__U__g__)
                    __B__U__g__["SoundEmitter"]:PlaySound "dontstarve/creatures/rook_minotaur/step"
                    ShakeAllCameras(CAMERA["VERTICAL"], .5, .05, .1, __B__U__g__, 40)
                    __B__U__g__["Physics"]:Stop()
                end
            )
        }
    },
    nil,
    (287 + 442 + 346 - 55 ~= 1028)
)
CommonStates["AddSleepStates"](
    buG,
    {
        starttimeline = {
            TimeEvent(
                11 * FRAMES,
                function(Bu_G__)
                    Bu_G__["SoundEmitter"]:PlaySound "dontstarve/creatures/rook_minotaur/liedown"
                end
            )
        },
        sleeptimeline = {
            TimeEvent(
                18 * FRAMES,
                function(BUG)
                    BUG["SoundEmitter"]:PlaySound "dontstarve/creatures/rook_minotaur/sleep"
                end
            )
        }
    }
)
CommonStates["AddFrozenStates"](buG)
return StateGraph("minotau", buG, __B__U_g__, "idle")
