local BuG__ = {Asset("ANIM", "anim/dsc_fish.zip")}
local _b_u_g_ = {}
local function __BUG(__b_u_g_)
    local _bu__G__, B__U_g, _b__ug_ = __b_u_g_["Transform"]:GetWorldPosition()
    local _bu_g__ = TheSim:FindEntities(_bu__G__, 0, _b__ug_, 60, {"garden_exit"})[1]
    if _bu_g__ ~= nil then
        local __B__u__g = math["random"]() * (1.7 - 1.3) + 1.3
        __b_u_g_["components"]["shanhaimovemotor"]["runspeed"] = __B__u__g
        local _Bu__g = 150
        local __BU__g__, _b__ug__ = _bu__G__, _b__ug_
        local _b__u_g__ = __b_u_g_:GetAngleToPoint(_bu_g__["Transform"]:GetWorldPosition())
        local B_Ug = math["random"](-10, 10)
        if _b__u_g__ > 0 and _b__u_g__ < 180 then
            _b__u_g__ = -60
            __b_u_g_["Transform"]:SetRotation(_b__u_g__)
            __BU__g__ = _bu__G__
            _b__ug__ = _b__ug_ - _Bu__g
        elseif _b__u_g__ > -180 and _b__u_g__ < 0 then
            _b__u_g__ = 180
            __b_u_g_["Transform"]:SetRotation(_b__u_g__)
            __BU__g__ = _bu__G__
            _b__ug__ = _b__ug_ + _Bu__g
        else
            _b__u_g__ = -60
            __b_u_g_["Transform"]:SetRotation(_b__u_g__)
            __BU__g__ = _bu__G__
            _b__ug__ = _b__ug_ + _Bu__g
        end
        __b_u_g_["AnimState"]:PlayAnimation("yu_idle", (203 * 429 + 483 + 423 - 401 == 87592))
        __b_u_g_["components"]["shanhaimovemotor"]:SetTargetPos(Vector3(__BU__g__, 0, _b__ug__))
        __b_u_g_["components"]["shanhaimovemotor"]:EnableMove((472 - 264 + 418 * 57 * 69 ~= 1644212))
        __b_u_g_:StartUpdatingComponent(__b_u_g_["components"]["shanhaimovemotor"])
    else
        print "deepseacave_fish can not get the correct rotation, remove it ========"
        __b_u_g_:Remove()
    end
end
local function _b_u__G()
    local b_U__G__ = CreateEntity()
    b_U__G__["entity"]:AddTransform()
    b_U__G__["entity"]:AddAnimState()
    b_U__G__["entity"]:AddPhysics()
    b_U__G__["entity"]:AddSoundEmitter()
    b_U__G__["entity"]:AddNetwork()
    b_U__G__["AnimState"]:SetBank "dsc_fish"
    b_U__G__["AnimState"]:SetBuild "dsc_fish"
    b_U__G__["AnimState"]:PlayAnimation "idle"
    b_U__G__["AnimState"]:SetDeltaTimeMultiplier(0.3)
    b_U__G__["AnimState"]:SetOrientation(ANIM_ORIENTATION["OnGround"])
    b_U__G__["AnimState"]:SetLayer(LAYER_BACKGROUND)
    b_U__G__["AnimState"]:SetSortOrder(-1)
    b_U__G__["Physics"]:SetMass(10)
    b_U__G__["Physics"]:SetCapsule(1.5, 1)
    b_U__G__["Physics"]:SetFriction(0)
    b_U__G__["Physics"]:SetDamping(5)
    b_U__G__["Physics"]:ClearCollisionMask()
    local __b__u_g__ = math["random"]() * (2.3 - 2.1) + 2.1
    b_U__G__["Transform"]:SetScale(__b__u_g__ + 0.3, __b__u_g__, __b__u_g__)
    b_U__G__:AddTag "deepseacave_fish"
    b_U__G__:AddTag "NOCLICK"
    b_U__G__["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return b_U__G__
    end
    b_U__G__["AnimState"]:SetMultColour(1, 1, 1, 0.5)
    b_U__G__:AddComponent "colourtweener"
    b_U__G__:AddComponent "shanhaimovemotor"
    b_U__G__:DoTaskInTime(
        0,
        function()
            __BUG(b_U__G__)
        end
    )
    b_U__G__:DoTaskInTime(
        5,
        function()
            if b_U__G__:IsValid() then
                b_U__G__["components"]["colourtweener"]:StartTween(
                    {1, 1, 1, 0},
                    3,
                    function()
                        b_U__G__:Remove()
                    end
                )
            end
        end
    )
    return b_U__G__
end
return Prefab("deepseacave_fish", _b_u__G, BuG__, _b_u_g_)
