"""Translate EVA fox depart/arrive animations to spawn around their origin."""

from argparse import ArgumentParser
from copy import copy
from hashlib import sha256
from pathlib import Path
from zipfile import ZipFile
import struct


SOURCE_SHA256 = "062a0c4d8a5bedc60ab7dde55e37532c5a70aad3f2a0ca61220096febb3369ab"
ELEMENT = struct.Struct("<IIIfffffff")


class Reader:
    def __init__(self, data):
        self.data, self.pos = data, 0

    def take(self, size):
        value = self.data[self.pos:self.pos + size]
        if len(value) != size:
            raise ValueError("truncated Klei binary")
        self.pos += size
        return value

    def uint(self):
        return struct.unpack("<I", self.take(4))[0]

    def string_bytes(self):
        return self.take(self.uint())


def parse_build(data):
    reader = Reader(data)
    if reader.take(4) != b"BILD" or reader.uint() != 6:
        raise ValueError("expected BILD v6")
    symbol_count, _ = reader.uint(), reader.uint()
    reader.string_bytes()
    for _ in range(reader.uint()):
        reader.string_bytes()
    symbols = {}
    for _ in range(symbol_count):
        symbol_hash, frame_count = reader.uint(), reader.uint()
        for _ in range(frame_count):
            frame, _, _, _, _, _, alpha_index, alpha_count = struct.unpack(
                "<IIffffII", reader.take(32))
            symbols[(symbol_hash, frame)] = (alpha_index, alpha_count)
    vertices = [struct.unpack("<ffffff", reader.take(24))
                for _ in range(reader.uint())]
    return symbols, vertices


def parse_animations(data):
    reader = Reader(data)
    if reader.take(4) != b"ANIM" or reader.uint() != 4:
        raise ValueError("expected ANIM v4")
    reader.take(12)
    animations = []
    for _ in range(reader.uint()):
        name = reader.string_bytes()
        reader.take(1 + 4 + 4)
        frames = []
        for _ in range(reader.uint()):
            bounds_offset = reader.pos
            bounds = struct.unpack("<ffff", reader.take(16))
            reader.take(reader.uint() * 4)
            elements = []
            for _ in range(reader.uint()):
                element_offset = reader.pos
                values = ELEMENT.unpack(reader.take(ELEMENT.size))
                elements.append((element_offset, values))
            frames.append((bounds_offset, bounds, elements))
        animations.append((name, frames))
    return animations


def rendered_bounds(frame, symbols, vertices):
    points = []
    for _, element in frame[2]:
        symbol_hash, symbol_frame, _, a, b, c, d, tx, ty, _ = element
        alpha_index, alpha_count = symbols[(symbol_hash, symbol_frame)]
        for x, y, _, _, _, _ in vertices[alpha_index:alpha_index + alpha_count]:
            points.append((a * x + c * y + tx, b * x + d * y + ty))
    if not points:
        return None
    xs, ys = zip(*points)
    return min(xs), min(ys), max(xs), max(ys)


def transform_anim(anim_data, build_data):
    symbols, vertices = parse_build(build_data)
    animations = parse_animations(anim_data)
    named = {name: frames for name, frames in animations if name in (b"in", b"out")}
    if set(named) != {b"in", b"out"}:
        raise ValueError("missing EVA fox in/out animations")
    references = {
        b"in": next(frame for frame in named[b"in"]
                    if rendered_bounds(frame, symbols, vertices) is not None),
        b"out": next(frame for frame in reversed(named[b"out"])
                     if rendered_bounds(frame, symbols, vertices) is not None),
    }
    translations = {}
    for name, frame in references.items():
        left, _, right, bottom = rendered_bounds(frame, symbols, vertices)
        translations[name] = (-((left + right) / 2), -bottom)

    output = bytearray(anim_data)
    for name, frames in named.items():
        delta_x, delta_y = translations[name]
        for bounds_offset, bounds, elements in frames:
            struct.pack_into("<f", output, bounds_offset, bounds[0] + delta_x)
            struct.pack_into("<f", output, bounds_offset + 4, bounds[1] + delta_y)
            for element_offset, values in elements:
                struct.pack_into("<f", output, element_offset + 28, values[7] + delta_x)
                struct.pack_into("<f", output, element_offset + 32, values[8] + delta_y)
    return bytes(output), translations


def reanchor(source_path, output_path):
    source_bytes = source_path.read_bytes()
    actual_hash = sha256(source_bytes).hexdigest()
    if actual_hash != SOURCE_SHA256:
        raise ValueError(f"source EVA fox archive hash mismatch: {actual_hash}")
    with ZipFile(source_path) as source:
        infos = source.infolist()
        entries = {info.filename: source.read(info.filename) for info in infos}
    transformed, translations = transform_anim(entries["anim.bin"], entries["build.bin"])
    entries["anim.bin"] = transformed
    with ZipFile(output_path, "w") as output:
        for source_info in infos:
            info = copy(source_info)
            output.writestr(info, entries[info.filename])
    print("Built", output_path)
    for name in (b"in", b"out"):
        print(name.decode("ascii"), translations[name])


def main():
    parser = ArgumentParser()
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    if args.source.resolve() == args.output.resolve():
        parser.error("--source and --output must differ")
    reanchor(args.source, args.output)


if __name__ == "__main__":
    main()
