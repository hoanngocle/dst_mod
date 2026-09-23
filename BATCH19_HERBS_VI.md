# Batch 19 — Ngọc Lộ Huyền Thương và Ngọc Lộ Tiên Khu

## Phạm vi

Batch này chuyển độc lập hai công trình từ nguồn `3235319974`:

- `xd_ylxc` → `ttk_ylxc` — **Ngọc Lộ Huyền Thương**.
- `xd_ylxq` → `ttk_ylxq` — **Ngọc Lộ Tiên Khu**.

Đợt chuyển hai công trình này không gồm `xd_xcdf` (Tinh Thối Đan Phủ). Đan Lô và đan dược đã được tích hợp sau đó qua `main/ttk_alchemy.lua`; ghi chú loại trừ của batch cũ không áp dụng cho toàn bộ mod hiện tại.

## Ngọc Lộ Huyền Thương

- 36 ô chứa đồ, dùng giao diện 6×6.
- Chỉ nhận 6 linh thảo và 6 hạt linh thảo của module; cả 12 prefab mang tag mạng `ttk_ylxc_valid`.
- `preserver` dùng hệ số `-1`, giữ nguyên hành vi nguồn: đồ dễ hỏng trong kho không giảm độ tươi.
- Giữ infinite stack của kho nguồn.
- Đập búa thả đồ theo giới hạn chồng chuẩn DST; nếu còn quá nhiều đồ, chuyển sang Rương Sập để giữ phần còn lại và tránh sinh hàng loạt thực thể.
- Recipe nguồn được giữ nguyên sau khi đổi namespace: `3 ttk_lingshi2 + 10 bluegem + 10 cutstone + 5 boards`, cấp `SCIENCE_ONE`.

## Ngọc Lộ Tiên Khu

- Mỗi tiên khu trồng một hạt linh thảo.
- Linh khí từ 0–100, giảm 1 điểm mỗi chu kỳ thế giới như nguồn.
- Nguồn nạp linh khí bằng pháp bảo `xd_ztp`, nằm ngoài batch. Bản port dùng action server `TTK_INFUSE_YLXQ`: một `ttk_lingshi1` nạp 25 điểm, không tiêu hao khi tiên khu đã đầy.
- Action gieo `TTK_LC_PLANT` kiểm tra khoảng cách, quyền sở hữu vật phẩm trong inventory, tag hạt và trạng thái trống ở server trước khi tạo cây.
- Component lưu `current` và save record của cây; load lại cây, follower, sự kiện tăng trưởng và trạng thái giao diện.
- Đập búa trả một linh thảo từ cây đang trồng rồi xóa cây.
- Recipe nguồn được giữ nguyên sau khi đổi namespace: `3 ttk_lingshi2 + 8 livinglog + 5 cutstone + 1 greengem`, cấp `SCIENCE_ONE`.

## Sáu chuỗi linh thảo

Mỗi cây có bốn giai đoạn 720 giây (`seed`, `sprout`, `small`, `med`) và 10 giây để vào giai đoạn thu hoạch. Cây chỉ chạy thời gian khi tiên khu còn linh khí và đúng điều kiện nguồn.

| Mã | Tên | Điều kiện sinh trưởng | Ăn linh thảo | Nguy cơ khi hái |
|---|---|---|---|---|
| `hsc` | Hàn Sương Thảo | Mùa đông | +10 máu, +8 đói, -30 tinh thần, hạ nhiệt 10 | Tăng lạnh bằng ngưỡng kháng đóng băng hiện tại |
| `dms` | Địa Mạch Sâm | Ban ngày, không mưa/tuyết | +10 máu, +12.5 đói, -5 tinh thần, hồi 0.5 máu mỗi nhịp jellybean | Gây buồn ngủ như nguồn |
| `qfx` | Thanh Phong Tiên | Mùa thu | 0 máu, 0 đói, -2 tinh thần | Không |
| `cyh` | Xích Viêm Hoa | Mùa hè | +20 máu, +12.5 đói, tăng nhiệt 15 | Thiêu 2% máu tối đa mỗi giây trong 8.1 giây |
| `lmg` | Lôi Minh Quả | Mùa xuân | +20 máu, +12.5 đói, -45 tinh thần, hạ nhiệt 10 và gọi sét | Điện giật 100 sát thương nếu người hái không cách điện |
| `yhh` | U Hồn Hoa | Ban đêm | +5 máu, 0 đói, -60 tinh thần | -100 tinh thần |

