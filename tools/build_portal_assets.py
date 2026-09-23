"""Compile and verify the Truyen Tong Tran portal's UI textures and Klei animation.

Run with the bundled Codex Python runtime (Pillow is used only to inspect the
source alpha channel).  Artwork is never painted, cropped, or rewritten here;
Klei's TextureConverter performs the requested texture resizing and encoding.
"""
from __future__ import annotations

import argparse
import hashlib
import math
import struct
import subprocess
import xml.etree.ElementTree as ET
from dataclasses import dataclass
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile, ZipInfo

from PIL import Image


MOD_ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = MOD_ROOT / "assets" / "source"
UI_DIR = MOD_ROOT / "images" / "ttt_portal"
ANIM_DIR = MOD_ROOT / "anim"
CONVERTER = Path(
    "C:/Program Files (x86)/Steam/steamapps/common/Don't Starve Mod Tools/"
    "mod_tools/tools/bin/TextureConverter.exe"
)

BANK = "ttt_portal"
BUILD = "ttt_portal"
FPS = 30.0
FACING_ALL = 255

# World-space calibration from the generated frame.  The unmodified source
# canvas is mapped to a 320x320 quad.  Its feet are at about 92.2% of canvas
# height, so -135 places them on y=0.  The vortex is independently scaled into
# the opening measured from the same image.
FRAME_W = 320.0
FRAME_H = 320.0
FRAME_Y = -135.0
VORTEX_W = 148.0
VORTEX_H = 206.0
VORTEX_Y = -125.0
FRAME_RECT = (0.0, FRAME_Y, 340.0, 330.0)


@dataclass(frozen=True)
class TextureSpec:
    source: str
    output: str
    width: int
    height: int
    element: str


TEXTURES = (
    TextureSpec("ttt_portal_frame.png", "frame.tex", 512, 512, "frame.tex"),
    TextureSpec("ttt_portal_vortex.png", "vortex.tex", 512, 512, "vortex.tex"),
    TextureSpec("ttt_portal_panel.png", "panel.tex", 512, 1024, "panel.tex"),
    # The icon deliberately has a globally distinctive element name.  DST can
    # put atlas elements from inventory and minimap atlases in shared lookups.
    TextureSpec(
        "ttt_portal_frame.png", "icon.tex", 256, 256, "ttt_portal_icon.tex"
    ),
)


def sdbm(name: str) -> int:
    """Klei's lowercase SDBM hash, as used by buildanimation.py."""
    value = 0
    for char in name.lower():
        value = (ord(char) + (value << 6) + (value << 16) - value) & 0xFFFFFFFF
    return value


def put_string(buffer: bytearray, value: str) -> None:
    data = value.encode("ascii")
    buffer.extend(struct.pack("<I", len(data)))
    buffer.extend(data)


def register_name(names: dict[int, str], name: str) -> int:
    key = sdbm(name)
    old = names.setdefault(key, name)
    if old != name:
        raise ValueError(f"SDBM collision: {old!r} and {name!r} -> {key:#x}")
    return key


def source_alpha_report() -> dict[str, dict[str, object]]:
    report: dict[str, dict[str, object]] = {}
    for name in sorted({spec.source for spec in TEXTURES}):
        path = SOURCE_DIR / name
        if not path.is_file():
            raise FileNotFoundError(f"Missing source artwork: {path}")
        with Image.open(path) as image:
            rgba = image.convert("RGBA")
            alpha = rgba.getchannel("A")
            lo, hi = alpha.getextrema()
            histogram = alpha.histogram()
            transparent = sum(histogram[:8]) / float(rgba.width * rgba.height)
            if lo > 7 or hi < 128 or transparent < 0.01:
                raise ValueError(
                    f"{name} needs real transparency; alpha={lo}..{hi}, "
                    f"near-transparent={transparent:.2%}"
                )
            report[name] = {
                "size": rgba.size,
                "alpha": (lo, hi),
                "near_transparent": transparent,
                "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
            }
    return report


