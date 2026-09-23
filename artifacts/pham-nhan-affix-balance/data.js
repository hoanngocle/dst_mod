(function (root, factory) {
  const api = factory();
  if (typeof module === 'object' && module.exports) module.exports = api;
  if (root) root.AffixBalanceCatalog = api;
})(typeof globalThis !== 'undefined' ? globalThis : this, function () {
  'use strict';

  const rows = [];
  const SOURCE_ENCHANT = 'scripts/enums/hh_enchant.lua';
  const SOURCE_EFFECTS = 'scripts/enums/hh_effects.lua';
  const SOURCE_DUNGEON = 'scripts/components/hh_dungeon_effects.lua';
  const SOURCE_ALCHEMY = 'scripts/components/ttk_alchemy_effects.lua';
  const REMOVED_NOTE = 'Đã loại khỏi thiết kế đá cường hóa.';

  function display(imageId, meaning) {
    return { imageId, imageSrc: `images/affixes/${imageId}.png`, meaning };
  }

  const REVIEWED_DISPLAY_BY_FAMILY = {
    'Bạch Hổ-G': display('B10', 'Giảm phần trăm sát thương nhận vào; cùng tham gia giới hạn giảm sát thương tối đa 80%.'),
    'Bạo Kích': display('B22', 'Tăng tỷ lệ chí mạng và đồng thời tăng sát thương chí mạng.'),
    'Tỷ Lệ Bạo Kích': display('B22', 'Tăng tỷ lệ chí mạng.'),
    'Sát Thương Bạo Kích': display('B22', 'Tăng sát thương chí mạng.'),
    'Thanh Long': display('A06', 'Tăng sát thương đòn chính; cấp IV còn gây Trọng Thương theo máu hiện tại của mục tiêu.'),
    'Hộ Giáp': display('A15', 'Tăng độ bền của giáp; cấp V khiến giáp bền vĩnh cửu.'),
    'Bền Bỉ': display('A03', 'Tăng độ tươi hoặc độ bền tối đa của trang bị phù hợp.'),
    'Nhanh Nhẹn': display('A14', 'Tăng tốc độ di chuyển; pool tốc chạy Phàm Nhân có giới hạn riêng.'),
    'Tốc chạy': display('A14', 'Tăng tốc độ di chuyển; pool tốc chạy Phàm Nhân có giới hạn riêng.'),
    'Đóng Băng': display('A01', 'Đòn đánh có tỷ lệ đóng băng quái thường 2 giây; boss bị chậm 20% trong 2 giây, hồi riêng 5 giây.'),
    'Hạ Độc': display('A04', 'Đòn đánh có tỷ lệ hạ độc; tối đa 5 tầng trong 10 giây, mỗi tầng gây 20% sát thương nền mỗi 2 giây.'),
    'Liên Kích': display('B02', 'Tăng tốc độ đánh; tổng thưởng tốc đánh Phàm Nhân bị giới hạn.'),
    'Bạo Phát': display('A08', 'I: 30% x1,5; II: 20% x2; III: 10% x3; IV: 8% x5 sát thương đòn chính.'),
    'Bạch Hổ': display('B04', 'Giảm sát thương nhận vào trên giáp; cấp IV đạt 80% và miễn Giảm Hồi Máu.'),
    'Gia Trì': display('B18', 'Tự hồi độ bền: I 1/10 giây; II 1/5 giây; III 1/giây; IV 2%/giây; cấp V không mất độ bền.'),
    'Xuyên Giáp': display('B07', 'Gây thêm gói sát thương nền theo phần trăm bỏ qua giáp; tổng tỷ lệ tối đa 40%.'),
  };

  const REVIEWED_DISPLAY_BY_CODE = {
    follow_reduce_damage: display('B12', 'Giảm sát thương nhận vào cho sinh vật đang đi theo người chơi.'),
    follow_add_damage: display('A05', 'Tăng sát thương cho sinh vật đang đi theo người chơi.'),
    fast_act: display('B01', 'Tăng tốc thu hoạch, xây dựng, trao đổi, chế tạo và nướng thức ăn.'),
    work_speed: display('B17', 'Tăng tốc khai thác tài nguyên.'),
    shadow_camp: display('B09', 'Sinh vật Bóng Tối không chủ động tấn công người sở hữu.'),
    moon_camp: display('A10', 'Sinh vật Vô Định hoặc Gestalt không chủ động tấn công người sở hữu.'),
    add_speed: display('A14', 'Tăng tốc độ di chuyển; pool tốc chạy Phàm Nhân có giới hạn riêng.'),
    add_light: display('B13', 'Cho trang bị hoặc người dùng khả năng phát sáng.'),
    blood_outburst: display('B21', 'Máu càng thấp thì sát thương đòn chính càng cao, tối đa +50%.'),
    spirit_fade: display('B06', 'Tinh thần càng thấp thì sát thương đòn chính càng cao, tối đa +50%.'),
    hunger_assault: display('B20', 'Độ no càng thấp thì sát thương đòn chính càng cao, tối đa +50%.'),
    add_immune_cold: display('B15', 'Miễn nhiễm lạnh cóng.'),
    add_immune_hot: display('A11', 'Miễn nhiễm quá nhiệt.'),
    add_immune_poison: display('B14', 'Miễn nhiễm trúng độc.'),
    add_immune_freeze: display('B08', 'Miễn nhiễm đóng băng.'),
    immunity_moisture: display('B11', 'Miễn nhiễm ẩm ướt.'),
    immunity_reduce_speed: display('B19', 'Miễn nhiễm hiệu ứng làm chậm.'),
    immune_sleep: display('A09', 'Miễn nhiễm ru ngủ.'),
    immune_suppress: display('A13', 'Không bị hiệu ứng Giảm Hồi Máu.'),
    immune_debuff: display('B03', 'Miễn nhiễm đồng thời quá nhiệt, lạnh cóng và ẩm ướt.'),
    immune_debuff_2: display('B05', 'Miễn nhiễm đồng thời đóng băng, độc, làm chậm và ru ngủ.'),
    special_zqrf: display('B16', 'Miễn nhiễm toàn bộ: nóng, lạnh, băng, độc, ướt, chậm và ru ngủ.'),
    health_suppress_num: display('A02', 'Đòn chính gây hiệu ứng giảm 90% hồi máu dương của mục tiêu trong 5 giây; không cộng tầng.'),
    atk_blood_suck: display('A12', 'Hồi máu theo phần trăm sát thương hợp lệ thực sự gây ra khi tấn công.'),
    special_xwsh: display('A07', 'Đòn đánh gây Giảm Hồi Máu cho mục tiêu và hồi máu theo sát thương hợp lệ.'),
  };

  function reviewedDisplay(row) {
    return REVIEWED_DISPLAY_BY_CODE[row.code]
      || REVIEWED_DISPLAY_BY_FAMILY[row.family]
      || { imageId: '', imageSrc: '', meaning: '' };
  }

  function add(row) {
    const reviewed = reviewedDisplay(row);
    rows.push({
      numericId: '',
      family: row.name,
      slot: 'Mọi trang bị',
      exclusiveGroup: '',
      cap: '',
      source: SOURCE_ENCHANT,
      decision: row.status === 'Đang có' ? 'Giữ và cân lại' : 'Đánh giá',
      note: '',
      ...row,
      ...reviewed,
      key: row.key || row.code,
    });
  }

  function existingTierFamily(def) {
    for (const entry of def.entries) {
      add({
        family: def.family,
        code: entry.code,
        numericId: String(entry.id ?? ''),
        name: entry.name,
        tier: entry.tier,
        category: def.category,
        slot: def.slot,
        status: 'Đang có',
        effectKey: def.effectKey,
        current: entry.value,
        proposed: entry.value,
        cap: def.cap || '',
        exclusiveGroup: def.exclusiveGroup || '',
        source: entry.source || SOURCE_ENCHANT,
        note: entry.note || def.note || '',
      });
    }
  }

  function proposalFamily(def) {
    const tiers = ['I', 'II', 'III', 'IV', 'V'];
    tiers.forEach((tier, index) => add({
      family: def.family,
      code: `${def.code}_${tier.toLowerCase()}`,
      name: `${def.family} ${tier}`,
      tier,
      category: def.category,
      slot: def.slot,
      status: def.status,
      effectKey: def.effectKey,
      current: 'Chưa có',
      proposed: def.values[index],
      cap: def.cap || '',
      exclusiveGroup: def.exclusiveGroup || '',
      source: def.source,
      decision: def.decision || 'Đánh giá',
      note: def.note || '',
    }));
  }

  function utility(def) {
    add({
      family: def.name,
      code: def.code,
      name: def.name,
      tier: 'UTILITY',
      category: 'Tiện ích',
      slot: def.slot || 'Mọi trang bị',
      status: def.status || 'Đề xuất - adapter',
      effectKey: def.effectKey,
      current: 'Chưa có',
      proposed: def.value,
      cap: def.cap || '1 hiệu ứng',
      exclusiveGroup: def.exclusiveGroup || 'utility',
      source: def.source,
      decision: def.decision || 'Đánh giá',
      note: def.note || '',
    });
  }

  // Workbench giữ cả các dòng đã bị loại để theo dõi lịch sử quyết định cân bằng.
  add({ code:'follow_reduce_damage', numericId:'96', name:'Trợ Thủ-PT', family:'Trợ thủ phòng thủ', tier:'IV', category:'Đệ tử', slot:'Mọi trang bị', status:'Đang có', effectKey:'addFollowReduceDamage', current:'Giảm 5-10 ST đệ tử nhận', proposed:'Giảm 5-10 ST đệ tử nhận', source:SOURCE_ENCHANT, decision:'Bỏ', note:REMOVED_NOTE });
  add({ code:'follow_add_damage', numericId:'95', name:'Trợ Thủ-TC', family:'Trợ thủ tấn công', tier:'IV', category:'Đệ tử', slot:'Mọi trang bị', status:'Đang có', effectKey:'addFollowDamage', current:'Tăng 10-20 ST đệ tử', proposed:'Tăng 10-20 ST đệ tử', source:SOURCE_ENCHANT, decision:'Bỏ', note:REMOVED_NOTE });
  add({ code:'fast_act', numericId:'94', name:'Tháo Vát-TH', family:'Tương tác nhanh', tier:'UTILITY', category:'Tiện ích', slot:'Mọi trang bị', status:'Đang có', effectKey:'fast_act', current:'Tăng tốc thu hoạch, xây, đổi, chế tạo, nấu', proposed:'Giữ nguyên', source:SOURCE_ENCHANT });
  add({ code:'work_speed', numericId:'93', name:'Tháo Vát-KT', family:'Khai thác nhanh', tier:'UTILITY', category:'Tiện ích', slot:'Mọi trang bị', status:'Đang có', effectKey:'workAddSpeed', current:'Gấp đôi tốc độ làm việc', proposed:'Gấp đôi tốc độ làm việc', source:SOURCE_ENCHANT });
  add({ code:'shadow_camp', numericId:'92', name:'Phục Ma-BT', family:'Thân thiện Shadow', tier:'UTILITY', category:'Tiện ích', slot:'Mọi trang bị', status:'Đang có', effectKey:'shadowCamp', current:'Sinh vật shadow không tấn công', proposed:'Giữ nguyên', source:SOURCE_ENCHANT });
  add({ code:'moon_camp', numericId:'91', name:'Phục Ma-VĐ', family:'Thân thiện Gestalt', tier:'UTILITY', category:'Tiện ích', slot:'Mọi trang bị', status:'Đang có', effectKey:'moonCamp', current:'Sinh vật gestalt không tấn công', proposed:'Giữ nguyên', source:SOURCE_ENCHANT });
  add({ code:'add_speed', numericId:'89', name:'Nhanh Nhẹn', family:'Tốc chạy', tier:'III', category:'Cơ động', slot:'Vũ khí', status:'Đang có', effectKey:'addSpeedPercent', current:'5-25%', proposed:'5-25%', source:SOURCE_ENCHANT, decision:'Bỏ', note:REMOVED_NOTE });
  proposalFamily({ family:'Nhanh Nhẹn', code:'equip_speed', effectKey:'addSpeedPercent', category:'Cơ động', slot:'Vũ khí', status:'Đề xuất - adapter', values:['1-5%','3-10%','5-15%','10-20%','15-30%'], exclusiveGroup:'move_speed', source:`${SOURCE_ENCHANT} + ${SOURCE_EFFECTS}`, decision:'Bỏ', note:REMOVED_NOTE });
  add({ code:'add_light', numericId:'90', name:'☆Phổ Độ', family:'Phát sáng', tier:'UTILITY', category:'Tiện ích', slot:'Mọi trang bị', status:'Đang có', effectKey:'add_light', current:'Phát sáng khi trang bị', proposed:'Giữ nguyên', source:SOURCE_ENCHANT });

  existingTierFamily({ family:'Bền Bỉ', category:'Độ bền', slot:'Trang bị có độ bền', effectKey:'add_max_use', entries:[
    {tier:'I', code:'add_max_use_small', id:87, name:'Bền Bỉ I', value:'+20-80 độ bền'},
    {tier:'II', code:'add_max_use_big', id:88, name:'Bền Bỉ II', value:'+40-160 độ bền'},
  ]});
  add({ code:'add_max_use_tier_iii', name:'Bền Bỉ III', family:'Bền Bỉ', tier:'III', category:'Độ bền', slot:'Trang bị có độ bền', status:'Đề xuất - dùng ngay', effectKey:'add_max_use', current:'Chưa có', proposed:'+120-280 độ bền', cap:'Chỉ 1 viên Bền Bỉ', exclusiveGroup:'durability_capacity', source:SOURCE_ENCHANT, note:'Dùng lại cơ chế cộng độ bền tối đa hiện có.' });
  add({ code:'add_max_use_tier_iv', name:'Bền Bỉ IV', family:'Bền Bỉ', tier:'IV', category:'Độ bền', slot:'Trang bị có độ bền', status:'Đề xuất - dùng ngay', effectKey:'add_max_use', current:'Chưa có', proposed:'+240-400 độ bền', cap:'Chỉ 1 viên Bền Bỉ', exclusiveGroup:'durability_capacity', source:SOURCE_ENCHANT, note:'Dùng lại cơ chế cộng độ bền tối đa hiện có.' });
  add({ code:'add_max_use_tier_v', name:'Bền Bỉ V', family:'Bền Bỉ', tier:'V', category:'Độ bền', slot:'Trang bị có độ bền', status:'Đề xuất - dùng ngay', effectKey:'add_max_use', current:'Chưa có', proposed:'+360-640 độ bền', cap:'Chỉ 1 viên Bền Bỉ', exclusiveGroup:'durability_capacity', source:SOURCE_ENCHANT, note:'Dùng lại cơ chế cộng độ bền tối đa hiện có.' });
  existingTierFamily({ family:'Bạo Kích', category:'Tấn công', slot:'Không phải giáp', effectKey:'criticalHitRate + criticalHitEffect', entries:[
    {tier:'I', code:'add_critical_hit_rate_small', id:79, name:'Bạo Kích I', value:'+1-10% tỷ lệ và ST chí mạng'},
    {tier:'II', code:'add_critical_hit_rate_med', id:80, name:'Bạo Kích II', value:'+1-20% tỷ lệ và ST chí mạng'},
    {tier:'III', code:'add_critical_hit_rate_big', id:77, name:'☆Bạo Kích III', value:'+1-30% tỷ lệ và ST chí mạng'},
    {tier:'IV', code:'add_critical_hit_rate_special', id:78, name:'★Bạo Kích IV', value:'+1-50% tỷ lệ và ST chí mạng'},
  ]});
  proposalFamily({ family:'Tỷ Lệ Bạo Kích', code:'equip_critical_rate', effectKey:'criticalHitRate', category:'Tấn công', slot:'Không phải giáp', status:'Đề xuất - adapter', values:['1-5%','3-10%','5-15%','10-20%','15-30%'], cap:'Tổng 100%', exclusiveGroup:'critical_rate', source:`${SOURCE_ENCHANT} + ${SOURCE_EFFECTS}`, note:'Tách phần tỷ lệ khỏi Bạo Kích cũ. Effect key đã có, cần affix riêng.' });
  proposalFamily({ family:'Sát Thương Bạo Kích', code:'equip_critical_damage', effectKey:'criticalHitEffect', category:'Tấn công', slot:'Không phải giáp', status:'Đề xuất - adapter', values:['2-10%','6-20%','10-30%','20-40%','30-60%'], cap:'Không cap', exclusiveGroup:'critical_damage', source:`${SOURCE_ENCHANT} + ${SOURCE_EFFECTS}`, note:'Mỗi khoảng gấp đôi khoảng Tỷ Lệ Bạo Kích cùng tier.' });
  existingTierFamily({ family:'Liên Kích', category:'Tấn công', slot:'Vũ khí', effectKey:'atk_speed', exclusiveGroup:'attack_speed', entries:[
    {tier:'I', code:'atk_speed_small', id:75, name:'Liên Kích I', value:'+5-10% tốc đánh'},
    {tier:'II', code:'atk_speed_med', id:76, name:'Liên Kích II', value:'+15-25% tốc đánh'},
    {tier:'III', code:'atk_speed_big', id:73, name:'☆Liên Kích III', value:'+30-45% tốc đánh'},
    {tier:'IV', code:'atk_speed_special', id:74, name:'★Liên Kích IV', value:'+50-70% tốc đánh'},
  ]});
  existingTierFamily({ family:'Gia Trì', category:'Độ bền', slot:'Trang bị có độ bền', effectKey:'durabilityRegen', entries:[
    {tier:'I', code:'restore_use_10s_1use', id:71, name:'Gia Trì I', value:'Hồi 1 độ bền mỗi 10 giây'},
    {tier:'II', code:'restore_use_5s_1use', id:72, name:'Gia Trì II', value:'Hồi 1 độ bền mỗi 5 giây'},
    {tier:'III', code:'restore_use_1s_1use', id:69, name:'☆Gia Trì III', value:'Hồi 1 độ bền mỗi giây'},
    {tier:'IV', code:'restore_use_1s_2_percent', id:70, name:'★Gia Trì IV', value:'Hồi 2% độ bền mỗi giây'},
  ]});
  add({ code:'durability_immune_amount', name:'★Gia Trì V', family:'Gia Trì', tier:'V', category:'Độ bền', slot:'Trang bị có độ bền', status:'Đề xuất - adapter', effectKey:'durabilityImmune', current:'Chưa có', proposed:'Đồ không mất độ bền', cap:'Chỉ 1 viên Gia Trì', exclusiveGroup:'durability_regen', source:SOURCE_ENCHANT, note:'Đề xuất web, chưa triển khai trong runtime.' });
  existingTierFamily({ family:'Hộ Giáp', category:'Độ bền', slot:'Giáp', effectKey:'armorDurability', entries:[
    {tier:'I', code:'add_max_use_armor_01', id:67, name:'Hộ Giáp I', value:'+200-500 độ bền giáp'},
    {tier:'II', code:'add_max_use_armor_02', id:68, name:'Hộ Giáp II', value:'+500-1000 độ bền giáp'},
    {tier:'III', code:'add_max_use_armor_03', id:65, name:'☆Hộ Giáp III', value:'+1000-3000 độ bền giáp'},
  ]});
  add({ code:'add_max_use_armor_04', name:'★Hộ Giáp IV', family:'Hộ Giáp', tier:'IV', category:'Độ bền', slot:'Giáp', status:'Đề xuất - dùng ngay', effectKey:'armorDurability', current:'Chưa có', proposed:'+2000-5000 độ bền giáp', cap:'Chỉ 1 viên Hộ Giáp', exclusiveGroup:'armor_durability', source:SOURCE_ENCHANT, note:'Dùng lại cơ chế cộng độ bền giáp hiện có.' });
  add({ code:'armor_immune_amount', numericId:'66', name:'★Hộ Giáp V', family:'Hộ Giáp', tier:'V', category:'Độ bền', slot:'Giáp', status:'Đang có', effectKey:'armorDurability', current:'Giáp không mất độ bền', proposed:'Giáp không mất độ bền', cap:'Chỉ 1 viên Hộ Giáp', exclusiveGroup:'armor_durability', source:SOURCE_ENCHANT, note:'value_range 10-80 không tham gia hiệu ứng chính.' });
  existingTierFamily({ family:'Xuyên Giáp', category:'Tấn công', slot:'Vũ khí', effectKey:'trueDamageNum', cap:'Tổng 40%', exclusiveGroup:'armor_pierce', entries:[
    {tier:'I', code:'true_damage_small', id:63, name:'Xuyên Giáp I', value:'3-5% ST đòn chính bỏ qua giáp'},
    {tier:'II', code:'true_damage_med', id:64, name:'Xuyên Giáp II', value:'6-10% ST đòn chính bỏ qua giáp'},
    {tier:'III', code:'true_damage_big', id:61, name:'☆Xuyên Giáp III', value:'11-15% ST đòn chính bỏ qua giáp'},
    {tier:'IV', code:'true_damage_special', id:62, name:'★Xuyên Giáp IV', value:'16-20% ST đòn chính bỏ qua giáp'},
  ]});
  add({ code:'blood_outburst', numericId:'50', name:'Nghịch Cảnh-Máu', family:'Nghịch Cảnh', tier:'III', category:'Tấn công', slot:'Vũ khí', status:'Đang có', effectKey:'bloodOutburst', current:'Máu càng thấp, ST càng cao, tối đa 50%', proposed:'Tối đa 50%', cap:'Chỉ 1 loại Nghịch Cảnh', exclusiveGroup:'adversity', source:SOURCE_ENCHANT });
  add({ code:'spirit_fade', numericId:'48', name:'Nghịch Cảnh-Não', family:'Nghịch Cảnh', tier:'III', category:'Tấn công', slot:'Vũ khí', status:'Đang có', effectKey:'spiritFade', current:'Tinh thần càng thấp, ST càng cao, tối đa 50%', proposed:'Tối đa 50%', cap:'Chỉ 1 loại Nghịch Cảnh', exclusiveGroup:'adversity', source:SOURCE_ENCHANT });
  add({ code:'hunger_assault', numericId:'47', name:'Nghịch Cảnh-Đói', family:'Nghịch Cảnh', tier:'III', category:'Tấn công', slot:'Vũ khí', status:'Đang có', effectKey:'hungerAssault', current:'Độ no càng thấp, ST càng cao, tối đa 50%', proposed:'Tối đa 50%', cap:'Chỉ 1 loại Nghịch Cảnh', exclusiveGroup:'adversity', source:SOURCE_ENCHANT });
  existingTierFamily({ family:'Thanh Long', category:'Tấn công', slot:'Vũ khí', effectKey:'addComDamagePercent', exclusiveGroup:'dragon_damage', entries:[
    {tier:'I', code:'add_damage_small', id:33, name:'Thanh Long I', value:'+3-5% ST đòn chính'},
    {tier:'II', code:'add_damage_med', id:34, name:'Thanh Long II', value:'+6-10% ST đòn chính'},
    {tier:'III', code:'add_damage_big', id:31, name:'☆Thanh Long III', value:'+11-15% ST đòn chính'},
    {tier:'IV', code:'special_bhtg', id:32, name:'★Thanh Long IV', value:'+16-20% ST; Trọng Thương 3%, Boss 1%', note:'Trọng Thương tính theo máu hiện tại.'},
  ]});
  existingTierFamily({ family:'Bạch Hổ-G', category:'Phòng thủ', slot:'Mọi trang bị', effectKey:'absorbDamage', cap:'Tổng 80%', entries:[
    {tier:'I', code:'absorb_small', id:27, name:'Bạch Hổ-G1', value:'Giảm 1-5% ST nhận'},
    {tier:'II', code:'absorb_mid', id:28, name:'Bạch Hổ-G2', value:'Giảm 1-15% ST nhận'},
    {tier:'III', code:'absorb_big', id:25, name:'Bạch Hổ-G3', value:'Giảm 1-25% ST nhận'},
    {tier:'IV', code:'absorb_special', id:26, name:'☆Bạch Hổ-G4', value:'Giảm 1-35% ST nhận'},
  ]});
  existingTierFamily({ family:'Bạch Hổ', category:'Phòng thủ', slot:'Giáp', effectKey:'absorbDamage', cap:'Tổng 80%', entries:[
    {tier:'I', code:'reduce_damage_small', id:23, name:'Bạch Hổ I', value:'Giảm 1-5% ST nhận'},
    {tier:'II', code:'reduce_damage_mid', id:24, name:'Bạch Hổ II', value:'Giảm 5-15% ST nhận'},
    {tier:'III', code:'reduce_damage_big', id:21, name:'☆Bạch Hổ III', value:'Giảm 10-25% ST nhận'},
    {tier:'IV', code:'special_sgsy', id:22, name:'★Bạch Hổ IV', value:'Giảm cố định 80% ST và miễn Giảm Hồi Máu', note:'value_range 1-1000 không được dùng bởi runtime.'},
  ]});

  add({ code:'add_immune_cold', numericId:'20', name:'Huyền Vũ-Lạnh', family:'Huyền Vũ', tier:'II', category:'Kháng hiệu ứng', slot:'Mọi trang bị', status:'Đang có', effectKey:'immuneCold', current:'Miễn lạnh cóng', proposed:'Miễn lạnh cóng', source:SOURCE_ENCHANT });
  add({ code:'add_immune_hot', numericId:'19', name:'Huyền Vũ-Nóng', family:'Huyền Vũ', tier:'II', category:'Kháng hiệu ứng', slot:'Mọi trang bị', status:'Đang có', effectKey:'immuneHot', current:'Miễn quá nhiệt', proposed:'Miễn quá nhiệt', source:SOURCE_ENCHANT });
  add({ code:'add_immune_poison', numericId:'18', name:'Huyền Vũ-Độc', family:'Huyền Vũ', tier:'II', category:'Kháng hiệu ứng', slot:'Mọi trang bị', status:'Đang có', effectKey:'immunePoison', current:'Miễn trúng độc', proposed:'Miễn trúng độc', source:SOURCE_ENCHANT });
  add({ code:'add_immune_freeze', numericId:'17', name:'Huyền Vũ-Băng', family:'Huyền Vũ', tier:'II', category:'Kháng hiệu ứng', slot:'Mọi trang bị', status:'Đang có', effectKey:'immuneFreeze', current:'Miễn đóng băng', proposed:'Miễn đóng băng', source:SOURCE_ENCHANT });
  add({ code:'immunity_moisture', numericId:'16', name:'Huyền Vũ-Ướt', family:'Huyền Vũ', tier:'II', category:'Kháng hiệu ứng', slot:'Mọi trang bị', status:'Đang có', effectKey:'immunityMoisture', current:'Miễn ẩm ướt', proposed:'Miễn ẩm ướt', source:SOURCE_ENCHANT });
  add({ code:'immunity_reduce_speed', numericId:'15', name:'Huyền Vũ-Chậm', family:'Huyền Vũ', tier:'II', category:'Kháng hiệu ứng', slot:'Mọi trang bị', status:'Đang có', effectKey:'immuneReduceSpeed + porter', current:'Miễn làm chậm', proposed:'Miễn làm chậm', source:SOURCE_ENCHANT, note:'value_range 10-80 hiện không được dùng.' });
  add({ code:'immune_sleep', numericId:'13', name:'Huyền Vũ-Ngủ', family:'Huyền Vũ', tier:'II', category:'Kháng hiệu ứng', slot:'Mọi trang bị', status:'Đang có', effectKey:'immunitySleep', current:'Miễn ru ngủ', proposed:'Miễn ru ngủ', source:SOURCE_ENCHANT });
  add({ code:'immune_suppress', numericId:'11', name:'Miễn Giảm Hồi Máu', family:'Huyền Vũ', tier:'III', category:'Kháng hiệu ứng', slot:'Mọi trang bị', status:'Đang có', effectKey:'immuneSuppressNum', current:'Miễn Giảm Hồi Máu', proposed:'Miễn Giảm Hồi Máu', source:SOURCE_ENCHANT });
  add({ code:'immune_debuff', numericId:'12', name:'☆Huyền Vũ-TT', family:'Huyền Vũ tổ hợp', tier:'III', category:'Kháng hiệu ứng', slot:'Mọi trang bị', status:'Đang có', effectKey:'immuneHot + immuneCold + immunityMoisture', current:'Miễn nóng, lạnh và ướt', proposed:'Miễn nóng, lạnh và ướt', source:SOURCE_ENCHANT });
  add({ code:'immune_debuff_2', numericId:'9', name:'☆Huyền Vũ-KC', family:'Huyền Vũ tổ hợp', tier:'III', category:'Kháng hiệu ứng', slot:'Mọi trang bị', status:'Đang có', effectKey:'immuneFreeze + immunePoison + immuneReduceSpeed + immunitySleep', current:'Miễn băng, độc, chậm và ngủ', proposed:'Miễn băng, độc, chậm và ngủ', source:SOURCE_ENCHANT });
  add({ code:'special_zqrf', numericId:'10', name:'★Huyền Vũ-BX', family:'Huyền Vũ tổ hợp', tier:'IV', category:'Kháng hiệu ứng', slot:'Mọi trang bị', status:'Đang có', effectKey:'allStatusImmunity', current:'Miễn nóng, lạnh, băng, độc, ướt, chậm và ngủ', proposed:'Giữ nguyên', source:SOURCE_ENCHANT });
  add({ code:'health_suppress_num', numericId:'3', name:'Giảm Hồi Máu', family:'Giảm Hồi Máu', tier:'I', category:'Tấn công', slot:'Vũ khí', status:'Đang có', effectKey:'addSuppressAddHealth', current:'10-50% xác suất gây Giảm Hồi Máu', proposed:'10-50%', source:SOURCE_ENCHANT });
  add({ code:'atk_blood_suck', numericId:'1', name:'☆Chu Tước-HM', family:'Chu Tước', tier:'III', category:'Hồi phục', slot:'Vũ khí', status:'Đang có', effectKey:'bloodSuck', current:'Hút 1-3% ST hợp lệ', proposed:'1-3%', source:SOURCE_ENCHANT });
  add({ code:'special_xwsh', numericId:'2', name:'★Chu Tước-TM', family:'Chu Tước', tier:'IV', category:'Hồi phục', slot:'Vũ khí', status:'Đang có', effectKey:'bloodSuck + addSuppressAddHealth', current:'Hút 2-5% ST và gây Giảm Hồi Máu', proposed:'2-5%', source:SOURCE_ENCHANT });

  existingTierFamily({ family:'Bạo Phát', category:'Tấn công', slot:'Vũ khí', effectKey:'moreDamage proc', exclusiveGroup:'burst', entries:[
    {tier:'I', code:'more_damage_30_150', id:97, name:'Bạo Phát I', value:'30% gây x1,5 ST đòn chính'},
    {tier:'II', code:'more_damage_20_200', id:98, name:'Bạo Phát II', value:'20% gây x2 ST đòn chính'},
    {tier:'III', code:'more_damage_15_300', id:99, name:'Bạo Phát III', value:'10% gây x3 ST đòn chính', note:'ID lịch sử còn ghi 15 nhưng runtime dùng 10%.'},
    {tier:'IV', code:'more_damage_8_500', id:100, name:'Bạo Phát IV', value:'8% gây x5 ST đòn chính'},
  ]});
  existingTierFamily({ family:'Hạ Độc', category:'Hiệu ứng đòn đánh', slot:'Vũ khí', effectKey:'atkAddPoisonChance', exclusiveGroup:'poison', note:'Tối đa 5 tầng. Mỗi tầng gây 20% ST đòn đánh mỗi 2 giây trong 10 giây.', entries:[
    {tier:'I', code:'atk_add_poison_small', id:101, name:'Hạ Độc I', value:'10% xác suất'},
    {tier:'II', code:'atk_add_poison_med', id:102, name:'Hạ Độc II', value:'20% xác suất'},
    {tier:'III', code:'atk_add_poison_big', id:103, name:'Hạ Độc III', value:'30% xác suất'},
    {tier:'IV', code:'atk_add_poison_special', id:104, name:'Hạ Độc IV', value:'40% xác suất'},
  ]});
  existingTierFamily({ family:'Đóng Băng', category:'Hiệu ứng đòn đánh', slot:'Vũ khí', effectKey:'atkChanceAddFreeze', exclusiveGroup:'freeze', note:'Đóng băng 2 giây. Boss bị chậm 20% trong 2 giây. Hồi nội bộ 5 giây.', entries:[
    {tier:'I', code:'atk_add_freeze_small', id:105, name:'Đóng Băng I', value:'5% xác suất'},
    {tier:'II', code:'atk_add_freeze_med', id:106, name:'Đóng Băng II', value:'10% xác suất'},
    {tier:'III', code:'atk_add_freeze_big', id:107, name:'Đóng Băng III', value:'15% xác suất'},
    {tier:'IV', code:'atk_add_freeze_special', id:108, name:'Đóng Băng IV', value:'20% xác suất'},
  ]});

  // Family đề xuất: tất cả chỉ tồn tại khi trang bị món đồ.
  proposalFamily({ family:'Ảnh Bộ', code:'equip_dodge', effectKey:'chanceDodgeAttack', category:'Phòng thủ', slot:'Giày, giáp hoặc phụ kiện', status:'Đề xuất - dùng ngay', values:['2%','4%','6%','9%','12%'], cap:'Tổng né 70%; phần từ đá nên tối đa 20%', exclusiveGroup:'dodge', source:`${SOURCE_EFFECTS} + scripts/components/hh_player.lua`, note:'Runtime né đã có và đang clamp tổng ở 70%.' });
  proposalFamily({ family:'Chấn Kích', code:'equip_splash', effectKey:'addSplashDamageAOE', category:'Tấn công', slot:'Vũ khí', status:'Đề xuất - dùng ngay', values:['5%','8%','12%','18%','25%'], cap:'Tổng 60%', exclusiveGroup:'splash', source:`${SOURCE_EFFECTS} + scripts/combat/hh_combat_status.lua`, note:'Sát thương lan trong bán kính 3, không đánh đồng minh.' });
  proposalFamily({ family:'Đoạt Mệnh', code:'equip_execute', effectKey:'killUnderThreshold', category:'Tấn công', slot:'Vũ khí', status:'Đề xuất - adapter', values:['3% máu','5% máu','7% máu','10% máu','15% máu'], cap:'Không áp dụng Boss', exclusiveGroup:'finisher', source:'scripts/combat/hh_combat_status.lua', note:'Code hiện coi effect là boolean và kết liễu cố định ở 15%. Cần đọc giá trị tier.' });
  proposalFamily({ family:'Trảm Yêu', code:'equip_boss_damage', effectKey:'bossDamagePercent', category:'Tấn công', slot:'Vũ khí', status:'Đề xuất - adapter', values:['3%','5%','8%','12%','18%'], cap:'Tổng 30%', exclusiveGroup:'boss_damage', source:SOURCE_DUNGEON, note:'Chuyển cơ chế Beru Săn Boss thành modifier cho người chơi.' });
  proposalFamily({ family:'Phá Cương', code:'equip_armor_break', effectKey:'armorBreakChance', category:'Hiệu ứng đòn đánh', slot:'Vũ khí', status:'Đề xuất - adapter', values:['5%','8%','12%','16%','20%'], cap:'Debuff cố định 10%, 5 giây', exclusiveGroup:'armor_break', source:'scripts/enums/hh_monster.lua', note:'Mượn cơ chế atkAddArmorReduceBuff của quái. Cần cooldown nội bộ.' });
  proposalFamily({ family:'Lôi Linh', code:'equip_lightning_proc', effectKey:'lightningProcDamage', category:'Hiệu ứng đòn đánh', slot:'Vũ khí', status:'Đề xuất - adapter', values:['15 ST','30 ST','50 ST','75 ST','110 ST'], cap:'15% proc; hồi nội bộ 1 giây', exclusiveGroup:'element_proc', source:SOURCE_ALCHEMY, note:'Không dùng mức 180 ST trên mọi đòn của đan dược.' });
  proposalFamily({ family:'Nhật Sát', code:'equip_day_damage', effectKey:'dayDamagePercent', category:'Tấn công điều kiện', slot:'Vũ khí', status:'Đề xuất - adapter', values:['4%','7%','10%','15%','22%'], cap:'Chỉ hoạt động ban ngày', exclusiveGroup:'time_damage', source:'scripts/enums/hh_monster.lua', note:'Mượn cơ chế sunlightStrike của quái.' });
  proposalFamily({ family:'Dạ Sát', code:'equip_night_damage', effectKey:'nightDamagePercent', category:'Tấn công điều kiện', slot:'Vũ khí', status:'Đề xuất - adapter', values:['4%','7%','10%','15%','22%'], cap:'Chỉ hoạt động ban đêm', exclusiveGroup:'time_damage', source:'scripts/enums/hh_monster.lua', note:'Mượn cơ chế nightMenace của quái.' });
  proposalFamily({ family:'Hộ Mệnh', code:'equip_max_health', effectKey:'equipMaxHealthPercent', category:'Sinh tồn', slot:'Giáp hoặc phụ kiện', status:'Đề xuất - adapter', values:['5%','8%','12%','16%','22%'], cap:'Tổng từ đá 35%', exclusiveGroup:'max_health', source:SOURCE_DUNGEON, note:'Dùng external health modifier và hoàn nguyên đúng khi tháo đồ.' });
  proposalFamily({ family:'Sinh Cơ', code:'equip_health_regen', effectKey:'equipHealthRegen', category:'Hồi phục', slot:'Giáp hoặc phụ kiện', status:'Đề xuất - adapter', values:['0,2 HP/s','0,4 HP/s','0,7 HP/s','1 HP/s','1,5 HP/s'], cap:'Tổng 2 HP/s', exclusiveGroup:'health_regen', source:`${SOURCE_DUNGEON} + ${SOURCE_ALCHEMY}`, note:'Dùng hồi phẳng để không phình theo máu tối đa.' });
  proposalFamily({ family:'Linh Hải', code:'equip_max_mana', effectKey:'equipMaxMana', category:'Mana', slot:'Mũ hoặc phụ kiện', status:'Đề xuất - adapter', values:['+10','+20','+30','+45','+65'], cap:'Tổng từ đá +100 mana', exclusiveGroup:'mana_pool', source:'scripts/components/hh_mana.lua', note:'Cần cộng nguồn trang bị vào RecalculateMax.' });
  proposalFamily({ family:'Tụ Linh', code:'equip_mana_regen', effectKey:'equipManaRegen', category:'Mana', slot:'Mũ hoặc phụ kiện', status:'Đề xuất - adapter', values:['+0,1/s','+0,2/s','+0,35/s','+0,5/s','+0,75/s'], cap:'Tổng từ đá +1 mana/s', exclusiveGroup:'mana_regen', source:'scripts/components/hh_mana.lua', note:'Cộng vào GetRegenPerSecond, vẫn tôn trọng trì hoãn hồi mana.' });
  proposalFamily({ family:'Tiết Linh', code:'equip_mana_save', effectKey:'equipManaCostReduction', category:'Mana', slot:'Mũ hoặc phụ kiện', status:'Đề xuất - adapter', values:['3%','5%','8%','12%','18%'], cap:'Tổng giảm mana 50%', exclusiveGroup:'mana_cost', source:`scripts/components/hh_mana.lua + ${SOURCE_DUNGEON}`, note:'Áp dụng cho kỹ năng và chi phí duy trì, không cho chi phí bằng vật phẩm.' });
  proposalFamily({ family:'Ngộ Đạo', code:'equip_skill_cooldown', effectKey:'skillCooldownReduction', category:'Kỹ năng', slot:'Mũ hoặc phụ kiện', status:'Đề xuất - adapter', values:['2%','4%','6%','8%','12%'], cap:'Tổng 30%', exclusiveGroup:'cooldown', source:'scripts/components/hh_shadow_manager.lua + components kỹ năng', note:'Giảm phần cooldown mới tạo, không tua ngược timer đang chạy.' });
  proposalFamily({ family:'Trợ Kích', code:'equip_follower_crit', effectKey:'addFollowCritical', category:'Đệ tử', slot:'Mọi trang bị', status:'Đề xuất - dùng ngay', values:['3%','5%','8%','12%','18%'], cap:'Tổng 40%', exclusiveGroup:'follower_crit', source:`${SOURCE_EFFECTS} + main/hh_api.lua`, decision:'Bỏ', note:REMOVED_NOTE });
  proposalFamily({ family:'Hắc Sinh Mệnh', code:'equip_shadow_health', effectKey:'shadowHealthPercent', category:'Đệ tử', slot:'Mọi trang bị', status:'Đề xuất - adapter', values:['3-8%','7-15%','14-24%','23-32%','31-40%'], cap:'Tổng 40%', exclusiveGroup:'shadow_health', source:SOURCE_DUNGEON, note:'Mỗi viên ngọc random một giá trị trong range của tier.' });
  proposalFamily({ family:'Hắc Công Kích', code:'equip_shadow_damage', effectKey:'shadowDamagePercent', category:'Đệ tử', slot:'Mọi trang bị', status:'Đề xuất - adapter', values:['2-4%','3-7%','6-11%','10-15%','14-20%'], cap:'Tổng 20%', exclusiveGroup:'shadow_damage', source:SOURCE_DUNGEON, note:'Mỗi viên ngọc random một giá trị trong range của tier.' });
  proposalFamily({ family:'Hắc Phòng Ngự', code:'equip_shadow_guard', effectKey:'shadowGuardPercent', category:'Đệ tử', slot:'Mọi trang bị', status:'Đề xuất - adapter', values:['3%','5%','8%','12%','16%'], cap:'Tổng 30%', exclusiveGroup:'shadow_guard', source:SOURCE_DUNGEON, decision:'Bỏ', note:REMOVED_NOTE });
  proposalFamily({ family:'Hắc Tốc Hành', code:'equip_shadow_speed', effectKey:'shadowSpeedPercent', category:'Đệ tử', slot:'Mọi trang bị', status:'Đề xuất - adapter', values:['5%','8%','12%','16%','22%'], cap:'Tổng 35%', exclusiveGroup:'shadow_speed', source:SOURCE_DUNGEON, decision:'Bỏ', note:REMOVED_NOTE });
  proposalFamily({ family:'Hắc Liên Kích', code:'equip_shadow_attack_speed', effectKey:'shadowAttackSpeed', category:'Đệ tử', slot:'Mọi trang bị', status:'Đề xuất - adapter', values:['3%','5%','8%','11%','15%'], cap:'Tổng 25%', exclusiveGroup:'shadow_attack_speed', source:SOURCE_DUNGEON, decision:'Bỏ', note:REMOVED_NOTE });
  proposalFamily({ family:'Hắc Tái Sinh', code:'equip_shadow_regen', effectKey:'shadowHealthRegen', category:'Đệ tử', slot:'Mọi trang bị', status:'Đề xuất - adapter', values:['0,1%/s','0,2%/s','0,3%/s','0,5%/s','0,75%/s'], cap:'Tổng 1% máu tối đa mỗi giây', exclusiveGroup:'shadow_regen', source:SOURCE_DUNGEON, decision:'Bỏ', note:REMOVED_NOTE });
  proposalFamily({ family:'Quân Đoàn Ma', code:'equip_shadow_mana', effectKey:'shadowManaReduction', category:'Đệ tử', slot:'Mũ hoặc phụ kiện', status:'Đề xuất - adapter', values:['3%','5%','8%','12%','18%'], cap:'Tổng 40%', exclusiveGroup:'shadow_mana', source:`scripts/components/hh_mana.lua + ${SOURCE_DUNGEON}`, decision:'Bỏ', note:REMOVED_NOTE });

  utility({ name:'Nhiếp Vật', code:'utility_auto_pickup', effectKey:'utilityAutoPickup', value:'Tự nhặt trong bán kính 6', source:SOURCE_DUNGEON, note:'Mượn OrangeAmuletPickup. Không nhặt đồ đang cháy, trong container hoặc thuộc người khác.' });
  utility({ name:'Bền Lực', code:'utility_durability_save', effectKey:'utilityDurabilitySave', value:'25% không hao độ bền', source:SOURCE_DUNGEON, decision:'Bỏ', note:REMOVED_NOTE });
  utility({ name:'Bích Cốc', code:'utility_hunger_rate', effectKey:'utilityHungerRate', value:'Giảm 25% tốc độ hao đói', source:SOURCE_ALCHEMY, note:'Không dùng mức giảm 80% của Bích Cốc Đan.' });
  utility({ name:'Cường Kình', code:'utility_work_efficiency', effectKey:'utilityWorkEfficiency', value:'+35% hiệu suất chặt, đập và đào', source:SOURCE_ALCHEMY, note:'Không tăng tốc đào đất, hái hoặc thu hoạch.' });
  utility({ name:'Hàn Ngọc', code:'utility_cold_protection', effectKey:'utilityColdProtection', value:'+120 cách nhiệt mùa đông', source:SOURCE_ALCHEMY, note:'Là chống lạnh, không phải miễn nhiễm lạnh cóng.' });
  utility({ name:'Viêm Ngọc', code:'utility_heat_protection', effectKey:'utilityHeatProtection', value:'+120 cách nhiệt mùa hè', source:SOURCE_ALCHEMY, note:'Là chống nóng, không phải miễn nhiễm quá nhiệt.' });
  utility({ name:'Tĩnh Tâm', code:'utility_sanity_regen', effectKey:'utilitySanityRegen', value:'+0,5 tinh thần mỗi giây', source:SOURCE_ALCHEMY, note:'Thấp hơn nhiều so với Thanh Tâm Đan.' });
  utility({ name:'Học Giả', code:'utility_exp_gain', effectKey:'utilityExpGain', value:'+10% EXP ngoài Dungeon', source:SOURCE_DUNGEON, decision:'Cân nhắc', note:'Ảnh hưởng tốc độ progression. Không nên xuất hiện trong pool chiến đấu thông thường.' });

  return {
    rows,
    tiers: ['I', 'II', 'III', 'IV', 'V', 'UTILITY'],
    storageKey: 'pham-nhan-affix-balance:v1',
  };
});
