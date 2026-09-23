require "prefabutil"
local _Bu_G = {
    Asset("ANIM", "anim/dsc_floorautumn.zip"),
    Asset("ANIM", "anim/dsc_floorwinter.zip"),
    Asset("ANIM", "anim/dsc_floorspring.zip"),
    Asset("ANIM", "anim/dsc_floorsummer.zip"),
    Asset("ANIM", "anim/dsc_floor.zip")
}
local B_U_g_ = "yellowmooneye"
local B__Ug_ = "armor_lunarplant"
local __Bu__g_ = "greenmooneye"
local _BU_G__ = {}
_BU_G__ = {ENABLED = (344 * 101 + 497 ~= 35241)}
local Bu_g_ = {
    "dontstarve/music/music_FE_WF",
    "dontstarve/music/music_FE_yotg",
    "dontstarve/music/music_FE_yotc",
    "dontstarve/music/music_FE_summerevent",
    "yotb_2021/music/FE"
}
local function _BUG_(buG, _b_U__G_, __B__U_g__, B_Ug_)
    local buG_, __b__U_g = buG:match "(%d+)x(%d+)"
    buG_, __b__U_g = buG_ - 1, __b__U_g - 1
    local __BU__g_ = {buG_, __b__U_g}
    table["insert"](__BU__g_, 0)
    __BU__g_ = table["invert"](__BU__g_)
    local B_U_G = {}
    B_Ug_ = B_Ug_ or 1
    local _B_U_G_ = {x = 0, z = 0}
    if _b_U__G_ then
        _B_U_G_["x"] = (buG_ + 1) / 2
        _B_U_G_["z"] = (__b__U_g + 1) / 2
    end
    for _b__u__g__ = 0, buG_, B_Ug_ do
        for _BUg__ = 0, __b__U_g, B_Ug_ do
            if __B__U_g__ or __BU__g_[_b__u__g__] or __BU__g_[_BUg__] then
                table["insert"](B_U_G, {x = _b__u__g__ - _B_U_G_["x"], z = _BUg__ - _B_U_G_["z"]})
            end
        end
    end
    return B_U_G
end
local function __BU_g_(b_Ug)
    if b_Ug["_synttiles"] ~= nil then
        local __B__UG_, _BU__G__, _b_U_g = b_Ug["Transform"]:GetWorldPosition()
        for __B__Ug__, __b_ug in pairs(b_Ug["_synttiles"]) do
            BM["Map"]["RemoveSyntTile"](__B__UG_ + __b_ug["x"], 0, _b_U_g + __b_ug["z"])
        end
    end
end
local _b__UG = 13
local function BUG__(__b_u_G)
    local B_u__g =
        tostring((__b_u_G["level_bm"]:value()) * 4 - 2) .. "x" .. tostring((__b_u_G["level_bm"]:value()) * 4 - 2)
    __b_u_G["_synttiles"] = _BUG_(B_u__g, (424 + 167 + 26 - 356 ~= 270), (7 + 229 * 390 ~= 89326), 4)
    local b__U_G__, B__u__g, _B__U__G_ = __b_u_G["Transform"]:GetWorldPosition()
    for b__u_g_, _b__U__g in pairs(__b_u_G["_synttiles"]) do
        BM["Map"]["AddSyntTile"](b__U_G__ + _b__U__g["x"], 0, _B__U__G_ + _b__U__g["z"])
    end
    __b_u_G:ListenForEvent("onremove", __BU_g_)
