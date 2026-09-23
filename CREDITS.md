# Credits

## Solo Leveling tích hợp (0.10.0)

- Nguồn: **Solo Leveling 2.2.7**, tác giả **Saikuno**, Workshop `3780347550`, bản sao trong repository.
- Toàn bộ 660 file nguồn được giữ nguyên nội dung; entrypoint và metadata/manifest gốc được chuyển vị trí để dùng chung gói Phàm Nhân Tu Tiên. Ánh xạ và SHA-256 nằm trong `SOLO_SOURCE_MANIFEST.json`.
- Phần mới của Phàm Nhân Tu Tiên: bootstrap hợp nhất, bảo vệ chống bật hai bản Solo, cấu hình chung và kiểm chứng chuyển gói.
- HUD chiến đấu tích hợp tái sử dụng widget/proxy, định nghĩa boss/phase và atlas từ **Epic Healthbar v102** của Tykvesh. Thanh máu trên đầu chuyển thể renderer **Standard** và texture trắng gốc từ **Simple Health Bar DST 2.16** của DYC, Workshop `1207269058`: kích thước, lề, màu `dynamic2`, vị trí `overhead2`, hoạt ảnh và vệt mất máu được giữ; phần nối chỉ đọc proxy đã đồng bộ của Phàm Nhân và ẩn thanh khi Epic HUD cục bộ đang hiển thị cùng mục tiêu. Runtime được cô lập dưới namespace `ttk_hud_` / `TTK_HUD`; không nhập hook chat, lệnh debug, updater, cấu hình, popup sát thương hoặc global của hai bản nguồn. Thư mục `mods/SoloCombatHUD` được giữ làm bằng chứng/provenance nhưng không cần bật khi dùng Phàm Nhân.
- Các ghi chú “không import Solo” bên dưới mô tả từng đợt chuyển thể trước 0.10.0; từ 0.10.0 Solo là một phần của gói.

## Bộ giáp Tử Xá và Vân Mạc Thượng Trang

- Nguồn Tu Tiên Workshop `3235319974`: `xd_zcmj`, `xd_xshj`, `xd_yunxiao_ymsz`, hiệu ứng `xd_zcmj_forcefield`, hoạt ảnh và icon tương ứng. Tác giả nguồn: 薪人小黄、路障僵尸、吃不吃大肉丸子.
- Tu Tiên Ký chuyển namespace sang `ttk_`, mở công thức không bản vẽ, thay nguyên liệu còn thiếu bằng nguyên liệu DST theo yêu cầu; giữ cơ chế bộ giáp và tự sửa. Áo sử dụng `minerhatlight` của Klei. Chi tiết tại `ARMOR_SET_VI.md`.

## Boss Indicators (0.9.0)

- Nguồn Workshop `1120124958`, bản **0.3**, tác giả **Ryuu**.
- Sao chép nguyên byte texture atlas icon boss vào `images/ttk_bossindicators.tex`; XML chỉ đổi tên texture theo namespace Phàm Nhân Tu Tiên. Icon gốc được dùng cho Deerclops, Bearger, Dragonfly, Moose/Goose, Ancient Guardian/Minotau, Toadstool, Antlion và Klaus.
- Phần điều khiển của Phàm Nhân Tu Tiên được viết lại theo HUD hiện tại của DST (`widgets/targetindicator` và `PlayerHud.under_root`), quét lân cận có giới hạn và hỗ trợ icon/tên dự phòng. Không dùng component/widget cũ của nguồn và không import mã Solo.

## Increased Stack size (0.8.2)

- Nguồn Workshop `374550642`, bản **2.3**, tác giả **ChaosMind42**.
- Tích hợp tại `main/ttk_stacksize.lua`: cố định năm nhóm tuning và giới hạn component stackable ở 120; bỏ cấu hình và nhánh ánh xạ kích thước của nguồn. Dùng property setter của game để đồng bộ replica và giữ stack vô hạn.

## Túi đồ 45 ô (0.8.0)

