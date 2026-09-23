/* eslint-disable @typescript-eslint/no-require-imports */
const test = require('node:test');
const assert = require('node:assert/strict');

const View = require('./view.js');

test('maps tiers to semantic classes including utility gradient', () => {
  assert.equal(View.tierClass('I'), 'tier-i');
  assert.equal(View.tierClass('V'), 'tier-v');
  assert.equal(View.tierClass('UTILITY'), 'tier-utility');
  assert.equal(View.tierClass('unknown'), 'tier-none');
});

test('escapes catalog copy before rendering editable table rows', () => {
  const html = View.renderRow({
    key: 'unsafe',
    numericId: '1',
    name: '<img src=x onerror=alert(1)>',
    family: 'Test',
    code: 'test_code',
    effectKey: 'testEffect',
    tier: 'I',
    category: 'Tấn công',
    slot: 'Vũ khí',
    status: 'Đề xuất - adapter',
    current: 'Chưa có',
    proposed: '5%',
    cap: '10%',
    exclusiveGroup: '',
    source: 'source.lua',
    decision: 'Đánh giá',
    note: 'Ghi chú',
  });

  assert.ok(!html.includes('<img'));
  assert.ok(html.includes('&lt;img'));
  assert.ok(html.includes('data-key="unsafe"'));
  assert.ok(html.includes('data-field="proposed"'));
});

test('renders Bỏ as the selected decision for rejected rows', () => {
  const html = View.renderRow({
    key: 'removed',
    name: 'Nhanh Nhẹn',
    family: 'Nhanh Nhẹn',
    code: 'equip_speed_i',
    effectKey: 'addSpeedPercent',
    tier: 'I',
    category: 'Cơ động',
    slot: 'Vũ khí',
    status: 'Đề xuất - adapter',
    current: 'Chưa có',
    proposed: '1-5%',
    cap: '',
    source: 'data.js',
    decision: 'Bỏ',
    note: 'Đã loại khỏi thiết kế đá cường hóa.',
  });

  assert.ok(html.includes('<option value="Bỏ" selected>Bỏ</option>'));
});

test('summarizes visible and edited rows for the header', () => {
  const summary = View.summarize(
    [
      { status: 'Đang có', tier: 'I' },
      { status: 'Đề xuất - adapter', tier: 'V' },
      { status: 'Đề xuất - adapter', tier: 'UTILITY' },
    ],
    { edited: { proposed: '9%' } },
  );

  assert.deepEqual(summary, { visible: 3, current: 1, proposals: 2, utility: 1, edited: 1 });
});

test('renders the reviewed image code and meaning in an affix row', () => {
  const html = View.renderRow({
    key: 'add_damage_small',
    numericId: '33',
    name: 'Thanh Long I',
    family: 'Thanh Long',
    code: 'add_damage_small',
    effectKey: 'addComDamagePercent',
    tier: 'I',
    category: 'Tấn công',
    slot: 'Vũ khí',
    status: 'Đang có',
    current: '+3-5% ST đòn chính',
    proposed: '+3-5% ST đòn chính',
    cap: '',
    exclusiveGroup: 'dragon_damage',
    source: 'scripts/enums/hh_enchant.lua',
    decision: 'Giữ và cân lại',
    note: '',
    imageId: 'A06',
    imageSrc: 'images/affixes/A06.png',
    meaning: 'Tăng sát thương đòn chính.',
  });

  assert.ok(html.includes('src="images/affixes/A06.png"'));
  assert.ok(html.includes('<figcaption>A06</figcaption>'));
  assert.ok(html.includes('<td class="meaning-cell">Tăng sát thương đòn chính.</td>'));
});

test('renders explicit fallbacks when a proposed family has no reviewed image', () => {
  const html = View.renderRow({
    key: 'equip_dodge_i',
    numericId: '',
    name: 'Ảnh Bộ I',
    family: 'Ảnh Bộ',
    code: 'equip_dodge_i',
    effectKey: 'chanceDodgeAttack',
    tier: 'I',
    category: 'Phòng thủ',
    slot: 'Giày, giáp hoặc phụ kiện',
    status: 'Đề xuất - dùng ngay',
    current: 'Chưa có',
    proposed: '2%',
    cap: 'Tổng né 70%',
    exclusiveGroup: 'dodge',
    source: 'scripts/enums/hh_effects.lua',
    decision: 'Đánh giá',
    note: '',
    imageId: '',
    imageSrc: '',
    meaning: '',
  });

  assert.ok(html.includes('Chưa gán ảnh'));
  assert.ok(html.includes('<td class="meaning-cell is-empty">Chưa có mô tả bổ sung.</td>'));
  assert.equal(html.includes('<img'), false);
});
