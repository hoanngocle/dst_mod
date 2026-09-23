# Nhóm công trình và vườn trong đợt 18 món

Tinh Thối Đan Phủ (`xd_xcdf`) đã bị loại theo yêu cầu. Đan Lô và hệ đan dược hiện được tích hợp độc lập qua `main/ttk_alchemy.lua`, không phụ thuộc công trình đã loại này.

## Các món và sản vật

- Quỳnh Lâu Kim Khuyết: bán kính sáng 6, intensity/falloff 0,8; đốt 1 Hạ Phẩm Linh Thạch cho 3.360 giây sáng. Chỉ sáng và tiêu hao vào ban đêm; giữ tiến độ nhiên liệu qua lưu/tải.
- Sơ Quả Thương: 36 ô, nhận rau/quả/hạt sống; không nhận món đã nấu hoặc linh thảo. Hệ số hư hỏng −0,2 làm hồi độ tươi. Có nâng cấp chồng đồ bằng mảnh vương miện.
- Trữ Nhục Thương: 36 ô, nhận thịt sống, bơ, sữa và milkywhites; không nhận món đã nấu. Hồi độ tươi và nâng cấp giống Sơ Quả Thương.
- Thiên Vị Thực Khám: sang mỗi ngày chọn một món ngẫu nhiên từ danh sách món đã nêm gia vị chuẩn DST, tạo 1–2 phần. Món chưa nhận bị thay khi sang ngày, giống nguồn. Nhận bằng ACTIVATE; lưu/tải món đang chờ. Hiệu ứng full/small dùng cùng gói lunar FX đã nhập.
- Thủy Phù Dung, Triều Dương Hoa, U Lan: hồi tinh thần với aura 2 × SANITYAURA_TINY; 40% sinh một bướm mỗi bình minh ngoài mùa đông, không sinh trong hang.
- Vân Yên Hương Liệu Trạm: hai ô món ăn/gia vị, nêm cùng loại theo chồng; mỗi mẻ tối đa 120 cặp. Giữ nguyên liệu dư, lưu số lượng mẻ khi lưu/tải, xuất đủ sản phẩm khi thu hoạch. Sao chép bảng công thức portablespicer sang cooker riêng, không sửa bảng công thức hay component chung của Solo.
- Vô Song Kiếm Hạp: 20 ô nhận vũ khí; mỗi khoảng 10 giây nhặt đồ trong bán kính 8. Bỏ qua đồ đang được giữ, đồ có chủ/khóa cá nhân và vũ khí Solo có buff bind.
- Yên Liễu Thụ: tạo 1 Ngọc Lục mỗi khoảng 3.360 + 0–100 giây, có che chở và vùng nhiệt độ 19 trong bán kính 6.

Các đầu ra dùng prefab chuẩn DST khi chúng đã có trong game: bướm, ngọc, món ăn/gia vị và rương sập giữ đồ. Không cần sao chép lại prefab chuẩn dưới tên mới.

## Thích nghi để dùng độc lập

- Bỏ điều kiện nhân vật nguồn khỏi công thức hai công trình thức ăn.
- Thêm bốn công thức tên riêng `ttk_spice_*` tại Máy Khoa Học: 3 Tỏi/Mật Ong/Ớt/Muối Đá → 2 gia vị chuẩn tương ứng. Không đổi công thức Warly gốc.
- Dùng thao tác ACTIVATE chuẩn để nhận món ăn, không nhập toàn bộ action/component Tu Tiên.
- Sửa lỗi nguồn tiêu thụ chồng nguyên liệu dư khi nêm hàng loạt; số lượng nguyên liệu và sản phẩm được quản lý trên riêng thực thể trạm.

## Kiểm tra

Đã biên dịch cú pháp Lua nhóm này bằng LuaJIT; đã đối chiếu API stewer, container và ACTIVATE với scripts.zip của DST cài trên máy. Đã kiểm tra atlas/texture inventory và minimap của cả 10 món, cùng các gói animation. Đây là kiểm tra mã/tài nguyên, chưa phải xác nhận đã chơi thử đợt 18 món với Solo.