- Nguồn: **45 Inventory Slots [Fixed + EquipSlot UI expand]**, Workshop `3075429483`, bản **1.1.5.2b**, tác giả **Antaeogo, dayoumingqi, xuopleu**.
- Bản nguồn kế thừa `2801880191` và `2906717350`. Sao chép sáu tài nguyên TEX/XML vào `images/ttk_inventory45`; bố cục hai hàng và vùng dành cho trang bị chuyển thể trong `ttk_inventory45_layout.lua`.
- Viết phần nối với API game hiện tại, giữ bộ xử lý inventory/replica/UI gốc, không sao chép bộ khởi tạo inventory cũ của nguồn. Ô ba lô và dây chuyền luôn bật theo yêu cầu; tên cấu hình dùng tiền tố `ttk_inv45_`.

## DJPaul's Sort Inventory — bản sửa (0.7.1)

- Nguồn Workshop `1462979419`, bản **1.9d**, tác giả **Paul Gibbs (DJPaul)**, giấy phép **CC BY-NC-SA 4.0**; giữ thông báo tại `licenses/DJPaul-Sort-Inventory-license.txt`.
- Module chuyển thể `scripts/ttk_inventorysort.lua` giữ danh sách nguyên liệu và thứ tự nhóm của nguồn. Phần chuyển thể này tiếp tục theo CC BY-NC-SA 4.0.
- Viết lại cách bố trí ô để hỗ trợ phím G theo kho đang mở, container custom, stack vô hạn, replica và trưng bày; không dùng thuật toán rút toàn bộ đồ rồi chọn kho đích của nguồn. Sắp riêng từng kho; sát thương dạng hàm được xếp theo tên thay vì gọi hàm khi thiếu mục tiêu.

## Vĩnh Hằng Thần Hỏa (0.7.0)

- Nguồn: Deluxe Campfires 3.0.12, Workshop `2422129165`, tác giả **EldVarg, KreygasmTR và Fuzzy Logic**; chuyển từ bản sửa độc lập Vĩnh Hằng Thần Hỏa.
- Giữ tài nguyên và mã định danh của bốn bếp cùng bốn hiệu ứng lửa. Thêm thẻ chống máy phóng băng, tách cấu hình bằng tiền tố `ttk_vhth_`, Việt hóa phần hiển thị và nạp qua `main/ttk_vinhhangthanhoa.lua`.
- Giữ công thức và hành vi nguồn; sửa mã nguyên liệu `stone` thành `rocks` trong lựa chọn công thức rất rẻ của Bếp Thần Hỏa để dùng đúng Đá của game.

## Smarter Ice Flingomatic (0.6.4)

- Nguồn Workshop `1845106626`, bản **1.3.0**, tác giả **辣椒小皇纸**. Giấy phép nguồn: `licenses/Smarter-Ice-Flingomatic-LICENSE.txt`.
- Giữ các giá trị emergency tuning và cách thêm tag `burnt` để bộ dò lửa bỏ qua bếp/lửa chủ động. Giữ nhiên liệu mặc định ×1.
- Tích hợp tại `main/ttk_smarter_flingomatic.lua`, luôn nạp. Đăng ký trực tiếp tên prefab tương thích Deluxe/Tropical để hỗ trợ cả bản mod đổi tên/thư mục cục bộ, gồm Vĩnh Hằng Thần Hỏa; không yêu cầu ID Workshop gốc.

## Tiện ích luôn bật (0.6.3)

- **Open gifts everywhere**, Workshop `3036001095`, tác giả **hamurlik**, bản 1.00: giữ cách dùng người chơi làm `giftmachine` và ngăn builder thay đổi máy nhận quà.
- **No Grass Gekko**, Workshop `1686705509`, tác giả **Jupiter**, bản 1.1: giữ thiết lập `GRASSGEKKO_MORPH_CHANCE = 0`. Giấy phép nguồn lưu tại `licenses/No-Grass-Gekko-LICENSE.txt`.
- Mã tích hợp nằm trong `main/ttk_qualityoflife.lua`, luôn được nạp từ `modmain.lua`; không sao chép icon hoặc metadata mod độc lập.

## Công trình và cây cảnh (0.5.0)

