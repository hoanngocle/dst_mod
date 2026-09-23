"""Strict offline renderer for real DST player animation matrices.

The renderer intentionally has no donor build, frame-zero substitution, geometry
fitting, or palette manipulation.  Every visible ANIM element must resolve to an
explicit BILD frame (including a frame record's encoded duration interval).
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass, field
from hashlib import sha256
import json
import math
from pathlib import Path
import struct
import sys
from zipfile import ZipFile

import numpy as np
from PIL import Image, ImageDraw

from facing_alias_map import load_contract, sources_for_facing


ELEMENT = struct.Struct("<IIIfffffff")


def sdbm(value: str) -> int:
    result = 0
    for byte in value.encode("utf8"):
        result = (byte + (result << 6) + (result << 16) - result) & 0xFFFFFFFF
    return result


class BinaryReader:
    def __init__(self, data: bytes):
        self.data = data
        self.pos = 0

    def take(self, size: int) -> bytes:
        value = self.data[self.pos:self.pos + size]
        if len(value) != size:
            raise ValueError("truncated Klei binary")
        self.pos += size
        return value

    def unpack(self, fmt: str):
        return struct.unpack("<" + fmt, self.take(struct.calcsize("<" + fmt)))

    def uint(self) -> int:
        return self.unpack("I")[0]

    def string(self) -> str:
        return self.take(self.uint()).decode("utf8", "strict")


def _read_names(reader: BinaryReader) -> dict[int, str]:
    names = {}
    for _ in range(reader.uint()):
        key = reader.uint()
        value = reader.string()
        if key in names:
            raise ValueError(f"duplicate hash name 0x{key:08x}")
        names[key] = value
    return names


def parse_anim(data: bytes) -> dict:
    reader = BinaryReader(data)
    magic, version, total_elements, total_frames, total_events, clip_count = reader.unpack(
        "4sIIIII"
    )
    if (magic, version) != (b"ANIM", 4):
        raise ValueError("expected ANIM v4")
    raw_clips = []
    seen_elements = seen_frames = seen_events = 0
    for _ in range(clip_count):
        name = reader.string()
        facing, bank_hash, fps, frame_count = reader.unpack("BIfI")
        frames = []
        for _ in range(frame_count):
            bounds = reader.unpack("ffff")
            events = [reader.uint() for _ in range(reader.uint())]
            elements = [ELEMENT.unpack(reader.take(ELEMENT.size))
                        for _ in range(reader.uint())]
            seen_frames += 1
            seen_events += len(events)
            seen_elements += len(elements)
            frames.append({"bounds": bounds, "events": events, "elements": elements})
        raw_clips.append((name, facing, bank_hash, fps, frames))
    names = _read_names(reader)
    if reader.pos != len(data):
        raise ValueError("trailing ANIM bytes")
    if (seen_elements, seen_frames, seen_events) != (
        total_elements, total_frames, total_events
    ):
        raise ValueError("invalid ANIM aggregate counts")
    clips = []
    for name, facing, bank_hash, fps, frames in raw_clips:
        if bank_hash not in names:
            raise ValueError(f"unnamed bank hash 0x{bank_hash:08x}")
        clips.append({"name": name, "facing": facing, "bank": names[bank_hash],
                      "fps": fps, "frames": frames})
    return {"clips": clips, "names": names}


class MissingFrameError(ValueError):
    pass


def index_build_parts(symbols: dict, vertices, atlases) -> dict:
    indexed = {}
    for name, records in symbols.items():
        key = sdbm(name)
        if key in indexed and indexed[key][0] != name:
            raise ValueError(f"SDBM collision for {name!r}")
        ordered = sorted(records, key=lambda record: record[0])
        previous_end = None
        for record in ordered:
            start, duration = record[0], record[1]
            if duration <= 0:
                raise ValueError(f"{name} frame {start} has non-positive duration")
            if previous_end is not None and start < previous_end:
                raise ValueError(f"{name} has overlapping frame durations")
            previous_end = start + duration
        indexed[key] = (name, ordered)
    return {"symbols": indexed, "vertices": vertices, "atlases": atlases}


def resolve_frame(build: dict, symbol_hash: int, frame_index: int):
    symbol = build["symbols"].get(symbol_hash)
    if symbol is None:
        raise MissingFrameError(
            f"unknown symbol 0x{symbol_hash:08x} requested at frame {frame_index}"
        )
    name, records = symbol
    for record in records:
        start, duration = record[0], record[1]
        if start <= frame_index < start + duration:
            return name, record
    raise MissingFrameError(f"{name} has no record covering frame {frame_index}")


@dataclass(frozen=True)
class Visibility:
    arm: str = "normal"
    head: str = "normal"
    hidden_layers: frozenset[int] = field(default_factory=frozenset)
    hidden_symbols: frozenset[int] = field(default_factory=frozenset)

    def __post_init__(self):
        if self.arm not in {"normal", "carry", "both"}:
            raise ValueError(f"invalid arm visibility {self.arm!r}")
        if self.head not in {"normal", "hat", "both"}:
            raise ValueError(f"invalid head visibility {self.head!r}")


ARM_NORMAL_LAYERS = {sdbm("ARM_normal"), sdbm("arm_normal")}
ARM_CARRY_LAYERS = {sdbm("ARM_carry"), sdbm("arm_carry")}
HEAD_NORMAL = sdbm("headbase")
HEAD_HAT = sdbm("headbase_hat")


def is_element_visible(element, visibility: Visibility) -> bool:
    symbol_hash = element[0]
    layer_hash = element[2]
    if layer_hash in visibility.hidden_layers or symbol_hash in visibility.hidden_symbols:
        return False
    if visibility.arm != "both":
        if layer_hash in ARM_NORMAL_LAYERS:
            return visibility.arm == "normal"
        if layer_hash in ARM_CARRY_LAYERS:
            return visibility.arm == "carry"
    if visibility.head != "both":
        if symbol_hash == HEAD_NORMAL:
            return visibility.head == "normal"
        if symbol_hash == HEAD_HAT:
            return visibility.head == "hat"
    return True


@dataclass(frozen=True)
class OverlayBinding:
    target_hash: int
    build: dict
    source_hash: int


def facing_alias_overrides(build: dict, contract: dict, facing: int) -> dict:
    overrides = {}
    for target, source in sources_for_facing(contract, facing).items():
        binding = OverlayBinding(sdbm(target), build, sdbm(source))
        if binding.source_hash not in build["symbols"]:
            raise ValueError(f"archive has no exact facing alias symbol {source!r}")
        overrides[binding.target_hash] = binding
    return overrides


def resolve_element(build: dict, element, overrides=None):
    overrides = overrides or {}
    symbol_hash, frame_index = element[:2]
    binding = overrides.get(symbol_hash)
    if binding is not None:
        return resolve_frame(binding.build, binding.source_hash, frame_index)
    return resolve_frame(build, symbol_hash, frame_index)


def coverage_misses(build: dict, clip: dict, visibility: Visibility,
                    overrides=None, animation_names=None) -> list[dict]:
    misses = []
    for animation_frame, frame in enumerate(clip["frames"]):
        for element in frame["elements"]:
            if not is_element_visible(element, visibility):
                continue
            symbol_hash, build_frame = element[:2]
            try:
                resolve_element(build, element, overrides)
            except MissingFrameError as error:
                symbol = build["symbols"].get(symbol_hash, (None,))[0]
                if symbol is None and animation_names is not None:
                    symbol = animation_names.get(symbol_hash)
                symbol = symbol or f"0x{symbol_hash:08x}"
                misses.append({
                    "animation_frame": animation_frame,
                    "symbol": symbol,
                    "symbol_hash": symbol_hash,
                    "build_frame": build_frame,
                    "error": str(error),
                })
    return misses


def unpaired_upper_skin(clip: dict, visibility: Visibility) -> list[dict]:
    skin_hash = sdbm("arm_upper_skin")
    upper_hash = sdbm("arm_upper")
    misses = []
    for animation_frame, frame in enumerate(clip["frames"]):
        visible = [element for element in frame["elements"]
                   if is_element_visible(element, visibility)]
        layers = {element[2] for element in visible
                  if element[0] == skin_hash and element[1] in (0, 1)}
        for layer_hash in sorted(layers):
            skin_count = sum(element[0] == skin_hash and element[1] in (0, 1)
                             and element[2] == layer_hash for element in visible)
            upper_count = sum(element[0] == upper_hash and element[2] == layer_hash
                              for element in visible)
            if upper_count < skin_count:
                misses.append({
                    "animation_frame": animation_frame,
                    "layer_hash": layer_hash,
                    "upper_skin_count": skin_count,
                    "upper_arm_count": upper_count,
                })
    return misses


def find_clip(parsed_anim: dict, name: str, facing: int) -> dict:
    matches = [clip for clip in parsed_anim["clips"]
               if clip["name"] == name and clip["facing"] == facing]
    if len(matches) != 1:
        raise ValueError(
            f"expected exactly one {name!r} clip for facing {facing}; found {len(matches)}"
        )
    return matches[0]


def gif_schedule(frame_count: int, fps: float, step: int = 4):
    if frame_count <= 0 or fps <= 0 or step <= 0:
        raise ValueError("frame_count, fps, and step must be positive")
    indices = list(range(0, frame_count, step))
    stops = indices[1:] + [frame_count]
    durations = [round(1000.0 * (stop - start) / fps)
                 for start, stop in zip(indices, stops)]
    return indices, durations


def unpremultiply_rgba(stored: np.ndarray) -> np.ndarray:
    pixels = np.asarray(stored, dtype=np.uint16).copy()
    if pixels.ndim != 3 or pixels.shape[2] != 4:
        raise ValueError("expected an HxWx4 RGBA array")
    alpha = pixels[:, :, 3]
    nonzero = alpha > 0
    for channel in range(3):
        values = pixels[:, :, channel]
        values[nonzero] = np.minimum(
            255, (values[nonzero] * 255 + alpha[nonzero] // 2) // alpha[nonzero]
        )
        values[~nonzero] = 0
    return pixels.astype(np.uint8)


def load_build_archive(path: Path) -> dict:
    tools = Path(__file__).resolve().parents[1]
    if str(tools) not in sys.path:
        sys.path.insert(0, str(tools))
    from build_eva_approved import parse_build, read_ktex

    with ZipFile(path) as archive:
        parsed = parse_build(archive.read("build.bin"))
        symbols = {}
        vertices = []
        for symbol in parsed.order:
            records = []
            for frame in parsed.symbols[symbol]:
                start = len(vertices)
                vertices.extend(frame.vertices)
                records.append((
                    frame.index, frame.duration, frame.x, frame.y,
                    frame.width, frame.height, start, len(frame.vertices),
                ))
            symbols[symbol] = records
        stored_atlases = []
        for atlas in parsed.atlases:
            _, image = read_ktex(archive.read(atlas))
            stored_atlases.append(image)
    vertices = np.asarray(vertices, dtype=np.float32)
    atlases = [unpremultiply_rgba(atlas) for atlas in stored_atlases]
    return index_build_parts(symbols, vertices, atlases)


OPTIONAL_OVERLAY_SYMBOLS = frozenset(sdbm(name.lower()) for name in (
    "arm_lower_cuff", "BEARD", "HAIR_HAT", "LANTERN_OVERLAY", "SWAP_BODY",
    "SWAP_BODY_TALL", "SWAP_FACE", "swap_hat",
))
NO_HAT_LAYERS = frozenset(sdbm(name.lower()) for name in (
    "HAT", "HAIR_HAT", "HEAD_HAT", "HEAD_HAT_NOHELM", "HEAD_HAT_HELM",
))
HAT_HEAD_HIDDEN_LAYERS = frozenset(sdbm(name.lower()) for name in (
    "HAIR_NOHAT", "HAIR", "HEAD", "HEAD_HAT_HELM",
))


def candidate_visibility(arm: str, overlay: bool, head: str = "normal") -> Visibility:
    hidden_symbols = set(OPTIONAL_OVERLAY_SYMBOLS)
    if head == "hat":
        hidden_symbols.discard(sdbm("hair_hat"))
    if not overlay:
        hidden_symbols.add(sdbm("swap_object"))
    return Visibility(
        arm=arm,
        head=head,
        hidden_layers=NO_HAT_LAYERS if head == "normal" else HAT_HEAD_HIDDEN_LAYERS,
        hidden_symbols=frozenset(hidden_symbols),
    )


def transform_vertices(vertices: np.ndarray, element) -> np.ndarray:
    result = np.asarray(vertices, dtype=np.float32).copy()
    _, _, _, a, b, c, d, tx, ty, z = element
    source_x = result[:, 0].copy()
    source_y = result[:, 1].copy()
    result[:, 0] = a * source_x + c * source_y + tx
    result[:, 1] = b * source_x + d * source_y + ty
    result[:, 2] += z
    return result


def _resolved_geometry(build: dict, element, overrides=None):
    overrides = overrides or {}
    symbol_hash, frame_index = element[:2]
    binding = overrides.get(symbol_hash)
    selected = binding.build if binding is not None else build
    resolved_hash = binding.source_hash if binding is not None else symbol_hash
    name, record = resolve_frame(selected, resolved_hash, frame_index)
    start, count = record[6], record[7]
    vertices = np.asarray(selected["vertices"][start:start + count], dtype=np.float32)
    if len(vertices) != count or count % 3:
        raise ValueError(f"{name} frame {frame_index} has invalid triangle vertex count {count}")
    return selected, name, record, transform_vertices(vertices, element)


def animation_bounds(build: dict, frames: list[dict], visibility: Visibility,
                     overrides=None, padding: int = 4):
    points = []
    for frame in frames:
        for element in frame["elements"]:
            if is_element_visible(element, visibility):
                points.append(_resolved_geometry(build, element, overrides)[3][:, :2])
    if not points:
        raise ValueError("animation has no visible geometry")
    joined = np.concatenate(points)
    left, top = np.floor(joined.min(axis=0)).astype(int) - padding
    right, bottom = np.ceil(joined.max(axis=0)).astype(int) + padding
    return int(left), int(top), int(right), int(bottom)


def _sample_atlas(atlas: np.ndarray, uv: np.ndarray,
                  sampling: str = "linear") -> np.ndarray:
    atlas_height, atlas_width = atlas.shape[:2]
    if sampling == "nearest":
        sample_x = np.clip(
            np.floor(uv[0] * atlas_width).astype(int), 0, atlas_width - 1
        )
        sample_y = np.clip(
            np.floor(uv[1] * atlas_height).astype(int), 0, atlas_height - 1
        )
        return atlas[sample_y, sample_x]
    if sampling != "linear":
        raise ValueError(f"unknown atlas sampling mode {sampling!r}")

    # Klei UVs address texel cells. Shift to texel centers, then interpolate
    # premultiplied color so transparent DXT color cannot bleed into an edge.
    x = uv[0] * atlas_width - 0.5
    y = uv[1] * atlas_height - 0.5
    x0 = np.floor(x).astype(int)
    y0 = np.floor(y).astype(int)
    x1 = x0 + 1
    y1 = y0 + 1
    wx = (x - x0)[:, None]
    wy = (y - y0)[:, None]
    x0 = np.clip(x0, 0, atlas_width - 1)
    x1 = np.clip(x1, 0, atlas_width - 1)
    y0 = np.clip(y0, 0, atlas_height - 1)
    y1 = np.clip(y1, 0, atlas_height - 1)

    def premultiplied(rows, columns):
        values = atlas[rows, columns].astype(np.float32)
        values[:, :3] *= values[:, 3:4] / 255.0
        return values

    top_values = (
        premultiplied(y0, x0) * (1.0 - wx)
        + premultiplied(y0, x1) * wx
    )
    bottom_values = (
        premultiplied(y1, x0) * (1.0 - wx)
        + premultiplied(y1, x1) * wx
    )
    values = top_values * (1.0 - wy) + bottom_values * wy
    alpha = values[:, 3:4]
    nonzero = alpha[:, 0] > 0
    values[nonzero, :3] *= 255.0 / alpha[nonzero]
    values[~nonzero, :3] = 0
    return np.clip(np.rint(values), 0, 255).astype(np.uint8)


def _source_over_rgba(destination: np.ndarray, source: np.ndarray) -> np.ndarray:
    """Composite straight-alpha uint8 RGBA source over destination."""
    destination = np.asarray(destination, dtype=np.uint8)
    source = np.asarray(source, dtype=np.uint8)
    if destination.shape != source.shape or destination.shape[-1] != 4:
        raise ValueError("source-over inputs must be equal-shaped RGBA arrays")
    dst = destination.astype(np.uint32)
    src = source.astype(np.uint32)
    src_alpha = src[..., 3]
    dst_alpha = dst[..., 3]
    inverse_source = 255 - src_alpha
    alpha_numerator = src_alpha * 255 + dst_alpha * inverse_source

    result = np.zeros_like(src, dtype=np.uint32)
    result[..., 3] = (alpha_numerator + 127) // 255
    nonzero = alpha_numerator > 0
    for channel in range(3):
        color_numerator = (
            src[..., channel] * src_alpha * 255
            + dst[..., channel] * dst_alpha * inverse_source
        )
        result[..., channel][nonzero] = (
            color_numerator[nonzero] + alpha_numerator[nonzero] // 2
        ) // alpha_numerator[nonzero]
    return np.clip(result, 0, 255).astype(np.uint8)


def _paint_triangle(layer: np.ndarray, triangle: np.ndarray, atlas: np.ndarray,
                    left: int, top: int, sampling: str = "linear") -> None:
    triangle = np.asarray(triangle, dtype=np.float32)
    edge_a = triangle[1, :2] - triangle[0, :2]
    edge_b = triangle[2, :2] - triangle[0, :2]
    signed_area = edge_a[0] * edge_b[1] - edge_a[1] * edge_b[0]
    if abs(signed_area) < 1e-8:
        return
    # Normalize winding while carrying UV/atlas payload with each vertex.
    # This makes the top-left edge rule invariant under reflected ANIM matrices.
    if signed_area < 0:
        triangle = triangle[[0, 2, 1]]
    x0, y0 = np.floor(triangle[:, :2].min(axis=0)).astype(int)
    x1, y1 = np.ceil(triangle[:, :2].max(axis=0)).astype(int)
    x0, y0 = max(x0, left), max(y0, top)
    x1 = min(x1, left + layer.shape[1])
    y1 = min(y1, top + layer.shape[0])
    if x1 <= x0 or y1 <= y0:
        return
    matrix = np.vstack((triangle[:, :2].T, np.ones(3)))
    yy, xx = np.mgrid[y0:y1, x0:x1]
    sample_x = xx.ravel() + 0.5
    sample_y = yy.ravel() + 0.5
    weights = np.linalg.solve(
        matrix,
        np.vstack((sample_x, sample_y, np.ones(xx.size))),
    )

    def edge_values(start, end):
        return ((end[0] - start[0]) * (sample_y - start[1])
                - (end[1] - start[1]) * (sample_x - start[0]))

    def is_top_left(start, end):
        dx, dy = end - start
        return dy < 0 or (dy == 0 and dx > 0)

    edges = (
        (triangle[1, :2], triangle[2, :2]),
        (triangle[2, :2], triangle[0, :2]),
        (triangle[0, :2], triangle[1, :2]),
    )
    inside = np.ones(sample_x.shape, dtype=bool)
    for start, end in edges:
        values = edge_values(start, end)
        inside &= ((values > 1e-6)
                   | ((np.abs(values) <= 1e-6) & is_top_left(start, end)))
    if not np.any(inside):
        return
    uv = triangle[:, 3:5].T @ weights
    target_x = xx.ravel()[inside] - left
    target_y = yy.ravel()[inside] - top
    source = _sample_atlas(atlas, uv[:, inside], sampling)
    destination = layer[target_y, target_x]
    layer[target_y, target_x] = _source_over_rgba(destination, source)


def render_animation_frame(build: dict, frame: dict, visibility: Visibility,
                           bounds=None, overrides=None,
                           sampling: str = "linear") -> Image.Image:
    if bounds is None:
        bounds = animation_bounds(build, [frame], visibility, overrides)
    left, top, right, bottom = bounds
    if right <= left or bottom <= top:
        raise ValueError(f"invalid render bounds {bounds}")
    canvas = Image.new("RGBA", (right - left, bottom - top))
    visible = [element for element in frame["elements"]
               if is_element_visible(element, visibility)]
    # Klei's more-negative Z is closer to camera; Pillow paints back-to-front.
    for element in sorted(visible, key=lambda item: item[-1], reverse=True):
        selected, _, _, vertices = _resolved_geometry(build, element, overrides)
        layer = np.zeros((bottom - top, right - left, 4), dtype=np.uint8)
        for triangle in vertices.reshape((-1, 3, 6)):
            atlas_index = round(float(triangle[0, 5]))
            if not 0 <= atlas_index < len(selected["atlases"]):
                raise ValueError(f"atlas index {atlas_index} is out of range")
            _paint_triangle(
                layer, triangle, selected["atlases"][atlas_index], left, top,
                sampling,
            )
        canvas.alpha_composite(Image.fromarray(layer, "RGBA"))
    return canvas


MOTION_SPECS = {
    "idle": ("player_idles.zip", "idle_loop", 66, "normal"),
    "run": ("player_basic.zip", "run_loop", 16, "normal"),
    "atk": ("player_attacks.zip", "atk", 19, "carry"),
    "scythe": ("player_actions_scythe.zip", "scythe_loop", 26, "carry"),
}
FACING_LABELS = {8: "front", 5: "profile", 2: "rear"}


def _contact_sheet(items, title: str) -> Image.Image:
    cell_width = max(image.width for _, image in items) + 24
    cell_height = max(image.height for _, image in items) + 52
    sheet = Image.new("RGB", (cell_width * len(items), cell_height), "#282631")
    draw = ImageDraw.Draw(sheet)
    draw.text((12, 8), title, fill="white")
    for index, (label, image) in enumerate(items):
        x = index * cell_width + (cell_width - image.width) // 2
        y = 30 + (cell_height - 42 - image.height) // 2
        sheet.paste(image, (x, y), image)
        draw.text((index * cell_width + 12, cell_height - 18), label, fill="#ddd7e5")
    return sheet


def _parse_overlay(spec: str | None):
    if spec is None:
        return {}
    try:
        target, remainder = spec.split("=", 1)
        archive_text, source = remainder.rsplit("#", 1)
    except ValueError as error:
        raise ValueError("overlay must be TARGET=ARCHIVE#SOURCE") from error
    overlay_build = load_build_archive(Path(archive_text))
    binding = OverlayBinding(sdbm(target.lower()), overlay_build, sdbm(source))
    # Validate the requested source immediately; do not guess another symbol.
    if binding.source_hash not in overlay_build["symbols"]:
        raise ValueError(f"overlay archive has no exact symbol {source!r}")
    return {binding.target_hash: binding}


def render_outputs(archive_path: Path, output: Path, game_anim: Path,
                   motions: list[str], overlay_spec: str | None = None,
                   idle_contact_only: bool = False,
                   override_map_path: Path | None = None,
                   sampling: str = "linear") -> dict:
    if idle_contact_only and motions != ["idle"]:
        raise ValueError("idle_contact_only requires motions=['idle']")
    build = load_build_archive(archive_path)
    overrides = _parse_overlay(overlay_spec)
    alias_contract = load_contract(override_map_path) if override_map_path else None
    output.mkdir(parents=True, exist_ok=True)
    prepared = {}
    report = {
        "archive": str(archive_path.resolve()),
        "archive_sha256": sha256(archive_path.read_bytes()).hexdigest(),
        "matrix_policy": "exact ANIM matrices; one build unit per output pixel",
        "frame_policy": "exact BILD frame or duration interval; no fallback",
        "atlas_policy": "DXT5 premultiplied RGBA unpremultiplied once",
        "sampling": sampling,
        "overlay": overlay_spec,
        "facing_alias_map": str(override_map_path.resolve()) if override_map_path else None,
        "idle_contact_only": idle_contact_only,
        "motions": {},
    }
    for motion in motions:
        filename, clip_name, expected_count, arm = MOTION_SPECS[motion]
        with ZipFile(game_anim / filename) as archive:
            parsed = parse_anim(archive.read("anim.bin"))
        motion_report = {}
        visibility = candidate_visibility(arm, overlay=bool(overrides))
        for facing, facing_label in FACING_LABELS.items():
            motion_overrides = dict(overrides)
            if alias_contract is not None:
                motion_overrides.update(facing_alias_overrides(build, alias_contract, facing))
            clip = find_clip(parsed, clip_name, facing)
            if len(clip["frames"]) != expected_count:
                raise ValueError(
                    f"{filename}:{clip_name}:{facing} has {len(clip['frames'])} frames; "
                    f"expected {expected_count}"
                )
            misses = coverage_misses(
                build, clip, visibility, overrides=motion_overrides,
                animation_names=parsed["names"],
            )
            if misses:
                preview = json.dumps(misses[:12], indent=2)
                raise MissingFrameError(
                    f"{motion}/{facing_label} has {len(misses)} visible missing references:\n{preview}"
                )
            bounds = animation_bounds(build, clip["frames"], visibility, motion_overrides)
            prepared[(motion, facing)] = (clip, visibility, bounds, motion_overrides)
            motion_report[facing_label] = {
                "facing": facing, "frames": len(clip["frames"]), "fps": clip["fps"],
                "bounds": list(bounds), "coverage_misses": 0,
            }
        report["motions"][motion] = motion_report

    if "idle" in motions:
        items = []
        for facing, label in FACING_LABELS.items():
            clip, visibility, bounds, motion_overrides = prepared[("idle", facing)]
            image = render_animation_frame(
                build, clip["frames"][8], visibility, bounds, motion_overrides,
                sampling,
            )
            items.append((f"{label} / frame 8", image))
        _contact_sheet(items, "EVA candidate / real player_idles idle_loop / frame 8").save(
            output / "idle-frame-008-contact.png"
        )

    if idle_contact_only:
        (output / "render-manifest.json").write_text(
            json.dumps(report, indent=2), encoding="utf8"
        )
        return report

    if "idle" in motions:
        arm_items = []
        hat_items = []
        state_report = {
            "arm_carry": {},
            "hat": {},
            "combinations": {
                "nohat_normal": {},
                "nohat_carry": {},
                "hat_normal": {},
                "hat_carry": {},
            },
            "blink_window": {},
            "headbase_hat_frame3_exercised": False,
        }
        for facing, facing_label in FACING_LABELS.items():
            clip, normal_visibility, _, motion_overrides = prepared[("idle", facing)]
            carry_visibility = candidate_visibility("carry", overlay=False)
            hat_visibility = candidate_visibility("normal", overlay=False, head="hat")
            hat_carry_visibility = candidate_visibility(
                "carry", overlay=False, head="hat"
            )
            for state_name, state_visibility in (
                ("arm_carry", carry_visibility), ("hat", hat_visibility),
            ):
                misses = coverage_misses(
                    build, clip, state_visibility, overrides=motion_overrides
                )
                pairs = unpaired_upper_skin(clip, state_visibility)
                if misses:
                    raise MissingFrameError(
                        f"idle/{facing_label}/{state_name} has {len(misses)} missing references:\n"
                        + json.dumps(misses[:12], indent=2)
                    )
                if pairs:
                    raise ValueError(
                        f"idle/{facing_label}/{state_name} has unpaired upper-skin elements:\n"
                        + json.dumps(pairs[:12], indent=2)
                    )
                state_report[state_name][facing_label] = {
                    "coverage_misses": 0, "unpaired_upper_skin": 0,
                }

            combinations = (
                ("nohat_normal", "no hat / ARM_normal", normal_visibility),
                ("nohat_carry", "no hat / ARM_carry", carry_visibility),
                ("hat_normal", "hat / ARM_normal", hat_visibility),
                ("hat_carry", "hat / ARM_carry", hat_carry_visibility),
            )
            combination_bounds = []
            for state_name, _, state_visibility in combinations:
                misses = coverage_misses(
                    build, clip, state_visibility, overrides=motion_overrides
                )
                pairs = unpaired_upper_skin(clip, state_visibility)
                if misses:
                    raise MissingFrameError(
                        f"idle/{facing_label}/{state_name} has {len(misses)} missing references:\n"
                        + json.dumps(misses[:12], indent=2)
                    )
                if pairs:
                    raise ValueError(
                        f"idle/{facing_label}/{state_name} has unpaired upper-skin elements:\n"
                        + json.dumps(pairs[:12], indent=2)
                    )
                combination_bounds.append(animation_bounds(
                    build, clip["frames"], state_visibility, motion_overrides
                ))
                visible_head_frames = sorted({
                    element[1]
                    for frame in clip["frames"]
                    for element in frame["elements"]
                    if element[0] in {HEAD_NORMAL, HEAD_HAT}
                    and is_element_visible(element, state_visibility)
                })
                state_report["combinations"][state_name][facing_label] = {
                    "coverage_misses": 0,
                    "unpaired_upper_skin": 0,
                    "visible_head_frames": visible_head_frames,
                }
                if state_visibility.head == "hat" and 3 in visible_head_frames:
                    state_report["headbase_hat_frame3_exercised"] = True

            combination_common_bounds = (
                min(bounds[0] for bounds in combination_bounds),
                min(bounds[1] for bounds in combination_bounds),
                max(bounds[2] for bounds in combination_bounds),
                max(bounds[3] for bounds in combination_bounds),
            )
            combination_items = [
                (
                    label,
                    render_animation_frame(
                        build, clip["frames"][8], state_visibility,
                        combination_common_bounds, motion_overrides, sampling,
                    ),
                )
                for _, label, state_visibility in combinations
            ]
            _contact_sheet(
                combination_items,
                f"EVA candidate / idle_loop frame 8 / {facing_label} / native layer selection",
            ).save(
                output / f"idle-{facing_label}-state-combinations-frame-008-contact.png"
            )

            normal_bounds = animation_bounds(
                build, clip["frames"], normal_visibility, motion_overrides
            )
            carry_bounds = animation_bounds(
                build, clip["frames"], carry_visibility, motion_overrides
            )
            common_bounds = (
                min(normal_bounds[0], carry_bounds[0]),
                min(normal_bounds[1], carry_bounds[1]),
                max(normal_bounds[2], carry_bounds[2]),
                max(normal_bounds[3], carry_bounds[3]),
            )
            for state_name, state_visibility in (
                ("normal", normal_visibility), ("carry", carry_visibility),
            ):
                arm_items.append((
                    f"{facing_label} / {state_name}",
                    render_animation_frame(
                        build, clip["frames"][8], state_visibility, common_bounds,
                        motion_overrides, sampling,
                    ),
                ))
            hat_bounds = animation_bounds(
                build, clip["frames"], hat_visibility, motion_overrides
            )
            hat_items.append((
                f"{facing_label} / hat branch",
                render_animation_frame(
                    build, clip["frames"][8], hat_visibility, hat_bounds,
                    motion_overrides, sampling,
                ),
            ))

            blink_indices = (8, 32, 33, 34, 35)
            blink_items = []
            face_frames = []
            cheeks_frames = []
            face_hash = sdbm("face")
            cheeks_hash = sdbm("cheeks")
            for frame_index in blink_indices:
                frame = clip["frames"][frame_index]
                blink_items.append((
                    f"native frame {frame_index}",
                    render_animation_frame(
                        build, frame, normal_visibility, normal_bounds,
                        motion_overrides, sampling,
                    ),
                ))
                for element in frame["elements"]:
                    if not is_element_visible(element, normal_visibility):
                        continue
                    if element[0] == face_hash:
                        face_frames.append(element[1])
                    elif element[0] == cheeks_hash:
                        cheeks_frames.append(element[1])
            _contact_sheet(
                blink_items,
                f"EVA candidate / idle_loop blink window / {facing_label} / no hat + ARM_normal",
            ).save(output / f"idle-{facing_label}-blink-window-contact.png")
            state_report["blink_window"][facing_label] = {
                "native_animation_frames": list(blink_indices),
                "face_frames": face_frames,
                "cheeks_frames": cheeks_frames,
                "coverage_misses": 0,
            }
        _contact_sheet(
            arm_items, "EVA candidate / idle frame 8 / ARM_normal vs ARM_carry / body-only"
        ).save(output / "idle-arm-states-frame-008-contact.png")
        _contact_sheet(
            hat_items, "EVA candidate / idle frame 8 / visible headbase_hat branch"
        ).save(output / "idle-hat-state-frame-008-contact.png")
        report["state_probes"] = state_report

    for motion in motions:
        for facing, facing_label in FACING_LABELS.items():
            clip, visibility, bounds, motion_overrides = prepared[(motion, facing)]
            frame_count = len(clip["frames"])
            gif_indices, gif_durations = gif_schedule(frame_count, clip["fps"], 4)
            key_indices = sorted(set((0, frame_count // 4, frame_count // 2,
                                      3 * frame_count // 4, frame_count - 1)))
            needed = sorted(set(gif_indices + key_indices))
            rendered = {
                index: render_animation_frame(
                    build, clip["frames"][index], visibility, bounds,
                    motion_overrides, sampling,
                )
                for index in needed
            }
            _contact_sheet(
                [(f"frame {index}", rendered[index]) for index in key_indices],
                f"EVA candidate / {motion} / {facing_label} / native matrices",
            ).save(output / f"{motion}-{facing_label}-contact.png")
            gif_frames = []
            for index in gif_indices:
                background = Image.new("RGBA", rendered[index].size, "#282631")
                background.alpha_composite(rendered[index])
                gif_frames.append(background.convert("RGB"))
            gif_frames[0].save(
                output / f"{motion}-{facing_label}.gif",
                save_all=True, append_images=gif_frames[1:], loop=0,
                duration=gif_durations, disposal=2, optimize=False,
            )
            report["motions"][motion][facing_label].update({
                "gif_indices": gif_indices,
                "gif_durations_ms": gif_durations,
                "keyframes": key_indices,
            })
    (output / "render-manifest.json").write_text(
        json.dumps(report, indent=2), encoding="utf8"
    )
    return report


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--archive", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument(
        "--game-anim", type=Path,
        default=Path("C:/Program Files (x86)/Steam/steamapps/common/Don't Starve Together/data/anim"),
    )
    parser.add_argument("--motion", action="append", choices=tuple(MOTION_SPECS))
    parser.add_argument(
        "--idle-contact-only", action="store_true",
        help="coverage-check all 66 idle frames, then render only frame 8 at facings 8/5/2",
    )
    parser.add_argument(
        "--overlay",
        help="explicit override TARGET=ARCHIVE#SOURCE, e.g. swap_object=swap.zip#swap_eva_scythe",
    )
    parser.add_argument(
        "--override-map", type=Path,
        help="JSON facing alias contract applied from the candidate build",
    )
    parser.add_argument(
        "--sampling", choices=("linear", "nearest"), default="linear",
        help="atlas texture sampling; linear is native-like, nearest is diagnostic",
    )
    args = parser.parse_args(argv)
    motions = ["idle"] if args.idle_contact_only else (args.motion or list(MOTION_SPECS))
    report = render_outputs(
        args.archive, args.output, args.game_anim, motions, args.overlay,
        idle_contact_only=args.idle_contact_only,
        override_map_path=args.override_map,
        sampling=args.sampling,
    )
    print(json.dumps({"output": str(args.output.resolve()), "motions": report["motions"]}, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
