/* eslint-disable @typescript-eslint/no-require-imports */
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const Catalog = require('./data.js');

test('ships all 71 current affixes including entries marked for removal', () => {
  const current = Catalog.rows.filter((row) => row.status === 'Đang có');
  assert.equal(current.length, 71);
});

test('gives every row a unique key and the fields required by the workbench', () => {
  const keys = new Set();
  for (const row of Catalog.rows) {
    assert.equal(typeof row.key, 'string');
    assert.ok(row.key.length > 0);
    assert.ok(!keys.has(row.key), `duplicate key: ${row.key}`);
    keys.add(row.key);
    for (const field of ['name', 'family', 'code', 'effectKey', 'tier', 'category', 'status', 'current', 'proposed']) {
      assert.equal(typeof row[field], 'string', `${row.key}.${field}`);
    }
  }
});

test('defines all five tiers for every tiered proposal family', () => {
  const proposals = Catalog.rows.filter((row) => row.status.startsWith('Đề xuất') && row.tier !== 'UTILITY');
  const byFamily = new Map();
  for (const row of proposals) {
    if (!byFamily.has(row.family)) byFamily.set(row.family, []);
    byFamily.get(row.family).push(row.tier);
  }
  assert.ok(byFamily.size >= 20);
  for (const family of byFamily.keys()) {
    const tiers = Catalog.rows
      .filter((row) => row.family === family && row.tier !== 'UTILITY')
      .map((row) => row.tier);
    assert.deepEqual([...new Set(tiers)].sort(), ['I', 'II', 'III', 'IV', 'V'], family);
  }
});

test('keeps utility proposals in the gradient tier', () => {
  const utilities = Catalog.rows.filter((row) => row.status.startsWith('Đề xuất') && row.category === 'Tiện ích');
  assert.ok(utilities.length >= 7);
  assert.ok(utilities.every((row) => row.tier === 'UTILITY'));
});

test('adds durability tiers III to V with the requested ranges', () => {
  const rows = Catalog.rows.filter((row) => row.family === 'Bền Bỉ');
  assert.deepEqual(
    rows.map((row) => [row.tier, row.proposed]),
    [
      ['I', '+20-80 độ bền'],
      ['II', '+40-160 độ bền'],
      ['III', '+120-280 độ bền'],
      ['IV', '+240-400 độ bền'],
      ['V', '+360-640 độ bền'],
    ],
  );
  assert.deepEqual(rows.slice(2).map((row) => row.status), [
    'Đề xuất - dùng ngay',
    'Đề xuất - dùng ngay',
    'Đề xuất - dùng ngay',
  ]);
});

test('splits critical rate and critical damage into five requested tiers', () => {
  const rate = Catalog.rows.filter((row) => row.family === 'Tỷ Lệ Bạo Kích');
  const damage = Catalog.rows.filter((row) => row.family === 'Sát Thương Bạo Kích');

  assert.deepEqual(rate.map((row) => row.proposed), ['1-5%', '3-10%', '5-15%', '10-20%', '15-30%']);
  assert.ok(rate.every((row) => row.effectKey === 'criticalHitRate' && row.cap === 'Tổng 100%'));
  assert.deepEqual(damage.map((row) => row.proposed), ['2-10%', '6-20%', '10-30%', '20-40%', '30-60%']);
  assert.ok(damage.every((row) => row.effectKey === 'criticalHitEffect' && row.cap === 'Không cap'));
});

test('splits Nhanh Nhẹn into five proposed tiers while preserving the runtime row', () => {
  const proposals = Catalog.rows.filter((row) => row.family === 'Nhanh Nhẹn');
  assert.deepEqual(proposals.map((row) => row.proposed), ['1-5%', '3-10%', '5-15%', '10-20%', '15-30%']);
  assert.ok(proposals.every((row) => row.effectKey === 'addSpeedPercent' && row.status === 'Đề xuất - adapter'));

  const runtime = Catalog.rows.find((row) => row.code === 'add_speed');
  assert.equal(runtime.current, '5-25%');
  assert.equal(runtime.status, 'Đang có');
});

test('keeps only the two requested disciple families with overlapping random ranges', () => {
  const discipleRows = Catalog.rows.filter((row) => row.category === 'Đệ tử');
  const retainedRows = discipleRows.filter((row) => row.decision !== 'Bỏ');
  assert.deepEqual([...new Set(retainedRows.map((row) => row.family))], ['Hắc Sinh Mệnh', 'Hắc Công Kích']);

  const health = retainedRows.filter((row) => row.family === 'Hắc Sinh Mệnh');
  const damage = retainedRows.filter((row) => row.family === 'Hắc Công Kích');
  assert.deepEqual(health.map((row) => row.proposed), ['3-8%', '7-15%', '14-24%', '23-32%', '31-40%']);
  assert.deepEqual(damage.map((row) => row.proposed), ['2-4%', '3-7%', '6-11%', '10-15%', '14-20%']);
  assert.ok(health.every((row) => row.cap === 'Tổng 40%'));
  assert.ok(damage.every((row) => row.cap === 'Tổng 20%'));
});

