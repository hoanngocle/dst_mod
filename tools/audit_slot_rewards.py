"""Compare every original reward against TTK; explicit exclusions only."""
from pathlib import Path
import re
import sys

MOD = Path(__file__).resolve().parents[1]
ROOT = MOD.parents[1]
sys.path.insert(0, str(ROOT / '.superpowers/luoshen-runtime'))
from lupa.lua51 import LuaRuntime

EXCLUDED = {
    'xd_ftj': 'Phần Thiên Kiếm: chưa chuyển prefab và cơ chế riêng.',
    'xd_zhf': 'Tôn Hồn Phiên: chưa chuyển; khác Cửu Thiên Tinh Thần Phiên (vanhonphien).',
    'xd_fs': 'Phượng Tủy: chưa chuyển.',
    'xd_qlr': 'Kỳ Lân Nhung: chưa chuyển.',
    'xd_danyao_dt': 'Đoán Thể Hoàn: chưa chuyển hệ thống đan dược.',
    'xd_danyao_hj': 'Hóa Tinh Đan: chưa chuyển hệ thống đan dược.',
    'xd_danyao_jq': 'Tụ Khí Hoàn: chưa chuyển hệ thống đan dược.',
    'xd_danyao_xs': 'Tẩy Tủy Hoàn: chưa chuyển hệ thống đan dược.',
    'xd_danyao_yz': 'Vân Trung Đan: chưa chuyển hệ thống đan dược.',
    'xd_danyao_zj': 'Trúc Cơ Đan: chưa chuyển hệ thống đan dược.',
    'xd_jfsn': 'Boss riêng Tu Tiên: chưa chuyển prefab và cơ chế chiến đấu.',
    'xd_qlch': 'Boss riêng Tu Tiên: chưa chuyển prefab và cơ chế chiến đấu.',
}
RENAMES = {'xd_lingshi2': 'ttk_lingshi2'}
REMOVED = {'panflute': 'Bỏ sáo Pan theo yêu cầu trực tiếp.'}
REPLACED = {}
for names, replacement in [
    ('bonestew dragonpie icecream perogies meatballs bird_egg_cooked butter drumstick ratatouille taffy powcake',
     'Lạc Thần Thanh Sơ / Lạc Hương Phanh Nhục và hạt linh thảo'),
    ('nightsword armormarble armorslurper armorwood footballhat cutless tentaclespike',
     'Pháp bảo và trang bị Tu Tiên Ký trong nhóm khá/hiếm; linh thảo trong nhóm thường'),
    ('golden_farm_hoe goldenaxe goldenpickaxe goldenpitchfork goldenshovel farm_plow_item fishingrod oceanfishingrod chum',
     'Hạt linh thảo và Hạt Giống Lạc Thần Hoa'),
    ('icehat monkey_mediumhat monkey_smallhat raincoat reflectivevest sweatervest umbrella watermelonhat',
     'Nhất Vũ Phương Hoa / Vân Mạc Thượng Trang và linh thảo theo mùa'),
    ('bandage butterfly cutreeds dug_trap_starfish honeycomb livinglog pigskin saltrock sewing_kit',
     'Linh thảo, Hoa Ấn Lạc Thần, đuôi Pog, chân nhện và vật liệu Tu Tiên Ký'),
]:
    for name in names.split(): REPLACED[name] = replacement

def audit():
    source = (ROOT / 'mods/eva-assets-work/skill-audit/decoded/scripts/prefabs/xd_choujiangji.lua').read_text(encoding='utf-8')
    source = re.sub(r'--[^\n]*', '', source)
    original = {}
    for group in ('good', 'ok', 'ok2', 'bad', 'bad2'):
        section = source.split('local ' + group + 'items = {', 1)[1].split('\nlocal ', 1)[0]
        original[group] = {name for block in re.findall(r'\bitems\s*=\s*\{([^}]+)\}', section)
                           for name in re.findall(r'(\w+)\s*=\s*\d+', block)}
    prizes = LuaRuntime().execute((MOD / 'scripts/ttk_slot_prizes.lua').read_text(encoding='utf-8'))
    actual = {group: {item.prefab for bundle in data.bundles.values() for item in bundle['items'].values()}
              for group, data in prizes.groups.items()}
    missing = {group: sorted(RENAMES.get(name, name) for name in names
                            if name not in EXCLUDED and name not in REMOVED and name not in REPLACED
                            and RENAMES.get(name, name) not in actual[group])
               for group, names in original.items()}
    # Enforce original group membership too: cheap jackpots must not replace rare rewards.
    missing = {g: names for g, names in missing.items() if names}
    present = set.union(*actual.values())
    assert not (present & (REMOVED.keys() | REPLACED.keys())), 'A removed/replaced reward is still in the pool'
    return original, prizes, missing

if __name__ == '__main__':
    original, prizes, missing = audit()
    if missing:
        print('FAIL: original rewards missing from their groups:', missing)
        raise SystemExit(1)
    count = len(set.union(*original.values()))
    print(f'PASS: {count} original unique prefabs audited; {count-len(EXCLUDED)-len(REPLACED)-len(REMOVED)} retained, '
          f'{len(REPLACED)} replaced, {len(REMOVED)} removed by request, {len(EXCLUDED)} unported exclusions')
