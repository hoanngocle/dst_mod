# Ảnh EVA trong bảng Nhân vật

- Bộ chọn gồm ảnh EVA gốc và 4 ảnh người dùng cung cấp, giữ nguyên toàn bộ khung hình và tỉ lệ.
- Mở bảng Nhân vật bằng B; dùng < / > để xem trước. Bấm Đặt làm mặc định để lưu trên máy; mở lại bảng hoặc khởi động lại game sẽ nạp lựa chọn đã lưu.
- Chỉ chuyển ảnh không ghi đè mặc định. Hiển thị đang lưu/lỗi; chỉ xác nhận mặc định sau khi ghi thành công.
- Khóa lưu: pham_nhan_eva_portrait_v1. Lưu ID ổn định, không lưu đường dẫn file tạm hoặc dữ liệu ảnh vào save thế giới.
- Bộ chọn hiện gắn vào bảng Nhân vật có sẵn. Nút Nhiệm vụ/Ảnh EVA chuyển phần bên phải; chức năng nhiệm vụ và nâng cấp quân đoàn vẫn giữ. Bảng tab chung đang ở giai đoạn phác thảo.
- Texture/atlas đóng gói trong images/eva_portraits. Ảnh nguồn không chỉnh sửa và SHA-256 tại mods/eva-assets-work/portrait-gallery.
- Kiểm chứng: 5 lựa chọn, lưu/nạp, lỗi ghi, ID không hợp lệ, vòng ảnh, các tình huống callback bất đồng bộ, hash nguồn, kích thước texture và cú pháp Lua. Chưa kiểm tra trực tiếp trong client DST.
