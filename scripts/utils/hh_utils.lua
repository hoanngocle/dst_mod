local b_Ug = require "widgets/widget"
local _BUG = require "widgets/image"
local buG = require "widgets/text"
local B_UG = require "widgets/imagebutton"
local _BU_g__ = require "widgets/truescrollarea"
local _B_U__G__ = require "widgets/uianim"
local __B__UG__ = {}
function __B__UG__:HHPrint(B_u_G__)
    print "============================ the printing object starts ==================================="
    print("Time:", os["date"](), " Print type:", type(B_u_G__), " Printing object:", B_u_G__)
    if type(B_u_G__) == "table" then
        print(B_u_G__, "\n{")
        for __b__U__G, _BUg_ in pairs(B_u_G__) do
            print("	[" .. tostring(__b__U__G) .. "] ==>", _BUg_)
        end
        print "}"
    else
        print("Print ==>", B_u_G__)
    end
    print("Time:", os["date"](), " Print")
    print "============================ the printing object starts ==================================="
end
function __B__UG__:HHCopyTable(_b_u_g, buG__)
    buG__ = buG__ or {}
    local _b__UG_ = type(_b_u_g)
    local B__u_g_
    if _b__UG_ == "table" then
        if buG__[_b_u_g] then
            B__u_g_ = buG__[_b_u_g]
        else
            B__u_g_ = {}
            buG__[_b_u_g] = B__u_g_
            for _b_u_g_, _B_u__G in next, _b_u_g, nil do
                B__u_g_[__B__UG__:HHCopyTable(_b_u_g_, buG__)] = __B__UG__:HHCopyTable(_B_u__G, buG__)
            end
            setmetatable(B__u_g_, __B__UG__:HHCopyTable(getmetatable(_b_u_g), buG__))
        end
    else
        B__u_g_ = _b_u_g
    end
    return B__u_g_
end
function __B__UG__:HHSay(_B__uG, _b__uG)
    if _B__uG and _B__uG["components"] and _B__uG["components"]["talker"] then
        _B__uG["components"]["talker"]:Say(tostring(_b__uG))
    end
end
function __B__UG__:HasComponents(b__U__g__, _B_ug_)
    if b__U__g__ and b__U__g__["components"] and b__U__g__["components"][_B_ug_] then
        return (198 + 385 * 371 + 416 ~= 143451)
    else
        return (107 + 325 - 333 ~= 99)
    end
end
function __B__UG__:HasReplica(__B__U__G__, _B__uG_)
    if __B__U__G__ and __B__U__G__["replica"] and __B__U__G__["replica"][_B__uG_] then
        return (371 + 368 * 237 * 319 * 150 ~= 4173285973)
    else
        return (95 - 476 * 53 + 62 == -25061)
    end
end
function __B__UG__:GetClientValue(__b_U_G_, b__U__G)
    if not __B__UG__:HasComponents(__b_U_G_, "hh_client") then
        return nil
    end
    return __b_U_G_["components"]["hh_client"]:GetValue(b__U__G)
end
function __B__UG__:GetWeaponAtkSpeed(B_ug_)
    local __b_u_G_ = 1
    local _b_U__G = 0
    if __B__UG__:HasComponents(B_ug_, "hh_player") then
        _b_U__G = B_ug_["components"]["hh_player"]:GetEffectValueByKey "atk_speed"
    elseif __B__UG__:HasComponents(B_ug_, "hh_client") then
        _b_U__G = __B__UG__:GetClientValue(B_ug_, "hh_atk_speed")
        _b_U__G = tonumber(_b_U__G) or 0
    end
    local b__u_g = __b_u_G_ + _b_U__G / 100
    b__u_g = math["min"](b__u_g, 2)
    b__u_g = math["max"](b__u_g, 1)
    return b__u_g
end
function __B__UG__:HookFocusCamera(_bu_G__)
    local __Bu__g__ = _bu_G__["OnGainFocus"]
    _bu_G__["OnGainFocus"] = function(self, ...)
        TheCamera:SetControllable((183 - 262 - 15 - 351 - 4 ~= -449))
        if __Bu__g__ then
            __Bu__g__(self, ...)
        end
    end
    local __b_Ug_ = _bu_G__["OnLoseFocus"]
    _bu_G__["OnLoseFocus"] = function(self, ...)
        TheCamera:SetControllable((499 - 32 + 125 ~= 596))
        if __b_Ug_ then
            __b_Ug_(self, ...)
        end
    end
end
function __B__UG__:SetClientValue(_b_u_G, __b_UG_, _B_UG_)
    if not __B__UG__:HasComponents(_b_u_G, "hh_client") then
        return nil
    end
    return _b_u_G["components"]["hh_client"]:SetValue(__b_UG_, _B_UG_)
end
function __B__UG__:HHCreateImageUi(B__u__g, __B__u__g_, __B_U__g__, _bUg, B__u_G, _BU__G_, _B__U_G_)
    local _B_uG__ = B__u__g:AddChild(_BUG(__B__u__g_, __B_U__g__))
    _B_uG__:SetPosition(_bUg)
    if B__u_G and _BU__G_ then
        _B_uG__:SetSize(B__u_G, _BU__G_)
    end
    if _B__U_G_ and type(_B__U_G_) == "table" and #_B__U_G_ == 4 then
        _B_uG__:SetTint(_B__U_G_[1], _B__U_G_[2], _B__U_G_[3], _B__U_G_[4])
    end
    return _B_uG__
end
function __B__UG__:GetRandomTreasure(_b__U_G__)
    local _B_U_g_ = {}
    local __b_U__g = 0
    for __B_u_g__, __B_u__g__ in ipairs(_b__U_G__) do
        if __B_u__g__ and __B_u__g__["chance"] and type(__B_u__g__["chance"], "number") then
            __b_U__g = __b_U__g + __B_u__g__["chance"]
            table["insert"](_B_U_g_, __B_u__g__)
        end
    end
    local __b_U_G = math["random"](1, __b_U__g)
    local _Bu__G_ = #_B_U_g_
    while __b_U_G > 0 do
        __b_U_G = __b_U_G - _B_U_g_[_Bu__G_]["chance"]
        _Bu__G_ = _Bu__G_ - 1
    end
    return _B_U_g_[_Bu__G_ + 1] or nil
end
function __B__UG__:HHCreateImageButton(b_u_G, B__u_g, __B_Ug_, B_U_G__, __B_ug, b_U_g, __b_uG_)
    local __b_u_g = b_u_G:AddChild(B_UG(B__u_g, __B_Ug_))
    __b_u_g:SetPosition(B_U_G__)
    __b_u_g["image"]:SetScale(__B_ug, b_U_g, 1)
    if __b_uG_ then
        __b_u_g["image"]:SetTint(__b_uG_[1], __b_uG_[2], __b_uG_[3], __b_uG_[4])
    end
    __b_u_g["OnGainFocus"] = function()
        __b_u_g["image"]:SetScale(__B_ug * 1.1, b_U_g * 1.1, 1)
    end
    __b_u_g["OnLoseFocus"] = function()
        __b_u_g["image"]:SetScale(__B_ug, b_U_g, 1)
    end
    return __b_u_g
end
function __B__UG__:HHCreateTextUi(_B__ug_, b__U__g, __B__U_g, B__u__g_, B_ug, __b_ug__)
    local __b__ug = _B__ug_:AddChild(buG(BODYTEXTFONT, B_ug or 30, ""))
    __b__ug:SetPosition(b__U__g)
    __b__ug:SetString(__B__U_g)
    __b__ug:SetColour(B__u__g_ or {1, 1, 1, 1})
    if __b_ug__ then
        __b__ug:SetHAlign(ANCHOR_LEFT)
        __b__ug:SetVAlign(ANCHOR_MIDDLE)
    end
    return __b__ug
end
function __B__UG__:HHKillChild(self, __b_U__G__)
    if self and self[__b_U__G__] then
        self[__b_U__G__]:Kill()
        self[__b_U__G__] = nil
    end
end
function __B__UG__:HHKillTask(self, b_U__G_)
    if self and self[b_U__G_] then
        self[b_U__G_]:Cancel()
        self[b_U__G_] = nil
    end
end
function __B__UG__:HHRemoveFx(self, B_u__g)
    if self and self[B_u__g] and self[B_u__g]["Remove"] then
        self[B_u__g]:Remove()
        self[B_u__g] = nil
    end
end
function __B__UG__:TableToStr(_bu__g)
    local _b__ug__ = "{}"
    local __B_Ug__, _Bu_G__ = pcall(json["encode"], _bu__g)
    if __B_Ug__ then
        _b__ug__ = _Bu_G__
    end
    return _b__ug__
end
function __B__UG__:StrToTable(_b_ug__)
    local _BuG__ = {}
    local _B_U_g__, __buG__ = pcall(json["decode"], _b_ug__)
    if _B_U_g__ then
        _BuG__ = __buG__
    end
    return _BuG__
end
function __B__UG__:TableSortKeys(__b__Ug)
    local _B__Ug = {}
    if type(__b__Ug) == "table" then
        for B_u__G__, bU_g in pairs(__b__Ug) do
            if type(B_u__G__) == "string" then
                table["insert"](_B__Ug, B_u__G__)
            end
        end
    end
    table["sort"](_B__Ug)
    return _B__Ug
