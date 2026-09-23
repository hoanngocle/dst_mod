# Nguồn tài nguyên

- Artwork cổng, lõi xoáy và khung giao diện: tạo mới bằng công cụ **image_gen tích hợp**, theo concept người dùng đã duyệt; không lấy hình từ Workshop khác.
- Concept: `assets/concept/portal_concept.png`, hình ý tưởng của bản nền Fast Travel, không dùng làm tên/logo trong giao diện mod mới.
- Prompt nguyên văn: `assets/source/prompts.json`.
- PNG nguồn: `assets/source/ttt_portal_frame.png`, `ttt_portal_vortex.png`, `ttt_portal_panel.png`.
- Prompt khung cổng: khung gỗ cổ và chân đá rune, bảng tên để trống, đèn tím, phong cách vẽ tay Don't Starve Together; nền và lòng cổng trong suốt, không chữ/nhân vật/phong cảnh.
- Prompt lõi: vòng xoáy tròn xanh tím với tâm tối, viền alpha mềm; không khung, không chữ, dùng riêng để xoay trong animation.
- Prompt bảng UI: khung gỗ–đá dọc, rune tím, phần giữa tối trống, nền ngoài alpha; không vẽ sẵn nút, chữ hoặc portal để Lua đặt nội dung động.
- Biên dịch TEX bằng **Klei TextureConverter** trong Don't Starve Mod Tools đã cài. Build v6 / animation v4 được đóng gói theo định dạng được mô tả trong `buildanimation.py` của bộ công cụ Klei.
- Mã Fast Travel được dùng làm nền; bản Truyền Tống Trận tách component/replica/asset sang `ttt_`, RPC sang `NYX_TTT`. Cơ chế bảng hiệu, công thức, writeable và widget gốc thuộc Don't Starve Together/Klei.

Tên mod và tác giả hiển thị được đặt theo yêu cầu: **Truyền Tống Trận — Nyx**.
