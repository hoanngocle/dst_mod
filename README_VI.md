# Phàm Nhân Tu Tiên 2.0

## Solo đã tích hợp đầy đủ

Chỉ cần bật **Phàm Nhân Tu Tiên**: Solo Leveling 2.2.7 cùng hệ chỉ số, kỹ năng, nhiệm vụ, hiệp hội, quân đoàn, cường hóa, UI và hầm ngục đã nằm trong gói. **Tắt Solo Leveling riêng** trên cả Master/Caves và máy khách để tránh chạy trùng. Cấu hình Solo nằm trong cấu hình Phàm Nhân Tu Tiên, có nhãn `Solo:`. Xem hướng dẫn chuyển save và phạm vi kiểm chứng tại [SOLO_INTEGRATION_VI.md](SOLO_INTEGRATION_VI.md).

Thanh máu boss theo phase, thanh máu trên đầu và số sát thương server-authoritative cũng đã nằm trong Phàm Nhân. Tắt `SoloCombatHUD`, Simple Health Bar DST và Epic Healthbar độc lập. Mặc định HUD thay chữ chiến đấu cũ bằng số trắng (thường), vàng/cam (chí mạng) và cyan (xuyên giáp), nhưng vẫn giữ thông báo EXP, nhiệm vụ và lên cấp. HUD luôn bật và không còn menu config: bật thanh máu boss, thanh máu trên đầu, ẩn thanh máu phụ trên đầu boss, hiện số HP và số sát thương; không hiện sát thương đồng đội gần. Các config HUD cũ của thế giới không còn được đọc. Công tắc chữ hiệu ứng Solo riêng đã bỏ.

Đã chạy smoke test bằng server DST offline thực: HUD và RPC đăng ký thành công; prefab Phàm Nhân cũ và component Solo tích hợp vẫn nạp; sát thương thường, xuyên giáp và chí mạng thật phát đúng loại gói RPC; mục tiêu nhận proxy thanh máu trên đầu. Chưa kiểm tra hình ảnh, HUD scale hoặc đồng bộ qua mạng với client thật, nên vẫn cần playtest host/client trước khi phát hành.

## Hệ chiến đấu — Mục 2 (2026-09-21)

Đã triển khai cho world mới; không chuyển đổi save cũ. Achievement đã tích hợp trong Phàm Nhân: thành tựu thưởng **Star**, nhiệm vụ mùa claim EXP vào `hh_leveling`. Phạm vi perk còn thiếu và điều kiện cấu hình EXP nhiệm vụ mùa được ghi tại [ACHIEVEMENT_PERK_RUNTIME.md](ACHIEVEMENT_PERK_RUNTIME.md). Không dùng các con số chiến đấu dưới đây để suy ra tiến trình EXP đã đổi.

- Sát thương nền `B = sát thương gốc + cộng phẳng còn hợp lệ`. Đòn chính: `B × (1 + (Công Kích + Nghịch Cảnh)/100) × Bạo Kích × Bạo Phát`. Sát thương lan dùng Công Kích và hai hệ số crit/proc, không nhận Nghịch Cảnh. Độc và Xuyên Giáp chỉ dùng `B`, không nhận các bonus này.
- Bạo Kích mặc định ×2; hiệu quả crit cộng vào hệ số này, ví dụ +150% → ×3,5. Tỷ lệ dùng miền 1–100 và chặn 0–100%; né xảy ra trước, không tiêu lượt quay crit/proc.
- Bạo Phát là affix vũ khí trong pool đá huyền thoại cực hiếm; mỗi vũ khí chỉ một cấp: I 30% ×1,5; II 20% ×2; III 10% ×3; IV 8% ×5. Độc lập với Bạo Kích, được nhân nhau; không còn bốn proc nội tại cùng kích hoạt.
- STR: mỗi điểm +0,1% Xuyên Giáp. Gói Xuyên bổ sung `B × min(tổng %, 40)/100`, không cắt một phần từ đòn chính. Bỏ qua giáp vật lý và pool giảm thương người chơi Phàm Nhân; vẫn tôn trọng miễn nhiễm `immuneTrue`, phòng thủ không phải giáp, phòng thủ quái, world rank, chuyển hướng, bất tử và Ngưỡng Sinh Tử. Đòn hụt/không gây mất máu không tạo gói Xuyên.
- AGI: mỗi điểm +1% né, tổng trần 70%. VIT: mỗi điểm +1% vào pool giảm thương Phàm Nhân, tổng pool tối đa 80%; không còn trừ sát thương phẳng. Pool chỉ giảm sát thương thường, không giảm planar.
- DST lấy tỷ lệ giáp cao nhất, không nhân mũ với áo. Ví dụ pool Phàm Nhân 80% và lớp giáp DST 80% khiến nhận `20% × 20% = 4%`, tức giảm 96%; đây là hai lớp khác nhau, không phải hai món giáp vanilla.
- Thanh Long I–IV: +3–5 / 6–10 / 11–15 / 16–20% Công Kích, tối đa một cấp trên vũ khí; IV giữ Trọng Thương. Bảo★Sát +15%, Siêu★Sát +20%, Đá Sức Mạnh +10%; cùng cộng vào pool Công Kích, cho phép khảm lặp theo số lỗ, chưa đặt trần pool này. Đá Sát Thương +20 đã bỏ.
- Xuyên Giáp I–IV: 3–5 / 6–10 / 11–15 / 16–20%, tối đa một cấp trên vũ khí. Nghịch Cảnh chỉ một trong ba dòng Máu/Đói/Tinh Thần trên một vũ khí; bonus tối đa +50% theo phần tài nguyên đã mất.
- Siêu★Lan: 20% mỗi viên, tối đa một viên mỗi món và tổng 60%; bán kính 3 quanh mục tiêu chính, hỗ trợ đòn cận chiến/tầm xa. Mỗi mục tiêu phụ chịu giáp riêng; không đánh người chơi/đồng minh/pet và không sinh thêm proc.
- Hút Máu chỉ tính phần HP thực mất bởi đòn chính thường và sát thương lan: tối đa 15% máu tối đa mỗi lần, tổng 90% trong cửa sổ một giây. Xuyên, Độc, Trọng Thương, Kết Liễu và sát thương gián tiếp không cho hút máu; hiệu ứng giảm/cấm hồi máu áp dụng sau giới hạn.
- Hạ Độc I–IV: 10/20/30/40% trên vũ khí, tối đa một cấp. Mỗi lần thêm một tầng, tối đa 5, làm mới cả hiệu ứng 10 giây; nhịp 2 giây, mỗi tầng gây 20% sát thương nền lúc đặt tầng. Độc bỏ giáp vật lý nhưng vẫn chịu pool giảm thương Phàm Nhân và miễn nhiễm; không hút máu hoặc sinh proc.
- Trọng Thương: tối đa 3% HP hiện tại quái thường hoặc 1% boss, tính sau đòn chính và vẫn chịu giáp/giảm thương. Kết Liễu chỉ áp dụng quái thường khi còn ≤15% HP; không kết liễu boss/endgame boss.
- Giảm Hồi Máu: giảm 90% hồi máu dương trong 5 giây, đòn chính làm mới; không gây sát thương, không cộng tầng. Đóng Băng I–IV có tỷ lệ 5/10/15/20%: quái thường đóng băng 2 giây, boss chỉ chậm 20% trong 2 giây; hồi chiêu riêng trên mục tiêu 5 giây.
- Liên Kích I–IV: 5–10 / 15–25 / 30–45 / 50–70% tốc đánh, tổng thưởng Phàm Nhân tối đa +100%. Nhanh Nhẹn: 5–25% tốc chạy; pool tốc chạy Phàm Nhân tối đa +50%, các hệ số vanilla vẫn riêng.
- Đã bỏ custom Phản Kích/Phản Đòn, kể cả Phản Chấn giáp +7; giữ nguyên gai/phản đòn vanilla và nội tại Bất Diệt của giáp. Đã bỏ Lá Chắn tinh thần, Ban Phúc, Hồi Não, sát thương điều kiện cũ (`soakStrike`...), các nhánh độc/đóng băng/giảm hồi máu phản ứng cũ, và ba set Bạch Hổ Thiên Cương, Phi Vân Dật Ảnh, Thánh Quang Tí Hựu. Các mốc cường hóa còn lại không đổi số.

Kiểm chứng và giới hạn được ghi tại `../../.superpowers/sdd/2026-09-21-pham-nhan-combat-pipeline/task-5-report.md`. Cổng provenance vẫn báo lệch hash có sẵn ở nguồn Solo `main/hh_tunning.lua`; không sửa nguồn hay hạ điều kiện kiểm tra để che lỗi. Chưa thể coi toàn bộ Mục 2 đã qua mọi cổng phát hành, và kiểm thử server không thay thế playtest đồ họa/client.

## Tế Đàn thử luyện boss

