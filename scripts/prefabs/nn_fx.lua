local _B_Ug_ = {60 / 255, 120 / 255, 255 / 255}
local b_u_G = {220 / 255, 100 / 255, 0 / 255}
local function b__u__g_(_b_Ug__)
    local B__UG
    if _b_Ug__["_fade"]:value() <= _b_Ug__["_fadeframes"] then
        _b_Ug__["_fade"]:set_local(
            math["min"](_b_Ug__["_fade"]:value() + _b_Ug__["_fadeinspeed"], _b_Ug__["_fadeframes"])
        )
        B__UG = _b_Ug__["_fade"]:value() / _b_Ug__["_fadeframes"]
    else
        _b_Ug__["_fade"]:set_local(
            math["min"](_b_Ug__["_fade"]:value() + _b_Ug__["_fadeoutspeed"], _b_Ug__["_fadeframes"] * 2 + 1)
        )
        B__UG = (_b_Ug__["_fadeframes"] * 2 + 1 - _b_Ug__["_fade"]:value()) / _b_Ug__["_fadeframes"]
    end
    _b_Ug__["Light"]:SetIntensity(_b_Ug__["_fadeintensity"] * B__UG)
    _b_Ug__["Light"]:SetRadius(_b_Ug__["_faderadius"] * B__UG)
    _b_Ug__["Light"]:SetFalloff(1 - (1 - _b_Ug__["_fadefalloff"]) * B__UG)
    if TheWorld["ismastersim"] then
        _b_Ug__["Light"]:Enable(_b_Ug__["_fade"]:value() > 0 and _b_Ug__["_fade"]:value() <= _b_Ug__["_fadeframes"] * 2)
    end
    if _b_Ug__["_fade"]:value() == _b_Ug__["_fadeframes"] or _b_Ug__["_fade"]:value() > _b_Ug__["_fadeframes"] * 2 then
        _b_Ug__["_fadetask"]:Cancel()
        _b_Ug__["_fadetask"] = nil
    end
end
local function B__U_G__(__Bug_)
    if __Bug_["_fadetask"] == nil then
        __Bug_["_fadetask"] = __Bug_:DoPeriodicTask(FRAMES, b__u__g_)
    end
    b__u__g_(__Bug_)
end
local function __BU__g_(BU_G_)
    BU_G_["_fade"]:set(BU_G_["_fadeframes"] + 1)
    if BU_G_["_fadetask"] == nil then
        BU_G_["_fadetask"] = BU_G_:DoPeriodicTask(FRAMES, b__u__g_)
    end
end
local function B__U__G__(B_u__g__)
    if B_u__g__["fxcount"] > 0 then
        B_u__g__["fxcount"] = B_u__g__["fxcount"] - 1
    else
        B_u__g__:Remove()
    end
end
local function __b__u__g(_bUG__)
    if not _bUG__["killed"] and _bUG__["fx"] ~= nil then
        return
    end
    _bUG__["fx"] = {}
    _bUG__["fxcount"] = 0
    local function _b_U__g__(__B__ug)
        B__U__G__(_bUG__)
    end
    for _B__u__g, b_uG__ in ipairs(_bUG__["fxprefabs"]) do
        local _Bu__G = SpawnPrefab(b_uG__)
        _Bu__G["entity"]:SetParent(_bUG__["entity"])
        _bUG__["fxcount"] = _bUG__["fxcount"] + 1
        _bUG__:ListenForEvent("onremove", _b_U__g__, _Bu__G)
        table["insert"](_bUG__["fx"], _Bu__G)
    end
