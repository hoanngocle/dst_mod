
local STRINGS = GLOBAL.STRINGS

-- ============================================================================
-- 1. DANH SACH VAT PHAM VA HIEU UNG (ITEMS & EFFECTS)
-- ============================================================================
local items = {
    ["rock_treasure"] = { "Khối Ma Thạch", "Có khá nhiều khoáng sản tinh khiết bên trong thứ này!", "Một khối đá chứa đầy khoáng sản" },
    ["hh_dungeon_pig"] = { "Heo Hầm Ngục", "BẢO VỆ HOÀNG THƯỢNG!", "Heo Hầm Ngục" },
    ["hh_dungeon_spider"] = { "Nhện Hầm Ngục", "Cẩn thận nọc độc!", "Nhện Hầm Ngục" },
    ["hh_effect_stone"] = { "Đá Thuộc Tính", "dùng để thêm thuộc tính cho trang bị", "dùng để thêm thuộc tính cho trang bị" },
    ["hh_effect_tally"] = { "Giấy Thuộc Tính", "dùng để thêm thuộc tính ngẫu nhiên cho trang bị", "dùng để thêm thuộc tính ngẫu nhiên cho trang bị" },
    ["hh_remove_stone"] = { "Lục Bảo Thạch", "dùng để xoá ngẫu nhiên thuộc tính trang bị", "dùng để xoá ngẫu nhiên thuộc tính trang bị" },
    ["hh_essence"] = { "Linh Thạch", "viên đá có linh khí", "nguyên liệu cần thiết, dùng cho nhiều việc" },
    ["hh_treasure_tally_a"] = { "Tầm Bảo Quyển Trục", "có khả năng tìm thấy quái trùm siêu cấp", "chỉ vị trí chính xác của kho báu" },
    ["hh_treasure_tally_b"] = { "Tầm Bảo Quyển Trục", "có khả năng tìm thấy quái trùm siêu cấp", "chỉ vị trí chính xác của kho báu" },
    ["hh_treasure_tally_a_blueprint"] = { "Tầm Bảo Quyển Trục Blueprint", "Tầm Bảo Quyển Trục", "Tầm Bảo Quyển Trục" },
    ["hh_treasure_tally_b_blueprint"] = { "Tầm Bảo Quyển Trục Blueprint", "Tầm Bảo Quyển Trục", "Tầm Bảo Quyển Trục" },
    ["hh_ui_container"] = { "Bảng Tổng Hợp", "Enchantment container", "Enchantment container" },
    ["hh_forge_container"] = { "Thần Binh Phổ", "Forge container", "Forge container" },
    ["hh_suit_build"] = { "Thần Binh Phổ", "Nhấn  để sử dụng", "nơi để đúc linh đá, thanh tẩy và kế thừa trang bị" },
    ["hh_quat_long_vu"] = { "Quạt Lông Vũ", "Dùng để hợp thành, khảm nạm, tái chế trang bị dưới đất", "Dùng để hợp thành, khảm nạm, tái chế trang bị dưới đất" },
    ["hh_daogam5"] = { "Hắc Thiên Kiếm", "Lưỡi kiếm được bóng tối tôi luyện.", "Có thể thi triển Ảnh Bộ Nhất Tuyến" },
    ["hh_daogam3"] = { "Trượng Ma Vực", "Nó mang theo hơi thở của Ma Vực.", "Có thể bắn ra 2 luồng phép thuật cùng lúc" },
    ["hh_daogam4"] = { "Trượng Hỏa Ngục", "Ngọn lửa của Địa Ngục chưa bao giờ tắt.", "Có thể triệu hoán Bát Hoang Hỏa Long" },
    ["hh_daogam6"] = { "Tà Thuật Đen - Vũ Khí", "Vũ khí hắc ám có thể biến đổi hình dạng", "Tà Thuật Đen - Vũ Khí" },
    ["hh_daogam6_sword"] = { "Tà Thuật Đen - Vũ Khí", "Vũ khí hắc ám có thể biến đổi hình dạng", "Tà Thuật Đen - Vũ Khí" },
    ["hh_daogam6_axe"] = { "Tà Thuật Đen - Rìu", "Vũ khí hắc ám có thể biến đổi hình dạng", "Tà Thuật Đen - Rìu" },
    ["hh_daogam6_hoe"] = { "Tà Thuật Đen - Cuốc", "Vũ khí hắc ám có thể biến đổi hình dạng", "Tà Thuật Đen - Cuốc" },
    ["hh_daogam6_pickaxe"] = { "Tà Thuật Đen - Cúp", "Vũ khí hắc ám có thể biến đổi hình dạng", "Tà Thuật Đen - Cúp" },
    ["hh_daogam6_shovel"] = { "Tà Thuật Đen - Xẻng", "Vũ khí hắc ám có thể biến đổi hình dạng", "Tà Thuật Đen - Xẻng" },
    ["hh_daogam"] = { "Kiếm Quỷ Vương", "Ma khí ngút trời, quỷ vương xuất thế", "Thi triển Thiên Phạt Quỷ Vương" },
    ["hh_daogam2"] = { "Hắc Ảnh Kiếm", "Thanh kiếm mang hình bóng hắc ám", "Thanh kiếm mang hình bóng hắc ám" },
    ["hh_van_nang_trao"] = { "Vạn Năng Trảo", "Dụng cụ đa năng, vô cùng tiện lợi", "Dụng cụ đa năng, vô cùng tiện lợi" },
    ["hh_monarch_storage_container"] = { "Kho Quân Vương", "Kho cá nhân của Quân Vương.", "Kho cá nhân của Quân Vương." },


    ["hh_true_damage"] = { "Hiệu ứng xuyên giáp", "hh_true_damage", "hh_true_damage" },
    ["hh_poison"] = { "Hiệu ứng trúng độc", "Hiệu ứng trúng độc", "Hiệu ứng trúng độc" },
    ["hh_monster_kj"] = { "Hiệu ứng sợ hãi", "Hiệu ứng sợ hãi", "Hiệu ứng sợ hãi" },
    ["hh_turret"] = { "Pháo Kích", "Pháo Kích", "Pháo Kích" },
    ["hh_turret_ice"] = { "Kỹ năng Hàn Băng Pháo Kích", "Kỹ năng Pháo Băng", "Kỹ năng Pháo Băng" },
    ["hh_turret_fire"] = { "Kỹ năng Hoả Diễm Pháo Kích", "Kỹ năng Pháo Lửa", "Kỹ năng Pháo Lửa" },
    ["hh_turret_poison"] = { "Kỹ năng Kịch Độc Pháo Kích", "Kỹ năng Pháo Độc", "Kỹ năng Pháo Độc" },
    ["hh_igris_shadow"] = { "Igris", "Đội quân bóng tối", "Đội quân bóng tối" },
    ["hh_beru_shadow"] = { "Beru", "Đội quân bóng tối", "Đội quân bóng tối" },
    ["hh_corpse_igris"] = { "Xác Igris", "Xác của Hiệp Sĩ Đỏ", "Dùng để trích xuất bóng ma" },
    ["hh_corpse_beru"] = { "Xác Beru", "Xác của Vua Côn Trùng", "Dùng để trích xuất bóng ma" },
    ["hh_fruitfly_shadow"] = { "Fruitfly", "Đệ tử chăm sóc cây trồng", "Đội quân bóng tối" },
    ["hh_corpse_fruitfly"] = { "Xác Chúa Ruồi Trái Cây", "Xác của Lord of the Fruit Flies", "Dùng để trích xuất bóng ma" },
    ["hh_beru_dungeon"] = { "Beru", "Beru - Vua Côn Trùng", "Beru - Vua Côn Trùng" },
    ["hh_dungeon_firehound"] = { "Sói Lửa", "Hừng hực lửa căm hờn!", "Sói Lửa" },
    ["hh_dungeon_icehound"] = { "Sói Băng", "Cắn phải là tê cứng ngay!", "Sói Băng" },
    ["hh_dungeon_snowhound"] = { "Sói Tuyết", "Hãy cẩn thận với đạn băng của nó!", "Sói Tuyết" },
    ["hh_dungeon_lightninghound"] = { "Sói Điện", "Sấm sét giáng xuống từ phía nó!", "Sói Điện" },
    ["hh_dungeon_horrorhound"] = { "Sói Bóng Đêm", "Nhanh và nguy hiểm khôn lường!", "Sói Bóng Đêm" },
    ["hh_arena_lava_pond"] = { "Hồ Dung Nham", "Hồ dung nham sục sôi nóng rực!", "Hồ Dung Nham" },
    ["hh_hac_nguyet_ho"] = { "Hắc Nguyệt Hồ", "Một công trình chứa cá hồ.", "Chứa và bảo quản cá hồ" },
    ["lava_pond"] = { "Hồ Dung Nham", "Hồ dung nham sục sôi nóng rực!", "Hồ Dung Nham" },
    ["hh_arena_lava_pond_rock"] = { "Đá Dung Nham", "Những tảng đá cháy xém quanh hồ dung nham.", "Đá Dung Nham" },
    ["lava_pond_rock"] = { "Đá Dung Nham", "Những tảng đá cháy xém quanh hồ dung nham.", "Đá Dung Nham" },
}

