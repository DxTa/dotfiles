import json
import os
import re
import subprocess
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PROMPTS_PATH = ROOT / "opencode" / "benchmarks" / "tier-detector-prompts.jsonl"
OUTPUT_PATH = ROOT / "opencode" / "benchmarks" / "tier-detector-benchmark-results.json"

OPENCODE_BIN = Path.home() / ".opencode" / "bin" / "opencode"
STORAGE_ROOT = Path.home() / ".local" / "share" / "opencode" / "storage"
MSG_ROOT = STORAGE_ROOT / "message"
PART_ROOT = STORAGE_ROOT / "part"

TIER_RE = re.compile(r"TIER:\s*\[?(\d)\]?", re.IGNORECASE)
TASK_ID_RE = re.compile(r"TaskID:\s*(\d+)")


def run_cmd(args):
    subprocess.run(args, check=True)


def git_branch():
    try:
        return subprocess.check_output(
            ["git", "rev-parse", "--abbrev-ref", "HEAD"], text=True
        ).strip()
    except subprocess.CalledProcessError:
        return "unknown"


def read_text_part(message_id):
    part_dir = PART_ROOT / message_id
    if not part_dir.exists():
        return ""
    texts = []
    for part_file in sorted(part_dir.glob("prt_*.json")):
        data = json.loads(part_file.read_text())
        if data.get("type") == "text":
            texts.append(data.get("text", ""))
    return "\n".join(texts)


def main():
    if not OPENCODE_BIN.exists():
        raise SystemExit("opencode binary not found at ~/.opencode/bin/opencode")

    prompts = [
        json.loads(line)
        for line in PROMPTS_PATH.read_text().splitlines()
        if line.strip()
    ]
    cwd = str(Path.cwd())
    branch = git_branch()

    start_ms = int(time.time() * 1000)

    for item in prompts:
        task_id = item["id"]
        task = item["task"]
        prompt = (
            f"Context: cwd={cwd}\n"
            f"Context: git_branch={branch}\n"
            f"TaskID: {task_id}\n"
            f"Task: {task}"
        )
        run_cmd(
            [
                str(OPENCODE_BIN),
                "run",
                "--agent",
                "tier-detector-bench",
                "--model",
                "opencode/gpt-5-nano",
                "--format",
                "json",
                prompt,
            ]
        )

    results = []
    for msg_file in MSG_ROOT.rglob("msg_*.json"):
        data = json.loads(msg_file.read_text())
        if data.get("agent") != "tier-detector-bench":
            continue
        if data.get("role") != "assistant":
            continue
        if data.get("time", {}).get("created", 0) < start_ms:
            continue
        if data.get("error"):
            continue

        message_id = data["id"]
        text = read_text_part(message_id)
        tier_match = TIER_RE.search(text)
        tier = int(tier_match.group(1)) if tier_match else None

        parent_id = data.get("parentID")
        task_id = None
        if parent_id:
            parent_text = read_text_part(parent_id)
            task_match = TASK_ID_RE.search(parent_text)
            if task_match:
                task_id = int(task_match.group(1))

        created = data["time"]["created"]
        completed = data["time"]["completed"]
        duration_ms = completed - created

        results.append(
            {
                "message_id": message_id,
                "task_id": task_id,
                "tier": tier,
                "duration_ms": duration_ms,
            }
        )

    expected = {p["id"]: p["expected_tier"] for p in prompts}
    scored = []
    for r in results:
        exp = expected.get(r["task_id"])
        r["expected_tier"] = exp
        r["correct"] = exp is not None and r["tier"] == exp
        scored.append(r)

    durations = sorted(
        [r["duration_ms"] for r in scored if r["duration_ms"] is not None]
    )

    def pct(vals, p):
        if not vals:
            return None
        k = (len(vals) - 1) * p
        f = int(k)
        c = min(f + 1, len(vals) - 1)
        if f == c:
            return vals[f]
        return vals[f] + (vals[c] - vals[f]) * (k - f)

    p50 = pct(durations, 0.50)
    p95 = pct(durations, 0.95)
    accuracy = None
    if scored:
        accuracy = sum(1 for r in scored if r["correct"]) / len(scored)

    output = {
        "start_ms": start_ms,
        "count": len(scored),
        "p50_ms": p50,
        "p95_ms": p95,
        "accuracy": accuracy,
        "results": scored,
    }

    OUTPUT_PATH.write_text(json.dumps(output, indent=2))
    print(json.dumps(output, indent=2))


if __name__ == "__main__":
    main()
