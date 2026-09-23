# Audit Tế Đàn — Phàm Nhân Tu Tiên 2.0

## Phạm vi đã chuyển

Tế Đàn chuyển cơ chế dâng lễ, thử luyện boss và rương thưởng riêng từ Tu Tiên 19.7, nhưng dùng prefab và lifecycle hiện hành của DST/Phàm Nhân. Không chuyển hai boss riêng Tu Tiên, tai họa bàn thờ, hazard môi trường hoặc các biến toàn cục `XD_*` của nguồn.

Catalog hiện có 51 encounter:

- 37 encounter DST gốc, gồm boss đất, boss biển, nhóm nhiều mục tiêu, Celestial Champion ba phase, Twins và hai dạng lunar-rift.
- 1 encounter Shadow Thralls được giữ từ pool cũ.
- 6 boss trực tiếp có nguồn gốc Solo đã tích hợp.
- 7 biến thể Super Treasure, khởi tạo qua component `hh_monster:SetTreasureId` sẵn có.

Solo đã nằm trong Phàm Nhân 2.0. 13 encounter có nguồn gốc Solo mặc định tham gia Tế Đàn; đã bỏ tùy chọn bật/tắt riêng theo yêu cầu người dùng. Availability được đọc sau khi bootstrap tích hợp hoàn tất, đồng thời kiểm tra prefab, prefab phụ, địa hình, số vị trí tạo và mùa trước khi nhận lễ vật. Deerclops/Mutated Deerclops chỉ tạo vào mùa đông theo gate gốc; Moose/Goose chỉ tạo vào mùa xuân và không tạo trong hang.

Danh mục, adapter và nguồn dòng cụ thể được lưu tại `docs/superpowers/reports/2026-09-20-pham-nhan-te-dan-boss-catalog.md` ở workspace. Báo cáo provenance tài nguyên/nguồn ban đầu nằm tại `docs/superpowers/reports/2026-09-19-tu-tien-ky-te-dan-source.md`.

## Lifecycle và quyền sở hữu

- Mỗi lượt có namespace bền vững gồm định danh Tế Đàn và bộ đếm tăng dần. Boss, manager, minion, bẫy và thực thể phụ được đánh dấu theo đúng lượt; cleanup không quét bán kính.
- Celestial Champion chuyển phase bằng wrapper trên chính instance thuộc lượt. Phase 3 giữ timeline rơi đồ nhưng không phát tiến trình thế giới `moonboss_defeated` hoặc tạo dead-orb endgame.
- Klaus tạo và theo dõi hai deer, chỉ hoàn tất sau death cuối khi đã unchained. Minotaur DST vô hiệu hóa riêng construction callback của instance thử luyện để không bị thay thành boss Solo giữa trận.
- Antlion kích hoạt `StartCombat` với cửa sổ `persists` đồng bộ rồi quay lại nonpersistent. Daywalker/Sharkboi dùng defeat API thật. Twins giữ manager tới hết dispatch death cuối để shield/sketch được gắn vào loot thật.
- `CaptureOwned` theo các field/component nguồn cho Worm, Crab King, Moose, Toadstool, Celestial Champion, commander/leader/childspawner. Thắng chỉ dọn auxiliary; thua/hủy/xóa Tế Đàn dọn toàn bộ thực thể còn sống thuộc lượt bằng `Remove`, không phát `death`/`killed` giả.
- Boss thử luyện nonpersistent. Lượt đang chạy khi load lại trở về idle; reward đã settle vẫn tồn tại. Settlement có latch trước mọi callback/remove để không phát thưởng hoặc hoàn lễ hai lần.

## Thưởng và rương riêng

Nguồn thực hiện 2–3 lượt `GenerateLoot`, mỗi lượt chọn một món từ danh sách sinh ra. Port giữ thuật toán đó bằng snapshot tĩnh của 34 shared loot table từ DST build 747465; bảng động không đủ bằng chứng không bị đoán. Loot chết tự nhiên của boss vẫn chạy độc lập. Hook rơi linh thạch chung bỏ qua boss Tế Đàn để tránh trả hai lần.

Mỗi reward được snapshot bằng save record trước khi claim, nên stack, durability và cường hóa giữ nguyên. Queue chống lặp theo run id. `Container:GiveItem(..., false)` giữ chính xác remainder nếu chỉ ghép được một phần stack và không làm rơi đồ ra đất.

Một `ttk_llbx` vật lý định tuyến tới container 36 ô ẩn riêng cho từng `userid`. Facade từ chối chèn item; private container kiểm quyền ngay tại `Container:Open`, có `NOCLICK`, và không chia sẻ slot. Hammer bị khóa khi còn item/pending. Khi rương mất, queue và item private được chuyển đúng một lần sang authority Tế Đàn còn sống; mở rương xây lại gần đó tự flush backup, không cần dâng lễ mới.

## Bằng chứng tự động

Các suite mục tiêu đạt bằng Python bundled/Lua 5.1:

- `tools/test_jitan.py`
- `tools/test_jitan_bosses.py`
- `tools/test_jitan_catalog.py`
- `tools/test_jitan_rewards.py`
- `tools/test_jitan_save.py`
- `tools/test_jitan_solo.py`

Smoke dedicated-server thực trên cluster riêng:

- Cấu hình mặc định: 51/51 encounter PASS sau 0,5 giây khởi tạo, mỗi required entity có health/combat thật; seasonal encounter được chạy lại đúng mùa. Phase chain, Twins final loot và rương hai người đều PASS; không có `LUA ERROR`/stack traceback.
- Bằng chứng lịch sử trước khi bỏ công tắc Solo: 38 encounter DST/legacy PASS và 13 encounter Solo bị loại khi tắt. Cấu hình này không còn trong bản hiện tại.
- Cấu hình HUD tích hợp tắt (`ttk_hud_enabled=false`) boot và shutdown sạch. Hai cluster save thử cũ (`ttk`, `migrated`) cũng boot bằng Phàm Nhân 2.0; đây là kiểm tra load/upgrade, không phải lặp lại smoke 51 encounter.
- Test hồi quy Solo liên quan: damage binding, Vạn Hồn Phiên, Lục Nguyên và armor đều đạt. Toàn bộ 460 file Lua trong stage compile bằng Lua 5.1 theo kiểm tra độc lập của parent.

Hai failure nền không thuộc Tế Đàn vẫn được giữ nguyên để không sửa ngoài scope: audit registration tĩnh hiểu sai 6 chuỗi trong mã Solo obfuscated và còn 1 `require` thật bị thiếu trong `hh_igris_brain` legacy không được dùng; suite integration đạt 6/7, chỉ lệch checksum lịch sử của `anim/lo_ren.zip` vì asset Phàm Nhân hiện tại đã thay đổi.

## Chưa được chứng minh

Smoke không chơi trọn 51 trận đến chết, không đo toàn bộ bảng loot động và không thay cho cân bằng combat dài hạn. Chưa mở client đồ họa để kiểm animation, widget 36 ô, thao tác Trader/Hammer, HUD scale hoặc đồng bộ host-client nhiều người. Trước phát hành nên playtest ít nhất một trận mỗi họ lifecycle lớn (phase chain, defeat, ocean, Twins, Solo corpse), nhận rương bằng hai client thật, lưu/tải giữa trận và phá/xây lại rương.