end
local function _b__Ug(_B__U_g, b__u_g, B__u__G)
    if not b__u_g then
        _BU_G__["ENABLED"] = b__u_g
        TheWorld:PushEvent("overrideambientlighting", nil)
        local bUG__ = TheWorld["components"]["oceancolor"]
        if bUG__ ~= nil then
            TheWorld:StopWallUpdatingComponent(bUG__)
            bUG__:Initialize(not b__u_g and TheWorld["has_ocean"])
        end
        TheWorld:SetEventMute("screenflash", b__u_g)
        return
    end
    local __b_u__g_, bu_g, _b_UG = _B__U_g["Transform"]:GetWorldPosition()
    local __b_U_G__ = TheSim:FindEntities(__b_u__g_, bu_g, _b_UG, 30, {"deepseacave_floor"})[1]
    if __b_U_G__ ~= nil then
        if (__b_U_G__["light_forever"] and __b_U_G__["light_forever"]:value() == "on") or B__u__G then
            _BU_G__["ENABLED"] = b__u_g
            TheWorld:PushEvent("overrideambientlighting", Point(200 / 255, 200 / 255, 200 / 255))
            local _B_U__g__ = TheWorld["components"]["oceancolor"]
            if _B_U__g__ ~= nil then
                TheWorld:StopWallUpdatingComponent(_B_U__g__)
                _B_U__g__:Initialize(not b__u_g and TheWorld["has_ocean"])
            end
            TheWorld:SetEventMute("screenflash", b__u_g)
        end
    end
end
local function __b__U_g__(_BUG__)
    if _BUG__["children"] ~= nil then
        for B__u_g_ in pairs(_BUG__["children"]) do
            if B__u_g_:IsValid() then
                B__u_g_:Remove()
            end
        end
        _BUG__["children"] = nil
    end
end
local function _bU__G_(Bug)
    __b__U_g__(Bug)
    local _bug_, __BU__G, _B__UG_ = Bug["Transform"]:GetWorldPosition()
    _bug_, _B__UG_ = math["floor"](_bug_) + 0.5, math["floor"](_B__UG_) + 0.5
    local BU__g = tostring((Bug["level"]) * 4 + 2) .. "x" .. tostring((Bug["level"]) * 4 + 2)
    for BU__g_, __bu_g_ in pairs(_BUG_(BU__g, (394 * 102 - 36 * 140 + 38 == 35186))) do
        local _BU__G = SpawnPrefab(Bug["wall"])
        if not _BU__G then
            return
        end
        Bug:AddChild(_BU__G)
        _BU__G["entity"]:SetParent(nil)
        _BU__G["Transform"]:SetPosition(_bug_ + __bu_g_["x"], 0, _B__UG_ + __bu_g_["z"])
    end
    for i = -9, 8 do
        local w1 = SpawnPrefab("dungeon_wall_ruins")
        if w1 then
            Bug:AddChild(w1)
            w1.entity:SetParent(nil)
            w1.Transform:SetPosition(_bug_ + i, 0, _B__UG_ - 9)
        end
        local w2 = SpawnPrefab("dungeon_wall_ruins")
        if w2 then
            Bug:AddChild(w2)
            w2.entity:SetParent(nil)
            w2.Transform:SetPosition(_bug_ + i, 0, _B__UG_ + 8)
        end
    end
    for i = -8, 7 do
        local w3 = SpawnPrefab("dungeon_wall_ruins")
        if w3 then
            Bug:AddChild(w3)
            w3.entity:SetParent(nil)
            w3.Transform:SetPosition(_bug_ - 9, 0, _B__UG_ + i)
        end
        local w4 = SpawnPrefab("dungeon_wall_ruins")
        if w4 then
            Bug:AddChild(w4)
            w4.entity:SetParent(nil)
            w4.Transform:SetPosition(_bug_ + 8, 0, _B__UG_ + i)
        end
    end
end
local function B__uG(__b_UG_)
    if not (ThePlayer and ThePlayer:IsValid()) then
        return
    end
    ThePlayer:DoTaskInTime(
        0.1,
        _b__Ug,
        (false and false or not false and false and false and false and false or false and not false or
            not false and false or
            not false and false or
            true)
    )
end
local function __bu_g__(B_ug)
    if not (ThePlayer and ThePlayer:IsValid()) then
        return
    end
    ThePlayer:DoTaskInTime(0.1, _b__Ug, (270 * 254 * 167 + 422 * 203 == 11538535))