- Chế **Tế Đàn** tại Máy Luyện Kim bằng 12 Đá Cắt + 6 Vàng + 2 Thượng Phẩm Linh Thạch; chế **Linh Lung Bảo Sương** bằng 6 Ván Gỗ + 4 Vàng + 1 Thượng Phẩm Linh Thạch. Đặt rương trong bán kính 32 trước khi dâng lễ.
- Dâng đúng 1 Trung Phẩm hoặc Thượng Phẩm Linh Thạch. Tế Đàn kiểm tra người dâng, rương, vị trí, mùa và khả năng tạo đủ boss trước khi lấy lễ vật; sau đếm ngược 5 giây, người dâng phải tiếp tục ở gần.
- Pool gồm 38 encounter DST/legacy tương thích và 13 encounter có nguồn gốc Solo đã tích hợp. Boss Solo mặc định tham gia pool vì Solo đã tích hợp sẵn trong Phàm Nhân; không có công tắc bật/tắt riêng. Deerclops chỉ vào pool mùa đông, Moose/Goose chỉ vào pool mùa xuân; boss biển chỉ vào pool khi địa hình gần Tế Đàn phù hợp.
- Boss giữ component, tăng sức mạnh theo thế giới, EXP/đồ, phase và defeat thật của Phàm Nhân. Hủy/thua dọn đúng thực thể thuộc lượt, không giả sự kiện chết. Xác Igris/Beru sau chiến thắng vẫn được giữ để dùng cơ chế chiêu mộ của hệ Solo.
- Thưởng được chốt một lần theo người dâng và lưu dưới dạng save record. Một rương vật lý tạo kho 36 ô riêng theo `userid`; người khác không mở trực tiếp được. Rương đầy giữ phần còn lại để nhận sau, kể cả sau lưu/tải hoặc khi rương cũ bị phá rồi xây lại gần Tế Đàn.
- Server smoke thật đã tạo, chờ qua task khởi tạo, chạy một tick và dọn đủ 51 encounter theo đúng mùa; kiểm riêng chuỗi ba phase Thiên Thể, loot cuối của Twins và hai kho rương độc lập. Chi tiết và giới hạn kiểm thử: [AUDIT_JITAN_VI.md](AUDIT_JITAN_VI.md).

## Mỏ linh thạch tự nhiên và chế tạo

Ba cấp mỏ tự nhiên đào hết sẽ mất, mỗi mùa sinh thêm mỏ mới. Công trình nhân tạo **Linh Tuyền Cực Phẩm** có hình ảnh riêng, tạo linh thạch mỗi 5 ngày để bấm **Thu hoạch**, vẫn giữ nguyên công trình; thay thế ba công thức mỏ chế tạo cũ. Công thức, sản lượng, phân bố và lưu/tải: [SPIRIT_MINES_VI.md](SPIRIT_MINES_VI.md).

## Bổ sung bốn món vườn

Đã thêm **Nguyệt Hoa Nhiếp Dược Chi**, **Hoán Nguyệt Trì**, **Hạnh Hoa Thụ** và **Hoán Miêu Thụ Ốc**. Mọi nhân vật sử dụng được. Công thức, cách hái linh thảo, nuôi cá và nhận quà Catcoon: [GARDEN_EXPANSION_VI.md](GARDEN_EXPANSION_VI.md).

## Máy Quay Thưởng Linh Thạch

- Mã `ttk_choujiangji`, chuyển hình ảnh, hoạt ảnh và âm thanh từ `xd_choujiangji` của Tu Tiên 19.7 (`3235319974`). Không cần bật mod gốc.
- Chế tạo tại Máy Luyện Kim: **6 Đá Cắt + 4 Ván Gỗ + 2 Bánh Răng + 1 Ngọc Tím + 30 Hạ Phẩm Linh Thạch**. Có hình đặt công trình và biểu tượng bản đồ; không tự sinh trong đầm lầy.
- **1 Trung Phẩm Linh Thạch (`ttk_lingshi2`) = 1 lượt**, kể cả khi đưa cả chồng. Không nhận các cấp linh thạch khác.
- 104 gói: 16 hiếm, 20 khá, 23 thường, 13 boss và 32 nhóm quái. Giữ trọng số nhóm gốc: hiếm 0,5; khá 1,5; thường 3,5; boss 0,8; quái 4,2 (tổng 10,5). Khoảng 47,62% lượt gọi quái/boss; không có bảo hiểm lần đầu.
- Một lượt nhận trọn một gói có chủ đề. Trang bị không xếp chồng luôn chỉ một chiếc mỗi loại trong gói; nguyên liệu và đồ tiêu hao có thể nhiều hơn. Những lần quay khác nhau vẫn có thể trùng quà. Đã bỏ đan dược và boss riêng chưa chuyển; pháp bảo dùng prefab Phàm Nhân Tu Tiên.
- Máy khóa nhận đá và tháo bằng búa từ lúc quay đến hết trả thưởng. Lưu/tải giữ danh sách phần thưởng chưa phát; tải lại sẽ tiếp tục trả thưởng. Quà rơi quanh máy, quái có thể tìm người chơi trong bán kính 25.
- Bỏ hoàn toàn sáo Pan. 44 món phổ thông trong bảng gốc được thay bằng linh thực Lạc Thần, hạt/linh thảo, nguyên liệu và trang bị Phàm Nhân Tu Tiên. Khôi phục Vương Miện Khai Sáng, Giáp Xương, Ô Hư Không, bộ trượng ngọc và các món DST giá trị còn thiếu.
- Bảng thưởng đầy đủ: [CHOUJIANGJI_REWARDS.md](CHOUJIANGJI_REWARDS.md). [Kiểm kê 183 prefab gốc và lý do giữ/thay/bỏ](CHOUJIANGJI_AUDIT.md). Mã bảng thưởng: `scripts/ttk_slot_prizes.lua`.
- Kiểm tra Lua 5.1 xác nhận lưu/tải chỉ phát phần quà còn lại, không phát lặp, không có sáo Pan, không lặp trang bị trong một gói và không bỏ sót prefab ngoài danh sách thay/bỏ có lý do. Chưa kiểm tra hình ảnh/âm thanh bằng client đồ họa.
- Máy chủ DST build 747465 đã tạo được mọi prefab trong 104 gói, kiểm tra công thức/hình đặt, trừ đúng 1 viên từ chồng 10 Trung Phẩm, khóa lượt, xử lý boss Thiên Thể và hoàn tất quay/trả thưởng. Bộ kiểm tra mod cùng hai audit: 17/17 đạt.

## Luân Hồi Đài

- Mã `ttk_fsct`, chuyển từ `xd_fsct` của Tu Tiên gốc; giữ hình dáng, biểu tượng bản đồ và hiệu ứng gọi sét khi hồi sinh.
- Mọi nhân vật chế tạo ở Máy Luyện Kim: **10 Đá Cắt + 6 Vàng + 2 Tim Mách Lẻo (Telltale Heart, `reviver`) + 2 Thượng Phẩm Linh Thạch**. Có hình xem trước để đặt công trình.
- Hồn ma ám vào đài để hồi sinh theo cơ chế chuẩn của game. **Vô hạn lượt, không thời gian chờ, không cần nạp**, không biến mất sau khi dùng; bỏ hoàn toàn bộ đếm 3 lượt và bộ hồi 960 giây của bản gốc.
- Kiểm thử với Hauntable thật của DST xác nhận 20 lần dùng liên tiếp, chỉ nhận hồn ma, không còn bộ đếm/thời gian chờ, công thức và ranh giới máy chủ/máy khách. Chưa kiểm tra trực tiếp trong game.

## Ngư Long Đăng

- Mã `ttk_ngulongdang`. Mọi nhân vật chế tạo tại Máy Khoa Học: 3 Vàng + 2 Gỗ + 3 Giấy + 1 Trung Phẩm Linh Thạch.
- Giữ chiếu sáng và điều hòa nhiệt độ gốc: bán kính nhiệt 10, nhiệt độ 19°C; dung lượng 3.360 giây, hao nhanh hơn khi gặp mưa như bản gốc.
- Đưa **Hạ Phẩm Linh Thạch** (`ttk_lingshi1`) vào đèn: nhận đúng 1 viên, hồi **10% tổng dung lượng**, tối đa 100%. Đèn đầy không nhận thêm; không nhận hồn hoặc linh thạch cấp khác.
- Đèn cạn vẫn còn và nạp lại được. Đèn đang cầm hoặc đặt dưới đất sáng lại khi được nạp; đèn cất trong túi không tự bật khi nạp.
- Đã kiểm thử bằng component Trader/Fueled thật của DST: tiêu hao đúng một viên, mức nạp, giới hạn, cạn/nạp lại, cất/thả/cầm và lưu/tải. Chưa xác nhận hình ảnh/thao tác trực tiếp trong game.

## Lạc Thần Hoa và hai món ăn

- Hoàn thiện nhóm 5 mục: `ttk_luoshen_huazhong` (Hạt Giống Lạc Thần Hoa), `ttk_luoshen_hua` (cây), `ttk_luoshen_huayin` (Lạc Thần Hoa Nhân), `ttk_luoshen_qingshu` (Lạc Thần Thanh Sơ), `ttk_luoxiang_pengrou` (Lạc Hương Phanh Nhục). Mọi nhân vật đều dùng được, không cần bật mod Tu Tiên gốc.
- Chế hạt tại Máy Luyện Kim: 60 Cánh Hoa + 3 Thịt Lá + 1 Trung Phẩm Linh Thạch. Gieo rồi dưỡng qua 4 lần để đạt tầng 5. Mỗi lần dùng Chưởng Thiên Bình tốn 100 linh khí; vẫn có thể dùng Hạ Phẩm Linh Thạch như trước. Hoa non chưa cho thu hoạch; hoa trưởng thành tái tạo Hoa Nhân mỗi ngày.
- Nấu tại Nồi Hầm hoặc nồi di động: có ít nhất 1 Hoa Nhân, không có giá trị thịt → **Lạc Thần Thanh Sơ**: 200 máu, 42,5 đói, 80 tinh thần; hỏng sau 15 ngày game.
- Có Hoa Nhân và giá trị thịt > 0 → **Lạc Hương Phanh Nhục**: 10 máu, 75 đói, 62,5 tinh thần; hỏng sau 20 ngày game. Trong 480 giây sau khi ăn, mỗi đòn đánh mục tiêu còn sống hồi 2 máu; ăn tiếp làm mới thời gian, không cộng dồn hiệu ứng.
- Cả hai công thức có độ ưu tiên 10 như bản nguồn; nguyên liệu cần tránh khớp món khác có độ ưu tiên cao hơn. Ví dụ: 1 Hoa Nhân + 3 Cà Rốt; hoặc 1 Hoa Nhân + 1 Thịt + 2 Cà Rốt.
- Đã kiểm tra Lua 5.1: phân loại công thức, chỉ số, độ tươi, prefab, hiệu ứng hồi máu, dưỡng/thu hoạch/lưu giai đoạn hoa, chi phí bình và ranh giới máy chủ/máy khách. Rà tài nguyên/đăng ký đạt; chưa kiểm tra hình ảnh và thao tác trực tiếp trong game.