- Nguồn Tu Tiên 19.7 (`3235319974`): các nhánh `xd_tree_yhs` trong `xd_trees.lua`, `xd_flower_bh/bmg/pgy` trong `xd_flowers.lua`, `xd_gj` trong `xd_lights.lua`, `xd_huapen` cùng hook trồng/chất lượng cây, và `xd_shatangshu_normal`/`xd_shatangshunut` trong `xd_shatangshu.lua`.
- Sáu anim ZIP (`xd_trees`, `xd_flowers`, `xd_gj`, `xd_huapen`, `xd_shatangshu`, `xd_shatangshunut`) và TEX inventory/minimap được sao chép nguyên byte. File/XML đổi sang `ttk_`; tên bank/build nhị phân giữ nguồn. Không đăng ký các prefab cây/hoa khác trong các bộ anim dùng chung.
- Công cụ sao chép: `tools/port_ttk_garden_assets.py`. Việc đọc mã nguồn dùng giải mã byte tĩnh, không chạy loader Tu Tiên.
- Gameplay viết lại bằng component chuẩn: `periodicspawner`, `temperatureoverrider`, `watersource`, `sanityaura`, `playerprox`, `deployable`, `entitytracker`, `finiteuses`. Hook gieo hạt/stress/nạp linh lực và chống xâm nhập giới hạn vào chậu/cây liên kết của Tu Tiên Ký.
- Thay đổi có chủ đích: chậu tồn tại cùng cây thay vì thay bằng FX rồi tạo lại; xử lý cây vô danh chuyển giống; bỏ khóa vị trí nhà Tu Tiên; Sa Đường có hạt cầm/trồng trực tiếp, recipe riêng và loot tái trồng, không kéo hệ nhà đại thụ; hoa chỉ sinh bướm lúc bình minh.

## Thần Hi Quang Trượng (0.4.0)

- Nguồn: Phức Úc Thủ Trượng của Tam Tiêu, prefab `xd_yunxiao_fysz`, Tu Tiên 19.7 (`3235319974`), tác giả ghi ở mục tài nguyên gốc.
- Sao chép nguyên byte anim ZIP, inventory TEX và particle TEX; đổi tên file/XML sang `thanhiquangtruong`. Bank/build nhị phân giữ `xd_yunxiao_fysz` để bảo toàn tài nguyên; không đăng ký prefab gameplay gốc.
- Trích riêng đoạn particle FX bằng giải mã byte tĩnh, không chạy loader. Chỉ khởi tạo 3 emitter thực sự được cấu hình thay vì 6 emitter của nguồn. Công cụ: `tools/port_thanhiquangtruong_assets.py`.
- Viết lại prefab/action độc lập, giữ tốc độ, lượt, hồi chiêu và nạp Đá Sa Mạc. Dùng component BLINK/stategraph chuẩn của Klei thay cho state dịch chuyển Tam Tiêu; map action riêng giới hạn đích hợp lệ/đã khám phá và tầm 128.
- Công thức giữ lượng nguyên liệu nguồn, thay linh thạch bằng bản Tu Tiên Ký, bỏ khóa Tam Tiêu và yêu cầu Shadow Manipulator. Không nhập mã tu luyện hay component của Solo.

## Cửu Thiên Tinh Thần Phiên (0.3.0)

- Nguồn gameplay và hình ảnh: Tôn Hồn Phiên — Cô Phẩm (`xd_wmz_zhf`) của Tu Tiên 19.7, Workshop `3235319974`, tác giả ghi ở mục tài nguyên gốc bên dưới.
- Chuyển thể prefab, brain và stategraph bằng giải mã thay thế byte tĩnh; không chạy loader hoặc mã nguồn mod để trích xuất. Công cụ tái tạo: `tools/port_vanhonphien.py` trong workspace.
- Tài nguyên sao chép nguyên byte: `xd_wmz_zhf.zip`, `xd_wmz_zhf_soul.zip`, `xd_vortex_fx.zip`, `cloak_fx.zip` và texture inventory. Tên file được đổi sang `vanhonphien*`; các bank/build nhị phân vẫn dùng tên tài nguyên nguồn, gồm `xd_wmz_zhf`, `xd_wmz_zhf_soul`, `xd_vortex_fx`, `cloakfx`. Không đăng ký prefab gameplay `xd_*`.
- Phần chuyển thể thêm: bỏ khóa Vương Ma Tử; xử lý chủ/mục tiêu độc lập, giữ hồn/hồi chiêu qua thu–đặt và save/load, chặn bắn đồng đội, đặt công thức mới với linh thạch Tu Tiên Ký, tên và mô tả tiếng Việt.
- Không nhập hệ tu luyện hoặc hàm toàn cục của Tu Tiên; nền sát thương hồn 20 thay cho hàm tính sát thương phụ thuộc chủ/tu luyện của nguồn. Không phụ thuộc Solo và chưa triển khai cường hóa Solo cho pháp bảo này.

