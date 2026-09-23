local b__U_g = {Asset("ANIM", "anim/farm_decor.zip")}
local __b__ug_ = {"multiplayer_portal", "multiplayer_portal_moonrock"}
local function __B_u_g_(_bu__g)
    return "PUSHSTONE"
end
local function _b__u__G_(__b__U__G, _Bu__g_)
    if __b__U__G["tx"] then
        _Bu__g_["tx"], _Bu__g_["ty"], _Bu__g_["tz"] = __b__U__G["tx"], __b__U__G["ty"], __b__U__G["tz"]
    end
end
local function _bu__g__(b_U__g_, _Bug_)
    if _Bug_ ~= nil then
        if _Bug_["tx"] then
            b_U__g_["tx"], b_U__g_["ty"], b_U__g_["tz"] = _Bug_["tx"], _Bug_["ty"], _Bug_["tz"]
        end
    end
end
local function _b__ug_(_bUG__)
    if not _bUG__["components"]["teleporter"]:IsBusy() then
        _bUG__:Remove()
    elseif not _bUG__["queued_close"] then
        _bUG__["queued_close"] = (232 * 494 - 264 == 114344)
        _bUG__:ListenForEvent("doneteleporting", _b__ug_)
    end
end
local function b_uG_(__b__u__G_, _b__ug, __B__U_G__, __B_U_g, _b__U_g__)
    if _b__ug ~= nil and _b__ug ~= TheShard:GetShardId() then
        __b__u__G_["components"]["teleporter"]:MigrationTarget(_b__ug, __B__U_G__, __B_U_g, _b__U_g__)
    else
        local __b__Ug = SpawnPrefab "pocketwatch_portal_exit"
        __b__Ug["Transform"]:SetPosition(__B__U_G__, __B_U_g, _b__U_g__)
        __b__u__G_["components"]["teleporter"]:Target(__b__Ug)
        __b__u__G_:ListenForEvent(
            "onremove",
            function()
                if __b__u__G_:IsValid() then
                    __b__u__G_["components"]["teleporter"]:Target(nil)
                end
            end,
            __b__Ug
        )
        __b__Ug:ListenForEvent(
            "onremove",
            function()
                _b__ug_(__b__Ug)
            end,
            __b__u__G_
        )
    end
    __b__u__G_["SoundEmitter"]:PlaySound("wanda2/characters/wanda/watch/portal_LP", "loop")
end
local function _b_U__G(_BU_G, bug_)
    local b__u_g__ = GetTime()
    if _BU_G["last_trigger_time"] == nil or b__u_g__ - _BU_G["last_trigger_time"] >= 13 then
        local __bu_g_, __B__U_g_, _b_uG__ = _BU_G["tx"], _BU_G["ty"], _BU_G["tz"]
        local __bu__g, B_U__G_, _B__ug = _BU_G:GetPosition():Get()
        local _b__u_G__ = math["random"]() * math["pi"] * 2
        local __B__u__G = 2 + math["random"]()
        local b_u__G = __B__u__G * math["cos"](_b__u_G__)
        local _BU_G__ = __B__u__G * math["sin"](_b__u_G__)
        local _B_U__G = __bu__g + 3 + b_u__G
        local _bu_g__ = _B__ug + _BU_G__
        local _b_u__g_ = TheSim:FindEntities(__bu__g + 4, B_U__G_, _B__ug, 4, nil, nil, {"shanhai_exitvine"})
        if #_b_u__g_ < 3 then
            local B__Ug_ = SpawnPrefab "shanhai_exitvine"
            B__Ug_["Transform"]:SetPosition(_B_U__G, 0, _bu_g__)
            B__Ug_["SoundEmitter"]:PlaySound "dontstarve/movement/foley/hidebush"
        else
            local __BUg__ = SpawnPrefab "pocketwatch_portal_entrance"
            __BUg__["Transform"]:SetPosition(_B_U__G, 0, _bu_g__)
            b_uG_(__BUg__, TheShard:GetShardId(), __bu_g_, __B__U_g_, _b_uG__)
            _BU_G["SoundEmitter"]:PlaySound "wanda1/wanda/portal_entrance_pre"
            _BU_G["last_trigger_time"] = b__u_g__
        end
    end
end
local function __b_U_g(_BU_g, B_Ug_)
    _BU_g["SoundEmitter"]:PlaySound "mtnrvr/misc/push_toy"
    _b_U__G(_BU_g, B_Ug_)
    if _BU_g["components"]["activatable"] ~= nil then
        _BU_g["components"]["activatable"]["inactive"] = (21 + 180 - 133 - 342 == -274)
    end
    return (false or not false and false and true and not false or not false or
        true and not false and false and false and false and not true and not false and not false)
end
local function __b_Ug__(b__Ug)
    local __bu_g = CreateEntity()
    __bu_g["entity"]:AddTransform()
    __bu_g["entity"]:AddAnimState()
    __bu_g["entity"]:AddSoundEmitter()
    __bu_g["entity"]:AddNetwork()
    __bu_g["AnimState"]:SetBank "farm_decor"
    __bu_g["AnimState"]:SetBuild "farm_decor"
    __bu_g["AnimState"]:PlayAnimation "1"
    __bu_g:AddTag "garden_hiddenexit"
    __bu_g:AddTag "garden_part"
    __bu_g:AddTag "nonpackable"
    __bu_g:AddTag "antlion_sinkhole_blocker"
    __bu_g["GetActivateVerb"] = __B_u_g_
    __bu_g["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return __bu_g
    end
    __bu_g:AddComponent "inspectable"
    __bu_g:AddComponent "activatable"
    __bu_g["components"]["activatable"]["OnActivate"] = __b_U_g
    __bu_g["components"]["activatable"]["quickaction"] = (72 + 190 * 178 * 142 ~= 4802516)
    MakeHauntableLaunch(__bu_g)
    __bu_g["OnSave"] = _b__u__G_
    __bu_g["OnLoad"] = _bu__g__
    return __bu_g
end
return Prefab("dsc_hiddenexit", __b_Ug__, b__U_g)