## Tinh La Kiếm

- Prefab `ttk_tinhlakiem`, chuyển từ `xd_xlj` của Tu Tiên gốc 19.7. Mọi nhân vật được chế tạo, cầm và chuyển cho người khác; không khóa WX-78 hoặc chủ sở hữu.
- Công thức tại Máy Luyện Kim: **3 Ngọc Xanh Dương + 6 Vàng + 1 Trung Phẩm Linh Thạch**.
- Giữ **100 sát thương, tầm đánh 2, tối đa 1.000 lượt**, khởi đầu **300 lượt (30%)** như gốc. Đánh hao độ bền theo cơ chế DST; hết lượt kiếm không biến mất và vẫn giữ 100 sát thương theo thiết lập hiện tại.
- Nội tại Thủy: **20% cơ hội** làm chậm di chuyển mục tiêu **25% trong 3 giây**; không cộng dồn. Là một trong sáu nguyên liệu ghép Lục Nguyên Kiếm Đồng.
- Cầm vật phẩm nạp bằng con trỏ và dùng thao tác đưa vào kiếm. **Mỗi lần tiêu thụ một món** theo bảng Tu Tiên gốc, không phụ thuộc độ bền còn lại của món đó. Khi đầy, kiếm từ chối nhận; lượng dư khi gần đầy bị mất.
- Một số mức nạp: Giáo 25; Giáo Chiến Đấu 50; Chùy Giăm Bông/Xúc Tu/phi tiêu 75; Kiếm Bóng Đêm/Kiếm Thủy Tinh 100; Bat Bat/Roi 125; Chùy Thulecite/Sao Mai 150; Kiếm–Trượng Brightshade/Lưỡi Hái Shadow/Đồng Hồ Báo Động 225; Đinh Ba/Trượng Lốc/Giáo Sấm 250; Khiên Kinh Hoàng 300 lượt. Danh sách đầy đủ: `scripts/ttk_tinhlakiem_repair.lua`, gồm cả đạn ná theo gốc.
- Chỉ chuyển kiếm, công thức và nạp độ bền theo yêu cầu; không chuyển kỹ năng mìn/sét của WX-78.
- Kiểm thử bằng component `finiteuses` và `trader` thật của DST đã đạt: tiêu thụ một món, bảng nạp, đầy/cạn, lưu/tải, tháo hiệu ứng và công thức không khóa nhân vật. Chưa kiểm tra hình ảnh/thao tác bằng máy khách trong game.

## Nhất Vũ Phương Hoa

- Prefab `nhatvuphuonghoa`, chuyển từ ô Tu Tiên gốc 19.7. Mọi nhân vật đều chế tạo và sử dụng được.
- Chế tạo tại Máy Luyện Kim: 6 Giấy + 3 Tơ + 2 Trung Phẩm Linh Thạch + 2 Gỗ Sống.
- Cầm để chống ướt hoàn toàn và cách nhiệt mùa hè; thả xuống đất để tạo vùng che mưa. Vùng che mưa tiêu hao độ bền và giảm tinh thần người đứng gần như bản gốc.
- Phép **Giữ Khô** lên người chơi xóa độ ướt và chống ướt 240 giây, tốn 25% độ bền.
- Đưa **Hạ Phẩm Linh Thạch** (`ttk_lingshi1`) vào ô: mỗi lần nhận đúng 1 viên và hồi **5% tổng độ bền**, tối đa 100%. Ô đầy không nhận thêm; không nhận linh thạch cấp khác hay hồn Đát Kỷ.
- Ô cạn vẫn còn, nạp một viên là dùng lại được. Dung lượng gốc 3.360 giây được giữ nguyên.
- Kiểm thử callback Lua và rà cú pháp/tài nguyên được chạy cho phần này. Máy chủ thử hiện bị chặn bởi atlas DST `images/cookbook_unagi_spice_salt.xml` bị thiếu, nên chưa xác nhận hình ảnh và thao tác trực tiếp trong game cho ô mới.

Đợt kiểm tra trước khi thêm ô đã rà đăng ký và chạy máy chủ DST thật với 80 thực thể, 14 skin và 24 công thức.
Đây là kết quả lịch sử của bản 0.8.4, không phải chứng nhận cho toàn bộ runtime hiện tại. Các sửa lỗi tương ứng được giữ trong [CHANGELOG.md](CHANGELOG.md).

## Chỉ báo boss lớn (0.9.0)

- Khi boss lớn ở trong phạm vi gần nhưng nằm ngoài màn hình, HUD hiện icon và mũi tên chỉ hướng. Boss đang ở trên màn hình không có chỉ báo thừa.
- Hỗ trợ các boss lớn hiện tại của DST, boss mod có thẻ `epic`, và các boss Solo tích hợp: Super Frostjaw, Lợn Rừng Bọ Hung, Siêu Lợn Song Kiếm, Igris, Beru và Minotau.
- Boss chưa có icon riêng dùng icon dự phòng cùng tên hiển thị hoặc tên prefab đã làm dễ đọc. Boss nhỏ quen thuộc, pet, hồn triệu hồi, thực thể chết hoặc ẩn bị loại.
- Tính năng luôn bật cùng Phàm Nhân Tu Tiên, không có cấu hình riêng và không cần cài Boss Indicators gốc. Phàm Nhân Tu Tiên vẫn phải có trên máy chủ và mọi người chơi; phần chỉ báo chỉ chạy phía máy khách.
- Kiểm thử tự động không xác nhận được vị trí, tỷ lệ và độ rõ của icon ở từng độ phân giải; cần kiểm tra trực tiếp trong game.

## Skin, Phiên và bỏ Sa Đường (0.8.3)

- Nhập đủ **14 skin cho 11 công trình đang có**, không nhập vật phẩm/nhân vật mới chỉ để dùng skin. Skin của Sa Đường và các món đã loại không được nhập.
- Chọn skin khi chế tạo hoặc dùng Chổi Sạch; giữ cơ chế lưu skin chuẩn của DST, công thức, kho, sản vật và nhiên liệu của công trình gốc.
- Đa Bảo Các LLT có linh thú trang trí riêng: đi quanh khoảng 8 giây rồi tan; nhịp 110–120 giây, giãn nhịp với kệ LLT trong bán kính 20. Không nhập boss/chiến lợi phẩm của linh thú nguồn. Đổi skin hoặc tháo kệ dọn linh thú đang hiện.
- Cửu Thiên Tinh Thần Phiên có carrier số `weapon.damage` nền **20** từ lúc tạo vật phẩm, để Solo nhận diện. Đạn và sát thương lan Hồn Vệ đọc carrier này. Phiên không gây thêm đòn đánh trực tiếp.
- Mức cường hóa được chuyển qua đặt/thu và lưu cùng Phiên; component Solo do bootstrap chung nạp. Phiên giữ bản sao dữ liệu cường hóa khi chuyển trạng thái. Chỉ tích hợp sát thương; không tự chuyển mọi nội tại cường hóa vào đạn.
- **Đã bỏ toàn bộ Sa Đường:** cây thường, hạt, nhánh, quả, công thức, hook ăn quả/đi nước và tài nguyên riêng. Những vật phẩm/cây Sa Đường trong save cũ không còn được đăng ký ở bản này.
- Chỉ cập nhật thư mục mod và trang web; không đóng gói ZIP, không tự mở game.

| Công trình | Skin đã nhập |
|---|---|
| Hoàng Hoa Lê Mộc Trác | HTJC, WFZ |
| Bách Hợp | YA |
| Bạch Mân Côi | SRLG |
| Cam Tỉnh | LRQ, QSJ |
| Anh Đào Thụ | FD |
| Đan Phong | ZSYJ |
| Chuồng Bò Lai | QNS |
| Chuồng Dê Điện | ZJZY |
| Công Cụ Hạp | JSTH |
| Đa Bảo Các | LLT, YBG |
| Cửu U Xích Linh Đăng | HH |


## Stack 120 (0.8.2)

- Tích hợp **Increased Stack size** (`374550642`), cố định **120 món/ô** cho tất cả vật phẩm có thể xếp chồng, gồm vật phẩm mod. Không có tùy chọn cấu hình và không cần bật mod nguồn.
- Vật phẩm vốn không xếp chồng được giữ nguyên. Đa Bảo Các nâng cấp vẫn chứa stack vô hạn; giới hạn stack thường là 120.

## Túi đồ 45 ô và trang bị riêng (0.8.0)

