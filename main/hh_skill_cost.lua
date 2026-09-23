-- Kỹ năng đặc biệt (chuột phải CASTAOE) của các vũ khí Solo Leveling tốn thêm 20 mana.
-- Không đủ mana: không thi triển kỹ năng và nhân vật nói câu thoại báo hết mana.
-- Cách làm theo SKILL.md §2.4: bọc (monkey-patch) ACTIONS.CASTAOE.fn — giữ nguyên hàm gốc,
-- chỉ chen kiểm tra mana khi vũ khí nằm trong danh sách của mod; vật phẩm vanilla không bị ảnh hưởng.

local SKILL_MANA_COST = 20

local HH_SKILL_WEAPONS = {
    hh_daogam3 = true,

    hh_daogam = true,

    hh_daogam5 = true,}

local CASTAOE = GLOBAL.ACTIONS.CASTAOE
local old_castaoe_fn = CASTAOE.fn

CASTAOE.fn = function(act)
    local weapon = act.invobject
    if weapon ~= nil and HH_SKILL_WEAPONS[weapon.prefab] and act.doer ~= nil then
        local mana = act.doer.components.hh_mana
        if mana == nil or not mana:CanSpend(SKILL_MANA_COST) then
            if act.doer.components.talker ~= nil then
                act.doer.components.talker:Say("Mana đã cạn kiệt, cần thời gian hồi phục !")
            end
            return false
        end
        local ok, reason = old_castaoe_fn(act)
        if ok then
            mana:Spend(SKILL_MANA_COST, "hh_weapon_skill_" .. weapon.prefab)
        end
        return ok, reason
    end
    return old_castaoe_fn(act)
end
