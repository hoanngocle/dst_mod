# Phàm Nhân Tu Tiên 2.0 — Chiến lợi phẩm boss

## Phần thưởng đã chốt

| Nhóm | Phần thưởng mỗi lần chết cuối cùng |
|---|---|
| Sáu boss đánh lại được | 1 `ttk_boss_core_<khóa>` + 1 `ttk_summon_<khóa>` + 2–5 `ttk_lingshi3` |
| Ba boss duy nhất | 10 `ttk_lingshi4`, 100 `ttk_lingshi3`, 10 mỗi loại redgem/bluegem/purplegem, 5 mỗi loại yellowgem/orangegem/greengem |

Khóa sáu boss: `baihu`, `jfsn`, `qlch`, `spiderqueen`, `stalke_fuben`, `deerclops_ziyun`. Ba boss duy nhất: `qxdx`, `futu`, `ziyunboss`.

Phần thưởng trên do sổ boss quản lý và chỉ phát một lần cho cái chết cuối cùng của cá thể chính. Quái phụ/phân thân/chuyển pha không phát bộ phần thưởng này. Hệ thống linh thạch chung bỏ qua boss được quản lý để không trả thưởng trùng.

## Công dụng vật phẩm

Sáu linh vật có công dụng ăn tăng chỉ số đã chốt trong [BOSSES_VI.md](BOSSES_VI.md). Vật phẩm triệu hồi dùng trực tiếp, không dùng linh vật làm nguyên liệu chế tạo.

Các vật phẩm đang dùng gồm linh vật tăng chỉ số, vật phẩm triệu hồi, nguyên liệu chế giáp, ba lô và hạt giống. Da Bạch Hổ, Phượng Tủy Cổ, Kỳ Lân Nhục và mười Đan Dược Cổ đã bị loại khỏi đăng ký prefab; không còn hỗ trợ tải các món này từ save cũ. Giữ các tài nguyên hình ảnh dùng chung với vật phẩm hiện hành.

## Đối chiếu chiến lợi phẩm nguồn

Các nguyên liệu DST dưới đây cộng thêm vào phần thưởng chính ở trên, tại cái chết cuối cùng. Các cặp linh vật + vật phẩm triệu hồi được liệt kê để rõ tên chính là phần thưởng chính, không cộng thêm lần nữa. “Chắc chắn” nghĩa là 100%. Ngọc, vàng, đá, thịt, tơ và tim bóng tối giữ công dụng DST hiện có.

### Tàn Khu Bạch Hổ — đánh lại được

- Chắc chắn **1 Bạch Hổ Huyết Tủy** (`ttk_boss_core_baihu`, ăn tăng chỉ số) + **1 Bạch Hổ Tàn Hồn** (`ttk_summon_baihu`, dùng triệu hồi). Bỏ 2 Da Bạch Hổ cũ khỏi bảng rơi.
- Chắc chắn 3 ngọc lục, 4 ngọc cam, 4 ngọc vàng, 3 ngọc đỏ và 15 vàng.

### Kim Phượng Thần Niệm — đánh lại được

- Chắc chắn **1 Kim Phượng Tinh Huyết** (`ttk_boss_core_jfsn`, ăn tăng chỉ số) + **1 Kim Phượng Tàn Hồn** (`ttk_summon_jfsn`, dùng triệu hồi). Bỏ 2 Phượng Tủy Cổ cũ khỏi bảng rơi; Tinh Huyết dùng icon Phượng Tủy nguồn `xd_fs`.
- Chắc chắn 2 mỗi loại ngọc lục/cam/vàng/tím và 9 vàng.

### Kỳ Lân Tàn Hồn — đánh lại được

- Chắc chắn **1 Kỳ Lân Linh Đan** (`ttk_boss_core_qlch`, ăn tăng chỉ số) + **1 Kỳ Lân Tàn Hồn** (`ttk_summon_qlch`, dùng triệu hồi). Bỏ 2 Kỳ Lân Nhục cũ khỏi bảng rơi.
- Chắc chắn 2 mỗi loại ngọc lục/cam/vàng và 5 vàng. Phân thân không phát phần thưởng chính.

### Thanh Tụ Đan Tiên — duy nhất

- Chắc chắn 2 `xd_npxsz` → `ttk_npxsz`: dùng prefab nguyên liệu đã tích hợp, không tạo bản sao hệ công dụng.
- Chắc chắn rơi 1 `xd_back_xh` → `ttk_boss_back_xh` (**Ba Lô Tiên Hà**): túi đeo **18 ô, 3 cột × 6 hàng**, dùng ô ba lô riêng. Không có chức năng giáp, bảo quản hay tăng tốc. Không xếp chồng hoặc nhét vào túi/rương khác. Tên cũ “Tiên Hà Bảo Giáp” được sửa lại cho đúng chức năng.
- Ba Lô Tiên Hà dùng ID cũ nên đồ đã rơi trước khi cập nhật trở thành túi dùng được. Nếu save cũ có nhiều món trong một chồng, các túi dư được tách và đặt cạnh người/vật đang giữ sau khi tải save. Đồ trong 18 ô được lưu bằng container chuẩn của DST.
- Chắc chắn 5 ngọc đỏ và 2 mỗi loại ngọc lục/cam/vàng.
- **Bỏ hoàn toàn hai lượt rơi đan cổ ngẫu nhiên và mười prefab Đan Dược Cổ.**
- Chắc chắn **2 Hạt Tử Chi** (`ttk_boss_zcyseed`, nguồn `xd_zcyseed`) và **3 hạt mỗi loại**: `ttk_lc_hsc_seed`, `ttk_lc_dms_seed`, `ttk_lc_qfx_seed`, `ttk_lc_cyh_seed`, `ttk_lc_lmg_seed`, `ttk_lc_yhh_seed`. Tổng **20 hạt**, không chọn ngẫu nhiên.
- Hạt Tử Chi trồng trực tiếp xuống đất: 50% cây xanh, 50% cây tím. Ăn hồi 5 máu, 12 no, 2 tinh thần; có hạn sử dụng theo hạt nguồn. Sáu hạt linh thảo vẫn gieo trong Ngọc Lộ Tiên Khu. Chi tiết thời gian lớn và thu hoạch: [SEED_TREE_VI.md](SEED_TREE_VI.md).