- Tích hợp từ mod `3075429483`, cố định **45 ô túi đồ**, ô đầu ở dưới trái, khoảng cách chia nhóm 15 và không bật cất ba lô vào túi. Không còn menu config túi đồ; các lựa chọn cũ của thế giới không được đọc.
- **Ô ba lô và ô dây chuyền luôn có, không có công tắc bật/tắt.** Có thể mang áo giáp cùng ba lô và dây chuyền. Lục Mạch Thần Kiếm dùng ô dây chuyền khi cấu hình pháp bảo chọn vị trí này.
- Dùng cơ chế túi đồ/đồng bộ mạng hiện tại của game, giữ kiểm tra nguyên liệu từ ba lô ở cả máy chủ và máy khách. Giữ các ô trang bị do mod khác thêm vào.
- Bố cục hai hàng theo bản nguồn, khoảng giữa dành cho trang bị; ba lô tích hợp lớn tự xuống hàng. Giữ các điều khiển và xử lý túi đồ gốc, không áp dụng bố cục mới cho Đấu Trường/Dạ Tiệc.
- Tắt mod riêng **45 Inventory Slots [Fixed + EquipSlot UI expand]** và các mod tăng số ô trùng chức năng khi bật bản tích hợp. Cài Phàm Nhân Tu Tiên cho cả máy chủ và người chơi; khởi động lại thế giới sau khi cập nhật.
- Đã kiểm thử Lua cho số ô, đồng bộ, ba lô riêng, nguyên liệu chế tạo và bố cục mô phỏng. Chưa kiểm tra hình ảnh hoặc thao tác trực tiếp trong game, đặc biệt tay cầm và giao diện từ mod khác.

Không giảm số ô hoặc gỡ tính năng khi các ô cuối còn đồ; chuyển đồ ra trước để tránh mất đồ khi tải lại.

## Vĩnh Hằng Thần Hỏa (0.7.0)

- Tích hợp Bếp Thần Hỏa, Bếp Hàn Hỏa, Vĩnh Hằng Thần Hỏa và Vĩnh Hằng Hàn Hỏa từ bản sửa của mod `2422129165`.
- Cả bốn bếp không bị máy phóng băng chọn làm mục tiêu hoặc dập bằng đạn tuyết lan, kể cả chế độ khẩn cấp và khi khu vực không được hiển thị. Vẫn tiêu hao nhiên liệu và tắt khi hết nhiên liệu.
- Phần này luôn được nạp và không còn menu config chung/riêng. Cả bốn công trình cố định: công thức Tiêu chuẩn, hiệu suất nhiên liệu ×0,75, dung lượng ×10, nhiên liệu ban đầu 25%, phạm vi sáng ×1,25, kích thước ×1, hồi tinh thần mặc định nguồn (0,5), vật phẩm khi tắt Bình thường (2), không sinh chó săn. Các giá trị config Thần Hỏa cũ của thế giới không còn được đọc.
- Chỉ bật **Phàm Nhân Tu Tiên**; tắt **Vĩnh Hằng Thần Hỏa** độc lập và mod gốc **2422129165** để tránh trùng bếp/công thức. Giữ mã định danh bếp để nhận lại bếp đã xây. Đổi mod khi thế giới đang đóng, không tải rồi lưu thế giới khi thiếu mod cung cấp bếp. Thiết lập cố định trên thay cho cấu hình của bản độc lập.
- Dùng thẻ loại trừ `shadow_fire` của game; các nguồn nước có cùng bộ lọc như bóng nước cũng bỏ qua bếp.
- Đã kiểm tra đăng ký, cấu hình, tài nguyên, cú pháp Lua và mô phỏng chữa cháy bằng mã game đang cài. Chưa thử trực tiếp trong thế giới hoặc xác minh tương tác với mod chống dập lửa khác.

## Tiện ích luôn bật (0.7.1)

- **Open gifts everywhere** (`3036001095`): mở quà ở bất cứ đâu, không cần Máy Khoa Học.
- **No Grass Gekko** (`1686705509`): cỏ không biến thành Grass Gekko khi hái. Grass Gekko đã tồn tại không bị xóa.
- **Smarter Ice Flingomatic** (`1845106626`): tăng độ nhạy chữa cháy khẩn cấp kể cả khi máy đang tắt; bỏ qua bếp/lửa chủ động, gồm bếp Deluxe của Vĩnh Hằng Thần Hỏa. Máy vẫn cần nhiên liệu; giữ dung lượng nhiên liệu mặc định ×1.
- **DJPaul's Sort Inventory — bản sửa** (`1462979419`): chỉ sắp xếp khi nhấn **G**. Đang mở rương/Đa Bảo Các: chỉ sort kho đang mở. Không mở rương: sort inventory và ba lô. Nhặt đồ, chuyển đồ, mở kho hoặc tải save không tự sort. Nếu đang cầm đồ trên con trỏ, đặt đồ xuống rồi nhấn G lại.
- Sắp riêng từng kho, không chuyển nguyên liệu giữa inventory/ba lô như tùy chọn của mod gốc. Giữ ô khóa và trang bị; bỏ qua kho chỉ đọc, thiết bị có ô chức năng hoặc bộ lọc vị trí. Đa Bảo Các giữ stack vô hạn và cập nhật tám ô trưng bày.
- Các tính năng được nạp tự động cùng Phàm Nhân Tu Tiên, không có công tắc bật/tắt riêng; không cần bật thêm các mod nguồn. Nếu bật cả bản DJPaul đã sửa và Phàm Nhân Tu Tiên, sorter chỉ đăng ký một lần; cấu hình của bản được nạp trước được dùng.

Mod độc lập cho Don't Starve Together, gồm bàn, linh thạch, vũ khí/pháp bảo, Truyền Tống Trận và nhóm công trình/cây cảnh bên dưới. Mod dùng tài nguyên hình ảnh đã ghi trong `CREDITS.md`, không cần bật toàn bộ mod Tu Tiên hoặc mod kiếm riêng.

Bản 0.6.2 từng sửa tải save khi đang đạp nước, thả thú khi phá chuồng ban đêm và chọn điểm đến an toàn cho cổng sát bờ; lịch sử nằm trong [CHANGELOG.md](CHANGELOG.md). Rà soát tĩnh chưa thay thế thử trong game/multiplayer.


## Chuồng nuôi, kho và đèn (0.6.0)

Đã chuyển bảy món bên dưới. **Đan Lô để làm riêng sau**, theo lựa chọn của người dùng; chưa nhập hệ đan dược/tu luyện.

| Vật phẩm | Prefab | Công thức | Trạm |
|---|---|---|---|
| Chuồng Bò Lai | `ttk_pflnw` | 5 Đá Cắt + 3 Vàng + 2 Sừng Bò + 10 Hạ Phẩm Linh Thạch | Máy Khoa Học |
| Chuồng Dê Điện | `ttk_ftys` | 2 Sừng Dê Điện + 10 Đá + 10 Dây Thừng + 10 Hạ Phẩm Linh Thạch | Máy Khoa Học |
| Chuồng Voi Koala | `ttk_klxw` | 5 Đá Cắt + 1 Vòi Voi Hè + 1 Vòi Voi Đông + 10 Hạ Phẩm Linh Thạch | Máy Khoa Học |
| Công Cụ Hạp | `ttk_gjx` | 3 Vàng + 2 Ván Gỗ + 7 Hạ Phẩm Linh Thạch | Máy Khoa Học |
| Đa Bảo Các | `ttk_dbg` | 6 Ván Gỗ + 2 Vàng + 2 Đá Cẩm Thạch + 1 Hạ Phẩm Linh Thạch | Máy Khoa Học |
| Đan Phong | `ttk_tree_df` | 4 Gỗ Sống + 8 Ngọc Đỏ + 1 Hạ Phẩm Linh Thạch | Máy Luyện Kim |
| Cửu U Xích Linh Đăng | `ttk_dc` | 10 Cành Cây + 3 Dây Thừng + 3 Vàng + 1 Hạ Phẩm Linh Thạch | Máy Khoa Học |

- Ba chuồng có tối đa hai thú, tự phục hồi số lượng và cho thú về chuồng ban đêm. Thu hoạch bằng tương tác **Thu hoạch**. Chỉ tích lũy kỳ sản xuất khi đủ hai thú (tính cả ở trong và ngoài chuồng).
- Bò: mỗi ba kỳ ngày đủ đàn cho 8 lông, 50% thêm 1 sừng; dê: mỗi kỳ ngày đủ đàn cho 1 sữa, 25% thêm 1 sừng; voi: mỗi ba kỳ ngày đủ đàn cho một vòi hè/đông ngẫu nhiên. Cần chỗ trống trong kho chuồng.
- Công Cụ Hạp và Đa Bảo Các giữ **36 ô** theo nguồn hiện tại. Hạp nhặt công cụ cách tối đa 8 đơn vị mỗi khoảng 10 giây, bỏ qua vật đang được cầm và vật có thông tin chủ sở hữu. Kệ trưng bày tám ô đầu. Cả hai dùng cơ chế nâng cấp sức chứa bằng mảnh vương miện đã có trong mod.
- Đan Phong che mưa, giữ nhiệt độ trong bán kính 6 ở 19 độ, sinh 4 Ngọc Đỏ mỗi khoảng 7 ngày + 0–100 giây.
- Đăng Thải đổi tên thành **Cửu U Xích Linh Đăng**, bán kính sáng **2,5 → 3,5**. Cho Hạ Phẩm Linh Thạch vào ô đèn; đèn chỉ sáng ban đêm, mỗi viên duy trì 3.360 giây phát sáng. Đồng hồ dừng khi ban ngày hoặc hết nhiên liệu và được lưu qua save/load.
- Công trình ở mục Công trình; hai kho có thêm mục Rương, đèn có thêm Ánh sáng, Đan Phong có thêm Trang trí.

Cập nhật trực tiếp thư mục, không tạo ZIP. Đã kiểm tra cú pháp Lua và tài nguyên; chưa chạy thử trong game.

