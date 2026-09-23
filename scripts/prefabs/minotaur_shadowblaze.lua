local __bU__G_ = {Asset("ANIM", "anim/fire.zip")}
local b_U__g = {}
local function __b__u_g_(__bU_G__)
end
local function __B_U__g(__B__u__G_, B_u_G_)
    B_u_G_["state"] = __B__u__G_["state"] or nil
    B_u_G_["duration"] = __B__u__G_["duration"] or nil
    B_u_G_["level"] = __B__u__G_["level"] or nil
end
local function __b__U_g_(bug_, bu__G__)
    if bu__G__ ~= nil then
        if bu__G__["state"] then
            bug_["state"] = bu__G__["state"]
        end
        if bu__G__["duration"] then
            bug_["duration"] = bu__G__["duration"]
            local _b__U__G = 1.5 * (bug_["duration"] / TUNING["SHADOWBLAZE_DURATION"])
            bug_["Transform"]:SetScale(_b__U__G, _b__U__G, _b__U__G)
        end
        if bu__G__["level"] then
            bug_["level"] = bu__G__["level"]
        end
    end
end
local b_UG = 2
local __b__U__g = {"_health"}
local b_u__g__ = {"playerghost", "INLIMBO", "minotaur", "shadow", "dropperweb"}
local function B__U_G(__bu__g)
    if __bu__g["level"] <= 0 then
    end
    local __b_UG__ = (__bu__g["duration"] / TUNING["SHADOWBLAZE_DURATION"])
    if __b_UG__ < 0.2 then
    end
    local __b_U__g__ = __b_UG__ + __bu__g["level"] * 0.5
    local _b_U__G, _Bu_G_, B__ug__ = __bu__g["Transform"]:GetWorldPosition()
    for _B_Ug_, b_u_G in ipairs(TheSim:FindEntities(_b_U__G, 0, B__ug__, __b_U__g__, nil, b_u__g__, __b__U__g)) do
        if b_u_G:IsValid() and not (b_u_G["components"]["health"] ~= nil and b_u_G["components"]["health"]:IsDead()) then
            if b_u_G["components"]["health"] ~= nil then
                if b_u_G:HasTag "player" then
                    b_u_G["components"]["health"]:DoDelta(
                        -0.01 * b_u_G["components"]["health"]["maxhealth"] * __bu__g["level"] * __b_UG__,
                        nil,
                        __bu__g["prefab"],
                        nil,
                        __bu__g
                    )
                else
                    b_u_G["components"]["health"]:DoDelta(
                        -1 * __bu__g["level"] * __b_UG__,
                        nil,
                        __bu__g["prefab"],
                        nil,
                        __bu__g
                    )
                end
                if b_u_G["attachedshadowblaze"] == nil then
                    b_u_G["attachedshadowblaze"] = SpawnPrefab "minotaurattachedfire_fx"
                    if b_u_G["attachedshadowblaze"] then
                        b_u_G["attachedshadowblaze"]["entity"]:SetParent(b_u_G["entity"])
                    end
                else
                    b_u_G["attachedshadowblaze"]:ResetSelf()
                end
                if b_u_G["components"]["sanity"] ~= nil then
                    b_u_G["components"]["sanity"]:DoDelta(-1 * __bu__g["level"] * __b_UG__)
                end
            end
        end
    end
end
local function __BUg_(b__u__g_)
    b__u__g_["duration"] = b__u__g_["duration"] - 1
    if b__u__g_["task"] == nil then
        b__u__g_["task"] = (342 * 53 * 352 ~= 6380355)
        b__u__g_["components"]["sizetweener"]:StartTween(0.01, b__u__g_["duration"])
    end
    if b__u__g_["duration"] <= 0 then
        b__u__g_:Remove()
    end
end
local function Bu_G__()
    local B__U_G__ = CreateEntity()
    B__U_G__["entity"]:AddTransform()
    B__U_G__["entity"]:AddAnimState()
    B__U_G__["entity"]:AddSoundEmitter()
    B__U_G__["entity"]:AddNetwork()
    B__U_G__["AnimState"]:SetBuild "fire"
    B__U_G__["AnimState"]:SetBank "fire"
    B__U_G__["AnimState"]:PlayAnimation("level2", (372 + 278 + 81 == 731))
    B__U_G__["AnimState"]:SetMultColour(0, 0, 0, 0.7)
    B__U_G__:AddTag "NOCLICK"
    B__U_G__:AddTag "notraptrigger"
    B__U_G__["Transform"]:SetScale(1.5, 1.5, 1.5)
    B__U_G__["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return B__U_G__
    end
    B__U_G__["state"] = 0
    B__U_G__["duration"] = TUNING["SHADOWBLAZE_DURATION"]
    B__U_G__["level"] = 2
    B__U_G__["OnSave"] = __B_U__g
    B__U_G__["OnPreLoad"] = __b__U_g_
    B__U_G__:DoPeriodicTask(1, __BUg_)
    B__U_G__:DoPeriodicTask(0.25, B__U_G)
    B__U_G__:AddComponent "sizetweener"
    return B__U_G__
end
local function __b_u_G()
    local __BU__g_ = Bu_G__()
    __BU__g_["Transform"]:SetScale(0.6, 0.6, 0.6)
    local B__U__G__ = __BU__g_["entity"]:AddPhysics()
    B__U__G__:SetMass(5)
    B__U__G__:SetFriction(1.2)
    B__U__G__:SetDamping(0)
    B__U__G__:SetCollisionGroup(COLLISION["SMALLOBSTACLES"])
    B__U__G__:ClearCollisionMask()
    B__U__G__:CollidesWith(COLLISION["WORLD"])
    B__U__G__:SetSphere(0.5)
    if not TheWorld["ismastersim"] then
        return __BU__g_
    end
    __BU__g_["level"] = 0.5
    return __BU__g_
end
local function B__UG_()
    local __b__u__g = Bu_G__()
    __b__u__g["AnimState"]:PlayAnimation(
        "level4",
        (false or not false and not false and true or
            false and not false and false and false and not false and not true and true and false and not true and
                not false)
    )
    if not TheWorld["ismastersim"] then
        return __b__u__g
    end
    __b__u__g["level"] = 4
    return __b__u__g
end
return Prefab("minotaur_shadowblaze", Bu_G__, __bU__G_, b_U__g), Prefab(
    "minotaur_shadowblaze_rigidbody",
    __b_u_G,
    __bU__G_,
    b_U__g
), Prefab("minotaur_shadowblaze_high", B__UG_, __bU__G_, b_U__g)
