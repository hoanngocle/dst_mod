"""Generate the checked-in Phàm Nhân alchemy catalog from manual records."""

from __future__ import annotations

import json
from pathlib import Path
import re
import tempfile
from typing import Any

from test_support import find_workspace_root


MOD_ROOT = Path(__file__).resolve().parents[1]
WORKSPACE_ROOT = find_workspace_root("data/manual/tu_tien_item_details.json")
MANUAL_PATH = WORKSPACE_ROOT / "data" / "manual" / "tu_tien_item_details.json"
OUTPUT_PATH = MOD_ROOT / "scripts" / "alchemy" / "ttk_alchemy_defs.lua"

CULTIVATION_PREFABS = (
    "xd_danyao_jq", "xd_danyao_dt", "xd_danyao_zj", "xd_danyao_xs",
    "xd_danyao_hj", "xd_danyao_yz", "xd_danyao_sm", "xd_danyao_rl",
    "xd_danyao_jy", "xd_danyao_yx", "xd_danyao_ns", "xd_danyao_hs",
    "xd_danyao_hy", "xd_danyao_hl", "xd_danyao_kx",
)
BUFF_PREFABS = (
    "xd_dy_cyfxd_1", "xd_dy_dmhsd_1", "xd_dy_lmsqd_1",
    "xd_dy_qxdhd_1", "xd_dy_yfsxd_1", "xd_dy_pshsd_1",
    "xd_dy_qjqsd_1", "xd_dy_xynyd_1", "xd_dy_hsphd_1",
    "xd_dy_xttyd_1",
)
FASTING_PREFAB = "xd_danyao_bg"

# Verified identity renames: ttk_lingshi, ttk_herbs and ttk_batch19_houseitems
# are loaded by the current mod's registration chain.
# Keep this explicit: replacing an xd_ prefix does not prove a prefab exists.
INGREDIENT_ALIASES = {
    "xd_lingshi1": "ttk_lingshi1",
    "xd_lingshi2": "ttk_lingshi2",
    "xd_lingshi3": "ttk_lingshi3",
    "xd_lc_hsc": "ttk_lc_hsc",
    "xd_lc_dms": "ttk_lc_dms",
    "xd_lc_qfx": "ttk_lc_qfx",
    "xd_lc_cyh": "ttk_lc_cyh",
    "xd_lc_lmg": "ttk_lc_lmg",
    "xd_lc_yhh": "ttk_lc_yhh",
    "xd_npxsz": "ttk_npxsz",
    "xd_pog_tail": "ttk_pog_tail",
    "xd_spider_leg": "ttk_spider_leg",
}

# Task 19 controller ruling (2026-09-22): these source materials are absent,
# retired, or limited to one-time unique-boss drops. These are approved recipe
# substitutions, NOT identity renames. Preserve quantities and use existing
# repeatable ttk_boss_cores instead of one-time ttk_boss_mgqg/ttk_boss_zcmy.
# Stage 15 uses approved grade-one pills exported by ttk_alchemy; grade two
# is unavailable. No runtime crafting aliases or new prefabs are introduced.
INGREDIENT_SUBSTITUTIONS = {
    "xd_ayhx": "ttk_boss_core_stalke_fuben",
    "xd_aymg": "ttk_boss_core_stalke_fuben",
    "xd_baihu_skin": "ttk_boss_core_baihu",
    "xd_fs": "ttk_boss_core_jfsn",
    "xd_qlr": "ttk_boss_core_qlch",
    "xd_qianyu": "ttk_boss_core_deerclops_ziyun",
    "xd_mgqg": "ttk_boss_core_stalke_fuben",
    "xd_zcmy": "ttk_boss_core_deerclops_ziyun",
    "xd_dy_pshsd_2": "xd_dy_pshsd_1",
    "xd_dy_xttyd_2": "xd_dy_xttyd_1",
}
CURRENT_XD_INGREDIENTS = frozenset({"xd_dy_pshsd_1", "xd_dy_xttyd_1"})