### Ma Tướng Phù Đồ — duy nhất

- Chắc chắn 1 bản vẽ Tà Sát Hộ Giáp (`ttk_xshj_blueprint`).
- Chắc chắn 1 `xd_mgqg` → `ttk_boss_mgqg` (Ma Cốt): nguyên liệu chế tạo Tà Sát Hộ Giáp sau khi học bản vẽ.
- Chắc chắn 5 ngọc lục, 2 ngọc cam, 2 ngọc vàng, 3 ngọc tím và 25 đá.

### Tà Sát Thù Vương — đánh lại được

- Bộ thưởng chính: **1 Ma Thù Nội Đan** (`ttk_boss_core_spiderqueen`) + **1 Huyết Ngọc Tri Thù Noãn** (`ttk_summon_spiderqueen`, icon nguồn `xd_htz_xyzzl`).

- Chắc chắn 2 `xd_spider_leg` → `ttk_spider_leg`: dùng prefab nguyên liệu đã có.
- Chắc chắn 8 thịt quái, 6 tơ, 3 mỗi loại ngọc lục/cam/vàng và 5 ngọc tím.

### Tử Vân Ma Quân — duy nhất

- Chắc chắn 1 bản vẽ Tử Xá Diện Giáp (`ttk_zcmj_blueprint`) ở cái chết cuối cùng.
- Chắc chắn 1 `xd_zcmy` → `ttk_boss_zcmy` (Tử Thần Ma Ngọc): nguyên liệu chế tạo Tử Xá Diện Giáp sau khi học bản vẽ.
- Chắc chắn 1 tim bóng tối, 3 ngọc tím, 4 ngọc vàng, 4 ngọc cam và 3 ngọc lục.
- Pha hồi sinh và Hươu Một Mắt phụ trợ trong trận không trả bộ thưởng của boss chính.

### Thượng Cổ Hắc Ám — đánh lại được

Bản thực thể phó bản nguồn không có bảng chiến lợi phẩm độc lập ngoài linh thạch nguồn. Bản Phàm Nhân dùng bộ thưởng chính gồm **1 Hắc Ám Hồn Tinh** (`ttk_boss_core_stalke_fuben`), **1 Tâm Nhĩ Hắc Ám** (`ttk_summon_stalke_fuben`) và 2–5 Thượng Phẩm Linh Thạch; không tự đặt thêm nguyên liệu nguồn.

### Hồn Phách Tinh Thể Hươu Một Mắt — đánh lại được

Thực thể nguồn là quái phụ của Tử Vân, không có bộ chiến lợi phẩm chính riêng. Cá thể độc lập trong Phàm Nhân nhận bộ **1 Băng Phách Tinh Tủy** (`ttk_boss_core_deerclops_ziyun`), **1 Độc Nhãn Tàn Hồn** (`ttk_summon_deerclops_ziyun`) và 2–5 Thượng Phẩm Linh Thạch. Bản phụ trợ `ttk_boss_deerclops_ziyun_aux` không nhận bộ này.

## Khác biệt có chủ ý so với nguồn

- Linh thạch nguồn được gộp vào luật thưởng chính để tránh cộng trùng.
- Các vật phẩm cũ không có công dụng đã được loại bỏ theo yêu cầu.
- Sổ boss chỉ quản lý cá thể chính. Thanh Tụ Đan Tiên khi thoát giao tranh trở về pha đầu trên cùng thực thể, thay vì chuyển thành NPC khác và làm mất liên kết.
- Combat adapter dùng mức thế giới nguồn mặc định 0 khi không có hệ tu luyện nguồn; không ghi đè hệ Solo đã tích hợp.

Đối chiếu kỹ thuật: `scripts/ttk_boss_collectible_defs.lua`, các bảng loot trong chín prefab chính và `scripts/ttk_boss_lifecycle.lua`. Ba prefab cũ `ttk_boss_baihu_skin`, `ttk_boss_fs`, `ttk_boss_qlr` và mười prefab `ttk_boss_dy_*` đã bị loại bỏ, không chuyển thành vật phẩm tăng chỉ số. Cả 12 linh vật/vật phẩm triệu hồi hiện hành có icon và hình trên đất tương ứng; nguồn/prompt và lệnh biên dịch ở `assets/source/boss_relics/README.md`.
