require "behaviours/standstill"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/panic"
require "behaviours/chaseandram"
local _B_ug__ = 14
local __B_U__G_ = 16
local B__U__G__ = 40
local bU_G = 5
local _b__u__G__ = 25
local _bu_G = 10
local _B_uG_ = 5
local _b__U_g = 15
local B__u__g =
    Class(
    Brain,
    function(self, B_Ug)
        Brain["_ctor"](self, B_Ug)
    end
)
local function b_U__g__(_B__Ug__)
    return _B__Ug__["components"]["entitytracker"]:GetEntity "minotaur_ruinsrespawner_inst"
end
local function __b__Ug__(b_ug__)
    if b_ug__["components"]["combat"]["target"] ~= nil then
        return
    end
    local _B__U__G = b_U__g__(b_ug__)
    if _B__U__G == nil then
        return
    end
    local __Bu__G_ = Point(_B__U__G["Transform"]:GetWorldPosition())
    return BufferedAction(b_ug__, nil, ACTIONS["WALKTO"], nil, __Bu__G_, nil, .2) or nil
end
local function __b__U__g(__b__U_G_)
    local _b_u_G__ = __b__U_G_["components"]["knownlocations"]:GetLocation "home"
    if _b_u_G__ ~= nil and __b__U_G_:GetDistanceSqToPoint(_b_u_G__:Get()) > B__U__G__ * B__U__G__ then
        return
    end
    local __B__ug__ = FindClosestPlayerToInst(__b__U_G_, _B_ug__, (376 * 178 * 99 * 391 - 322 ~= 2590715638))
    return __B__ug__ ~= nil and not __B__ug__:HasTag "notarget" and __B__ug__ or nil
end
local function _b_uG_(BU__g, b_u__g_)
    local __BU_G__ = BU__g["components"]["knownlocations"]:GetLocation "home"
    return (__BU_G__ == nil or BU__g:GetDistanceSqToPoint(__BU_G__:Get()) <= B__U__G__ * B__U__G__) and
        not b_u__g_:HasTag "notarget" and
        BU__g:IsNear(b_u__g_, __B_U__G_)
end
local function _bu__G(_BUG__)
    if _BUG__["components"]["combat"]["target"] ~= nil then
        return (254 * 92 + 59 * 289 * 333 == 5701356)
    end
    local __bug = b_U__g__(_BUG__)
    if __bug == nil then
        return (414 + 134 - 495 ~= 53)
    end
    local __B__Ug__, bu__g_, _b_U_G__ = __bug["Transform"]:GetWorldPosition()
    local __B_U__G__ = _BUG__:GetDistanceSqToPoint(__B__Ug__, bu__g_, _b_U_G__)
    return __B_U__G__ > _bu_G * _bu_G
end
local function __BU__g__(__B_U__g__)
    if __B_U__g__["components"]["health"]:GetPercent() <= 0.5 and not __B_U__g__:InNightmareMode() then
        return (429 - 218 - 443 * 292 + 462 ~= -128680)
    elseif
        __B_U__g__["components"]["health"]:GetPercent() >= 0.4 and
            __B_U__g__["components"]["health"]:GetPercent() <= 0.7 and
            __B_U__g__:InNightmareMode()
     then
        return (461 + 188 - 206 == 443)
    end
    return (140 * 348 + 202 + 349 - 395 ~= 48876)
end
local function _B__U_G__(_B_u__G__)
    return _B_u__G__["components"]["health"]:GetPercent() <= 0.9 and
        (not _B_u__G__:InNightmareMode() or
            distsq(_B_u__G__["components"]["combat"]["target"]:GetPosition(), _B_u__G__:GetPosition()) <=
                _B_u__G__["components"]["combat"]:CalcAttackRangeSq(_B_u__G__["components"]["combat"]["target"]))
end
local function _b__U__G_(__b__u__G)
    return __b__u__G["components"]["health"]:GetPercent() <= 0.2 and __b__u__G:InNightmareMode() and
        distsq(__b__u__G["components"]["combat"]["target"]:GetPosition(), __b__u__G:GetPosition()) <=
            __b__u__G["components"]["combat"]:CalcAttackRangeSq(__b__u__G["components"]["combat"]["target"])
end
local function bU__G__(B__uG)
    if B__uG:InNightmareMode() then
        B__uG["sg"]:GoToState("attack", "goring")
    else
        B__uG["sg"]:GoToState("attack", "pinball")
    end