## Tài nguyên gốc

- Mod nguồn: **Tu Tiên 【登仙】**, Steam Workshop ID `3235319974`, phiên bản nguồn 19.7.
- Tác giả được ghi trong `modinfo.lua` của nguồn: **薪人小黄、路障僵尸、吃不吃大肉丸子**.
- Tài nguyên được chuyển tên cho mod này: animation `xd_hhlmz`, `xd_lingshi`, `xd_hhlmz_skins_htjc`, `xd_hhlmz_skins_wfz`; icon inventory của bàn, hai skin bàn và bốn cấp linh thạch; icon minimap của bàn.

Các file TEX và anim ZIP được sao chép nguyên byte từ bản copy nguồn. Chỉ tên file đóng gói và tham chiếu XML được đổi sang tiền tố `ttk_`; bank/build nhị phân vẫn mang tên `xd_hhlmz`, `xd_lingshi`, `xd_hhlmz_skins_htjc` và `xd_hhlmz_skins_wfz` theo tài nguyên gốc.

Mod **Skin Đăng Tiên**, Steam Workshop ID `3773896514`, được dùng để xác định bối cảnh mở khóa skin. Bản copy này không chứa tài nguyên hình ảnh riêng; Tu Tiên Ký không chép loader hoặc mã mở khóa của mod đó. Hai bộ animation và icon skin được lấy trực tiếp từ bản copy Tu Tiên gốc `3235319974`.

## Chuyển thể độc lập

Mã Lua của phần bàn/linh thạch Tu Tiên Ký được viết lại thành mod độc lập. Mod không tải loader mã hóa, helper toàn cục, component tu luyện hay mã gameplay khác của Tu Tiên.

Logic nâng cấp và collapsed chest dựa trên API/component chuẩn cùng cách xử lý của prefab `treasurechest` và `collapsedchest` trong Don't Starve Together của Klei. Phần nhận diện tương thích Solo Leveling dựa trên tag/field công khai quan sát được trong bản copy Solo Leveling v2.2.7, không nhập mã hoặc module của Solo.

## Lục Mạch Thần Kiếm (0.2.0)

- Nguồn: **Terraprisma 1.2.5**, tác giả **WIGFRID**, Workshop ID `2675609101`, qua bản chỉnh sửa cục bộ Terraprisma v2.0.
- Giữ logic điều khiển phi kiếm, animation/texture, shader và âm thanh nguồn. Các biểu thức chuỗi hằng trong prefab đã được giải tĩnh để đổi tên; không nạp loader hoặc chạy mã nguồn bằng công cụ chuyển đổi.
- Mã gameplay, component, prefab, RPC/action và config đã đổi sang `lucmachthankiem`. Giữ các tên tài nguyên âm thanh bên trong FMOD `terraprisma_sfx` và sự kiện âm thanh vanilla `terraria1/skins/terraprisma_summon`, vì đó là tên trong ngân hàng âm thanh/game, không phải ID gameplay. Không thay nội dung âm thanh gốc.
- Các anim ZIP của kiếm được đổi bank/build/symbol và hash theo định dạng BILD v6 / ANIM v4 của `buildanimation.py` trong **Don't Starve Mod Tools** chính thức; geometry, frame và atlas TEX không đổi. Công cụ chuyển đổi kiểm tra roundtrip cấu trúc trước và sau khi đổi tên.
- Phần sửa thêm: bridge sát thương cường hóa Solo, Ngọc Lấp Lánh giữ cầu vồng và thêm ×2 sát thương gốc/planar, cấu hình mặc định vô hạn/dây chuyền và chuỗi hiển thị tiếng Việt.

## Truyền Tống Trận (0.3.1)

Tích hợp từ bản local **Truyền Tống Trận 1.0.0**, tác giả hiển thị **Nyx**, phát triển trên nền Fast Travel. Cổng, vòng xoáy và panel được tạo bằng công cụ sinh ảnh theo thiết kế đã duyệt; các TEX và animation ttt_portal được sao chép nguyên byte. Prefab bảng hiệu, writeable và API/widget gốc thuộc Don't Starve Together/Klei. Ghi chú nguồn chi tiết được lưu trong PORTAL_ASSET_CREDITS.md.
## Tinh La Kiếm