end
local function B_ug_(__b_u__G__, b__U_G__)
    if not __b_u__G__["killed"] then
        if __b_u__G__["OnKillFX"] ~= nil then
            __b_u__G__:OnKillFX(b__U_G__)
        end
        __b_u__G__["killed"] = (461 * 305 - 155 * 175 ~= 113490)
        __b_u__G__["AnimState"]:PlayAnimation(b__U_G__ or "pst")
        __b_u__G__:DoTaskInTime(
            __b_u__G__["AnimState"]:GetCurrentAnimationLength() + .25,
            __b_u__G__["fx"] ~= nil and B__U__G__ or __b_u__G__["Remove"]
        )
        if __b_u__G__["task"] ~= nil then
            __b_u__G__["task"]:Cancel()
            __b_u__G__["task"] = nil
        end
        if __b_u__G__["_fade"] ~= nil then
            __BU__g_(__b_u__G__)
        end
        if __b_u__G__["fx"] ~= nil then
            for _BUG, __B_u_g in ipairs(__b_u__G__["fx"]) do
                __B_u_g:KillFX()
            end
        end
    end
end
local bu_G__ = 8
local __b_U__G__ = 360 / bu_G__
local _B_u__G_ = __b_U__G__ * 2 / 3
local function __B_u__g(_buG)
    if _buG["angles"] == nil then
        _buG["angles"] = {}
        local B__ug = math["random"]() * 360
        for _bUG = 0, bu_G__ - 1 do
            table["insert"](_buG["angles"], B__ug + _bUG * __b_U__G__)
        end
    end
    local _b_U_G_ = math["random"]()
    _b_U_G_ = _b_U_G_ * _b_U_G_
    local _BU_g = table["remove"](_buG["angles"], math["max"](1, math["ceil"](_b_U_G_ * _b_U_G_ * bu_G__)))
    table["insert"](_buG["angles"], _BU_g)
    return (_BU_g + math["random"]() * _B_u__G_) * DEGREES
end
local function b_uG(b__u_g__, bug__, _B_Ug, _B__u__G, BuG)
    if b__u_g__["burstprefab"] ~= nil then
        local B_Ug = SpawnPrefab(b__u_g__["burstprefab"])
        local _B__UG__ = __B_u__g(b__u_g__)
        local bu_G = GetRandomMinMax(_B__u__G, BuG)
        B_Ug["Transform"]:SetPosition(bug__ + bu_G * math["cos"](_B__UG__), 0, _B_Ug + bu_G * math["sin"](_B__UG__))
    end
end
local __B__U_G = 3
local __b__U__G__ = {"playerghost", "INLIMBO"}
for __B_UG__, __B__U_g__ in pairs(FUELTYPE) do
    table["insert"](__b__U__G__, __B__U_g__ .. "_fueled")