for key, data in pairs(items) do
    local upper_key = string.upper(key)
    STRINGS.NAMES[upper_key] = data[1] or "kxD"
    STRINGS.RECIPE_DESC[upper_key] = data[3] or "kxD"
    STRINGS.CHARACTERS.GENERIC.DESCRIBE[upper_key] = data[2] or "kxD"
end

-- ============================================================================
-- 2. DANH SACH TRANG BI VA VAT PHAM HO TRO (EQUIPMENTS & SUPPORT ITEMS)
-- ============================================================================
local equipments = {
    ["wb_strengthen_strengthen_6_levelpaper"] = { "Cuộn Cường Hoá +6", "cường hoá chắc chắn thành công", "Cường Hoá Tất Thành" },
    ["wb_strengthen_strengthen_7_levelpaper"] = { "Cuộn Cường Hoá +7", "cường hoá chắc chắn thành công", "Cường Hoá Tất Thành" },
    ["wb_strengthen_strengthen_8_levelpaper"] = { "Cuộn Cường Hoá +8", "cường hoá chắc chắn thành công", "Cường Hoá Tất Thành" },
    ["wb_strengthen_strengthen_9_levelpaper"] = { "Cuộn Cường Hoá +9", "cường hoá chắc chắn thành công", "Cường Hoá Tất Thành" },
    ["wb_strengthen_strengthen_10_levelpaper"] = { "Cuộn Cường Hoá +10", "cường hoá chắc chắn thành công", "Cường Hoá Tất Thành" },
    ["wb_strengthen_strengthen_11_levelpaper"] = { "Cuộn Cường Hoá +11", "cường hoá chắc chắn thành công", "Cường Hoá Tất Thành" },
    ["wb_strengthen_strengthen_12_levelpaper"] = { "Cuộn Cường Hoá +12", "cường hoá chắc chắn thành công", "Cường Hoá Tất Thành" },
    ["wb_strengthen_clearpaper"] = { "Cuộn Tẩy Tuỷ", "huh? really? serious men?", "dùng để khôi phục trang bị đã cường hoá về trang bị gốc" },
    ["nn_liquidluck"] = { "Phúc Lạc Dược I", "với nó, tôi cảm thấy như mình có thể làm mọi thứ!", "uống vào giúp tăng 5% tỷ lệ cường hóa thành công trong 30 giây" },
    ["nn_liquidluck_2"] = { "Phúc Lạc Dược II", "với nó, tôi cảm thấy như mình có thể làm mọi thứ!", "uống vào giúp tăng 15% tỷ lệ cường hóa thành công trong 90 giây" },
    ["nn_liquidluck_3"] = { "Phúc Lạc Dược III", "với nó, tôi cảm thấy như mình có thể làm mọi thứ!", "uống vào giúp tăng 25% tỷ lệ cường hóa thành công trong 270 giây" },
    ["wb_strengthen_strengthen_protectpaper"] = { "Bùa Bảo Vệ", "tôi sẽ ko dám cường hoá cao cấp nếu không có nó", "ko làm mất trang bị khi cường hoá cao cấp thất bại" },
    ["nn_magicpaper"] = { "Bùa Ma Thuật", "tôi sẽ ko dám cường hoá trung cấp nếu không có nó", "ko làm tụt cấp trang bị khi cường hoá trung cấp thất bại" },
    ["wb_enhancegem"] = { "Đá Cường Hoá", "thứ ma thuật gì đây", "dùng để cường hoá trang bị" },
    ["hh_lo_ren"] = { "Lam Phượng Luyện Khí Đài", "Nhấn để sử dụng", "nơi để cường hoá trang bị" },
    ["hh_lo_ren_build"] = { "Lam Phượng Luyện Khí Đài", "Nhấn để sử dụng", "nơi để cường hoá trang bị" },
}

