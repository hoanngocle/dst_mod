"""Build the non-production white-purple EVA3 Luoshen preview."""

from dataclasses import replace
from hashlib import sha256
import json
from pathlib import Path
import shutil
import sys
from zipfile import ZipFile

import numpy as np
from PIL import Image, ImageDraw, ImageOps

try:
    from . import build_eva_v2_luoshen_preview as base
    from .build_eva_approved import parse_build
except ImportError:  # Direct script execution.
    import build_eva_v2_luoshen_preview as base
    from build_eva_approved import parse_build


MOD = Path(__file__).resolve().parents[1]
SOURCE = base.SOURCE
V2 = base.CANDIDATE
OUTPUT = MOD / "assets/source/eva_v3_luoshen"
CANDIDATE = OUTPUT / "eva-v3-luoshen-white-purple.zip"
BEFORE = OUTPUT / "eva-v3-luoshen-white-purple-dark-outline.zip"
BEFORE_SHA256 = "e04eb76c2998250d8dfe50f8c1c8268a70c301072242a4cedb099ca7a44c39ba"
ACCEPTED_SUBTLE = OUTPUT / "eva-v3-luoshen-white-purple-subtle-48.zip"
OUTLINE_SYMBOLS = frozenset({
    "hairpigtails", "headbase", "headbase_hat", "skirt", "torso",
    "arm_upper", "arm_upper_skin", "arm_lower",
})


def _purple(value, saturation):
    """Fixed 276-degree HSV, expressed directly to avoid color drift."""
    return np.stack((
        value * (1.0 - 0.40 * saturation),
        value * (1.0 - saturation),
        value,
    ), axis=2)


def recolor_eva_v3(straight: np.ndarray) -> np.ndarray:
    """Silver-lavender hair, pale costume, and deep amethyst jewels."""
    source = np.asarray(straight, dtype=np.uint8)
    result = source.copy()
    rgb = source[:, :, :3].astype(np.float32) / 255.0
    red, green, blue = (rgb[:, :, channel] for channel in range(3))
    maximum = rgb.max(axis=2)
    minimum = rgb.min(axis=2)
    saturation = np.divide(
        maximum - minimum, maximum, out=np.zeros_like(maximum), where=maximum > 0
    )
    visible = source[:, :, 3] > 0
    lineart = maximum <= (55.0 / 255.0)
    neutral = saturation < 0.08
    skin = (
        (source[:, :, 0] >= 170)
        & (source[:, :, 1] >= 105)
        & (source[:, :, 2] >= 100)
        & (source[:, :, 0] >= source[:, :, 1])
        & (source[:, :, 0].astype(np.int16)
           - source[:, :, 2].astype(np.int16) <= 100)
    )
    colored = visible & ~lineart & ~neutral & ~skin
    jewel = colored & (green > red * 1.08) & (green > blue * 1.05)
    hair = (
        colored & ~jewel & (red > green) & (green >= blue * 0.92)
        & (saturation <= 0.62) & (maximum <= 0.72)
    )
    costume = colored & ~jewel & ~hair

    # Lift brown hair into silver-white lavender while retaining its source
    # value ordering. Values at or below the ink threshold remain untouched.
    hair_value = np.clip(0.79 + 0.20 * maximum, 0.0, 1.0)
    hair_saturation = np.clip(0.055 + 0.075 * (1.0 - maximum), 0.055, 0.13)
    costume_value = np.clip(0.72 + 0.28 * maximum, 0.0, 1.0)
    costume_saturation = np.clip(0.18 + 0.15 * saturation, 0.18, 0.34)
    jewel_value = np.clip(0.55 + 0.35 * maximum, 0.0, 1.0)
    jewel_saturation = np.clip(0.55 + 0.25 * saturation, 0.55, 0.80)

    for mask, mapped in (
        (hair, _purple(hair_value, hair_saturation)),
        (costume, _purple(costume_value, costume_saturation)),
        (jewel, _purple(jewel_value, jewel_saturation)),
    ):
        colors = np.clip(np.rint(mapped * 255.0), 0, 255).astype(np.uint8)
        result[:, :, :3][mask] = colors[mask]
    return result


def soften_selected_outlines(straight: np.ndarray, symbol_mask: np.ndarray) -> np.ndarray:
    """Lift structural ink inside selected symbol UVs; preserve face and skin."""
    source = np.asarray(straight, dtype=np.uint8)
    if symbol_mask.shape != source.shape[:2]:
        raise ValueError("outline mask dimensions do not match atlas mip")
    result = source.copy()
    maximum = source[:, :, :3].max(axis=2)
    outline = symbol_mask & (source[:, :, 3] > 0) & (maximum <= 55)
    endpoint = np.array([72, 59, 86], dtype=np.float32)
    blended = np.rint(
        source[:, :, :3].astype(np.float32) * 0.4 + endpoint * 0.6
    ).astype(np.uint8)
    result[:, :, :3][outline] = blended[outline]
    return result


