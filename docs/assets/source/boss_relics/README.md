# Phàm Nhân Tu Tiên 2.0 — hình linh vật và Tàn Hồn

Ngày 2026-09-20. Bốn PNG trong `assets/source/boss_relics/` được tạo bằng công cụ ImageGen tích hợp của Codex, không dùng CLI/API fallback. Giữ nguyên PNG nền trong suốt; Klei TextureConverter chỉ đổi kích thước/định dạng. Các file `*.preview.png` là bản giải mã texture để kiểm tra, không phải asset runtime.

| Prefab giữ nguyên | Tên hiển thị | Nguồn hình |
|---|---|---|
| ttk_boss_core_baihu | Bạch Hổ Huyết Tủy | PNG mới: tinh thể đỏ bọc nanh trắng vằn hổ |
| ttk_boss_core_jfsn | Kim Phượng Tinh Huyết | `images/inventoryimages/xd_fs.tex`, Phượng Tủy từ Tu Tiên gốc |
| ttk_boss_core_qlch | Kỳ Lân Linh Đan | `images/inventoryimages/xd_dy_lmsqd_5.tex`, đan dược xanh từ Tu Tiên gốc |
| ttk_summon_baihu | Bạch Hổ Tàn Hồn | PNG mới: hổ trắng linh hồn nhỏ |
| ttk_summon_jfsn | Kim Phượng Tàn Hồn | PNG mới: phượng vàng linh hồn nhỏ |
| ttk_summon_qlch | Kỳ Lân Tàn Hồn | PNG mới: kỳ lân xanh linh hồn nhỏ |
| ttk_boss_core_stalke_fuben | Hắc Ám Hồn Tinh | `images/dyc_gem_purple`, tinh thạch tối từ phần Solo đã tích hợp |
| ttk_summon_stalke_fuben | Tâm Nhĩ Hắc Ám | `shadowheart`, Tim Bóng Tối DST, atlas tra bằng GetInventoryItemAtlas |
| ttk_boss_core_deerclops_ziyun | Băng Phách Tinh Tủy | `xd_hxyp`, mảnh băng xanh từ Tu Tiên gốc |
| ttk_summon_deerclops_ziyun | Độc Nhãn Tàn Hồn | `xd_sudaji_soul`, icon linh hồn từ Tu Tiên gốc |
| ttk_boss_core_spiderqueen | Ma Thù Nội Đan | `xd_dy_xynyd_5`, đan dược đỏ từ Tu Tiên gốc |
| ttk_summon_spiderqueen | Huyết Ngọc Tri Thù Noãn | `xd_htz_xyzzl`, đúng icon người dùng chỉ định |

Ba cặp bổ sung chỉ tái sử dụng asset có sẵn, không tạo hình bằng AI. Prefab triệu hồi nhện giữ ID `ttk_summon_spiderqueen`; `xd_htz_xyzzl` là nguồn hình, không nhập cơ chế nuôi nhện của mod nguồn. Tâm Nhĩ chỉ mượn hình Tim Bóng Tối, không mang tag hoặc chức năng socket của vật phẩm DST.

Biên dịch từ thư mục dự án: `python mods/PhamNhanTuTien/tools/build_boss_relic_assets.py`.
Đầu ra: 11 cặp TEX/XML trong `images/inventoryimages` và 11 gói ANIM trong `anim`, cùng tên prefab. Vật phẩm thứ 12, Tâm Nhĩ Hắc Ám, dùng trực tiếp atlas và animation Tim Bóng Tối của DST. Hình trên đất là sprite tĩnh, mỗi Tàn Hồn rộng 48 đơn vị; món ăn rộng 36 đơn vị. Icon mới 128px, icon tái sử dụng giữ nguyên 64px nguồn. Cả sáu vật phẩm triệu hồi đều không còn dùng hình cuộn phù.

## Prompt nguyên văn

### ttk_boss_core_baihu.png

Create one game inventory icon on a genuinely transparent background, square composition, no text. Bạch Hổ Huyết Tủy: a small crimson blood marrow crystal with ivory white tiger fang-shaped casing and two black tiger stripes, rich red inner glow, hand-painted dark fantasy survival game item, strong dark ink outline, readable at 64 pixels, centered single item occupies 75 percent of canvas. No frame, no ground, no cast shadow, no other objects. Deliver transparent PNG.

### ttk_summon_baihu.png

One transparent PNG game inventory icon: Bạch Hổ Tàn Hồn, a miniature spectral white tiger boss, full body three-quarter pose crouching proudly, white fur with black stripes, large fierce head, icy pale blue spiritual flame curling below paws and tail. Hand painted 2D dark fantasy survival game aesthetic, chunky dark ink outline and simplified forms legible at 64px. Square canvas, centered single creature occupies 80 percent with safe transparent margins. True alpha transparent background, no scenery, no text, no frame, no realistic photograph.

### ttk_summon_jfsn.png

One game inventory icon on true transparent alpha background: Kim Phượng Tàn Hồn, miniature golden phoenix spirit boss, entire bird in graceful three-quarter flying pose, two wings sweeping upwards, compact golden yellow body, red crest, long curved orange-red tail feathers and golden spiritual flame wisps. Strong readable silhouette at 64px, hand-painted 2D dark fantasy survival game style with black ink outlines, simplified chunky shapes. Centered on square canvas, safe transparent margins, no text, no badge, no scenery, no ground or shadow, single creature only.

### ttk_summon_qlch.png

One transparent PNG game inventory icon: Kỳ Lân Tàn Hồn, miniature Chinese qilin spirit boss, full four-legged body in three-quarter prancing pose, deer-like body with turquoise jade scales, dragon face, two short golden antlers, flowing white mane, cloven hooves, curled tail, cyan frost spirit wisps. Compact fierce mythical creature, hand painted 2D fantasy survival game icon with bold dark ink outlines and chunky readable shapes at 64px. Centered square canvas with safe clear margins. Truly transparent alpha background, no text, no frame, no scenery, no cast shadow, no extra creatures.
