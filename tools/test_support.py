"""Shared path discovery for tests run from either source or the Steam mod."""

from __future__ import annotations

import os
from pathlib import Path


MOD_ROOT = Path(__file__).resolve().parents[1]
SCRIPTS_ZIP = Path("data/databundles/scripts.zip")


def find_workspace_root(*required_markers: str, include_defaults: bool = True) -> Path:
    """Return the first workspace containing every requested relative path."""
    candidates: list[Path] = []
    configured = os.environ.get("PHAMNHAN_WORKSPACE_ROOT")
    if configured:
        candidates.append(Path(configured).expanduser())
    if include_defaults:
        candidates.extend((MOD_ROOT, *MOD_ROOT.parents, Path.home() / "company" / "dst_wiki"))

    seen: set[Path] = set()
    for candidate in candidates:
        candidate = candidate.resolve()
        if candidate in seen:
            continue
        seen.add(candidate)
        if all((candidate / marker).exists() for marker in required_markers):
            return candidate

    markers = ", ".join(required_markers) or "<workspace marker>"
    raise FileNotFoundError(
        f"Could not locate the Phàm Nhân workspace containing: {markers}. "
        "Set PHAMNHAN_WORKSPACE_ROOT to the source workspace."
    )


def find_dst_root(*, mod_root: Path = MOD_ROOT) -> Path:
    """Locate the installed Don't Starve Together directory."""
    candidates: list[Path] = []
    configured = os.environ.get("DST_ROOT")
    if configured:
        candidates.append(Path(configured).expanduser())
    if mod_root.parent.name.lower() == "mods":
        candidates.append(mod_root.parent.parent)
    candidates.append(Path("C:/Program Files (x86)/Steam/steamapps/common/Don't Starve Together"))

    for candidate in candidates:
        candidate = candidate.resolve()
        if (candidate / SCRIPTS_ZIP).is_file():
            return candidate
    raise FileNotFoundError("Could not locate DST data/databundles/scripts.zip; set DST_ROOT")


def find_workshop_root(*, dst_root: Path | None = None) -> Path:
    """Return the Steam Workshop content directory for DST app 322330."""
    configured = os.environ.get("DST_WORKSHOP_ROOT")
    if configured:
        return Path(configured).expanduser().resolve()
    dst_root = (dst_root or find_dst_root()).resolve()
    return dst_root.parents[1] / "workshop" / "content" / "322330"
