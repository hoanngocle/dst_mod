"""Build a non-production EVA 2.0 preview from the exact Luoshen archive.

Only DXT5 color blocks are replaced. Native alpha blocks, BILD, ANIM, UVs,
dimensions, mip headers, and archive member topology remain source-exact.
"""

from __future__ import annotations

from dataclasses import replace
from hashlib import sha256
from io import BytesIO
import json
from pathlib import Path
import struct
import sys
from zipfile import ZipFile

import numpy as np
from PIL import Image, ImageDraw, ImageOps


MOD = Path(__file__).resolve().parents[1]
SOURCE = MOD / "assets/source/eva_approved/donor-luoshen.zip"
OUTPUT = MOD / "assets/source/eva_v2_luoshen"
CANDIDATE = OUTPUT / "eva-v2-luoshen-purple.zip"
SOURCE_SHA256 = "83ded69ce707e7851966aaf518e25c1466a3898d04665911894011f09a56d02d"
GAME_ANIM = Path(
    "C:/Program Files (x86)/Steam/steamapps/common/Don't Starve Together/"
    "data/anim"
)
MIP = struct.Struct("<HHHI")


def read_ktex(data: bytes):
    if data[:4] != b"KTEX":
        raise ValueError("expected KTEX")
    specification = struct.unpack_from("<I", data, 4)[0]
    mip_count = (specification >> 13) & 31
    records = [
        MIP.unpack_from(data, 8 + index * MIP.size)
        for index in range(mip_count)
    ]
    offset = 8 + mip_count * MIP.size
    payloads = []
    for width, height, _, size in records:
        end = offset + size
        if not width or not height or end > len(data):
            raise ValueError("invalid KTEX mip record")
        payloads.append(data[offset:end])
        offset = end
    if offset != len(data):
        raise ValueError("unexpected KTEX trailing bytes")
    return specification, records, payloads


