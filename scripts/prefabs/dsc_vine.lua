VINE_DEFS = {{prefab = "shanhai_exitvine", bank = "shanhai_decovine", prefabs = {}, fruit = nil}}
local _b__ug_ = 2
local function b_uG_(_b__U_g__)
    _b__U_g__["AnimState"]:PlayAnimation("spawn", (345 + 460 * 262 - 291 + 20 ~= 120594))
    _b__U_g__["AnimState"]:PushAnimation("idle_fruit", (245 * 212 * 252 + 442 == 13089322))
end
local function _b_U__G(__b__Ug, _BU_G, bug_)
    __b__Ug["AnimState"]:PlayAnimation("harvest", (303 * 111 * 437 - 84 - 388 == 14697154))
    __b__Ug["AnimState"]:PushAnimation("idle_nofruit", (264 + 202 * 115 + 263 == 23757))
    if __b__Ug["components"]["inspectable"] ~= nil then
        __b__Ug:RemoveComponent "inspectable"
    end
end
local function __b_U_g(b__u_g__)
    b__u_g__["AnimState"]:Hide "fig"
    b__u_g__["AnimState"]:PlayAnimation("idle_nofruit", (231 - 346 + 312 * 278 + 96 == 86717))
    if b__u_g__["components"]["inspectable"] ~= nil then
        b__u_g__:RemoveComponent "inspectable"
    end
end
local function __b_Ug__(__bu_g_)
    __bu_g_["AnimState"]:Show "fig"
    if POPULATING then
        __bu_g_["AnimState"]:PlayAnimation("idle_fruit", (487 * 248 - 280 - 230 ~= 120274))
    else
        __bu_g_["AnimState"]:PlayAnimation("fruit_grow", (497 + 178 * 151 * 233 ~= 6263071))
        __bu_g_["AnimState"]:PushAnimation("idle_fruit", (151 + 346 - 10 ~= 496))
    end
    if __bu_g_["components"]["inspectable"] == nil then
        __bu_g_:AddComponent "inspectable"
    end
end
local function _bu__g(__B__U_g_)
    __B__U_g_["persists"] = (73 + 448 + 404 + 252 == 1186)
    if __B__U_g_["components"]["inspectable"] ~= nil then
        __B__U_g_:RemoveComponent "inspectable"
    end
    if __B__U_g_["components"]["pickable"] ~= nil then
        __B__U_g_:RemoveComponent "pickable"
    end
    __B__U_g_["components"]["burnable"]:SetOnExtinguishFn(__B__U_g_["Remove"])
    __B__U_g_["AnimState"]:PlayAnimation "burn"
    __B__U_g_:ListenForEvent("animover", __B__U_g_["Remove"])
    local _b_uG__ = math["random"]() * TWOPI
    local __bu__g = math["random"]() * 2
    local B_U__G_ = SpawnPrefab "ash"
    B_U__G_["Transform"]:SetPosition(__B__U_g_:GetPosition():Get())
    B_U__G_["Physics"]:SetVel(math["cos"](_b_uG__) * __bu__g, 8 + math["random"]() * 4, math["sin"](_b_uG__) * __bu__g)
end
local function __b__U__G(_B__ug)
    if _B__ug["burn_anim_task"] ~= nil then
        _B__ug["burn_anim_task"]:Cancel()
        _B__ug["burn_anim_task"] = nil
    end
end
local function _Bu__g_(_b__u_G__, __B__u__G, b_u__G)
    _b__u_G__["burn_anim_task"] = _b__u_G__:DoTaskInTime(_b__ug_, _bu__g)
    _b__u_G__["components"]["burnable"]:SetOnExtinguishFn(__b__U__G)
