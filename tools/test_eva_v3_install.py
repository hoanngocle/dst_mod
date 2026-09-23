from hashlib import sha256
import json
from pathlib import Path
import struct
import unittest
from zipfile import ZipFile

ROOT = Path(__file__).resolve().parents[1]
PURPLE_SOURCE = ROOT / "assets/source/eva_v2_luoshen/eva-v2-luoshen-purple.zip"
PRODUCTION = ROOT / "anim/eva.zip"
MANIFEST = ROOT / "docs/eva/package-manifest.json"


def renamed_build(source: bytes, target_name: bytes) -> bytes:
    length = struct.unpack_from("<I", source, 16)[0]
    self_name = source[20:20 + length]
    if self_name != b"xd_luoshen":
        raise ValueError(self_name)
    return (source[:16] + struct.pack("<I", len(target_name)) + target_name
            + source[20 + length:])


def build_symbols(data: bytes):
    position = 8
    symbol_count, _ = struct.unpack_from("<II", data, position)
    position += 8
    name_length = struct.unpack_from("<I", data, position)[0]
    position += 4
    build_name = data[position:position + name_length].decode("ascii")
    position += name_length
    atlas_count = struct.unpack_from("<I", data, position)[0]
    position += 4
    for _ in range(atlas_count):
        length = struct.unpack_from("<I", data, position)[0]
        position += 4 + length
    hashes = []
    for _ in range(symbol_count):
        symbol_hash, frame_count = struct.unpack_from("<II", data, position)
        position += 8 + frame_count * 32
        hashes.append(symbol_hash)
    vertex_count = struct.unpack_from("<I", data, position)[0]
    position += 4 + vertex_count * 24
    names = {}
    name_count = struct.unpack_from("<I", data, position)[0]
    position += 4
    for _ in range(name_count):
        key, length = struct.unpack_from("<II", data, position)
        position += 8
        names[key] = data[position:position + length].decode("ascii")
        position += length
    if position != len(data):
        raise ValueError("trailing BILD bytes")
    return build_name, hashes, {names[value] for value in hashes}


class EvaV3InstallTest(unittest.TestCase):
    def test_production_archive_is_exact_eva_named_purple_donor(self):
        with ZipFile(PURPLE_SOURCE) as source, ZipFile(PRODUCTION) as production:
            self.assertEqual(production.namelist(), source.namelist())
            for member in source.namelist():
                expected = renamed_build(source.read(member), b"eva") if member == "build.bin" else source.read(member)
                self.assertEqual(production.read(member), expected, member)
            name, hashes, symbols = build_symbols(production.read("build.bin"))
        self.assertEqual(name, "eva")
        self.assertEqual(hashes, sorted(hashes))
        self.assertEqual(len(symbols), 12)
        self.assertFalse(any("__eva_" in symbol for symbol in symbols))

    def test_obsolete_motion_and_head_customization_files_are_removed(self):
        for relative in (
            "scripts/util/eva_facing_alias_runtime.lua",
            "scripts/util/eva_facing_alias.lua",
            "scripts/util/eva_run_route.lua",
            "scripts/util/eva_characterbutton.lua",
            "anim/ttk_eva_run_loop.zip",
        ):
            self.assertFalse((ROOT / relative).exists(), relative)

    def test_manifest_records_purple_as_the_only_runtime_archive(self):
        manifest = json.loads(MANIFEST.read_text(encoding="utf8"))
        self.assertEqual(manifest["eva_visual_version"], "EVA2_PURPLE_DEFAULT")
        self.assertEqual(manifest["candidate_source"], "assets/source/eva_v2_luoshen/eva-v2-luoshen-purple.zip")
        self.assertEqual(
            manifest["source_candidate_sha256"], sha256(PURPLE_SOURCE.read_bytes()).hexdigest()
        )
        self.assertEqual(
            manifest["candidate_sha256"], sha256(PRODUCTION.read_bytes()).hexdigest()
        )
        self.assertNotIn("purple_skin_sha256", manifest)
        self.assertEqual(manifest["runtime_motion"], "native_luoshen_build")


if __name__ == "__main__":
    unittest.main()
