"""Render the reviewed reward pool and the original-prefab coverage inventory."""
from audit_slot_rewards import audit, MOD, EXCLUDED, REMOVED, REPLACED, RENAMES

original, prizes, missing = audit()
assert not missing, missing
labels = {'good':'Hiếm', 'ok':'Khá', 'ok2':'Thường', 'bad':'Boss', 'bad2':'Quái'}
lines = ['# Bảng thưởng Máy Quay Thưởng Linh Thạch', '',
         '**1 Trung Phẩm Linh Thạch = 1 lượt.** Chọn nhóm trước, sau đó chọn một gói; nhận toàn bộ nội dung gói.', '',
         'Trang bị mỗi loại tối đa một chiếc/gói. Các lượt khác nhau vẫn có thể trùng quà. Không có sáo Pan. Đồ sơ cấp đã thay bằng linh thảo, linh thực, nguyên liệu và pháp bảo Tu Tiên Ký.', '',
         'Công thức: 6 Đá Cắt + 4 Ván Gỗ + 2 Bánh Răng + 1 Ngọc Tím + 30 Hạ Phẩm Linh Thạch; Máy Luyện Kim.', '',
         '[Kiểm kê so với mod gốc](CHOUJIANGJI_AUDIT.md). Hình ảnh/âm thanh gốc: Tu Tiên 19.7, Workshop 3235319974.']
for category, label in labels.items():
    group = prizes.groups[category]
    bundles = list(group.bundles.values())
    total = sum(b.weight for b in bundles)
    lines += ['', f'## {label}: {len(bundles)} gói — {100*group.weight/10.5:.4f}% mỗi lượt', '',
              '| Gói | Nội dung | Xác suất mỗi lượt |', '|---|---|---:|']
    for b in bundles:
        contents = ' + '.join(f'`{i.prefab}` ×{i.count}' for i in b['items'].values())
        lines.append(f'| {b.label} | {contents} | {100*group.weight/10.5*b.weight/total:.4f}% |')
lines += ['', 'Tỷ lệ áp dụng khi tất cả prefab được nạp. Nếu mod khác làm mất prefab, máy bỏ cả gói không hợp lệ trước khi chọn. Không có bảo hiểm.', '']
(MOD/'docs/CHOUJIANGJI_REWARDS.md').write_text('\n'.join(lines), encoding='utf-8')

all_original = set.union(*original.values())
lines = ['# Kiểm kê bảng thưởng Tu Tiên gốc → Tu Tiên Ký', '',
         f'Đối chiếu **{len(all_original)} prefab duy nhất** trong `xd_choujiangji` của Tu Tiên 19.7: **126 giữ lại, 44 thay thế, 1 bỏ theo yêu cầu, 12 chưa chuyển**.', '',
         'Giữ chi phí 1 Trung Phẩm/lượt và trọng số năm nhóm gốc. Giảm số lượng trang bị xuống một chiếc mỗi loại; gói quà phối hợp nhiều món khác nhau.', '',
         'Các món đã khôi phục gồm Vương Miện Khai Sáng, Giáp Xương, Ô Hư Không, bộ trượng ngọc, các dây chuyền ngọc, công cụ mặt trăng, mũ hải mã và các vật phẩm boss. Bảng mới có 104 gói.', '',
         '## Danh sách gốc và quyết định', '', '| Prefab gốc | Nhóm gốc | Xử lý |', '|---|---|---|']
for name in sorted(all_original):
    groups = ', '.join(labels[g] for g in labels if name in original[g])
    if name in EXCLUDED: status = 'Chưa chuyển — '+EXCLUDED[name]
    elif name in REMOVED: status = REMOVED[name]
    elif name in REPLACED: status = 'Thay bằng '+REPLACED[name]
    elif name in RENAMES: status = 'Dùng `'+RENAMES[name]+'` của Tu Tiên Ký'
    else: status = 'Có trong bảng thưởng'
    lines.append(f'| `{name}` | {groups} | {status} |')
current = {i.prefab for g in prizes.groups.values() for b in g.bundles.values() for i in b['items'].values()}
lines += ['', '## Các món bổ sung của Tu Tiên Ký', '']
for name in sorted(current-set(RENAMES.get(n,n) for n in all_original)):
    lines.append('- `'+name+'`')
lines += ['', '## Boss đặc biệt', '',
          '- Klaus được gọi cùng cặp hươu và ghi vị trí xuất hiện như mod gốc.',
          '- Vệ Binh Thiên Thể do máy gọi có dấu riêng lưu cùng thế giới; khi chết, kết thúc bằng rơi Vương Miện Khai Sáng, không tạo quả cầu hậu chiến. Boss tự nhiên giữ handler gốc.',
          '- Giữ xử lý riêng của mod gốc cho bộ sinh rương Vệ Binh Cổ Đại nếu nó gắn với boss do máy gọi.', '',
          'Tôn Hồn Phiên (`xd_zhf`) là món khác Cửu Thiên Tinh Thần Phiên (`vanhonphien`); không coi hai prefab này là bản đổi tên của nhau.', '']
(MOD/'docs/CHOUJIANGJI_AUDIT.md').write_text('\n'.join(lines),encoding='utf-8')
print('Updated rewards and full original-prefab inventory')