def compile_texture(spec: TextureSpec, converter: Path) -> Path:
    source = SOURCE_DIR / spec.source
    target = UI_DIR / spec.output
    args = [
        str(converter),
        "--swizzle",
        "--format",
        "bc3",
        "--platform",
        "opengl",
        "--premultiply",
        "--mipmap",
        "-w",
        str(spec.width),
        "-h",
        str(spec.height),
        "-i",
        str(source),
        "-o",
        str(target),
    ]
    subprocess.run(args, check=True)
    width, height, format_id, mipmaps = inspect_ktex(target)
    if (width, height, format_id) != (spec.width, spec.height, 2):
        raise ValueError(
            f"Unexpected KTEX metadata for {target.name}: "
            f"{width}x{height}, format {format_id}, {mipmaps} mipmaps"
        )
    return target


def inspect_ktex(path: Path) -> tuple[int, int, int, int]:
    data = path.read_bytes()
    if len(data) < 18 or data[:4] != b"KTEX":
        raise ValueError(f"Invalid KTEX header: {path}")
    specification = struct.unpack_from("<I", data, 4)[0]
    format_id = (specification >> 4) & 31
    mipmaps = (specification >> 13) & 31
    width, height = struct.unpack_from("<HH", data, 8)
    if not width or not height or not mipmaps or len(data) < 8 + mipmaps * 10:
        raise ValueError(f"Invalid KTEX metadata: {path}")
    return width, height, format_id, mipmaps


