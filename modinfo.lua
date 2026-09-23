name = "Phàm Nhân Tu Tiên"
description = "Thêm nhân vật EVA với bộ kỹ năng tím bạc và Hồn Lực (cấp từ Achievement & Level). Pháp bảo, linh thạch, công trình và 179 skin; cây hoa, linh thảo và hạt giống, chuồng nuôi và sào huyệt, kho chuyên dụng, Thiên Cơ Ốc, trạm gia vị, Truyền Tống Trận và Vĩnh Hằng Thần Hỏa. Tích hợp đầy đủ Solo Leveling cùng HUD chiến đấu: chỉ số, kỹ năng, nhiệm vụ, quân đoàn, hầm ngục, thanh máu và số sát thương."
author = "Phàm Nhân Tu Tiên; Solo Leveling: Saikuno"
version = "2.0.3"

api_version = 10
dst_compatible = true
client_only_mod = false
all_clients_require_mod = true
server_only_mod = false

configuration_options = {}

-- Thần Hỏa dùng thiết lập cố định trong main/ttk_vinhhangthanhoa.lua.

-- Solo Leveling 2.2.7 configuration (original keys and defaults).
local function SoloOptions()
local a = {
    {["description"] = "G", ["data"] = 103},
    {["description"] = "H", ["data"] = 104},
    {["description"] = "I", ["data"] = 105},
    {["description"] = "J", ["data"] = 106},
    {["description"] = "K", ["data"] = 107},
    {["description"] = "L", ["data"] = 108},
    {["description"] = "N", ["data"] = 110},
    {["description"] = "O", ["data"] = 111},
    {["description"] = "P", ["data"] = 112},
    {["description"] = "R", ["data"] = 114},
    {["description"] = "T", ["data"] = 116},
    {["description"] = "X", ["data"] = 120},
    {["description"] = "Z", ["data"] = 122},
    {["description"] = "F1", ["data"] = 282},
    {["description"] = "F2", ["data"] = 283},
    {["description"] = "F3", ["data"] = 284},
    {["description"] = "F4", ["data"] = 285},
    {["description"] = "F5", ["data"] = 286},
    {["description"] = "F6", ["data"] = 287},
    {["description"] = "F7", ["data"] = 288},
    {["description"] = "F8", ["data"] = 289},
    {["description"] = "F9", ["data"] = 290},
    {["description"] = "F10", ["data"] = 291},
    {["description"] = "F11", ["data"] = 292},
    {["description"] = "F12", ["data"] = 293}
}
local configuration_options = {
    {name = "key_config", label = "Phím Tắt", hover = "phím tắt để mở Bảng Tổng Hợp", options = a, default = 120},
    {
        name = "monster_day",
        label = "Giới Hạn",
        hover = "Giới hạn về số ngày mà lượng máu hàng ngày của quái có thể tăng lên",
        options = {
            {description = "Bật", data = false, hover = "Máu quái tăng đến giới hạn sẽ dừng"},
            {description = "Tắt", data = true, hover = "Máu quái tăng vô hạn theo thời gian"}
        },
        default = false
    },
    {
        name = "can_show_equip",
        label = "Chỉ Số",
        hover = "Hiện thông tin trang bị cho người khác thấy khi ping đồ\nPhím tắt: Shift + Alt + chuột trái",
        options = {
            {description = "Tắt", data = false, hover = ""},
            {description = "Bật", data = true, hover = "Khuyên dùng"}
        },
        default = true
    },
}

return configuration_options
end
local solo_options = SoloOptions()
for i = 1, #solo_options do
    local option = solo_options[i]
    option.label = "Solo: " .. option.label
    configuration_options[#configuration_options + 1] = option
end
