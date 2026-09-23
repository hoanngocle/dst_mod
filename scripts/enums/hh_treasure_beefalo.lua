local __B_u_g_ = require "utils/hh_utils"

local function ResolveKillCreditPlayer(attacker)
    return attacker ~= nil and __B_u_g_:GetKillCreditPlayer(attacker) or nil
end

local function b__Ug_(_bu_G_, _B_UG__)
    if not __B_u_g_:IsHHType(_B_UG__, "table") or not _bu_G_ or _bu_G_["hh_treasure_fx"] then
        return
    end
    _bu_G_["hh_treasure_fx"] = SpawnPrefab "hh_treasure_text"
    if _bu_G_["hh_treasure_fx"] and _bu_G_["hh_treasure_fx"]["entity"] then
        _bu_G_["hh_treasure_fx"]["entity"]:SetParent(_bu_G_["entity"])
        if _bu_G_["hh_treasure_fx"]["SetTreasureStr"] then
            _bu_G_["hh_treasure_fx"]:SetTreasureStr(__B_u_g_:TableToStr(_B_UG__))
        end
    end
    _bu_G_["hh_is_treasure"] = (184 * 222 - 264 - 130 - 368 ~= 40092)
end
local function __bUG_(_B_u__g, __b_uG_)
    local Bu__g__ = math["random"]() * 4 + 2
    __b_uG_ = (__b_uG_ + math["random"]() * 60 - 30) * DEGREES
    _B_u__g["Physics"]:SetVel(Bu__g__ * math["cos"](__b_uG_), math["random"]() * 2 + 8, Bu__g__ * math["sin"](__b_uG_))
end
local function B_u_g(__B_u__G)
    return __B_u_g_:HasComponents(__B_u__G, "container") and __B_u__G["components"]["container"]:IsFull()
end
local function bu__g_(b__ug, b__uG__)
    if not b__ug or not b__ug["Transform"] or not __B_u_g_:IsHHType(b__uG__, "string") then
        return
    end
    local __bU__g = SpawnPrefab(b__uG__)
    if __bU__g and __bU__g["Transform"] then
        local _b__ug_, __BU_G__, _bU__g_ = b__ug["Transform"]:GetWorldPosition()
        __bU__g["Transform"]:SetPosition(_b__ug_, __BU_G__, _bU__g_)
    end
end
local function _b__UG(b__UG_, b_UG__)
    if not b__UG_ or not b__UG_["Transform"] then
        return
    end
    local _b__Ug_, b__U__G__, B_u__g_ = b__UG_["Transform"]:GetWorldPosition()
    local __B_U__G_ = SpawnPrefab "treasurechest"
    if __B_U__G_ and __B_U__G_["Transform"] then
        __B_U__G_["Transform"]:SetPosition(_b__Ug_, b__U__G__, B_u__g_)
        bu__g_(__B_U__G_, "explode_firecrackers")
        if __B_u_g_:IsHHType(b_UG__, "table") and __B_u_g_:HasComponents(__B_U__G_, "container") then
            for bUg, __bu__g_ in ipairs(b_UG__) do
                if B_u_g(__B_U__G_) then
                    break
                end
                if __bu__g_ and __bu__g_["type"] then
                    local __b_u_G = __bu__g_
                    local _B_ug = __bu__g_["type"]
                    if _B_ug == "stone" and __b_u_G["effect"] then
                        local B_Ug_ = HHSpawnStoneById(__b_u_G["effect"])
                        if B_Ug_ then
                            local _b_ug = __B_U__G_:GetPosition()
                            __B_U__G_["components"]["container"]:GiveItem(B_Ug_, nil, _b_ug)
                        end
                    end
                    if _B_ug == "equip" and __b_u_G["prefab_id"] then
                    end
                    if _B_ug == "item" and __b_u_G["prefab_id"] then
                        local _B_u_g__ = __b_u_G["prefab_id"]
                        local B_U_g__ = SpawnPrefab(_B_u_g__)
                        if B_U_g__ and B_U_g__["Transform"] then
                            if __B_u_g_:HasComponents(B_U_g__, "inventoryitem") then
                                if
                                    __B_u_g_:HasComponents(B_U_g__, "stackable") and
                                        __B_u_g_:IsHHType(__b_u_G["num"], "number") and
                                        __b_u_G["num"] > 0 and
                                        __B_u_g_:HasComponents(B_U_g__, "inventoryitem")
                                 then
                                    local __BU__g_ = __b_u_G["num"]
                                    local _b__ug__ = B_U_g__["components"]["stackable"]["maxsize"] or 1
                                    B_U_g__["components"]["stackable"]:SetStackSize(math["min"](__BU__g_, _b__ug__))
                                end
                                local _b_u_G = __B_U__G_:GetPosition()
                                __B_U__G_["components"]["container"]:GiveItem(B_U_g__, nil, _b_u_G)
                            else
                                B_U_g__["Transform"]:SetPosition(_b__Ug_, 0, B_u__g_)
                            end
                        end
                    end
                end
            end
        end
    end