def inspect_ktex_alpha(path: Path) -> tuple[int, int]:
    """Decode the first BC3 mip with Pillow and return its alpha range."""
    data = path.read_bytes()
    width, height, format_id, mipmaps = inspect_ktex(path)
    if format_id != 2:
        raise ValueError(f"Expected BC3 texture: {path}")
    first_mip_size = struct.unpack_from("<I", data, 14)[0]
    start = 8 + mipmaps * 10
    expected = ((width + 3) // 4) * ((height + 3) // 4) * 16
    if first_mip_size != expected or start + first_mip_size > len(data):
        raise ValueError(f"Truncated BC3 payload: {path}")
    image = Image.frombytes(
        "RGBA",
        (width, height),
        data[start : start + first_mip_size],
        "bcn",
        (3, "DXT5"),
    )
    return image.getchannel("A").getextrema()


def write_atlas(spec: TextureSpec) -> Path:
    atlas = ET.Element("Atlas")
    ET.SubElement(atlas, "Texture", filename=spec.output)
    elements = ET.SubElement(atlas, "Elements")
    ET.SubElement(
        elements,
        "Element",
        name=spec.element,
        u1="0",
        u2="1",
        v1="0",
        v2="1",
    )
    path = UI_DIR / f"{Path(spec.output).stem}.xml"
    ET.indent(atlas, space="    ")
    ET.ElementTree(atlas).write(path, encoding="utf-8", xml_declaration=False)
    return path


def quad_vertices(width: float, height: float, sampler: int) -> list[tuple[float, ...]]:
    left, right = -width / 2.0, width / 2.0
    top, bottom = -height / 2.0, height / 2.0
    # Klei's OpenGL KTEX is bottom-up; this is the same full-image mapping used
    # by the native AddVertsToVB serializer.
    return [
        (left, top, 0.0, 0.0, 1.0, float(sampler)),
        (right, top, 0.0, 1.0, 1.0, float(sampler)),
        (left, bottom, 0.0, 0.0, 0.0, float(sampler)),
        (right, top, 0.0, 1.0, 1.0, float(sampler)),
        (right, bottom, 0.0, 1.0, 0.0, float(sampler)),
        (left, bottom, 0.0, 0.0, 0.0, float(sampler)),
    ]


def make_build() -> bytes:
    names: dict[int, str] = {}
    symbols = [
        ("frame", FRAME_W, FRAME_H, 0),
        ("vortex", VORTEX_W, VORTEX_H, 1),
    ]
    symbols.sort(key=lambda symbol: register_name(names, symbol[0]))
    vertices: list[tuple[float, ...]] = []
    frames: list[tuple[str, float, float, int, int]] = []
    for name, width, height, sampler in symbols:
        start = len(vertices)
        vertices.extend(quad_vertices(width, height, sampler))
        frames.append((name, width, height, start, 6))

    out = bytearray(struct.pack("<4sIII", b"BILD", 6, len(symbols), len(frames)))
    put_string(out, BUILD)
    out.extend(struct.pack("<I", 2))
    put_string(out, "atlas-0.tex")
    put_string(out, "atlas-1.tex")
    for name, width, height, start, count in frames:
        out.extend(struct.pack("<II", register_name(names, name), 1))
        out.extend(struct.pack("<IIffffII", 0, 1, 0.0, 0.0, width, height, start, count))
    out.extend(struct.pack("<I", len(vertices)))
    for vertex in vertices:
        out.extend(struct.pack("<ffffff", *vertex))
    out.extend(struct.pack("<I", len(names)))
    for key, name in sorted(names.items()):
        out.extend(struct.pack("<I", key))
        put_string(out, name)
    return bytes(out)


def rotation(degrees: float, scale: float = 1.0) -> tuple[float, float, float, float]:
    angle = math.radians(degrees)
    cosine = math.cos(angle) * scale
    sine = math.sin(angle) * scale
    return cosine, sine, -sine, cosine


def vortex_rotation(degrees: float, scale: float = 1.0) -> tuple[float, float, float, float]:
    # S * R * inverse(S): rotate the source circle while its ellipse stays fixed.
    angle = math.radians(degrees)
    cosine = math.cos(angle) * scale
    sine = math.sin(angle) * scale
    return cosine, sine * VORTEX_H / VORTEX_W, -sine * VORTEX_W / VORTEX_H, cosine


def element(
    symbol: str,
    layer: str,
    matrix: tuple[float, float, float, float],
    tx: float,
    ty: float,
    z: float,
) -> tuple[object, ...]:
    return symbol, 0, layer, *matrix, tx, ty, z


def normal_frame(
    vortex_angle: float = 0.0,
    x: float = 0.0,
    frame_angle: float = 0.0,
    scale: float = 1.0,
) -> list[tuple[object, ...]]:
    return [
        element(
            "vortex",
            "WRITING",
            vortex_rotation(vortex_angle, scale),
            x,
            VORTEX_Y * scale,
            -5.0,
        ),
        element(
            "frame",
            "frame",
            rotation(frame_angle, scale),
            x,
            FRAME_Y * scale,
            0.0,
        ),
    ]


def make_clips() -> list[tuple[str, list[list[tuple[object, ...]]]]]:
    idle = [normal_frame(index * 6.0) for index in range(60)]

    offsets = (0.0, -8.0, 7.0, -5.0, 4.0, -2.0, 1.0, 0.0, 0.0, 0.0)
    tilts = (0.0, -1.5, 1.2, -0.8, 0.6, -0.3, 0.15, 0.0, 0.0, 0.0)
    hit = [
        normal_frame(index * 12.0, x=offsets[index], frame_angle=tilts[index])
        for index in range(len(offsets))
    ]

    burnt = [[element("frame", "frame", rotation(0.0), 0.0, FRAME_Y, 0.0)]]

    place = []
    for index in range(12):
        t = index / 11.0
        # Cubic ease-out keeps the base planted while the portal settles.
        scale = 0.72 + 0.28 * (1.0 - (1.0 - t) ** 3)
        place.append(normal_frame(index * 18.0, scale=scale))
    return [("idle", idle), ("hit", hit), ("burnt", burnt), ("place", place)]


def make_anim() -> bytes:
    clips = make_clips()
    names: dict[int, str] = {}
    bank_hash = register_name(names, BANK)
    element_count = sum(len(elements) for _, frames in clips for elements in frames)
    frame_count = sum(len(frames) for _, frames in clips)
    out = bytearray(
        struct.pack("<4sIIIII", b"ANIM", 4, element_count, frame_count, 0, len(clips))
    )
    for clip_name, frames in clips:
        put_string(out, clip_name)
        out.extend(struct.pack("<BIfI", FACING_ALL, bank_hash, FPS, len(frames)))
        for elements in frames:
            out.extend(struct.pack("<ffffI", *FRAME_RECT, 0))
            out.extend(struct.pack("<I", len(elements)))
            for entry in elements:
                symbol, symbol_frame, layer, *values = entry
                out.extend(
                    struct.pack(
                        "<IIIfffffff",
                        register_name(names, str(symbol)),
                        int(symbol_frame),
                        register_name(names, str(layer)),
                        *values,
                    )
                )
    out.extend(struct.pack("<I", len(names)))
    for key, name in sorted(names.items()):
        out.extend(struct.pack("<I", key))
        put_string(out, name)
    return bytes(out)


def zip_info(name: str) -> ZipInfo:
    info = ZipInfo(name, date_time=(1980, 1, 1, 0, 0, 0))
    info.compress_type = ZIP_DEFLATED
    return info


def write_animation() -> Path:
    path = ANIM_DIR / "ttt_portal.zip"
    with ZipFile(path, "w") as archive:
        archive.writestr(zip_info("build.bin"), make_build())
        archive.writestr(zip_info("anim.bin"), make_anim())
        archive.writestr(zip_info("atlas-0.tex"), (UI_DIR / "frame.tex").read_bytes())
        archive.writestr(zip_info("atlas-1.tex"), (UI_DIR / "vortex.tex").read_bytes())
    return path


class Reader:
    def __init__(self, data: bytes):
        self.data = data
        self.offset = 0

    def read(self, fmt: str) -> tuple[object, ...]:
        result = struct.unpack_from("<" + fmt, self.data, self.offset)
        self.offset += struct.calcsize("<" + fmt)
        return result

    def string(self) -> str:
        length = int(self.read("I")[0])
        return bytes(self.read(f"{length}s")[0]).decode("ascii")

    def finish(self) -> None:
        if self.offset != len(self.data):
            raise ValueError(f"Trailing binary data: {len(self.data) - self.offset} bytes")


def read_names(reader: Reader) -> dict[int, str]:
    names: dict[int, str] = {}
    for _ in range(int(reader.read("I")[0])):
        key = int(reader.read("I")[0])
        names[key] = reader.string()
    return names


def inspect_build(data: bytes) -> dict[str, object]:
    reader = Reader(data)
    magic, version, symbol_count, frame_count = reader.read("4sIII")
    if (magic, version) != (b"BILD", 6):
        raise ValueError(f"Unexpected build header: {magic!r} v{version}")
    build_name = reader.string()
    atlases = [reader.string() for _ in range(int(reader.read("I")[0]))]
    raw_frames = []
    for _ in range(int(symbol_count)):
        symbol_hash, count = reader.read("II")
        for _ in range(int(count)):
            values = reader.read("IIffffII")
            raw_frames.append((int(symbol_hash), values))
    vertices = [reader.read("ffffff") for _ in range(int(reader.read("I")[0]))]
    names = read_names(reader)
    reader.finish()
    frames = []
    for symbol_hash, values in raw_frames:
        index, duration, x, y, width, height, start, count = values
        used = vertices[int(start) : int(start) + int(count)]
        frames.append(
            {
                "symbol": names[symbol_hash],
                "index": index,
                "duration": duration,
                "rect": (x, y, width, height),
                "vertices": used,
            }
        )
    if len(frames) != frame_count:
        raise ValueError(f"Build frame count mismatch: {len(frames)} != {frame_count}")
    return {"name": build_name, "atlases": atlases, "frames": frames}


def inspect_anim(data: bytes) -> list[dict[str, object]]:
    reader = Reader(data)
    magic, version, total_elements, total_frames, total_events, count = reader.read(
        "4sIIIII"
    )
    if (magic, version) != (b"ANIM", 4):
        raise ValueError(f"Unexpected animation header: {magic!r} v{version}")
    raw_clips = []
    seen_elements = seen_frames = seen_events = 0
    for _ in range(int(count)):
        name = reader.string()
        facing, bank_hash, rate, frame_count = reader.read("BIfI")
        frames = []
        for _ in range(int(frame_count)):
            rect = reader.read("ffff")
            events = [reader.read("I")[0] for _ in range(int(reader.read("I")[0]))]
            elements = [reader.read("IIIfffffff") for _ in range(int(reader.read("I")[0]))]
            seen_events += len(events)
            seen_elements += len(elements)
            seen_frames += 1
            frames.append({"rect": rect, "events": events, "elements": elements})
        raw_clips.append(
            {
                "name": name,
                "facing": int(facing),
                "bank_hash": int(bank_hash),
                "rate": float(rate),
                "frames": frames,
            }
        )
    names = read_names(reader)
    reader.finish()
    if (seen_elements, seen_frames, seen_events) != (
        total_elements,
        total_frames,
        total_events,
    ):
        raise ValueError("ANIM aggregate counts do not match serialized records")
    for clip in raw_clips:
        clip["bank"] = names[clip.pop("bank_hash")]
        for frame in clip["frames"]:
            frame["elements"] = [
                {
                    "symbol": names[int(entry[0])],
                    "index": int(entry[1]),
                    "layer": names[int(entry[2])],
                    "matrix": entry[3:],
                }
                for entry in frame["elements"]
            ]
    return raw_clips


def verify_outputs() -> dict[str, object]:
    alpha = source_alpha_report()
    for spec in TEXTURES:
        width, height, format_id, mipmaps = inspect_ktex(UI_DIR / spec.output)
        if (width, height, format_id) != (spec.width, spec.height, 2):
            raise ValueError(f"Texture mismatch: {spec.output}")
        root = ET.parse(UI_DIR / f"{Path(spec.output).stem}.xml").getroot()
        texture = root.find("Texture")
        elements = root.find("Elements")
        if texture is None or texture.attrib.get("filename") != spec.output:
            raise ValueError(f"Atlas texture mismatch: {spec.output}")
        found = [] if elements is None else elements.findall("Element")
        if len(found) != 1 or found[0].attrib.get("name") != spec.element:
            raise ValueError(f"Atlas element mismatch: {spec.output}")
        alpha_range = inspect_ktex_alpha(UI_DIR / spec.output)
        if alpha_range[0] > 7 or alpha_range[1] < 128:
            raise ValueError(
                f"Compiled texture lost transparency: {spec.output} alpha={alpha_range}"
            )

    archive_path = ANIM_DIR / "ttt_portal.zip"
    with ZipFile(archive_path) as archive:
        if archive.testzip() is not None:
            raise ValueError("Animation ZIP CRC failure")
        if set(archive.namelist()) != {
            "build.bin",
            "anim.bin",
            "atlas-0.tex",
            "atlas-1.tex",
        }:
            raise ValueError(f"Unexpected animation members: {archive.namelist()}")
        build = inspect_build(archive.read("build.bin"))
        clips = inspect_anim(archive.read("anim.bin"))
        if archive.read("atlas-0.tex") != (UI_DIR / "frame.tex").read_bytes():
            raise ValueError("World frame atlas is not the compiled UI frame texture")
        if archive.read("atlas-1.tex") != (UI_DIR / "vortex.tex").read_bytes():
            raise ValueError("World vortex atlas is not the compiled UI vortex texture")

    if build["name"] != BUILD or build["atlases"] != ["atlas-0.tex", "atlas-1.tex"]:
        raise ValueError(f"Build identity mismatch: {build}")
    frames = {frame["symbol"]: frame for frame in build["frames"]}
    if set(frames) != {"frame", "vortex"}:
        raise ValueError(f"Build symbols mismatch: {set(frames)}")
    for symbol, frame in frames.items():
        vertices = frame["vertices"]
        if len(vertices) != 6:
            raise ValueError(f"{symbol} must contain exactly two triangles")
        sampler = 0 if symbol == "frame" else 1
        if {int(vertex[5]) for vertex in vertices} != {sampler}:
            raise ValueError(f"{symbol} sampler mismatch")
        if not all(0.0 <= value <= 1.0 for vertex in vertices for value in vertex[3:5]):
            raise ValueError(f"{symbol} UV outside 0..1")

    by_name = {clip["name"]: clip for clip in clips}
    if set(by_name) != {"idle", "hit", "burnt", "place"}:
        raise ValueError(f"Animation clips mismatch: {set(by_name)}")
    if any(clip["facing"] != FACING_ALL or clip["bank"] != BANK for clip in clips):
        raise ValueError("Animation facing or bank mismatch")
    if len(by_name["idle"]["frames"]) != 60 or by_name["idle"]["rate"] != FPS:
        raise ValueError("idle must be a 2-second, 30 fps loop")
    for frame in by_name["idle"]["frames"]:
        elements = frame["elements"]
        if [entry["layer"] for entry in elements] != ["WRITING", "frame"]:
            raise ValueError("idle depth/layer order must be WRITING behind frame")
        writing = elements[0]
        if writing["symbol"] != "vortex":
            raise ValueError("WRITING layer must contain the vortex symbol")
    burnt_elements = by_name["burnt"]["frames"][0]["elements"]
    if [entry["symbol"] for entry in burnt_elements] != ["frame"]:
        raise ValueError("burnt must contain the frame only")
    final_hit = by_name["hit"]["frames"][-1]["elements"]
    if any(abs(float(entry["matrix"][4])) > 1e-5 for entry in final_hit):
        raise ValueError("hit must return to its centered idle position")

    return {
        "source_alpha": alpha,
        "textures": {
            spec.output: {
                "ktex": inspect_ktex(UI_DIR / spec.output),
                "alpha": inspect_ktex_alpha(UI_DIR / spec.output),
            }
            for spec in TEXTURES
        },
        "build": {
            "name": build["name"],
            "atlases": build["atlases"],
            "symbols": sorted(frames),
            "triangles": {name: len(frame["vertices"]) // 3 for name, frame in frames.items()},
        },
        "clips": {
            clip["name"]: {
                "frames": len(clip["frames"]),
                "fps": clip["rate"],
                "facing": clip["facing"],
            }
            for clip in clips
        },
        "zip_sha256": hashlib.sha256(archive_path.read_bytes()).hexdigest(),
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--converter",
        type=Path,
        default=CONVERTER,
        help="Path to Klei TextureConverter.exe",
    )
    parser.add_argument(
        "--verify-only",
        action="store_true",
        help="Read and validate existing outputs without rebuilding them",
    )
    args = parser.parse_args()

    if not args.verify_only:
        if not args.converter.is_file():
            raise FileNotFoundError(f"TextureConverter not found: {args.converter}")
        UI_DIR.mkdir(parents=True, exist_ok=True)
        ANIM_DIR.mkdir(parents=True, exist_ok=True)
        report = source_alpha_report()
        for name, details in report.items():
            print(
                f"Source {name}: {details['size']}, alpha {details['alpha']}, "
                f"near-transparent {details['near_transparent']:.1%}"
            )
        for spec in TEXTURES:
            target = compile_texture(spec, args.converter)
            atlas = write_atlas(spec)
            print(f"Compiled {target.relative_to(MOD_ROOT)} and {atlas.relative_to(MOD_ROOT)}")
        archive = write_animation()
        print(f"Packed {archive.relative_to(MOD_ROOT)}")

    report = verify_outputs()
    print(
        "Verified "
        f"BILD v6 {report['build']['name']} symbols={report['build']['symbols']}; "
        f"ANIM v4 clips={list(report['clips'])}; CRC OK; "
        f"SHA256={report['zip_sha256']}"
    )


if __name__ == "__main__":
    main()