# Runtime behavior is deliberately explicit: gameplay never parses manual prose.
RUNTIME_EFFECTS = {
    "xd_dy_cyfxd_1": {"kind": "damage_mult", "multiplier": 1.4, "duration": 2400},
    "xd_dy_dmhsd_1": {"kind": "health_regen", "immediate": 120, "amount": 15, "interval": 6, "duration": 2400},
    "xd_dy_lmsqd_1": {"kind": "lightning_damage", "amount": 180, "duration": 2400},
    "xd_dy_qxdhd_1": {"kind": "sanity_regen", "amount": 20 / 3, "duration": 2400},
    "xd_dy_yfsxd_1": {"kind": "speed_mult", "multiplier": 1.25, "duration": 2400},
    "xd_dy_pshsd_1": {"kind": "damage_reduction", "multiplier": 0.65, "duration": 2400},
    "xd_dy_qjqsd_1": {"kind": "work_efficiency", "multiplier": 1.9, "duration": 2400},
    "xd_dy_xynyd_1": {"kind": "cold_protection", "duration": 2400},
    "xd_dy_hsphd_1": {"kind": "heat_protection", "duration": 2400},
    "xd_dy_xttyd_1": {"kind": "lifesteal", "fraction": 0.5, "duration": 2400},
    FASTING_PREFAB: {"kind": "hunger_rate", "multiplier": 0.2},
}

# Manual records deliberately do not carry a stable user-facing name. These
# approved names must remain explicit rather than inferred during generation.
DISPLAY_NAMES = {
    "xd_danyao_jq": "Tụ Khí Hoàn",
    "xd_danyao_dt": "Đột Phá Đan",
    "xd_danyao_zj": "Trúc Cơ Đan",
    "xd_danyao_xs": "Tẩy Tủy Đan",
    "xd_danyao_hj": "Hóa Tinh Đan",
    "xd_danyao_yz": "Ngưng Chân Đan",
    "xd_danyao_sm": "Sơ Mạch Đan",
    "xd_danyao_rl": "Dung Linh Đan",
    "xd_danyao_jy": "Kết Anh Đan",
    "xd_danyao_yx": "Uẩn Huyết Đan",
    "xd_danyao_ns": "Ngưng Thần Đan",
    "xd_danyao_hs": "Hóa Thần Đan",
    "xd_danyao_hy": "Hồi Nguyên Đan",
    "xd_danyao_hl": "Hợp Linh Đan",
    "xd_danyao_kx": "Khuy Hư Đan",
    "xd_dy_cyfxd_1": "Cuồng Ý Phúc Xà Đan",
    "xd_dy_dmhsd_1": "Đại Mệnh Hồi Sinh Đan",
    "xd_dy_lmsqd_1": "Lôi Mãng Sát Khí Đan",
    "xd_dy_qxdhd_1": "Thanh Tâm Đan",
    "xd_dy_yfsxd_1": "Ngự Phong Thần Hành Đan",
    "xd_dy_pshsd_1": "Phòng Sát Hộ Thân Đan",
    "xd_dy_qjqsd_1": "Cường Kình Khai Sơn Đan",
    "xd_dy_xynyd_1": "Huyền Nguyên Ninh Dương Đan",
    "xd_dy_hsphd_1": "Hỏa Sát Phích Hàn Đan",
    "xd_dy_xttyd_1": "Huyết Thực Thiên Ý Đan",
    "xd_danyao_bg": "Bích Cốc Đan",
}


def require_mapping(value: Any, field: str) -> dict[str, Any]:
    if type(value) is not dict:
        raise ValueError(f"{field} must be a JSON object")
    return value


def require_list(value: Any, field: str) -> list[Any]:
    if type(value) is not list:
        raise ValueError(f"{field} must be a JSON array")
    return value


def require_string(value: Any, field: str, *, non_empty: bool = False) -> str:
    if type(value) is not str:
        raise ValueError(f"{field} must be a JSON string")
    if non_empty and not value.strip():
        raise ValueError(f"{field} must not be empty")
    return value


