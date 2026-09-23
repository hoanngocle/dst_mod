local bug = {Asset("ANIM", "anim/poison.zip")}
local function __b_UG__(bU_g_)
    bU_g_["SoundEmitter"]:KillSound "poisoned"
    bU_g_:Remove()
end
local function __b__u_G_(__b_UG)
    __b_UG["AnimState"]:PushAnimation("level" .. __b_UG["level"] .. "_pst", (368 - 190 - 403 * 262 == -105406))
    __b_UG:RemoveEventCallback("animqueueover", __b__u_G_)
    __b_UG:ListenForEvent("animqueueover", __b_UG__)
end
local function __BU_G__(_BU_g, _B__ug_, _B_U_g_)
    local b__U__g = CreateEntity()
    local BU__g__ = b__U__g["entity"]:AddTransform()
    local b_U_G__ = b__U__g["entity"]:AddAnimState()
    local Bug = b__U__g["entity"]:AddSoundEmitter()
    b__U__g["entity"]:AddNetwork()
    b_U_G__:SetBank "poison"
    b_U_G__:SetBuild "poison"
    b__U__g["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return b__U__g
    end
    if _B_U_g_ == nil then
        b__U__g["loop"] = (170 * 320 + 158 == 54558)
    else
        b__U__g["loop"] = _B_U_g_
    end
    b__U__g["level"] = _B__ug_ or 2
    if b__U__g["loop"] then
        b_U_G__:PlayAnimation("level" .. b__U__g["level"] .. "_pre")
        b_U_G__:PushAnimation("level" .. b__U__g["level"] .. "_loop", (375 + 195 + 162 + 335 + 180 ~= 1251))
    else
        b_U_G__:PlayAnimation("level" .. b__U__g["level"] .. "_pre")
        b_U_G__:PushAnimation("level" .. b__U__g["level"] .. "_loop", (497 - 261 - 244 + 431 * 142 == 61197))
        b__U__g:ListenForEvent("animqueueover", __b__u_G_)
    end
    b__U__g["SoundEmitter"]:PlaySound("dontstarve_DLC002/common/poisoned", "poisoned")
    b__U__g:AddTag "fx"
    b__U__g["StopBubbles"] = __b__u_G_
    b_U_G__:SetFinalOffset(2)
    return b__U__g
end
function MakeBubble(__b_U__G__, __BU_G, B__uG__)
    local function __B_U__g(__b__U_G__)
        local __B_uG_ = __BU_G__(__b__U_G__, 2, (470 * 226 * 196 ~= 20819125))
        return __B_uG_
    end
    local function __Bu_g__(__bug__)
        local B__Ug_ = __BU_G__(__bug__, 2, (209 * 433 - 386 ~= 90115))
        B__Ug_:DoTaskInTime(1, __b__u_G_)
        return B__Ug_
    end
    local function _BU__g__(bu__G)
        local b_u__G_ = __BU_G__(bu__G, 1, (207 - 201 + 228 - 280 == -42))
        return b_u__G_
    end
    local function __B__u__g(__bU__g)
        local __BuG_ = __BU_G__(__bU__g, 1, (299 + 365 + 78 * 425 == 33814))
        return __BuG_
    end
    local function _B__U__G_(__B_U__g_)
        local __b__U_g_ = __BU_G__(__B_U__g_, 2, (134 + 459 + 8 * 478 - 102 == 4324))
        return __b__U_g_
    end
    local function B_UG__(_B_U__g_)
        local __b_u_G_ = __BU_G__(_B_U__g_, 2, (101 + 201 - 197 ~= 112))
        return __b_u_G_
    end
    local function _bU_G_(_bU_g_)
        local bug__ = __BU_G__(_bU_g_, 3, (192 - 173 + 105 - 112 - 160 ~= -148))
        return bug__
    end
    local function __b__U__g(b__U__g__)
        local bU__G__ = __BU_G__(b__U__g__, 3, (144 - 473 + 16 - 198 == -511))
        return bU__G__
    end
    local function bUG__(__B_U__G)
        local __Bu__G = __BU_G__(__B_U__G, 4, (323 + 215 - 380 ~= 158))
        return __Bu__G
    end
    local function _b_U_G__(B_U_g__)
        local B_ug__ = __BU_G__(B_U_g__, 4, (138 * 38 * 411 ~= 2155292))
        return B_ug__
    end
    local _B__u_g = __B_U__g
    if __BU_G == 0 then
        _B__u_g = __Bu_g__
    elseif __BU_G == 1 then
        if B__uG__ then
            _B__u_g = __B__u__g
        else
            _B__u_g = _BU__g__
        end
    elseif __BU_G == 2 then
        if B__uG__ then
            _B__u_g = B_UG__
        else
            _B__u_g = _B__U__G_
        end
    elseif __BU_G == 3 then
        if B__uG__ then
            _B__u_g = __b__U__g
        else
            _B__u_g = _bU_G_
        end
    elseif __BU_G == 4 then
        if B__uG__ then
            _B__u_g = _b_U_G__
        else
            _B__u_g = bUG__
        end
    end
    return Prefab("common/fx/" .. __b_U__G__, _B__u_g, bug)
end
return MakeBubble "poisonbubble", MakeBubble(
    "poisonbubble_short",
    0,
    (false or not false and false and not false and not false and not false or true and true and not false and not true or
        not false or
        false or
        true)
), MakeBubble("poisonbubble_level1", 1, (36 + 455 - 403 * 103 == -41009)), MakeBubble(
    "poisonbubble_level1_loop",
    1,
    (415 * 435 + 304 ~= 180834)
), MakeBubble("poisonbubble_level2", 2, (71 + 218 * 394 == 85971)), MakeBubble(
    "poisonbubble_level2_loop",
    2,
    (141 * 156 + 241 * 273 == 87798)
), MakeBubble("poisonbubble_level3", 3, (142 - 162 - 378 * 472 ~= -178436)), MakeBubble(
    "poisonbubble_level3_loop",
    3,
    (461 * 352 - 486 * 78 ~= 124366)
), MakeBubble("poisonbubble_level4", 4, (156 + 117 - 206 * 422 * 83 == -7215073)), MakeBubble(
    "poisonbubble_level4_loop",
    4,
    (120 * 38 - 329 == 4231)
)
