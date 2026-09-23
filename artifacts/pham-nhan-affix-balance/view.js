(function (root, factory) {
  const api = factory();
  if (typeof module === 'object' && module.exports) module.exports = api;
  if (root) root.AffixBalanceView = api;
})(typeof globalThis !== 'undefined' ? globalThis : this, function () {
  'use strict';

  const TIERS = ['I', 'II', 'III', 'IV', 'V', 'UTILITY'];
  const DECISIONS = ['Giữ và cân lại', 'Đánh giá', 'Ưu tiên làm', 'Tạm hoãn', 'Bỏ', 'Cân nhắc'];

  function escapeHtml(value) {
    return String(value ?? '')
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#039;');
  }

  function tierClass(tier) {
    const value = String(tier || '').toLowerCase();
    return ['i', 'ii', 'iii', 'iv', 'v', 'utility'].includes(value)
      ? `tier-${value}`
      : 'tier-none';
  }

  function option(value, selected) {
    return `<option value="${escapeHtml(value)}"${value === selected ? ' selected' : ''}>${escapeHtml(value)}</option>`;
  }

  function renderImage(row) {
    if (!row.imageSrc) return '<span class="image-missing">Chưa gán ảnh</span>';
    return `<figure class="affix-image">
      <img src="${escapeHtml(row.imageSrc)}" alt="Ảnh ${escapeHtml(row.name)}" loading="lazy">
      <figcaption>${escapeHtml(row.imageId)}</figcaption>
    </figure>`;
  }

  function renderRow(row) {
    const key = escapeHtml(row.key);
    const statusClass = row.status === 'Đang có' ? 'status-current'
      : row.status.includes('dùng ngay') ? 'status-ready'
      : 'status-adapter';
    return `
      <tr class="affix-row ${tierClass(row.tier)}" data-key="${key}">
        <td class="tier-cell">
          <select class="tier-select editor" data-key="${key}" data-field="tier" aria-label="Tier của ${escapeHtml(row.name)}">
            ${TIERS.map((tier) => option(tier, row.tier)).join('')}
          </select>
        </td>
        <td class="image-cell">${renderImage(row)}</td>
        <td class="name-cell">
          <strong>${escapeHtml(row.name)}</strong>
          <span>${escapeHtml(row.family)}</span>
        </td>
        <td class="code-cell">
          <button type="button" class="code-copy" data-copy="${escapeHtml(row.code)}" title="Sao chép code">${escapeHtml(row.code)}</button>
          ${row.numericId ? `<span>ID ${escapeHtml(row.numericId)}</span>` : ''}
        </td>
        <td><code>${escapeHtml(row.effectKey)}</code></td>
        <td><strong>${escapeHtml(row.category)}</strong><span class="subline">${escapeHtml(row.slot)}</span></td>
        <td><span class="status ${statusClass}">${escapeHtml(row.status)}</span></td>
        <td class="current-cell">${escapeHtml(row.current)}</td>
        <td class="meaning-cell${row.meaning ? '' : ' is-empty'}">${row.meaning ? escapeHtml(row.meaning) : 'Chưa có mô tả bổ sung.'}</td>
        <td><input class="cell-input editor" data-key="${key}" data-field="proposed" value="${escapeHtml(row.proposed)}" aria-label="Thông số đề xuất của ${escapeHtml(row.name)}"></td>
        <td><input class="cell-input editor" data-key="${key}" data-field="cap" value="${escapeHtml(row.cap)}" placeholder="Chưa đặt cap" aria-label="Cap của ${escapeHtml(row.name)}"></td>
        <td><code>${escapeHtml(row.exclusiveGroup || 'Không')}</code></td>
        <td class="source-cell">${escapeHtml(row.source)}</td>
        <td>
          <select class="decision-select editor" data-key="${key}" data-field="decision" aria-label="Quyết định cho ${escapeHtml(row.name)}">
            ${DECISIONS.map((decision) => option(decision, row.decision)).join('')}
          </select>
        </td>
        <td><input class="cell-input note-input editor" data-key="${key}" data-field="note" value="${escapeHtml(row.note)}" placeholder="Ghi chú cân bằng" aria-label="Ghi chú cho ${escapeHtml(row.name)}"></td>
      </tr>`;
  }

  function summarize(visibleRows, edits) {
    return {
      visible: visibleRows.length,
      current: visibleRows.filter((row) => row.status === 'Đang có').length,
      proposals: visibleRows.filter((row) => row.status.startsWith('Đề xuất')).length,
      utility: visibleRows.filter((row) => row.tier === 'UTILITY').length,
      edited: Object.keys(edits || {}).length,
    };
  }

  return { escapeHtml, tierClass, renderImage, renderRow, summarize };
});
