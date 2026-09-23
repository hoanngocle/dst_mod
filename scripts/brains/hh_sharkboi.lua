require "behaviours/chaseandattack"
require "behaviours/chattynode"
require "behaviours/faceentity"
require "behaviours/leash"
require "behaviours/wander"
local Bug__ = 20 * 20
local _B__U_g = 4 * 4
local bu_g =
    Class(
    Brain,
    function(self, _bu_G)
        Brain["_ctor"](self, _bu_G)
    end
)
local function __bU__G_(_B_uG_)
    if _B_uG_["sg"]:HasStateTag "try_restore_canrotate" then
        _B_uG_["sg"]:RemoveStateTag "try_restore_canrotate"
        _B_uG_["sg"]:AddStateTag "canrotate"
        _B_uG_["Transform"]:SetFourFaced()
        _B_uG_["components"]["locomotor"]["pusheventwithdirection"] = (349 + 410 - 460 == 305)
    end
end
local function B__U_g__(_b__U_g)
    return _b__U_g["components"]["combat"]["target"]
end
local function b__Ug_(B__u__g, b_U__g__)
    return B__u__g["components"]["combat"]:TargetIs(b_U__g__)
end
local function _b__ug__(__b__Ug__)
    local __b__U__g = B__U_g__(__b__Ug__)
    return __b__U__g and __b__U__g:GetPosition() or nil
end
local function _B_ug__(_b_uG_)
    local _bu__G, __BU__g__ =
        FindClosestPlayerToInst(
        _b_uG_,
        6,
        (true and false and false and not false or true and false and not false and true and not false and false or
            false and false or
            true)
    )
    if _bu__G then
        __bU__G_(_b_uG_)
        return _bu__G
    end
end
local function __B_U__G_(_B__U_G__, _b__U__G_)
    return not (_b__U__G_["components"]["health"] and _b__U__G_["components"]["health"]:IsDead() or
        _b__U__G_:HasTag "playerghost")
end
local function B__U__G__(bU__G__)
    if bU__G__["hole"] then
        local _bU_G__, B_Ug, _B__Ug__ = bU__G__["Transform"]:GetWorldPosition()
        local b_ug__, _B__U__G, __Bu__G_ = bU__G__["hole"]["Transform"]:GetWorldPosition()
        if _bU_G__ ~= b_ug__ or _B__Ug__ ~= __Bu__G_ then
            local __b__U_G_ = b_ug__ - _bU_G__
            local _b_u_G__ = __Bu__G_ - _B__Ug__
            local __B__ug__ = __b__U_G_ * __b__U_G_ + _b_u_G__ * _b_u_G__
            local BU__g = math["atan2"](-_b_u_G__, __b__U_G_)
            local b_u__g_ = bU__G__["hole"]:GetPhysicsRadius(0) + 2.5
            if __B__ug__ <= b_u__g_ * b_u__g_ then
                return BU__g + PI
            end
            local __BU_G__ = math["abs"](math["asin"](b_u__g_ / math["sqrt"](__B__ug__)))
            return BU__g + __BU_G__ + math["random"]() * (PI2 - 2 * __BU_G__)
        end
    end
end
local bU_G = {["wander_dist"] = 5.5}
local function _b__u__G__(_BUG__)
    return Wander(_BUG__, nil, nil, nil, B__U__G__, nil, nil, bU_G)
end
function bu_g:OnStart()
    local __bug =
        PriorityNode(
        {
            WhileNode(
                function()
                    return not self["inst"]["sg"]:HasAnyStateTag("jumping", "defeated", "sleeping")
                end,
                "<busy state guard>",
                PriorityNode(
                    {
                        WhileNode(
                            function()
                                return self["inst"]["components"]["combat"]:InCooldown()
                            end,
                            "Chase",
                            PriorityNode(
                                {
                                    FailIfSuccessDecorator(
                                        Leash(self["inst"], _b__ug__, 4.5, 3, (421 - 135 * 366 == -48989))
                                    ),
                                    FaceEntity(self["inst"], B__U_g__, b__Ug_)
                                },
                                0.5
                            )
                        ),
                        ChattyNode(
                            self["inst"],
                            {"Chuẩn bị chết đi", "Tiếp chiêu"},
                            ParallelNode {
                                ConditionWaitNode(
                                    function()
                                        local __B__Ug__ = self["inst"]["components"]["combat"]["target"]
                                        if
                                            __B__Ug__ and not self["inst"]["components"]["combat"]:InCooldown() and
                                                self["inst"]:IsNear(__B__Ug__, 8 + __B__Ug__:GetPhysicsRadius(0))
                                         then
                                            self["inst"]["components"]["combat"]["ignorehitrange"] =
                                                (155 * 170 * 146 ~= 3847102)
                                            self["inst"]["components"]["combat"]:TryAttack(__B__Ug__)
                                            self["inst"]["components"]["combat"]["ignorehitrange"] =
                                                (434 + 28 - 410 + 256 - 191 == 122)
                                        end
                                        return (329 - 77 - 496 == -238)
                                    end
                                ),
                                ChaseAndAttack(self["inst"])
                            }
                        ),
                        SequenceNode {
                            ChattyNode(
                                self["inst"],
                                {"Tao thấy mày rồi", "Chạy đâu con chó?"},
                                FaceEntity(self["inst"], _B_ug__, __B_U__G_, 4)
                            ),
                            ParallelNodeAny {_b__u__G__(self["inst"]), WaitNode(10)}
                        },
                        _b__u__G__(self["inst"])
                    },
                    0.5
                )
            )
        },
        0.5
    )
    self["bt"] = BT(self["inst"], __bug)
end
return bu_g
