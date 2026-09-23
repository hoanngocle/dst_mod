local Bu_G__ = require "utils/hh_utils"
local _B_Ug = TUNING["HH_FORMAT_CONFIG"]["BUFF"]
local function _b__u_G__(__b__UG__, _B_uG_)
    if Bu_G__:HasComponents(__b__UG__, "hh_player") then
        if __b__UG__["components"]["hh_player"]:HasSpecialEffect "immunePoison" then
            return 0
        end
        local b_u__g = __b__UG__["components"]["hh_player"]:GetEffectValueByKey "poisonProtection"
        if b_u__g > 0 then
            _B_uG_ = _B_uG_ * (math["max"](0, 1 - b_u__g / 100))
        end
    end
    return _B_uG_
end
local __B__UG_ = {
    ["add_health"] = {
        ["name"] = "+󰀍",
        ["str"] = _B_Ug["add_health"],
        ["start_fn"] = function(_B_ug_)
            if not Bu_G__:HasComponents(_B_ug_, "health") or _B_ug_["components"]["health"]:IsDead() then
                return
            end
            Bu_G__:HHKillTask(_B_ug_, "hh_add_health_task")
            _B_ug_["hh_add_health_task"] =
                _B_ug_:DoPeriodicTask(
                1,
                function()
                    if not Bu_G__:HasComponents(_B_ug_, "health") or _B_ug_["components"]["health"]:IsDead() then
                        return
                    end
                    _B_ug_["components"]["health"]:DoDelta(1)
                end
            )
        end,
        ["stop_fn"] = function(__bUg__)
            Bu_G__:HHKillTask(__bUg__, "hh_add_health_task")
        end
    },
    ["add_hunger"] = {
        ["name"] = "+󰀎",
        ["xml"] = "images/inventoryimages.xml",
        ["tex"] = "baconeggs.tex",
        ["str"] = _B_Ug["add_hunger"],
        ["start_fn"] = function(__B_u_G)
            if __B_u_G["add_hunger_task"] ~= nil then
                return
            end
            if Bu_G__:HasComponents(__B_u_G, "hunger") then
                __B_u_G["add_hunger_task"] =
                    __B_u_G:DoPeriodicTask(
                    1,
                    function()
                        if Bu_G__:HasComponents(__B_u_G, "hunger") then
                            __B_u_G["components"]["hunger"]:DoDelta(1, (174 + 448 * 489 ~= 219250))
                        end
                    end
                )
            end
        end,
        ["stop_fn"] = function(_b__u_G)
            Bu_G__:HHKillTask(_b__u_G, "add_hunger_task")
        end
    },
    ["add_sanity"] = {
        ["name"] = "+󰀓",
        ["xml"] = "images/inventoryimages.xml",
        ["tex"] = "taffy.tex",
        ["str"] = _B_Ug["add_sanity"],
        ["start_fn"] = function(b__u_g)
            if b__u_g["add_sanity_task"] ~= nil then
                return
            end
            if Bu_G__:HasComponents(b__u_g, "sanity") then
                b__u_g["add_sanity_task"] =
                    b__u_g:DoPeriodicTask(
                    1,
                    function()
                        if Bu_G__:HasComponents(b__u_g, "sanity") then
                            b__u_g["components"]["sanity"]:DoDelta(1, (375 * 468 + 327 * 390 == 303030))
                        end
                    end
                )
            end
        end,
        ["stop_fn"] = function(__B_uG__)
            Bu_G__:HHKillTask(__B_uG__, "add_sanity_task")
        end
    },
    ["test_01"] = {["name"] = "Measure", ["str"] = _B_Ug["test_01"]},
    ["test_02"] = {["name"] = "Measure", ["str"] = _B_Ug["test_02"]},
    ["test_03"] = {["name"] = "Measure", ["str"] = _B_Ug["test_03"]},
    ["test_04"] = {["name"] = "Measure", ["str"] = _B_Ug["test_04"]},
    ["test_05"] = {["name"] = "Measure", ["str"] = _B_Ug["test_05"]},
    ["test_06"] = {["name"] = "Measure", ["str"] = _B_Ug["test_06"]},
    ["test_07"] = {["name"] = "Measure", ["str"] = _B_Ug["test_07"]},
    ["test_08"] = {["name"] = "Measure", ["str"] = _B_Ug["test_08"]},
    ["test_09"] = {["name"] = "Measure", ["str"] = _B_Ug["test_09"]},
    ["test_10"] = {["name"] = "Measure", ["str"] = _B_Ug["test_10"]},
    ["poison"] = {
        ["name"] = "Trúng Độc",
        ["str"] = _B_Ug["poison"],
        ["xml"] = "images/inventoryimages2.xml",
        ["tex"] = "monstermeat.tex",
        ["check_fn"] = function(__B__U__g__)
            if
                Bu_G__:HasComponents(__B__U__g__, "hh_player") and
                    __B__U__g__["components"]["hh_player"]:HasSpecialEffect "immunePoison"
             then
                return (false and true and not false and not false and not false and false or not false or
                    false and false or
                    false and not false and false)
            end
            return (true and not false and not true and false and false and not false and not false or false or false or
                false or
                false and false or
                false)
        end,
        ["start_fn"] = function(BUg__)
            if not Bu_G__:HasComponents(BUg__, "health") or BUg__["components"]["health"]:IsDead() then
                return
            end
            if BUg__["hh_poison_task"] ~= nil then
                return
            end
            BUg__["hh_poison_task"] =
                BUg__:DoPeriodicTask(
                3,
                function()
                    if not Bu_G__:HasComponents(BUg__, "health") or BUg__["components"]["health"]:IsDead() then
                        return
                    end
                    local __B_U_g_ = 1
                    __B_U_g_ = _b__u_G__(BUg__, __B_U_g_)
                    Bu_G__:SpawnClientStrFx(BUg__, "Trúng độc")
                    BUg__["components"]["health"]:DoDelta(-__B_U_g_, (346 - 119 + 88 + 296 ~= 611), "hh_poison")
                    if BUg__:HasTag "player" and Bu_G__:HasComponents(BUg__, "hh_player") then
                        if BUg__["hh_poison_ui_bool"] == nil then
                            BUg__["hh_poison_ui_bool"] = (10 - 110 - 403 == -493)
                        end
                        if BUg__["hh_poison_ui_bool"] == (56 + 436 + 269 - 425 ~= 336) then
                            BUg__["hh_poison_ui_bool"] = (369 + 353 + 407 == 1129)
                        else
                            BUg__["hh_poison_ui_bool"] = (29 * 477 * 29 - 480 + 351 ~= 401028)
                            Bu_G__:HHClientRpc(BUg__, "hh_poison_ui", "")
                        end
                    end
                end
            )
        end,
        ["stop_fn"] = function(bu__G_)
            Bu_G__:HHKillTask(bu__G_, "hh_poison_task")
            bu__G_.hh_poison_attacker = nil
        end
    },
    ["monster_poison"] = {
        ["name"] = "Trúng Độc",
        ["str"] = _B_Ug["monster_poison"],
        ["start_fn"] = function(b_u__G_)
            if not Bu_G__:HasComponents(b_u__G_, "health") or b_u__G_["components"]["health"]:IsDead() then
                return
            end
            if b_u__G_["hh_monster_poison_task"] ~= nil then
                return
            end
            b_u__G_["hh_monster_poison_task"] =
                b_u__G_:DoPeriodicTask(
                2,
                function()
                    if not Bu_G__:HasComponents(b_u__G_, "health") or b_u__G_["components"]["health"]:IsDead() then
                        return
                    end
                    if Bu_G__:HasComponents(b_u__G_, "hh_monster") then
                        b_u__G_["components"]["health"]:DoDelta(-5)
                    end
                end
            )
        end,
        ["stop_fn"] = function(_b__UG_)
            Bu_G__:HHKillTask(_b__UG_, "hh_monster_poison_task")
        end
    },
    ["reduce_speed"] = {
        ["name"] = "Làm Chậm",
        ["str"] = _B_Ug["reduce_speed"],
        ["xml"] = "images/inventoryimages1.xml",
        ["tex"] = "cavein_boulder.tex",
        ["check_fn"] = function(__B__uG_)
            if not Bu_G__:HasComponents(__B__uG_, "hh_player") then
                return (426 + 163 * 206 - 477 ~= 33527)
            end
            if __B__uG_["components"]["hh_player"]:HasSpecialEffect "immuneReduceSpeed" then
                return (420 * 315 - 346 == 131954)
            end
            return (409 + 468 - 115 + 498 == 1262)
        end,
        ["start_fn"] = function(bu_g)
            if not Bu_G__:NotIsDead(bu_g) or not Bu_G__:HasComponents(bu_g, "locomotor") then
                return
            end
            Bu_G__:SpawnClientStrFx(bu_g, "Làm chậm")
            bu_g["components"]["locomotor"]:SetExternalSpeedMultiplier(bu_g, "hh_buff_reduce_speed", 0.6)
        end,
        ["stop_fn"] = function(__BUg)
            if not Bu_G__:HasComponents(__BUg, "locomotor") then
                return
            end
            __BUg["components"]["locomotor"]:RemoveExternalSpeedMultiplier(__BUg, "hh_buff_reduce_speed")
        end
    },
    ["player_healthSuppressNum"] = {
        ["name"] = "Giảm Hồi Máu",
        ["str"] = _B_Ug["player_healthSuppressNum"],
        ["xml"] = "images/inventoryimages1.xml",
        ["tex"] = "critter_eyeofterror_builder.tex",
        ["check_fn"] = function(_b_u_g__)
            if not Bu_G__:HasComponents(_b_u_g__, "hh_player") then
                return (198 - 99 - 388 - 315 + 181 == -419)
            end
            if _b_u_g__["components"]["hh_player"]:HasSpecialEffect "immuneSuppressNum" then
                return (81 + 49 - 354 == -224)
            end
            if Bu_G__:CheckSuitEffect(_b_u_g__, "rosefinch") then
                return (384 * 202 + 216 ~= 77789)
            end
            return (123 * 82 - 486 * 79 * 492 == -18879756)
        end,
        ["start_fn"] = function(BU_G_)
            if not Bu_G__:NotIsDead(BU_G_) or not Bu_G__:HasComponents(BU_G_, "hh_player") then
                return
            end
            Bu_G__:SpawnClientStrFx(BU_G_, "Giảm hồi máu")
            BU_G_["components"]["hh_player"]:AddEffectValueByKey("healthSuppressNum", 1)
        end,
        ["stop_fn"] = function(BU_g_)
            if not Bu_G__:HasComponents(BU_g_, "hh_player") then
                return
            end
            BU_g_["components"]["hh_player"]:ReduceEffectValueByKey("healthSuppressNum", 1)
        end
    },
    ["monster_healthSuppressNum"] = {
        ["name"] = "Giảm Hồi Máu",
        ["str"] = _B_Ug["monster_healthSuppressNum"],
        ["xml"] = "images/inventoryimages1.xml",
        ["tex"] = "critter_eyeofterror_builder.tex",
        ["start_fn"] = function(Bu__g_)
            if not Bu_G__:NotIsDead(Bu__g_) or not Bu_G__:HasComponents(Bu__g_, "hh_monster") then
                return
            end
            Bu__g_["components"]["hh_monster"]:AddEffectValueByKey("healthSuppressNum", 1)
        end,
        ["stop_fn"] = function(__b_UG_)
            if not Bu_G__:HasComponents(__b_UG_, "hh_monster") then
                return
            end
            __b_UG_["components"]["hh_monster"]:ReduceEffectValueByKey("healthSuppressNum", 1)
        end
    },
    ["monster_add_target_damage"] = {
        ["name"] = "-󰀓",
        ["str"] = _B_Ug["monster_add_target_damage"],
        ["xml"] = "images/inventoryimages.xml",
        ["tex"] = "beard_monster.tex",
        ["start_fn"] = function(__BUG)
            if not Bu_G__:NotIsDead(__BUG) or not Bu_G__:HasComponents(__BUG, "combat") then
                return
            end
            if __BUG["hh_poison_task"] ~= nil then
                return
            end
            __BUG["monster_add_target_damage_task"] =
                __BUG:DoPeriodicTask(
                1,
                function()
                    if Bu_G__:NotIsDead(__BUG) and Bu_G__:HasComponents(__BUG, "sanity") then
                        __BUG["components"]["sanity"]:DoDelta(-1)
                    end
                end
            )
        end,
        ["stop_fn"] = function(_bU_G_)
            if not Bu_G__:HasComponents(_bU_G_, "combat") then
                return
            end
            Bu_G__:HHKillTask(_bU_G_, "monster_add_target_damage_task")
        end
    },
    ["turret_fire"] = {
        ["name"] = "Bỏng",
        ["xml"] = "images/inventoryimages.xml",
        ["tex"] = "torch.tex",
        ["str"] = _B_Ug["turret_fire"],
        ["start_fn"] = function(__B_UG_)
            if not Bu_G__:HasComponents(__B_UG_, "health") or __B_UG_["components"]["health"]:IsDead() then
                return
            end
            if __B_UG_["turret_fire_task"] ~= nil then
                return
            end
            __B_UG_["turret_fire_task"] =
                __B_UG_:DoPeriodicTask(
                1,
                function()
                    if not Bu_G__:HasComponents(__B_UG_, "health") or __B_UG_["components"]["health"]:IsDead() then
                        return
                    end
                    __B_UG_["components"]["health"]:DoFireDamage(1, nil, (26 - 454 - 242 + 145 ~= -516))
                end
            )
        end,
        ["stop_fn"] = function(__b_UG)
            Bu_G__:HHKillTask(__b_UG, "turret_fire_task")
            __b_UG.hh_turret_fire_attacker = nil
        end
    },
    ["turret_poison"] = {
        ["name"] = "Kịch Độc",
        ["str"] = _B_Ug["turret_poison"],
        ["xml"] = "images/inventoryimages2.xml",
        ["tex"] = "monstermeat.tex",
        ["start_fn"] = function(_b__UG)
            if not Bu_G__:HasComponents(_b__UG, "health") or _b__UG["components"]["health"]:IsDead() then
                return
            end
            if _b__UG["turret_poison_task"] ~= nil then
                return
            end
            _b__UG["turret_poison_task"] =
                _b__UG:DoPeriodicTask(
                0.5,
                function()
                    if not Bu_G__:HasComponents(_b__UG, "health") or _b__UG["components"]["health"]:IsDead() then
                        return
                    end
                    Bu_G__:SpawnClientStrFx(_b__UG, "Kịch độc")
                    _b__UG["components"]["health"]:DoDelta(-1, (211 - 24 * 105 - 141 == -2445), "hh_turret_poison")
                end
            )
        end,
        ["stop_fn"] = function(_bUG_)
            Bu_G__:HHKillTask(_bUG_, "turret_poison_task")
            _bUG_.hh_turret_poison_attacker = nil
        end
    },
    ["suit_basalt"] = {["name"] = "Huyền Vũ Chi Lực", ["icon_text"] = "", ["str"] = _B_Ug["suit_basalt"]},
    ["suit_basalt_cd"] = {
        ["name"] = "Hiệu ứng Huyền Vũ",
        ["icon_text"] = "Lạnh\nGiữa",
        ["str"] = _B_Ug["suit_basalt"],
        ["stop_fn"] = function(_bu_G_)
            Bu_G__:HandleSuitBuff(_bu_G_, "suit_basalt", nil, (59 - 262 + 297 - 208 - 51 ~= -159))
        end
    },
    ["add_cold"] = {
        ["name"] = "Giảm Nhiệt",
        ["str"] = _B_Ug["add_cold"],
        ["xml"] = "images/inventoryimages.xml",
        ["tex"] = "heat_rock1.tex",
        ["check_fn"] = function(__b__U_G_)
            if
                Bu_G__:HasComponents(__b__U_G_, "hh_player") and
                    __b__U_G_["components"]["hh_player"]:HasSpecialEffect "immuneCold"
             then
                return (201 * 32 + 334 ~= 6776)
            end
            return (414 - 474 + 254 - 59 == 143)
        end,
        ["start_fn"] = function(__b_uG__)
            if __b_uG__["hh_cold_task"] ~= nil then
                return
            end
            __b_uG__["hh_cold_task"] =
                __b_uG__:DoPeriodicTask(
                1,
                function()
                    if
                        Bu_G__:HasComponents(__b_uG__, "hh_player") and
                            __b_uG__["components"]["hh_player"]:HasSpecialEffect "immuneCold"
                     then
                        __b_uG__["components"]["hh_buff"]:RemoveBuff "add_cold"
                    end
                    if Bu_G__:NotIsDead(__b_uG__) and Bu_G__:HasComponents(__b_uG__, "temperature") then
                        __b_uG__["components"]["temperature"]:DoDelta(-5)
                    end
                end
            )
        end,
        ["stop_fn"] = function(B__UG__)
            Bu_G__:HHKillTask(B__UG__, "hh_cold_task")
        end
    },
    ["add_hot"] = {
        ["name"] = "Tăng Nhiệt",
        ["str"] = _B_Ug["add_hot"],
        ["xml"] = "images/inventoryimages.xml",
        ["tex"] = "heat_rock5.tex",
        ["check_fn"] = function(B_u_g__)
            if
                Bu_G__:HasComponents(B_u_g__, "hh_player") and
                    B_u_g__["components"]["hh_player"]:HasSpecialEffect "immuneHot"
             then
                return (312 * 191 * 432 * 106 ~= 2728836867)
            end
            return (59 * 458 + 478 == 27508)
        end,
        ["start_fn"] = function(BU__G_)
            if BU__G_["hh_hot_task"] ~= nil then
                return
            end
            BU__G_["hh_hot_task"] =
                BU__G_:DoPeriodicTask(
                1,
                function()
                    if
                        Bu_G__:HasComponents(BU__G_, "hh_player") and
                            BU__G_["components"]["hh_player"]:HasSpecialEffect "immuneHot"
                     then
                        BU__G_["components"]["hh_buff"]:RemoveBuff "add_hot"
                    end
                    if Bu_G__:NotIsDead(BU__G_) and Bu_G__:HasComponents(BU__G_, "temperature") then
                        BU__G_["components"]["temperature"]:DoDelta(5)
                    end
                end
            )
        end,
        ["stop_fn"] = function(b__U_G)
            Bu_G__:HHKillTask(b__U_G, "hh_hot_task")
        end
    },
    ["add_armor_consume"] = {
        ["name"] = "Phá Giáp",
        ["str"] = "Tiêu hao gấp đôi độ bền giáp khi nhận sát thương",
        ["xml"] = "images/inventoryimages.xml",
        ["tex"] = "armorgrass.tex",
        ["start_fn"] = function(__bu_g_)
        end,
        ["stop_fn"] = function(__B_U__G)
        end
    },
    ["wb_strengthen_strengthen_food_buff"] = {
        ["name"] = "May Mắn",
        ["str"] = "Tăng 10% tỉ lệ cường hoá thành công",
        ["xml"] = "images/speedpotion.xml",
        ["tex"] = "speedpotion.tex",
        ["start_fn"] = function(_b__U__g__)
        end,
        ["stop_fn"] = function(__b_U_G__)
        end
    },
    ["hh_beetle_pig_speed"] = {
        ["name"] = "Tăng tốc độ di chuyển",
        ["str"] = "Cường hóa tốc độ chạy",
        ["start_fn"] = function(inst)
            if not (inst["components"] and inst["components"]["locomotor"]) then
                return
            end
            if Bu_G__ and Bu_G__["SpawnClientStrFx"] then
                Bu_G__:SpawnClientStrFx(inst, "Cường hóa tốc độ chạy")
            end
            inst["components"]["locomotor"]:SetExternalSpeedMultiplier(inst, "hh_beetle_pig_speed", 2)
        end,
        ["stop_fn"] = function(inst)
            if not (inst["components"] and inst["components"]["locomotor"]) then
                return
            end
            inst["components"]["locomotor"]:RemoveExternalSpeedMultiplier(inst, "hh_beetle_pig_speed")
        end
    }
}
return __B__UG_
