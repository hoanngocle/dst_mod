"""Validation and facing lookup for EVA's offline symbol-alias contract."""

from __future__ import annotations

import json
from pathlib import Path


ANIM_FACING_VIEWS = {8: "front", 5: "profile", 2: "rear"}


def load_contract(path: Path) -> dict:
    contract = json.loads(Path(path).read_text(encoding="utf8"))
    if not isinstance(contract, dict) or not isinstance(contract.get("targets"), dict):
        raise ValueError("facing alias map must contain an object-valued 'targets' field")
    return contract


def sources_for_facing(contract: dict, facing: int) -> dict[str, str]:
    try:
        view = ANIM_FACING_VIEWS[facing]
    except KeyError as error:
        raise ValueError(f"unsupported player ANIM facing mask {facing}") from error
    targets = contract.get("targets")
    if not isinstance(targets, dict) or not targets:
        raise ValueError("facing alias map has no targets")
    result = {}
    for target, views in targets.items():
        if not isinstance(target, str) or not isinstance(views, dict):
            raise ValueError("facing alias targets and view maps must be objects of strings")
        source = views.get(view)
        if not isinstance(source, str) or not source:
            raise ValueError(f"facing alias target {target!r} has no {view!r} source")
        result[target] = source
    return result
