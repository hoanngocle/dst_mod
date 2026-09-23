from hashlib import sha256
from pathlib import Path
import shutil
import unittest
from uuid import uuid4
from zipfile import ZipFile

try:
    import numpy as np
except ModuleNotFoundError as error:
    raise unittest.SkipTest("optional EVA preview tests require numpy") from error

from mods.PhamNhanTuTien.tools import build_eva_v3_luoshen_preview as builder


SOURCE = Path(__file__).resolve().parents[1] / "assets/source/eva_approved/donor-luoshen.zip"


class EvaV3LuoshenPreviewTest(unittest.TestCase):
    def test_outline_softening_changes_only_masked_dark_non_skin_pixels(self):
        pixels = np.array([[
            [10, 8, 9, 255],         # selected structural ink
            [10, 8, 9, 255],         # unselected face ink
            [250, 215, 213, 255],    # selected skin remains skin
            [120, 100, 130, 255],    # selected non-ink remains palette color
        ]], dtype=np.uint8)
        mask = np.array([[True, False, True, True]])
        mapped = builder.soften_selected_outlines(pixels, mask)
        np.testing.assert_array_equal(mapped[0, 0], [47, 39, 55, 255])
        self.assertLessEqual(int(mapped[0, 0, :3].max()), 70)
        np.testing.assert_array_equal(mapped[0, 1:], pixels[0, 1:])

    def test_outline_uv_mask_includes_outfit_arms_but_excludes_hands(self):
        with ZipFile(SOURCE) as archive:
            build = builder.parse_build(archive.read("build.bin"))
        mask = builder.outline_uv_masks(SOURCE)[(2048, 2048)]

        def triangle_centroid(symbol):
            vertices = build.symbols[symbol][0].vertices[:3]
            x = int(sum(vertex[3] for vertex in vertices) / 3 * 2048)
            y = int(sum(vertex[4] for vertex in vertices) / 3 * 2048)
            return x, y

        for symbol in ("arm_upper", "arm_upper_skin", "arm_lower"):
            x, y = triangle_centroid(symbol)
            self.assertTrue(mask[y, x], symbol)
        x, y = triangle_centroid("hand")
        self.assertFalse(mask[y, x], "hand")

    def test_material_palette_and_native_archive_invariants(self):
        pixels = np.array([[
            [20, 18, 19, 255],       # ink
            [250, 215, 213, 255],    # skin
            [92, 50, 43, 255],       # brown hair
            [230, 92, 25, 255],      # orange costume
            [25, 148, 101, 255],     # green jewel
        ]], dtype=np.uint8)
        mapped = builder.recolor_eva_v3(pixels)
        np.testing.assert_array_equal(mapped[0, :2], pixels[0, :2])
        self.assertGreater(mapped[0, 2, 0], pixels[0, 2, 0])
        self.assertGreater(mapped[0, 2, 2], mapped[0, 2, 1])
        self.assertGreater(mapped[0, 3, 2], mapped[0, 3, 1])
        self.assertGreater(mapped[0, 4, 2], mapped[0, 4, 1])
        np.testing.assert_array_equal(mapped[:, :, 3], pixels[:, :, 3])

        fixture = Path(__file__).resolve().parents[1] / "assets/source/eva_v3_luoshen" / (
            "test-" + uuid4().hex
        )
        fixture.mkdir(parents=True)
        try:
            target = fixture / "eva-v3-luoshen-white-purple.zip"
            report = builder.build_candidate(builder.BEFORE, target)
            with ZipFile(builder.BEFORE) as baseline, ZipFile(target) as candidate:
                self.assertEqual(baseline.namelist(), candidate.namelist())
                self.assertEqual(baseline.read("build.bin"), candidate.read("build.bin"))
                self.assertEqual(baseline.read("anim.bin"), candidate.read("anim.bin"))
                before = baseline.read("atlas-0.tex")
                after = candidate.read("atlas-0.tex")
                self.assertNotEqual(before, after)
                self.assertTrue(builder.base._alpha_blocks_equal(before, after))
                _, records, old_payloads = builder.base.read_ktex(before)
                _, _, new_payloads = builder.base.read_ktex(after)
                masks = builder.outline_uv_masks(SOURCE)
                for record, old, new in zip(records, old_payloads, new_payloads):
                    width, height = record[:2]
                    stored = np.asarray(builder.Image.frombytes(
                        "RGBA", (width, height), old, "bcn", (3, "DXT5")
                    ))
                    straight = builder.base._unpremultiply(stored)
                    selected_ink = (
                        masks[(width, height)]
                        & (straight[:, :, 3] > 0)
                        & (straight[:, :, :3].max(axis=2) <= 55)
                    )
                    blocks_wide = (width + 3) // 4
                    for block_y in range((height + 3) // 4):
                        for block_x in range(blocks_wide):
                            y0, x0 = block_y * 4, block_x * 4
                            offset = (block_y * blocks_wide + block_x) * 16
                            if not selected_ink[
                                y0:min(y0 + 4, height), x0:min(x0 + 4, width)
                            ].any():
                                self.assertEqual(
                                    old[offset:offset + 16], new[offset:offset + 16]
                                )
            self.assertEqual(
                report["source_sha256"], sha256(builder.BEFORE.read_bytes()).hexdigest()
            )
            self.assertTrue(report["alpha_blocks_exact"])
        finally:
            shutil.rmtree(fixture)


if __name__ == "__main__":
    unittest.main()
