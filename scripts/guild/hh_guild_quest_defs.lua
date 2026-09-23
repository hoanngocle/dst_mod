local RANK = require("guild/hh_rank_defs").RANK

local GROUPS = {
    rocks = { rock1=true, rock2=true, rock_flintless=true, rock_flintless_med=true, rock_flintless_low=true, rock_moon=true },
    trees = { evergreen=true, evergreen_sparse=true, deciduoustree=true, twiggytree=true, moon_tree=true },
    clockworks = { knight=true, bishop=true, rook=true, knight_nightmare=true, bishop_nightmare=true, rook_nightmare=true },
    hounds = { hound=true, firehound=true, icehound=true },
    spiders = { spider=true, spider_hider=true, spider_spitter=true, spider_warrior=true },
    nightmares = { crawlinghorror=true, terrorbeak=true, crawlingnightmare=true, nightmarebeak=true },
    tentacles = { tentacle=true, bigshadowtentacle=true },
    minibosses = { spiderqueen=true, warg=true, leif=true, leif_sparse=true },
    bosses = { deerclops=true, bearger=true, moose=true, dragonfly=true, antlion=true, beequeen=true, klaus=true, minotaur=true, malbatross=true, daywalker=true, daywalker2=true },
    endgamebosses = { toadstool_dark=true, stalker_atrium=true, alterguardian_phase3=true, alterguardian_phase4_lunarrift=true },
    bees = { bee=true, killerbee=true, beeguard=true },
    seeds = {
        seeds=true, carrot_seeds=true, corn_seeds=true, pumpkin_seeds=true,
        eggplant_seeds=true, durian_seeds=true, pomegranate_seeds=true,
        dragonfruit_seeds=true, watermelon_seeds=true, potato_seeds=true,
        tomato_seeds=true, asparagus_seeds=true, onion_seeds=true,
        garlic_seeds=true, pepper_seeds=true,
    },
    fish = {
        oceanfish_small_1=true, oceanfish_small_2=true, oceanfish_small_3=true,
        oceanfish_small_4=true, oceanfish_small_5=true, oceanfish_small_6=true,
        oceanfish_medium_1=true, oceanfish_medium_2=true, oceanfish_medium_3=true,
        oceanfish_medium_4=true, oceanfish_medium_5=true, oceanfish_medium_6=true,
    },
    foods = {
        berries=true, berries_juicy=true, berries_cooked=true, berries_juicy_cooked=true,
        carrot=true, carrot_cooked=true, meat=true, cookedmeat=true,
        monstermeat=true, cookedmonstermeat=true, smallmeat=true, cookedsmallmeat=true,
        drumstick=true, drumstick_cooked=true, honeyham=true, meatballs=true,
    },
    forage_basic = { grass=true, sapling=true, berrybush=true, berrybush2=true, berrybush_juicy=true },
    cacti = { cactus=true, oasis_cactus=true },
    mushrooms = { red_mushroom=true, green_mushroom=true, blue_mushroom=true },
    tree_seeds = { pinecone=true, acorn=true, twiggy_nut=true },
    rarefish = {
        oceanfish_medium_6=true, oceanfish_medium_7=true, oceanfish_medium_8=true,
        oceanfish_small_7=true, oceanfish_small_8=true, oceanfish_small_9=true,
    },
}

local function Reward(rank, credit, prefab, amount)
    return {
        reward_credit = credit,
        reward_items = prefab and { { prefab=prefab, amount=amount or 1 } } or {},
    }
end

