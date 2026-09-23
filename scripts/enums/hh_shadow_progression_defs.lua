local M = {}

M.VERSION = 1
M.ORDER = {
    "hh_igris_shadow",
    "hh_beru_shadow",
    "hh_fruitfly_shadow",
    "hh_macanh_shadow",
    "hh_hacanh_shadow",
}

M.DEFS = {
    hh_igris_shadow = {
        key = "igris",
        name = "Igris",
        role = "Kỵ sĩ hộ vệ / khống chế tuyến đầu",
        exp_kind = "combat",
        talents = {
            { id = "steel_guard", level = 5, name = "Thép Đen", desc = "Giảm 10% sát thương nhận vào." },
            { id = "provoking_arc", level = 10, name = "Khiêu Khích", desc = "Đòn đánh trúng khiến quái thường ưu tiên\nIgris. Tăng 1000 máu tối đa." },
            { id = "sword_mastery", level = 15, name = "Kiếm Thuật", desc = "Tăng 15% sát thương gây ra." },
            { id = "royal_guard", level = 20, name = "Hộ Chủ", desc = "Phản ứng khi chủ nhân bị đánh và nhận\ngiảm 50% sát thương nhận vào trong 15 giây." },
            { id = "unyielding", level = 25, name = "Bất Khuất", desc = "Dưới 30% máu: tăng 25% tốc độ và giảm\nthêm 25% sát thương nhận vào." },
            { id = "knights_oath", level = 30, name = "Lời Thề Kỵ Sĩ", desc = "Một lần mỗi lượt triệu hồi, sống sót đòn chí\ntử và hồi 80% máu." },
        },
    },
    hh_beru_shadow = {
        key = "beru",
        name = "Beru",
        role = "Sát thủ / chuyên săn boss",
        exp_kind = "combat",
        talents = {
            { id = "predator", level = 5, name = "Kẻ Săn Mồi", desc = "Tăng thêm 20% sát thương khi mục tiêu\ndưới 50% máu." },
            { id = "lifesteal", level = 10, name = "Hấp Thụ", desc = "Hồi tối đa 20 máu từ mỗi đòn đánh." },
            { id = "swift_predator", level = 15, name = "Không Kích", desc = "Tăng 10% tốc độ di chuyển." },
            { id = "corrosion", level = 20, name = "Độc Ăn Mòn", desc = "Mục tiêu trúng đòn nhận thêm 10% sát\nthương trong 5 giây." },
            { id = "execute", level = 25, name = "Hành Quyết", desc = "Tăng mạnh thêm 30% sát thương khi mục\ntiêu dưới 20% máu." },
            { id = "king_regen", level = 30, name = "Vua Kiến", desc = "Hạ boss/epic sẽ hồi 30% máu tối đa." },
        },
    },
    hh_fruitfly_shadow = {
        key = "fruitfly",
        name = "Fruitfly",
        role = "Nông nghiệp / chăm sóc cây trồng",
        exp_kind = "farming",
        talents = {
            { id = "wide_field", level = 5, name = "Canh Tác", desc = "Tăng 5 ô bán kính chăm sóc." },
            { id = "swift_wings", level = 10, name = "Đôi Cánh", desc = "Tăng 15% tốc độ di chuyển." },
            { id = "green_thumb", level = 15, name = "Mát Tay", desc = "Nhận thêm 25% EXP từ chăm cây." },
            { id = "steady_care", level = 20, name = "Bền Bỉ", desc = "Tăng 20% tốc độ chăm sóc cây trồng." },
            { id = "mana_saver", level = 25, name = "Tiết Kiệm", desc = "Mỗi lần tiêu mana thứ tư được miễn phí." },
            { id = "royal_gardener", level = 30, name = "Ngự Viên", desc = "Tăng thêm 30% tốc độ chăm sóc cây trồng.\nMỗi lần chăm sóc được 3 cây." },
        },
    },
    hh_macanh_shadow = {
        key = "macanh",
        name = "Mặc Ảnh",
        role = "Khai thác / thu gom tài nguyên",
        exp_kind = "working",
        talents = {
            { id = "keen_eye", level = 5, name = "Chạy Nhanh", desc = "Tăng 30% tốc độ di chuyển." },
            { id = "skilled_hands", level = 10, name = "Thành Thạo", desc = "Tăng 25% hiệu suất CHOP/MINE/DIG." },
            { id = "collector", level = 15, name = "Thu Gom", desc = "Có 50% tỉ lệ tăng gấp đôi vật phẩm nhặt." },
            { id = "chain_worker", level = 20, name = "Hiệu Quả", desc = "Tăng thêm 25% hiệu suất làm việc." },
            { id = "mana_saver", level = 25, name = "Tiết Kiệm", desc = "Mỗi lần tiêu mana thứ tư được miễn phí." },
            { id = "delivery_master", level = 30, name = "Giao Nộp", desc = "Tăng thêm 25% hiệu suất CHOP, MINE,\nDIG và PICK." },
        },
    },
    hh_hacanh_shadow = {
        key = "hacanh",
        name = "Hắc Ảnh",
        role = "Đấu sĩ cơ động / bảo vệ chủ nhân",
        exp_kind = "combat",
        talents = {
            { id = "shadow_step", level = 5, name = "Bộ Pháp", desc = "Tăng 30% tốc độ di chuyển." },
            { id = "mana_saver", level = 10, name = "Tiết Kiệm", desc = "Thực hiện thêm 2 đòn trước khi tiêu mana." },
            { id = "shadow_edge", level = 15, name = "Trảm Ảnh", desc = "Tăng 20% sát thương gây ra." },
            { id = "shadow_dodge", level = 20, name = "Né Bóng", desc = "Giảm 15% sát thương nhận vào." },
            { id = "protector", level = 25, name = "Hộ Vệ", desc = "Ưu tiên kẻ vừa tấn công chủ nhân." },
            { id = "night_hunter", level = 30, name = "Thợ Săn Đêm", desc = "Tăng thêm 30% sát thương gây ra." },
        },
    },
}

