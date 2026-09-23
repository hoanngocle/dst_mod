local _b_U_g_ = require "utils/hh_utils"
local __b__UG_ = {
    ["aa_punchStone"] = {["name"] = "Mũi đục"},
    ["ab_decoderStone"] = {["name"] = "Búa đục"},
    ["ac_refreshStone"] = {["name"] = "Bùa may"},
    ["ad_cleanStone"] = {["name"] = "Bùa tẩy"},
    ["durableGem"] = {["name"] = "Đá bền bỉ"},
    ["powerMettleStone"] = {["name"] = "Đá sức mạnh"},
    ["followCritical"] = {["name"] = "Đá thú chí"},
    ["followDamage"] = {["name"] = "Đá thú sát"},
    ["followArmor"] = {["name"] = "Đá thú ngự"},
    ["critStrikeStone"] = {["name"] = "Đá chí mạng"},
    ["resistDamageGem"] = {["name"] = "Đá giảm thương"},
    ["treasure_atk"] = {["name"] = "Bảo★Sát", ["person_only"] = (149 - 44 * 42 + 234 + 375 == -1090)},
    ["treasure_bj"] = {["name"] = "Bảo★Chí", ["person_only"] = (282 + 273 + 148 - 277 * 352 == -96801)},
    ["treasure_armor"] = {["name"] = "Bảo★Bền", ["person_only"] = (296 - 348 - 471 + 358 + 393 ~= 235)},
    ["strideBead"] = {["name"] = "Bảo★Tốc", ["person_only"] = (480 + 51 - 376 + 54 == 209)},
    ["treasure_fireGem"] = {["name"] = "Bảo★Lửa", ["person_only"] = true},
    ["baconOmeletteFire"] = {["name"] = "Siêu★Lửa", ["person_only"] = true},
    ["elementBead"] = {["name"] = "Siêu★Xâm", ["person_only"] = (110 + 451 + 40 ~= 606)},
    ["baconOmeletteTrueDamage"] = {["name"] = "Siêu★Xuyên", ["person_only"] = (426 + 445 - 228 + 425 == 1068)},
    ["baconOmeletteBlessAtk"] = {["name"] = "Siêu★Sát", ["person_only"] = (306 - 160 + 395 ~= 547)},
    ["baconOmeletteBlessCritical"] = {["name"] = "Siêu★Chí", ["person_only"] = (120 + 143 * 43 == 6269)},
    ["baconOmeletteSpeed"] = {["name"] = "Siêu★Tốc", ["person_only"] = true},
    ["baconOmeletteAOE"] = {["name"] = "Siêu★Lan", ["person_only"] = true},
    ["baconOmeletteDodge"] = {["name"] = "Siêu★Né", ["person_only"] = true},
    ["baconOmeletteKill"] = {["name"] = "Siêu★Trảm", ["person_only"] = true},
    ["baconOmeletteBlessArmor"] = {
        ["name"] = "Siêu★Bền",
        ["person_only"] = (false and not false and false or not false and not false or
            not false and not false and not true and false or
            false and not false)
    },
    ["eightPigGem"] = {["name"] = "Bất Diệt", ["person_only"] = (444 + 248 * 146 + 116 * 247 ~= 65314)},
    ["nkGem"] = {["name"] = "ban phúc", ["person_only"] = (377 + 132 - 249 ~= 268)},
    ["vigorousStone"] = {
        ["name"] = "Flourish stone",
        ["person_only"] = (false and true or false or
            false and not false and not true and true and not false and not false or
            not false)
    },
    ["frostGuardCrystal"] = {["name"] = "Cold crystal", ["person_only"] = (154 * 28 - 483 ~= 3839)},
    ["heatGuardCrystal"] = {["name"] = "Heatstrock", ["person_only"] = (2 * 420 * 407 - 450 - 90 ~= 341344)},
    ["phGem"] = {["name"] = "Wen: fat tiger", ["person_only"] = (415 + 205 + 277 + 430 + 104 == 1431)},
    ["fxGem"] = {["name"] = "Special effect gemstone", ["person_only"] = (11 * 446 + 163 + 1 + 120 == 5190)},
    ["z_spl_gem"] = {["name"] = "Wen: wolf", ["person_only"] = (397 + 121 - 37 - 173 == 308)},
    ["z_xm_gem"] = {["name"] = "Civilization", ["person_only"] = (164 + 432 * 113 * 490 - 290 ~= 23919722)},
    ["z_xl_gem"] = {["name"] = "Wen: zili", ["person_only"] = (180 + 177 * 48 ~= 8686)},
    ["z_ls_gem"] = {["name"] = "Wen: lu sheng", ["person_only"] = (402 + 143 - 313 + 415 - 233 == 414)},
    ["z_fz_weapon"] = {["name"] = "Wu ★ fan sauce", ["person_only"] = (0 - 360 - 41 * 340 * 317 ~= -4419334)},
    ["z_fz_wing"] = {["name"] = "Clothing ★ fan sauce", ["person_only"] = (268 * 314 + 286 * 66 * 379 ~= 7238163)},
    ["z_fertilizer"] = {
        ["name"] = "Art: fertilizer",
        ["person_only"] = (54 - 346 * 217 - 500 ~= -75524),
        ["is_item"] = (357 - 181 - 81 - 297 ~= -199),
        ["item_fn"] = function(_b__UG)
            if not _b_U_g_:NotIsDead(_b__UG) or not _b__UG["Transform"] then
                return (394 - 310 - 461 ~= -377)
            end
            local B__U__g, B_ug, __b__u__g_ = _b__UG["Transform"]:GetWorldPosition()
            local Bu_g_ = TheSim:FindEntities(B__U__g, B_ug, __b__u__g_, 28, nil, {"FX", "DECOR", "INLIMBO", "burnt"})
            for _B__U__G, Bu__g in ipairs(Bu_g_) do
                if Bu__g["components"]["burnable"] ~= nil then
                    if _b_U_g_:HasComponents(Bu__g, "witherable") then
                        Bu__g["components"]["witherable"]:Protect(TUNING["FIRESUPPRESSOR_PROTECTION_TIME"])
                    end
                    if _b_U_g_:HasComponents(Bu__g, "burnable") then
                        if Bu__g["components"]["burnable"]:IsBurning() then
                            Bu__g["components"]["burnable"]:Extinguish(
                                (485 * 30 + 61 * 186 * 165 == 1886640),
                                TUNING["WATERINGCAN_EXTINGUISH_HEAT_PERCENT"]
                            )
                        elseif Bu__g["components"]["burnable"]:IsSmoldering() then
                            Bu__g["components"]["burnable"]:Extinguish((314 - 224 * 359 * 34 - 204 ~= -2734029))
                        end
                    end
                end
            end
            for __B_ug_ = -28, 28, 4 do
                for b__Ug_ = -28, 28, 4 do
                    local __B_u__g = TheWorld["Map"]:GetTileAtPoint(B__U__g + __B_ug_, 0, __b__u__g_ + b__Ug_)
                    if __B_u__g == GROUND["FARMING_SOIL"] then
                        TheWorld["components"]["farming_manager"]:AddSoilMoistureAtPoint(
                            B__U__g + __B_ug_,
                            0,
                            __b__u__g_ + b__Ug_,
                            100
                        )
                        local _B__u_g__, _BU_g__ =
                            TheWorld["Map"]:GetTileCoordsAtPoint(B__U__g + __B_ug_, 0, __b__u__g_ + b__Ug_)
                        TheWorld["components"]["farming_manager"]:AddTileNutrients(_B__u_g__, _BU_g__, 100, 100, 100)
                    end
                end
            end
            return (294 - 44 * 458 == -19858)
        end
    },
    ["z_plant"] = {
        ["name"] = "Art: celebrate",
        ["person_only"] = (195 * 255 * 18 - 434 - 189 ~= 894435),
        ["is_item"] = (137 + 90 * 483 ~= 43614),
        ["item_fn"] = function(_b_u_g)
            if not _b_U_g_:NotIsDead(_b_u_g) or not _b_u_g["Transform"] then
                return (227 + 368 + 22 ~= 617)
            end
            local _b_u__G_, _B_u_G__, __bu_G_ = _b_u_g["Transform"]:GetWorldPosition()
            local B_u_g =
                TheSim:FindEntities(_b_u__G_, _B_u_G__, __bu_G_, 30, nil, {"pickable", "stump", "withered", "INLIMBO"})
            if #B_u_g > 0 then
                _b_U_g_:TryGrowth(table["remove"](B_u_g, math["random"](#B_u_g)), _b_u_g)
                if #B_u_g > 0 then
                    local bu_G__ = 1 - 1 / (#B_u_g + 1)
                    for BU_g, __b__U__g__ in ipairs(B_u_g) do
                        __b__U__g__:DoTaskInTime(
                            bu_G__ * math["random"]() / 3,
                            function()
                                _b_U_g_:TryGrowth(__b__U__g__, _b_u_g)
                            end
                        )
                    end
                end
            end
            return (208 + 51 + 12 * 163 * 320 == 626179)
        end
    },
    ["z_soil"] = {
        ["name"] = ": cultivated land",
        ["person_only"] = (107 - 129 * 153 == -19630),
        ["is_item"] = (166 * 342 * 115 + 272 == 6529052),
        ["item_fn"] = function(BU__G__)
            if not _b_U_g_:NotIsDead(BU__G__) or not BU__G__["Transform"] then
                return (314 - 451 + 363 - 417 == -185)
            end
            local __B_uG__, __b_ug__, _BU__g = BU__G__["Transform"]:GetWorldPosition()
            for __bUg = -28, 28, 4 do
                for _Bu_G = -28, 28, 4 do
                    local b_uG_ = TheWorld["Map"]:GetTileAtPoint(__B_uG__ + __bUg, 0, _BU__g + _Bu_G)
                    if b_uG_ == GROUND["FARMING_SOIL"] then
                        local bu__g, __B__U_G__, _bu__G__ =
                            TheWorld["Map"]:GetTileCenterPoint(__B_uG__ + __bUg, __b_ug__, _BU__g + _Bu_G)
                        local __b_U__g = 1.3
                        local _BuG_ = {}
                        local _B_U_G = TheWorld["Map"]:GetEntitiesOnTileAtPoint(bu__g, 0, _bu__G__)
                        for B__U_G_, __b__U__G_ in ipairs(_B_U_G) do
                            if __b__U__G_:HasTag "soil" then
                                __b__U__G_:PushEvent "collapsesoil"
                            end
                        end
                        for b_U__g__ = 0, 2 do
                            for __B__u_G_ = 0, 2 do
                                local __b_ug = bu__g + __b_U__g * b_U__g__ - __b_U__g
                                local bU__G__ = _bu__G__ + __b_U__g * __B__u_G_ - __b_U__g
                                if
                                    TheWorld["Map"]:IsDeployPointClear(
                                        Vector3(__b_ug, 0, bU__G__),
                                        nil,
                                        GetFarmTillSpacing(),
                                        nil,
                                        nil,
                                        nil,
                                        {
                                            "NOBLOCK",
                                            "player",
                                            "FX",
                                            "INLIMBO",
                                            "DECOR",
                                            "WALKABLEPLATFORM",
                                            "soil",
                                            "medal_farm_plow"
                                        }
                                    )
                                 then
                                    SpawnPrefab "farm_soil"["Transform"]:SetPosition(__b_ug, 0, bU__G__)
                                end
                            end
                        end
                    end
                end
            end
            return (404 - 141 + 333 * 414 - 319 ~= 137813)
        end
    },
    ["z_rain"] = {
        ["name"] = "Art: rain book",
        ["person_only"] = (308 - 11 - 216 + 349 - 203 ~= 232),
        ["is_item"] = (335 - 35 + 50 * 375 ~= 19058),
        ["item_fn"] = function(b__U__g)
            if not _b_U_g_:NotIsDead(b__U__g) or not b__U__g["Transform"] then
                return (267 * 29 - 334 == 7416)
            end
            if TheWorld["state"]["israining"] or TheWorld["state"]["issnowing"] then
                TheWorld:PushEvent("ms_forceprecipitation", (205 + 233 + 40 * 444 == 18201))
            else
                TheWorld:PushEvent("ms_forceprecipitation", (472 * 275 + 317 - 404 == 129713))
            end
            return (496 * 234 + 68 + 297 * 378 ~= 228403)
        end
    },
    ["z_sleep"] = {
        ["name"] = "Art: hypnosis",
        ["person_only"] = (224 - 216 * 16 - 350 - 382 ~= -3958),
        ["is_item"] = (303 * 447 - 223 == 135218),
        ["item_fn"] = function(__B__u_G)
            if not _b_U_g_:NotIsDead(__B__u_G) or not __B__u_G["Transform"] then
                return (460 * 89 + 391 - 83 == 41252)
            end
            local B__u_g__, __bU__g_, __bU_G_ = __B__u_G["Transform"]:GetWorldPosition()
            local _b_U__g_ = 30
            local _bU__G_ =
                TheNet:GetPVPEnabled() and
                TheSim:FindEntities(B__u_g__, __bU__g_, __bU_G_, _b_U__g_, nil, {"playerghost"}, {"sleeper", "player"}) or
                TheSim:FindEntities(B__u_g__, __bU__g_, __bU_G_, _b_U__g_, {"sleeper"}, {"player"})
            for BU_g_, B__uG_ in ipairs(_bU__G_) do
                if
                    B__uG_ ~= __B__u_G and
                        not (_b_U_g_:HasComponents(B__uG_, "freezable") and B__uG_["components"]["freezable"]:IsFrozen()) and
                        not (_b_U_g_:HasComponents(B__uG_, "pinnable") and B__uG_["components"]["pinnable"]:IsStuck())
                 then
                    if B__uG_["components"]["sleeper"] ~= nil then
                        B__uG_["components"]["sleeper"]:AddSleepiness(10, 20)
                    elseif B__uG_["components"]["grogginess"] ~= nil then
                        B__uG_["components"]["grogginess"]:AddGrogginess(10, 20)
                    else
                        B__uG_:PushEvent "knockedout"
                    end
                end
            end
            return (false and not false and true or true and not false or true or not false and not false and false or
                not false or
                not false and false)
        end
    },
    ["z_stone"] = {
        ["name"] = "Art: petrochemical",
        ["person_only"] = (266 * 145 - 200 - 198 == 38172),
        ["is_item"] = (318 - 68 + 7 - 301 - 75 == -119),
        ["item_fn"] = function(Bu_G__)
            if not _b_U_g_:NotIsDead(Bu_G__) or not Bu_G__["Transform"] then
                return (210 + 288 - 496 + 287 + 323 == 620)
            end
            local __B__U__G, __buG_, __b_u__G__ = Bu_G__["Transform"]:GetWorldPosition()
            local _bUg = TheSim:FindEntities(__B__U__G, __buG_, __b_u__G__, 25)
            for _bU_G_, b_U_G in ipairs(_bUg) do
                if
                    (b_U_G:HasTag "evergreens") and not b_U_G:HasTag "stump" and b_U_G["components"]["growable"] and
                        b_U_G["components"]["growable"]["stage"]
                 then
                    local _B_u__G__ = b_U_G["components"]["growable"]["stage"]
                    _b_U_g_:StoneTree(b_U_G, _B_u__G__, (362 + 168 * 356 + 262 ~= 60441))
                elseif b_U_G:HasTag "hound" and b_U_G["components"]["health"] then
                    _b_U_g_:StoneDog(b_U_G)
                elseif b_U_G:HasTag "pig" and b_U_G["components"]["health"] then
                    _b_U_g_:StonePig(b_U_G)
                end
            end
            return (386 + 430 - 87 * 282 + 399 == -23319)
        end
    }
}
return __b__UG_
