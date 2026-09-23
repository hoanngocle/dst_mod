-- Định nghĩa các ký tự bản vẽ
-- ' ' (Khoảng trắng): Không có gạch
-- '.': Gạch Ruins
-- 'W': Gạch Ruins + Tường Ruins
-- 'X': Gạch Ruins + Cột Ruins (Trang trí/Ánh sáng)
-- 'E': Gạch Ruins + Cổng Thoát (Exit)

local Blueprints = {}

Blueprints.SquareArena = {
    "WWWWWWWWWWWWWWW",
    "W.............W",
    "W....F........W",
    "W.........D...W",
    "W..S..........W",
    "W....F........W",
    "W.............W",
    "W......E...F..W",
    "W.............W",
    "W...D.........W",
    "W.............W",
    "W.........S...W",
    "W...F.........W",
    "W.............W",
    "WWWWWWWWWWWWWWW"
}

Blueprints.DiamondArena = {
    "      WWW      ",
    "    WW...WW    ",
    "   W.......W   ",
    "  W...D.....W  ",
    " W...........W ",
    " W...F....S..W ",
    "W.............W",
    "W..F...E......W",
    "W........D....W",
    " W...........W ",
    " W..S........W ",
    "  W.....D...W  ",
    "   W.......W   ",
    "    WW...WW    ",
    "      WWW      "
}

Blueprints.HexagonArena = {
    "    WWWWWWWWW    ",
    "   W.........W   ",
    "  W...........W  ",
    " W.....D.......W ",
    " W.........S...W ",
    "W...F...........W",
    "W............F..W",
    "W..S....E.......W",
    "W...............W",
    "W.....F.........W",
    " W..........D..W ",
    " W....F........W ",
    "  W...........W  ",
    "   W.........W   ",
    "    WWWWWWWWW    "
}

return Blueprints
