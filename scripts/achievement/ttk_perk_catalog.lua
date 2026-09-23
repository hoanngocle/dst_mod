local M = {}

local perks = {
    { id = "planar_defense", group = "stats", name = "Planar Defense +", max_level = 25, effect_per_level = 0.5 },
    { id = "planar_damage", group = "stats", name = "Planar Damage +", max_level = 25, effect_per_level = 1 },
    { id = "critical_hit", group = "stats", name = "Critical Hit +", max_level = 25, effect_per_level = 0.01 },
    { id = "critical_damage", group = "stats", name = "Critical Damage +", max_level = 25, effect_per_level = 0.02 },
    { id = "lifesteal", group = "stats", name = "Lifesteal +", max_level = 25, effect_per_level = 0.01 },
    { id = "scale", group = "stats", name = "Scale +", max_level = 25, effect_per_level = 0.01 },
    { id = "xp_multiplier", group = "stats", name = "XP Multiplier +", max_level = 25, effect_per_level = 0.05 },

    { id = "fast_worker", group = "ability", name = "Tay Nhanh", price = 8 },
    { id = "mine_faster", group = "ability", name = "Búa Tạ", price = 6 },
    { id = "chop_faster", group = "ability", name = "Máy Cưa", price = 6 },
    { id = "fish_faster", group = "ability", name = "Ngư Thần", price = 6 },
    { id = "cook_faster", group = "ability", name = "Siêu Đầu Bếp", price = 6 },
    { id = "warly_chef", group = "ability", name = "Michelin 5 Sao", price = 8 },
    { id = "trinket_owner", group = "ability", name = "Enchantmemento", price = 12 },
    { id = "double_healed", group = "ability", name = "Trị Liệu Sư", price = 15 },
    { id = "double_pick", group = "ability", name = "Thu Hoạch", price = 20 },
    { id = "double_drop", group = "ability", name = "Khát Máu", price = 30 },
    { id = "build_cheaper", group = "ability", name = "Bậc Thầy Chế Tác", price = 35 },
    { id = "eternal_cage", group = "ability", name = "Phước Lành Fawkes", price = 5 },
    { id = "easy_farm", group = "ability", name = "Phân Bón Tốt", price = 12 },
    { id = "icy_weed", group = "ability", name = "Icy-Breezy", price = 10 },

    { id = "ancient_builder", group = "craft", name = "Ancient Builder", price = 15, builder_tag = "ttk_achievement_craft_ancient_builder" },
    { id = "lunar_knight", group = "craft", name = "Kỵ Sĩ Ánh Trăng", price = 10, builder_tag = "ttk_achievement_craft_lunar_knight" },
    { id = "pearl_bff", group = "craft", name = "Pearl BFF", price = 8, builder_tag = "ttk_achievement_craft_pearl_bff" },
    { id = "benevolent_mind", group = "craft", name = "Benevolent Mind", price = 8, builder_tag = "ttk_achievement_craft_benevolent_mind" },
    { id = "mad_scientist", group = "craft", name = "Nhà Khoa Học Điên", price = 10, builder_tag = "ttk_achievement_craft_mad_scientist" },
    { id = "celebrate", group = "craft", name = "Celebrate!", price = 5, builder_tag = "ttk_achievement_craft_celebrate" },
    { id = "festive", group = "craft", name = "Festive!", price = 5, builder_tag = "ttk_achievement_craft_festive" },
    { id = "christmas_gift", group = "craft", name = "Quà Giáng Sinh", price = 8, builder_tag = "ttk_achievement_craft_christmas_gift" },
    { id = "legendary_smith", group = "craft", name = "Thợ Rèn Huyền Thoại", price = 15, builder_tag = "ttk_achievement_craft_legendary_smith" },
    { id = "pokeball", group = "craft", name = "Pokeball", price = 12, builder_tag = "ttk_achievement_craft_pokeball" },
    { id = "antique_shop", group = "craft", name = "Antique Shop", price = 8, builder_tag = "ttk_achievement_craft_antique_shop" },
    {
        id = "inherit_luoshen", group = "craft", name = "Truyền Thừa Lạc Thần", price = 20,
        builder_tag = "ttk_inheritance_luoshen",
        recipes = {
            "fence_gate_luoshen_item", "xd_luoshen_jihuaze", "xd_luoshen_jiangren", "xd_luoshen_huazhong", "xd_luoshen_liuguanghuafen", "xd_luoshen_yin", "xd_luoshen_huaxia", "fence_luoshen_item", "wall_luoshen_item", "xd_luoshen_dinghunxianglu",
        },
    },
    {
        id = "inherit_sanxiao", group = "craft", name = "Truyền Thừa Tam Tiêu", price = 14,
        builder_tag = "ttk_inheritance_sanxiao",
        recipes = {
            "xd_yunxiao_hyjditem", "xd_yunxiao_fgfq", "xd_yunxiao_fls", "xd_yunxiao_fysz", "xd_yunxiao_ymsz", "xd_yunxiao_hyjdyqd", "xd_yunxiao_portable_spicer",
        },
    },
    {
        id = "inherit_shiji", group = "craft", name = "Truyền Thừa Thạch Cơ", price = 16,
        builder_tag = "ttk_inheritance_shiji",
        recipes = {
            "xd_sj_bglxp", "xd_sj_bgygp", "xd_sj_by_builder", "xd_sj_kls", "xd_sj_tlsq", "xd_sj_cy_builder", "xd_sj_sxz", "xd_sj_xsydz",
        },
    },
    {
        id = "inherit_jingwei", group = "craft", name = "Truyền Thừa Tinh Vệ", price = 14,
        builder_tag = "ttk_inheritance_jingwei",
        recipes = {
            "xd_xuanyu", "xd_jingwei_blowdart", "xd_jingwei_fenice_builder", "xd_jingwei_fan", "xd_jingwei_hat", "turf_jingweitile", "xd_qianyu",
        },
    },
    {
        id = "inherit_sudaji", group = "craft", name = "Truyền Thừa Tô Đát Kỷ", price = 10,
        builder_tag = "ttk_inheritance_sudaji",
        recipes = {
            "xd_sudaji_redlantern", "xd_sudaji_ywfh", "xd_qwsk", "xd_sudaji_sjpn", "xd_sudaji_tsmd",
        },
    },
    {
        id = "inherit_hantianzun", group = "craft", name = "Truyền Thừa Hàn Thiên Tôn", price = 8,
        builder_tag = "ttk_inheritance_hantianzun",
        recipes = {
            "xd_htz_xyzzl", "xd_htz_sjcx", "xd_htz_tlz",
        },
    },
    {
        id = "inherit_wangmazi", group = "craft", name = "Truyền Thừa Vương Ma Tử", price = 20,
        builder_tag = "ttk_inheritance_wangmazi",
        recipes = {
            "xd_wmz_kjb", "xd_wmz_slxj", "xd_wmz_md1", "xd_wmz_md2", "xd_wmz_md3", "xd_wmz_md4", "xd_wmz_md5", "xd_wmz_md6", "xd_wmz_md7", "xd_wmz_md8",
        },
    },
}

local by_id = {}
for _, perk in ipairs(perks) do
    assert(by_id[perk.id] == nil, "duplicate perk id: " .. perk.id)
    by_id[perk.id] = perk
end

function M.All()
    return perks
end

function M.ById(id)
    return by_id[id]
end

function M.PriceForLevel(level)
    if type(level) ~= "number" or level ~= math.floor(level) or level < 1 or level > 25 then
        return nil
    end
    if level <= 10 then return 2 end
    if level <= 15 then return 3 end
    if level <= 20 then return 4 end
    return 5
end

function M.NextPrice(perk, current_level)
    if perk == nil then return nil end
    if perk.max_level ~= nil then
        return M.PriceForLevel((current_level or 0) + 1)
    end
    return perk.price
end

function M.MaxCost()
    local total = 0
    for _, perk in ipairs(perks) do
        if perk.max_level ~= nil then
            for level = 1, perk.max_level do total = total + M.PriceForLevel(level) end
        else
            total = total + perk.price
        end
    end
    return total
end

assert(#perks == 39, "expected 39 approved perks")
assert(M.MaxCost() == 945, "perk cost contract")

return M
