"""Build the approved EVA player art on the existing native player rig.

The builder is deterministic and source-driven.  It keeps EVA's anim.bin,
build identity, default skin, two-atlas limit, and complete existing symbol /
frame coverage.  Normal body frames are replaced from approved transparent
parts; Luoshen expressions and rare existing specials remain explicit in the
generated rig-map instead of being silently repeated or dropped.
"""

from __future__ import annotations

from dataclasses import dataclass
from hashlib import sha256
from io import BytesIO
import argparse
import json
import math
from pathlib import Path
import struct
from zipfile import ZIP_DEFLATED, ZipFile, ZipInfo

import numpy as np
from PIL import Image


MOD = Path(__file__).resolve().parents[1]
SOURCE = MOD / "assets/source/eva_approved"
BASELINE = SOURCE / "baseline-eva.zip"
DONOR = SOURCE / "donor-luoshen.zip"
DEFAULT_OUTPUT = MOD / "tools/eva/output/eva-full-rig-candidate.zip"
PLAYER_IDLES = Path(
    "C:/Program Files (x86)/Steam/steamapps/common/Don't Starve Together/"
    "data/anim/player_idles.zip"
)
SIZE = 2048
MIP = struct.Struct("<HHHI")
VERTEX = struct.Struct("<ffffff")
FRAME = struct.Struct("<IIffffII")
ELEMENT = struct.Struct("<IIIfffffff")
ANIM_SHA256 = "13969e77f249aff2a55035cd36e9134a31380b367dc4d4b4c2c2f57c41e8de9d"


def sdbm(name: str) -> int:
    value = 0
    for byte in name.lower().encode("utf8"):
        value = (byte + (value << 6) + (value << 16) - value) & 0xFFFFFFFF
    return value


class Reader:
    def __init__(self, data: bytes):
        self.data = data
        self.pos = 0

    def take(self, size: int) -> bytes:
        value = self.data[self.pos:self.pos + size]
        if len(value) != size:
            raise ValueError("truncated native asset")
        self.pos += size
        return value

    def unpack(self, fmt: str):
        fmt = "<" + fmt
        return struct.unpack(fmt, self.take(struct.calcsize(fmt)))

    def uint(self) -> int:
        return self.unpack("I")[0]

    def string(self) -> str:
        return self.take(self.uint()).decode("ascii")


@dataclass
class BuildFrame:
    index: int
    duration: int
    x: float
    y: float
    width: float
    height: float
    vertices: list[tuple[float, float, float, float, float, float]]


@dataclass
class BuildData:
    name: str
    atlases: list[str]
    order: list[str]
    hashes: dict[str, int]
    symbols: dict[str, list[BuildFrame]]
    names: dict[int, str]


def parse_build(data: bytes) -> BuildData:
    reader = Reader(data)
    magic, version, symbol_count, frame_count = reader.unpack("4sIII")
    if (magic, version) != (b"BILD", 6):
        raise ValueError("expected BILD v6")
    name = reader.string()
    atlases = [reader.string() for _ in range(reader.uint())]
    raw = []
    for _ in range(symbol_count):
        key, count = reader.unpack("II")
        raw.append((key, [reader.unpack("IIffffII") for _ in range(count)]))
    vertices = [reader.unpack("ffffff") for _ in range(reader.uint())]
    names = {}
    for _ in range(reader.uint()):
        key = reader.uint()
        names[key] = reader.string()
    if reader.pos != len(data):
        raise ValueError("trailing BILD data")
    order = [names[key] for key, _ in raw]
    symbols = {}
    hashes = {}
    for key, frames in raw:
        symbol = names[key]
        hashes[symbol] = key
        symbols[symbol] = [BuildFrame(
            int(index), int(duration), x, y, width, height,
            list(vertices[start:start + count]),
        ) for index, duration, x, y, width, height, start, count in frames]
    if sum(map(len, symbols.values())) != frame_count:
        raise ValueError("BILD frame count mismatch")
    return BuildData(name, atlases, order, hashes, symbols, names)


def put_string(out: bytearray, value: str) -> None:
    encoded = value.encode("ascii")
    out.extend(struct.pack("<I", len(encoded)))
    out.extend(encoded)


def write_build(build: BuildData) -> bytes:
    symbol_order = sorted(build.order, key=lambda name: build.hashes[name])
    frame_count = sum(len(build.symbols[name]) for name in symbol_order)
    out = bytearray(struct.pack("<4sIII", b"BILD", 6, len(symbol_order), frame_count))
    put_string(out, build.name)
    out.extend(struct.pack("<I", len(build.atlases)))
    for atlas in build.atlases:
        put_string(out, atlas)
    flat_vertices = []
    for symbol in symbol_order:
        frames = build.symbols[symbol]
        out.extend(struct.pack("<II", build.hashes[symbol], len(frames)))
        for frame in frames:
            start = len(flat_vertices)
            flat_vertices.extend(frame.vertices)
            out.extend(FRAME.pack(
                frame.index, frame.duration, frame.x, frame.y,
                frame.width, frame.height, start, len(frame.vertices),
            ))
    out.extend(struct.pack("<I", len(flat_vertices)))
    for vertex in flat_vertices:
        out.extend(VERTEX.pack(*vertex))
    out.extend(struct.pack("<I", len(build.names)))
    for key, value in sorted(build.names.items()):
        out.extend(struct.pack("<I", key))
        put_string(out, value)
    return bytes(out)


