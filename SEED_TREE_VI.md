# Phàm Nhân Tu Tiên 2.0 — hạt cây từ Thanh Tụ Đan Tiên

Vật phẩm `ttk_boss_zcyseed` giữ tên hiển thị Hạt Tử Chi và ID cũ để dùng tiếp đồ đã có trong save. Nguồn là `xd_zcyseed`, trồng thành cây `xd_zuichunyan` của Tu Tiên 19.7. Đây là cây lấy gỗ tán rủ, không phải nấm linh chi hoặc linh thảo trồng trong Tiên Khu.

## Trồng và thu hoạch

- Cầm hạt và trồng trên nền đất hợp lệ theo chế độ trồng cây của DST, không cần luống nông trại. Mỗi lần trồng tốn một hạt, ngẫu nhiên 50% cây xanh và 50% cây tím.
- Cây non bén rễ sau 960 giây mô phỏng; cây nhỏ lớn tiếp sau khoảng 1.400–1.480 giây theo cấu hình nguồn (cơ chế tăng trưởng mùa xuân có thể ảnh hưởng thời gian). Timer và giai đoạn sinh trưởng được lưu.
- Chặt cây nhỏ: 2 gỗ + 1 hạt. Chặt cây lớn: 3 gỗ + 2 hạt, thêm 17% cơ hội được 1 Gỗ Sống. Đào gốc: thêm 1 gỗ.
- Hai màu có cùng chức năng. Cây có thể cháy; chặt cây cháy được 1 than và 1/3 cơ hội thêm 1 than.
- Đào cây non nhận một cành cây theo nguồn. Gốc cây đã chặt không tự mọc lại.
- Hạt ăn được: 5 máu, 12 độ no, 2 tinh thần. Hạt xếp chồng được và hư hỏng theo `TUNING.PERISH_PRESERVED` của DST; đồ cũ bắt đầu có độ tươi sau khi nâng cấp.

## Phần thưởng cố định

Thanh Tụ Đan Tiên chết rơi chắc chắn 2 Hạt Tử Chi và 3 hạt mỗi loại linh thảo `hsc`, `dms`, `qfx`, `cyh`, `lmg`, `yhh`: tổng 20 hạt. Bỏ hai lượt đan cổ ngẫu nhiên và hai lượt hạt ngẫu nhiên cũ. Ba Lô Tiên Hà chắc chắn rơi 1 chiếc (100%). Những phần thưởng khác giữ nguyên. Không trả thưởng bổ sung cho boss đã chết trong save trước bản cập nhật.

Sáu hạt linh thảo tiếp tục dùng Ngọc Lộ Tiên Khu; hạt cây này dùng trực tiếp trên đất. Thu hoạch linh thảo bằng Nguyệt Hoa Nhiếp Dược Chi còn độ bền: 75% cơ hội ra hạt; khi ra hạt, 75% nhận 1 hạt và 25% nhận 2 hạt cùng loại. Mỗi lần dùng tiêu hao 1 độ bền. Hái tay: 40% nhận 1 hạt. Mỗi lần thu hoạch vẫn nhận 1 linh thảo.

## Nguồn và tái tạo

`tools/port_phamnhan_seed_tree.py` giải mã tĩnh hai prefab nguồn `xd_zuichunyan.lua`, `xd_planted_tree.lua`, đổi namespace cây sang `ttk_zuichunyan_*`, chuyển hạt thu hoạch về ID hiện có, dùng các hiệu ứng lá đã chuyển cùng boss và sao chép hai animation gốc + bốn icon bản đồ. Không thực thi loader nguồn. Tên bank/build bên trong animation vẫn giữ `xd_`.

`tools/port_phamnhan_boss_combat.py` giữ thay đổi bộ hạt cố định khi tái tạo Thanh Tụ Đan Tiên. Mười prefab đan cổ đã bị loại bỏ theo yêu cầu; không còn đăng ký vật phẩm hoặc rơi từ boss.