for key, data in pairs(equipments) do
    local upper_key = string.upper(key)
    STRINGS.NAMES[upper_key] = data[1]
    STRINGS.NAMES[upper_key .. "_BUILD"] = data[1]
    STRINGS.CHARACTERS.GENERIC.DESCRIBE[upper_key] = data[2]
    STRINGS.RECIPE_DESC[upper_key] = data[3]
end

STRINGS["HH_LEVELING"] = {
    TITLE = "BẢNG TRẠNG THÁI",
    LEVEL = "Cấp Độ",
    EXP = "Kinh Nghiệm",
    AP = "Điểm Tiềm Năng",
    STR = "Sức Mạnh",
    AGI = "Linh Hoạt",
    VIT = "Thể Lực",
    SEN = "Cảm Quan",
    INT = "Trí Lực",
    STR_DESC = "+%d sát thương xuyên giáp",
    AGI_DESC = "+%d%% tỉ lệ né đòn",
    VIT_DESC = "+%d giảm sát thương",
    SEN_DESC = "+%d%% chí mạng / +%d%% ST chí mạng",
    INT_DESC = "-%ds hồi chiêu / -%ds hồi phục đệ tử",
}

STRINGS.HH_SANCTUARY = {
    NAME = "Thánh Vực Hồi Phục",
    ANNOUNCEMENT = "Thợ Săn %s đã mở khóa kỹ năng Thánh Vực Hồi Phục",
    COOLDOWN = "Kỹ năng Thánh Vực Hồi Phục hồi lại sau %d giây",
    NO_MANA = "Không có đủ mana để sử dụng Thánh Vực Hồi Phục",
}