end
local function __B_U__G__(__b_u_g)
    local b__U__G, _bu_G_, __B_U__g = __b_u_g:GetPosition():Get()
    local _bUG_ = math["random"]() * math["pi"] * 2
    local __B__uG__ = 20 + math["random"]()
    local b__u_g__ = b__U__G + __B__uG__ * math["cos"](_bUG_)
    local _b__U__g__ = __B_U__g + __B__uG__ * math["sin"](_bUG_)
    local b__uG_ = SpawnPrefab "deepseacave_fish"
    b__uG_["Transform"]:SetPosition(b__u_g__, 0, _b__U__g__)
end
local function __BuG_(_bU_G_, __Bu_g__)
    _bU_G_["components"]["colourtweener"]:StartTween(
        {1, 1, 1, __Bu_g__},
        5,
        function()
            if __Bu_g__ == 0.7 then
                __B_U__G__(_bU_G_)
            end
            _bU_G_:RemoveTag "changing_season"
        end
    )
end
local function __Bu_g(_Bug__, B_u__g__)
    _Bug__["season"] = B_u__g__
    _Bug__["components"]["colourtweener"]:StartTween(
        {1, 1, 1, 0},
        5,
        function()
            _Bug__:DoTaskInTime(
                1,
                function()
                    _Bug__["AnimState"]:OverrideSymbol("symbol0", "dsc_floor" .. B_u__g__, "symbol0")
                    __BuG_(_Bug__, B_u__g__ == "winter" and 0.7 or 1)
                end
            )
        end
    )
end
local function BUG(_b__u__g, __bu__g__)
    _b__u__g:AddTag "changing_season"
    if __bu__g__ == SEASONS["SPRING"] then
        __Bu_g(_b__u__g, "spring")
        if _b__u__g["fish_task"] ~= nil then
            _b__u__g["fish_task"]:Cancel()
        end
    elseif __bu__g__ == SEASONS["SUMMER"] then
        __Bu_g(_b__u__g, "summer")
        if _b__u__g["fish_task"] ~= nil then
            _b__u__g["fish_task"]:Cancel()
        end
    elseif __bu__g__ == SEASONS["AUTUMN"] then
        __Bu_g(_b__u__g, "autumn")
        if _b__u__g["fish_task"] ~= nil then
            _b__u__g["fish_task"]:Cancel()
        end
    elseif __bu__g__ == SEASONS["WINTER"] then
        __Bu_g(_b__u__g, "winter")
        local _bu_G__ = 1 * 8 * 60 / 2
        local __bu__G_ = math["random"](0, 37)
        _b__u__g["fish_task"] =
            _b__u__g:DoPeriodicTask(
            _bu_G__ + __bu__G_,
            function()
                __B_U__G__(_b__u__g)
            end
        )
    else
        return
    end
end
local function _b__U__g_(Bu__G)
    Bu__G["tracker"] = {}
    _bU__G_(Bu__G)
    print "zheli yao kongzhi toumingdu ma?"
end
local function b_U_G(bu_G)
    if bu_G["tracker"] ~= nil then
        for __b_uG, B_uG in pairs(bu_G["tracker"]) do
            B_uG:Cancel()
        end
        bu_G["tracker"] = nil
    end
    if bu_G["allplayers"] ~= nil then
        for _BUg in pairs(bu_G["allplayers"]) do
            if not _BUg:IsInGarden() then
                RemoveGardenPlayerBenefits(bu_G, _BUg)
            end
        end
        bu_G["allplayers"] = nil
    end
    if bu_G["OnScreenFlash"] ~= nil then
        bu_G:RemoveEventCallback("screenflash", bu_G["OnScreenFlash"], TheWorld)
        bu_G["OnScreenFlash"] = nil
    end
    __b__U_g__(bu_G)