def _paint_symbol_uvs(draw: ImageDraw.ImageDraw, build, symbols, size) -> None:
    width, height = size
    for symbol in symbols:
        for frame in build.symbols[symbol]:
            vertices = frame.vertices
            for start in range(0, len(vertices), 3):
                triangle = vertices[start:start + 3]
                if len(triangle) != 3 or any(int(vertex[5]) != 0 for vertex in triangle):
                    continue
                draw.polygon(
                    [(vertex[3] * width, vertex[4] * height) for vertex in triangle],
                    fill=255,
                )


def outline_uv_masks(source: Path = SOURCE) -> dict[tuple[int, int], np.ndarray]:
    with ZipFile(source) as archive:
        build = parse_build(archive.read("build.bin"))
        _, records, _ = base.read_ktex(archive.read("atlas-0.tex"))
    missing = OUTLINE_SYMBOLS - set(build.symbols)
    if missing:
        raise ValueError(f"missing outline symbols: {sorted(missing)}")
    masks = {}
    for width, height, _, _ in records:
        selected = Image.new("L", (width, height))
        _paint_symbol_uvs(ImageDraw.Draw(selected), build, OUTLINE_SYMBOLS, (width, height))
        # Face expression UVs are separately owned and must never be softened,
        # even if a future atlas repack places them against a selected polygon.
        face = Image.new("L", (width, height))
        _paint_symbol_uvs(ImageDraw.Draw(face), build, {"face", "cheeks"}, (width, height))
        masks[(width, height)] = (
            (np.asarray(selected) > 0) & ~(np.asarray(face) > 0)
        )
    return masks


class EvaV3Palette:
    def __init__(self, masks):
        self.masks = masks

    def __call__(self, straight):
        height, width = straight.shape[:2]
        return soften_selected_outlines(
            recolor_eva_v3(straight), self.masks[(width, height)]
        )


