# Phàm Nhân Tu Tiên 2.0 — gỡ Phụ Ma

Mã hiện tại ở mods/TuTienKy. Đã bỏ DoIncrease, xác suất/vật liệu/config/UI riêng và hai nhánh thông báo cuộn nâng cấp. Giữ khóa do_mode để đọc save; mọi giá trị cũ khác nil chuyển sang strengthen trước SetLevel (cap 13). Giữ toàn bộ buff cường hóa và điều kiện thưởng ngẫu nhiên bằng strengthen_prize; 24 biểu thức cũ được đối chiếu với Lua 5.1. Không có prefab Phụ Ma riêng đang đăng ký để xóa; Đá Tím còn phục vụ game và được giữ.

Bổ sung chặn +13 trước khi RPC trừ đá. RPC giữ tên và chấp nhận đối số cũ nhưng không còn đổi chế độ.

Kiểm chứng:
- test_strengthen_only.py: API cũ đã mất; migration 0/6/13/22, save, giới hạn, xác suất và mốc thất bại.
- test_weapon_solo.py: sát thương cường hóa, sửa chữa/độ bền, Vạn Hồn Phiên, phi kiếm và hệ số tế luyện.
- strengthen_only_smoke.lua chạy trong DST dedicated Phàm Nhân: thành công, đối số RPC cũ true, không trừ Đá Tím, +13 không trừ đá, tụt cấp/mất đồ, từng bùa và cả hai bùa, save roundtrip. native-smoke.log có PHAM_NHAN_STRENGTHEN_SMOKE_PASS. Chưa kiểm tra client đồ họa.
- CodeGraph 1.6.0 từ https://github.com/colbymchenry/codegraph, SHA256 khớp manifest phát hành. Cài cục bộ .superpowers/codegraph-tools/v1.6.0/codegraph-win32-x64/bin/codegraph.cmd; telemetry tắt khi chạy. Index riêng mods/TuTienKy; mã tên làm rối và gọi qua bảng cần đối chiếu thêm tìm kiếm text và test engine.
- Rà soát độc lập bốn file runtime: không phát hiện vấn đề đáng kể.

Lệnh chạy lại từ workspace (dùng Python có lupa.lua51 tại .superpowers/ttk-solo-integration/lua-runtime):

    python mods/TuTienKy/tools/test_strengthen_only.py
    python mods/TuTienKy/tools/test_weapon_solo.py
    python mods/solo-assets-work/lam-phuong/run_smoke.py --smoke mods/TuTienKy/tools/strengthen_only_smoke.lua --log artifacts/pham-nhan-remove-phu-ma/native-smoke.log --marker PHAM_NHAN_STRENGTHEN_SMOKE

Dọn thư mục: xem artifacts/mods-cleanup/deleted.json. Giữ nguồn mod, assets nguồn, công cụ, backup làm đầu vào và bằng chứng test. Xóa runtime có thể tạo lại sau khi máy chủ kết thúc; gỡ junction trước khi xóa đệ quy để không đụng data Steam. EVA ingame/runtime được giữ vì runner lịch sử chưa có bootstrap và thiếu smoke.lua bên ngoài runtime.