def read_ktex(data: bytes):
    if data[:4] != b"KTEX":
        raise ValueError("expected KTEX")
    specification = struct.unpack_from("<I", data, 4)[0]
    mip_count = (specification >> 13) & 31
    records = [MIP.unpack_from(data, 8 + index * MIP.size) for index in range(mip_count)]
    offset = 8 + mip_count * MIP.size
    width, height, _, size = records[0]
    image = Image.frombytes(
        "RGBA", (width, height), data[offset:offset + size], "bcn", (3, "DXT5")
    )
    return specification, image


def encode_dxt5(image: Image.Image) -> bytes:
    stream = BytesIO()
    image.save(stream, format="DDS", pixel_format="DXT5")
    data = stream.getvalue()
    if data[84:88] != b"DXT5":
        raise RuntimeError("Pillow did not emit DXT5")
    return data[128:]


def make_ktex(top: Image.Image, source_specification: int) -> bytes:
    image = top
    sizes = []
    payloads = []
    while True:
        sizes.append(image.size)
        payloads.append(encode_dxt5(image))
        if image.size == (1, 1):
            break
        target = (max(1, image.width // 2), max(1, image.height // 2))
        image = Image.merge("RGBA", tuple(
            channel.resize(target, Image.Resampling.LANCZOS)
            for channel in image.split()
        ))
    specification = (source_specification & ~(31 << 13)) | (len(payloads) << 13)
    out = bytearray(b"KTEX" + struct.pack("<I", specification))
    for (width, height), payload in zip(sizes, payloads):
        out.extend(MIP.pack(width, height, max(4, width) * 4, len(payload)))
    for payload in payloads:
        out.extend(payload)
    return bytes(out)


def premultiply(image: Image.Image) -> Image.Image:
    pixels = np.asarray(image.convert("RGBA"), dtype=np.uint16).copy()
    alpha = pixels[:, :, 3:4]
    pixels[:, :, :3] = (pixels[:, :, :3] * alpha + 127) // 255
    return Image.fromarray(pixels.astype(np.uint8), "RGBA")


def visible_crop(image: Image.Image, padding: int = 4):
    alpha = image.getchannel("A")
    bounds = alpha.point(lambda value: 255 if value >= 32 else 0).getbbox()
    if bounds is None:
        raise ValueError("source component has no alpha >= 32")
    left, top, right, bottom = bounds
    bounds = (
        max(0, left - padding), max(0, top - padding),
        min(image.width, right + padding), min(image.height, bottom + padding),
    )
    return image.crop(bounds), bounds


def grid_parts(filename, rows, columns, names):
    sheet = Image.open(SOURCE / filename).convert("RGBA")
    result = {}
    for index, name in enumerate(names):
        row, column = divmod(index, len(columns) - 1)
        cell = sheet.crop((columns[column], rows[row], columns[column + 1], rows[row + 1]))
        image, bounds = visible_crop(cell)
        result[name] = image
    return result


def cropped_parts(filename, regions):
    sheet = Image.open(SOURCE / filename).convert("RGBA")
    return {name: visible_crop(sheet.crop(rect))[0]
            for name, rect in regions.items()}


def fit_into(canvas: Image.Image, image: Image.Image, rect, preserve_aspect=True):
    left, top, right, bottom = rect
    width, height = right - left, bottom - top
    if preserve_aspect:
        scale = min(width / image.width, height / image.height)
        target = (max(1, round(image.width * scale)), max(1, round(image.height * scale)))
        x = round((left + right - target[0]) / 2)
        y = round((top + bottom - target[1]) / 2)
    else:
        target = (width, height)
        x, y = left, top
    canvas.alpha_composite(image.resize(target, Image.Resampling.LANCZOS), (x, y))


def crop_composite(canvas: Image.Image):
    image, bounds = visible_crop(canvas)
    return image, (bounds[0], bounds[1])


def load_sources():
    names = (
        "head_blank", "face", "crown", "back_hair", "bodice", "skirt",
        "upper_arm", "forearm", "hand",
    )
    front = grid_parts("front-parts.png", (0, 410, 890, 1254),
                       (0, 420, 820, 1254), names)
    profile = grid_parts("side-parts.png", (0, 412, 960, 1254),
                         (0, 440, 820, 1254), names)
    rear = cropped_parts("rear-parts.png", {
        "rear_head": (0, 100, 415, 585),
        "quarter_rear_head": (415, 100, 825, 585),
        "back_hair": (825, 0, 1254, 640),
        "bodice": (30, 680, 390, 1120),
        "skirt": (360, 660, 870, 1230),
        "quarter_skirt": (850, 680, 1254, 1210),
    })
    hands = grid_parts("hand-poses-clean.png", (0, 512, 1024),
                       (0, 384, 768, 1152, 1536), (
                           "relaxed_palm", "relaxed_back", "relaxed_side", "fist_palm",
                           "grip_palm", "grip_back", "grip_side", "fist_back",
                       ))
    tresses = grid_parts("hair-tresses.png", (0, 1024), (0, 768, 1536),
                         ("left", "right"))
    rear_hat, _ = visible_crop(Image.open(SOURCE / "rear-head-hat.png").convert("RGBA"))
    return {"front": front, "profile": profile, "rear": rear,
            "hands": hands, "tresses": tresses, "rear_hat": rear_hat}


def head_composites(parts):
    result = {}
    for view, layout, face_rect in (
        ("front", {
            "back_hair": (62, 111, 429, 579),
            "head_blank": (109, 52, 387, 353),
            "crown": (180, 64, 347, 147),
        }, (151, 190, 361, 306)),
        ("profile", {
            "back_hair": (100, 49, 344, 557),
            "head_blank": (157, 42, 433, 352),
            "crown": (298, 65, 405, 130),
        }, (308, 187, 412, 295)),
    ):
        for hat in (False, True):
            canvas = Image.new("RGBA", (512, 640))
            fit_into(canvas, parts[view]["head_blank"], layout["head_blank"])
            if not hat:
                fit_into(canvas, parts[view]["crown"], layout["crown"])
            image, origin = crop_composite(canvas)
            result[(view, hat)] = {
                "image": image,
                "origin": origin,
                "face_center": ((face_rect[0] + face_rect[2]) / 2,
                                (face_rect[1] + face_rect[3]) / 2),
                "face_size": (face_rect[2] - face_rect[0], face_rect[3] - face_rect[1]),
            }
    for hat in (False, True):
        canvas = Image.new("RGBA", (512, 640))
        head = parts["rear_hat"] if hat else parts["rear"]["rear_head"]
        fit_into(canvas, head, (105, 48, 407, 365))
        image, origin = crop_composite(canvas)
        result[("rear", hat)] = {"image": image, "origin": origin}
    return result


def zip_info(name: str) -> ZipInfo:
    info = ZipInfo(name, date_time=(1980, 1, 1, 0, 0, 0))
    info.compress_type = ZIP_DEFLATED
    info.create_system = 0
    info.external_attr = 0
    return info


def load_idle(facing: int):
    with ZipFile(PLAYER_IDLES) as archive:
        reader = Reader(archive.read("anim.bin"))
    if reader.unpack("4sI") != (b"ANIM", 4):
        raise ValueError("expected player_idles ANIM v4")
    reader.take(12)
    matches = []
    for _ in range(reader.uint()):
        name = reader.string()
        animation_facing = reader.take(1)[0]
        reader.take(8)
        frames = []
        for _ in range(reader.uint()):
            reader.take(16)
            reader.take(reader.uint() * 4)
            frames.append([ELEMENT.unpack(reader.take(ELEMENT.size))
                           for _ in range(reader.uint())])
        if name == "idle_loop" and animation_facing == facing:
            matches.append(frames)
    if len(matches) != 1:
        raise ValueError(f"expected one idle_loop facing {facing}")
    return matches[0]


def bounds(vertices):
    if not vertices:
        return None
    return (
        min(vertex[0] for vertex in vertices), min(vertex[1] for vertex in vertices),
        max(vertex[0] for vertex in vertices), max(vertex[1] for vertex in vertices),
    )


def donor_frame(donor: BuildData, symbol: str, index: int):
    frames = donor.symbols.get(symbol, [])
    return next((frame for frame in frames if frame.index == index), None)


def element_for(elements, symbol: str, frame_index: int):
    key = sdbm(symbol)
    matches = [element for element in elements
               if element[0] == key and element[1] == frame_index]
    if not matches:
        raise ValueError(f"idle calibration lacks {symbol}:{frame_index}")
    return matches[0]


def transformed_bounds(vertices, element):
    a, b, c, d, tx, ty = element[3:9]
    points = [(a * x + c * y + tx, b * x + d * y + ty)
              for x, y, *_ in vertices]
    return (min(x for x, _ in points), min(y for _, y in points),
            max(x for x, _ in points), max(y for _, y in points))


def inverse_point(element, x, y):
    a, b, c, d, tx, ty = element[3:9]
    determinant = a * d - b * c
    if abs(determinant) < 1e-8:
        raise ValueError("singular idle head transform")
    x, y = x - tx, y - ty
    return ((d * x - c * y) / determinant,
            (-b * x + a * y) / determinant)


def calibrated_head_corners(info, head_element, face_element, face_frame):
    face_world = transformed_bounds(face_frame.vertices, face_element)
    face_width = face_world[2] - face_world[0]
    face_height = face_world[3] - face_world[1]
    scale = min(face_width / info["face_size"][0],
                face_height / info["face_size"][1])
    face_center = ((face_world[0] + face_world[2]) / 2,
                   (face_world[1] + face_world[3]) / 2)
    relative_face = (info["face_center"][0] - info["origin"][0],
                     info["face_center"][1] - info["origin"][1])
    left = face_center[0] - relative_face[0] * scale
    top = face_center[1] - relative_face[1] * scale
    right = left + info["image"].width * scale
    bottom = top + info["image"].height * scale
    corners = [inverse_point(head_element, x, y) for x, y in (
        (left, top), (right, top), (left, bottom), (right, bottom),
    )]
    canvas_origin = (left - info["origin"][0] * scale,
                     top - info["origin"][1] * scale)
    return corners, scale, canvas_origin


def canvas_aligned_corners(info, head_element, scale, canvas_origin):
    left = canvas_origin[0] + info["origin"][0] * scale
    top = canvas_origin[1] + info["origin"][1] * scale
    right = left + info["image"].width * scale
    bottom = top + info["image"].height * scale
    return [inverse_point(head_element, x, y) for x, y in (
        (left, top), (right, top), (left, bottom), (right, bottom),
    )]


def standard_corners(frame: BuildFrame):
    frame_bounds = bounds(frame.vertices)
    if frame_bounds is not None:
        left, top, right, bottom = frame_bounds
    else:
        left = frame.x - frame.width / 2
        top = frame.y - frame.height / 2
        right = left + frame.width
        bottom = top + frame.height
    return [(left, top), (right, top), (left, bottom), (right, bottom)]


UPPER_JOINTS = {
    0: ((0.0, 0.0), (-1.19, 31.89)),
    1: ((0.0, 0.0), (0.70, 36.30)),
    2: ((0.0, 0.0), (-0.06, 32.84)),
    3: ((0.0, 0.0), (0.0, 33.0)),
    4: ((0.0, 0.0), (0.0, 33.0)),
}
LOWER_JOINTS = {
    0: ((0.0, 0.0), (-0.82, 29.31)),
    1: ((0.0, 0.0), (1.59, 41.97)),
    2: ((0.0, 0.0), (0.0, 33.0)),
    5: ((0.0, 0.0), (0.0, 33.0)),
    6: ((0.0, 0.0), (0.0, 33.0)),
}


def joint_corners(image: Image.Image, segment, overlap=4.0, width_scale=1.45):
    """Fit upright authored limb art to a native joint segment uniformly."""
    (sx, sy), (ex, ey) = segment
    dx, dy = ex - sx, ey - sy
    length = math.hypot(dx, dy)
    ux, uy = dx / length, dy / length
    nx, ny = -uy, ux
    sx, sy = sx - ux * overlap, sy - uy * overlap
    ex, ey = ex + ux * overlap, ey + uy * overlap
    art_length = length + overlap * 2
    half_width = art_length * image.width / image.height * width_scale / 2
    return [
        (sx - nx * half_width, sy - ny * half_width),
        (sx + nx * half_width, sy + ny * half_width),
        (ex - nx * half_width, ey - ny * half_width),
        (ex + nx * half_width, ey + ny * half_width),
    ]


def compact_hand_corners(image: Image.Image, frame: BuildFrame):
    # Donor opaque hands are about 31x33 local units; their mesh bboxes include
    # large transparent padding.  Keep the approved pose's aspect around the
    # donor registration center instead of stretching it to that padding.
    height = 60.0
    width = height * image.width / image.height
    center_x, center_y = frame.x, frame.y - 8.0
    return [
        (center_x - width / 2, center_y - height / 2),
        (center_x + width / 2, center_y - height / 2),
        (center_x - width / 2, center_y + height / 2),
        (center_x + width / 2, center_y + height / 2),
    ]


def skirt_corners(image: Image.Image, frame: BuildFrame):
    left, top, right, bottom = bounds(frame.vertices)
    height = (bottom - top) + 82.0
    width = height * image.width / image.height
    center_x = (left + right) / 2
    return [
        (center_x - width / 2, top), (center_x + width / 2, top),
        (center_x - width / 2, top + height), (center_x + width / 2, top + height),
    ]


HAND_MAP = {
    0: "grip_side", 1: "grip_palm", 2: "grip_side", 3: "grip_palm",
    4: "fist_back", 5: "fist_palm", 6: "relaxed_side", 7: "relaxed_palm",
    8: "relaxed_palm", 9: "relaxed_back", 10: "relaxed_side",
    13: "relaxed_palm", 14: "fist_back", 16: "relaxed_side",
    17: "relaxed_palm",
}


def replacement(symbol, index, parts, heads):
    if symbol == "headbase" and index < 3:
        view = ("front", "profile", "rear")[index]
        return f"head_{view}", heads[(view, False)]["image"], f"approved_{view}#head_full"
    if symbol == "headbase_hat" and index < 3:
        view = ("front", "profile", "rear")[index]
        source_id = "approved_rear_hat" if view == "rear" else f"approved_{view}"
        return f"head_hat_{view}", heads[(view, True)]["image"], f"{source_id}#head_hat"
    if symbol == "torso" and index <= 8:
        view = "front" if index <= 2 else "profile" if index <= 5 else "rear"
        return f"torso_{view}", parts[view]["bodice"], f"approved_{view}#bodice"
    if symbol == "skirt" and index < 4:
        if index == 0:
            view, name = "front", "skirt"
        elif index == 1:
            view, name = "rear", "skirt"
        elif index == 2:
            view, name = "front", "skirt"
        else:
            view, name = "front", "skirt"
        return f"skirt_{view}_{name}", parts[view][name], f"approved_{view}#{name}"
    if symbol == "arm_upper" and index < 5:
        view = "profile" if index == 2 else "front"
        return f"upper_{view}", parts[view]["upper_arm"], f"approved_{view}#upper_arm"
    if symbol == "arm_lower" and index in (0, 1, 2, 5, 6):
        view = "profile" if index in (2, 6) else "front"
        return f"lower_{view}", parts[view]["forearm"], f"approved_{view}#forearm"
    if symbol == "hand" and index in HAND_MAP:
        name = HAND_MAP[index]
        return f"hand_{name}", parts["hands"][name], f"approved_hands#{name}"
    return None


# These obsolete old-head overlays would duplicate the approved full head.
# Other EVA-only symbols stay preserved until a real motion preview proves a
# specific layer should be replaced or intentionally hidden.
HIDDEN_SYMBOLS = {"hair", "hair_hat", "hairfront"}
COMBINED_SYMBOL_FRAMES = {("arm_upper_skin", 0), ("arm_upper_skin", 1)}
PRESERVED_SPECIALS = {
    ("headbase", 3), ("headbase_hat", 3), ("torso", 9), ("torso", 10),
    ("skirt", 4), ("arm_upper_skin", 2), ("arm_lower", 3), ("arm_lower", 4),
    ("hand", 11), ("hand", 12), ("hand", 15), ("hand", 18), ("hand", 19),
}


@dataclass
class TextureItem:
    key: str
    image: Image.Image
    source_crop: tuple[int, int, int, int] | None = None


@dataclass
class Placement:
    atlas: int
    x: int
    y: int
    width: int
    height: int


def preserved_texture(frame: BuildFrame, atlases):
    if not frame.vertices:
        return None
    atlas_indices = {int(vertex[5]) for vertex in frame.vertices}
    if len(atlas_indices) != 1:
        raise ValueError("one frame unexpectedly spans atlases")
    atlas_index = atlas_indices.pop()
    u = [vertex[3] for vertex in frame.vertices]
    v = [vertex[4] for vertex in frame.vertices]
    crop = (math.floor(min(u) * SIZE), math.floor(min(v) * SIZE),
            math.ceil(max(u) * SIZE), math.ceil(max(v) * SIZE))
    return atlas_index, crop, atlases[atlas_index].crop(crop)


def add_gutters(atlas: Image.Image, image: Image.Image, x: int, y: int):
    # Inputs are already premultiplied.  Cells never overlap, so a direct paste
    # preserves their bytes instead of asking Pillow to composite them again.
    atlas.paste(image, (x, y))
    gutter = 4
    atlas.paste(image.crop((0, 0, 1, image.height)).resize((gutter, image.height)),
                (x - gutter, y))
    atlas.paste(image.crop((image.width - 1, 0, image.width, image.height)).resize(
        (gutter, image.height)), (x + image.width, y))
    atlas.paste(image.crop((0, 0, image.width, 1)).resize((image.width, gutter)),
                (x, y - gutter))
    atlas.paste(image.crop((0, image.height - 1, image.width, image.height)).resize(
        (image.width, gutter)), (x, y + image.height))


def pack_textures(items: dict[str, TextureItem]):
    atlases = [Image.new("RGBA", (SIZE, SIZE)), Image.new("RGBA", (SIZE, SIZE))]
    placements = {}
    ordered = sorted(items.values(), key=lambda item: (-item.image.height, -item.image.width, item.key))
    atlas_index = x = y = row_height = 0
    for item in ordered:
        slot_w = item.image.width + 8
        slot_h = item.image.height + 8
        if slot_w > SIZE or slot_h > SIZE:
            raise ValueError(f"texture too large: {item.key} {item.image.size}")
        if x and x + slot_w > SIZE:
            x = 0
            y += row_height
            row_height = 0
        if y + slot_h > SIZE:
            atlas_index += 1
            if atlas_index >= 2:
                raise ValueError("approved EVA textures exceed two atlases")
            x = y = row_height = 0
        content_x, content_y = x + 4, y + 4
        add_gutters(atlases[atlas_index], item.image, content_x, content_y)
        placements[item.key] = Placement(
            atlas_index, content_x, content_y, item.image.width, item.image.height
        )
        x += slot_w
        row_height = max(row_height, slot_h)
    return atlases, placements


def uv_for(placement: Placement):
    return (placement.x / SIZE, placement.y / SIZE,
            (placement.x + placement.width) / SIZE,
            (placement.y + placement.height) / SIZE)


def quad_vertices(corners, placement: Placement):
    (left_top, right_top, left_bottom, right_bottom) = corners
    u0, v0, u1, v1 = uv_for(placement)
    atlas = float(placement.atlas)
    return [
        (*left_top, 0.0, u0, v1, atlas),
        (*right_top, 0.0, u1, v1, atlas),
        (*left_bottom, 0.0, u0, v0, atlas),
        (*right_top, 0.0, u1, v1, atlas),
        (*right_bottom, 0.0, u1, v0, atlas),
        (*left_bottom, 0.0, u0, v0, atlas),
    ]


def frame_from_vertices(frame: BuildFrame, vertices):
    frame_bounds = bounds(vertices)
    if frame_bounds is None:
        return BuildFrame(frame.index, frame.duration, frame.x, frame.y,
                          frame.width, frame.height, [])
    left, top, right, bottom = frame_bounds
    return BuildFrame(frame.index, frame.duration, (left + right) / 2,
                      (top + bottom) / 2, right - left, bottom - top, vertices)


def source_records():
    result = {}
    for source_id, filename in (
        ("approved_front", "front-parts.png"),
        ("approved_profile", "side-parts.png"),
        ("approved_rear", "rear-parts.png"),
        ("approved_rear_hat", "rear-head-hat.png"),
        ("approved_hands", "hand-poses-clean.png"),
        ("approved_tresses", "hair-tresses.png"),
        ("approved_design", "approved-design.png"),
        ("donor_luoshen", "donor-luoshen.zip"),
        ("baseline", "baseline-eva.zip"),
    ):
        path = SOURCE / filename
        result[source_id] = {"path": filename, "sha256": sha256(path.read_bytes()).hexdigest()}
    return result


def calibrated_world_rect(element, rect, scale):
    left, top, right, bottom = rect
    world = tuple((value - (256 if index % 2 == 0 else 600)) * scale
                  for index, value in enumerate((left, top, right, bottom)))
    return [inverse_point(element, x, y) for x, y in (
        (world[0], world[1]), (world[2], world[1]),
        (world[0], world[3]), (world[2], world[3]),
    )]


def build_candidate(output: Path, registration_overrides=None,
                    registration_geometry=None, registration_aliases=None,
                    manifest_path=None,
                    manifest_extra=None):
    registration_overrides = registration_overrides or {}
    registration_geometry = registration_geometry or {}
    registration_aliases = registration_aliases or {}
    parts = load_sources()
    heads = head_composites(parts)
    with ZipFile(BASELINE) as archive:
        baseline_build_bytes = archive.read("build.bin")
        baseline = parse_build(baseline_build_bytes)
        anim = archive.read("anim.bin")
        baseline_ktex = [archive.read(name) for name in baseline.atlases]
    if sha256(anim).hexdigest() != ANIM_SHA256:
        raise ValueError("baseline EVA anim.bin changed")
    if baseline.name != "eva" or baseline.atlases != ["atlas-0.tex", "atlas-1.tex"]:
        raise ValueError("unexpected baseline EVA identity")
    with ZipFile(DONOR) as donor_archive:
        donor = parse_build(donor_archive.read("build.bin"))
        donor_ktex = [donor_archive.read(name) for name in donor.atlases]
    donor_atlases = [read_ktex(data)[1] for data in donor_ktex]
    specifications = []
    old_atlases = []
    for data in baseline_ktex:
        specification, image = read_ktex(data)
        if image.size != (SIZE, SIZE) or ((specification >> 4) & 31) != 2:
            raise ValueError("baseline atlas must be 2048 DXT5")
        specifications.append(specification)
        old_atlases.append(image)

    idles = {view: load_idle(facing)[8]
             for view, facing in (("front", 8), ("profile", 5), ("rear", 2))}
    head_corners = {}
    head_scales = {}
    head_canvas_origins = {}
    for view, head_index in (("front", 0), ("profile", 1)):
        head_element = element_for(idles[view], "headbase", head_index)
        face_element = next(element for element in idles[view]
                            if element[0] == sdbm("face"))
        face_frame = donor_frame(donor, "face", face_element[1])
        if face_frame is None:
            raise ValueError(f"donor face frame missing for {view}")
        for hat in (False, True):
            corners, scale, canvas_origin = calibrated_head_corners(
                heads[(view, hat)], head_element, face_element, face_frame
            )
            head_corners[(view, hat)] = corners
            head_scales[view] = scale
            if not hat:
                head_canvas_origins[view] = canvas_origin
    rear_element = element_for(idles["rear"], "headbase", 2)
    for hat in (False, True):
        head_corners[("rear", hat)] = canvas_aligned_corners(
            heads[("rear", hat)], rear_element, head_scales["front"],
            head_canvas_origins["front"],
        )

    # Native tail elements sit behind the torso. Use them for the long approved
    # back-hair curtain instead of baking hair into the front-most head layer.
    hair_sources = {
        0: parts["tresses"]["left"],
        1: parts["tresses"]["right"],
        2: parts["profile"]["back_hair"],
    }
    hair_corners = {}
    front_hair_rects = ((62, 230, 248, 500), (244, 230, 429, 500))
    for index in (0, 1):
        element = element_for(idles["front"], "hairpigtails", index)
        scale = head_scales["front"]
        ox, oy = head_canvas_origins["front"]
        left, top, right, bottom = front_hair_rects[index]
        hair_corners[index] = [inverse_point(element, x, y) for x, y in (
            (ox + left * scale, oy + top * scale),
            (ox + right * scale, oy + top * scale),
            (ox + left * scale, oy + bottom * scale),
            (ox + right * scale, oy + bottom * scale),
        )]
    profile_hair_element = element_for(idles["profile"], "hairpigtails", 2)
    scale = head_scales["profile"]
    ox, oy = head_canvas_origins["profile"]
    left, top, right, bottom = (100, 210, 344, 500)
    hair_corners[2] = [inverse_point(profile_hair_element, x, y) for x, y in (
        (ox + left * scale, oy + top * scale),
        (ox + right * scale, oy + top * scale),
        (ox + left * scale, oy + bottom * scale),
        (ox + right * scale, oy + bottom * scale),
    )]

    textures: dict[str, TextureItem] = {}
    plans = {}
    provenance = {symbol: [] for symbol in baseline.order}
    art_sizes = {}
    for symbol in baseline.order:
        for frame in baseline.symbols[symbol]:
            key = (symbol, frame.index)
            registered = registration_overrides.get(key)
            if registered is not None:
                registered_plans = []
                for piece_index, piece in enumerate(registered["pieces"]):
                    texture_key = f"registered_{symbol}_{frame.index}_{piece_index}"
                    image = piece["image"]
                    textures[texture_key] = TextureItem(
                        texture_key,
                        premultiply(image).transpose(Image.Transpose.FLIP_TOP_BOTTOM),
                    )
                    registered_plans.append((texture_key, piece["corners"]))
                    art_sizes[f"{symbol}:{frame.index}:{piece_index}"] = image.size
                plans[key] = ("registered", registered_plans, None)
                provenance[symbol].append({
                    "frame": frame.index, "mode": "approved",
                    "source": registered["source"],
                })
                continue
            if symbol in ("face", "cheeks"):
                donor_index = 0 if symbol == "face" and frame.index == 33 else frame.index
                authentic = donor_frame(donor, symbol, donor_index)
                if authentic is None:
                    raise ValueError(f"donor expression missing: {symbol}:{donor_index}")
                donor_texture = preserved_texture(authentic, donor_atlases)
                if donor_texture is None:
                    raise ValueError(f"donor expression is empty: {symbol}:{donor_index}")
                atlas_index, crop, image = donor_texture
                texture_key = f"donor_{symbol}_{donor_index}_{'_'.join(map(str, crop))}"
                textures.setdefault(texture_key, TextureItem(texture_key, image, crop))
                plans[key] = (
                    "donor", texture_key,
                    (crop, authentic.vertices, registration_geometry.get(key)),
                )
                provenance[symbol].append({
                    "frame": frame.index, "mode": "donor_expression",
                    "source": f"donor_luoshen#{symbol}:{donor_index}",
                })
                continue
            source = replacement(symbol, frame.index, parts, heads)
            if symbol == "hairpigtails" and frame.index < 3:
                texture_key = f"hair_{frame.index}"
                image = hair_sources[frame.index]
                textures.setdefault(texture_key, TextureItem(
                    texture_key,
                    premultiply(image).transpose(Image.Transpose.FLIP_TOP_BOTTOM),
                ))
                plans[key] = ("new", texture_key, hair_corners[frame.index])
                provenance[symbol].append({
                    "frame": frame.index, "mode": "approved",
                    "source": ("approved_profile#back_hair" if frame.index == 2
                               else f"approved_tresses#{('left', 'right')[frame.index]}"),
                })
                art_sizes[f"{symbol}:{frame.index}"] = image.size
                continue
            if key in COMBINED_SYMBOL_FRAMES:
                plans[key] = ("hidden", None, None)
                provenance[symbol].append({
                    "frame": frame.index, "mode": "approved_combined",
                    "source": "approved_front#upper_arm_consumes_skin_layer",
                })
                continue
            if source is not None:
                texture_key, image, source_label = source
                textures.setdefault(texture_key, TextureItem(
                    texture_key,
                    premultiply(image).transpose(Image.Transpose.FLIP_TOP_BOTTOM),
                ))
                if symbol == "headbase":
                    view = ("front", "profile", "rear")[frame.index]
                    corners = head_corners[(view, False)]
                elif symbol == "headbase_hat":
                    view = ("front", "profile", "rear")[frame.index]
                    corners = head_corners[(view, True)]
                else:
                    foundation = donor_frame(donor, symbol, frame.index) or frame
                    if symbol in ("arm_upper", "arm_upper_skin"):
                        joint_index = frame.index if symbol == "arm_upper" else 0
                        corners = joint_corners(image, UPPER_JOINTS[joint_index])
                    elif symbol == "arm_lower":
                        corners = joint_corners(image, LOWER_JOINTS[frame.index])
                    elif symbol == "hand":
                        corners = compact_hand_corners(image, foundation)
                    elif symbol == "skirt":
                        corners = skirt_corners(image, foundation)
                    else:
                        corners = standard_corners(foundation)
                plans[key] = ("new", texture_key, corners)
                provenance[symbol].append({
                    "frame": frame.index, "mode": "approved", "source": source_label,
                })
                art_sizes[f"{symbol}:{frame.index}"] = image.size
                continue
            if symbol in HIDDEN_SYMBOLS:
                plans[key] = ("hidden", None, None)
                provenance[symbol].append({
                    "frame": frame.index, "mode": "hidden",
                    "source": f"baseline#{symbol}:{frame.index}",
                })
                continue
            preserved = preserved_texture(frame, old_atlases)
            if preserved is None:
                plans[key] = ("hidden", None, None)
                provenance[symbol].append({
                    "frame": frame.index, "mode": "hidden",
                    "source": f"baseline#{symbol}:{frame.index}",
                })
                continue
            atlas_index, crop, image = preserved
            texture_key = f"old_{atlas_index}_{'_'.join(map(str, crop))}"
            textures.setdefault(texture_key, TextureItem(texture_key, image, crop))
            plans[key] = ("preserved", texture_key, (atlas_index, crop))
            if key in PRESERVED_SPECIALS:
                mode = "preserved_special"
                source_label = f"baseline#{symbol}:{frame.index}"
            else:
                mode = "preserved_existing"
                source_label = f"baseline#{symbol}:{frame.index}"
            provenance[symbol].append({
                "frame": frame.index, "mode": mode, "source": source_label,
            })

    alias_plans = {}
    for alias, alias_record in registration_aliases.items():
        source_symbol = alias_record["source_symbol"]
        if source_symbol not in baseline.symbols:
            raise ValueError(f"alias source symbol missing: {source_symbol}")
        for frame in baseline.symbols[source_symbol]:
            registered = alias_record.get("frame_overrides", {}).get(frame.index)
            if registered is None:
                alias_plans[(alias, frame.index)] = ("clone", None)
                continue
            registered_plans = []
            for piece_index, piece in enumerate(registered["pieces"]):
                texture_key = f"alias_{alias}_{frame.index}_{piece_index}"
                image = piece["image"]
                textures[texture_key] = TextureItem(
                    texture_key,
                    premultiply(image).transpose(Image.Transpose.FLIP_TOP_BOTTOM),
                )
                registered_plans.append((texture_key, piece["corners"]))
                art_sizes[f"{alias}:{frame.index}:{piece_index}"] = image.size
            alias_plans[(alias, frame.index)] = ("registered", registered_plans)

    packed_atlases, placements = pack_textures(textures)
    for symbol in baseline.order:
        updated = []
        for frame in baseline.symbols[symbol]:
            kind, texture_key, detail = plans[(symbol, frame.index)]
            if kind == "hidden":
                updated.append(frame_from_vertices(frame, []))
            elif kind == "new":
                vertices = quad_vertices(detail, placements[texture_key])
                updated.append(frame_from_vertices(frame, vertices))
            elif kind == "registered":
                vertices = []
                for registered_key, corners in texture_key:
                    vertices.extend(quad_vertices(corners, placements[registered_key]))
                updated.append(frame_from_vertices(frame, vertices))
            elif kind == "donor":
                crop, geometry, geometry_transform = detail
                placement = placements[texture_key]
                left, top, _, _ = crop
                vertices = []
                for geometry_vertex in geometry:
                    x, y, z, u, v, _ = geometry_vertex
                    if geometry_transform is not None:
                        transformed_x = (geometry_transform[0][0] * x
                                         + geometry_transform[0][1] * y
                                         + geometry_transform[0][2])
                        transformed_y = (geometry_transform[1][0] * x
                                         + geometry_transform[1][1] * y
                                         + geometry_transform[1][2])
                        x, y = transformed_x, transformed_y
                    vertices.append((
                        x, y, z,
                        (u * SIZE - left + placement.x) / SIZE,
                        (v * SIZE - top + placement.y) / SIZE,
                        float(placement.atlas),
                    ))
                updated.append(frame_from_vertices(frame, vertices))
            else:
                _, crop = detail
                placement = placements[texture_key]
                left, top, _, _ = crop
                vertices = []
                for baseline_vertex in frame.vertices:
                    x, y, z = baseline_vertex[:3]
                    u, v = baseline_vertex[3:5]
                    vertices.append((
                        x, y, z,
                        (u * SIZE - left + placement.x) / SIZE,
                        (v * SIZE - top + placement.y) / SIZE,
                        float(placement.atlas),
                    ))
                updated.append(frame_from_vertices(frame, vertices))
        baseline.symbols[symbol] = updated

    for alias, alias_record in registration_aliases.items():
        if alias in baseline.symbols:
            raise ValueError(f"alias symbol already exists: {alias}")
        alias_hash = sdbm(alias)
        if alias_hash in baseline.names:
            raise ValueError(f"alias symbol hash collision: {alias}")
        source_symbol = alias_record["source_symbol"]
        updated = []
        alias_provenance = []
        for frame in baseline.symbols[source_symbol]:
            kind, detail = alias_plans[(alias, frame.index)]
            if kind == "clone":
                updated.append(BuildFrame(
                    frame.index, frame.duration, frame.x, frame.y,
                    frame.width, frame.height, list(frame.vertices),
                ))
                source = f"candidate#{source_symbol}:{frame.index}"
            else:
                vertices = []
                for texture_key, corners in detail:
                    vertices.extend(quad_vertices(corners, placements[texture_key]))
                updated.append(frame_from_vertices(frame, vertices))
                source = alias_record["frame_overrides"][frame.index]["source"]
            alias_provenance.append({
                "frame": frame.index, "mode": "facing_alias", "source": source,
            })
        baseline.order.append(alias)
        baseline.hashes[alias] = alias_hash
        baseline.names[alias_hash] = alias
        baseline.symbols[alias] = updated
        provenance[alias] = alias_provenance

    built = write_build(baseline)
    # Parsing the freshly emitted bytes catches layout/offset corruption before
    # any archive can be presented for visual review.
    roundtrip = parse_build(built)
    if {name: len(frames) for name, frames in roundtrip.symbols.items()} != {
        name: len(frames) for name, frames in baseline.symbols.items()
    }:
        raise RuntimeError("rebuilt BILD coverage changed")
    textures_out = [make_ktex(image, specifications[index])
                    for index, image in enumerate(packed_atlases)]
    output.parent.mkdir(parents=True, exist_ok=True)
    with ZipFile(output, "w") as archive:
        archive.writestr(zip_info("anim.bin"), anim)
        archive.writestr(zip_info("atlas-0.tex"), textures_out[0])
        archive.writestr(zip_info("atlas-1.tex"), textures_out[1])
        archive.writestr(zip_info("build.bin"), built)
    manifest = {
        "version": 1,
        "build": "eva",
        "atlas_limit": 2,
        "animation_sha256": sha256(anim).hexdigest(),
        "build_sha256": sha256(built).hexdigest(),
        "archive_sha256": sha256(output.read_bytes()).hexdigest(),
        "sources": source_records(),
        "symbols": provenance,
        "calibration": {
            "face_geometry_basis": "donor_luoshen",
            "limb_geometry_basis": "native_joint_similarity",
            "upper_joint_segments": UPPER_JOINTS,
            "lower_joint_segments": LOWER_JOINTS,
            "head_front_face_scale": head_scales["front"],
            "head_profile_face_scale": head_scales["profile"],
            "note": "Workspace-promoted playable iteration; in-game visual acceptance is required before Steam deployment.",
        },
        "approved_source_pixel_sizes": art_sizes,
    }
    if manifest_extra:
        manifest.update(manifest_extra)
    manifest_path = Path(manifest_path) if manifest_path else SOURCE / "rig-map.json"
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    manifest_path.write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf8"
    )
    return manifest


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    args = parser.parse_args()
    manifest = build_candidate(args.output.resolve())
    print(f"Built {args.output}: {manifest['archive_sha256']}")
    print(f"Head face scales front={manifest['calibration']['head_front_face_scale']:.6f} "
          f"profile={manifest['calibration']['head_profile_face_scale']:.6f}")


if __name__ == "__main__":
    main()
