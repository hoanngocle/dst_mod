-- Each entry is a complete themed bundle. Equipment is always one of each kind.
local function gear(name) return {prefab=name, count=1, kind="equipment", reward_kind="rare"} end
local function pill(name) return {prefab=name, count=1, kind="supply", reward_kind="pill"} end
local function goods(name, count) return {prefab=name, count=count, kind="supply"} end
local function creature(name, count) return {prefab=name, count=count, kind="creature"} end
local function bundle(label, ...)
    return {label=label, weight=1, items={...}}
end

local groups = {
    good = {weight=.5, bundles={
        bundle("Dreadstone", gear("dreadstonehat"), gear("armordreadstone")),
        bundle("Nguyệt thực", gear("lunarplanthat"), gear("armor_lunarplant")),
        bundle("Hư không", gear("voidclothhat"), gear("armor_voidcloth"), gear("voidcloth_scythe"), gear("voidcloth_umbrella")),
        bundle("Túi hành trang", gear("krampus_sack"), goods("ttk_luoshen_qingshu",2)),
        bundle("Lông gấu", gear("beargerfur_sack"), goods("ttk_lc_cyh_seed",3)),
        bundle("Ngọc quý", goods("yellowgem",2), goods("greengem",2), goods("orangegem",2)),
        bundle("Trượng dịch chuyển", gear("orangestaff"), goods("ttk_luoshen_huayin",3)),
        bundle("Cửu Thiên Tinh Thần Phiên", gear("vanhonphien"), goods("ttk_lc_yhh_seed",3)),
        bundle("Tử Xá Diện Giáp", gear("ttk_zcmj"), goods("ttk_pog_tail",3)),
        bundle("Tà Sát Hộ Giáp", gear("ttk_xshj"), goods("ttk_spider_leg",2)),
        bundle("Vương miện và Giáp Xương", gear("alterguardianhat"), gear("armorskeleton")),
        bundle("Trượng ngọc", gear("yellowstaff"), gear("opalstaff"), gear("greenstaff")),
        bundle("Linh thực cay", goods("jellybean_spice_chili",2), goods("seafoodgumbo_spice_chili",2), goods("flowersalad_spice_chili",2)),
        bundle("Thạch dê điện", goods("voltgoatjelly",3), goods("ttk_luoxiang_pengrou",2)),
        bundle("Lục Mạch Thần Kiếm", gear("lucmachthankiem"), goods("ttk_lc_lmg_seed",3)),
        bundle("Tinh La Kiếm", gear("ttk_tinhlakiem"), goods("ttk_luoshen_qingshu",2)),
    }},
    ok = {weight=1.5, bundles={
        bundle("Nhất Vũ Phương Hoa", gear("nhatvuphuonghoa"), goods("ttk_lc_hsc_seed",3)),
        bundle("Thần Hi Quang Trượng", gear("thanhiquangtruong"), goods("townportaltalisman",3)),
        bundle("Ngư Long Đăng", gear("ttk_ngulongdang"), goods("ttk_lingshi1",20)),
        bundle("Chưởng Thiên Bình", gear("ttk_chuongthienbinh"), goods("ttk_luoshen_huazhong",2)),
        bundle("Di tích", gear("armorruins"), gear("ruinshat"), goods("thulecite",3)),
        bundle("Mùa mưa", gear("eyebrellahat"), goods("ttk_luoxiang_pengrou",2)),
        bundle("Linh thực", goods("jellybean",3), goods("ttk_luoshen_qingshu",3)),
        bundle("Chiến lợi phẩm", goods("deerclops_eyeball",1), goods("bearger_fur",1), goods("ttk_npxsz",3)),
        bundle("Vảy và da", goods("dragon_scales",1), goods("shroom_skin",1)),
        bundle("Làm vườn", gear("shovel_lunarplant"), goods("rock_avocado_fruit_sprout",3), goods("ttk_luoshen_huazhong",2)),
        bundle("Thuyền", goods("boat_item",1), goods("boatpatch",3), goods("boat_rotator_kit",1)),
        bundle("Vân Mạc Thượng Trang", gear("ttk_yunxiao_ymsz"), goods("ttk_lc_cyh",3)),
        bundle("Kho báu", goods("chestupgrade_stacksize",1), goods("ttk_lingshi1",30)),
        bundle("Bùa ngọc I", gear("blueamulet"), gear("greenamulet"), gear("purpleamulet")),
        bundle("Bùa ngọc II", gear("orangeamulet"), gear("yellowamulet"), gear("amulet")),
        bundle("Linh thực đóng gói", goods("ttk_luoxiang_pengrou",3), goods("ttk_luoshen_qingshu",3), goods("bundlewrap",3)),
        bundle("Công cụ mặt trăng", gear("pickaxe_lunarplant"), gear("moonglassaxe")),
        bundle("Phòng tuyến", gear("staff_tornado"), goods("deerclopseyeball_sentryward_kit",1)),
        bundle("Chìa khóa và mỏ biển", goods("klaussackkey",1), goods("malbatross_beak",1)),
        bundle("Linh thạch hoàn thưởng", goods("ttk_lingshi2",2)),
    }},
    ok2 = {weight=3.5, bundles={
        bundle("Linh thực Lạc Thần", goods("ttk_luoshen_qingshu",2), goods("ttk_luoxiang_pengrou",2), pill("xd_dy_cyfxd_1")),
        bundle("Hạt dưỡng sinh", goods("ttk_lc_hsc_seed",4), goods("ttk_lc_cyh_seed",4)),
        bundle("Hạt dưỡng thần", goods("ttk_lc_qfx_seed",4), goods("ttk_lc_yhh_seed",4)),
        bundle("Hạt dưỡng khí", goods("ttk_lc_dms_seed",4), goods("ttk_lc_lmg_seed",4)),
        bundle("Linh thảo băng hỏa", goods("ttk_lc_hsc",3), goods("ttk_lc_cyh",3), goods("ttk_lc_dms_seed",3)),
        bundle("Địa Mạch Sâm", goods("ttk_lc_dms",4), goods("ttk_lc_dms_seed",3)),
        bundle("Thanh Phong Tiên", goods("ttk_lc_qfx",3), goods("ttk_lc_qfx_seed",4)),
        bundle("Lôi Minh Quả", goods("ttk_lc_lmg",3), goods("ttk_lc_lmg_seed",4)),
        bundle("U Hồn Hoa", goods("ttk_lc_yhh",3), goods("ttk_lc_yhh_seed",4)),
        bundle("Vườn Lạc Thần", goods("ttk_luoshen_huazhong",2), goods("ttk_luoshen_huayin",3)),
        bundle("Nguyên liệu Tu Tiên", goods("ttk_pog_tail",3), goods("ttk_spider_leg",2), goods("ttk_npxsz",3)),
        bundle("Linh khí dự trữ", goods("ttk_lingshi1",30), goods("ttk_luoshen_qingshu",2)),
        bundle("Ngọc sơ cấp", goods("redgem",1), goods("bluegem",1), goods("ttk_lc_lmg_seed",3)),
        bundle("Trở về", gear("amulet"), goods("reviver",1), goods("ttk_lc_dms_seed",3)),
        bundle("Mắt và sinh lực", gear("eyemaskhat"), goods("lifeinjector",2), goods("ttk_luoshen_qingshu",2)),
        bundle("Mandrake", creature("mandrake_planted",1), goods("mandrakesoup",1)),
        bundle("Sừng cổ đại", goods("minotaurhorn",1), goods("ttk_spider_leg",2)),
        bundle("Khai khoáng đa năng", gear("multitool_axe_pickaxe"), goods("moonglass",6)),
        bundle("Thuyền trưởng", gear("polly_rogershat"), goods("ttk_lc_hsc_seed",3)),
        bundle("Nhện đồng hành", goods("spidereggsack",1), gear("spiderhat"), goods("ttk_spider_leg",2)),
        bundle("Mũ hải mã", gear("walrushat"), goods("ttk_lc_qfx_seed",3)),
        bundle("Dịch chuyển", goods("townportaltalisman",3), goods("ttk_lc_yhh_seed",3)),
        bundle("Soi hang", gear("molehat"), goods("lightninggoathorn",2)),
    }},
    bad = {weight=.8, bundles={
        bundle("Nữ hoàng ong", creature("beequeen",1)),
        bundle("Rồng ruồi", creature("dragonfly",1)),
        bundle("Gấu", creature("bearger",1)),
        bundle("Hươu một mắt", creature("deerclops",1)),
        bundle("Nữ hoàng nhện", creature("spiderqueen",2)),
        bundle("Gấu đột biến", creature("mutatedbearger",1)),
        bundle("Hươu đột biến", creature("mutateddeerclops",1)),
        bundle("Warg đột biến", creature("mutatedwarg",1)),
        bundle("Quân cờ bóng tối", creature("shadow_knight",1), creature("shadow_bishop",1), creature("shadow_rook",1)),
        bundle("Klaus", creature("klaus",1)),
        bundle("Vệ Binh Thiên Thể", creature("alterguardian_phase3",1)),
        bundle("Vệ Binh Cổ Đại", creature("minotaur",1)),
        bundle("Cây chiếm hữu", creature("lunarthrall_plant",3)),
    }},
    bad2 = {weight=4.2, bundles={
        bundle("Chó nguyên tố", creature("firehound",3), creature("icehound",3)),
        bundle("Nhện", creature("spider",4), creature("spider_warrior",2)),
        bundle("Xúc tu", creature("tentacle",3)),
        bundle("Ong sát thủ", creature("killerbee",8)),
        bundle("Ác mộng", creature("crawlingnightmare",2), creature("nightmarebeak",1)),
        bundle("Warg", creature("warg",1), creature("hound",3)),
        bundle("Thỏ", creature("bunnyman",4)),
        bundle("Lính người cá", creature("mermguard",4)),
        bundle("Quỷ trộm", creature("krampus",2)),
        bundle("Sên hang", creature("slurtle",3), creature("snurtle",1)),
        bundle("Dê điện", creature("lightninggoat",3)),
        bundle("Người nấm", creature("mushgnome",3)),
        bundle("Rồng trái cây", creature("fruitdragon",3)),
        bundle("Bóng tối", creature("shadowthrall_horns",1), creature("shadowthrall_hands",1), creature("shadowthrall_wings",1)),
        bundle("Nhện hang", creature("spider_hider",3), creature("spider_spitter",2)),
        bundle("Khỉ", creature("monkey",4), creature("powder_monkey",3)),
        bundle("Lính heo", creature("pigguard",3)),
        bundle("Cây mặt trăng", creature("lunarthrall_plant",1)),
        bundle("Sâu và Slurper", creature("worm",3), creature("slurper",2)),
        bundle("Ewecus", creature("spat",1)),
        bundle("Thợ săn hải mã", creature("walrus",2)),
        bundle("Chim cao cổ", creature("tallbird",2)),
        bundle("Quân cờ", creature("bishop",1), creature("rook",1), creature("knight",1)),
        bundle("Ếch", creature("frog",3), creature("lunarfrog",2)),
        bundle("Dơi", creature("bat",5)),
        bundle("Bom bóng tối", creature("fused_shadeling_bomb",3)),
        bundle("Ruồi trái cây", creature("lordfruitfly",1), creature("fruitfly",3)),
        bundle("Mèo gấu", creature("catcoon",3)),
        bundle("Nhện hỗ trợ", creature("spider_healer",3), creature("moonspider_spike",2)),
        bundle("Voi Koala", creature("koalefant_summer",1), creature("koalefant_winter",1)),
        bundle("Mắt bay", creature("eyeofterror_mini",4)),
        bundle("Kền kền", creature("buzzard",3)),
    }},
}

