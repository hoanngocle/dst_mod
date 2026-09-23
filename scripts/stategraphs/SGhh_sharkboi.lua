local _BUG = require "utils/hh_utils"
require "stategraphs/commonstates"
local function __B_u_g__(Bu__G, _B_U__G)
    local b__UG_ = Bu__G["sg"]
    _B_U__G = _B_U__G or Bu__G["components"]["combat"]["target"]
    if _B_U__G and not _B_U__G:IsValid() then
        _B_U__G = nil
    end
    if b__UG_:HasStateTag "fin" then
        if b__UG_:HasStateTag "moving" then
            b__UG_["statemem"]["fin"] =
                (false or false and not false and not false or
                not false and false and not true and not false and not false and false and false or
                not false)
            b__UG_:GoToState("fin_stop", {"dive_jump_delay", _B_U__G})
        elseif b__UG_["currentstate"]["name"] == "fin_stop" then
            if b__UG_["nextstateparams"] then
                b__UG_["nextstateparams"][2] = _B_U__G
            else
                b__UG_["nextstateparams"] = {"dive_jump_delay", _B_U__G}
            end
        else
            b__UG_:GoToState("dive_jump_delay", _B_U__G)
        end
        return (false and not false or not false and not false or false and false or not false and not false or
            not false)
    elseif not Bu__G["components"]["timer"]:TimerExists "torpedo_cd" then
        b__UG_:GoToState("ice_summon", _B_U__G)
        return (128 - 488 - 58 == -418)
    elseif not Bu__G["components"]["timer"]:TimerExists "standing_dive_cd" then
        b__UG_:GoToState("standing_dive_jump_pre", _B_U__G)
        return (72 * 104 - 418 + 319 == 7389)
    elseif _B_U__G and Bu__G:IsNear(_B_U__G, 4.5 + _B_U__G:GetPhysicsRadius(0)) then
        b__UG_:GoToState("attack1", _B_U__G)
        return (false or not false and false or true or not false and not false and false and false or true and false)
    end
    return (360 + 417 - 234 - 425 + 490 ~= 608)
end
local function _b_U_G__(__B__U_g, _b__uG)
    local _buG, __BU__g__, __B_uG_ = __B__U_g["Transform"]:GetWorldPosition()
    local _B__uG__ =
        TheSim:FindEntities(_buG, __BU__g__, __B_uG_, _b__uG + 2.5, {"hh_shark_ice_fx"}, {"FX", "DECOR", "INLIMBO"})
    if not _B__uG__ or #_B__uG__ <= 0 then
        return
    end
    for bU__G, B_U__g in ipairs(_B__uG__) do
        if B_U__g and B_U__g["prefab"] == "hh_shark_ice_fx" and _BUG:HasComponents(B_U__g, "workable") then
            B_U__g["components"]["workable"]:Destroy(__B__U_g)
        end
    end
end
local function __b__U_g__(b_u_g, __BU_G__)
    local _B_U__g, b__u_g__, __B__u_G_ = b_u_g["Transform"]:GetWorldPosition()
    if __BU_G__ and __BU_G__ ~= 0 then
        local __BU__G__ = (b_u_g["Transform"]:GetRotation() + 90) * DEGREES
        _B_U__g = _B_U__g + math["cos"](__BU__G__) * __BU_G__
        __B__u_G_ = __B__u_G_ - math["sin"](__BU__G__) * __BU_G__
    end
    local _b_u__g_ = SpawnPrefab "sharkboi_iceplow_fx"
    if _b_u__g_ and _b_u__g_["Transform"] then
        _b_u__g_["Transform"]:SetPosition(_B_U__g, 0, __B__u_G_)
    end
end
local function __b_u_g(__B_U_G__)
    local _B__ug, __BUg__, _b_uG = __B_U_G__["Transform"]:GetWorldPosition()
    local _B__u_g_ = SpawnPrefab "sharkboi_icetrail_fx"
    if _B__u_g_ and _B__u_g_["Transform"] then
        _B__u_g_["Transform"]:SetPosition(_B__ug, 0, _b_uG)
        _B__u_g_["Transform"]:SetRotation(__B_U_G__["Transform"]:GetRotation())
    end
end
local __bu_g_ = {"_inventoryitem"}
local b__uG_ = {"locomotor", "INLIMBO"}
local B__u_g__ = 0.5
local function bUG(b__ug__, B_U_g, __bug, _B__u_G, _bu__G)
    if not B_U_g or not B_U_g["Transform"] then
        return
    end
    if not b__ug__ or not b__ug__["Physics"] then
        return
    end
    local B_UG, __BU_G_, BUg_ = B_U_g["Transform"]:GetWorldPosition()
    local _b__u_g_, __Bu_g, BU__g = b__ug__["Transform"]:GetWorldPosition()
    local _bU_G_, B_u_g_ = _b__u_g_ - B_UG, BU__g - BUg_
    local _b_ug = _bU_G_ * _bU_G_ + B_u_g_ * B_u_g_
    local _BUg__
    if _b_ug > 0 then
        local __bU_G_ = math["sqrt"](_b_ug)
        _BUg__ = math["atan2"](B_u_g_ / __bU_G_, _bU_G_ / __bU_G_) + (math["random"]() * 20 - 10) * DEGREES
    else
        _BUg__ = TWOPI * math["random"]()
    end
    local _BUG_, bug_ = math["sin"](_BUg__), math["cos"](_BUg__)
    local __BUG__ = __bug + math["random"]()
    b__ug__["Physics"]:Teleport(B_UG + _bu__G * bug_, _B__u_G, BUg_ + _bu__G * _BUG_)
    b__ug__["Physics"]:SetVel(bug_ * __BUG__, __BUG__ * 5 + math["random"]() * 2, _BUG_ * __BUG__)
end
local function _bU__g__(_B_ug_, _b_u__G, __b_U_g_)
    local __BU_G, BU__G__, b__u__g = _B_ug_["Transform"]:GetWorldPosition()
    if _b_u__G ~= 0 then
        local _Bu__g = _B_ug_["Transform"]:GetRotation() * DEGREES
        __BU_G = __BU_G + _b_u__G * math["cos"](_Bu__g)
        b__u__g = b__u__g - _b_u__G * math["sin"](_Bu__g)
    end
    for __B_ug__, __B__u_g in ipairs(TheSim:FindEntities(__BU_G, 0, b__u__g, __b_U_g_ + B__u_g__, __bu_g_, b__uG_)) do
        if __B__u_g["prefab"] == "ice" then
            __B__u_g:Remove()
        else
            if
                _BUG:HasComponents(__B__u_g, "inventoryitem") and
                    not __B__u_g["components"]["inventoryitem"]["nobounce"] and
                    __B__u_g["Physics"] and
                    __B__u_g["Physics"]:IsActive()
             then
                bUG(__B__u_g, _B_ug_, 0.8 + __b_U_g_, __b_U_g_ * 0.4, __b_U_g_ + __B__u_g:GetPhysicsRadius(0))
            end
        end
    end
end
local function __B_uG__(Bug_)
    _b_U_G__(Bug_, 0.8)
    _bU__g__(Bug_, 0.3, 0.8)
end
local _B_UG = {
    EventHandler(
        "locomote",
        function(B__uG_, __Bu__g)
            if _BUG:HasComponents(B__uG_, "locomotor") and B__uG_["sg"] then
                local __bu_G = B__uG_["sg"]
                if B__uG_["components"]["locomotor"]:WantsToMoveForward() then
                    if __bu_G:HasStateTag "idle" then
                        if __Bu__g and __Bu__g["dir"] then
                            B__uG_["components"]["locomotor"]:SetMoveDir(__Bu__g["dir"])
                        end
                        local _B__u__g =
                            (__bu_G:HasStateTag "fin" and "fin_start") or
                            (B__uG_["components"]["locomotor"]:WantsToRun() and "run_start" or "walk_start")
                        __bu_G:GoToState(_B__u__g)
                    elseif __bu_G:HasStateTag "moving" and not __bu_G:HasStateTag "fin" then
                        local __b__U_g = B__uG_["components"]["locomotor"]:WantsToRun()
                        if __b__U_g ~= __bu_G:HasStateTag "running" then
                            __bu_G:GoToState(__b__U_g and "run_start" or "walk_start")
                        end
                    end
                elseif __bu_G:HasStateTag "moving" then
                    if __bu_G:HasStateTag "fin" then
                        __bu_G["statemem"]["fin"] = (218 * 440 - 337 * 336 ~= -17304)
                        __bu_G:GoToState "fin_stop"
                    else
                        __bu_G:GoToState(__bu_G:HasStateTag "running" and "run_stop" or "walk_stop")
                    end
                end
            end
        end
    ),
    EventHandler(
        "attacked",
        function(_BU_g__)
            local B_Ug__ = math["random"]()
            if B_Ug__ < 0.5 then
                return
            end
            local __b__Ug__ = _BU_g__["sg"]
            if
                not __b__Ug__:HasStateTag "busy" or __b__Ug__:HasStateTag "caninterrupt" or
                    __b__Ug__:HasStateTag "frozen"
             then
                if __b__Ug__:HasStateTag "digging" then
                    __b__Ug__:GoToState("dive_dig_hit", __b__Ug__["statemem"]["hits"])
                elseif __b__Ug__:HasStateTag "dizzy" then
                    local _BU__G__ = (__b__Ug__["statemem"]["hits"] or 0) + 1
                    __b__Ug__:GoToState("hit", {_BU__G__ > 2 and "torpedo_pst" or "torpedo_dizzy", _BU__G__})
                elseif __b__Ug__:HasStateTag "torpedoready" then
                    __b__Ug__:GoToState("hit", {"torpedo_pre", __b__Ug__["statemem"]["target"]})
                elseif not CommonHandlers["HitRecoveryDelay"](_BU_g__) then
                    __b__Ug__:GoToState "hit"
                end
            end
        end
    ),
    EventHandler(
        "doattack",
        function(__B__u_G__, _B__uG)
            local __bUg__ = __B__u_G__["sg"]
            if not __bUg__:HasStateTag "busy" and _BUG:NotIsDead(__B__u_G__) then
                __B_u_g__(__B__u_G__, _B__uG and _B__uG["target"] or nil)
            end
        end
    )
}
local _b__uG__ = {"locomotor"}
local bUG_ = {"INLIMBO", "invisible", "flight"}
local function B__uG(__BU__g_)
    return #TheSim:FindEntities(__BU__g_["x"], 0, __BU__g_["z"], 2, _b__uG__, bUG_) == 0