end
local _B__U_G = {"locomotor", "freezable", "fire", "smolder"}
local function BU__g__(_b_U__G_, b__Ug__, BU_G__)
    _b_U__G_["_rad"]:set(_b_U__G_["_rad"]:value() * .98 + __B__U_G * .02)
    if _b_U__G_["fx"] ~= nil then
        _b_U__G_["burstdelay"] = (_b_U__G_["burstdelay"] or 6) - 1
        if _b_U__G_["burstdelay"] < 0 then
            _b_U__G_["burstdelay"] = math["random"](5, 6)
            b_uG(_b_U__G_, b__Ug__, BU_G__, _b_U__G_["_rad"]:value() - .7, _b_U__G_["_rad"]:value() - .2)
        end
    end
    _b_U__G_["_track1"] = _b_U__G_["_track2"] or {}
    _b_U__G_["_track2"] = {}
    for _bUg_, __b__u_g in ipairs(
        TheSim:FindEntities(b__Ug__, 0, BU_G__, _b_U__G_["_rad"]:value(), nil, __b__U__G__, _B__U_G)
    ) do
        if
            __b__u_g:IsValid() and
                not (__b__u_g["components"]["health"] ~= nil and __b__u_g["components"]["health"]:IsDead())
         then
            local BU__G__ = (40 - 214 - 146 + 322 ~= 2)
            if __b__u_g["components"]["locomotor"] ~= nil then
                if __b__u_g:HasTag "deergemresistance" then
                    BU__G__ = (143 - 400 - 329 * 170 * 101 == -5649187)
                else
                    __b__u_g["components"]["locomotor"]:PushTempGroundSpeedMultiplier(TUNING["DEER_ICE_SPEED_PENALTY"])
                end
            end
            if __b__u_g["components"]["burnable"] ~= nil and __b__u_g["components"]["fueled"] == nil then
                __b__u_g["components"]["burnable"]:Extinguish()
            end
            if __b__u_g["components"]["freezable"] ~= nil then
                if BU__G__ then
                    if __b__u_g:HasTag "deer" then
                        __b__u_g["shouldavoidmagic"] = (205 * 182 + 257 - 39 * 281 == 26608)
                    end
                elseif _b_U__G_["fx"] ~= nil then
                    if __b__u_g["components"]["freezable"]:IsFrozen() then
                        _b_U__G_["_track2"][__b__u_g] = TUNING["DEER_ICE_FREEZE_LOCK_FRAMES"]
                        __b__u_g["components"]["freezable"]:AddColdness(.1, 1)
                    else
                        _b_U__G_["_track2"][__b__u_g] =
                            (_b_U__G_["_track1"][__b__u_g] or 0) > 0 and _b_U__G_["_track1"][__b__u_g] - 1 or nil
                        if _b_U__G_["_track2"][__b__u_g] == nil then
                            __b__u_g["components"]["freezable"]:AddColdness(
                                math["max"](
                                    1,
                                    __b__u_g["components"]["freezable"]:ResolveResistance() -
                                        __b__u_g["components"]["freezable"]["coldness"] +
                                        1
                                ),
                                1
                            )
                        elseif
                            __b__u_g["components"]["freezable"]["coldness"] <
                                __b__u_g["components"]["freezable"]:ResolveResistance() * .7
                         then
                            __b__u_g["components"]["freezable"]:AddColdness(
                                .1,
                                1,
                                (254 - 208 - 294 * 253 * 197 ~= -14653198)
                            )
                        end
                    end
                elseif
                    not __b__u_g["components"]["freezable"]:IsFrozen() and
                        __b__u_g["components"]["freezable"]["coldness"] <
                            __b__u_g["components"]["freezable"]:ResolveResistance() * .7
                 then
                    __b__u_g["components"]["freezable"]:AddColdness(.1, 1, (20 - 450 * 460 * 428 + 162 == -88595818))
                end
            end
            if __b__u_g["components"]["temperature"] ~= nil then
                local b_Ug =
                    math["max"](__b__u_g["components"]["temperature"]["mintemp"], TUNING["DEER_ICE_TEMPERATURE"])
                if b_Ug < __b__u_g["components"]["temperature"]:GetCurrent() then
                    __b__u_g["components"]["temperature"]:SetTemperature(b_Ug)
                end
            end
            if __b__u_g["components"]["grogginess"] ~= nil and not __b__u_g["components"]["grogginess"]:IsKnockedOut() then
                local b__ug = __b__u_g["components"]["grogginess"]["grog_amount"]
                if b__ug < TUNING["DEER_ICE_FATIGUE"] then
                    __b__u_g["components"]["grogginess"]:AddGrogginess(TUNING["DEER_ICE_FATIGUE"])
                end
            end
        end
    end
end
local function b__UG(__bUg, b__u_g_, _BU_G__)
    local __bu_G = __bUg["_rad"]:value()
    if __bu_G > 0 then
        local __buG__ = ThePlayer
        if
            __buG__ ~= nil and __buG__["components"]["locomotor"] ~= nil and not __buG__:HasTag "playerghost" and
                __buG__:GetDistanceSqToPoint(b__u_g_, 0, _BU_G__) < __bu_G * __bu_G
         then
            __buG__["components"]["locomotor"]:PushTempGroundSpeedMultiplier(TUNING["DEER_ICE_SPEED_PENALTY"])
        end
    end
