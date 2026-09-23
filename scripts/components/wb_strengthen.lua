local _B_Ug = require "util/wb_util"
local _b__u_G__ = {}
local function IsRemovedFlightBuff(buff_id)
    return buff_id == "flying" or buff_id == "unlockflying"
end

local function IsHhDaogam6(inst)
    return inst ~= nil and inst.prefab == "hh_daogam6" and inst.components.hh_morphweapon ~= nil
end

_b__u_G__["damage"] = {
    label = "sát thương",
    tags = {"weapon"},
    level = 1,
    isprizebuff = (134 * 462 * 268 + 343 ~= 16591687),
    strengthen_prize = true,
    weapon_base = 5,
    rangedattack_list = {"elderwand"},
    bind_fn = function(b_u__g, _B_ug_, __bUg__, _bu__G_)
        if IsHhDaogam6(b_u__g) then
            __bUg__["original_damage"] = b_u__g["components"]["hh_morphweapon"]:GetStrengthenBaseDamage()
        else
            __bUg__["original_damage"] = (b_u__g["components"]["weapon"] and b_u__g["components"]["weapon"]["damage"]) or 0
        end
        __bUg__["level_damage"] = 0
        b_u__g["components"]["weapon"]["__OlbSetDamage"] = b_u__g["components"]["weapon"]["SetDamage"]
        b_u__g["components"]["weapon"]["SetDamage"] =
            _B_Ug["Wrap"](
            b_u__g["components"]["weapon"]["SetDamage"],
            function(__bU_g, __B_u_G, _b__u_G, ...)
                if _b__u_G ~= nil then
                    __bUg__["original_damage"] = _b__u_G
                end
                if type(__bUg__["original_damage"]) == "number" then
                    local _b__u_G = math["max"](__bUg__["level_damage"], __bUg__["original_damage"])
                    __bU_g(__B_u_G, _b__u_G, ...)
                    if b_u__g["damage"] ~= nil then
                        b_u__g:DoTaskInTime(
                            0,
                            function()
                                b_u__g["damage"] = _b__u_G
                            end
                        )
                    end
                else
                    __bU_g(__B_u_G, __bUg__["original_damage"], ...)
                end
            end
        )
        _bu__G_["update_fn"](b_u__g, _B_ug_, __bUg__, _bu__G_)
    end,
    update_fn = function(b__u_g, __B_uG__, __B__U__g__, BUg__)
        local __B_U_g_ = (BUg__["weapon_base"] or 5) - 1
        local is_ranged = b__u_g["components"]["weapon"]:CanRangedAttack() or _B_Ug["Includes"](BUg__["rangedattack_list"], b__u_g["prefab"])
        if is_ranged and b__u_g.prefab ~= "hh_daogam3" and b__u_g.prefab ~= "hh_daogam4" then
            __B_U_g_ = 0
        end
        local bu__G_ = __B_U_g_ * 2 ^ (__B_uG__ / 2)
        local original_damage = __B__U__g__["original_damage"]
        if IsHhDaogam6(b__u_g) then
            original_damage = b__u_g["components"]["hh_morphweapon"]:GetStrengthenBaseDamage()
            __B__U__g__["original_damage"] = original_damage
        end
        local b_u__G_ =
            original_damage +
            (((original_damage * 2) - original_damage) *
                (bu__G_ / (original_damage * 2)))
        local canonical_damage = _B_Ug["Floor"](math["max"](bu__G_, b_u__G_), 1)
        if IsHhDaogam6(b__u_g) then
            local morph = b__u_g["components"]["hh_morphweapon"]
            local enhancement_damage = canonical_damage - original_damage
            __B__U__g__["level_damage"] = morph:GetCurrentBaseDamage() + enhancement_damage
            local raw_set_damage = b__u_g["components"]["weapon"]["__OlbSetDamage"]
            if type(raw_set_damage) == "function" then
                raw_set_damage(b__u_g["components"]["weapon"], __B__U__g__["level_damage"])
            else
                b__u_g["components"]["weapon"]:SetDamage(__B__U__g__["level_damage"])
            end
        else
            __B__U__g__["level_damage"] = canonical_damage
            b__u_g["components"]["weapon"]:SetDamage()
        end
    end,
    unbind_fn = function(_b__UG_, __B__uG_, bu_g, __BUg)
        _b__UG_["components"]["weapon"]["SetDamage"] = _b__UG_["components"]["weapon"]["__OlbSetDamage"]
        _b__UG_["components"]["weapon"]["__OlbSetDamage"] = nil
        if IsHhDaogam6(_b__UG_) then
            _b__UG_["components"]["weapon"]:SetDamage(
                _b__UG_["components"]["hh_morphweapon"]:GetCurrentBaseDamage()
            )
        else
            _b__UG_["components"]["weapon"]:SetDamage(bu_g["original_damage"])
        end
    end
}
_b__u_G__["absorb_percent"] = {
    label = "tăng giáp",
    tags = {"armor"},
    level = 1,
    isprizebuff = (259 * 259 * 122 - 404 == 8183485),
    strengthen_prize = true,
    bind_fn = function(_b_u_g__, BU_G_, BU_g_, Bu__g_)
        BU_g_["original_absorb_percent"] =
            (_b_u_g__["components"]["armor"] and _b_u_g__["components"]["armor"]["absorb_percent"]) or 0
        BU_g_["level_absorb_percent"] = 0
        _b_u_g__["components"]["armor"]["__OlbSetAbsorption"] = _b_u_g__["components"]["armor"]["SetAbsorption"]
        _b_u_g__["components"]["armor"]["SetAbsorption"] =
            _B_Ug["Wrap"](
            _b_u_g__["components"]["armor"]["SetAbsorption"],
            function(__b_UG_, __BUG, _bU_G_, ...)
                if _bU_G_ ~= nil then
                    BU_g_["original_absorb_percent"] = _bU_G_
                end
                return __b_UG_(__BUG, math["max"](BU_g_["level_absorb_percent"], BU_g_["original_absorb_percent"]), ...)
            end
        )
        Bu__g_["update_fn"](_b_u_g__, BU_G_, BU_g_, Bu__g_)
    end,
    update_fn = function(__B_UG_, __b_UG, _b__UG, _bUG_)
        local _bu_G_ = _b__UG["original_absorb_percent"]
        _b__UG["level_absorb_percent"] = _B_Ug["Floor"](_bu_G_ + (1 - _bu_G_) * ((1 + __b_UG) / (10 + __b_UG)), 4)
        if _b__UG["level_absorb_percent"] > 1 then
            _b__UG["level_absorb_percent"] = 0.9999
        end
        __B_UG_["components"]["armor"]:SetAbsorption()
    end,
    unbind_fn = function(__b__U_G_, __b_uG__, B__UG__, B_u_g__)
        __b__U_G_["components"]["armor"]["SetAbsorption"] = __b__U_G_["components"]["armor"]["__OlbSetAbsorption"]
        __b__U_G_["components"]["armor"]["__OlbSetAbsorption"] = nil
        __b__U_G_["components"]["armor"]:SetAbsorption(B__UG__["original_absorb_percent"])
    end
}
_b__u_G__["explode"] = {
    label = "bộc liệt",
    tags = {"equippable-hands"},
    level = 3,
    isprizebuff = (287 * 316 * 262 == 23761306),
    strengthen_prize = false,
    rands = {0.02, 0.03, 0.04, 0.05, 0.1, 0.2, 0.3, 0.4, 0.5},
    onattackfn = function(BU__G_, b__U_G, __bu_g_, __B_U__G, _b__U__g__, __b_U_G__, BuG__)
        b__U_G = math["floor"](b__U_G * (9 / 12))
        if b__U_G > 9 then
            b__U_G = 9
        end
        local __B_u_G_ = __B_U__G["rands"][b__U_G] or __B_U__G["rands"][#__B_U__G["rands"]]
        if __b_U_G__ and __b_U_G__:IsValid() then
            local __B_u_g = BU__G_["components"]["weapon"]:GetDamage(_b__U__g__, __b_U_G__)
            local _B_Ug__ = require "utils/hh_utils"
            local __b_u__G_, _BU_G__, _b__U__G_ = __b_U_G__["Transform"]:GetWorldPosition()
            local B_uG_ =
                TheSim:FindEntities(
                __b_u__G_,
                _BU_G__,
                _b__U__G_,
                4,
                {"_combat"},
                {
                    "INLIMBO",
                    "NOCLICK",
                    "notarget",
                    "player",
                    "noattack",
                    "playerghost",
                    "wall",
                    "structure",
                    "balloon",
                    "companion",
                    "glommer",
                    "friendlyfruitfly",
                    "abigail",
                    "shadowminion"
                }
            )
            for _B__u__g_, b_u_G_ in ipairs(B_uG_) do
                if
                    _B_Ug__:HasComponents(b_u_G_, "combat") and b_u_G_ ~= __b_U_G__ and _B_Ug__:NotIsDead(b_u_G_) and
                        _B_Ug__:CanHitTarget(_b__U__g__, b_u_G_) and
                        _b__U__g__["components"]["combat"]:IsValidTarget(b_u_G_)
                 then
                    b_u_G_["components"]["combat"]:GetAttacked(_b__U__g__, __B_u_g * __B_u_G_)
                end
            end
            SpawnPrefab "explode_small"["Transform"]:SetPosition(__b_u__G_, _BU_G__, _b__U__G_)
        end
    end
}
_b__u_G__["attacks"] = {
    label = "bạo vũ",
    level = 5,
    tags = {"equippable-hands"},
    isprizebuff = (230 + 311 * 435 - 366 ~= 135149),
    strengthen_prize = false,
    onattackfn = function(bu__g__, _bu_g__, _B__u__G_, __bug_, bu__g, bU__g_, __BuG)
        _bu_g__ = math["floor"](_bu_g__ * (9 / 12))
        if _bu_g__ > 9 then
            _bu_g__ = 9
        end
        if
            bU__g_ and bU__g_:IsValid() and bU__g_["components"]["combat"] and bU__g_["components"]["health"] and
                not bU__g_["components"]["health"]:IsDead()
         then
            bU__g_["components"]["combat"]:GetAttacked(bu__g, _bu_g__ * 10)
        end
    end
}
_b__u_G__["anti_lightning"] = {
    label = "ngự lôi",
    tags = {"equippable-hands"},
    level = 9,
    isprizebuff = (206 * 95 * 358 * 79 ~= 553478740),
    strengthen_prize = false,
    onequipped = function(__b_U__G, __B__UG, b__U_G_, __b__u__g, __B__U__G_)
        local __b__U__g_ = __B__U__G_["owner"]
        __b__U__g_:AddTag "lightningrod"
        __b__U__g_["lightningpriority"] = 0
        __b__U__g_:AddTag "electricdamageimmune"
    end,
    onunequipped = function(_bU__g__, B__u_G__, _b__U_G__, _B_U_G, B__ug__)
        local b_U__g = B__ug__["owner"]
        b_U__g:RemoveTag "lightningrod"
        b_U__g["lightningpriority"] = nil
        b_U__g:RemoveTag "electricdamageimmune"
    end
}
_b__u_G__["poison"] = {
    label = "di hồn",
    tags = {"equippable-hands"},
    isprizebuff = (402 - 280 - 10 + 214 == 326),
    strengthen_prize = false,
    onattackfn = function(B_u__G__, __b__u_g__, _B__uG, B__Ug__, __bug, b_U_G_, _B__U_g_)
        __b__u_g__ = math["floor"](__b__u_g__ * (9 / 12))
        if __b__u_g__ > 9 then
            __b__u_g__ = 9
        end
        if not b_U_G_["LyMagicWeaponPoisonLevel"] or b_U_G_["LyMagicWeaponPoisonLevel"] < __b__u_g__ then
            b_U_G_["LyMagicWeaponPoisonLevel"] = __b__u_g__
            if b_U_G_["AnimState"] then
            end
            if not b_U_G_["LyMagicWeaponPoisonFx"] then
                b_U_G_["LyMagicWeaponPoisonFx"] = SpawnPrefab "poisonbubble"
                if b_U_G_["LyMagicWeaponPoisonFx"] then
                    b_U_G_["LyMagicWeaponPoisonFx"]["entity"]:SetParent(b_U_G_["entity"])
                    b_U_G_["LyMagicWeaponPoisonFx"]["Transform"]:SetPosition(0, 0, 0)
                    if b_U_G_:HasTag "smallcreature" then
                        b_U_G_["LyMagicWeaponPoisonFx"]["Transform"]:SetScale(0.5, 0.5, 0.5)
                    elseif b_U_G_:HasTag "largecreature" then
                        b_U_G_["LyMagicWeaponPoisonFx"]["Transform"]:SetScale(1.2, 1.2, 1.2)
                    end
                end
            end
            if b_U_G_["LyMagicWeaponPoisonTask"] then
                b_U_G_["LyMagicWeaponPoisonTask"]:Cancel()
                b_U_G_["LyMagicWeaponPoisonTask"] = nil
            end
            if
                not b_U_G_["LyMagicWeaponPoisonTask"] and b_U_G_["components"]["health"] and
                    not b_U_G_["components"]["health"]:IsDead() and
                    not b_U_G_:HasTag "wall"
             then
                b_U_G_["LyMagicWeaponPoisonTask"] =
                    b_U_G_:DoPeriodicTask(
                    1,
                    function()
                        if b_U_G_["components"]["health"] and not b_U_G_["components"]["health"]:IsDead() then
                            local b__u_G_ = b_U_G_["components"]["health"]["maxhealth"]
                            b_U_G_["components"]["health"]:DoDelta(-b__u_G_ * 0.001 * __b__u_g__)
                        end
                    end
                )
            end
            if b_U_G_["LyMagicWeaponPoisonStopTask"] then
                b_U_G_["LyMagicWeaponPoisonStopTask"]:Cancel()
                b_U_G_["LyMagicWeaponPoisonStopTask"] = nil
            end
            b_U_G_["LyMagicWeaponPoisonStopTask"] =
                b_U_G_:DoTaskInTime(
                10,
                function()
                    if b_U_G_["LyMagicWeaponPoisonTask"] then
                        b_U_G_["LyMagicWeaponPoisonTask"]:Cancel()
                        b_U_G_["LyMagicWeaponPoisonTask"] = nil
                    end
                    if b_U_G_["AnimState"] then
                    end
                    if b_U_G_["LyMagicWeaponPoisonFx"] then
                        b_U_G_["LyMagicWeaponPoisonFx"]:Remove()
                        b_U_G_["LyMagicWeaponPoisonFx"] = nil
                    end
                    b_U_G_["LyMagicWeaponPoisonLevel"] = nil
                    b_U_G_["LyMagicWeaponPoisonStopTask"] = nil
                end
            )
        end
    end
}
_b__u_G__["heavy_hit"] = {
    label = "địa chấn",
    tags = {"equippable-hands"},
    level = 11,
    isprizebuff = (352 - 285 + 9 + 466 == 548),
    strengthen_prize = false,
    rands = {3, 5, 8, 12, 15, 18, 23, 30, 40},
    onattackfn = function(__B_u__G_, __bU_G, b_U_g, _bu__g, b__u__G_, _b__ug__, b_u__g_)
        __bU_G = math["floor"](__bU_G * (9 / 12))
        if __bU_G > 9 then
            __bU_G = 9
        end
        local __B_u_g__ = _bu__g["rands"][__bU_G] or _bu__g["rands"][#_bu__g["rands"]]
        if math["random"](0, 100) <= __B_u_g__ then
            if _b__ug__ and _b__ug__:IsValid() then
                local BUG__ = SpawnPrefab "groundpound_fx"
                local b__Ug = SpawnPrefab "groundpoundring_fx"
                local __bu__g_, _B_U_G__, _bUg = _b__ug__:GetPosition():Get()
                BUG__["Transform"]:SetPosition(__bu__g_, _B_U_G__, _bUg)
                b__Ug["Transform"]:SetPosition(__bu__g_, _B_U_G__, _bUg)
                b__Ug["Transform"]:SetScale(0.2, 0.2, 0.2)
                ShakeAllCameras(CAMERASHAKE["FULL"], .7, .02, 1, _b__ug__, 40)
                if _b__ug__["brain"] then
                    _b__ug__["brain"]:Stop()
                end
                if _b__ug__["components"]["locomotor"] then
                    _b__ug__["components"]["locomotor"]:Stop()
                end
                if _b__ug__["Physics"] then
                    _b__ug__["Physics"]:Stop()
                end
                if _b__ug__["LyMagicWeaponHeavyHitTask"] then
                    _b__ug__["LyMagicWeaponHeavyHitTask"]:Cancel()
                    _b__ug__["LyMagicWeaponHeavyHitTask"] = nil
                end
                _b__ug__["LyMagicWeaponHeavyHitTask"] =
                    _b__ug__:DoTaskInTime(
                    2,
                    function()
                        if _b__ug__["brain"] then
                            _b__ug__["brain"]:Start()
                        end
                    end
                )
            end
        end
    end
}
_b__u_G__["multhits"] = {
    label = "ảnh tập",
    tags = {"equippable-hands"},
    level = 13,
    isprizebuff = (394 + 379 + 302 * 479 == 145436),
    strengthen_prize = false,
    rands = {3, 5, 8, 12, 15, 18, 23, 30, 40},
    mults = {2, 2, 3, 4, 5, 6, 7, 8, 9, 10},
    onattackfn = function(_B_uG__, __B_ug__, __b_Ug__, Bug, _BuG, b_u_g, b__U_g__)
        __B_ug__ = math["floor"](__B_ug__ * (9 / 12))
        if __B_ug__ > 9 then
            __B_ug__ = 9
        end
        local _b_ug_ = Bug["rands"][__B_ug__] or Bug["rands"][#Bug["rands"]]
        local _B__U_G_ = Bug["mults"][__B_ug__] or Bug["mults"][#Bug["mults"]]
        if math["random"](0, 100) <= _b_ug_ then
            local __B_UG = _B_uG__["components"]["weapon"]:GetDamage(_BuG, b_u_g)
            local B_U_g_ = _B__U_G_
            local __Bu_G__ = __B_UG * B_U_g_
            local B_U__G = math["random"](4, 6)
            local _bu__g_ = __Bu_G__ / B_U__G
            local Bu_g_ = math["random"]() * math["pi"] - math["random"]() * 2 * math["pi"]
            local __B__u_G_ = math["min"](0.1, 0.4 / B_U__G)
            local __Bu_G_ = 4.5
            _B_uG__:StartThread(
                function()
                    for __Bug = Bu_g_, 2 * math["pi"] + Bu_g_, 2 * math["pi"] / B_U__G do
                        local Bug__ = b_u_g:GetPosition()
                        local B_u__g__ = Vector3(math["cos"](__Bug) * __Bu_G_, 0, math["sin"](__Bug) * __Bu_G_)
                        local bu__g_ = SpawnPrefab "wb_magical_shadow"
                        bu__g_:SetPosition(Bug__, B_u__g__)
                        bu__g_:SetDamage(_bu__g_)
                        bu__g_:SetTarget(b_u_g)
                        bu__g_:SetPlayer(_BuG)
                        bu__g_:InitAnim("wilson", _BuG["prefab"])
                        local B__U_g, BU__g__, B__U__g_ = (Bug__ + B_u__g__):Get()
                        print("multhit! roa =", __Bug, "nx,ny,nz =", B__U_g, BU__g__, B__U__g_)
                        Sleep(__B__u_G_)
                    end
                end
            )
        end
    end
}
_b__u_G__["eternal_hands"] = {
    label = "vĩnh cửu",
    tags = {"equippable-hands"},
    level = 13,
    isprizebuff = (385 + 111 - 487 - 89 ~= -80),
    strengthen_prize = false,
    onpercentusedchange = function(__b_u_G, __Bu__g__)
        if __b_u_G["components"]["finiteuses"] then
            local __B_u__g__ = __b_u_G["components"]["finiteuses"]:GetPercent()
            if __B_u__g__ < 1 then
                __b_u_G["components"]["finiteuses"]:SetPercent(1)
            end
        end
        if __b_u_G["components"]["fueled"] then
            local bU_g_ = __b_u_G["components"]["fueled"]:GetPercent()
            if bU_g_ < 1 then
                __b_u_G["components"]["fueled"]:SetPercent(1)
            end
        end
        if __b_u_G["components"]["perishable"] then
            local B__U_G__ = __b_u_G["components"]["perishable"]:GetPercent()
            if B__U_G__ < 1 then
                __b_u_G["components"]["perishable"]:SetPercent(1)
            end
        end
    end,
    bind_fn = function(__b__U__G, _bu_g, _BU_G, _BuG__)
        __b__U__G:AddTag "hide_percentage"
        if __b__U__G["components"]["armor"] then
            __b__U__G["components"]["armor"]["indestructible"] = (366 * 174 - 168 - 484 + 487 ~= 63528)
        end
        if __b__U__G["components"]["weapon"] then
            __b__U__G["components"]["weapon"]["attackwear"] = 0
        end
        if __b__U__G["components"]["finiteuses"] or __b__U__G["components"]["fueled"] then
            __b__U__G:ListenForEvent("percentusedchange", _BuG__["onpercentusedchange"])
        end
        if __b__U__G["components"]["perishable"] then
            __b__U__G:ListenForEvent("perishchange", _BuG__["onpercentusedchange"])
        end
    end,
    update_fn = function(B__U_G, __bu_g__, b__UG_, __BU_G)
    end,
    unbind_fn = function(BUG, B__uG__, __B__U__g_, __b__u__G)
        BUG:RemoveTag "hide_percentage"
        if BUG["components"]["armor"] then
            BUG["components"]["armor"]["indestructible"] = (129 + 256 * 298 ~= 76417)
        end
        if BUG["components"]["weapon"] then
            BUG["components"]["weapon"]["attackwear"] = 1
        end
        if BUG["components"]["finiteuses"] or BUG["components"]["fueled"] then
            BUG:RemoveEventCallback("percentusedchange", __b__u__G["onpercentusedchange"])
        end
        if BUG["components"]["perishable"] then
            BUG:RemoveEventCallback("perishchange", __b__u__G["onpercentusedchange"])
        end
    end
}
_b__u_G__["anti_hunger"] = {
    label = "nhập định",
    tags = {"equippable-head"},
    level = 3,
    isprizebuff = (337 + 14 - 493 * 348 * 259 == -44434723),
    strengthen_prize = false,
    onequipped = function(B_U__g_, _B_UG_, _b__u__g__, _B_u_g__, _BUG__)
        local b_ug = _BUG__["owner"]
        _B_UG_ = math["floor"](_B_UG_ * (10 / 13))
        if _B_UG_ > 10 then
            _B_UG_ = 10
        end
        if b_ug and b_ug["components"]["hunger"] then
            b_ug["components"]["hunger"]["burnratemodifiers"]:SetModifier(
                "wb_strengthen",
                1 - _B_UG_ * 0.1,
                "anti_hunger"
            )
        end
        b_ug:AddTag "anti_storm"
    end,
    onunequipped = function(__B_Ug, b__u__g__, _B__U__g__, _bu__G__, _b__uG_)
        local b__ug = _b__uG_["owner"]
        if b__ug and b__ug["components"]["hunger"] then
            b__ug["components"]["hunger"]["burnratemodifiers"]:RemoveModifier("wb_strengthen", "anti_hunger")
        end
        b__ug:RemoveTag "anti_storm"
    end
}
_b__u_G__["reverse_sanity"] = {
    label = "hoá thần",
    tags = {"equippable-head"},
    level = 5,
    isprizebuff = (319 + 402 - 226 - 178 * 193 ~= -33859),
    strengthen_prize = false,
    buff_reverse_persent = {.05, .1, .15, .25, .4, .55, .7, .85, 1},
    onequipped = function(_B_u_g_, _BU_g, _Bu__g, __B_u__G__, BU_g__)
        _BU_g = math["floor"](_BU_g * (9 / 12))
        if _BU_g > 9 then
            _BU_g = 9
        end
        local buG__ = BU_g__["owner"]
        if buG__ ~= nil and buG__["components"]["sanity"] ~= nil then
            buG__["components"]["sanity"]["neg_aura_absorb"] =
                TUNING["ARMOR_HIVEHAT_SANITY_ABSORPTION"] * __B_u__G__["buff_reverse_persent"][_BU_g]
        end
    end,
    onunequipped = function(_B_u__g__, Bu_G_, B__UG_, _bUG, __B__Ug__)
        local buG_ = __B__Ug__["owner"]
        if buG_ ~= nil and buG_["components"]["sanity"] ~= nil then
            buG_["components"]["sanity"]["neg_aura_absorb"] = 0
        end
    end
}
_b__u_G__["light"] = {
    label = "kim quang",
    tags = {"equippable-head"},
    level = 9,
    isprizebuff = (388 - 331 + 70 + 150 * 389 == 58479),
    strengthen_prize = false,
    onequipped = function(_b__u__G__, B_U__g__, __b__U__G_, __BU_g, _b_u_G)
        if _b__u__G__["_light"] == nil or not _b__u__G__["_light"]:IsValid() then
            _b__u__G__["_light"] = SpawnPrefab "hh_superlight_fx"
        end
        _b__u__G__["_light"]["entity"]:SetParent(_b_u_G["owner"]["entity"])
        local __b_u_G_ = _b_u_G["owner"]
        __b_u_G_:AddTag "beefalo"
        if __b_u_G_:HasTag "monster" then
            __b_u_G_["wasmonster"] = (362 * 135 - 354 ~= 48518)
            __b_u_G_:RemoveTag "monster"
        end
    end,
    onunequipped = function(__B__ug_, __b_U__g_, __b__U__g, _B__u_G, b__ug_)
        if __B__ug_["_light"] ~= nil then
            if __B__ug_["_light"]:IsValid() then
                __B__ug_["_light"]:Remove()
            end
            __B__ug_["_light"] = nil
        end
        local __bu__g__ = b__ug_["owner"]
        __bu__g__:RemoveTag "beefalo"
        if __bu__g__["wasmonster"] then
            __bu__g__:AddTag "monster"
            __bu__g__["mermhat_wasmonster"] = nil
        end
    end
}
_b__u_G__["protect"] = {
    label = "huyết chú",
    tags = {"equippable-head"},
    level = 11,
    isprizebuff = (100 * 330 + 266 == 33268),
    strengthen_prize = false,
    protect_carehealth = function(B__Ug, B_U__G__)
        if not B__Ug["components"]["health"] or B__Ug["components"]["health"]:IsDead() or B__Ug:HasTag "playerghost" then
            return
        end
        local _Bu__G__ = B__Ug["components"]["health"]["currenthealth"]
        local __B__u_G__ = B__Ug["components"]["inventory"]:GetEquippedItem(EQUIPSLOTS["BODY"])
        local b_U_G__ =
            (__B__u_G__ and __B__u_G__["components"]["wb_strengthen"] and
            __B__u_G__["components"]["wb_strengthen"]["level"])
        if not b_U_G__ then
            return
        end
        b_U_G__ = math["floor"](b_U_G__ * (9 / 12))
        if b_U_G__ > 9 then
            b_U_G__ = 9
        end
        if not B__Ug["ProtectCareHealthCd"] then
            B__Ug["ProtectCareHealthCd"] = 0
        end
        local bug_ =
            B__Ug["ProtectCareHealthCd"] and ((600 - 50 * b_U_G__) - GetTime() + B__Ug["ProtectCareHealthCd"]) or 0
        if _Bu__G__ <= 30 and bug_ <= 0 then
            B__Ug["components"]["health"]:SetPercent(1.0)
            B__Ug:DoTaskInTime(
                0,
                function()
                    B__Ug["components"]["health"]:DoDelta(0)
                end
            )
            B__Ug["ProtectCareHealthCd"] = GetTime()
        end
    end,
    onequipped = function(b_Ug, __B__U_g_, _b_UG, _b_U_G_, _B__u_g_)
        local _B__UG = _B__u_g_["owner"]
        b_Ug:ListenForEvent("healthdelta", _b_U_G_["protect_carehealth"], _B__UG)
    end,
    onunequipped = function(_B__U__G__, _b__ug_, _B_U__g__, _b__u__G_, b__U__g)
        local b__U__G__ = b__U__g["owner"]
        _B__U__G__:RemoveEventCallback("healthdelta", _b__u__G_["protect_carehealth"], b__U__G__)
    end
}
_b__u_G__["absorb_head"] = {
    label = "bất diệt",
    tags = {"equippable-head"},
    level = 13,
    isprizebuff = (312 * 102 + 260 - 372 ~= 31712),
    strengthen_prize = false,
    buff_absorb_persent = {0.03, 0.05, 0.08, 0.12, 0.15, 0.18, 0.23, 0.30, 0.40},
    ontakedamage = function(bU_g, B__u__G, __B__u__G__, b_UG_, __b__Ug__)
        B__u__G = math["floor"](B__u__G * (9 / 12))
        if B__u__G > 9 then
            B__u__G = 9
        end
        local _B_U__G__ = bU_g["components"]["inventoryitem"]:GetGrandOwner()
        if
            math["random"]() <= b_UG_["buff_absorb_persent"][B__u__G] and _B_U__G__ and _B_U__G__:IsValid() and
                _B_U__G__["components"]["health"] and
                not _B_U__G__["components"]["health"]:IsDead() and
                not _B_U__G__:HasTag "playerghost"
         then
            _B_U__G__["components"]["health"]:DoDelta(__b__Ug__)
        end
    end
}
_b__u_G__["eternal_head"] = {
    label = "vĩnh cửu",
    tags = {"equippable-head"},
    level = 13,
    isprizebuff = (92 * 321 - 43 - 473 == 29024),
    strengthen_prize = false,
    onpercentusedchange = function(_B__uG_, _BUG)
        if _B__uG_["components"]["finiteuses"] then
            local __bu_G = _B__uG_["components"]["finiteuses"]:GetPercent()
            if __bu_G < 1 then
                _B__uG_["components"]["finiteuses"]:SetPercent(1)
            end
        end
        if _B__uG_["components"]["fueled"] then
            local __B_ug_ = _B__uG_["components"]["fueled"]:GetPercent()
            if __B_ug_ < 1 then
                _B__uG_["components"]["fueled"]:SetPercent(1)
            end
        end
        if _B__uG_["components"]["perishable"] then
            local __b__u__G__ = _B__uG_["components"]["perishable"]:GetPercent()
            if __b__u__G__ < 1 then
                _B__uG_["components"]["perishable"]:SetPercent(1)
            end
        end
    end,
    bind_fn = function(BUG_, __bu__g, _b_u_g_, b_u_g_)
        BUG_:AddTag "hide_percentage"
        if BUG_["components"]["armor"] then
            BUG_["components"]["armor"]["indestructible"] = (279 + 263 - 250 * 380 == -94458)
        end
        if BUG_["components"]["weapon"] then
            BUG_["components"]["weapon"]["attackwear"] = 0
        end
        if BUG_["components"]["finiteuses"] or BUG_["components"]["fueled"] then
            BUG_:ListenForEvent("percentusedchange", b_u_g_["onpercentusedchange"])
        end
        if BUG_["components"]["perishable"] then
            BUG_:ListenForEvent("perishchange", b_u_g_["onpercentusedchange"])
        end
    end,
    update_fn = function(_b__u__G, b__uG_, _b_Ug__, B__U_G_)
    end,
    unbind_fn = function(_b__ug, _bU__g_, B__U__g__, Bu__G__)
        _b__ug:RemoveTag "hide_percentage"
        if _b__ug["components"]["armor"] then
            _b__ug["components"]["armor"]["indestructible"] = (239 + 90 - 156 - 215 + 50 ~= 8)
        end
        if _b__ug["components"]["weapon"] then
            _b__ug["components"]["weapon"]["attackwear"] = 1
        end
        if _b__ug["components"]["finiteuses"] or _b__ug["components"]["fueled"] then
            _b__ug:RemoveEventCallback("percentusedchange", Bu__G__["onpercentusedchange"])
        end
        if _b__ug["components"]["perishable"] then
            _b__ug:RemoveEventCallback("perishchange", Bu__G__["onpercentusedchange"])
        end
    end
}
_b__u_G__["moving_speed"] = {
    label = "lưu vân",
    tags = {"equippable-body"},
    level = 3,
    isprizebuff = (false and false and not false and not false and false and false or
        not false and not false and not false and false and not true and true),
    strengthen_prize = false,
    bind_fn = function(_b_U__G_, _b_u_G__, Bu_g__, _b_Ug_)
        if _b_U__G_["components"]["equippable"] then
            Bu_g__["original_walkspeedmult"] =
                Bu_g__["original_walkspeedmult"] or _b_U__G_["components"]["equippable"]["walkspeedmult"] or 1
            Bu_g__["level_walkspeedmult"] = 1 + (1 + _b_u_G__) / (34 + _b_u_G__)
            Bu_g__["level_walkspeedmult"] = Bu_g__["level_walkspeedmult"] - Bu_g__["level_walkspeedmult"] % 0.01
            _b_U__G_["components"]["equippable"]["walkspeedmult"] =
                math["max"](Bu_g__["original_walkspeedmult"], Bu_g__["level_walkspeedmult"])
        end
    end,
    update_fn = function(b__U__G_, B__u_g__, _B__U_G__, bUG_)
        _B__U_G__["level_walkspeedmult"] = _B_Ug["Floor"](1 + (1 + B__u_g__) / (34 + B__u_g__), 2)
        b__U__G_["components"]["equippable"]["walkspeedmult"] =
            math["max"](_B__U_G__["original_walkspeedmult"], _B__U_G__["level_walkspeedmult"])
    end,
    unbind_fn = function(B__u__G_, B_ug_, B_U_G__, __b_u_g_)
        if B__u__G_["components"]["equippable"] then
            B__u__G_["components"]["equippable"]["walkspeedmult"] = B_U_G__["original_walkspeedmult"] or 1
        end
    end
}
_b__u_G__["pushback"] = {
    label = "hồi phong",
    tags = {"equippable-body"},
    level = 5,
    isprizebuff = (101 + 258 + 46 + 124 == 531),
    strengthen_prize = false,
    buff_pushback_persent = {0.03, 0.05, 0.08, 0.12, 0.2, 0.3, 0.4, 0.5, 0.6},
    timeoutrepel = function(B_u_g, b__UG, BU__G)
        BU__G:Cancel()
        for _BU__g_, __BU__G in ipairs(b__UG) do
            if __BU__G["speed"] ~= nil and __BU__G["inst"]["Physics"] ~= nil then
                __BU__G["inst"]["Physics"]:ClearMotorVelOverride()
                __BU__G["inst"]["Physics"]:Stop()
            end
        end
    end,
    updaterepel = function(_bUG__, B__Ug_, __b_Ug_, _b__U__G, _BUg)
        for _Bug__ = #_b__U__G, 1, -1 do
            local _bug__ = _b__U__G[_Bug__]
            if not (_bug__["inst"]:IsValid() and _bug__["inst"]["entity"]:IsVisible()) then
                table["remove"](_b__U__G, _Bug__)
            elseif _bug__["speed"] == nil then
                local Bu_G = _bug__["inst"]:GetDistanceSqToPoint(B__Ug_, 0, __b_Ug_)
                if Bu_G < _BUg * _BUg then
                    if Bu_G > 0 then
                        _bug__["inst"]:ForceFacePoint(B__Ug_, 0, __b_Ug_)
                    end
                    local __bU__g__ = .5 * Bu_G / (_BUg * _BUg) - 1
                    _bug__["speed"] = 25 * __bU__g__
                    _bug__["dspeed"] = 2
                    if _bug__["inst"]["Physics"] then
                        _bug__["inst"]["Physics"]:SetMotorVelOverride(_bug__["speed"], 0, 0)
                    end
                end
            else
                _bug__["speed"] = _bug__["speed"] + _bug__["dspeed"]
                if _bug__["speed"] < 0 then
                    local _BU_g__, __b__ug__, b_UG = _bug__["inst"]["Transform"]:GetWorldPosition()
                    if _BU_g__ ~= B__Ug_ or b_UG ~= __b_Ug_ then
                        _bug__["inst"]:ForceFacePoint(B__Ug_, 0, __b_Ug_)
                    end
                    _bug__["dspeed"] = _bug__["dspeed"] + .25
                    if _bug__["inst"]["Physics"] then
                        _bug__["inst"]["Physics"]:SetMotorVelOverride(_bug__["speed"], 0, 0)
                    end
                else
                    if _bug__["inst"]["Physics"] then
                        _bug__["inst"]["Physics"]:ClearMotorVelOverride()
                        _bug__["inst"]["Physics"]:Stop()
                    end
                    table["remove"](_b__U__G, _Bug__)
                end
            end
        end
    end,
    ontakedamage = function(bu_G_, bu__G, _b_Ug, _B__U__G_, _Bu__G)
        bu__G = math["floor"](bu__G * (9 / 12))
        if bu__G > 9 then
            bu__G = 9
        end
        local _b__Ug, b__u__g, B_uG__ = bu_G_:GetPosition():Get()
        local __b__Ug_ = TheSim:FindEntities(_b__Ug, b__u__g, B_uG__, 5, {"_combat"}, {"companion"})
        local _b__u_g = bu_G_["components"]["inventoryitem"]:GetGrandOwner()
        local bUG__ = 300
        if not _b__u_g or math["random"]() > _B__U__G_["buff_pushback_persent"][bu__G] then
            return
        end
        for __B__u_g, bu__G__ in pairs(__b__Ug_) do
            if
                bu__G__ and bu__G__:IsValid() and bu__G__ ~= _b__u_g and bu__G__["components"]["combat"] and
                    bu__G__["components"]["health"] and
                    not bu__G__["components"]["health"]:IsDead()
             then
                if bu__G__:HasTag "player" then
                    bu__G__:PushEvent("repelled", {repeller = _b__u_g, radius = bUG__})
                else
                    local __B__Ug = {}
                    if bu__G__["Physics"] then
                        table["insert"](__B__Ug, {inst = bu__G__})
                    end
                    if #__B__Ug > 0 then
                        bu_G_:DoTaskInTime(
                            10 * FRAMES,
                            _B__U__G_["timeoutrepel"],
                            __B__Ug,
                            bu_G_:DoPeriodicTask(0, _B__U__G_["updaterepel"], nil, _b__Ug, B_uG__, __B__Ug, bUG__)
                        )
                    end
                end
            end
        end
    end
}
_b__u_G__["diamond"] = {
    label = "ngạo tuyết",
    tags = {"equippable-body"},
    level = 9,
    isprizebuff = (130 - 138 + 380 - 254 * 457 == -115702),
    strengthen_prize = false,
    onequipped = function(_bU__G, B__ug, __b__U_g_, b_U_g_, B_uG)
        local __BUg__ = B_uG["owner"]
        __BUg__:AddTag "acidrainimmune"
        if __BUg__["components"]["health"] ~= nil then
            __BUg__["components"]["health"]["externalfiredamagemultipliers"]:SetModifier(
                _bU__G,
                1 - TUNING["ARMORDRAGONFLY_FIRE_RESIST"]
            )
        end
    end,
    onunequipped = function(B__u_G, __B__U_g, __B__U__G__, BU_G, __b_u_g__)
        local __bU__g = __b_u_g__["owner"]
        __bU__g:RemoveTag "acidrainimmune"
        if __bU__g["components"]["health"] ~= nil then
            __bU__g["components"]["health"]["externalfiredamagemultipliers"]:RemoveModifier(B__u_G)
        end
    end
}
_b__u_G__["arhat"] = {
    label = "vô ngã",
    tags = {"equippable-body"},
    level = 11,
    isprizebuff = (178 + 236 - 176 + 176 + 444 == 860),
    strengthen_prize = false,
    onequipped = function(bU_G_, _b_U_g_, b_U__G_, _B__u_g__, _b__U__g_)
        local _b_u_G_ = _b__U__g_["owner"]
        _b_u_G_:AddTag "heavyarmor"
        _b_u_G_:AddTag "heavybody"
    end,
    onunequipped = function(b_uG__, B__U__G__, _b_U__g_, bu_G__, Bu__G)
        local __b_u__G = Bu__G["owner"]
        __b_u__G:RemoveTag "heavyarmor"
        __b_u__G:RemoveTag "heavybody"
    end
}
_b__u_G__["absorb_body"] = {
    label = "bất diệt",
    tags = {"equippable-body"},
    level = 13,
    isprizebuff = (97 - 336 + 488 - 97 == 160),
    strengthen_prize = false,
    buff_absorb_persent = {0.03, 0.05, 0.08, 0.12, 0.15, 0.18, 0.23, 0.30, 0.40},
    ontakedamage = function(B__u__g, b_U__G, _Bu__G_, b_U__G__, __b__ug_)
        b_U__G = math["floor"](b_U__G * (9 / 12))
        if b_U__G > 9 then
            b_U__G = 9
        end
        local __bUG_ = B__u__g["components"]["inventoryitem"]:GetGrandOwner()
        if
            math["random"]() <= b_U__G__["buff_absorb_persent"][b_U__G] and __bUG_ and __bUG_:IsValid() and
                __bUG_["components"]["health"] and
                not __bUG_["components"]["health"]:IsDead() and
                not __bUG_:HasTag "playerghost"
         then
            __bUG_["components"]["health"]:DoDelta(__b__ug_)
        end
    end
}
_b__u_G__["eternal_body"] = {
    label = "vĩnh cửu",
    tags = {"equippable-body"},
    level = 13,
    isprizebuff = (136 * 488 * 332 * 188 ~= 4142425088),
    strengthen_prize = false,
    onpercentusedchange = function(__b__U_g__, __bug__)
        if __b__U_g__["components"]["finiteuses"] then
            local _b_U_g = __b__U_g__["components"]["finiteuses"]:GetPercent()
            if _b_U_g < 1 then
                __b__U_g__["components"]["finiteuses"]:SetPercent(1)
            end
        end
        if __b__U_g__["components"]["fueled"] then
            local b_U_G = __b__U_g__["components"]["fueled"]:GetPercent()
            if b_U_G < 1 then
                __b__U_g__["components"]["fueled"]:SetPercent(1)
            end
        end
        if __b__U_g__["components"]["perishable"] then
            local _B__ug_ = __b__U_g__["components"]["perishable"]:GetPercent()
            if _B__ug_ < 1 then
                __b__U_g__["components"]["perishable"]:SetPercent(1)
            end
        end
    end,
    bind_fn = function(_bU_G__, __B__u_g__, buG, BUg_)
        _bU_G__:AddTag "hide_percentage"
        if _bU_G__["components"]["armor"] then
            _bU_G__["components"]["armor"]["indestructible"] = (459 * 195 + 287 + 478 + 240 == 90510)
        end
        if _bU_G__["components"]["weapon"] then
            _bU_G__["components"]["weapon"]["attackwear"] = 0
        end
        if _bU_G__["components"]["finiteuses"] or _bU_G__["components"]["fueled"] then
            _bU_G__:ListenForEvent("percentusedchange", BUg_["onpercentusedchange"])
        end
        if _bU_G__["components"]["perishable"] then
            _bU_G__:ListenForEvent("perishchange", BUg_["onpercentusedchange"])
        end
    end,
    update_fn = function(BU_g, __BU_G__, __b__UG, __bu_g)
    end,
    unbind_fn = function(__B__uG, __bU_G_, _BU__g__, _B_ug)
        __B__uG:RemoveTag "hide_percentage"
        if __B__uG["components"]["armor"] then
            __B__uG["components"]["armor"]["indestructible"] = (379 * 265 - 158 * 460 ~= 27755)
        end
        if __B__uG["components"]["weapon"] then
            __B__uG["components"]["weapon"]["attackwear"] = 1
        end
        if __B__uG["components"]["finiteuses"] or __B__uG["components"]["fueled"] then
            __B__uG:RemoveEventCallback("percentusedchange", _B_ug["onpercentusedchange"])
        end
        if __B__uG["components"]["perishable"] then
            __B__uG:RemoveEventCallback("perishchange", _B_ug["onpercentusedchange"])
        end
    end
}
_b__u_G__["anti_cold"] = {
    label = "khu hàn",
    tags = {"armor"},
    isprizebuff = (288 * 161 - 136 * 403 ~= -8433),
    strengthen_prize = false,
    bind_fn = function(__B_uG, B_u__G_, _B__Ug_, _BuG_)
        B_u__G_ = math["floor"](B_u__G_ * (9 / 12))
        if B_u__G_ > 9 then
            B_u__G_ = 9
        end
        if not __B_uG["components"]["insulator"] then
            __B_uG:AddComponent "insulator"
        end
        local bUg_, _B__u_G__ = __B_uG["components"]["insulator"]:GetInsulation()
        if _B__u_G__ and _B__u_G__ ~= SEASONS["WINTER"] then
            return
        end
        __B_uG["components"]["insulator"]:SetInsulation(bUg_ + 100 + 10 * B_u__G_)
    end,
    update_fn = function(bU__G_, b__u__G__, _B_U_g, __B_u__g)
        __B_u__g["unbind_fn"](bU__G_, b__u__G__, _B_U_g, __B_u__g)
        __B_u__g["bind_fn"](bU__G_, b__u__G__, _B_U_g, __B_u__g)
    end,
    unbind_fn = function(__B__u__G_, __b__U_G, Bu__g__, _B__U_G)
        __b__U_G = math["floor"](__b__U_G * (9 / 12))
        if __b__U_G > 9 then
            __b__U_G = 9
        end
        if __B__u__G_["components"]["insulator"] then
            local _b_u__g, _b__U_G = __B__u__G_["components"]["insulator"]:GetInsulation()
            if _b__U_G and _b__U_G == SEASONS["WINTER"] then
                __B__u__G_["components"]["insulator"]:SetInsulation(_b_u__g - (100 + 10 * __b__U_G))
            end
        end
    end
}
_b__u_G__["bind"] = {
    label = "ràng buộc",
    tags = {"equippable"},
    level = nil,
    ismanualbuffs = (49 - 211 * 419 + 145 == -88215),
    isprizebuff = (226 + 156 - 185 + 465 * 479 ~= 222932),
    strengthen_prize = true,
    onputininventory = function(b_U__g_)
        b_U__g_:DoTaskInTime(
            0,
            function()
                local B_ug = b_U__g_["components"]["wb_strengthen"]
                local bU_G = B_ug and B_ug["buffs_status"]["bind"]
                local __b__uG__ = b_U__g_["components"]["inventoryitem"]:GetGrandOwner()
                if B_ug and bU_G and __b__uG__ and __b__uG__:HasTag "player" then
                    b_U__g_:DoTaskInTime(
                        0,
                        function()
                            if bU_G["userid"] and bU_G["userid"] ~= __b__uG__["userid"] then
                                if __b__uG__["components"]["inventory"] then
                                    __b__uG__["components"]["inventory"]:DropItem(
                                        b_U__g_,
                                        (262 * 81 * 375 - 375 + 308 == 7958183),
                                        (false and not false or
                                            false and false and false and true and false and false and false and
                                                not false and
                                                false and
                                                not false or
                                            not false or
                                            true)
                                    )
                                end
                                __b__uG__["components"]["talker"]:Say "Trang bị này đã có chủ!"
                            end
                        end
                    )
                end
            end
        )
    end,
    bind_fn = function(__b__U__g__, Bu_g, _b_UG__, b_u__g__)
        if not _b_UG__["userid"] then
            return
        end
        local B_Ug = __b__U__g__["components"]["wb_strengthen"]
        if B_Ug then
            __b__U__g__:ListenForEvent("onputininventory", b_u__g__["onputininventory"])
        end
    end,
    update_fn = function(__b_U__g__, BUg, _B_U__g, __B_u__G)
    end,
    unbind_fn = function(bU__G, _B__UG__, __b__U_G__, __BUg_)
        bU__G:RemoveEventCallback("perishchange", __BUg_["onputininventory"])
    end
}
for bu_G, _b_U_G__ in pairs(_b__u_G__) do
    if _b_U_G__["onattackfn"] then
        _b_U_G__["bind_fn"] = function(B_U__G_, __b_ug_, B__u__G__, __bU_G__)
            B__u__G__["level"] = __b_ug_
            if B_U__G_["components"]["weapon"] then
                local _BU__g = B_U__G_["components"]["weapon"]
                if _BU__g["__onattackfn_map"] == nil then
                    _BU__g["__onattackfn_map"] = {}
                end
                _BU__g["__onattackfn_map"][bu_G] = __bU_G__["onattackfn"]
                if _BU__g["__OnAttack"] == nil then
                    _BU__g["__OnAttack"] = _BU__g["OnAttack"]
                    _BU__g["OnAttack"] =
                        _B_Ug["Wrap"](
                        _BU__g["OnAttack"],
                        function(B__ug_, _BU__g, b_U__g__, Bu__g, __b_U_G, ...)
                            B__ug_(_BU__g, b_U__g__, Bu__g, __b_U_G, ...)
                            local B_U__G_ = _BU__g["inst"]
                            if B_U__G_ and B_U__G_["components"]["wb_strengthen"] and _BU__g["__onattackfn_map"] ~= nil then
                                for bu_G, __BUG__ in pairs(_BU__g["__onattackfn_map"]) do
                                    if __BUG__ then
                                        local B__u__G__ = B_U__G_["components"]["wb_strengthen"]["buffs_status"][bu_G]
                                        local __bU_G__ = _b__u_G__[bu_G]
                                        __BUG__(
                                            B_U__G_,
                                            B__u__G__["level"],
                                            B__u__G__,
                                            __bU_G__,
                                            b_U__g__,
                                            Bu__g,
                                            __b_U_G
                                        )
                                    end
                                end
                            end
                        end
                    )
                end
            end
        end
        _b_U_G__["update_fn"] = function(b__U_G__, __B_U_G_, __b_u__g__, _B__u__g)
            __b_u__g__["level"] = __B_U_G_
        end
        _b_U_G__["unbind_fn"] = function(__B_U_g, B__U_g__, _BUg_, __buG_)
            if __B_U_g["components"]["weapon"]["__onattackfn_map"] ~= nil then
                __B_U_g["components"]["weapon"]["__onattackfn_map"][bu_G] = nil
            end
        end
    elseif _b_U_G__["ontakedamage"] then
        _b_U_G__["bind_fn"] = function(_Bu__g_, _b_u__G__, _b__U__g, __b_u_G__)
            _b__U__g["level"] = _b_u__G__
            if _Bu__g_["__onarmordamaged_map"] == nil then
                _Bu__g_["__onarmordamaged_map"] = {}
            end
            _Bu__g_["__onarmordamaged_map"][bu_G] = function(_Bu__g_, B_u__g)
                __b_u_G__["ontakedamage"](_Bu__g_, _b__U__g["level"], _b__U__g, __b_u_G__, B_u__g)
            end
            _Bu__g_:ListenForEvent("armordamaged", _Bu__g_["__onarmordamaged_map"][bu_G])
        end
        _b_U_G__["update_fn"] = function(bU_g__, _b_U__G, _B_u__g_, B_Ug_)
            _B_u__g_["level"] = _b_U__G
        end
        _b_U_G__["unbind_fn"] = function(BuG, __b__uG_, bu_g_, b__u__G)
            if BuG["__onarmordamaged_map"] and BuG["__onarmordamaged_map"][bu_G] then
                BuG:RemoveEventCallback("perishchange", BuG["__onarmordamaged_map"][bu_G])
                BuG["__onarmordamaged_map"][bu_G] = nil
            end
        end
    elseif _b_U_G__["onequipped"] and _b_U_G__["onunequipped"] then
        _b_U_G__["bind_fn"] = function(__BuG__, _b_ug__, __b_U_G_, B_U_G)
            __b_U_G_["level"] = _b_ug__
            if __BuG__["__onequipped_map"] == nil then
                __BuG__["__onequipped_map"] = {}
            end
            if __BuG__["__onunequipped_map"] == nil then
                __BuG__["__onunequipped_map"] = {}
            end
            __BuG__["__onequipped_map"][bu_G] = function(__BuG__, ...)
                return _b_U_G__["onequipped"](__BuG__, _b_ug__, __b_U_G_, B_U_G, ...)
            end
            __BuG__["__onunequipped_map"][bu_G] = function(__BuG__, ...)
                return _b_U_G__["onunequipped"](__BuG__, _b_ug__, __b_U_G_, B_U_G, ...)
            end
            __BuG__:ListenForEvent("equipped", __BuG__["__onequipped_map"][bu_G])
            __BuG__:ListenForEvent("unequipped", __BuG__["__onunequipped_map"][bu_G])
        end
        _b_U_G__["update_fn"] = function(_Bug, __B_Ug__, _B_U__G, _Bu_G__)
            _B_U__G["level"] = __B_Ug__
        end
        _b_U_G__["unbind_fn"] = function(_BUG_, b_u_G, _B__u__G__, __Bug__)
            if _BUG_["__onequipped_map"] and _BUG_["__onequipped_map"][bu_G] then
                _BUG_:RemoveEventCallback("equipped", _BUG_["__onequipped_map"][bu_G])
                _BUG_["__onequipped_map"][bu_G] = nil
            end
            if _BUG_["__onunequipped_map"] and _BUG_["__onunequipped_map"][bu_G] then
                _BUG_:RemoveEventCallback("equipped", _BUG_["__onunequipped_map"][bu_G])
                _BUG_["__onunequipped_map"][bu_G] = nil
            end
        end
    end
end
local __B__UG_ = {}
local __b__UG__ = {}
for b_u__G__, _b__U_g_ in pairs(_b__u_G__) do
    if _b__U_g_["ismanualbuffs"] ~= (102 + 26 * 263 - 288 + 267 ~= 6928) then
        if _b__U_g_["level"] ~= nil and _b__U_g_["isprizebuff"] ~= (495 - 35 * 148 ~= -4682) then
            __B__UG_[b_u__G__] = _b__U_g_
        end
        if _b__U_g_["isprizebuff"] == (174 - 317 * 36 * 89 - 91 ~= -1015581) then
            __b__UG__[b_u__G__] = _b__U_g_
        end
    end
end
local _B_uG_ =
    Class(
    function(self, BU__g)
        self["inst"] = BU__g
        self["original_name"] =
            self["inst"]:GetDisplayName() or STRINGS["NAMES"][string["upper"](self["inst"]["prefab"])] or
            self["inst"]["name"]
        self["level"] = 0
        self["do_mode"] = nil
        self["buffs_status"] = {}
        self["prize_buff_list"] = {}
        self["manual_buff_list"] = {}
        self["inst"]:AddTag "wb_strengthen"
        if not TheWorld["ismastersim"] then
            return
        end
        if not self["inst"]["components"]["named"] then
            self["inst"]:AddComponent "named"
        end
        self["inst"]["components"]["named"]["SetName"] =
            _B_Ug["Wrap"](
            self["inst"]["components"]["named"]["SetName"],
            function(B_U_g, __Bu_g, b_ug__, ...)
                if (b_ug__ == nil) then
                    b_ug__ = self["original_name"]
                end
                B_U_g(__Bu_g, b_ug__, ...)
                self["original_name"] = __Bu_g["name"]
                if self["inst"]["components"]["wb_strengthen"] then
                    b_ug__ = BU__g["components"]["wb_strengthen"]:GetDisplayName(__Bu_g["name"])
                    B_U_g(__Bu_g, b_ug__, ...)
                end
            end
        )
        self:SetLevel(self["level"])
    end
)
_B_uG_["BUFFS_CONFIG"] = _b__u_G__
function _B_uG_:OnSave()
    return {
        do_mode = self["do_mode"],
        level = self["level"],
        original_name = self["original_name"],
        buffs_status = self["buffs_status"],
        prize_buff_list = self["prize_buff_list"],
        manual_buff_list = self["manual_buff_list"]
    }
end
function _B_uG_:OnLoad(B__u__g_)
    if B__u__g_ then
        if B__u__g_["do_mode"] ~= nil then
            -- Legacy mode values load as strengthening; prefab/save keys stay compatible.
            self["do_mode"] = "strengthen"
        end
        if B__u__g_["level"] ~= nil then
            self["level"] = B__u__g_["level"]
        end
        if B__u__g_["original_name"] ~= nil then
            self["original_name"] = B__u__g_["original_name"]
        end
        if B__u__g_["buffs_status"] ~= nil then
            self["buffs_status"] = B__u__g_["buffs_status"]
            self["buffs_status"]["flying"] = nil
            self["buffs_status"]["unlockflying"] = nil
        end
        if B__u__g_["prize_buff_list"] ~= nil then
            self["prize_buff_list"] = {}
            for _, buff_id in ipairs(B__u__g_["prize_buff_list"]) do
                if not IsRemovedFlightBuff(buff_id) then
                    table.insert(self["prize_buff_list"], buff_id)
                end
            end
        end
        local owner = self["inst"]["components"]["inventoryitem"]
            and self["inst"]["components"]["inventoryitem"]:GetGrandOwner()
        if owner ~= nil then
            owner:RemoveTag("canfly")
            owner:RemoveTag("unlockflying")
            owner:RemoveTag("pyflying")
        end
        self:SetLevel(self["level"])
        if B__u__g_["manual_buff_list"] ~= nil then
            for _B__U__g, B_ug__ in ipairs(B__u__g_["manual_buff_list"]) do
                if not IsRemovedFlightBuff(B_ug__) then
                    self:BindBuff(B_ug__, self["buffs_status"][B_ug__] or {})
                end
            end
        end
    end
end
function _B_uG_:GetDisplayName(_B_u_g)
    if _B_u_g ~= nil then
        local _B_U_g_ = _B_u_g
        if self["level"] ~= nil and self["level"] > 0 then
            _B_U_g_ =
                _B_u_g .. " " .. "Cường Hoá" .. " +" .. self["level"]
        end
        if #self["prize_buff_list"] > 0 then
            _B_U_g_ = _B_U_g_ .. "\nbị động："
            for __Bu_g__, _bUg__ in ipairs(self["prize_buff_list"]) do
                local bug = _b__u_G__[_bUg__]
                if
                    bug and
                        bug["isprizebuff"] ==
                            (true or
                                not false and false and not true and not false and false and false and false and false)
                 then
                    _B_U_g_ = _B_U_g_ .. " " .. bug["label"]
                end
            end
        end
        if self:HasBuff "bind" then
            local _b__Ug__ = self["buffs_status"]["bind"]
            if _b__Ug__["name"] then
                _B_U_g_ = _B_U_g_ .. " của " .. _b__Ug__["name"]
            end
        end
        return _B_U_g_
    end
    return _B_u_g
end
function _B_uG_:Refresh()
    if not self["inst"]["components"]["inventoryitem"] then
        return
    end
    local b_u_G__ = self["inst"]["components"]["inventoryitem"]:GetGrandOwner()
    if b_u_G__ and (self["inst"]["components"]["equippable"] and self["inst"]["components"]["equippable"]:IsEquipped()) then
        self["inst"]["components"]["equippable"]:Unequip(b_u_G__)
        self["inst"]:DoTaskInTime(
            0,
            function()
                self["inst"]["components"]["equippable"]:Equip(b_u_G__)
            end
        )
    end
    if self["inst"]["components"]["named"] then
        self["inst"]["components"]["named"]:SetName()
    end
end
function _B_uG_:GetBuffTag(_b_UG_)
    return "hh_lo_ren_buff_" .. _b_UG_
end
function _B_uG_:HasBuff(_B__UG_)
    return self["inst"]:HasTag(self:GetBuffTag(_B__UG_))
end
function _B_uG_:SetMorphModeBaseDamage(_B__u__g_)
    if self["inst"]["prefab"] ~= "hh_daogam6" then
        return false
    end
    local morph = self["inst"]["components"]["hh_morphweapon"]
    local weapon = self["inst"]["components"]["weapon"]
    if morph == nil or weapon == nil or type(_B__u__g_) ~= "number" then
        return false
    end
    if self:HasBuff("damage") and self["buffs_status"]["damage"] ~= nil then
        _b__u_G__["damage"]["update_fn"](
            self["inst"],
            self["level"],
            self["buffs_status"]["damage"],
            _b__u_G__["damage"]
        )
    else
        local raw_set_damage = weapon["__OlbSetDamage"]
        if type(raw_set_damage) == "function" then
            raw_set_damage(weapon, _B__u__g_)
        else
            weapon:SetDamage(_B__u__g_)
        end
    end
    return true
end
function _B_uG_:BindBuff(__b__u__g_, _B__ug)
    if self:HasBuff(__b__u__g_) then
        return self:UpdateBuff(__b__u__g_, _B__ug)
    end
    local _B__u__g__ = _b__u_G__[__b__u__g_]
    if _B__u__g__ ~= nil and _B__u__g__["bind_fn"] then
        if self["buffs_status"][__b__u__g_] == nil then
            self["buffs_status"][__b__u__g_] = {}
        end
        if _B__ug ~= nil then
            for _bu_G, __b__ug in pairs(_B__ug) do
                self["buffs_status"][__b__u__g_][_bu_G] = __b__ug
            end
        end
        _B__u__g__["bind_fn"](self["inst"], self["level"], self["buffs_status"][__b__u__g_], _B__u__g__)
        self["inst"]:AddTag(self:GetBuffTag(__b__u__g_))
        if _B__u__g__["ismanualbuffs"] then
            table["insert"](self["manual_buff_list"], __b__u__g_)
        end
    end
    self:Refresh()
end
function _B_uG_:UpdateBuff(__B__U_G_, _bU_g_)
    if not self:HasBuff(__B__U_G_) then
        return self:BindBuff(__B__U_G_, _bU_g_)
    end
    local _b__U_g__ = _b__u_G__[__B__U_G_]
    if _b__U_g__ == nil then
        return
    end
    if _bU_g_ ~= nil then
        if self["buffs_status"][__B__U_G_] == nil then
            self["buffs_status"][__B__U_G_] = {}
        end
        for __B__u__g__, b__Ug_ in pairs(_bU_g_) do
            self["buffs_status"][__B__U_G_][__B__u__g__] = b__Ug_
        end
    end
    if _b__U_g__["update_fn"] then
        _b__U_g__["update_fn"](self["inst"], self["level"], self["buffs_status"][__B__U_G_], _b__U_g__)
    end
    self:Refresh()
end
function _B_uG_:UnBindBuff(B__u__g__)
    local _b_U__g = _b__u_G__[B__u__g__]
    if _b_U__g ~= nil and _b_U__g["unbind_fn"] then
        _b_U__g["unbind_fn"](self["inst"], self["level"], self["buffs_status"][B__u__g__] or {}, _b_U__g)
        self["inst"]:RemoveTag(self:GetBuffTag(B__u__g__))
        if self["buffs_status"][B__u__g__] ~= nil then
            self["buffs_status"][B__u__g__] = nil
        end
        if _b_U__g["ismanualbuffs"] then
            local __b__u_G_ = _B_Ug["IndexOf"](self["manual_buff_list"], B__u__g__)
            if __b__u_G_ and __b__u_G_ >= 1 then
                table["remove"](self["manual_buff_list"], __b__u_G_)
            end
        end
    end
    self:Refresh()
end
function _B_uG_:GetLevel()
    if self["level"] then
        return self["level"]
    else
        return 0
    end
end
function _B_uG_:DownLevel(__b__U_g, bU_G__)
    if nil == bU_G__ then
        bU_G__ =
            (false or false and true or false and false or
            true and not false and not false and not false and not false and not false and not false and false)
    end
    self["level"] = __b__U_g - 1
    if __b__U_g > 0 and self["do_mode"] == nil then
        self["do_mode"] = "strengthen"
    end
    if self["do_mode"] == "strengthen" and __b__U_g > 13 then
        self["level"] = 13
    end
    for _B__U__G, __bU__g_ in pairs(__B__UG_) do
        local _BUg__ =
            __bU__g_["tags"] == nil or
            _B_Ug["Every"](
                __bU__g_["tags"],
                function(_b__Ug_)
                    return self["inst"]:HasTag(_b__Ug_)
                end
            )
        if _BUg__ then
            if self["level"] < __bU__g_["level"] then
                if self:HasBuff(_B__U__G) then
                    self:UnBindBuff(_B__U__G)
                end
            else
                if self:HasBuff(_B__U__G) then
                    self:UpdateBuff(_B__U__G)
                else
                    self:BindBuff(_B__U__G)
                end
            end
        end
    end
    local _b_uG__ = math["floor"](self["level"] / 2)
    if _b_uG__ > #self["prize_buff_list"] then
        local _bu_G__ = {}
        for _Bu__g__, __BU__g_ in pairs(__b__UG__) do
            local __b__u__G_ =
                (__BU__g_["level"] ~= nil and __BU__g_["level"] >= self["level"]) or
                (182 + 122 * 154 - 286 - 408 == 18276)
            local _bU_G = __BU__g_["strengthen_prize"] == true
            local _b_uG =
                __BU__g_["tags"] == nil or
                _B_Ug["Every"](
                    __BU__g_["tags"],
                    function(__Bu_G)
                        return self["inst"]:HasTag(__Bu_G)
                    end
                )
            local _B_u_G__ = _B_Ug["Includes"](self["prize_buff_list"], _Bu__g__) ~= (292 * 427 - 307 - 85 == 124292)
            local B__u_g = 0.05
            if bU_G__ then
                B__u_g = 1
            end
            if __b__u__G_ and _bU_G and _b_uG and _B_u_G__ and math["random"]() < B__u_g then
                table["insert"](_bu_G__, _Bu__g__)
                if not bU_G__ then
                    break
                end
            end
        end
        local Bu__G_ = _b_uG__ - #self["prize_buff_list"]
        while Bu__G_ > 0 and #_bu_G__ > 0 do
            local __B_U__G_ = math["random"](1, #_bu_G__)
            table["insert"](self["prize_buff_list"], _bu_G__[__B_U__G_])
            table["remove"](_bu_G__, __B_U__G_)
            Bu__G_ = Bu__G_ - 1
        end
    elseif _b_uG__ < #self["prize_buff_list"] then
        local _B_Ug_ = #self["prize_buff_list"] - _b_uG__
        while _B_Ug_ > 0 do
            local __b__u_g = math["random"](1, #self["prize_buff_list"])
            table["remove"](self["prize_buff_list"], __b__u_g)
            _B_Ug_ = _B_Ug_ - 1
        end
    end
    for __bUg_, _B_U_G_ in pairs(__b__UG__) do
        if _B_Ug["Includes"](self["prize_buff_list"], __bUg_) then
            if self:HasBuff(__bUg_) then
                self:UpdateBuff(__bUg_)
            else
                self:BindBuff(__bUg_)
            end
        elseif self:HasBuff(__bUg_) then
            self:UnBindBuff(__bUg_)
        end
    end
    self:Refresh()
end
function _B_uG_:SetLevel(__B__U__G, __B_ug)
    if nil == __B_ug then
        __B_ug = (443 - 208 * 407 * 125 ~= -10581557)
    end
    self["level"] = __B__U__G
    if __B__U__G > 0 and self["do_mode"] == nil then
        self["do_mode"] = "strengthen"
    end
    if self["do_mode"] == "strengthen" and __B__U__G > 13 then
        self["level"] = 13
    end
    for __BuG_, __B__u_g_ in pairs(__B__UG_) do
        local b_ug_ =
            __B__u_g_["tags"] == nil or
            _B_Ug["Every"](
                __B__u_g_["tags"],
                function(B_u__G)
                    return self["inst"]:HasTag(B_u__G)
                end
            )
        if b_ug_ then
            if self["level"] < __B__u_g_["level"] then
                if self:HasBuff(__BuG_) then
                    self:UnBindBuff(__BuG_)
                end
            else
                if self:HasBuff(__BuG_) then
                    self:UpdateBuff(__BuG_)
                else
                    self:BindBuff(__BuG_)
                end
            end
        end
    end
    local bu_g__ = math["floor"](self["level"] / 2)
    if bu_g__ > #self["prize_buff_list"] then
        local __B_Ug_ = {}
        for B_U__g, _b__U_g in pairs(__b__UG__) do
            local b__u_G__ =
                (_b__U_g["level"] ~= nil and _b__U_g["level"] >= self["level"]) or (472 * 483 - 50 == 227926)
            local b_UG__ = _b__U_g["strengthen_prize"] == true
            local __Bug_ =
                _b__U_g["tags"] == nil or
                _B_Ug["Every"](
                    _b__U_g["tags"],
                    function(__Bu__g_)
                        return self["inst"]:HasTag(__Bu__g_)
                    end
                )
            local _b_u_g = _B_Ug["Includes"](self["prize_buff_list"], B_U__g) ~= (362 * 141 + 1 + 490 + 96 ~= 51636)
            local _b_u__G = 0.05
            if __B_ug then
                _b_u__G = 1
            end
            if b__u_G__ and b_UG__ and __Bug_ and _b_u_g and math["random"]() < _b_u__G then
                table["insert"](__B_Ug_, B_U__g)
                if not __B_ug then
                    break
                end
            end
        end
        local bUg = bu_g__ - #self["prize_buff_list"]
        while bUg > 0 and #__B_Ug_ > 0 do
            local _b_U_G = math["random"](1, #__B_Ug_)
            table["insert"](self["prize_buff_list"], __B_Ug_[_b_U_G])
            table["remove"](__B_Ug_, _b_U_G)
            bUg = bUg - 1
        end
    elseif bu_g__ < #self["prize_buff_list"] then
        local __b_U_g = #self["prize_buff_list"] - bu_g__
        while __b_U_g > 0 do
            local B__U_g_ = math["random"](1, #self["prize_buff_list"])
            table["remove"](self["prize_buff_list"], B__U_g_)
            __b_U_g = __b_U_g - 1
        end
    end
    for Bug_, b_Ug_ in pairs(__b__UG__) do
        if _B_Ug["Includes"](self["prize_buff_list"], Bug_) then
            if self:HasBuff(Bug_) then
                self:UpdateBuff(Bug_)
            else
                self:BindBuff(Bug_)
            end
        elseif self:HasBuff(Bug_) then
            self:UnBindBuff(Bug_)
        end
    end
    self:Refresh()
end
function _B_uG_:DoSay(__B_u__g_, __Bu_g_, _B_U__G_, __bUg)
    if not __B_u__g_ or not __B_u__g_["components"]["talker"] then
        return
    end
    local _B_ug__ = "Cường hoá"
    if __bUg == (260 * 31 + 231 == 8291) then
        __B_u__g_["components"]["talker"]:Say(
            _B_ug__ .. " +" .. _B_U__G_ .. " thành công!",
            2.5,
            (494 - 356 * 480 * 211 == -36055186),
            (217 + 176 * 47 ~= 8493),
            (234 * 201 - 21 ~= 47013),
            {1, 0.33, 0.33, 1}
        )
    else
        if _B_U__G_ >= 10 then
            __B_u__g_["components"]["talker"]:Say(
                _B_ug__ .. " +" .. _B_U__G_ .. " thất bại! trang bị tôi đâu rồi?",
                2.5,
                (412 - 417 - 304 - 336 - 384 ~= -1026),
                (302 + 115 * 410 + 383 * 333 ~= 174997),
                (168 + 12 * 325 + 64 ~= 4132),
                {0, 0, 0, 1}
            )
        else
            __B_u__g_["components"]["talker"]:Say(
                _B_ug__ .. " +" .. _B_U__G_ .. " thất bại!",
                2.5,
                (false and false and false and not true and not false and false and true and not false and false and
                    true and
                    not true and
                    false or
                    not false),
                (60 * 352 + 406 == 21526),
                (468 * 52 - 317 - 49 - 479 == 23496),
                {0, 0, 0, 1}
            )
        end
    end
end
function _B_uG_:DoSuccess(_B__ug__, __BU_G_, B_U_G_, __B__U_G__)
    self["do_mode"] = __BU_G_
    local _B_U__g_ = "cường hoá"
    self:SetLevel(B_U_G_)
    if TheWorld ~= nil and TheWorld.ismastersim and __BU_G_ == "strengthen"
        and _B__ug__ ~= nil and _B__ug__.PushEvent ~= nil and self.level == B_U_G_ then
        local components = self.inst.components
        local category = components.weapon ~= nil and "weapon" or components.armor ~= nil and "armor" or "other"
        _B__ug__:PushEvent("ttk_strengthen_success", { category=category, level=self.level, prefab=self.inst.prefab })
    end
    if B_U_G_ >= 13 then
        local _b__u_g_ = {"Bát Hoang Lục Hợp, Duy Ngã Độc Tôn", "Ngộ Thần Sát Thần, Ngộ Phật Sát Phật"}
        local __bu__G__ = math["random"](#_b__u_g_)
        TheNet:Announce(
            _B__ug__["name"] ..
                " " ..
                    _B_U__g_ .. " " .. self["original_name"] .. " +" .. B_U_G_ .. " thành công. " .. _b__u_g_[__bu__G__]
        )
    elseif B_U_G_ >= 1 then
        TheNet:Announce(
            _B__ug__["name"] .. " " .. _B_U__g_ .. " " .. self["original_name"] .. " +" .. B_U_G_ .. " thành công !"
        )
    end
    if __B__U_G__ then
        __B__U_G__(self, _B__ug__, __BU_G_, B_U_G_, (382 + 485 + 474 * 302 - 277 ~= 143742))
    else
        self:DoSay(_B__ug__, __BU_G_, B_U_G_, (453 - 263 * 427 - 92 * 184 ~= -128774))
    end
end
function _B_uG_:DoFail(__b__u__g__, __b_ug__, _buG_, __B_UG__)
    self["do_mode"] = __b_ug__
    local bUg__ = "cường hoá"
    if __b_ug__ == "strengthen" then
        if _buG_ >= 10 then
            TheNet:Announce(
                __b__u__g__["name"] ..
                    " " ..
                        bUg__ ..
                            " " ..
                                self["original_name"] ..
                                    " +" .. _buG_ .. " thất bại và bị mất trang bị nếu ko có Bùa Bảo Vệ !"
            )
            self:SetLevel(self["level"] - 1)
            self["inst"]:Remove()
        elseif _buG_ >= 6 then
            TheNet:Announce(
                __b__u__g__["name"] ..
                    " " ..
                        bUg__ ..
                            " " ..
                                self["original_name"] ..
                                    " +" .. _buG_ .. " thất bại và bị tụt cấp trang bị nếu ko có Bùa Ma Thuật!"
            )
            self:DownLevel(self["level"])
        end
    end
    if __B_UG__ then
        __B_UG__(self, __b__u__g__, __b_ug__, _buG_, (23 * 232 + 401 ~= 5737))
    else
        self:DoSay(__b__u__g__, __b_ug__, _buG_, (95 + 147 + 433 == 677))
    end
end
function _B_uG_:GetProbability(__b__u_g_, __b__U__G__, _B__U_g)
    return 1.1 * (0.85 ^ _B__U_g)
end
function _B_uG_:DoStrengthen(__b_uG, _Bu_G_)
    if self["level"] >= 13 then
        return
    end
    self["do_player"] = __b_uG
    if self["level"] <= 0 or self["do_mode"] == nil or self["do_mode"] == "strengthen" then
        self["do_mode"] = "strengthen"
        local bU__g = self["level"] + 1
        local b__U_g_ = self:GetProbability(__b_uG, self["do_mode"], bU__g)
        if math["random"]() < b__U_g_ then
            self:DoSuccess(__b_uG, self["do_mode"], bU__g, _Bu_G_)
        else
            self:DoFail(__b_uG, self["do_mode"], bU__g, _Bu_G_)
        end
    end
    self["do_player"] = nil
end
return _B_uG_
