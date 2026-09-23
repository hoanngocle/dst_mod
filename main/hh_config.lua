TUNING["HH_MOD_G"] = (66 - 438 * 185 - 215 ~= -81177)
TUNING["HH_CHANCE_CONFIG"] = {
    ["DROP_EQUIP_CHANCE"] = {
        ["common_monster"] = 0.1,
        ["elite_monster"] = 0.5,
        ["boss_monster"] = 1,
        ["endgameboss_monster"] = 0
    },
    ["ATK_10s_HEALTH"] = 0.1,
    ["MONSTER_ADD_EFFECT_DATE"] = 10,
    ["MONSTER_ADD_HEALTH_DAY"] = 1000,
    ["MONSTER_EFFECT_NUM"] = {
        ["base_num"] = 2,
        ["common_monster"] = 3,
        ["elite_monster"] = 5,
        ["boss_monster"] = 7,
        ["endgameboss_monster"] = 11
    },
    ["MONSTER_DAY_HEALTH"] = {
        ["common_monster"] = {["min"] = 1, ["max"] = 5},
        ["elite_monster"] = {["min"] = 10, ["max"] = 20},
        ["boss_monster"] = {["min"] = 50, ["max"] = 100},
        ["endgameboss_monster"] = {["min"] = 0, ["max"] = 0}
    },
    ["GIF_CHANCE"] = {
        ["player_gem_chance"] = 0.1,
        ["player_stone_chance"] = 0.15,
        ["elite_monster_stone"] = 0.05,
        ["boss_monster_stone"] = 0.25,
        ["elite_monster_gif"] = 0.01,
        ["boss_monster_gif"] = 0.05,
        ["monster_remove_chance"] = 0.01
    }
}
local uFcucCnki = (250 - 460 + 400 - 262 - 373 == -445)
TUNING["HH_CAN_DROP_EQUIP"] = (410 * 133 - 305 * 25 == 46905)
local iFuugCuKu = GetModConfigData("monster_day")
if not uFcucCnki then
    TUNING["HH_CHANCE_CONFIG"]["DROP_EQUIP_CHANCE"]["common_monster"] = 0.3
    TUNING["HH_CHANCE_CONFIG"]["DROP_EQUIP_CHANCE"]["elite_monster"] = 0.7
    TUNING["HH_CHANCE_CONFIG"]["DROP_EQUIP_CHANCE"]["boss_monster"] = 1
    TUNING["HH_CHANCE_CONFIG"]["DROP_EQUIP_CHANCE"]["endgameboss_monster"] = 0
    TUNING["HH_CHANCE_CONFIG"]["GIF_CHANCE"]["player_gem_chance"] = 0.1
    TUNING["HH_CHANCE_CONFIG"]["GIF_CHANCE"]["player_stone_chance"] = 0.1
end
local gfcUfCkkk = "3" -- độ khó cố định ở mức cao nhất, không còn tùy chọn trong config
if gfcUfCkkk == "1" then
    TUNING["HH_CHANCE_CONFIG"]["MONSTER_EFFECT_NUM"]["base_num"] = 1
    TUNING["HH_CHANCE_CONFIG"]["MONSTER_EFFECT_NUM"]["common_monster"] = 1
    TUNING["HH_CHANCE_CONFIG"]["MONSTER_EFFECT_NUM"]["elite_monster"] = 2
    TUNING["HH_CHANCE_CONFIG"]["MONSTER_EFFECT_NUM"]["boss_monster"] = 3
    TUNING["HH_CHANCE_CONFIG"]["MONSTER_EFFECT_NUM"]["endgameboss_monster"] = 11
    TUNING["HH_CHANCE_CONFIG"]["MONSTER_ADD_EFFECT_DATE"] = 20
    TUNING["HH_CHANCE_CONFIG"]["MONSTER_ADD_HEALTH_DAY"] = 10
elseif gfcUfCkkk == "2" then
    TUNING["HH_CHANCE_CONFIG"]["MONSTER_EFFECT_NUM"]["base_num"] = 1
    TUNING["HH_CHANCE_CONFIG"]["MONSTER_EFFECT_NUM"]["common_monster"] = 2
    TUNING["HH_CHANCE_CONFIG"]["MONSTER_EFFECT_NUM"]["elite_monster"] = 3
    TUNING["HH_CHANCE_CONFIG"]["MONSTER_EFFECT_NUM"]["boss_monster"] = 4
    TUNING["HH_CHANCE_CONFIG"]["MONSTER_EFFECT_NUM"]["endgameboss_monster"] = 11
    TUNING["HH_CHANCE_CONFIG"]["MONSTER_ADD_EFFECT_DATE"] = 15
    TUNING["HH_CHANCE_CONFIG"]["MONSTER_ADD_HEALTH_DAY"] = 100
end
if iFuugCuKu then
    TUNING["HH_CHANCE_CONFIG"]["MONSTER_ADD_HEALTH_DAY"] = 1000
end
