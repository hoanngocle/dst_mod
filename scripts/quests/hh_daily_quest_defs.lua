local Q = {
    { id=1, category="gather", difficulty="easy", title="Lâm tặc tập sự", description="Chặt hạ 20 cây hoàn chỉnh.", target=20, reward=50, tracker="finishedwork", action="CHOP", group="trees" },
    { id=2, category="gather", difficulty="medium", title="Thợ mỏ", description="Đào vỡ 3 tảng đá.", target=3, reward=10, tracker="finishedwork", action="MINE", group="rocks" },
    { id=3, category="gather", difficulty="easy", title="Gom cành", description="Thu hoạch 30 bụi cây non lấy cành.", target=30, reward=15, tracker="pick", group="saplings" },
    { id=4, category="gather", difficulty="easy", title="Dự trữ cỏ", description="Thu hoạch 30 bụi cỏ.", target=30, reward=15, tracker="pick", group="grass" },
    { id=5, category="gather", difficulty="easy", title="Quả mọng", description="Thu hoạch 15 bụi berry.", target=15, reward=20, tracker="pick", group="berries" },
    { id=6, category="gather", difficulty="easy", title="Cà rốt hoang", description="Thu thập 10 cà rốt từ tự nhiên.", target=10, reward=20, tracker="pick", group="carrots" },
    { id=7, category="gather", difficulty="medium", title="Thu hoạch đầm lầy", description="Thu hoạch 20 bụi lau sậy trong đầm lầy.", target=20, reward=30, tracker="pick", group="reeds" },
    { id=8, category="gather", difficulty="easy", title="Thợ săn nấm", description="Hái 10 cây nấm bất kỳ.", target=10, reward=25, tracker="pick", group="mushrooms" },
    { id=9, category="gather", difficulty="medium", title="Gai sa mạc", description="Thu hoạch 10 cây xương rồng.", target=10, reward=35, tracker="pick", group="cactus" },
    { id=10, category="gather", difficulty="hard", title="Tiếp tế lương thực", description="Thu hoạch 25 nguồn thức ăn từ tự nhiên.", target=25, reward=50, tracker="pick", group="wild_food" },

    { id=11, category="kill", difficulty="easy", title="Dọn ổ nhện", description="Tự tay tiêu diệt 15 con nhện.", target=15, reward=30, tracker="kill", group="spiders" },
    { id=12, category="kill", difficulty="medium", title="Săn chim", description="Tự tay tiêu diệt 10 con chim, bất kể loài nào.", target=10, reward=65, tracker="kill", group="birds" },
    { id=13, category="kill", difficulty="hard", title="Đầm lầy nguy hiểm", description="Tự tay tiêu diệt 3 xúc tu.", target=3, reward=80, tracker="kill", group="tentacles" },
    { id=14, category="kill", difficulty="easy", title="Bữa tiệc ếch", description="Tự tay tiêu diệt 10 con ếch.", target=10, reward=25, tracker="kill", group="frogs", allowed_seasons={spring=true, summer=true, autumn=true}, autumn_no_assign_last_days=3 },
    { id=15, category="kill", difficulty="medium", title="Đối đầu người heo", description="Tự tay tiêu diệt 4 Pigman hoặc Werepig.", target=4, reward=45, tracker="kill", group="pigs" },
    { id=16, category="kill", difficulty="hard", title="Quái vật bóng tối", description="Tự tay tiêu diệt 4 quái vật ác mộng.", target=4, reward=55, tracker="kill", group="nightmares" },
    { id=17, category="kill", difficulty="medium", title="Thanh trừng Merm", description="Tự tay tiêu diệt 3 Merm.", target=3, reward=50, tracker="kill", group="merms" },
    { id=18, category="kill", difficulty="medium", title="Săn thỏ", description="Tự tay tiêu diệt 8 con thỏ.", target=8, reward=30, tracker="kill", group="rabbits" },
    { id=19, category="kill", difficulty="medium", title="Hang dơi", description="Tự tay tiêu diệt 4 Bat hoặc Molebat.", target=4, reward=20, tracker="kill", group="bats", cave_only=true },
    { id=20, category="kill", difficulty="medium", title="Bầy ong dữ", description="Tự tay tiêu diệt 10 Killer Bee hoặc Bee Guard.", target=10, reward=35, tracker="kill", group="killer_bees" },

    { id=21, category="physical", difficulty="easy", title="Khởi động", description="Chạy bộ tổng cộng 1.000 đơn vị khoảng cách.", target=1000, reward=35, tracker="distance" },
    { id=22, category="physical", difficulty="medium", title="Chạy bền", description="Chạy bộ tổng cộng 1.500 đơn vị khoảng cách.", target=1500, reward=50, tracker="distance" },
    { id=23, category="physical", difficulty="hard", title="Chạy marathon", description="Chạy bộ tổng cộng 3.000 đơn vị khoảng cách.", target=3000, reward=105, tracker="distance" },
    { id=24, category="physical", difficulty="medium", title="Luyện tập ban đêm", description="Chạy bộ 750 đơn vị trong ban đêm.", target=750, reward=60, tracker="distance", night_only=true },
    { id=25, category="physical", difficulty="medium", title="Lao động cường độ cao", description="Thực hiện 120 hành động CHOP, MINE hoặc HAMMER.", target=120, reward=65, tracker="work" },
    { id=26, category="physical", difficulty="medium", title="Kỷ luật dinh dưỡng", description="Giữ Độ No từ 80% trở lên liên tục trong 480 giây.", target=480, reward=100, tracker="maintain", hunger=0.80 },
    { id=27, category="physical", difficulty="medium", title="Tâm trí vững vàng", description="Giữ Tinh thần từ 80% trở lên liên tục trong 480 giây.", target=480, reward=100, tracker="maintain", sanity=0.80 },
    { id=28, category="physical", difficulty="hard", title="Trạng thái hoàn hảo", description="Giữ Độ No và Tinh thần từ 80% trở lên liên tục trong 420 giây.", target=420, reward=150, tracker="maintain", hunger=0.80, sanity=0.80 },
    { id=29, category="physical", difficulty="hard", title="Cơ thể bất khuất", description="Giữ Máu từ 90% trở lên liên tục trong 480 giây.", target=480, reward=100, tracker="maintain", health=0.90 },
    { id=30, category="physical", difficulty="hard", title="Cardio khắc nghiệt", description="Chạy 900 đơn vị khi Độ No nằm trong khoảng 30% đến 70%.", target=900, reward=100, tracker="distance", hunger_min=0.30, hunger_max=0.70 },

    { id=31, category="craft", difficulty="easy", title="Bàn tay chế tác", description="Chế tạo 8 vật phẩm bằng các công thức.", target=8, reward=40, tracker="event", event="builditem" },
    { id=32, category="craft", difficulty="medium", title="Bậc thầy công thức", description="Chế tạo 5 vật phẩm từ công thức khác nhau.", target=5, reward=65, tracker="event", event="builditem", unique_field="recipe" },
    { id=33, category="build", difficulty="medium", title="Dựng cơ nghiệp", description="Xây dựng 5 công trình hoàn chỉnh.", target=5, reward=60, tracker="event", event="buildstructure" },
    { id=34, category="survival", difficulty="easy", title="Tiếp tế bản thân", description="Ăn 10 món ăn.", target=10, reward=40, tracker="event", event="oneat" },
    { id=35, category="survival", difficulty="medium", title="Khẩu vị đa dạng", description="Ăn 5 loại thức ăn khác nhau.", target=5, reward=55, tracker="event", event="oneat", unique_field="food" },
    { id=36, category="cooking", difficulty="medium", title="Khám phá ẩm thực", description="Học 3 công thức món ăn khác nhau từ nồi nấu.", target=3, reward=75, tracker="event", event="learncookbookrecipe", unique_field="product" },
    { id=37, category="interaction", difficulty="easy", title="Người chăm thú cưỡi", description="Cho thú cưỡi ăn 5 lần.", target=5, reward=35, tracker="event", event="feedmount" },
    { id=38, category="gather", difficulty="medium", title="Kho lương công trình", description="Thu hoạch 5 lần từ các công trình tạo sản phẩm (VD: Bee Box....)", target=5, reward=60, tracker="event", event="harvestsomething", definition_key="daily_harvestsomething_v1" },
    { id=39, category="farming", difficulty="medium", title="Gieo mầm sự sống", description="Trồng 6 hạt giống hoặc cây trồng.", target=6, reward=55, tracker="event", event="itemplanted" },
    { id=40, category="fishing", difficulty="medium", title="Cần thủ ao hồ", description="Câu và thu được 5 con cá ở ao.", target=5, reward=70, tracker="event", event="fishingcollect" },
    { id=41, category="fishing", difficulty="hard", title="Thợ săn ngoài khơi", description="Câu và thu được 4 con cá biển.", target=4, reward=100, tracker="event", event="fishcaught" },
    { id=42, category="catching", difficulty="medium", title="Bậc thầy giăng lưới", description="Bắt 5 sinh vật bằng lưới bắt.", target=5, reward=65, tracker="event", event="catch" },
    { id=43, category="equipment", difficulty="medium", title="Thợ sửa trang bị", description="Sửa chữa 3 món trang bị bằng công cụ sửa chữa.", target=3, reward=60, tracker="event", event="repair" },
    { id=44, category="knowledge", difficulty="medium", title="Học nghề qua bản thiết kế", description="Học 3 công thức khác nhau từ bản thiết kế.", target=3, reward=70, tracker="event", event="learnrecipe", unique_field="recipe", source_prefab="blueprint" },
    { id=45, category="exploration", difficulty="medium", title="Bước qua không gian", description="Dịch chuyển thành công 2 lần bằng Telelocator Staff.", target=2, reward=70, tracker="event", event="teleport_move", min_completed_quests=10, definition_key="daily_teleport_move_v1" },
    { id=46, category="inventory", difficulty="easy", title="Thu gom chiến lợi phẩm", description="Đưa 15 vật phẩm vào hành trang.", target=15, reward=40, tracker="event", event="itemget" },
    { id=47, category="inventory", difficulty="easy", title="Sắp xếp hành trang", description="Thả 10 vật phẩm khỏi hành trang.", target=10, reward=35, tracker="event", event="dropitem" },
    { id=48, category="equipment", difficulty="easy", title="Chuẩn bị hành trang", description="Trang bị 5 món đồ.", target=5, reward=50, tracker="event", event="equip" },
    { id=49, category="equipment", difficulty="easy", title="Thay đổi chiến thuật", description="Tháo 5 món đồ đang trang bị.", target=5, reward=40, tracker="event", event="unequip" },
    { id=50, category="survival", difficulty="easy", title="Nghỉ ngơi đúng lúc", description="Đi vào trạng thái ngủ 3 lần.", target=3, reward=45, tracker="event", event="gotosleep" },
    { id=51, category="survival", difficulty="easy", title="Trở lại chiến trường", description="Thức dậy sau khi ngủ 3 lần.", target=3, reward=45, tracker="event", event="onwakeup" },
    { id=52, category="combat", difficulty="medium", title="Luyện quyền chiến", description="Đánh trúng đối tượng có thể chiến đấu 20 lần.", target=20, reward=65, tracker="event", event="onhitother" },
    { id=53, category="combat", difficulty="medium", title="Chịu đòn tôi luyện", description="Chịu 8 lần bị tấn công có sát thương.", target=8, reward=50, tracker="event", event="attacked" },
    { id=54, category="farming", difficulty="medium", title="Khai luống canh tác", description="Cày 6 ô đất hợp lệ để chuẩn bị gieo trồng.", target=6, reward=55, tracker="event", event="tilling", definition_key="daily_tilling_v1" },
    { id=55, category="survival", difficulty="medium", title="Hồi phục chiến trường", description="Hồi phục tổng cộng 300 Máu bằng các nguồn hồi phục.", target=300, reward=90, tracker="event", event="healthdelta", definition_key="daily_healthdelta_v1" },
    { id=56, category="survival", difficulty="medium", title="Tâm trí dao động", description="Chuyển Tinh thần giữa Insanity và Lunacy tổng cộng 3 lần.", target=3, reward=80, tracker="event", event="sanitymodechanged", definition_key="daily_sanitymodechanged_v1" },
    { id=57, category="interaction", difficulty="medium", title="Triển khai tiện ích", description="Đặt 5 vật dụng có thể đặt xuống đất (ví dụ: Bee Mine....).", target=5, reward=75, tracker="event", event="deployitem", group="utility_deployables", definition_key="daily_deployitem_v1" },
    { id=58, category="exploration", difficulty="medium", title="Bản đồ không lặp lại", description="Khám phá 5 khu vực bản đồ khác nhau.", target=5, reward=80, tracker="event", event="changearea", unique_field="area" },
    { id=59, category="travel", difficulty="medium", title="Thuần phục thú cưỡi", description="Cưỡi thú 3 lần.", target=3, reward=55, tracker="event", event="mounted" },
    { id=60, category="travel", difficulty="easy", title="Rời yên an toàn", description="Xuống thú cưỡi 3 lần.", target=3, reward=35, tracker="event", event="dismounted" },
}

