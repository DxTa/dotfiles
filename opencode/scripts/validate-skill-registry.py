#!/usr/bin/env python3
"""Validate skill registry IDs across index and rules."""

import json
from pathlib import Path
import sys


def load_json(path: Path) -> dict:
    try:
        return json.loads(path.read_text())
    except FileNotFoundError:
        print(f"ERROR: Missing file: {path}")
        sys.exit(2)
    except json.JSONDecodeError as exc:
        print(f"ERROR: Invalid JSON in {path}: {exc}")
        sys.exit(2)


def main() -> int:
    repo_root = Path(__file__).resolve().parents[1]
    index_path = repo_root / "skills" / "index.json"
    rules_path = repo_root / "skill-rules.json"

    index = load_json(index_path)
    rules = load_json(rules_path)

    index_ids = set(index.get("skills", {}).keys())
    rules_ids = set(rules.get("skills", {}).keys())

    missing_in_rules = sorted(index_ids - rules_ids)
    allowed_extras = {
        "debugging",
        "superpowers-branch-completion",
        "superpowers-code-review",
        "superpowers-debugging",
        "superpowers-tdd",
        "superpowers-verification",
    }
    extra_in_rules = sorted((rules_ids - index_ids) - allowed_extras)

    ok = True
    if missing_in_rules:
        ok = False
        print("MISSING in skill-rules.json:")
        for item in missing_in_rules:
            print(f"  - {item}")

    if extra_in_rules:
        ok = False
        print("EXTRA in skill-rules.json:")
        for item in extra_in_rules:
            print(f"  - {item}")

    if ok:
        print("OK: skill-rules.json matches skills/index.json")
        return 0

    return 1


if __name__ == "__main__":
    raise SystemExit(main())