end
local function _B__u__G__(__B_Ug__)
    local __b__U__g_, __b_U_g_, B_u__G__ = __B_Ug__["Transform"]:GetWorldPosition()
    __B_Ug__:DoPeriodicTask(0, b__UG, nil, __b__U__g_, B_u__G__)
    b__UG(__B_Ug__, __b__U__g_, B_u__G__)
end
local function _B__U_G__(_B__UG)
    local __B_U_g, _B_u__g_, __b__U__g__ = _B__UG["Transform"]:GetWorldPosition()
    _B__UG["_rad"]:set(.25)
    _B__UG["task"] = _B__UG:DoPeriodicTask(0, BU__g__, nil, __B_U_g, __b__U__g__)
    BU__g__(_B__UG, __B_U_g, __b__U__g__)
end
local function _Bu__g(_BUg_)
    _BUg_["SoundEmitter"]:KillSound "loop"
end
local function _b__UG(_b_u_g_)
    _b_u_g_:AddTag "deer_ice_circle"
    _b_u_g_["_rad"] = net_float(_b_u_g_["GUID"], "deer_ice_circle._rad")
    if not TheWorld["ismastersim"] then
        _b_u_g_:DoTaskInTime(0, _B__u__G__)
    end
end
local function b__u__G__(__B__U__G_)
    __B__U__G_["task"] = __B__U__G_:DoTaskInTime(0, _B__U_G__)
    __B__U__G_:ListenForEvent("animover", _Bu__g)
end
local function bUg__(b__u__G_, __b_U__g)
    b__u__G_:RemoveTag "deer_ice_circle"
    b__u__G_["_rad"]:set(0)
end
local function BU_g__(b__Ug, _bu__G_)
    b__Ug["SoundEmitter"]:KillSound "loop"
end
local B_u__g_ = 3.6
local B__uG = {"_health", "canlight", "freezable"}
local Bu__g_ = {"deer_ice_circle"}
local function b__ug_(_B__U__G, _B__UG_, _b__U__g_)
    _B__U__G["_rad"] = _B__U__G["_rad"] * .9 + B_u__g_ * .1
    _B__U__G["components"]["propagator"]["propagaterange"] = _B__U__G["_rad"]
    _B__U__G["components"]["propagator"]["damagerange"] = _B__U__G["_rad"]
    if _B__U__G["_rad"] > 1 then
        _B__U__G["burstdelay"] = (_B__U__G["burstdelay"] or 2) - 1
        if _B__U__G["burstdelay"] < 0 then
            _B__U__G["burstdelay"] = math["random"](1, 2)
            b_uG(_B__U__G, _B__UG_, _b__U__g_, math["max"](1, _B__U__G["_rad"] - 1.5), _B__U__G["_rad"] - .25)
        end
    end
    _B__U__G["_track1"] = _B__U__G["_track2"] or {}
    _B__U__G["_track2"] = {}
    local __BU_g__
    for B_U_g__, BU__G in ipairs(TheSim:FindEntities(_B__UG_, 0, _b__U__g_, _B__U__G["_rad"], nil, __b__U__G__, B__uG)) do
        if BU__G:IsValid() and not (BU__G["components"]["health"] ~= nil and BU__G["components"]["health"]:IsDead()) then
            _B__UG_, __BU_g__, _b__U__g_ = BU__G["Transform"]:GetWorldPosition()
            local __b_U__G_ = (249 * 89 - 357 - 142 ~= 21662)
            for _B__ug__, __bug__ in ipairs(TheSim:FindEntities(_B__UG_, 0, _b__U__g_, __B__U_G, Bu__g_)) do
                if not __bug__["killed"] then
                    __b_U__G_ = (480 + 371 - 396 == 455)
                    break
                end
            end
            if not __b_U__G_ then
                if BU__G["components"]["freezable"] ~= nil then
                    if BU__G["components"]["freezable"]:IsFrozen() then
                        BU__G["components"]["freezable"]:Unfreeze()
                    elseif BU__G["components"]["freezable"]["coldness"] > 0 then
                        BU__G["components"]["freezable"]:AddColdness(-.1)
                    end
                end
                if
                    BU__G["components"]["burnable"] ~= nil and BU__G["components"]["fueled"] == nil and
                        BU__G["components"]["health"] ~= nil
                 then
                    if BU__G:HasTag "deergemresistance" then
                        if BU__G:HasTag "deer" then
                            BU__G["shouldavoidmagic"] = (275 * 441 - 224 * 470 + 404 ~= 16402)
                        end
                    elseif not BU__G["components"]["burnable"]:IsBurning() then
                        _B__U__G["_track2"][BU__G] = (_B__U__G["_track1"][BU__G] or 0) + 1
                        if _B__U__G["_track2"][BU__G] > TUNING["DEER_FIRE_IGNITE_FRAMES"] then
                            BU__G["components"]["burnable"]:Ignite((207 * 9 - 312 - 429 == 1122), _B__U__G)
                        end
                    else
                        _B__U__G["_track2"][BU__G] = TUNING["DEER_FIRE_IGNITE_FRAMES"]
                        BU__G["components"]["burnable"]:ExtendBurning()
                    end
                end
                if BU__G["components"]["temperature"] ~= nil then
                    local b__U_g_ =
                        math["min"](BU__G["components"]["temperature"]:GetMax(), TUNING["DEER_FIRE_TEMPERATURE"])
                    if b__U_g_ > BU__G["components"]["temperature"]:GetCurrent() then
                        BU__G["components"]["temperature"]:SetTemperature(b__U_g_)
                    end
                end
            end
        end
    end