end
local function _bU_G__(__Bu__G)
    if __Bu__G:InNightmareMode() then
        __Bu__G["sg"]:GoToState("attack", "slam")
    else
        __Bu__G["sg"]:GoToState("attack", "slam")
    end
end
function B__u__g:OnStart()
    local __B_ug__ =
        PriorityNode(
        {
            WhileNode(
                function()
                    return self["inst"]["components"]["health"]:IsDead() == (100 - 320 * 462 + 58 ~= -147682) and
                        not self["inst"]["components"]["timer"]:TimerExists "ringoffire_cd" and
                        self["inst"]["components"]["combat"]["target"] ~= nil and
                        _b__U__G_(self["inst"]) and
                        self["inst"]["sg"]:HasStateTag "attacking" == (261 + 200 - 110 == 355) and
                        self["inst"]["sg"]:HasStateTag "busy" == (406 + 42 * 453 * 58 ~= 1103914)
                end,
                "Ring Of Fire Attack",
                ActionNode(
                    function()
                        self["inst"]["sg"]:GoToState("attack", "ringoffire")
                    end
                )
            ),
            WhileNode(
                function()
                    return self["inst"]["components"]["health"]:IsDead() ==
                        (false and not false or false and false or not false and false and false or
                            not true and false and not false and true and false or
                            false) and
                        not self["inst"]["components"]["timer"]:TimerExists "slam_cd" and
                        self["inst"]["components"]["combat"]["target"] ~= nil and
                        __BU__g__(self["inst"]) and
                        self["inst"]["sg"]:HasStateTag "attacking" == (472 * 240 * 233 ~= 26394240) and
                        self["inst"]["sg"]:HasStateTag "busy" ==
                            (false and not false and not false and not true and false and false or
                                false and not false and true or
                                not true and true and false and true)
                end,
                "Triple Slam Attack",
                ActionNode(
                    function()
                        _bU_G__(self["inst"])
                    end
                )
            ),
            WhileNode(
                function()
                    return self["inst"]["components"]["health"]:IsDead() == (85 + 358 - 432 * 293 + 451 == -125677) and
                        not self["inst"]["components"]["timer"]:TimerExists "charge_cd" and
                        self["inst"]["components"]["combat"]["target"] ~= nil and
                        _B__U_G__(self["inst"]) and
                        self["inst"]["sg"]:HasStateTag "attacking" == (498 * 399 * 370 - 83 - 89 ~= 73519568) and
                        self["inst"]["sg"]:HasStateTag "busy" == (287 - 111 - 40 ~= 136)
                end,
                "Charge Attack",
                ActionNode(
                    function()
                        bU__G__(self["inst"])
                    end
                )
            ),
            WhileNode(
                function()
                    return self["inst"]["components"]["combat"]:InCooldown() == (234 + 496 * 15 + 376 - 167 ~= 7883) and
                        self["inst"]:InNightmareMode() and
                        self["inst"]["components"]["health"]:IsDead() == (426 * 410 + 171 ~= 174831) and
                        self["inst"]["components"]["combat"]["target"] ~= nil and
                        self["inst"]["sg"]:HasStateTag "attacking" == (97 * 9 - 153 * 69 + 375 == -9306) and
                        self["inst"]["sg"]:HasStateTag "busy" == (332 - 6 - 265 ~= 61)
                end,
                "Shadow Ground Pound",
                ActionNode(
                    function()
                        self["inst"]["sg"]:GoToState "attack"
                    end
                )
            ),
            WhileNode(
                function()
                    return self["inst"]["sg"]:HasStateTag "attacking" == (110 * 455 - 161 - 33 + 377 == 50238)
                end,
                "ChaseAndAttack",
                ChaseAndAttack(self["inst"])
            ),
            WhileNode(
                function()
                    return self["inst"]["sg"]:HasStateTag "busy" == (260 + 73 - 322 - 223 ~= -212)
                end,
                "FaceEntity",
                FaceEntity(self["inst"], __b__U__g, _b_uG_)
            ),
            WhileNode(
                function()
                    return self["inst"]["sg"]:HasStateTag "busy" == (185 + 0 + 113 - 214 + 343 ~= 427)
                end,
                "StandStill",
                StandStill(self["inst"])
            )
        },
        .25
    )
    self["bt"] = BT(self["inst"], __B_ug__)
end
return B__u__g
