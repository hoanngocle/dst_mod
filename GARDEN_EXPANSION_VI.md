# Bốn món bổ sung từ Tu Tiên 19.7

Nguồn: bản cục bộ `mods/mod_steam/3235319974`. Đọc Lua bằng bảng byte, không chạy loader nguồn. Mọi nhân vật chế tạo và sử dụng được; không cần bật Tu Tiên gốc.

| Món | Mã TTK | Công thức | Trạm |
|---|---|---|---|
| Nguyệt Hoa Nhiếp Dược Chi | `ttk_yhsyz` | 12 Cành Cây + 6 Cánh Hoa + 2 Ngọc Cam + 1 Trung Phẩm Linh Thạch | Máy Khoa Học |
| Hoán Nguyệt Trì | `ttk_hyc` | 10 Mảnh Kính Trăng + 3 Ngọc Vàng + 15 Đá Cẩm Thạch + 1 Hạ Phẩm Linh Thạch | Máy Khoa Học |
| Hạnh Hoa Thụ | `ttk_tree_xhs` | 4 Gỗ Sống + 2 Ngọc Vàng + 1 Hạ Phẩm Linh Thạch | Máy Luyện Kim |
| Hoán Miêu Thụ Ốc | `ttk_hmsw` | 3 Đá Cắt + 10 Gỗ + 3 Đuôi Mèo + 10 Hạ Phẩm Linh Thạch | Máy Khoa Học |

Dụng cụ ở mục Công cụ/Làm vườn; ba công trình ở Công trình/Làm vườn. Lượng nguyên liệu và trạm theo nguồn, linh thạch đổi sang TTK. Dụng cụ giữ cấm giải cấu trúc như nguồn.

## Dụng cụ hái

Trang bị trên tay rồi hái linh thảo trưởng thành trong Ngọc Lộ Tiên Khu bằng thao tác hái thông thường. Mỗi lượt thành công tiêu hao một trong 100 lượt, tăng tỷ lệ trả hạt lên 75% thay vì 40%, bỏ tác hại khi hái cả sáu loại linh thảo. Lượt cuối vẫn được bảo vệ rồi dụng cụ biến mất. Không tăng tốc sinh trưởng và không thu cây non. Không thêm action/component của mod nguồn; dùng callback thu hoạch hiện có của TTK. Hỗ trợ dụng cụ nguồn qua tag `xd_yhsyz` vẫn được giữ.

## Hồ cá

Đưa cá ao hoặc cá biển sống vào hồ: mỗi lần nhận một cá, tối đa ba vị trí. Mỗi vị trí có đồng hồ riêng 3.360 giây. Chọn **Thu hoạch cá** để nhận bốn cá cùng loại từ mỗi vị trí đã đủ thời gian, rồi thả giống mới. Không thu cá non bằng thao tác này. Hồ đầy từ chối cá mới; không nhận thịt cá.

Đồng hồ dùng component Timer chuẩn DST; component riêng chỉ lưu tên loài theo vị trí. Tắt máy chủ không tự cộng thời gian thực. Hồ sáng ban đêm với bán kính 3,5, không dùng nhiên liệu. Khi đập hồ, cá non được trả lại, vị trí trưởng thành trả bốn cá; khắc phục việc nguồn xóa hồ mà không trả cá đang nuôi.

## Cây và nhà Catcoon

Hạnh Hoa Thụ dùng cùng hệ cây cảnh TTK: che chở, nhiệt độ 19°C bán kính 6, một Ngọc Vàng mỗi khoảng 3.360 giây + 0–100 giây. Dùng chung bộ hoạt ảnh cây đã có.

Hoán Miêu Thụ Ốc giữ một Catcoon và hồi con sau 480 giây. Khi đủ thú, mỗi lần sang ngày tạo tối đa 2–3 quà cùng loại ngẫu nhiên tùy chỗ trống. Nhận quà bằng tương tác chuẩn. Giữ danh sách quà nguồn, bao gồm cả quà chất lượng thấp; không bảo đảm ngày nào cũng có nguyên liệu tốt. Inventory, ChildSpawner và tuổi các ô giữ qua lưu/tải như nguồn.

## Kiểm tra

`tools/test_garden_expansion.py` trong mod kiểm tra logic với Timer, Trader, FiniteUses thực của DST và mô phỏng API thực thể: sức chứa, thời gian nuôi lệch nhau, lưu/tải, không thu hai lần, trả cá khi tháo, 100 lượt bảo vệ, từ chối giao cá sai, ánh sáng đêm, ranh giới máy chủ/máy khách, quà Catcoon và cây ngọc vàng. Kiểm tra này không thay thế việc quan sát hình ảnh, thao tác và đồng bộ trong game.

Script tài nguyên có thể chạy lại: `tools/port_ttk_garden_expansion.py` ở gốc dự án. Không sửa nguồn Steam, không đóng ZIP hoặc mở game.

Kết quả kiểm tra lần bổ sung này:

- Bộ kiểm tra mới đạt, gồm cả callback thu hoạch thực của sáu linh thảo ở lượt cuối và đăng ký bốn công thức không khóa nhân vật.
- Kiểm tra hạt giống hiện có đạt.
- Rà 171 tệp Lua, 175 tham chiếu texture và 148 gói hoạt ảnh đạt; không thiếu `require`/`modimport` tĩnh.
- Sinh lại dữ liệu và icon wiki; bài kiểm tra trang `app/tu-tien-ky/page.test.tsx` đạt.
- Rà mã độc lập không tìm thấy lỗi cần sửa trong phạm vi bốn món. Chưa xác nhận hình ảnh, thao tác multiplayer và lưu/tải toàn bộ thế giới trong game thật.