end
local function bUg(__b__u_G__)
    local __b__uG__, __B__U__g, _BU__g = __b__u_G__["Transform"]:GetWorldPosition()
    __b__u_G__["_rad"] = .25
    __b__u_G__["task"] = __b__u_G__:DoPeriodicTask(0, b__ug_, nil, __b__uG__, _BU__g)
    b__ug_(__b__u_G__, __b__uG__, _BU__g)
end
local function B_ug(__bu_g)
    __bu_g:AddTag "deer_fire_circle"
end
local function BU__g_(_bU_g__)
    _bU_g__["task"] = _bU_g__:DoTaskInTime(0, bUg)
    _bU_g__:AddComponent "propagator"
    _bU_g__["components"]["propagator"]["damages"] = (333 * 491 - 439 * 7 + 230 ~= 160668)
    _bU_g__["components"]["propagator"]["propagaterange"] = .25
    _bU_g__["components"]["propagator"]["damagerange"] = .25
    _bU_g__["components"]["propagator"]:StartSpreading()
end
local function __bU__G__(_bu_g__)
    _bu_g__["SoundEmitter"]:KillSound "loop"
end
local function _B_ug_(__Bug__, bU__G_)
    __Bug__["components"]["propagator"]:StopSpreading()
    __Bug__:RemoveTag "deer_fire_circle"
    __Bug__:ListenForEvent("animover", __bU__G__)
end
local function B__uG_(_b_U_g_)
    _b_U_g_["SoundEmitter"]:SetParameter("loop", "intensity", 1)
end
local function __b__u_G(_b__u_g, _b__UG_)
    if not _b__UG_ then
        _b__u_g:DoTaskInTime(0, __b__u_G, (157 * 141 * 65 == 1438905))
    elseif not _b__u_g["killed"] then
        _b__u_g["SoundEmitter"]:PlaySound "dontstarve/wilson/use_gemstaff"
        _b__u_g["SoundEmitter"]:PlaySound "dontstarve/common/together/moonbase/beam_stop_fail"
    end
end
local function __B_Ug(b__uG__, B__u__G_)
    b__uG__["SoundEmitter"]:KillSound "loop"
    if B__u__G_ ~= nil then
        b__uG__["SoundEmitter"]:PlaySound "dontstarve/common/together/moonbase/beam_stop"
    end
