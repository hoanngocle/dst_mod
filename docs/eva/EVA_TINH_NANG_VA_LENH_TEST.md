# Phàm Nhân Tu Tiên — kiểm tra EVA hiện tại

Đối chiếu runtime ngày 22/09/2026. Các bước làm thay đổi cấp/Hồn Lực cần dùng world thử riêng.

## Cài đặt và ngoại hình

- Dùng thư mục `PhamNhanTuTien` chứa trực tiếp `modinfo.lua` và `modmain.lua`.
- Chỉ bật Phàm Nhân; tắt EVA, Solo Leveling và Achievement & Level độc lập.
- Chọn nhân vật `eva`. Ngoại hình mặc định duy nhất là EVA2 màu tím (`eva_none`); không còn skin trắng–tím hoặc lựa chọn `eva_purple` riêng.
- EVA mới vào thế giới với túi đồ trống. Vật phẩm và công thức Lưỡi Hái EVA đã được gỡ; kỹ năng Trận Lưỡi Hái vẫn hoạt động độc lập.
- Nguồn đóng gói hiện hành và hash archive nằm trong `package-manifest.json`. Thông tin triển khai Steam trong manifest là bản ghi tại thời điểm triển khai, không xác nhận trạng thái máy khác.
- Host, client và các shard phải dùng cùng bản mod. Khởi động lại game sau khi thay runtime.

## Cấp, Hồn Lực và điều khiển

EVA đọc cấp từ `components.hh_leveling.level`, cập nhật qua `hh_levelup` và sau khi tải save. `eva_souls` không có hệ Level/EXP độc lập; `levelsystem` của Achievement & Level cũ không còn là nguồn cấp.

Sức chứa Hồn Lực là `min(1000, 100 + 6 × (cấp − 1))`. Từ cấp 101, nhân vật còn sống tự hồi 1 Hồn Lực/giây. Chết mất 90% Hồn Lực, phần còn lại làm tròn xuống. Lên cấp không mặc định nạp đầy Hồn Lực.

| Phím | Kỹ năng | Cấp mở |
| --- | --- | ---: |
| 1 | Sinh Chi Hoa | 10 |
| 2 | Tử Phong Tụ Linh | 20 |
| 3 | Tinh Vũ Nguyệt Dực | 30 |
| 4 | Dạ Du | 50 |
| 5 | Trảm Linh | 100 |
| R | Thuấn Ảnh | 1 |

Phím 1–5 là dãy số trên bàn phím, theo `main/ttk_eva_source.lua`. Thuấn Ảnh dùng phím R để dịch chuyển và lôi kích; chuột phải được dành cho kỹ năng vũ khí. Các hướng dẫn hóa cáo/alias chuyển động từ bản thử nghiệm cũ không áp dụng.

## Console kiểm tra trên server

Mở console trong world thử, chọn Remote/server. In cấp chung và Hồn Lực:

```lua
local p = ConsoleCommandPlayer(); local s = p and p.components.eva_souls; if s then s:RefreshLevel(); print("Level:", p.components.hh_leveling.level, "Soul:", s.current, "/", s.max) end
```

Nạp đầy Hồn Lực, giữ nguyên cấp:

```lua
local p = ConsoleCommandPlayer(); local s = p and p.components.eva_souls; if s then s:RefreshLevel(); s:SetPercent(1) end
```

Để kiểm tra đường lên cấp thật, cộng đủ EXP còn thiếu cho một cấp qua component chung; lệnh này thay đổi tiến trình và có thể được lưu:

```lua
local p = ConsoleCommandPlayer(); local l = p and p.components.hh_leveling; if l then l:AddExp(math.max(1, l:GetExpGoal(l.level) - l.exp)) end
```

## Checklist hiện hành

- Kiểm tra ngoại hình tím mặc định, túi đồ khởi đầu trống, chạy, đánh và đội mũ.
- Thử các mốc 9→10, 19→20, 29→30, 49→50, 99→100 và 100→101; phím 1–5 mở đúng kỹ năng.
- Thử đủ/thiếu Hồn Lực, hồi chiêu, mục tiêu không hợp lệ và Thuấn Ảnh sát bờ/vật cản.
- Save/load giữ cấp chung, lượng Hồn Lực và phạt chết; cấp 150 có sức chứa 994, cấp 151 có 1000.
- Kiểm tra HUD từ host và client nếu chơi mạng. Kết quả Python/Lua không thay thế kiểm tra hình ảnh trong DST.

Các test còn dùng trong `tools/`: `test_eva_v3_install.py`, `test_eva_loadout.py`, `test_eva_approved_rig.py`, `test_eva_build_repack.py`, `test_eva_skins.py`, `test_eva_fixed_hotkeys.py`, `test_eva_lightning_blink.py`, `test_eva_skillpanel.py` và các test HUD. Bộ build/preview EVA2–EVA3 còn dùng parser và renderer chung; không xóa `build_eva_approved.py` hoặc `tools/eva` chỉ dựa vào tên cũ.

Giới hạn Achievement/perk và cấu hình EXP nhiệm vụ mùa: [ACHIEVEMENT_PERK_RUNTIME.md](../ACHIEVEMENT_PERK_RUNTIME.md).