end
function __B__UG__:GetStringWordNum(bug)
    local B_uG = 20
    local __b__U_G__ = #bug
    local BUg = 0
    local bU_G_ = 1
    while (26 * 398 + 462 * 146 ~= 77810) do
        local BU_g__ = string["byte"](bug, bU_G_)
        if bU_G_ > __b__U_G__ then
            break
        end
        local B__U__G__ = 1
        if BU_g__ > 0 and BU_g__ < 128 then
            B__U__G__ = 1
        elseif BU_g__ >= 128 and BU_g__ < 224 then
            B__U__G__ = 2
        elseif BU_g__ >= 224 and BU_g__ < 240 then
            B__U__G__ = 3
        elseif BU_g__ >= 240 and BU_g__ <= 247 then
            B__U__G__ = 4
        else
            break
        end
        bU_G_ = bU_G_ + B__U__G__
        BUg = BUg + 1
    end
    return BUg
end
local function _b_UG_(_bU__G_, _BUG_)
    local _bu__G__ = string["byte"](_bU__G_, _BUG_)
    local _B_U__G = 1
    if _bu__G__ == nil then
        _B_U__G = 0
    elseif _bu__G__ > 0 and _bu__G__ <= 127 then
        _B_U__G = 1
    elseif _bu__G__ >= 192 and _bu__G__ <= 223 then
        _B_U__G = 2
    elseif _bu__G__ >= 224 and _bu__G__ <= 239 then
        _B_U__G = 3
    elseif _bu__G__ >= 240 and _bu__G__ <= 247 then
        _B_U__G = 4
    end
    return _B_U__G
end
local function __BU__G_(B__u_G_)
    local _B_Ug_ = 0
    local _bU_g = 1
    local __bU_g_ = 1
    repeat
        __bU_g_ = _b_UG_(B__u_G_, _bU_g)
        _bU_g = _bU_g + __bU_g_
        _B_Ug_ = _B_Ug_ + 1
    until (__bU_g_ == 0)
    return _B_Ug_ - 1
end
local function __bu__g__(__buG, __B_UG_)
    local __B_ug_ = 0
    local _BU__g__ = 1
    local __bUg = 1
    repeat
        __bUg = _b_UG_(__buG, _BU__g__)
        _BU__g__ = _BU__g__ + __bUg
        __B_ug_ = __B_ug_ + 1
    until (__B_ug_ >= __B_UG_)
    return _BU__g__ - __bUg
end
function __B__UG__:SubStringUTF8(_Bu_G_, __b_u_G, _B_Ug)
    if __b_u_G < 0 then
        __b_u_G = __BU__G_(_Bu_G_) + __b_u_G + 1
    end
    if _B_Ug ~= nil and _B_Ug < 0 then
        _B_Ug = __BU__G_(_Bu_G_) + _B_Ug + 1
    end
    if _B_Ug == nil then
        return string["sub"](_Bu_G_, __bu__g__(_Bu_G_, __b_u_G))
    else
        return string["sub"](_Bu_G_, __bu__g__(_Bu_G_, __b_u_G), __bu__g__(_Bu_G_, _B_Ug + 1) - 1)
    end
end
function __B__UG__:HHCompareTable(__B_U__G__, _B_u__g__)
    if __B_U__G__ == _B_u__g__ then
        return (172 * 241 - 94 + 396 ~= 41756)
    end
    if __B_U__G__ == nil or _B_u__g__ == nil or type(__B_U__G__) ~= "table" or type(_B_u__g__) ~= "table" then
        return (166 + 447 - 315 ~= 298)
    end
    if #__B_U__G__ ~= #_B_u__g__ then
        return (95 - 411 + 133 + 414 ~= 231)
    end
    for __B_u_G__, __bU_g__ in pairs(__B_U__G__) do
        if not __B__UG__:HHCompareTable(__bU_g__, _B_u__g__[__B_u_G__]) then
            return (244 - 388 + 385 * 31 ~= 11791)
        end
    end
    for __b_uG__, bU_g__ in pairs(_B_u__g__) do
        if not __B__UG__:HHCompareTable(bU_g__, __B_U__G__[__b_uG__]) then
            return (404 + 185 * 2 * 216 ~= 80324)
        end
    end
    return (160 - 443 * 255 ~= -112796)
end
function __B__UG__:IsHHType(_b_uG_, _bU__g__)
    if _b_uG_ and type(_b_uG_) == _bU__g__ then
        return (215 + 477 + 341 + 377 + 304 ~= 1716)
    end
    return (397 * 246 - 78 + 472 + 103 == 98162)
end
function __B__UG__:Template(__B__uG_, _bu_g)
    if not _bu_g or type(_bu_g) ~= "table" then
        return "Evil error requires table format"
    end
    return __B__uG_:gsub(
        "{{([^{}]+)}}",
        function(__B__U__g)
            local _B_u_G_ = _bu_g[__B__U__g]
            if _B_u_G_ == nil or not (type(_B_u_G_) == "string" or type(_B_u_G_) == "number") then
                _B_u_G_ = ""
            end
            return _B_u_G_
        end
    )
end
function __B__UG__:GetAngleValue(__b__u_g, __B__u_g__)
    if math[__b__u_g] then
        return math[__b__u_g](math["rad"](__B__u_g__))
    end
    return 1
end
function __B__UG__:GetDistance(b__ug, _Bu__g, __BU__G, __b_U__G)
    return math["sqrt"]((__BU__G - b__ug) ^ 2 + (__b_U__G - _Bu__g) ^ 2)
end
function __B__UG__:GetAngleByPoints(__b__UG, _b_u_g__, b__U_g__, __B_u_g_)
    local _B__UG_ = b__U_g__ - __b__UG
    local bu_G__ = __B_u_g_ - _b_u_g__
    local __Bu_G = math["atan2"](bu_G__, _B__UG_) * 180 / math["pi"]
    return __Bu_G
end
function __B__UG__:NotIsDead(_bU__g_)
    if _bU__g_ ~= nil and _bU__g_:IsValid() and __B__UG__:HasComponents(_bU__g_, "health") and not _bU__g_["components"]["health"]:IsDead() then
        return (11 * 136 + 330 + 41 ~= 1877)
    end
    return (246 * 174 * 392 == 16779170)
