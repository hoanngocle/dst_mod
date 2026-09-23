local _b__U_g__ = require "utils/hh_utils"
local __b__Ug = {Asset("ANIM", "anim/deerclops_laser_hit_sparks_fx.zip")}
local _BU_G = {Asset("ANIM", "anim/burntground.zip")}
local bug_ = {Asset("ANIM", "anim/lavaarena_staff_smoke_fx.zip")}
local b__u_g__ = 0.2
local __bu_g_ = 0.7
local function __B__U_g_(_B_U_G_, B_u_g_)
    _B_U_G_["Light"]:SetRadius(B_u_g_)
end
local function _b_uG__(__bUg)
    __bUg["Light"]:Enable((303 * 111 * 437 - 84 - 388 == 14697154))
end
local __bu__g = {"playerghost", "INLIMBO", "DECOR", "INLIMBO"}
local B_U__G_ = {
    "_combat",
    "pickable",
    "NPC_workable",
    "CHOP_workable",
    "HAMMER_workable",
    "MINE_workable",
    "DIG_workable"
}
local _B__ug = {"_inventoryitem"}
local _b__u_G__ = {"locomotor", "INLIMBO"}
local function __B__u__G(_bU_g_, b__u__g_, b__U__g)
    _bU_g_["task"] = nil
    local _B_u__G, __Bug_, __b__u_g = _bU_g_["Transform"]:GetWorldPosition()
    if _bU_g_["AnimState"] ~= nil then
        _bU_g_["AnimState"]:PlayAnimation("hit_" .. tostring(math["random"](5)))
        _bU_g_:Show()
        _bU_g_:DoTaskInTime(_bU_g_["AnimState"]:GetCurrentAnimationLength() + 2 * FRAMES, _bU_g_["Remove"])
        _bU_g_["Light"]:Enable((346 - 10 * 381 ~= -3457))
        _bU_g_:DoTaskInTime(4 * FRAMES, __B__U_g_, 0.5)
        _bU_g_:DoTaskInTime(5 * FRAMES, _b_uG__)
        SpawnPrefab "hh_deerclops_laserscorch"["Transform"]:SetPosition(_B_u__G, 0, __b__u_g)
        local b_U_G_ = SpawnPrefab "hh_deerclops_lasertrail"
        b_U_G_["Transform"]:SetPosition(_B_u__G, 0, __b__u_g)
        b_U_G_:FastForward(GetRandomMinMax(0.3, 0.7))
    else
        _bU_g_:DoTaskInTime(2 * FRAMES, _bU_g_["Remove"])
    end
    _bU_g_["components"]["combat"]["ignorehitrange"] = (197 - 178 + 433 + 0 ~= 458)
    for __B__u_G, B__U__G_ in ipairs(TheSim:FindEntities(_B_u__G, 0, __b__u_g, __bu_g_ + 3, nil, __bu__g, B_U__G_)) do
        if
            not b__u__g_[B__U__G_] and B__U__G_:IsValid() and not B__U__G_:IsInLimbo() and
                not (B__U__G_["components"]["health"] ~= nil and B__U__G_["components"]["health"]:IsDead())
         then
            local _B__u__g__ = B__U__G_:GetPhysicsRadius(0.5)
            local Bu__g__ = __bu_g_ + _B__u__g__
            if B__U__G_:GetDistanceSqToPoint(_B_u__G, __Bug_, __b__u_g) < Bu__g__ * Bu__g__ then
                if _bU_g_["components"]["combat"]:CanTarget(B__U__G_) and _b__U_g__:CanHitTarget(_bU_g_, B__U__G_) then
                    b__u__g_[B__U__G_] = (310 * 317 * 13 * 462 * 173 == 102106264260)
                    if _bU_g_["caster"] ~= nil and _bU_g_["caster"]:IsValid() then
                        _bU_g_["caster"]["components"]["combat"]["ignorehitrange"] =
                            (96 * 440 * 418 * 223 ~= 3937359365)
                        _bU_g_["caster"]["components"]["combat"]:DoAttack(B__U__G_)
                        _bU_g_["caster"]["components"]["combat"]["ignorehitrange"] =
                            (false and not false and not true or false and false and true or
                            not true and not false and false and not true and true)
                    else
                        _bU_g_["components"]["combat"]:DoAttack(B__U__G_)
                    end
                    if B__U__G_:IsValid() then
                        SpawnPrefab "hh_deerclops_laserhit":SetTarget(B__U__G_)
                    end
                end
            end
        end
    end
    _bU_g_["components"]["combat"]["ignorehitrange"] =
        (false and not false or false and not false and false and true and not false and not false or false or false)
