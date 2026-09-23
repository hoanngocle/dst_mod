# Batch 19 — nhóm sào huyệt và Thiên Cơ Ốc

Nguồn đối chiếu: mod Steam `3235319974`. Mã Lua được trích tĩnh bằng bảng byte của dự án; không chạy loader đã mã hóa.

## Năm công trình trong `ttk_batch19_houses.lua`

- **Sào Huyệt Gấu Lưng Thiết Giáp (`ttk_zzxhcx`)** sinh một `ttk_bearger` vào ban ngày, hồi sinh sau 5 ngày. Khi thú vẫn còn đủ đàn, công trình đếm ngày và cất 2 Quang Hoa Thuần Túy sau mỗi 10 ngày; dùng hành động Thu hoạch để lấy đồ. Chủ sở hữu và bộ đếm ngày được lưu/tải.
- **Sào Huyệt Long Đằng (`ttk_lycx`)** sinh một `ttk_dragonfly` vào ban ngày, hồi sinh sau 5 ngày. Mỗi 10 ngày đủ đàn, kho nhận 1 vảy rồng, 1 đá vàng, 1 đá lục, 1 đá cam, 2 đá đỏ, 2 đá lam và 2 đá tím. Chủ sở hữu và bộ đếm ngày được lưu/tải.
- **Sào Huyệt Ma Thù (`ttk_spiderden`)** có 1.000 máu, giữ tối đa 6 `ttk_spider`, hồi một con mỗi 100 giây và gọi quân phòng thủ khi bị đánh. Khi phá hủy rơi 3 đá và 6 tơ.
- **Thanh Khâu Phường (`ttk_pog_house`)** sinh một `ttk_pog` vào ban đêm, hồi sinh sau 2 ngày. Cho Linh Hồ 10 Thịt lớn sống hoặc 5 món nấu thuộc nhóm thịt để thuê 2.400 giây (5 ngày game); trong thời gian đó Linh Hồ tự hái cây và không rơi chiến lợi phẩm thù địch. Hai loại thức ăn được đếm riêng, tiến độ cho ăn được lưu/tải. Trả đủ lần nữa làm mới thời gian thuê về 2.400 giây. Linh Hồ hoang rơi 1 thịt và có 25% rơi Đuôi Linh Hồ.
- **Thừa Vận Tọa (`ttk_stool`)** dùng thành phần ngồi bản địa. Mỗi 10 giây hồi 5 máu, 2 tinh thần và 2 no cho người đang ngồi.

Ba nguyên liệu gốc Đuôi Linh Hồ (`xd_pog_tail`), Tà Sát Bộ Túc (`xd_spider_leg`) và Niết Bàn Huyết Tủy Trúc (`xd_npxsz`) vốn chỉ đến từ chuỗi boss/công trình bị loại khỏi đợt port này. Bản port thêm công thức tinh chế riêng cho các bản `ttk_`, tránh công thức vòng tròn hoặc vật phẩm không thể kiếm.

Các thú giữ nguyên bộ não và stategraph nguồn đã đổi namespace. Mục tiêu chiến đấu được lọc theo chủ sở hữu, trạng thái đồng hành và thiết lập PvP; các nhánh phụ thuộc Kunpeng/Sudaji đã được bỏ vì nằm ngoài phạm vi. Hiệu ứng vòng lửa thiếu prefab riêng trong nguồn con được ánh xạ sang `firering_fx` bản địa.

## Thiên Cơ Ốc

Thiên Cơ Ốc tiếp tục dùng hệ thống đã đăng ký tại `main/ttk_tianji.lua`: phòng riêng 30×30 ngoài bản đồ, cửa vào/ra, vị trí trở về, người theo cùng chủ, khóa chủ và shard, lưu/tải phòng, miễn mưa, ánh sáng, nhiệt độ, chống sét, chống hố Kiến Sư Tử và camera riêng. Quyển trục dùng đúng công thức nguồn: 7 giấy cói, 15 cẩm thạch, 6 gỗ sống và 45 Hạ Phẩm Linh Thạch tại Máy Thao Túng Bóng Tối. Lệnh Bài có công thức bổ sung 1 giấy cói + 1 Hạ Phẩm Linh Thạch để người chơi không bị kẹt nếu làm mất vật phẩm thu hồi.

`ttk_batch19_houses.lua` chỉ bổ sung skin **Bạch Ngọc Kinh** (`ttk_tianjiwu_skins_byj`) vào hệ thống này. Skin đổi đồng bộ nền, vách, cửa và phù điêu trong phòng; mỗi 110–120 giây tạo một Bạch Hổ hiện hình trong 8 giây. Skin được giữ qua thao tác thu hồi/triển khai bằng reskin API của game, và hiệu ứng chỉ gắn với đúng căn nhà.

Kiểm tra tương thích Solo: bộ cấp phát phòng hiện có quét toàn bộ lưới 32×32 theo bước 4 trước khi giữ chỗ; các ô tổng hợp của Solo trả về `IsAboveGroundAtPoint`/`IsPassableAtPoint`, nên vị trí chồng lấn bị loại. Wrapper bản đồ và camera của Thiên Cơ Ốc chỉ trả kết quả riêng trong phòng đã đăng ký và chuyển tiếp hàm gốc ở mọi vị trí khác.

## Kiểm tra tĩnh

- 19 tệp Lua đã đăng ký thuộc phạm vi biên dịch thành công bằng `lupa` (chỉ `load`, không chạy prefab).
- Các ZIP hoạt ảnh thuộc phạm vi qua kiểm tra CRC.
- Không còn tham chiếu đến `xd_ziyun_house`, `xd_jwtcd`, `xd_lyd`, `xd_rock1..3`, chuỗi Sa Dương, `ttk_sudaji_controller`, `ttk_kunpeng*` hoặc global `XD_GetGroundPoints`.
- Theo yêu cầu, không khởi chạy game và không tạo bộ test runtime mới.

Nguồn: [Steam Workshop 3235319974](https://steamcommunity.com/sharedfiles/filedetails/?id=3235319974).