local BY_ID = {}
for _, quest in ipairs(Q) do
    BY_ID[quest.id] = quest
end

local GROUPS = {
    trees = { evergreen=true, evergreen_sparse=true, deciduoustree=true, twiggytree=true, mushtree_small=true, mushtree_medium=true, mushtree_tall=true },
    rocks = { rock1=true, rock2=true, rock_flintless=true, rock_moon=true, rock_petrified_tree=true, moonglass_rock=true },
    saplings = { sapling=true, sapling_moon=true },
    grass = { grass=true },
    berries = { berrybush=true, berrybush2=true, berrybush_juicy=true },
    carrots = { carrot_planted=true },
    reeds = { reeds=true },
    mushrooms = { red_mushroom=true, green_mushroom=true, blue_mushroom=true },
    cactus = { cactus=true, oasis_cactus=true },
    wild_food = { berrybush=true, berrybush2=true, berrybush_juicy=true, carrot_planted=true, red_mushroom=true, green_mushroom=true, blue_mushroom=true, cactus=true, oasis_cactus=true, cave_banana_tree=true, kelp=true },
    spiders = { spider=true, spider_warrior=true, spider_dropper=true, spider_hider=true, spider_spitter=true, spider_healer=true, spider_moon=true, hh_dungeon_spider=true },
    birds = { crow=true, robin=true, robin_winter=true, canary=true, quagmire_pigeon=true, puffin=true, puffin_water=true, bird_mutant=true, bird_mutant_spitter=true, mutatedbird=true },
    tentacles = { tentacle=true, tentacle_pillar=true, tentacle_pillar_arm=true },
    frogs = { frog=true },
    pigs = { pigman=true, werepig=true, pigguard=true, hh_dungeon_pig=true },
    nightmares = { crawlinghorror=true, terrorbeak=true, nightmarebeak=true, ruinsnightmare=true },
    merms = { merm=true, mermguard=true, merm_shadow=true, merm_lunar=true },
    rabbits = { rabbit=true },
    bats = { bat=true, molebat=true },
    killer_bees = { killerbee=true, beeguard=true },
    utility_deployables = {
        beemine=true, minisign_item=true, portablecookpot_item=true, portablefirepit_item=true,
        portableblender_item=true, portabletent_item=true, portablespicer_item=true,
        spidereggsack=true, trap_bramble=true, trap_fumarole=true,
        fossil_piece=true, dock_kit=true, dock_woodposts_item=true,
        fence_item=true, fence_electric_item=true, hermitcrab_relocation_kit=true,
        lureplantbulb=true, mast_item=true, rope_bridge_kit=true,
    },
}

local M = { list=Q, by_id=BY_ID, groups=GROUPS }

function M.Get(id)
    return BY_ID[id]
end

function M.Matches(group, prefab)
    return group ~= nil and prefab ~= nil and GROUPS[group] ~= nil and GROUPS[group][prefab] == true
end

return M