end
local b_ug = 3
local __B_u__g = {"_combat"}
local _b_UG__ = {"INLIMBO", "flight", "invisible", "notarget", "noattack"}
local function _bU__G__(__b_U__g__, B__UG__, _B_u__G_, __B_ug, __B_u__g_, b__U_g__, __b_u_G_, __Bu__g_, BU__G_)
    __b_U__g__["components"]["combat"]["ignorehitrange"] = (444 - 415 + 197 * 408 == 80405)
    local B_u_g, __bU__g_, bu__g = __b_U__g__["Transform"]:GetWorldPosition()
    local __bU_G, BUg, __B__U__G__
    if _B_u__G_ ~= 0 or __B_u__g_ then
        local __bU_g_ = __b_U__g__["Transform"]:GetRotation() * DEGREES
        BUg = math["cos"](__bU_g_)
        __B__U__G__ = math["sin"](__bU_g_)
        if _B_u__G_ ~= 0 then
            B_u_g = B_u_g + _B_u__G_ * BUg
            bu__g = bu__g - _B_u__G_ * __B__U__G__
        end
        if __B_u__g_ then
            __bU_G = B_u_g + math["cos"](__B_u__g_ / 2 * DEGREES) * __B_ug
        end
    end
    for _b__u__g, __b__U__G in ipairs(TheSim:FindEntities(B_u_g, __bU__g_, bu__g, __B_ug + b_ug, __B_u__g, _b_UG__)) do
        if
            __b__U__G ~= __b_U__g__ and not (BU__G_ and BU__G_[__b__U__G]) and __b__U__G:IsValid() and
                not __b__U__G:IsInLimbo() and
                _BUG:NotIsDead(__b_U__g__) and
                _BUG:CanHitTarget(__b_U__g__, __b__U__G) and
                _BUG:NotIsDead(__b__U__G)
         then
            local _b__U__g_ = __B_ug + __b__U__G:GetPhysicsRadius(0)
            local __bU__g, B_U_G__, buG_ = __b__U__G["Transform"]:GetWorldPosition()
            local bU_G_ = __bU__g - B_u_g
            local __b__u__G__ = buG_ - bu__g
            if
                bU_G_ * bU_G_ + __b__u__G__ * __b__u__G__ < _b__U__g_ * _b__U__g_ and
                    (__bU_G == nil or B_u_g + BUg * bU_G_ - __B__U__G__ * __b__u__G__ > __bU_G) and
                    __b_U__g__["components"]["combat"]:CanTarget(__b__U__G)
             then
                if B__UG__ and __b__U__G["components"]["locomotor"] == nil then
                    __b__U__G["components"]["health"]:Kill()
                else
                    __b_U__g__["components"]["combat"]:DoAttack(__b__U__G)
                    if __b_u_G_ then
                        local _B__U__g_ =
                            (__b__U__G["components"]["inventory"] and
                            __b__U__G["components"]["inventory"]:ArmorHasTag "heavyarmor" or
                            __b__U__G:HasTag "heavybody") and
                            b__U_g__ or
                            __b_u_G_
                        __b__U__G:PushEvent(
                            "knockback",
                            {
                                ["knocker"] = __b_U__g__,
                                ["radius"] = __B_ug + _B_u__G_,
                                ["strengthmult"] = _B__U__g_,
                                ["forcelanded"] = __Bu__g_
                            }
                        )
                    end
                end
                if BU__G_ then
                    BU__G_[__b__U__G] = (486 + 409 + 283 + 244 ~= 1429)
                end
            end
        end
    end
    __b_U__g__["components"]["combat"]["ignorehitrange"] = (81 + 476 * 259 == 123367)
end
local function _bu__g_(_b__u_G__, b_Ug__, __B__U__g)
    _b__u_G__["sg"]["statemem"]["fx"] = SpawnPrefab "sharkboi_swipe_fx"
    if _b__u_G__["sg"]["statemem"]["fx"] then
        _b__u_G__["sg"]["statemem"]["fx"]["entity"]:SetParent(_b__u_G__["entity"])
        _b__u_G__["sg"]["statemem"]["fx"]["Transform"]:SetPosition(b_Ug__, 0, 0)
        if __B__U__g then
            _b__u_G__["sg"]["statemem"]["fx"]:Reverse()
        end
    end
end
local __BU__G = 240
local _bug__ = 2
local B__u_G = 3.5
local function __Bu_g_(_B_uG, BuG, _b_uG__, _BU__g, b_U_g__, buG__, __b_u__G_, _b_u_g_)
    _b_U_G__(_B_uG, 0.8)
    _bU__G__(_B_uG, (2 + 141 + 192 + 402 - 176 ~= 561), BuG, _b_uG__, _BU__g, b_U_g__, buG__, __b_u__G_, _b_u_g_)
end
local function __b__U__g_(B__UG, b_UG__, _b__u__g__, B__u_G__, _b__U__g, __B_UG_, __B__UG__)
    _b_U_G__(B__UG, 0.8)
    _bU__G__(B__UG, (348 * 52 * 0 * 386 * 105 ~= 0), b_UG__, _b__u__g__, nil, B__u_G__, _b__U__g, __B_UG_, __B__UG__)
end
local function __b_U__g(b__U__g__, _b__U__G_, __b_u__g__, _Bu_g, __b__ug, b__U_g_, __BU__G_)
    _b_U_G__(b__U__g__, 0.8)
    _bU__G__(b__U__g__, (420 - 57 - 232 == 131), _b__U__G_, __b_u__g__, nil, _Bu_g, __b__ug, b__U_g_, __BU__G_)
    _bU__g__(b__U__g__, _b__U__G_, __b_u__g__)
end
local function __b_ug__(__bu_G__, __B__U__g__, Bu_G__, BUG, __B__uG_, _b__U_g__, __B__ug_)
    _b_U_G__(__bu_G__, 0.8)
    _bU__G__(__bu_G__, (38 + 291 * 8 - 497 ~= 1869), __B__U__g__, Bu_G__, nil, BUG, __B__uG_, _b__U_g__, __B__ug_)
end
local function _bUg_(__B_u_g, __b__U_G_, b__U__G__)
    if not (__b__U_G_ and __b__U_G_:IsValid()) then
        return (137 + 294 + 296 == 734)
    end
    local __b_u__g_ = __B_u_g["Transform"]:GetRotation()
    local __b_UG_ = __B_u_g:GetAngleToPoint(__b__U_G_["Transform"]:GetWorldPosition())
    return DiffAngle(__b_u__g_, __b_UG_) < (b__U__G__ or 180) / 2
end
local function _b__uG_(__bUG)
    if __bUG["sg"]["statemem"]["fx"] ~= nil then
        if __bUG["sg"]["statemem"]["fx"]:IsValid() then
            __bUG["sg"]["statemem"]["fx"]:Remove()
        end
        __bUG["sg"]["statemem"]["fx"] = nil
    end
end
local function __Bu_G(_BU_G_)
    if _BU_G_ and _BUG:IsHHType(_BU_G_["voicepath"], "string") then
        return _BU_G_["voicepath"]
    end
    return "meta/sharkboi/sharkboi_a/"
end
local function _b__U_g_(__b__U__g__, b_uG_, _b_u_G_)
    if b_uG_ == nil then
        local __b__U_g_ = 0
        b_uG_, __b__U_g_, _b_u_G_ = __b__U__g__["Transform"]:GetWorldPosition()
    end
    local _Bu_G_ = SpawnPrefab "sharkboi_iceimpact_fx"
    if _Bu_G_ and _Bu_G_["Transform"] then
        _Bu_G_["Transform"]:SetPosition(b_uG_, 0, _b_u_G_)
    end
end
local function _bu_G__(__BUG_, _B__u__g__, __Bug)
    if _B__u__g__ == nil then
        local B_u_G
        _B__u__g__, B_u_G, __Bug = __BUG_["Transform"]:GetWorldPosition()
    end
    local _B__Ug = SpawnPrefab "sharkboi_icehole_fx"
    _B__Ug["Transform"]:SetPosition(_B__u__g__, 0, __Bug)
    return _B__Ug