def require_positive_int(value: Any, field: str) -> int:
    if type(value) is not int or value <= 0:
        raise ValueError(f"{field} must be a positive JSON integer")
    return value


def runtime_prefab(item_id: str) -> str:
    """Resolve a source ingredient during generation, never at craft time."""
    item_id = require_string(item_id, "ingredient id", non_empty=True)
    namespace, separator, prefab = item_id.partition(":")
    if (
        item_id.count(":") != 1
        or namespace not in {"base_game", "tu_tien"}
        or not separator
        or not prefab
        or prefab != prefab.strip()
        or re.fullmatch(r"[a-z0-9_]+", prefab) is None
    ):
        raise ValueError(f"Invalid manual item id: {item_id!r}")
    resolved = INGREDIENT_ALIASES.get(prefab, INGREDIENT_SUBSTITUTIONS.get(prefab, prefab))
    if resolved.startswith("xd_") and resolved not in CURRENT_XD_INGREDIENTS:
        raise ValueError(f"Unmapped historical alchemy ingredient: {item_id!r}")
    return resolved


def lua_string(value: str) -> str:
    """Encode a validated Python string as a Lua 5.1-compatible literal."""
    value = require_string(value, "Lua string")
    escapes = {
        "\\": "\\\\",
        '"': '\\"',
        "\a": "\\a",
        "\b": "\\b",
        "\f": "\\f",
        "\n": "\\n",
        "\r": "\\r",
        "\t": "\\t",
        "\v": "\\v",
    }
    encoded = "".join(
        escapes.get(character, f"\\{ord(character):03d}" if ord(character) < 32 or ord(character) == 127 else character)
        for character in value
    )
    return f'"{encoded}"'


def read_records() -> list[tuple[str, dict[str, Any]]]:
    with MANUAL_PATH.open(encoding="utf-8") as manual_file:
        document = require_mapping(json.load(manual_file), "manual document")
    return records_from_items(require_mapping(document.get("items"), "manual items"))


def records_from_items(items: dict[str, Any]) -> list[tuple[str, dict[str, Any]]]:
    """Select and validate the exact manual fields that are rendered to Lua."""
    items = require_mapping(items, "manual items")

    allowed = (*CULTIVATION_PREFABS, *BUFF_PREFABS, FASTING_PREFAB)
    if len(DISPLAY_NAMES) != len(allowed) or set(DISPLAY_NAMES) != set(allowed):
        raise ValueError("Display-name overrides must cover exactly the allowed alchemy records")
    if set(RUNTIME_EFFECTS) != set(BUFF_PREFABS) | {FASTING_PREFAB}:
        raise ValueError("Runtime-effect overrides must cover exactly the approved buff records")

    records: list[tuple[str, dict[str, Any]]] = []
    for prefab in allowed:
        record = items.get(f"tu_tien:{prefab}")
        if type(record) is not dict:
            raise ValueError(f"Missing manual record for {prefab}")
        recipe = require_mapping(record.get("recipe"), f"{prefab}.recipe")
        require_positive_int(recipe.get("outputCount"), f"{prefab}.recipe.outputCount")
        ingredients = require_list(recipe.get("ingredients"), f"{prefab}.recipe.ingredients")
        if not 1 <= len(ingredients) <= 4:
            raise ValueError(f"{prefab} must have one to four recipe ingredients")
        for index, ingredient in enumerate(ingredients, start=1):
            ingredient = require_mapping(ingredient, f"{prefab}.recipe.ingredients[{index}]")
            runtime_prefab(require_string(ingredient.get("id"), f"{prefab}.recipe.ingredients[{index}].id", non_empty=True))
            require_positive_int(ingredient.get("amount"), f"{prefab}.recipe.ingredients[{index}].amount")
        require_string(recipe.get("craftingNote"), f"{prefab}.recipe.craftingNote")

        usage = require_mapping(record.get("usage"), f"{prefab}.usage")
        effects = require_list(usage.get("effects"), f"{prefab}.usage.effects")
        for index, effect in enumerate(effects, start=1):
            effect = require_mapping(effect, f"{prefab}.usage.effects[{index}]")
            require_string(effect.get("trigger"), f"{prefab}.usage.effects[{index}].trigger")
            require_string(effect.get("text"), f"{prefab}.usage.effects[{index}].text")
        records.append((prefab, record))
    return records


