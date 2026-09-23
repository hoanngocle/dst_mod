# Lịch sử thay đổi

## 2.0.3 — 2026-09-20

- Viết lại thoại EVA khi xem nhân vật, gặp linh hồn và cứu đồng đội theo giọng dịu dàng, bảo hộ.
- Giữ nguyên thoại đồ vật và cơ chế kỹ năng.

## 2.0.2 — 2026-09-20

- Việt hóa mô tả, cấu hình, lời thoại và thông báo nhân vật EVA.
- Chuẩn hóa prefab, component, cấu hình, đường dẫn và bank/build tài nguyên sang tên EVA.
- Chỉ dùng world mới; giữ nguyên bộ kỹ năng và nguồn cấp Achievement & Level.


## 2.0.1 — 2026-09-20

- Tích hợp nhân vật EVA 1.1.9, toàn bộ kỹ năng, Hồn Lực, HUD và assets tím bạc.
- EVA có một ngoại hình mặc định; không có skin riêng; chỉ hỗ trợ tạo world mới.
- Giữ nguồn cấp Achievement & Level; không chuyển cấp EVA sang hh_leveling.
- Chặn bật đồng thời mod EVA riêng; gộp prefab/assets mà không ghi đè danh sách Phàm Nhân.
- Kiểm thử DST offline: chi tiết trong EVA_INTEGRATION_VI.md.

## 2.0 — 2026-09-20

- Đổi tên hiển thị thành **Phàm Nhân Tu Tiên**, viết tắt **Phàm Nhân**, sau khi tích hợp đầy đủ Solo Leveling.
- Giữ thư mục `TuTienKy`, namespace prefab/component/RPC và dữ liệu save hiện có để tương thích.
- Thiết kế 9 boss và chiến lợi phẩm đang được duyệt riêng; mục đổi tên này không có nghĩa các boss đã được triển khai.

## 0.10.0 — 2026-09-20

- Gộp toàn bộ Solo Leveling 2.2.7 vào một gói Tu Tiên Ký: runtime, UI, tài nguyên, cấu hình và worldgen hầm ngục.
- Giữ nguyên tên prefab/component, dữ liệu cường hóa và tiến trình Solo; giữ mặc định của cả hai bộ cấu hình.
- Hợp nhất danh sách prefab/asset, giữ thứ tự khởi tạo Tu Tiên Ký trước Solo và chặn bật trùng bản Solo riêng.
- Tạo thế giới mới có đấu trường Solo. Thế giới cũ thiếu đấu trường không được tự chỉnh địa hình.
- Chi tiết cài đặt, chuyển save và kiểm chứng: `SOLO_INTEGRATION_VI.md`.

## Tế luyện Lục Nguyên Kiếm Đồng — 2026-09-20

- Linh Bảo Tế Luyện Đài nhận `ttk_lucnguyenkiemdong`, dùng chi phí và giới hạn chín cấp hiện có.
- Mỗi cấp tăng 5% sát thương phát bắn và nền kiếm phụ, tối đa 45%; nhân một lần khi phóng, giữ tương thích sát thương Solo. Hiệu ứng nguyên tố cố định giữ nguyên.
- Lưu cấp trên vũ khí; save cũ mặc định cấp 0. Đài hiển thị animation kiếm khi đặt Kiếm Đồng.
- Kiểm thử Lua và máy chủ DST riêng đã kiểm tra nhận đồ, chi phí, lưu/tải và sát thương phát bắn.

## Bổ sung Tinh La Kiếm — 2026-09-19

- Chuyển kiếm `xd_xlj` từ Tu Tiên 19.7 thành `ttk_tinhlakiem`, giữ animation/icon, 100 sát thương, tầm 2, 300/1.000 lượt ban đầu; cạn còn 10 sát thương và không biến mất.
- Thêm công thức Máy Luyện Kim cho mọi nhân vật; bỏ khóa WX-78 và khóa chủ sở hữu.
- Nạp bằng cách tiêu thụ một vũ khí/vật phẩm trong bảng gốc, giữ nguyên số lượt hồi và không xét độ bền món nạp. Kiếm đầy không nhận thêm.
- Không chuyển kỹ năng mìn/sét theo lựa chọn của người dùng.

## Bổ sung Nhất Vũ Phương Hoa — 2026-09-19