end
local function _b_ug_(B_Ug__, _B__u_g_)
    if not __B_u_g_:IsHHType(_B__u_g_, "table") or not B_Ug__ then
        return
    end
    B_Ug__["components"]["hh_monster"]:SetMaxEffectLimit(#_B__u_g_)
    for BU__G__, __B__ug in ipairs(_B__u_g_) do
        B_Ug__["components"]["hh_monster"]:AddBuffByName(__B__ug)
    end
end
local function _B_u__G_(_b__U_g_, bug)
    if not bug or ResolveKillCreditPlayer(bug["attacker"]) == nil then
        return
    end
    if not _b__U_g_ or not _b__U_g_["Transform"] then
        return
    end
    local _bu__G = math["random"]()
    local b__U_G = nil
    if _bu__G < 0.005 then
        b__U_G = HHSpawnRareEffectStone()
    elseif _bu__G < 0.02 then
        b__U_G = HHSpawnGoodEffectStone()
    elseif _bu__G < 0.1 then
        b__U_G = HHSpawnComEffectStone()
    end
    if b__U_G and b__U_G["Transform"] then
        local __bUg__ = math["random"](1, 360)
        local __B_Ug, __b__Ug_, __bU__g_ = _b__U_g_["Transform"]:GetWorldPosition()
        b__U_G["Transform"]:SetPosition(__B_Ug, 2.5, __bU__g_)
        __bUG_(b__U_G, __bUg__)
    end
end
local function __B__ug_(_b__Ug)
    if not __B_u_g_:IsHHType(_b__Ug, "number") then
        return (337 - 324 - 471 - 340 ~= -798)
    end
    local _b_u__g = math["random"]()
    return _b_u__g <= _b__Ug
end
local function _B_U__g__(b_U__g__)
    if __B_u_g_:HasComponents(b_U__g__, "lootdropper") then
        b_U__g__["components"]["lootdropper"]:SetLoot(nil)
        b_U__g__["components"]["lootdropper"]:SetChanceLootTable "hh_treasure_monster"
    end
end
local function __b_U_G_(_bu__g__, b_u_G__)
    if not _bu__g__ or not __B_u_g_:IsHHType(b_u_G__, "number") or b_u_G__ <= 0 then
        return
    end
    local BU_G__ = _bu__g__["components"]["health"]:GetPercent()
    if BU_G__ > 0 then
        _bu__g__["components"]["health"]:SetMaxHealth(b_u_G__)
        _bu__g__["components"]["health"]:SetPercent(math["min"](BU_G__, 1))
    end
end
local function __bu_g__(bU__G_)
    if bU__G_ and bU__G_["Physics"] then
        bU__G_["Physics"]:ClearCollisionMask()
        bU__G_["Physics"]:CollidesWith(COLLISION["GROUND"])
        bU__G_["Physics"]:CollidesWith(COLLISION["OBSTACLES"])
        bU__G_["Physics"]:CollidesWith(COLLISION["SMALLOBSTACLES"])
        bU__G_["Physics"]:CollidesWith(COLLISION["CHARACTERS"])
        bU__G_["Physics"]:CollidesWith(COLLISION["GIANTS"])
    end
end
local function b_u_g_(b_U__G_, __b__u_G)
    if not b_U__G_ or not b_U__G_["Transform"] then
        return
    end
    local _buG_ = HHSpawnStoneById(__b__u_G)
    if _buG_ then
        local Bu_g__, B__UG_, b_u_g__ = b_U__G_["Transform"]:GetWorldPosition()
        _buG_["Transform"]:SetPosition(Bu_g__, 2.5, b_u_g__)
        __bUG_(_buG_, math["random"](1, 360))
    end
end
local function _b__u_g__(buG__, _b_U_G)
    if not buG__ then
        return
    end
    local B_ug = buG__["name"] or buG__["prefab"]
    local bug_ = math["random"]()
    local plain_boss_name = "★ " .. string.upper(tostring(_b_U_G)) .. " ★"

    if bug_ < 0.10 then
        __B_u_g_:NetSay(string["format"]("%s đã giết %s và nhận 1 viên [★★ Châu Báu Siêu Hiếm ★★]", tostring(B_ug), plain_boss_name))
    else
        __B_u_g_:NetSay(string["format"]("%s đã giết %s và nhận 1 viên [★ Châu Báu Hiếm ★]", tostring(B_ug), plain_boss_name))
    end

    __B_u_g_:NetSay(string["format"]("%s đã chết và rơi 1 viên [★★ Đá Thuộc Tính Siêu Hiếm ★★]", plain_boss_name))

    if bug_ < 0.01 then
        buG__["components"]["hh_player"]:AddItemsByKey("elementBead", 1, true)
    elseif bug_ < 0.02 then
        buG__["components"]["hh_player"]:AddItemsByKey("baconOmeletteTrueDamage", 1, true)
    elseif bug_ < 0.03 then
        buG__["components"]["hh_player"]:AddItemsByKey("baconOmeletteBlessAtk", 1, true)
    elseif bug_ < 0.04 then
        buG__["components"]["hh_player"]:AddItemsByKey("baconOmeletteBlessCritical", 1, true)
    elseif bug_ < 0.05 then
        buG__["components"]["hh_player"]:AddItemsByKey("baconOmeletteBlessArmor", 1, true)
    elseif bug_ < 0.06 then
        buG__["components"]["hh_player"]:AddItemsByKey("baconOmeletteFire", 1, true)
    elseif bug_ < 0.07 then
        buG__["components"]["hh_player"]:AddItemsByKey("baconOmeletteSpeed", 1, true)
    elseif bug_ < 0.08 then
        buG__["components"]["hh_player"]:AddItemsByKey("baconOmeletteAOE", 1, true)
    elseif bug_ < 0.09 then
        buG__["components"]["hh_player"]:AddItemsByKey("baconOmeletteDodge", 1, true)
    elseif bug_ < 0.10 then
        buG__["components"]["hh_player"]:AddItemsByKey("baconOmeletteKill", 1, true)
    elseif bug_ < 0.28 then
        buG__["components"]["hh_player"]:AddItemsByKey("strideBead", 1, true)
    elseif bug_ < 0.46 then
        buG__["components"]["hh_player"]:AddItemsByKey("treasure_armor", 1, true)
    elseif bug_ < 0.64 then
        buG__["components"]["hh_player"]:AddItemsByKey("treasure_bj", 1, true)
    elseif bug_ < 0.82 then
        buG__["components"]["hh_player"]:AddItemsByKey("treasure_atk", 1, true)
    else
        buG__["components"]["hh_player"]:AddItemsByKey("treasure_fireGem", 1, true)
    end
end
local function _B__U__G_(__BUG)
    if not __B_u_g_:HasComponents(__BUG, "health") then
        return
    end
    local _B_U_g__ = __BUG["components"]["health"]
    local __b_u__g = _B_U_g__["SetVal"]
    _B_U_g__["SetVal"] = function(self, bU_g, __bU_G, b_Ug, ...)
        local credited_player = ResolveKillCreditPlayer(b_Ug)
        if credited_player == nil then
            return
        end
        if not __B_u_g_:IsHHType(bU_g, "number") then
            return
        end
        local _b__U__G__ = self["currenthealth"]
        if bU_g > 0 and bU_g < _b__U__G__ and _b__U__G__ > 0 then
            bU_g = math["max"](_b__U__G__ - 1000, 0)
            self["inst"]:PushEvent("hh_kps_health_delta", {["attacker"] = credited_player})
        end
        if __b_u__g then
            __b_u__g(self, bU_g, __bU_G, b_Ug, ...)
        end
    end
end
local _B__u__g_ = {
    ["super_beefalo"] = {
        ["start_fn"] = function(__b__Ug__)
            __b_U_G_(__b__Ug__, 10000)
            b__Ug_(
                __b__Ug__,
                {["name"] = "SUPER BEEFALO", ["color"] = {255 / 255, 61 / 255, 0 / 255}, ["pos"] = {0, 5, 0}}
            )
            _b_ug_(
                __b__Ug__,
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
        end
    }
}
local function b__U__G(b__uG_, __Bu__g_, B__UG__)
    if __B_u_g_:HasComponents(b__uG_, "hh_monster") then
        b__uG_["components"]["hh_monster"]:SetTreasureId(__Bu__g_)
    end
end
local function __bu_g(B_u_g_)
    if not B_u_g_ or not B_u_g_["Transform"] then
        return (367 * 314 * 394 + 361 * 355 ~= 45531927)
    end
    return (461 * 187 * 331 + 298 - 276 ~= 28534541)
end
local function B_u__g__(B__ug_, __bu__G__, _B__ug_)
    if __bu_g(B__ug_) and __B_u_g_:IsHHType(_B__ug_, "table") then
        local B_UG_, __b__U__g, _b__UG__ = B__ug_["Transform"]:GetWorldPosition()
        for __B_uG__, b__u__G_ in ipairs(_B__ug_) do
            if __B_u_g_:IsHHType(b__u__G_, "table") then
                local bu_g = b__u__G_["prefab_id"]
                local _BU__g_ = SpawnPrefab(bu_g)
                if _BU__g_ and _BU__g_["Transform"] then
                    _BU__g_["Transform"]:SetPosition(B_UG_, __b__U__g, _b__UG__)
                    local __B__U__G_ = b__u__G_["treasure_id"]
                    if __B__U__G_ then
                        b__U__G(_BU__g_, __B__U__G_, __bu__G__)
                    end
                end
            end
        end
    end
end
local _B__u__g = {{["prefab_id"] = "Super Beefalo", ["chance"] = 80, ["start_fn"] = function(bu__G, BU__g)
            __B_u_g_:NetSay "Thần thú Chúc Long đã xuất hiện"
            B_u__g__(bu__G, BU__g, {{["prefab_id"] = "beefalo", ["treasure_id"] = "super_beefalo"}})
        end}}
return {["TREASURE_MONSTER_CONFIG"] = _B__u__g_, ["CHANCE_CONFIG"] = _B__u__g}