local Q = {
    { id=1, rank=RANK.E, title="Nhiệm vụ: Lập kho tiền tuyến", description="Nội dung: Giao cỏ, cành cây và đá lửa cho Hiệp Hội.", target=3, tracker="delivery", requirements={{prefab="cutgrass", amount=20}, {prefab="twigs", amount=20}, {prefab="flint", amount=10}}, duration_days=3, group="delivery", reward_credit=30, reward_items={{prefab="torch", amount=2}} },
    { id=2, rank=RANK.E, title="Nhiệm vụ: Cứu trợ y tế", description="Nội dung: Giao 2 Thuốc mỡ hồi phục cho Nhân Viên Hiệp Hội.", target=1, tracker="delivery", requirements={{prefab="healingsalve", amount=2}}, duration_days=3, group="delivery", reward_credit=30, reward_items={{prefab="healingsalve", amount=2}} },
    { id=3, rank=RANK.E, title="Nhiệm vụ: Tuần tra máy móc", description="Nội dung: Đánh bại 4 cỗ máy Clockwork.", target=4, tracker="killed", group="clockworks", duration_days=3, reward_credit=80, reward_items={{prefab="goldnugget", amount=20}} },
    { id=4, rank=RANK.E, title="Nhiệm vụ: Đường vận chuyển", description="Nội dung: Di chuyển 2.000 đơn vị để kiểm tra tuyến đường.", target=2000, tracker="distance", duration_days=3, reward_credit=80, reward_items={{prefab="rope", amount=10}} },

    { id=5, rank=RANK.D, title="Nhiệm vụ: Săn chó địa ngục", description="Nội dung: Đánh bại 20 Hound hoặc biến thể của chúng.", target=20, tracker="killed", group="hounds", duration_days=4, reward_credit=90, reward_items={{prefab="houndstooth", amount=20}} },
    { id=6, rank=RANK.D, title="Nhiệm vụ: Tơ và nanh", description="Nội dung: Đánh bại 35 sinh vật nhện.", target=35, tracker="killed", group="spiders", duration_days=4, reward_credit=90, reward_items={{prefab="silk", amount=20}} },
    { id=7, rank=RANK.D, title="Nhiệm vụ: Hậu cần xây dựng", description="Nội dung: Giao gỗ, đá và vàng cho công trường.", target=3, tracker="delivery", requirements={{prefab="log", amount=30}, {prefab="rocks", amount=30}, {prefab="goldnugget", amount=10}}, duration_days=4, group="delivery", reward_credit=90, reward_items={{prefab="hammer", amount=1}, {prefab="log", amount=10}, {prefab="rocks", amount=10}} },
    { id=8, rank=RANK.D, title="Nhiệm vụ: Khai khoáng tiền tuyến", description="Nội dung: Khai thác 8 tảng đá.", target=8, tracker="finishedwork", action="MINE", group="rocks", duration_days=4, reward_credit=20, reward_items={{prefab="rocks", amount=10}} },

    { id=9,  rank=RANK.C, title="Nhiệm vụ: Đêm ác mộng", description="Nội dung: Đánh bại 15 quái vật ác mộng.", target=15, tracker="killed", group="nightmares", duration_days=5, reward_credit=90, reward_items={{prefab="nightmarefuel", amount=10}} },
    { id=10, rank=RANK.C, title="Nhiệm vụ: Bản kê kỹ sư", description="Nội dung: Giao 2 Giáo và 2 Giáp gỗ cho Nhân Viên Hiệp Hội.", target=2, tracker="delivery", requirements={{prefab="spear", amount=2}, {prefab="armorwood", amount=2}}, duration_days=5, reward_credit=30, reward_items={{prefab="gears", amount=2}} },
    { id=11, rank=RANK.C, title="Nhiệm vụ: Dọn ổ bóng tối", description="Nội dung: Đánh bại 4 xúc tu.", target=4, tracker="killed", group="tentacles", duration_days=5, reward_credit=30, reward_items={{prefab="tentaclespike", amount=2}} },
    { id=12, rank=RANK.C, title="Nhiệm vụ: Kho vật liệu ma thuật", description="Nội dung: Giao tơ, nhiên liệu ác mộng và gỗ sống.", target=3, tracker="delivery", requirements={{prefab="silk", amount=15}, {prefab="nightmarefuel", amount=10}, {prefab="livinglog", amount=5}}, duration_days=5, reward_credit=100, reward_items={{prefab="thulecite_pieces", amount=24}} },

    { id=13, rank=RANK.B, title="Nhiệm vụ: Miniboss Bounty", description="Nội dung: Đánh bại 3 mục tiêu tinh anh được Hiệp Hội chỉ định.", target=3, tracker="killed", group="minibosses", duration_days=7, reward_credit=130, reward_items={{prefab="gears", amount=10}} },
    { id=14, rank=RANK.B, title="Nhiệm vụ: Lửa rừng tiền tuyến", description="Nội dung: Hoàn tất 50 lần chặt cây.", target=50, tracker="finishedwork", action="CHOP", duration_days=7, reward_credit=100, reward_items={{prefab="livinglog", amount=12}} },
    { id=15, rank=RANK.B, title="Nhiệm vụ: Cứu viện chiến trường", description="Nội dung: Giao bánh răng, gỗ sống và trái tim hồi sinh.", target=3, tracker="delivery", requirements={{prefab="gears", amount=8}, {prefab="livinglog", amount=6}, {prefab="reviver", amount=2}}, duration_days=7, reward_credit=100, reward_items={{prefab="lifeinjector", amount=3}} },
    { id=16, rank=RANK.B, title="Nhiệm vụ: Kiểm soát đàn hoang", description="Nội dung: Đánh bại 6 Beefalo.", target=6, tracker="killed", prefabs={beefalo=true}, duration_days=7, reward_credit=110, reward_items={{prefab="beefalowool", amount=15}} },

    { id=17, rank=RANK.A, title="Nhiệm vụ: Hợp đồng Trùm I", description="Nội dung: Đánh bại 2 boss thế giới ngoài dungeon.", target=2, tracker="killed", group="bosses", duration_days=9, reward_credit=150, reward_items={{prefab="dragon_scales", amount=2}} },
    { id=18, rank=RANK.A, title="Nhiệm vụ: Bộ máy cổ đại", description="Nội dung: Giao thulecite và nhiên liệu cấp cao cho xưởng.", target=3, tracker="delivery", requirements={{prefab="thulecite", amount=8}, {prefab="horrorfuel", amount=10}, {prefab="purebrilliance", amount=10}}, duration_days=9, reward_credit=160, reward_items={{prefab="thulecite", amount=8}} },
    { id=19, rank=RANK.A, title="Nhiệm vụ: Bão biển", description="Nội dung: Bắt 3 cá biển thuộc danh sách Hiệp Hội.", target=3, tracker="fishcaught", group="fish", duration_days=9, reward_credit=100, reward_items={{prefab="malbatross_feather", amount=3}} },
    { id=20, rank=RANK.A, title="Nhiệm vụ: Hành quân không gục ngã", description="Nội dung: Hồi phục tổng cộng 1.200 HP trong chiến dịch.", target=1200, tracker="healthdelta", duration_days=9, reward_credit=200, reward_items={{prefab="healingsalve", amount=10}} },

    { id=21, rank=RANK.E, title="Nhiệm vụ: Dựng trạm lửa", description="Nội dung: Dựng 3 Campfire.", target=3, tracker="buildstructure", prefabs={campfire=true}, duration_days=3, reward_credit=20, reward_items={{prefab="cutgrass", amount=20}} },
    { id=22, rank=RANK.E, title="Nhiệm vụ: Mạch khoáng khởi đầu", description="Nội dung: Khai thác 6 tảng đá.", target=6, tracker="finishedwork", action="MINE", group="rocks", duration_days=3, reward_credit=15, reward_items={{prefab="rocks", amount=5}} },
    { id=23, rank=RANK.E, title="Nhiệm vụ: Hộp lương khẩn cấp", description="Nội dung: Giao 10 món ăn đã nấu cho kho lương.", target=1, tracker="delivery", requirements={{prefab="cookedmeat", amount=10}}, duration_days=3, reward_credit=60, reward_items={{prefab="berries", amount=20}} },
    { id=24, rank=RANK.E, title="Nhiệm vụ: Người đưa tin", description="Nội dung: Di chuyển 3.000 đơn vị trong vùng hoang.", target=3000, tracker="distance", duration_days=3, reward_credit=160, reward_items={{prefab="log", amount=20}} },

    { id=25, rank=RANK.D, title="Nhiệm vụ: Vườn tiền tuyến", description="Nội dung: Trồng 20 hạt giống vanilla được Hiệp Hội chấp thuận.", target=20, tracker="deployitem", group="seeds", duration_days=4, reward_credit=80, reward_items={{prefab="compostwrap", amount=4}} },
    { id=26, rank=RANK.D, title="Nhiệm vụ: Mật ong Hiệp Hội", description="Nội dung: Thu hoạch 20 lần từ Bee Box.", target=20, tracker="harvestsomething", prefabs={beebox=true}, duration_days=4, reward_credit=300, reward_items={{prefab="honey", amount=20}} },
    { id=27, rank=RANK.D, title="Nhiệm vụ: Xưởng chống thời tiết", description="Nội dung: Chế tạo đủ Umbrella, Thermal Stone và Rain Coat, mỗi loại một lần.", target=3, tracker="builditem", prefabs={umbrella=true, heatrock=true, raincoat=true}, distinct=true, duration_days=4, reward_credit=90, reward_items={{prefab="goldnugget", amount=20}} },
    { id=28, rank=RANK.D, title="Nhiệm vụ: Bãi côn trùng", description="Nội dung: Đánh bại 20 Bee hoặc Killer Bee.", target=20, tracker="killed", group="bees", duration_days=4, reward_credit=30, reward_items={{prefab="stinger", amount=10}} },

    { id=29, rank=RANK.C, title="Nhiệm vụ: Bếp trưởng Hiệp Hội", description="Nội dung: Ăn 10 món ăn khác nhau trong danh sách hợp lệ.", target=10, tracker="oneat", group="foods", distinct=true, duration_days=5, reward_credit=100, reward_items={{prefab="honeyham", amount=4}} },
    { id=30, rank=RANK.C, title="Nhiệm vụ: Ngư dân Hiệp Hội", description="Nội dung: Bắt 20 cá biển.", target=20, tracker="fishcaught", group="fish", duration_days=5, reward_credit=300, reward_items={{prefab="fishsticks", amount=5}} },
    { id=31, rank=RANK.C, title="Nhiệm vụ: Thợ chế tác đa dụng", description="Nội dung: Chế tạo 8 công cụ hoặc vật dụng được phê duyệt.", target=8, tracker="builditem", prefabs={axe=true, pickaxe=true, shovel=true, hammer=true, spear=true, backpack=true, torch=true}, duration_days=5, reward_credit=40, reward_items={{prefab="gears", amount=3}} },
    { id=32, rank=RANK.C, title="Nhiệm vụ: Đêm tỉnh táo", description="Nội dung: Chuyển chế độ Tinh thần giữa Insanity và Lunacy 3 lần. Chỉ thay đổi điểm Tinh thần đơn thuần không được tính.", target=3, tracker="sanitymodechanged", duration_days=5, reward_credit=40, reward_items={{prefab="nightmarefuel", amount=6}} },

    { id=33, rank=RANK.B, title="Nhiệm vụ: Kỵ sĩ đồng cỏ", description="Nội dung: Lên lưng thú cưỡi 3 lần trong chiến dịch.", target=3, tracker="mounted", duration_days=7, reward_credit=30, reward_items={{prefab="beefalowool", amount=5}} },
    { id=34, rank=RANK.B, title="Nhiệm vụ: Lãnh địa ánh trăng", description="Nội dung: Ghi nhận 3 lần bước vào trạng thái lãnh địa mặt trăng.", target=3, tracker="sanitymodechanged", condition="lunar", duration_days=7, reward_credit=30, reward_items={{prefab="purebrilliance", amount=1}} },
    { id=35, rank=RANK.B, title="Nhiệm vụ: Ba trạm sinh tồn", description="Nội dung: Dựng đủ Fire Pit, Endothermic Fire Pit và Tent, mỗi loại một lần.", target=3, tracker="buildstructure", prefabs={firepit=true, coldfirepit=true, tent=true}, distinct=true, duration_days=7, reward_credit=50, reward_items={{prefab="nitre", amount=20}} },
    { id=36, rank=RANK.B, title="Nhiệm vụ: Ranh giới lửa băng", description="Nội dung: Sống sót qua 2 lần bị đốt cháy hoặc đóng băng.", target=2, tracker="condition", conditions={"onignite", "freeze"}, duration_days=7, reward_credit=30, reward_items={{prefab="bluegem", amount=2}, {prefab="redgem", amount=2}} },

    { id=37, rank=RANK.A, title="Nhiệm vụ: Thợ săn biển sâu", description="Nội dung: Bắt 3 cá hiếm trong danh sách biển sâu.", target=3, tracker="fishcaught", group="rarefish", duration_days=9, reward_credit=400, reward_items={{prefab="malbatross_feather", amount=6}} },
    { id=38, rank=RANK.A, title="Nhiệm vụ: Hành quân sinh tồn", description="Nội dung: Hồi phục tổng cộng 1.800 HP.", target=1800, tracker="healthdelta", duration_days=9, reward_credit=300, reward_items={{prefab="healingsalve", amount=4}} },

    { id=39, rank=RANK.S, title="Nhiệm vụ: Hợp đồng tận thế", description="Nội dung: Đánh bại 5 mục tiêu endgame ngoài dungeon.", target=5, tracker="killed", group="endgamebosses", duration_days=25, reward_credit=1500, reward_items={{prefab="horrorfuel", amount=15}} },
    { id=40, rank=RANK.S, title="Nhiệm vụ: Thẩm phán sáu lãnh địa", description="Nội dung: Đánh bại 6 mục tiêu tinh anh thuộc danh sách sáu lãnh địa.", target=6, tracker="killed", group="bosses", duration_days=80, reward_credit=3500, reward_items={{prefab="purebrilliance", amount=20}} },

    { id=41, rank=RANK.E, title="Nhiệm vụ: Thu gom thảo mộc", description="Nội dung: Thu hoạch 30 Bụi cỏ, Cây non hoặc Bụi quả mọng.", target=30, tracker="picksomething", group="forage_basic", duration_days=3, reward_credit=45, reward_items={{prefab="cutgrass", amount=15}} },
    { id=42, rank=RANK.E, title="Nhiệm vụ: Bếp dã chiến", description="Nội dung: Giao 8 Meatballs cho Nhân Viên Hiệp Hội.", target=1, tracker="delivery", requirements={{prefab="meatballs", amount=8}}, duration_days=3, reward_credit=60, reward_items={{prefab="honey", amount=10}} },
    { id=43, rank=RANK.E, title="Nhiệm vụ: Nghỉ ngơi đúng lúc", description="Nội dung: Ngủ 3 lần trong thời gian hợp đồng.", target=3, tracker="gotosleep", duration_days=3, reward_credit=30, reward_items={{prefab="bedroll_furry", amount=1}} },

    { id=44, rank=RANK.D, title="Nhiệm vụ: Thu hoạch sa mạc", description="Nội dung: Thu hoạch 10 Cactus.", target=10, tracker="picksomething", group="cacti", duration_days=4, reward_credit=40, reward_items={{prefab="cactus_meat", amount=5}} },
    { id=45, rank=RANK.D, title="Nhiệm vụ: Đường tơ tái sinh", description="Nội dung: Đánh bại 25 Nhện từ các tổ có khả năng sinh sản.", target=25, tracker="killed", group="spiders", duration_days=4, reward_credit=80, reward_items={{prefab="silk", amount=10}} },
    { id=46, rank=RANK.D, title="Nhiệm vụ: Bẫy tiền tuyến", description="Nội dung: Chế tạo 10 Bẫy để bổ sung kho săn bắn.", target=10, tracker="builditem", prefabs={trap=true}, duration_days=4, reward_credit=70, reward_items={{prefab="rope", amount=4}} },
    { id=47, rank=RANK.D, title="Nhiệm vụ: Kho mật dự phòng", description="Nội dung: Giao 30 Honey cho Nhân Viên Hiệp Hội.", target=1, tracker="delivery", requirements={{prefab="honey", amount=30}}, duration_days=4, reward_credit=120, reward_items={{prefab="healingsalve", amount=4}} },

    { id=48, rank=RANK.C, title="Nhiệm vụ: Mùa nấm Hiệp Hội", description="Nội dung: Thu hoạch 15 Nấm đỏ, xanh lá hoặc xanh dương.", target=15, tracker="picksomething", group="mushrooms", duration_days=5, reward_credit=100, reward_items={{prefab="blue_cap", amount=6}} },
    { id=49, rank=RANK.C, title="Nhiệm vụ: Suất ăn hồi phục", description="Nội dung: Giao 8 Meatballs và 5 Pierogi cho Nhân Viên Hiệp Hội.", target=2, tracker="delivery", requirements={{prefab="meatballs", amount=8}, {prefab="perogies", amount=5}}, duration_days=5, reward_credit=130, reward_items={{prefab="honeyham", amount=6}} },
    { id=50, rank=RANK.C, title="Nhiệm vụ: Canh gác bóng tối", description="Nội dung: Đánh bại 20 sinh vật ác mộng.", target=20, tracker="killed", group="nightmares", duration_days=5, reward_credit=100, reward_items={{prefab="nightmarefuel", amount=10}} },
    { id=51, rank=RANK.C, title="Nhiệm vụ: Trồng lại rừng", description="Nội dung: Trồng 20 Pine Cone, Birchnut hoặc Twiggy Nut để bù lại cây đã chặt.", target=20, tracker="deployitem", group="tree_seeds", duration_days=5, reward_credit=40, reward_items={{prefab="livinglog", amount=2}} },

    { id=52, rank=RANK.B, title="Nhiệm vụ: Kho giáp đa dụng", description="Nội dung: Chế tạo 4 loại giáp khác nhau theo danh sách Hiệp Hội.", target=4, tracker="builditem", prefabs={armorgrass=true, armorwood=true, armormarble=true, armorsnurtleshell=true}, distinct=true, duration_days=7, reward_credit=200, reward_items={{prefab="marble", amount=10}} },
    { id=53, rank=RANK.B, title="Nhiệm vụ: Truy lùng Varg", description="Nội dung: Đánh bại 1 Varg từ cuộc săn có thể tái xuất hiện.", target=1, tracker="killed", prefabs={warg=true}, duration_days=7, reward_credit=100, reward_items={{prefab="houndstooth", amount=20}, {prefab="redgem", amount=2}, {prefab="bluegem", amount=2}} },
    { id=54, rank=RANK.B, title="Nhiệm vụ: Ẩm thực mười lăm vùng", description="Nội dung: Ăn 15 món khác nhau trong danh sách thực phẩm tái tạo của Hiệp Hội.", target=15, tracker="oneat", group="foods", distinct=true, duration_days=7, reward_credit=300, reward_items={{prefab="jellybean", amount=3}} },
    { id=55, rank=RANK.B, title="Nhiệm vụ: Tuyến vận tải lục địa", description="Nội dung: Di chuyển 8.000 đơn vị để khảo sát tuyến tiếp tế dài ngày.", target=8000, tracker="distance", duration_days=10, reward_credit=500, reward_items={{prefab="cane", amount=1}} },

    { id=56, rank=RANK.A, title="Nhiệm vụ: Khế ước Ong Chúa", description="Nội dung: Đánh bại 1 Bee Queen theo yêu cầu hiệp hội", target=1, tracker="killed", prefabs={beequeen=true}, duration_days=10, reward_credit=400, reward_items={{prefab="royal_jelly", amount=6}} },
    { id=57, rank=RANK.A, title="Nhiệm vụ: Hậu cần ma thuật", description="Nội dung: Giao Nightmare Fuel, Living Log và Purple Gem cho Nhân Viên Hiệp Hội.", target=3, tracker="delivery", requirements={{prefab="nightmarefuel", amount=40}, {prefab="livinglog", amount=15}, {prefab="purplegem", amount=5}}, duration_days=9, reward_credit=400, reward_items={{prefab="thulecite_pieces", amount=40}} },
    { id=58, rank=RANK.A, title="Nhiệm vụ: Tam trượng ma pháp", description="Nội dung: Chế tạo đủ Fire Staff, Ice Staff và Telelocator Staff, mỗi loại một lần.", target=3, tracker="builditem", prefabs={firestaff=true, icestaff=true, telestaff=true}, distinct=true, duration_days=9, reward_credit=150, reward_items={{prefab="purplegem", amount=5}} },

    { id=59, rank=RANK.S, title="Nhiệm vụ: Hợp đồng bốn mùa", description="Nội dung: Đánh bại 4 boss khác nhau trong danh sách boss thế giới có thể tái xuất hiện.", target=4, tracker="killed", group="bosses", distinct=true, duration_days=15, reward_credit=1500, reward_items={{prefab="deerclops_eyeball", amount=2}, {prefab="dragon_scales", amount=2}} },
    { id=60, rank=RANK.S, title="Nhiệm vụ: Đại dương vô tận", description="Nội dung: Bắt 30 cá biển từ nguồn sinh vật có khả năng tái tạo.", target=30, tracker="fishcaught", group="fish", duration_days=12, reward_credit=540, reward_items={{prefab="malbatross_feather", amount=6}} },
}

local BY_ID = {}
for _, quest in ipairs(Q) do
    BY_ID[quest.id] = quest
end

return {
    list = Q,
    by_id = BY_ID,
    groups = GROUPS,
    Get = function(id)
        return BY_ID[tonumber(id)]
    end,
    MatchesGroup = function(group, prefab)
        return group ~= nil and prefab ~= nil and GROUPS[group] ~= nil and GROUPS[group][prefab] == true
    end,
}
