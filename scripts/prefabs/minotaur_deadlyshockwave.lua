local _b_U__g_ = {Asset("ANIM", "anim/explode.zip")}
local _B__ug = {}
local function __B_u_G__(bU_g__, __bU__G_, b_U__g)
    bU_g__["level"] = __bU__G_
    bU_g__["dir"] = b_U__g
end
local function _bu_g_()
    local __b__u_g_ = CreateEntity()
    __b__u_g_["entity"]:AddTransform()
    __b__u_g_["entity"]:AddAnimState()
    __b__u_g_["entity"]:AddSoundEmitter()
    __b__u_g_["entity"]:AddNetwork()
    __b__u_g_["AnimState"]:SetBuild "explode"
    __b__u_g_["AnimState"]:SetBank "explode"
    __b__u_g_["AnimState"]:PlayAnimation "small"
    __b__u_g_["AnimState"]:SetMultColour(0, 0, 0, 1)
    __b__u_g_:AddTag "NOCLICK"
    __b__u_g_:AddTag "FX"
    __b__u_g_:AddTag "notraptrigger"
    __b__u_g_["Transform"]:SetScale(2.1, 2.1, 2.1)
    __b__u_g_["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return __b__u_g_
    end
    __b__u_g_["level"] = TUNING["MINOTAUR_DSW_DEFAULT_LEVEL"]
    __b__u_g_["dir"] = Vector3(1, 0, 0)
    __b__u_g_:AddComponent "combat"
    __b__u_g_["components"]["combat"]:SetDefaultDamage(TUNING["MINOTAU_DAMAGE"])
    __b__u_g_:SetStateGraph "SGminotaur_deadlyshockwave"
    __b__u_g_["SetWaveInfo"] = __B_u_G__
    return __b__u_g_
end
local function b_U_g(__B_U__g, __b__U_g_, b_UG)
    if __b__U_g_["components"]["sanity"] ~= nil then
        __b__U_g_["components"]["sanity"]:DoDelta(-999)
    end
end
local function _B__ug_()
    local __b__U__g = CreateEntity()
    __b__U__g["entity"]:AddTransform()
    __b__U__g["entity"]:AddAnimState()
    __b__U__g["entity"]:AddSoundEmitter()
    __b__U__g["entity"]:AddNetwork()
    __b__U__g["AnimState"]:SetBuild "explode"
    __b__U__g["AnimState"]:SetBank "explode"
    __b__U__g["AnimState"]:PlayAnimation "small"
    __b__U__g["AnimState"]:SetMultColour(0, 0, 0, 1)
    __b__U__g["AnimState"]:SetSortOrder(3)
    __b__U__g:AddTag "NOCLICK"
    __b__U__g:AddTag "FX"
    __b__U__g:AddTag "notraptrigger"
    __b__U__g["Transform"]:SetScale(3, 3, 3)
    __b__U__g["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return __b__U__g
    end
    __b__U__g["level"] = 1
    __b__U__g["dir"] = Vector3(1, 0, 0)
    __b__U__g:AddComponent "combat"
    __b__U__g["components"]["combat"]:SetDefaultDamage(360)
    __b__U__g["components"]["combat"]["onhitotherfn"] = b_U_g
    __b__U__g:SetStateGraph "SGminotaur_deathshockwave"
    __b__U__g["SetWaveInfo"] = __B_u_G__
    return __b__U__g
end
return Prefab("minotaur_deadlyshockwave", _bu_g_, _b_U__g_, _B__ug), Prefab(
    "minotaur_deathshockwave",
    _B__ug_,
    _b_U__g_,
    _B__ug
)
