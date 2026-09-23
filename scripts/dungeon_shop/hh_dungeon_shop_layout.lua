-- Dungeon Shop HUD layout configuration.
-- Mỗi category tạo một bảng slot riêng gồm 10 ô.
-- Có thể chỉnh trực tiếp, ví dụ:
--   LAYOUTS.player_potion[1].icon.x = -6
--   LAYOUTS.player_potion[1].icon.scale = 1.20
--   LAYOUTS.disciple_potion[3].name.size = 15
--   LAYOUTS.qol[7].desc.font = NUMBERFONT
--
-- Tọa độ là tương đối so với tâm card. scale của icon là hệ số nhân
-- trên kích thước cơ sở (72px): 1.0 = bình thường, 0.8 = nhỏ hơn, 1.3 = lớn hơn.

local function NewSlot(x, y)
    return {
        card = {
            x = x,
            y = y,
        },
        icon = {
            x = 0,
            y = 70,
            size = 72,
            scale = 1.0,
        },
        name = {
            x = 0,
            y = 27,
            width = 114,
            height = 42,
            font = UIFONT,
            size = 17,
            halign = ANCHOR_MIDDLE,
        },
        desc = {
            x = 0,
            y = -17,
            width = 114,
            height = 48,
            font = UIFONT,
            size = 13,
            halign = ANCHOR_MIDDLE,
        },
        price = {
            x = -32,
            y = -61,
            width = 61,
            height = 24,
            font = NUMBERFONT,
            size = 15,
            halign = ANCHOR_MIDDLE,
        },
        stock = {
            x = 34,
            y = -61,
            width = 61,
            height = 24,
            font = NUMBERFONT,
            size = 15,
            halign = ANCHOR_MIDDLE,
        },
        buy = {
            x = 0,
            y = -96,
            width = 100,
            height = 30,
            font = UIFONT,
            size = 17,
        },
    }
end

local function NewCategoryLayout()
    return {
        NewSlot(-249, 95),
        NewSlot(-111, 95),
        NewSlot(27, 95),
        NewSlot(165, 95),
        NewSlot(303, 95),
        NewSlot(-249, -150),
        NewSlot(-111, -150),
        NewSlot(27, -150),
        NewSlot(165, -150),
        NewSlot(303, -150),
    }
end

-- Mỗi dòng dưới đây là một object riêng. Không dùng chung reference giữa tab.
local LAYOUTS = {
    player_potion = NewCategoryLayout(),
    disciple_potion = NewCategoryLayout(),
    qol = NewCategoryLayout(),
    weapon = NewCategoryLayout(),
}

local MANUAL_LAYOUT = require("dungeon_shop/hh_dungeon_shop_manual_layout")
for category, slots in pairs(MANUAL_LAYOUT) do
    if LAYOUTS[category] ~= nil then
        for index, override in pairs(slots) do
            local slot = LAYOUTS[category][index]
            if slot ~= nil then
                for section, values in pairs(override) do
                    for key, value in pairs(values) do
                        slot[section][key] = value
                    end
                end
            end
        end
    end
end
LAYOUTS.hud = MANUAL_LAYOUT.hud or {}
return LAYOUTS