## Công trình và cây cảnh (0.5.0)

| Vật phẩm | Prefab | Công thức | Trạm |
|---|---|---|---|
| Anh Đào Thụ | `ttk_tree_yhs` | 4 Gỗ Sống + 4 Ngọc Tím + 1 Hạ Phẩm Linh Thạch | Máy Luyện Kim |
| Bách Hợp | `ttk_flower_bh` | 2 Bướm sống + 2 Ngọc Tím + 1 Hạ Phẩm Linh Thạch | Máy Khoa Học |
| Bạch Mân Côi | `ttk_flower_bmg` | 2 Bướm sống + 2 Ngọc Vàng + 1 Hạ Phẩm Linh Thạch | Máy Khoa Học |
| Bồ Công Anh | `ttk_flower_pgy` | 2 Bướm sống + 12 Gỗ + 1 Hạ Phẩm Linh Thạch | Máy Khoa Học |
| Cam Tỉnh | `ttk_gj` | 12 Đá + 1 Dây Thừng + 11 Gỗ + 1 Hạ Phẩm Linh Thạch | Máy Khoa Học |
| Chậu Hoa Uẩn Linh | `ttk_huapen` | 1 Gỗ Sống + 2 Đá Cắt + 3 Hạ Phẩm Linh Thạch | Máy Khoa Học |

Công thức của sáu công trình đầu giữ nguyên lượng trong Tu Tiên gốc, đổi sang linh thạch `ttk_lingshi1`. Các hoa/cây ở mục Trang trí/Làm vườn; Anh Đào Thụ có thêm Công trình; giếng/chậu ở Công trình/Làm vườn.

- **Anh Đào Thụ:** che mưa; giữ nhiệt độ vùng bán kính 6 ở 19 độ; sinh 2 Ngọc Tím mỗi khoảng 7 ngày + 0–100 giây như nguồn. Có thể đập búa tháo công trình.
- **Ba chậu hoa:** aura tinh thần bằng `2 * TUNING.SANITYAURA_TINY`. Mỗi bình minh ngoài mùa đông có 40% cơ hội sinh bướm, không sinh trong hang. Sửa điều kiện callback nguồn để chỉ xét bình minh, không xét cả lúc hết ngày.
- **Cam Tỉnh:** nguồn nước chuẩn, dùng nạp bình tưới. Không cần hệ bình nước/linh lực riêng của Tu Tiên.
- **Chậu Hoa Uẩn Linh:** trồng bằng hạt rau như trồng lên mô đất, mỗi chậu một cây. Có 2 lượt linh lực; khi còn lượt, cây trong chậu được bỏ stress ở bước xét chất lượng cuối và có thể đạt nông sản khổng lồ. Vẫn cần thời gian, ánh sáng và quá trình sinh trưởng của game. Hạt giống thường vẫn có thể ra cỏ dại như game.
- Mỗi lần cây bị thu hoạch/đào bỏ/cháy mất sẽ tốn 1 lượt; cây chuyển từ mầm vô danh sang cây cụ thể không tốn lượt. Khi chậu hết linh lực, dùng 1 Hạ Phẩm Linh Thạch lên chậu hoặc cây, chọn **Uẩn linh**, để nạp lại 2 lượt. Hết linh lực vẫn trồng được nhưng mất hỗ trợ stress. Chậu đang có cây không thể đập búa; chậu trống đập ra 1 Đá Cắt + 1 Hạ Phẩm Linh Thạch như nguồn.
- Liên kết chậu/cây và linh lực được lưu bằng `entitytracker`/`finiteuses`; chậu tồn tại suốt vụ, không tạo lại chậu khi xóa cây. Hạt vô danh đổi thành cây được nối lại vào chậu. Phần chống cây nguyệt xâm nhập chỉ áp dụng cây trong chậu. Bỏ điều kiện chỉ xây cạnh nhà Tu Tiên vì bản độc lập không có nhà đó.



Chỉ cập nhật thư mục mod, không đóng ZIP. Kiểm tra cú pháp/tài nguyên và đối chiếu API cài trên máy; chưa chạy game, không viết/chạy test suite.

## Thần Hi Quang Trượng

Chuyển thể Phức Úc Thủ Trượng (`xd_yunxiao_fysz`) của Tam Tiêu trong Tu Tiên 19.7. Đây là trượng di chuyển/thoát hiểm; mọi nhân vật đều dùng được, không cần Tu Tiên gốc hoặc Solo.

- Cầm trên tay tăng tốc độ di chuyển **30%**. Đánh thường dùng sát thương gậy đi bộ (`TUNING.CANE_DAMAGE`), không có planar riêng và không hao lượt do đánh thường.
- Chuột phải vào mặt đất để dịch chuyển gần, tiêu hao **1 lượt**. Dùng luồng BLINK chuẩn của game, tầm hành động 36 đơn vị.
- Khi cầm trượng, mở bản đồ và chuột phải vào điểm đã khám phá trong cùng shard, cách tối đa **128 đơn vị game**, để Độn Quang. Tiêu hao **3 lượt**. Đích phải đi được và không bị chặn; không vượt giới hạn dịch chuyển của game. Có thể chọn trực tiếp vị trí sàn thuyền hợp lệ; không tự tìm thuyền gần điểm biển trống như nguồn.
- Hai kiểu dịch chuyển dùng chung hồi chiêu **30 giây**, không tiêu hao tinh thần. Kiểm tra trượng đang cầm, lượt còn lại, hồi chiêu, tầm và vị trí ở phía server.
- Trượng có **30 lượt**. Đưa **Đá Sa Mạc** (`townportaltalisman`) vào để hồi **15 lượt**, tối đa 30. Không nhận đá khi đã đầy. Nạp lượt không xóa hồi chiêu. Dùng hết lượt thì trượng biến mất, giống nguồn; nên nạp trước khi cạn.
- Lượt còn lại và hồi chiêu lưu bằng component chuẩn `finiteuses`/`rechargeable`.
- Công thức: **3 Đá Sa Mạc + 1 Ngọc Vàng + 1 Trung Phẩm Linh Thạch**, tại **Shadow Manipulator**, mục **Ma thuật / Công cụ**. Giữ lượng nguyên liệu nguồn, đổi `xd_lingshi2` thành `ttk_lingshi2`, bỏ khóa nhân vật và thêm trạm chế tạo. Giữ cấm giải cấu trúc của công thức nguồn.
- Giữ hình dáng và hạt sáng vàng/trắng của trượng gốc. Dùng hiệu ứng/hoạt ảnh dịch chuyển chuẩn của game thay cho state riêng của Tam Tiêu để hoạt động độc lập.

Prefab: `thanhiquangtruong`; console host: `c_give("thanhiquangtruong")`.

Bản 0.4.0 cập nhật trực tiếp thư mục mod, không đóng ZIP. Rà mã, kiểm tra cú pháp/tài nguyên; chưa chạy trong game, không viết/chạy test suite.

## Cửu Thiên Tinh Thần Phiên

Pháp bảo đặt xuống đất, chuyển thể từ Tôn Hồn Phiên — Cô Phẩm của Vương Ma Tử trong Tu Tiên 19.7. Mọi nhân vật đều có thể dùng; không cần Tu Tiên gốc hoặc Solo.

- Chế tạo tại **Shadow Manipulator**, mục **Ma thuật / Vũ khí**: 6 Gỗ Sống + 12 Nhiên Liệu Ác Mộng + 2 Ngọc Tím + 6 Trung Phẩm Linh Thạch. Đây là công thức mới của Phàm Nhân Tu Tiên.
- Cầm vật phẩm bằng con trỏ và đặt xuống đất. Nếu hết hồi chiêu, gọi ngay **2 Hồn Vệ**; lượt gọi ban đầu hồi **60 giây**, kiểm tra cả người đặt và bản thân Phiên.
- Thu hồn từ sinh vật đủ điều kiện chết trong bán kính **18 đơn vị game**. Mỗi **2 hồn** gọi thêm 1 Hồn Vệ nếu người đặt còn sống và đứng trong bán kính 16.
- Có **4 lượt gọi bổ sung**, mỗi lượt hồi riêng 60 giây. Khi hết lượt, giữ tối đa 2 hồn chờ; không tích kho hồn vô hạn.
- Hồn Vệ tồn tại **60 giây**, hỗ trợ đánh mục tiêu của chủ hoặc kẻ đang tấn công chủ/Hồn Vệ. Mỗi chuỗi đánh bắn 2 đạn, chu kỳ tấn công 2 giây; sát thương vật lý nền **20 mỗi đạn**, lan bán kính 3. Sát thương thực nhận còn qua cơ chế phòng thủ của game.
- Nền 20 lấy từ `combat.defaultdamage` của bản gốc; bản gốc ghi đè tính sát thương để dùng giá trị này rồi áp hệ tu luyện. Bản độc lập bỏ phần hệ số tu luyện đó, không lấy nhầm con số 33 trên vũ khí nội bộ làm sát thương cuối.
- Chuột phải lên Phiên đã dựng để thu lại. Số hồn tích lũy và các hồi chiêu được giữ khi thu/đặt lại và lưu game. Thu Phiên sẽ giải tán Hồn Vệ của Phiên đó.
- Người đặt chết hoặc rời shard thì Hồn Vệ hiện tại giải tán. Hồn Vệ là thực thể tạm thời, không được khôi phục khi tải lại save, giống nguồn; Phiên, người sở hữu, hồn tích lũy và hồi chiêu được lưu.
- Không đánh chủ/thú của chủ; khi tắt PvP cũng không đánh người chơi khác hoặc đồng hành của họ. Kiểm tra lại mục tiêu lúc đạn trúng.
- Phiên không dùng độ bền. Pháp bảo đặt đất hỗ trợ carrier sát thương Solo tùy chọn từ 0.8.3; không có nâng cấp Ngọc Lấp Lánh riêng.