STRINGS.HH_GODSLAYER = {
    NAME = "Diệt Thần",
    ANNOUNCEMENT = "Thợ Săn %s đã mở khóa kỹ năng Diệt Thần",
    COOLDOWN = "Kỹ năng Diệt Thần hồi phục sau %d giây",
    NO_MANA = "Không có đủ mana để sử dụng Diệt Thần",
}

if STRINGS.HH_RULER ~= nil and type(STRINGS.HH_RULER) ~= "table" then
    error("HH_RULER string namespace collision: expected a string table")
end
STRINGS.HH_RULER = STRINGS.HH_RULER or {}
STRINGS.HH_RULER.NAME = "Kẻ Thống Trị"
STRINGS.HH_RULER.ANNOUNCEMENT = "Thợ Săn %s đã mở khóa kỹ năng Kẻ Thống Trị"
STRINGS.HH_RULER.COOLDOWN = "Kỹ năng Kẻ Thống Trị hồi lại sau %d giây"
STRINGS.HH_RULER.NO_MANA = "Không có đủ mana để sử dụng Kẻ Thống Trị"

if STRINGS.HH_KING ~= nil and type(STRINGS.HH_KING) ~= "table" then
    error("HH_KING string namespace collision: expected a string table")
end
STRINGS.HH_KING = STRINGS.HH_KING or {}
STRINGS.HH_KING.NAME = "Nhà Vua"
STRINGS.HH_KING.ANNOUNCEMENT = "Thợ săn %s đã mở khóa kỹ năng Nhà Vua"
STRINGS.HH_KING.COOLDOWN = "Kỹ năng Nhà Vua hồi lại sau %d giây"
STRINGS.HH_KING.NO_MANA = "Không có đủ mana để sử dụng Nhà Vua"
STRINGS.HH_KING.NO_ACTIVE_SHADOW = "Phải có đệ tử đang được triệu hồi mới có thể sử dụng kỹ năng"