local function GetConfig()
    return TUNING.HH_SHADOW_PROGRESSION or {}
end

function M.IsSupported(prefab)
    return M.DEFS[prefab] ~= nil
end

function M.Get(prefab)
    return M.DEFS[prefab]
end

function M.GetMaxLevel()
    return GetConfig().MAX_LEVEL or 30
end

function M.GetExpForNextLevel(level)
    level = math.max(1, math.floor(tonumber(level) or 1))
    local config = GetConfig()
    local base = config.EXP_BASE or 100
    local linear = config.EXP_LINEAR or 35
    local quadratic = config.EXP_QUADRATIC or 5
    local n = level - 1
    return math.floor(base + linear * n + quadratic * n * n)
end

function M.GetTalent(prefab, talent_id)
    local def = M.DEFS[prefab]
    if def == nil then return nil end
    for index, talent in ipairs(def.talents) do
        if talent.id == talent_id then
            return talent, index
        end
    end
    return nil
end

function M.HasTalent(mask, index_or_id, prefab)
    local index = index_or_id
    if type(index_or_id) == "string" then
        local _, found = M.GetTalent(prefab, index_or_id)
        index = found
    end
    if index == nil then return false end
    local bit_value = 2 ^ (index - 1)
    return math.floor((tonumber(mask) or 0) / bit_value) % 2 == 1
end

function M.AddTalent(mask, index)
    mask = math.max(0, math.floor(tonumber(mask) or 0))
    if M.HasTalent(mask, index) then
        return mask
    end
    return mask + 2 ^ (index - 1)
end

function M.CountTalents(mask)
    local count = 0
    mask = math.max(0, math.floor(tonumber(mask) or 0))
    for index = 1, 6 do
        if M.HasTalent(mask, index) then
            count = count + 1
        end
    end
    return count
end

function M.GetNetField(prefab, field)
    local def = M.DEFS[prefab]
    return def ~= nil and ("hh_shadow_" .. def.key .. "_" .. field) or nil
end

