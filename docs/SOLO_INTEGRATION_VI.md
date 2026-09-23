# Solo trong Phàm Nhân Tu Tiên 2.0

Gói này chứa đầy đủ bản Solo Leveling 2.2.7 đang có trong dự án, gồm chỉ số/cấp độ, mana, kỹ năng, nhiệm vụ, hiệp hội, quân đoàn/bóng ma, hệ trang bị, cường hóa, UI, RPC, vật phẩm, boss và hầm ngục. Solo chạy mặc định khi bật Phàm Nhân Tu Tiên.

## Cài đặt

1. Dừng server và sao lưu toàn bộ cụm save trước khi đổi bản mod.
2. Chép thư mục `PhamNhanTuTien` vào `mods` của game/server. Gói `TuTienKy_v0.10.0.zip` thuộc bản phát hành cũ, không phải gói 2.0. Máy khách và hai shard Master/Caves cần cùng phiên bản.
3. Chỉ bật **Phàm Nhân Tu Tiên**; tắt Solo Leveling riêng (`workshop-3780347550`, `3780347550`, `SoloLeveling` hoặc bản đổi tên). Nếu bật trùng, bản gộp báo lỗi và hướng dẫn tắt Solo riêng trước khi nạp hệ thống.
4. Đặt cấu hình Solo trong bảng cấu hình Phàm Nhân Tu Tiên, dưới các nhãn `Solo:`. Những thiết lập riêng đã lưu dưới mod Solo cũ không tự chuyển; cần chép các giá trị mong muốn sang Phàm Nhân Tu Tiên. Giá trị mặc định Solo được giữ nguyên, kể cả các lựa chọn `false`.
5. Khởi động lại cụm sau khi cập nhật đủ các máy. Gói không tự sửa modoverrides hoặc save đang sử dụng.

HUD chiến đấu nay được tích hợp trực tiếp trong **Phàm Nhân Tu Tiên**. Chỉ bật Phàm Nhân; tắt `SoloCombatHUD`, Simple Health Bar DST và Epic Healthbar độc lập để tránh hai bộ hook/UI cùng chạy. HUD dùng sát thương HP thật từ server, phân loại thường/chí mạng/xuyên giáp, có thanh boss theo phase và thanh máu trên đầu. Khi HUD bật, chữ chiến đấu cũ bị tắt nhưng EXP, nhiệm vụ và lên cấp vẫn được phục hồi có chọn lọc.

Smoke test trên server DST offline đã xác nhận bootstrap tích hợp, component Solo, RPC sát thương thường/chí mạng/xuyên giáp và proxy thanh máu. Phần đồ họa và phiên host/client qua mạng chưa được playtest.

## Thế giới và dữ liệu cũ

- Tên prefab, component, khóa lưu và namespace RPC Solo được giữ để game đọc lại vật phẩm và tiến trình cũ.
- Thế giới mới tạo khi bật bản gộp có địa hình đấu trường Solo trong Forest. Cơ chế worldgen gốc được giữ nguyên.
- Save trước đó đã bật Solo và đã có đấu trường có thể tiếp tục dùng địa hình đó; bản gộp không tái tạo bản đồ.
- Save chưa từng có đấu trường/`dungeon_exit` sẽ không tự xuất hiện hầm ngục khi nâng cấp. Đây là giới hạn của Solo gốc: các tính năng còn lại vẫn được nạp, nhưng muốn đủ hầm ngục cần thế giới mới hoặc một save đã có đấu trường. Không tự sửa địa hình save cũ.
- Bản hiện tại dùng tên thư mục `PhamNhanTuTien`. Nếu game báo thay đổi danh sách mod khi mở save, kiểm tra trên bản sao rằng Phàm Nhân đã bật và Solo riêng đã tắt; không đổi prefab/component/RPC để xử lý thông báo này.

## Kiểm chứng

- 7 kiểm tra tự động đạt, gồm cấu hình trong sandbox Lua, chống bật trùng, hợp nhất đăng ký, checksum 660 file nguồn, đường dẫn tài nguyên và atlas; 423 file Lua biên dịch được bằng Lua 5.1.
- Server DST offline đã tạo thế giới có đấu trường, nạp các prefab đại diện của cả hai hệ, kiểm tra 45 ô túi đồ và component Solo trên nhân vật.
- Save record nhân vật giữ cấp 7 và EXP 23 khi ghi/đọc; vũ khí Solo cường hóa cấp 3 và chồng 7 linh thạch được giữ sau khi khởi động lại server.
- Save mẫu tạo bằng Tu Tiên Ký 0.9.0 + Solo riêng đã được mở lại bằng chỉ Tu Tiên Ký 0.10.0; đấu trường và hai loại vật phẩm nêu trên vẫn còn.
- Ba bộ hồi quy sắp túi đồ, ô trang bị và chỉ báo boss đã đạt. Rà soát mã độc lập không còn phát hiện lỗi tích hợp nghiêm trọng sau khi sửa API liệt kê mod trong worldgen.

Công cụ tái kiểm tra: `tools/test_ttk_solo_integration.py` và `tools/run_ttk_solo_smoke.py`.

Kiểm thử server offline và serialization không thay thế kiểm tra giao diện bằng máy khách, kết nối nhiều người, Master–Caves hoặc toàn bộ kỹ năng/boss trong một phiên chơi thật. Giữ bản sao save cho đến khi đã kiểm tra nhân vật, trang bị, quân đoàn, nhiệm vụ và hầm ngục của mình.

## Nguồn

Solo Leveling 2.2.7 — Saikuno. Danh sách nguồn và checksum lịch sử: `SOLO_SOURCE_MANIFEST.json`; metadata/manifest gốc: `provenance/solo`. Runtime tích hợp đã có các thay đổi riêng của Phàm Nhân; checksum nguồn không đại diện cho checksum runtime hiện tại.