def soften_outline_ktex(data: bytes, masks) -> bytes:
    """Re-encode only DXT color blocks containing selected outline pixels."""
    _, records, payloads = base.read_ktex(data)
    result = bytearray(data)
    payload_offset = 8 + len(records) * base.MIP.size
    for (width, height, _, size), original in zip(records, payloads):
        stored = np.asarray(Image.frombytes(
            "RGBA", (width, height), original, "bcn", (3, "DXT5")
        ))
        straight = base._unpremultiply(stored)
        mapped = soften_selected_outlines(straight, masks[(width, height)])
        changed = np.any(mapped[:, :, :3] != straight[:, :, :3], axis=2)
        encoded = base._encode_dxt5(Image.fromarray(base._premultiply(mapped), "RGBA"))
        payload = bytearray(original)
        blocks_wide = (width + 3) // 4
        for block_y in range((height + 3) // 4):
            for block_x in range(blocks_wide):
                y0, x0 = block_y * 4, block_x * 4
                if not changed[y0:min(y0 + 4, height), x0:min(x0 + 4, width)].any():
                    continue
                offset = (block_y * blocks_wide + block_x) * 16
                payload[offset + 8:offset + 16] = encoded[offset + 8:offset + 16]
        result[payload_offset:payload_offset + size] = payload
        payload_offset += size
    return bytes(result)


PALETTE = {
    "name": "EVA3 white-purple",
    "preserved": [
        "alpha", "face and hand lineart", "pale skin", "neutral whites",
    ],
    "materials": {
        "brown hair": "silver-white lavender shading",
        "orange/gold costume": "white and pale lavender",
        "green jewels": "deep amethyst",
    },
}


def build_candidate(source: Path = BEFORE, target: Path = CANDIDATE) -> dict:
    source, target = Path(source), Path(target)
    source_hash = sha256(source.read_bytes()).hexdigest()
    if source.resolve() == BEFORE.resolve() and source_hash != BEFORE_SHA256:
        raise ValueError(f"dark-outline EVA3 baseline changed: {source_hash}")
    with ZipFile(source) as archive:
        rows = [(info, archive.read(info.filename)) for info in archive.infolist()]
    row_data = {info.filename: data for info, data in rows}
    original_atlas = row_data["atlas-0.tex"]
    recolored_atlas = soften_outline_ktex(
        original_atlas, outline_uv_masks(SOURCE)
    )
    target.parent.mkdir(parents=True, exist_ok=True)
    with ZipFile(target, "w") as output:
        for info, data in rows:
            output.writestr(
                info, recolored_atlas if info.filename == "atlas-0.tex" else data
            )
    report = {
        "source": str(source.resolve()),
        "source_sha256": source_hash,
        "candidate": str(target.resolve()),
        "candidate_sha256": sha256(target.read_bytes()).hexdigest(),
        "build_sha256": sha256(row_data["build.bin"]).hexdigest(),
        "anim_sha256": sha256(row_data["anim.bin"]).hexdigest(),
        "atlas_count": 1,
        "alpha_blocks_exact": base._alpha_blocks_equal(
            original_atlas, recolored_atlas
        ),
        "palette": PALETTE,
    }
    report["softened_outline_symbols"] = sorted(OUTLINE_SYMBOLS)
    report["outline_blend"] = {
        "source_weight": 0.4,
        "dark_plum_rgb": [72, 59, 86],
        "dark_plum_weight": 0.6,
    }
    return report


def write_atlas_png(candidate: Path = CANDIDATE, output: Path = OUTPUT) -> Path:
    output.mkdir(parents=True, exist_ok=True)
    with ZipFile(candidate) as archive:
        image = base._top_image(archive.read("atlas-0.tex"))
    path = output / "eva-v3-white-purple-atlas-0.png"
    ImageOps.flip(image).save(path)
    return path


def render_comparison(v2: Path = ACCEPTED_SUBTLE, v3: Path = CANDIDATE,
                      output: Path = OUTPUT) -> Path:
    eva_tools = Path(__file__).resolve().parent / "eva"
    if str(eva_tools) not in sys.path:
        sys.path.insert(0, str(eva_tools))
    import render_player_motion as renderer

    v2_build = renderer.load_build_archive(v2)
    v3_build = renderer.load_build_archive(v3)
    with ZipFile(base.GAME_ANIM / "player_idles.zip") as archive:
        animations = renderer.parse_anim(archive.read("anim.bin"))
    visibility = renderer.candidate_visibility("normal", overlay=False)
    clips = [renderer.find_clip(animations, "idle_loop", facing)
             for facing in renderer.FACING_LABELS]
    unbound = {
        element[0] for clip in clips for frame in clip["frames"]
        for element in frame["elements"] if element[0] not in v2_build["symbols"]
    }
    visibility = replace(
        visibility,
        hidden_symbols=frozenset(set(visibility.hidden_symbols) | unbound),
    )
    cells = []
    for facing, label in renderer.FACING_LABELS.items():
        frame = renderer.find_clip(animations, "idle_loop", facing)["frames"][8]
        bounds = renderer.animation_bounds(v2_build, [frame], visibility)
        cells.append((
            label,
            renderer.render_animation_frame(
                v2_build, frame, visibility, bounds, sampling="linear"
            ),
            renderer.render_animation_frame(
                v3_build, frame, visibility, bounds, sampling="linear"
            ),
        ))
    cell_width = max(image.width for _, a, b in cells for image in (a, b)) + 28
    cell_height = max(image.height for _, a, b in cells for image in (a, b)) + 34
    canvas = Image.new("RGB", (cell_width * 3, 34 + cell_height * 2), "#282631")
    draw = ImageDraw.Draw(canvas)
    draw.text((12, 10), "Native EVA3 / accepted subtle vs slightly lighter", fill="white")
    for column, (label, old, new) in enumerate(cells):
        for row, (row_label, image) in enumerate((("accepted", old), ("lighter", new))):
            x = column * cell_width + (cell_width - image.width) // 2
            y = 34 + row * cell_height + (cell_height - 20 - image.height) // 2
            canvas.paste(image, (x, y), image)
            draw.text(
                (column * cell_width + 10, 34 + (row + 1) * cell_height - 18),
                f"{label} / {row_label}", fill="#ddd7e5",
            )
    path = output / "eva-v3-outline-before-after-front-profile-rear.png"
    canvas.save(path)
    return path


def main() -> int:
    if not V2.exists():
        base.build_candidate()
    if not BEFORE.exists():
        shutil.copyfile(CANDIDATE, BEFORE)
    if not ACCEPTED_SUBTLE.exists():
        shutil.copyfile(CANDIDATE, ACCEPTED_SUBTLE)
    report = build_candidate()
    report["atlas_png"] = str(write_atlas_png().resolve())
    report["comparison"] = str(render_comparison().resolve())
    (OUTPUT / "preview-manifest.json").write_text(
        json.dumps(report, indent=2) + "\n", encoding="utf8"
    )
    print(json.dumps(report, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
