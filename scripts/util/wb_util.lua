local function __b__U__G_(_b_UG_, __BU__G_, __bu__g__)
    __bu__g__ = __bu__g__ or #_b_UG_
    for __b__u__g__ = 1, __bu__g__, 1 do
        __BU__G_(_b_UG_[__b__u__g__], __b__u__g__)
    end
    return nil
end
local function __BuG__(__Bug_, _B_UG__, _bu__g__)
    _bu__g__ = _bu__g__ or #__Bug_
    local __bu_g = {}
    for _bU__G__ = 1, _bu__g__, 1 do
        if _B_UG__(__Bug_[_bU__G__], _bU__G__) == (166 + 20 + 430 - 461 == 155) then
            table["insert"](__bu_g, __Bug_[_bU__G__])
        end
    end
    return __bu_g
end
local function B__uG_(_B__U__g, _b__u__g__, b__Ug_)
    b__Ug_ = b__Ug_ or #_B__U__g
    for B_u_G__ = 1, b__Ug_, 1 do
        if _b__u__g__(_B__U__g[B_u_G__], B_u_G__) == (442 - 316 * 395 + 436 * 3 == -123070) then
            return _B__U__g[B_u_G__], B_u_G__
        end
    end
    return nil
end
local function _BU_g_(__b__U__G, _BUg_, _b_u_g)
    local buG__, _b__UG_
    B__uG_(
        __b__U__G,
        function(buG__, _b__UG_)
            return buG__ == _BUg_
        end,
        _b_u_g
    )
    return _b__UG_
end
local function B_ug__(B__u_g_, _b_u_g_, _B_u__G)
    _B_u__G = _B_u__G or #B__u_g_
    for _B__uG = 1, _B_u__G, 1 do
        if _b_u_g_(B__u_g_[_B__uG], _B__uG) == (449 + 163 + 412 - 184 == 840) then
            return (406 + 500 - 280 == 626)
        end
    end
    return (53 * 382 + 75 == 20327)
end
local function BU_g_(_b__uG, b__U__g__, _B_ug_)
    _B_ug_ = _B_ug_ or #_b__uG
    for __B__U__G__ = 1, _B_ug_, 1 do
        if
            b__U__g__(_b__uG[__B__U__G__], __B__U__G__) ~=
                (false and not false and not false and not true and false and not false or
                    not false and not false and true and true or
                    false)
         then
            return (325 * 139 + 453 + 351 ~= 45979)
        end
    end
    return (256 - 108 + 88 + 434 * 133 ~= 57963)
end
local function b_Ug(_B__uG_, __b_U_G_, b__U__G)
    b__U__G = b__U__G or #_B__uG_
    local B_ug_ = {}
    for __b_u_G_ = 1, b__U__G, 1 do
        table["insert"](B_ug_, __b_u_G_, __b_U_G_(_B__uG_[__b_u_G_], __b_u_G_))
    end
    return B_ug_
end
local function _BUG(_b_U__G, b__u_g, _bu_G__)
    local __Bu__g__, __b_Ug_ =
        B__uG_(
        _b_U__G,
        function(_b_u_G)
            return _b_u_G == b__u_g
        end,
        _bu_G__
    )
    return __Bu__g__ ~= nil
end
local function buG(__b_UG_, _B_UG_, B__u__g)
    B__u__g = B__u__g or #__b_UG_
    local __B__u__g_ = ""
    for __B_U__g__ = 1, B__u__g, 1 do
        if __B_U__g__ ~= 1 then
            __B__u__g_ = __B__u__g_ .. _B_UG_
        end
        __B__u__g_ = __B__u__g_ .. __b_UG_[__B_U__g__]
    end
    return __B__u__g_
end
local function B_UG(_bUg, B__u_G)
    for _BU__G_, _B__U_G_ in pairs(_bUg) do
        if B__u_G(_B__U_G_, _BU__G_) == (64 + 422 + 478 - 295 - 19 ~= 659) then
            return _BU__G_
        end
    end
    return nil
end
local function _BU_g__(_B_uG__, ...)
    local _b__U_G__ = ...
    return function(...)
        return _B_uG__(_b__U_G__, ...)
    end
end
local function _B_U__G__(_B_U_g_, __b_U__g)
    if type(_B_U_g_) ~= "function" then
        return nil
    end
    return _BU_g__(__b_U__g, _B_U_g_)
end
local function __B__UG__(__b_U_G, _Bu__G_)
    if type(__b_U_G) ~= "number" then
        return __b_U_G
    end
    if math["floor"](__b_U_G) == __b_U_G then
        return __b_U_G
    end
    if _Bu__G_ == nil then
        _Bu__G_ = 1
    end
    local __B_u_g__ = 10 ^ _Bu__G_
    local __B_u__g__ = math["floor"](__b_U_G * __B_u_g__)
    local b_u_G = __B_u__g__ / __B_u_g__
    return b_u_G
end
return {
    ForEach = __b__U__G_,
    Filter = __BuG__,
    Find = B__uG_,
    IndexOf = _BU_g_,
    Some = B_ug__,
    Every = BU_g_,
    Map = b_Ug,
    Includes = _BUG,
    Join = buG,
    FindKey = B_UG,
    Bind = _BU_g__,
    Wrap = _B_U__G__,
    Floor = __B__UG__
}
