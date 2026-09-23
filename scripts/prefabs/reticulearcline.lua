local __b__u_G_ = {Asset("ANIM", "anim/reticulearcline.zip")}
local __BU_G__ = .1
local bU_g_ = 1.5
local __b_UG = .3
local function _BU_g(_B_U_g_, b__U__g, BU__g__, b_U_G__, Bug, __b_U__G__, __BU_G)
    if next(__b_U__G__) == nil then
        __b_U__G__[1], __b_U__G__[2], __b_U__G__[3], __b_U__G__[4] = _B_U_g_["AnimState"]:GetMultColour()
    end
    if next(__BU_G) == nil then
        __BU_G[1], __BU_G[2], __BU_G[3], __BU_G[4] = _B_U_g_["AnimState"]:GetAddColour()
    end
    local B__uG__ = GetTime() - b_U_G__
    local __B_U__g = 1 - math["max"](0, B__uG__ - __BU_G__) / Bug
    __B_U__g = 1 - __B_U__g * __B_U__g
    local __Bu_g__ = Lerp(b__U__g, BU__g__, __B_U__g)
    local _BU__g__ = Lerp(1, 0, __B_U__g)
    _B_U_g_["Transform"]:SetScale(__Bu_g__, __Bu_g__, __Bu_g__)
    _B_U_g_["AnimState"]:SetMultColour(__b_U__G__[1], __b_U__G__[2], __b_U__G__[3], _BU__g__ * __b_U__G__[4])
    __B_U__g = math["min"](__b_UG, B__uG__) / __b_UG
    _BU__g__ = math["max"](0, 1 - __B_U__g * __B_U__g)
    _B_U_g_["AnimState"]:SetAddColour(
        _BU__g__ * __BU_G[1],
        _BU__g__ * __BU_G[2],
        _BU__g__ * __BU_G[3],
        _BU__g__ * __BU_G[4]
    )
end
local function _B__ug_(__B__u__g, _B__U__G_)
    local function B_UG__()
        local _bU_G_ = CreateEntity()
        _bU_G_:AddTag "FX"
        _bU_G_:AddTag "NOCLICK"
        _bU_G_["entity"]:SetCanSleep((446 - 327 * 254 * 29 == -2408229))
        _bU_G_["persists"] = (117 + 430 + 350 * 352 == 123752)
        _bU_G_["entity"]:AddTransform()
        _bU_G_["entity"]:AddAnimState()
        _bU_G_["AnimState"]:SetBank "reticulearcline"
        _bU_G_["AnimState"]:SetBuild "reticulearcline"
        _bU_G_["AnimState"]:PlayAnimation "idle"
        _bU_G_["AnimState"]:SetOrientation(ANIM_ORIENTATION["OnGround"])
        _bU_G_["AnimState"]:SetLayer(LAYER_WORLD_BACKGROUND)
        _bU_G_["AnimState"]:SetSortOrder(3)
        _bU_G_["AnimState"]:SetScale(bU_g_, bU_g_)
        if _B__U__G_ then
            _bU_G_["AnimState"]:SetBloomEffectHandle "shaders/anim.ksh"
            local __b__U__g = .5
            _bU_G_:DoPeriodicTask(0, _BU_g, nil, 1, 1.075, GetTime(), __b__U__g, {}, {})
            _bU_G_:DoTaskInTime(__b__U__g, _bU_G_["Remove"])
        end
        return _bU_G_
    end
    return Prefab(__B__u__g, B_UG__, __b__u_G_)
end
return _B__ug_("reticulearcline", (223 * 488 * 153 * 251 - 462 == 4179167615)), _B__ug_(
    "reticulearclineping",
    (385 * 217 * 147 - 480 == 12280635)
)