if STRINGS.HH_DEATH_THRESHOLD ~= nil and type(STRINGS.HH_DEATH_THRESHOLD) ~= "table" then
    error("HH_DEATH_THRESHOLD string namespace collision: expected a string table")
end
STRINGS.HH_DEATH_THRESHOLD = STRINGS.HH_DEATH_THRESHOLD or {}
STRINGS.HH_DEATH_THRESHOLD.NAME = "Ngưỡng Sinh Tử"
STRINGS.HH_DEATH_THRESHOLD.ANNOUNCEMENT = "Thợ săn %s đã mở khóa kỹ năng bị động Ngưỡng Sinh Tử"

if STRINGS.HH_SUPER_GROWTH ~= nil and type(STRINGS.HH_SUPER_GROWTH) ~= "table" then
    error("HH_SUPER_GROWTH string namespace collision: expected a string table")
end
STRINGS.HH_SUPER_GROWTH = STRINGS.HH_SUPER_GROWTH or {}
STRINGS.HH_SUPER_GROWTH.NAME = "Siêu Tăng Trưởng"
STRINGS.HH_SUPER_GROWTH.ANNOUNCEMENT = "Thợ săn %s đã mở khóa kỹ năng bị động Siêu Tăng Trưởng"

STRINGS['HH_DAILY_QUEST'] = {
    TITLE = 'NHIỆM VỤ NGÀY',
    CATEGORY = { gather='THU THẬP TÀI NGUYÊN', kill='TIÊU DIỆT QUÁI VẬT', physical='RÈN LUYỆN THỂ CHẤT' },
    STATUS = { [0]='CHƯA CÓ NHIỆM VỤ', [1]='ĐANG THỰC HIỆN', [2]='HOÀN THÀNH', [3]='THẤT BẠI' },
    PROGRESS = 'Tiến độ',
    REMAINING = 'Còn Lại',
    REWARD = 'Phần Thưởng',
    EXP_SEAL = 'Phong ấn EXP: còn %d giây',
    EXP_BLOCKED = 'EXP ĐANG BỊ PHONG ẤN',
    SLOT_LOCK_APPLIED = 'Slot %s đã bị khóa trong 1 ngày.',
    SLOT_LOCK_FAILED = 'Không thể áp dụng hình phạt khóa slot do xung đột trang bị.',
    SLOT_NAMES = { hands='Tay cầm', body='Balo/Giáp', head='Nón' },
    FAILURE = {
        timeout = 'Nhiệm vụ thất bại !',
        hunger_below_threshold = 'Chỉ số Đói đã giảm dưới mức yêu cầu.',
        sanity_below_threshold = 'Chỉ số Tinh thần đã giảm dưới mức yêu cầu.',
        health_below_threshold = 'Máu đã giảm dưới mức yêu cầu.',
    },
}

STRINGS.HH_SHADOW_SUMMON = {
    TITLE = 'TRIỆU HỒI ĐỆ TỬ',
    HINT = 'Chọn một đệ tử để Trỗi Dậy. Máy chủ sẽ xác thực lại lựa chọn.',
    EMPTY = 'Chưa có đệ tử nào sẵn sàng.',
    READY = 'Sẵn sàng triệu hồi',
    ACTIVE = 'Đang hoạt động',
    RECOVERING = 'Hồi phục sau %ds',
    GLOBAL_COOLDOWN = 'Trỗi Dậy hồi sau %ds',
    COST = 'Mana %d  |  Tinh Thần 20',
    CLOSE = 'Đóng',
    INVALID = 'Đệ tử được chọn không thuộc đội quân của bạn.',
    ACTIVE_SERVER = 'Đệ tử này đang ở bên cạnh chủ nhân.',
}