- Thêm `nhatvuphuonghoa` từ Tu Tiên 19.7, giữ animation/icon và chức năng che mưa, chống nóng, vùng che mưa, phép làm khô 240 giây.
- Mở công thức cho mọi nhân vật; hiệu ứng dùng component DST chuẩn, không cần nhân vật/hệ tu luyện nguồn.
- Đổi nạp hồn sang Hạ Phẩm Linh Thạch: mỗi viên hồi 5% tổng độ bền; chặn nạp khi đầy, giữ ô khi cạn và khôi phục khả năng trang bị khi nạp lại.

## 0.9.0 — 2026-09-19

- Tích hợp Boss Indicators (`1120124958`, bản 0.3): chỉ báo hướng cho boss lớn ở gần nhưng nằm ngoài màn hình; quét thẻ mạng `epic` mỗi 0,5 giây thay cho danh sách đăng ký prefab cũ.
- Mở rộng cho boss hiện tại của DST và boss Solo tùy chọn (Super Frostjaw, Lợn Rừng Bọ Hung, Siêu Lợn Song Kiếm, Igris, Beru, Minotau) mà không import mã Solo.
- Thêm icon dự phòng và tên dễ đọc cho boss mod; lọc boss nhỏ, pet/hồn triệu hồi, thực thể chết/ẩn/limbo và dọn chỉ báo khi boss hoặc HUD biến mất.
- Chỉ chạy HUD ở máy khách, không cài hook trên dedicated server. Đã kiểm thử logic và hợp đồng widget bằng Lua 5.1; chưa kiểm tra hình ảnh trực tiếp trong game.

## 0.8.4 — 2026-09-19

- Sửa lỗi nạp `modinfo.lua` do dùng `ipairs` ngoài môi trường cho phép của game.
- Sửa vị trí khởi tạo mạng của bốn bếp và hệ số ánh sáng ở một mức nhiên liệu Thần Hỏa.
- Sửa xung đột hiển thị áo giáp/ba lô/dây chuyền và chỉ báo giảm nguyên liệu của bùa xanh; bỏ hook hồi sinh lỗi thời.
- Rà toàn bộ đăng ký/tài nguyên, chạy máy chủ ngoại tuyến thật và kiểm tra tạo thực thể/skin/công thức của bản 0.8.4.

## 0.8.3 — 2026-09-19

- Nhập 14 skin cho 11 công trình hiện có, kèm linh thú trang trí LLT và dọn hiệu ứng khi đổi skin/tháo kệ.
- Phiên có carrier sát thương Solo tùy chọn; truyền sát thương sang đạn/lan và giữ cường hóa qua đặt/thu/save. Không import Solo.
- Gỡ toàn bộ chuỗi Sa Đường và hiệu ứng đi nước; đồng bộ trang `/tu-tien-ky`.

## 0.8.2 — 2026-09-19

- Gộp Increased Stack size (`374550642`): cố định 120 món/stack cho mọi item có component `stackable`, gồm item mod có giới hạn riêng. Không thêm cấu hình.
- Cập nhật cả năm nhóm stack chuẩn; không biến vật phẩm không stack được thành stackable. Giữ stack vô hạn của kho nâng cấp và giới hạn 120 khi lấy đồ ra.

## 0.8.1 — 2026-09-19

- Sửa lại theo yêu cầu: DJPaul chỉ sort khi nhấn G; bỏ toàn bộ hook/timer tự sort khi thay đổi đồ, mở kho hoặc tải save.
- Đang mở rương/Đa Bảo Các thì G chỉ sort kho đang mở; không mở rương thì G sort inventory và ba lô.
- Giữ các sửa lỗi stack vô hạn, ô khóa, replica và trưng bày. Đã kiểm tra hồi quy chế độ thủ công; chưa thử trực tiếp trong game.

## 0.8.0 — 2026-09-19

- Tích hợp túi đồ 45 ô từ `3075429483` (1.1.5.2b); Việt hóa các tùy chọn.
- Ô ba lô và dây chuyền luôn bật theo yêu cầu, không có tùy chọn tắt; không ghi đè bảng ô trang bị khác.
- Giữ mã túi đồ hiện tại của game; đồng bộ số ô bằng `GetMaxItemSlots`, bổ sung đọc ba lô riêng cho máy chủ và dự đoán chế tạo phía máy khách.
- Bố cục hai hàng và vùng trang bị riêng; ba lô lớn xuống hàng. Nạp trước Lục Mạch Thần Kiếm để pháp bảo nhận đúng ô dây chuyền.
- Kiểm thử Lua 5.1 với mã game cục bộ cho 15/25/45 ô, ba lô và bố cục; chưa thử trực tiếp trong game.

## 0.7.1 — 2026-09-19

