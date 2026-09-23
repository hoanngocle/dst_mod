"""Run the Pham Nhan unified UI controller contract in Lua 5.1."""
from pathlib import Path
import unittest
from zipfile import ZipFile
import xml.etree.ElementTree as ET

from lupa.lua51 import LuaRuntime
from test_support import find_dst_root

MOD = Path(__file__).resolve().parents[1]


def run_unified_ui_contracts():
    with ZipFile(MOD / "fonts" / "ttk_forge_serif.zip") as archive:
        common = ET.fromstring(archive.read("font.fnt")).find("common")
    assert common is not None
    assert common.attrib["alphaChnl"] == "1"
    assert common.attrib["redChnl"] == "0"
    assert common.attrib["greenChnl"] == "0"
    assert common.attrib["blueChnl"] == "0"
    print("Forge font channel metadata PASS")

    lua = LuaRuntime(unpack_returned_tuples=True)
    with ZipFile(find_dst_root() / "data" / "databundles" / "scripts.zip") as scripts:
        lua.execute(scripts.read("scripts/class.lua").decode())
    lua.globals().package.path = (
        str(MOD / "scripts" / "?.lua").replace("\\", "/")
        + ";"
        + lua.globals().package.path
    )
    syntax_files = (
        "main/hh_dungeon_shop.lua",
        "main/hh_guild_main.lua",
        "main/hh_rpc.lua",
        "main/hh_ui.lua",
        "main/ttk_solo_source.lua",
        "scripts/screens/hh_dungeon_shop_screen.lua",
        "scripts/screens/hh_shadow_upgrade_screen.lua",
        "scripts/screens/ttk_unified_screen.lua",
        "scripts/ui/ttk_request_gate.lua",
        "scripts/ui/ttk_native_bridge.lua",
        "scripts/ui/ttk_native_open_ack.lua",
        "scripts/ui/ttk_native_input.lua",
        "scripts/ui/ttk_unified_controller.lua",
        "scripts/ui/ttk_unified_open.lua",
        "scripts/ui/ttk_unified_registry.lua",
        "scripts/widgets/hh_guild_ui.lua",
        "scripts/widgets/hh_status_ui.lua",
        "scripts/widgets/hh_ui/hh_equip_ui.lua",
        "scripts/widgets/hh_ui/hh_forge_ui.lua",
        "scripts/widgets/hh_ui/ttk_native_panel.lua",
        "scripts/widgets/hh_ui/ttk_quest_panel.lua",
        "scripts/widgets/hh_ui/ttk_storage_ui.lua",
        "scripts/widgets/hh_ui/ttk_artifact_primitives.lua",
        "scripts/widgets/hh_ui/ttk_strengthen_ui.lua",
        "scripts/widgets/hh_ui/ttk_unified_theme.lua",
    )
    for relative_path in syntax_files:
        lua.globals().__syntax_path = str(MOD / relative_path).replace("\\", "/")
        lua.execute("assert(loadfile(__syntax_path))")
    print(f"Lua syntax checks PASS ({len(syntax_files)} files)")
    lua.globals().__font_loader_path = str(MOD / "main" / "ttk_forge_fonts.lua").replace("\\", "/")
    lua.execute((MOD / "tests" / "ui" / "test_forge_fonts.lua").read_text(encoding="utf-8"))
    for test_name in ("test_unified_controller.lua", "test_unified_screen.lua"):
        lua.execute((MOD / "tests" / "ui" / test_name).read_text(encoding="utf-8"))
    lua.execute((MOD / "tests" / "ui" / "test_artifact_theme.lua").read_text(encoding="utf-8"))


class UnifiedUIContractTest(unittest.TestCase):
    def test_unified_ui_contracts(self):
        run_unified_ui_contracts()


if __name__ == "__main__":
    unittest.main()