def _unpremultiply(stored: np.ndarray) -> np.ndarray:
    pixels = np.asarray(stored, dtype=np.uint16).copy()
    alpha = pixels[:, :, 3]
    nonzero = alpha > 0
    for channel in range(3):
        values = pixels[:, :, channel]
        values[nonzero] = np.minimum(
            255, (values[nonzero] * 255 + alpha[nonzero] // 2) // alpha[nonzero]
        )
        values[~nonzero] = 0
    return pixels.astype(np.uint8)


def _premultiply(straight: np.ndarray) -> np.ndarray:
    pixels = np.asarray(straight, dtype=np.uint16).copy()
    alpha = pixels[:, :, 3:4]
    pixels[:, :, :3] = (pixels[:, :, :3] * alpha + 127) // 255
    return pixels.astype(np.uint8)


def recolor_straight_rgba(straight: np.ndarray) -> np.ndarray:
    """Map colored Luoshen material to purple while preserving skin/ink/white."""
    source = np.asarray(straight, dtype=np.uint8)
    result = source.copy()
    rgb = source[:, :, :3].astype(np.float32) / 255.0
    red, green, blue = (rgb[:, :, index] for index in range(3))
    maximum = rgb.max(axis=2)
    minimum = rgb.min(axis=2)
    saturation = np.divide(
        maximum - minimum,
        maximum,
        out=np.zeros_like(maximum),
        where=maximum > 0,
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
    mask = visible & ~lineart & ~neutral & ~skin

    # Fixed HSV hue 280.8° (sector 4, f=.68): dark brown becomes plum,
    # orange/gold becomes violet, and green jewels become amethyst. Value and
    # most source saturation are retained so original shading survives.
    purple_saturation = np.clip(np.maximum(saturation, 0.38), 0.38, 0.78)
    value = maximum
    purple = np.stack((
        value * (1.0 - 0.32 * purple_saturation),
        value * (1.0 - purple_saturation),
        value,
    ), axis=2)
    mapped = np.clip(np.rint(purple * 255.0), 0, 255).astype(np.uint8)
    result[:, :, :3][mask] = mapped[mask]
    return result


def _encode_dxt5(image: Image.Image) -> bytes:
    stream = BytesIO()
    image.save(stream, format="DDS", pixel_format="DXT5")
    data = stream.getvalue()
    if data[84:88] != b"DXT5":
        raise RuntimeError("Pillow did not emit DXT5")
    return data[128:]


def recolor_ktex(data: bytes, recolor=recolor_straight_rgba) -> bytes:
    _, records, payloads = read_ktex(data)
    result = bytearray(data)
    payload_offset = 8 + len(records) * MIP.size
    for (width, height, _, size), original in zip(records, payloads):
        stored = np.asarray(Image.frombytes(
            "RGBA", (width, height), original, "bcn", (3, "DXT5")
        ))
        straight = _unpremultiply(stored)
        mapped = recolor(straight)
        encoded = _encode_dxt5(Image.fromarray(_premultiply(mapped), "RGBA"))
        if len(encoded) != size or size % 16:
            raise ValueError("unexpected DXT5 payload size")
        payload = bytearray(original)
        for offset in range(0, size, 16):
            # DXT5 alpha occupies the first eight bytes. Retaining them exactly
            # makes the native silhouette independent of color recompression.
            payload[offset + 8:offset + 16] = encoded[offset + 8:offset + 16]
        result[payload_offset:payload_offset + size] = payload
        payload_offset += size
    return bytes(result)


def _alpha_blocks_equal(before: bytes, after: bytes) -> bool:
    _, records_before, payloads_before = read_ktex(before)
    _, records_after, payloads_after = read_ktex(after)
    if records_before != records_after:
        return False
    return all(
        old[offset:offset + 8] == new[offset:offset + 8]
        for old, new in zip(payloads_before, payloads_after)
        for offset in range(0, len(old), 16)
    )


def build_candidate(source: Path = SOURCE, target: Path = CANDIDATE,
                    recolor=recolor_straight_rgba, palette_report=None) -> dict:
    source = Path(source)
    target = Path(target)
    source_hash = sha256(source.read_bytes()).hexdigest()
    if source.resolve() == SOURCE.resolve() and source_hash != SOURCE_SHA256:
        raise ValueError(f"Luoshen donor hash changed: {source_hash}")
    with ZipFile(source) as archive:
        rows = [(info, archive.read(info.filename)) for info in archive.infolist()]
    atlas_names = [info.filename for info, data in rows if data[:4] == b"KTEX"]
    if atlas_names != ["atlas-0.tex"]:
        raise ValueError(f"expected one Luoshen atlas, found {atlas_names}")
    original_atlas = dict((info.filename, data) for info, data in rows)["atlas-0.tex"]
    recolored_atlas = recolor_ktex(original_atlas, recolor)
    target.parent.mkdir(parents=True, exist_ok=True)
    with ZipFile(target, "w") as output:
        for info, data in rows:
            output.writestr(
                info,
                recolored_atlas if info.filename == "atlas-0.tex" else data,
            )
    with ZipFile(target) as candidate, ZipFile(source) as donor:
        if candidate.read("build.bin") != donor.read("build.bin"):
            raise RuntimeError("candidate BILD changed")
        if candidate.read("anim.bin") != donor.read("anim.bin"):
            raise RuntimeError("candidate ANIM changed")
    return {
        "source": str(source.resolve()),
        "source_sha256": source_hash,
        "candidate": str(target.resolve()),
        "candidate_sha256": sha256(target.read_bytes()).hexdigest(),
        "build_sha256": sha256(dict((i.filename, d) for i, d in rows)["build.bin"]).hexdigest(),
        "anim_sha256": sha256(dict((i.filename, d) for i, d in rows)["anim.bin"]).hexdigest(),
        "atlas_count": 1,
        "alpha_blocks_exact": _alpha_blocks_equal(original_atlas, recolored_atlas),
        "palette": palette_report or {
            "hue_degrees": 280.8,
            "saturation_range": [0.38, 0.78],
            "preserved": ["alpha", "black lineart", "pale skin", "neutral whites"],
        },
    }


def _top_image(ktex: bytes) -> Image.Image:
    _, records, payloads = read_ktex(ktex)
    width, height = records[0][:2]
    stored = np.asarray(Image.frombytes(
        "RGBA", (width, height), payloads[0], "bcn", (3, "DXT5")
    ))
    return Image.fromarray(_unpremultiply(stored), "RGBA")


def write_atlas_pngs(source: Path = SOURCE, candidate: Path = CANDIDATE,
                     output: Path = OUTPUT) -> None:
    output.mkdir(parents=True, exist_ok=True)
    with ZipFile(source) as archive:
        original = _top_image(archive.read("atlas-0.tex"))
    with ZipFile(candidate) as archive:
        purple = _top_image(archive.read("atlas-0.tex"))
    # KTEX/OpenGL storage is vertically inverted relative to conventional PNG.
    ImageOps.flip(original).save(output / "luoshen-original-atlas-0.png")
    ImageOps.flip(purple).save(output / "eva-v2-purple-atlas-0.png")


def render_comparison(source: Path = SOURCE, candidate: Path = CANDIDATE,
                      output: Path = OUTPUT) -> Path:
    eva_tools = Path(__file__).resolve().parent / "eva"
    if str(eva_tools) not in sys.path:
        sys.path.insert(0, str(eva_tools))
    import render_player_motion as renderer

    source_build = renderer.load_build_archive(source)
    purple_build = renderer.load_build_archive(candidate)
    with ZipFile(GAME_ANIM / "player_idles.zip") as archive:
        animations = renderer.parse_anim(archive.read("anim.bin"))

    # The original prefab calls SetBuild("xd_luoshen") and does not add a
    # Wilson override build.  Render each complete 12-symbol build directly;
    # animation elements that have no symbol in that build remain invisible.
    visibility = renderer.candidate_visibility("normal", overlay=False)
    idle_clips = [
        renderer.find_clip(animations, "idle_loop", facing)
        for facing in renderer.FACING_LABELS
    ]
    available = set(source_build["symbols"])
    unbound = {
        element[0]
        for clip in idle_clips
        for frame in clip["frames"]
        for element in frame["elements"]
        if element[0] not in available
    }
    visibility = replace(
        visibility,
        hidden_symbols=frozenset(set(visibility.hidden_symbols) | unbound),
    )
    cells = []
    for facing, label in renderer.FACING_LABELS.items():
        clip = renderer.find_clip(animations, "idle_loop", facing)
        frame = clip["frames"][8]
        bounds = renderer.animation_bounds(
            source_build, [frame], visibility
        )
        cells.append((label, renderer.render_animation_frame(
            source_build, frame, visibility, bounds,
            sampling="linear"
        ), renderer.render_animation_frame(
            purple_build, frame, visibility, bounds,
            sampling="linear"
        )))

    cell_width = max(image.width for _, a, b in cells for image in (a, b)) + 28
    cell_height = max(image.height for _, a, b in cells for image in (a, b)) + 34
    canvas = Image.new("RGB", (cell_width * 3, 34 + cell_height * 2), "#282631")
    draw = ImageDraw.Draw(canvas)
    draw.text((12, 10), "Native xd_luoshen build / idle_loop frame 8", fill="white")
    for column, (label, original, purple) in enumerate(cells):
        for row, (row_label, image) in enumerate((("source", original), ("purple", purple))):
            x = column * cell_width + (cell_width - image.width) // 2
            y = 34 + row * cell_height + (cell_height - 20 - image.height) // 2
            canvas.paste(image, (x, y), image)
            draw.text((column * cell_width + 10, 34 + (row + 1) * cell_height - 18),
                      f"{label} / {row_label}", fill="#ddd7e5")
    path = output / "idle-front-profile-rear-comparison.png"
    canvas.save(path)
    return path


def main() -> int:
    report = build_candidate()
    write_atlas_pngs()
    report["comparison"] = str(render_comparison().resolve())
    report["outputs"] = [
        "luoshen-original-atlas-0.png",
        "eva-v2-purple-atlas-0.png",
        "eva-v2-luoshen-purple.zip",
        "idle-front-profile-rear-comparison.png",
    ]
    (OUTPUT / "preview-manifest.json").write_text(
        json.dumps(report, indent=2) + "\n", encoding="utf8"
    )
    print(json.dumps(report, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
