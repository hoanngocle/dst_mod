from hashlib import sha256
import importlib.util
from pathlib import Path
import shutil
import unittest
from uuid import uuid4
from zipfile import ZipFile

try:
    import numpy as np
except ModuleNotFoundError as error:
    raise unittest.SkipTest("optional EVA preview tests require numpy") from error


TOOLS = Path(__file__).resolve().parent
SCRIPT = TOOLS / "build_eva_v2_luoshen_preview.py"
SOURCE = TOOLS.parent / "assets/source/eva_approved/donor-luoshen.zip"


def load_builder():
    spec = importlib.util.spec_from_file_location("eva_v2_builder", SCRIPT)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


class EvaV2LuoshenPreviewTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.builder = load_builder()

    def test_palette_preserves_skin_neutral_lineart_and_maps_colors_to_purple(self):
        pixels = np.array([[[
            [20, 18, 19, 255],       # black line
            [250, 215, 213, 255],    # pale skin
            [245, 245, 245, 255],    # eye white
            [92, 50, 43, 255],       # brown hair
            [230, 92, 25, 255],      # orange costume
            [25, 148, 101, 255],     # green gem
        ]]], dtype=np.uint8).reshape((1, 6, 4))
        recolored = self.builder.recolor_straight_rgba(pixels)
        np.testing.assert_array_equal(recolored[0, :3], pixels[0, :3])
        np.testing.assert_array_equal(recolored[:, :, 3], pixels[:, :, 3])
        for index in (3, 4, 5):
            red, green, blue = map(int, recolored[0, index, :3])
            self.assertGreater(blue, green, index)
            self.assertGreater(red, green, index)
            self.assertFalse(np.array_equal(recolored[0, index], pixels[0, index]))

    def test_ktex_recolor_preserves_headers_dimensions_and_every_alpha_block(self):
        with ZipFile(SOURCE) as archive:
            original = archive.read("atlas-0.tex")
        recolored = self.builder.recolor_ktex(original)
        before = self.builder.read_ktex(original)
        after = self.builder.read_ktex(recolored)
        self.assertEqual(before[:2], after[:2])
        self.assertEqual(len(before[2]), len(after[2]))
        changed_color_blocks = 0
        for old_payload, new_payload in zip(before[2], after[2]):
            self.assertEqual(len(old_payload), len(new_payload))
            for offset in range(0, len(old_payload), 16):
                self.assertEqual(
                    old_payload[offset:offset + 8],
                    new_payload[offset:offset + 8],
                )
                changed_color_blocks += (
                    old_payload[offset + 8:offset + 16]
                    != new_payload[offset + 8:offset + 16]
                )
        self.assertGreater(changed_color_blocks, 0)

    def test_candidate_is_exact_donor_except_for_atlas_color_payload(self):
        fixture = SCRIPT.parent.parent / "assets/source/eva_v2_luoshen" / (
            "test-" + uuid4().hex
        )
        fixture.mkdir(parents=True)
        try:
            target = fixture / "eva-v2-luoshen-purple.zip"
            report = self.builder.build_candidate(SOURCE, target)
            with ZipFile(SOURCE) as original, ZipFile(target) as candidate:
                self.assertEqual(original.namelist(), candidate.namelist())
                self.assertEqual(
                    original.read("build.bin"), candidate.read("build.bin")
                )
                self.assertEqual(
                    original.read("anim.bin"), candidate.read("anim.bin")
                )
                self.assertNotEqual(
                    original.read("atlas-0.tex"), candidate.read("atlas-0.tex")
                )
            self.assertEqual(
                report["source_sha256"], sha256(SOURCE.read_bytes()).hexdigest()
            )
            self.assertTrue(report["alpha_blocks_exact"])
        finally:
            shutil.rmtree(fixture)


if __name__ == "__main__":
    unittest.main()
