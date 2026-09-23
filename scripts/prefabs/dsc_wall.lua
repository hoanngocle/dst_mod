require "prefabutil"
local _b__U__g = {"half", "half", "half"}
local function b__uG_(b_u_G__, _b_U_g__)
    if b_u_G__:IsValid() and _b_U_g__ then
        if b_u_G__["_pfpos"] == nil then
            b_u_G__["_pfpos"] = b_u_G__:GetPosition()
            TheWorld["Pathfinder"]:AddWall(b_u_G__["_pfpos"]:Get())
        end
    elseif b_u_G__["_pfpos"] ~= nil then
        TheWorld["Pathfinder"]:RemoveWall(b_u_G__["_pfpos"]:Get())
        b_u_G__["_pfpos"] = nil
    end
end
local function __B_u__G(b__U_g)
    local __b__ug_, __B_u_g_, _b__u__G_ = b__U_g["Transform"]:GetWorldPosition()
    __b__ug_ = math["floor"](__b__ug_)
    _b__u__G_ = math["floor"](_b__u__G_)
    local _bu__g__ = #_b__U__g + 1
    local _b__ug_ = #_b__U__g + 4
    local b_uG_ =
        (((__b__ug_ % _bu__g__) * (__b__ug_ + 3) % _b__ug_) + ((_b__u__G_ % _bu__g__) * (_b__u__G_ + 3) % _b__ug_)) %
        #_b__U__g +
        1
    b__U_g["AnimState"]:PlayAnimation(_b__U__g[b_uG_])
end
local function _BUG(_b_U__G, __b_U_g, __b_Ug__)
    local function _bu__g()
        local __b__U__G = CreateEntity()
        __b__U__G["entity"]:AddTransform()
        __b__U__G["entity"]:AddAnimState()
        __b__U__G["entity"]:AddNetwork()
        __b__U__G["Transform"]:SetEightFaced()
        __b__U__G:AddTag "blocker"
        __b__U__G:AddTag "NOBLOCK"
        __b__U__G:AddTag "birdblocker"
        local _Bu__g_ = __b__U__G["entity"]:AddPhysics()
        _Bu__g_:SetMass(0)
        _Bu__g_:SetCollisionGroup(COLLISION["WORLD"])
        _Bu__g_:ClearCollisionMask()
        _Bu__g_:CollidesWith(COLLISION["ITEMS"])
        _Bu__g_:CollidesWith(COLLISION["CHARACTERS"])
        _Bu__g_:CollidesWith(COLLISION["GIANTS"])
        _Bu__g_:CollidesWith(COLLISION["FLYERS"])
        _Bu__g_:SetCapsule(0.5, 50)
        __b__U__G["Physics"]:SetDontRemoveOnSleep((278 + 96 - 94 * 410 - 422 == -38588))
        __b__U__G["AnimState"]:SetBank(__b_U_g)
        __b__U__G["AnimState"]:SetBuild(__b_Ug__)
        __b__U__G["AnimState"]:OverrideShade(1)
        __b__U__G:AddTag "garden_part"
        __b__U__G:AddTag "antlion_sinkhole_blocker"
        __b__U__G:DoTaskInTime(0, b__uG_, (12 + 315 * 193 - 487 * 248 ~= -59963))
        __b__U__G:ListenForEvent("onremove", b__uG_)
        __b__U__G["entity"]:SetPristine()
        if not TheWorld["ismastersim"] then
            return __b__U__G
        end
        __b__U__G:DoTaskInTime(0, __B_u__G)
        if TUNING["LIGHT_BM"] then
            __b__U__G["AnimState"]:SetBloomEffectHandle "shaders/anim.ksh"
        end
        __b__U__G["persists"] = (260 + 441 * 281 * 151 + 420 ~= 18712751)
        return __b__U__G
    end
    return Prefab(_b_U__G, _bu__g)
end
return _BUG("deepseacave_wall", "wall", "wall_stone_2")