-- Keep the two original half-weight special-prize slots, now mapped to available gear.
groups.good.bundles[8].weight = .5
groups.good.bundles[9].weight = .5

local function choose(entries)
    local total = 0
    for _, entry in ipairs(entries) do total = total + entry.weight end
    local roll = math.random() * total
    for _, entry in ipairs(entries) do
        roll = roll - entry.weight
        if roll < 0 then return entry end
    end
    return entries[#entries]
end

local function Pick(available)
    local candidates = {}
    for _, category in ipairs({"good", "ok", "ok2", "bad", "bad2"}) do
        local group = groups[category]
        local bundles = {}
        for _, prize in ipairs(group.bundles) do
            local valid = true
            for _, item in ipairs(prize.items) do
                if not available[item.prefab] then valid = false; break end
            end
            if valid then bundles[#bundles + 1] = prize end
        end
        if #bundles > 0 then
            candidates[#candidates + 1] = {category=category, weight=group.weight, bundles=bundles}
        end
    end
    if #candidates == 0 then return end
    local group = choose(candidates)
    local prize = choose(group.bundles)
    return {category=group.category, items=prize.items}
end

-- Classification belongs to the received prefab, never the requested bundle/category.
local reward_kinds = {}
for _, name in ipairs({"redgem", "bluegem", "yellowgem", "greengem", "orangegem", "thulecite", "moonglass",
    "ttk_pog_tail", "ttk_spider_leg", "ttk_npxsz", "bearger_fur", "dragon_scales", "shroom_skin",
    "ttk_lc_hsc", "ttk_lc_cyh", "ttk_lc_dms", "ttk_lc_qfx", "ttk_lc_lmg", "ttk_lc_yhh"}) do
    reward_kinds[name] = "material"
end
for _, group in pairs(groups) do
    for _, prize in ipairs(group.bundles) do
        for _, item in ipairs(prize.items) do
            if item.reward_kind ~= nil then reward_kinds[item.prefab] = item.reward_kind end
        end
    end
end
local function Classify(prefab) return reward_kinds[prefab] end
return {groups=groups, Pick=Pick, Classify=Classify}