Prefab: `vanhonphien`; bản dựng: `vanhonphien_ground`; Hồn Vệ: `vanhonphien_soul`.

Lệnh console host để lấy vật phẩm: `c_give("vanhonphien")`.

Kiểm tra bản 0.3.0: compile cú pháp Lua bằng runtime có sẵn, rà module/tài nguyên và kiểm tra gói ZIP. Chưa chạy thử trong game; theo yêu cầu trước đó không viết/chạy test suite hoặc tự mở game.

## Truyền Tống Trận (0.3.1)

- Truyền Tống Trận luôn hoạt động khi bật Phàm Nhân Tu Tiên; không có công tắc bật/tắt riêng.
- Bảng hiệu `homesign` dùng hình cổng gỗ–đá, vòng xoáy tím và nhãn tên. Tùy chọn riêng cho phép áp dụng cả `arrowsign_post`.
- Công thức mỗi cổng: **5 Ván Gỗ + 5 Vàng**, mở khóa tại **Máy Khoa Học**.
- Xây ít nhất hai cổng, viết tên điểm đến và nhấp phải **Chọn điểm đến**. Dịch chuyển trong cùng shard; chưa hỗ trợ từ mặt đất xuống hang.
- Không còn menu config Truyền Tống Trận. Cố định tiêu hao độ no ×1, tinh thần ×1; tắt đếm ngược, tắt dùng biển chỉ đường và tắt giới hạn quyền sở hữu (kể cả kiểm tra Camp Security). Các lựa chọn config cũ của thế giới không còn được đọc.
- **Tắt mod Truyền Tống Trận riêng khi dùng bản tích hợp.** Fast Travel cũng thay hành vi bảng hiệu, nên tắt chức năng/mod đó để tránh hai thao tác dịch chuyển.
- Cổng dùng prefab bảng hiệu gốc nên tên và vị trí bảng hiệu hiện có được giữ.
- Host, client, Master và Caves cần cùng bản Phàm Nhân Tu Tiên và cấu hình do server cung cấp. Namespace cổng giữ `ttt_` / `NYX_TTT`; không cần bật Fast Travel hoặc Truyền Tống Trận riêng.

## Cài đặt

1. Sử dụng thư mục mod `PhamNhanTuTien` có `modinfo.lua` và `modmain.lua` nằm trực tiếp bên trong.
2. Chép cả thư mục `PhamNhanTuTien` vào thư mục `mods` của Don't Starve Together trên máy host và mọi máy client.
3. Bật `Phàm Nhân Tu Tiên` và tắt `Solo Leveling` riêng cho cụm máy chủ. Nếu cụm có hang động, dùng cùng bản mod và cấu hình cho cả shard Master và Caves.
4. Khởi động lại server sau khi mọi máy đã có cùng phiên bản.

Bản hiện tại dùng thư mục `PhamNhanTuTien`. Các gói `TuTienKy_v0.10.0.zip` là bản lịch sử. Mod không tự cài hoặc tự bật trong game.

## Nội dung

| Cấp | Prefab | Cách có / đổi phẩm |
|---|---|---|
| Hạ Phẩm Linh Thạch | `ttk_lingshi1` | Quái thường đủ điều kiện rơi 2–5 viên |
| Trung Phẩm Linh Thạch | `ttk_lingshi2` | 100 Hạ Phẩm → 1 Trung Phẩm |
| Thượng Phẩm Linh Thạch | `ttk_lingshi3` | Boss đủ điều kiện rơi 2–5 viên; 10 Trung Phẩm → 1 Thượng Phẩm |
| Cực Phẩm Linh Thạch | `ttk_lingshi4` | 10 Thượng Phẩm → 1 Cực Phẩm |

Không có công thức tạo Hạ Phẩm từ Vàng hoặc Đá, không có đổi ngược. Công thức chuẩn của game có thể lấy nguyên liệu từ nhiều chồng; mod không vá builder hoặc inventory toàn cục.

Hoàng Hoa Lê Mộc Trác cần:

- 3 Gỗ Sống (`livinglog`)
- 5 Ván Gỗ (`boards`)
- 10 Hạ Phẩm Linh Thạch (`ttk_lingshi1`)
- Trạm khoa học cấp `SCIENCE_ONE`

Bàn có 8 ô, chỉ nhận vật phẩm mang tag `preparedfood`. Món ăn được hiển thị trên mặt bàn khi có recipe/build phù hợp. Món mod thiếu dữ liệu hiển thị vẫn cất và lấy bình thường. Hệ số bảo quản `-0.2` làm đồ ăn hồi độ tươi theo API preserver của game.

Khi chọn công thức Hoàng Hoa Lê Mộc Trác, bảng chi tiết chế tạo của game có bộ chọn gồm mẫu mặc định, **Mẫu HTJC** và **Mẫu WFZ**. Skin đã chọn cũng được dùng cho hình đặt công trình và được lưu cùng công trình theo cơ chế skin chuẩn của DST. Hai skin này được mở miễn phí trong phạm vi Phàm Nhân Tu Tiên; không cần bật mod Skin Đăng Tiên hoặc toàn bộ mod Tu Tiên.

Bàn hỗ trợ nâng cấp rương bằng cơ chế `UPGRADETYPES.CHEST`: sau một lần nâng cấp, mỗi ô có thể giữ chồng không giới hạn. Trạng thái nâng cấp và đồ trong bàn dùng component save/load chuẩn. Khi đập hoặc giải thể bàn có quá nhiều chồng, mod dùng giới hạn và collapsed chest chuẩn để tránh tạo lượng entity quá lớn.

## Nhận diện quái và boss

Phân loại được thực hiện đúng lúc game phát `entity_death` trên server:

- Boss: tag `epic`, tag `boss`, hoặc `hh_tags.boss_monster` / `hh_tags.endgameboss_monster` của Solo Leveling.
- Quái thường: tag `monster`, tag `hostile`, field `hh_is_dungeon_monster == true`, tag `hh_dungeon_mob`, hoặc allowlist vanilla đã xác minh gồm `killerbee` và `mosquito` (hai prefab thù địch này không có tag `monster`/`hostile`).
- Boss được xét trước nên chỉ nhận một lượt 2–5 Thượng Phẩm, không nhận thêm Hạ Phẩm.
- Quái chết do đệ tử, bẫy hoặc sát thương theo thời gian vẫn được tính nếu bản thân quái đủ điều kiện.

Các đối tượng sau bị loại: player, player ghost, FX, công trình, companion, critter, `shadowminion`, `shadow_minion`, follower có leader là player, và các đệ tử Solo `hh_igris_shadow`, `hh_beru_shadow`, `hh_macanh_shadow`, `hh_hacanh_shadow`, `hh_fruitfly_shadow`. `alterguardian_phase1` và `alterguardian_phase2` bị loại vì cái chết của chúng là chuyển phase; phase cuối được xét như boss bình thường.

Mod không dùng ngưỡng máu để đoán boss, không dùng tag `in_solo_dungeon`, không gọi module của Solo và không hứa nhận diện mọi boss từ mod chưa được kiểm tra. Remove/despawn không phát thưởng. Load xác chết bị bỏ qua; nếu thực thể thật sự hồi sinh rồi chết lại, chốt thưởng được mở lại khi health chuyển từ 0 lên trên 0.

## Lục Mạch Thần Kiếm

- Prefab và công thức mới: **`lucmachthankiem`**. Tên hiển thị: **Lục Mạch Thần Kiếm**.
- Cố định **1.000 độ bền**, chế tạo đầy bền, đeo ô **dây chuyền**, tốc độ **×1,15**, sát thương gốc **50**, planar **10**, đánh lan bật. Không còn menu config Thần Kiếm. Nếu thiếu `EQUIPSLOTS.NECK`, dùng ô thân theo cơ chế nguồn.
- Hết độ bền **không biến mất**: kiếm tự tháo và tạm khóa trang bị; nạp lại để dùng tiếp. Dùng vũ khí trong bảng nạp Tinh La Kiếm để nạp (ví dụ Giáo +25, Glass Cutter +100, Khiên Kinh Hoàng +300). Mỗi lần tiêu hao một vật phẩm, lượng nạp không phụ thuộc độ bền vũ khí hiến tế và không vượt 1.000.
- Công thức: **1 Glass Cutter + 6 Ngọc Đỏ**, trạm `MAGIC_THREE` (Shadow Manipulator).
- Khởi đầu 1 kiếm đỏ; lần lượt dùng xanh dương, tím, cam, vàng, xanh lá để lên tối đa 6 kiếm. Mỗi cấp cần 9 viên đúng màu; hệ số sát thương từng cấp là 0,2 / 0,3 / 0,45 / 0,6 / 0,75 / 1.
- **1 Ngọc Lấp Lánh** giữ hiệu ứng cầu vồng, đồng thời nhân đôi sát thương gốc và planar một lần. Ở cấp xanh lá và cấu hình mặc định: **50 + 10 planar → 100 + 20 planar** trước giáp/hệ số khác.
- Giữ nạp bằng ngọc: Ngọc Lấp Lánh sửa 800 độ bền và chỉ nâng cầu vồng một lần. Khi đầy bền, chỉ nhận ngọc nếu còn tác dụng nâng cấp; không tiêu hao vũ khí hoặc ngọc chỉ để sửa khi đã đầy.
- Có nút bật/tắt tự động tấn công và thao tác chỉ định mục tiêu. Các RPC/action, net field, component, prefab và TUNING của kiếm dùng tên riêng `lucmachthankiem`.
- Cường hóa Solo tăng sát thương kiếm bay. Bonus Solo được tính trên nền sau nâng cấp Ngọc Lấp Lánh; planar chỉ nhận hệ số cấp ngọc và bonus ×2 riêng. Solo được nạp cùng Phàm Nhân Tu Tiên.
- Hiệu ứng cầu vồng/cấp ngọc được lưu theo kiếm; cấp cường hóa do Solo quản lý. Không chuyển toàn bộ hiệu ứng phụ/khảm ngọc Solo sang kiếm bay.

