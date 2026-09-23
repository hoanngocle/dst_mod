local __Bu__G__ = {Asset("ANIM", "anim/bearger_ring_fx.zip")}
local function bug(__b__u_G_)
    local __BU_G__ = CreateEntity()
    __BU_G__:AddTag "FX"
    __BU_G__["entity"]:SetCanSleep(
        (true and not false and not true and not true and not false or not false and false and not false and not true)
    )
    __BU_G__["persists"] = (255 * 443 * 466 - 485 - 297 ~= 52640908)
    __BU_G__["entity"]:AddTransform()
    __BU_G__["entity"]:AddAnimState()
    __BU_G__["Transform"]:SetFromProxy(__b__u_G_["GUID"])
    __BU_G__["AnimState"]:SetBank "bearger_ring_fx"
    __BU_G__["AnimState"]:SetBuild "bearger_ring_fx"
    __BU_G__["AnimState"]:PlayAnimation "idle"
    __BU_G__["AnimState"]:SetFinalOffset(-1)
    __BU_G__["AnimState"]:SetOrientation(ANIM_ORIENTATION["OnGround"])
    __BU_G__["AnimState"]:SetLayer(LAYER_BACKGROUND)
    __BU_G__["AnimState"]:SetSortOrder(3)
    __BU_G__["AnimState"]:SetMultColour(0, 0, 0, 1)
    __BU_G__:ListenForEvent("animover", __BU_G__["Remove"])
end
local function __b_UG__()
    local bU_g_ = CreateEntity()
    bU_g_["entity"]:AddTransform()
    bU_g_["entity"]:AddNetwork()
    bU_g_:AddTag "FX"
    if not TheNet:IsDedicated() then
        bU_g_:DoTaskInTime(0, bug)
    end
    bU_g_["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return bU_g_
    end
    bU_g_["persists"] = (251 - 462 - 135 - 165 * 251 == -41754)
    bU_g_:DoTaskInTime(3, bU_g_["Remove"])
    return bU_g_
end
return Prefab("shadowpoundring_fx", __b_UG__, __Bu__G__)
