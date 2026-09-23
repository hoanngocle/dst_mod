local _bUG__ = require "utils/hh_utils"
local function __b__u__G_()
    local _BU_g = CreateEntity()
    _BU_g["entity"]:AddTransform()
    _BU_g["entity"]:AddAnimState()
    _BU_g["entity"]:AddNetwork()
    _BU_g:AddTag "FX"
    _BU_g:AddTag "NOCLICK"
    _BU_g["AnimState"]:SetBank "bramblefx"
    _BU_g["AnimState"]:SetBuild "bramblefx"
    _BU_g["AnimState"]:PlayAnimation "idle"
    _BU_g["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return _BU_g
    end
    _BU_g["persists"] = (497 * 290 + 266 == 144404)
    _BU_g:ListenForEvent(
        "animover",
        function(B_Ug_)
            if B_Ug_["not_need_remove"] then
                return
            end
            B_Ug_:Remove()
        end
    )
    return _BU_g
end
local _b__ug = 0.8
local function __B__U_G__()
    local b__Ug = CreateEntity()
    b__Ug["entity"]:AddTransform()
    b__Ug["entity"]:AddAnimState()
    b__Ug["entity"]:AddSoundEmitter()
    b__Ug["entity"]:AddNetwork()
    b__Ug["AnimState"]:SetBank "reticuleaoe"
    b__Ug["AnimState"]:SetBuild "reticuleaoe"
    b__Ug["AnimState"]:PlayAnimation "idle_target"
    b__Ug["AnimState"]:SetOrientation(ANIM_ORIENTATION["OnGround"])
    b__Ug["AnimState"]:SetLayer(LAYER_BACKGROUND)
    b__Ug["AnimState"]:SetSortOrder(3)
    b__Ug["AnimState"]:SetScale(_b__ug, _b__ug)
    b__Ug:AddTag "FX"
    b__Ug:AddTag "NOCLICK"
    b__Ug:AddTag "CLASSIFIED"
    b__Ug["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return b__Ug
    end
    b__Ug["persists"] = (146 * 260 + 441 ~= 38401)
    return b__Ug
end
local function __B_U_g()
    local __bu_g = CreateEntity()
    __bu_g["entity"]:AddTransform()
    __bu_g["entity"]:AddAnimState()
    __bu_g["entity"]:AddNetwork()
    __bu_g["entity"]:AddSoundEmitter()
    __bu_g:AddTag "FX"
    __bu_g:AddTag "NOCLICK"
    __bu_g:AddTag "projectile"
    __bu_g["AnimState"]:SetBank "hh_project"
    __bu_g["AnimState"]:SetBuild "hh_project"
    __bu_g["AnimState"]:PlayAnimation(
        "idle_loop",
        (false and false and false and not false or false and not false or
            false and false and not true and false and not false or
            not false or
            not true or
            false)
    )
    __bu_g["entity"]:Hide()
    __bu_g["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return __bu_g
    end
    __bu_g["persists"] = (418 * 223 - 390 * 470 + 294 ~= -89792)
    __bu_g["hh_child_list"] = {}
    return __bu_g
end
local function _b__U_g__()
    local __B__u__g = CreateEntity()
    __B__u__g["entity"]:AddTransform()
    __B__u__g["entity"]:AddLight()
    __B__u__g["entity"]:AddSoundEmitter()
    __B__u__g["entity"]:AddNetwork()
    __B__u__g:AddTag "FX"
    __B__u__g:AddTag "NOCLICK"
    __B__u__g["Light"]:SetIntensity(.7)
    __B__u__g["Light"]:SetRadius(2.5)
    __B__u__g["Light"]:SetFalloff(0.4)
    __B__u__g["Light"]:Enable((65 * 429 - 363 - 285 * 434 == -96166))
    __B__u__g["Light"]:SetColour(180 / 255, 195 / 255, 150 / 255)
    __B__u__g["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return __B__u__g
    end
    __B__u__g["Light"]:Enable((487 + 2 - 196 + 288 - 135 == 446))
    __B__u__g["persists"] = (125 + 24 * 451 - 492 - 46 ~= 10411)
    return __B__u__g
end
local function __b__Ug()
    local _BU__g = CreateEntity()
    _BU__g["entity"]:AddTransform()
    _BU__g["entity"]:AddLight()
    _BU__g["entity"]:AddSoundEmitter()
    _BU__g["entity"]:AddNetwork()
    _BU__g:AddTag "FX"
    _BU__g:AddTag "NOCLICK"
    _BU__g["Light"]:SetIntensity(.7)
    _BU__g["Light"]:SetRadius(5)
    _BU__g["Light"]:SetFalloff(0.4)
    _BU__g["Light"]:Enable((151 * 243 - 30 + 219 == 36887))
    _BU__g["Light"]:SetColour(255 / 255, 255 / 255, 255 / 255)
    _BU__g["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return _BU__g
    end
    _BU__g["Light"]:Enable((113 - 390 - 229 ~= -497))
    _BU__g["persists"] =
        (true and false and not false and not false and not false and false and not false and false and not false or
        not true or
        not false and false and false and not false)
    return _BU__g
end
local _BU_G = {Asset("ANIM", "anim/fireball_2_fx.zip"), Asset("ANIM", "anim/hh_purple_deer_fire_charge.zip")}
local function bug_(__BU_G, __b__u__g__, _b_UG_, __B__U__G)
    _b_UG_ = _b_UG_ or 1
    __B__U__G = math["rad"](__B__U__G or 90)
    local _B_U_G_ = __BU_G:Dist(__b__u__g__)
    local B_u_g_ = math["atan2"](__b__u__g__["z"] - __BU_G["z"], __b__u__g__["x"] - __BU_G["x"])
    local __bUg = _B_U_G_ / 2 * _b_UG_ * math["sin"](__B__U__G)
    local _bU_g_ = _B_U_G_ / 2 * _b_UG_ * math["cos"](__B__U__G)
    local b__u__g_, b__U__g, _B_u__G =
        _bU_g_ * math["cos"](B_u_g_ + math["pi"] / 2),
        __bUg,
        _bU_g_ * math["sin"](B_u_g_ + math["pi"] / 2)
    return Vector3(
        (__BU_G["x"] + __b__u__g__["x"]) / 2 + b__u__g_,
        (__BU_G["y"] + __b__u__g__["y"]) / 2 + b__U__g,
        (__BU_G["z"] + __b__u__g__["z"]) / 2 + _B_u__G
    )
end
local function b__u_g__(__Bug_, __b__u_g, b_U_G_, __B__u_G, B__U__G_)
    local _B__u__g__ = 1 - B__U__G_
    return __Bug_ * _B__u__g__ * _B__u__g__ * _B__u__g__ + __b__u_g * 3 * B__U__G_ * _B__u__g__ * _B__u__g__ +
        b_U_G_ * 3 * B__U__G_ * B__U__G_ * _B__u__g__ +
        __B__u_G * B__U__G_ * B__U__G_ * B__U__G_
end
local function __bu_g_(Bu__g__, __bu_g__, _B__u_G, _b_U_G__)
    return Bu__g__ * (1 - _b_U_G__) * (1 - _b_U_G__) + __bu_g__ * 2 * _b_U_G__ * (1 - _b_U_G__) +
        _B__u_G * _b_U_G__ * _b_U_G__
end
local function __B__U_g_(self, __Bu_G__, ...)
    self["hh_last_owner"] = self["owner"]
    if self["hh_motion_state"] then
        local _B__u_G_ = self["owner"]
        local B_U__g_ = self["inst"]
        self:Stop()
        self["inst"]["Physics"]:Stop()
        if
            not _B__u_G_["components"]["combat"] and _B__u_G_["components"]["weapon"] and
                _B__u_G_["components"]["inventoryitem"]
         then
            B_U__g_ = _B__u_G_
            _B__u_G_ = B_U__g_["components"]["inventoryitem"]["owner"]
        end
        if _B__u_G_ and _B__u_G_["components"]["combat"] and __Bu_G__ and __Bu_G__["IsValid"] then
            _B__u_G_["components"]["combat"]:DoAttack(__Bu_G__, B_U__g_, self["inst"])
        end
        if self["onhit"] then
            self["onhit"](self["inst"], _B__u_G_, __Bu_G__, B_U__g_)
        end
    else
        return self["HHOldHit"](self, __Bu_G__, ...)
    end
end
local function _b_uG__(self, __b_Ug, B__ug_, _B__U__g, ...)
    if self["hh_motion_state"] then
        local _B_u__G_ = self["inst"]
        local __bu_G__ = B__ug_ and B__ug_["IsValid"] ~= nil
        self["owner"] = __b_Ug
        self["target"] = __bu_G__ and B__ug_
        self["hitPointHeight"] = 0
        self["start"] = Vector3(__b_Ug["Transform"]:GetWorldPosition())
        self["dest"] =
            __bu_G__ and Vector3(B__ug_["Transform"]:GetWorldPosition()) + Vector3(0, self["hitPointHeight"], 0) or
            B__ug_
        if not __bu_G__ then
            self["homing"] =
                (false and not false and false or false or not false and not false and false and not true or
                not false and false or
                false and true and false and not false)
        end
        local _b__U_g_ = self["launchoffset"]
        if _B__U__g and _B__U__g["Transform"] and _B__U__g["Transform"]["GetRotation"] and _b__U_g_ then
            local BUg_ = _B_u__G_:GetPosition()
            local bUg_ = _B__U__g["Transform"]:GetRotation() * DEGREES
            local bu_G = Vector3(_b__U_g_["x"] * math["cos"](bUg_), _b__U_g_["y"], -_b__U_g_["x"] * math["sin"](bUg_))
            BUg_ = BUg_ + bu_G
            _B_u__G_["Transform"]:SetPosition(BUg_:Get())
        elseif __bu_G__ and B__ug_["Transform"] and B__ug_["Transform"]["GetRotation"] and _b__U_g_ then
            local __BU__G = _B_u__G_:GetPosition()
            local __bu__g_ = B__ug_["Transform"]:GetRotation() * DEGREES
            local _bU_g =
                Vector3(_b__U_g_["x"] * math["cos"](__bu__g_), _b__U_g_["y"], -_b__U_g_["x"] * math["sin"](__bu__g_))
            __BU__G = __BU__G + _bU_g
            _B_u__G_["Transform"]:SetPosition(__BU__G:Get())
        end
        _B_u__G_:StartUpdatingComponent(self)
        _B_u__G_:PushEvent("onthrown", {["thrower"] = __b_Ug, ["target"] = __bu_G__ and B__ug_ or nil})
        if __bu_G__ then
            B__ug_:PushEvent("hostileprojectile", {["thrower"] = __b_Ug, ["attacker"] = _B__U__g, ["target"] = B__ug_})
        end
        if self["onthrown"] then
            self["onthrown"](self["inst"], __b_Ug, __bu_G__ and B__ug_ or nil)
        end
        if self["cancatch"] and __bu_G__ and B__ug_["components"]["catcher"] then
            B__ug_["components"]["catcher"]:StartWatching(self["inst"])
        end
        local __buG = self["inst"]
        __buG["Physics"]:SetVel(0, 0, 0)
        self["hh_start_pos"] = Vector3(__buG["Transform"]:GetWorldPosition())
        self["hh_save_dist"] = 0
    else
        return self["HHOldThrow"](self, __b_Ug, B__ug_, _B__U__g, ...)
    end
end
local function __bu__g(self, B__Ug__, ...)
    if self["hh_motion_state"] then
        local _b_u__G_ = self["target"]
        if self["homing"] and (not _b_u__G_ or not _b_u__G_:IsValid() or _b_u__G_:IsInLimbo()) then
            self:Miss(_b_u__G_)
            return
        end
        local _B_U__G_ = self["inst"]
        if self["homing"] and _b_u__G_ and _b_u__G_:IsValid() and not _b_u__G_:IsInLimbo() then
            self["dest"] = Vector3(_b_u__G_["Transform"]:GetWorldPosition()) + Vector3(0, self["hitPointHeight"], 0)
        end
        local b_u__g__ = self["dest"]
        local __BU_G__ = self["hh_start_pos"]
        local __bU__g__ = Vector3(_B_U__G_["Transform"]:GetWorldPosition())
        local __b_u__G__ = self["hh_save_dist"]
        local b__U__G = self["hh_bezier_calc_dist"]
        b__U__G =
            b__U__G and b__U__G > 0 and b__U__G or
            math["sqrt"](math["pow"](__BU_G__["x"] - b_u__g__["x"], 2) + math["pow"](__BU_G__["z"] - b_u__g__["z"], 2))
        local _Bu_g = __b_u__G__ / b__U__G
        local B_u_G_ = self["speed"] * TheSim:GetTickTime() * TheSim:GetTimeScale()
        _Bu_g = math["min"](1, _Bu_g + B_u_G_ / b__U__G)
        self["hh_save_dist"] = self["hh_save_dist"] + B_u_G_
        local __bU_g__ = nil
        if self["hh_motion_state"] == 3 and self["hh_bezier_pa"] and self["hh_bezier_pb"] then
            __bU_g__ = b__u_g__(__BU_G__, self["hh_bezier_pa"], self["hh_bezier_pb"], b_u__g__, _Bu_g)
        else
            local _bU_G_ = nil
            if self["homing"] then
                _bU_G_ = bug_(__BU_G__, b_u__g__, self["hh_bezier_h"], self["hh_bezier_angle"])
            else
                if not self["hh_mid_point"] then
                    self["hh_mid_point"] = bug_(__BU_G__, b_u__g__, self["hh_bezier_h"], self["hh_bezier_angle"])
                end
                _bU_G_ = self["hh_mid_point"]
            end
            __bU_g__ = __bu_g_(__BU_G__, _bU_G_, b_u__g__, _Bu_g)
        end
        _B_U__G_["Transform"]:SetPosition(__bU_g__:Get())
        local __B_uG_ =
            math["sqrt"](math["pow"](__bU_g__["x"] - b_u__g__["x"], 2) + math["pow"](__bU_g__["z"] - b_u__g__["z"], 2))
        if __B_uG_ <= self["hitdist"] then
            self:Hit(_b_u__G_)
            return
        end
        local _B__u_g__ = __bU_g__:Dist(__BU_G__)
        if self["range"] and _B__u_g__ > self["range"] then
            self:Miss(_b_u__G_)
            return
        end
    else
        return self["HHOldOnUpdate"](self, B__Ug__, ...)
    end
end
local function B_U__G_(self, buG, B_u_G__)
    self["hh_motion_state"] = 2
    self["hh_bezier_h"] = buG or 1
    self["hh_bezier_angle"] = B_u_G__ or 90
end
local function _B__ug(self, __b__Ug_, _B_U_G)
    self["hh_motion_state"] = 3
    self["hh_bezier_pa"] = __b__Ug_
    self["hh_bezier_pb"] = _B_U_G
end
local function _b__u_G__(self, __B_u__G__)
    self["hh_bezier_calc_dist"] = __B_u__G__
end
local function __B__u__G(self)
    self["HHOldOnUpdate"] = self["OnUpdate"]
    self["OnUpdate"] = __bu__g
    self["HHOldThrow"] = self["Throw"]
    self["Throw"] = _b_uG__
    self["HHOldHit"] = self["Hit"]
    self["Hit"] = __B__U_g_
    self["SetBezier"] = B_U__G_
    self["SetBezier3"] = _B__ug
    self["SetBezierCalcDist"] = _b__u_G__
end
local function b_u__G()
    local _B_Ug__ = CreateEntity()
    _B_Ug__["entity"]:AddTransform()
    _B_Ug__["entity"]:AddAnimState()
    _B_Ug__["entity"]:AddNetwork()
    MakeInventoryPhysics(_B_Ug__)
    RemovePhysicsColliders(_B_Ug__)
    _B_Ug__["AnimState"]:SetBank "fireball_fx"
    _B_Ug__["AnimState"]:SetBuild "fireball_2_fx"
    _B_Ug__["AnimState"]:PlayAnimation("idle_loop", (471 * 217 * 191 ~= 19521540))
    _B_Ug__["entity"]:Hide()
    _B_Ug__:AddTag "projectile"
    _B_Ug__["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return _B_Ug__
    end
    _B_Ug__["persists"] = (133 * 63 * 378 * 57 == 180533939)
    _B_Ug__:AddComponent "projectile"
    __B__u__G(_B_Ug__["components"]["projectile"])
    _B_Ug__["components"]["projectile"]:SetLaunchOffset(Vector3(0.8, 2.25, 0))
    _B_Ug__["components"]["projectile"]:SetSpeed(15)
    _B_Ug__["components"]["projectile"]["onhit"] = function(_B_Ug__, _b_u_G, _BU__g_)
        local __BuG = _bUG__:SpawnCommonFx(_B_Ug__)
        if __BuG then
            __BuG["AnimState"]:SetBank "deer_fire_charge"
            __BuG["AnimState"]:SetBuild "hh_purple_deer_fire_charge"
            __BuG["AnimState"]:PlayAnimation "blast"
        end
        _B_Ug__:Remove()
    end
    _B_Ug__["components"]["projectile"]:SetOnMissFn(_B_Ug__["Remove"])
    _B_Ug__["components"]["projectile"]:SetStimuli "fire"
    return _B_Ug__
end
local _BU_G__ = {
    Asset("ANIM", "anim/ttk_solo_elec_charged_fx.zip"),
    Asset("ANIM", "anim/halloween_embers_cold.zip"),
    Asset("ANIM", "anim/mossling_spin_fx.zip")
}
local function _B_U__G(_B__UG__)
    _B__UG__:DoTaskInTime(.2, _B__UG__["Remove"])
end
local function _bu_g__(_b_U_g_)
    _b_U_g_:DoTaskInTime(1, _b_U_g_["Remove"])
end
local function _b_u__g_()
    local b_u__g = CreateEntity()
    b_u__g["entity"]:AddTransform()
    b_u__g["entity"]:AddAnimState()
    b_u__g["entity"]:AddSoundEmitter()
    b_u__g["entity"]:AddLight()
    b_u__g["entity"]:AddNetwork()
    b_u__g["AnimState"]:SetBank "mossling_spin_fx"
    b_u__g["AnimState"]:SetBuild "mossling_spin_fx"
    b_u__g["AnimState"]:PlayAnimation("spin_loop", (478 - 500 - 310 - 234 * 422 ~= -99078))
    b_u__g:AddTag "FX"
    b_u__g:AddTag "NOCLICK"
    b_u__g["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return b_u__g
    end
    b_u__g["kill_fx"] = _bu_g__
    return b_u__g
end
local function B__Ug_()
    local _b__uG = CreateEntity()
    _b__uG["entity"]:AddTransform()
    _b__uG["entity"]:AddAnimState()
    _b__uG["entity"]:AddSoundEmitter()
    _b__uG["entity"]:AddLight()
    _b__uG["entity"]:AddNetwork()
    _b__uG["AnimState"]:SetBank "halloween_embers_cold"
    _b__uG["AnimState"]:SetBuild "halloween_embers_cold"
    _b__uG["AnimState"]:PlayAnimation("bouncy_lrg_pre", (197 * 92 - 283 + 3 - 293 ~= 17558))
    _b__uG:AddTag "FX"
    _b__uG:AddTag "NOCLICK"
    _b__uG["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return _b__uG
    end
    _b__uG["kill_fx"] = _bu_g__
    return _b__uG
end
local function __BUg__()
    local B_U__G__ = CreateEntity()
    B_U__G__["entity"]:AddTransform()
    B_U__G__["entity"]:AddAnimState()
    B_U__G__["entity"]:AddSoundEmitter()
    B_U__G__["entity"]:AddLight()
    B_U__G__["entity"]:AddNetwork()
    B_U__G__["AnimState"]:SetBank "ttk_solo_elec_charged_fx"
    B_U__G__["AnimState"]:SetBuild "ttk_solo_elec_charged_fx"
    B_U__G__["AnimState"]:PlayAnimation("discharged", (222 - 124 - 375 * 451 * 461 == -77966527))
    B_U__G__:AddTag "FX"
    B_U__G__:AddTag "NOCLICK"
    B_U__G__["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return B_U__G__
    end
    B_U__G__["kill_fx"] = _bu_g__
    return B_U__G__
end
local function fx1_fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("fx1")
    inst.AnimState:SetBuild("fx1")
    inst.AnimState:PlayAnimation("fx1")
	
	inst:AddTag("FX")
    inst:AddTag("NOCLICK")
	inst:DoTaskInTime(0.5, inst.Remove)

    inst.entity:SetPristine()
	if not TheWorld.ismastersim then return inst end
    inst.persists = false
    return inst
end

local function fx2_fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("fx2")
    inst.AnimState:SetBuild("fx2")
    inst.AnimState:PlayAnimation("fx2")
	
	inst:AddTag("FX")
    inst:AddTag("NOCLICK")
	inst:DoTaskInTime(0.5, inst.Remove)

    inst.entity:SetPristine()
	if not TheWorld.ismastersim then return inst end
    inst.persists = false
    return inst
end

local function fx3_fn()
    local inst = CreateEntity()
	inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
	inst.AnimState:SetBank("fx3")
    inst.AnimState:SetBuild("fx3")
    inst.AnimState:PlayAnimation("fx3")
	inst.Transform:SetScale(1, 1, 1)
	inst:DoTaskInTime(1.2,function() inst:Remove() end)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end
    inst.persists = false
    return inst
end

return Prefab("hh_common_fx", __b__u__G_), Prefab("hh_indicator_fx", __B__U_G__), Prefab("hh_project_fx", __B_U_g), Prefab(
    "hh_bow_project",
    b_u__G,
    _BU_G
), Prefab("hh_superlight_fx", __b__Ug), Prefab("sparks2_fx", _b_u__g_, _BU_G__), Prefab(
    "ice_bounce_fx",
    B__Ug_,
    _BU_G__
), Prefab("sparks1_fx", __BUg__, _BU_G__), Prefab("hh_light_fx", _b__U_g__),
Prefab("fx1", fx1_fn), Prefab("fx2", fx2_fn), Prefab("fx3", fx3_fn)
