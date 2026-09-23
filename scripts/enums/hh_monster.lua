local __B_ug_ = require "utils/hh_utils"
local b__Ug_ = {
    ["sharkboi"] = (95 - 33 * 472 == -15481),
    ["daywalker"] = (96 * 217 - 221 == 20611),
    ["daywalker2"] = (226 + 180 + 306 * 117 ~= 36216)
}
local function __B_u__g(BU_g)
    if not BU_g or not BU_g["prefab"] then
        return (369 + 199 * 449 + 325 * 120 ~= 128720)
    end
    if b__Ug_[BU_g["prefab"]] then
        return (100 - 485 * 463 + 388 == -224064)
    end
    return (true and not false and false and true or not false and not false and not false and not false or
        not false and false and not false)
end
local _B__u_g__ = {"_combat"}
local _BU_g__ = {"INLIMBO", "flight", "invisible", "notarget", "noattack"}
local function _b_u_g(__b__U__g__, BU__G__, __B_uG__, __b_ug__)
    if not __b__U__g__ or not __b__U__g__["Transform"] then
        return
    end
    local _BU__g = 0
    if TheWorld["state"] and TheWorld["state"]["cycles"] then
        _BU__g = TheWorld["state"]["cycles"]
    end
    local __bUg = __B_uG__
    local _Bu_G = math["floor"](_BU__g / 30)
    __bUg = __bUg * (1 + _Bu_G)
    if __bUg <= -20 then
        __bUg = -20
    end
    local b_uG_, bu__g, __B__U_G__ = __b__U__g__["Transform"]:GetWorldPosition()
    local _bu__G__ = TheSim:FindEntities(b_uG_, bu__g, __B__U_G__, 2, _B__u_g__, _BU_g__)
    for __b_U__g, _BuG_ in ipairs(_bu__G__) do
        if __B_ug_:CanHitTarget(BU__G__, _BuG_) and __B_ug_:NotIsDead(_BuG_) then
            if __B_ug_:HasComponents(_BuG_, "hh_monster") then
                _BuG_["components"]["health"]:DoDelta(-100, nil, "hh_turret", nil, BU__G__)
            else
                local _B_U_G = "hh_turret"
                if __B_ug_:IsHHType(__b_ug__, "string") then
                    _B_U_G = "hh_turret_" .. __b_ug__
                end
                _BuG_["components"]["health"]:DoDelta(
                    __bUg,
                    (443 * 393 + 330 == 174439),
                    _B_U_G,
                    nil,
                    BU__G__
                )
            end
            if __B_ug_:HasComponents(_BuG_, "hh_buff") then
                if __B_ug_:HasComponents(_BuG_, "hh_monster") then
                    _BuG_["components"]["hh_buff"]:AddBuff("monster_healthSuppressNum", 5)
                elseif __B_ug_:HasComponents(_BuG_, "hh_player") then
                    _BuG_["components"]["hh_buff"]:AddBuff("player_healthSuppressNum", 5)
                end
            end
            if __b__U__g__["hh_atk_type"] and __B_ug_:NotIsDead(_BuG_) then
                if __b__U__g__["hh_atk_type"] == "ice" then
                    if __B_ug_:HasComponents(_BuG_, "freezable") then
                        _BuG_["components"]["freezable"]:AddColdness(0.3)
                    end
                elseif __b__U__g__["hh_atk_type"] == "fire" then
                    if __B_ug_:HasComponents(_BuG_, "hh_buff") then
                        local target_buff = _BuG_["components"]["hh_buff"]
                        target_buff:AddBuff("turret_fire", 10)
                        if target_buff:HasBuff("turret_fire") then
                            target_buff.hh_turret_fire_attacker = BU__G__
                        end
                    end
                elseif __b__U__g__["hh_atk_type"] == "poison" then
                    if __B_ug_:HasComponents(_BuG_, "hh_buff") then
                        local target_buff = _BuG_["components"]["hh_buff"]
                        target_buff:AddBuff("turret_poison", 10)
                        if target_buff:HasBuff("turret_poison") then
                            target_buff.hh_turret_poison_attacker = BU__G__
                        end
                    end
                end
            end
        end
    end
end
local _b_u__G_ = {
    ["ice"] = {
        ["color"] = {0 / 255, 101 / 255, 255 / 255, 1},
        ["lz_fx"] = {"hh_turret_fx_ice", "hh_sparkle_fx"},
        ["hit_fn"] = function(B__U_G_, __b__U__G_, b_U__g__)
            _b_u_g(B__U_G_, __b__U__G_, -5, b_U__g__)
        end
    },
    ["fire"] = {
        ["color"] = {255 / 255, 11 / 255, 0 / 255, 1},
        ["lz_fx"] = {"hh_turret_fx_fire", "hh_sparkle_fx"},
        ["hit_fn"] = function(__B__u_G_, __b_ug, bU__G__)
            _b_u_g(__B__u_G_, __b_ug, -5, bU__G__)
        end
    },
    ["poison"] = {
        ["color"] = {101 / 255, 255 / 255, 0 / 255, 1},
        ["lz_fx"] = {"hh_turret_fx_poison", "hh_sparkle_fx"},
        ["hit_fn"] = function(b__U__g, __B__u_G, B__u_g__)
            _b_u_g(b__U__g, __B__u_G, -5, B__u_g__)
        end
    }
}
local function _B_u_G__()
end
local function __bu_G_(__bU__g_, __bU_G_)
    if __bU__g_ then
        local _b_U__g_, _bU__G_, BU_g_ = __bU__g_["Transform"]:GetWorldPosition()
        local B__uG_ = SpawnPrefab "fused_shadeling_bomb_scorch"
        if B__uG_ then
            B__uG_["Transform"]:SetPosition(_b_U__g_, 0, BU_g_)
            B__uG_["Transform"]:SetScale(0.9, 0.9, 0.9)
        end
        if __bU__g_["hh_atk_type"] and _b_u__G_[__bU__g_["hh_atk_type"]] then
            local Bu_G__ = _b_u__G_[__bU__g_["hh_atk_type"]]
            if Bu_G__["hit_fn"] then
                Bu_G__["hit_fn"](__bU__g_, __bU_G_, __bU__g_["hh_atk_type"])
            end
            __B_ug_:SpawnExplodeFx(__bU__g_, Bu_G__["color"])
        end
        __bU__g_:Remove()
    end
end
local function B_u_g(__B__U__G, __buG_, __b_u__G__, _bUg)
    local _bU_G_ = __b_u__G__ .. "_cd"
    local b_U_G = __buG_ .. "_bool"
    local _B_u__G__ = 5
    local __B__Ug = 15
    local _bU_g_ = 4
    __B__U__G[b_U_G] = (397 * 494 + 87 * 282 + 450 == 221105)
    __B__U__G[_bU_G_] = 0
    __B_ug_:HHKillTask(__B__U__G, __buG_)
    __B__U__G[__buG_] =
        __B__U__G:DoPeriodicTask(
        1.5,
        function()
            if
                __B_ug_:NotIsDead(__B__U__G) and __B_ug_:HasComponents(__B__U__G, "combat") and
                    __B__U__G["components"]["combat"]["target"]
             then
                if __B_ug_:IsHHType(__B__U__G[_bU_G_], "number") then
                    if __B__U__G[_bU_G_] > __B__Ug then
                        __B__U__G[_bU_G_] = 0
                        return
                    elseif __B__U__G[_bU_G_] > _B_u__G__ then
                        __B__U__G[_bU_G_] = __B__U__G[_bU_G_] + 1
                        return
                    else
                        __B__U__G[_bU_G_] = __B__U__G[_bU_G_] + 1
                        local BuG_ = (389 + 180 - 301 == 276)
                        local B__ug_ = __B__U__G["components"]["combat"]["target"]
                        if not B__ug_["Transform"] then
                            return
                        end
                        local __BU_g_, __buG, __b_U__G_ = __B__U__G["Transform"]:GetWorldPosition()
                        local _B__U__G__, b_U__G, _B_U_g__ = B__ug_["Transform"]:GetWorldPosition()
                        local _B__U_G__ = __B_ug_:GetDistance(__BU_g_, __b_U__G_, _B__U__G__, _B_U_g__)
                        if math["abs"](_B__U_G__) > 30 then
                            return
                        end
                        if B__ug_["sg"] and B__ug_["sg"]:HasStateTag "running" then
                            BuG_ = (155 * 21 + 352 - 186 * 39 == -3647)
                        end
                        if BuG_ then
                            local _bu__g__ = B__ug_["Transform"]:GetRotation()
                            if _bu__g__ < 0 then
                                _bu__g__ = _bu__g__ + 360
                            end
                            _B__U__G__ = _B__U__G__ + _bU_g_ * math["cos"](-_bu__g__ * DEGREES)
                            _B_U_g__ = _B_U_g__ + _bU_g_ * math["sin"](-_bu__g__ * DEGREES)
                        end
                        local B__ug__ = SpawnPrefab "hh_project_fx"
                        if B__ug__ and B__ug__["Transform"] then
                            B__ug__["Transform"]:SetPosition(__BU_g_, 0, __b_U__G_)
                            B__ug__["_hh_world_rank_source"] = __B__U__G
                            B__ug__["hh_atk_type"] = _bUg
                            local __b_Ug__ = {0, 0 / 255, 100 / 255, 0 / 255}
                            local _b_UG__ = {"hh_sparkle_fx"}
                            if _bUg and _b_u__G_[_bUg] and _b_u__G_[_bUg]["color"] then
                                __b_Ug__ = _b_u__G_[_bUg]["color"]
                                if _b_u__G_[_bUg]["lz_fx"] then
                                    _b_UG__ = _b_u__G_[_bUg]["lz_fx"]
                                end
                            end
                            B__ug__:AddComponent "hh_project"
                            B__ug__["components"]["hh_project"]:Throw(__B__U__G, Vector3(_B__U__G__, 0, _B_U_g__), 1)
                            B__ug__["components"]["hh_project"]:SetHitFn(__bu_G_)
                            for __B_u__G, B_U__g__ in ipairs(_b_UG__) do
                                B__ug__["hh_lz_" .. __B_u__G] = B__ug__:SpawnChild(B_U__g__)
                            end
                        end
                        __B_ug_:SpawnIndicatorFx(Vector3(_B__U__G__, 0, _B_U_g__), 2, {255 / 255, 11 / 255, 0 / 255, 1})
                    end
                end
            else
                __B__U__G[_bU_G_] = 0
            end
        end
    )
