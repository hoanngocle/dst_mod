/* eslint-disable @typescript-eslint/no-require-imports */
const test = require('node:test');
const assert = require('node:assert/strict');

const State = require('./state.js');

const rows = [
  {
    key: 'dodge_i',
    name: 'Ảnh Bộ I',
    code: 'chance_dodge_i',
    effectKey: 'chanceDodgeAttack',
    tier: 'I',
    category: 'Phòng thủ',
    status: 'Đề xuất - dùng ngay',
    proposed: '2%',
    cap: '20%',
    note: '',
  },
  {
    key: 'utility_pickup',
    name: 'Nhiếp Vật',
    code: 'utility_auto_pickup',
    effectKey: 'utilityAutoPickup',
    tier: 'UTILITY',
    category: 'Tiện ích',
    status: 'Đề xuất - adapter',
    proposed: 'Bán kính 6',
    cap: '1 hiệu ứng',
    note: '',
  },
];

test('sanitizes edits to known rows and editable fields', () => {
  const edits = State.sanitizeEdits(rows, {
    dodge_i: { proposed: '3%', cap: '24%', note: 'Thử lại', code: 'hacked' },
    missing: { proposed: '999%' },
  });

  assert.deepEqual(edits, {
    dodge_i: { proposed: '3%', cap: '24%', note: 'Thử lại' },
  });
});

test('round trips edits through storage and survives malformed storage', () => {
  const memory = new Map();
  const storage = {
    getItem: (key) => memory.get(key) ?? null,
    setItem: (key, value) => memory.set(key, value),
    removeItem: (key) => memory.delete(key),
  };

  State.saveEdits(storage, 'affix-balance', { dodge_i: { proposed: '4%' } });
  assert.deepEqual(State.loadEdits(storage, 'affix-balance', rows), {
    dodge_i: { proposed: '4%' },
  });

  storage.setItem('affix-balance', '{broken json');
  assert.deepEqual(State.loadEdits(storage, 'affix-balance', rows), {});
});

test('exports resolved rows and imports only the supported schema', () => {
  const edits = { dodge_i: { proposed: '5%', note: 'Mốc thử' } };
  const payload = State.buildExport(rows, edits, '2026-09-22T00:00:00.000Z');

  assert.equal(payload.schemaVersion, 1);
  assert.equal(payload.generatedAt, '2026-09-22T00:00:00.000Z');
  assert.equal(payload.rows.length, 2);
  assert.equal(payload.rows[0].proposed, '5%');
  assert.deepEqual(State.importExport(rows, payload), edits);
  assert.throws(
    () => State.importExport(rows, { schemaVersion: 2, edits: {} }),
    /schema/i,
  );
});

test('filters across text, tier, category, and status', () => {
  assert.deepEqual(
    State.filterRows(rows, { query: 'dodge', tier: 'ALL', category: 'ALL', status: 'ALL' })
      .map((row) => row.key),
    ['dodge_i'],
  );
  assert.deepEqual(
    State.filterRows(rows, { query: '', tier: 'UTILITY', category: 'Tiện ích', status: 'Đề xuất - adapter' })
      .map((row) => row.key),
    ['utility_pickup'],
  );
});

test('applies edits without mutating catalog defaults', () => {
  const resolved = State.applyEdits(rows, { dodge_i: { proposed: '6%' } });

  assert.equal(resolved[0].proposed, '6%');
  assert.equal(rows[0].proposed, '2%');
  assert.notEqual(resolved[0], rows[0]);
});
