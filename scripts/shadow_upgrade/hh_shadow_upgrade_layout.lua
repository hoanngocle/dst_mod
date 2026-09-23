-- Shadow Legion upgrade screen layout configuration.
--
-- Tọa độ của profile/talent là tương đối so với root của màn hình.
-- Tọa độ của các text/icon trong một talent row là tương đối so với row đó.
-- Có thể chỉnh trực tiếp trong file override:
--   LAYOUTS.hh_igris_shadow.profile.name.x = -300
--   LAYOUTS.hh_igris_shadow.talent_rows[1].name.size = 20
--   LAYOUTS.hh_igris_shadow.talent_rows[1].icon.x = -130
--   LAYOUTS.hh_igris_shadow.talent_rows[1].icon.size = 56
--
-- Icon tạm thời dùng prayer_symbol.tex. Thay atlas/tex trong
-- hh_shadow_upgrade_manual_layout.lua khi có icon kỹ năng chính thức.

local DEFAULT_ICON_ATLAS = "images/prayer_symbol.xml"
local DEFAULT_ICON_TEX = "prayer_symbol.tex"

local function NewText(x, y, width, height, size, font, halign, colour)
    return {
        x = x,
        y = y,
        width = width,
        height = height,
        size = size,
        font = font or UIFONT,
        halign = halign or ANCHOR_LEFT,
        colour = colour,
    }
end

local function NewTalentRow(y)
    return {
        row = {
            x = 235,
            y = y,
        },
        icon = {
            atlas = DEFAULT_ICON_ATLAS,
            tex = DEFAULT_ICON_TEX,
            x = -150,
            y = 0,
            size = 52,
            scale = 1.0,
        },
        level = NewText(-118, 18, 70, 24, 16, NUMBERFONT, ANCHOR_LEFT, { .86, .76, .42, 1 }),
        name = NewText(-38, 18, 170, 28, 18, UIFONT, ANCHOR_LEFT, { .88, .90, .98, 1 }),
        status = NewText(-38, -18, 170, 24, 15, UIFONT, ANCHOR_LEFT, { .58, .86, .70, 1 }),
        desc = NewText(145, 0, 315, 62, 15, UIFONT, ANCHOR_LEFT, { .72, .76, .84, 1 }),
    }
end

local function NewProfileLayout()
    return {
        name = NewText(-345, 170, 440, 44, 38, TITLEFONT, ANCHOR_LEFT, { .75, .55, 1, 1 }),
        role = NewText(-345, 125, 430, 60, 24, UIFONT, ANCHOR_LEFT, { .70, .80, .95, 1 }),
        level = NewText(-345, 70, 430, 34, 30, UIFONT, ANCHOR_LEFT, { .85, .90, 1, 1 }),
        exp = NewText(-345, 30, 430, 30, 25, UIFONT, ANCHOR_LEFT, { .72, .80, .90, 1 }),
        progress = NewText(-345, -15, 430, 32, 24, UIFONT, ANCHOR_LEFT, { 1, .85, .20, 1 }),
        stats = NewText(-345, -100, 440, 120, 22, UIFONT, ANCHOR_LEFT, { .55, .90, .85, 1 }),
    }
end

local function NewDiscipleLayout()
    return {
        profile = NewProfileLayout(),
        talent_rows = {
            NewTalentRow(165),
            NewTalentRow(87),
            NewTalentRow(9),
            NewTalentRow(-69),
            NewTalentRow(-147),
            NewTalentRow(-225),
        },
    }
end

local LAYOUTS = {
    hh_igris_shadow = NewDiscipleLayout(),
    hh_beru_shadow = NewDiscipleLayout(),
    hh_fruitfly_shadow = NewDiscipleLayout(),
    hh_macanh_shadow = NewDiscipleLayout(),
    hh_hacanh_shadow = NewDiscipleLayout(),
}

LAYOUTS.hud = {
    title = NewText(0, 305, 900, 58, 48, TITLEFONT, ANCHOR_MIDDLE, { .35, .75, 1, 1 }),
    close = NewText(520, 305, 89, 38, 20, UIFONT, ANCHOR_MIDDLE, { .85, .85, .90, 1 }),
    tabs = {
        hh_igris_shadow = { x = -460, y = 245, width = 210, height = 48, font = UIFONT, size = 19 },
        hh_beru_shadow = { x = -230, y = 245, width = 210, height = 48, font = UIFONT, size = 19 },
        hh_fruitfly_shadow = { x = 0, y = 245, width = 210, height = 48, font = UIFONT, size = 19 },
        hh_macanh_shadow = { x = 230, y = 245, width = 210, height = 48, font = UIFONT, size = 19 },
        hh_hacanh_shadow = { x = 460, y = 245, width = 210, height = 48, font = UIFONT, size = 19 },
    },
}

local function MergeInto(destination, overrides)
    if type(overrides) ~= "table" then return end
    for key, value in pairs(overrides) do
        if type(value) == "table" and type(destination[key]) == "table" then
            MergeInto(destination[key], value)
        else
            destination[key] = value
        end
    end
end

local MANUAL_LAYOUT = require("shadow_upgrade/hh_shadow_upgrade_manual_layout")
for prefab, override in pairs(MANUAL_LAYOUT) do
    if prefab ~= "hud" and LAYOUTS[prefab] ~= nil then
        MergeInto(LAYOUTS[prefab], override)
    end
end
MergeInto(LAYOUTS.hud, MANUAL_LAYOUT.hud)

return LAYOUTS