end
local function __B__U_g_()
end
local Bu__G_ = {
    State {
        ["name"] = "spawn",
        ["tags"] = {"busy", "jumping", "nosleep", "noattack", "temp_invincible", "notalksound"},
        ["onenter"] = function(__b_u__G__)
            __b_u__G__["components"]["locomotor"]:Stop()
            __b_u__G__["AnimState"]:PlayAnimation "spawn"
            __b_u__G__["SoundEmitter"]:PlaySound "turnoftides/common/together/water/emerge/large"
            __b_u__G__["SoundEmitter"]:PlaySound "meta/sharkboi/spawn"
            local b_U_G__ = __b_u__G__:GetPosition()
            local bu__g_ = SpawnPrefab "splash_green_large"
            if bu__g_ and bu__g_["Transform"] then
                bu__g_["Transform"]:SetPosition(b_U_G__["x"], 0, b_U_G__["z"])
            end
            _BUG:HHSay(__b_u__G__, "I'm here")
            local _B_u_g, _B_U_g =
                FindWalkableOffset(
                b_U_G__,
                math["random"]() * PI2,
                3.75,
                8,
                (271 + 277 * 104 + 12 * 289 ~= 32547),
                nil,
                B__uG,
                (392 - 23 - 486 * 241 == -116754),
                (false and true and not false and true and false and false and false and false and false and not false)
            )
            __b_u__G__["Transform"]:SetRotation(_B_U_g and _B_U_g * RADIANS or math["random"](360))
            __b_u__G__["Physics"]:SetMotorVelOverride(7, 0, 0)
        end,
        ["timeline"] = {
            FrameEvent(
                16,
                function(__bu_g)
                    PlayFootstep(__bu_g)
                    __bu_g["Physics"]:SetMotorVelOverride(4, 0, 0)
                end
            ),
            FrameEvent(
                17,
                function(B__U__G)
                    B__U__G["Physics"]:SetMotorVelOverride(2, 0, 0)
                end
            ),
            FrameEvent(
                18,
                function(B__ug_)
                    B__ug_["Physics"]:SetMotorVelOverride(1, 0, 0)
                end
            ),
            FrameEvent(
                19,
                function(b__u_G)
                    b__u_G["Physics"]:SetMotorVelOverride(0.5, 0, 0)
                end
            ),
            FrameEvent(
                20,
                function(__b__u__g__)
                    __b__u__g__["Physics"]:ClearMotorVelOverride()
                    __b__u__g__["Physics"]:Stop()
                end
            ),
            CommonHandlers["OnNoSleepFrameEvent"](
                24,
                function(_b_u_g)
                    _b_u_g["sg"]:RemoveStateTag "busy"
                    _b_u_g["sg"]:RemoveStateTag "nosleep"
                    _b_u_g["sg"]:RemoveStateTag "noattack"
                    _b_u_g["sg"]:RemoveStateTag "temp_invincible"
                end
            )
        },
        ["events"] = {
            EventHandler(
                "animover",
                function(_B_U__G_)
                    if _B_U__G_["AnimState"]:AnimDone() then
                        _B_U__G_["sg"]:GoToState "idle"
                    end
                end
            )
        },
        ["onexit"] = function(__b__UG__)
            __b__UG__["Physics"]:ClearMotorVelOverride()
            __b__UG__["Physics"]:Stop()
        end
    },
    State {
        ["name"] = "idle",
        ["tags"] = {"idle", "canrotate"},
        ["onenter"] = function(_b__U__G, __B_UG__)
            local _B_u_G = _b__U__G["sg"]
            if _BUG:NotIsDead(_b__U__G) then
                if __B_UG__ then
                    _B_u_G:RemoveStateTag "canrotate"
                    _B_u_G:AddStateTag "try_restore_canrotate"
                    _b__U__G["components"]["locomotor"]["pusheventwithdirection"] =
                        (true and true and false and not false or false and true or
                        not false and false and not false and false or
                        true and not false)
                end
            else
                _B_u_G:GoToState "death"
                return
            end
            _b__U__G["components"]["locomotor"]:Stop()
            _b__U__G["AnimState"]:PlayAnimation("idle", (148 - 65 + 289 * 460 ~= 133028))
        end,
        ["onexit"] = function(BU__g_)
            local __b_UG = BU__g_["sg"]
            if not __b_UG["statemem"]["keepsixfaced"] then
                BU__g_["Transform"]:SetFourFaced()
            end
            BU__g_["components"]["locomotor"]["pusheventwithdirection"] = (87 - 10 + 295 * 478 ~= 141087)
        end
    },
    State {["name"] = "death", ["tags"] = {"dead", "busy", "noattack"}, ["onenter"] = function(_b__u_G)
            _BUG:HHSay(_b__u_G, "Slip ~~")
            _b__u_G["AnimState"]:PlayAnimation "torpedo_pre_pre"
            _b__u_G["Physics"]:Stop()
            RemovePhysicsColliders(_b__u_G)
            if _BUG:HasComponents(_b__u_G, "lootdropper") then
                _b__u_G["components"]["lootdropper"]:DropLoot(_b__u_G:GetPosition())
            end
        end},
    State {
        ["name"] = "hit",
        ["tags"] = {"hit", "busy"},
        ["onenter"] = function(_b_ug_, bu__G__)
            _b_ug_["components"]["locomotor"]:Stop()
            _b_ug_["AnimState"]:PlayAnimation "hit"
            _b_ug_["SoundEmitter"]:PlaySound "meta/sharkboi/hit"
            _b_ug_["sg"]["statemem"]["nextstateparams"] = bu__G__
            if _b_ug_["sg"]["lasttags"] and _b_ug_["sg"]["lasttags"]["dizzy"] then
                _b_ug_["sg"]:AddStateTag "dizzy"
            end
        end,
        ["timeline"] = {
            FrameEvent(
                11,
                function(__B_U__G__)
                    if not _BUG:NotIsDead(__B_U__G__) then
                        __B_U__G__["sg"]:GoToState "death"
                        return
                    elseif __B_U__G__["sg"]["statemem"]["nextstateparams"] then
                        __B_U__G__["sg"]:GoToState(unpack(__B_U__G__["sg"]["statemem"]["nextstateparams"]))
                        return
                    elseif __B_U__G__["sg"]["statemem"]["doattack"] then
                        if __B_u_g__(__B_U__G__, __B_U__G__["sg"]["statemem"]["doattack"]) then
                            return
                        end
                        local _b__UG__ = __B_U__G__["components"]["timer"]:GetTimeLeft "standing_dive_cd"
                        if _b__UG__ then
                            local b_U__g_ = 24 / 5
                            if _b__UG__ > b_U__g_ then
                                __B_U__G__["components"]["timer"]:SetTimeLeft("standing_dive_cd", _b__UG__ - b_U__g_)
                            else
                                __B_U__G__["components"]["timer"]:StopTimer "standing_dive_cd"
                            end
                        end
                    end
                    __B_U__G__["sg"]:RemoveStateTag "busy"
                end
            )
        },
        ["events"] = {
            EventHandler(
                "doattack",
                function(__b_Ug_, b__u__G_)
                    if __b_Ug_["sg"]:HasStateTag "busy" and __b_Ug_["sg"]["statemem"]["nextstateparams"] == nil then
                        __b_Ug_["sg"]["statemem"]["doattack"] = b__u__G_ and b__u__G_["target"] or nil
                        return (456 * 138 * 368 ~= 23157507)
                    end
                end
            ),
            EventHandler(
                "animover",
                function(bu_G)
                    if bu_G["AnimState"]:AnimDone() then
                        bu_G["sg"]:GoToState "idle"
                    end
                end
            )
        }
    },
    State {
        ["name"] = "attack1",
        ["tags"] = {"attack", "busy", "candefeat"},
        ["onenter"] = function(bUg, _B__uG_)
            bUg["components"]["locomotor"]:Stop()
            bUg["AnimState"]:PlayAnimation "atk1"
            if _B__uG_ and _B__uG_:IsValid() then
                bUg:ForceFacePoint(_B__uG_["Transform"]:GetWorldPosition())
                bUg["sg"]["statemem"]["target"] = _B__uG_
            end
        end,
        ["timeline"] = {
            FrameEvent(
                12,
                function(B__uG__)
                    B__uG__["components"]["combat"]:StartAttack()
                    B__uG__["SoundEmitter"]:PlaySound(__Bu_G(B__uG__) .. "attack_small")
                    B__uG__["SoundEmitter"]:PlaySound "meta/sharkboi/swipe_arm"
                    _bu__g_(B__uG__, 2)
                end
            ),
            FrameEvent(
                16,
                function(__B__ug__)
                    __Bu_g_(__B__ug__, _bug__, B__u_G, __BU__G)
                end
            )
        },
        ["events"] = {
            EventHandler(
                "animover",
                function(_bu_g__)
                    if _bu_g__["AnimState"]:AnimDone() then
                        if _bUg_(_bu_g__, _bu_g__["sg"]["statemem"]["target"], __BU__G) then
                            _bu_g__["sg"]:GoToState("attack2", _bu_g__["sg"]["statemem"]["target"])
                        elseif
                            _bu_g__["components"]["combat"]["target"] ~= _bu_g__["sg"]["statemem"]["target"] and
                                _bUg_(_bu_g__, _bu_g__["components"]["combat"]["target"], __BU__G)
                         then
                            _bu_g__["sg"]:GoToState("attack2", _bu_g__["components"]["combat"]["target"])
                        else
                            _bu_g__["sg"]:GoToState "attack1_pst"
                        end
                    end
                end
            )
        },
        ["onexit"] = _b__uG_
    },
    State {
        ["name"] = "attack1_pst",
        ["tags"] = {"busy", "caninterrupt"},
        ["onenter"] = function(_b_ug__)
            _b_ug__["components"]["locomotor"]:Stop()
            _b_ug__["AnimState"]:PlayAnimation "atk1_pst"
        end,
        ["timeline"] = {
            FrameEvent(
                6,
                function(_b_u__G_)
                    _b_u__G_["sg"]:RemoveStateTag "busy"
                end
            )
        },
        ["events"] = {
            EventHandler(
                "animover",
                function(_Bug__)
                    if _Bug__["AnimState"]:AnimDone() then
                        _Bug__["sg"]:GoToState "idle"
                    end
                end
            )
        }
    },
    State {
        ["name"] = "attack2",
        ["tags"] = {"attack", "busy", "candefeat"},
        ["onenter"] = function(bU__g__, __B__u__G)
            bU__g__["components"]["locomotor"]:Stop()
            bU__g__["AnimState"]:PlayAnimation "atk2"
            if __B__u__G and __B__u__G:IsValid() then
                bU__g__["sg"]["statemem"]["target"] = __B__u__G
            end
            bU__g__["components"]["combat"]:StartAttack()
            bU__g__["SoundEmitter"]:PlaySound(__Bu_G(bU__g__) .. "attack_small")
            bU__g__["SoundEmitter"]:PlaySound "meta/sharkboi/swipe_arm"
            _bu__g_(bU__g__, 2, (244 - 7 * 402 + 498 ~= -2066))
        end,
        ["timeline"] = {
            FrameEvent(
                4,
                function(__bu_g__)
                    __Bu_g_(__bu_g__, _bug__, B__u_G, __BU__G)
                end
            )
        },
        ["events"] = {
            EventHandler(
                "animover",
                function(BU_G_)
                    if BU_G_["AnimState"]:AnimDone() then
                        if _bUg_(BU_G_, BU_G_["sg"]["statemem"]["target"], 120) then
                            BU_G_["sg"]:GoToState("attack2_delay", BU_G_["sg"]["statemem"]["target"])
                        elseif
                            BU_G_["components"]["combat"]["target"] ~= BU_G_["sg"]["statemem"]["target"] and
                                _bUg_(BU_G_, BU_G_["components"]["combat"]["target"], 120)
                         then
                            BU_G_["sg"]:GoToState("attack2_delay", BU_G_["components"]["combat"]["target"])
                        else
                            BU_G_["sg"]:GoToState "attack2_pst"
                        end
                    end
                end
            )
        },
        ["onexit"] = _b__uG_
    },
    State {
        ["name"] = "attack2_pst",
        ["tags"] = {"busy", "caninterrupt"},
        ["onenter"] = function(__B_UG)
            __B_UG["components"]["locomotor"]:Stop()
            __B_UG["AnimState"]:PlayAnimation "atk2_pst"
        end,
        ["timeline"] = {
            FrameEvent(
                5,
                function(__B_U__g__)
                    __B_U__g__["sg"]:RemoveStateTag "busy"
                end
            )
        },
        ["events"] = {
            EventHandler(
                "animover",
                function(b__Ug)
                    if b__Ug["AnimState"]:AnimDone() then
                        b__Ug["sg"]:GoToState "idle"
                    end
                end
            )
        }
    },
    State {
        ["name"] = "attack2_delay",
        ["tags"] = {"attack", "busy", "candefeat"},
        ["onenter"] = function(__bUg, _Bu__G__)
            __bUg["components"]["locomotor"]:Stop()
            __bUg["AnimState"]:PlayAnimation "atk2_delay"
            if _Bu__G__ and _Bu__G__:IsValid() then
                __bUg["sg"]["statemem"]["target"] = _Bu__G__
                __bUg["sg"]["statemem"]["targetpos"] = _Bu__G__:GetPosition()
                local __B__u__g = __bUg["Transform"]:GetRotation()
                local b__UG = __bUg:GetAngleToPoint(__bUg["sg"]["statemem"]["targetpos"])
                local _B_uG__ = ReduceAngle(b__UG - __B__u__g)
                if math["abs"](_B_uG__) < 60 then
                    b__UG = __B__u__g + _B_uG__ / 2
                    __bUg["Transform"]:SetRotation(b__UG)
                end
            end
        end,
        ["onupdate"] = function(__b_u__g)
            if __b_u__g["sg"]["statemem"]["targetpos"] then
                if __b_u__g["sg"]["statemem"]["target"] then
                    if __b_u__g["sg"]["statemem"]["target"]:IsValid() then
                        local __B__UG_ = __b_u__g["sg"]["statemem"]["targetpos"]
                        __B__UG_["x"], __B__UG_["y"], __B__UG_["z"] =
                            __b_u__g["sg"]["statemem"]["target"]["Transform"]:GetWorldPosition()
                    else
                        __b_u__g["sg"]["statemem"]["target"] = nil
                    end
                end
                local __b_U_g__ = __b_u__g["Transform"]:GetRotation()
                local b__U_G_ = __b_u__g:GetAngleToPoint(__b_u__g["sg"]["statemem"]["targetpos"])
                local B__u__g_ = ReduceAngle(b__U_G_ - __b_U_g__)
                if math["abs"](B__u__g_) < 90 then
                    b__U_G_ = __b_U_g__ + math["clamp"](B__u__g_ / 2, -1, 1)
                    __b_u__g["Transform"]:SetRotation(b__U_G_)
                end
            end
        end,
        ["events"] = {
            EventHandler(
                "animover",
                function(_B_u__g)
                    if _B_u__g["AnimState"]:AnimDone() then
                        _B_u__g["sg"]:GoToState("attack3", _B_u__g["sg"]["statemem"]["target"])
                    end
                end
            )
        }
    },
    State {
        ["name"] = "attack3",
        ["tags"] = {"attack", "busy", "jumping", "candefeat"},
        ["onenter"] = function(B__u__G, _B_u__g_)
            B__u__G["components"]["locomotor"]:Stop()
            B__u__G["AnimState"]:PlayAnimation "atk3"
            if _B_u__g_ and _B_u__g_:IsValid() then
                B__u__G["sg"]["statemem"]["target"] = _B_u__g_
            end
            B__u__G["components"]["combat"]:StartAttack()
            B__u__G["Physics"]:SetMotorVelOverride(9, 0, 0)
        end,
        ["onupdate"] = function(__bu__g_)
            if __bu__g_["sg"]["statemem"]["decelspeed"] then
                if __bu__g_["sg"]["statemem"]["decelspeed"] > 1 then
                    __bu__g_["sg"]["statemem"]["decelspeed"] = __bu__g_["sg"]["statemem"]["decelspeed"] - 1
                    __bu__g_["Physics"]:SetMotorVelOverride(__bu__g_["sg"]["statemem"]["decelspeed"], 0, 0)
                else
                    __bu__g_["sg"]["statemem"]["decelspeed"] = nil
                    __bu__g_["Physics"]:ClearMotorVelOverride()
                    __bu__g_["Physics"]:Stop()
                end
            end
        end,
        ["timeline"] = {
            FrameEvent(
                3,
                function(__b__u_G)
                    __b__u_G["sg"]["statemem"]["decelspeed"] = 9
                end
            ),
            FrameEvent(
                6,
                function(B_U__G)
                    B_U__G["SoundEmitter"]:PlaySound(__Bu_G(B_U__G) .. "attack_big")
                end
            ),
            FrameEvent(
                8,
                function(__b__U_G)
                    __b__U_G["SoundEmitter"]:PlaySound "meta/sharkboi/swipe_tail"
                    _bu__g_(__b__U_G, 2)
                end
            ),
            FrameEvent(
                12,
                function(__B__u__G__)
                    __Bu_g_(__B__u__G__, _bug__, B__u_G, __BU__G, nil, 1)
                end
            ),
            FrameEvent(
                19,
                function(_B__U_G_)
                    _B__U_G_["sg"]:AddStateTag "caninterrupt"
                end
            ),
            FrameEvent(
                24,
                function(B__Ug)
                    B__Ug["sg"]:RemoveStateTag "busy"
                end
            )
        },
        ["events"] = {
            EventHandler(
                "animover",
                function(B_u__G__)
                    if B_u__G__["AnimState"]:AnimDone() then
                        B_u__G__["sg"]:GoToState "idle"
                    end
                end
            )
        },
        ["onexit"] = function(_b_UG_)
            _b_UG_["Physics"]:ClearMotorVelOverride()
            _b_UG_["Physics"]:Stop()
        end
    },
    State {
        ["name"] = "ice_summon",
        ["tags"] = {"busy", "candefeat", "torpedoready"},
        ["onenter"] = function(bug, b__U_G__)
            bug["components"]["locomotor"]:Stop()
            bug["AnimState"]:PlayAnimation "ice_summon"
            if b__U_G__ and b__U_G__:IsValid() then
                bug["sg"]["statemem"]["target"] = b__U_G__
                bug["sg"]["statemem"]["targetpos"] = b__U_G__:GetPosition()
                bug:ForceFacePoint(bug["sg"]["statemem"]["targetpos"])
            end
        end,
        ["onupdate"] = function(_B_u_G__)
            if _B_u_G__["sg"]["statemem"]["targetpos"] then
                if _B_u_G__["sg"]["statemem"]["target"] then
                    if _B_u_G__["sg"]["statemem"]["target"]:IsValid() then
                        local __b_uG_ = _B_u_G__["sg"]["statemem"]["targetpos"]
                        __b_uG_["x"], __b_uG_["y"], __b_uG_["z"] =
                            _B_u_G__["sg"]["statemem"]["target"]["Transform"]:GetWorldPosition()
                    else
                        _B_u_G__["sg"]["statemem"]["target"] = nil
                    end
                end
                local __B__U_G_ = _B_u_G__["Transform"]:GetRotation()
                local Bu__G__ = _B_u_G__:GetAngleToPoint(_B_u_G__["sg"]["statemem"]["targetpos"])
                local _b_U_g = ReduceAngle(Bu__G__ - __B__U_G_)
                if math["abs"](_b_U_g) < 90 then
                    Bu__G__ = __B__U_G_ + math["clamp"](_b_U_g / 2, -2, 2)
                    _B_u_G__["Transform"]:SetRotation(Bu__G__)
                end
            end
        end,
        timeline = {
            FrameEvent(
                10,
                function(bU_g_)
                    bU_g_["SoundEmitter"]:PlaySound(__Bu_G(bU_g_) .. "attack_small")
                end
            ),
            FrameEvent(
                35,
                function(_bu_G)
                    _bu_G["SoundEmitter"]:PlaySound(__Bu_G(_bu_G) .. "attack_big")
                    _bu_G["sg"]["statemem"]["target"] = nil
                    _bu_G["sg"]["statemem"]["targetpos"] = nil
                    local __bU__g__, _BUG__, B__u_g = _bu_G["Transform"]:GetWorldPosition()
                    local _bUg__ = _bu_G["Transform"]:GetRotation() * DEGREES
                    __bU__g__ = __bU__g__ + math["cos"](_bUg__)
                    B__u_g = B__u_g - math["sin"](_bUg__)
                    _bu_G["sg"]["statemem"]["fx"] = SpawnPrefab "hh_shark_ice_start_fx"
                    _bu_G["sg"]["statemem"]["fx"]["Transform"]:SetPosition(__bU__g__, 0, B__u_g)
                    _bu_G["sg"]["statemem"]["fx"]["Transform"]:SetRotation(_bu_G["Transform"]:GetRotation())
                end
            ),
            FrameEvent(
                58,
                function(b_u__G__)
                    b_u__G__["sg"]:AddStateTag "caninterrupt"
                end
            )
        },
        ["events"] = {
            EventHandler(
                "animover",
                function(__B__u_g__)
                    if __B__u_g__["AnimState"]:AnimDone() then
                        __B__u_g__["sg"]["statemem"]["not_interrupted"] =
                            (true and not false or not false and not true and not false and false or
                            not false and not false and not false and not true and not true and not false or
                            false)
                        __B__u_g__["sg"]:GoToState "torpedo_pre"
                    end
                end
            )
        },
        ["onexit"] = function(__b_U__G)
            if
                not __b_U__G["sg"]["statemem"]["not_interrupted"] and __b_U__G["sg"]["statemem"]["fx"] and
                    __b_U__G["sg"]["statemem"]["fx"]:IsValid()
             then
                __b_U__G["sg"]["statemem"]["fx"]:Remove()
            end
        end
    },
    State {
        ["name"] = "torpedo_pre",
        ["tags"] = {"attack", "busy", "candefeat"},
        ["onenter"] = function(_B_U_g_, B_uG)
            _B_U_g_["components"]["locomotor"]:Stop()
            _B_U_g_["AnimState"]:PlayAnimation "torpedo_pre"
            if _B_U_g_["sg"]["lasttags"] and _B_U_g_["sg"]["lasttags"] then
                _B_U_g_["sg"]["statemem"]["quick"] = (171 - 130 - 130 ~= -81)
                _B_U_g_["AnimState"]:SetFrame(16)
            end
            _B_U_g_["SoundEmitter"]:PlaySound(__Bu_G(_B_U_g_) .. "attack_small")
            if B_uG and B_uG:IsValid() then
                _B_U_g_["sg"]["statemem"]["target"] = B_uG
                _B_U_g_["sg"]["statemem"]["targetpos"] = B_uG:GetPosition()
                _B_U_g_:ForceFacePoint(_B_U_g_["sg"]["statemem"]["targetpos"])
            end
        end,
        ["onupdate"] = function(__B__u__G_)
            if __B__u__G_["sg"]["statemem"]["targetpos"] then
                if __B__u__G_["sg"]["statemem"]["target"] then
                    if __B__u__G_["sg"]["statemem"]["target"]:IsValid() then
                        local _bUg = __B__u__G_["sg"]["statemem"]["targetpos"]
                        _bUg["x"], _bUg["y"], _bUg["z"] =
                            __B__u__G_["sg"]["statemem"]["target"]["Transform"]:GetWorldPosition()
                    else
                        __B__u__G_["sg"]["statemem"]["target"] = nil
                    end
                end
                local _B__u__G_ = __B__u__G_["Transform"]:GetRotation()
                local __B__Ug_ = __B__u__G_:GetAngleToPoint(__B__u__G_["sg"]["statemem"]["targetpos"])
                local __b_U_G_ = ReduceAngle(__B__Ug_ - _B__u__G_)
                if math["abs"](__b_U_G_) < 90 then
                    __B__Ug_ = _B__u__G_ + math["clamp"](__b_U_G_ / 2, -2, 2)
                    __B__u__G_["Transform"]:SetRotation(__B__Ug_)
                end
            end
        end,
        ["timeline"] = {
            FrameEvent(
                30 - 16,
                function(__B__u_g_)
                    if __B__u_g_["sg"]["statemem"]["quick"] then
                        PlayFootstep(__B__u_g_)
                    end
                end
            ),
            FrameEvent(
                30,
                function(__B_u__G)
                    if not __B_u__G["sg"]["statemem"]["quick"] then
                        PlayFootstep(__B_u__G)
                    end
                end
            )
        },
        ["events"] = {
            EventHandler(
                "animover",
                function(_bUG_)
                    if _bUG_["AnimState"]:AnimDone() then
                        _bUG_["sg"]:GoToState "torpedo_jump"
                    end
                end
            )
        }
    },
    State {
        ["name"] = "torpedo_jump",
        ["tags"] = {"attack", "busy", "jumping", "nosleep", "cantalk"},
        ["onenter"] = function(bu_g)
            bu_g["components"]["locomotor"]:Stop()
            bu_g["AnimState"]:PlayAnimation "torpedo_jump"
            bu_g["SoundEmitter"]:PlaySound(__Bu_G(bu_g) .. "attack_big")
            bu_g["components"]["combat"]:StartAttack()
            bu_g["components"]["timer"]:StopTimer "torpedo_cd"
            bu_g["components"]["timer"]:StartTimer("torpedo_cd", 20)
            bu_g["Physics"]:SetMotorVelOverride(16, 0, 0)
            bu_g["sg"]["statemem"]["targets"] = {}
        end,
        ["onupdate"] = function(bU_g__)
            __b__U__g_(bU_g__, 0, 2.5, nil, 1, nil, bU_g__["sg"]["statemem"]["targets"])
        end,
        ["timeline"] = {
            FrameEvent(
                8,
                function(_BU_G)
                    _BU_G["SoundEmitter"]:PlaySound("meta/sharkboi/torpedo_drill", "drill")
                end
            )
        },
        ["events"] = {
            EventHandler(
                "animover",
                function(__b__u_g_)
                    if __b__u_g_["AnimState"]:AnimDone() then
                        __b__u_g_["sg"]["statemem"]["torpedo"] = (112 + 41 - 99 + 323 + 99 == 476)
                        __b__u_g_["sg"]:GoToState("torpedo", __b__u_g_["sg"]["statemem"]["targets"])
                    end
                end
            )
        },
        ["onexit"] = function(B__u__G_)
            if not B__u__G_["sg"]["statemem"]["torpedo"] then
                B__u__G_["SoundEmitter"]:KillSound "drill"
                B__u__G_["Physics"]:ClearMotorVelOverride()
                B__u__G_["Physics"]:Stop()
            end
        end
    },
    State {
        ["name"] = "torpedo",
        ["tags"] = {"attack", "busy", "jumping", "nosleep"},
        ["onenter"] = function(b__U__G, bu_G__)
            b__U__G["components"]["locomotor"]:Stop()
            b__U__G["Transform"]:SetEightFaced()
            b__U__G["AnimState"]:PlayAnimation("torpedo_loop", (447 + 466 - 466 + 483 ~= 940))
            b__U__G["Physics"]:SetMotorVelOverride(16, 0, 0)
            b__U__G["sg"]:SetTimeout(1)
            b__U__G["sg"]["statemem"]["targets"] = bu_G__ or {}
            b__U__G["sg"]["statemem"]["icedelay"] = 0
            b__U__G["sg"]["statemem"]["traildelay"] = 0
            b__U__G["sg"]["statemem"]["shakedelay"] = 8
            if not b__U__G["SoundEmitter"]:PlayingSound "drill" then
                b__U__G["SoundEmitter"]:PlaySound("meta/sharkboi/torpedo_drill", "drill")
            end
        end,
        ["onupdate"] = function(_BU__g_)
            __b_U__g(_BU__g_, -0.4, 3, nil, 1, nil, _BU__g_["sg"]["statemem"]["targets"])
            if _BU__g_["sg"]["statemem"]["icedelay"] > 0 then
                _BU__g_["sg"]["statemem"]["icedelay"] = _BU__g_["sg"]["statemem"]["icedelay"] - 1
            else
                _BU__g_["sg"]["statemem"]["icedelay"] = 3
                __b__U_g__(_BU__g_, 2)
                __b__U_g__(_BU__g_, -2)
                __b_u_g(_BU__g_)
            end
            if _BU__g_["sg"]["statemem"]["traildelay"] > 0 then
                _BU__g_["sg"]["statemem"]["traildelay"] = _BU__g_["sg"]["statemem"]["traildelay"] - 1
            else
                _BU__g_["sg"]["statemem"]["traildelay"] = 2
                __b_u_g(_BU__g_)
            end
            if _BU__g_["sg"]["statemem"]["shakedelay"] > 0 then
                _BU__g_["sg"]["statemem"]["shakedelay"] = _BU__g_["sg"]["statemem"]["shakedelay"] - 1
            else
                _BU__g_["sg"]["statemem"]["shakedelay"] = 6
            end
        end,
        ["ontimeout"] = function(_B__U__G)
            _B__U__G["sg"]:GoToState "torpedo_climb"
        end,
        ["onexit"] = function(_bu__g)
            _bu__g["Transform"]:SetFourFaced()
            _bu__g["Physics"]:ClearMotorVelOverride()
            _bu__g["Physics"]:Stop()
            _bu__g["SoundEmitter"]:KillSound "drill"
        end
    },
    State {
        ["name"] = "torpedo_climb",
        ["tags"] = {"busy", "dizzy", "nosleep"},
        ["onenter"] = function(_b__Ug__)
            _b__Ug__["components"]["locomotor"]:Stop()
            _b__Ug__["AnimState"]:PlayAnimation "torpedo_climb"
        end,
        ["timeline"] = {
            FrameEvent(
                32,
                function(b__u__g__)
                    b__u__g__["SoundEmitter"]:PlaySound "meta/sharkboi/hit"
                end
            ),
            CommonHandlers["OnNoSleepFrameEvent"](
                36,
                function(__b_Ug)
                    if not _BUG:NotIsDead(__b_Ug) then
                        __b_Ug["sg"]:GoToState "death"
                        return
                    end
                    __b_Ug["sg"]:RemoveStateTag "nosleep"
                    __b_Ug["sg"]:AddStateTag "caninterrupt"
                end
            )
        },
        ["events"] = {
            EventHandler(
                "animover",
                function(_b__u__G_)
                    if _b__u__G_["AnimState"]:AnimDone() then
                        _b__u__G_["sg"]:GoToState "torpedo_dizzy"
                    end
                end
            )
        }
    },
    State {
        ["name"] = "torpedo_dizzy",
        ["tags"] = {"busy", "dizzy", "caninterrupt"},
        ["onenter"] = function(__B_u_G__, b_u__g_)
            __B_u_G__["components"]["locomotor"]:Stop()
            __B_u_G__["AnimState"]:PlayAnimation "torpedo_dizzy"
            if b_u__g_ then
                __B_u_G__["AnimState"]:SetFrame(23)
                __B_u_G__["SoundEmitter"]:PlaySound("meta/sharkboi/hit", nil, 0.6)
                __B_u_G__["sg"]["statemem"]["hits"] = b_u__g_
            end
        end,
        ["timeline"] = {
            FrameEvent(
                22,
                function(bu_g__)
                    if bu_g__["sg"]["statemem"]["hits"] == nil then
                        bu_g__["SoundEmitter"]:PlaySound "meta/sharkboi/hit"
                    end
                end
            )
        },
        ["events"] = {
            EventHandler(
                "animover",
                function(BuG__)
                    if BuG__["AnimState"]:AnimDone() then
                        BuG__["sg"]:GoToState "torpedo_pst"
                    end
                end
            )
        }
    },
    State {
        ["name"] = "torpedo_pst",
        ["tags"] = {"busy", "notalksound"},
        ["onenter"] = function(_b_U_g_, b_u_G__)
            _b_U_g_["components"]["locomotor"]:Stop()
            _b_U_g_["AnimState"]:PlayAnimation "torpedo_pst"
            if b_u_G__ then
                _b_U_g_["AnimState"]:SetFrame(19)
                _b_U_g_["SoundEmitter"]:PlaySound(__Bu_G(_b_U_g_) .. "talk", nil, 0.4)
                _b_U_g_["SoundEmitter"]:PlaySound("meta/sharkboi/hit", nil, 0.6)
            else
                _b_U_g_["sg"]:AddStateTag "dizzy"
                _b_U_g_["sg"]:AddStateTag "caninterrupt"
            end
            _b_U_g_["sg"]["statemem"]["hits"] = 3
        end,
        ["timeline"] = {
            FrameEvent(
                34 - 19,
                function(__B_u__G_)
                    if not __B_u__G_["sg"]:HasStateTag "dizzy" then
                        __B_u__G_["sg"]:AddStateTag "caninterrupt"
                    end
                end
            ),
            FrameEvent(
                16,
                function(_B__Ug__)
                    if _B__Ug__["sg"]:HasStateTag "dizzy" then
                        _B__Ug__["SoundEmitter"]:PlaySound(__Bu_G(_B__Ug__) .. "talk", nil, 0.4)
                        _B__Ug__["SoundEmitter"]:PlaySound("meta/sharkboi/hit", nil, 0.6)
                    end
                end
            ),
            FrameEvent(
                19,
                function(__BU_g__)
                    if __BU_g__["sg"]:HasStateTag "dizzy" then
                        __BU_g__["sg"]:RemoveStateTag "dizzy"
                        __BU_g__["sg"]:RemoveStateTag "caninterrupt"
                    end
                end
            ),
            FrameEvent(
                34,
                function(_B__u__G__)
                    _B__u__G__["sg"]:AddStateTag "caninterrupt"
                end
            )
        },
        ["events"] = {
            EventHandler(
                "animover",
                function(b__u_G__)
                    if b__u_G__["AnimState"]:AnimDone() then
                        b__u_G__["sg"]:GoToState "idle"
                    end
                end
            )
        }
    },
    State {
        ["name"] = "standing_dive_jump_pre",
        ["tags"] = {"busy", "candefeat", "fastdig"},
        ["onenter"] = function(__BuG_, Bu__g)
            __BuG_["components"]["locomotor"]:Stop()
            __BuG_["AnimState"]:PlayAnimation "icedive_standing_jump_pre"
            if Bu__g and Bu__g:IsValid() then
                __BuG_["sg"]["statemem"]["target"] = Bu__g
                __BuG_["sg"]["statemem"]["targetpos"] = Bu__g:GetPosition()
                __BuG_:ForceFacePoint(__BuG_["sg"]["statemem"]["targetpos"])
            end
        end,
        ["onupdate"] = function(_b_u__g__)
            local __B_U_G_ = _b_u__g__["sg"]["statemem"]["target"]
            if __B_U_G_ then
                if __B_U_G_:IsValid() then
                    local b_U__G__ = _b_u__g__["sg"]["statemem"]["targetpos"]
                    b_U__G__["x"], b_U__G__["y"], b_U__G__["z"] = __B_U_G_["Transform"]:GetWorldPosition()
                    if __B_U_G_["Physics"] then
                        local _bU__g, __b_Ug__, B__U_G__ = __B_U_G_["Physics"]:GetVelocity()
                        b_U__G__["x"] = b_U__G__["x"] + _bU__g * 0.3
                        b_U__G__["z"] = b_U__G__["z"] + B__U_G__ * 0.3
                    end
                    local _bU_g_ = _b_u__g__["Transform"]:GetRotation()
                    local _Bu_G = _b_u__g__:GetAngleToPoint(b_U__G__)
                    if DiffAngle(_bU_g_, _Bu_G) < 45 then
                        _b_u__g__["Transform"]:SetRotation(_Bu_G)
                    else
                        _b_u__g__["sg"]["statemem"]["target"] = nil
                    end
                else
                    _b_u__g__["sg"]["statemem"]["target"] = nil
                end
            end
        end,
        ["timeline"] = {FrameEvent(10, PlayFootstep)},
        ["events"] = {
            EventHandler(
                "animover",
                function(Bu_g__)
                    if Bu_g__["AnimState"]:AnimDone() then
                        Bu_g__["sg"]:GoToState("dive_jump", Bu_g__["sg"]["statemem"]["targetpos"])
                    end
                end
            )
        }
    },
    State {
        ["name"] = "dive_jump_delay",
        ["tags"] = {"fin", "busy", "nosleep", "noattack", "invisible", "temp_invincible", "jumping"},
        ["onenter"] = function(__B_u__G__, __B__U__G)
            __B_u__G__["components"]["locomotor"]:Stop()
            __B_u__G__:Hide()
            if __B__U__G and __B__U__G:IsValid() then
                __B_u__G__["sg"]["statemem"]["target"] = __B__U__G
                __B_u__G__["sg"]["statemem"]["targetpos"] = __B__U__G:GetPosition()
            end
            if __B_u__G__["sg"]["lasttags"] and __B_u__G__["sg"]["lasttags"]["idle"] then
                __B_u__G__["Physics"]:SetMotorVelOverride(6 / 4, 0, 0)
            else
                __B_u__G__["Physics"]:SetMotorVelOverride(6 / 2, 0, 0)
            end
            __B_u__G__["sg"]:SetTimeout(0.5)
        end,
        ["onupdate"] = function(_BU__g__)
            local _b_u_g__ = _BU__g__["sg"]["statemem"]["target"]
            local _bu__G__ = _BU__g__["sg"]["statemem"]["targetpos"]
            if _b_u_g__ then
                if _b_u_g__:IsValid() then
                    _bu__G__["x"], _bu__G__["y"], _bu__G__["z"] = _b_u_g__["Transform"]:GetWorldPosition()
                    if _b_u_g__["Physics"] then
                        local _b_u__G__, _b__u_g, _b_u_G = _b_u_g__["Physics"]:GetVelocity()
                        _bu__G__["x"] = _bu__G__["x"] + _b_u__G__ * 0.3
                        _bu__G__["z"] = _bu__G__["z"] + _b_u_G * 0.3
                    end
                    local B_U__g_ = _BU__g__["Transform"]:GetRotation()
                    local _B__U_G = _BU__g__:GetAngleToPoint(_bu__G__)
                    if DiffAngle(B_U__g_, _B__U_G) < 45 then
                        _BU__g__["Transform"]:SetRotation(_B__U_G)
                    else
                        _BU__g__["sg"]["statemem"]["target"] = nil
                    end
                else
                    _BU__g__["sg"]["statemem"]["target"] = nil
                end
            end
        end,
        ["ontimeout"] = function(__bUG_)
            __bUG_["sg"]["statemem"]["diving"] = (283 - 35 - 195 == 53)
            __bUG_["sg"]:GoToState(
                "dive_jump_pre",
                {["target"] = __bUG_["sg"]["statemem"]["target"], ["targetpos"] = __bUG_["sg"]["statemem"]["targetpos"]}
            )
        end,
        ["onexit"] = function(bU__G_)
            bU__G_["Physics"]:ClearMotorVelOverride()
            bU__G_["Physics"]:Stop()
            bU__G_:Show()
        end
    },
    State {
        ["name"] = "dive_jump_pre",
        ["tags"] = {"busy", "nosleep", "noattack", "invisible", "temp_invincible"},
        ["onenter"] = function(_bU__G, __bU__G)
            _bU__G["components"]["locomotor"]:Stop()
            _bU__G["AnimState"]:PlayAnimation "icedive_jump_pre"
            _bU__G["DynamicShadow"]:Enable((458 + 303 - 237 == 532))
            if __bU__G then
                if EntityScript["is_instance"](__bU__G) then
                    if __bU__G:IsValid() then
                        _bU__G["sg"]["statemem"]["target"] = __bU__G
                        _bU__G["sg"]["statemem"]["targetpos"] = __bU__G:GetPosition()
                        _bU__G:ForceFacePoint(_bU__G["sg"]["statemem"]["targetpos"])
                    end
                else
                    _bU__G["sg"]["statemem"]["target"] = __bU__G["target"]
                    _bU__G["sg"]["statemem"]["targetpos"] = __bU__G["targetpos"]
                end
            end
        end,
        ["onupdate"] = function(bU__g_)
            if bU__g_["sg"]["statemem"]["targets"] then
                local b__Ug__ = bU__g_["sg"]["statemem"]["targets"]
                __b_U__g(bU__g_, 0, 2, nil, 1, nil, b__Ug__)
                if b__Ug__ ~= bU__g_["sg"]["statemem"]["targets"] then
                    return
                end
            end
            local _B__UG = bU__g_["sg"]["statemem"]["target"]
            if _B__UG then
                if _B__UG:IsValid() then
                    local __bU_g = bU__g_["sg"]["statemem"]["targetpos"]
                    __bU_g["x"], __bU_g["y"], __bU_g["z"] = _B__UG["Transform"]:GetWorldPosition()
                    if _B__UG["Physics"] then
                        local _bU__G_, Bu__g__, __buG__ = _B__UG["Physics"]:GetVelocity()
                        __bU_g["x"] = __bU_g["x"] + _bU__G_ * 0.3
                        __bU_g["z"] = __bU_g["z"] + __buG__ * 0.3
                    end
                    local _buG_ = bU__g_["Transform"]:GetRotation()
                    local b__U_g = bU__g_:GetAngleToPoint(__bU_g)
                    if DiffAngle(_buG_, b__U_g) < 45 then
                        bU__g_["Transform"]:SetRotation(b__U_g)
                    else
                        bU__g_["sg"]["statemem"]["target"] = nil
                    end
                else
                    bU__g_["sg"]["statemem"]["target"] = nil
                end
            end
        end,
        ["timeline"] = {
            FrameEvent(
                3,
                function(B__UG_)
                    B__UG_["sg"]:RemoveStateTag "invisible"
                    B__UG_["sg"]:RemoveStateTag "temp_invincible"
                    B__UG_["DynamicShadow"]:Enable((195 + 246 + 81 + 477 - 494 == 505))
                    B__UG_["components"]["combat"]:StartAttack()
                    B__UG_["sg"]["statemem"]["targets"] = {}
                    B__UG_["SoundEmitter"]:PlaySound "meta/sharkboi/popup"
                    _b__U_g_(B__UG_)
                end
            )
        },
        ["events"] = {
            EventHandler(
                "animover",
                function(b__ug)
                    if b__ug["AnimState"]:AnimDone() then
                        b__ug["sg"]["statemem"]["jumping"] = (242 * 50 * 100 + 97 ~= 1210101)
                        b__ug["sg"]:GoToState("dive_jump", b__ug["sg"]["statemem"]["targetpos"])
                    end
                end
            )
        },
        ["onexit"] = function(BUG_)
            BUG_["DynamicShadow"]:Enable((444 - 28 * 13 - 316 - 351 ~= -582))
        end
    },
    State {
        ["name"] = "dive_jump",
        ["tags"] = {"busy", "jumping", "nosleep"},
        ["onenter"] = function(Bug__, __B_U_G)
            Bug__["components"]["locomotor"]:Stop()
            Bug__["AnimState"]:PlayAnimation "icedive_jump"
            Bug__["SoundEmitter"]:PlaySound(__Bu_G(Bug__) .. "attack_big")
            Bug__["components"]["combat"]:StartAttack()
            local _B_U__G__, __b__UG, __bu__G_ = Bug__["Transform"]:GetWorldPosition()
            Bug__["components"]["timer"]:StopTimer "standing_dive_cd"
            if Bug__["sg"]["lasttags"] and Bug__["sg"]["lasttags"]["fastdig"] then
                Bug__["sg"]:AddStateTag "fastdig"
                Bug__["components"]["timer"]:StartTimer("standing_dive_cd", 24 / 2)
            else
                Bug__["components"]["timer"]:StartTimer("standing_dive_cd", 24)
                _bu_G__(Bug__, _B_U__G__, __bu__G_)
            end
            local b__u__G = Bug__["Transform"]:GetRotation() * DEGREES
            local __bU_g__ = math["cos"](b__u__G)
            local B_uG_ = math["sin"](b__u__G)
            local _B_u_G_ = 6
            if __B_U_G then
                local b__Ug_, _b__U_G_ = _B_U__G__, __bu__G_
                local _B_ug = __B_U_G["x"] - b__Ug_
                local __b_u_G__ = __B_U_G["z"] - _b__U_G_
                if _B_ug == 0 and __b_u_G__ == 0 then
                    _B_u_G_ = 2
                else
                    local __B__Ug__ = math["atan2"](-__b_u_G__, _B_ug)
                    local __b_u_G = DiffAngleRad(b__u__G, __B__Ug__)
                    _B_u_G_ = math["sqrt"](_B_ug * _B_ug + __b_u_G__ * __b_u_G__) * math["cos"](__b_u_G)
                    _B_u_G_ = math["clamp"](math["abs"](_B_u_G_), 2, 8)
                end
            end
            local __Bu__G__ = TheWorld["Map"]
            while _B_u_G_ > 1 and
                not __Bu__G__:IsVisualGroundAtPoint(_B_U__G__ + __bU_g__ * _B_u_G_, 0, __bu__G_ - B_uG_ * _B_u_G_) do
                _B_u_G_ = math["max"](1, _B_u_G_ - 0.5)
            end
            local B__u__G__ = _B_u_G_ / Bug__["AnimState"]:GetCurrentAnimationLength()
            Bug__["Physics"]:SetMotorVelOverride(B__u__G__, 0, 0)
        end,
        ["timeline"] = {
            FrameEvent(
                20,
                function(B__u__g__)
                    B__u__g__["sg"]["statemem"]["targets"] = {}
                    __b_ug__(B__u__g__, 0, 2, nil, 1, nil, B__u__g__["sg"]["statemem"]["targets"])
                end
            )
        },
        ["events"] = {
            EventHandler(
                "animover",
                function(Bu_G)
                    if Bu_G["AnimState"]:AnimDone() then
                        Bu_G["sg"]:GoToState("dive_dig_pre", Bu_G["sg"]["statemem"]["targets"])
                    end
                end
            )
        },
        ["onexit"] = function(_Bu__G_)
            _Bu__G_["Physics"]:ClearMotorVelOverride()
            _Bu__G_["Physics"]:Stop()
        end
    },
    State {
        ["name"] = "dive_dig_pre",
        ["tags"] = {"digging", "busy", "caninterrupt", "nosleep"},
        ["onenter"] = function(__BUg, BU__g__)
            __BUg["components"]["locomotor"]:Stop()
            __BUg["AnimState"]:PlayAnimation "icedive_dig_pre"
            __BUg["SoundEmitter"]:PlaySound "meta/sharkboi/divedown"
            if not _BUG:NotIsDead(__BUg) then
                __BUg["sg"]:GoToState "death"
                return
            end
            _b__U_g_(__BUg)
            __b_U__g(__BUg, 0, 2, nil, 1, nil, BU__g__)
            if __BUg["sg"]["mem"]["sleeping"] then
                __BUg["sg"]:GoToState "dive_dig_hit"
            elseif __BUg["sg"]["lasttags"] and __BUg["sg"]["lasttags"]["fastdig"] then
                __BUg["sg"]:AddStateTag "fastdig"
            end
        end,
        ["events"] = {
            EventHandler(
                "animover",
                function(__Bu__G)
                    if __Bu__G["AnimState"]:AnimDone() then
                        __Bu__G["sg"]:GoToState "dive_dig_loop"
                    end
                end
            )
        }
    },
    State {
        ["name"] = "dive_dig_loop",
        ["tags"] = {"digging", "busy", "caninterrupt", "nosleep"},
        ["onenter"] = function(_b__ug_, b_U_g_)
            _b__ug_["components"]["locomotor"]:Stop()
            if b_U_g_ then
                _b__ug_["AnimState"]:PlayAnimation "icedive_dig_loop"
                _b__ug_["sg"]["statemem"]["hits"] = b_U_g_
            elseif _b__ug_["sg"]["lasttags"] and _b__ug_["sg"]["lasttags"]["fastdig"] then
                _b__ug_["AnimState"]:PlayAnimation "icedive_dig_loop"
            else
                _b__ug_["AnimState"]:PlayAnimation("icedive_dig_loop", (124 - 452 - 227 - 94 ~= -642))
                _b__ug_["sg"]:SetTimeout(2 * _b__ug_["AnimState"]:GetCurrentAnimationLength())
            end
            _b__ug_["SoundEmitter"]:PlaySound("meta/sharkboi/feetsies_wiggle_LP", "loop")
        end,
        ["ontimeout"] = function(_B_ug__)
            _B_ug__["sg"]:GoToState "dive_dig_pst"
        end,
        ["events"] = {
            EventHandler(
                "animqueueover",
                function(__b__u__G_)
                    if __b__u__G_["AnimState"]:AnimDone() then
                        __b__u__G_["sg"]:GoToState "dive_dig_pst"
                    end
                end
            )
        },
        ["onexit"] = function(__b__u_g__)
            __b__u_g__["SoundEmitter"]:KillSound "loop"
        end
    },
    State {
        ["name"] = "dive_dig_hit",
        ["tags"] = {"digging", "hit", "busy", "nosleep"},
        ["onenter"] = function(_B_u_g_, B__U__g__)
            _B_u_g_["components"]["locomotor"]:Stop()
            _B_u_g_["AnimState"]:PlayAnimation "icedive_dig_hit"
            _B_u_g_["sg"]["statemem"]["hits"] = (B__U__g__ or 0) + 1
        end,
        ["timeline"] = {
            FrameEvent(
                3,
                function(B_U__G__)
                    if not _BUG:NotIsDead(B_U__G__) then
                        B_U__G__["sg"]:GoToState "death"
                        return
                    end
                    if B_U__G__["sg"]["statemem"]["hits"] >= 3 or B_U__G__["sg"]["mem"]["sleeping"] then
                        B_U__G__["sg"]:GoToState "dive_dig_stun"
                    end
                end
            )
        },
        ["events"] = {
            EventHandler(
                "animover",
                function(B_U_g_)
                    if B_U_g_["AnimState"]:AnimDone() then
                        B_U_g_["sg"]:GoToState("dive_dig_loop", B_U_g_["sg"]["statemem"]["hits"])
                    end
                end
            )
        }
    },
    State {
        ["name"] = "dive_dig_pst",
        ["tags"] = {"digging", "busy", "nosleep"},
        ["onenter"] = function(__BU__g)
            __BU__g["components"]["locomotor"]:Stop()
            __BU__g["AnimState"]:PlayAnimation "icedive_dig_pst"
            __BU__g["sg"]["statemem"]["fx"] = _bu_G__(__BU__g)
            if __BU__g["sg"]["statemem"]["fx"] and __BU__g["sg"]["statemem"]["fx"]["AnimState"] then
                __BU__g["sg"]["statemem"]["fx"]["AnimState"]:Pause()
            end
        end,
        ["timeline"] = {
            FrameEvent(
                2,
                function(__BuG__)
                    __BuG__["SoundEmitter"]:PlaySound "meta/sharkboi/popup"
                end
            ),
            FrameEvent(
                4,
                function(b_uG__)
                    if not _BUG:NotIsDead(b_uG__) then
                        b_uG__["sg"]:GoToState "death"
                        return
                    end
                    b_uG__["sg"]:AddStateTag "noattack"
                    b_uG__["sg"]:AddStateTag "temp_invincible"
                    b_uG__["DynamicShadow"]:Enable((135 + 289 + 353 * 144 * 175 ~= 8896024))
                    __b__U_g__(b_uG__)
                end
            ),
            FrameEvent(
                10,
                function(_b__u_G_)
                    if _b__u_G_["sg"]["statemem"]["fx"] and _b__u_G_["sg"]["statemem"]["fx"]["AnimState"] then
                        _b__u_G_["sg"]["statemem"]["fx"]["AnimState"]:Resume()
                        _b__u_G_["sg"]["statemem"]["fx"] = nil
                    end
                end
            )
        },
        ["events"] = {
            EventHandler(
                "animover",
                function(_b__Ug_)
                    if _b__Ug_["AnimState"]:AnimDone() then
                        _b__Ug_["sg"]["statemem"]["fin"] = (170 + 276 - 404 == 42)
                        _b__Ug_["sg"]:GoToState "fin_idle"
                    end
                end
            )
        },
        ["onexit"] = function(B_uG__)
            if not B_uG__["sg"]["statemem"]["fin"] then
                B_uG__["DynamicShadow"]:Enable((276 - 6 - 74 + 5 + 408 == 609))
            end
            if B_uG__["sg"]["statemem"]["fx"] and B_uG__["sg"]["statemem"]["fx"]["AnimState"] then
                B_uG__["sg"]["statemem"]["fx"]["AnimState"]:Resume()
            end
        end
    },
    State {
        ["name"] = "dive_dig_stun",
        ["tags"] = {"busy", "dizzy", "jumping", "nosleep"},
        ["onenter"] = function(_b__u__G__)
            _b__u__G__["components"]["locomotor"]:Stop()
            _b__u__G__["AnimState"]:PlayAnimation "icedive_stun"
            _b__u__G__["SoundEmitter"]:PlaySound "meta/sharkboi/popup"
            local __B_ug_, __b__Ug, b__U__G_ = _b__u__G__["Transform"]:GetWorldPosition()
            _b__U_g_(_b__u__G__, __B_ug_, b__U__G_)
            _bu_G__(_b__u__G__, __B_ug_, b__U__G_)
            _b__u__G__["Physics"]:SetMotorVelOverride(4, 0, 0)
        end,
        ["timeline"] = {
            FrameEvent(9, PlayFootstep),
            FrameEvent(
                12,
                function(b_UG)
                    b_UG["Physics"]:SetMotorVelOverride(2, 0, 0)
                end
            ),
            FrameEvent(17, PlayFootstep),
            FrameEvent(
                20,
                function(_B__U__G__)
                    _B__U__G__["Physics"]:SetMotorVelOverride(1, 0, 0)
                end
            ),
            FrameEvent(
                21,
                function(b_u_g_)
                    b_u_g_["Physics"]:SetMotorVelOverride(0.5, 0, 0)
                end
            ),
            FrameEvent(
                22,
                function(b__u_g)
                    b__u_g["Physics"]:SetMotorVelOverride(0.25, 0, 0)
                end
            ),
            FrameEvent(
                23,
                function(__bu__G__)
                    __bu__G__["Physics"]:ClearMotorVelOverride()
                    __bu__G__["Physics"]:Stop()
                end
            ),
            FrameEvent(
                29,
                function(_BuG__)
                    PlayFootstep(_BuG__, 0.5)
                end
            ),
            FrameEvent(
                36,
                function(_b__U_G)
                    PlayFootstep(_b__U_G, 0.5)
                end
            ),
            FrameEvent(
                59,
                function(B__U__G__)
                    PlayFootstep(B__U__G__, 0.75)
                end
            ),
            CommonHandlers["OnNoSleepFrameEvent"](
                59,
                function(_B_Ug__)
                    if not _BUG:NotIsDead(_B_Ug__) then
                        _B_Ug__["sg"]:GoToState "death"
                        return
                    end
                    _B_Ug__["sg"]:RemoveStateTag "nosleep"
                    _B_Ug__["sg"]:AddStateTag "caninterrupt"
                end
            )
        },
        ["events"] = {
            EventHandler(
                "animover",
                function(B_U_g__)
                    if B_U_g__["AnimState"]:AnimDone() then
                        B_U_g__["sg"]:GoToState "torpedo_dizzy"
                    end
                end
            )
        },
        ["onexit"] = function(_b__Ug)
            _b__Ug["Physics"]:ClearMotorVelOverride()
            _b__Ug["Physics"]:Stop()
        end
    },
    State {
        ["name"] = "fin_idle",
        ["tags"] = {"fin", "idle", "canrotate", "nosleep", "noattack", "invisible"},
        ["onenter"] = function(_b_Ug__)
            _b_Ug__["components"]["locomotor"]:StopMoving()
            _b_Ug__:Hide()
            _b_Ug__["sg"]:SetTimeout(0.6)
        end,
        ["ontimeout"] = function(_B_U_G)
            _B_U_G["components"]["combat"]:ResetCooldown()
        end,
        ["onexit"] = function(__b__u_G_)
            local bu__G, BuG_, __B__ug = __b__u_G_["Transform"]:GetWorldPosition()
            __b__u_G_:Show()
        end
    },
    State {
        ["name"] = "fin_start",
        ["tags"] = {"fin", "moving", "running", "canrotate", "nosleep", "noattack"},
        ["onenter"] = function(_B_u__G)
            _B_u__G["components"]["locomotor"]:RunForward()
            _B_u__G["AnimState"]:PlayAnimation "fin_pre"
            if not _B_u__G["SoundEmitter"]:PlayingSound "loop" then
                _B_u__G["SoundEmitter"]:PlaySound("meta/sharkboi/movement_thru_ice", "loop")
            end
        end,
        ["timeline"] = {FrameEvent(2, __b__U_g__), FrameEvent(2, __b_u_g), FrameEvent(4, __B_uG__)},
        ["events"] = {
            EventHandler(
                "animover",
                function(_bU_G__)
                    if _bU_G__["AnimState"]:AnimDone() then
                        _bU_G__["sg"]["statemem"]["fin"] = (202 + 229 + 134 == 565)
                        _bU_G__["sg"]:GoToState "fin"
                    end
                end
            )
        },
        ["onexit"] = function(__bug__)
            if not __bug__["sg"]["statemem"]["fin"] then
                __bug__["SoundEmitter"]:KillSound "loop"
            end
        end
    },
    State {
        ["name"] = "fin",
        ["tags"] = {"fin", "moving", "running", "canrotate", "nosleep", "noattack"},
        ["onenter"] = function(_B_Ug)
            _B_Ug["components"]["locomotor"]:RunForward()
            if not _B_Ug["AnimState"]:IsCurrentAnimation "fin_loop" then
                _B_Ug["AnimState"]:PlayAnimation("fin_loop", (248 - 39 + 28 == 237))
            end
            if not _B_Ug["SoundEmitter"]:PlayingSound "loop" then
                _B_Ug["SoundEmitter"]:PlaySound("meta/sharkboi/movement_thru_ice", "loop")
            end
            _B_Ug["sg"]:SetTimeout(_B_Ug["AnimState"]:GetCurrentAnimationLength())
        end,
        ["timeline"] = {
            FrameEvent(3, __b__U_g__),
            FrameEvent(12, __b__U_g__),
            FrameEvent(21, __b__U_g__),
            FrameEvent(0, __b_u_g),
            FrameEvent(4, __b_u_g),
            FrameEvent(9, __b_u_g),
            FrameEvent(13, __b_u_g),
            FrameEvent(18, __b_u_g),
            FrameEvent(22, __b_u_g),
            FrameEvent(0, __B_uG__),
            FrameEvent(3, __B_uG__),
            FrameEvent(6, __B_uG__),
            FrameEvent(9, __B_uG__),
            FrameEvent(12, __B_uG__),
            FrameEvent(15, __B_uG__),
            FrameEvent(18, __B_uG__),
            FrameEvent(21, __B_uG__),
            FrameEvent(24, __B_uG__)
        },
        ["ontimeout"] = function(__Bug__)
            __Bug__["sg"]["statemem"]["fin"] = (214 * 109 * 231 == 5388306)
            __Bug__["sg"]:GoToState "fin"
        end,
        ["onexit"] = function(_Bu__g_)
            if not _Bu__g_["sg"]["statemem"]["fin"] then
                _Bu__g_["SoundEmitter"]:KillSound "loop"
            end
        end
    },
    State {
        ["name"] = "fin_stop",
        ["tags"] = {"fin", "canrotate", "nosleep", "noattack"},
        ["onenter"] = function(__B__UG, bu__G_)
            __B__UG["components"]["locomotor"]:RunForward()
            __B__UG["AnimState"]:PlayAnimation "fin_pst"
            if not __B__UG["SoundEmitter"]:PlayingSound "loop" then
                __B__UG["SoundEmitter"]:PlaySound("meta/sharkboi/movement_thru_ice", "loop")
            end
            if bu__G_ then
                __B__UG["sg"]["statemem"]["nextstateparams"] = bu__G_
                __B__UG["sg"]:AddStateTag "jumping"
            end
            __b_u_g(__B__UG)
        end,
        ["timeline"] = {
            FrameEvent(
                5,
                function(__buG_)
                    __buG_["SoundEmitter"]:KillSound "loop"
                end
            )
        },
        ["events"] = {
            EventHandler(
                "animover",
                function(_b__UG_)
                    if _b__UG_["AnimState"]:AnimDone() then
                        if _b__UG_["sg"]["statemem"]["nextstateparams"] then
                            _b__UG_["sg"]:GoToState(unpack(_b__UG_["sg"]["statemem"]["nextstateparams"]))
                        else
                            _b__UG_["sg"]:GoToState "fin_idle"
                        end
                    end
                end
            )
        },
        ["onexit"] = function(b__u_G_)
            b__u_G_["components"]["locomotor"]:StopMoving()
            b__u_G_["SoundEmitter"]:KillSound "loop"
        end
    }
}
local function _B__u__G(__b__uG, bu_G_)
    __b__uG["sg"]["mem"]["lastfootstep"] = GetTime()
    PlayFootstep(__b__uG, bu_G_)
