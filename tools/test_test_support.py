from pathlib import Path
import os
import tempfile
import unittest
from unittest.mock import patch

from test_support import find_dst_root, find_workshop_root, find_workspace_root


class WorkspaceRootTest(unittest.TestCase):
    def test_explicit_workspace_with_required_marker_is_selected(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            marker = root / "data" / "manual" / "catalog.json"
            marker.parent.mkdir(parents=True)
            marker.write_text("{}", encoding="utf-8")

            with patch.dict(os.environ, {"PHAMNHAN_WORKSPACE_ROOT": str(root)}):
                self.assertEqual(root, find_workspace_root("data/manual/catalog.json"))

    def test_missing_workspace_reports_the_required_marker(self):
        with tempfile.TemporaryDirectory() as temp:
            with patch.dict(os.environ, {"PHAMNHAN_WORKSPACE_ROOT": temp}):
                with self.assertRaisesRegex(FileNotFoundError, "missing/catalog.json"):
                    find_workspace_root("missing/catalog.json", include_defaults=False)

    def test_dst_root_is_derived_from_the_installed_mod_location(self):
        with tempfile.TemporaryDirectory() as temp:
            dst_root = Path(temp) / "steamapps" / "common" / "Don't Starve Together"
            scripts_zip = dst_root / "data" / "databundles" / "scripts.zip"
            scripts_zip.parent.mkdir(parents=True)
            scripts_zip.write_bytes(b"zip")
            mod_root = dst_root / "mods" / "PhamNhanTuTien"
            mod_root.mkdir(parents=True)

            with patch.dict(os.environ, {}, clear=True):
                self.assertEqual(dst_root, find_dst_root(mod_root=mod_root))
                self.assertEqual(
                    Path(temp) / "steamapps" / "workshop" / "content" / "322330",
                    find_workshop_root(dst_root=dst_root),
                )


if __name__ == "__main__":
    unittest.main()