STRINGS.NAMES.HH_DAILY_SLOT_LOCK_HANDS = 'Slot Tay Cầm Bị Khóa'
STRINGS.NAMES.HH_DAILY_SLOT_LOCK_BODY = 'Slot Balo/Giáp Bị Khóa'
STRINGS.NAMES.HH_DAILY_SLOT_LOCK_HEAD = 'Slot Nón Bị Khóa'
STRINGS.HH_DAILY_SLOT_LOCK_DESCRIPTIONS = {
    hands = 'Không thể sử dụng cánh tay trong %d giây',
    body = 'Không thể mặc giáp và đeo balo trong %d giây',
    head = 'Không thể đội nón trong %d giây',
}
STRINGS.NAMES.HH_MACANH_SHADOW = 'Mặc Ảnh'
STRINGS.NAMES.HH_HACANH_SHADOW = 'Hắc Ảnh'
STRINGS.CHARACTERS.GENERIC.DESCRIBE.HH_HACANH_SHADOW = 'Một đệ tử bóng tối chuyên chiến đấu.'
STRINGS.HH_HACANH_SHADOW = { UNLOCKED = 'Đã mở khóa Hắc Ảnh !', RECALL_MANA = 'Hắc Ảnh đã bị thu hồi vì chủ nhân hết Mana.' }
STRINGS.RECIPE_DESC.HH_MACANH_SHADOW = 'Đệ tử khai thác và thu hoạch'
STRINGS.CHARACTERS.GENERIC.DESCRIBE.HH_MACANH_SHADOW = 'Một bóng ma chăm chỉ cày cuốc !'
STRINGS.HH_MACANH_SHADOW = {
    UNLOCKED = 'Đã mở khóa Mặc Ảnh !',
    SPEECH = {
        'Chủ nhân cứ nghỉ ngơi, việc khai thác cứ giao cho ta.',
        'Khoáng thạch này sẽ sớm thuộc về chủ nhân.',
        'Không một mạch quặng nào thoát khỏi mắt ta.',
        'Rừng cây đang chờ lưỡi rìu của ta.',
        'Ta sẽ dọn sạch tài nguyên trong khu vực này.',
        'Thu hoạch hoàn tất, tiếp tục mục tiêu kế tiếp.',
        'Vật phẩm rơi vãi đều sẽ được thu gom.',
        'Mệnh lệnh đã rõ: khai thác và mang về.',
        'Ta không biết mệt, chủ nhân.',
        'Tài nguyên càng nhiều, quân đoàn càng mạnh.',
        'Mỗi nhát cuốc đều phục vụ chủ nhân.',
        'Mỗi thân cây ngã xuống đều có giá trị.',
        'Ta đã phát hiện tài nguyên ở gần đây.',
        'Không để sót bất kỳ thứ gì hữu dụng.',
        'Mùa màng đã chín, để ta thu hoạch.',
        'Kho chứa của chủ nhân sẽ sớm đầy.',
        'Bóng tối cũng có thể mang về một mùa bội thu.',
        'Hãy chỉ mục tiêu, ta sẽ xử lý.',
        'Công việc vẫn đang tiến hành.',
        'Mặc Ảnh luôn sẵn sàng phụng sự.',
    },
}

STRINGS.NAMES.GUILD_STAFF = 'Nhân Viên Hiệp Hội'
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GUILD_STAFF = 'Người phụ trách Rank, nhiệm vụ và cửa hàng của Hiệp Hội.'
STRINGS.ACTIONS.HH_GUILD_OPEN = 'Làm việc với Hiệp Hội'
STRINGS.HH_GUILD = {
    TITLE = 'HIỆP HỘI THỢ SĂN',
    CREDIT = 'Xu Hiệp Hội',
    SLEEPING = 'Nhân Viên Hiệp Hội đã đi ngủ.',
}