Thu hoạch luôn cho một linh thảo và có 40% trả hạt, đúng nguồn. Trang bị **Nguyệt Hoa Nhiếp Dược Chi** (`ttk_yhsyz`) trên tay tăng xác suất hạt lên 75% và tránh nguy cơ khi hái; mỗi lượt thành công tiêu hao một trong 100 lượt của dụng cụ. Dụng cụ độc lập đã được bổ sung trong [GARDEN_EXPANSION_VI.md](GARDEN_EXPANSION_VI.md). Khi mod nguồn cùng tồn tại, vật phẩm có tag `xd_yhsyz` vẫn được nhận diện; module không require hoặc gọi loader nguồn.

## Ăn trực tiếp sáu loại hạt

Hạt hồi chỉ số hiện tại, không tăng mức tối đa và không cần luyện đan. Chỉ số cơ bản của hạt tươi:

| Hạt giống | Hồi khi ăn |
|---|---|
| Thanh Nang (`qfx`), Sí Nhiệt (`cyh`) | +50 độ no |
| Điện Khuẩn (`lmg`), U Ảnh (`yhh`) | +50 tinh thần |
| Địa Tủy (`dms`), Phủ Băng (`hsc`) | +50 máu |

Hai chỉ số còn lại bằng 0. Hạt không gây hiệu ứng ăn đặc biệt của linh thảo; vẫn có thể gieo và giữ cơ chế độ tươi, chế độ ăn của DST. Kiểm tra tự động: `tools/test_seed_food.py`.

## Cách lấy hạt ban đầu

Trong nguồn, boss `xd_qxdx` thả ngẫu nhiên hai hạt trong sáu loại khi chết. Boss này không thuộc batch nên nếu giữ nguyên tuyệt đối, người chơi mới không thể bắt đầu chuỗi trồng. Bản port thay đường vào bằng sáu recipe chuyển hóa ở `SCIENCE_TWO`, mỗi recipe dùng một hạt cây vanilla tương ứng và một `ttk_lingshi1`:

| Hạt linh thảo | Nguyên liệu |
|---|---|
| `ttk_lc_hsc_seed` | `asparagus_seeds ×1 + ttk_lingshi1 ×1` |
| `ttk_lc_dms_seed` | `carrot_seeds ×1 + ttk_lingshi1 ×1` |
| `ttk_lc_qfx_seed` | `garlic_seeds ×1 + ttk_lingshi1 ×1` |
| `ttk_lc_cyh_seed` | `pepper_seeds ×1 + ttk_lingshi1 ×1` |
| `ttk_lc_lmg_seed` | `pumpkin_seeds ×1 + ttk_lingshi1 ×1` |
| `ttk_lc_yhh_seed` | `tomato_seeds ×1 + ttk_lingshi1 ×1` |

## An toàn và tương thích

- Tất cả ID mới dùng tiền tố `ttk_`; action dùng tiền tố `TTK_`.
- Không require component, prefab, player component hay hàm global của mod nguồn.
- Các hiệu ứng người chơi đều kiểm tra component trước khi dùng; `AddItemPermission` chỉ gọi khi host cung cấp.
- Client chỉ dựa vào tag mạng để hiện action. Mọi thay đổi inventory, charge, spawn cây và consume đều chạy và xác thực ở master simulation.
- Asset được sao chép sang tên riêng `ttk_*`; bank/build bên trong archive giữ tên gốc để không phá animation.

## Nguồn đã đối chiếu tĩnh

- `scripts/prefabs/xd_ylxc.lua`
- `scripts/prefabs/xd_ylxq.lua`
- `scripts/components/xd_ylxq_grower.lua`
- `scripts/prefabs/xd_plant.lua`
- `scripts/prefabs/xd_dms_healthregenbuff.lua`
- `scripts/prefabs/xd_dy_buffs.lua` (chỉ hành vi burn khi hái Xích Viêm Hoa)
- `scripts/main/actions.lua`
- `scripts/main/recipes.lua`
- `scripts/prefabs/xd_qxdx.lua` (đường rơi hạt nguồn)

Các file mã hóa chỉ được đọc bằng byte map tĩnh của `tools/port_ttk_buildings.py`/`tools/port_vanhonphien.py`; loader nguồn không được thực thi.
