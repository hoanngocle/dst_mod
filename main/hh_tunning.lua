local gFnunCkKf = require("utils/hh_utils")
TUNING["HH_ATK_SPEED_BOOL"] = (70 - 94 + 4 - 356 + 408 ~= 39)
TUNING["HH_FORMAT_CONFIG"] = {
    ["BUFF"] = {
        ["add_health"] = "+1 máu/s",
        ["add_hunger"] = "+1 no/s",
        ["add_sanity"] = "+1 não/s",
        ["poison"] = "-1 máu/3s",
        ["monster_poison"] = "-5 máu/2s",
        ["reduce_speed"] = "làm chậm 40%",
        ["player_healthSuppressNum"] = "hiệu quả hồi máu -90%",
        ["monster_healthSuppressNum"] = "hiệu quả hồi máu -90%",
        ["turret_fire"] = "gây 1 ST lửa/s",
        ["turret_poison"] = "gây 2 ST độc/s",
        ["monster_add_target_damage"] = "-1 não/s",
        ["add_cold"] = "-5ºC/s",
        ["add_hot"] = "+5ºC/s",
        ["test_01"] = "",
        ["test_02"] = "",
        ["test_03"] = "",
        ["test_04"] = "",
        ["test_05"] = "",
        ["test_06"] = "",
        ["test_07"] = "",
        ["test_08"] = "",
        ["test_09"] = "",
        ["test_10"] = "",
    },
    ["EQUIP_EFFECT"] = {
        ["restore_use_10s_1use"] = "hồi 1 độ bền/10s",
        ["restore_use_5s_1use"] = "hồi 1 độ bền/5s",
        ["restore_use_3s_1use"] = "hồi 1 độ bền/1s",
        ["restore_use_1s_2_percent"] = "hồi 2% độ bền/s",
        ["add_max_use"] = "tăng %s độ bền",
        ["add_max_use_armor_01"] = "tăng %s độ bền giáp",
        ["add_max_use_armor_02"] = "tăng %s độ bền giáp",
        ["add_max_use_armor_03"] = "tăng %s độ bền giáp",
        ["reduce_damage"] = "giảm %s%% ST nhận vào (tổng tối đa 80%%)",
        ["true_damage"] = "%s%% sát thương đòn chính bỏ qua giáp (tổng tối đa 40%%)",
        ["add_damage_small"] = "tăng %s%% sát thương đòn chính",
        ["add_damage_med"] = "tăng %s%% sát thương đòn chính",
        ["add_damage_big"] = "tăng %s%% sát thương đòn chính",
        ["atk_add_poison"] = "tấn công có %s%% hạ độc; tối đa 5 tầng\n20%% ST đòn đánh mỗi tầng/2s trong 10s",
        ["atk_add_freeze"] = "tấn công có %s%% đóng băng 2s\ntrùm bị chậm 20%% trong 2s; hồi 5s",
        ["blood_outburst"] = "ST càng to khi máu càng thấp\n(tối đa: 50% ST)",
        ["spirit_fade"] = "ST càng to khi não càng thấp\n(tối đa: 50% ST)",
        ["hunger_assault"] = "ST càng to khi càng đói\n(tối đa: 50% ST)",
        ["add_extra_damage_percent"] = "tăng %s%% ST",
        ["add_critical_hit_rate"] = "tăng %s%% chí mạng và ST chí mạng",
        ["reduce_fire_damage"] = "giảm %s%% ST lửa",
        ["atk_blood_suck"] = "%s%% ST gây ra hồi vào máu khi tấn công",
        ["add_speed"] = "tăng %s%% tốc chạy",
        ["add_immune_cold"] = "miễn nhiễm lạnh cóng",
        ["add_immune_hot"] = "miễn nhiễm quá nhiệt",
        ["add_max_health_01"] = "tăng %s máu tối đa",
        ["add_max_health_02"] = "tăng %s máu tối đa",
        ["add_max_health_03"] = "tăng %s máu tối đa",
        ["add_max_health_04"] = "tăng %s máu tối đa",
        ["add_poisonProtection"] = "kháng độc %s%%",
        ["add_immune_poison"] = "miễn nhiễm trúng độc",
        ["add_immune_freeze"] = "miễn nhiễm đóng băng",
        ["attack_fire_impact"] = "tấn công có %% tạo 5 xích diễm",
        ["follow_damage"] = "tăng %s ST cho quái đi theo",
        ["follow_reduce_damage"] = "giảm %s ST nhận vào cho quái đi theo",
        ["more_damage_30_150"] = "30%% gây %s%% ST đòn chính",
        ["more_damage_20_200"] = "20%% gây %s%% ST đòn chính",
        ["more_damage_15_300"] = "10%% gây %s%% ST đòn chính",
        ["more_damage_8_500"] = "8%% gây %s%% ST đòn chính",
        ["health_suppress_num"] = "có %s%% gây Giảm Hồi Máu khi tấn công",
        ["shadow_camp"] = "sinh vật bóng tối (shadow) ko tấn công",
        ["moon_camp"] = "sinh vật vô định (gestalt) ko tấn công",
        ["immunity_moisture"] = "miễn nhiễm ẩm ướt",
        ["add_light"] = "có thể phát sáng",
        ["fast_act"] = "tăng tốc độ thu hoạch, xây dựng,\ntrao đổi, chế tạo và nướng đồ ăn",
        ["work_speed"] = "tăng tốc độ khai thác tài nguyên",
        ["armor_reduce_amount"] = "tiêu hao độ bền giáp giảm %s%%",
        ["armor_immune_amount"] = "giáp bền vĩnh cửu",
        ["porter"] = "miễn nhiễm làm chậm",
        ["immune_debuff"] = "miễn nhiễm quá nhiệt, lạnh cóng\nvà ẩm ướt",
        ["immune_debuff_2"] = "miễn nhiễm băng, độc\nlàm chậm và rủ ngủ",
        ["special_zqrf"] = "miễn nhiễm quá nhiệt, lạnh cóng,\nbăng, độc, ướt, chậm, ru ngủ",
        ["special_bhtg"] = "tăng %s%% sát thương đòn chính\nTrọng Thương: 3%% máu hiện tại; trùm 1%%",
        ["special_xwsh"] = "Giảm Hồi Máu mục tiêu, %s%% ST hợp lệ\nhồi máu khi tấn công",
        ["special_sgsy"] = "giảm 80%% ST nhận vào\nMiễn Giảm Hồi Máu",
        ["atk_speed"] = "tăng %s%% tốc đánh",
        ["immune_sleep"] = "miễn nhiễm ru ngủ",
        ["immune_suppress"] = "Miễn Giảm Hồi Máu",
        ["absorb_small"] = "giảm %s%% ST nhận vào",
        ["treasure_poison_freeze"] = "miễn nhiễm trúng độc và đóng băng",
        ["treasure_hot_cold"] = "miễn nhiễm quá nhiệt và lạnh cóng",
        ["z_suit_zqrf"] = "Chu Tước Loan Phụng",
        ["z_suit_xwsh"] = "Huyền Vũ Thủ Hộ",
        ["z_suit_slly"] = "Thanh Long Lăng Vân",
    },
    ["SUIT_CONFIG"] = {
        ["suit_zqrf"] = {["name"] = "Chu Tước Loan Phụng", ["desc"] = "", ["effect_str"] = ""},
    },
    ["GEM_EFFECT"] = {
        ["durableGem"] = " Hồi 1 độ bền mỗi giây",
        ["powerMettleStone"] = " Tăng 10% ST",
        ["strideBead"] = " Tăng 3% tốc chạy",
        ["treasure_fireGem"] = " Tăng 30% sát thương thiêu đốt",
        ["critStrikeStone"] = " Tăng 5% chí mạng",
        ["resistDamageGem"] = " Giảm 5% ST nhận vào",
        ["followCritical"] = " Tăng 10% chí mạng cho quái đi theo",
        ["followDamage"] = " Tăng 15 ST cho quái đi theo",
        ["followArmor"] = " Giảm 5 ST nhận vào cho quái đi theo",
        ["treasure_armor"] = " Hồi 2% độ bền mỗi giây",
        ["treasure_atk"] = " Tăng 15% sát thương đòn chính",
        ["treasure_bj"] = " Tăng 20% chí mạng",
        ["elementBead"] = " Miễn nhiễm quá nhiệt, lạnh cóng,\nđóng băng, độc, ướt, chậm; Miễn Giảm Hồi Máu;\nnhìn xuyên Bão Cát và Bão Mặt Trăng",
        ["eightPigGem"] = " Miễn nhiễm quá nhiệt, lạnh cóng,\nđóng băng, độc, ướt, chậm; Miễn Giảm Hồi Máu",
        ["baconOmeletteBlessArmor"] = " Tăng 1000 độ bền vĩnh viễn, hồi độ bền siêu nhanh",
        ["baconOmeletteBlessAtk"] = " Tăng 20% sát thương đòn chính",
        ["baconOmeletteBlessCritical"] = " Tăng 40% tỉ lệ chí mạng",
        ["baconOmeletteTrueDamage"] = " 20% sát thương đòn chính bỏ qua giáp",
        ["baconOmeletteSpeed"] = " Tăng 6% tốc độ di chuyển",
        ["baconOmeletteAOE"] = " Đòn đánh gây 20% sát thương lan",
        ["baconOmeletteDodge"] = " Có 15% tỉ lệ né toàn bộ sát thương",
        ["baconOmeletteKill"] = " Sát thương kết liễu quái vật (Trừ Boss) dưới 15% máu",
        ["baconOmeletteFire"] = " Tăng 50% sát thương thiêu đốt",
        ["nkGem"] = " Ban phúc",
        ["phGem"] = " Hiệu ứng văn bản???",
        ["fxGem"] = " Hiệu ứng văn bản???"
    },
    ["MONSTER_CONFIG"] = {
        ["addMaxHealthNum"] = " Tăng %s máu tối đa",
        ["addMaxHealthPercent"] = " Tăng %s%% máu tối đa",
        ["addComDamageNum"] = " Tăng %s ST",
        ["addComDamagePercent"] = " Tăng %s%% ST",
        ["atkAddPoison"] = " Có %s%% hạ độc mục tiêu",
        ["hitAddPoison"] = " Có %s%% hạ độc kẻ tấn công",
        ["atkChanceAddFreeze"] = " Có %s%% đóng băng mục tiêu",
        ["hitChanceAddFreeze"] = " Có %s%% đóng băng kẻ tấn công",
        ["atkChanceReduceSpeed"] = " Có %s%% làm chậm mục tiêu",
        ["hitChanceReduceSpeed"] = " Có %s%% làm chậm kẻ tấn công",
        ["addSpeedPercent"] = " Tăng %s%% tốc chạy",
        ["atkBlood"] = " Tấn công hút %s%% máu",
        ["addCriticalHitRate"] = " Tăng %s%% chí mạng +50%% ST chí mạng",
        ["bossAddCriticalHitRate"] = " Tăng %s%% chí mạng +120%% ST chí mạng",
        ["addReduceAttackedDamage"] = " Giảm %s ST nhận vào",
        ["addDayDamage"] = " Tăng %s ST vào buổi sáng",
        ["addDuskDamage"] = " Tăng %s ST vào buổi chiều",
        ["addNightDamage"] = " Tăng %s ST vào buổi tối",
        ["addSuppressAddHealth"] = " Có %s%% gây Giảm Hồi Máu mục tiêu",
        ["hitSuppressAddHealth"] = " Có %s%% gây Giảm Hồi Máu kẻ tấn công",
        ["deadAddFreeze"] = " Đóng băng xung quanh khi chết",
        ["deadAddMoisture"] = " Gây ướt xung quanh khi chết",
        ["deadAddExplode"] = " Phát nổ xung quanh khi chết",
        ["deadAddPoison"] = " Hạ độc xung quanh khi chết",
        ["deadAddReduceSpeed"] = " Làm chậm xung quanh khi chết",
        ["iceTurret"] = " Kỹ năng bị động: Hàn Băng Pháo Kích",
        ["fireTurret"] = " Kỹ năng bị động: Hoả Diễm Pháo Kích",
        ["poisonTurret"] = " Kỹ năng bị động: Kịch Độc Pháo Kích",
        ["iceLaser"] = " Kỹ năng chủ động: Lôi Quang Tuyệt Diệt",
        ["addHealth3sNum"] = " Hồi %s máu mỗi 3s",
        ["addHealth5sNum"] = " Hồi %s máu mỗi 5s",
        ["addHealth10sNum"] = " Hồi %s máu mỗi 10s",
        ["addHealth3sPercent"] = " Hồi %s%% máu mỗi 3s",
        ["addTargetDamage"] = " Có %s%% giảm tinh thần mục tiêu trong 30s",
        ["immuneFreeze"] = " Miễn nhiễm hiệu ứng đóng băng",
        ["noHitDamage"] = " Có %s%% vô hiệu sát thương nhận vào",
        ["hitAddMoisture"] = " Có %s%% làm ướt mục tiêu",
        ["addHealthPercent03"] = " Hồi %s%% máu mỗi 3s",
        ["addHealthPercent05"] = " Hồi %s%% máu mỗi 5s",
        ["addHealthPercent10"] = " Hồi %s%% máu mỗi 10s",
        ["hitAddCold"] = " Có %s%% giảm nhiệt mục tiêu trong 30s",
        ["hitAddHot"] = " Có %s%% tăng nhiệt mục tiêu trong 30s",
        ["reduceNightDamage"] = " Giảm %s ST nhận vào buổi tối",
        ["reduceSunlightDamage"] = " Giảm %s ST nhận vào buổi ngày",
        ["reduceAfterglowDamage"] = " Giảm %s ST nhận vào buổi chiều",
        ["atkReduceArmor"] = " Có %s%% phá giáp mục tiêu",
        ["reducePercentDamage"] = " Giảm %s%% ST nhận vào",
        ["immuneTearing"] = " Miễn nhiễm hiệu ứng gây trọng thương",
        ["immuneTrue"] = " Miễn nhiễm hiệu ứng gây xuyên giáp"
    }
}
TUNING["HH_COLOR_CONFIG"] = {
    {["name"] = "黑色", ["color"] = {0, 0, 0}},
    {["name"] = "象牙黑", ["color"] = {41, 36, 33}},
    {["name"] = "灰色", ["color"] = {192, 192, 192}},
    {["name"] = "冷灰", ["color"] = {128, 138, 135}},
    {["name"] = "石板灰", ["color"] = {112, 128, 105}},
    {["name"] = "暖灰色", ["color"] = {128, 128, 105}},
    {["name"] = "白色", ["color"] = {255, 255, 255}},
    {["name"] = "古董白", ["color"] = {250, 235, 0}},
    {["name"] = "天蓝色", ["color"] = {240, 255, 255}},
    {["name"] = "白烟", ["color"] = {245, 245, 245}},
    {["name"] = "白杏仁", ["color"] = {255, 235, 205}},
    {["name"] = "蛋壳色", ["color"] = {252, 230, 201}},
    {["name"] = "花白", ["color"] = {255, 250, 240}},
    {["name"] = "蜜露橙", ["color"] = {240, 255, 240}},
    {["name"] = "象牙白", ["color"] = {250, 255, 240}},
    {["name"] = "亚麻色", ["color"] = {250, 240, 230}},
    {["name"] = "海贝壳色", ["color"] = {255, 245, 238}},
    {["name"] = "雪白", ["color"] = {255, 250, 250}},
    {["name"] = "红色", ["color"] = {255, 0, 0}},
    {["name"] = "砖红", ["color"] = {156, 102, 31}},
    {["name"] = "镉红", ["color"] = {227, 23, 13}},
    {["name"] = "珊瑚色", ["color"] = {255, 127, 80}},
    {["name"] = "耐火砖红", ["color"] = {178, 34, 34}},
    {["name"] = "印度红", ["color"] = {176, 23, 31}},
    {["name"] = "栗色", ["color"] = {176, 48, 96}},
    {["name"] = "粉红", ["color"] = {255, 192, 203}},
    {["name"] = "草莓色", ["color"] = {135, 38, 87}},
    {["name"] = "橙红色", ["color"] = {250, 128, 114}},
    {["name"] = "蕃茄红", ["color"] = {255, 99, 71}},
    {["name"] = "桔红", ["color"] = {255, 69, 0}},
    {["name"] = "黄色", ["color"] = {255, 255, 0}},
    {["name"] = "香蕉色", ["color"] = {227, 207, 87}},
    {["name"] = "镉黄", ["color"] = {255, 153, 18}},
    {["name"] = "金黄色", ["color"] = {255, 215, 0}},
    {["name"] = "黄花色", ["color"] = {218, 165, 105}},
    {["name"] = "橙色", ["color"] = {255, 97, 0}},
    {["name"] = "胡萝卜色", ["color"] = {237, 145, 33}},
    {["name"] = "桔黄", ["color"] = {255, 128, 0}},
    {["name"] = "淡黄色", ["color"] = {245, 222, 179}},
    {["name"] = "棕色", ["color"] = {128, 42, 42}},
    {["name"] = "米色", ["color"] = {163, 148, 128}},
    {["name"] = "锻浓黄土色", ["color"] = {138, 54, 15}},
    {["name"] = "锻棕土色", ["color"] = {135, 51, 36}},
    {["name"] = "黄褐色", ["color"] = {240, 230, 140}},
    {["name"] = "肖贡土色", ["color"] = {199, 97, 20}},
    {["name"] = "标土棕", ["color"] = {115, 74, 18}},
    {["name"] = "乌贼墨棕", ["color"] = {94, 38, 18}},
    {["name"] = "赫色", ["color"] = {160, 82, 45}},
    {["name"] = "马棕色", ["color"] = {139, 69, 19}},
    {["name"] = "沙棕色", ["color"] = {244, 164, 96}},
    {["name"] = "棕褐色", ["color"] = {210, 180, 140}},
    {["name"] = "蓝色", ["color"] = {0, 0, 255}},
    {["name"] = "钴色", ["color"] = {61, 89, 171}},
    {["name"] = "锰蓝", ["color"] = {3, 168, 158}},
    {["name"] = "深蓝色", ["color"] = {25, 25, 112}},
    {["name"] = "孔雀蓝", ["color"] = {51, 161, 201}},
    {["name"] = "土耳其玉色", ["color"] = {0, 199, 140}},
    {["name"] = "浅灰蓝色", ["color"] = {176, 224, 230}},
    {["name"] = "品蓝", ["color"] = {65, 105, 225}},
    {["name"] = "石板蓝", ["color"] = {106, 90, 205}},
    {["name"] = "天蓝", ["color"] = {135, 206, 235}},
    {["name"] = "青色", ["color"] = {0, 255, 255}},
    {["name"] = "绿土", ["color"] = {56, 94, 15}},
    {["name"] = "靛青", ["color"] = {8, 46, 84}},
    {["name"] = "碧绿色", ["color"] = {127, 255, 212}},
    {["name"] = "青绿色", ["color"] = {64, 224, 208}},
    {["name"] = "绿色", ["color"] = {0, 255, 0}},
    {["name"] = "黄绿色", ["color"] = {127, 255, 0}},
    {["name"] = "钴绿色", ["color"] = {61, 145, 64}},
    {["name"] = "翠绿色", ["color"] = {0, 201, 87}},
    {["name"] = "森林绿", ["color"] = {34, 139, 34}},
    {["name"] = "草地绿", ["color"] = {124, 252, 0}},
    {["name"] = "酸橙绿", ["color"] = {50, 205, 50}},
    {["name"] = "薄荷色", ["color"] = {189, 252, 201}},
    {["name"] = "草绿色", ["color"] = {107, 142, 35}},
    {["name"] = "暗绿色", ["color"] = {48, 128, 20}},
    {["name"] = "海绿色", ["color"] = {46, 139, 87}},
    {["name"] = "嫩绿色", ["color"] = {0, 255, 127}},
    {["name"] = "紫色", ["color"] = {160, 32, 240}},
    {["name"] = "紫罗蓝色", ["color"] = {138, 43, 226}},
    {["name"] = "湖紫色", ["color"] = {153, 51, 250}},
    {["name"] = "淡紫色", ["color"] = {218, 112, 214}}
}
TUNING["HH_ICON_CONFIG"] = {
    {
        ["name"] = "无",
        ["xml"] = "images/hh_icon/hh_icon_01.xml",
        ["tex"] = "hh_icon_01.tex",
        ["no_icon"] = (false and not false and not false or false and false and false or false or not true or
            true and not false and not false or
            false)
    },
    {["name"] = "粉色兔子", ["xml"] = "images/hh_icon/hh_icon_01.xml", ["tex"] = "hh_icon_01.tex"},
    {["name"] = "星星", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_favorites.tex"},
    {["name"] = "太阳", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_summer.tex"},
    {["name"] = "锅", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_cooking.tex"},
    {["name"] = "花盆", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_cosmetic.tex"},
    {["name"] = "爱心", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_health.tex"},
    {["name"] = "符号", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_none.tex"},
    {["name"] = "雪花", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_winter.tex"},
    {["name"] = "攻击", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_weapon.tex"},
    {["name"] = "箱子", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_containers.tex"},
    {["name"] = "烟花", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_events.tex"},
    {["name"] = "胡萝卜", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_gardening.tex"},
    {["name"] = "齿轮", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_modded.tex"},
    {["name"] = "火焰", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_fire.tex"},
    {["name"] = "护甲", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_armour.tex"},
    {["name"] = "钓鱼", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_fishing.tex"},
    {["name"] = "伞", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_rain.tex"},
    {["name"] = "砖石", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_refine.tex"},
    {["name"] = "牛鞍", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_riding.tex"},
    {["name"] = "船", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_sailing.tex"},
    {["name"] = "科技", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_science.tex"},
    {["name"] = "骷髅头", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_skull.tex"},
    {["name"] = "房子", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_structure.tex"},
    {["name"] = "工具", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_tool.tex"},
    {["name"] = "衣服", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_warable.tex"},
    {["name"] = "书", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "station_books.tex"},
    {["name"] = "锯子", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "station_carpentry.tex"},
    {["name"] = "制图", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "station_cartography.tex"},
    {["name"] = "天体", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "station_celestial.tex"},
    {["name"] = "远古", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "station_crafting_table.tex"},
    {["name"] = "冬季盛宴炉子", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "station_feast_oven.tex"},
    {["name"] = "调味台", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "station_foodprocessing.tex"},
    {["name"] = "瓶子", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "station_hermitcrab_shop.tex"},
    {["name"] = "乌鸦", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "station_host.tex"},
    {["name"] = "月亮科技", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "station_lunar_forge.tex"},
    {["name"] = "药剂", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "station_madscience_lab.tex"},
    {["name"] = "宠物牌", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "station_orphanage.tex"},
    {["name"] = "元宝", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "station_perd_offering.tex"},
    {["name"] = "鸦年华", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "station_prizebooth.tex"},
    {["name"] = "船方向盘", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "station_seafaring.tex"},
    {["name"] = "暗影锅", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "station_shadow_forge.tex"},
    {["name"] = "小男孩", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_walter.tex"},
    {["name"] = "旺达", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_wanda.tex"},
    {["name"] = "沃利", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_warly.tex"},
    {["name"] = "女武神", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_wathgrithr.tex"},
    {["name"] = "老麦", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_waxwell.tex"},
    {["name"] = "蜘蛛人", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_webber.tex"},
    {["name"] = "温蒂", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_wendy.tex"},
    {["name"] = "维斯", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_wes.tex"},
    {["name"] = "老奶奶", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_wickerbottom.tex"},
    {["name"] = "威诺", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_willow.tex"},
    {["name"] = "威尔逊", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_wilson.tex"},
    {["name"] = "女工", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_winona.tex"},
    {["name"] = "大力士", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_wolfgang.tex"},
    {["name"] = "猴子", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_wonkey.tex"},
    {["name"] = "吴迪", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_woodie.tex"},
    {["name"] = "鼹鼠", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_woodie_1.tex"},
    {["name"] = "鹿", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_woodie_2.tex"},
    {["name"] = "大鹅", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_woodie_3.tex"},
    {["name"] = "植物人", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_wormwood.tex"},
    {["name"] = "植物人-2", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_wormwood_1.tex"},
    {["name"] = "植物人-3", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_wormwood_2.tex"},
    {["name"] = "植物人-4", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_wormwood_3.tex"},
    {["name"] = "小恶魔", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_wortox.tex"},
    {["name"] = "小鱼妹", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_wurt.tex"},
    {["name"] = "机器人", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_wx78.tex"},
    {["name"] = "科学家", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_wagstaff_npc.tex"}
}
TUNING["HH_CAN_SHOW_TEXT_FX"] = true -- HUD tích hợp tắt chữ chiến đấu cũ khi được nạp.
local function ffguncfKk()
    local nFuukCkkn = {
        string["format"]("• Châu báu/Đạo-Cụ: %s%%\n", TUNING["HH_CHANCE_CONFIG"]["GIF_CHANCE"]["player_gem_chance"] * 100),
        string["format"](
            "• Giấy Thuộc Tính/Lục Bảo Thạch: %s%%\n",
            TUNING["HH_CHANCE_CONFIG"]["GIF_CHANCE"]["player_stone_chance"] * 100
        ),
        string["format"](
            "• Trang bị từ Quái thường: %s%%\n",
            TUNING["HH_CHANCE_CONFIG"]["DROP_EQUIP_CHANCE"]["common_monster"] * 100
        ),
        string["format"](
            "• Trang bị từ Quái mạnh: %s%%\n",
            TUNING["HH_CHANCE_CONFIG"]["DROP_EQUIP_CHANCE"]["elite_monster"] * 100
        ),
        string["format"](
            "• Trang bị từ Quái trùm: %s%%\n",
            TUNING["HH_CHANCE_CONFIG"]["DROP_EQUIP_CHANCE"]["boss_monster"] * 100
        ),
        string["format"](
            "• Đá Thuộc Tính hiếm từ Quái mạnh: %s%%\n",
            TUNING["HH_CHANCE_CONFIG"]["GIF_CHANCE"]["elite_monster_stone"] * 100
        ),
        string["format"](
            "• Đá Thuộc Tính hiếm từ Quái trùm: %s%%\n",
            TUNING["HH_CHANCE_CONFIG"]["GIF_CHANCE"]["boss_monster_stone"] * 100
        ),
        string["format"](
            "• Túi Quà từ Quái mạnh: %s%%\n",
            TUNING["HH_CHANCE_CONFIG"]["GIF_CHANCE"]["elite_monster_gif"] * 100
        ),
        string["format"](
            "• Túi Quà từ Quái trùm: %s%%\n",
            TUNING["HH_CHANCE_CONFIG"]["GIF_CHANCE"]["boss_monster_gif"] * 100
        )
    }
    local kFgUgcgKc = ""
    for nFiUgCgKk, ufkUuCnkg in ipairs(nFuukCkkn) do
        kFgUgcgKc = kFgUgcgKc .. ufkUuCnkg
    end
    return kFgUgcgKc
end
TUNING["HH_UI_TEXT"] = {
    ["UPDATE_VISION"] = {
        {
            ["title"] = "TỔNG QUAN",
            ["desc"] = "- Bỏ trang bị (TB) vào [Lò Rèn] và sử dụng [Đá Cường Hoá]\nđể nâng cấp. Số lượng tiêu tốn bằng đúng số cấp cần lên.\n- Đối với vũ khí sẽ tăng sát thương vật lý (ST), với giáp sẽ tăng\nhệ số hấp thụ sát thương.\n- Cấp càng cao chỉ số càng tốt hơn, nhưng tỉ lệ cường hoá thành\ncông càng thấp đi.\n- Vũ khí tầm xa sẽ ko tăng sát thương.\n- Trang bị cường hoá +3/+6/+9 trở lên sẽ xuất hiện thêm 1/2/3\nlỗ cho phép dùng đạo cụ [Mũi đục] để khảm nạm châu báu.\n- Một số công thức đặc biệt chỉ mở khoá khi đứng cạnh Lò Rèn.",
            ["space"] = ""
        },
        {
            ["title"] = "CƯỜNG HOÁ",
            ["desc"] = "- Sơ cấp (từ +1 tới +5) nếu thất bại sẽ ko làm tụt cấp.\n- Trung cấp (từ +6 tới +9) nếu thất bại sẽ bị tụt cấp.\n- Cao cấp (từ +10 tới +13) nếu thất bại sẽ mất trang bị.\n- Sở hữu Bùa Ma Thuật sẽ giúp ko tụt cấp nếu cường hoá trung\ncấp thất bại.\n- Sở hữu Bùa Bảo Vệ sẽ giúp ko mất trang bị nếu cường hoá\ncao cấp thất bại, tuy nhiên vẫn bị tụt cấp trang bị.\n- Uống Phúc Lạc Dược giúp tăng tỉ lệ cường hoá thành công.\n- Giết 4 loại cá mùa (ngoài biển), đập nông sản khổng lồ, mở túi\nmù ở Ốc Đảo và cường hoá cao cấp thất bại có tỉ lệ nhận các\nCuộn Cường Hoá.",
            ["space"] = ""
        },
        {
            ["title"] = "TRANG BỊ ĐẦU",
            ["desc"] = "Khi đạt đến cấp độ nhất định [TB Đầu] sẽ tự động nhận thêm\ncác nội tại đặc biệt:\n+3 - [Nhập Định] - giảm tiêu hao năng lượng\n+5 - [Hoá Thần] - đảo ngược hào quang tinh thần tiêu cực\n+9 - [Kim Quang] - giúp người chơi phát sáng phạm vi lớn\n+11 - [Huyết Chú] - lập tức phục hồi đầy máu khi máu thấp\n+13 - [Bất Diệt] - ko tiêu hao độ bền trang bị và bị tấn công\ncó tỉ lệ cao phục hồi sinh lực bằng ST giáp đã hấp thụ.",
            ["space"] = ""
        },
        {
            ["title"] = "TRANG BỊ THÂN",
            ["desc"] = "Khi đạt đến cấp độ nhất định [TB Thân] sẽ tự động nhận thêm\ncác nội tại đặc biệt:\n+3 - [Lưu Vân] - tăng tốc độ di chuyển\n+5 - [Hồi Phong] - có tỉ lệ đẩy lùi mục tiêu ra xa\n+9 - [Ngạo Tuyết] - kháng lửa và kháng axít\n+11 - [Vô Ngã] - chuyển bị hất ngã thành bị đẩy lùi\n+13 - [Bất Diệt] - ko tiêu hao độ bền trang bị và bị tấn công\ncó tỉ lệ cao phục hồi sinh lực bằng ST giáp đã hấp thụ.",
            ["space"] = ""
        },
        {
            ["title"] = "TRANG BỊ TAY",
            ["desc"] = "Khi đạt đến cấp độ nhất định [TB Tay] sẽ tự động nhận thêm\ncác nội tại đặc biệt:\n+3 - [Bộc Liệt] - tấn công gây sát thương lan\n+5 - [Bạo Vũ] - tấn công gây ST chuẩn tăng theo cấp\n+9 - [Ngự Lôi] - miễn nhiễm sát thương từ sét\n+11 - [Địa Chấn] - tấn công có tỉ lệ giữ chân mục tiêu\n+13 - [Tàn Ảnh] - tấn công có cơ hội tạo nhiều phân thân\nđồng loạt tấn công lên mục tiêu và ko tiêu hao độ bền trang bị",
            ["space"] = ""
        }
    },
    ["MOD_INFO"] = {
        ["mod_role_1"] = "- Đây là Mod Solo Leveling, nơi người chơi sẽ hóa thành các thợ săn khởi đầu ở mức Rank-E. Sau khi trải qua qua trình thăm ngàn, tu luyện trong Hầm Ngục sẽ khiến bản thân trở nên mạnh hơn.\n- Bản Mod này có thay đổi địa hình và cập nhật thêm nhân vật mới (sẽ update sau).\n- Mod sở hữu hệ thống độc quyền bao gồm: Cường Hoá, Hợp Thành, Khảm Nạm kèm các cơ chế Đúc Linh, Kế Thừa, Thanh Tẩy, Nâng Cấp, Dung Hợp.",
        ["mod_role_2"] = "- Bản Mod sẽ tập trung vào cày cuốc, farm quái vật từ yếu đến mạnh. Bên cạnh đó cũng cần làm ruộng, câu cá, farm tài nguyên và đánh BOSS rất nhiều.\n- Hệ thống Hầm Ngục và gia tăng sức mạnh của thợ săn, cùng với đó là các chỉ số được cường hóa khi thăng cấp lên bậc Rank cao hơn\n- Mod cũng có nhiều bí mật ko có trong hướng dẫn đang chờ người chơi khám phá.\n- Chi tiết hơn hãy nhấn vào dòng chữa màu xanh dương bên dưới tham gia nhóm Discord.",
        ["monster"] = "- Một số quái vật ban đầu đã bị đột biến và thêm khả năng đặc biệt.\n- Lượng máu tối đa của quái vật sẽ tăng lên theo thời gian (có giới hạn nếu tuỳ chỉnh)\n- Giết các quái mạnh (BOSS) sẽ có cơ hội rơi ra Đá Thuộc Tính hiếm.\n- Giết các trùm siêu cấp (SUPER BOSS) sẽ có cơ hội rơi ra Đá Thuộc Tính siêu hiếm và Châu báu quý hiếm.",
        ["qq_str"] = "Youtube: Saikuno  |  Nhóm Discord: Saikou",
        ["conflict"] = "- Sử dụng kèm 1 số mod Extra Slot sẽ gây lỗi crash. Giải pháp: tìm và sử dụng mod mới hơn.\n- Có thể chơi kèm các mod: Epic Healthbar; Extra Equip Slots.\n- Lưu ý: Phải bật hỗ trợ mod khác ở Confid Mod.\n- Các mod khác khi chơi cùng có thể gây CRASH, đừng cố gắng chơi theo phong cách thập cẩm.\n- Các Lỗi / Bug đã biết như sau:\n  => Ná cao su bị mất thuộc tính sau khi sử dụng (do cơ chế spawn prefab mới).\n  => Một số dòng thuộc tính bị mất khi cường hoá lên +13 (do không còn độ bền).\n  => Không ép được đá thuộc tính vào một số trang bị (cần bật hỗ trợ mod khác ở config)",
        ["respect"] = "• [VI] Tiếng Việt (nếu không thì chữ sẽ lệch ra ngoài)",
        ["update"] = {
            {["date"] = "2026-06-29", ["desc"] = "• RA MẮT VERSION 1.0 - THỨC TỈNH\n• Thêm 7 loại châu báu mới: Bảo★Lửa, Siêu★Lửa, Siêu★Bền, Siêu★Tốc, Siêu★Lan, Siêu★Né, Siêu★Trảm\n• Thay đổi toàn bộ Font chữ mới độc quyền của Saikuno\n• Thêm một tab Wiki chứa đầy đủ thông tin của bản mod"},
            {["date"] = "2026-08-10", ["desc"] = "• RA MẮT VERSION 2.0 - SOLO LEVELING\n• Ra mắt hệ thống Hầm Ngục (Dungeon).\n• Ra mắt hệ thống Trích Xuất - Nâng Cấp Bóng Ma.\n• Ra mắt hệ thống Chỉ Số Thợ Săn.\n• Ra mắt hệ thống Nhiệm Vụ Ngày.\n• Ra mắt hệ thống Hiệp Hội Thợ Săn.\n• Ra mắt hệ thống Kỹ Năng Thợ Săn.\n• Xóa bỏ hoàn toàn các vật phẩm: Hắc Trượng, Thập Hổ Kiếm, Hàn Băng Đao, Xích Diễm Kiếm, Kim Cương Thương, Lục Hợp Thuẫn, Thất Tinh Trượng, Thương Tâm Kỳ Hoa, Mặc Tuyết Thần Kiếm, Ly\nNhân Chuỳ, Thiên Gia Thần Kiếm, Hổ Phách Chu Lăng, Thanh Lương Châu, Cuộn Huyết Luyện, Phục\nLong Đỉnh, Cuộn Phong Ấn, Cuộn Khế Ước, Linh Phù Truyền Tống.\n• Xóa bỏ hoàn toàn khả năng dung hợp của: Bệ Đá Mặt Trăng, Đài Giả Cổ, Ốc Đảo, Vĩnh Hằng Chi Hỏa, Sơn Dương Dịch Trạm, Mặc Lục Bào, Lục Hợp Thuẫn, Mặc Tuyết Thần Kiếm, Hổ Phách Chu\nLăng, Ly Nhân Chuỳ, Huyễn Nguyệt Tháp.\n• Xóa bỏ hoàn toàn hệ thống Ngự Không Phi Hành."},
        }
    },
    ["UI_ITEMS"] = {
        ["ui_role_1"] = "1. Các loại đạo cụ nhấn trực tiếp để sử dụng bao gồm:\n• Mũi đục: dùng để đục lỗ trên trang bị, sau đó các trang bị này sẽ có thể khảm châu báu mới (mỗi lần sử dụng sẽ tiêu tốn 1 mũi đục)\n• Búa đục: dùng để phá ngẫu nhiên 1 châu báu đã khảm vào trang bị (mỗi lần sử dụng sẽ tiêu tốn 1 búa đục)\n2. Các loại đạo cụ cần phải nhấn thêm các nút chức năng và tiêu tốn:\n• Bùa may: dùng để đặt lại ngẫu nhiên giá trị của các dòng Đá Thuộc Tính hoặc Giấy Thuộc Tính đã ép vào trang bị (Thực hiện bằng cách nhấn nút Đặt Lại dưới ô trang bị). Nếu giá trị của các dòng thuộc tính đã đạt tối đa (MAX) thì khi sử dụng Bùa May sẽ không làm giảm các giá trị tối đa (MAX) đó. Mỗi lần sử dụng sẽ tiêu tốn 1 bùa may\n• Bùa tẩy: dùng để xoá các dòng Đá Thuộc Tính hoặc Giấy thuộc Tính đã được ép vào trang bị (bằng cách nhấn nút Thanh Tẩy khi mở công trình có tên Thần Binh Phổ). Điểm khác biệt giữ Bùa Tẩy và Lục Bảo Thạch là bùa tẩy cho phép bạn chỉ định dòng thuộc tính muốn xóa, còn Lục Bảo Thạch sẽ ngẫu nhiên xóa 1 dòng thuộc tính bất kì. Với mỗi 1 dòng thuộc tính muốn xóa sẽ tiêu tốn 1 bùa tẩy (Ví dụ: bạn có thể xóa 1 lần 3 dòng thuộc tính chỉ định và sẽ tiêu tốn 3 bùa tẩy)",
        ["ui_role_2"] = "• Đá bền bỉ: Tăng độ bền trang bị theo thời gian (+1 độ bền mỗi giây)\n• Đá sức mạnh: Tăng 10% sát thương gây ra\n• Đá giảm thương: Giảm 5% sát thương nhận vào\n• Đá chí mạng: Tăng 5% chí mạng",
        ["ui_role_3"] = "• Đá thú chí: Tăng 10% chí mạng cho quái vật/(follower) đi theo\n• Đá thú sát: Tăng 15 sát thương cho quái vật/(follower) đi theo\n• Đá thú ngự: Giảm 5 sát thương nhận vào cho quái vật/(follower) đi theo",
        ["ui_role_4"] = "----------HIẾM----------\n• Bảo★Sát: Tăng 15% sát thương đòn chính\n• Bảo★Chí: Tăng 20% chí mạng\n• Bảo★Bền: Hồi 2% độ bền mỗi giây\n• Bảo★Tốc: Tăng 3% tốc độ di chuyển\n• Bảo★Lửa: Tăng 30% sát thương lửa\n-----------SIÊU HIẾM-----------\n• Siêu★Sát: Tăng 20% sát thương đòn chính\n• Siêu★Chí: Tăng 40% tỉ lệ chí mạng\n• Siêu★Xuyên: 20% sát thương đòn chính bỏ qua giáp\n• Siêu★Xâm: Miễn nhiễm quá nhiệt, lạnh cóng, độc, ướt, chậm, băng; Miễn Giảm Hồi Máu; nhìn xuyên Bão Cát và Bão Mặt Trăng\n• Siêu★Bền: Tăng 1000 độ bền vĩnh viễn, hồi độ bền siêu nhanh\n• Siêu★Lửa: Tăng 50% sát thương lửa\n• Siêu★Tốc: Tăng 6% tốc độ di chuyển\n• Siêu★Lan: Đòn đánh gây 20% sát thương lan ra các mục tiêu lân cận\n• Siêu★Né: Có 15% tỉ lệ né toàn bộ sát thương nhận vào tại 1 thời điểm\n• Siêu★Trảm: Sát thương kết liễu quái vật (Trừ BOSS) dưới 15% máu",
        ["ui_role_5"] = "Đạo cụ và Châu Báu có tỉ lệ rơi ra khi giết quái vật và thợ săn sẽ tự thu thập chúng vào Bảng Tổng Hợp, ngoài ra thợ săn không còn cách nào khác để sở hữu (ngoại trừ cheat ~~).",
        ["ui_role_6"] = "Quạt Lông Vũ: Dùng để khảm nạm, hợp thành, tái chế những trang bị đặt dưới mặt đất. Hiệu ứng tạo ra sẽ khác nhau dựa trên vật phẩm được bỏ vào bên trong ô chứa của Quạt Lông Vũ.\n1. Vật phẩm tiêu hao khi dùng xong:\n• Đá Thuộc Tính: dùng để ép thuộc tính chỉ định\n• Giấy Thuộc Tính: dùng để ep thuộc tính ngẫu nhiên\n• Lục Bảo Thạch: dùng để tẩy ngẫu nhiên 1 dòng thuộc tính\n2. Vật phẩm không tiêu hao khi dùng xong:\n• Bánh Răng: dùng để tháo châu báu (tiêu hao Búa đục)\n• Sừng Bò: dùng để đục lỗ mới (tiêu hao Mũi đục)\n• Ngọc Lục: dùng để đặt lại giá trị ngẫu nhiên cho các dòng thuộc tính (tiêu hao Bùa may)\n• Ngọc Đỏ: dùng để khảm Đá chí mạng\n• Đá Cát: dùng để khảm Đá sức mạnh",
        ["ui_role_7"] = "• Vảy Rồng: dùng để khảm Bảo★Sát\n• Sừng Ancient Guardian: dùng để khảm Bảo★Chí\n• Mắt Deer: dùng để khảm Bảo★Bền\n• Răng Tusk: dùng để khảm Bảo★Tốc"
    },
    ["CHANCE_TEXT"] = ffguncfKk(),
    ["QQ_HTTP"] = "https://discord.gg/x8bMTgtbBg"
}
TUNING["WW_INFERNALSTAFF"] = {
    USES = 150,
    SHADOW_LEVEL = 1,
    PROJECTILE_SPEED = 25,
    DAMAGE_BASIC = 0,
    COST_SPELL = 5,
    COST_SANITY_SPELL = -5,
    COST_SANITY_BASIC = -1,
    RECHARGE = 30,
    INIT_DELAY = 4 * FRAMES,
    SPELL_RANGE = 16,
    BASIC_RANGE = 20,
    SPELL_RADIUS = 4.5,
    SPELL_WORK = 20,
    SPELL_DAMAGE = 500,
    SPELL_WORK_ACTIONS = {
        [ACTIONS["CHOP"]] = (490 * 266 * 487 + 54 ~= 63475642),
        [ACTIONS["DIG"]] = (false and false or true and not true and not false and not false or
            false and not true and not false and true and false or
            false and not true),
        [ACTIONS["HAMMER"]] = (297 - 112 - 195 * 200 + 323 ~= -38492),
        [ACTIONS["MINE"]] = (51 + 390 * 317 * 178 == 22006191)
    },
    SPELL_NOTAGS = {
        "playerghost",
        "INLIMBO",
        "FX",
        "player",
        "companion",
        "shadowminion",
        "abigail",
        "wall",
        "meteor_protection"
    }
}

TUNING["HH_LEVELING"] = {
    AP_PER_LEVEL = 2,
    AP_BONUS_INTERVAL = 10,
    AP_BONUS_AMOUNT = 2,
    LEVEL_UP_RESTORE_TIME = 10,
    MAX_LEVELS_PER_EXP_GRANT = 1000,
    STAT_CAPS = { STR = 200, AGI = 50, VIT = 40, SEN = 50, INT = 15 },
    STR_GAIN = 0.1,
    AGI_GAIN = 1,
    VIT_GAIN = 1,
    SEN_CRIT_RATE = 1,
    SEN_CRIT_DMG = 2,
    INT_CD_REDUCE = 1,
    INT_SHADOW_REDUCE = 10,
}

TUNING["HH_MANA"] = {
    BASE_MAX = 100,
    MAX_PER_INT = 20,
    BASE_REGEN = 1,
    REGEN_PER_INT = 0.15,
    REGEN_INTERVAL = 0.5,
    REGEN_DELAY = 3,
    ARISE_COST = 40,
	ARISE_COSTS = {
        hh_igris_shadow = 50,
        hh_beru_shadow = 50,
        hh_fruitfly_shadow = 40,
        hh_macanh_shadow = 30,
        hh_hacanh_shadow = 40,
    },
	SWAP_COST = 100,
	SWAP_COOLDOWN = 480,
    HUD_WIDTH = 240,
    HUD_HEIGHT = 24,
    HUD_SCALE = 4,
    HUD_OFFSET_X = -450,
    HUD_OFFSET_Y = 230,
    LIQUID_INSET_LEFT = 43.125,
    LIQUID_INSET_RIGHT = 41.875,
}

TUNING["HH_SANCTUARY"] = {
    RADIUS = 15,
    HEAL_BASE = 30,
    HEAL_MAX_HEALTH_RATIO = 0.20,
    BASE_COST = 30,
    BASE_COOLDOWN = 30,
    MIN_COOLDOWN = 3,
}

TUNING["HH_GODSLAYER"] = {
    ACTIVE_DURATION = 30,
    CURRENT_HEALTH_DAMAGE_RATIO = 0.01,
    BASE_COST = 50,
    BASE_COOLDOWN = 80,
    MIN_COOLDOWN = 3,
}

-- Kẻ Thống Trị is intentionally kept in its own namespace.  The AOE and
-- prison constants mirror the current Maxwell Shadow Prison implementation
-- in the vanilla source; the gameplay values below are skill-specific.
if TUNING.HH_RULER ~= nil and type(TUNING.HH_RULER) ~= "table" then
    error("HH_RULER namespace collision: expected a tuning table")
end
TUNING["HH_RULER"] = TUNING["HH_RULER"] or {}
TUNING["HH_RULER"].BASE_COST = 100
TUNING["HH_RULER"].BASE_COOLDOWN = 80
TUNING["HH_RULER"].MIN_COOLDOWN = 3
TUNING["HH_RULER"].DAMAGE = 30
TUNING["HH_RULER"].DAMAGE_INTERVAL = 0.3
TUNING["HH_RULER"].AOE_RADIUS = 4
TUNING["HH_RULER"].CAST_RANGE = 8

if TUNING.HH_KING ~= nil and type(TUNING.HH_KING) ~= "table" then
    error("HH_KING namespace collision: expected a tuning table")
end
TUNING["HH_KING"] = TUNING["HH_KING"] or {}
TUNING["HH_KING"].BASE_COST = 100
TUNING["HH_KING"].BASE_COOLDOWN = 150
TUNING["HH_KING"].MIN_COOLDOWN = 3
TUNING["HH_KING"].ACTIVE_DURATION = 30
TUNING["HH_KING"].STAT_MULT = 2

if TUNING.HH_DEATH_THRESHOLD ~= nil and type(TUNING.HH_DEATH_THRESHOLD) ~= "table" then
    error("HH_DEATH_THRESHOLD namespace collision: expected a tuning table")
end
TUNING["HH_DEATH_THRESHOLD"] = TUNING["HH_DEATH_THRESHOLD"] or {}
TUNING["HH_DEATH_THRESHOLD"].BASE_COOLDOWN = 480
TUNING["HH_DEATH_THRESHOLD"].TRIGGER_HEALTH_RATIO = .90
TUNING["HH_DEATH_THRESHOLD"].REGEN_INTERVAL = .3
TUNING["HH_DEATH_THRESHOLD"].REGEN_TICKS = 33
TUNING["HH_DEATH_THRESHOLD"].REGEN_MAX_HEALTH_RATIO = .01

if TUNING.HH_SUPER_GROWTH ~= nil and type(TUNING.HH_SUPER_GROWTH) ~= "table" then
    error("HH_SUPER_GROWTH namespace collision: expected a tuning table")
end
TUNING["HH_SUPER_GROWTH"] = TUNING["HH_SUPER_GROWTH"] or {}
TUNING["HH_SUPER_GROWTH"].KILL_EXP_MULT = 2

TUNING["HH_SHADOW_HUD"] = {
    HUD_WIDTH = 320,
    HUD_HEIGHT = 100,
    HUD_SCALE = 1.5,
    HUD_OFFSET_X = 150,
    HUD_OFFSET_Y = 200,
}

TUNING["HH_EXP_BALANCE"] = {
    SHARE_RADIUS = 32,
    LEVEL_FACTORS = {
        { gap = 40, factor = 0.10 },
        { gap = 30, factor = 0.25 },
        { gap = 20, factor = 0.50 },
        { gap = 10, factor = 0.75 },
    },
}

TUNING["HH_MONSTER_BALANCE"] = {
    normal = { health = 1.25, damage = 1.10 },
    miniboss = { health = 1.50, damage = 1.20 },
    boss = { health = 1.75, damage = 1.30 },
}

TUNING["HH_MOB_EXP"] = {
    ["bee"] = 1, ["killerbee"] = 1, ["fruitfly"] = 1, ["bat"] = 1, ["eyeofterror_mini"] = 1,
    ["strider"] = 1, ["cookiecutter"] = 1, ["magma_hound"] = 1, ["beeguard"] = 1, ["mutatedhound"] = 1,
    ["lavae"] = 1, ["mutated_penguin"] = 1, ["crow"] = 1, ["robin"] = 1, ["robin_winter"] = 1, 
    ["canary"] = 1, ["puffin"] = 1, ["babybeefalo"] = 1, ["toddlerbeefalo"] = 1, ["teenbeefalo"] = 1,
    ["frog"] = 1, ["ghost"] = 1, ["perd"] = 1, ["grassgekko"] = 1, ["squid"] = 1, ["shadow_leech"] = 1,
    ["little_walrus"] = 1, ["lureplant"] = 1, ["mosquito"] = 1, ["rabbit"] = 1, ["beardling"] = 1,
    ["spider"] = 1, ["spider_hider"] = 1, ["smallbird"] = 1, ["buzzard"] = 1,
    ["bird_mutant"] = 1, ["bird_mutant_spitter"] = 1, ["birchnutdrake"] = 1,
    ["lightcrab"] = 1, ["hedgehound"] = 1, ["itemmimic_revealed"] = 1, ["graveguard_ghost"] = 1,
    ["catcoon"] = 1, ["glommer"] = 1, ["mole"] = 1, ["deciduous_root"] = 1, ["tentacle_pillar_arm"] = 1,

    
    ["spider_healer"] = 2, ["spider_moon"] = 2, ["deciduous_monster"] = 2, ["hound"] = 2, ["firehound"] = 2, ["icehound"] = 2,
    ["penguin"] = 2, ["crawlinghorror"] = 2, ["terrorbeak"] = 2, ["monkey"] = 2,
    ["spider_water"] = 2, ["powder_monkey"] = 2, ["lunarfrog"] = 2,
    ["moonhound"] = 2, ["clayhound"] = 2,
    ["terrorclaw"] = 2, ["slurper"] = 2, ["snurtle"] = 2, ["mutant_monkey"] = 2, ["spider_warrior"] = 2,
    ["spider_spitter"] = 2, ["spider_dropper"] = 2, ["teenbird"] = 2,
    ["crabking_mob"] = 2, ["crabking_mob_knight"] = 2,

    
    ["koalefant_summer"] = 3, ["koalefant_winter"] = 3, ["werepig"] = 3, ["tallbird"] = 3, ["tentacle_pillar"] = 3, ["krampus"] = 3, ["pigman"] = 2,
    ["gnarwail"] = 3, ["rockjaw"] = 3, ["mushgnome"] = 3, ["molebat"] = 3, ["grassgator"] = 3, ["mutatedbuzzard_gestalt"] = 3, ["walrus"] = 3, ["merm"] = 3,
    ["merm_shadow"] = 3, ["merm_lunar"] = 3, ["shark"] = 3, ["oceanhorror"] = 3, ["rabbitkingminion_bunnyman"] = 3,
    ["moonpig"] = 3,
    ["deer"] = 3, ["waterplant"] = 3, ["gelblob"] = 3, ["tentacle"] = 3, ["bunnyman"] = 3,
    

    ["beefalo"] = 4, ["knight"] = 4, ["bishop"] = 4, ["rook"] = 4, ["knight_nightmare"] = 4,
    ["bishop_nightmare"] = 4, ["rook_nightmare"] = 4, ["worm"] = 4, ["spat"] = 4, ["pigguard"] = 4,
    ["rocky"] = 4, ["slurtle"] = 4, ["mossling"] = 4, ["warglet"] = 4, ["lightninggoat"] = 4,
    ["mermguard"] = 4, ["mermguard_shadow"] = 4, ["mermguard_lunar"] = 4, ["prime_mate"] = 4,
    ["ruinsnightmare"] = 4,
    ["deer_red"] = 4, ["deer_blue"] = 4, ["chest_mimic_revealed"] = 4,

    
    ["lordfruitfly"] = 5, ["leif"] = 5, ["leif_sparse"] = 5, ["spiderqueen"] = 5, ["warg"] = 5,
    ["fruitdragon"] = 5, ["claywarg"] = 5, ["gingerbreadwarg"] = 5,
    ["rabbitking_aggressive"] = 5, ["shadowthrall_hands"] = 5, ["shadowthrall_horns"] = 5,
    ["shadowthrall_wings"] = 5, ["shadowthrall_mouth"] = 5, ["fused_shadeling"] = 5, ["lunarthrall_plant"] = 5,

    
    ["minotaur"] = 20, ["deerclops"] = 20, ["dragonfly"] = 20, ["antlion"] = 20, ["klaus"] = 20,
    ["malbatross"] = 20, ["crabking"] = 20, ["eyeofterror"] = 20, ["twinofterror1"] = 20,
    ["twinofterror2"] = 20, ["shadow_bishop"] = 20, ["shadow_knight"] = 20, ["shadow_rook"] = 20,
    ["alterguardian_phase1"] = 20, ["alterguardian_phase2"] = 20, ["bearger"] = 20, ["sharkboi"] = 20, 
    ["moose"] = 20, ["daywalker"] = 20, ["daywalker2"] = 20, ["worm_boss"] = 20,

    
    ["beequeen"] = 30, ["stalker_atrium"] = 30, ["toadstool"] = 30, ["alterguardian_phase3"] = 30,
    ["wagboss_robot"] = 30, ["alterguardian_phase4"] = 30, ["mutatedbearger"] = 30, ["mutatedwarg"] = 30, 
    ["alterguardian_phase4_lunarrift"] = 30, ["mutateddeerclops"] = 30,


    ["toadstool_dark"] = 40, 

    ------------------------------ quái vật / boss trong dungeon ---------------------------
    ["hh_dungeon_spider"] = 5, ["hh_dungeon_firehound"] = 5, ["hh_dungeon_icehound"] = 5, ["hh_dungeon_snowhound"] = 5,
    ["hh_dungeon_lightninghound"] = 5, ["hh_dungeon_horrorhound"] = 5,
    
    ["hh_dungeon_pig"] = 10, 

    ["hh_igris_dungeon"] = 1000, 

    ["hh_beru_dungeon"] = 2000,


}

TUNING["HH_TREASURE_BOSS_EXP"] = {
    ["walrus_adc"] = { exp = 5000, level = 65, class = "boss" },
    ["mutateddeerclops_boss"] = { exp = 5000, level = 80, class = "superboss" },
    ["mutatedbearger_boss"] = { exp = 5000, level = 80, class = "superboss" },
    ["mutatedwarg_boss"] = { exp = 5000, level = 80, class = "superboss" },
    ["hh_sharkboi_boss"] = { exp = 5000, level = 85, class = "superboss" },
    ["treasure_kps"] = { exp = 5000, level = 100, class = "superboss" },
    ["treasure_cat_you"] = { exp = 5000, level = 100, class = "superboss" },
}

TUNING["HH_DUNGEON_BOSS_EXP"] = {
    ["hh_igris_dungeon"] = { exp = 8000, level = 60, class = "boss" },
    ["hh_sharkboi"] = { exp = 8000, level = 80, class = "superboss" },
    ["hh_beru_dungeon"] = { exp = 8000, level = 100, class = "superboss" },
}

TUNING["HH_MINIBOSS_PREFABS"] = {
    lordfruitfly = true, fruitdragon = true, leif = true, leif_sparse = true,
    spiderqueen = true, warg = true, claywarg = true, gingerbreadwarg = true,
}

TUNING["HH_BOSS_PREFABS"] = {
    minotaur = true, deerclops = true, dragonfly = true, antlion = true, klaus = true,
    malbatross = true, crabking = true, eyeofterror = true, twinofterror1 = true,
    twinofterror2 = true, shadow_bishop = true, shadow_knight = true, shadow_rook = true,
    alterguardian_phase1 = true, alterguardian_phase2 = true, alterguardian_phase3 = true,
    alterguardian_phase4 = true, alterguardian_phase4_lunarrift = true, bearger = true,
    sharkboi = true, moose = true, daywalker = true, daywalker2 = true, beequeen = true,
    stalker_atrium = true, toadstool = true, toadstool_dark = true, wagboss_robot = true,
    mutatedbearger = true, mutatedwarg = true, mutateddeerclops = true, worm_boss = true,
}

TUNING["HH_MOB_RECOMMENDED_LEVEL"] = {}
for prefab, exp in pairs(TUNING["HH_MOB_EXP"]) do
    TUNING["HH_MOB_RECOMMENDED_LEVEL"][prefab] =
        exp <= 1 and 5 or exp <= 2 and 10 or exp <= 3 and 15 or exp <= 4 and 20 or
        exp <= 5 and 25 or exp <= 20 and 40 or exp <= 30 and 60 or 80
end

for prefab, exp in pairs(TUNING["HH_MOB_EXP"]) do
    TUNING["HH_MOB_EXP"][prefab] =
        exp <= 1 and 5 or exp <= 2 and 10 or exp <= 3 and 35 or exp <= 4 and 45 or
        exp <= 5 and 100 or exp <= 20 and 1000 or exp <= 30 and 2000 or 5000
end
TUNING["HH_MOB_EXP"]["spiderqueen"] = 80
TUNING["HH_MOB_EXP"]["warg"] = 80
TUNING["HH_MOB_EXP"]["claywarg"] = 80
TUNING["HH_MOB_EXP"]["gingerbreadwarg"] = 80
TUNING["HH_MOB_EXP"]["leif"] = 60
TUNING["HH_MOB_EXP"]["leif_sparse"] = 60
TUNING["HH_MOB_EXP"]["hh_dungeon_spider"] = 20
TUNING["HH_MOB_EXP"]["hh_dungeon_firehound"] = 20
TUNING["HH_MOB_EXP"]["hh_dungeon_icehound"] = 20
TUNING["HH_MOB_EXP"]["hh_dungeon_snowhound"] = 20
TUNING["HH_MOB_EXP"]["hh_dungeon_lightninghound"] = 20
TUNING["HH_MOB_EXP"]["hh_dungeon_horrorhound"] = 20
TUNING["HH_MOB_EXP"]["hh_dungeon_pig"] = 40
TUNING["HH_MOB_EXP"]["hh_igris_dungeon"] = 800
TUNING["HH_MOB_EXP"]["hh_sharkboi"] = 1100
TUNING["HH_MOB_EXP"]["hh_beru_dungeon"] = 1400
TUNING["HH_MOB_EXP"]["alterguardian_phase1"] = 0
TUNING["HH_MOB_EXP"]["alterguardian_phase2"] = 0

TUNING['HH_DAILY_QUEST'] = {
    EXP_SEAL_DAYS = 1,
    SLOT_LOCK_DAYS = 1,
    SLOT_LOCK_ICON_SCALE = 0.07,
    FAILURE_VITAL_MULT = 0.5,
    FAILURE_VITAL_FLOOR = 1,
    EXP_BLOCK_NOTICE_COOLDOWN = 3,
    FIRST_DAY = 10,
    DURATION_DAYS = 2,
    SAMPLE_INTERVAL = 0.5,
    SPEED_TOLERANCE = 2.5,
    MIN_MAX_SPEED = 10,
}

-- Tỷ lệ trích xuất bóng ma theo Rank: E, D, C, B, A, S.
TUNING["HH_SHADOW_EXTRACTION_CHANCE_BY_RANK"] = {
    [1] = 0.15,
    [2] = 0.20,
    [3] = 0.25,
    [4] = 0.35,
    [5] = 0.40,
    [6] = 1.00,
}
TUNING.HH_MACANH_SHADOW = {
    UNLOCK_COMPLETED_DAILY_QUESTS = 5,
    SPEECH_INTERVAL = 10,
    MAX_OWNED = 1,
    MAX_HEALTH = 100,
    WORK_RADIUS = 25,
    FOLLOW_RADIUS = 25,
    MANA_UPKEEP_INTERVAL = 3,
    MANA_PER_COMPLETED_TARGET = 1,
    RECOVERY = 480,
    LIFESPAN = nil,
    SCALE = 1,
}
TUNING.HH_HACANH_SHADOW = {
    UNLOCK_COMPLETED_DAILY_QUESTS = 10,
    MANA_UPKEEP_INTERVAL = 3,
    ATTACKS_PER_MANA = 6,
    RECOVERY = TUNING.HH_MACANH_SHADOW.RECOVERY,
    MAX_HEALTH = 200,
    DAMAGE = 60,
    ATTACK_PERIOD = TUNING.SHADOWWAXWELL_ATTACK_PERIOD,
}

TUNING.HH_SHADOW_PROGRESSION = {
    SAVE_VERSION = 1,
    MAX_LEVEL = 30,
    EXP_BASE = 100,
    EXP_LINEAR = 35,
    EXP_QUADRATIC = 5,
    COMBAT_XP_HEALTH_SCALE = 2,
    COMBAT_XP_MIN = 5,
    COMBAT_XP_MAX = 250,
    EPIC_XP_MULT = 2,
    FRUITFLY_BASE_WORK_RADIUS = 20,
    GROWTH = {
        hh_igris_shadow = {
            HEALTH_PER_LEVEL = .025,
            DAMAGE_PER_LEVEL = .015,
            ABSORB_PER_LEVEL = .0035,
            ABSORB_CAP = .10,
        },
        hh_beru_shadow = {
            HEALTH_PER_LEVEL = .015,
            DAMAGE_PER_LEVEL = .02,
            ATTACK_PERIOD_PER_LEVEL = .006,
            ATTACK_PERIOD_CAP = .15,
        },
        hh_fruitfly_shadow = {
            HEALTH_PER_LEVEL = .02,
            SPEED_PER_LEVEL = .0025,
        },
        hh_macanh_shadow = {
            HEALTH_PER_LEVEL = .05,
            SPEED_PER_LEVEL = .0025,
        },
        hh_hacanh_shadow = {
            HEALTH_PER_LEVEL = .025,
            DAMAGE_PER_LEVEL = .025,
            ATTACK_PERIOD_PER_LEVEL = .004,
            ATTACK_PERIOD_CAP = .12,
            SPEED_PER_LEVEL = .0025,
        },
    },
}
