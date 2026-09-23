local RANK = require("guild/hh_rank_defs").RANK

local PRODUCTS = {
    { id=1, rank=RANK.E, prefab="cutgrass", name="Cỏ cắt", price=2, stock=10, amount=6 },
    { id=2, rank=RANK.E, prefab="twigs", name="Cành cây", price=2, stock=10, amount=6 },
    { id=3, rank=RANK.E, prefab="flint", name="Đá lửa", price=3, stock=10, amount=6 },
    { id=4, rank=RANK.E, prefab="torch", name="Đuốc", price=5, stock=1, amount=1 },
    { id=5, rank=RANK.E, prefab="healingsalve", name="Thuốc mỡ hồi phục", price=12, stock=3, amount=2 },
    { id=6, rank=RANK.E, prefab="axe", name="Rìu", price=5, stock=1, amount=1 },

    { id=7, rank=RANK.D, prefab="log", name="Gỗ", price=4, stock=10, amount=5 },
    { id=8, rank=RANK.D, prefab="rocks", name="Đá", price=4, stock=10, amount=10 },
    { id=9, rank=RANK.D, prefab="goldnugget", name="Vàng thỏi", price=10, stock=10, amount=5 },
    { id=10, rank=RANK.D, prefab="pickaxe", name="Cuốc chim", price=5, stock=1, amount=1 },
    { id=11, rank=RANK.D, prefab="rope", name="Dây thừng", price=6, stock=10, amount=3 },
    { id=12, rank=RANK.D, prefab="silk", name="Tơ nhện", price=15, stock=10, amount=10 },

    { id=13, rank=RANK.C, prefab="gears", name="Bánh răng", price=30, stock=5, amount=2 },
    { id=14, rank=RANK.C, prefab="nightmarefuel", name="Nhiên liệu ác mộng", price=24, stock=10, amount=5 },
    { id=15, rank=RANK.C, prefab="livinglog", name="Gỗ sống", price=21, stock=8, amount=3 },
    { id=16, rank=RANK.C, prefab="reviver", name="Trái tim Telltale", price=10, stock=5, amount=1 },
    { id=17, rank=RANK.C, prefab="heatrock", name="Đá nhiệt", price=10, stock=1, amount=1 },
    { id=18, rank=RANK.C, prefab="spear", name="Giáo", price=5, stock=1, amount=1 },

    { id=19, rank=RANK.B, prefab="tentaclespike", name="Gai xúc tu", price=10, stock=1, amount=1 },
    { id=20, rank=RANK.B, prefab="armorwood", name="Giáp gỗ", price=10, stock=1, amount=1 },
    { id=21, rank=RANK.B, prefab="footballhat", name="Mũ bóng đá", price=15, stock=3, amount=1 },
    { id=22, rank=RANK.B, prefab="hambat", name="Giăm bông chiến đấu", price=30, stock=1, amount=1 },
    { id=23, rank=RANK.B, prefab="thulecite_pieces", name="Mảnh thulecite", price=7, stock=6, amount=5 },

    { id=24, rank=RANK.A, prefab="thulecite", name="Thulecite", price=80, stock=4, amount=3 },
    { id=25, rank=RANK.A, prefab="horrorfuel", name="Nhiên liệu kinh hoàng", price=130, stock=5, amount=5 },
    { id=26, rank=RANK.A, prefab="purebrilliance", name="Nhiên liệu thuần túy", price=130, stock=5, amount=5 },
    { id=27, rank=RANK.A, prefab="lifeinjector", name="Life Injector", price=30, stock=3, amount=1 },
    { id=28, rank=RANK.A, prefab="dragon_scales", name="Vảy rồng", price=100, stock=3, amount=1 },

    { id=29, rank=RANK.S, prefab="deerclops_eyeball", name="Nhãn cầu Deerclops", price=200, stock=2, amount=1 },
    { id=30, rank=RANK.S, prefab="malbatross_feather", name="Lông Malbatross", price=70, stock=8, amount=1 },

    -- 60 sản phẩm mở rộng: tổng pool đạt 15 sản phẩm cho mỗi Rank.
    { id=31, rank=RANK.E, prefab="berries", name="Dâu rừng", price=5, stock=10, amount=5 },
    { id=32, rank=RANK.E, prefab="carrot", name="Cà rốt", price=5, stock=10, amount=5 },
    { id=33, rank=RANK.E, prefab="petals", name="Cánh hoa", price=2, stock=10, amount=6 },
    { id=34, rank=RANK.E, prefab="seeds", name="Hạt giống", price=2, stock=10, amount=6 },
    { id=35, rank=RANK.E, prefab="charcoal", name="Than củi", price=5, stock=10, amount=5 },
    { id=36, rank=RANK.E, prefab="nitre", name="Ni tơ", price=10, stock=10, amount=5 },
    { id=37, rank=RANK.E, prefab="boards", name="Ván gỗ", price=8, stock=10, amount=2 },
    { id=38, rank=RANK.E, prefab="papyrus", name="Giấy cói", price=8, stock=10, amount=2 },
    { id=39, rank=RANK.E, prefab="strawhat", name="Mũ rơm", price=5, stock=1, amount=1 },

    { id=40, rank=RANK.D, prefab="manure", name="Phân bón", price=7, stock=10, amount=5 },
    { id=41, rank=RANK.D, prefab="beefalowool", name="Lông bò", price=15, stock=10, amount=5 },
    { id=42, rank=RANK.D, prefab="spidergland", name="Tuyến nhện", price=9, stock=10, amount=3 },
    { id=43, rank=RANK.D, prefab="houndstooth", name="Răng sói", price=9, stock=10, amount=3 },
    { id=44, rank=RANK.D, prefab="pigskin", name="Da heo", price=16, stock=8, amount=2 },
    { id=45, rank=RANK.D, prefab="honey", name="Mật ong", price=10, stock=10, amount=5 },
    { id=46, rank=RANK.D, prefab="beeswax", name="Sáp ong", price=20, stock=6, amount=1 },
    { id=47, rank=RANK.D, prefab="meatballs", name="Thịt viên", price=14, stock=10, amount=7 },
    { id=48, rank=RANK.D, prefab="backpack", name="Ba lô", price=5, stock=1, amount=1 },

    { id=49, rank=RANK.C, prefab="bluegem", name="Ngọc lam", price=25, stock=5, amount=1 },
    { id=50, rank=RANK.C, prefab="redgem", name="Ngọc đỏ", price=25, stock=5, amount=1 },
    { id=51, rank=RANK.C, prefab="purplegem", name="Ngọc tím", price=50, stock=5, amount=1 },
    { id=52, rank=RANK.C, prefab="moonrocknugget", name="Đá mặt trăng", price=27, stock=10, amount=3 },
    { id=53, rank=RANK.C, prefab="marble", name="Đá cẩm thạch", price=20, stock=10, amount=4 },
    { id=54, rank=RANK.C, prefab="glommerfuel", name="Nhiên liệu Glommer", price=20, stock=10, amount=2 },
    { id=55, rank=RANK.C, prefab="umbrella", name="Cây dù", price=15, stock=1, amount=1 },
    { id=56, rank=RANK.C, prefab="raincoat", name="Áo mưa", price=30, stock=1, amount=1 },
    { id=57, rank=RANK.C, prefab="perogies", name="Pierogi (Há cảo)", price=30, stock=10, amount=10 },

    { id=58, rank=RANK.B, prefab="orangegem", name="Ngọc cam", price=90, stock=5, amount=1 },
    { id=59, rank=RANK.B, prefab="yellowgem", name="Ngọc vàng", price=90, stock=5, amount=1 },
    { id=60, rank=RANK.B, prefab="greengem", name="Ngọc lục", price=90, stock=5, amount=1 },
    { id=61, rank=RANK.B, prefab="armorruins", name="Giáp Thulecite", price=120, stock=1, amount=1 },
    { id=62, rank=RANK.B, prefab="ruinshat", name="Vương miện Thulecite", price=120, stock=1, amount=1 },
    { id=63, rank=RANK.B, prefab="nightstick", name="Gậy Sao Mai", price=75, stock=1, amount=1 },
    { id=64, rank=RANK.B, prefab="icestaff", name="Gậy băng", price=35, stock=1, amount=1 },
    { id=65, rank=RANK.B, prefab="firestaff", name="Gậy lửa", price=35, stock=1, amount=1 },
    { id=66, rank=RANK.B, prefab="panflute", name="Sáo thần", price=200, stock=1, amount=1 },
    { id=67, rank=RANK.B, prefab="amulet", name="Bùa hồi sinh", price=30, stock=1, amount=1 },

    { id=68, rank=RANK.A, prefab="opalpreciousgem", name="Đá quý ánh kim", price=300, stock=5, amount=1 },
    { id=69, rank=RANK.A, prefab="dreadstone", name="Đá kinh hãi", price=160, stock=10, amount=2 },
    { id=70, rank=RANK.A, prefab="voidcloth", name="Vải hư không", price=120, stock=10, amount=2 },
    { id=71, rank=RANK.A, prefab="lunarplant_husk", name="Vỏ cây Brightshade", price=150, stock=10, amount=3 },
    { id=72, rank=RANK.A, prefab="sword_lunarplant", name="Kiếm Brightshade", price=350, stock=1, amount=1 },
    { id=73, rank=RANK.A, prefab="armorskeleton", name="Giáp xương", price=450, stock=1, amount=1 },
    { id=74, rank=RANK.A, prefab="yellowstaff", name="Gậy gọi sao", price=200, stock=1, amount=1 },
    { id=75, rank=RANK.A, prefab="orangestaff", name="Gậy dịch chuyển", price=300, stock=1, amount=1 },
    { id=76, rank=RANK.A, prefab="greenstaff", name="Gậy giải cấu trúc", price=300, stock=1, amount=1 },
    { id=77, rank=RANK.A, prefab="shroom_skin", name="Da cóc", price=170, stock=2, amount=1 },

    { id=78, rank=RANK.S, prefab="bearger_fur", name="Lông Bearger", price=300, stock=1, amount=1 },
    { id=79, rank=RANK.S, prefab="minotaurhorn", name="Sừng Ancient Guardian", price=300, stock=1, amount=1 },
    { id=80, rank=RANK.S, prefab="krampus_sack", name="Túi Krampus", price=2500, stock=1, amount=1 },
    { id=81, rank=RANK.S, prefab="hivehat", name="Vương miện Ong Chúa", price=350, stock=1, amount=1 },
    { id=82, rank=RANK.S, prefab="royal_jelly", name="Sữa ong chúa", price=210, stock=2, amount=7 },
    { id=83, rank=RANK.S, prefab="shadowheart", name="Tâm nhĩ hắc ám", price=130, stock=1, amount=1 },
    { id=84, rank=RANK.S, prefab="alterguardianhat", name="Vương miện Khai Sáng", price=2000, stock=1, amount=1 },
    { id=85, rank=RANK.S, prefab="dreadstonehat", name="Mũ đá kinh hãi", price=450, stock=1, amount=1 },
    { id=86, rank=RANK.S, prefab="armorwagpunk", name="Giáp Wagpunk", price=450, stock=1, amount=1 },
    { id=87, rank=RANK.S, prefab="staff_lunarplant", name="Gậy Brightshade", price=350, stock=1, amount=1 },
    { id=88, rank=RANK.S, prefab="voidcloth_scythe", name="Lưỡi hái hư không", price=350, stock=1, amount=1 },
    { id=89, rank=RANK.S, prefab="armor_lunarplant", name="Giáp Brightshade", price=350, stock=1, amount=1 },
    { id=90, rank=RANK.S, prefab="wagpunk_bits", name="Linh kiện Wagpunk", price=240, stock=2, amount=3 },
}

local BY_ID = {}
for _, product in ipairs(PRODUCTS) do
    BY_ID[product.id] = product
end

return {
    list = PRODUCTS,
    by_id = BY_ID,
    Get = function(id)
        return BY_ID[tonumber(id)]
    end,
}
