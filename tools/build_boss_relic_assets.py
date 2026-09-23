"""Compile unedited ImageGen sprites and reuse source icons for six boss relics.

Only Klei TextureConverter resizes/encodes PNGs. No generated image is repainted.
Old prefab identifiers are retained for inventory/save compatibility.
"""
from pathlib import Path
import shutil
import struct
import subprocess
from zipfile import ZipFile
from PIL import Image
from build_portal_assets import put_string, register_name, quad_vertices, zip_info, inspect_build, inspect_anim, inspect_ktex_alpha

ROOT = Path(__file__).resolve().parents[1]
ICONS = ROOT / 'images/inventoryimages'
SOURCE = ROOT / 'assets/source/boss_relics'
CONVERTER = Path("C:/Program Files (x86)/Steam/steamapps/common/Don't Starve Mod Tools/mod_tools/tools/bin/TextureConverter.exe")
GENERATED = ('ttk_boss_core_baihu', 'ttk_summon_baihu', 'ttk_summon_jfsn', 'ttk_summon_qlch')
REUSED = {
    'ttk_boss_core_jfsn': 'inventoryimages/xd_fs',
    'ttk_boss_core_qlch': 'inventoryimages/xd_dy_lmsqd_5',
    'ttk_boss_core_stalke_fuben': 'dyc_gem_purple',
    'ttk_boss_core_deerclops_ziyun': 'inventoryimages/xd_hxyp',
    'ttk_boss_core_spiderqueen': 'inventoryimages/xd_dy_xynyd_5',
    'ttk_summon_deerclops_ziyun': 'inventoryimages/xd_sudaji_soul',
    'ttk_summon_spiderqueen': 'inventoryimages/xd_htz_xyzzl',
}


def sprite(name, texture, width):
    """Build a single idle quad with the base at ground level."""
    height = width
    names = {}
    symbol = register_name(names, 'relic')
    build = bytearray(struct.pack('<4sIII', b'BILD', 6, 1, 1))
    put_string(build, name)
    build.extend(struct.pack('<I', 1)); put_string(build, 'atlas-0.tex')
    build.extend(struct.pack('<II', symbol, 1))
    build.extend(struct.pack('<IIffffII', 0, 1, 0, 0, width, height, 0, 6))
    build.extend(struct.pack('<I', 6))
    for vertex in quad_vertices(width, height, 0):
        build.extend(struct.pack('<ffffff', *vertex))
    build.extend(struct.pack('<I', len(names)))
    for key, value in sorted(names.items()):
        build.extend(struct.pack('<I', key)); put_string(build, value)
    names = {}
    bank = register_name(names, name)
    anim = bytearray(struct.pack('<4sIIIII', b'ANIM', 4, 1, 1, 0, 1))
    put_string(anim, 'idle')
    anim.extend(struct.pack('<BIfI', 255, bank, 30, 1))
    anim.extend(struct.pack('<ffffI', 0, -height / 2, width, height, 0))
    anim.extend(struct.pack('<I', 1))
    anim.extend(struct.pack('<IIIfffffff', register_name(names, 'relic'), 0,
        register_name(names, 'relic'), 1, 0, 0, 1, 0, -height / 2, 0))
    anim.extend(struct.pack('<I', len(names)))
    for key, value in sorted(names.items()):
        anim.extend(struct.pack('<I', key)); put_string(anim, value)
    assert inspect_build(build)['name'] == name
    assert inspect_anim(anim)[0]['name'] == 'idle'
    with ZipFile(ROOT / ('anim/' + name + '.zip'), 'w') as archive:
        archive.writestr(zip_info('build.bin'), build)
        archive.writestr(zip_info('anim.bin'), anim)
        archive.writestr(zip_info('atlas-0.tex'), texture.read_bytes())


def main():
    for name in GENERATED:
        source = SOURCE / (name + '.png')
        with Image.open(source) as im:
            assert im.width == im.height
            assert im.getchannel('A').getextrema() == (0, 255), name
        world = SOURCE / (name + '.tex')
        for target, size in [(world, 256), (ICONS / (name + '.tex'), 128)]:
            subprocess.run([str(CONVERTER), '--swizzle', '--format', 'bc3', '--platform', 'opengl',
                '--premultiply', '--mipmap', '-w', str(size), '-h', str(size),
                '-i', str(source), '-o', str(target)], check=True)
            assert inspect_ktex_alpha(target) == (0, 255)
        (ICONS / (name + '.xml')).write_text('<Atlas><Texture filename="'+name+'.tex"/><Elements><Element name="'+name+'.tex" u1="0" u2="1" v1="0" v2="1"/></Elements></Atlas>')
        sprite(name, world, 48 if name.startswith('ttk_summon_') else 36)
    for name, original in REUSED.items():
        original_path = ROOT / 'images' / original
        shutil.copyfile(original_path.with_suffix('.tex'), ICONS / (name + '.tex'))
        (ICONS / (name + '.xml')).write_text(original_path.with_suffix('.xml').read_text().replace(original_path.name, name))
        sprite(name, ICONS / (name + '.tex'), 48 if name.startswith('ttk_summon_') else 36)
    print('Built eleven boss relic icons/sprites; the twelfth uses native DST shadowheart art.')


if __name__ == '__main__':
    main()