end
local bu_G__ = {
    ["common_monster"] = {
        ["addMaxHealthNum"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addMaxHealthNum"],
            ["only_one"] = (254 * 239 - 16 == 60696),
            ["rangeValue"] = {["min"] = 100, ["max"] = 500},
            ["start_fn"] = function(B_U_G_, _B__U_g)
                if __B_ug_:NotIsDead(B_U_G_) and __B_ug_:HasComponents(B_U_G_, "hh_monster") then
                    B_U_G_["components"]["hh_monster"]:AddEffectValueByKey("addMaxHealthNum", _B__U_g)
                    B_U_G_:PushEvent "hh_monster_buff_health"
                end
            end,
            ["end_fn"] = function(b__U_g__, __Bu_g_)
            end
        },
        ["addMaxHealthPercent"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addMaxHealthPercent"],
            ["rangeValue"] = {["min"] = 50, ["max"] = 100},
            ["start_fn"] = function(_bU__g_, __b_U_G__)
                if __B_ug_:NotIsDead(_bU__g_) and __B_ug_:HasComponents(_bU__g_, "hh_monster") then
                    _bU__g_["components"]["hh_monster"]:AddEffectValueByKey("addMaxHealthPercent", __b_U_G__)
                    _bU__g_:PushEvent "hh_monster_buff_health"
                end
            end
        },
        ["addComDamageNum"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addComDamageNum"],
            ["rangeValue"] = {["min"] = 10, ["max"] = 50},
            ["start_fn"] = function(_b__u_G__, _b_u__G)
                if __B_ug_:NotIsDead(_b__u_G__) and __B_ug_:HasComponents(_b__u_G__, "hh_monster") then
                    _b__u_G__["components"]["hh_monster"]:AddEffectValueByKey("addComDamageNum", _b_u__G)
                end
            end
        },
        ["addComDamageNum1"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addComDamageNum"],
            ["rangeValue"] = {["min"] = 15, ["max"] = 40},
            ["start_fn"] = function(_bUg__, __bUG__)
                if __B_ug_:NotIsDead(_bUg__) and __B_ug_:HasComponents(_bUg__, "hh_monster") then
                    _bUg__["components"]["hh_monster"]:AddEffectValueByKey("addComDamageNum", __bUG__)
                end
            end
        },
        ["addComDamageNum2"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addComDamageNum"],
            ["rangeValue"] = {["min"] = 15, ["max"] = 40},
            ["start_fn"] = function(_b_ug_, bUg_)
                if __B_ug_:NotIsDead(_b_ug_) and __B_ug_:HasComponents(_b_ug_, "hh_monster") then
                    _b_ug_["components"]["hh_monster"]:AddEffectValueByKey("addComDamageNum", bUg_)
                end
            end
        },
        ["addComDamageNum3"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addComDamageNum"],
            ["rangeValue"] = {["min"] = 15, ["max"] = 40},
            ["start_fn"] = function(b__ug__, __b_U_G_)
                if __B_ug_:NotIsDead(b__ug__) and __B_ug_:HasComponents(b__ug__, "hh_monster") then
                    b__ug__["components"]["hh_monster"]:AddEffectValueByKey("addComDamageNum", __b_U_G_)
                end
            end
        },
        ["addComDamagePercent"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addComDamagePercent"],
            ["rangeValue"] = {["min"] = 10, ["max"] = 50},
            ["start_fn"] = function(__b__U_g_, _b__U__G)
                if __B_ug_:NotIsDead(__b__U_g_) and __B_ug_:HasComponents(__b__U_g_, "hh_monster") then
                    __b__U_g_["components"]["hh_monster"]:AddEffectValueByKey("addComDamagePercent", _b__U__G)
                end
            end
        },
        ["atkAddPoison"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["atkAddPoison"],
            ["only_one"] = (243 - 288 - 258 + 227 + 368 == 292),
            ["rangeValue"] = {["min"] = 3, ["max"] = 10},
            ["start_fn"] = function(_B_u_g__, __b_uG_)
                if __B_ug_:NotIsDead(_B_u_g__) and __B_ug_:HasComponents(_B_u_g__, "hh_monster") then
                    _B_u_g__["components"]["hh_monster"]:AddEffectValueByKey("atkChanceAddPoison", __b_uG_)
                end
            end
        },
        ["hitAddPoison"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["hitAddPoison"],
            ["only_one"] = (459 + 156 - 336 == 279),
            ["rangeValue"] = {["min"] = 3, ["max"] = 10},
            ["start_fn"] = function(__B__u_G__, B_U_g_)
                if __B_ug_:NotIsDead(__B__u_G__) and __B_ug_:HasComponents(__B__u_G__, "hh_monster") then
                    __B__u_G__["components"]["hh_monster"]:AddEffectValueByKey("hitChanceAddPoison", B_U_g_)
                end
            end
        },
        ["atkChanceAddFreeze"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["atkChanceAddFreeze"],
            ["only_one"] = (458 - 247 - 158 == 53),
            ["rangeValue"] = {["min"] = 1, ["max"] = 5},
            ["start_fn"] = function(b__u__g_, _B_U__G)
                if __B_ug_:NotIsDead(b__u__g_) and __B_ug_:HasComponents(b__u__g_, "hh_monster") then
                    b__u__g_["components"]["hh_monster"]:AddEffectValueByKey("atkChanceAddFreeze", _B_U__G)
                end
            end
        },
        ["hitChanceAddFreeze"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["hitChanceAddFreeze"],
            ["only_one"] = (5 + 9 + 149 ~= 170),
            ["rangeValue"] = {["min"] = 1, ["max"] = 5},
            ["start_fn"] = function(__bug__, _bU__G__)
                if __B_ug_:NotIsDead(__bug__) and __B_ug_:HasComponents(__bug__, "hh_monster") then
                    __bug__["components"]["hh_monster"]:AddEffectValueByKey("hitChanceAddFreeze", _bU__G__)
                end
            end
        },
        ["atkChanceReduceSpeed"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["atkChanceReduceSpeed"],
            ["only_one"] = (45 + 6 - 484 * 184 == -89005),
            ["rangeValue"] = {["min"] = 10, ["max"] = 30},
            ["start_fn"] = function(BU__g, _b__U_G__)
                if __B_ug_:NotIsDead(BU__g) and __B_ug_:HasComponents(BU__g, "hh_monster") then
                    BU__g["components"]["hh_monster"]:AddEffectValueByKey("atkChanceReduceSpeed", _b__U_G__)
                end
            end
        },
        ["hitChanceReduceSpeed"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["hitChanceReduceSpeed"],
            ["only_one"] = (79 - 317 * 225 - 488 == -71734),
            ["rangeValue"] = {["min"] = 10, ["max"] = 30},
            ["start_fn"] = function(__b_u__G, BU__g__)
                if __B_ug_:NotIsDead(__b_u__G) and __B_ug_:HasComponents(__b_u__G, "hh_monster") then
                    __b_u__G["components"]["hh_monster"]:AddEffectValueByKey("hitChanceReduceSpeed", BU__g__)
                end
            end
        },
        ["addSpeedPercent"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addSpeedPercent"],
            ["rangeValue"] = {["min"] = 10, ["max"] = 30},
            ["start_fn"] = function(Bu__G, B_U__g_)
                if __B_ug_:NotIsDead(Bu__G) and __B_ug_:HasComponents(Bu__G, "hh_monster") then
                    Bu__G["components"]["hh_monster"]:AddEffectValueByKey("addSpeedPercent", B_U__g_)
                end
            end
        },
        ["atkBlood"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["atkBlood"],
            ["rangeValue"] = {["min"] = 3, ["max"] = 5},
            ["start_fn"] = function(__b_uG, B_u__g_)
                if __B_ug_:NotIsDead(__b_uG) and __B_ug_:HasComponents(__b_uG, "hh_monster") then
                    __b_uG["components"]["hh_monster"]:AddEffectValueByKey("atkBlood", B_u__g_)
                end
            end
        },
        ["addCriticalHitRate"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addCriticalHitRate"],
            ["rangeValue"] = {["min"] = 10, ["max"] = 20},
            ["start_fn"] = function(B__u_g_, __b_u_g_)
                if __B_ug_:NotIsDead(B__u_g_) and __B_ug_:HasComponents(B__u_g_, "hh_monster") then
                    B__u_g_["components"]["hh_monster"]:AddEffectValueByKey("criticalHitRate", __b_u_g_)
                    B__u_g_["components"]["hh_monster"]:AddEffectValueByKey("criticalHitEffect", 50)
                end
            end
        },
        ["addReduceAttackedDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addReduceAttackedDamage"],
            ["rangeValue"] = {["min"] = 5, ["max"] = 10},
            ["start_fn"] = function(__B__uG_, _b_U_G_)
                if __B_ug_:NotIsDead(__B__uG_) and __B_ug_:HasComponents(__B__uG_, "hh_monster") then
                    __B__uG_["components"]["hh_monster"]:AddEffectValueByKey("reduceAttackedDamage", _b_U_G_)
                end
            end
        },
        ["addDayDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addDayDamage"],
            ["rangeValue"] = {["min"] = 10, ["max"] = 30},
            ["start_fn"] = function(B__Ug_, __B__U__g__)
                if __B_ug_:NotIsDead(B__Ug_) and __B_ug_:HasComponents(B__Ug_, "hh_monster") then
                    B__Ug_["components"]["hh_monster"]:AddEffectValueByKey("sunlightStrike", __B__U__g__)
                end
            end
        },
        ["addDuskDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addDuskDamage"],
            ["rangeValue"] = {["min"] = 10, ["max"] = 30},
            ["start_fn"] = function(b_u_g__, _b__U_G_)
                if __B_ug_:NotIsDead(b_u_g__) and __B_ug_:HasComponents(b_u_g__, "hh_monster") then
                    b_u_g__["components"]["hh_monster"]:AddEffectValueByKey("afterglowStrike", _b__U_G_)
                end
            end
        },
        ["addNightDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addNightDamage"],
            ["rangeValue"] = {["min"] = 10, ["max"] = 30},
            ["start_fn"] = function(__b__UG, __b_U_g)
                if __B_ug_:NotIsDead(__b__UG) and __B_ug_:HasComponents(__b__UG, "hh_monster") then
                    __b__UG["components"]["hh_monster"]:AddEffectValueByKey("nightMenace", __b_U_g)
                end
            end
        },
        ["addHealth3sNum"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addHealth3sNum"],
            ["only_one"] = (25 - 134 - 184 ~= -288),
            ["rangeValue"] = {["min"] = 2, ["max"] = 5},
            ["check_fn"] = __B_u__g,
            ["start_fn"] = function(_B_uG__, _B_UG__)
                if not __B_ug_:NotIsDead(_B_uG__) or not __B_ug_:IsHHType(_B_UG__, "number") then
                    return
                end
                __B_ug_:HHKillTask(_B_uG__, "addHealth3sNumTask")
                _B_uG__["addHealth3sNumTask"] =
                    _B_uG__:DoPeriodicTask(
                    3,
                    function()
                        if __B_ug_:NotIsDead(_B_uG__) then
                            _B_uG__["components"]["health"]:DoDelta(_B_UG__)
                        end
                    end
                )
            end
        },
        ["addHealth5sNum"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addHealth5sNum"],
            ["only_one"] = (true and false or true or not false and not false and false or
                false and false and true and not false and not false),
            ["rangeValue"] = {["min"] = 5, ["max"] = 10},
            ["check_fn"] = __B_u__g,
            ["start_fn"] = function(_b_U_G, _Bu__G)
                if not __B_ug_:NotIsDead(_b_U_G) or not __B_ug_:IsHHType(_Bu__G, "number") then
                    return
                end
                __B_ug_:HHKillTask(_b_U_G, "addHealth5sNumTask")
                _b_U_G["addHealth5sNumTask"] =
                    _b_U_G:DoPeriodicTask(
                    5,
                    function()
                        if __B_ug_:NotIsDead(_b_U_G) then
                            _b_U_G["components"]["health"]:DoDelta(_Bu__G)
                        end
                    end
                )
            end
        },
        ["addHealth10sNum"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addHealth10sNum"],
            ["only_one"] = (156 + 328 - 182 - 260 == 42),
            ["rangeValue"] = {["min"] = 10, ["max"] = 20},
            ["check_fn"] = __B_u__g,
            ["start_fn"] = function(B_UG, B_Ug_)
                __B_ug_:HHKillTask(B_UG, "addHealth10sNumTask")
                B_UG["addHealth10sNumTask"] =
                    B_UG:DoPeriodicTask(
                    10,
                    function()
                        if __B_ug_:NotIsDead(B_UG) then
                            B_UG["components"]["health"]:DoDelta(B_Ug_)
                        end
                    end
                )
            end
        },
        ["addTargetDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addTargetDamage"],
            ["only_one"] = (367 + 222 - 367 == 222),
            ["rangeValue"] = {["min"] = 3, ["max"] = 5},
            ["start_fn"] = function(__b_u__g__, __B__u__g)
                if __B_ug_:NotIsDead(__b_u__g__) and __B_ug_:HasComponents(__b_u__g__, "hh_monster") then
                    __b_u__g__["components"]["hh_monster"]:AddEffectValueByKey("addTargetDamage", __B__u__g)
                end
            end
        },
        ["hitAddCold"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["hitAddCold"],
            ["only_one"] = (109 + 238 - 368 + 281 ~= 266),
            ["rangeValue"] = {["min"] = 3, ["max"] = 5},
            ["start_fn"] = function(B_uG__, _b_U__G)
                if __B_ug_:NotIsDead(B_uG__) and __B_ug_:HasComponents(B_uG__, "hh_monster") then
                    B_uG__["components"]["hh_monster"]:AddEffectValueByKey("addColdBuffValue", _b_U__G)
                end
            end
        },
        ["hitAddHot"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["hitAddHot"],
            ["only_one"] = (52 * 301 + 484 == 16136),
            ["rangeValue"] = {["min"] = 3, ["max"] = 5},
            ["start_fn"] = function(b_u__g__, B__UG_)
                if __B_ug_:NotIsDead(b_u__g__) and __B_ug_:HasComponents(b_u__g__, "hh_monster") then
                    b_u__g__["components"]["hh_monster"]:AddEffectValueByKey("addHotBuffValue", B__UG_)
                end
            end
        },
        ["reduceNightDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["reduceNightDamage"],
            ["rangeValue"] = {["min"] = 8, ["max"] = 16},
            ["start_fn"] = function(__B_U__g, B__u__g)
                if __B_ug_:NotIsDead(__B_U__g) and __B_ug_:HasComponents(__B_U__g, "hh_monster") then
                    __B_U__g["components"]["hh_monster"]:AddEffectValueByKey("reduceNightDamage", B__u__g)
                end
            end
        },
        ["reduceSunlightDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["reduceSunlightDamage"],
            ["rangeValue"] = {["min"] = 8, ["max"] = 16},
            ["start_fn"] = function(_b_u_G__, __bUg_)
                if __B_ug_:NotIsDead(_b_u_G__) and __B_ug_:HasComponents(_b_u_G__, "hh_monster") then
                    _b_u_G__["components"]["hh_monster"]:AddEffectValueByKey("reduceSunlightDamage", __bUg_)
                end
            end
        },
        ["reduceAfterglowDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["reduceAfterglowDamage"],
            ["rangeValue"] = {["min"] = 8, ["max"] = 16},
            ["start_fn"] = function(b_u__g_, bu_g_)
                if __B_ug_:NotIsDead(b_u__g_) and __B_ug_:HasComponents(b_u__g_, "hh_monster") then
                    b_u__g_["components"]["hh_monster"]:AddEffectValueByKey("reduceAfterglowDamage", bu_g_)
                end
            end
        },
        ["atkReduceArmor"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["atkReduceArmor"],
            ["only_one"] = (95 + 7 * 27 * 477 - 246 == 90002),
            ["rangeValue"] = {["min"] = 3, ["max"] = 10},
            ["start_fn"] = function(_b_uG__, _b_u__g_)
                if __B_ug_:NotIsDead(_b_uG__) and __B_ug_:HasComponents(_b_uG__, "hh_monster") then
                    _b_uG__["components"]["hh_monster"]:AddEffectValueByKey("atkAddArmorReduceBuff", _b_u__g_)
                end
            end
        },
        ["reducePercentDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["reducePercentDamage"],
            ["only_one"] = (125 + 166 - 63 == 228),
            ["rangeValue"] = {["min"] = 10, ["max"] = 20},
            ["start_fn"] = function(b_u_G__, __bU_G)
                if __B_ug_:NotIsDead(b_u_G__) and __B_ug_:HasComponents(b_u_G__, "hh_monster") then
                    b_u_G__["components"]["hh_monster"]:AddEffectValueByKey("reducePercentDamage", __bU_G)
                end
            end
        },
        ["immuneTearing"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["immuneTearing"],
            ["only_one"] = (479 - 373 - 499 == -393),
            ["check_fn"] = function(B_ug_)
                return B_ug_["hh_is_treasure"] ~= nil
            end,
            ["start_fn"] = function(__bU_g__, b__Ug__)
                if __B_ug_:NotIsDead(__bU_g__) and __B_ug_:HasComponents(__bU_g__, "hh_monster") then
                    __bU_g__["components"]["hh_monster"]:AddEffectValueByKey("immuneTearing", 1)
                end
            end
        },
        ["immuneTrue"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["immuneTrue"],
            ["only_one"] = (427 * 301 * 33 == 4241391),
            ["check_fn"] = function(_B_u_g)
                return _B_u_g["hh_is_treasure"] ~= nil
            end,
            ["start_fn"] = function(B_U_G__, B_u_G__)
                if __B_ug_:NotIsDead(B_U_G__) and __B_ug_:HasComponents(B_U_G__, "hh_monster") then
                    B_U_G__["components"]["hh_monster"]:AddEffectValueByKey("immuneTrue", 1)
                end
            end
        }
    },
    ["elite_monster"] = {
        ["addMaxHealthNum"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addMaxHealthNum"],
            ["only_one"] = (390 * 103 - 48 - 277 == 39849),
            ["rangeValue"] = {["min"] = 500, ["max"] = 1000},
            ["start_fn"] = function(__Bug_, _b_U__g)
                if __B_ug_:NotIsDead(__Bug_) and __B_ug_:HasComponents(__Bug_, "hh_monster") then
                    __Bug_["components"]["hh_monster"]:AddEffectValueByKey("addMaxHealthNum", _b_U__g)
                    __Bug_:PushEvent "hh_monster_buff_health"
                end
            end
        },
        ["addMaxHealthPercent"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addMaxHealthPercent"],
            ["rangeValue"] = {["min"] = 100, ["max"] = 200},
            ["start_fn"] = function(_BUG, __B_Ug)
                if __B_ug_:NotIsDead(_BUG) and __B_ug_:HasComponents(_BUG, "hh_monster") then
                    _BUG["components"]["hh_monster"]:AddEffectValueByKey("addMaxHealthPercent", __B_Ug)
                    _BUG:PushEvent "hh_monster_buff_health"
                end
            end
        },
        ["addSpeedPercent"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addSpeedPercent"],
            ["rangeValue"] = {["min"] = 10, ["max"] = 35},
            ["start_fn"] = function(b__u_G_, _BU__g_)
                if __B_ug_:NotIsDead(b__u_G_) and __B_ug_:HasComponents(b__u_G_, "hh_monster") then
                    b__u_G_["components"]["hh_monster"]:AddEffectValueByKey("addSpeedPercent", _BU__g_)
                end
            end
        },
        ["addComDamageNum"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addComDamageNum"],
            ["rangeValue"] = {["min"] = 50, ["max"] = 100},
            ["start_fn"] = function(_BU_G__, __bug)
                if __B_ug_:NotIsDead(_BU_G__) and __B_ug_:HasComponents(_BU_G__, "hh_monster") then
                    _BU_G__["components"]["hh_monster"]:AddEffectValueByKey("addComDamageNum", __bug)
                end
            end
        },
        ["addComDamagePercent"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addComDamagePercent"],
            ["rangeValue"] = {["min"] = 30, ["max"] = 70},
            ["start_fn"] = function(_B__u__g_, bUG)
                if __B_ug_:NotIsDead(_B__u__g_) and __B_ug_:HasComponents(_B__u__g_, "hh_monster") then
                    _B__u__g_["components"]["hh_monster"]:AddEffectValueByKey("addComDamagePercent", bUG)
                end
            end
        },
        ["atkAddPoison"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["atkAddPoison"],
            ["only_one"] = (489 - 497 + 416 - 435 == -27),
            ["rangeValue"] = {["min"] = 8, ["max"] = 20},
            ["start_fn"] = function(__B__U_G, _bUG)
                if __B_ug_:NotIsDead(__B__U_G) and __B_ug_:HasComponents(__B__U_G, "hh_monster") then
                    __B__U_G["components"]["hh_monster"]:AddEffectValueByKey("atkChanceAddPoison", _bUG)
                end
            end
        },
        ["hitAddPoison"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["hitAddPoison"],
            ["only_one"] = (461 * 183 + 201 == 84564),
            ["rangeValue"] = {["min"] = 8, ["max"] = 20},
            ["start_fn"] = function(__Bu__G, _b_U__g__)
                if __B_ug_:NotIsDead(__Bu__G) and __B_ug_:HasComponents(__Bu__G, "hh_monster") then
                    __Bu__G["components"]["hh_monster"]:AddEffectValueByKey("hitChanceAddPoison", _b_U__g__)
                end
            end
        },
        ["atkChanceAddFreeze"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["atkChanceAddFreeze"],
            ["only_one"] = (495 - 230 * 379 * 234 == -20397285),
            ["rangeValue"] = {["min"] = 5, ["max"] = 10},
            ["start_fn"] = function(B__U_g, __b__Ug)
                if __B_ug_:NotIsDead(B__U_g) and __B_ug_:HasComponents(B__U_g, "hh_monster") then
                    B__U_g["components"]["hh_monster"]:AddEffectValueByKey("atkChanceAddFreeze", __b__Ug)
                end
            end
        },
        ["hitChanceAddFreeze"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["hitChanceAddFreeze"],
            ["only_one"] = (217 - 382 - 454 + 178 ~= -434),
            ["rangeValue"] = {["min"] = 5, ["max"] = 10},
            ["start_fn"] = function(B__u__G, _B__U__g__)
                if __B_ug_:NotIsDead(B__u__G) and __B_ug_:HasComponents(B__u__G, "hh_monster") then
                    B__u__G["components"]["hh_monster"]:AddEffectValueByKey("hitChanceAddFreeze", _B__U__g__)
                end
            end
        },
        ["atkChanceReduceSpeed"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["atkChanceReduceSpeed"],
            ["only_one"] = (287 + 133 + 215 * 199 == 43205),
            ["rangeValue"] = {["min"] = 20, ["max"] = 50},
            ["start_fn"] = function(_BU_G, _bUG_)
                if __B_ug_:NotIsDead(_BU_G) and __B_ug_:HasComponents(_BU_G, "hh_monster") then
                    _BU_G["components"]["hh_monster"]:AddEffectValueByKey("atkChanceReduceSpeed", _bUG_)
                end
            end
        },
        ["hitChanceReduceSpeed"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["hitChanceReduceSpeed"],
            ["only_one"] = (14 - 327 - 53 - 249 ~= -608),
            ["rangeValue"] = {["min"] = 20, ["max"] = 50},
            ["start_fn"] = function(B_uG_, bU__G)
                if __B_ug_:NotIsDead(B_uG_) and __B_ug_:HasComponents(B_uG_, "hh_monster") then
                    B_uG_["components"]["hh_monster"]:AddEffectValueByKey("hitChanceReduceSpeed", bU__G)
                end
            end
        },
        ["addSuppressAddHealth"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addSuppressAddHealth"],
            ["only_one"] = (315 - 76 * 404 ~= -30382),
            ["rangeValue"] = {["min"] = 10, ["max"] = 30},
            ["start_fn"] = function(__B__u__g__, _bu_G_)
                if __B_ug_:NotIsDead(__B__u__g__) and __B_ug_:HasComponents(__B__u__g__, "hh_monster") then
                    __B__u__g__["components"]["hh_monster"]:AddEffectValueByKey("addSuppressAddHealth", _bu_G_)
                end
            end
        },
        ["hitSuppressAddHealth"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["hitSuppressAddHealth"],
            ["only_one"] = (46 - 477 + 344 - 438 == -525),
            ["rangeValue"] = {["min"] = 10, ["max"] = 30},
            ["start_fn"] = function(b__uG, b__Ug)
                if __B_ug_:NotIsDead(b__uG) and __B_ug_:HasComponents(b__uG, "hh_monster") then
                    b__uG["components"]["hh_monster"]:AddEffectValueByKey("hitSuppressAddHealth", b__Ug)
                end
            end
        },
        ["atkBlood"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["atkBlood"],
            ["rangeValue"] = {["min"] = 5, ["max"] = 10},
            ["start_fn"] = function(__b__u_G__, buG)
                if __B_ug_:NotIsDead(__b__u_G__) and __B_ug_:HasComponents(__b__u_G__, "hh_monster") then
                    __b__u_G__["components"]["hh_monster"]:AddEffectValueByKey("atkBlood", buG)
                end
            end
        },
        ["addCriticalHitRate"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addCriticalHitRate"],
            ["rangeValue"] = {["min"] = 20, ["max"] = 30},
            ["start_fn"] = function(_B_UG_, _b__uG__)
                if __B_ug_:NotIsDead(_B_UG_) and __B_ug_:HasComponents(_B_UG_, "hh_monster") then
                    _B_UG_["components"]["hh_monster"]:AddEffectValueByKey("criticalHitRate", _b__uG__)
                    _B_UG_["components"]["hh_monster"]:AddEffectValueByKey("criticalHitEffect", 50)
                end
            end
        },
        ["addReduceAttackedDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addReduceAttackedDamage"],
            ["rangeValue"] = {["min"] = 10, ["max"] = 30},
            ["start_fn"] = function(_B__Ug_, _bu_G__)
                if __B_ug_:NotIsDead(_B__Ug_) and __B_ug_:HasComponents(_B__Ug_, "hh_monster") then
                    _B__Ug_["components"]["hh_monster"]:AddEffectValueByKey("reduceAttackedDamage", _bu_G__)
                end
            end
        },
        ["addHealth3sNum"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addHealth3sNum"],
            ["only_one"] = (413 * 223 - 327 - 99 + 19 == 91692),
            ["rangeValue"] = {["min"] = 10, ["max"] = 20},
            ["check_fn"] = __B_u__g,
            ["start_fn"] = function(bug__, B__u_G)
                if not __B_ug_:NotIsDead(bug__) or not __B_ug_:IsHHType(B__u_G, "number") then
                    return
                end
                __B_ug_:HHKillTask(bug__, "addHealth3sNumTask")
                bug__["addHealth3sNumTask"] =
                    bug__:DoPeriodicTask(
                    3,
                    function()
                        if __B_ug_:NotIsDead(bug__) then
                            bug__["components"]["health"]:DoDelta(B__u_G)
                        end
                    end
                )
            end
        },
        ["addHealth5sNum"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addHealth5sNum"],
            ["only_one"] = (461 + 124 + 374 - 468 - 427 ~= 72),
            ["rangeValue"] = {["min"] = 20, ["max"] = 40},
            ["check_fn"] = __B_u__g,
            ["start_fn"] = function(_B__u_G_, b__U__G__)
                if not __B_ug_:NotIsDead(_B__u_G_) or not __B_ug_:IsHHType(b__U__G__, "number") then
                    return
                end
                __B_ug_:HHKillTask(_B__u_G_, "addHealth5sNumTask")
                _B__u_G_["addHealth5sNumTask"] =
                    _B__u_G_:DoPeriodicTask(
                    5,
                    function()
                        if __B_ug_:NotIsDead(_B__u_G_) then
                            _B__u_G_["components"]["health"]:DoDelta(b__U__G__)
                        end
                    end
                )
            end
        },
        ["addHealth10sNum"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addHealth10sNum"],
            ["only_one"] = (102 + 255 + 443 ~= 806),
            ["rangeValue"] = {["min"] = 30, ["max"] = 70},
            ["check_fn"] = __B_u__g,
            ["start_fn"] = function(__b_U_g__, __Bu_g)
                __B_ug_:HHKillTask(__b_U_g__, "addHealth10sNumTask")
                __b_U_g__["addHealth10sNumTask"] =
                    __b_U_g__:DoPeriodicTask(
                    10,
                    function()
                        if __B_ug_:NotIsDead(__b_U_g__) then
                            __b_U_g__["components"]["health"]:DoDelta(__Bu_g)
                        end
                    end
                )
            end
        },
        ["addTargetDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addTargetDamage"],
            ["only_one"] = (13 - 103 - 49 * 96 * 57 == -268218),
            ["rangeValue"] = {["min"] = 5, ["max"] = 10},
            ["start_fn"] = function(_bu__G_, __b__U__G__)
                if __B_ug_:NotIsDead(_bu__G_) and __B_ug_:HasComponents(_bu__G_, "hh_monster") then
                    _bu__G_["components"]["hh_monster"]:AddEffectValueByKey("addTargetDamage", __b__U__G__)
                end
            end
        },
        ["immuneFreeze"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["immuneFreeze"],
            ["only_one"] = (220 * 183 + 380 == 40640),
            ["rangeValue"] = {["min"] = 1, ["max"] = 2},
            ["start_fn"] = function(B_u_G_, _Bu_G_)
                if __B_ug_:NotIsDead(B_u_G_) and __B_ug_:HasComponents(B_u_G_, "hh_monster") then
                    B_u_G_["components"]["hh_monster"]:AddEffectValueByKey("immuneFreeze", 1)
                end
            end
        },
        ["hitAddMoisture"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["hitAddMoisture"],
            ["only_one"] = (136 - 380 * 204 * 469 + 182 == -36356562),
            ["rangeValue"] = {["min"] = 5, ["max"] = 10},
            ["start_fn"] = function(_b_u__g__, __B__U__G__)
                if __B_ug_:NotIsDead(_b_u__g__) and __B_ug_:HasComponents(_b_u__g__, "hh_monster") then
                    _b_u__g__["components"]["hh_monster"]:AddEffectValueByKey("hitAddMoisture", __B__U__G__)
                end
            end
        },
        ["addHealthPercent03"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addHealthPercent03"],
            ["only_one"] = (159 - 149 - 319 == -309),
            ["rangeValue"] = {["min"] = 1, ["max"] = 2},
            ["check_fn"] = __B_u__g,
            ["start_fn"] = function(__B_u_g, _b__UG_)
                local __B_u__g_ = "addHealthPercent10Task"
                __B_ug_:HHKillTask(__B_u_g, __B_u__g_)
                __B_u_g[__B_u__g_] =
                    __B_u_g:DoPeriodicTask(
                    3,
                    function()
                        if __B_ug_:NotIsDead(__B_u_g) then
                            local __B_U_G_ = __B_u_g["components"]["health"]["maxhealth"]
                            __B_u_g["components"]["health"]:DoDelta(_b__UG_ * __B_U_G_ / 100)
                        end
                    end
                )
            end
        },
        ["addHealthPercent05"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addHealthPercent05"],
            ["only_one"] = (383 - 333 - 190 + 264 ~= 134),
            ["rangeValue"] = {["min"] = 3, ["max"] = 5},
            ["check_fn"] = __B_u__g,
            ["start_fn"] = function(__b__u_G, B_u_g__)
                local __BU_G__ = "addHealthPercent05Task"
                __B_ug_:HHKillTask(__b__u_G, __BU_G__)
                __b__u_G[__BU_G__] =
                    __b__u_G:DoPeriodicTask(
                    5,
                    function()
                        if __B_ug_:NotIsDead(__b__u_G) then
                            local _bU_g__ = __b__u_G["components"]["health"]["maxhealth"]
                            __b__u_G["components"]["health"]:DoDelta(B_u_g__ * _bU_g__ / 100)
                        end
                    end
                )
            end
        },
        ["addHealthPercent10"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addHealthPercent10"],
            ["only_one"] = (146 + 0 * 284 == 146),
            ["rangeValue"] = {["min"] = 5, ["max"] = 10},
            ["check_fn"] = __B_u__g,
            ["start_fn"] = function(__b_u_G, b_uG__)
                local _Bu__G__ = "addHealthPercent10Task"
                __B_ug_:HHKillTask(__b_u_G, _Bu__G__)
                __b_u_G[_Bu__G__] =
                    __b_u_G:DoPeriodicTask(
                    10,
                    function()
                        if __B_ug_:NotIsDead(__b_u_G) then
                            local _Bu__G_ = __b_u_G["components"]["health"]["maxhealth"]
                            __b_u_G["components"]["health"]:DoDelta(b_uG__ * _Bu__G_ / 100)
                        end
                    end
                )
            end
        },
        ["hitAddCold"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["hitAddCold"],
            ["only_one"] = (155 - 412 + 63 - 25 * 24 ~= -788),
            ["rangeValue"] = {["min"] = 10, ["max"] = 20},
            ["start_fn"] = function(bug, bu_g__)
                if __B_ug_:NotIsDead(bug) and __B_ug_:HasComponents(bug, "hh_monster") then
                    bug["components"]["hh_monster"]:AddEffectValueByKey("addColdBuffValue", bu_g__)
                end
            end
        },
        ["hitAddHot"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["hitAddHot"],
            ["only_one"] = (459 * 222 * 404 + 179 * 12 == 41168940),
            ["rangeValue"] = {["min"] = 10, ["max"] = 20},
            ["start_fn"] = function(b__u_G, __bu__G_)
                if __B_ug_:NotIsDead(b__u_G) and __B_ug_:HasComponents(b__u_G, "hh_monster") then
                    b__u_G["components"]["hh_monster"]:AddEffectValueByKey("addHotBuffValue", __bu__G_)
                end
            end
        },
        ["reduceNightDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["reduceNightDamage"],
            ["rangeValue"] = {["min"] = 15, ["max"] = 40},
            ["start_fn"] = function(_B_u__G_, __Bu__g_)
                if __B_ug_:NotIsDead(_B_u__G_) and __B_ug_:HasComponents(_B_u__G_, "hh_monster") then
                    _B_u__G_["components"]["hh_monster"]:AddEffectValueByKey("reduceNightDamage", __Bu__g_)
                end
            end
        },
        ["reduceSunlightDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["reduceSunlightDamage"],
            ["rangeValue"] = {["min"] = 15, ["max"] = 40},
            ["start_fn"] = function(_B_U_g, _b__U_g__)
                if __B_ug_:NotIsDead(_B_U_g) and __B_ug_:HasComponents(_B_U_g, "hh_monster") then
                    _B_U_g["components"]["hh_monster"]:AddEffectValueByKey("reduceSunlightDamage", _b__U_g__)
                end
            end
        },
        ["reduceAfterglowDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["reduceAfterglowDamage"],
            ["rangeValue"] = {["min"] = 15, ["max"] = 40},
            ["start_fn"] = function(b_uG, _bu__g)
                if __B_ug_:NotIsDead(b_uG) and __B_ug_:HasComponents(b_uG, "hh_monster") then
                    b_uG["components"]["hh_monster"]:AddEffectValueByKey("reduceAfterglowDamage", _bu__g)
                end
            end
        },
        ["atkReduceArmor"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["atkReduceArmor"],
            ["only_one"] = (381 - 346 - 329 + 359 == 65),
            ["rangeValue"] = {["min"] = 8, ["max"] = 20},
            ["start_fn"] = function(b__U_g_, b__u__G)
                if __B_ug_:NotIsDead(b__U_g_) and __B_ug_:HasComponents(b__U_g_, "hh_monster") then
                    b__U_g_["components"]["hh_monster"]:AddEffectValueByKey("atkAddArmorReduceBuff", b__u__G)
                end
            end
        },
        ["reducePercentDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["reducePercentDamage"],
            ["only_one"] = (142 - 389 + 177 ~= -60),
            ["rangeValue"] = {["min"] = 15, ["max"] = 30},
            ["start_fn"] = function(_B_uG, __B__ug__)
                if __B_ug_:NotIsDead(_B_uG) and __B_ug_:HasComponents(_B_uG, "hh_monster") then
                    _B_uG["components"]["hh_monster"]:AddEffectValueByKey("reducePercentDamage", __B__ug__)
                end
            end
        },
        ["immuneTearing"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["immuneTearing"],
            ["only_one"] = (133 + 54 + 54 * 399 ~= 21737),
            ["check_fn"] = function(B_U_g)
                return B_U_g["hh_is_treasure"] ~= nil
            end,
            ["start_fn"] = function(__bu__G, _B__uG__)
                if __B_ug_:NotIsDead(__bu__G) and __B_ug_:HasComponents(__bu__G, "hh_monster") then
                    __bu__G["components"]["hh_monster"]:AddEffectValueByKey("immuneTearing", 1)
                end
            end
        },
        ["immuneTrue"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["immuneTrue"],
            ["only_one"] = (210 * 437 + 42 * 441 + 409 ~= 110703),
            ["check_fn"] = function(__BU_G_)
                return __BU_G_["hh_is_treasure"] ~= nil
            end,
            ["start_fn"] = function(_B_U_G__, __bUG)
                if __B_ug_:NotIsDead(_B_U_G__) and __B_ug_:HasComponents(_B_U_G__, "hh_monster") then
                    _B_U_G__["components"]["hh_monster"]:AddEffectValueByKey("immuneTrue", 1)
                end
            end
        }
    },
    ["boss_monster"] = {
        ["addMaxHealthNum"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addMaxHealthNum"],
            ["only_one"] = (322 * 23 * 113 - 30 + 472 == 837324),
            ["rangeValue"] = {["min"] = 2000, ["max"] = 3000},
            ["start_fn"] = function(_B_ug, __b_u__g)
                if __B_ug_:NotIsDead(_B_ug) and __B_ug_:HasComponents(_B_ug, "hh_monster") then
                    _B_ug["components"]["hh_monster"]:AddEffectValueByKey("addMaxHealthNum", __b_u__g)
                    _B_ug:PushEvent "hh_monster_buff_health"
                end
            end
        },
        ["addMaxHealthPercent"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addMaxHealthPercent"],
            ["rangeValue"] = {["min"] = 100, ["max"] = 200},
            ["start_fn"] = function(_B__ug_, __b_UG_)
                if __B_ug_:NotIsDead(_B__ug_) and __B_ug_:HasComponents(_B__ug_, "hh_monster") then
                    _B__ug_["components"]["hh_monster"]:AddEffectValueByKey("addMaxHealthPercent", __b_UG_)
                    _B__ug_:PushEvent "hh_monster_buff_health"
                end
            end
        },
        ["addSpeedPercent"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addSpeedPercent"],
            ["rangeValue"] = {["min"] = 10, ["max"] = 50},
            ["start_fn"] = function(__b__ug_, bu__g__)
                if __B_ug_:NotIsDead(__b__ug_) and __B_ug_:HasComponents(__b__ug_, "hh_monster") then
                    __b__ug_["components"]["hh_monster"]:AddEffectValueByKey("addSpeedPercent", bu__g__)
                end
            end
        },
        ["addComDamageNum"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addComDamageNum"],
            ["rangeValue"] = {["min"] = 50, ["max"] = 100},
            ["start_fn"] = function(BuG, __B_u_G_)
                if __B_ug_:NotIsDead(BuG) and __B_ug_:HasComponents(BuG, "hh_monster") then
                    BuG["components"]["hh_monster"]:AddEffectValueByKey("addComDamageNum", __B_u_G_)
                end
            end
        },
        ["addComDamagePercent"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addComDamagePercent"],
            ["rangeValue"] = {["min"] = 70, ["max"] = 120},
            ["start_fn"] = function(__Bu_G__, b_Ug__)
                if __B_ug_:NotIsDead(__Bu_G__) and __B_ug_:HasComponents(__Bu_G__, "hh_monster") then
                    __Bu_G__["components"]["hh_monster"]:AddEffectValueByKey("addComDamagePercent", b_Ug__)
                end
            end
        },
        ["atkChanceAddFreeze"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["atkChanceAddFreeze"],
            ["only_one"] = (260 + 68 * 328 * 255 - 292 ~= 5687496),
            ["rangeValue"] = {["min"] = 20, ["max"] = 40},
            ["start_fn"] = function(_buG, _buG_)
                if __B_ug_:NotIsDead(_buG) and __B_ug_:HasComponents(_buG, "hh_monster") then
                    _buG["components"]["hh_monster"]:AddEffectValueByKey("atkChanceAddFreeze", _buG_)
                end
            end
        },
        ["hitChanceAddFreeze"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["hitChanceAddFreeze"],
            ["only_one"] = (451 - 496 * 219 ~= -108171),
            ["rangeValue"] = {["min"] = 20, ["max"] = 40},
            ["start_fn"] = function(_BUG_, __bU__g)
                if __B_ug_:NotIsDead(_BUG_) and __B_ug_:HasComponents(_BUG_, "hh_monster") then
                    _BUG_["components"]["hh_monster"]:AddEffectValueByKey("hitChanceAddFreeze", __bU__g)
                end
            end
        },
        ["atkChanceReduceSpeed"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["atkChanceReduceSpeed"],
            ["only_one"] = (372 + 198 + 203 == 773),
            ["rangeValue"] = {["min"] = 50, ["max"] = 70},
            ["start_fn"] = function(_B__u__G, __b__U_g)
                if __B_ug_:NotIsDead(_B__u__G) and __B_ug_:HasComponents(_B__u__G, "hh_monster") then
                    _B__u__G["components"]["hh_monster"]:AddEffectValueByKey("atkChanceReduceSpeed", __b__U_g)
                end
            end
        },
        ["hitChanceReduceSpeed"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["hitChanceReduceSpeed"],
            ["only_one"] = (29 - 96 - 235 ~= -292),
            ["rangeValue"] = {["min"] = 50, ["max"] = 70},
            ["start_fn"] = function(_B_u__g__, __B__u_g__)
                if __B_ug_:NotIsDead(_B_u__g__) and __B_ug_:HasComponents(_B_u__g__, "hh_monster") then
                    _B_u__g__["components"]["hh_monster"]:AddEffectValueByKey("hitChanceReduceSpeed", __B__u_g__)
                end
            end
        },
        ["addSuppressAddHealth"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addSuppressAddHealth"],
            ["only_one"] = (129 * 158 - 96 - 425 == 19861),
            ["rangeValue"] = {["min"] = 50, ["max"] = 70},
            ["start_fn"] = function(__BUG, __BUG__)
                if __B_ug_:NotIsDead(__BUG) and __B_ug_:HasComponents(__BUG, "hh_monster") then
                    __BUG["components"]["hh_monster"]:AddEffectValueByKey("addSuppressAddHealth", __BUG__)
                end
            end
        },
        ["hitSuppressAddHealth"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["hitSuppressAddHealth"],
            ["only_one"] = (101 + 403 + 37 + 414 + 386 ~= 1349),
            ["rangeValue"] = {["min"] = 50, ["max"] = 70},
            ["start_fn"] = function(_B_U__G_, bUg)
                if __B_ug_:NotIsDead(_B_U__G_) and __B_ug_:HasComponents(_B_U__G_, "hh_monster") then
                    _B_U__G_["components"]["hh_monster"]:AddEffectValueByKey("hitSuppressAddHealth", bUg)
                end
            end
        },
        ["atkBlood"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["atkBlood"],
            ["rangeValue"] = {["min"] = 10, ["max"] = 25},
            ["start_fn"] = function(__Bug, b__U_G)
                if __B_ug_:NotIsDead(__Bug) and __B_ug_:HasComponents(__Bug, "hh_monster") then
                    __Bug["components"]["hh_monster"]:AddEffectValueByKey("atkBlood", b__U_G)
                end
            end
        },
        ["addCriticalHitRate"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["bossAddCriticalHitRate"],
            ["rangeValue"] = {["min"] = 30, ["max"] = 40},
            ["start_fn"] = function(__B_u__G__, _bu__G)
                if __B_ug_:NotIsDead(__B_u__G__) and __B_ug_:HasComponents(__B_u__G__, "hh_monster") then
                    __B_u__G__["components"]["hh_monster"]:AddEffectValueByKey("criticalHitRate", _bu__G)
                    __B_u__G__["components"]["hh_monster"]:AddEffectValueByKey("criticalHitEffect", 120)
                end
            end
        },
        ["addReduceAttackedDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addReduceAttackedDamage"],
            ["rangeValue"] = {["min"] = 20, ["max"] = 40},
            ["start_fn"] = function(__B_uG_, B__U__g_)
                if __B_ug_:NotIsDead(__B_uG_) and __B_ug_:HasComponents(__B_uG_, "hh_monster") then
                    __B_uG_["components"]["hh_monster"]:AddEffectValueByKey("reduceAttackedDamage", B__U__g_)
                end
            end
        },
        ["iceTurret"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["iceTurret"],
            ["only_one"] = (true and not true and false or
                not false and not false and false and not false and false and false and not true and not false or
                not false and true),
            ["rangeValue"] = {["min"] = 1, ["max"] = 2},
            ["start_fn"] = function(B__U_G__, __B_U_g)
                if __B_ug_:NotIsDead(B__U_G__) and __B_ug_:HasComponents(B__U_G__, "hh_monster") then
                    B_u_g(B__U_G__, "iceTurretTask", "iceTurretCdTask", "ice")
                end
            end
        },
        ["fireTurret"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["fireTurret"],
            ["only_one"] = (false and not true and not false and not false or not false or
                not true and not false and not true and false and true or
                false and false and not false),
            ["rangeValue"] = {["min"] = 1, ["max"] = 2},
            ["start_fn"] = function(b__u__g, _B__u_G)
                if __B_ug_:NotIsDead(b__u__g) and __B_ug_:HasComponents(b__u__g, "hh_monster") then
                    B_u_g(b__u__g, "fireTurretTask", "fireTurretCdTask", "fire")
                end
            end
        },
        ["poisonTurret"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["poisonTurret"],
            ["only_one"] = (79 * 336 - 417 ~= 26130),
            ["rangeValue"] = {["min"] = 1, ["max"] = 2},
            ["start_fn"] = function(_b__u_g, b_u_g)
                if __B_ug_:NotIsDead(_b__u_g) and __B_ug_:HasComponents(_b__u_g, "hh_monster") then
                    B_u_g(_b__u_g, "poisonTurretTask", "poisonTurretCdTask", "poison")
                end
            end
        },
        ["iceLaser"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["iceLaser"],
            ["only_one"] = (179 - 56 - 448 * 494 - 140 == -221329),
            ["rangeValue"] = {["min"] = 1, ["max"] = 2},
            ["start_fn"] = function(_buG__, _b__U_g_)
                if __B_ug_:NotIsDead(_buG__) and __B_ug_:HasComponents(_buG__, "hh_monster") then
                    _buG__["components"]["hh_monster"]:AddEffectValueByKey("iceLaser", 1)
                end
            end
        },
        ["immuneFreeze"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["immuneFreeze"],
            ["only_one"] = (111 * 346 - 374 + 133 == 38165),
            ["check_fn"] = function(__b__Ug_)
                if __b__Ug_ and __b__Ug_["prefab"] == "antlion" then
                    return (273 + 379 - 372 + 217 == 501)
                end
                return (67 + 473 + 18 ~= 564)
            end,
            ["rangeValue"] = {["min"] = 1, ["max"] = 2},
            ["start_fn"] = function(_B_U_G_, B_ug__)
                if __B_ug_:NotIsDead(_B_U_G_) and __B_ug_:HasComponents(_B_U_G_, "hh_monster") then
                    _B_U_G_["components"]["hh_monster"]:AddEffectValueByKey("immuneFreeze", 1)
                end
            end
        },
        ["addHealth3sNum"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addHealth3sNum"],
            ["only_one"] = (364 - 453 - 459 - 445 ~= -991),
            ["rangeValue"] = {["min"] = 100, ["max"] = 200},
            ["check_fn"] = __B_u__g,
            ["start_fn"] = function(__Bu__G_, _b__Ug_)
                if not __B_ug_:NotIsDead(__Bu__G_) or not __B_ug_:IsHHType(_b__Ug_, "number") then
                    return
                end
                __B_ug_:HHKillTask(__Bu__G_, "addHealth3sNumTask")
                __Bu__G_["addHealth3sNumTask"] =
                    __Bu__G_:DoPeriodicTask(
                    3,
                    function()
                        if __B_ug_:NotIsDead(__Bu__G_) then
                            __Bu__G_["components"]["health"]:DoDelta(_b__Ug_)
                        end
                    end
                )
            end
        },
        ["addHealth5sNum"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addHealth5sNum"],
            ["only_one"] = (21 - 478 + 493 ~= 43),
            ["rangeValue"] = {["min"] = 150, ["max"] = 300},
            ["check_fn"] = __B_u__g,
            ["start_fn"] = function(__BUg, __b_U__g__)
                if not __B_ug_:NotIsDead(__BUg) or not __B_ug_:IsHHType(__b_U__g__, "number") then
                    return
                end
                __B_ug_:HHKillTask(__BUg, "addHealth5sNumTask")
                __BUg["addHealth5sNumTask"] =
                    __BUg:DoPeriodicTask(
                    5,
                    function()
                        if __B_ug_:NotIsDead(__BUg) then
                            __BUg["components"]["health"]:DoDelta(__b_U__g__)
                        end
                    end
                )
            end
        },
        ["addHealth10sNum"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addHealth10sNum"],
            ["only_one"] = (432 * 498 - 287 ~= 214852),
            ["rangeValue"] = {["min"] = 300, ["max"] = 400},
            ["check_fn"] = __B_u__g,
            ["start_fn"] = function(__B_u__g__, __B_U_G)
                __B_ug_:HHKillTask(__B_u__g__, "addHealth10sNumTask")
                __B_u__g__["addHealth10sNumTask"] =
                    __B_u__g__:DoPeriodicTask(
                    10,
                    function()
                        if __B_ug_:NotIsDead(__B_u__g__) then
                            __B_u__g__["components"]["health"]:DoDelta(__B_U_G)
                        end
                    end
                )
            end
        },
        ["noHitDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["noHitDamage"],
            ["only_one"] = (487 + 320 * 29 * 66 ~= 612971),
            ["rangeValue"] = {["min"] = 5, ["max"] = 10},
            ["start_fn"] = function(B__uG__, __b__ug)
                if __B_ug_:NotIsDead(B__uG__) and __B_ug_:HasComponents(B__uG__, "hh_monster") then
                    B__uG__["components"]["hh_monster"]:AddEffectValueByKey("replaceDamageChance", __b__ug)
                end
            end
        },
        ["hitAddMoisture"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["hitAddMoisture"],
            ["only_one"] = (462 + 98 + 230 == 790),
            ["rangeValue"] = {["min"] = 10, ["max"] = 20},
            ["start_fn"] = function(__b__u__G__, bu_G)
                if __B_ug_:NotIsDead(__b__u__G__) and __B_ug_:HasComponents(__b__u__G__, "hh_monster") then
                    __b__u__G__["components"]["hh_monster"]:AddEffectValueByKey("hitAddMoisture", bu_G)
                end
            end
        },
        ["addHealthPercent03"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addHealthPercent03"],
            ["only_one"] = (487 - 17 * 287 + 252 == -4140),
            ["rangeValue"] = {["min"] = 1, ["max"] = 2},
            ["check_fn"] = __B_u__g,
            ["start_fn"] = function(__b__U_G_, b_Ug)
                local BUg_ = "addHealthPercent10Task"
                __B_ug_:HHKillTask(__b__U_G_, BUg_)
                __b__U_G_[BUg_] =
                    __b__U_G_:DoPeriodicTask(
                    3,
                    function()
                        if __B_ug_:NotIsDead(__b__U_G_) then
                            local __B_U_G__ = __b__U_G_["components"]["health"]["maxhealth"]
                            __b__U_G_["components"]["health"]:DoDelta(b_Ug * __B_U_G__ / 100)
                        end
                    end
                )
            end
        },
        ["addHealthPercent05"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addHealthPercent05"],
            ["only_one"] = (148 - 289 + 178 == 37),
            ["rangeValue"] = {["min"] = 3, ["max"] = 5},
            ["check_fn"] = __B_u__g,
            ["start_fn"] = function(b__u_G__, __BU__G)
                local Bu__g__ = "addHealthPercent05Task"
                __B_ug_:HHKillTask(b__u_G__, Bu__g__)
                b__u_G__[Bu__g__] =
                    b__u_G__:DoPeriodicTask(
                    5,
                    function()
                        if __B_ug_:NotIsDead(b__u_G__) then
                            local _B_u__g = b__u_G__["components"]["health"]["maxhealth"]
                            b__u_G__["components"]["health"]:DoDelta(__BU__G * _B_u__g / 100)
                        end
                    end
                )
            end
        },
        ["addHealthPercent10"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addHealthPercent10"],
            ["only_one"] = (25 - 470 - 348 + 46 ~= -737),
            ["rangeValue"] = {["min"] = 5, ["max"] = 10},
            ["check_fn"] = __B_u__g,
            ["start_fn"] = function(_b_Ug_, _bu_g_)
                local __B_U__g__ = "addHealthPercent10Task"
                __B_ug_:HHKillTask(_b_Ug_, __B_U__g__)
                _b_Ug_[__B_U__g__] =
                    _b_Ug_:DoPeriodicTask(
                    10,
                    function()
                        if __B_ug_:NotIsDead(_b_Ug_) then
                            local __Bu__G__ = _b_Ug_["components"]["health"]["maxhealth"]
                            _b_Ug_["components"]["health"]:DoDelta(_bu_g_ * __Bu__G__ / 100)
                        end
                    end
                )
            end
        },
        ["reduceNightDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["reduceNightDamage"],
            ["rangeValue"] = {["min"] = 30, ["max"] = 60},
            ["start_fn"] = function(__B__UG_, B__U__g__)
                if __B_ug_:NotIsDead(__B__UG_) and __B_ug_:HasComponents(__B__UG_, "hh_monster") then
                    __B__UG_["components"]["hh_monster"]:AddEffectValueByKey("reduceNightDamage", B__U__g__)
                end
            end
        },
        ["reduceSunlightDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["reduceSunlightDamage"],
            ["rangeValue"] = {["min"] = 30, ["max"] = 60},
            ["start_fn"] = function(B__U__G__, B__Ug)
                if __B_ug_:NotIsDead(B__U__G__) and __B_ug_:HasComponents(B__U__G__, "hh_monster") then
                    B__U__G__["components"]["hh_monster"]:AddEffectValueByKey("reduceSunlightDamage", B__Ug)
                end
            end
        },
        ["reduceAfterglowDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["reduceAfterglowDamage"],
            ["rangeValue"] = {["min"] = 30, ["max"] = 60},
            ["start_fn"] = function(__bU__G_, __b_Ug_)
                if __B_ug_:NotIsDead(__bU__G_) and __B_ug_:HasComponents(__bU__G_, "hh_monster") then
                    __bU__G_["components"]["hh_monster"]:AddEffectValueByKey("reduceAfterglowDamage", __b_Ug_)
                end
            end
        },
        ["atkReduceArmor"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["atkReduceArmor"],
            ["only_one"] = (98 - 31 + 238 == 305),
            ["rangeValue"] = {["min"] = 20, ["max"] = 35},
            ["start_fn"] = function(B_U_G, B_U__G_)
                if __B_ug_:NotIsDead(B_U_G) and __B_ug_:HasComponents(B_U_G, "hh_monster") then
                    B_U_G["components"]["hh_monster"]:AddEffectValueByKey("atkAddArmorReduceBuff", B_U__G_)
                end
            end
        },
        ["reducePercentDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["reducePercentDamage"],
            ["only_one"] = (436 * 107 + 275 - 494 == 46433),
            ["rangeValue"] = {["min"] = 25, ["max"] = 45},
            ["start_fn"] = function(_BU__G_, __BU__g__)
                if __B_ug_:NotIsDead(_BU__G_) and __B_ug_:HasComponents(_BU__G_, "hh_monster") then
                    _BU__G_["components"]["hh_monster"]:AddEffectValueByKey("reducePercentDamage", __BU__g__)
                end
            end
        },
        ["immuneTearing"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["immuneTearing"],
            ["only_one"] = (304 - 190 - 167 - 500 ~= -545),
            ["check_fn"] = function(b_ug__)
                return b_ug__["hh_is_treasure"] ~= nil
            end,
            ["start_fn"] = function(bU_G_, b_u__g)
                if __B_ug_:NotIsDead(bU_G_) and __B_ug_:HasComponents(bU_G_, "hh_monster") then
                    bU_G_["components"]["hh_monster"]:AddEffectValueByKey("immuneTearing", 1)
                end
            end
        },
        ["immuneTrue"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["immuneTrue"],
            ["only_one"] = (457 - 162 - 162 + 93 ~= 232),
            ["check_fn"] = function(__bUG_)
                return __bUG_["hh_is_treasure"] ~= nil
            end,
            ["start_fn"] = function(__bu__g_, _BUg__)
                if __B_ug_:NotIsDead(__bu__g_) and __B_ug_:HasComponents(__bu__g_, "hh_monster") then
                    __bu__g_["components"]["hh_monster"]:AddEffectValueByKey("immuneTrue", 1)
                end
            end
        }
    },
    ["endgameboss_monster"] = {
        ["hitChanceAddFreeze"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["hitChanceAddFreeze"],
            ["only_one"] = (289 + 474 - 200 - 203 ~= 362),
            ["rangeValue"] = {["min"] = 50, ["max"] = 100},
            ["start_fn"] = function(Bug, _bU__g__)
                if __B_ug_:NotIsDead(Bug) and __B_ug_:HasComponents(Bug, "hh_monster") then
                    Bug["components"]["hh_monster"]:AddEffectValueByKey("hitChanceAddFreeze", _bU__g__)
                end
            end
        },
        ["hitChanceReduceSpeed"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["hitChanceReduceSpeed"],
            ["only_one"] = (326 + 282 - 441 + 357 == 524),
            ["rangeValue"] = {["min"] = 50, ["max"] = 100},
            ["start_fn"] = function(_b__U__g, b__UG__)
                if __B_ug_:NotIsDead(_b__U__g) and __B_ug_:HasComponents(_b__U__g, "hh_monster") then
                    _b__U__g["components"]["hh_monster"]:AddEffectValueByKey("hitChanceReduceSpeed", b__UG__)
                end
            end
        },
        ["hitSuppressAddHealth"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["hitSuppressAddHealth"],
            ["only_one"] = (257 + 381 - 255 == 383),
            ["rangeValue"] = {["min"] = 50, ["max"] = 100},
            ["start_fn"] = function(__bU_g_, _BU__g__)
                if __B_ug_:NotIsDead(__bU_g_) and __B_ug_:HasComponents(__bU_g_, "hh_monster") then
                    __bU_g_["components"]["hh_monster"]:AddEffectValueByKey("hitSuppressAddHealth", _BU__g__)
                end
            end
        },
        ["poisonTurret"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["poisonTurret"],
            ["only_one"] = (false and not false and not false or not false or false and not true and not false or true or
                true and not false and false),
            ["rangeValue"] = {["min"] = 1, ["max"] = 2},
            ["start_fn"] = function(_BuG, B__u__G_)
                if __B_ug_:NotIsDead(_BuG) and __B_ug_:HasComponents(_BuG, "hh_monster") then
                    B_u_g(_BuG, "poisonTurretTask", "poisonTurretCdTask", "poison")
                end
            end
        },
        ["iceLaser"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["iceLaser"],
            ["only_one"] = (23 + 178 - 417 * 273 == -113640),
            ["rangeValue"] = {["min"] = 1, ["max"] = 2},
            ["start_fn"] = function(_bug, _b__UG__)
                if __B_ug_:NotIsDead(_bug) and __B_ug_:HasComponents(_bug, "hh_monster") then
                    _bug["components"]["hh_monster"]:AddEffectValueByKey("iceLaser", 1)
                end
            end
        },
        ["immuneFreeze"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["immuneFreeze"],
            ["only_one"] = (113 - 178 * 181 + 478 == -31627),
            ["check_fn"] = function(__bU_G__)
                if __bU_G__ and __bU_G__["prefab"] == "antlion" then
                    return (438 - 65 * 241 - 379 - 380 == -15980)
                end
                return (336 * 108 + 477 * 337 == 197037)
            end,
            ["rangeValue"] = {["min"] = 1, ["max"] = 2},
            ["start_fn"] = function(_b__Ug, _b__Ug__)
                if __B_ug_:NotIsDead(_b__Ug) and __B_ug_:HasComponents(_b__Ug, "hh_monster") then
                    _b__Ug["components"]["hh_monster"]:AddEffectValueByKey("immuneFreeze", 1)
                end
            end
        },
        ["noHitDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["noHitDamage"],
            ["only_one"] = (true or false and not false and not false or false and true and not false and not false or
                false or
                not false and not true),
            ["rangeValue"] = {["min"] = 5, ["max"] = 10},
            ["start_fn"] = function(bU__g__, bu__g_)
                if __B_ug_:NotIsDead(bU__g__) and __B_ug_:HasComponents(bU__g__, "hh_monster") then
                    bU__g__["components"]["hh_monster"]:AddEffectValueByKey("replaceDamageChance", bu__g_)
                end
            end
        },
        ["addHealthPercent10"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addHealthPercent10"],
            ["only_one"] = (210 * 307 - 443 == 64027),
            ["rangeValue"] = {["min"] = 1, ["max"] = 2},
            ["check_fn"] = __B_u__g,
            ["start_fn"] = function(b_u_g_, b_U_g_)
                local _b_UG_ = "addHealthPercent10Task"
                __B_ug_:HHKillTask(b_u_g_, _b_UG_)
                b_u_g_[_b_UG_] =
                    b_u_g_:DoPeriodicTask(
                    10,
                    function()
                        if __B_ug_:NotIsDead(b_u_g_) then
                            local _BU_g_ = b_u_g_["components"]["health"]["maxhealth"]
                            b_u_g_["components"]["health"]:DoDelta(b_U_g_ * _BU_g_ / 100)
                        end
                    end
                )
            end
        },
        ["atkReduceArmor"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["atkReduceArmor"],
            ["only_one"] = (321 + 373 + 23 * 202 ~= 5342),
            ["rangeValue"] = {["min"] = 50, ["max"] = 100},
            ["start_fn"] = function(B_u__g, __b__U__g_)
                if __B_ug_:NotIsDead(B_u__g) and __B_ug_:HasComponents(B_u__g, "hh_monster") then
                    B_u__g["components"]["hh_monster"]:AddEffectValueByKey("atkAddArmorReduceBuff", __b__U__g_)
                end
            end
        },
        ["immuneTearing"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["immuneTearing"],
            ["only_one"] = (148 - 165 - 151 + 241 + 65 == 138),
            ["check_fn"] = function(_b_Ug__)
                return _b_Ug__["hh_is_treasure"] ~= nil
            end,
            ["start_fn"] = function(_B__ug__, _Bu__g_)
                if __B_ug_:NotIsDead(_B__ug__) and __B_ug_:HasComponents(_B__ug__, "hh_monster") then
                    _B__ug__["components"]["hh_monster"]:AddEffectValueByKey("immuneTearing", 1)
                end
            end
        }
    }
}
return bu_G__