Kiếm `xd_xlj`, animation/icon, thông số và bảng `repairableitems` lấy từ Tu Tiên gốc 19.7 cục bộ (`3235319974`): `scripts/prefabs/xd_xlj.lua`, `scripts/main/mainfunction.lua`, `scripts/main/actions.lua`. Prefab mới `ttk_tinhlakiem`, bank/build gốc `xd_xlj`; hiệu ứng `nightsword_sharp_fx` thuộc DST/Klei. Viết phần tích hợp riêng bằng component chuẩn DST, không nhập loader, khóa chủ sở hữu hoặc kỹ năng nhân vật. Công thức mới của bản chuyển thể được ghi trong README. Công cụ sao chép tài nguyên: `tools/port_tinhlakiem_assets.py` ở gốc workspace.

## Nhất Vũ Phương Hoa

Chuyển từ `xd_sudaji_ywfh` của bản Tu Tiên gốc 19.7 cục bộ (`3235319974`): hai animation `xd_sudaji_ywfh`, `xd_sudaji_ywfh_fx` và icon gốc. Giữ bank/build bên trong tài nguyên; prefab độc lập `nhatvuphuonghoa`. Bỏ khóa công thức Đát Kỷ, thay nạp hồn bằng Hạ Phẩm Linh Thạch 5%, dùng hiệu ứng chống ướt riêng dựa trên component DST chuẩn. Không nhập loader hoặc hệ kỹ năng/giấy phép nguồn. Công cụ tái tạo: `tools/port_nhatvuphuonghoa.py` ở gốc workspace.

# Tài nguyên bổ sung 0.6.0

Chuồng Bò Lai, Chuồng Dê Điện, Chuồng Voi Koala và thú nuôi; Công Cụ Hạp, Đa Bảo Các, Đan Phong, Đăng Thải lấy từ bản Tu Tiên 19.7 cục bộ (`3235319974`). Đăng Thải đổi tên hiển thị thành Cửu U Xích Linh Đăng. Mã gameplay được chuyển sang `ttk_`; tên bank/build bên trong tài nguyên vẫn giữ nguyên để bảo toàn animation. Không nhập loader, hệ skin đặc quyền hoặc hệ tu luyện. Đan Lô chưa được chuyển.
# Bổ sung sản vật Sa Đường 0.6.1

Quả Sa Đường (`xd_stg`, trong `xd_veggie.lua`), nhánh quả (`xd_shatangshuvine`) và thông số hiệu ứng ăn từ Tu Tiên 19.7. Animation/icon quả sao chép nguyên byte, đường dẫn đổi `ttk_`. Logic đi trên nước viết riêng, không nhập hệ tu luyện hoặc loader nguồn; cơ chế kết quả được chuyển từ đại thụ sang cây thường theo yêu cầu.


## Skin công trình (0.8.3)

14 bộ skin từ nguồn Tu Tiên 19.7 (`3235319974`), danh sách đầy đủ trong `skins_manifest.json`; giữ bank/build hình ảnh gốc, đổi ID đăng ký sang `ttk_`. Linh thú trang trí LLT dùng build `xd_qlch`; cơ chế đi quanh/mờ dần được tách khỏi boss nguồn. Không nhập loader, máy chủ giấy phép hoặc toàn bộ hệ tu luyện nguồn.


## Chưởng Thiên Bình

Nguồn: `xd_ztp` trong Tu Tiên 19.7 (`3235319974`). Giữ animation và texture gốc, đổi đường dẫn/prefab sang `ttk_chuongthienbinh`; bank/build nội bộ giữ nguyên. Sức chứa 200 đối chiếu `xd_htz_ztp` (Cô Phẩm). Thêm công thức độc lập, dùng chi phí tuyệt đối để mức tích trữ tăng thực sự tăng số lần dùng; không nạp loader hoặc hệ tu luyện nguồn.


## Thiên Cơ Ốc

Nguồn Tu Tiên 19.7 (`3235319974`): `xd_tianjiwu`, `xd_tianji_items`, các bộ `xd_floortjw`, `xd_walltjw`, `xd_door_exittjw`, `xd_door_exittjw_heng`, `xd_wall_decals_tjw`. Animation và texture sao chép nguyên byte; đường dẫn và ID prefab dùng `ttk_`, bank/build nội bộ giữ nguyên. Bố trí phòng/camera dựa trên `xd_playerhouse`, `house.lua`, `xd_floor` và `xd_door_exit`. Cơ chế lưu phòng, quyền thu hồi, ràng buộc shard và điểm về an toàn được chuyển thể độc lập; không chạy loader nguồn.


