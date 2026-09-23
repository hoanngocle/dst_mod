from pathlib import Path
from zipfile import ZipFile
import hashlib
import math
import os
import struct
import unittest


ROOT = Path(__file__).resolve().parents[1]
ARCHIVE = Path(os.environ.get("EVA_FOX_ARCHIVE", ROOT / "anim/eva_fox.zip"))
BUILD_SHA256 = "2d498004bf75ffc3e5b1f589ce8170282a01fa135a5290241fb3a221e1c66470"
ATLAS_SHA256 = "4b470d0976d13fc1868fb2b4cdc6d9f3c7998638b83e1f0e16a521337ebe8484"
ANIM_SHA256 = "ca721693e0431389f3c852b068cdab8485188812170aabd075eff704e5248548"


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
    vertex_count = reader.uint()
    vertices = [struct.unpack("<ffffff", reader.take(24))
                for _ in range(vertex_count)]
    return symbols, vertices


def parse_animations(data):
    reader = Reader(data)
    if reader.take(4) != b"ANIM" or reader.uint() != 4:
        raise ValueError("expected ANIM v4")
    totals = (reader.uint(), reader.uint(), reader.uint())
    animations = []
    for _ in range(reader.uint()):
        name = reader.string_bytes()
        facing = reader.take(1)
        bank_hash = reader.uint()
        fps = struct.unpack("<f", reader.take(4))[0]
        frames = []
        for _ in range(reader.uint()):
            bounds = struct.unpack("<ffff", reader.take(16))
            events = [reader.uint() for _ in range(reader.uint())]
            elements = [struct.unpack("<IIIfffffff", reader.take(40))
                        for _ in range(reader.uint())]
            frames.append((bounds, events, elements))
        animations.append((name, facing, bank_hash, fps, frames))
    return totals, animations


def rendered_bounds(frame, symbols, vertices):
    points = []
    for element in frame[2]:
        symbol_hash, symbol_frame, _, a, b, c, d, tx, ty, _ = element
        alpha_index, alpha_count = symbols[(symbol_hash, symbol_frame)]
        for x, y, _, _, _, _ in vertices[alpha_index:alpha_index + alpha_count]:
            points.append((a * x + c * y + tx, b * x + d * y + ty))
    if not points:
        return None
    xs, ys = zip(*points)
    return min(xs), min(ys), max(xs), max(ys)


class EvaFoxAnchorTest(unittest.TestCase):
    def test_archive_art_and_animation_contract(self):
        with ZipFile(ARCHIVE) as archive:
            self.assertEqual(archive.namelist(), ["anim.bin", "atlas-0.tex", "build.bin"])
            build = archive.read("build.bin")
            atlas = archive.read("atlas-0.tex")
            self.assertEqual(hashlib.sha256(build).hexdigest(), BUILD_SHA256)
            self.assertEqual(hashlib.sha256(atlas).hexdigest(), ATLAS_SHA256)
            anim = archive.read("anim.bin")
            self.assertEqual(hashlib.sha256(anim).hexdigest(), ANIM_SHA256)
            symbols, vertices = parse_build(build)
            totals, animations = parse_animations(anim)
        named = {animation[0]: animation for animation in animations
                 if animation[0] in (b"in", b"out")}
        self.assertEqual(set(named), {b"in", b"out"})
        self.assertEqual({name: len(value[4]) for name, value in named.items()},
                         {b"in": 12, b"out": 12})
        self.assertTrue(all(math.isclose(value[3], 40, abs_tol=1e-6)
                            for value in named.values()))
        self.assertEqual(len(animations), 4)
        self.assertEqual(totals[1], 26)

        depart = rendered_bounds(named[b"in"][4][0], symbols, vertices)
        arrive = rendered_bounds(named[b"out"][4][-1], symbols, vertices)
        self.assertIsNotNone(depart)
        self.assertIsNotNone(arrive)
        self.assertAlmostEqual((depart[0] + depart[2]) / 2, 0, places=3)
        self.assertAlmostEqual(depart[3], 0, places=3)
        self.assertAlmostEqual((arrive[0] + arrive[2]) / 2, 0, places=3)
        self.assertAlmostEqual(arrive[3], 0, places=3)


if __name__ == "__main__":
    unittest.main()