- Gộp bản sửa DJPaul's Sort Inventory (`1462979419`): bản gốc chỉ chạy bằng G và không xử lý chest; bản mới tự sắp xếp khi thay đổi đồ/mở kho, hỗ trợ inventory, ba lô, rương và Đa Bảo Các.
- Giữ nhóm ưu tiên của nguồn; sửa kiểm tra tag ánh sáng, tên vật phẩm nil và vũ khí có sát thương phụ thuộc mục tiêu.
- Sắp riêng từng kho bằng hoán vị ô và sự kiện replica, không tháo/nhét lại đồ hoặc chuyển qua chủ sở hữu khác; giữ stack vô hạn và cập nhật trưng bày Đa Bảo Các. Gộp stack bằng API Klei.
- Chờ thao tác con trỏ, giữ ô khóa/trang bị, bỏ qua kho chỉ đọc/ô chức năng; RPC chỉ tác động túi của người gửi và kho họ đang mở. Chống hook trùng với bản DJPaul đã sửa.
- Kiểm tra hồi quy Lua cho dữ liệu/kho/sự kiện và client/server; chưa chạy thử trong game.

## 0.7.0 — 2026-09-19

- Gộp Vĩnh Hằng Thần Hỏa: bốn loại bếp, bốn hiệu ứng lửa, tài nguyên và cấu hình nguồn.
- Bảo vệ bếp khỏi máy phóng băng và đạn tuyết lan; giữ tiêu hao nhiên liệu và hành vi tắt thông thường.
- Việt hóa tên, mô tả, cấu hình và lời thoại; tách biến/cấu hình bằng tiền tố `ttk_vhth_`.
- Giữ mã định danh bếp cho thế giới đã dùng bản độc lập; không cần bật thêm mod gốc hoặc bản độc lập.
- Kiểm tra bằng Lua 5.1 và mã game cục bộ; chưa thử trực tiếp trong thế giới.

## 0.6.4 — 2026-09-19

- Gộp Smarter Ice Flingomatic (`1845106626`, bản 1.3.0), luôn bật: ngưỡng khẩn cấp 1, thời gian cảnh báo 1 giây, cửa sổ phản ứng 3 giây và duy trì bật khẩn cấp 30 giây.
- Giữ cơ chế bỏ qua bếp/lửa chủ động của nguồn; hỗ trợ cả prefab Deluxe trong Vĩnh Hằng Thần Hỏa và Obsidian Fire Pit mà không phụ thuộc ID Workshop.
- Giữ nhiên liệu mặc định ×1, không cần bật mod nguồn riêng.

## 0.6.3 — 2026-09-19

- Gộp Open gifts everywhere (3036001095): mở quà mà không cần đứng cạnh Máy Khoa Học.
- Gộp No Grass Gekko (1686705509): cỏ không biến thành Grass Gekko khi hái; không xóa Grass Gekko đã tồn tại.
- Cả hai tính năng luôn bật cùng Tu Tiên Ký, không có công tắc cấu hình và không cần cài hai mod riêng.

## 0.6.2 — 2026-09-19

- Rà soát nội dung đã gộp vào Tu Tiên Ký 0.6.2, đối chiếu sản vật, thực thể, phụ thuộc và phần loại trừ có chủ ý. Không rà/sửa nhân vật cũ Mori theo yêu cầu.
- Sửa tải save khi hiệu lực Sa Đường còn và người chơi đứng trên nước: chặn riêng bước sửa vị trí của `player_common`, khôi phục cờ drownable ngay sau bước tải.
- Sửa đập ba chuồng ban đêm: bỏ điều kiện ngày khi thả đàn. Nếu không có chỗ ra, giữ chuồng với số thú còn bên trong để tránh mất thú; không phát loot tháo dỡ trước khi thả xong.
- Khai báo trực tiếp lông/sừng/sữa/vòi trong dependencies của chuồng.
- Cổng tính lại điểm đến khi hết đếm ngược; chọn điểm đi được, tránh hố/vật chắn và dùng điểm đó cho người, thú đi theo, đồ nặng. Kiểm tra lại quyền Camp Security ở điểm đến, không truy cập inventory nil.
- Chỉ kiểm tra mã/cú pháp/tài nguyên/API game cục bộ; không chạy game/test suite, không tạo ZIP.

## 0.6.1 — 2026-09-19

