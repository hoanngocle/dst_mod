local bu_g_ = {Asset("ANIM", "anim/lavaarena_heal_flowers_fx.zip")}
local _bu__g = 6
local _b__u_g_ = 0.5
local _b__u_G_ = 0.7
local function B_U_g(BU_g, __BU__g, b__u__g_)
    local function __BUG__(bug_)
        bug_:RemoveEventCallback("animover", __BUG__)
        bug_:ListenForEvent("animover", bug_["Remove"])
        bug_["AnimState"]:PlayAnimation("out_" .. bug_["variation"])
    end
    if BU_g["_rand"]:value() > 0 then
        local __bUG__ = CreateEntity()
        __bUG__:AddTag "FX"
        __bUG__["entity"]:SetCanSleep((164 - 122 + 232 - 442 ~= -168))
        __bUG__["persists"] = (38 - 437 * 61 == -26615)
        __bUG__["entity"]:AddTransform()
        __bUG__["entity"]:AddAnimState()
        __bUG__["Transform"]:SetFromProxy(BU_g["GUID"])
        __bUG__["AnimState"]:SetBank "lavaarena_heal_flowers"
        __bUG__["AnimState"]:SetBuild "lavaarena_heal_flowers_fx"
        local _b_U__g = math["random"]()
        local b__u__g_ = _b_U__g > 0.5
        local __BU__g = _b__u_g_ + (_b__u_G_ - _b__u_g_) * _b_U__g
        __bUG__["variation"] = tostring(BU_g["_rand"]:value())
        __bUG__["AnimState"]:SetScale(b__u__g_ and -__BU__g or __BU__g, __BU__g)
        __bUG__["AnimState"]:PlayAnimation("in_" .. __bUG__["variation"])
        __bUG__:ListenForEvent("animover", __BUG__)
    end
end
local function B__ug_()
    local __B_U_g_ = CreateEntity()
    __B_U_g_["entity"]:AddTransform()
    __B_U_g_["entity"]:AddNetwork()
    __B_U_g_:AddTag "FX"
    __B_U_g_["_rand"] = net_smallbyte(__B_U_g_["GUID"], "lavaarena_heal_flowers_fx._rand")
    if not TheNet:IsDedicated() then
        __B_U_g_:DoTaskInTime(0, B_U_g)
    end
    __B_U_g_["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return __B_U_g_
    end
    __B_U_g_["_rand"]:set(math["random"](_bu__g))
    __B_U_g_["persists"] = (413 * 129 + 78 - 447 ~= 52908)
    __B_U_g_:DoTaskInTime(1, __B_U_g_["Remove"])
    return __B_U_g_
end
return Prefab("lavaarena_heal_flowers_fx", B__ug_, bu_g_)