def append_row(lines: list[str], prefab: str, record: dict[str, Any]) -> None:
    recipe = record["recipe"]
    lines.extend((
        f"M.by_prefab[{lua_string(prefab)}] = {{",
        f"  prefab = {lua_string(prefab)},",
        f"  name = {lua_string(DISPLAY_NAMES[prefab])},",
        "  recipe = {",
        f"    output_count = {recipe['outputCount']},",
        "    ingredients = {",
    ))
    for ingredient in recipe["ingredients"]:
        lines.append(f"      {{ prefab={lua_string(runtime_prefab(ingredient['id']))}, amount={ingredient['amount']} }},")
    lines.extend((
        "    },",
        f"    crafting_note = {lua_string(recipe['craftingNote'])},",
        "  },",
        "  effects = {",
    ))
    for effect in record["usage"]["effects"]:
        lines.append(f"    {{ trigger={lua_string(effect['trigger'])}, text={lua_string(effect['text'])} }},")
    lines.append("  },")
    runtime = RUNTIME_EFFECTS.get(prefab)
    if runtime is not None:
        parts = []
        for key, value in runtime.items():
            encoded = lua_string(value) if type(value) is str else repr(value)
            parts.append(f"{key} = {encoded}")
        lines.append(f"  effect = {{ {', '.join(parts)} }},")
    lines.extend(("}", ""))


def render(records: list[tuple[str, dict[str, Any]]]) -> str:
    lines = [
        "-- Generated by tools/build_alchemy_defs.py; do not edit manually.",
        "local M = {}",
        "",
        "M.furnace = {",
        '  prefab = "xd_liandanlu",',
        "  duration = 180,",
        "  ingredients = {",
        '    { prefab="goldnugget", amount=5 },',
        '    { prefab="cutstone", amount=3 },',
        '    { prefab="flint", amount=3 },',
        '    { prefab="ttk_lingshi1", amount=5 },',
        "  },",
        "}",
        "",
        "M.by_prefab = {}",
        "",
    ]
    for prefab, record in records:
        append_row(lines, prefab, record)

    lines.append("M.cultivation = {}")
    for stage, prefab in enumerate(CULTIVATION_PREFABS, start=1):
        lines.append(f"M.cultivation[{stage}] = M.by_prefab[{lua_string(prefab)}]")
    lines.extend(("", f"M.fasting = M.by_prefab[{lua_string(FASTING_PREFAB)}]", "", "M.buffs = {}"))
    for prefab in BUFF_PREFABS:
        lines.append(f"M.buffs[{lua_string(prefab)}] = M.by_prefab[{lua_string(prefab)}]")
    lines.extend((
        "",
        "function M.Get(prefab) return M.by_prefab[prefab] end",
        "function M.GetCultivationStage(stage) return M.cultivation[stage] end",
        "function M.GetRecipe(prefab) local row=M.Get(prefab); return row and row.recipe or nil end",
        "return M",
        "",
    ))
    return "\n".join(lines)


def write_output(source: str) -> None:
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(
        "w", encoding="utf-8", newline="\n", dir=OUTPUT_PATH.parent,
        prefix=f".{OUTPUT_PATH.name}.", suffix=".tmp", delete=False,
    ) as temporary:
        temporary.write(source)
        temporary_path = Path(temporary.name)
    temporary_path.replace(OUTPUT_PATH)


def main() -> None:
    write_output(render(read_records()))


if __name__ == "__main__":
    main()