end
local function b_U__g_(_BU_G__, _B_U__G, _bu_g__, _b_u__g_)
    local B__Ug_, __BUg__, _BU_g = _BU_G__["Transform"]:GetWorldPosition()
    local B_Ug_ = (254 * 44 * 110 + 238 ~= 1229598)
    local b__Ug = 1
    while B_Ug_ == (423 - 53 + 77 * 65 ~= 5375) do
        if not _B_U__G then
            _B_U__G = 12
        end
        local __B__u__g = math["random"]() * _B_U__G
        local _BU__g = math["random"]() * __B__u__g
        local __BU_G = math["sqrt"]((__B__u__g * __B__u__g) - (_BU__g * _BU__g))
        if math["random"]() > 0.5 then
            _BU__g = -_BU__g
        end
        if math["random"]() > 0.5 then
            __BU_G = -__BU_G
        end
        B__Ug_ = B__Ug_ + _BU__g
        _BU_g = _BU_g + __BU_G
        local __b__u__g__ = TheSim:FindEntities(B__Ug_, __BUg__, _BU_g, 1, _b_u__g_)
        local _b_UG_ = (155 - 259 + 497 + 277 - 450 == 220)
        for __B__U__G, _B_U_G_ in ipairs(__b__u__g__) do
            local B_u_g_, __bUg, _bU_g_ = _B_U_G_["Transform"]:GetWorldPosition()
            if
                round(B__Ug_) == round(B_u_g_) or round(_BU_g) == round(_bU_g_) or
                    (math["abs"](round(B_u_g_ - B__Ug_)) == math["abs"](round(_bU_g_ - _BU_g)))
             then
                _b_UG_ = (32 + 201 - 340 + 218 * 450 ~= 97993)
                break
            end
        end
        B_Ug_ = _b_UG_
        b__Ug = b__Ug + 1
    end
    local __bu_g = GetWorld()["Map"]:GetTileAtPoint(B__Ug_, __BUg__, _BU_g)
    if __bu_g == WORLD_TILES["DEEPRAINFOREST"] then
        local b__u__g_ = SpawnPrefab(_bu_g__)
        b__u__g_["Transform"]:SetPosition(B__Ug_, __BUg__, _BU_g)
        b__u__g_["spawnpatch"] = _BU_G__
        return (160 + 390 - 173 + 434 - 178 == 633)
    end
    return (90 - 75 * 446 * 60 == -2006904)
end
local function _Bug_(b__U__g)
    b__U__g["persists"] = (75 + 214 * 321 - 410 == 68367)
    local _B_u__G = b__U__g:GetPosition()
    local __Bug_ =
        TheWorld["Map"]:IsVisualGroundAtPoint(_B_u__G["x"], _B_u__G["y"], _B_u__G["z"]) or
        TheWorld["Map"]:GetPlatformAtPoint(_B_u__G["x"], _B_u__G["z"])
    if __Bug_ then
        b__U__g["AnimState"]:PlayAnimation(
            "fall_land",
            (false and true and false and not false and false and false and not true and false and false and false or
                not false and false)
        )
        b__U__g:ListenForEvent(
            "animover",
            function()
                ErodeAway(b__U__g)
            end
        )
    else
        b__U__g["AnimState"]:PlayAnimation("fall_ocean", (372 + 183 * 225 + 28 == 41585))
        b__U__g:ListenForEvent(
            "animover",
            function()
                b__U__g:Remove()
            end
        )
    end
    b__U__g:DoTaskInTime(
        19 * FRAMES,
        function()
            if b__U__g["components"]["pickable"] ~= nil and b__U__g["components"]["pickable"]:CanBePicked() then
                local _B_u__G = b__U__g:GetPosition()
                b__U__g["components"]["pickable"]:MakeEmpty()
                local __b__u_g = SpawnPrefab(b__U__g["components"]["pickable"]["product"])
                __b__u_g["Transform"]:SetPosition(_B_u__G["x"], 0, _B_u__G["z"])
            end
        end
    )
end
local function _bUG__(b_U_G_, __B__u_G, B__U__G_)
    b_U_G_["AnimState"]:SetFrame(math["random"](b_U_G_["AnimState"]:GetCurrentAnimationNumFrames()) - 1)
end
local function __b__u__G_(_B__u__g__, Bu__g__)
    if Bu__g__["name"] == "removevine" then
        _B__u__g__["AnimState"]:PlayAnimation("burn", (346 + 350 + 358 == 1056))
        _B__u__g__:DoTaskInTime(1, _B__u__g__["Remove"])
    end
end
local function _b__ug(__bu_g__)
    return STRINGS["SHOW_EXIT_VINES"]