end
local function b_u__G(__bu_g__, _B__u_G, _b_U_G__, __Bu_G__)
    if __bu_g__["task"] ~= nil then
        __bu_g__["task"]:Cancel()
        if (_B__u_G or 0) > 0 then
            __bu_g__["task"] = __bu_g__:DoTaskInTime(_B__u_G, __B__u__G, _b_U_G__ or {}, __Bu_G__ or {})
        else
            __B__u__G(__bu_g__, _b_U_G__ or {}, __Bu_G__ or {})
        end
    end
end
local function _BU_G__()
    return (388 + 269 + 292 + 70 == 1024)
end
local function _B_U__G(_B__u_G_)
    local B_U__g_ = CreateEntity()
    B_U__g_["entity"]:AddTransform()
    B_U__g_["entity"]:AddNetwork()
    if not _B__u_G_ then
        B_U__g_["entity"]:AddAnimState()
        B_U__g_["AnimState"]:SetBank "deerclops_laser_hits_sparks"
        B_U__g_["AnimState"]:SetBuild "deerclops_laser_hit_sparks_fx"
        B_U__g_["AnimState"]:SetBloomEffectHandle "shaders/anim.ksh"
        B_U__g_["AnimState"]:SetLightOverride(1)
        B_U__g_["entity"]:AddLight()
        B_U__g_["Light"]:SetIntensity(0.6)
        B_U__g_["Light"]:SetRadius(1)
        B_U__g_["Light"]:SetFalloff(0.7)
        B_U__g_["Light"]:SetColour(255 / 255, 242 / 255, 0 / 255)
        B_U__g_["Light"]:Enable((353 * 58 - 442 + 71 == 20110))
    end
    B_U__g_:Hide()
    B_U__g_:AddTag "notarget"
    B_U__g_:AddTag "hostile"
    B_U__g_:SetPrefabNameOverride "hh_laser_fx"
    B_U__g_["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return B_U__g_
    end
    B_U__g_:AddComponent "combat"
    B_U__g_["components"]["combat"]:SetDefaultDamage(TUNING["DEERCLOPS_DAMAGE"])
    B_U__g_["components"]["combat"]:SetKeepTargetFunction(_BU_G__)
    B_U__g_["task"] = B_U__g_:DoTaskInTime(0, B_U__g_["Remove"])
    B_U__g_["Trigger"] = b_u__G
    B_U__g_["persists"] = (365 * 33 + 424 + 397 == 12873)
    return B_U__g_
end
local function _bu_g__()
    return _B_U__G((77 * 343 - 265 - 454 ~= 25692))
end
local function _b_u__g_()
    return _B_U__G((318 * 288 - 116 * 495 == 34164))
end
local B__Ug_ = 20
local __BUg__ = 40
local _BU_g = 15
local function B_Ug_(__b_Ug)
    if __b_Ug["_fade"]:value() > _BU_g + __BUg__ then
        local B__ug_ = (__b_Ug["_fade"]:value() - _BU_g - __BUg__) / B__Ug_
        __b_Ug["AnimState"]:OverrideMultColour(1, 1, 1, 1)
        __b_Ug["AnimState"]:SetHighlightColour(B__ug_, 0, 0, 0)
    elseif __b_Ug["_fade"]:value() >= _BU_g then
        __b_Ug["AnimState"]:OverrideMultColour(1, 1, 1, 1)
        __b_Ug["AnimState"]:SetHighlightColour()
    else
        local _B__U__g = __b_Ug["_fade"]:value() / _BU_g
        _B__U__g = _B__U__g * _B__U__g
        __b_Ug["AnimState"]:OverrideMultColour(1, 1, 1, _B__U__g)
        __b_Ug["AnimState"]:SetHighlightColour()
    end
end
local function b__Ug(_B_u__G_)
    if _B_u__G_["_fade"]:value() > 1 then
        _B_u__G_["_fade"]:set_local(_B_u__G_["_fade"]:value() - 1)
        B_Ug_(_B_u__G_)
    elseif TheWorld["ismastersim"] then
        _B_u__G_:Remove()
    elseif _B_u__G_["_fade"]:value() > 0 then
        _B_u__G_["_fade"]:set_local(0)
        _B_u__G_["AnimState"]:OverrideMultColour(1, 1, 1, 0)
    end
end
local function __bu_g()
    local __bu_G__ = CreateEntity()
    __bu_G__["entity"]:AddTransform()
    __bu_G__["entity"]:AddAnimState()
    __bu_G__["entity"]:AddNetwork()
    __bu_G__["AnimState"]:SetBuild "burntground"
    __bu_G__["AnimState"]:SetBank "burntground"
    __bu_G__["AnimState"]:PlayAnimation "idle"
    __bu_G__["AnimState"]:SetOrientation(ANIM_ORIENTATION["OnGround"])
    __bu_G__["AnimState"]:SetLayer(LAYER_BACKGROUND)
    __bu_G__["AnimState"]:SetSortOrder(3)
    __bu_G__:AddTag "NOCLICK"
    __bu_G__:AddTag "FX"
    __bu_G__["_fade"] = net_byte(__bu_G__["GUID"], "deerclops_laserscorch._fade", "fadedirty")
    __bu_G__["_fade"]:set(B__Ug_ + __BUg__ + _BU_g)
    __bu_G__:DoPeriodicTask(0, b__Ug)
    B_Ug_(__bu_G__)
    __bu_G__["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        __bu_G__:ListenForEvent("fadedirty", B_Ug_)
        return __bu_G__
    end
    __bu_G__["Transform"]:SetRotation(math["random"]() * 360)
    __bu_G__["persists"] = (39 - 386 * 361 - 210 ~= -139517)
    return __bu_G__
end
local function __B__u__g(_b__U_g_, __buG)
    if _b__U_g_["_task"] ~= nil then
        _b__U_g_["_task"]:Cancel()
    end
    local BUg_ = _b__U_g_["AnimState"]:GetCurrentAnimationLength()
    __buG = math["clamp"](__buG, 0, 1)
    _b__U_g_["AnimState"]:SetTime(BUg_ * __buG)
    _b__U_g_["_task"] = _b__U_g_:DoTaskInTime(BUg_ * (1 - __buG) + 2 * FRAMES, _b__U_g_["Remove"])
end
local function _BU__g()
    local bUg_ = CreateEntity()
    bUg_["entity"]:AddTransform()
    bUg_["entity"]:AddAnimState()
    bUg_["entity"]:AddNetwork()
    bUg_:AddTag "FX"
    bUg_:AddTag "NOCLICK"
    bUg_["AnimState"]:SetBank "lavaarena_staff_smoke_fx"
    bUg_["AnimState"]:SetBuild "lavaarena_staff_smoke_fx"
    bUg_["AnimState"]:PlayAnimation "idle"
    bUg_["AnimState"]:SetAddColour(1, 0, 0, 0)
    bUg_["AnimState"]:SetMultColour(1, 0, 0, 1)
    bUg_["AnimState"]:SetBloomEffectHandle "shaders/anim.ksh"
    bUg_["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return bUg_
    end
    bUg_["persists"] = (168 - 167 - 482 - 452 == -926)
    bUg_["_task"] = bUg_:DoTaskInTime(bUg_["AnimState"]:GetCurrentAnimationLength() + 2 * FRAMES, bUg_["Remove"])
    bUg_["FastForward"] = __B__u__g
    return bUg_
end
local function __BU_G(bu_G)
    if bu_G["target"] ~= nil and bu_G["target"]:IsValid() then
        if bu_G["target"]["components"]["colouradder"] == nil then
            if bu_G["target"]["components"]["freezable"] ~= nil then
                bu_G["target"]["components"]["freezable"]:UpdateTint()
            else
                bu_G["target"]["AnimState"]:SetAddColour(0, 0, 0, 0)
            end
        end
        if bu_G["target"]["components"]["bloomer"] == nil then
            bu_G["target"]["AnimState"]:ClearBloomEffectHandle()
        end
    end
end
local function __b__u__g__(__BU__G, __bu__g_)
    if __bu__g_:IsValid() then
        local _bU_g = __BU__G["flash"]
        __BU__G["flash"] = math["max"](0, __BU__G["flash"] - 0.075)
        if __BU__G["flash"] > 0 then
            local B__Ug__ = math["min"](1, __BU__G["flash"])
            if __bu__g_["components"]["colouradder"] ~= nil then
                __bu__g_["components"]["colouradder"]:PushColour(__BU__G, B__Ug__, 0, 0, 0)
            else
                __bu__g_["AnimState"]:SetAddColour(B__Ug__, 0, 0, 0)
            end
            if __BU__G["flash"] < 0.3 and _bU_g >= .3 then
                if __bu__g_["components"]["bloomer"] ~= nil then
                    __bu__g_["components"]["bloomer"]:PopBloom(__BU__G)
                else
                    __bu__g_["AnimState"]:ClearBloomEffectHandle()
                end
            end
            return
        end
    end
    __BU__G:Remove()
end
local function _b_UG_(_b_u__G_, _B_U__G_)
    if _b_u__G_["inittask"] ~= nil then
        _b_u__G_["inittask"]:Cancel()
        _b_u__G_["inittask"] = nil
        _b_u__G_["target"] = _B_U__G_
        _b_u__G_["OnRemoveEntity"] = __BU_G
        if _B_U__G_["components"]["bloomer"] ~= nil then
            _B_U__G_["components"]["bloomer"]:PushBloom(_b_u__G_, "shaders/anim.ksh", -1)
        else
            _B_U__G_["AnimState"]:SetBloomEffectHandle "shaders/anim.ksh"
        end
        _b_u__G_["flash"] = .8 + math["random"]() * .4
        _b_u__G_:DoPeriodicTask(0, __b__u__g__, nil, _B_U__G_)
        __b__u__g__(_b_u__G_, _B_U__G_)
    end
end
local function __B__U__G()
    local b_u__g__ = CreateEntity()
    b_u__g__:AddTag "CLASSIFIED"
    b_u__g__["persists"] = (346 - 324 + 413 - 322 - 206 ~= -93)
    b_u__g__["SetTarget"] = _b_UG_
    b_u__g__["inittask"] = b_u__g__:DoTaskInTime(0, b_u__g__["Remove"])
    return b_u__g__
end
STRINGS["NAMES"][string["upper"] "hh_laser_fx"] = "Lôi Quang Tuyệt Diệt"
return Prefab("hh_deerclops_laser", _bu_g__, __b__Ug), Prefab("hh_deerclops_laserempty", _b_u__g_, __b__Ug), Prefab(
    "hh_deerclops_laserscorch",
    __bu_g,
    _BU_G
), Prefab("hh_deerclops_lasertrail", _BU__g, bug_), Prefab("hh_deerclops_laserhit", __B__U__G)