local HH_DUNGEON_PLAYER_POTION_STRINGS = {
    HH_THUOC_SUC_MANH = { 'Thuốc Sức Mạnh', 'Tăng 15% sát thương gây ra.' },
    HH_THUOC_PHONG_TOC = { 'Thuốc Phong Tốc', 'Tăng 15% tốc độ di chuyển.' },
    HH_THUOC_LIEN_KICH = { 'Thuốc Liên Kích', 'Tăng 12% tốc độ đánh.' },
    HH_THUOC_HO_THE = { 'Thuốc Hộ Thể', 'Giảm 12% sát thương nhận vào.' },
    HH_THUOC_SINH_MENH = { 'Thuốc Sinh Mệnh', 'Tăng 20% máu tối đa.' },
    HH_THUOC_TAI_SINH = { 'Thuốc Tái Sinh', 'Hồi 1 máu mỗi giây.' },
    HH_THUOC_TINH_TAM = { 'Thuốc Tĩnh Tâm', 'Hồi 1 điểm tinh thần mỗi giây.' },
    HH_THUOC_MA_LUC = { 'Thuốc Ma Lực', 'Hồi thêm 1 mana mỗi giây.' },
    HH_THUOC_TIET_MA = { 'Thuốc Tiết Ma', 'Giảm 20% mana tiêu hao.' },
    HH_THUOC_HOC_GIA = { 'Thuốc Học Giả', 'Tăng 25% EXP từ quái ngoài Hầm ngục.' },
    HH_THUOC_CHINH_PHAT = { 'Thuốc Chinh Phạt', 'Tăng 35% EXP từ quái trong Hầm ngục.' },
    HH_THUOC_BAO_KICH = { 'Thuốc Bạo Kích', 'Tăng 8% tỉ lệ chí mạng.' },
    HH_THUOC_HAP_HUYET = { 'Thuốc Hấp Huyết', 'Hồi máu bằng 5% sát thương gây ra.' },
    HH_THUOC_KHANG_THE = { 'Thuốc Kháng Thể', 'Miễn nhiễm đóng băng, làm chậm và thiêu đốt.' },
    HH_THUOC_TOAN_NANG = { 'Thuốc Toàn Năng', 'Tăng 8% sát thương và tốc độ di chuyển; giảm 8% sát thương nhận vào.' },
}

for prefab_id, data in pairs(HH_DUNGEON_PLAYER_POTION_STRINGS) do
    STRINGS.NAMES[prefab_id] = data[1]
    STRINGS.CHARACTERS.GENERIC.DESCRIBE[prefab_id] = data[2]
end

local HH_DUNGEON_DISCIPLE_POTION_STRINGS = {
    HH_HAC_DUOC_SINH_MENH = { "Hắc Sinh Mệnh", "Toàn bộ đệ tử tăng 20% máu tối đa." },
    HH_HAC_DUOC_CONG_KICH = { "Hắc Công Kích", "Toàn bộ đệ tử tăng 15% sát thương, cộng thêm 15 sát thương cơ bản." },
    HH_HAC_DUOC_PHONG_NGU = { "Hắc Phòng Ngự", "Toàn bộ đệ tử giảm 12% sát thương nhận vào, giảm thêm 12 sát thương cố định." },
    HH_HAC_DUOC_TOC_HANH = { "Hắc Tốc Hành", "Toàn bộ đệ tử tăng 12% tốc độ di chuyển." },
    HH_HAC_DUOC_LIEN_KICH = { "Hắc Liên Kích", "Toàn bộ đệ tử tăng 10% tốc độ đánh." },
    HH_HAC_DUOC_TAI_SINH = { "Hắc Tái Sinh", "Toàn bộ đệ tử hồi 1% máu tối đa mỗi giây." },
    HH_IGRIS_THIET_VE = { "Igris Thiết Vệ", "Igris giảm 15% sát thương nhận vào." },
    HH_IGRIS_KHIEU_KHICH = { "Igris Khiêu Khích", "Igris buộc tối đa 8 kẻ địch trong bán kính 12 ưu tiên tấn công mình." },
    HH_BERU_SAN_BOSS = { "Beru Săn Boss", "Beru tăng 20% sát thương lên Boss." },
    HH_BERU_HAP_HUYET = { "Beru Hấp Huyết", "Beru hồi 15% sát thương gây ra." },
    HH_FRUITFLY_MO_RONG = { "FruitFly Mở Rộng", "FruitFly tăng bán kính chăm cây từ 20 lên 30." },
    HH_FRUITFLY_CHAM_SOC = { "FruitFly Chăm Sóc", "FruitFly giảm 50% mana khi chăm cây." },
    HH_MAC_ANH_LAO_DONG = { "Hắc Năng Suất", "Mặc Ảnh tăng 20% tốc độ di chuyển và bán kính làm việc từ 25 lên 37.5." },

    HH_QUAN_DOAN_TIET_MA = { "Quân Đoàn Ma", "Giảm 25% mana triệu hồi và duy trì đệ tử." },
}