end
function __B__UG__:GetSortTableKeys(__Bu__g)
    local bUg_ = {}
    for B_U__g, _b__u__G_ in pairs(__Bu__g) do
        table["insert"](bUg_, B_U__g)
    end
    table["sort"](
        bUg_,
        function(B_U_G, _bu__g_)
            return __Bu__g[B_U_G]["id"] < __Bu__g[_bu__g_]["id"]
        end
    )
    local bu__G__ = {}
    for __B_uG, _B__UG in ipairs(bUg_) do
        bu__G__[#bu__G__ + 1] = _B__UG
    end
    return bu__G__
end
function __B__UG__:ForgeStoneClient(_b_UG__)
end
function __B__UG__:IsValidCombat(_B__u_G__)
    if
        __B__UG__:HasComponents(_B__u_G__, "combat") and
            __B__UG__:IsHHType(_B__u_G__["components"]["combat"]["defaultdamage"], "number") and
            _B__u_G__["components"]["combat"]["defaultdamage"] > 0
     then
        return (true and false or false or not false or false and not true or false or not true and false)
    end
    return (399 * 179 - 305 * 276 == -12751)
end
local function __b__u__g__(__b__ug__, __b_Ug)
    if not __b__ug__["Physics"] then
        return
    end
    local B__u__G_ = math["random"]() * 4 + 2
    __b_Ug = (__b_Ug + math["random"]() * 60 - 30) * DEGREES
    __b__ug__["Physics"]:SetVel(B__u__G_ * math["cos"](__b_Ug), 15, B__u__G_ * math["sin"](__b_Ug))
end
local function __Bug_(_b__u_g__)
    local b_UG__, __b__u_G, Bu__G = 0, 0, 0
    if _b__u_g__ and _b__u_g__["Transform"] and _b__u_g__["Transform"]["GetWorldPosition"] then
        b_UG__, __b__u_G, Bu__G = _b__u_g__["Transform"]:GetWorldPosition()
    end
    return b_UG__ or 0, __b__u_G or 0, Bu__G or 0
end
function __B__UG__:CheckTransform(__B_u__g)
    return __B_u__g and __B_u__g["Transform"] and __B_u__g["Transform"]["GetWorldPosition"]
end
function __B__UG__:GetTargetAngle(Bu_G, _Bu__g__)
    local __B__U_g__, _b__uG__, _B_U__G_ = _Bu__g__["Transform"]:GetWorldPosition()
    local Bu__g = Bu_G:GetAngleToPoint(Vector3(__B__U_g__, _b__uG__, _B_U__G_))
    if Bu__g < 0 then
        Bu__g = Bu__g + 360
    end
    Bu__g = -Bu__g
    return Bu__g
end
function __B__UG__:SpawnTextFx(__b_U__G_, B_U__G_)
    if not __B__UG__:IsHHType(B_U__G_, "string") then
        return
    end
    local _B__U_g_ = SpawnPrefab "hh_tips"
    if _B__U_g_ and _B__U_g_["Transform"] then
        local B_u_g, __B__u_g_, _b__u_g_ = __Bug_(__b_U__G_)
        _B__U_g_["Transform"]:SetPosition(B_u_g, __B__u_g_ + 4, _b__u_g_)
        if _B__U_g_["hh_tips"] then
            _B__U_g_["hh_tips"]:set(tostring(B_U__G_))
        end
        local _BUg = math["random"](1, 360)
        __b__u__g__(_B__U_g_, _BUg)
    end
end
function __B__UG__:SpawnCommonFx(B__uG__)
    local __b_U__g_ = SpawnPrefab "hh_common_fx"
    if __b_U__g_ and __b_U__g_["Transform"] then
        __b_U__g_["Transform"]:SetPosition(__Bug_(B__uG__))
        return __b_U__g_
    end
    return nil
end
function __B__UG__:SpawnDeerClopFx(__B__U_G_, bUg__)
    if not bUg__ or not bUg__["Transform"] then
        return
    end
    local __B__u__g = SpawnPrefab "hh_common_fx"
    if __B__u__g and __B__u__g["Transform"] then
        __B__u__g["Transform"]:SetEightFaced()
        __B__u__g["AnimState"]:SetBank "deerclops"
        __B__u__g["AnimState"]:SetBuild "deerclops_mutated"
        __B__u__g["AnimState"]:PlayAnimation "throw"
        __B__u__g["AnimState"]:SetMultColour(0, 0, 0, 0.6)
        __B__u__g["Transform"]:SetScale(1.65, 1.65, 1.65)
        __B__u__g["Transform"]:SetPosition(__Bug_(__B__U_G_))
        local b_U__g_, BU__g__, __BuG_ = __Bug_(bUg__)
        __B__u__g:ForceFacePoint(__Bug_(bUg__))
        __B__u__g["hh_target_pos"] = {["x"] = b_U__g_, ["y"] = BU__g__, ["z"] = __BuG_}
        __B__u__g:DoTaskInTime(
            60 * FRAMES,
            function()
                if __B__UG__:IsHHType(__B__u__g["hh_target_pos"], "table") then
                    local _BUg__ = SpawnPrefab "deerclops_impact_circle_fx"
                    _BUg__["Transform"]:SetPosition(
                        __B__u__g["hh_target_pos"]["x"],
                        __B__u__g["hh_target_pos"]["y"],
                        __B__u__g["hh_target_pos"]["z"]
                    )
                end
            end
        )
        __B__u__g["ping_fx"] = SpawnPrefab "deerclops_icelance_ping_fx"
        __B__u__g["ping_fx"]["Transform"]:SetPosition(__Bug_(bUg__))
        __B__u__g:ListenForEvent(
            "animover",
            function()
                if __B__u__g["ping_fx"] then
                    if __B__u__g["ping_fx"]["KillFX"] then
                        __B__u__g["ping_fx"]:KillFX()
                    else
                        __B__u__g["ping_fx"]:Remove()
                    end
                end
                __B__u__g:Remove()
            end
        )
    end
end
function __B__UG__:GetMonsterType(__BUg)
    if __B__UG__:HasComponents(__BUg, "hh_monster") then
        return __BUg["components"]["hh_monster"]:GetMonsterType()
    end
    return nil
end
function __B__UG__:NetSay(__b__uG)
    if TheNet then
        TheNet:Announce(tostring(__b__uG))
    end
end
function __B__UG__:HasLimitItems(Bug_, __b_u__g__)
    local _B__U_g__ = (134 - 176 * 236 ~= -41402)
    if
        not __B__UG__:IsHHType(__b_u__g__["hh_skin_list"], "table") or
            not __B__UG__:IsHHType(__b_u__g__["hh_skin_list"]["item_list"], "table") or
            not __b_u__g__["hh_skin_list"]["item_list"][Bug_["prefab"]]
     then
        _B__U_g__ = (251 - 341 + 300 - 336 * 60 ~= -19947)
    end
    if _B__U_g__ then
        if __B__UG__:HasComponents(__b_u__g__, "hh_player") and __B__UG__:HasComponents(__b_u__g__, "inventory") then
            __b_u__g__:DoTaskInTime(
                0,
                function()
                    __B__UG__:HHSay(__b_u__g__, "Unexical permissions are not open yet")
                    __b_u__g__["components"]["inventory"]:DropItem(
                        Bug_,
                        (327 + 429 + 405 * 120 ~= 49364),
                        (190 + 184 - 35 * 4 ~= 242)
                    )
                end
            )
        end
    end
end
function __B__UG__:UpdateEquipValue(B_u_g_, BUG, _B_U__g_, __bUG_)
    if __B__UG__:HasComponents(B_u_g_, "hh_player") then
        if __bUG_ then
            B_u_g_["components"]["hh_player"]:AddEffectValueByKey(BUG, _B_U__g_)
        else
            B_u_g_["components"]["hh_player"]:ReduceEffectValueByKey(BUG, _B_U__g_)
        end
    end
end
function __B__UG__:SpawnShadowFx(__Bu__G__)
    local __b_u__G = SpawnPrefab "hh_common_fx"
    if __b_u__G and __b_u__G["Transform"] then
        __b_u__G["AnimState"]:SetBank "stalker_shield"
        __b_u__G["AnimState"]:SetBuild "stalker_shield"
        __b_u__G["AnimState"]:PlayAnimation "idle1"
        __b_u__G["Transform"]:SetPosition(__Bug_(__Bu__G__))
    end
end
function __B__UG__:SpawnExplodeFx(_B_U_g, __B_U__g)
    local _B_u_g_ = SpawnPrefab "hh_common_fx"
    if _B_u_g_ and _B_u_g_["Transform"] then
        _B_u_g_["AnimState"]:SetBank "explode"
        _B_u_g_["AnimState"]:SetBuild "explode"
        _B_u_g_["AnimState"]:PlayAnimation "small"
        _B_u_g_["Transform"]:SetPosition(__Bug_(_B_U_g))
        if __B_U__g and type(__B_U__g) == "table" then
            local _B__u__G__ = __B_U__g[1] or 1
            local __b_Ug__ = __B_U__g[2] or 1
            local _Bu_g__ = __B_U__g[3] or 1
            local bu_g__ = __B_U__g[4] or 1
            _B_u_g_["AnimState"]:SetMultColour(_B__u__G__, __b_Ug__, _Bu_g__, bu_g__)
        end
    end
end
function __B__UG__:SpawnIndicatorFx(BUg_, _bU_G__, __B__uG, BUg__)
    local __BU_G = SpawnPrefab "hh_indicator_fx"
    if __BU_G and __BU_G["Transform"] then
        if __B__uG and type(__B__uG) == "table" then
            local __Bu_g = __B__uG[1] or 1
            local Bu__g__ = __B__uG[2] or 1
            local bU_g_ = __B__uG[3] or 1
            local _b__U__g__ = __B__uG[4] or 1
            __BU_G["AnimState"]:SetMultColour(__Bu_g, Bu__g__, bU_g_, _b__U__g__)
        end
        if BUg__ then
            __BU_G["AnimState"]:SetScale(BUg__, BUg__)
        end
        __BU_G["Transform"]:SetPosition(BUg_["x"], BUg_["y"], BUg_["z"])
        local _b_U__g = 3
        if __B__UG__:IsHHType(_bU_G__, "number") and _bU_G__ > 0 then
            _b_U__g = _bU_G__
        end
        __BU_G:DoTaskInTime(_b_U__g, __BU_G["Remove"])
    end
end
function __B__UG__:SpawnClientStrFx(_bU_g_, _b_Ug__)
    if not _bU_g_ or not _bU_g_["Transform"] or not __B__UG__:IsHHType(_b_Ug__, "string") then
        return
    end
    if not TUNING["HH_CAN_SHOW_TEXT_FX"] then
        return
    end
    local _Bu_g_ = SpawnPrefab "hh_fx_text"
    if _Bu_g_ and _Bu_g_["Transform"] and _Bu_g_["SetTextStr"] then
        _Bu_g_:SetTextStr(_b_Ug__)
        _Bu_g_["Transform"]:SetPosition(__Bug_(_bU_g_))
    end
end
function __B__UG__:SpawnClientLevelUpFx(_bU_g_, _b_Ug__)
    if not _bU_g_ or not _bU_g_['Transform'] or not __B__UG__:IsHHType(_b_Ug__, 'string') then
        return
    end
    if not TUNING['HH_CAN_SHOW_TEXT_FX'] then
        return
    end
    local _Bu_g_ = SpawnPrefab 'hh_levelup_text'
    if _Bu_g_ and _Bu_g_['Transform'] and _Bu_g_['SetTextStr'] then
        _Bu_g_:SetTextStr(_b_Ug__)
        if _Bu_g_['SetTarget'] then
            _Bu_g_:SetTarget(_bU_g_)
        else
            _Bu_g_['Transform']:SetPosition(__Bug_(_bU_g_))
        end
    end
end
function __B__UG__:SolveParabolaEquation(b_Ug_)
    local _b_Ug_, __bUG, bUg
    bUg = b_Ug_[1][2]
    local _b__Ug__, b_u__G__ = b_Ug_[1][1], b_Ug_[1][2]
    local _b__U__g_, _bU_g__ = b_Ug_[2][1], b_Ug_[2][2]
    local _b__Ug_, __bu_g__ = b_Ug_[3][1], b_Ug_[3][2]
    local b_u_g_ = (_b__Ug__ - _b__U__g_) * (_b__Ug__ - _b__Ug_) * (_b__U__g_ - _b__Ug_)
    if b_u_g_ == 0 then
        return nil, nil, nil
    end
    local b__U__G_ =
        (_b__Ug_ * (_bU_g__ - b_u__G__) + _b__U__g_ * (b_u__G__ - __bu_g__) + _b__Ug__ * (__bu_g__ - _bU_g__)) / b_u_g_
    local bu__G =
        (_b__Ug_ ^ 2 * (b_u__G__ - _bU_g__) + _b__U__g_ ^ 2 * (__bu_g__ - b_u__G__) +
        _b__Ug__ ^ 2 * (_bU_g__ - __bu_g__)) /
        b_u_g_
    _b_Ug_ = b__U__G_
    __bUG = bu__G - 2 * b__U__G_ * _b__Ug__
    bUg = b_u__G__ - b__U__G_ * _b__Ug__ ^ 2 - bu__G * _b__Ug__
    return _b_Ug_, __bUG, bUg
end
function __B__UG__:HHClientRpc(_B__U_g, B__Ug__, b__UG)
    if _B__U_g and _B__U_g["userid"] and _B__U_g:HasTag "player" and type(B__Ug__) == "string" then
        SendModRPCToClient(CLIENT_MOD_RPC["hh_rpc"]["hh_client_value"], _B__U_g["userid"], B__Ug__, b__UG)
    end
end
function __B__UG__:MakeUiCanMove(__BUG_)
    local B__U_G_ = __BUG_["OnControl"]
    __BUG_["OnControl"] = function(self, __bU_G__, bU__g_)
        if self["Passive_OnControl"] then
            self:Passive_OnControl(__bU_G__, bU__g_)
        end
        if B__U_G_ then
            return B__U_G_(self, __bU_G__, bU__g_)
        end
    end
    __BUG_["Passive_OnControl"] = function(self, b__u__G_, _b_u__g__)
        if self["focus"] and b__u__G_ == CONTROL_SECONDARY then
            if _b_u__g__ then
                self:StartDrag()
            else
                self:EndDrag()
            end
        end
    end
    __BUG_["SetDragPosition"] = function(self, __BU__g__, _B_u_G__, _B__U__G)
        local Bu__G_
        if type(__BU__g__) == "number" then
            Bu__G_ = Vector3(__BU__g__, _B_u_G__, _B__U__G)
        else
            Bu__G_ = __BU__g__
        end
        local b_ug__ = self:GetScale()
        local __Bu__g_ = 1
        local __b_ug = self["p_startpos"] + (Bu__G_ - self["m_startpos"]) / (b_ug__["x"] / __Bu__g_)
        self:SetPosition(__b_ug)
    end
    __BUG_["StartDrag"] = function(self)
        if not self["hh_follower"] then
            local __bUG__ = TheInput:GetScreenPosition()
            self["m_startpos"] = __bUG__
            self["p_startpos"] = self:GetPosition()
            self["hh_follower"] =
                TheInput:AddMoveHandler(
                function(bu__g_, _BU__G)
                    self:SetDragPosition(bu__g_, _BU__G, 0)
                    if not Input:IsMouseDown(MOUSEBUTTON_RIGHT) then
                        self:EndDrag()
                    end
                end
            )
            self:SetDragPosition(__bUG__)
        end
    end
    __BUG_["EndDrag"] = function(self)
        if self["hh_follower"] then
            self["hh_follower"]:Remove()
        end
        self["hh_follower"] = nil
        self["m_startpos"] = nil
        self["p_startpos"] = nil
    end
end
function __B__UG__:HandleSuitBuff(__B_U_G__, __B_U_g__, __bu__G, _B_U_G_)
    if not __B__UG__:HasComponents(__B_U_G__, "hh_buff") then
        return
    end
    if _B_U_G_ then
        __B_U_G__["components"]["hh_buff"]:AddBuff(__B_U_g__, __bu__G)
    else
        __B_U_G__["components"]["hh_buff"]:RemoveBuff(__B_U_g__)
    end
end
function __B__UG__:CheckSuitEffect(__B__Ug__, _B_u__G__)
    if not __B__UG__:HasComponents(__B__Ug__, "hh_player") then
        return (26 + 187 + 454 - 237 + 232 ~= 662)
    end
    return __B__Ug__["components"]["hh_player"]:HasSuitEffect(_B_u__G__)
end
function __B__UG__:ExitGame(BU__G)
    if ThePlayer and __B__UG__:IsHHType(BU__G, "number") then
        ThePlayer:DoTaskInTime(
            BU__G,
            function()
                DoRestart((494 * 470 * 240 * 317 - 116 ~= 17664254286))
            end
        )
    end
end
function __B__UG__:GetAtkSpeedLevel(__B_U_G_)
    if
        not __B__UG__:HasComponents(__B_U_G_, "hh_player") or
            not __B_U_G_["components"]["hh_player"]:HasSpecialEffect "atkSpeed"
     then
        return 1
    end
    local _B_u_g = __B_U_G_["components"]["hh_player"]:GetEffectValueByKey "atkSpeed"
    _B_u_g = math["floor"](_B_u_g)
    _B_u_g = math["min"](_B_u_g, 4)
    return _B_u_g + 1
end
function __B__UG__:ClientMapBlink(_b__ug)
    if not __B__UG__:HasComponents(_b__ug, "hh_player") then
        return (340 - 31 + 385 == 697)
    end
    if _b__ug["components"]["hh_player"]:HasSpecialEffect "z_map_blink" then
        __B__UG__:SetClientValue(_b__ug, "hh_can_map_blink", "Y")
    else
        __B__UG__:SetClientValue(_b__ug, "hh_can_map_blink", "N")
    end
end
function __B__UG__:CanHitTarget(b__u__G, B__u__g__)
    if
        not (__B__UG__:IsHHType(b__u__G, "table") and __B__UG__:IsHHType(B__u__g__, "table") and b__u__G["IsValid"] and
            b__u__G:IsValid() and
            B__u__g__["IsValid"] and
            B__u__g__:IsValid() and
            b__u__G["Transform"] and
            not b__u__G:HasTag "FX" and
            not b__u__G:HasTag "INLIMBO" and
            not b__u__G:HasTag "DECOR" and
            B__u__g__["Transform"] and
            not B__u__g__:HasTag "FX" and
            not B__u__g__:HasTag "INLIMBO" and
            not B__u__g__:HasTag "DECOR")
     then
        return (245 * 483 * 24 + 230 == 2840276)
    end
    if b__u__G == B__u__g__ then
        return (72 * 340 + 301 + 92 ~= 24873)
    end
    local __B_U_g_ = b__u__G["components"]["follower"]
    local b__U_G = B__u__g__["components"]["follower"]
    if __B_U_g_ and __B_U_g_["leader"] == B__u__g__ then
        return (109 * 85 + 417 * 372 == 164398)
    end
    if b__U_G and b__U_G["leader"] == b__u__G then
        return (false and false and false and false and not false and false and true and not true and not false)
    end
    return (89 * 272 + 456 * 184 + 135 ~= 108250)
end

-- Shadow-only ownership helpers. Keep CanHitTarget() unchanged because it is
-- also used by unrelated weapons, monsters, and progression effects.
local function IsValidShadowRelationEntity(inst)
    return inst ~= nil
        and inst.IsValid ~= nil
        and inst:IsValid()
        and (inst.IsInLimbo == nil or not inst:IsInLimbo())
end

function __B__UG__:GetTopFollowerOwner(inst)
    local current = inst
    local visited = {}

    -- Follower:GetLeader() already resolves itemowner before leader. The
    -- inventory-item fallback covers owner chains such as a domestication
    -- bell whose grand owner is the player.
    for _ = 1, 16 do
        if not IsValidShadowRelationEntity(current) or visited[current] then
            return nil
        end
        visited[current] = true

        local follower = current.components ~= nil and current.components.follower or nil
        local leader = follower ~= nil and follower:GetLeader() or nil
        if leader ~= nil and leader ~= current then
            current = leader
        else
            local inventoryitem = current.components ~= nil and current.components.inventoryitem or nil
            local grand_owner = inventoryitem ~= nil
                and inventoryitem.GetGrandOwner ~= nil
                and inventoryitem:GetGrandOwner()
                or nil
            if grand_owner ~= nil and grand_owner ~= current then
                current = grand_owner
            else
                return current
            end
        end
    end

    return nil
end

function __B__UG__:GetShadowOwner(shadow)
    return __B__UG__:GetTopFollowerOwner(shadow)
end

-- Kill-credit ownership is broader than shadow-only ownership. Resolve the
-- live player at the moment of the kill without changing GetShadowOwner(),
-- whose root-owner semantics are used by combat/friendly-fire checks.
local KILL_CREDIT_SOURCE_FIELDS = {
    "owner",
    "caster",
    "_caster",
    "instigator",
    "source",
    "creator",
    "host",
    "parent",
}

local function IsValidKillCreditPlayer(inst)
    if not IsValidShadowRelationEntity(inst)
        or inst.HasTag == nil
        or not inst:HasTag("player")
        or inst:HasTag("playerghost")
        or inst._hh_kill_credit_disconnected == true
        or not __B__UG__:HasComponents(inst, "hh_player") then
        return false
    end

    local health = inst.components ~= nil and inst.components.health or nil
    return health ~= nil and not health:IsDead()
end

function __B__UG__:GetKillCreditPlayer(attacker)
    local visited = {}

    local function Resolve(current, depth)
        local current_type = type(current)
        if (current_type ~= "table" and current_type ~= "userdata")
            or depth > 16
            or not IsValidShadowRelationEntity(current)
            or visited[current] then
            return nil
        end

        -- A player entity is terminal. Do not walk through a dead/removed
        -- player and accidentally credit an unrelated object owner.
        if current.HasTag ~= nil and current:HasTag("player") then
            return IsValidKillCreditPlayer(current) and current or nil
        end

        visited[current] = true
        local components = current.components

        -- Follower:GetLeader() is the vanilla authority and includes
        -- Follower.itemowner as well as Follower.leader.
        local follower = components ~= nil and components.follower or nil
        local leader = follower ~= nil and follower.GetLeader ~= nil and follower:GetLeader() or nil
        if leader ~= nil and leader ~= current then
            return Resolve(leader, depth + 1)
        end

        -- Bernie is a vanilla companion with a custom owner field instead of
        -- the follower component.
        local bernieleader = current.bernieleader
        if bernieleader ~= nil and bernieleader ~= current then
            return Resolve(bernieleader, depth + 1)
        end

        local inventoryitem = components ~= nil and components.inventoryitem or nil
        if inventoryitem ~= nil then
            local grand_owner = inventoryitem.GetGrandOwner ~= nil
                and inventoryitem:GetGrandOwner()
                or inventoryitem.owner
            if grand_owner ~= nil and grand_owner ~= current then
                return Resolve(grand_owner, depth + 1)
            end
        end

        for _, field in ipairs(KILL_CREDIT_SOURCE_FIELDS) do
            local source = current[field]
            if source ~= nil and source ~= current then
                return Resolve(source, depth + 1)
            end
        end

        local projectile = components ~= nil and components.projectile or nil
        if projectile ~= nil and projectile.owner ~= nil and projectile.owner ~= current then
            return Resolve(projectile.owner, depth + 1)
        end

        local complexprojectile = components ~= nil and components.complexprojectile or nil
        if complexprojectile ~= nil
            and complexprojectile.attacker ~= nil
            and complexprojectile.attacker ~= current then
            return Resolve(complexprojectile.attacker, depth + 1)
        end

        local weapon = components ~= nil and components.weapon or nil
        if weapon ~= nil and weapon.inst ~= nil and weapon.inst ~= current then
            return Resolve(weapon.inst, depth + 1)
        end

        return nil
    end

    return Resolve(attacker, 0)
end

-- The vanilla Health:Kill() API has no attacker parameter. Use its exact
-- DoDelta semantics while preserving the actual attacker for the health
-- death event and the shared kill-credit relay.
function __B__UG__:PushKilledEvent(attacker, victim)
    if attacker == nil or victim == nil or attacker.PushEvent == nil then
        return false
    end
    attacker:PushEvent("killed", { victim = victim, attacker = attacker })
    return true
end

function __B__UG__:KillWithAttacker(target, attacker)
    local health = target ~= nil and target.components ~= nil and target.components.health or nil
    if health == nil or attacker == nil or health:IsDead() or (health.currenthealth or 0) <= 0 then
        return false
    end

    local previous_ignore_max = health._ignore_maxdamagetakenperhit
    health._ignore_maxdamagetakenperhit = true
    health:DoDelta(-health.currenthealth, nil, nil, nil, attacker, true)
    health._ignore_maxdamagetakenperhit = previous_ignore_max
    if health:IsDead() then
        __B__UG__:PushKilledEvent(attacker, target)
    end
    return true
end

function __B__UG__:DoDeltaWithAttacker(target, amount, cause, attacker, ...)
    local health = target ~= nil and target.components ~= nil and target.components.health or nil
    if health == nil or attacker == nil or health:IsDead() then
        return false
    end

    local was_alive = not health:IsDead()
    health:DoDelta(amount, nil, cause, nil, attacker, ...)
    if was_alive and health:IsDead() then
        __B__UG__:PushKilledEvent(attacker, target)
    end
    return true
end

function __B__UG__:RelayKillToOwner(actual_killer, data)
    local victim = data ~= nil and data.victim or nil
    if victim == nil or victim._hh_kill_credit_relayed then
        return false
    end

    local credited_player = __B__UG__:GetKillCreditPlayer(actual_killer)
    -- Vanilla Combat will emit the direct-player event itself. Only relay
    -- when the actual killer is an owned non-player entity/source.
    if credited_player == nil or credited_player == actual_killer then
        return false
    end

    victim._hh_kill_credit_relayed = true
    local relayed_data = {}
    if type(data) == "table" then
        for key, value in pairs(data) do
            relayed_data[key] = value
        end
    end
    relayed_data.victim = victim
    relayed_data.attacker = credited_player
    relayed_data._hh_actual_attacker = actual_killer
    credited_player:PushEvent("killed", relayed_data)
    return true
end

function __B__UG__:IsShadowOwnerAlly(shadow, target)
    if not IsValidShadowRelationEntity(shadow)
        or not IsValidShadowRelationEntity(target)
        or shadow == target then
        return false
    end

    local owner = __B__UG__:GetShadowOwner(shadow)
    if owner == nil then
        return false
    end
    if target == owner then
        return true
    end
    return __B__UG__:GetTopFollowerOwner(target) == owner
end

function __B__UG__:IsOwnerIntentionalAllyTarget(owner, target)
    local marker = owner ~= nil and owner._hh_intentional_ally_target or nil
    if marker == nil then
        return false
    end

    local owner_valid = IsValidShadowRelationEntity(owner)
    local marker_valid = IsValidShadowRelationEntity(marker)
    local owner_components = owner_valid and owner.components or nil
    local marker_components = marker_valid and marker.components or nil
    local combat = owner_components ~= nil and owner_components.combat or nil
    local owner_health = owner_components ~= nil and owner_components.health or nil
    local target_health = marker_components ~= nil and marker_components.health or nil
    local valid = owner_valid
        and marker_valid
        and owner ~= marker
        and combat ~= nil
        and combat.target == marker
        and (owner_health == nil or not owner_health:IsDead())
        and (target_health == nil or not target_health:IsDead())
        and __B__UG__:IsShadowOwnerAlly(owner, marker)

    if not valid and owner_valid then
        -- Event callbacks clear the common remove/death paths. This lazy
        -- validation also covers target-owner changes, target drops, and
        -- stale combat state without a periodic world task.
        local manager = owner_components ~= nil and owner_components.hh_shadow_manager or nil
        if manager ~= nil
            and manager._intentional_ally_target == marker
            and manager.ClearIntentionalAllyTarget ~= nil then
            manager:ClearIntentionalAllyTarget()
        else
            owner._hh_intentional_ally_target = nil
        end
    end
    return valid and marker == target
end

function __B__UG__:CanShadowDamageTarget(shadow, target)
    if not IsValidShadowRelationEntity(shadow)
        or not IsValidShadowRelationEntity(target)
        or shadow == target then
        return false
    end

    local owner = __B__UG__:GetShadowOwner(shadow)
    if owner == nil then
        return true
    end
    if target == owner then
        return false
    end
    if not __B__UG__:IsShadowOwnerAlly(shadow, target) then
        return true
    end
    return __B__UG__:IsOwnerIntentionalAllyTarget(owner, target)
end

function __B__UG__:CanShadowDealIntentionalAllyDamage(target, afflicter)
    if not IsValidShadowRelationEntity(target)
        or not IsValidShadowRelationEntity(afflicter)
        or not __B__UG__:IsShadowOwnerAlly(target, afflicter) then
        return false
    end

    local owner = __B__UG__:GetShadowOwner(target)
    if owner == nil or not __B__UG__:IsOwnerIntentionalAllyTarget(owner, target) then
        return false
    end
    if afflicter == owner then
        return true
    end

    -- A same-owner follower is not enough for the exception. The manager's
    -- bounded ownership list is the authority for Solo Leveling Shadow
    -- instances; this avoids broad tag-based friendly-fire openings.
    local manager = owner.components ~= nil and owner.components.hh_shadow_manager or nil
    return manager ~= nil
        and manager.IsOwnedShadowInstance ~= nil
        and manager:IsOwnedShadowInstance(afflicter)
        and __B__UG__:CanShadowDamageTarget(afflicter, target)
end

function __B__UG__:CreateMoreTextUi(__BU__G__, _Bu_G, __B__U__G)
    local __Bug = __BU__G__:AddChild(b_Ug())
    local __B_u_G_, _BU__g_ = 0, 0
    if __B__UG__:IsHHType(_Bu_G, "table") then
        for bUG_, __b__Ug_ in ipairs(_Bu_G) do
            if __B__UG__:IsHHType(__b__Ug_, "table") then
                local _b_U_g_ = __b__Ug_["scale"] or 30
                local _B__ug = __b__Ug_["str"] or "Word"
                local b__u__G__ = __b__Ug_["color"] or {1, 1, 1, 1}
                __Bug["hh_text_" .. bUG_] = __Bug:AddChild(buG(BODYTEXTFONT, _b_U_g_ or 30, ""))
                __Bug["hh_text_" .. bUG_]:SetString(_B__ug)
                __Bug["hh_text_" .. bUG_]:SetColour(b__u__G__)
                __Bug["hh_text_" .. bUG_]:SetHAlign(ANCHOR_LEFT)
                __Bug["hh_text_" .. bUG_]:SetVAlign(ANCHOR_MIDDLE)
                local __B__UG, __b_u_g__ = __Bug["hh_text_" .. bUG_]:GetRegionSize()
                if __B__U__G and __B__U__G ~= 1 then
                    if __B__U__G == 2 then
                        __Bug["hh_text_" .. bUG_]:SetPosition(__B_u_G_ - __B__UG / 2, -__b_u_g__ / 2, 0)
                        __B_u_G_ = __B_u_G_ - __B__UG
                        _BU__g_ = math["max"](_BU__g_, __b_u_g__)
                    elseif __B__U__G == 3 then
                        __Bug["hh_text_" .. bUG_]:SetPosition(__B__UG / 2, _BU__g_ - __b_u_g__ / 2, 0)
                        __B_u_G_ = math["max"](__B_u_G_, __B__UG)
                        _BU__g_ = _BU__g_ - __b_u_g__
                    elseif __B__U__G == 4 then
                        __Bug["hh_text_" .. bUG_]:SetPosition(__B__UG / 2, _BU__g_ + __b_u_g__ / 2, 0)
                        __B_u_G_ = math["max"](__B_u_G_, __B__UG)
                        _BU__g_ = _BU__g_ + __b_u_g__
                    end
                else
                    __Bug["hh_text_" .. bUG_]:SetPosition(__B_u_G_ + __B__UG / 2, -__b_u_g__ / 2, 0)
                    __B_u_G_ = __B_u_G_ + __B__UG
                    _BU__g_ = math["max"](_BU__g_, __b_u_g__)
                end
            end
        end
    end
    __Bug["max_x"] = math["abs"](__B_u_G_)
    __Bug["max_y"] = math["abs"](_BU__g_)
    return __Bug
end
function __B__UG__:CreateImageAndText(__b_U__g__, _b__U_G, _B__U_G__)
    local bU__g__ = __b_U__g__:AddChild(b_Ug "")
    local b__u_g_, __b__Ug__ = 0, 0
    local b_uG = _B__U_G__ or 1
    if __B__UG__:IsHHType(_b__U_G, "table") then
        for _bU__G, _b__u__G in ipairs(_b__U_G) do
            if __B__UG__:IsHHType(_b__u__G, "table") and _b__u__G["type"] then
                local bu_G, __Bu_G_ = 0, 0
                local __b__u_g__ = "hh_child_" .. _bU__G
                if _b__u__G["type"] == "text" then
                    local __B__ug__ = _b__u__G["scale"] or 30
                    local BUG_ = _b__u__G["str"] or "Word"
                    local __bu__G__ = _b__u__G["color"] or {1, 1, 1, 1}
                    bU__g__[__b__u_g__] = bU__g__:AddChild(buG(BODYTEXTFONT, __B__ug__ or 30, ""))
                    bU__g__[__b__u_g__]:SetString(BUG_)
                    bU__g__[__b__u_g__]:SetColour(__bu__G__)
                    bU__g__[__b__u_g__]:SetHAlign(ANCHOR_LEFT)
                    bU__g__[__b__u_g__]:SetVAlign(ANCHOR_MIDDLE)
                    local __b__U_G_, Bu_g_ = bU__g__[__b__u_g__]:GetRegionSize()
                    bu_G, __Bu_G_ = __b__U_G_, Bu_g_
                elseif _b__u__G["type"] == "image" then
                    local BU__G__ = _b__u__G["xml"] or "images/global.xml"
                    local __b_U_g__ = _b__u__G["tex"] or "square.tex"
                    local _b_U__g__ = _b__u__G["size_x"] or 30
                    local __bu__g_ = _b__u__G["size_y"] or 30
                    local B__ug = _b__u__G["color"] or {1, 1, 1, 1}
                    bU__g__[__b__u_g__] = bU__g__:AddChild(_BUG(BU__G__, __b_U_g__))
                    bU__g__[__b__u_g__]:SetSize(_b_U__g__, __bu__g_)
                    bU__g__[__b__u_g__]:SetTint(B__ug[1], B__ug[2], B__ug[3], B__ug[4])
                    bU__g__[__b__u_g__]:SetClickable((306 + 138 - 227 == 222))
                    bu_G, __Bu_G_ = _b_U__g__, __bu__g_
                end
                if bU__g__[__b__u_g__] then
                    if b_uG == 1 then
                        bU__g__[__b__u_g__]:SetPosition(b__u_g_ + bu_G / 2, -__Bu_G_ / 2, 0)
                        b__u_g_ = b__u_g_ + bu_G
                        __b__Ug__ = math["max"](__b__Ug__, __Bu_G_)
                    elseif b_uG == 2 then
                        bU__g__[__b__u_g__]:SetPosition(b__u_g_ - bu_G / 2, -__Bu_G_ / 2, 0)
                        b__u_g_ = b__u_g_ - bu_G
                        __b__Ug__ = math["max"](__b__Ug__, __Bu_G_)
                    elseif b_uG == 3 then
                        bU__g__[__b__u_g__]:SetPosition(bu_G / 2, __b__Ug__ - __Bu_G_ / 2, 0)
                        b__u_g_ = math["max"](b__u_g_, bu_G)
                        __b__Ug__ = __b__Ug__ - __Bu_G_
                    elseif b_uG == 4 then
                        bU__g__[__b__u_g__]:SetPosition(bu_G / 2, __b__Ug__ + __Bu_G_ / 2, 0)
                        b__u_g_ = math["max"](b__u_g_, bu_G)
                        __b__Ug__ = __b__Ug__ + __Bu_G_
                    end
                end
            end
        end
    end
    bU__g__["max_x"] = math["abs"](b__u_g_)
    bU__g__["max_y"] = math["abs"](__b__Ug__)
    return bU__g__
end
function __B__UG__:CreateFrameUi(b_U__G, B__u__G__, bug__, __B__u_G)
    local B__u_g__ = b_U__G:AddChild(_BUG("images/global.xml", "square.tex"))
    B__u_g__:SetPosition(B__u__G__)
    local _b__UG__, b__Ug = bug__["size_x"] or 100, bug__["size_y"] or 100
    B__u_g__:SetSize(_b__UG__, b__Ug)
    if __B__UG__:IsHHType(bug__["color"], "table") and #bug__["color"] == 4 then
        local __B__UG_ = bug__["color"]
        B__u_g__:SetTint(__B__UG_[1], __B__UG_[2], __B__UG_[3], __B__UG_[4])
    end
    if __B__UG__:IsHHType(__B__u_G, "table") then
        local __bU__G__ = __B__u_G["size"] or 5
        local Bu__g_ = __B__u_G["color"] or {1, 1, 1, 1}
        B__u_g__["hh_left"] =
            __B__UG__:HHCreateImageUi(
            B__u_g__,
            "images/global.xml",
            "square.tex",
            Vector3(-_b__UG__ / 2 - __bU__G__ / 2, 0, 1),
            __bU__G__,
            b__Ug,
            Bu__g_
        )
        B__u_g__["hh_right"] =
            __B__UG__:HHCreateImageUi(
            B__u_g__,
            "images/global.xml",
            "square.tex",
            Vector3(_b__UG__ / 2 + __bU__G__ / 2, 0, 1),
            __bU__G__,
            b__Ug,
            Bu__g_
        )
        B__u_g__["hh_up"] =
            __B__UG__:HHCreateImageUi(
            B__u_g__,
            "images/global.xml",
            "square.tex",
            Vector3(0, b__Ug / 2 + __bU__G__ / 2, 1),
            _b__UG__,
            __bU__G__,
            Bu__g_
        )
        B__u_g__["hh_down"] =
            __B__UG__:HHCreateImageUi(
            B__u_g__,
            "images/global.xml",
            "square.tex",
            Vector3(0, -b__Ug / 2 - __bU__G__ / 2, 1),
            _b__UG__,
            __bU__G__,
            Bu__g_
        )
        local _B__Ug_, b_Ug__ = __bU__G__ / 2 + _b__UG__ / 2, b__Ug / 2 + __bU__G__ / 2
        B__u_g__["hh_icon_01"] =
            __B__UG__:HHCreateImageUi(
            B__u_g__,
            "images/global.xml",
            "square.tex",
            Vector3(-_B__Ug_, b_Ug__, 1),
            __bU__G__,
            __bU__G__,
            Bu__g_
        )
        B__u_g__["hh_icon_02"] =
            __B__UG__:HHCreateImageUi(
            B__u_g__,
            "images/global.xml",
            "square.tex",
            Vector3(_B__Ug_, b_Ug__, 1),
            __bU__G__,
            __bU__G__,
            Bu__g_
        )
        B__u_g__["hh_icon_03"] =
            __B__UG__:HHCreateImageUi(
            B__u_g__,
            "images/global.xml",
            "square.tex",
            Vector3(-_B__Ug_, -b_Ug__, 1),
            __bU__G__,
            __bU__G__,
            Bu__g_
        )
        B__u_g__["hh_icon_04"] =
            __B__UG__:HHCreateImageUi(
            B__u_g__,
            "images/global.xml",
            "square.tex",
            Vector3(_B__Ug_, -b_Ug__, 1),
            __bU__G__,
            __bU__G__,
            Bu__g_
        )
    end
    return B__u_g__
end
local _B_UG__ = {
    {
        ["id"] = "name2",
        ["name"] = " ",
        ["scale"] = 1,
        ["color"] = {1, 1, 1, 1},
        ["is_mid"] = (137 - 244 + 267 + 46 - 309 == -103),
        ["child_mid"] = (346 + 309 - 90 * 49 * 27 ~= -118405)
    }
}
local _bu__g__ = {
    ["name"] = {
        ["str"] = "Name",
        ["color"] = {1, 0, 0, 1},
        ["child"] = {
            ["ui_type"] = 2,
            ["child_type"] = 1,
            {["type"] = "text", ["str"] = "Right", ["color"] = {1, 0, 1, 1}, scale = 30},
            {["type"] = "text", ["str"] = "Together", ["color"] = {0, 1, 1, 1}, scale = 30},
            {["type"] = "text", ["str"] = "Grid", ["color"] = {1, 0, 0, 1}, scale = 30},
            {["type"] = "text", ["str"] = "Mode", ["color"] = {0, 0, 1, 1}, scale = 30}
        }
    }
}
function __B__UG__:CreateInfoUi(_b__U_G_, B__U__G_, __b__u__g)
    local _b__ug_ = _b__U_G_:AddChild(b_Ug "hh_info")
    _b__ug_["max_x"], _b__ug_["max_y"] = 1, 1
    if not __B__UG__:IsHHType(B__U__G_, "table") or not __B__UG__:IsHHType(__b__u__g, "table") then
        return _b__ug_
    end
    local __B__Ug, bUG = 0, 0
    for _B__U_G, Bu_g__ in ipairs(__b__u__g) do
        if Bu_g__ and Bu_g__["id"] and B__U__G_[Bu_g__["id"]] then
            local Bug__, __b__U__g_ = 0, 0
            local _b_ug = Bu_g__["id"]
            local B__Ug_ = Bu_g__["name"] or "Prefix"
            local __b_U_g_ = Bu_g__["scale"] or 30
            local __BU__g_ = Bu_g__["color"] or {1, 1, 1, 1}
            local bU__G_ = "text_title" .. _b_ug
            _b__ug_[bU__G_] = __B__UG__:HHCreateTextUi(_b__ug_, Vector3(0, 0, 1), B__Ug_, __BU__g_, __b_U_g_)
            local __B_U__G, b_u__g__ = _b__ug_[bU__G_]:GetRegionSize()
            _b__ug_[bU__G_]:SetPosition(__B_U__G / 2, -bUG - b_u__g__ / 2, 1)
            Bug__ = __B_U__G
            __b__U__g_ = b_u__g__
            local _BuG_ = B__U__G_[_b_ug]
            local BU_G = _BuG_["str"] or "Describe"
            local _B__U__g_ = _BuG_["color"] or {1, 1, 1, 1}
            local _bug = _b__ug_[bU__G_]
            if BU_G ~= "" then
                _bug["hh_str"] =
                    __B__UG__:HHCreateTextUi(
                    _bug,
                    Vector3(0, 0, 1),
                    BU_G,
                    _B__U__g_,
                    __b_U_g_,
                    (314 * 7 * 71 * 198 - 79 ~= 30899411)
                )
                local _b_U__G_, _B__u_G = _bug["hh_str"]:GetRegionSize()
                _bug["hh_str"]:SetPosition(__B_U__G / 2 + _b_U__G_ / 2, b_u__g__ / 2 - _B__u_G / 2, 1)
                Bug__ = Bug__ + _b_U__G_
                __b__U__g_ = math["max"](__b__U__g_, _B__u_G)
            end
            if _BuG_["child"] then
                _bug["hh_child_ui"] = __B__UG__:CreateImageAndText(_bug, _BuG_["child"], _BuG_["child"]["child_type"])
                local _B_U__g__, b_U_G = _bug["hh_child_ui"]["max_x"], _bug["hh_child_ui"]["max_y"]
                local __bug__ = _BuG_["child"]["ui_type"] or 3
                if __bug__ == 1 then
                    _bug["hh_child_ui"]:SetPosition(Bug__ - __B_U__G / 2, b_u__g__ / 2, 0)
                    Bug__ = Bug__ + _B_U__g__
                    __b__U__g_ = math["max"](__b__U__g_, b_U_G)
                elseif __bug__ == 2 then
                    _bug["hh_child_ui"]:SetPosition(-__B_U__G / 2, -(__b__U__g_ / 2 + b_u__g__ / 2), 0)
                    Bug__ = math["max"](Bug__, _B_U__g__)
                    __b__U__g_ = __b__U__g_ + b_U_G
                elseif __bug__ == 3 then
                    _bug["hh_child_ui"]:SetPosition(__B_U__G / 2, -(__b__U__g_ / 2 + b_u__g__ / 2), 0)
                    Bug__ = math["max"](Bug__, _B_U__g__ + __B_U__G)
                    __b__U__g_ = __b__U__g_ + b_U_G
                end
            end
            _b__ug_[bU__G_]["max_x"] = Bug__
            _b__ug_[bU__G_]["max_y"] = __b__U__g_
            bUG = bUG + __b__U__g_
            __B__Ug = math["max"](__B__Ug, Bug__)
        end
    end
    for _b_Ug, bU__G__ in ipairs(__b__u__g) do
        if bU__G__ and bU__G__["id"] and B__U__G_[bU__G__["id"]] then
            local _Bu__G__ = bU__G__["id"]
            local b__U__G__ = "text_title" .. _Bu__G__
            if _b__ug_[b__U__G__] then
                local __b__U_g = _b__ug_[b__U__G__]
                local __B_U_G = __b__U_g:GetPosition()
                if bU__G__["is_mid"] then
                    __b__U_g:SetPosition(__B__Ug / 2, __B_U_G["y"], 1)
                end
                if bU__G__["child_mid"] and __b__U_g["hh_child_ui"] then
                    local b_U__g__ = __b__U_g["hh_child_ui"]["max_x"] or 10
                    local __b__ug_ = __b__U_g["hh_child_ui"]:GetPosition()
                    __b__U_g["hh_child_ui"]:SetPosition(__B__Ug / 2 - b_U__g__ / 2, __b__ug_["y"], 1)
                end
            end
        end
    end
    _b__ug_["max_x"], _b__ug_["max_y"] = math["abs"](__B__Ug), math["abs"](bUG)
    return _b__ug_
end
function __B__UG__:CreateTrueScrollArea(__bu_G_, _b__u_G_, Bu__G__, b__u__g, __bu__G_, B_u_g__, _B__u__G_, B__U_g_)
    local bUG__ = {["x"] = 0, ["y"] = 0, ["width"] = Bu__G__, ["height"] = b__u__g}
    local __B__u__g__, _B_ug__ = _B__u__G_ or 0, B__U_g_ or 0
    local __B__U__g_ = {
        ["widget"] = _b__u_G_,
        ["offset"] = {["x"] = 0 + __B__u__g__, ["y"] = b__u__g + _B_ug__},
        ["size"] = {["w"] = 0, ["height"] = __bu__G_}
    }
    local BuG = B_u_g__ or 15
    local __b_u__g_ = {["scroll_per_click"] = BuG}
    local b_u_G__ = __bu_G_:AddChild(_BU_g__(__B__U__g_, bUG__, __b_u__g_))
    return b_u_G__
end
function __B__UG__:UiAddFocusStr(__B__u__G, _buG__)
    local __B_u__G__ = __B__u__G["OnGainFocus"]
    __B__u__G["OnGainFocus"] = function()
        if __B_u__G__ then
            __B_u__G__()
        end
        __B__u__G["hh_desc"] = __B__UG__:HHCreateTextUi(__B__u__G, Vector3(0, 0, 1), tostring(_buG__), {1, 1, 1, 1}, 30)
        __B__u__G["hh_desc"]:MoveTo(Vector3(0, 20, 1), Vector3(0, 40, 1), 0.5)
    end
    local _BU_G__ = __B__u__G["OnLoseFocus"]
    __B__u__G["OnLoseFocus"] = function()
        if _BU_G__ then
            _BU_G__()
        end
        __B__UG__:HHKillChild(__B__u__G, "hh_desc")
    end
end
function __B__UG__:CreateAnimUi(bu__g__, b__u__g__, _B__u_G_, _b__U__g, _B_UG, _B_U_G)
    local __bUg_ = bu__g__:AddChild(_B_U__G__())
    __bUg_:GetAnimState():SetBank(b__u__g__)
    __bUg_:GetAnimState():SetBuild(_B__u_G_)
    if _B_UG then
        __bUg_:GetAnimState():PlayAnimation(_b__U__g, (39 + 353 + 200 == 592))
    else
        __bUg_:GetAnimState():PlayAnimation(_b__U__g)
    end
    __bUg_:SetClickable(
        (false or true and not false and not false and not false and false and true and not false or not true)
    )
    if _B_U_G then
        __bUg_:SetScale(_B_U_G, _B_U_G, _B_U_G)
    end
    return __bUg_
end
local function __bu_g(B_U_g_, __Bu_g_, __B_U_g)
    if B_U_g_["components"][__Bu_g_] ~= nil and B_U_g_["components"][__Bu_g_]:TimerExists(__B_U_g) then
        B_U_g_["components"][__Bu_g_]:StopTimer(__B_U_g)
        B_U_g_:PushEvent("timerdone", {name = __B_U_g})
    end
end
function __B__UG__:TryGrowth(_B_U_G__, b__u_G_)
    if not _B_U_G__ or _B_U_G__:IsInLimbo() then
        return
    end
    if __B__UG__:HasComponents(_B_U_G__, "pickable") then
        if _B_U_G__:HasTag "sunflower" and TUNING["SUNFLOWER_REGROW_TIME"] then
            _B_U_G__["time"] = GetTime() - TUNING["SUNFLOWER_REGROW_TIME"]
        end
        if _B_U_G__["components"]["pickable"]:CanBePicked() and _B_U_G__["components"]["pickable"]["caninteractwith"] then
            return
        end
        local B__u_G__ = nil
        if _B_U_G__["components"]["pickable"]["nomagic"] then
            _B_U_G__["components"]["pickable"]["nomagic"] = nil
            B__u_G__ = (40 * 85 + 134 ~= 3538)
        end
        _B_U_G__["components"]["pickable"]:FinishGrowing()
        _B_U_G__["components"]["pickable"]["nomagic"] = B__u_G__
    end
    if _B_U_G__["components"]["crop"] ~= nil then
        _B_U_G__["components"]["crop"]:DoGrow(TUNING["TOTAL_DAY_TIME"] * 6, (161 * 497 * 145 * 267 - 244 == 3097857911))
    end
    __bu_g(_B_U_G__, "timer", "grow")
    __bu_g(_B_U_G__, "timer", "growth")
    __bu_g(_B_U_G__, "worldsettingstimer", "grow")
    __bu_g(_B_U_G__, "worldsettingstimer", "growth")
    if __B__UG__:HasComponents(_B_U_G__, "crop_legion") and _B_U_G__["components"]["crop_legion"]["DoGrow"] then
        _B_U_G__["components"]["crop_legion"]:DoGrow(TUNING["TOTAL_DAY_TIME"] * 6, (63 * 392 + 152 == 24848))
    end
    if b__u_G_ then
        if _B_U_G__["components"]["perennialcrop"] ~= nil then
            _B_U_G__["components"]["perennialcrop"]:DoMagicGrowth(b__u_G_, TUNING["TOTAL_DAY_TIME"] * 3)
        end
        if _B_U_G__["components"]["perennialcrop2"] ~= nil then
            _B_U_G__["components"]["perennialcrop2"]:DoMagicGrowth(b__u_G_, TUNING["TOTAL_DAY_TIME"] * 3)
        end
    end
    if
        __B__UG__:HasComponents(_B_U_G__, "growable") and
            (_B_U_G__:HasTag "tree" or _B_U_G__:HasTag "peachtree" or _B_U_G__:HasTag "plant" or
                _B_U_G__:HasTag "winter_tree" or
                _B_U_G__:HasTag "boulder" or
                _B_U_G__["components"]["growable"]["magicgrowable"])
     then
        local __bUg__ = _B_U_G__["components"]["growable"]["stage"]
        local b__U_G_ = #_B_U_G__["components"]["growable"]["stages"]
        if _B_U_G__:HasTag "evergreens" then
            b__U_G_ = b__U_G_ - 1
        end
        if _B_U_G__:HasTag "siving_derivant" then
            _B_U_G__["components"]["growable"]:DoGrowth()
            _B_U_G__["components"]["growable"]:DoMagicGrowth()
            _B_U_G__["components"]["growable"]:DoMagicGrowth()
            _B_U_G__["components"]["growable"]:DoMagicGrowth()
        else
            if __bUg__ == b__U_G_ then
                _B_U_G__["components"]["growable"]:Pause()
            elseif __bUg__ == b__U_G_ - 1 then
                _B_U_G__["components"]["growable"]:DoGrowth()
                _B_U_G__["components"]["growable"]:Pause()
            else
                _B_U_G__["components"]["growable"]:DoGrowth()
            end
        end
    end
    if _B_U_G__["components"]["harvestable"] ~= nil and _B_U_G__:HasTag "mushroom_farm" then
        if _B_U_G__["components"]["harvestable"]["task"] then
            _B_U_G__["components"]["harvestable"]:Grow()
            _B_U_G__["components"]["harvestable"]:Grow()
            _B_U_G__["components"]["harvestable"]:Grow()
            _B_U_G__["components"]["harvestable"]:Grow()
            _B_U_G__["components"]["harvestable"]:Grow()
            _B_U_G__["components"]["harvestable"]:Grow()
        end
    end
end
local _bU__G__ = {
    "rock_petrified_tree_short",
    "rock_petrified_tree_med",
    "rock_petrified_tree_tall",
    "rock_petrified_tree_old"
}
local _B__U__g = {
    "petrified_tree_fx_short",
    "petrified_tree_fx_normal",
    "petrified_tree_fx_tall",
    "petrified_tree_fx_old"
}
local _b__u__g__ = {"gargoyle_houndatk", "gargoyle_hounddeath"}
local b__Ug_ = {"gargoyle_werepigatk", "gargoyle_werepigdeath", "gargoyle_werepighowl"}
function __B__UG__:StoneTree(_B__u__g_, Bu_g, _bUG__)
    local B_u_G_, __b__uG_, _b__u__G__ = __Bug_(_B__u__g_)
    local _b__u_G__, __b_u__g, _BU_g = _B__u__g_["AnimState"]:GetMultColour()
    _B__u__g_:Remove()
    if not _bU__G__[Bu_g] then
        return
    end
    local _b_U_G_ = SpawnPrefab(_bU__G__[Bu_g])
    if _b_U_G_ then
        _b_U_G_["AnimState"]:SetMultColour(_b__u_G__, __b_u__g, _BU_g, 1)
        _b_U_G_["Transform"]:SetPosition(B_u_G_, 0, _b__u__G__)
        if not _bUG__ and _B__U__g[Bu_g] then
            local _bU_G = SpawnPrefab(_B__U__g[Bu_g])
            if _bU_G then
                _bU_G["Transform"]:SetPosition(B_u_G_, __b__uG_, _b__u__G__)
                _bU_G:InheritColour(_b__u_G__, __b_u__g, _BU_g)
            end
        end
    end
end
function __B__UG__:StoneDog(__BU_G__)
    if not __BU_G__["components"]["health"]:IsDead() and (not __BU_G__["sg"]:HasStateTag "busy" or __BU_G__:IsAsleep()) then
        local B__UG_, _bu_G, b__uG = __Bug_(__BU_G__)
        local __BUG = __BU_G__["Transform"]:GetRotation()
        __BU_G__:Remove()
        local b__UG_ = SpawnPrefab(_b__u__g__[math["random"](#_b__u__g__)])
        if not b__UG_ then
            return
        end
        b__UG_["Transform"]:SetPosition(B__UG_, _bu_G, b__uG)
        b__UG_["Transform"]:SetRotation(__BUG)
        b__UG_:Petrify()
    end
end
function __B__UG__:StonePig(__B__u_g)
    if not __B__u_g["components"]["health"]:IsDead() and (not __B__u_g["sg"]:HasStateTag "busy" or __B__u_g:IsAsleep()) then
        local b__U_g, __b_UG, __BU_g = __Bug_(__B__u_g)
        local b__u_G__ = __B__u_g["Transform"]:GetRotation()
        local b_u_g__ = __B__u_g["components"]["named"]["name"]
        __B__u_g:Remove()
        local _B__u__g = SpawnPrefab(b__Ug_[math["random"](#b__Ug_)])
        if not _B__u__g then
            return
        end
        _B__u__g["components"]["named"]:SetName(b_u_g__)
        _B__u__g["Transform"]:SetPosition(b__U_g, __b_UG, __BU_g)
        _B__u__g["Transform"]:SetRotation(b__u_G__)
        _B__u__g:Petrify()
    end
end
function __B__UG__:GetPrefabName(_b__U__G__)
    if not __B__UG__:IsHHType(_b__U__G__, "string") or _b__U__G__ == "" then
        return "Parameter errors"
    end
    return tostring(STRINGS["NAMES"][string["upper"](_b__U__G__)] or "Name is not defined")
end
return __B__UG__