end
CommonStates["AddWalkStates"](
    Bu__G_,
    {["walktimeline"] = {FrameEvent(2, _B__u__G), FrameEvent(20, _B__u__G)}},
    nil,
    nil,
    nil,
    {["endonenter"] = function(bu_g_)
            local __B__U_G__ = GetTime()
            if (bu_g_["sg"]["mem"]["lastfootstep"] or -math["huge"]) + 0.3 < __B__U_G__ then
                bu_g_["sg"]["mem"]["lastfootstep"] = __B__U_G__
                PlayFootstep(bu_g_, 0.5)
            end
        end}
)
CommonStates["AddRunStates"](
    Bu__G_,
    {
        ["starttimeline"] = {FrameEvent(1, __B__U_g_)},
        ["runtimeline"] = {FrameEvent(2, _B__u__G), FrameEvent(16, _B__u__G)}
    },
    nil,
    nil,
    nil,
    {["endonenter"] = function(_BUg)
            local _B__u__g_ = GetTime()
            if (_BUg["sg"]["mem"]["lastfootstep"] or -math["huge"]) + 0.3 < _B__u__g_ then
                _BUg["sg"]["mem"]["lastfootstep"] = _B__u__g_
                PlayFootstep(_BUg, 0.5)
            end
        end}
)
return StateGraph("hh_sharkboi", Bu__G_, _B_UG, "idle")