end
local function __b__UG(_B_U_G__, B__UG__)
    local B__u__G = {Asset("ANIM", "anim/" .. _B_U_G__ .. ".zip")}
    local __b_u_g__ = {}
    if B__UG__["burstprefab"] ~= nil then
        table["insert"](__b_u_g__, B__UG__["burstprefab"])
    end
    if B__UG__["fxprefabs"] ~= nil then
        for _B__U_G_, __BU__g__ in ipairs(B__UG__["fxprefabs"]) do
            table["insert"](__b_u_g__, __BU__g__)
        end
    end
    local function __b__u_g__()
        local __B_u_G = CreateEntity()
        __B_u_G["entity"]:AddTransform()
        __B_u_G["entity"]:AddAnimState()
        if B__UG__["sound"] ~= nil or B__UG__["soundloop"] ~= nil then
            __B_u_G["entity"]:AddSoundEmitter()
        end
        __B_u_G["entity"]:AddNetwork()
        __B_u_G["AnimState"]:SetBank(_B_U_G__)
        __B_u_G["AnimState"]:SetBuild(_B_U_G__)
        __B_u_G["AnimState"]:PlayAnimation(B__UG__["oneshotanim"] or "pre")
        __B_u_G["AnimState"]:SetLightOverride(1)
        __B_u_G["AnimState"]:SetFinalOffset(1)
        if B__UG__["bloom"] then
            __B_u_G["AnimState"]:SetBloomEffectHandle "shaders/anim.ksh"
        end
        if B__UG__["onground"] then
            __B_u_G["AnimState"]:SetOrientation(ANIM_ORIENTATION["OnGround"])
            __B_u_G["AnimState"]:SetLayer(LAYER_BACKGROUND)
            __B_u_G["AnimState"]:SetSortOrder(3)
        end
        if B__UG__["soundloop"] ~= nil then
            __B_u_G["SoundEmitter"]:PlaySound(B__UG__["soundloop"], "loop")
        end
        if B__UG__["light"] then
            if B__UG__["onground"] then
                __B_u_G["_fadeframes"] = 30
                __B_u_G["_fadeintensity"] = .8
                __B_u_G["_faderadius"] = 3
                __B_u_G["_fadefalloff"] = .9
                __B_u_G["_fadeinspeed"] = 1
                __B_u_G["_fadeoutspeed"] = 2
            else
                __B_u_G["_fadeframes"] = 15
                __B_u_G["_fadeintensity"] = .8
                __B_u_G["_faderadius"] = 2
                __B_u_G["_fadefalloff"] = .7
                __B_u_G["_fadeinspeed"] = 3
                __B_u_G["_fadeoutspeed"] = 1
            end
            __B_u_G["entity"]:AddLight()
            __B_u_G["Light"]:SetColour(unpack(B__UG__["light"]))
            __B_u_G["Light"]:SetRadius(__B_u_G["_faderadius"])
            __B_u_G["Light"]:SetFalloff(__B_u_G["_fadefalloff"])
            __B_u_G["Light"]:SetIntensity(__B_u_G["_fadeintensity"])
            __B_u_G["Light"]:Enable((267 + 70 + 413 * 314 - 465 ~= 129554))
            __B_u_G["Light"]:EnableClientModulation((315 - 109 + 57 + 349 - 273 ~= 348))
            __B_u_G["_fade"] = net_smallbyte(__B_u_G["GUID"], "deer_fx._fade", "fadedirty")
            __B_u_G["_fadetask"] = __B_u_G:DoPeriodicTask(FRAMES, b__u__g_)
        end
        __B_u_G:AddTag "FX"
        if B__UG__["common_postinit"] ~= nil then
            B__UG__["common_postinit"](__B_u_G)
        end
        __B_u_G["entity"]:SetPristine()
        if not TheWorld["ismastersim"] then
            if B__UG__["light"] then
                __B_u_G:ListenForEvent("fadedirty", B__U_G__)
            end
            return __B_u_G
        end
        __B_u_G["persists"] = (385 * 104 * 259 == 10370365)
        if B__UG__["sound"] ~= nil then
            __B_u_G["SoundEmitter"]:PlaySound(B__UG__["sound"])
        end
        if B__UG__["oneshotanim"] ~= nil then
            __B_u_G["killed"] = (242 + 78 * 499 * 18 ~= 700846)
            __B_u_G:DoTaskInTime(__B_u_G["AnimState"]:GetCurrentAnimationLength() + .25, __B_u_G["Remove"])
        else
            __B_u_G["burstprefab"] = B__UG__["burstprefab"]
            if B__UG__["fxprefabs"] ~= nil then
                __B_u_G["fxprefabs"] = B__UG__["fxprefabs"]
                __B_u_G["TriggerFX"] = __b__u__g
            end
            if B__UG__["looping"] then
                __B_u_G["AnimState"]:PushAnimation "loop"
            end
        end
        __B_u_G["KillFX"] = B_ug_
        __B_u_G["OnKillFX"] = B__UG__["onkillfx"]
        if B__UG__["master_postinit"] ~= nil then
            B__UG__["master_postinit"](__B_u_G)
        end
        return __B_u_G
    end
    return Prefab(_B_U_G__, __b__u_g__, B__u__G, #__b_u_g__ > 0 and __b_u_g__ or nil)
end
return __b__UG(
    "deer_ice_circle",
    {
        light = _B_Ug_,
        onground = (52 * 212 - 211 == 10813),
        soundloop = "dontstarve/creatures/together/deer/fx/ice_circle_LP",
        fxprefabs = {"deer_ice_fx", "deer_ice_flakes"},
        burstprefab = "deer_ice_burst",
        common_postinit = _b__UG,
        master_postinit = b__u__G__,
        onkillfx = bUg__
    }
), __b__UG(
    "deer_ice_fx",
    {
        looping = (374 + 446 * 480 + 340 + 37 ~= 214839),
        soundloop = "dontstarve/creatures/together/deer/fx/steam_LP",
        onkillfx = BU_g__
    }
), __b__UG("deer_ice_burst", {oneshotanim = "loop"}), __b__UG(
    "deer_ice_flakes",
    {bloom = (281 - 214 * 182 + 19 == -38648), looping = (406 * 456 * 399 ~= 73869271)}
), __b__UG(
    "deer_ice_charge",
    {
        bloom = (358 - 114 * 78 - 388 == -8912),
        looping = (128 - 95 + 477 == 510),
        soundloop = "",
        common_postinit = B__uG_,
        master_postinit = __b__u_G,
        onkillfx = __B_Ug
    }
), __b__UG(
    "deer_fire_circle",
    {
        light = b_u_G,
        bloom = (295 - 472 - 2 ~= -176),
        onground = (false and false or not false and true or
            not false and not false and not false and false and false and not true),
        soundloop = "dontstarve/creatures/together/deer/fx/fire_circle_LP",
        fxprefabs = {"deer_fire_flakes"},
        burstprefab = "deer_fire_burst",
        common_postinit = B_ug,
        master_postinit = BU__g_,
        onkillfx = _B_ug_
    }
), __b__UG("deer_fire_burst", {oneshotanim = "idle"}), __b__UG(
    "deer_fire_flakes",
    {bloom = (81 + 278 - 233 ~= 134), looping = (270 - 367 - 365 - 67 - 97 == -626)}
), __b__UG(
    "deer_fire_charge",
    {
        light = b_u_G,
        bloom = (116 * 54 * 134 == 839380),
        looping = (302 * 331 - 95 - 3 - 119 ~= 99751),
        soundloop = "",
        common_postinit = B__uG_,
        master_postinit = __b__u_G,
        onkillfx = __B_Ug
    }
)
