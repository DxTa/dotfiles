import json
import subprocess
import sys
from pathlib import Path


SCRIPT = Path(__file__).resolve().parents[1] / "tier-detector-fast.py"


def run_detector(task: str, extra_args=None) -> dict:
    extra_args = extra_args or []
    cmd = [
        sys.executable,
        str(SCRIPT),
        "--task",
        task,
        "--rules-only",
        "--format",
        "json",
        *extra_args,
    ]
    completed = subprocess.run(cmd, check=True, capture_output=True, text=True)
    return json.loads(completed.stdout)


def test_single_weak_trigger_does_not_force_t3():
    payload = run_detector("show api endpoints")
    assert payload["tier"] == 1


def test_multi_weak_triggers_escalate_to_t3():
    payload = run_detector("review api logging caching strategy across services")
    assert payload["tier"] == 3


def test_read_only_request_with_high_risk_stays_high_tier():
    payload = run_detector("review rollback plan for production migration")
    assert payload["tier"] == 4


def test_non_destructive_drop_shadow_phrase_is_not_t4():
    payload = run_detector("fix drop shadow contrast on button css")
    assert payload["tier"] != 4


def test_schema_v1_default_remains_backward_compatible():
    payload = run_detector("git status")
    assert set(payload.keys()) == {"tier", "confidence", "source", "use_llm"}


def test_schema_v2_adds_depth_and_controls():
    payload = run_detector("git status", ["--schema-version", "2"])
    assert payload["depth"] == "light"
    assert isinstance(payload["triggers"], list)
    assert isinstance(payload["mandatory_controls"], list)


def test_negated_t4_trigger_does_not_escalate():
    payload = run_detector("do not deploy, just explain the plan")
    assert payload["tier"] == 1


def test_quoted_t4_trigger_does_not_escalate():
    payload = run_detector('review docs mentioning "drop table" statements')
    assert payload["tier"] != 4


def test_backticked_t4_trigger_does_not_escalate():
    payload = run_detector("analyze `truncate table` examples in docs")
    assert payload["tier"] != 4
