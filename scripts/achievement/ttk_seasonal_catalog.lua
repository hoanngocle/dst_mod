-- Phàm Nhân Tu Tiên: curated solo activities. Params describe server evidence,
-- never client progress. Work counts completed targets, not individual swings.
local Catalog = {}
local definitions = {
{id="spring_muffin",season="spring",kind="once",name="Bánh Bướm",description="Ăn 3 bánh bướm trong mùa xuân.",event="oneat",target=3,params={prefab="butterflymuffin"},max_claims=1},
{id="spring_frogglebun",season="spring",kind="once",name="Bánh Kẹp Ếch",description="Ăn 3 bánh kẹp chân ếch.",event="oneat",target=3,params={prefab="frogglebunwich"},max_claims=1},
{id="spring_dragonpie",season="spring",kind="once",name="Bánh Thanh Long",description="Ăn 3 bánh thanh long.",event="oneat",target=3,params={prefab="dragonpie"},max_claims=1},
{id="spring_taffy",season="spring",kind="once",name="Kẹo Mật Xuân",description="Ăn 3 viên kẹo mật ong.",event="oneat",target=3,params={prefab="taffy"},max_claims=1},
{id="spring_cookie",season="spring",kind="once",name="Bánh Bí Ngô",description="Ăn 3 bánh quy bí ngô.",event="oneat",target=3,params={prefab="pumpkincookie"},max_claims=1},
{id="spring_eggplant",season="spring",kind="once",name="Cà Tím Nhồi",description="Ăn 3 phần cà tím nhồi.",event="oneat",target=3,params={prefab="stuffedeggplant"},max_claims=1},
{id="spring_ratatouille",season="spring",kind="once",name="Rau Hầm Xuân",description="Ăn 3 phần rau củ hầm.",event="oneat",target=3,params={prefab="ratatouille"},max_claims=1},
{id="spring_powcake",season="spring",kind="once",name="Bánh Bột Ngô",description="Ăn 1 chiếc bánh bột ngô Powcake.",event="oneat",target=1,params={prefab="powcake"},max_claims=1},
{id="spring_berries",season="spring",kind="once",name="Quả Mọng Tươi",description="Ăn 10 quả mọng chưa nấu.",event="oneat",target=10,params={prefab="berries"},max_claims=1},
{id="spring_carrot",season="spring",kind="once",name="Cà Rốt Tươi",description="Ăn 5 củ cà rốt chưa nấu.",event="oneat",target=5,params={prefab="carrot"},max_claims=1},
{id="spring_spider",season="spring",kind="once",name="Dọn Nhện Vườn",description="Hạ 15 nhện thường trong mùa xuân.",event="killed",target=15,params={prefab="spider"},max_claims=1},
{id="spring_warrior",season="spring",kind="once",name="Nhện Chiến Binh",description="Hạ 5 nhện chiến binh.",event="killed",target=5,params={prefab="spider_warrior"},max_claims=1},
{id="spring_tentacle",season="spring",kind="once",name="Đầm Lầy An Toàn",description="Hạ 3 xúc tu đầm lầy.",event="killed",target=3,params={prefab="tentacle"},max_claims=1},
{id="spring_merm",season="spring",kind="once",name="Ngư Nhân Đầm Lầy",description="Hạ 5 ngư nhân Merm.",event="killed",target=5,params={prefab="merm"},max_claims=1},
{id="spring_bat",season="spring",kind="once",name="Dơi Trong Hang",description="Hạ 8 con dơi trong hang.",event="killed",target=8,params={prefab="bat"},max_claims=1},
{id="spring_slurtle",season="spring",kind="once",name="Ốc Sên Giáp Nhọn",description="Hạ 2 Slurtle trong hang.",event="killed",target=2,params={prefab="slurtle"},max_claims=1},
{id="spring_snurtle",season="spring",kind="once",name="Ốc Sên Mai Tròn",description="Hạ 1 Snurtle trong hang.",event="killed",target=1,params={prefab="snurtle"},max_claims=1},
{id="spring_eyeplant",season="spring",kind="once",name="Nhổ Mắt Ăn Thịt",description="Hạ 10 mắt cây ăn thịt.",event="killed",target=10,params={prefab="eyeplant"},max_claims=1},
{id="spring_mosling",season="spring",kind="once",name="Đàn Ngỗng Non",description="Hạ 3 ngỗng non Mosling.",event="killed",target=3,params={prefab="mossling"},max_claims=1},
{id="spring_goose",season="spring",kind="once",name="Chúa Tể Mưa Xuân",description="Hạ 1 Moose/Goose trong mùa xuân.",event="killed",target=1,params={prefab="moose"},max_claims=1},
{id="spring_umbrella",season="spring",kind="once",name="Chiếc Ô Đầu Mùa",description="Chế tạo 1 chiếc ô chống mưa.",event="builditem",target=1,params={prefab="umbrella"},max_claims=1},
{id="spring_rainhat",season="spring",kind="once",name="Mũ Đi Mưa",description="Chế tạo 1 chiếc mũ đi mưa.",event="builditem",target=1,params={prefab="rainhat"},max_claims=1},
{id="spring_raincoat",season="spring",kind="once",name="Áo Đi Mưa",description="Chế tạo 1 chiếc áo đi mưa.",event="builditem",target=1,params={prefab="raincoat"},max_claims=1},
{id="spring_lightningrod",season="spring",kind="once",name="Cột Thu Lôi",description="Dựng 1 cột thu lôi bảo vệ căn cứ.",event="buildstructure",target=1,params={prefab="lightningrod"},max_claims=1},
{id="spring_fishbox",season="spring",kind="once",name="Thùng Nuôi Cá",description="Dựng 1 thùng chứa cá sống Tin Fishin' Bin.",event="buildstructure",target=1,params={prefab="fish_box"},max_claims=1},
{id="spring_fishingrod",season="spring",kind="once",name="Cần Câu Ao",description="Chế tạo 1 cần câu dùng tại ao.",event="builditem",target=1,params={prefab="fishingrod"},max_claims=1},
{id="spring_birdtrap",season="spring",kind="once",name="Bẫy Chim Xuân",description="Chế tạo 2 bẫy chim.",event="builditem",target=2,params={prefab="birdtrap"},max_claims=1},
{id="spring_bugnet",season="spring",kind="once",name="Vợt Bắt Côn Trùng",description="Chế tạo 1 vợt bắt côn trùng.",event="builditem",target=1,params={prefab="bugnet"},max_claims=1},
{id="spring_strawhat",season="spring",kind="once",name="Mũ Rơm Ra Vườn",description="Chế tạo 1 mũ rơm.",event="builditem",target=1,params={prefab="strawhat"},max_claims=1},
{id="spring_backpack",season="spring",kind="once",name="Ba Lô Thu Hái",description="Chế tạo 1 ba lô cho chuyến thu hái.",event="builditem",target=1,params={prefab="backpack"},max_claims=1},
{id="spring_berrybush",season="spring",kind="once",name="Bụi Quả Mọng",description="Thu hoạch 10 bụi quả mọng thường.",event="picksomething",target=10,params={prefab="berrybush"},max_claims=1},
{id="spring_berrybush_leaf",season="spring",kind="once",name="Quả Mọng Lá Rộng",description="Thu hoạch 10 bụi quả mọng lá rộng.",event="picksomething",target=10,params={prefab="berrybush2"},max_claims=1},
{id="spring_juicybush",season="spring",kind="once",name="Quả Mọng Mọng Nước",description="Thu hoạch 8 bụi quả mọng nước.",event="picksomething",target=8,params={prefab="berrybush_juicy"},max_claims=1},
{id="spring_redmushroom",season="spring",kind="once",name="Nấm Đỏ Ban Ngày",description="Hái 6 cây nấm đỏ.",event="picksomething",target=6,params={prefab="red_mushroom"},max_claims=1},
{id="spring_greenmushroom",season="spring",kind="once",name="Nấm Xanh Chiều Tà",description="Hái 6 cây nấm xanh lá.",event="picksomething",target=6,params={prefab="green_mushroom"},max_claims=1},
{id="spring_bluemushroom",season="spring",kind="once",name="Nấm Lam Ban Đêm",description="Hái 6 cây nấm xanh dương.",event="picksomething",target=6,params={prefab="blue_mushroom"},max_claims=1},
{id="spring_reeds",season="spring",kind="once",name="Lau Sậy Đầm Lầy",description="Thu hoạch 15 bụi lau sậy.",event="picksomething",target=15,params={prefab="reeds"},max_claims=1},
{id="spring_marshbush",season="spring",kind="once",name="Bụi Gai Đầm Lầy",description="Thu hoạch 8 bụi gai đầm lầy.",event="picksomething",target=8,params={prefab="marsh_bush"},max_claims=1},
{id="spring_fern",season="spring",kind="once",name="Dương Xỉ Trong Hang",description="Hái 10 cây dương xỉ trong hang.",event="picksomething",target=10,params={prefab="cave_fern"},max_claims=1},
{id="spring_evilflower",season="spring",kind="once",name="Hoa Tối",description="Hái 6 bông hoa ác.",event="picksomething",target=6,params={prefab="flower_evil"},max_claims=1},
{id="spring_wetgoop",season="spring",kind="repeat",name="Món Hầm Vụng Về",description="Ăn 3 phần Wet Goop mỗi lượt.",event="oneat",target=3,params={prefab="wetgoop"},max_claims=5},
{id="spring_starving",season="spring",kind="repeat",name="Bữa Ăn Cứu Đói",description="Ăn khi đang đói cạn 3 lần mỗi lượt; xét đói trước bữa ăn.",event="oneat",target=3,params={starving=true},max_claims=5},
{id="spring_bee",season="spring",kind="repeat",name="Ong Trong Vườn",description="Hạ 8 ong thường mỗi lượt.",event="killed",target=8,params={prefab="bee"},max_claims=5},
{id="spring_killerbee",season="spring",kind="repeat",name="Ong Hung Hãn",description="Hạ 8 ong sát thủ mỗi lượt.",event="killed",target=8,params={prefab="killerbee"},max_claims=5},
{id="spring_frog",season="spring",kind="repeat",name="Mưa Ếch",description="Hạ 10 con ếch mỗi lượt.",event="killed",target=10,params={prefab="frog"},max_claims=5},
{id="spring_horror",season="spring",kind="repeat",name="Bóng Bò Trườn",description="Hạ 3 Crawling Horror mỗi lượt.",event="killed",target=3,params={prefab="crawlinghorror"},max_claims=5},
{id="spring_butterfly",season="spring",kind="repeat",name="Bắt Bướm",description="Dùng vợt bắt 5 con bướm mỗi lượt.",event="finishedwork",target=5,params={action="NET",prefab="butterfly"},max_claims=5},
{id="spring_netcatches",season="spring",kind="repeat",name="Tay Vợt Khéo",description="Hoàn tất 10 lần bắt bằng vợt mỗi lượt.",event="finishedwork",target=10,params={action="NET"},max_claims=5},
{id="spring_flowers",season="spring",kind="repeat",name="Bó Hoa Xuân",description="Hái 10 bông hoa thường mỗi lượt.",event="picksomething",target=10,params={prefab="flower"},max_claims=5},
{id="spring_till",season="spring",kind="repeat",name="Luống Đất Mới",description="Cày thành công 8 ô đất mỗi lượt.",event="tilling",target=8,params={action="TILL"},max_claims=5},
{id="summer_icecream",season="summer",kind="once",name="Kem Ngày Nóng",description="Ăn 2 phần kem trong mùa hạ.",event="oneat",target=2,params={prefab="icecream"},max_claims=1},
{id="summer_watermelonicle",season="summer",kind="once",name="Kem Dưa Hấu",description="Ăn 3 que kem dưa hấu.",event="oneat",target=3,params={prefab="watermelonicle"},max_claims=1},
{id="summer_guacamole",season="summer",kind="once",name="Guacamole Mùa Hạ",description="Ăn 3 phần guacamole.",event="oneat",target=3,params={prefab="guacamole"},max_claims=1},
{id="summer_flowersalad",season="summer",kind="once",name="Salad Hoa",description="Ăn 3 phần salad hoa xương rồng.",event="oneat",target=3,params={prefab="flowersalad"},max_claims=1},
{id="summer_ceviche",season="summer",kind="once",name="Cá Ướp Lạnh",description="Ăn 3 phần ceviche.",event="oneat",target=3,params={prefab="ceviche"},max_claims=1},
{id="summer_surfnturf",season="summer",kind="once",name="Tiệc Biển Và Rừng",description="Ăn 3 phần Surf 'n' Turf.",event="oneat",target=3,params={prefab="surfnturf"},max_claims=1},
{id="summer_unagi",season="summer",kind="once",name="Lươn Nướng",description="Ăn 3 phần unagi.",event="oneat",target=3,params={prefab="unagi"},max_claims=1},
{id="summer_bananapop",season="summer",kind="once",name="Kem Chuối",description="Ăn 3 que kem chuối.",event="oneat",target=3,params={prefab="bananapop"},max_claims=1},
{id="summer_fruitmedley",season="summer",kind="once",name="Đĩa Trái Cây",description="Ăn 3 phần trái cây trộn.",event="oneat",target=3,params={prefab="fruitmedley"},max_claims=1},
{id="summer_watermelon",season="summer",kind="once",name="Dưa Hấu Nướng",description="Ăn 5 miếng dưa hấu đã nấu.",event="oneat",target=5,params={prefab="watermelon_cooked"},max_claims=1},
{id="summer_hound",season="summer",kind="once",name="Đàn Chó Săn",description="Hạ 12 chó săn thường.",event="killed",target=12,params={prefab="hound"},max_claims=1},
{id="summer_firehound",season="summer",kind="once",name="Chó Săn Lửa",description="Hạ 5 chó săn lửa.",event="killed",target=5,params={prefab="firehound"},max_claims=1},
{id="summer_dropper",season="summer",kind="once",name="Nhện Treo Hang",description="Hạ 5 nhện thả từ trần hang.",event="killed",target=5,params={prefab="spider_dropper"},max_claims=1},
{id="summer_spitter",season="summer",kind="once",name="Nhện Phun Tơ",description="Hạ 5 nhện phun tơ trong hang.",event="killed",target=5,params={prefab="spider_spitter"},max_claims=1},
{id="summer_bunnyman",season="summer",kind="once",name="Thỏ Người",description="Hạ 5 thỏ người Bunnyman.",event="killed",target=5,params={prefab="bunnyman"},max_claims=1},
{id="summer_tallbird",season="summer",kind="once",name="Chim Chân Dài",description="Hạ 3 chim Tallbird.",event="killed",target=3,params={prefab="tallbird"},max_claims=1},
{id="summer_antlion",season="summer",kind="once",name="Chúa Cát",description="Hạ 1 Antlion trong mùa hạ.",event="killed",target=1,params={prefab="antlion"},max_claims=1},
{id="summer_dragonfly",season="summer",kind="once",name="Rồng Sa Mạc",description="Hạ 1 Dragonfly tại sa mạc.",event="killed",target=1,params={prefab="dragonfly"},max_claims=1},
{id="summer_warg",season="summer",kind="once",name="Đầu Đàn Chó Săn",description="Hạ 1 Varg dẫn đàn chó săn.",event="killed",target=1,params={prefab="warg"},max_claims=1},
{id="summer_queen",season="summer",kind="once",name="Nữ Hoàng Nhện",description="Hạ 1 nữ hoàng nhện.",event="killed",target=1,params={prefab="spiderqueen"},max_claims=1},
{id="summer_coldfire",season="summer",kind="once",name="Bếp Lửa Lạnh",description="Dựng 1 bếp lửa thu nhiệt cố định.",event="buildstructure",target=1,params={prefab="coldfirepit"},max_claims=1},
{id="summer_icebox",season="summer",kind="once",name="Tủ Lạnh Mùa Hạ",description="Dựng 1 tủ lạnh bảo quản thức ăn.",event="buildstructure",target=1,params={prefab="icebox"},max_claims=1},
{id="summer_watermelonhat",season="summer",kind="once",name="Mũ Dưa Hấu",description="Chế tạo 1 mũ dưa hấu.",event="builditem",target=1,params={prefab="watermelonhat"},max_claims=1},
{id="summer_featherfan",season="summer",kind="once",name="Quạt Lông Vũ",description="Chế tạo 1 quạt lông vũ.",event="builditem",target=1,params={prefab="featherfan"},max_claims=1},
{id="summer_icehat",season="summer",kind="once",name="Mũ Băng",description="Chế tạo 1 khối băng đội đầu.",event="builditem",target=1,params={prefab="icehat"},max_claims=1},
{id="summer_goggles",season="summer",kind="once",name="Kính Thời Trang",description="Chế tạo 1 kính thời trang tại ốc đảo.",event="builditem",target=1,params={prefab="goggleshat"},max_claims=1},
{id="summer_deserthat",season="summer",kind="once",name="Kính Sa Mạc",description="Chế tạo 1 kính chống bão cát.",event="builditem",target=1,params={prefab="deserthat"},max_claims=1},
{id="summer_wateringcan",season="summer",kind="once",name="Bình Tưới Vườn",description="Chế tạo 1 bình tưới thường.",event="builditem",target=1,params={prefab="wateringcan"},max_claims=1},
{id="summer_farmhoe",season="summer",kind="once",name="Cuốc Làm Vườn",description="Chế tạo 1 cuốc làm vườn.",event="builditem",target=1,params={prefab="farm_hoe"},max_claims=1},
{id="summer_flingomatic",season="summer",kind="once",name="Máy Dập Lửa",description="Dựng 1 máy ném tuyết bảo vệ căn cứ.",event="buildstructure",target=1,params={prefab="firesuppressor"},max_claims=1},
{id="summer_rock",season="summer",kind="once",name="Đá Ven Sa Mạc",description="Đào vỡ 8 tảng đá thường.",event="finishedwork",target=8,params={action="MINE",prefab="rock1"},max_claims=1},
{id="summer_goldrock",season="summer",kind="once",name="Mạch Vàng",description="Đào vỡ 6 tảng đá chứa vàng.",event="finishedwork",target=6,params={action="MINE",prefab="rock2"},max_claims=1},
{id="summer_flintless",season="summer",kind="once",name="Đá Không Đá Lửa",description="Đào vỡ 6 tảng đá không chứa đá lửa.",event="finishedwork",target=6,params={action="MINE",prefab="rock_flintless"},max_claims=1},
{id="summer_moonrock",season="summer",kind="once",name="Thiên Thạch Mặt Trăng",description="Đào vỡ 3 tảng đá mặt trăng.",event="finishedwork",target=3,params={action="MINE",prefab="rock_moon"},max_claims=1},
{id="summer_stonefruitbush",season="summer",kind="once",name="Bụi Quả Đá",description="Thu hoạch 8 bụi quả đá trên đảo trăng.",event="picksomething",target=8,params={prefab="rock_avocado_bush"},max_claims=1},
{id="summer_palm",season="summer",kind="once",name="Gỗ Cọ Bờ Biển",description="Chặt hạ 5 cây cọ Palmcone.",event="finishedwork",target=5,params={action="CHOP",prefab="palmconetree"},max_claims=1},
{id="summer_farmwatermelon",season="summer",kind="once",name="Vụ Dưa Hấu",description="Thu hoạch 6 cây dưa hấu trong vườn.",event="picksomething",target=6,params={prefab="farm_plant_watermelon"},max_claims=1},
{id="summer_farmdragonfruit",season="summer",kind="once",name="Vụ Thanh Long",description="Thu hoạch 6 cây thanh long trong vườn.",event="picksomething",target=6,params={prefab="farm_plant_dragonfruit"},max_claims=1},
{id="summer_farmpomegranate",season="summer",kind="once",name="Vụ Lựu",description="Thu hoạch 6 cây lựu trong vườn.",event="picksomething",target=6,params={prefab="farm_plant_pomegranate"},max_claims=1},
{id="summer_farmdurian",season="summer",kind="once",name="Vụ Sầu Riêng",description="Thu hoạch 6 cây sầu riêng trong vườn.",event="picksomething",target=6,params={prefab="farm_plant_durian"},max_claims=1},
{id="summer_jam",season="summer",kind="repeat",name="Mứt Quả Mùa Hạ",description="Ăn 3 phần mứt quả mỗi lượt.",event="oneat",target=3,params={prefab="jammypreserves"},max_claims=5},
{id="summer_pierogi",season="summer",kind="repeat",name="Bánh Xếp Hồi Sức",description="Ăn 3 phần bánh xếp mỗi lượt.",event="oneat",target=3,params={prefab="perogies"},max_claims=5},
{id="summer_mosquito",season="summer",kind="repeat",name="Dẹp Muỗi",description="Hạ 8 con muỗi mỗi lượt.",event="killed",target=8,params={prefab="mosquito"},max_claims=5},
{id="summer_stonefruit",season="summer",kind="repeat",name="Tách Quả Đá",description="Đập mở 10 quả đá mỗi lượt.",event="finishedwork",target=10,params={action="MINE",prefab="rock_avocado_fruit"},max_claims=5},
{id="summer_hammer",season="summer",kind="repeat",name="Tháo Dỡ Công Trình",description="Hoàn tất 5 lần phá bằng búa mỗi lượt.",event="finishedwork",target=5,params={action="HAMMER"},max_claims=5},
{id="summer_banana",season="summer",kind="repeat",name="Chuối Trong Hang",description="Thu hoạch 6 cây chuối hang mỗi lượt.",event="picksomething",target=6,params={prefab="cave_banana_tree"},max_claims=5},
{id="summer_monkeytail",season="summer",kind="repeat",name="Cỏ Đuôi Khỉ",description="Thu hoạch 8 cây đuôi khỉ mỗi lượt.",event="picksomething",target=8,params={prefab="monkeytail"},max_claims=5},
{id="summer_cactus",season="summer",kind="repeat",name="Xương Rồng Sa Mạc",description="Thu hoạch 8 cây xương rồng thường mỗi lượt.",event="picksomething",target=8,params={prefab="cactus"},max_claims=5},
{id="summer_oasiscactus",season="summer",kind="repeat",name="Xương Rồng Ốc Đảo",description="Thu hoạch 8 cây xương rồng ốc đảo mỗi lượt.",event="picksomething",target=8,params={prefab="oasis_cactus"},max_claims=5},
{id="summer_row",season="summer",kind="repeat",name="Tay Chèo Mùa Hạ",description="Thực hiện thành công 30 nhịp chèo thuyền mỗi lượt.",event="rowing",target=30,params={action="ROW"},max_claims=5},
{id="autumn_roastberries",season="autumn",kind="once",name="Quả Mọng Nướng",description="Ăn 10 quả mọng đã nấu.",event="oneat",target=10,params={prefab="berries_cooked"},max_claims=1},
{id="autumn_juicyberries",season="autumn",kind="once",name="Quả Mọng Nước Tươi",description="Ăn 10 quả mọng nước chưa nấu.",event="oneat",target=10,params={prefab="berries_juicy"},max_claims=1},
{id="autumn_roastjuicy",season="autumn",kind="once",name="Quả Mọng Nước Nướng",description="Ăn 10 quả mọng nước đã nấu.",event="oneat",target=10,params={prefab="berries_juicy_cooked"},max_claims=1},
{id="autumn_roastcarrot",season="autumn",kind="once",name="Cà Rốt Nướng",description="Ăn 5 củ cà rốt đã nấu.",event="oneat",target=5,params={prefab="carrot_cooked"},max_claims=1},
{id="autumn_corn",season="autumn",kind="once",name="Bắp Tươi",description="Ăn 5 bắp ngô chưa nấu.",event="oneat",target=5,params={prefab="corn"},max_claims=1},
{id="autumn_popcorn",season="autumn",kind="once",name="Bắp Rang",description="Ăn 5 phần bắp rang.",event="oneat",target=5,params={prefab="corn_cooked"},max_claims=1},
{id="autumn_pumpkin",season="autumn",kind="once",name="Bí Ngô Tươi",description="Ăn 5 quả bí ngô chưa nấu.",event="oneat",target=5,params={prefab="pumpkin"},max_claims=1},
{id="autumn_roastpumpkin",season="autumn",kind="once",name="Bí Ngô Nướng",description="Ăn 5 phần bí ngô đã nấu.",event="oneat",target=5,params={prefab="pumpkin_cooked"},max_claims=1},
{id="autumn_dragonfruit",season="autumn",kind="once",name="Thanh Long Tươi",description="Ăn 3 quả thanh long chưa nấu.",event="oneat",target=3,params={prefab="dragonfruit"},max_claims=1},
{id="autumn_roastdragonfruit",season="autumn",kind="once",name="Thanh Long Nướng",description="Ăn 3 quả thanh long đã nấu.",event="oneat",target=3,params={prefab="dragonfruit_cooked"},max_claims=1},
{id="autumn_pigman",season="autumn",kind="once",name="Thợ Săn Lợn",description="Hạ 5 người lợn thường.",event="killed",target=5,params={prefab="pigman"},max_claims=1},
{id="autumn_pigguard",season="autumn",kind="once",name="Lính Gác Lợn",description="Hạ 2 lính gác lợn.",event="killed",target=2,params={prefab="pigguard"},max_claims=1},
{id="autumn_beefalo",season="autumn",kind="once",name="Săn Beefalo",description="Hạ 3 Beefalo hoang dã.",event="killed",target=3,params={prefab="beefalo"},max_claims=1},
{id="autumn_goat",season="autumn",kind="once",name="Dê Điện",description="Hạ 3 dê điện Lightning Goat.",event="killed",target=3,params={prefab="lightninggoat"},max_claims=1},
{id="autumn_koalefant",season="autumn",kind="once",name="Dấu Chân Voi",description="Hạ 1 Koalefant không có lông mùa đông.",event="killed",target=1,params={prefab="koalefant_summer"},max_claims=1},
{id="autumn_catcoon",season="autumn",kind="once",name="Mèo Gấu Rừng",description="Hạ 3 Catcoon trong rừng bạch dương.",event="killed",target=3,params={prefab="catcoon"},max_claims=1},
{id="autumn_mole",season="autumn",kind="once",name="Chuột Chũi",description="Hạ 5 chuột chũi.",event="killed",target=5,params={prefab="mole"},max_claims=1},
{id="autumn_rabbit",season="autumn",kind="once",name="Thỏ Đồng",description="Hạ 8 con thỏ đồng.",event="killed",target=8,params={prefab="rabbit"},max_claims=1},
{id="autumn_grassgekko",season="autumn",kind="once",name="Thằn Lằn Cỏ",description="Hạ 5 thằn lằn cỏ Grass Gekko.",event="killed",target=5,params={prefab="grassgekko"},max_claims=1},
{id="autumn_bearger",season="autumn",kind="once",name="Gấu Lửng Mùa Thu",description="Hạ 1 Bearger trong mùa thu.",event="killed",target=1,params={prefab="bearger"},max_claims=1},
{id="autumn_axe",season="autumn",kind="once",name="Rìu Khai Hoang",description="Chế tạo 2 chiếc rìu thường.",event="builditem",target=2,params={prefab="axe"},max_claims=1},
{id="autumn_pickaxe",season="autumn",kind="once",name="Cuốc Khai Mỏ",description="Chế tạo 2 cuốc chim thường.",event="builditem",target=2,params={prefab="pickaxe"},max_claims=1},
{id="autumn_shovel",season="autumn",kind="once",name="Xẻng Làm Vườn",description="Chế tạo 2 chiếc xẻng thường.",event="builditem",target=2,params={prefab="shovel"},max_claims=1},
{id="autumn_hammer",season="autumn",kind="once",name="Búa Của Thợ",description="Chế tạo 1 chiếc búa.",event="builditem",target=1,params={prefab="hammer"},max_claims=1},
{id="autumn_spear",season="autumn",kind="once",name="Giáo Phòng Thân",description="Chế tạo 2 cây giáo thường.",event="builditem",target=2,params={prefab="spear"},max_claims=1},
{id="autumn_logarmor",season="autumn",kind="once",name="Áo Giáp Gỗ",description="Chế tạo 2 bộ giáp gỗ.",event="builditem",target=2,params={prefab="armorwood"},max_claims=1},
{id="autumn_footballhat",season="autumn",kind="once",name="Mũ Bảo Hộ",description="Chế tạo 2 mũ bóng bầu dục.",event="builditem",target=2,params={prefab="footballhat"},max_claims=1},
{id="autumn_chest",season="autumn",kind="once",name="Kho Dự Trữ",description="Dựng 3 rương gỗ chứa vật tư.",event="buildstructure",target=3,params={prefab="treasurechest"},max_claims=1},
{id="autumn_cookpot",season="autumn",kind="once",name="Bếp Thu Hoạch",description="Dựng 1 nồi hầm.",event="buildstructure",target=1,params={prefab="cookpot"},max_claims=1},
{id="autumn_science",season="autumn",kind="once",name="Máy Khoa Học",description="Dựng 1 máy khoa học.",event="buildstructure",target=1,params={prefab="researchlab"},max_claims=1},
{id="autumn_farmpumpkin",season="autumn",kind="once",name="Thu Hoạch Bí Ngô",description="Thu hoạch 8 cây bí ngô trong vườn.",event="picksomething",target=8,params={prefab="farm_plant_pumpkin"},max_claims=1},
{id="autumn_farmcorn",season="autumn",kind="once",name="Thu Hoạch Bắp",description="Thu hoạch 8 cây ngô trong vườn.",event="picksomething",target=8,params={prefab="farm_plant_corn"},max_claims=1},
{id="autumn_farmcarrot",season="autumn",kind="once",name="Thu Hoạch Cà Rốt",description="Thu hoạch 8 cây cà rốt trong vườn.",event="picksomething",target=8,params={prefab="farm_plant_carrot"},max_claims=1},
{id="autumn_farmpotato",season="autumn",kind="once",name="Thu Hoạch Khoai Tây",description="Thu hoạch 8 cây khoai tây trong vườn.",event="picksomething",target=8,params={prefab="farm_plant_potato"},max_claims=1},
{id="autumn_farmgarlic",season="autumn",kind="once",name="Thu Hoạch Tỏi",description="Thu hoạch 6 cây tỏi trong vườn.",event="picksomething",target=6,params={prefab="farm_plant_garlic"},max_claims=1},
{id="autumn_farmonion",season="autumn",kind="once",name="Thu Hoạch Hành",description="Thu hoạch 6 cây hành trong vườn.",event="picksomething",target=6,params={prefab="farm_plant_onion"},max_claims=1},
{id="autumn_farmtomato",season="autumn",kind="once",name="Thu Hoạch Cà Chua",description="Thu hoạch 8 cây cà chua trong vườn.",event="picksomething",target=8,params={prefab="farm_plant_tomato"},max_claims=1},
{id="autumn_farmeggplant",season="autumn",kind="once",name="Thu Hoạch Cà Tím",description="Thu hoạch 6 cây cà tím trong vườn.",event="picksomething",target=6,params={prefab="farm_plant_eggplant"},max_claims=1},
{id="autumn_farmasparagus",season="autumn",kind="once",name="Thu Hoạch Măng Tây",description="Thu hoạch 6 cây măng tây trong vườn.",event="picksomething",target=6,params={prefab="farm_plant_asparagus"},max_claims=1},
{id="autumn_farmpepper",season="autumn",kind="once",name="Thu Hoạch Ớt",description="Thu hoạch 6 cây ớt trong vườn.",event="picksomething",target=6,params={prefab="farm_plant_pepper"},max_claims=1},
{id="autumn_honeyham",season="autumn",kind="repeat",name="Giăm Bông Mật Ong",description="Ăn 3 phần giăm bông mật ong mỗi lượt.",event="oneat",target=3,params={prefab="honeyham"},max_claims=5},
{id="autumn_honeynuggets",season="autumn",kind="repeat",name="Thịt Viên Mật Ong",description="Ăn 3 phần thịt viên mật ong mỗi lượt.",event="oneat",target=3,params={prefab="honeynuggets"},max_claims=5},
{id="autumn_trailmix",season="autumn",kind="repeat",name="Lương Khô Đường Rừng",description="Ăn 3 phần hỗn hợp hạt và quả mỗi lượt.",event="oneat",target=3,params={prefab="trailmix"},max_claims=5},
{id="autumn_crow",season="autumn",kind="repeat",name="Quạ Đồng",description="Hạ 5 con quạ mỗi lượt.",event="killed",target=5,params={prefab="crow"},max_claims=5},
{id="autumn_redbird",season="autumn",kind="repeat",name="Chim Đỏ",description="Hạ 5 chim đỏ mỗi lượt.",event="killed",target=5,params={prefab="robin"},max_claims=5},
{id="autumn_birchnut",season="autumn",kind="repeat",name="Gỗ Bạch Dương",description="Chặt hạ 8 cây bạch dương mỗi lượt.",event="finishedwork",target=8,params={action="CHOP",prefab="deciduoustree"},max_claims=5},
{id="autumn_chop",season="autumn",kind="repeat",name="Thợ Đốn Củi",description="Hoàn tất 12 lần chặt cây mỗi lượt.",event="finishedwork",target=12,params={action="CHOP"},max_claims=5},
{id="autumn_grass",season="autumn",kind="repeat",name="Bó Cỏ Khô",description="Thu hoạch 20 bụi cỏ mỗi lượt.",event="picksomething",target=20,params={prefab="grass"},max_claims=5},
{id="autumn_sapling",season="autumn",kind="repeat",name="Cành Cây Dự Trữ",description="Thu hoạch 20 cây non mỗi lượt.",event="picksomething",target=20,params={prefab="sapling"},max_claims=5},
{id="autumn_plantbirchnut",season="autumn",kind="repeat",name="Gieo Rừng Mới",description="Trồng thành công 8 hạt bạch dương mỗi lượt.",event="deployitem",target=8,params={action="DEPLOY",prefab="acorn"},max_claims=5},
{id="winter_chili",season="winter",kind="once",name="Ớt Hầm Giữ Ấm",description="Ăn 3 phần ớt hầm cay.",event="oneat",target=3,params={prefab="hotchili"},max_claims=1},
{id="winter_baconeggs",season="winter",kind="once",name="Trứng Thịt No Lâu",description="Ăn 3 phần thịt xông khói và trứng.",event="oneat",target=3,params={prefab="baconeggs"},max_claims=1},
{id="winter_fishsticks",season="winter",kind="once",name="Que Cá Nóng",description="Ăn 3 phần que cá.",event="oneat",target=3,params={prefab="fishsticks"},max_claims=1},
{id="winter_turkeydinner",season="winter",kind="once",name="Tiệc Gà Tây",description="Ăn 2 phần tiệc gà tây.",event="oneat",target=2,params={prefab="turkeydinner"},max_claims=1},
{id="winter_waffles",season="winter",kind="once",name="Bánh Waffle",description="Ăn 1 phần bánh waffle.",event="oneat",target=1,params={prefab="waffles"},max_claims=1},
{id="winter_cookedmeat",season="winter",kind="once",name="Thịt Nướng Bên Lửa",description="Ăn 8 miếng thịt lớn đã nấu.",event="oneat",target=8,params={prefab="cookedmeat"},max_claims=1},
{id="winter_smallmeat",season="winter",kind="once",name="Miếng Thịt Nhỏ",description="Ăn 8 miếng thịt nhỏ đã nấu.",event="oneat",target=8,params={prefab="cookedsmallmeat"},max_claims=1},
{id="winter_monstermeat",season="winter",kind="once",name="Thịt Quái Nướng",description="Ăn 3 miếng thịt quái vật đã nấu.",event="oneat",target=3,params={prefab="cookedmonstermeat"},max_claims=1},
{id="winter_cookedfish",season="winter",kind="once",name="Cá Nướng Mùa Đông",description="Ăn 5 con cá ao đã nấu.",event="oneat",target=5,params={prefab="fish_cooked"},max_claims=1},
{id="winter_cookedeel",season="winter",kind="once",name="Lươn Nướng Than",description="Ăn 3 con lươn đã nấu.",event="oneat",target=3,params={prefab="eel_cooked"},max_claims=1},
{id="winter_icehound",season="winter",kind="once",name="Chó Săn Băng",description="Hạ 5 chó săn băng.",event="killed",target=5,params={prefab="icehound"},max_claims=1},
{id="winter_koalefant",season="winter",kind="once",name="Voi Lông Dày",description="Hạ 1 Koalefant mùa đông.",event="killed",target=1,params={prefab="koalefant_winter"},max_claims=1},
{id="winter_walrus",season="winter",kind="once",name="Thợ Săn Hải Mã",description="Hạ 2 MacTusk trong mùa đông.",event="killed",target=2,params={prefab="walrus"},max_claims=1},
{id="winter_littlewalrus",season="winter",kind="once",name="Hải Mã Con",description="Hạ 2 Wee MacTusk trong mùa đông.",event="killed",target=2,params={prefab="little_walrus"},max_claims=1},
{id="winter_treeguard",season="winter",kind="once",name="Thần Rừng Thông",description="Hạ 1 Treeguard thường.",event="killed",target=1,params={prefab="leif"},max_claims=1},
{id="winter_lumpytreeguard",season="winter",kind="once",name="Thần Rừng Thưa",description="Hạ 1 Treeguard từ cây thông thưa.",event="killed",target=1,params={prefab="leif_sparse"},max_claims=1},
{id="winter_terrorbeak",season="winter",kind="once",name="Mỏ Kinh Hoàng",description="Hạ 3 Terrorbeak do mất tỉnh táo.",event="killed",target=3,params={prefab="terrorbeak"},max_claims=1},
{id="winter_deerclops",season="winter",kind="once",name="Người Khổng Lồ Một Mắt",description="Hạ 1 Deerclops trong mùa đông.",event="killed",target=1,params={prefab="deerclops"},max_claims=1},
{id="winter_krampus",season="winter",kind="once",name="Kẻ Trộm Mùa Đông",description="Hạ 1 Krampus sau khi tích lũy độ nghịch.",event="killed",target=1,params={prefab="krampus"},max_claims=1},
{id="winter_rook",season="winter",kind="once",name="Xe Máy Canh Gác",description="Hạ 2 quân xe máy Clockwork Rook.",event="killed",target=2,params={prefab="rook"},max_claims=1},
{id="winter_heatrock",season="winter",kind="once",name="Đá Giữ Nhiệt",description="Chế tạo 1 viên đá giữ nhiệt.",event="builditem",target=1,params={prefab="heatrock"},max_claims=1},
{id="winter_winterhat",season="winter",kind="once",name="Mũ Len Mùa Đông",description="Chế tạo 1 mũ mùa đông.",event="builditem",target=1,params={prefab="winterhat"},max_claims=1},
{id="winter_beefalohat",season="winter",kind="once",name="Mũ Lông Beefalo",description="Chế tạo 1 mũ Beefalo giữ ấm.",event="builditem",target=1,params={prefab="beefalohat"},max_claims=1},
{id="winter_trunkvest",season="winter",kind="once",name="Áo Lông Dày",description="Chế tạo 1 áo voi mùa đông.",event="builditem",target=1,params={prefab="trunkvest_winter"},max_claims=1},
{id="winter_bandage",season="winter",kind="once",name="Băng Mật Ong",description="Chế tạo 3 băng mật ong.",event="builditem",target=3,params={prefab="bandage"},max_claims=1},
{id="winter_salve",season="winter",kind="once",name="Thuốc Bôi Vết Thương",description="Chế tạo 3 thuốc bôi hồi máu.",event="builditem",target=3,params={prefab="healingsalve"},max_claims=1},
{id="winter_firepit",season="winter",kind="once",name="Bếp Sưởi Đá",description="Dựng 1 bếp lửa đá.",event="buildstructure",target=1,params={prefab="firepit"},max_claims=1},
{id="winter_lantern",season="winter",kind="once",name="Đèn Lồng Đêm Dài",description="Chế tạo 1 đèn lồng.",event="builditem",target=1,params={prefab="lantern"},max_claims=1},
{id="winter_minerhat",season="winter",kind="once",name="Mũ Đèn Thợ Mỏ",description="Chế tạo 1 mũ đèn thợ mỏ.",event="builditem",target=1,params={prefab="minerhat"},max_claims=1},
{id="winter_tent",season="winter",kind="once",name="Lều Trú Đông",description="Dựng 1 lều nghỉ tại căn cứ.",event="buildstructure",target=1,params={prefab="tent"},max_claims=1},
{id="winter_ice",season="winter",kind="once",name="Dự Trữ Băng",description="Nhận vào hành trang tổng cộng 30 viên băng.",event="itemget",target=30,params={prefab="ice"},max_claims=1},
{id="winter_cutstone",season="winter",kind="once",name="Đá Xây Trú Ẩn",description="Nhận vào hành trang tổng cộng 12 đá cắt.",event="itemget",target=12,params={prefab="cutstone"},max_claims=1},
{id="winter_nitre",season="winter",kind="once",name="Diêm Tiêu Dự Trữ",description="Nhận vào hành trang tổng cộng 15 diêm tiêu.",event="itemget",target=15,params={prefab="nitre"},max_claims=1},
{id="winter_gold",season="winter",kind="once",name="Vàng Dưới Tuyết",description="Nhận vào hành trang tổng cộng 20 vàng.",event="itemget",target=20,params={prefab="goldnugget"},max_claims=1},
{id="winter_marble",season="winter",kind="once",name="Cẩm Thạch Trắng",description="Nhận vào hành trang tổng cộng 12 cẩm thạch.",event="itemget",target=12,params={prefab="marble"},max_claims=1},
{id="winter_moonrock",season="winter",kind="once",name="Đá Trăng Lạnh",description="Nhận vào hành trang tổng cộng 12 đá mặt trăng.",event="itemget",target=12,params={prefab="moonrocknugget"},max_claims=1},
{id="winter_thulecite",season="winter",kind="once",name="Khoáng Cổ Đại",description="Nhận vào hành trang tổng cộng 6 Thulecite.",event="itemget",target=6,params={prefab="thulecite"},max_claims=1},
{id="winter_fragments",season="winter",kind="once",name="Mảnh Khoáng Cổ",description="Nhận vào hành trang tổng cộng 18 mảnh Thulecite.",event="itemget",target=18,params={prefab="thulecite_pieces"},max_claims=1},
{id="winter_redgem",season="winter",kind="once",name="Ngọc Đỏ Sưởi Ấm",description="Nhận vào hành trang tổng cộng 3 ngọc đỏ.",event="itemget",target=3,params={prefab="redgem"},max_claims=1},
{id="winter_purplegem",season="winter",kind="once",name="Ngọc Tím Huyền Thuật",description="Nhận vào hành trang tổng cộng 2 ngọc tím.",event="itemget",target=2,params={prefab="purplegem"},max_claims=1},
{id="winter_kabob",season="winter",kind="repeat",name="Xiên Thịt Nóng",description="Ăn 3 xiên thịt mỗi lượt.",event="oneat",target=3,params={prefab="kabobs"},max_claims=5},
{id="winter_meatballs",season="winter",kind="repeat",name="Thịt Viên No Bụng",description="Ăn 3 phần thịt viên mỗi lượt.",event="oneat",target=3,params={prefab="meatballs"},max_claims=5},
{id="winter_stew",season="winter",kind="repeat",name="Nồi Thịt Hầm",description="Ăn 3 phần thịt hầm mỗi lượt.",event="oneat",target=3,params={prefab="bonestew"},max_claims=5},
{id="winter_snowbird",season="winter",kind="repeat",name="Chim Tuyết",description="Hạ 5 chim tuyết mỗi lượt.",event="killed",target=5,params={prefab="robin_winter"},max_claims=5},
{id="winter_puffin",season="winter",kind="repeat",name="Chim Hải Âu Cụt",description="Hạ 5 Puffin trên biển mỗi lượt.",event="killed",target=5,params={prefab="puffin"},max_claims=5},
{id="winter_pengull",season="winter",kind="repeat",name="Đàn Pengull",description="Hạ 5 Pengull mỗi lượt.",event="killed",target=5,params={prefab="penguin"},max_claims=5},
{id="winter_evergreen",season="winter",kind="repeat",name="Củi Thông",description="Chặt hạ 8 cây thông thường mỗi lượt.",event="finishedwork",target=8,params={action="CHOP",prefab="evergreen"},max_claims=5},
{id="winter_lumpy",season="winter",kind="repeat",name="Củi Thông Thưa",description="Chặt hạ 8 cây thông thưa mỗi lượt.",event="finishedwork",target=8,params={action="CHOP",prefab="evergreen_sparse"},max_claims=5},
{id="winter_glacier",season="winter",kind="repeat",name="Khai Thác Băng",description="Đào vỡ 8 tảng băng nhỏ mỗi lượt.",event="finishedwork",target=8,params={action="MINE",prefab="rock_ice"},max_claims=5},
{id="winter_lichen",season="winter",kind="repeat",name="Địa Y Dưới Hang",description="Hái 8 bụi địa y mỗi lượt.",event="picksomething",target=8,params={prefab="lichen"},max_claims=5},
}