function M.CalculateStats(prefab, level, talent_mask)
    local config = GetConfig()
    local growths = config.GROWTH or {}
    local growth = growths[prefab] or {}
    local n = math.max(0, math.min(M.GetMaxLevel(), math.floor(tonumber(level) or 1)) - 1)
    local stats = {
        health_mult = 1 + (growth.HEALTH_PER_LEVEL or 0) * n,
        max_health_bonus = 0,
        damage_mult = 1 + (growth.DAMAGE_PER_LEVEL or 0) * n,
        attack_period_mult = 1 - math.min(growth.ATTACK_PERIOD_CAP or 0, (growth.ATTACK_PERIOD_PER_LEVEL or 0) * n),
        speed_mult = 1 + (growth.SPEED_PER_LEVEL or 0) * n,
        absorb = math.min(growth.ABSORB_CAP or 0, (growth.ABSORB_PER_LEVEL or 0) * n),
        talent_damage_mult = 1,
        work_radius_bonus = 0,
        work_mult = 1,
        inventory_bonus = 0,
        xp_mult = 1,
        mana_free_every = nil,
        upkeep_interval_bonus = 0,
        attacks_per_mana_bonus = 0,
        care_speed_mult = 1,
        pick_speed_mult = 1,
    }

    local function Has(id)
        return M.HasTalent(talent_mask, id, prefab)
    end

    if prefab == "hh_igris_shadow" then
        if Has("steel_guard") then stats.absorb = stats.absorb + .10 end
        if Has("provoking_arc") then stats.max_health_bonus = stats.max_health_bonus + 1000 end
        if Has("sword_mastery") then stats.talent_damage_mult = stats.talent_damage_mult * 1.15 end
    elseif prefab == "hh_beru_shadow" then
        if Has("swift_predator") then stats.speed_mult = stats.speed_mult * 1.10 end
    elseif prefab == "hh_fruitfly_shadow" then
        if Has("wide_field") then stats.work_radius_bonus = stats.work_radius_bonus + 5 end
        if Has("swift_wings") then stats.speed_mult = stats.speed_mult * 1.15 end
        if Has("green_thumb") then stats.xp_mult = stats.xp_mult * 1.25 end
        if Has("steady_care") then stats.care_speed_mult = stats.care_speed_mult + .20 end
        if Has("mana_saver") then stats.mana_free_every = 4 end
        if Has("royal_gardener") then
            stats.care_speed_mult = stats.care_speed_mult + .30
        end
    elseif prefab == "hh_macanh_shadow" then
        if Has("keen_eye") then stats.speed_mult = stats.speed_mult * 1.30 end
        if Has("skilled_hands") then stats.work_mult = stats.work_mult * 1.25 end
        if Has("collector") then stats.double_loot_chance = 0.5 end
        if Has("chain_worker") then
            stats.work_mult = stats.work_mult * 1.25
            stats.pick_speed_mult = stats.pick_speed_mult + .25
        end
        if Has("mana_saver") then stats.mana_free_every = 4 end
        if Has("delivery_master") then
            stats.work_mult = stats.work_mult * 1.25
            stats.pick_speed_mult = stats.pick_speed_mult + .25
        end
    elseif prefab == "hh_hacanh_shadow" then
        if Has("shadow_step") then stats.speed_mult = stats.speed_mult * 1.30 end
        if Has("mana_saver") then stats.attacks_per_mana_bonus = stats.attacks_per_mana_bonus + 2 end
        if Has("shadow_edge") then stats.talent_damage_mult = stats.talent_damage_mult * 1.20 end
        if Has("shadow_dodge") then stats.absorb = stats.absorb + .15 end
        if Has("night_hunter") then stats.talent_damage_mult = stats.talent_damage_mult * 1.30 end
    end

    stats.absorb = math.min(.80, stats.absorb)
    stats.attack_period_mult = math.max(.55, stats.attack_period_mult)
    return stats
end

function M.GetGrowthText(prefab, level, talent_mask)
    local stats = M.CalculateStats(prefab, level, talent_mask)
    if prefab == "hh_fruitfly_shadow" then
        return string.format("Máu x%.2f          Tốc độ x%.2f\nBán kính +%d",
            stats.health_mult, stats.speed_mult, stats.work_radius_bonus)
    elseif prefab == "hh_macanh_shadow" then
        return string.format("Máu x%.2f          Hiệu suất x%.2f\nBán kính +%d          Tỷ lệ x2 đồ +%d%%",
            stats.health_mult, stats.work_mult, stats.work_radius_bonus, math.floor((stats.double_loot_chance or 0) * 100))
    end
    return string.format("Máu x%.2f          Sát thương x%.2f\nTốc độ x%.2f          Giảm sát thương %d%%",
        stats.health_mult,
        stats.damage_mult * stats.talent_damage_mult,
        stats.speed_mult,
        math.floor(stats.absorb * 100 + .5))
end

return M
