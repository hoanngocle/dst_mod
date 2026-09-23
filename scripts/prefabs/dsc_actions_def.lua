local function _b__u_g__(_Bu_G, B_U_g_)
    if _Bu_G["components"]["stackable"] then
        _Bu_G["components"]["stackable"]:Get(B_U_g_):Remove()
    else
        _Bu_G:Remove()
    end
end
local B_Ug = {"log", "cattoy", "molebait", "tool", "weapon"}
local function b_U__G__(B__Ug_, __Bu__g_)
    local _BU_G__, Bu_g_, _BUG_ = B__Ug_["Transform"]:GetWorldPosition()
    local __BU_g_ = TheSim:FindEntities(_BU_G__, Bu_g_, _BUG_, __Bu__g_, nil, {"gravity_fly"}, B_Ug)
    local _b__UG = {}
    for BUG__, _b__Ug in ipairs(__BU_g_) do
        if not _b__Ug["components"]["inventoryitem"] or _b__Ug["components"]["inventoryitem"]["owner"] == nil then
            table["insert"](_b__UG, _b__Ug)
        end
    end
    return _b__UG
end
local __b__u_g__ = "This is impossible!"
local function __buG__(__b__U_g__, _bU__G_, B__uG, __bu_g__, __B_U__G__)
    if __b__U_g__ ~= nil and __b__U_g__["Physics"] ~= nil and __b__U_g__["Physics"]:IsActive() then
        local __BuG_, __Bu_g, BUG = __b__U_g__["Transform"]:GetWorldPosition()
        __b__U_g__:AddTag "gravity_fly"
        if __b__U_g__["components"]["inventoryitem"] then
            __b__U_g__["components"]["inventoryitem"]["canbepickedup"] = (24 * 66 - 220 == 1373)
        end
        if __b__U_g__["components"]["floater"] then
            __b__U_g__:PushEvent "on_no_longer_landed"
        end
        if __b__U_g__["components"]["inspectable"] then
            __b__U_g__["temp_desc"] = __b__U_g__["components"]["inspectable"]["GetDescription"]
            __b__U_g__["components"]["inspectable"]["GetDescription"] = function(self, b_U_G)
                local bu__g = math["random"](#__b__u_g__)
                return __b__u_g__[bu__g]
            end
        end
        __b__U_g__:StartUpdatingComponent(__b__U_g__)
        local function _b__U__g_()
            if __b__U_g__:IsValid() then
                local _B__ug_, _Bu_g__, __B__u_g__ = __b__U_g__["Transform"]:GetWorldPosition()
                local _b_uG__ = _B__ug_ + (_bU__G_["x"] - _B__ug_) * B__uG
                local b_UG__ = _Bu_g__ + (_bU__G_["y"] - _Bu_g__) * B__uG
                local _B_Ug__ = __B__u_g__ + (_bU__G_["z"] - __B__u_g__) * B__uG
                if
                    math["abs"](_b_uG__ - _bU__G_["x"]) < 0.01 and math["abs"](b_UG__ - _bU__G_["y"]) < 0.01 and
                        math["abs"](_B_Ug__ - _bU__G_["z"]) < 0.01
                 then
                    _b_uG__, b_UG__, _B_Ug__ = _bU__G_["x"], _bU__G_["y"], _bU__G_["z"]
                    __b__U_g__:StopUpdatingComponent(__b__U_g__)
                end
                __b__U_g__["Physics"]:Teleport(_b_uG__, b_UG__, _B_Ug__)
            end
        end
        __b__U_g__["task"] = __b__U_g__:DoPeriodicTask(0.05, _b__U__g_)
    end
end
local function bU__G__(__b__u_G)
    local b_u_g_ = math["random"]() * 0.02
    if math["random"](0, 1) == 0 then
        return __b__u_G - b_u_g_
    else
        return __b__u_G + b_u_g_
    end
end
local function __B__U_G(__b_U__g, __B_Ug, __B_Ug__, _B__uG__, buG, _b_U__G_)
    local __B__U_g__ = {}
    local B_Ug_ = math["pi"] / 4
    local buG_ = buG
    for __b__U_g = 1, _B__uG__ do
        local __BU__g_ = buG_ * math["floor"]((__b__U_g - 1) / 8 + 1)
        local B_U_G = (__b__U_g - 1) * B_Ug_
        local _B_U_G_ = __b_U__g + __BU__g_ * math["cos"](B_U_G)
        local _b__u__g__ = __B_Ug__ + __BU__g_ * math["sin"](B_U_G)
        local _BUg__ = __B_Ug + _b_U__G_
        table["insert"](__B__U_g__, {x = _B_U_G_, y = _BUg__, z = _b__u__g__})
    end
    return __B__U_g__
end
local function _b_UG__(b_Ug, __B__UG_, _BU__G__, _b_U_g, __B__Ug__)
    local __b_ug, __b_u_G, B_u__g = b_Ug["Transform"]:GetWorldPosition()
    b_Ug:DoTaskInTime(
        2,
        function()
            local b__u_g = SpawnPrefab "fx_book_moon"
            b__u_g["Transform"]:SetPosition(__b_ug, __b_u_G + 7, B_u__g)
            b__u_g:ListenForEvent("animover", b__u_g["Remove"])
        end
    )
    local b__U_G__ = b_U__G__(b_Ug, __B__UG_)
    local B__u__g = #b__U_G__
    if B__u__g == 0 then
        return
    end
    local _B__U__G_ = {}
    for B__u__G, __b_u__g_ in ipairs(b__U_G__) do
        local bu_g = __b_u__g_["prefab"]
        if _B__U__G_[bu_g] == nil then
            _B__U__G_[bu_g] = {}
        end
        table["insert"](_B__U__G_[bu_g], __b_u__g_)
    end
    local b__u_g_ = 0
    for _b_UG in pairs(_B__U__G_) do
        b__u_g_ = b__u_g_ + 1
    end
    local _b__U__g = __B__U_G(__b_ug, __b_u_G, B_u__g, b__u_g_, 2, _BU__G__)
    local _B__U_g = 1
    for __b_U_G__, b__U_G__ in pairs(_B__U__G_) do
        local bUG__ = _b__U__g[_B__U_g]
        _B__U_g = _B__U_g + 1
        for _B_U__g__, _BUG__ in ipairs(b__U_G__) do
            local B__u_g_ = bU__G__(_b_U_g)
            local Bug = math["random"]()
            __buG__(_BUG__, bUG__, B__u_g_, __B__Ug__, Bug)
        end
    end
    b_Ug:DoTaskInTime(
        10,
        function()
            for _bug_, __BU__G in ipairs(b__U_G__) do
                if __BU__G:IsValid() and __BU__G["Physics"] ~= nil and __BU__G["Physics"]:IsActive() then
                    __BU__G:StopUpdatingComponent(__BU__G)
                    __BU__G["Physics"]:SetVel(0, -__B__Ug__, 0)
                    if __BU__G["task"] then
                        __BU__G["task"]:Cancel()
                    end
                    if __BU__G["components"]["inspectable"] then
                        __BU__G["components"]["inspectable"]["GetDescription"] = __BU__G["temp_desc"]
                    end
                    if __BU__G["components"]["inventoryitem"] then
                        __BU__G["components"]["inventoryitem"]["canbepickedup"] = (31 + 42 - 11 - 445 == -383)
                    end
                    __BU__G:RemoveTag "gravity_fly"
                end
            end
        end
    )
end
local function _b_UG_(_B__UG_)
    local function BU__g(__b_UG_)
        local B_ug = _B__UG_ + __b_UG_
        return TheWorld["Map"]:IsAboveGroundAtPoint(B_ug:Get())
    end
    local BU__g_ = math["random"]() * TWOPI
    local __bu_g_ = math["random"]() * 7
    local _BU__G = FindValidPositionByFan(BU__g_, __bu_g_, 12, BU__g)
    if _BU__G ~= nil then
        return _B__UG_ + _BU__G
    end
end
local function B__u__G__(__b_u_g)
    local b__U__G = __b_u_g:GetPosition()
    local _bu_G_ = _b_UG_(b__U__G)
    local __B_U__g = SpawnPrefab "mutatedwarg"
    __B_U__g["Transform"]:SetPosition(_bu_G_["x"], 20, _bu_G_["z"])
    __B_U__g["sg"]:GoToState "fall"
end
local function _b_U__g(_bUG_)
    local __B__uG__, b__u_g__, _b__U__g__ = _bUG_["Transform"]:GetWorldPosition()
    local b__uG_ = 12
    local _bU_G_ = TheSim:FindEntities(__B__uG__, b__u_g__, _b__U__g__, b__uG_, {"statue_eatmoon"})[1]
    if _bU_G_ ~= nil then
        if not _bU_G_:HasTag "breakeating" and _bU_G_:HasTag "is_eating" then
            _bU_G_:PushEvent "breakeating"
            B__u__G__(_bUG_)
            return
        end
    end
    local __Bu_g__ = TheWorld["state"]
    if
        __Bu_g__["isspring"] and __Bu_g__["israining"] and
            __Bu_g__["precipitationrate"] > TUNING["FROG_RAIN_PRECIPITATION"] and
            __Bu_g__["moistureceil"] > TUNING["FROG_RAIN_MOISTURE"]
     then
        local _Bug__ = TheWorld["components"]["frograin"]
        _Bug__:SetSpawnTimes({min = 0.1, max = 2})
    else
        local B_u__g__ = SpawnPrefab "shadowmeteor"
        B_u__g__:SetSize("large", 2)
        B_u__g__["Transform"]:SetPosition(__B__uG__, b__u_g__, _b__U__g__)
    end
end
local function __b_U__G_(_b__u__g)
    if not _b__u__g["components"]["inventoryitem"]["canbepickedup"] then
        _b__u__g["components"]["inventoryitem"]["canbepickedup"] = (140 - 351 * 362 == -126922)
    end
    MakeInventoryPhysics(_b__u__g)
    _b__u__g:RemoveEventCallback("animover", __b_U__G_)
    local __bu__g__ = SpawnPrefab "sand_puff"
    local _bu_G__ = __bu__g__["Transform"] and __bu__g__["Transform"]:GetScale()
    local __bu__G_ = _bu_G__ * 1.5
    __bu__g__["Transform"]:SetScale(__bu__G_, __bu__G_, __bu__G_)
    __bu__g__["Transform"]:SetPosition(_b__u__g["Transform"]:GetWorldPosition())
    _b__u__g["AnimState"]:PlayAnimation "idle"
end
local function __B_u__g_(Bu__G)
    Bu__G["components"]["teleporter"]["targetTeleporter"]["components"]["teleporter"]:SetEnabled(
        (425 - 59 * 266 + 400 ~= -14869)
    )
    Bu__G["components"]["teleporter"]["targetTeleporter"]:PushEvent "cannot_tel"
    Bu__G["components"]["teleporter"]:SetEnabled((437 + 355 * 406 - 460 == 144110))
    Bu__G:RemoveTag "structure"
    Bu__G["is_deployed"] = (271 + 52 * 462 - 336 * 245 ~= -58025)
    Bu__G["AnimState"]:PlayAnimation "activate"
    Bu__G["SoundEmitter"]:PlaySound "grotto/common/archive_switch/on"
    Bu__G:ListenForEvent("animover", __b_U__G_)
end
local __B_ug__ = {
    {
        id = "SEALDEEPSEACAVE",
        str = "Niêm Phong",
        fn = function(bu_G)
            if
                bu_G["doer"] ~= nil and bu_G["invobject"] ~= nil and bu_G["invobject"]["prefab"] == "deepseacave_seal" and
                    bu_G["target"]["prefab"] == "deepseacave" and
                    bu_G["target"]["AnimState"]:IsCurrentAnimation "idle_deploy"
             then
                bu_G["target"]["SoundEmitter"]:PlaySound "dontstarve/common/telebase_gemplace"
                bu_G["doer"]["components"]["talker"]:Say "Niêm phong thành công!"
                __B_u__g_(bu_G["target"])
                _b__u_g__(bu_G["invobject"])
                return (1 * 133 + 456 * 453 * 63 ~= 13013923)
            end
        end,
        state = "give",
        actiondata = {mount_valid = (152 * 36 + 141 == 5613)}
    },
}
local __B__Ug_ = {
    {
        type = "USEITEM",
        component = "inventoryitem",
        tests = {
            {
                action = "SEALDEEPSEACAVE",
                testfn = function(b__UG__, __b_u_G_, __b_uG__, __B_ug__, BuG_)
                    return __b_u_G_:HasTag "player" and b__UG__["prefab"] == "deepseacave_seal" and
                        __b_uG__["prefab"] == "deepseacave" and
                        __b_uG__["AnimState"]:IsCurrentAnimation "idle_deploy"
                end
            },
    }
}
}
local B__u__g__ = ACTIONS["TELEPORT"]["fn"]
local _b_Ug = {{switch = (409 - 264 - 163 ~= -11), id = "TELEPORT", actiondata = {fn = function(__b__U_G__)
                if __b__U_G__["doer"] ~= nil and __b__U_G__["doer"]["sg"] ~= nil then
                    local B__ug
                    if __b__U_G__["invobject"] ~= nil then
                        if __b__U_G__["doer"]["sg"]["currentstate"]["name"] == "dolongaction" then
                            B__ug = __b__U_G__["invobject"]
                        end
                    elseif __b__U_G__["target"] ~= nil and __b__U_G__["doer"]["sg"]["currentstate"]["name"] == "give" then
                        B__ug = __b__U_G__["target"]
                    end
                    if B__ug ~= nil and B__ug["components"]["teleporter"] then
                        local __b__U_G_ = B__ug["components"]["teleporter"]["targetTeleporter"]
                        if __b__U_G_ ~= nil and __b__U_G_:IsValid() then
                            return B__u__g__(__b__U_G__)
                        else
                            return (453 + 279 - 406 * 101 == -40265)
                        end
                    end
                end
                return B__u__g__(__b__U_G__)
            end}}}
return {actions = __B_ug__, component_actions = __B__Ug_, old_actions = _b_Ug}
