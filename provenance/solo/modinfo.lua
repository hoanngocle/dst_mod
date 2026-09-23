name = "【Solo Leveling】"
author = "Saikuno"
version = "2.2.7"
description =
    "󰀘󰀘 Phiên Bản 2.0 - Chương 2 󰀘󰀘\n\n󰀄 Ra mắt hệ thống độc quyền Hầm Ngục !\n\n󰀠 Ra mắt hệ thống độc quyền Bảng Chỉ Số !\n\n󰀦 Ra mắt hệ thống độc quyền Nhiệm Vụ Ngày !\n\n󰀏 Ra mắt hệ thống độc quyền Hiệp Hội !\n\n󰀏 Ra mắt hệ thống độc quyền Trích Xuất - Đệ Tử Bóng Ma !\n\n󰀌 Ra mắt hệ thống độc quyền Nâng Cấp Quân Đoàn !\n\n󰀧 Ra mắt hệ thống độc quyền Trừng Phạt !\n\n󰀄 Ra mắt 60+ Vật Phẩm, Thuốc và Vũ Khí mới !\n\n󰀃 Đăng ký kênh Youtube: Saikuno hoặc mình sẽ lấy 3 tô cơm của bạn !"
forumthread = ""
api_version = 10
priority = -10
dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false
all_clients_require_mod = true
icon_atlas = "modicon.xml"
icon = "modicon.tex"
server_filter_tags = {"saikuno", "dst", "solo leveling", "mod", "cường hóa", "hợp thành", "khảm nạm", "ngẫu luyện", "kế thừa", "nâng cấp", "dung hợp"}
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
local teleport_hotkey_options = {
    {["description"] = "A", ["data"] = 97},
    {["description"] = "C", ["data"] = 99},
    {["description"] = "D", ["data"] = 100},
    {["description"] = "E", ["data"] = 101},
    {["description"] = "F", ["data"] = 102},
    {["description"] = "G", ["data"] = 103},
    {["description"] = "H", ["data"] = 104},
    {["description"] = "I", ["data"] = 105},
    {["description"] = "J", ["data"] = 106},
    {["description"] = "M", ["data"] = 109},
    {["description"] = "O", ["data"] = 111},
    {["description"] = "P", ["data"] = 112},
    {["description"] = "Q", ["data"] = 113},
    {["description"] = "R", ["data"] = 114},
    {["description"] = "S", ["data"] = 115},
    {["description"] = "T", ["data"] = 116},
    {["description"] = "U", ["data"] = 117},
    {["description"] = "W", ["data"] = 119},
    {["description"] = "Y", ["data"] = 121},
    {["description"] = "Z", ["data"] = 122},
    {["description"] = "0", ["data"] = 48},
    {["description"] = "1", ["data"] = 49},
    {["description"] = "2", ["data"] = 50},
    {["description"] = "3", ["data"] = 51},
    {["description"] = "4", ["data"] = 52},
    {["description"] = "5", ["data"] = 53},
    {["description"] = "6", ["data"] = 54},
    {["description"] = "7", ["data"] = 55},
    {["description"] = "8", ["data"] = 56},
    {["description"] = "9", ["data"] = 57},
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
    {["description"] = "F12", ["data"] = 293},
    {["description"] = "Mũi tên lên", ["data"] = 273},
    {["description"] = "Mũi tên xuống", ["data"] = 274},
    {["description"] = "Mũi tên phải", ["data"] = 275},
    {["description"] = "Mũi tên trái", ["data"] = 276},
    {["description"] = "Home", ["data"] = 278},
    {["description"] = "Insert", ["data"] = 277},
    {["description"] = "Delete", ["data"] = 127},
    {["description"] = "End", ["data"] = 279},
    {["description"] = "Page Up", ["data"] = 280},
    {["description"] = "Page Down", ["data"] = 281}
}
configuration_options = {
    {
        name = "hoverer_text",
        label = "UI Gốc",
        hover = "Hiện UI gốc khi di chuyển chuột vào vật thể",
        options = {
            {description = "Hiện", data = false, hover = "Khi chỉ chuột sẽ hiện 2 bảng, khá rối mắt"},
            {description = "Không hiện", data = true, hover = "Khuyên dùng"}
        },
        default = true
    },
    {
        name = "hoverer_effect",
        label = "UI Mới",
        hover = "Hiển thị thông tin",
        options = {
            {description = "Đầy đủ", data = true, hover = "Giống như mod Showme"},
            {description = "Rút gọn", data = false, hover = "Chỉ hiện thị thông tin cần thiết"}
        },
        default = true
    },
    {name = "key_config", label = "Phím Tắt", hover = "phím tắt để mở Bảng Tổng Hợp", options = a, default = 120},
    {
        name = "teleport_hotkey",
        label = "Phím Dịch Chuyển",
        hover = "Phím kích hoạt kỹ năng Dịch Chuyển. Mặc định là Z. Không thể chọn X, V, B, N, K hoặc L.",
        options = teleport_hotkey_options,
        default = 122
    },
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
    {
        name = "can_show_text_fx",
        label = "Hiệu Ứng",
        hover = "Hiện tên các hiệu ứng gây ra hoặc nhận vào\nnhư: bạo kích, xuyên giáp, độc, làm chậm... ",
        options = {
            {description = "Tắt", data = false, hover = ""},
            {description = "Bật", data = true, hover = "Khuyên dùng"}
        },
        default = true
    },
    {
        name = "equip",
        label = "Mod Khác",
        hover = "Hỗ trợ trang bị từ mod khác (có thể gây crash)",
        options = {
            {description = "Tắt", data = false, hover = "Chỉ trang bị cho phép"},
            {description = "Bật", data = true, hover = "Tất cả trang bị"}
        },
        default = false
    },
    {
        name = "announcement",
        label = "Thông Báo",
        hover = "Hỗ trợ hiện thông báo sự kiện",
        options = {{description = "Tắt", data = false, hover = ""}, {description = "Bật", data = true, hover = ""}},
        default = true
    }
}
