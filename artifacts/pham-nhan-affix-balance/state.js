(function (root, factory) {
  const api = factory();
  if (typeof module === 'object' && module.exports) module.exports = api;
  if (root) root.AffixBalanceState = api;
})(typeof globalThis !== 'undefined' ? globalThis : this, function () {
  'use strict';

  const EDITABLE_FIELDS = ['proposed', 'cap', 'note', 'tier', 'decision'];

  function rowKeys(rows) {
    return new Set((rows || []).map((row) => row.key));
  }

  function sanitizeEdits(rows, raw) {
    const keys = rowKeys(rows);
    const clean = {};
    if (raw === null || typeof raw !== 'object' || Array.isArray(raw)) return clean;

    for (const [key, patch] of Object.entries(raw)) {
      if (!keys.has(key) || patch === null || typeof patch !== 'object' || Array.isArray(patch)) continue;
      const next = {};
      for (const field of EDITABLE_FIELDS) {
        if (typeof patch[field] === 'string') next[field] = patch[field];
      }
      if (Object.keys(next).length > 0) clean[key] = next;
    }
    return clean;
  }

  function applyEdits(rows, edits) {
    const clean = sanitizeEdits(rows, edits);
    return (rows || []).map((row) => ({ ...row, ...(clean[row.key] || {}) }));
  }

  function loadEdits(storage, storageKey, rows) {
    if (!storage || typeof storage.getItem !== 'function') return {};
    try {
      const value = storage.getItem(storageKey);
      return value ? sanitizeEdits(rows, JSON.parse(value)) : {};
    } catch (_) {
      return {};
    }
  }

  function saveEdits(storage, storageKey, edits) {
    if (!storage || typeof storage.setItem !== 'function') return false;
    try {
      storage.setItem(storageKey, JSON.stringify(edits || {}));
      return true;
    } catch (_) {
      return false;
    }
  }

  function buildExport(rows, edits, generatedAt) {
    const clean = sanitizeEdits(rows, edits);
    return {
      schemaVersion: 1,
      mod: 'Phàm Nhân Tu Tiên',
      generatedAt: generatedAt || new Date().toISOString(),
      edits: clean,
      rows: applyEdits(rows, clean),
    };
  }

  function importExport(rows, payload) {
    if (payload === null || typeof payload !== 'object' || payload.schemaVersion !== 1) {
      throw new Error('JSON không đúng schemaVersion 1.');
    }
    if (payload.edits === null || typeof payload.edits !== 'object' || Array.isArray(payload.edits)) {
      throw new Error('JSON không có bảng edits hợp lệ.');
    }
    return sanitizeEdits(rows, payload.edits);
  }

  function normalize(value) {
    return String(value || '').trim().toLocaleLowerCase('vi');
  }

  function filterRows(rows, filters) {
    const selected = filters || {};
    const query = normalize(selected.query);
    return (rows || []).filter((row) => {
      if (selected.tier && selected.tier !== 'ALL' && row.tier !== selected.tier) return false;
      if (selected.category && selected.category !== 'ALL' && row.category !== selected.category) return false;
      if (selected.status && selected.status !== 'ALL' && row.status !== selected.status) return false;
      if (!query) return true;
      const haystack = normalize([
        row.name,
        row.family,
        row.code,
        row.effectKey,
        row.category,
        row.status,
        row.current,
        row.proposed,
        row.source,
        row.note,
      ].join(' '));
      return haystack.includes(query);
    });
  }

  return {
    EDITABLE_FIELDS,
    sanitizeEdits,
    applyEdits,
    loadEdits,
    saveEdits,
    buildExport,
    importExport,
    filterRows,
  };
});