**Đây là vật phẩm mới với ID mới.** Kiếm có prefab `terraprisma` trong save cũ không tự chuyển thành `lucmachthankiem`. Bản gộp không đăng ký alias/migration cho ID cũ. Không cần cài bản Terraprisma riêng để chế tạo Lục Mạch Thần Kiếm.

## Phạm vi 0.3.1

Ở bản 0.3.1 chỉ có HTJC và WFZ; từ 0.8.3 đã có đủ 14 skin của nhóm công trình đang dùng. Mod không chép bộ mở khóa skin rộng hay hệ tu luyện. Bản 0.3.1 bổ sung Truyền Tống Trận với giao diện chọn điểm đến và RPC/action riêng, bên cạnh các nội dung hiện có. Bộ chọn skin bàn vẫn dùng giao diện chế tạo chuẩn của DST nên chỉ hiện trong những chế độ mà game cho phép hiển thị skin (online hoặc có hỗ trợ skin offline).

Bản này chưa được chạy trong game theo yêu cầu của người dùng; chưa xác nhận runtime hoặc multiplayer trong game.

Khi không thể tạo đống rương sập hoặc vị trí bàn không hợp lệ, bản này giữ lại bàn và phần đồ còn lại, mỗi lượt chỉ thả lượng đồ có giới hạn. Điều này tránh mất đồ hoặc tạo quá nhiều vật phẩm cùng lúc.


## Chưởng Thiên Bình

- Prefab: `ttk_chuongthienbinh`. Mọi nhân vật đều chế tạo và sử dụng được.
- Công thức tại Prestihatitator (`MAGIC_TWO`): **2 Gỗ Sống + 6 Mảnh Thủy Tinh Mặt Trăng (Moon Shard, `moonglass`) + 3 Ngọc Xanh Dương + 30 Hạ Phẩm Linh Thạch**. Gỗ Sống thay nguyên liệu Kỳ Lân Nhục chưa có trong bản độc lập.
- Giữ hình ảnh và chức năng thúc cây của bình thường Tu Tiên 19.7; tăng sức chứa từ 100 lên **200**, bằng bản Cô Phẩm. Không nhập phạm vi/tập mục tiêu mở rộng của Cô Phẩm.
- Bình mới rỗng. Đặt trên mặt đất ở thế giới mặt đất vào ban đêm để nạp **0,6 linh khí/giây**. Không nạp khi cầm/cất trong túi hoặc ở hang. Đầy sau khoảng **334 giây ban đêm** tích lũy.
- Cầm bình, dùng lên cây nông nghiệp: thúc tối đa **3 cây trong bán kính 4**, tốn **50 linh khí/lần**. Bình đầy dùng 4 lần, cạn không mất vật phẩm. Cây hợp lệ có nhánh tăng trưởng phép giữ cơ hội 25% đặt cờ khổng lồ của nguồn; không bảo đảm mọi cây đều thành khổng lồ.
- Bình giữ lượng linh khí khi lưu/tải. Hệ Ngọc Lộ Tiên Khu và sáu linh thảo chưa được nhập; không thay đổi cơ chế cây Sa Đường hiện có.
- Kiểm thử: `tools/test_chuongthienbinh.py` sử dụng component `finiteuses` thật của DST để kiểm tra nạp/tiêu hao/lưu tải, đồng thời kiểm tra đăng ký công thức, tài nguyên và cú pháp Lua. Chưa thử thao tác và hình ảnh trong game.


## Thiên Cơ Ốc, Quyển Trục và Lệnh Bài

- **Thiên Cơ Quyển Trục** (`ttk_tianji_juanzhou`): chế tạo tại Shadow Manipulator (`MAGIC_THREE`) bằng **7 Giấy Cói + 15 Đá Cẩm Thạch + 6 Gỗ Sống + 45 Hạ Phẩm Linh Thạch**. Mọi nhân vật dùng được.
- Đặt Quyển Trục trên đất liền để dựng **Thiên Cơ Ốc** (`ttk_tianjiwu`), đồng thời nhận **Lệnh Bài Thiên Cơ Ốc** (`ttk_tianji_lingpai`). Chuột phải vào nhà để vào; dùng cửa bên trong để ra. Hồn ma cũng dùng cửa được.
- Phòng riêng theo tài khoản người dựng trong từng shard, giữ bố trí sàn/tường/cửa gốc. Nhiều cửa của cùng một chủ trỏ tới cùng phòng. Có thể đặt rương và công trình trong vùng sàn; đồ đạc được lưu như thực thể bình thường của thế giới.
- Chủ nhà đưa Lệnh Bài cho nhà để thu hồi thành Quyển Trục. Chỉ thu hồi cửa ngoài; phòng và đồ đạc vẫn nguyên. Lệnh Bài bị tiêu hao khi thu hồi thành công, dựng lại nhận Lệnh Bài mới.
- Mất Lệnh Bài: chế tạo lại bằng **1 Giấy Cói + 1 Hạ Phẩm Linh Thạch**, không cần trạm. Lệnh Bài chỉ thu hồi nhà của mình.
- Quyển Trục đã sử dụng giữ chủ và shard ban đầu; chỉ chủ đó được dựng lại trên đúng shard. Nhà chưa hỗ trợ chuyển cả phòng từ mặt đất sang hang hoặc ngược lại.
- Nếu cửa bị thu hồi khi có người bên trong, người đó vẫn dùng được cửa ra để trở về điểm trước khi vào. Điểm cũ không an toàn sẽ tìm đất gần đó, rồi tìm cổng hồi sinh; nếu không có điểm hợp lệ thì từ chối dịch chuyển.
- Giữ camera phòng cố định, chiếu sáng, nhiệt độ 32 và chống mưa cho người bên trong; mang theo thú đi theo người/vật phẩm. Không nhập skin đặc quyền, hệ tài khoản ngoài hoặc hệ tu luyện của mod nguồn.

- Kiểm chứng Thiên Cơ Ốc: kiểm thử Lua và kiểm tra tài nguyên đạt. Server DST thử nghiệm riêng đã tạo phòng, lưu thế giới rồi khởi động lại; rương và vàng trong phòng vẫn còn. Chưa kiểm tra hình ảnh/camera trên client và thao tác multiplayer trực tiếp. Lần chạy toàn bộ mod bị chặn bởi tài nguyên món ăn không liên quan; kiểm thử server dùng riêng bộ nhà và linh thạch.


## Đợt 18 công trình bổ sung

Đã loại Tinh Thối Đan Phủ theo yêu cầu; không nhập Đan Lô hoặc hệ đan dược để phục vụ món đó. Giữ nguyên các loại trừ trước: Thiên Cơ Ốc Dị Hóa, Kim Ô Đằng Thải Đăng, Liên Diệp Đồng, ba mỏ Linh Thạch và Sa Đường.

Phạm vi: Ngọc Lộ Huyền Thương, Ngọc Lộ Tiên Khu, Quỳnh Lâu Kim Khuyết, Sào Huyệt Gấu Lưng Thiết Giáp, Sào Huyệt Long Đằng, Sào Huyệt Ma Thù, Sơ Quả Thương, Thanh Khâu Phường, Thiên Cơ Ốc, Thiên Vị Thực Khám, Thủy Phù Dung, Thừa Vận Tọa, Triều Dương Hoa, Trữ Nhục Thương, U Lan, Vân Yên Hương Liệu Trạm, Vô Song Kiếm Hạp và Yên Liễu Thụ.

- Công trình được chuyển cùng thú/brain/stategraph, linh thảo/hạt/cây, nguyên liệu và hiệu ứng liên quan. Đầu ra đã có trong DST dùng prefab chuẩn.
- Quỳnh Lâu Kim Khuyết giữ bán kính sáng 6 như nguồn.
- Hạt linh thảo ban đầu có công thức tại Máy Luyện Kim; Ngọc Lộ Tiên Khu dùng Hạ Phẩm Linh Thạch để nạp linh khí. Không yêu cầu nhân vật hay pháp bảo chưa nhập.
- Trạm gia vị xử lý nguyên liệu theo chồng, giữ phần dư và số lượng mẻ qua lưu/tải. Bốn gia vị chuẩn có công thức riêng tại Máy Khoa Học.
- Kho tự nhặt vũ khí bỏ qua đồ khóa chủ bằng Solo; các hook mới chỉ áp dụng cho prefab/action/cooker của Phàm Nhân Tu Tiên. Không import Solo.
- Skin nhập cho đúng vật phẩm đã chuyển: tổng cộng **179 skin** đã đối chiếu giữa manifest và bảng Lua, gồm Cổ Trận vốn đã có, các mẫu công trình, trang bị và các mẫu vũ khí dùng chung có bằng chứng alias từ nguồn. Skin BYJ của Thiên Cơ Ốc nối với hệ phòng hiện có, không đăng ký thêm bản nhà trùng tên. Nhà được dựng bằng Quyển Trục; dùng Chổi Sạch để đổi ngoại hình.
- Chi tiết cơ chế, đầu ra và các điều chỉnh để dùng độc lập: `BATCH19_MISC_VI.md`, `BATCH19_HERBS_VI.md`, `BATCH19_HOUSES_VI.md`. Dữ liệu web ở `/tu-tien-ky` có liên kết tới sản vật và vật phẩm liên quan.