local seasons = {"spring", "summer", "autumn", "winter"}
local by_id, by_season = {}, {}
local function Copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, child in pairs(value) do result[key] = Copy(child) end
    return result
end

function Catalog.Validate()
    local ids, signatures, pools = {}, {}, {}
    for _, season in ipairs(seasons) do pools[season] = {once={}, repeatable={}} end
    for _, row in ipairs(definitions) do
        assert(type(row.id) == "string" and not ids[row.id], "duplicate seasonal ID")
        local pool = pools[row.season]
        assert(pool ~= nil and (row.kind == "once" or row.kind == "repeat"), "invalid seasonal pool")
        assert(type(row.target) == "number" and row.target > 0 and row.target == math.floor(row.target), "invalid seasonal target")
        assert(row.max_claims == (row.kind == "once" and 1 or 5), "invalid seasonal claim limit")
        assert(type(row.params) == "table" and type(row.event) == "string", "missing seasonal evidence")
        local keys, parts = {}, {row.event}
        for key in pairs(row.params) do keys[#keys + 1] = key end
        table.sort(keys)
        for _, key in ipairs(keys) do parts[#parts + 1] = key .. "=" .. tostring(row.params[key]) end
        local signature = table.concat(parts, "|")
        assert(not signatures[signature], "duplicate seasonal activity")
        signatures[signature], ids[row.id] = true, row
        local group = row.kind == "once" and pool.once or pool.repeatable
        group[#group + 1] = row
    end
    assert(#definitions == 200, "seasonal catalog must contain 200 explicit activities")
    for _, season in ipairs(seasons) do
        assert(#pools[season].once == 40 and #pools[season].repeatable == 10, "seasonal split must be 40/10")
    end
    by_id, by_season = ids, pools
    return true
end

function Catalog.All() return Copy(definitions) end
function Catalog.ById(id) return type(id) == "string" and Copy(by_id[id]) or nil end
function Catalog.IsSeason(season) return type(season) == "string" and by_season[season] ~= nil end

function Catalog.Draw(season, random)
    if not Catalog.IsSeason(season) then return nil end
    random = random or math.random
    local slots = {}
    local function Pick(source, count)
        local pool = Copy(source)
        for index = 1, count do
            local chosen = random(index, #pool)
            assert(type(chosen) == "number" and chosen == math.floor(chosen) and chosen >= index and chosen <= #pool, "invalid seasonal RNG")
            pool[index], pool[chosen] = pool[chosen], pool[index]
            slots[#slots + 1] = {task_id=pool[index].id, progress=0, claims=0}
        end
    end
    Pick(by_season[season].once, 16)
    Pick(by_season[season].repeatable, 4)
    return slots
end

Catalog.Validate()
return Catalog
