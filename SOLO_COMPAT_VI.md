# Tương thích vũ khí với hệ Solo tích hợp trong Phàm Nhân

Solo đã tích hợp và luôn nạp cùng Phàm Nhân. Mọi vũ khí phải hoạt động với hệ này và mức tăng sát thương lớn; không cộng bonus Solo thủ công lần thứ hai. Tài liệu này mô tả giao diện tích hợp vũ khí, không hướng dẫn bật mod Solo độc lập.

Đối chiếu mã nguồn Solo Leveling 2.2.7 (`3780347550`).

| Vũ khí | Tích hợp |
| --- | --- |
| Tinh La Kiếm | Sát thương gốc luôn là 100, kể cả hết độ bền; giữ cường hóa Solo qua `ttk_weapon_damage.SetBase` khi đổi độ bền, không tháo/trang bị lại kiếm. |
| Lục Mạch Thần Kiếm | Vật phẩm giữ sát thương số để Solo cường hóa; kiếm bay nhận tỷ lệ cường hóa và kích hoạt hiệu ứng khi trúng. Lệnh điều khiển không tạo thêm một đòn sát thương. Ngọc cầu vồng và tế luyện không cộng dồn qua lưu/tải. |
| Cửu Thiên Tinh Thần Phiên | Hồn Vệ nhận sát thương cờ và tế luyện. Đạn trúng đi qua combat của chủ nhân; giữ vùng đánh và lọc đồng minh. Cờ đặt xuống lưu cường hóa và hiệu ứng đánh để dùng tiếp. |
| Thần Hi Quang Trượng | Dùng weapon/combat chuẩn, sát thương gốc dạng số; Solo xử lý trực tiếp. |

Nhất Vũ Phương Hoa và Ngự Long Đăng không có thành phần vũ khí gây sát thương.

Vũ khí mới cần giữ sát thương gốc độc lập với số đã cường hóa; dùng `SetBase` khi thay đổi trạng thái. Với đạn hoặc vật triệu hồi, dùng combat của người đánh và chuyển hiệu ứng qua `ForwardAttack` đúng một lần lúc trúng. Không gọi lại OnAttack của vật phẩm điều khiển từ đạn vì có thể tạo vòng lặp triệu hồi. Component Solo do bootstrap Phàm Nhân quản lý; không tạo thêm bản sao ở từng vũ khí.

Kiểm chứng: `tools/test_weapon_solo.py` dùng mã cường hóa Solo thật; `tools/test_vanhonphien_solo.py` dùng projectile DST thật. Các bài này kiểm tra mức cường hóa cao, nạp độ bền, lưu/tải kiếm bay, cờ đặt xuống, hiệu ứng đánh và khôi phục trạng thái khi callback lỗi. Vẫn cần thử trong phiên chơi thực tế với cấu hình mod của người chơi.
