"""Regression contract for the approved full EVA player build.

This intentionally tests semantic rig coverage rather than pinning the final
archive hash.  The build is expected to follow the native Luoshen-compatible
player symbol/frame layout while retaining EVA's existing animation bank and
single default-skin registration.
"""

from hashlib import sha256
import json
import math
import os
from pathlib import Path
import struct
import unittest
from zipfile import ZipFile


ROOT = Path(__file__).resolve().parents[1]
ARCHIVE = Path(os.environ.get("EVA_ARCHIVE", ROOT / "anim/eva.zip"))
SOURCE_ROOT = ROOT / "assets/source/eva_approved"
PROVENANCE = Path(os.environ.get("EVA_RIG_MAP", SOURCE_ROOT / "rig-map.json"))
EVA_NONE = ROOT / "scripts/prefabs/eva_none.lua"
ANIM_SHA256 = "13969e77f249aff2a55035cd36e9134a31380b367dc4d4b4c2c2f57c41e8de9d"
LUOSHEN_ANIM_SHA256 = "d0fc41f95ae026d5e6b995ec9a8bfb5c69f7095671c393001545afa76d95c535"
EXPECTED_FRAMES = {
    "SWAP_ICON": 1,
    "arm_lower": 7,
    "arm_upper": 7,
    "arm_upper_skin": 3,
    "cheeks": 2,
    "face": 34,
    "face_sail": 1,
    "foot": 8,
    "hair": 4,
    "hair_hat": 4,
    "hairfront": 2,
    "hairpigtails": 5,
    "hand": 20,
    "headbase": 4,
    "headbase_hat": 4,
    "leg": 11,
    "skirt": 5,
    "tail": 12,
    "torso": 11,
    "torso_pelvis": 11,
}
FACING_ALIAS_TARGETS = {
    f"{target}__eva_{view}": target
    for target in ("skirt", "arm_lower", "hairpigtails", "arm_upper", "hand")
    for view in ("front", "profile", "rear")
}
ALLOWED_PROVENANCE_MODES = {
    "approved",
    "approved_mirror",
    "approved_combined",
    "donor_expression",
    "facing_alias",
    "hidden",
    "preserved_existing",
    "preserved_special",
}


class Reader:
    def __init__(self, data):
        self.data = data
        self.pos = 0

    def take(self, size):
        value = self.data[self.pos:self.pos + size]
        if len(value) != size:
            raise ValueError("truncated BILD")
        self.pos += size
        return value

    def unpack(self, fmt):
        fmt = "<" + fmt
        values = struct.unpack(fmt, self.take(struct.calcsize(fmt)))
        return values

    def uint(self):
        return self.unpack("I")[0]

    def string(self):
        return self.take(self.uint()).decode("ascii")


def parse_build(data):
    reader = Reader(data)
    magic, version, symbol_count, frame_count = reader.unpack("4sIII")
    if (magic, version) != (b"BILD", 6):
        raise ValueError("expected BILD v6")
    build_name = reader.string()
    atlases = [reader.string() for _ in range(reader.uint())]
    raw_symbols = []
    for _ in range(symbol_count):
        symbol_hash, count = reader.unpack("II")
        frames = [reader.unpack("IIffffII") for _ in range(count)]
        raw_symbols.append((symbol_hash, frames))
    vertex_count = reader.uint()
    vertices = [reader.unpack("ffffff") for _ in range(vertex_count)]
    names = {}
    for _ in range(reader.uint()):
        key = reader.uint()
        names[key] = reader.string()
    if reader.pos != len(data):
        raise ValueError("trailing BILD bytes")
    symbols = {names[key]: frames for key, frames in raw_symbols}
    if sum(len(frames) for frames in symbols.values()) != frame_count:
        raise ValueError("BILD frame count mismatch")
    return {
        "name": build_name,
        "atlases": atlases,
        "symbols": symbols,
        "vertices": vertices,
    }


def frame_vertices(build, symbol, index):
    frame = build["symbols"][symbol][index]
    start, count = frame[6:8]
    return build["vertices"][start:start + count]


class EvaApprovedRigTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        with ZipFile(ARCHIVE) as archive:
            cls.members = archive.namelist()
            cls.build_data = archive.read("build.bin")
            cls.build = parse_build(cls.build_data)
            cls.anim = archive.read("anim.bin")
        with ZipFile(SOURCE_ROOT / "baseline-eva.zip") as archive:
            cls.baseline = parse_build(archive.read("build.bin"))
        with ZipFile(SOURCE_ROOT / "donor-luoshen.zip") as archive:
            cls.donor_build_data = archive.read("build.bin")
            cls.donor = parse_build(cls.donor_build_data)

    def expected_frames(self):
        if set(self.build["symbols"]) == set(self.donor["symbols"]):
            return {
                symbol: len(frames)
                for symbol, frames in self.donor["symbols"].items()
            }
        aliases = set(self.build["symbols"]) & set(FACING_ALIAS_TARGETS)
        if not aliases:
            return EXPECTED_FRAMES
        return EXPECTED_FRAMES | {
            alias: EXPECTED_FRAMES[target]
            for alias, target in FACING_ALIAS_TARGETS.items()
        }

    def manifest(self):
        self.assertTrue(PROVENANCE.is_file(), f"missing {PROVENANCE}")
        return json.loads(PROVENANCE.read_text(encoding="utf8"))

    def test_native_symbols_and_complete_facing_alias_contract(self):
        expected = self.expected_frames()
        actual = {
            symbol: len(frames)
            for symbol, frames in self.build["symbols"].items()
        }
        self.assertEqual(actual, expected)
        if set(self.build["symbols"]) == set(self.donor["symbols"]):
            for symbol, frames in self.build["symbols"].items():
                self.assertEqual(frames, self.donor["symbols"][symbol], symbol)
            return
        for symbol, count in EXPECTED_FRAMES.items():
            frames = self.build["symbols"][symbol]
            self.assertEqual(
                [(frame[0], frame[1]) for frame in frames],
                [(frame[0], frame[1]) for frame in self.baseline["symbols"][symbol]],
                symbol,
            )
            self.assertEqual([frame[0] for frame in frames], list(range(count)), symbol)
        for alias, target in FACING_ALIAS_TARGETS.items():
            if alias not in self.build["symbols"]:
                continue
            self.assertEqual(
                [(frame[0], frame[1]) for frame in self.build["symbols"][alias]],
                [(frame[0], frame[1]) for frame in self.build["symbols"][target]],
                f"{alias} must clone every {target} frame id and duration",
            )

    def test_every_native_frame_has_explicit_source_provenance(self):
        if set(self.build["symbols"]) == set(self.donor["symbols"]):
            name_length = struct.unpack_from("<I", self.donor_build_data, 16)[0]
            expected = (
                self.donor_build_data[:16] + struct.pack("<I", 3) + b"eva"
                + self.donor_build_data[20 + name_length:]
            )
            self.assertEqual(self.build_data, expected)
            return
        manifest = self.manifest()
        self.assertEqual(manifest.get("version"), 1)
        self.assertEqual(manifest.get("build"), "eva")
        self.assertEqual(manifest.get("atlas_limit"), 2)
        self.assertEqual(manifest.get("animation_sha256"), ANIM_SHA256)
        self.assertEqual(manifest.get("build_sha256"), sha256(self.build_data).hexdigest())
        sources = manifest.get("sources", {})
        self.assertTrue(sources)
        for source_id, record in sources.items():
            path = (SOURCE_ROOT / record.get("path", "")).resolve()
            self.assertTrue(path.is_relative_to(SOURCE_ROOT.resolve()), source_id)
            self.assertTrue(path.is_file(), (source_id, path))
            self.assertEqual(sha256(path.read_bytes()).hexdigest(), record.get("sha256"))
        mapped_symbols = manifest.get("symbols", {})
        expected = self.expected_frames()
        self.assertEqual(set(mapped_symbols), set(expected))
        undeclared_sources = [
            (symbol, row.get("frame"), row.get("source"))
            for symbol, rows in mapped_symbols.items()
            for row in rows
            if isinstance(row.get("source"), str)
            and row["source"].split("#", 1)[0] not in sources
        ]
        self.assertFalse(
            undeclared_sources,
            f"frames cite undeclared provenance sources: {undeclared_sources}",
        )
        for symbol, count in expected.items():
            rows = mapped_symbols[symbol]
            self.assertEqual([row.get("frame") for row in rows], list(range(count)), symbol)
            for row in rows:
                self.assertIn(row.get("mode"), ALLOWED_PROVENANCE_MODES, (symbol, row))
                self.assertIsInstance(row.get("source"), str, (symbol, row))
                self.assertTrue(row["source"].strip(), (symbol, row))
                self.assertNotEqual(row.get("mode"), "neutral_repeat", (symbol, row))

    def test_build_identity_default_skin_and_animation_bank_stay_stable(self):
        self.assertEqual(self.build["name"], "eva")
        self.assertEqual(
            set(self.members), {"anim.bin", "build.bin", *self.build["atlases"]}
        )
        if set(self.build["symbols"]) == set(self.donor["symbols"]):
            self.assertEqual(self.build["atlases"], ["atlas-0.tex"])
            self.assertEqual(sha256(self.anim).hexdigest(), LUOSHEN_ANIM_SHA256)
        else:
            self.assertEqual(self.build["atlases"], ["atlas-0.tex", "atlas-1.tex"])
            self.assertEqual(sha256(self.anim).hexdigest(), ANIM_SHA256)
        source = EVA_NONE.read_text(encoding="utf-8-sig")
        self.assertEqual(source.count('CreatePrefabSkin("eva_none"'), 1)
        self.assertIn('build_name_override = "eva"', source)
        self.assertIn('normal_skin = "eva"', source)

    def test_native_geometry_is_finite_and_uses_at_most_two_atlases(self):
        self.assertTrue(self.build["vertices"])
        for vertex in self.build["vertices"]:
            self.assertTrue(all(math.isfinite(value) for value in vertex))
            self.assertGreaterEqual(vertex[3], 0.0)
            self.assertLessEqual(vertex[3], 1.0)
            self.assertGreaterEqual(vertex[4], 0.0)
            self.assertLessEqual(vertex[4], 1.0)
            self.assertIn(vertex[5], (0.0, 1.0))
        vertex_count = len(self.build["vertices"])
        for symbol, frames in self.build["symbols"].items():
            for frame in frames:
                _, duration, x, y, width, height, start, count = frame
                self.assertGreaterEqual(duration, 1, (symbol, frame))
                self.assertTrue(all(math.isfinite(value) for value in (x, y, width, height)))
                self.assertGreater(width, 0, (symbol, frame))
                self.assertGreater(height, 0, (symbol, frame))
                self.assertGreaterEqual(count, 0, (symbol, frame))
                self.assertLessEqual(start + count, vertex_count, (symbol, frame))

    def test_no_visible_baseline_frame_is_silently_erased(self):
        if set(self.build["symbols"]) == set(self.donor["symbols"]):
            for symbol, frames in self.donor["symbols"].items():
                for index, donor_frame in enumerate(frames):
                    self.assertEqual(
                        self.build["symbols"][symbol][index][7], donor_frame[7],
                        f"{symbol}:{index}",
                    )
            return
        manifest = self.manifest()
        rows = {
            (symbol, row["frame"]): row
            for symbol, symbol_rows in manifest["symbols"].items()
            for row in symbol_rows
        }
        for symbol, baseline_frames in self.baseline["symbols"].items():
            for index, baseline_frame in enumerate(baseline_frames):
                if baseline_frame[7] == 0:
                    continue
                if self.build["symbols"][symbol][index][7] == 0:
                    self.assertIn(
                        rows[(symbol, index)]["mode"],
                        {"approved_combined", "hidden"},
                        f"visible baseline frame erased without explicit ownership: "
                        f"{symbol}:{index}",
                    )

    def test_face_registration_preserves_durations_and_special_face_14(self):
        if set(self.build["symbols"]) == set(self.donor["symbols"]):
            self.assertEqual(
                self.build["symbols"]["face"], self.donor["symbols"]["face"]
            )
            return
        for index in range(33):
            actual_frame = self.build["symbols"]["face"][index]
            donor_frame = self.donor["symbols"]["face"][index]
            self.assertEqual(actual_frame[1], donor_frame[1], f"face:{index} duration")
        self.assertEqual(
            self.build["symbols"]["face"][33][1],
            self.donor["symbols"]["face"][0][1],
            "face:33 neutral fallback duration",
        )
        self.assertEqual(
            [vertex[:3] for vertex in frame_vertices(self.build, "face", 14)],
            [vertex[:3] for vertex in frame_vertices(self.donor, "face", 14)],
            "face:14 special geometry",
        )

        manifest = self.manifest()
        face_rows = {row["frame"]: row for row in manifest["symbols"]["face"]}
        if set(self.build["symbols"]) & set(FACING_ALIAS_TARGETS):
            expected_bindings = {
                0: ("approved", "approved_design#concept_registered_front_face"),
                4: ("approved", "approved_design#concept_registered_profile_face"),
                14: ("donor_expression", "donor_luoshen#face:14"),
                33: ("approved", "approved_design#exact_front_neutral_fallback"),
            }
            for index, (mode, source) in expected_bindings.items():
                self.assertEqual(
                    (face_rows[index].get("mode"), face_rows[index].get("source")),
                    (mode, source),
                    f"face:{index} provenance binding",
                )
            for index in (0, 4):
                self.assertNotEqual(
                    [vertex[:3] for vertex in frame_vertices(self.build, "face", index)],
                    [vertex[:3] for vertex in frame_vertices(self.donor, "face", index)],
                    f"face:{index} must use registered concept geometry",
                )
        else:
            for index in range(33):
                self.assertEqual(
                    [vertex[:3] for vertex in frame_vertices(self.build, "face", index)],
                    [vertex[:3] for vertex in frame_vertices(self.donor, "face", index)],
                    f"face:{index} geometry",
                )
            self.assertEqual(
                [vertex[:3] for vertex in frame_vertices(self.build, "face", 33)],
                [vertex[:3] for vertex in frame_vertices(self.donor, "face", 0)],
                "face:33 must use donor neutral geometry",
            )


if __name__ == "__main__":
    unittest.main()
