local PRODUCTS = {
    -- Thuốc người chơi (15)
    { id="dp_player_power", name="Thuốc Sức Mạnh", desc="Tăng 15% sát thương.", category="player_potion", prefab="healingsalve", prefab_id="hh_thuoc_suc_manh", price=120, stock=2, effect_id="player_power", duration=600, icon="hh_thuoc_suc_manh", visual=1, ground_anim="idle_suc_manh" },
    { id="dp_player_speed", name="Thuốc Phong Tốc", desc="Tăng 15% tốc độ di chuyển.", category="player_potion", prefab="honey", prefab_id="hh_thuoc_phong_toc", price=100, stock=2, effect_id="player_speed", duration=600, icon="hh_thuoc_phong_toc", visual=2, ground_anim="idle_phong_toc" },
    { id="dp_player_attack_speed", name="Thuốc Liên Kích", desc="Tăng 12% tốc độ đánh.", category="player_potion", prefab="berries", prefab_id="hh_thuoc_lien_kich", price=130, stock=2, effect_id="player_attack_speed", duration=600, icon="hh_thuoc_lien_kich", visual=3, ground_anim="idle_lien_kich" },
    { id="dp_player_guard", name="Thuốc Hộ Thể", desc="Giảm 12% sát thương nhận vào.", category="player_potion", prefab="bluegem", prefab_id="hh_thuoc_ho_the", price=150, stock=2, effect_id="player_guard", duration=600, icon="hh_thuoc_ho_the", visual=4, ground_anim="idle_ho_the" },
    { id="dp_player_health", name="Thuốc Sinh Mệnh", desc="Tăng 20% máu tối đa.", category="player_potion", prefab="green_cap", prefab_id="hh_thuoc_sinh_menh", price=170, stock=2, effect_id="player_health", duration=600, icon="hh_thuoc_sinh_menh", visual=5, ground_anim="idle_sinh_menh" },
    { id="dp_player_regen", name="Thuốc Tái Sinh", desc="Hồi 1 máu mỗi giây.", category="player_potion", prefab="healingsalve", prefab_id="hh_thuoc_tai_sinh", price=100, stock=2, effect_id="player_regen", duration=480, icon="hh_thuoc_tai_sinh", visual=6, ground_anim="idle_tai_sinh" },
    { id="dp_player_sanity", name="Thuốc Tĩnh Tâm", desc="Hồi 1 tinh thần mỗi giây.", category="player_potion", prefab="green_cap", prefab_id="hh_thuoc_tinh_tam", price=90, stock=2, effect_id="player_sanity", duration=480, icon="hh_thuoc_tinh_tam", visual=7, ground_anim="idle_tinh_tam" },
    { id="dp_player_mana", name="Thuốc Ma Lực", desc="Hồi thêm 1 mana mỗi giây.", category="player_potion", prefab="nightmarefuel", prefab_id="hh_thuoc_ma_luc", price=120, stock=2, effect_id="player_mana", duration=480, icon="hh_thuoc_ma_luc", visual=8, ground_anim="idle_ma_luc" },
    { id="dp_player_mana_save", name="Thuốc Tiết Ma", desc="Giảm 20% mọi tiêu hao mana.", category="player_potion", prefab="purplegem", prefab_id="hh_thuoc_tiet_ma", price=150, stock=2, effect_id="player_mana_save", duration=600, icon="hh_thuoc_tiet_ma", visual=9, ground_anim="idle_tiet_ma" },
    { id="dp_player_exp", name="Thuốc Học Giả", desc="Tăng 25% EXP tiêu diệt quái ngoài Dungeon.", category="player_potion", prefab="honey", prefab_id="hh_thuoc_hoc_gia", price=180, stock=2, effect_id="player_exp", duration=600, icon="hh_thuoc_hoc_gia", visual=10, ground_anim="idle_hoc_gia" },
    { id="dp_player_dungeon_exp", name="Thuốc Chinh Phạt", desc="Tăng 35% EXP từ quái Dungeon.", category="player_potion", prefab="nightmarefuel", prefab_id="hh_thuoc_chinh_phat", price=220, stock=2, effect_id="player_dungeon_exp", duration=600, icon="hh_thuoc_chinh_phat", visual=11, ground_anim="idle_chinh_phat" },
    { id="dp_player_crit", name="Thuốc Bạo Kích", desc="Tăng 8% tỷ lệ chí mạng.", category="player_potion", prefab="redgem", prefab_id="hh_thuoc_bao_kich", price=210, stock=2, effect_id="player_crit", duration=600, icon="hh_thuoc_bao_kich", visual=12, ground_anim="idle_bao_kich" },
    { id="dp_player_lifesteal", name="Thuốc Hấp Huyết", desc="Hồi máu bằng 5% sát thương gây ra.", category="player_potion", prefab="royal_jelly", prefab_id="hh_thuoc_hap_huyet", price=240, stock=2, effect_id="player_lifesteal", duration=480, icon="hh_thuoc_hap_huyet", visual=13, ground_anim="idle_hap_huyet" },
    { id="dp_player_cc_guard", name="Thuốc Kháng Thể", desc="Kháng đóng băng, làm chậm và thiêu đốt.", category="player_potion", prefab="amulet", prefab_id="hh_thuoc_khang_the", price=250, stock=2, effect_id="player_cc_guard", duration=480, icon="hh_thuoc_khang_the", visual=14, ground_anim="idle_khang_the" },
    { id="dp_player_allround", name="Thuốc Toàn Năng", desc="Tăng 8% sát thương, tốc độ và giảm thương.", category="player_potion", prefab="opalpreciousgem", prefab_id="hh_thuoc_toan_nang", price=300, stock=2, effect_id="player_allround", duration=480, icon="hh_thuoc_toan_nang", visual=15, ground_anim="idle_toan_nang" },

    -- Thuốc đệ tử (14)
    { id="dp_shadow_health", name="Hắc Sinh Mệnh", desc="Đệ tử tăng 20% máu tối đa.", category="disciple_potion", prefab="healingsalve", prefab_id="hh_hac_duoc_sinh_menh", price=160, stock=2, effect_id="shadow_health", duration=600, visual=16, ground_anim="idle_hac_duoc_sinh_menh" },
    { id="dp_shadow_damage", name="Hắc Công Kích", desc="Đệ tử tăng 15% ST và 15 ST cơ bản.", category="disciple_potion", prefab="redgem", prefab_id="hh_hac_duoc_cong_kich", price=180, stock=2, effect_id="shadow_damage", duration=600, visual=17, ground_anim="idle_hac_duoc_cong_kich" },
    { id="dp_shadow_guard", name="Hắc Phòng Ngự", desc="Đệ tử giảm 12% ST và 12 ST nhận vào.", category="disciple_potion", prefab="bluegem", prefab_id="hh_hac_duoc_phong_ngu", price=180, stock=2, effect_id="shadow_guard", duration=600, visual=18, ground_anim="idle_hac_duoc_phong_ngu" },
    { id="dp_shadow_speed", name="Hắc Tốc Hành", desc="Đệ tử tăng 12% tốc độ di chuyển.", category="disciple_potion", prefab="honey", prefab_id="hh_hac_duoc_toc_hanh", price=120, stock=2, effect_id="shadow_speed", duration=600, visual=19, ground_anim="idle_hac_duoc_toc_hanh" },
    { id="dp_shadow_attack_speed", name="Hắc Liên Kích", desc="Đệ tử tăng 10% tốc độ đánh.", category="disciple_potion", prefab="berries", prefab_id="hh_hac_duoc_lien_kich", price=160, stock=2, effect_id="shadow_attack_speed", duration=600, visual=20, ground_anim="idle_hac_duoc_lien_kich" },
    { id="dp_shadow_regen", name="Hắc Tái Sinh", desc="Đệ tử hồi 1% máu tối đa mỗi giây.", category="disciple_potion", prefab="royal_jelly", prefab_id="hh_hac_duoc_tai_sinh", price=130, stock=2, effect_id="shadow_regen", duration=480, visual=21, ground_anim="idle_hac_duoc_tai_sinh" },
    { id="dp_igris_guard", name="Igris Thiết Vệ", desc="Igris giảm 15% sát thương nhận vào.", category="disciple_potion", prefab="armorwood", prefab_id="hh_igris_thiet_ve", price=170, stock=2, effect_id="igris_guard", duration=600, visual=22, ground_anim="idle_igris_thiet_ve" },
    { id="dp_igris_taunt", name="Igris Khiêu Khích", desc="Igris buộc kẻ địch ưu tiên tấn công mình.", category="disciple_potion", prefab="footballhat", prefab_id="hh_igris_khieu_khich", price=180, stock=2, effect_id="igris_taunt", duration=600, visual=23, ground_anim="idle_igris_khieu_khich" },
    { id="dp_beru_boss", name="Beru Săn Boss", desc="Beru tăng 20% sát thương lên Boss.", category="disciple_potion", prefab="monstermeat", prefab_id="hh_beru_san_boss", price=240, stock=2, effect_id="beru_boss", duration=600, visual=24, ground_anim="idle_beru_san_boss" },
    { id="dp_beru_lifesteal", name="Beru Hấp Huyết", desc="Beru hồi 15% sát thương gây ra.", category="disciple_potion", prefab="batwing", prefab_id="hh_beru_hap_huyet", price=220, stock=2, effect_id="beru_lifesteal", duration=600, visual=25, ground_anim="idle_beru_hap_huyet" },
    { id="dp_fruitfly_radius", name="FruitFly Mở Rộng", desc="FruitFly tăng bán kính chăm cây từ 20 lên 30.", category="disciple_potion", prefab="seeds", prefab_id="hh_fruitfly_mo_rong", price=140, stock=2, effect_id="fruitfly_radius", duration=600, visual=26, ground_anim="idle_fruitfly_mo_rong" },
    { id="dp_fruitfly_care", name="FruitFly Chăm Sóc", desc="FruitFly giảm 50% mana khi chăm cây.", category="disciple_potion", prefab="seeds", prefab_id="hh_fruitfly_cham_soc", price=150, stock=2, effect_id="fruitfly_care", duration=600, visual=27, ground_anim="idle_fruitfly_cham_soc" },
    { id="dp_macanh_work", name="Hắc Năng Suất", desc="Mặc Ảnh tăng 20% tốc độ và bán kính", category="disciple_potion", prefab="pickaxe", prefab_id="hh_mac_anh_lao_dong", price=180, stock=2, effect_id="macanh_work", duration=600, visual=28, ground_anim="idle_mac_anh_lao_dong" },
    { id="dp_shadow_mana", name="Quân Đoàn Ma", desc="Giảm 25% mana triệu hồi và duy trì đệ tử.", category="disciple_potion", prefab="nightmarefuel", prefab_id="hh_quan_doan_tiet_ma", price=200, stock=2, effect_id="shadow_mana", duration=600, visual=30, ground_anim="idle_quan_doan_tiet_ma" },

    -- Vũ khí (7)
    { id="weapon_hh_daogam", name="Kiếm Quỷ Vương", desc="Thi triển Thiên Phạt Quỷ Vương.", category="weapon", prefab="hh_daogam", prefab_id="hh_daogam", price=50000, stock=1, shop_atlas="images/inventoryimages/hh_daogam.xml", shop_icon="hh_daogam" },
    { id="weapon_hh_daogam2", name="Hắc Ảnh Kiếm", desc="Thanh kiếm mang hình bóng hắc ám.", category="weapon", prefab="hh_daogam2", prefab_id="hh_daogam2", price=50000, stock=1, shop_atlas="images/inventoryimages/hh_daogam2.xml", shop_icon="hh_daogam2" },
    { id="weapon_hh_daogam3", name="Trượng Ma Vực", desc="Có thể bắn ra 2 tia phép thuật cùng lúc.", category="weapon", prefab="hh_daogam3", prefab_id="hh_daogam3", price=50000, stock=1, shop_atlas="images/inventoryimages/hh_daogam3.xml", shop_icon="hh_daogam3" },
    { id="weapon_hh_daogam4", name="Trượng Hỏa Ngục", desc="Có thể triệu hoán Bát Hoang Hỏa Long.", category="weapon", prefab="hh_daogam4", prefab_id="hh_daogam4", price=50000, stock=1, shop_atlas="images/hh_daogam4.xml", shop_icon="hh_daogam4" },
    { id="weapon_hh_daogam5", name="Hắc Thiên Kiếm", desc="Lưỡi kiếm được bóng tối tôi luyện.", category="weapon", prefab="hh_daogam5", prefab_id="hh_daogam5", price=50000, stock=1, shop_atlas="images/inventoryimages/hh_daogam5.xml", shop_icon="hh_daogam5" },
    { id="weapon_hh_daogam6", name="Tà Thuật Đen", desc="Vũ khí hắc ám có thể biến đổi hình dạng.", category="weapon", prefab="hh_daogam6", prefab_id="hh_daogam6", price=50000, stock=1, shop_atlas="images/hh_daogam6_inventory.xml", shop_icon="hh_daogam6_sword" },
    { id="weapon_hh_van_nang_trao", name="Vạn Năng Trảo", desc="Dụng cụ đa năng, vô cùng tiện lợi.", category="weapon", prefab="hh_van_nang_trao", prefab_id="hh_van_nang_trao", price=3000, stock=1, shop_atlas="images/nn_tools.xml", shop_icon="nn_tools" },

    -- Vật phẩm chuyên dụng / QoL (17)
    { id="dq_dungeon_lamp", name="Đèn Hầm Ngục", desc="Nhận 1 Lantern và 40 Light Bulb.", category="qol", prefab="lantern", prefab_id="hh_den_ham_nguc", price=20, stock=4, use_id="dq_dungeon_lamp", anim_type="gift", visual=31, ground_anim="idle_hh_den_ham_nguc" },
    { id="dq_weapon_repair", name="Sửa Vũ Khí", desc="Hồi 35% độ bền công cụ/vũ khí trong ô đồ.", category="qol", prefab="sewing_kit", prefab_id="hh_sua_vu_khi", price=200, stock=1, use_id="dq_weapon_repair", anim_type="sew", visual=32, ground_anim="idle_hh_sua_vu_khi" },
    { id="dq_armor_repair", name="Bộ Sửa Giáp", desc="Hồi 35% độ bền bộ giáp trong ô đồ.", category="qol", prefab="sewing_kit", prefab_id="hh_bo_sua_giap", price=200, stock=1, use_id="dq_armor_repair", anim_type="sew", visual=33, ground_anim="idle_hh_bo_sua_giap" },
    { id="dq_cooldown_charm", name="Bùa Hồi Chiêu", desc="Lập tức xóa hồi chiêu kỹ năng của thợ săn.", category="qol", prefab="purplegem", prefab_id="hh_bua_hoi_chieu", price=220, stock=2, use_id="dq_cooldown_charm", anim_type="cast", visual=34, ground_anim="idle_hh_bua_hoi_chieu" },
    { id="dq_pickup_charm", name="Bùa Tự Nhặt", desc="Tự hút vật phẩm gần người trong 5 phút.", category="qol", prefab="orangegem", prefab_id="hh_bua_tu_nhat", price=150, stock=1, use_id="dq_pickup_charm", anim_type="cast", duration=300, visual=35, ground_anim="idle_hh_bua_tu_nhat" },
    { id="dq_dungeon_bag", name="Túi Tiếp Tế", desc="Nhận Backpack chứa sẵn bộ tiếp tế cơ bản.", category="qol", prefab="backpack", prefab_id="hh_tui_tiep_te", price=150, stock=2, use_id="dq_dungeon_bag", anim_type="gift", visual=36, ground_anim="idle_hh_tui_tiep_te" },
    { id="dq_fast_camp", name="Trại Dã Chiến", desc="Dựng Lều gần vị trí an toàn của thợ săn.", category="qol", prefab="tent", prefab_id="hh_trai_da_chien", price=10, stock=3, use_id="dq_fast_camp", anim_type="gift_camp", visual=37, ground_anim="idle_hh_trai_da_chien" },
    { id="dq_cold_kit", name="Bộ Chống Lạnh", desc="Làm ấm và chống tụt nhiệt trong 4 phút.", category="qol", prefab="heatrock", prefab_id="hh_bo_chong_lanh", price=300, stock=4, use_id="dq_cold_kit", anim_type="gift", duration=240, visual=38, ground_anim="idle_hh_bo_chong_lanh" },
    { id="dq_heat_kit", name="Bộ Chống Nóng", desc="Làm mát và chống tăng nhiệt trong 4 phút.", category="qol", prefab="heatrock", prefab_id="hh_bo_chong_nong", price=300, stock=4, use_id="dq_heat_kit", anim_type="gift", duration=240, visual=39, ground_anim="idle_hh_bo_chong_nong" },
    { id="dq_work_charm", name="Bùa Lao Động", desc="Nhân đôi hiệu quả khai thác trong 8 phút.", category="qol", prefab="yellowgem", prefab_id="hh_bua_lao_dong", price=300, stock=3, use_id="dq_work_charm", anim_type="cast", duration=480, visual=40, ground_anim="idle_hh_bua_lao_dong" },
    { id="dq_loot_collector", name="Máy Thu Đồ", desc="Hút toàn bộ vật phẩm trong bán kính 20.", category="qol", prefab="krampus_sack", prefab_id="hh_may_thu_do", price=50, stock=2, use_id="dq_loot_collector", anim_type="cast", visual=41, ground_anim="idle_hh_may_thu_do" },
    { id="dq_container_upgrade", name="Nâng Cấp Túi", desc="Đổi Balo thường thành Balo lạnh.", category="qol", prefab="boards", prefab_id="hh_nang_cap_tui", price=300, stock=1, use_id="dq_container_upgrade", anim_type="gift", visual=42, ground_anim="idle_hh_nang_cap_tui" },
    { id="dq_dungeon_food", name="Khẩu Phần Ăn", desc="Hồi máu, độ no, tinh thần và mana.", category="qol", prefab="perogies", prefab_id="hh_khau_phan_an", price=30, stock=5, use_id="dq_dungeon_food", anim_type="gift", visual=43, ground_anim="idle_hh_khau_phan_an" },
    { id="dq_dungeon_light", name="Quang Minh Thạch", desc="Tạo ánh sáng cá nhân trong 10 phút.", category="qol", prefab="minerhat", prefab_id="hh_quang_minh_thach", price=300, stock=1, use_id="dq_dungeon_light", anim_type="cast", duration=600, visual=44, ground_anim="idle_hh_quang_minh_thach" },
    { id="dq_durability_charm", name="Bùa Bền Bỉ", desc="Có 50% tỉ lệ không hao độ bền trong 10 phút.", category="qol", prefab="thulecite", prefab_id="hh_bua_ben_bi", price=300, stock=1, use_id="dq_durability_charm", anim_type="cast", duration=600, visual=45, ground_anim="idle_hh_bua_ben_bi" },
    { id="dq_stock_token", name="Phiếu Bổ Sung", desc="Bổ sung 1 stock cho một món đang hết.", category="qol", prefab="goldnugget", prefab_id="hh_phieu_bo_sung", price=30, stock=3, use_id="dq_stock_token", anim_type="coin", visual=46, ground_anim="idle_hh_phieu_bo_sung" },
    { id="dq_reincarnation_stone", name="Đá Chuyển Sinh", desc="Dùng tại Cổng Thiên Giới để chuyển sang nhân vật khác mà vẫn bảo toàn toàn bộ tiến trình Solo Leveling.", category="qol", prefab_id="hh_da_chuyen_sinh", price=1000, stock=2, inventory_atlas="images/vat_pham/hh_da_chuyen_sinh_inventory.xml", inventory_icon="hh_da_chuyen_sinh_inventory", shop_atlas="images/vat_pham/hh_da_chuyen_sinh_store.xml", shop_icon="hh_da_chuyen_sinh_store", ground_bank="hh_da_chuyen_sinh", ground_build="hh_da_chuyen_sinh", ground_anim="idle_hh_da_chuyen_sinh", visual=47 },
}