## Nhóm 18 công trình

Tài nguyên và cơ chế nguồn: Tu Tiên 19.7 (`3235319974`), gồm hai Ngọc Lộ, Quỳnh Lâu, ba sào huyệt, kho thực phẩm, Thanh Khâu, Thiên Cơ Ốc, Thiên Vị, ba hoa, Thừa Vận Tọa, trạm gia vị, kiếm hạp và Yên Liễu. Animation giữ bank/build nguồn; tên prefab/component/action và đường dẫn riêng dùng namespace `ttk_`. Bao gồm các skin tương ứng, linh thảo, hạt, thú, brain/stategraph và hiệu ứng liên quan. Không thực thi loader nguồn hoặc nhập mod Solo. Xem ba báo cáo BATCH19 để biết những điều chỉnh so với nguồn.

## Skin Cổ Trận — Truyền Tống Trận

- Nguồn hình ảnh: `anim/xd_gcsz.zip` và `images/map_icons/xd_gcsz.{tex,xml}` từ Tu Tiên gốc 3235319974.
- Bank/build được đổi riêng thành `ttt_portal_gcsz`; giữ nguyên atlas TEX, hình học và các khung hình idle/proximity_loop. Chỉ lấy clip thuộc bank xd_gcsz; thêm alias hit/place/burnt từ khung hình idle để tương thích bảng hiệu. Icon nguồn giữ nguyên pixel.
- Chỉ chuyển tài nguyên hiển thị; không nạp prefab, trader, linh thạch, điều kiện tế đàn hoặc hệ dịch chuyển của Tu Tiên gốc.


## Lục Nguyên Kiếm Đồng

Hình cầm, icon và phi tiêu từ `xd_jingwei_blowdart` của Tu Tiên 19.7 (`3235319974`). Sáu mẫu kiếm lấy từ `xd_wxj`, `xd_htz_qzj`, `xd_xlj`, `xd_ftj`, `xd_sword_red` (vật phẩm Tiên Kiếm) và `xd_sword_mo` (vật phẩm Ma Kiếm). Cơ chế đường bay tham khảo Lục Mạch Thần Kiếm đang có trong Tu Tiên Ký; không nhập hệ tự đánh/quay về hoặc loader mod nguồn. Tên Lục Nguyên Kiếm Đồng, cơ chế crit gọi loạt kiếm và nạp linh thạch là thiết kế riêng của bản chuyển thể này.

Bộ kiếm cầm tay nguyên tố dùng lại sáu mẫu trên; icon Tiên Kiếm và Ma Kiếm lấy từ `xd_xianjian_builder` và `xd_mo_builder`. Nội tại nguyên tố, công thức hợp thành sáu kiếm và hiệu ứng kiếm khí là thiết kế mới của Tu Tiên Ký, không phải bản sao kỹ năng nhân vật/pháp bảo gốc. Tinh La tiếp tục dùng prefab đã chuyển trước đó.

## EVA

Tích hợp từ EVA 1.1.9 trong workspace. Khung nhân vật ban đầu: khung nhân vật của ZeroRyuk; kỹ năng tham chiếu Tu Tiên gốc. Hình EVA, lưỡi hái và icon theo thiết kế người dùng duyệt. Artwork bổ sung qua imagegen; nguồn/prompt lưu trong mods/eva-assets-work.

## Perk Thành Tựu — Phàm Nhân Tu Tiên 2.0

Danh mục khả năng, họ công thức, chi phí nguyên liệu và cấu hình placer được chuyển thể từ Achievement & Level (Workshop `2937640068`, bản sao tham chiếu `mods/AchievementLevel`), cụ thể `main_recipes.lua`, `scripts/components/allachivcoin.lua`, `scripts/postInits/perk_abilities.lua`, `perk_global.lua`, `perk_produce.lua` và hai prefab placer. Runtime độc lập dùng API DST và provider `ttk_achievement_*`; không nhập hệ Level hoặc phụ thuộc mod nguồn. Các công thức truyền thừa hiện dùng lại tám prefab đã chuyển thể trong Phàm Nhân; catalog vẫn giữ đủ danh sách gốc. Những nội dung thiếu prefab/component không được kích hoạt bằng alias giả.