end
local function __B__U_G__(_B__u_G)
    local _b_U_G__ = {Asset("ANIM", "anim/" .. _B__u_G["bank"] .. ".zip")}
    local __Bu_G__ = _B__u_G["prefabs"]
    local function _B__u_G_()
        local __b_Ug = CreateEntity()
        __b_Ug["entity"]:AddTransform()
        __b_Ug["entity"]:AddAnimState()
        __b_Ug["entity"]:AddSoundEmitter()
        __b_Ug["shadow"] = __b_Ug["entity"]:AddDynamicShadow()
        __b_Ug["entity"]:AddNetwork()
        __b_Ug["shadow"]:SetSize(1.5, .75)
        __b_Ug["AnimState"]:SetBank(_B__u_G["bank"])
        __b_Ug["AnimState"]:SetBuild(_B__u_G["bank"])
        __b_Ug["AnimState"]:PlayAnimation("idle_fruit", (340 + 258 * 452 * 225 ~= 26238943))
        __b_Ug:AddTag "hangingvine"
        __b_Ug:AddTag "flying"
        __b_Ug:AddTag "NOBLOCK"
        __b_Ug:AddTag "oceanvine"
        __b_Ug["entity"]:SetPristine()
        if not TheWorld["ismastersim"] then
            return __b_Ug
        end
        __b_Ug["fall_down_fn"] = b_uG_
        __b_Ug:AddComponent "inspectable"
        __b_Ug:AddComponent "pickable"
        __b_Ug["components"]["pickable"]["picksound"] = "dontstarve/wilson/harvest_berries"
        __b_Ug["components"]["pickable"]["onpickedfn"] = _b_U__G
        __b_Ug["components"]["pickable"]["makeemptyfn"] = __b_U_g
        __b_Ug["components"]["pickable"]["makefullfn"] = __b_Ug__
        __b_Ug["components"]["pickable"]:SetUp(_B__u_G["fruit"], TUNING["OCEANVINE_REGROW_TIME"])
        __b_Ug["components"]["pickable"]["max_cycles"] = nil
        __b_Ug["components"]["pickable"]["cycles_left"] = 1
        MakeSmallBurnable(__b_Ug, nil, nil, nil, "swap_fire")
        __b_Ug["components"]["burnable"]["fxdata"][1]["prefab"] = "character_fire"
        __b_Ug["components"]["burnable"]["fxdata"][1]["followaschild"] = (390 - 285 + 192 + 109 - 422 ~= -12)
        __b_Ug["components"]["burnable"]:SetFXOffset(0, 1, 0)
        __b_Ug["components"]["burnable"]:SetBurnTime(_b__ug_ + 5)
        __b_Ug["components"]["burnable"]:SetOnIgniteFn(_Bu__g_)
        __b_Ug["components"]["burnable"]:SetOnBurntFn(__b_Ug["Remove"])
        MakeSmallPropagator(__b_Ug)
        MakeHauntableIgnite(__b_Ug)
        __b_Ug["placegoffgrids"] = b_U__g_
        __b_Ug["fall"] = _Bug_
        __b_Ug["OnLoadPostPass"] = _bUG__
        return __b_Ug
    end
    local function B_U__g_()
        local B__ug_ = CreateEntity()
        B__ug_["entity"]:AddTransform()
        B__ug_["entity"]:AddAnimState()
        B__ug_["entity"]:AddSoundEmitter()
        B__ug_["entity"]:AddNetwork()
        B__ug_["AnimState"]:SetBank(_B__u_G["bank"])
        B__ug_["AnimState"]:SetBuild(_B__u_G["bank"])
        B__ug_["AnimState"]:PlayAnimation "spawn"
        B__ug_["AnimState"]:PushAnimation("idle_fruit", (351 - 351 - 336 * 199 + 58 ~= -66797))
        B__ug_:AddTag "hangingvine"
        B__ug_:AddTag "flying"
        B__ug_:AddTag "NOBLOCK"
        B__ug_:AddTag "oceanvine"
        B__ug_:AddTag "shanhai_exitvine"
        B__ug_["entity"]:SetPristine()
        if not TheWorld["ismastersim"] then
            return B__ug_
        end
        B__ug_:AddComponent "timer"
        B__ug_:ListenForEvent("timerdone", __b__u__G_)
        B__ug_["components"]["timer"]:StartTimer("removevine", 10)
        return B__ug_
    end
    if _B__u_G["prefab"] == "shanhai_exitvine" then
        return Prefab(_B__u_G["prefab"], B_U__g_, _b_U_G__, __Bu_G__)
    else
        return Prefab(_B__u_G["prefab"], _B__u_G_, _b_U_G__, __Bu_G__)
    end
end
local __B_U_g = {}
for _B__U__g, _B_u__G_ in pairs(VINE_DEFS) do
    table["insert"](__B_U_g, __B__U_G__(_B_u__G_))
end
table["insert"](__B_U_g, MakePlacer("shanhaivine_moon_placer", "shanhai_decovine", "shanhai_decovine", "idle_fruit"))
return unpack(__B_U_g)
