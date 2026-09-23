local B_u_g = require "utils/hh_utils"

local function ResolveKillCreditPlayer(attacker)
    return attacker ~= nil and B_u_g:GetKillCreditPlayer(attacker) or nil
end

local function __B_u_G(BU_G_)
    if BU_G_["components"]["commander"] then
        for BU_g_, Bu__g_ in ipairs(BU_G_["components"]["commander"]:GetAllSoldiers()) do
            if Bu__g_:IsAsleep() then
                Bu__g_:Remove()
            end
        end
    end
    BU_G_:Remove()
end
local function _b__u_G(__b_UG_)
    if __b_UG_["_sleeptask"] ~= nil then
        __b_UG_["_sleeptask"]:Cancel()
    end
    __b_UG_["_sleeptask"] = not (__b_UG_["components"]["health"] and __b_UG_["components"]["health"]:IsDead()) and __b_UG_:DoTaskInTime(10, __B_u_G) or nil
end

local function bu__g_(b__ug, b__uG__)
    if not B_u_g:IsHHType(b__uG__, "table") or not b__ug or b__ug["hh_treasure_fx"] then
        return
    end
    b__ug["hh_treasure_fx"] = SpawnPrefab "hh_treasure_text"
    if b__ug["hh_treasure_fx"] and b__ug["hh_treasure_fx"]["entity"] then
        b__ug["hh_treasure_fx"]["entity"]:SetParent(b__ug["entity"])
        if b__ug["hh_treasure_fx"]["SetTreasureStr"] then
            b__ug["hh_treasure_fx"]:SetTreasureStr(B_u_g:TableToStr(b__uG__))
        end
    end
    b__ug["hh_is_treasure"] = (184 * 222 - 264 - 130 - 368 ~= 40092)
end
local function _b__UG(__bU__g, _b__ug_)
    local __BU_G__ = math["random"]() * 4 + 2
    _b__ug_ = (_b__ug_ + math["random"]() * 60 - 30) * DEGREES
    __bU__g["Physics"]:SetVel(
        __BU_G__ * math["cos"](_b__ug_),
        math["random"]() * 2 + 8,
        __BU_G__ * math["sin"](_b__ug_)
    )
end
local function _b_ug_(_bU__g_)
    return B_u_g:HasComponents(_bU__g_, "container") and _bU__g_["components"]["container"]:IsFull()
end
local function _B_u__G_(b__UG_, b_UG__)
    if not b__UG_ or not b__UG_["Transform"] or not B_u_g:IsHHType(b_UG__, "string") then
        return
    end
    local _b__Ug_ = SpawnPrefab(b_UG__)
    if _b__Ug_ and _b__Ug_["Transform"] then
        local b__U__G__, B_u__g_, __B_U__G_ = b__UG_["Transform"]:GetWorldPosition()
        _b__Ug_["Transform"]:SetPosition(b__U__G__, B_u__g_, __B_U__G_)
    end
end
local function __B__ug_(bUg, __bu__g_)
    if not bUg or not bUg["Transform"] then
        return
    end
    local __b_u_G, _B_ug, B_Ug_ = bUg["Transform"]:GetWorldPosition()
    local _b_ug = SpawnPrefab "treasurechest"
    if _b_ug and _b_ug["Transform"] then
        _b_ug["Transform"]:SetPosition(__b_u_G, _B_ug, B_Ug_)
        _B_u__G_(_b_ug, "explode_firecrackers")
        if B_u_g:IsHHType(__bu__g_, "table") and B_u_g:HasComponents(_b_ug, "container") then
            for _B_u_g__, B_U_g__ in ipairs(__bu__g_) do
                if _b_ug_(_b_ug) then
                    break
                end
                if B_U_g__ and B_U_g__["type"] then
                    local _b_u_G = B_U_g__
                    local __BU__g_ = B_U_g__["type"]
                    if __BU__g_ == "stone" and _b_u_G["effect"] then
                        local _b__ug__ = HHSpawnStoneById(_b_u_G["effect"])
                        if _b__ug__ then
                            local B_Ug__ = _b_ug:GetPosition()
                            _b_ug["components"]["container"]:GiveItem(_b__ug__, nil, B_Ug__)
                        end
                    end
                    if __BU__g_ == "equip" and _b_u_G["prefab_id"] then
                    end
                    if __BU__g_ == "item" and _b_u_G["prefab_id"] then
                        local _B__u_g_ = _b_u_G["prefab_id"]
                        local BU__G__ = SpawnPrefab(_B__u_g_)
                        if BU__G__ and BU__G__["Transform"] then
                            if B_u_g:HasComponents(BU__G__, "inventoryitem") then
                                if
                                    B_u_g:HasComponents(BU__G__, "stackable") and
                                        B_u_g:IsHHType(_b_u_G["num"], "number") and
                                        _b_u_G["num"] > 0 and
                                        B_u_g:HasComponents(BU__G__, "inventoryitem")
                                 then
                                    local _b__U_g_ = _b_u_G["num"]
                                    local bug = BU__G__["components"]["stackable"]["maxsize"] or 1
                                    BU__G__["components"]["stackable"]:SetStackSize(math["min"](_b__U_g_, bug))
                                end
                                local __B__ug = _b_ug:GetPosition()
                                _b_ug["components"]["container"]:GiveItem(BU__G__, nil, __B__ug)
                            else
                                BU__G__["Transform"]:SetPosition(__b_u_G, 0, B_Ug_)
                            end
                        end
                    end
                end
            end
        end
    end
