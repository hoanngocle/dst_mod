"""Compile the unedited ImageGen sprite to Klei textures and one-sprite animation."""
from pathlib import Path
import struct
import subprocess
from zipfile import ZipFile
from PIL import Image
from build_portal_assets import put_string, register_name, quad_vertices, zip_info, inspect_ktex_alpha

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'assets/source/ttk_spirit_workshop_spring.png'
OUT = ROOT / 'images/ttk_spirit_workshop'
CONVERTER = Path("C:/Program Files (x86)/Steam/steamapps/common/Don't Starve Mod Tools/mod_tools/tools/bin/TextureConverter.exe")
NAME = 'ttk_spirit_workshop'
OUT.mkdir(parents=True, exist_ok=True)
with Image.open(SOURCE) as im:
    alpha = im.getchannel('A')
    assert alpha.getextrema() == (0, 255)
    # Measure the solid feet; do not crop, paint or alter the source sprite.
    bounds = alpha.point(lambda v: 255 if v > 128 else 0).getbbox()
    width = 320.0
    height = width * im.height / im.width
    offset_y = height / 2 - height * bounds[3] / im.height

for filename, size in [('atlas-0.tex', 1024), ('icon.tex', 128)]:
    subprocess.run([str(CONVERTER), '--swizzle', '--format', 'bc3', '--platform', 'opengl',
        '--premultiply', '--mipmap', '-w', str(size), '-h', str(size),
        '-i', str(SOURCE), '-o', str(OUT / filename)], check=True)
    assert inspect_ktex_alpha(OUT / filename) == (0, 255)
(OUT / 'icon.xml').write_text('<Atlas><Texture filename="icon.tex"/><Elements><Element name="ttk_spirit_workshop.tex" u1="0" u2="1" v1="0" v2="1"/></Elements></Atlas>')

names = {}
symbol = register_name(names, 'workshop')
build = bytearray(struct.pack('<4sIII', b'BILD', 6, 1, 1))
put_string(build, NAME)
build.extend(struct.pack('<I', 1));put_string(build, 'atlas-0.tex')
build.extend(struct.pack('<II', symbol, 1))
build.extend(struct.pack('<IIffffII', 0, 1, 0, 0, width, height, 0, 6))
build.extend(struct.pack('<I', 6))
for vertex in quad_vertices(width, height, 0): build.extend(struct.pack('<ffffff', *vertex))
build.extend(struct.pack('<I', len(names)))
for key, value in sorted(names.items()): build.extend(struct.pack('<I', key));put_string(build, value)

names = {}
bank = register_name(names, NAME)
anim = bytearray(struct.pack('<4sIIIII', b'ANIM', 4, 1, 1, 0, 1))
put_string(anim, 'idle')
anim.extend(struct.pack('<BIfI', 255, bank, 30, 1))
anim.extend(struct.pack('<ffffI', 0, offset_y, width, height, 0))
anim.extend(struct.pack('<I', 1))
anim.extend(struct.pack('<IIIfffffff', register_name(names, 'workshop'), 0,
    register_name(names, 'workshop'), 1, 0, 0, 1, 0, offset_y, 0))
anim.extend(struct.pack('<I', len(names)))
for key, value in sorted(names.items()): anim.extend(struct.pack('<I', key));put_string(anim, value)
with ZipFile(ROOT / ('anim/' + NAME + '.zip'), 'w') as z:
    z.writestr(zip_info('build.bin'), build)
    z.writestr(zip_info('anim.bin'), anim)
    z.writestr(zip_info('atlas-0.tex'), (OUT / 'atlas-0.tex').read_bytes())
print('Compiled transparent workshop animation/icon; feet offset:', offset_y)
