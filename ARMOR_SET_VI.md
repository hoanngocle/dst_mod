# Bộ giáp Tử Xá và Vân Mạc Thượng Trang

Tử Xá Diện Giáp và Tà Sát Hộ Giáp khóa bằng `TECH.LOST`: mọi nhân vật phải học bản vẽ tương ứng trước khi chế tạo. Sau khi học không cần trạm chế tạo. Vân Mạc Thượng Trang vẫn mở sẵn (`TECH.NONE`).

| Trang bị | Công thức |
| --- | --- |
| Tử Xá Diện Giáp (`ttk_zcmj`) | 1 Tử Thần Ma Ngọc + 2 Ngọc Tím + 2 Ngọc Vàng + 1 Thượng Phẩm Linh Thạch |
| Tà Sát Hộ Giáp (`ttk_xshj`) | 1 Ma Cốt + 1 Giáp Xương (`armor_skeleton`) + 2 Ngọc Cam + 2 Ngọc Lục |
| Vân Mạc Thượng Trang (`ttk_yunxiao_ymsz`) | 8 Lông Bò + 10 Vàng + 2 Trung Phẩm Linh Thạch |

Ma Cốt là tên mới của Ma Cốt Quỷ Giáp, giữ mã `ttk_boss_mgqg` để tương thích save. Tử Thần Ma Ngọc giữ mã `ttk_boss_zcmy`. Hai bản vẽ dùng mã `ttk_zcmj_blueprint` và `ttk_xshj_blueprint` do cơ chế blueprint của DST tạo từ công thức.

Tử Vân Ma Quân chắc chắn rơi 1 bản vẽ Tử Xá Diện Giáp khi bị hạ ở pha cuối. Ma Tướng Phù Đồ chắc chắn rơi 1 bản vẽ Tà Sát Hộ Giáp. Công thức đã học trong save cũ vẫn được giữ theo cơ chế builder của DST.

## Hiệu ứng giữ từ bản gốc

- Mũ và giáp thân: mỗi món 830 độ bền, hấp thụ 90% sát thương thường, 10 phòng thủ phẳng. Mũ tăng 20% sát thương; giáp thân tăng 10% tốc độ.
- Mặc đủ bộ: khi bị đánh hợp lệ, 66% cơ hội kích hoạt kết giới 2 giây; sau đó hồi 8 giây. Kết giới chặn sát thương đi qua `inventory:ApplyDamage`, gồm sát thương thường và đặc biệt. Không thay đổi sát thương trực tiếp bỏ qua API này.
- Hai món tự phục hồi 1% độ bền mỗi 10 giây. Trung Phẩm Linh Thạch sửa 20%; từ chối nhận khi đầy. Hỏng vẫn giữ vật phẩm để sửa.
- Áo: 840 độ bền, hấp thụ 85%, giữ ấm 240. Hao 1,25% độ bền mỗi 60 giây mặc; sửa bằng Bộ Kim Chỉ như bản gốc.
- Áo dùng prefab `minerhatlight` của game, tăng bán kính riêng cho đèn của áo lên 5; giữ cường độ 0,7, falloff 0,4 và cùng màu mũ thợ mỏ. Tắt khi cởi, chuyển sang mannequin hoặc vật phẩm bị xóa.

## Nguồn và kiểm tra

Nguồn: bản sao Tu Tiên gốc Workshop `3235319974`; prefab gốc đối chiếu cùng SHA256 với bản Việt hóa `3721846643`. Tên prefab, đường dẫn tài nguyên và tag riêng dùng namespace `ttk_`; bank/build bên trong giữ tên gốc. Không sửa nguồn Workshop.

Kiểm tra: `tools/test_armor_set.py` chạy callback Lua 5.1 với fixture engine và component Trader thật của DST; kiểm tra công thức, chỉ số, sửa đồ, kết giới/hồi chiêu, nguồn sáng và phân tách client/server. `tools/audit_registration.py` kiểm tra cú pháp/phụ thuộc Lua, atlas/texture và ZIP hoạt ảnh toàn mod. Chưa chạy thử trực tiếp trong game.