end
local function _B_U__g__(_bu__G, b__U_G)
    if not B_u_g:IsHHType(b__U_G, "table") or not _bu__G then
        return
    end
    _bu__G["components"]["hh_monster"]:SetMaxEffectLimit(#b__U_G)
    for __bUg__, __B_Ug in ipairs(b__U_G) do
        _bu__G["components"]["hh_monster"]:AddBuffByName(__B_Ug)
    end
end
local function __b_U_G_(__b__Ug_, __bU__g_)
    if not __bU__g_ or ResolveKillCreditPlayer(__bU__g_["attacker"]) == nil then
        return
    end
    if not __b__Ug_ or not __b__Ug_["Transform"] then
        return
    end
    local _b__Ug = math["random"]()
    local _b_u__g = nil
    if _b__Ug < 0.005 then
        _b_u__g = HHSpawnRareEffectStone()
    elseif _b__Ug < 0.02 then
        _b_u__g = HHSpawnGoodEffectStone()
    elseif _b__Ug < 0.1 then
        _b_u__g = HHSpawnComEffectStone()
    end
    if _b_u__g and _b_u__g["Transform"] then
        local b_U__g__ = math["random"](1, 360)
        local _bu__g__, b_u_G__, BU_G__ = __b__Ug_["Transform"]:GetWorldPosition()
        _b_u__g["Transform"]:SetPosition(_bu__g__, 2.5, BU_G__)
        _b__UG(_b_u__g, b_U__g__)
    end
end
local function __bu_g__(bU__G_)
    if not B_u_g:IsHHType(bU__G_, "number") then
        return (337 - 324 - 471 - 340 ~= -798)
    end
    local b_U__G_ = math["random"]()
    return b_U__G_ <= bU__G_
end
local function b_u_g_(__b__u_G)
    if B_u_g:HasComponents(__b__u_G, "lootdropper") then
        __b__u_G["components"]["lootdropper"]:SetLoot(nil)
        __b__u_G["components"]["lootdropper"]:SetChanceLootTable "hh_treasure_monster"
    end
end
local function _b__u_g__(_buG_, Bu_g__)
    if not _buG_ or not B_u_g:IsHHType(Bu_g__, "number") or Bu_g__ <= 0 then
        return
    end
    local B__UG_ = _buG_["components"]["health"]:GetPercent()
    if B__UG_ > 0 then
        _buG_["components"]["health"]:SetMaxHealth(Bu_g__)
        _buG_["components"]["health"]:SetPercent(math["min"](B__UG_, 1))
    end
end
local function _B__U__G_(b_u_g__)
    if b_u_g__ and b_u_g__["Physics"] then
        b_u_g__["Physics"]:ClearCollisionMask()
        b_u_g__["Physics"]:CollidesWith(COLLISION["GROUND"])
        b_u_g__["Physics"]:CollidesWith(COLLISION["OBSTACLES"])
        b_u_g__["Physics"]:CollidesWith(COLLISION["SMALLOBSTACLES"])
        b_u_g__["Physics"]:CollidesWith(COLLISION["CHARACTERS"])
        b_u_g__["Physics"]:CollidesWith(COLLISION["GIANTS"])
    end
end
local function _B__u__g_(buG__, _b_U_G)
    if not buG__ or not buG__["Transform"] then
        return
    end
    local B_ug = HHSpawnStoneById(_b_U_G)
    if B_ug then
        local bug_, __BUG, _B_U_g__ = buG__["Transform"]:GetWorldPosition()
        B_ug["Transform"]:SetPosition(bug_, 2.5, _B_U_g__)
        _b__UG(B_ug, math["random"](1, 360))
    end
end
local function b__U__G(__b_u__g, bU_g)
    if not __b_u__g then
        return
    end
    local __bU_G = __b_u__g["name"] or __b_u__g["prefab"]
    local b_Ug = math["random"]()
    local plain_boss_name = "★ " .. string.upper(tostring(bU_g)) .. " ★"

    if b_Ug < 0.10 then
        B_u_g:NetSay(string["format"]("%s đã giết %s và nhận 1 viên [★★ Châu Báu Siêu Hiếm ★★]", tostring(__bU_G), plain_boss_name))
    else
        B_u_g:NetSay(string["format"]("%s đã giết %s và nhận 1 viên [★ Châu Báu Hiếm ★]", tostring(__bU_G), plain_boss_name))
    end
    
    B_u_g:NetSay(string["format"]("%s đã chết và rơi 1 viên [★★ Đá Thuộc Tính Siêu Hiếm ★★]", plain_boss_name))

    if b_Ug < 0.01 then
        __b_u__g["components"]["hh_player"]:AddItemsByKey("elementBead", 1, true)
    elseif b_Ug < 0.02 then
        __b_u__g["components"]["hh_player"]:AddItemsByKey("baconOmeletteTrueDamage", 1, true)
    elseif b_Ug < 0.03 then
        __b_u__g["components"]["hh_player"]:AddItemsByKey("baconOmeletteBlessAtk", 1, true)
    elseif b_Ug < 0.04 then
        __b_u__g["components"]["hh_player"]:AddItemsByKey("baconOmeletteBlessCritical", 1, true)
    elseif b_Ug < 0.05 then
        __b_u__g["components"]["hh_player"]:AddItemsByKey("baconOmeletteBlessArmor", 1, true)
    elseif b_Ug < 0.06 then
        __b_u__g["components"]["hh_player"]:AddItemsByKey("baconOmeletteFire", 1, true)
    elseif b_Ug < 0.07 then
        __b_u__g["components"]["hh_player"]:AddItemsByKey("baconOmeletteSpeed", 1, true)
    elseif b_Ug < 0.08 then
        __b_u__g["components"]["hh_player"]:AddItemsByKey("baconOmeletteAOE", 1, true)
    elseif b_Ug < 0.09 then
        __b_u__g["components"]["hh_player"]:AddItemsByKey("baconOmeletteDodge", 1, true)
    elseif b_Ug < 0.10 then
        __b_u__g["components"]["hh_player"]:AddItemsByKey("baconOmeletteKill", 1, true)
    elseif b_Ug < 0.28 then
        __b_u__g["components"]["hh_player"]:AddItemsByKey("strideBead", 1, true)
    elseif b_Ug < 0.46 then
        __b_u__g["components"]["hh_player"]:AddItemsByKey("treasure_armor", 1, true)
    elseif b_Ug < 0.64 then
        __b_u__g["components"]["hh_player"]:AddItemsByKey("treasure_bj", 1, true)
    elseif b_Ug < 0.82 then
        __b_u__g["components"]["hh_player"]:AddItemsByKey("treasure_atk", 1, true)
    else
        __b_u__g["components"]["hh_player"]:AddItemsByKey("treasure_fireGem", 1, true)
    end
end
local function __bu_g(_b__U__G__)
    if not B_u_g:HasComponents(_b__U__G__, "health") then
        return
    end
    local __b__Ug__ = _b__U__G__["components"]["health"]
    local b__uG_ = __b__Ug__["SetVal"]
    __b__Ug__["SetVal"] = function(self, __Bu__g_, B__UG__, B_u_g_, ...)
        local credited_player = ResolveKillCreditPlayer(B_u_g_)
        if credited_player == nil then
            return
        end
        if not B_u_g:IsHHType(__Bu__g_, "number") then
            return
        end
        local B__ug_ = self["currenthealth"]
        if __Bu__g_ > 0 and __Bu__g_ < B__ug_ and B__ug_ > 0 then
            __Bu__g_ = math["max"](B__ug_ - 1000, 0)
            self["inst"]:PushEvent("hh_kps_health_delta", {["attacker"] = credited_player})
        end
        if b__uG_ then
            b__uG_(self, __Bu__g_, B__UG__, B_u_g_, ...)
        end
    end
end
local function __CatYouAttacked(hh_inst, data)
    local player = data ~= nil and ResolveKillCreditPlayer(data["attacker"]) or nil
    if player == nil then
        return
    end
    if not hh_inst or not hh_inst["Transform"] then
        return
    end
    if player and player["components"]["health"] and not player["components"]["health"]:IsDead() then
        local b_Ug = math["random"]()
        if b_Ug < 0.03 then
            player["components"]["hh_player"]:AddItemsByKey("treasure_atk", 1, true)
        elseif b_Ug < 0.06 then
            player["components"]["hh_player"]:AddItemsByKey("treasure_bj", 1, true)
        elseif b_Ug < 0.09 then
            player["components"]["hh_player"]:AddItemsByKey("treasure_armor", 1, true)
        elseif b_Ug < 0.12 then
            player["components"]["hh_player"]:AddItemsByKey("strideBead", 1, true)
        elseif b_Ug < 0.15 then
            player["components"]["hh_player"]:AddItemsByKey("treasure_fireGem", 1, true)
        elseif b_Ug < 0.17 then
            player["components"]["hh_player"]:AddItemsByKey("opalpreciousgem", 1, true)
        elseif b_Ug < 0.22 then
            player["components"]["hh_player"]:AddItemsByKey("orangegem", 1, true)
        elseif b_Ug < 0.27 then
            player["components"]["hh_player"]:AddItemsByKey("yellowgem", 1, true)
        elseif b_Ug < 0.32 then
            player["components"]["hh_player"]:AddItemsByKey("greengem", 1, true)
        elseif b_Ug < 0.40 then
            player["components"]["hh_player"]:AddItemsByKey("bluegem", 1, true)
        elseif b_Ug < 0.48 then
            player["components"]["hh_player"]:AddItemsByKey("redgem", 1, true)
        elseif b_Ug < 0.56 then
            player["components"]["hh_player"]:AddItemsByKey("purplegem", 1, true)
        end
    end
end
local B_u__g__ = {
    ["treasure_kps"] = {
        ["start_fn"] = function(__bu__G__)
            __bu__G__["name"] = "Super Krampus"
            if __bu__G__["components"] and __bu__G__["components"]["named"] then
                __bu__G__["components"]["named"]:SetName("Super Krampus")
            end
            __bu__G__["AnimState"]:SetSymbolMultColour("krampus_bag", 255 / 255, 229 / 255, 0 / 255, 1)
            _b__u_g__(__bu__G__, 1000000)
            bu__g_(
                __bu__G__,
                {["name"] = "Super Krampus", ["color"] = {255 / 255, 61 / 255, 0 / 255}, ["pos"] = {0, 5, 0}}
            )
            _B_U__g__(
                __bu__G__,
                {
                    "addComDamageNum",
                    "addComDamageNum",
                    "addComDamagePercent",
                    "addCriticalHitRate",
                    "addReduceAttackedDamage",
                    "addReduceAttackedDamage",
                    "immuneTearing"
                }
            )
            b_u_g_(__bu__G__)
            __bu_g(__bu__G__)
            __bu__G__["hh_is_treasure_kps"] = (193 - 420 * 483 ~= -202660)
            __bu__G__["OnEntitySleep"] = _b__u_G
            __bu__G__:ListenForEvent("hh_kps_health_delta", __b_U_G_)
            __bu__G__:ListenForEvent(
                "death",
                function(_B__ug_, B_UG_)
                    local __b__U__g = B_UG_ ~= nil and ResolveKillCreditPlayer(B_UG_["afflicter"]) or nil
                    if __b__U__g ~= nil then
                        local _b__UG__ = __b__U__g["name"] or __b__U__g["prefab"]
                        B_u_g:NetSay(
                            string["format"](
                                "%s đã giết Super Krampus và nhận 3 viên Châu Báu hiếm",
                                tostring(_b__UG__)
                            )
                        )
                        __b__U__g["components"]["hh_player"]:AddItemsByKey(
                            "strideBead",
                            1,
                            (418 * 258 * 184 * 175 == 3472576800)
                        )
                        __b__U__g["components"]["hh_player"]:AddItemsByKey(
                            "strideBead",
                            1,
                            (false or false or not false and not false or
                                not false and not false and not false and not false and false and true or
                                false or
                                not false and not true)
                        )
                        __b__U__g["components"]["hh_player"]:AddItemsByKey(
                            "strideBead",
                            1,
                            (129 - 415 * 264 * 447 + 310 == -48972881)
                        )
                    end
                end
            )
        end,
        ["death_fn"] = function(__B_uG__)
            B_u_g:HHRemoveFx(__B_uG__, "hh_treasure_fx")
            local b__u__G_ = SpawnPrefab "krampus_sack"
            if b__u__G_ and __B_uG__["Transform"] then
                local bu_g, _BU__g_, __B__U__G_ = __B_uG__["Transform"]:GetWorldPosition()
                b__u__G_["Transform"]:SetPosition(bu_g, 2.5, __B__U__G_)
                _b__UG(b__u__G_, math["random"](1, 360))
            end
        end
    },
    ["treasure_cat_you"] = {
        ["start_fn"] = function(__bu__G__)
            __bu__G__["name"] = "Siêu Mèo Thần Tài"
            if __bu__G__["components"] and __bu__G__["components"]["named"] then
                __bu__G__["components"]["named"]:SetName("Siêu Mèo Thần Tài")
            end
            __bu__G__["AnimState"]:SetBuild("ticoon_build")
            _b__u_g__(__bu__G__, 1000000)
            bu__g_(
                __bu__G__,
                {["name"] = "Siêu Mèo Thần Tài", ["color"] = {255 / 255, 61 / 255, 0 / 255}, ["pos"] = {0, 5, 0}}
            )
            _B_U__g__(
                __bu__G__,
                {
                    "addComDamageNum",
                    "addComDamageNum",
                    "addComDamagePercent",
                    "addCriticalHitRate",
                    "addReduceAttackedDamage",
                    "addReduceAttackedDamage",
                    "immuneTearing"
                }
            )
            if __bu__G__["Transform"] then
                __bu__G__["Transform"]:SetScale(3, 3, 3)
            end
            b_u_g_(__bu__G__)
            __bu_g(__bu__G__)
            __bu__G__["hh_is_treasure_kps"] = (193 - 420 * 483 ~= -202660)
            __bu__G__["OnEntitySleep"] = _b__u_G
            __bu__G__:ListenForEvent("hh_kps_health_delta", __CatYouAttacked)
            __bu__G__:ListenForEvent(
                "death",
                function(_B__ug_, B_UG_)
                    local __b__U__g = B_UG_ ~= nil and ResolveKillCreditPlayer(B_UG_["afflicter"]) or nil
                    if __b__U__g ~= nil then
                        local _b__UG__ = __b__U__g["name"] or __b__U__g["prefab"]
                        B_u_g:NetSay(
                            string["format"](
                                "%s đã giết Siêu Mèo Thần Tài và nhận 3 viên Châu Báu hiếm",
                                tostring(_b__UG__)
                            )
                        )
                        __b__U__g["components"]["hh_player"]:AddItemsByKey(
                            "strideBead",
                            1,
                            (418 * 258 * 184 * 175 == 3472576800)
                        )
                        __b__U__g["components"]["hh_player"]:AddItemsByKey(
                            "strideBead",
                            1,
                            (false or false or not false and not false or
                                not false and not false and not false and not false and false and true or
                                false or
                                not false and not true)
                        )
                        __b__U__g["components"]["hh_player"]:AddItemsByKey(
                            "strideBead",
                            1,
                            (129 - 415 * 264 * 447 + 310 == -48972881)
                        )
                    end
                end
            )
        end,
        ["death_fn"] = function(__B_uG__)
            B_u_g:HHRemoveFx(__B_uG__, "hh_treasure_fx")
            local b__u__G_ = SpawnPrefab("krampus_sack")
            if b__u__G_ and __B_uG__["Transform"] then
                local bu_g, _BU__g_, __B__U__G_ = __B_uG__["Transform"]:GetWorldPosition()
                b__u__G_["Transform"]:SetPosition(bu_g, 2.5, __B__U__G_)
                _b__UG(b__u__G_, math["random"](1, 360))
            end
        end
    },
    ["pig_tank"] = {
        ["start_fn"] = function(bu__G)
            bu__g_(
                bu__G,
                {
                    ["name"] = "Heo Chiến Binh",
                    ["color"] = {27 / 255, 255 / 255, 0 / 255},
                    ["pos"] = {0, 3.4, 0},
                    ["scale"] = 18
                }
            )
            _B_U__g__(
                bu__G,
                {
                    "addMaxHealthNum",
                    "addMaxHealthPercent",
                    "addReduceAttackedDamage",
                    "addHealth3sNum",
                    "addHealth5sNum",
                    "reducePercentDamage"
                }
            )
        end,
        ["death_fn"] = function(BU__g)
            B_u_g:HHRemoveFx(BU__g, "hh_treasure_fx")
        end
    },
    ["pig_attack"] = {
        ["start_fn"] = function(_b_u_G__)
            bu__g_(
                _b_u_G__,
                {
                    ["name"] = "Heo Tiên Phong",
                    ["color"] = {27 / 255, 255 / 255, 0 / 255},
                    ["pos"] = {0, 3.4, 0},
                    ["scale"] = 18
                }
            )
            _B_U__g__(
                _b_u_G__,
                {
                    "addComDamageNum",
                    "addComDamageNum",
                    "addComDamagePercent",
                    "atkChanceReduceSpeed",
                    "addCriticalHitRate"
                }
            )
        end,
        ["death_fn"] = function(__B_uG)
            B_u_g:HHRemoveFx(__B_uG, "hh_treasure_fx")
        end
    },
    ["pig_buff"] = {
        ["start_fn"] = function(B_u_G__)
            bu__g_(
                B_u_G__,
                {
                    ["name"] = "Heo Sát Thủ",
                    ["color"] = {27 / 255, 255 / 255, 0 / 255},
                    ["pos"] = {0, 3.4, 0},
                    ["scale"] = 18
                }
            )
            _B_U__g__(
                B_u_G__,
                {
                    "hitAddPoison",
                    "hitChanceAddFreeze",
                    "hitChanceReduceSpeed",
                    "reducePercentDamage"
                }
            )
        end,
        ["death_fn"] = function(bU__G)
            B_u_g:HHRemoveFx(bU__G, "hh_treasure_fx")
        end
    },
    ["pig_wsz"] = {
        ["start_fn"] = function(B__Ug_)
            bu__g_(
                B__Ug_,
                {
                    ["name"] = "Heo Béo",
                    ["color"] = {27 / 255, 255 / 255, 0 / 255},
                    ["pos"] = {0, 3.4, 0},
                    ["scale"] = 18
                }
            )
        end,
        ["death_fn"] = function(_b_u__g__)
            B_u_g:HHRemoveFx(_b_u__g__, "hh_treasure_fx")
        end
    },
    ["super_pig"] = {["start_fn"] = function(__B__U__G)
            bu__g_(
                __B__U__G,
                {["name"] = "Heo Đại Vương", ["color"] = {0, 0, 255}, ["pos"] = {0, 3.4, 0}, ["scale"] = 18}
            )
            _b__u_g__(__B__U__G, 8000)
        end, ["death_fn"] = function(__Bu__g)
            B_u_g:HHRemoveFx(__Bu__g, "hh_treasure_fx")
        end},
    ["walrus_adc"] = {
        ["start_fn"] = function(__B__uG)
            b_u_g_(__B__uG)
            _b__u_g__(__B__uG, 100000)
            _B_U__g__(
                __B__uG,
                {
                    "immuneTearing",
                    "addSuppressAddHealth",
                    "addCriticalHitRate",
                    "immuneFreeze",
                    "atkChanceReduceSpeed",
                    "atkAddPoison",
                    "addComDamageNum",
                    "addSpeedPercent"
                }
            )
            __B__uG["name"] = "Super Mactusk"
            if __B__uG["components"] and __B__uG["components"]["named"] then
                __B__uG["components"]["named"]:SetName("Super Mactusk")
            end
            bu__g_(
                __B__uG,
                {
                    ["name"] = "Super Mactusk",
                    ["color"] = {211 / 255, 0 / 255, 255 / 255},
                    ["pos"] = {0, 5, 0}
                }
            )
            __B__uG["OnEntitySleep"] = _b__u_G
        end,
        ["death_fn"] = function(_BU__G)
            B_u_g:HHRemoveFx(_BU__G, "hh_treasure_fx")
            if __bu_g__(0.25) then
                __B__ug_(_BU__G, {{["effect"] = "add_critical_hit_rate_special", ["type"] = "stone"}})
            else
                __B__ug_(_BU__G, {{["effect"] = "immune_debuff_2", ["type"] = "stone"}})
            end
        end
    },
    ["mutateddeerclops_boss"] = {
        ["start_fn"] = function(B_u_G)
            B_u_G["hh_is_treasure_boss"] = (49 * 233 * 41 == 468097)
            B_u_G["name"] = "Super Crystal Deerclops"
            if B_u_G["components"] and B_u_G["components"]["named"] then
                B_u_G["components"]["named"]:SetName("Super Crystal Deerclops")
            end
            b_u_g_(B_u_G)
            bu__g_(
                B_u_G,
                {
                    ["name"] = "Super Crystal Deerclops",
                    ["color"] = {255 / 255, 110 / 255, 0 / 255},
                    ["pos"] = {0, 10, 0}
                }
            )
            _b__u_g__(B_u_G, 300000)
            _B_U__g__(
                B_u_G,
                {
                    "immuneTearing",
                    "addComDamageNum",
                    "addComDamageNum",
                    "addComDamagePercent",
                    "immuneFreeze",
                    "addCriticalHitRate",
                    "addSuppressAddHealth",
                    "iceTurret",
                    "iceLaser",
                    "addHealthPercent10"
                }
            )
            B_u_G:ListenForEvent(
                "death",
                function(b__U__G_, _B_U__G__)
                    local b_u_G = _B_U__G__ ~= nil and ResolveKillCreditPlayer(_B_U__G__["afflicter"]) or nil
                    if b_u_G ~= nil then
                        b__U__G(b_u_G, "Super Crystal Deerclops")
                    end
                end
            )
            B_u_G["OnEntitySleep"] = _b__u_G
        end,
        ["death_fn"] = function(Bug__)
            B_u_g:HHRemoveFx(Bug__, "hh_treasure_fx")
            local bu__g__ = math["random"]()
            if bu__g__ <= 0.1 then
                _B__u__g_(Bug__, "restore_use_1s_2_percent")
            elseif bu__g__ <= 0.2 then
                _B__u__g_(Bug__, "armor_immune_amount")
            elseif bu__g__ <= 0.3 then
                _B__u__g_(Bug__, "add_critical_hit_rate_special")
            elseif bu__g__ <= 0.4 then
                _B__u__g_(Bug__, "true_damage_special")
            elseif bu__g__ <= 0.5 then
                _B__u__g_(Bug__, "true_damage_special")
            elseif bu__g__ <= 0.6 then
                _B__u__g_(Bug__, "atk_speed_special")
            elseif bu__g__ <= 0.7 then
                _B__u__g_(Bug__, "special_xwsh")
            elseif bu__g__ <= 0.8 then
                _B__u__g_(Bug__, "special_zqrf")
            elseif bu__g__ <= 0.9 then
                _B__u__g_(Bug__, "special_sgsy")
            elseif bu__g__ <= 1 then
                _B__u__g_(Bug__, "special_bhtg")
            end
        end
    },
    ["mutatedbearger_boss"] = {
        ["start_fn"] = function(_Bu_G__)
            _Bu_G__["hh_is_treasure_boss"] = (23 + 491 * 160 - 146 + 40 == 78477)
            _Bu_G__["name"] = "Super Armored Bearger"
            if _Bu_G__["components"] and _Bu_G__["components"]["named"] then
                _Bu_G__["components"]["named"]:SetName("Super Armored Bearger")
            end
            b_u_g_(_Bu_G__)
            bu__g_(
                _Bu_G__,
                {["name"] = "Super Armored Bearger", ["color"] = {255 / 255, 110 / 255, 0 / 255}, ["pos"] = {0, 10, 0}}
            )
            _b__u_g__(_Bu_G__, 300000)
            _B_U__g__(
                _Bu_G__,
                {
                    "immuneTearing",
                    "addComDamageNum",
                    "addComDamageNum",
                    "addComDamagePercent",
                    "immuneFreeze",
                    "addCriticalHitRate",
                    "addSuppressAddHealth",
                    "poisonTurret",
                    "iceLaser",
                    "addHealthPercent10"
                }
            )
            _Bu_G__:ListenForEvent(
                "death",
                function(B__U__g_, B__uG__)
                    local _B_u__G__ = B__uG__ ~= nil and ResolveKillCreditPlayer(B__uG__["afflicter"]) or nil
                    if _B_u__G__ ~= nil then
                        b__U__G(_B_u__G__, "Super Armored Bearger")
                    end
                end
            )
            _Bu_G__["OnEntitySleep"] = _b__u_G
        end,
        ["death_fn"] = function(b_ug__)
            B_u_g:HHRemoveFx(b_ug__, "hh_treasure_fx")
            local _B_U__g = math["random"]()
            if _B_U__g <= 0.1 then
                _B__u__g_(b_ug__, "restore_use_1s_2_percent")
            elseif _B_U__g <= 0.2 then
                _B__u__g_(b_ug__, "armor_immune_amount")
            elseif _B_U__g <= 0.3 then
                _B__u__g_(b_ug__, "add_critical_hit_rate_special")
            elseif _B_U__g <= 0.4 then
                _B__u__g_(b_ug__, "true_damage_special")
            elseif _B_U__g <= 0.5 then
                _B__u__g_(b_ug__, "true_damage_special")
            elseif _B_U__g <= 0.6 then
                _B__u__g_(b_ug__, "atk_speed_special")
            elseif _B_U__g <= 0.7 then
                _B__u__g_(b_ug__, "special_xwsh")
            elseif _B_U__g <= 0.8 then
                _B__u__g_(b_ug__, "special_zqrf")
            elseif _B_U__g <= 0.9 then
                _B__u__g_(b_ug__, "special_sgsy")
            elseif _B_U__g <= 1 then
                _B__u__g_(b_ug__, "special_bhtg")
            end
        end
    },
    ["mutatedwarg_boss"] = {
        ["start_fn"] = function(inst)
            inst["hh_is_treasure_boss"] = true
            inst.name = "Siêu Sói Vương"
            if inst.components.named then
                inst.components.named:SetName("Siêu Sói Vương")
            end
            b_u_g_(inst)
            bu__g_(
                inst,
                {["name"] = "Siêu Sói Vương", ["color"] = {255 / 255, 110 / 255, 0 / 255}, ["pos"] = {0, 10, 0}}
            )
            _b__u_g__(inst, 300000)
            _B_U__g__(
                inst,
                {
                    "immuneTearing",
                    "addComDamageNum",
                    "addComDamageNum",
                    "addComDamagePercent",
                    "immuneFreeze",
                    "addCriticalHitRate",
                    "addSuppressAddHealth",
                    "iceTurret",
                    "iceLaser",
                    "atkBlood",
                    "addHealthPercent10"
                }
            )
            inst:ListenForEvent(
                "death",
                function(_inst, data)
                    local player = data ~= nil and ResolveKillCreditPlayer(data["afflicter"]) or nil
                    if player ~= nil then
                        b__U__G(player, "Siêu Sói Vương")
                    end
                end
            )
            inst["OnEntitySleep"] = _b__u_G
        end,
        ["death_fn"] = function(inst)
            B_u_g:HHRemoveFx(inst, "hh_treasure_fx")
            local bUg_ = math["random"]()
            if bUg_ <= 0.1 then
                _B__u__g_(inst, "restore_use_1s_2_percent")
            elseif bUg_ <= 0.2 then
                _B__u__g_(inst, "armor_immune_amount")
            elseif bUg_ <= 0.3 then
                _B__u__g_(inst, "add_critical_hit_rate_special")
            elseif bUg_ <= 0.4 then
                _B__u__g_(inst, "true_damage_special")
            elseif bUg_ <= 0.5 then
                _B__u__g_(inst, "true_damage_special")
            elseif bUg_ <= 0.6 then
                _B__u__g_(inst, "atk_speed_special")
            elseif bUg_ <= 0.7 then
                _B__u__g_(inst, "special_xwsh")
            elseif bUg_ <= 0.8 then
                _B__u__g_(inst, "special_zqrf")
            elseif bUg_ <= 0.9 then
                _B__u__g_(inst, "special_sgsy")
            elseif bUg_ <= 1 then
                _B__u__g_(inst, "special_bhtg")
            end
        end
    },
    ["hh_beetle_pig_boss"] = {
        ["start_fn"] = function(inst)
            inst["hh_is_treasure_boss"] = true
            inst["name"] = "Siêu Lợn Bọ Hung"
            if inst["components"] and inst["components"]["named"] then
                inst["components"]["named"]:SetName("Siêu Lợn Bọ Hung")
            end
            bu__g_(
                inst,
                {["name"] = "Siêu Lợn Bọ Hung", ["color"] = {255 / 255, 110 / 255, 0 / 255}, ["pos"] = {0, 10, 0}}
            )
            _b__u_g__(inst, 500000)
            _B_U__g__(
                inst,
                {
                    "immuneTearing",
                    "addComDamageNum",
                    "addComDamageNum",
                    "addComDamagePercent",
                    "immuneFreeze",
                    "addCriticalHitRate",
                    "addSuppressAddHealth",
                    "poisonTurret",
                    "addHealthPercent10"
                }
            )
            inst:ListenForEvent(
                "death",
                function(_inst, data)
                    local player = data ~= nil and ResolveKillCreditPlayer(data["afflicter"]) or nil
                    if player ~= nil then
                        b__U__G(player, "Siêu Lợn Bọ Hung")
                    end
                end
            )
            inst["OnEntitySleep"] = _b__u_G
        end,
        ["death_fn"] = function(inst)
            B_u_g:HHRemoveFx(inst, "hh_treasure_fx")
            local bUg_ = math["random"]()
            if bUg_ <= 0.1 then
                _B__u__g_(inst, "restore_use_1s_2_percent")
            elseif bUg_ <= 0.2 then
                _B__u__g_(inst, "armor_immune_amount")
            elseif bUg_ <= 0.3 then
                _B__u__g_(inst, "add_critical_hit_rate_special")
            elseif bUg_ <= 0.4 then
                _B__u__g_(inst, "true_damage_special")
            elseif bUg_ <= 0.5 then
                _B__u__g_(inst, "true_damage_special")
            elseif bUg_ <= 0.6 then
                _B__u__g_(inst, "atk_speed_special")
            elseif bUg_ <= 0.7 then
                _B__u__g_(inst, "special_xwsh")
            elseif bUg_ <= 0.8 then
                _B__u__g_(inst, "special_zqrf")
            elseif bUg_ <= 0.9 then
                _B__u__g_(inst, "special_sgsy")
            elseif bUg_ <= 1 then
                _B__u__g_(inst, "special_bhtg")
            end
        end
    },
    ["hh_sharkboi_boss"] = {
        ["start_fn"] = function(__bU_G_)
            __bU_G_["hh_is_treasure_boss"] = (289 * 301 + 286 ~= 87277)
            __bU_G_["name"] = "Super Frostjaw"
            if __bU_G_["components"] and __bU_G_["components"]["named"] then
                __bU_G_["components"]["named"]:SetName("Super Frostjaw")
            end
            b_u_g_(__bU_G_)
            bu__g_(
                __bU_G_,
                {["name"] = "Super Frostjaw", ["color"] = {255 / 255, 110 / 255, 0 / 255}, ["pos"] = {0, 10, 0}}
            )
            _b__u_g__(__bU_G_, 300000)
            _B_U__g__(
                __bU_G_,
                {
                    "immuneTearing",
                    "addComDamageNum",
                    "addComDamageNum",
                    "addComDamagePercent",
                    "immuneFreeze",
                    "addCriticalHitRate",
                    "addSuppressAddHealth",
                    "poisonTurret",
                    "iceLaser",
                    "addHealthPercent10"
                }
            )
            __bU_G_:ListenForEvent(
                "death",
                function(_b_ug__, _bUg_)
                    local __B_U__g_ = _bUg_ ~= nil and ResolveKillCreditPlayer(_bUg_["afflicter"]) or nil
                    if __B_U__g_ ~= nil then
                        b__U__G(__B_U__g_, "Super Frostjaw")
                    end
                end
            )
        end,
        ["death_fn"] = function(_BU_g_)
            B_u_g:HHRemoveFx(_BU_g_, "hh_treasure_fx")
            local bUg_ = math["random"]()
            if bUg_ <= 0.1 then
                _B__u__g_(_BU_g_, "restore_use_1s_2_percent")
            elseif bUg_ <= 0.2 then
                _B__u__g_(_BU_g_, "armor_immune_amount")
            elseif bUg_ <= 0.3 then
                _B__u__g_(_BU_g_, "add_critical_hit_rate_special")
            elseif bUg_ <= 0.4 then
                _B__u__g_(_BU_g_, "true_damage_special")
            elseif bUg_ <= 0.5 then
                _B__u__g_(_BU_g_, "true_damage_special")
            elseif bUg_ <= 0.6 then
                _B__u__g_(_BU_g_, "atk_speed_special")
            elseif bUg_ <= 0.7 then
                _B__u__g_(_BU_g_, "special_xwsh")
            elseif bUg_ <= 0.8 then
                _B__u__g_(_BU_g_, "special_zqrf")
            elseif bUg_ <= 0.9 then
                _B__u__g_(_BU_g_, "special_sgsy")
            elseif bUg_ <= 1 then
                _B__u__g_(_BU_g_, "special_bhtg")
            end
        end
    },
    ["hh_dual_wield_pig_boss"] = {
        ["start_fn"] = function(__bU_G_)
            __bU_G_["hh_is_treasure_boss"] = true
            __bU_G_["name"] = "Siêu Lợn Song Kiếm"
            if __bU_G_["components"] and __bU_G_["components"]["named"] then
                __bU_G_["components"]["named"]:SetName("Siêu Lợn Song Kiếm")
            end
            b_u_g_(__bU_G_)
            bu__g_(
                __bU_G_,
                {["name"] = "Siêu Lợn Song Kiếm", ["color"] = {255 / 255, 110 / 255, 0 / 255}, ["pos"] = {0, 10, 0}}
            )
            _b__u_g__(__bU_G_, 300000)
            _B_U__g__(
                __bU_G_,
                {
                    "immuneTearing",
                    "addComDamageNum",
                    "addComDamageNum",
                    "addComDamagePercent",
                    "immuneFreeze",
                    "addCriticalHitRate",
                    "addSuppressAddHealth",
                    "poisonTurret",
                    "iceLaser",
                    "addHealthPercent10"
                }
            )
            __bU_G_:ListenForEvent(
                "death",
                function(_b_ug__, _bUg_)
                    local __B_U__g_ = _bUg_ ~= nil and ResolveKillCreditPlayer(_bUg_["afflicter"]) or nil
                    if __B_U__g_ ~= nil then
                        b__U__G(__B_U__g_, "Siêu Lợn Song Kiếm")
                    end
                end
            )
            __bU_G_["OnEntitySleep"] = _b__u_G
        end,
        ["death_fn"] = function(_BU_g_)
            B_u_g:HHRemoveFx(_BU_g_, "hh_treasure_fx")
            local bUg_ = math["random"]()
            if bUg_ <= 0.1 then
                _B__u__g_(_BU_g_, "restore_use_1s_2_percent")
            elseif bUg_ <= 0.2 then
                _B__u__g_(_BU_g_, "armor_immune_amount")
            elseif bUg_ <= 0.3 then
                _B__u__g_(_BU_g_, "add_critical_hit_rate_special")
            elseif bUg_ <= 0.4 then
                _B__u__g_(_BU_g_, "true_damage_special")
            elseif bUg_ <= 0.5 then
                _B__u__g_(_BU_g_, "true_damage_special")
            elseif bUg_ <= 0.6 then
                _B__u__g_(_BU_g_, "atk_speed_special")
            elseif bUg_ <= 0.7 then
                _B__u__g_(_BU_g_, "special_xwsh")
            elseif bUg_ <= 0.8 then
                _B__u__g_(_BU_g_, "special_zqrf")
            elseif bUg_ <= 0.9 then
                _B__u__g_(_BU_g_, "special_sgsy")
            elseif bUg_ <= 1 then
                _B__u__g_(_BU_g_, "special_bhtg")
            end
        end
    },
    ["leif_hot"] = {["start_fn"] = function(__b_UG_)
            b_u_g_(__b_UG_)
            bu__g_(
                __b_UG_,
                {["name"] = "Thiên Tinh Quái", ["color"] = {11 / 255, 255 / 255, 0 / 255}, ["pos"] = {0, 10, 0}}
            )
            if B_u_g:HasComponents(__b_UG_, "hh_monster") then
                __b_UG_["components"]["hh_monster"]:AddBuffByName "hitAddHot"
            end
        end, ["death_fn"] = function(__B_UG_)
            B_u_g:HHRemoveFx(__B_UG_, "hh_treasure_fx")
            if __bu_g__(0.3) then
                _B__u__g_(__B_UG_, "add_immune_hot")
            end
        end},
    ["leif_cold"] = {["start_fn"] = function(__b_uG)
            b_u_g_(__b_uG)
            bu__g_(
                __b_uG,
                {["name"] = "Thiên Tinh Quái", ["color"] = {11 / 255, 255 / 255, 0 / 255}, ["pos"] = {0, 10, 0}}
            )
            if B_u_g:HasComponents(__b_uG, "hh_monster") then
                __b_uG["components"]["hh_monster"]:AddBuffByName "hitAddCold"
            end
        end, ["death_fn"] = function(__B__Ug)
            B_u_g:HHRemoveFx(__B__Ug, "hh_treasure_fx")
            if __bu_g__(0.3) then
                _B__u__g_(__B__Ug, "add_immune_cold")
            end
        end}
}
local function _B__u__g(b_U_g, _b_U__g__, _b_u__G__)
    if B_u_g:HasComponents(b_U_g, "hh_monster") then
        b_U_g["components"]["hh_monster"]:SetTreasureId(_b_U__g__)
    end
end
local function _bu_G_(__B__u__G_)
    if not __B__u__G_ or not __B__u__G_["Transform"] then
        return (65 - 202 + 481 == 354)
    end
    return (262 * 311 + 128 == 81610)
end
local function _B_UG__(__b__Ug, __b__U__G__, _Bug)
    if _bu_G_(__b__Ug) and B_u_g:IsHHType(_Bug, "table") then
        local B__u__g__, _bU_G_, __Bu__G_ = __b__Ug["Transform"]:GetWorldPosition()
        for Bu_g, _b_u_g in ipairs(_Bug) do
            if B_u_g:IsHHType(_b_u_g, "table") then
                local _Bu__g_ = _b_u_g["prefab_id"]
                local _b_u_G_ = SpawnPrefab(_Bu__g_)
                if _b_u_G_ and _b_u_G_["Transform"] then
                    _b_u_G_["Transform"]:SetPosition(B__u__g__, _bU_G_, __Bu__G_)
                    local __B__u__g__ = _b_u_g["treasure_id"]
                    if __B__u__g__ then
                        _B__u__g(_b_u_G_, __B__u__g__, __b__U__G__)
                    end
                end
            end
        end
    end
end
local function _B_u__g(_b_U_G_, _B__U_g__, _B_U__G)
    if _bu_G_(_b_U_G_) and B_u_g:IsHHType(_B_U__G, "table") then
        local Bu__g_, _B_u_G, _BUg__ = _b_U_G_["Transform"]:GetWorldPosition()
        local __b__u_g = 10
        if B_u_g:IsHHType(_B_U__G["radius"], "number") and _B_U__G["radius"] > 0 then
            __b__u_g = _B_U__G["radius"]
        end
        local _bu_G, _B_U__g_ = Bu__g_, _BUg__
        local _b_uG_ = math["pi"] / 180
        local __B_UG__ = _B_U__G["child"]
        if
            B_u_g:IsHHType(__B_UG__, "table") and B_u_g:IsHHType(__B_UG__["prefab_id"], "string") and
                B_u_g:IsHHType(__B_UG__["prefab_num"], "number") and
                __B_UG__["prefab_num"] > 0
         then
            local _B_Ug = __B_UG__["prefab_num"]
            local b_uG_ = 360 / _B_Ug
            local _bu__G_ = __B_UG__["prefab_id"]
            for _b_U_g_ = 0, (_B_Ug - 1) do
                _bu_G = Bu__g_ + __b__u_g * math["sin"](_b_U_g_ * b_uG_ * _b_uG_)
                _B_U__g_ = _BUg__ + __b__u_g * math["cos"](_b_U_g_ * b_uG_ * _b_uG_)
                if
                    TheWorld["Map"]:IsPassableAtPoint(_bu_G, 0, _B_U__g_) and
                        not TheWorld["Map"]:IsOceanTileAtPoint(_bu_G, 0, _B_U__g_)
                 then
                    local B__U_g = SpawnPrefab(_bu__G_)
                    if B__U_g and B__U_g["Transform"] then
                        B__U_g["Transform"]:SetPosition(_bu_G, _B_u_G, _B_U__g_)
                        if B_u_g:IsHHType(__B_UG__["start_fn"], "function") then
                            __B_UG__["start_fn"](B__U_g)
                        end
                    end
                end
            end
        end
        local _b_U_g__ = _B_U__G["center"]
        if B_u_g:IsHHType(_b_U_g__, "table") and B_u_g:IsHHType(_b_U_g__["prefab_id"], "string") then
            local b__u__g__ = _b_U_g__["prefab_id"]
            local B__ug__ = SpawnPrefab(b__u__g__)
            if B__ug__ and B__ug__["Transform"] then
                B__ug__["Transform"]:SetPosition(Bu__g_, _B_u_G, _BUg__)
                if B_u_g:IsHHType(_b_U_g__["start_fn"], "function") then
                    _b_U_g__["start_fn"](B__ug__)
                end
            end
        end
    end
end
local __b_uG_ = {
    {
        ["start_fn"] = function(BU__G_, _bUG_)
            B_u_g:HHSay(_bUG_, "của Thanh ngú tất")
            __B__ug_(
                BU__G_,
                {
                    {["type"] = "item", ["prefab_id"] = "yotc_seedpacket"},
                    {["type"] = "item", ["prefab_id"] = "yotc_seedpacket"},
                    {["type"] = "item", ["prefab_id"] = "yotc_seedpacket_rare"},
                    {["type"] = "item", ["prefab_id"] = "yotc_seedpacket_rare"}
                }
            )
        end
    },
    {
        ["start_fn"] = function(_B_u_g_, B_u__G_)
            B_u_g:HHSay(B_u__G_, "của Thanh ngú nữa")
            __B__ug_(
                _B_u_g_,
                {
                    {["prefab_id"] = "poop", ["type"] = "item", ["num"] = 10},
                    {["prefab_id"] = "spoiled_food", ["type"] = "item", ["num"] = 10},
                    {["prefab_id"] = "compostwrap", ["type"] = "item", ["num"] = 10}
                }
            )
        end
    },
    {
        ["start_fn"] = function(b__u_G_, _b__u__G__)
            B_u_g:HHSay(_b__u__G__, "của Khoai ngú tất")
            __B__ug_(
                b__u_G_,
                {
                    {["type"] = "item", ["prefab_id"] = "potato", ["num"] = 10},
                    {["type"] = "item", ["prefab_id"] = "tomato", ["num"] = 10}
                }
            )
        end
    },
    {["start_fn"] = function(BU__G, _B__U_G__)
            B_u_g:HHSay(_B__U_G__, "của Chúc ngú tất")
            __B__ug_(BU__G, {{["type"] = "item", ["prefab_id"] = "ghostflower", ["num"] = 10}})
        end},
    {
        ["start_fn"] = function(__b__ug__, B__u__g_)
            B_u_g:HHSay(B__u__g_, "của Bia ngú tất")
            __B__ug_(
                __b__ug__,
                {
                    {["type"] = "item", ["prefab_id"] = "oceanfishinglure_hermit_rain", ["num"] = 1},
                    {["type"] = "item", ["prefab_id"] = "oceanfishinglure_hermit_snow", ["num"] = 1},
                    {["type"] = "item", ["prefab_id"] = "oceanfishinglure_hermit_drowsy", ["num"] = 1},
                    {["type"] = "item", ["prefab_id"] = "oceanfishinglure_hermit_heavy", ["num"] = 1}
                }
            )
        end
    },
    {
        ["start_fn"] = function(_bug_, B_uG__)
            B_u_g:HHSay(B_uG__, "của Cạt ngú hết")
            __B__ug_(
                _bug_,
                {
                    {["type"] = "item", ["prefab_id"] = "lightninggoathorn", ["num"] = 5},
                    {["type"] = "item", ["prefab_id"] = "beefalowool", ["num"] = 5},
                    {["type"] = "item", ["prefab_id"] = "rocks", ["num"] = 5},
                    {["type"] = "item", ["prefab_id"] = "goldnugget", ["num"] = 5}
                }
            )
        end
    },
    {
        ["start_fn"] = function(__b_UG, __b__u__g__)
            B_u_g:HHSay(__b__u__g__, "của Green ngú hết")
            __B__ug_(
                __b_UG,
                {
                    {["type"] = "item", ["prefab_id"] = "leif_idol", ["num"] = 2},
                    {["type"] = "item", ["prefab_id"] = "log", ["num"] = 20}
                }
            )
        end
    },
    {
        ["start_fn"] = function(__bUG__, __B__UG_)
            B_u_g:HHSay(__B__UG_, "Chê")
            __B__ug_(
                __bUG__,
                {
                    {["type"] = "item", ["prefab_id"] = "fishmeat_small", ["num"] = 10},
                    {["type"] = "item", ["prefab_id"] = "fishmeat", ["num"] = 3},
                    {["type"] = "item", ["prefab_id"] = "ice", ["num"] = 10}
                }
            )
        end
    },
    {
        ["start_fn"] = function(__b_ug, b_U_g__)
            B_u_g:HHSay(b_U_g__, "Giàu rồi")
            __B__ug_(
                __b_ug,
                {
                    {["type"] = "item", ["prefab_id"] = "greengem", ["num"] = 5},
                    {["type"] = "item", ["prefab_id"] = "orangegem", ["num"] = 5},
                    {["type"] = "item", ["prefab_id"] = "yellowgem", ["num"] = 5}
                }
            )
        end
    },
    {
        ["start_fn"] = function(_b_U__G, b__ug__)
            B_u_g:HHSay(b__ug__, "jztr")
            __B__ug_(
                _b_U__G,
                {
                    {["type"] = "item", ["prefab_id"] = "purplegem", ["num"] = 5},
                    {["type"] = "item", ["prefab_id"] = "redgem", ["num"] = 5},
                    {["type"] = "item", ["prefab_id"] = "bluegem", ["num"] = 5}
                }
            )
        end
    },
    {["start_fn"] = function(_B__uG__, __b__U__G)
            B_u_g:HHSay(__b__U__G, "Thơm luôn")
            __B__ug_(_B__uG__, {{["type"] = "item", ["prefab_id"] = "opalpreciousgem", ["num"] = 1}})
            _B_u__g(_B__uG__, __b__U__G, {["radius"] = 4, ["child"] = {["prefab_id"] = "hound", ["prefab_num"] = 4}})
        end},
    {
        ["start_fn"] = function(b__U_G__, b__u_G)
            B_u_g:HHSay(b__u_G, "Tenanteam hahaha")
            __B__ug_(
                b__U_G__,
                {
                    {["type"] = "item", ["prefab_id"] = "amulet"},
                    {["type"] = "item", ["prefab_id"] = "reviver"},
                    {["type"] = "item", ["prefab_id"] = "lifeinjector"}
                }
            )
        end
    },
    {
        ["start_fn"] = function(__BuG__, _b__u_G_)
            B_u_g:HHSay(_b__u_G_, "Ngon luôn")
            __B__ug_(
                __BuG__,
                {
                    {["type"] = "item", ["prefab_id"] = "voltgoatjelly_spice_chili"},
                    {["type"] = "item", ["prefab_id"] = "jellybean_spice_garlic"}
                }
            )
        end
    },
    {["start_fn"] = function(_B__U__g_, B__Ug__)
            B_u_g:HHSay(B__Ug__, "hehe")
            __B__ug_(_B__U__g_, {{["type"] = "item", ["prefab_id"] = "mandrake", ["num"] = 5}})
        end},
    {["start_fn"] = function(__B_U__g, _B__u__G_)
            B_u_g:HHSay(_B__u__G_, "Again?")
            __B__ug_(__B_U__g, {{["type"] = "item", ["prefab_id"] = "marblebean", ["num"] = 5}})
        end},
    {["start_fn"] = function(__bu__g, b_Ug__)
            B_u_g:HHSay(b_Ug__, "Not bad")
            __B__ug_(__bu__g, {{["type"] = "item", ["prefab_id"] = "dug_rock_avocado_bush", ["num"] = 5}})
        end},
    {
        ["start_fn"] = function(__B__u__g, bU_g_)
            B_u_g:HHSay(bU_g_, "hub?")
            __B__ug_(
                __B__u__g,
                {
                    {["type"] = "item", ["prefab_id"] = "pigskin", ["num"] = 5},
                    {["type"] = "item", ["prefab_id"] = "twigs", ["num"] = 5},
                    {["type"] = "item", ["prefab_id"] = "meat", ["num"] = 5}
                }
            )
        end
    },
    {
        ["start_fn"] = function(_B__U__g__, BU_G)
            B_u_g:HHSay(BU_G, "2077 ???")
            __B__ug_(
                _B__U__g__,
                {
                    {["type"] = "item", ["prefab_id"] = "wagpunk_bits", ["num"] = 5},
                    {["type"] = "item", ["prefab_id"] = "twigs", ["num"] = 5}
                }
            )
        end
    },
    {
        ["start_fn"] = function(__Bu_g__, _b__U__G_)
            B_u_g:HHSay(_b__U__G_, "?")
            __B__ug_(
                __Bu_g__,
                {
                    {["type"] = "item", ["prefab_id"] = "feather_canary", ["num"] = 5},
                    {["type"] = "item", ["prefab_id"] = "feather_crow", ["num"] = 5},
                    {["type"] = "item", ["prefab_id"] = "feather_robin", ["num"] = 5},
                    {["type"] = "item", ["prefab_id"] = "feather_robin_winter", ["num"] = 5}
                }
            )
        end
    },
    {
        ["start_fn"] = function(_b_U__g_, _b_UG__)
            B_u_g:HHSay(_b_UG__, "Hmmm")
            __B__ug_(
                _b_U__g_,
                {
                    {["type"] = "item", ["prefab_id"] = "fossil_piece", ["num"] = 5},
                    {["type"] = "item", ["prefab_id"] = "nightmarefuel", ["num"] = 5}
                }
            )
        end
    },
    {
        ["start_fn"] = function(_b__U__g_, __B__u__g_)
            B_u_g:HHSay(__B__u__g_, "Cái gì thum thủm z")
            __B__ug_(
                _b__U__g_,
                {
                    {["type"] = "item", ["prefab_id"] = "batwing", ["num"] = 5},
                    {["type"] = "item", ["prefab_id"] = "guano", ["num"] = 5}
                }
            )
        end
    },
    {["start_fn"] = function(b__U__g__, __B__U__g)
            B_u_g:HHSay(__B__U__g, "zzz")
            __B__ug_(b__U__g__, {{["type"] = "item", ["prefab_id"] = "goose_feather", ["num"] = 10}})
        end},
    {
        ["start_fn"] = function(Bu_g_, _b__uG_)
            B_u_g:HHSay(_b__uG_, "kỳ lân?")
            __B__ug_(
                Bu_g_,
                {
                    {["type"] = "item", ["prefab_id"] = "gnarwail_horn"},
                    {["type"] = "item", ["prefab_id"] = "fishmeat", ["num"] = 5}
                }
            )
        end
    },
    {
        ["start_fn"] = function(_B__U_G, B_Ug)
            B_u_g:HHSay(B_Ug, "Talking To The Moon")
            __B__ug_(
                _B__U_G,
                {
                    {["type"] = "item", ["prefab_id"] = "moonglass", ["num"] = 5},
                    {["type"] = "item", ["prefab_id"] = "moonrocknugget", ["num"] = 5}
                }
            )
        end
    },
    {
        ["start_fn"] = function(_b_u__g_, _B__u__g__)
            B_u_g:HHSay(_B__u__g__, "Mèo l*n")
            __B__ug_(
                _b_u__g_,
                {
                    {["type"] = "item", ["prefab_id"] = "coontail", ["num"] = 5},
                    {["type"] = "item", ["prefab_id"] = "meat", ["num"] = 5}
                }
            )
        end
    },
    {
        ["start_fn"] = function(B__U__G, _B_u__G)
            B_u_g:HHSay(_B_u__G, "Động yêu nhền nhện?")
            __B__ug_(
                B__U__G,
                {
                    {["type"] = "item", ["prefab_id"] = "spidereggsack", ["num"] = 5},
                    {["type"] = "item", ["prefab_id"] = "silk", ["num"] = 5},
                    {["type"] = "item", ["prefab_id"] = "spidergland", ["num"] = 5}
                }
            )
        end
    },
    {
        ["start_fn"] = function(BUG__, b_Ug_)
            B_u_g:HHSay(b_Ug_, "The Silence of the Lambs")
            __B__ug_(
                BUG__,
                {
                    {["type"] = "item", ["prefab_id"] = "steelwool", ["num"] = 5},
                    {["type"] = "item", ["prefab_id"] = "phlegm", ["num"] = 5},
                    {["type"] = "item", ["prefab_id"] = "meat", ["num"] = 5}
                }
            )
        end
    },
    {["start_fn"] = function(_bu_g__, b__U_G_)
            B_u_g:HHSay(b__U_G_, "Bruhhh")
            __B__ug_(_bu_g__, {{["type"] = "item", ["prefab_id"] = "hh_essence", ["num"] = 5}})
        end},
    {["start_fn"] = function(bUG__, _bug__)
            B_u_g:HHSay(_bug__, "Khỉ thật")
            __B__ug_(bUG__, {{["type"] = "item", ["prefab_id"] = "dug_monkeytail", ["num"] = 10}})
        end}
}
local Bu__g__ = {
    {["start_fn"] = function(bU_G__, b_uG)
            B_u_g:HHSay(b_uG, "Giggle")
            _B_u__g(bU_G__, b_uG, {["radius"] = 4, ["child"] = {["prefab_id"] = "perd", ["prefab_num"] = 10}})
            _B_u__g(bU_G__, b_uG, {["radius"] = 6, ["child"] = {["prefab_id"] = "wall_stone", ["prefab_num"] = 30}})
            _B_u__g(bU_G__, b_uG, {["radius"] = 8, ["child"] = {["prefab_id"] = "berrybush", ["prefab_num"] = 4}})
        end},
    {
        ["start_fn"] = function(_b_U__G__, bug__)
            _B_u__g(
                _b_U__G__,
                bug__,
                {
                    ["radius"] = 4,
                    ["child"] = {["prefab_id"] = "rock_moon", ["prefab_num"] = 10},
                    ["center"] = {["prefab_id"] = "goldenpickaxe"}
                }
            )
        end
    },
    {
        ["start_fn"] = function(__BU__g__, _bU__G_)
            _B_u__g(
                __BU__g__,
                _bU__G_,
                {
                    ["child"] = {["prefab_id"] = "wasphive", ["prefab_num"] = 10},
                    ["center"] = {["prefab_id"] = "lightning_rod", ["start_fn"] = function(b_u_g)
                            if b_u_g and b_u_g["AnimState"] then
                                b_u_g["AnimState"]:PlayAnimation "place"
                                b_u_g["AnimState"]:PushAnimation "idle"
                            end
                        end}
                }
            )
        end
    },
    {
        ["start_fn"] = function(__B__Ug__, __B_ug_)
            B_u_g:HHSay(__B_ug_, "Huh")
            _B_u__g(
                __B__Ug__,
                __B_ug_,
                {
                    ["radius"] = 4,
                    ["child"] = {["prefab_id"] = "bunnyman", ["prefab_num"] = 6},
                    ["center"] = {["prefab_id"] = "hammer"}
                }
            )
            _B_u__g(
                __B__Ug__,
                __B_ug_,
                {["radius"] = 6, ["child"] = {["prefab_id"] = "wall_moonrock", ["prefab_num"] = 30}}
            )
        end
    },
    {["start_fn"] = function(BU__g__, __B__U_g_)
            B_u_g:HHSay(__B__U_g_, "Sheesh!!!")
            _B_u__g(BU__g__, __B__U_g_, {["radius"] = 4, ["child"] = {["prefab_id"] = "bishop", ["prefab_num"] = 4}})
            _B_u__g(
                BU__g__,
                __B__U_g_,
                {["radius"] = 3, ["child"] = {["prefab_id"] = "wall_stone", ["prefab_num"] = 10}}
            )
        end},
    {["start_fn"] = function(BuG_, __BU__g)
            B_u_g:HHSay(__BU__g, "Run bitch! Runnnn")
            _B_u__g(BuG_, __BU__g, {["radius"] = 4, ["child"] = {["prefab_id"] = "frog", ["prefab_num"] = 15}})
            _B__u__g_(BuG_, "add_speed")
        end},
    {["start_fn"] = function(B__U__G_, __b__U_G__)
            B_u_g:HHSay(__b__U_G__, "Voice")
            _B_u__g(
                B__U__G_,
                __b__U_G__,
                {["radius"] = 2, ["child"] = {["prefab_id"] = "koalefant_winter", ["prefab_num"] = 2}}
            )
            _B_u__g(
                B__U__G_,
                __b__U_G__,
                {["radius"] = 4, ["child"] = {["prefab_id"] = "koalefant_summer", ["prefab_num"] = 2}}
            )
        end},
    {["start_fn"] = function(_B__U__G, b_u_G_)
            B_u_g:HHSay(b_u_G_, "Somewhere")
            _B_u__g(_B__U__G, b_u_G_, {["center"] = {["prefab_id"] = "lightninggoat", ["prefab_num"] = 5}})
        end}
}
local __B_u__G = {
    {
        ["prefab_id"] = "Super Krampus",
        ["chance"] = 20,
        ["start_fn"] = function(_B__u__G__, B__U_G_)
            B_u_g:NetSay("★ Super Krampus ★ đã xuất hiện, hãy tiêu diệt và nhận phần thưởng")
            _B_UG__(
                _B__u__G__,
                B__U_G_,
                {
                    {["prefab_id"] = "krampus", ["treasure_id"] = "treasure_kps"},
                    {["prefab_id"] = "pigman", ["treasure_id"] = "pig_tank"},
                    {["prefab_id"] = "pigman", ["treasure_id"] = "pig_attack"}
                }
            )
        end
    },
    {
        ["prefab_id"] = "Super Catcoon",
        ["chance"] = 20,
        ["start_fn"] = function(_B__u__G__, B__U_G_)
            B_u_g:NetSay("★ Siêu Mèo Thần Tài ★ đã xuất hiện, hãy tiêu diệt và nhận phần thưởng")
            _B_UG__(
                _B__u__G__,
                B__U_G_,
                {
                    {["prefab_id"] = "catcoon", ["treasure_id"] = "treasure_cat_you"}
                }
            )
        end
    },
    {["prefab_id"] = "Super Crystal Deerclops", ["chance"] = 20, ["start_fn"] = function(__B__u__G, bu__G__)
            B_u_g:NetSay("★ Super Crystal Deerclops ★ đã xuất hiện, hãy tiêu diệt và nhận phần thưởng")
            _B_UG__(
                __B__u__G,
                bu__G__,
                {{["prefab_id"] = "mutateddeerclops", ["treasure_id"] = "mutateddeerclops_boss"}}
            )
        end},
    {["prefab_id"] = "Super Armored Bearger", ["chance"] = 20, ["start_fn"] = function(_b_U__G_, _b_U_g)
            B_u_g:NetSay("★ Super Armored Bearger ★ đã xuất hiện, hãy tiêu diệt và nhận phần thưởng")
            _B_UG__(_b_U__G_, _b_U_g, {{["prefab_id"] = "mutatedbearger", ["treasure_id"] = "mutatedbearger_boss"}})
        end},
    {["prefab_id"] = "Super Frostjaw", ["chance"] = 20, ["start_fn"] = function(Bu__G, _B_u_G_)
            B_u_g:NetSay("★ Super Frostjaw ★ đã xuất hiện, hãy tiêu diệt và nhận phần thưởng")
            _B_UG__(Bu__G, _B_u_G_, {{["prefab_id"] = "hh_sharkboi", ["treasure_id"] = "hh_sharkboi_boss"}})
        end},
    {["prefab_id"] = "Super Mactusk", ["chance"] = 20, ["start_fn"] = function(B_ug__, _Bug__)
            B_u_g:NetSay("★ Super Mactusk ★ đã xuất hiện, hãy tiêu diệt và nhận phần thưởng")
            _B_UG__(B_ug__, _Bug__, {{["prefab_id"] = "walrus", ["treasure_id"] = "walrus_adc"}})
        end},
    {["prefab_id"] = "Super Mutated Warg", ["chance"] = 20, ["start_fn"] = function(inst, pt)
            B_u_g:NetSay("★ Siêu Sói Vương ★ đã xuất hiện, hãy tiêu diệt và nhận phần thưởng")
            _B_UG__(inst, pt, {{["prefab_id"] = "mutatedwarg", ["treasure_id"] = "mutatedwarg_boss"}})
        end},
    ------ 2 CON BOSS BÊN DƯỚI SẼ KHÔNG XUẤT HIỆN KHI ĐÀO KHO BÁU, CHỈ CẦN BỎ CÁC DẤU -- COMMENT LÀ NÓ SẼ XUẤT HIỆN
--    {["prefab_id"] = "Super Beetle Pig", ["chance"] = 20, ["start_fn"] = function(inst, pt)
--            B_u_g:NetSay("★ Siêu Lợn Bọ Hung ★ đã xuất hiện, hãy tiêu diệt và nhận phần thưởng")
--            _B_UG__(inst, pt, {{["prefab_id"] = "hh_beetle_pig", ["treasure_id"] = "hh_beetle_pig_boss"}})
--        end},
--    {["prefab_id"] = "Super Dual Wield Pig", ["chance"] = 20, ["start_fn"] = function(inst, pt)
--            B_u_g:NetSay("★ Siêu Lợn Song Kiếm ★ đã xuất hiện, hãy tiêu diệt và nhận phần thưởng")
--            _B_UG__(inst, pt, {{["prefab_id"] = "hh_dual_wield_pig", ["treasure_id"] = "hh_dual_wield_pig_boss"}})
--        end},

    {
        ["prefab_id"] = "Pig guard",
        ["chance"] = 82,
        ["start_fn"] = function(_B__UG_, bU__G__)
            _B_UG__(
                _B__UG_,
                bU__G__,
                {
                    {["prefab_id"] = "pigman", ["treasure_id"] = "pig_wsz"},
                    {["prefab_id"] = "pigman", ["treasure_id"] = "pig_tank"},
                    {["prefab_id"] = "pigman", ["treasure_id"] = "pig_attack"},
                    {["prefab_id"] = "pigman", ["treasure_id"] = "pig_buff"}
                }
            )
        end
    },
    {["prefab_id"] = "Hotguard", ["chance"] = 82, ["start_fn"] = function(B_U__G__, Bu_G_)
            _B_UG__(B_U__G__, Bu_G_, {{["prefab_id"] = "leif", ["treasure_id"] = "leif_hot"}})
        end},
    {["prefab_id"] = "Coldguard", ["chance"] = 82, ["start_fn"] = function(_B__uG, __BU__G_)
            _B_UG__(_B__uG, __BU__G_, {{["prefab_id"] = "leif", ["treasure_id"] = "leif_cold"}})
        end},
    {["prefab_id"] = "Worm", ["chance"] = 82, ["start_fn"] = function(b_u__G_, __b__u_G_)
            _B_UG__(b_u__G_, __b__u_G_, {{["prefab_id"] = "worm"}, {["prefab_id"] = "worm"}, {["prefab_id"] = "worm"}})
        end},
    {["prefab_id"] = "Beefalo", ["chance"] = 82, ["start_fn"] = function(B__u_G__, _B_ug__)
            _B_UG__(B__u_G__, _B_ug__, {{["prefab_id"] = "beefalo"}})
        end},
    {["prefab_id"] = "Gear monster", ["chance"] = 82, ["start_fn"] = function(_b_UG, __B_U_g)
            _B_UG__(_b_UG, __B_U_g, {{["prefab_id"] = "bishop"}, {["prefab_id"] = "rook"}, {["prefab_id"] = "knight"}})
        end},
    {
        ["prefab_id"] = "Mushroom geomorphism",
        ["chance"] = 82,
        ["start_fn"] = function(_b_Ug__, B_U__g_)
            _B_UG__(
                _b_Ug__,
                B_U__g_,
                {{["prefab_id"] = "mushgnome"}, {["prefab_id"] = "mushgnome"}, {["prefab_id"] = "mushgnome"}}
            )
        end
    },
    {["prefab_id"] = "Ingredients", ["chance"] = 82, ["start_fn"] = function(bU_G_, __B_ug)
            local B_U__g = math["random"](1, #__b_uG_)
            if __b_uG_[B_U__g] and __b_uG_[B_U__g]["start_fn"] then
                __b_uG_[B_U__g]["start_fn"](bU_G_, __B_ug)
            end
        end},
    {["prefab_id"] = "Architecture", ["chance"] = 82, ["start_fn"] = function(__BuG_, __b_u__g_)
            local b__Ug = math["random"](1, #Bu__g__)
            if Bu__g__[b__Ug] and Bu__g__[b__Ug]["start_fn"] then
                Bu__g__[b__Ug]["start_fn"](__BuG_, __b_u__g_)
            end
        end},
    {["prefab_id"] = "Prism riders", ["chance"] = 82, ["start_fn"] = function(B__uG, _B__uG_)
            if TUNING["mod_legion_enabled"] then
                B_u_g:HHSay(_B__uG_, "I am invincible")
                __B__ug_(B__uG, {{["type"] = "item", ["prefab_id"] = "agronssword"}})
            else
                B_u_g:HHSay(_B__uG_, "Một sức mạnh bí ẩn đã biến mất")
                __B__ug_(B__uG, {{["type"] = "item", ["prefab_id"] = "steelwool", ["num"] = 1}})
            end
        end}
}
return {["TREASURE_MONSTER_CONFIG"] = B_u__g__, ["CHANCE_CONFIG"] = __B_u__G}