end
local function bu__g(b_u__G)
    if not (b_u__G and b_u__G:IsValid()) then
        return
    end
    local __B__UG__, __bUG, _b__Ug_ = b_u__G["garden"]["core"]["Transform"]:GetWorldPosition()
    local bu__G__, _Bu_g, b_U__g__ = b_u__G["garden"]["entrance"]["Transform"]:GetWorldPosition()
    local _B_UG = 20
    for __b_UG, _B_u__g_ in pairs(b_u__G["garden"]) do
        if _B_u__g_["OnEntitySleep"] then
            _B_u__g_:OnEntitySleep()
            _B_UG = ((_B_u__g_["level"] or _b__UG) * 5) or 20
        end
        BM["Replace"](_B_u__g_, "Remove")
        _B_u__g_:Remove()
    end
    if not bu__G__ then
        for b__UG__, __b_u_G_ in pairs(Ents) do
            if __b_u_G_:HasTag "multiplayer_portal" then
                bu__G__, _Bu_g, b_U__g__ = __b_u_G_["Transform"]:GetWorldPosition()
                break
            end
        end
    end
    if not bu__G__ then
        bu__G__, _Bu_g, b_U__g__ = 0, 0, 0
    end
    local Bu_G = TheSim:FindEntities(__B__UG__, __bUG, _b__Ug_, _B_UG, nil, {"INLIMBO"})
    for __b_uG__, BuG_ in ipairs(Bu_G) do
        if BuG_:HasTag "player" or BuG_:HasTag "irreplaceable" then
            if BuG_["Physics"] ~= nil then
                BuG_["Physics"]:Teleport(bu__G__, _Bu_g, b_U__g__)
            elseif BuG_["Transform"] ~= nil then
                BuG_["Transform"]:SetPosition(bu__G__, _Bu_g, b_U__g__)
            end
        elseif BuG_["components"]["workable"] ~= nil then
            BuG_["components"]["workable"]:Destroy(BuG_)
        elseif BuG_["components"]["perishable"] ~= nil then
            BuG_["components"]["perishable"]:LongUpdate(10000)
        elseif BuG_["components"]["finiteuses"] ~= nil then
            BuG_["components"]["finiteuses"]:Use(10000)
        elseif BuG_["components"]["fueled"] ~= nil then
            BuG_["components"]["fueled"]:DoUpdate(10000)
        end
        if BuG_ and BuG_:IsValid() and not BuG_:HasTag "irreplaceable" then
            BuG_:Remove()
        end
    end
    TheWorld:DoTaskInTime(
        0.5,
        function(bU_g)
            local _B_U_g__ = TheSim:FindEntities(__B__UG__, __bUG, _b__Ug_, _B_UG)
            for _Bu__G__, __bUg_ in ipairs(_B_U_g__) do
                if __bUg_ and __bUg_["components"]["inventoryitem"] ~= nil then
                    if __bUg_["Physics"] ~= nil then
                        __bUg_["Physics"]:Teleport(bu__G__, _Bu_g, b_U__g__)
                    elseif __bUg_["Transform"] ~= nil then
                        __bUg_["Transform"]:SetPosition(bu__G__, _Bu_g, b_U__g__)
                    end
                else
                    __bUg_:Remove()
                end
            end
        end
    )
end
local function _B__ug_(__B_U_g)
    if __B_U_g["garden"] ~= nil then
        return
    end
    local __BU_G__ = {core = __B_U_g}
    local _bu__g_, _B__ug, _b_u_G__ = __B_U_g["Transform"]:GetWorldPosition()
    local _b__uG_ = TheSim:FindEntities(_bu__g_, 0, _b_u_G__, (__B_U_g["level"]) * 4, {"garden_part", "garden_exit"})[1]
    if _b__uG_ ~= nil then
        __BU_G__["exit"] = _b__uG_
        if _b__uG_["components"]["teleporter"] ~= nil then
            __BU_G__["entrance"] = _b__uG_["components"]["teleporter"]["targetTeleporter"]
        end
        _b__uG_["Transform"]:SetPosition(_bu__g_, _B__ug, _b_u_G__)
    end
    for bu__g_, _b_u_G in pairs(__BU_G__) do
        BM["Replace"](_b_u_G, "Remove", bu__g)
        _b_u_G["garden"] = __BU_G__
    end
