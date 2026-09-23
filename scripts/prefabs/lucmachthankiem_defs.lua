
local function InitColor(r, g, b)
    return {r/255, g/255, b/255}
end

local defs =
{
    [1] = {
        name = "lucmachthankiem_red",
        color = InitColor(200, 100, 100),
        damage_mult = 0.2,
    },
    [2] = {
        name = "lucmachthankiem_blue",
        color = InitColor(100, 100, 200),
        damage_mult = 0.3,
        upgrade_mat = "bluegem",
    },
    [3] = {
        name = "lucmachthankiem_purple",
        color = InitColor(200, 0, 200),
        damage_mult = 0.45,
        upgrade_mat = "purplegem",
    },
    [4] = {
        name = "lucmachthankiem_orange",
        color = InitColor(255, 145, 0),
        damage_mult = 0.6,
        upgrade_mat = "orangegem",
    },
    [5] = {
        name = "lucmachthankiem_yellow",
        color = InitColor(200, 200, 0),
        damage_mult = 0.75,
        upgrade_mat = "yellowgem",
    },
    [6] = {
        name = "lucmachthankiem_green",
        color = InitColor(100, 200, 100),
        damage_mult = 1,
        upgrade_mat = "greengem",
    },
}

return defs