for prefab_id, data in pairs(HH_DUNGEON_DISCIPLE_POTION_STRINGS) do
    STRINGS.NAMES[prefab_id] = data[1]
    STRINGS.CHARACTERS.GENERIC.DESCRIBE[prefab_id] = data[2]
end

local HH_DUNGEON_QOL_STRINGS = {
    HH_DEN_HAM_NGUC = { "Đèn Hầm Ngục", "Nhận một Lantern đầy nhiên liệu và 40 Light Bulb." },
    HH_SUA_VU_KHI = { "Sửa Vũ Khí", "Hồi 35% độ bền công cụ và vũ khí đang mang." },
    HH_BO_SUA_GIAP = { "Bộ Sửa Giáp", "Hồi 35% độ bền toàn bộ giáp đang mang." },
    HH_BUA_HOI_CHIEU = { "Bùa Hồi Chiêu", "Lập tức xóa hồi chiêu kỹ năng của thợ săn." },
    HH_BUA_TU_NHAT = { "Bùa Tự Nhặt", "Tự hút vật phẩm gần người trong 5 phút." },
    HH_TUI_TIEP_TE = { "Túi Tiếp Tế", "Nhận Backpack chứa sẵn bộ tiếp tế cơ bản." },
    HH_TRAI_DA_CHIEN = { "Trại Dã Chiến", "Dựng Lều gần vị trí an toàn của thợ săn." },
    HH_BO_CHONG_LANH = { "Bộ Chống Lạnh", "Làm ấm và chống tụt nhiệt trong 4 phút." },
    HH_BO_CHONG_NONG = { "Bộ Chống Nóng", "Làm mát và chống tăng nhiệt trong 4 phút." },
    HH_BUA_LAO_DONG = { "Bùa Lao Động", "Nhân đôi hiệu quả khai thác trong 8 phút." },
    HH_MAY_THU_DO = { "Máy Thu Đồ", "Hút một lần toàn bộ vật phẩm hợp lệ trong bán kính 20." },
    HH_NANG_CAP_TUI = { "Nâng Cấp Túi", "Đổi Balo thường thành Balo lạnh." },
    HH_KHAU_PHAN_AN = { "Khẩu Phần Ăn", "Hồi ngay 60 máu, 100 đói, 40 tinh thần và 40 mana." },
    HH_QUANG_MINH_THACH = { "Quang Minh Thạch", "Tạo ánh sáng cá nhân trong 10 phút." },
    HH_BUA_BEN_BI = { "Bùa Bền Bỉ", "Có 50% xác suất không hao độ bền trong 10 phút." },
    HH_PHIEU_BO_SUNG = { "Phiếu Bổ Sung", "Bổ sung 1 stock cho một món đang hết trong shop chung." },
    HH_DA_CHUYEN_SINH = { "Đá Chuyển Sinh", "Dùng tại Cổng Thiên Giới để chuyển sang nhân vật khác mà vẫn bảo toàn toàn bộ tiến trình Solo Leveling." },
}

for prefab_id, data in pairs(HH_DUNGEON_QOL_STRINGS) do
    STRINGS.NAMES[prefab_id] = data[1]
    STRINGS.CHARACTERS.GENERIC.DESCRIBE[prefab_id] = data[2]
end