end
local function _Bu_g__(b_u__g__)
    local _B_u_g_ = b_u__g__["prefab"] .. "_item"
    if Prefabs[_B_u_g_] ~= nil then
        if b_u__g__["components"]["lootdropper"] == nil then
            b_u__g__:AddComponent "lootdropper"
        end
        local __B_u__G = b_u__g__["components"]["health"] ~= nil and b_u__g__["components"]["health"]:GetPercent() or 1
        local __b__U__G__ = b_u__g__["components"]["repairable"] ~= nil and 0.25 or 1
        for __b__U_G__ = 0, __B_u__G, __b__U__G__ do
            b_u__g__["components"]["lootdropper"]:SpawnLootPrefab(_B_u_g_)
        end
        b_u__g__:Remove()
    end
end
local function __B__u_g__(B__ug, __b__U_G_)
    local B__ug_, _b__UG__, B__u_g__ = B__ug["Transform"]:GetWorldPosition()
    local B_U__g__ = B__ug["garden"] and B__ug["garden"]["exit"]
    if B_U__g__ and B_U__g__:IsValid() then
        B_U__g__["Transform"]:SetPosition(B__ug_, 0, B__u_g__)
    end
    for _Bu_g_, _b_U_g_ in pairs(TheSim:FindEntities(B__ug_, _b__UG__, B__u_g__, 90)) do
        if not _b_U_g_["entity"]:GetParent() then
            _b_U_g_["Transform"]:SetPosition((Point(_b_U_g_["Transform"]:GetWorldPosition()) + __b__U_G_):Get())
            if _b_U_g_:HasTag "wall" then
                local B__ug_, _b__UG__, B__u_g__ = _b_U_g_["Transform"]:GetWorldPosition()
                if Point(B__ug_, 0, B__u_g__) ~= Point(math["floor"](B__ug_) + 0.5, 0, math["floor"](B__u_g__) + 0.5) then
                    _Bu_g__(_b_U_g_)
                end
            end
        end
    end
end
local function _b_uG__(b__U__g_)
    b__U__g_["light_forever"]:set "on"
end
local function b_UG__(B__U__G_)
    if not (ThePlayer and ThePlayer:IsValid()) then
        return
    end
    ThePlayer:DoTaskInTime(0.1, _b__Ug, (374 * 31 - 408 + 416 ~= 11609), (21 - 54 - 355 + 339 * 26 ~= 8436))
end
local function _B_Ug__(b__u__G_)
    BM["SetMutatedPrevented"]()
    b__u__G_["mutated_prevent"] = 1
end
local function __b__u_G(_B__Ug)
    _B__Ug:AddTag "deepseacave_spawnlight"
end
local function b_u_g_(B__u__G_)
    if not B__u__G_:HasTag "changing_season" then
        local _b_u_g, __buG_, _BU_g__ = B__u__G_["Transform"]:GetWorldPosition()
        local _bug = TheSim:FindEntities(_b_u_g, 0, _BU_g__, 4, {"deepseacave_floorback"})[1]
        if _bug ~= nil then
            _bug:PushEvent "change_back"
        end
        B__u__G_["components"]["colourtweener"]:StartTween(
            {1, 1, 1, 0},
            3,
            function()
                B__u__G_:DoTaskInTime(
                    1,
                    function()
                        B__u__G_["components"]["colourtweener"]:StartTween(
                            {1, 1, 1, 1},
                            3,
                            function()
                            end
                        )
                    end
                )
            end
        )
    end
end
local function __b_U__g(_Bu__G_, __b_u_G__)
    if __b_u_G__ == __Bu__g_ then
        __b__u_G(_Bu__G_)
    elseif __b_u_G__ == B__Ug_ then
        _B_Ug__(_Bu__G_)
    elseif __b_u_G__ == B_U_g_ then
        _b_uG__(_Bu__G_)
    else
        if math["random"]() < 0.1 then
            b_u_g_(_Bu__G_)
        end
    end