local BY_ID = {}
local BY_VISUAL = {}
local BY_INDEX = {}
local INDEX_BY_ID = {}
for index, product in ipairs(PRODUCTS) do
    BY_ID[product.id] = product
    BY_INDEX[index] = product
    INDEX_BY_ID[product.id] = index
    if product.icon ~= nil then
        product.atlas = "images/potions/" .. product.icon .. ".xml"
    end
    if product.category == "player_potion" and product.icon ~= nil then
        product.shop_atlas = "images/potions/hh_thuoc_store1.xml"
        product.shop_icon = product.icon .. "_store"
    elseif product.category == "disciple_potion" and product.prefab_id ~= nil then
        product.inventory_atlas = "images/potions/hh_thuoc_de_tu_inventory.xml"
        product.inventory_icon = product.prefab_id .. "_inventory"
        product.shop_atlas = "images/potions/hh_thuoc_store2.xml"
        product.shop_icon = product.prefab_id .. "_store"
        product.ground_bank = "hh_dungeon_disciple_potions"
        product.ground_build = "hh_dungeon_disciple_potions"
    elseif product.category == "qol" and product.prefab_id ~= nil then
        product.inventory_atlas = product.inventory_atlas or "images/vat_pham/hh_vat_pham_inventory.xml"
        product.inventory_icon = product.inventory_icon or product.prefab_id .. "_inventory"
        product.shop_atlas = product.shop_atlas or "images/vat_pham/hh_vat_pham_store1.xml"
        product.shop_icon = product.shop_icon or product.prefab_id .. "_store"
        product.ground_bank = product.ground_bank or "hh_vat_pham"
        product.ground_build = product.ground_build or "hh_vat_pham"
    elseif product.category == "weapon" and product.prefab_id ~= nil then
        product.shop_atlas = "images/vu_khi/hh_vukhi_store1.xml"
        product.shop_icon = product.prefab_id .. "_store"
    end
    if product.visual ~= nil then
        BY_VISUAL[product.visual] = product
    end
end

return {
    list = PRODUCTS,
    by_id = BY_ID,
    Get = function(id) return BY_ID[id] end,
    GetByIndex = function(index) return BY_INDEX[tonumber(index)] end,
    GetIndex = function(id) return INDEX_BY_ID[id] end,
    GetByVisual = function(visual) return BY_VISUAL[visual] end,
}
