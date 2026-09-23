# Phàm Nhân Tu Tiên 2.0 — Boss và linh vật

## Xuất hiện và triệu hồi

Chín boss sinh tự nhiên lần đầu trên đất liền của thế giới chính. Hệ thống tránh cổng, người chơi, công trình, nước và Thiên Cơ Ốc. Nếu chưa có vị trí an toàn, boss đó chờ lần thử tiếp theo; không ép sinh trong căn cứ.

Thanh Tụ Đan Tiên (`ttk_qxdx`), Ma Tướng Phù Đồ (`ttk_futu`) và Tử Vân Ma Quân (`ttk_ziyunboss`) là ba boss duy nhất. Chúng trung lập cho đến khi người chơi hoặc thực thể thuộc người chơi tấn công. Khi chết thật, chúng không sinh lại và không có phù triệu hồi. Chuyển pha hồi sinh trong trận Tử Vân không được tính là chết cuối cùng.

Sáu boss còn lại mỗi lần chết thật rơi **1 linh vật ăn được + 1 vật phẩm triệu hồi tương ứng**, tổng cộng cho cả trận, không nhân theo số người tham gia. Bạch Hổ, Kim Phượng và Kỳ Lân dùng **Tàn Hồn** mang hình linh thú nhỏ; Thượng Cổ Hắc Ám dùng **Tâm Nhĩ Hắc Ám**, Hươu Một Mắt dùng **Độc Nhãn Tàn Hồn**, Tà Sát Thù Vương dùng **Huyết Ngọc Tri Thù Noãn**. Dùng vật phẩm từ túi trên đất liền để đánh lại. Boss cùng loại phải đã chết; dùng thất bại không mất vật phẩm. Không dùng được trong hang, trên thuyền hoặc trong Thiên Cơ Ốc.

Trạng thái được lưu cùng thế giới. Khởi động lại không sinh thêm boss, không hồi sinh boss duy nhất. Rollback theo đúng trạng thái tại thời điểm save. Phân thân và quái phụ không nhận suất boss chính hay phát phần thưởng chính.

## Sáu linh vật

| Boss | Linh vật | Mỗi lần ăn, tối đa 10 lần | Tổng ở 10/10 | Đặc tính ở 10/10 |
|---|---|---|---|---|
| Tàn Khu Bạch Hổ | Bạch Hổ Huyết Tủy | +4 sát thương chuẩn | +40 | +10 điểm phần trăm tỉ lệ chí mạng |
| Kim Phượng Thần Niệm | Kim Phượng Tinh Huyết | +20 máu tối đa | +200 | Miễn sát thương do quá nóng |
| Kỳ Lân Tàn Hồn | Kỳ Lân Linh Đan | +20 mana tối đa | +200 | Miễn sát thương do quá lạnh |
| Tà Sát Thù Vương | Ma Thù Nội Đan | +20 độ no tối đa | +200 | Miễn độc theo cơ chế Solo đã tích hợp |
| Thượng Cổ Hắc Ám | Hắc Ám Hồn Tinh | +2 giảm sát thương nhận vào dạng cố định | +20 | Miễn bị cưỡng ép ngủ; vẫn được chủ động nghỉ |
| Hồn Phách Tinh Thể Hươu Một Mắt | Băng Phách Tinh Tủy | +20 tinh thần tối đa | +200 | Miễn đóng băng |

Mỗi người có sáu bộ đếm riêng. Mỗi món hồi phục cơ bản 50 máu, 75 độ no và 50 tinh thần, chịu giới hạn thanh và các modifier của nhân vật. Từ lần thứ 11 của cùng loại chỉ còn hồi phục, không cộng thêm chỉ số hay đặc tính. Không hồi mana từ món ăn.

Tiến độ lưu theo nhân vật và giữ qua chết/hồi sinh, đổi nhân vật qua cơ chế chuyển component. Bonus tách khỏi điểm AP và trang bị của Solo. Miễn nóng/lạnh là cơ chế nhiệt độ, không đồng nghĩa miễn sát thương lửa hoặc miễn đóng băng.

## Kiểm tra trong console

Máy chủ: `TheWorld.components.ttk_bossregistry.entries` chứa trạng thái của chín boss. Trạng thái `missing` cho biết thực thể từng sinh đã bị xóa bất thường; hệ thống không tự tạo bản thay thế.

Người chơi: `player:GetTtkBossProgressCount("jfsn")` trả số Kim Phượng Tinh Huyết đã hấp thụ (0–10), có đồng bộ client. Đổi tên từ Phượng Tủy giữ nguyên tiến độ cũ. Thay khóa bằng `baihu`, `qlch`, `spiderqueen`, `stalke_fuben`, `deerclops_ziyun` cho loại khác.

Không dùng `c_spawn` để kiểm tra phần thưởng chính: boss debug không được đăng ký là boss chính. Kiểm tra bằng sổ thế giới và vật phẩm triệu hồi để đi qua đúng vòng đời.

Chiến lợi phẩm khác và các công dụng đang chờ quyết định được ghi riêng trong [BOSS_DROPS_VI.md](BOSS_DROPS_VI.md). Kết quả kiểm tra thực tế được ghi trong báo cáo tích hợp ở `docs/superpowers/reports/2026-09-20-pham-nhan-boss-audit.md` của dự án.