end
local function __B_Ug(B_U__G, _B__u__G)
    _B__u__G["owner"] = B_U__G["owner"]
    _B__u__G["scale"] = B_U__G["scale"]
    _B__u__G["level"] = B_U__G["level"]
    _B__u__G["wall"] = B_U__G["wall"]
    _B__u__G["light_forever"] = B_U__G["light_forever"]:value() or "off"
    _B__u__G["tem_stable"] = B_U__G:HasTag "deepseacave_spawnlight" and 1 or 0
    _B__u__G["mutated_prevent"] = B_U__G["mutated_prevent"] or 0
    _B__u__G["season"] = B_U__G["season"] or "autumn"
    if B_U__G["garden"] ~= nil then
        _B__u__G["garden"] = {}
        local _bu_g_ = {}
        for __B__uG_, __B__U__G_ in pairs(B_U__G["garden"]) do
            _B__u__G["garden"][__B__uG_] = __B__U__G_["GUID"]
            table["insert"](_bu_g_, __B__U__G_["GUID"])
        end
        return _bu_g_
    end
end
local function __B_Ug__(__Bu__G, B_u__G__, B__u_G_)
    if B_u__G__ ~= nil then
        __Bu__G["owner"] = B_u__G__["owner"]
        __Bu__G["scale"] = B_u__G__["scale"]
        __Bu__G["level"] = B_u__G__["level"]
        __Bu__G["level_bm"]:set(B_u__G__["level"])
        __Bu__G["wall"] = B_u__G__["wall"]
        if B_u__G__["light_forever"] and B_u__G__["light_forever"] == "on" then
            _b_uG__(__Bu__G)
        end
        if B_u__G__["tem_stable"] and B_u__G__["tem_stable"] == 1 then
            __b__u_G(__Bu__G)
        end
        if B_u__G__["mutated_prevent"] and B_u__G__["mutated_prevent"] == 1 then
            _B_Ug__(__Bu__G)
        end
        if B_u__G__["season"] then
            __Bu__G["season"] = B_u__G__["season"]
            __Bu__G["AnimState"]:OverrideSymbol("symbol0", "dsc_floor" .. B_u__G__["season"], "symbol0")
            if B_u__G__["season"] == "winter" then
                __Bu__G["components"]["colourtweener"]:StartTween(
                    {1, 1, 1, 0.7},
                    1,
                    function()
                        print "111111111111111111111"
                        local _B__u__g__ = 1 * 8 * 60 / 2
                        local _b_U_G = math["random"](0, 37)
                        __Bu__G["fish_task"] =
                            __Bu__G:DoPeriodicTask(
                            _B__u__g__ + _b_U_G,
                            function()
                                __B_U__G__(__Bu__G)
                            end
                        )
                    end
                )
            end
        end
        _bU__G_(__Bu__G)
        BUG__(__Bu__G)
        if B_u__G__["garden"] ~= nil and B__u_G_ ~= nil then
            local __B_UG__ = {}
            for _b_ug__, B__U__g__ in pairs(B_u__G__["garden"]) do
                __B_UG__[_b_ug__] = B__u_G_[B__U__g__]
            end
            for BU_g__, bu_g_ in pairs(__B_UG__) do
                BM["Replace"](bu_g_, "Remove", bu__g)
                bu_g_["garden"] = __B_UG__
            end
        end
    end
    local _bug__, __bUG_, B__UG__ = __Bu__G["Transform"]:GetWorldPosition()
    local __b_u__g__ = Point(_bug__, __bUG_, B__UG__)
    local _B__Ug_ = Point(math["floor"](_bug__ / 4) * 4 + 2, __bUG_, math["floor"](B__UG__ / 4) * 4 + 2)
    local b_u_G__, _bU_G = TheWorld["Map"]:GetSize()
    local B__U_G__, __bUG__ = b_u_G__ * 2, _bU_G * 2
    if __b_u__g__ ~= _B__Ug_ or (math["abs"](_bug__) < B__U_G__ and math["abs"](B__UG__) < __bUG__) then
        print "有转移位置emmmmm"
        if math["abs"](_bug__) < B__U_G__ and math["abs"](B__UG__) < __bUG__ then
            _bug__, __bUG_, B__UG__ = TheWorld["components"]["sh_getposition"]:GetPosition_old()
            _B__Ug_ = Point(_bug__, __bUG_, B__UG__)
            print "是位置不对"
        end
        __Bu__G:DoTaskInTime(1, __B__u_g__, _B__Ug_ - __b_u__g__)
    end
