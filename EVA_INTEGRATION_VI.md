# Phàm Nhân Tu Tiên — tích hợp nhân vật EVA

EVA là nhân vật trong màn chọn nhân vật của Phàm Nhân, prefab `eva`. Ngoại hình tím EVA2 là diện mạo mặc định duy nhất qua `eva_none`; bản trắng–tím EVA3 và skin chọn riêng `eva_purple` đã được gỡ. Bộ alias chuyển động/đầu thử nghiệm cũ đã được gỡ. Dùng cho world mới theo yêu cầu người dùng.

## Sử dụng

- Bật Phàm Nhân; tắt bản EVA độc lập. Phàm Nhân tự nạp toàn bộ mã/tài nguyên EVA.
- EVA dùng chung cấp nhân vật `hh_leveling` đã tích hợp trong Phàm Nhân.
- Giữ toàn bộ Hồn Lực, mốc mở kỹ năng, giá kỹ năng và HUD đã duyệt. Bảng mặc định thu gọn; mở theo cấp 10/20/30/50/100. Thuấn Ảnh dùng phím R.
- Cấu hình EVA được thêm vào menu Phàm Nhân. Không thay đổi cấu hình Solo tích hợp.

## Các sửa chữa khi kiểm tra

- Cánh/Thuấn Ảnh đọc `locomotor.hopping`; không gọi bắt buộc `IsHopping()` vì DST đang cài không có phương thức đó.
- Thuấn Ảnh giữ action/component cũ để tương thích save nhưng nay kích hoạt bằng phím R, dịch chuyển sau 0,25 giây, hồi 15 giây và gây một lần 600 sát thương cơ bản dọc đường qua pipeline Phàm Nhân. EVA không hóa cáo/ẩn hình, không sinh hoa/lửa; hiệu ứng dùng `spear_wathgrithr_lightning_lunge_fx` đã precache theo dependency nhân vật.
- Tuning chi phí cánh thống nhất 100 Hồn Lực.
- Bỏ cơ chế alias nhân vật cũ; EVA chỉ còn skin mặc định `eva_none`, dùng build tím.
- Bỏ vật phẩm/công thức Lưỡi Hái EVA. Nhân vật mới vào thế giới với túi đồ trống; kỹ năng Trận Lưỡi Hái vẫn giữ nguyên.
- Bộ kiểm tra cập nhật tên Dạ Du, giá cánh và cấp mở kỹ năng để kiểm tra đúng hành vi hiện tại.

## Kiểm chứng và giới hạn

Đợt tích hợp ban đầu có 22/22 bộ kiểm tra Python/Lua đạt. Đây là kết quả lịch sử; runtime hiện tại đã đổi cấp chung, ngoại hình và phím tắt, không còn là bản sao byte-identical của EVA độc lập. Hướng dẫn kiểm tra hiện tại: [docs/eva/EVA_TINH_NANG_VA_LENH_TEST.md](docs/eva/EVA_TINH_NANG_VA_LENH_TEST.md).

Chạy DST dedicated offline trong `.superpowers/eva-vietnamese/fresh-server`, dùng world kiểm thử riêng, không đụng save thật/Steam mods. Script `tools/eva_integration_smoke.lua` kiểm tra sinh EVA tay không cùng component Phàm Nhân, 5 chiêu trên bảng, Thuấn Ảnh, hai đòn đánh sinh kiếm khí, sát thương, Hồn Lực và kết thúc hiệu ứng. Chạy bằng `tools/run_eva_integration_smoke.py` ở gốc workspace.

Dedicated server không render giao diện nên kết quả không chứng minh FPS, hình ảnh trên client hay độ trễ nhiều người chơi. Các mục đó cần duyệt trực tiếp trong game. Log còn có cảnh báo tài nguyên của các phần Phàm Nhân khác; không quy chúng thành lỗi EVA và không sửa ngoài phạm vi.

Nguồn và hash tài nguyên: `provenance/eva-assets.json`. Báo cáo test chi tiết: `mods/eva-assets-work/audit-integration/verified-tests.json` ở workspace.

## Việt hóa EVA 1.2.1

Toàn bộ tên hiển thị, mô tả nhân vật, cấu hình và thông báo EVA dùng tiếng Việt. Bộ thoại có 3974 mục, gồm nền Việt hóa và các câu bổ sung; ghi công tại CREDITS_EVA_VI.md. Prefab, component, cấu hình và tài nguyên đã đổi sang mã eva. Đây là bản dành cho thế giới mới.

Thoại tương tác nhân vật đã được biên tập riêng cho EVA; thoại đồ vật giữ nguyên.
