"""Static/runtime-marker checks for the disposable dedicated-server smoke."""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")

ROOT = Path(__file__).resolve().parents[1]
SMOKE = ROOT / "tools" / "jitan_runtime_smoke.lua"
source = SMOKE.read_text(encoding="utf-8")

for contract in (
    'Catalog.GetEntries()',
    'Bosses.Spawn(trial, encounter.id)',
    'trial:TickActive(trial.run_id)',
    'PHASE_PASS',
    'TWINS_PASS',
    'CHEST_PASS',
    'private_a.components.container:Open(other) == false',
    'runtime-recovery:1',
):
    assert contract in source, contract

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--log", type=Path)
    parser.add_argument("--expected-encounters", type=int, default=51)
    parser.add_argument("--expected-unavailable", type=int, default=0)
    args = parser.parse_args()
    if args.log is not None:
        log = args.log.read_text(encoding="utf-8", errors="replace")
        assert "TTK_JITAN_RUNTIME_FAIL" not in log
        assert "TTK_JITAN_RUNTIME_ENCOUNTER_FAIL" not in log
        assert "LUA ERROR" not in log and "stack traceback" not in log
        assert "TTK_JITAN_RUNTIME_PHASE_PASS" in log
        assert "TTK_JITAN_RUNTIME_TWINS_PASS" in log
        assert "TTK_JITAN_RUNTIME_CHEST_PASS" in log
        encounter_ids = re.findall(r"TTK_JITAN_RUNTIME_ENCOUNTER_PASS\s+([^\s]+)", log)
        assert len(encounter_ids) == len(set(encounter_ids)) == args.expected_encounters, encounter_ids
        summaries = [line for line in log.splitlines() if "TTK_JITAN_RUNTIME_PASS" in line]
        assert len(summaries) == 1, summaries
        summary = summaries[0]
        assert f"encounters={args.expected_encounters}" in summary, summary
        assert f"unavailable={args.expected_unavailable}" in summary, summary
        print(f"Đạt: runtime {args.expected_encounters} encounter, phase chain, twins loot và rương riêng")
    else:
        print("Đạt: runtime smoke bao phủ catalog, lifecycle và rương riêng; truyền --log để xác minh server")