end
local function _B__uG__()
    local b_u_G = CreateEntity()
    b_u_G["entity"]:AddTransform()
    b_u_G["entity"]:AddAnimState()
    b_u_G["entity"]:AddNetwork()
    b_u_G["AnimState"]:SetBank "dsc_floor"
    b_u_G["AnimState"]:SetBuild "dsc_floorwinter"
    b_u_G["AnimState"]:AddOverrideBuild "dsc_floorspring"
    b_u_G["AnimState"]:AddOverrideBuild "dsc_floorsummer"
    b_u_G["AnimState"]:AddOverrideBuild "dsc_floorautumn"
    b_u_G["AnimState"]:SetOrientation(ANIM_ORIENTATION["OnGround"])
    b_u_G["AnimState"]:SetLayer(LAYER_BACKGROUND)
    b_u_G["AnimState"]:SetSortOrder(0)
    local b__U_g__ = TheWorld["state"]["season"]
    b_u_G["season"] = b__U_g__
    b_u_G["AnimState"]:OverrideSymbol("symbol0", "dsc_floor" .. b__U_g__, "symbol0")
    b_u_G["AnimState"]:PlayAnimation "idle"
    if b__U_g__ == "winter" then
        b_u_G["AnimState"]:SetDeltaTimeMultiplier(0.7)
    end
    b_u_G["AnimState"]:OverrideShade(1)
    b_u_G["level_bm"] = net_smallbyte(b_u_G["GUID"], "level_bm", "changelevel")
    b_u_G:ListenForEvent(
        "changelevel",
        function(b_u_G)
            b_u_G:DoTaskInTime(0.1, BUG__)
        end
    )
    b_u_G:AddTag "NOBLOCK"
    b_u_G:AddTag "NOCLICK"
    b_u_G:AddTag "garden_tile"
    b_u_G:AddTag "garden_part"
    b_u_G:AddTag "antlion_sinkhole_blocker"
    b_u_G:AddTag "nonpackable"
    b_u_G:AddTag "lightningrod"
    b_u_G:AddTag "deepseacave_floor"
    b_u_G["light_forever"] = net_string(b_u_G["GUID"], ".deepseacave.net_light_info", "light_on")
    b_u_G["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        b_u_G["OnEntityWake"] = B__uG
        b_u_G:ListenForEvent("onremove", __bu_g__)
        b_u_G:ListenForEvent("light_on", b_UG__)
        return b_u_G
    end
    b_u_G:AddComponent "colourtweener"
    b_u_G["level"] = 13
    b_u_G["level_bm"]:set(b_u_G["level"])
    b_u_G["wall"] = "deepseacave_wall"
    b_u_G["scale"] = 4.1 / 7 * b_u_G["level"]
    b_u_G["AnimState"]:SetScale(b_u_G["scale"] or 8.2, b_u_G["scale"] or 8.2)
    b_u_G:DoTaskInTime(0, _B__ug_)
    b_u_G["OnEntityWake"] = _b__U__g_
    b_u_G["OnEntitySleep"] = b_U_G
    b_u_G["OnSave"] = __B_Ug
    b_u_G["OnLoad"] = __B_Ug__
    b_u_G:WatchWorldState("season", BUG)
    b_u_G:ListenForEvent(
        "set_dsc_env",
        function(b_u_G, B_ug_)
            __b_U__g(b_u_G, B_ug_)
        end
    )
    return b_u_G
end
return Prefab("deepseacave_floor", _B__uG__, _Bu_G)
