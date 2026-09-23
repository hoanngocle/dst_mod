(function () {
  'use strict';

  const State = window.AffixBalanceState;
  const Catalog = window.AffixBalanceCatalog;
  const View = window.AffixBalanceView;
  const body = document.getElementById('affix-body');
  const empty = document.getElementById('empty-state');
  const saveStatus = document.getElementById('save-status');
  const controls = {
    query: document.getElementById('search'),
    tier: document.getElementById('tier-filter'),
    category: document.getElementById('category-filter'),
    status: document.getElementById('status-filter'),
    editedOnly: document.getElementById('edited-filter'),
  };
  let edits = {};

  function setMessage(message, kind) {
    saveStatus.textContent = message;
    saveStatus.className = kind ? `is-${kind}` : '';
  }

  function populateSelect(select, values) {
    for (const value of [...new Set(values)].sort((a, b) => a.localeCompare(b, 'vi'))) {
      const option = document.createElement('option');
      option.value = value;
      option.textContent = value;
      select.appendChild(option);
    }
  }

  function activeFilters() {
    return {
      query: controls.query.value,
      tier: controls.tier.value,
      category: controls.category.value,
      status: controls.status.value,
    };
  }

  function currentRows() {
    const resolved = State.applyEdits(Catalog.rows, edits);
    let visible = State.filterRows(resolved, activeFilters());
    if (controls.editedOnly.checked) visible = visible.filter((row) => edits[row.key] !== undefined);
    return visible;
  }

  function updateSummary(visible) {
    const summary = View.summarize(visible, edits);
    document.getElementById('visible-count').textContent = summary.visible;
    document.getElementById('current-count').textContent = summary.current;
    document.getElementById('proposal-count').textContent = summary.proposals;
    document.getElementById('edited-count').textContent = summary.edited;
  }

  function render() {
    const visible = currentRows();
    body.innerHTML = visible.map(View.renderRow).join('');
    empty.hidden = visible.length !== 0;
    updateSummary(visible);
  }

  function compactPatch(key, field, value) {
    const original = Catalog.rows.find((row) => row.key === key);
    if (!original) return;
    const patch = { ...(edits[key] || {}) };
    if (String(original[field] ?? '') === value) delete patch[field];
    else patch[field] = value;
    if (Object.keys(patch).length === 0) delete edits[key];
    else edits[key] = patch;
  }

  function persist(message) {
    const saved = State.saveEdits(window.localStorage, Catalog.storageKey, edits);
    setMessage(saved ? message : 'Không thể ghi localStorage. Hãy xuất JSON để tránh mất dữ liệu.', saved ? 'success' : 'error');
  }

  function copyText(value) {
    if (navigator.clipboard && navigator.clipboard.writeText) return navigator.clipboard.writeText(value);
    const input = document.createElement('textarea');
    input.value = value;
    input.setAttribute('readonly', '');
    input.style.position = 'fixed';
    input.style.opacity = '0';
    document.body.appendChild(input);
    input.select();
    document.execCommand('copy');
    input.remove();
    return Promise.resolve();
  }

  function exportJson() {
    const payload = State.buildExport(Catalog.rows, edits);
    const blob = new Blob([JSON.stringify(payload, null, 2)], { type: 'application/json;charset=utf-8' });
    const url = URL.createObjectURL(blob);
    const anchor = document.createElement('a');
    const date = payload.generatedAt.slice(0, 10);
    anchor.href = url;
    anchor.download = `pham-nhan-affix-balance-${date}.json`;
    document.body.appendChild(anchor);
    anchor.click();
    anchor.remove();
    URL.revokeObjectURL(url);
    setMessage(`Đã xuất JSON với ${Object.keys(edits).length} dòng chỉnh sửa.`, 'success');
  }

  function importJson(file) {
    if (!file) return;
    const reader = new FileReader();
    reader.onload = function () {
      try {
        const payload = JSON.parse(String(reader.result || ''));
        edits = State.importExport(Catalog.rows, payload);
        persist(`Đã nhập ${Object.keys(edits).length} dòng chỉnh sửa.`);
        render();
      } catch (error) {
        setMessage(`Không nhập được JSON: ${error.message}`, 'error');
      }
    };
    reader.onerror = function () { setMessage('Không đọc được file JSON.', 'error'); };
    reader.readAsText(file, 'utf-8');
  }

  function init() {
    if (!State || !Catalog || !View) {
      setMessage('Thiếu module dữ liệu. Hãy mở lại toàn bộ thư mục artifact.', 'error');
      return;
    }
    populateSelect(controls.category, Catalog.rows.map((row) => row.category));
    populateSelect(controls.status, Catalog.rows.map((row) => row.status));
    edits = State.loadEdits(window.localStorage, Catalog.storageKey, Catalog.rows);
    render();

    for (const control of [controls.query, controls.tier, controls.category, controls.status, controls.editedOnly]) {
      control.addEventListener(control === controls.query ? 'input' : 'change', render);
    }

    body.addEventListener('input', function (event) {
      const editor = event.target.closest('.editor');
      if (!editor) return;
      compactPatch(editor.dataset.key, editor.dataset.field, editor.value);
      persist(`Đã tự lưu ${Object.keys(edits).length} dòng chỉnh sửa.`);
      updateSummary(currentRows());
    });

    body.addEventListener('change', function (event) {
      const editor = event.target.closest('.editor');
      if (!editor) return;
      compactPatch(editor.dataset.key, editor.dataset.field, editor.value);
      persist(`Đã tự lưu ${Object.keys(edits).length} dòng chỉnh sửa.`);
      render();
    });

    body.addEventListener('click', function (event) {
      const copy = event.target.closest('.code-copy');
      if (!copy) return;
      copyText(copy.dataset.copy)
        .then(() => setMessage(`Đã sao chép ${copy.dataset.copy}.`, 'success'))
        .catch(() => setMessage('Không thể sao chép code.', 'error'));
    });

    document.getElementById('export-button').addEventListener('click', exportJson);
    document.getElementById('import-button').addEventListener('click', function () {
      document.getElementById('import-file').click();
    });
    document.getElementById('import-file').addEventListener('change', function (event) {
      importJson(event.target.files && event.target.files[0]);
      event.target.value = '';
    });
    document.getElementById('reset-button').addEventListener('click', function () {
      if (!window.confirm('Xóa toàn bộ thông số và ghi chú đã chỉnh trên trình duyệt này?')) return;
      edits = {};
      window.localStorage.removeItem(Catalog.storageKey);
      render();
      setMessage('Đã xóa bản chỉnh. Catalog gốc không bị thay đổi.', 'success');
    });
  }

  init();
})();