- Bổ sung chuỗi Sa Đường còn thiếu: cây thường → nhánh quả → Quả Sa Đường → thức ăn thối khi hỏng.
- Chuyển cơ chế sinh tối đa hai nhánh của đại thụ nguồn sang cây thường; mỗi nhánh hái một quả, chặt cây thu nốt quả trên nhánh.
- Quả giữ chỉ số ăn 3 máu/47,5 no/7 tinh thần, tác dụng đi trên nước 480 giây và khoảng cách ăn 960 giây. Tách hiệu ứng khỏi hệ tu luyện; đồng bộ quyền di chuyển cho client và lưu timer.
- Đối chiếu ngọc/bướm/cây trồng của các vật phẩm vườn còn lại; không phát hiện sản vật custom khác bị thiếu trong nhóm được chọn.
- Không tạo ZIP; kiểm tra cú pháp/tài nguyên, chưa chạy game hoặc test suite.

## 0.6.0 — 2026-09-19

- Thêm Chuồng Bò Lai, Chuồng Dê Điện, Chuồng Voi Koala cùng ba thú nuôi, brain và stategraph độc lập; giữ sản xuất và thu hoạch của nguồn.
- Thêm Công Cụ Hạp và Đa Bảo Các 36 ô, tự nhặt công cụ/trưng bày tám ô đầu và nâng cấp sức chứa. Hạp bỏ qua vật có chủ để không phụ thuộc helper quyền sở hữu của Tu Tiên gốc.
- Thêm Đan Phong, giữ công thức và cơ chế kết ngọc đỏ/điều hòa nhiệt.
- Chuyển Đăng Thải thành Cửu U Xích Linh Đăng (`ttk_dc`), tăng bán kính sáng từ 2,5 lên 3,5; giữ nhiên liệu linh thạch và chỉ sáng ban đêm. Đồng bộ trạng thái nhiên liệu sau thay đổi ô và tải save.
- Đan Lô hoãn theo yêu cầu người dùng, chưa nhập hệ luyện đan.
- Kiểm tra cú pháp 57 file Lua, 11 animation và 14 bộ icon atlas/texture; không chạy game/test suite, không tạo ZIP.

## 0.5.0 — 2026-09-19

- Chuyển Anh Đào Thụ, Bách Hợp, Bạch Mân Côi, Bồ Công Anh, Cam Tỉnh và Chậu Hoa Uẩn Linh sang namespace `ttk_`, giữ công thức nguồn với linh thạch Tu Tiên Ký.
- Giữ cây anh đào sinh ngọc/điều hòa nhiệt, hoa hồi tinh thần/sinh bướm và giếng nạp nước; chỉ sinh bướm ở bình minh ngoài mùa đông.
- Chậu hỗ trợ gieo hạt, 2 lượt linh lực, nạp lại bằng Hạ Phẩm Linh Thạch, giảm stress cuối vụ, lưu liên kết cây và chuyển mầm vô danh. Bỏ yêu cầu ở cạnh nhà Tu Tiên.
- Chọn Sa Đường dạng thường; thêm hạt chế tạo/trồng trực tiếp và trả hạt khi chặt. Không nhập đại thụ/hệ nhà.
- Giữ tất cả module hiện có, cập nhật trực tiếp thư mục; không tạo ZIP hoặc tự chạy game.

## 0.4.0 — 2026-09-19

- Thêm **Thần Hi Quang Trượng**, chuyển thể Phức Úc Thủ Trượng; prefab `thanhiquangtruong`, mọi nhân vật dùng được.
- Giữ tăng tốc 30%, 30 lượt, dịch chuyển gần tốn 1 lượt/bản đồ tốn 3 lượt trong tầm 128, hồi chung 30 giây; Đá Sa Mạc nạp 15 lượt.
- Công thức 3 Đá Sa Mạc + 1 Ngọc Vàng + 1 Trung Phẩm Linh Thạch tại Shadow Manipulator; mục Ma thuật/Công cụ.
- Giữ tài nguyên trượng/hạt sáng; thay state Tam Tiêu bằng BLINK chuẩn có kiểm tra đích và điều kiện phía server. Không nhập Tu Tiên gốc/Solo.
- Giữ module Truyền Tống Trận từ 0.3.1. Cập nhật trực tiếp thư mục, không đóng ZIP; chưa chạy game.

## 0.3.1

- Gộp Truyền Tống Trận: cổng, animation, icon, nhãn tên và giao diện chọn điểm đến.
- Truyền Tống Trận luôn hoạt động; giữ năm tùy chọn dịch chuyển, bỏ công tắc bật/tắt riêng.
- Công thức cổng: 5 Ván Gỗ + 5 Vàng, Máy Khoa Học.
- Giữ module bàn, skin, linh thạch và Lục Mạch Thần Kiếm.
- Không đóng ZIP; chưa chạy thử trong game.





## 0.3.0 — 2026-09-19