Đối chiếu mã/API và kiểm tra cú pháp không thay thế chơi thử multiplayer với Solo. Báo cáo đợt này ghi riêng phạm vi kiểm tra, không coi kết quả runtime của tác vụ khác là kiểm chứng toàn bộ 18 món.
# Bộ giáp Tử Xá và áo Vân Mạc

Đã thêm Tử Xá Diện Giáp, Tà Sát Hộ Giáp và Vân Mạc Thượng Trang. Tử Xá Diện Giáp và Tà Sát Hộ Giáp cần học bản vẽ; Vân Mạc Thượng Trang vẫn mở sẵn. Áo phát sáng bán kính 5, giữ màu và cường độ mũ thợ mỏ. Công thức, chỉ số và cách sửa: [ARMOR_SET_VI.md](ARMOR_SET_VI.md).

## Skin Cổ Trận cho Truyền Tống Trận

Trong công thức **Truyền Tống Trận** (bảng hiệu `homesign`), chọn skin **Cổ Trận** trước khi đặt công trình. Dùng Chổi Sạch để đổi mẫu của cổng đã xây. Skin dùng hình ảnh và animation `xd_gcsz`, phát sáng khi người chơi đến gần; mẫu mặc định vẫn là cổng tím. Tên điểm đến, dịch chuyển và công thức **5 Ván Gỗ + 5 Vàng** giữ nguyên. Khi cháy, cả hai mẫu dùng hình cổng cháy mặc định. Skin này áp dụng cho cổng `homesign`, không thêm mẫu riêng cho biển chỉ đường. Host và các client cần cùng bản mod; bộ chọn skin tuân theo chế độ online/offline của hệ skin hiện có.


## Lục Nguyên Kiếm Đồng

- Prefab `ttk_lucnguyenkiemdong`; dùng hình ống bắn Huyền Vũ Xuy Tiễn của Tu Tiên 19.7. Mọi nhân vật đều chế tạo và sử dụng được.
- Sát thương nền **50**, tầm bắn **8**, không cần vật phẩm đạn. Chế tại Máy Luyện Kim bằng **1 thanh mỗi loại: Vô Tướng, Thanh Trúc Phong Vân, Tinh La, Phần Thiên, Tiên Kiếm và Ma Kiếm**. Sáu thanh bị tiêu thụ khi ghép.
- Tối đa **1.000 lượt bắn**, chế tạo đầy lượt; mỗi phát tốn 1 lượt. Hết lượt giữ lại vũ khí nhưng không bắn được. Đưa **1 Hạ Phẩm Linh Thạch** hồi **100 lượt**, tối đa 1.000; đầy thì từ chối nhận.
- Khi phát bắn trúng gây sát thương và crit thật qua Solo, gọi ngẫu nhiên **1–6 phi kiếm khác nhau**. Từng kiếm bốc riêng **10–20% sát thương nền của phát bắn trước crit**, có tính cường hóa vũ khí. Không lấy số damage đã nhân crit làm gốc.
- Kiếm xuất phát quanh người chơi lúc kích hoạt, tỏa hai bên rồi uốn về mục tiêu đang di chuyển. Mỗi kiếm chỉ đánh một lần rồi tan; không crit tiếp, không gọi thêm loạt kiếm và không hao thêm độ bền. Mục tiêu hoặc chủ không còn hợp lệ thì kiếm được dọn.
- Hiệu ứng khi kiếm khí trúng: **Kim** thêm 10 sát thương planar; **Mộc** hồi 2 máu; **Thủy** có 20% cơ hội làm chậm di chuyển 25% trong 2 giây; **Hỏa** nổ bán kính 2 lên địch khác, gây 50% sát thương kiếm khí; **Thổ** cho lá chắn hấp thụ 10 sát thương trong 3 giây; **Lôi** nảy sang một địch khác với 50% sát thương kiếm khí. Hỏa không gây cháy và không đánh thêm mục tiêu chính.
- Mộc và Thổ có hồi chiêu **riêng 3 giây theo người bắn**. Làm chậm và lá chắn không cộng dồn; lá chắn yếu hơn không hạ sức chắn đang mạnh hơn. Sát thương phụ không kích hoạt thêm nội tại.
- Solo được tích hợp mặc định: crit của vũ khí dùng hệ thống Solo, không tự cộng tỷ lệ crit riêng.
- Bộ kiếm và hiệu ứng nguyên tố đã qua kiểm thử Lua, hồi quy Solo và máy chủ DST offline. Báo cáo: `docs/superpowers/reports/2026-09-20-luc-nguyen-elements.md` ở gốc workspace. Chưa xác nhận hình ảnh bằng máy khách đồ họa.

## Bộ sáu kiếm nguyên tố

Mọi kiếm đều chế tại Máy Luyện Kim, dùng được bởi mọi nhân vật. Mỗi công thức dưới đây cần thêm **1 Trung Phẩm Linh Thạch**.

| Kiếm | Nguyên liệu khác | Nội tại khi cầm đánh |
|---|---|---|
| Vô Tướng (`ttk_votuongkiem`) | 12 Vàng + 6 Đá Lửa | Mỗi đòn thêm 10 sát thương planar. |
| Thanh Trúc Phong Vân (`ttk_thanhtrucphongvankiem`) | 6 Gỗ Sống + 12 Cành Cây | Mỗi đòn thứ tư gọi một phi kiếm gây 40% sát thương nền. |
| Tinh La (`ttk_tinhlakiem`) | 3 Ngọc Xanh Dương + 6 Vàng | 20% cơ hội làm chậm di chuyển 25% trong 3 giây. |
| Phần Thiên (`ttk_phanthienkiem`) | 3 Ngọc Đỏ + 6 Than | 15% cơ hội nổ bán kính 3, gây 30% sát thương nền; không gây cháy. |
| Tiên Kiếm (`ttk_tienkiem`) | 6 Thulecite + 12 Đá | Mỗi đòn thứ năm nhận lá chắn 30 sát thương trong 5 giây. |
| Ma Kiếm (`ttk_makiem`) | 3 Ngọc Tím + 6 Nhiên Liệu Ác Mộng | 20% cơ hội phóng điện sang tối đa hai địch khác, mỗi con nhận 35% sát thương nền. |

Sát thương nền của cả sáu là **100**, tầm đánh **2**. Sát thương phụ tính theo nền vũ khí sau cường hóa, không crit và không sinh thêm nội tại. Bộ hiệu ứng này được thiết kế lại cho Phàm Nhân Tu Tiên; không nhập kỹ năng biến hình, tu luyện hoặc khóa nhân vật của mod nguồn. Hiệu ứng trên kiếm cầm tay và kiếm khí của súng có thông số riêng như hai mục trên.

Năm kiếm mới có **1.000 lượt**, chế tạo đầy lượt và vỡ khi hết; có thể nạp bằng vũ khí khác trước khi vỡ theo cùng bảng nạp của Tinh La. Tinh La giữ cơ chế riêng đã có: bắt đầu 300/1.000 lượt và giữ lại khi cạn. Xem bảng nạp ở mục Tinh La Kiếm.

## Cường hóa trang bị

Phàm Nhân chỉ giữ cường hóa tối đa +13. Đã gỡ nhánh Phụ Ma khỏi component, RPC, giao diện và cuộn nâng cấp. Save cũ có trạng thái nâng cấp khác được chuyển sang cường hóa cùng cấp (tối đa +13), tính lại sát thương theo cường hóa. Đá Tím vẫn là nguyên liệu game, không dùng tại Lò Rèn. Giữ khóa save/RPC/prefab để tương thích.

Cường hóa lên +n tốn n Đá Cường Hóa, xác suất cơ bản 1,1 × 0,85^n. Các mốc thất bại và cơ chế hai bùa bảo vệ được giữ nguyên. Thử nâng đồ đã +13 không tiêu hao đá.

## Thiết lập Solo cố định và popup trắng–tím

- Ẩn tooltip gốc, giữ đầy đủ thông tin popup Solo. Nền tím than gần kín, chữ trắng/pastel sáng, nhãn tím nhạt, viền tím và góc trắng; màu chữ phân loại và cầu vồng được nâng độ sáng để dễ đọc. Màu nền/viền lưu từ giao diện cũ không ghi đè bộ màu mới.
- Hỗ trợ trang bị luôn bật theo bộ lọc nguồn: có equippable, inspectable, inventoryitem; không stackable và không mang tag hh_limit. Thông báo sự kiện luôn bật.
- Gỡ kỹ năng Dịch Chuyển Solo (Blink), hotkey, RPC, hồi chiêu và hướng dẫn riêng. Hoán Đổi, Truyền Tống Trận và các pháp bảo dịch chuyển vẫn giữ nguyên. Save cũ có trường hồi chiêu Blink được bỏ qua khi nạp.
- Giữ config giới hạn tăng máu quái để chờ lựa chọn: mỗi con lấy một hệ số HP/ngày (thường 1–5, tinh anh 10–20, boss 50–100, endgame 0). Máu tối đa = (máu nền + buff cộng thẳng + hệ số ngày × min(cycles, 1000)) × (1 + buff % / 100). cycles là số ngày thế giới đã trôi qua, không phải tuổi riêng của quái. Ở độ khó 3 hiện tại, cả hai lựa chọn giới hạn đều dùng mốc 1000.