test('keeps every rejected idea visible with a removal decision and note', () => {
  const rejected = Catalog.rows.filter((row) => row.decision === 'Bỏ');
  const expectedFamilies = [
    'Tốc chạy',
    'Nhanh Nhẹn',
    'Bền Lực',
    'Trợ thủ phòng thủ',
    'Trợ thủ tấn công',
    'Trợ Kích',
    'Hắc Phòng Ngự',
    'Hắc Tốc Hành',
    'Hắc Liên Kích',
    'Hắc Tái Sinh',
    'Quân Đoàn Ma',
  ];

  assert.equal(rejected.length, 39);
  for (const family of expectedFamilies) {
    assert.ok(rejected.some((row) => row.family === family), `missing rejected family: ${family}`);
  }
  assert.ok(rejected.every((row) => row.note === 'Đã loại khỏi thiết kế đá cường hóa.'));
  assert.equal(rejected.filter((row) => row.name.startsWith('Nhanh Nhẹn')).length, 6);
  assert.ok(rejected.some((row) => row.code === 'follow_reduce_damage'));
  assert.ok(rejected.some((row) => row.code === 'follow_add_damage'));
  assert.ok(rejected.some((row) => row.code === 'utility_durability_save'));
});

test('promotes permanent armor to tier V and adds the requested tier IV proposal', () => {
  const rows = Catalog.rows.filter((row) => row.family === 'Hộ Giáp');
  assert.deepEqual(rows.map((row) => row.tier), ['I', 'II', 'III', 'IV', 'V']);
  assert.equal(rows[3].name, '★Hộ Giáp IV');
  assert.equal(rows[3].proposed, '+2000-5000 độ bền giáp');
  assert.equal(rows[3].status, 'Đề xuất - dùng ngay');
  assert.equal(rows[4].code, 'armor_immune_amount');
  assert.equal(rows[4].name, '★Hộ Giáp V');
  assert.equal(rows[4].current, 'Giáp không mất độ bền');
});

test('adds Gia Trì V as a web-only permanent durability proposal', () => {
  const rows = Catalog.rows.filter((row) => row.family === 'Gia Trì');
  assert.deepEqual(rows.map((row) => row.tier), ['I', 'II', 'III', 'IV', 'V']);

  const tierV = rows[4];
  assert.equal(tierV.name, '★Gia Trì V');
  assert.equal(tierV.code, 'durability_immune_amount');
  assert.equal(tierV.proposed, 'Đồ không mất độ bền');
  assert.equal(tierV.status, 'Đề xuất - adapter');
  assert.equal(tierV.cap, 'Chỉ 1 viên Gia Trì');
});

test('uses the accurate one-second Gia Trì code in the web catalog', () => {
  assert.equal(Catalog.rows.some((row) => row.code === 'restore_use_3s_1use'), false);
  const restoration = Catalog.rows.find((row) => row.code === 'restore_use_1s_1use');
  assert.equal(restoration.name, '☆Gia Trì III');
  assert.equal(restoration.note, '');
});

test('contains no forbidden long dash in visible catalog copy', () => {
  const visible = JSON.stringify(Catalog.rows);
  assert.equal(visible.includes('—'), false);
  assert.equal(visible.includes('–'), false);
});

test('gives every current runtime affix its reviewed image and meaning', () => {
  const current = Catalog.rows.filter((row) => row.status === 'Đang có');

  for (const row of current) {
    assert.match(row.imageId, /^[AB]\d{2}$/, `${row.code}.imageId`);
    assert.equal(row.imageSrc, `images/affixes/${row.imageId}.png`, `${row.code}.imageSrc`);
    assert.ok(row.meaning.length > 0, `${row.code}.meaning`);
    assert.equal(
      fs.existsSync(path.join(__dirname, row.imageSrc)),
      true,
      `missing image asset: ${row.imageSrc}`,
    );
  }
});

test('reuses reviewed family images for added tiers and leaves new families unassigned', () => {
  const durabilityV = Catalog.rows.find((row) => row.code === 'add_max_use_tier_v');
  assert.equal(durabilityV.imageId, 'A03');
  assert.equal(durabilityV.meaning, 'Tăng độ tươi hoặc độ bền tối đa của trang bị phù hợp.');

  const dodgeI = Catalog.rows.find((row) => row.code === 'equip_dodge_i');
  assert.equal(dodgeI.imageId, '');
  assert.equal(dodgeI.imageSrc, '');
  assert.equal(dodgeI.meaning, '');
});