- Thêm **Cửu Thiên Tinh Thần Phiên**, chuyển thể pháp bảo đặt đất của Vương Ma Tử; prefab `vanhonphien`.
- Chuyển cả Hồn Vệ, brain, stategraph, đạn, thu hồn và hiệu ứng xoáy; mọi nhân vật dùng được, không cần Tu Tiên gốc hoặc Solo.
- Giữ cơ chế gọi 2 hồn ban đầu và dùng 2 hồn thu được để gọi thêm, 4 lượt bổ sung hồi riêng, Hồn Vệ tồn tại 60 giây.
- Dùng nền sát thương 20 độc lập; bỏ phụ thuộc hệ số tu luyện của nguồn.
- Bổ sung bảo toàn hồn tích lũy/hồi chiêu qua thu–đặt và save/load; kiểm tra đồng đội cả lúc chọn mục tiêu lẫn lúc đạn trúng.
- Công thức riêng: 6 Gỗ Sống, 12 Nhiên Liệu Ác Mộng, 2 Ngọc Tím, 6 Trung Phẩm Linh Thạch; Shadow Manipulator, mục Ma thuật/Vũ khí.
- Bản này chưa bổ sung cường hóa Solo hoặc nâng cấp ngọc cho Phiên. Kiểm tra tĩnh/cú pháp/gói ZIP; chưa chạy game.

## 0.2.0 — 2026-09-19

- Tích hợp **Lục Mạch Thần Kiếm** từ bản Terraprisma v2.0 đã chỉnh sửa.
- Đổi prefab/component/module, tuning/config, RPC/action và net field sang `lucmachthankiem`; không đăng ký prefab cũ.
- Đổi tên tài nguyên hình ảnh và toàn bộ bank/build/symbol animation tương ứng; giữ nguyên hình học, frame và texture.
- Mặc định vô hạn độ bền, đeo dây chuyền (fallback ô thân nếu không có NECK).
- Giữ cầu vồng và nâng cấp một lần ×2 sát thương gốc/planar khi dùng Ngọc Lấp Lánh.
- Giữ tương thích bonus sát thương cường hóa Solo và chế độ không có Solo.
- Thêm cấu hình kiếm trong Tu Tiên Ký; giữ công thức nguồn 1 Glass Cutter + 6 Ngọc Đỏ.
- Giữ nguyên bàn, hai skin bàn, linh thạch và quy tắc rơi đồ của 0.1.1.

## 0.1.1 — 2026-09-19

- Thêm hai skin Hoàng Hoa Lê Mộc Trác: **Mẫu HTJC** và **Mẫu WFZ**.
- Thêm lựa chọn mẫu ngay trong bộ chọn skin chuẩn của bảng chi tiết chế tạo DST, gồm cả mẫu mặc định.
- Áp dụng skin cho hình đặt công trình, đồng bộ công trình và save/load bằng luồng skin chuẩn của game.
- Chỉ mở quyền sở hữu cho hai skin `ttk_hhlmz_skins_htjc` và `ttk_hhlmz_skins_wfz`; không thay đổi quyền sở hữu skin chính thức hoặc skin của mod khác.

## 0.1.0 — 2026-09-19

- Thêm Hoàng Hoa Lê Mộc Trác 8 ô chỉ nhận `preparedfood`, hiển thị món ăn và hồi độ tươi với hệ số `-0.2`.
- Thêm bốn cấp linh thạch riêng `ttk_lingshi1` đến `ttk_lingshi4`.
- Thêm đổi phẩm 100 Hạ → 1 Trung, 10 Trung → 1 Thượng, 10 Thượng → 1 Cực.
- Thêm 100% rơi 2–5 Hạ Phẩm cho quái thường và 2–5 Thượng Phẩm cho boss, với loại trừ player, pet, follower và phase chuyển tiếp đã biết.
- Thêm nâng cấp chồng không giới hạn, save/load và xử lý collapsed chest cho bàn.
- Đóng gói toàn bộ prefab, atlas, texture và animation dưới namespace/path `ttk_` mà không phụ thuộc runtime Tu Tiên hoặc Solo Leveling.

## Bổ sung skin Truyền Tống Trận — 2026-09-20

- Thêm skin Cổ Trận từ xd_gcsz, chọn trong chế tạo và đổi bằng Chổi Sạch.
- Giữ công thức 5 Ván Gỗ + 5 Vàng, tên điểm đến và dịch chuyển hiện có.
- Thêm xử lý skin cho placer, save/load, đổi về mặc định, proximity và trạng thái cháy; chưa chạy thử trong game.
