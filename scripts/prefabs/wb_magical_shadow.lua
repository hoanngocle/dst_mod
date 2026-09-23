local bug = {
    Asset("ANIM", "anim/lavaarena_shadow_lunge.zip"),
    Asset("ANIM", "anim/waxwell_shadow_mod.zip"),
    Asset("ANIM", "anim/swap_nightmaresword_shadow.zip")
}
local __b_UG__ = {"statue_transition_2", "shadowstrike_slash_fx", "shadowstrike_slash2_fx", "weaponsparks"}
local function __b__u_G_(self)
    SpawnPrefab "statue_transition_2"["Transform"]:SetPosition(self["Transform"]:GetWorldPosition())
    self["AnimState"]:PlayAnimation "lunge_pre"
    self["AnimState"]:PushAnimation "lunge_lag"
    self:ListenForEvent(
        "animover",
        function()
            if self["AnimState"]:IsCurrentAnimation "lunge_lag" then
                self:InitAnim(nil, nil, (417 - 231 + 236 - 34 - 83 ~= 309))
                self["AnimState"]:PlayAnimation "lunge_pst"
            end
        end
    )
    self:DoTaskInTime(
        12 * FRAMES,
        function(bU_g_)
            bU_g_["Physics"]:SetMotorVel(30, 0, 0)
        end
    )
    self:DoTaskInTime(
        15 * FRAMES,
        function(__b_UG)
            __b_UG:Attack()
        end
    )
    self:DoTaskInTime(
        22 * FRAMES,
        function(_BU_g)
            _BU_g["Physics"]:ClearMotorVelOverride()
        end
    )
    self:DoTaskInTime(
        35 * FRAMES,
        function(_B__ug_)
            _B__ug_:Remove()
        end
    )
end
local function __BU_G__()
    local _B_U_g_ = CreateEntity()
    _B_U_g_["entity"]:AddTransform()
    _B_U_g_["entity"]:AddAnimState()
    _B_U_g_["entity"]:AddSoundEmitter()
    _B_U_g_["entity"]:AddPhysics()
    _B_U_g_["entity"]:AddNetwork()
    _B_U_g_["Transform"]:SetFourFaced(_B_U_g_)
    _B_U_g_["Physics"]:SetMass(1)
    _B_U_g_["Physics"]:SetFriction(0)
    _B_U_g_["Physics"]:SetDamping(5)
    _B_U_g_["Physics"]:SetCollisionGroup(COLLISION["CHARACTERS"])
    _B_U_g_["Physics"]:ClearCollisionMask()
    _B_U_g_["Physics"]:CollidesWith(COLLISION["GROUND"])
    _B_U_g_["Physics"]:SetCapsule(.5, 1)
    _B_U_g_:AddTag "scarytoprey"
    _B_U_g_:AddTag "NOBLOCK"
    _B_U_g_["InitAnim"] = function(self, b__U__g, BU__g__, b_U_G__)
        _B_U_g_["AnimState"]:SetBank(b__U__g or "lavaarena_shadow_lunge")
        _B_U_g_["AnimState"]:SetBuild(BU__g__ or "waxwell_shadow_mod")
        if b_U_G__ then
            _B_U_g_["AnimState"]:AddOverrideBuild "lavaarena_shadow_lunge"
        end
        _B_U_g_["AnimState"]:SetMultColour(0, 0, 0, .5)
        _B_U_g_["AnimState"]:OverrideSymbol("swap_object", "swap_nightmaresword_shadow", "swap_nightmaresword_shadow")
    end
    _B_U_g_["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return _B_U_g_
    end
    _B_U_g_["SetPlayer"] = function(self, Bug)
        _B_U_g_["player"] = Bug
    end
    _B_U_g_["SetDamage"] = function(self, __b_U__G__)
        _B_U_g_["damage"] = __b_U__G__ or 0
    end
    _B_U_g_["SetTarget"] = function(self, __BU_G)
        _B_U_g_["target"] = __BU_G
        _B_U_g_["target_pos"] = Point(__BU_G["Transform"]:GetWorldPosition())
        _B_U_g_:FacePoint(_B_U_g_["target_pos"])
    end
    _B_U_g_["SetPosition"] = function(self, B__uG__, __B_U__g)
        _B_U_g_["offset"] = __B_U__g
        self["Transform"]:SetPosition(
            B__uG__["x"] + __B_U__g["x"],
            B__uG__["y"] + __B_U__g["y"],
            B__uG__["z"] + __B_U__g["z"]
        )
        __b__u_G_(self)
    end
    _B_U_g_["Attack"] = function(self)
        local function __Bu_g__(_B__U__G_)
            _B__U__G_["Transform"]:SetPosition(
                self["target_pos"]["x"],
                self["target_pos"]["y"],
                self["target_pos"]["z"]
            )
            _B__U__G_["Transform"]:SetRotation(self["Transform"]:GetRotation())
        end
        local _BU__g__ = math["random"](1, 2)
        if _BU__g__ == 1 then
            __Bu_g__(SpawnPrefab "shadowstrike_slash_fx")
        else
            __Bu_g__(SpawnPrefab "shadowstrike_slash2_fx")
        end
        local __B__u__g = 0.25
        SpawnPrefab "wb_magical_weaponsparks":SetThrusting(
            self["player"],
            self["target"],
            Vector3(self["offset"]["x"] * __B__u__g, self["offset"]["y"] * __B__u__g, self["offset"]["z"] * __B__u__g)
        )
        if self and self:IsValid() and self["target"] and self["target"]:IsValid() then
            local B_UG__ = math["sqrt"](self:GetDistanceSqToInst(self["target"]))
            print("shadow attacks!", self["player"], self["target"], B_UG__)
            if
                self["player"] and self["target"] and B_UG__ <= 3.5 and self["target"]["components"]["health"] and
                    not self["target"]["components"]["health"]:IsDead()
             then
                self["target"]["components"]["combat"]:GetAttacked(self["player"], self["damage"])
            end
        end
        _B_U_g_["SoundEmitter"]:PlaySound "dontstarve/common/lava_arena/fireball"
    end
    return _B_U_g_
end
return Prefab("wb_magical_shadow", __BU_G__, bug, __b_UG__)
