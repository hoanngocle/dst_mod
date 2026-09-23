local B__u_G = {Asset("ANIM", "anim/lavaarena_hit_sparks_fx.zip")}
local function __b__ug__()
    local __B__u_g_ = CreateEntity()
    __B__u_g_["entity"]:AddTransform()
    __B__u_g_["entity"]:AddAnimState()
    __B__u_g_["entity"]:AddNetwork()
    __B__u_g_:AddTag "FX"
    __B__u_g_["AnimState"]:SetBank "hits_sparks"
    __B__u_g_["AnimState"]:SetBuild "lavaarena_hit_sparks_fx"
    __B__u_g_["AnimState"]:SetBloomEffectHandle "shaders/anim.ksh"
    __B__u_g_["AnimState"]:SetFinalOffset(1)
    __B__u_g_["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return __B__u_g_
    end
    __B__u_g_["SetPosition"] = function(__B__u_g_, _b__U__G__, Bug__)
        local __buG__ =
            (_b__U__G__:GetPosition() - Bug__:GetPosition()):GetNormalized() *
            (Bug__["Physics"] ~= nil and Bug__["Physics"]:GetRadius() or 1)
        __buG__["y"] = __buG__["y"] + 1 + math["random"](-5, 5) / 10
        __B__u_g_["Transform"]:SetPosition((Bug__:GetPosition() + __buG__):Get())
        __B__u_g_["AnimState"]:PlayAnimation "hit_3"
        __B__u_g_["AnimState"]:SetScale(_b__U__G__:GetRotation() > 0 and -.7 or .7, .7)
    end
    __B__u_g_["SetPiercing"] = function(__B__u_g_, _B__u_G__, __b__ug)
        local _bU_g =
            (_B__u_G__:GetPosition() - __b__ug:GetPosition()):GetNormalized() *
            (__b__ug["Physics"] ~= nil and __b__ug["Physics"]:GetRadius() or 1)
        _bU_g["y"] = _bU_g["y"] + 1 + math["random"](-5, 5) / 10
        __B__u_g_["Transform"]:SetPosition((__b__ug:GetPosition() + _bU_g):Get())
        __B__u_g_["AnimState"]:PlayAnimation "hit_3"
        __B__u_g_["AnimState"]:SetOrientation(ANIM_ORIENTATION["OnGround"])
        __B__u_g_["Transform"]:SetRotation(__B__u_g_:GetAngleToPoint(__b__ug:GetPosition():Get()) + 90)
    end
    __B__u_g_["SetThrusting"] = function(__B__u_g_, __B__ug_, __bu__g, __b_U__G_)
        __B__u_g_["Transform"]:SetPosition((__bu__g:GetPosition() + __b_U__G_):Get())
        __B__u_g_["AnimState"]:PlayAnimation "hit_3"
        __B__u_g_["AnimState"]:SetOrientation(ANIM_ORIENTATION["OnGround"])
        __B__u_g_["Transform"]:SetRotation(__B__u_g_:GetAngleToPoint(__bu__g:GetPosition():Get()) + 90)
    end
    __B__u_g_["SetBounce"] = function(__B__u_g_, __b__U__g_)
        __B__u_g_["Transform"]:SetPosition(__b__U__g_:GetPosition():Get())
        __B__u_g_["AnimState"]:PlayAnimation "hit_2"
        __B__u_g_["AnimState"]:Hide "glow"
        __B__u_g_["AnimState"]:SetScale(__b__U__g_:GetRotation() > 0 and 1 or -1, 1)
    end
    __B__u_g_:ListenForEvent("animover", __B__u_g_["Remove"])
    return __B__u_g_
end
return Prefab("wb_magical_weaponsparks", __b__ug__, B__u_G)
