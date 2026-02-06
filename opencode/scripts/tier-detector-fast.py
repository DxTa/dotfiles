#!/usr/bin/env python3
"""Local fast-path tier classification with small HF model fallback.

Usage:
  pkgx python /home/dxta/.dotfiles/opencode/scripts/tier-detector-fast.py --task "..."
  echo "..." | pkgx python /home/dxta/.dotfiles/opencode/scripts/tier-detector-fast.py --stdin
"""

from __future__ import annotations

import argparse
import contextlib
import hashlib
import io
import json
import os
import re
import sys
import time
from pathlib import Path
from dataclasses import dataclass
from typing import Dict, List, Optional


T4_KEYWORDS = {
    "deploy",
    "production",
    "rollback",
    "destroy",
    "drop table",
    "irreversible",
    "customer data",
    "pii",
    "secrets rotation",
    "rotate production secrets",
}

T3_KEYWORDS = {
    "architecture",
    "refactor",
    "new module",
    "new service",
    "auth",
    "logging",
    "caching",
    "shared utility",
    "schema",
    "migration",
    "database",
    "orm",
    "api",
    "webhook",
    "sdk",
    "external service",
    "security",
    "encryption",
    "permissions",
    "input validation",
    "breaking change",
    "public interface",
    "backward compatibility",
    "unclear scope",
    "unfamiliar",
    "might affect",
}


LABEL_PROMPTS: Dict[int, str] = {
    1: "Tiny change in one file (<30 lines); typo/comment/formatting.",
    2: "Small change across 2-5 files (30-100 lines) within existing patterns.",
    3: "Architecture or cross-cutting change; auth/integration/schema/security/uncertainty.",
    4: "Production deploy, irreversible change, data deletion, secrets rotation, PII.",
}


@dataclass
class Result:
    tier: int
    confidence: float
    source: str
    use_llm: bool


_MODEL_SINGLETON = {}
_TOKENIZER_SINGLETON = {}

CACHE_DIR = Path.home() / ".cache" / "opencode" / "tier-detector-fast"
HF_CACHE_DIR = CACHE_DIR / "hf"

# Keep local classification output quiet/fast in command workflows.
os.environ.setdefault("HF_HUB_DISABLE_PROGRESS_BARS", "1")
os.environ.setdefault("TOKENIZERS_PARALLELISM", "false")
os.environ.setdefault("TRANSFORMERS_VERBOSITY", "error")


DIRECT_COMMAND_PREFIXES = (
    "git ",
    "npm ",
    "pnpm ",
    "yarn ",
    "docker ",
    "pytest",
    "python ",
    "node ",
    "go ",
    "cargo ",
    "make ",
)

DIRECT_COMMAND_PATTERNS = (
    r"^(git\s+)?(pull|fetch|status|rebase|merge)\b",
    r"^(pull|fetch)\b.*\b(main|master|origin/main|origin/master)\b",
    r"^(check|show|list)\b",
)


def normalize(text: str) -> str:
    text = text.lower().strip()
    text = re.sub(r"\s+", " ", text)
    return text


def keyword_match(text: str, keywords: set) -> bool:
    for kw in keywords:
        if kw in text:
            return True
    return False


def direct_command_intent(text: str) -> bool:
    words = text.split()
    if not words or len(words) > 14:
        return False

    if any(text.startswith(prefix) for prefix in DIRECT_COMMAND_PREFIXES):
        return True

    return any(re.match(pattern, text) for pattern in DIRECT_COMMAND_PATTERNS)


def rules_only(text: str) -> Optional[Result]:
    if keyword_match(text, T4_KEYWORDS):
        return Result(tier=4, confidence=0.95, source="rules:t4", use_llm=False)
    if keyword_match(text, T3_KEYWORDS):
        return Result(tier=3, confidence=0.8, source="rules:t3", use_llm=False)
    if direct_command_intent(text):
        return Result(tier=1, confidence=0.99, source="rules:direct-command", use_llm=False)
    return None


def common_heuristics(text: str) -> Optional[Result]:
    words = text.split()

    if len(words) <= 8 and direct_command_intent(text):
        return Result(
            tier=1,
            confidence=0.95,
            source="heuristic:short-command",
            use_llm=False,
        )

    t1_markers = [
        "typo",
        "readme",
        "docs",
        "documentation",
        "comment",
        "spacing",
        "formatting",
        "lint warning",
        "rename variable",
    ]
    if any(m in text for m in t1_markers):
        return Result(tier=1, confidence=0.85, source="heuristic:t1", use_llm=False)

    t2_markers = [
        "2-5 files",
        "two files",
        "three files",
        "helper functions",
        "pagination",
        "feature flag",
        "endpoint test",
        "error messages",
    ]
    if any(m in text for m in t2_markers):
        return Result(tier=2, confidence=0.75, source="heuristic:t2", use_llm=False)

    return None


def _label_hash(labels: List[str]) -> str:
    joined = "\n".join(labels).encode("utf-8")
    return hashlib.sha256(joined).hexdigest()


def _cache_path(model_name: str, labels: List[str]) -> Path:
    safe = re.sub(r"[^a-zA-Z0-9_.-]+", "_", model_name)
    return CACHE_DIR / f"{safe}-{_label_hash(labels)}.json"


def _load_label_cache(path: Path) -> Optional[List[List[float]]]:
    try:
        data = json.loads(path.read_text())
    except Exception:
        return None
    if not isinstance(data, dict) or data.get("version") != 1:
        return None
    vectors = data.get("vectors")
    if not isinstance(vectors, list) or not vectors:
        return None
    return vectors


def _save_label_cache(path: Path, vectors: List[List[float]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    payload = {"version": 1, "vectors": vectors}
    path.write_text(json.dumps(payload))


def _get_tokenizer(model_name: str):
    tok = _TOKENIZER_SINGLETON.get(model_name)
    if tok is None:
        os.environ.setdefault("HF_HOME", str(HF_CACHE_DIR))
        os.environ.setdefault("TRANSFORMERS_CACHE", str(HF_CACHE_DIR))
        from transformers import AutoTokenizer

        tok = AutoTokenizer.from_pretrained(model_name)
        _TOKENIZER_SINGLETON[model_name] = tok
    return tok


def _get_model(model_name: str):
    model = _MODEL_SINGLETON.get(model_name)
    if model is None:
        os.environ.setdefault("HF_HOME", str(HF_CACHE_DIR))
        os.environ.setdefault("TRANSFORMERS_CACHE", str(HF_CACHE_DIR))
        from transformers import AutoModel

        model = AutoModel.from_pretrained(model_name)
        model.eval()
        _MODEL_SINGLETON[model_name] = model
    return model


def embed_similarity(model_name: str, text: str) -> Optional[Result]:
    try:
        import torch
    except Exception:
        return None

    tokenizer = _get_tokenizer(model_name)
    model = _get_model(model_name)

    def embed(texts: List[str]) -> "torch.Tensor":
        inputs = tokenizer(texts, padding=True, truncation=True, return_tensors="pt")
        with torch.no_grad():
            output = model(**inputs)
            last_hidden = output.last_hidden_state
            mask = inputs["attention_mask"].unsqueeze(-1)
            pooled = (last_hidden * mask).sum(dim=1) / mask.sum(dim=1)
            pooled = torch.nn.functional.normalize(pooled, p=2, dim=1)
        return pooled

    labels = [LABEL_PROMPTS[i] for i in sorted(LABEL_PROMPTS.keys())]
    cache_path = _cache_path(model_name, labels)
    cached = _load_label_cache(cache_path)
    if cached is None:
        label_vecs = embed(labels)
        _save_label_cache(cache_path, label_vecs.tolist())
    else:
        label_vecs = torch.tensor(cached, dtype=torch.float32)

    task_vec = embed([text])[0]
    scores = (label_vecs @ task_vec).tolist()

    scored = list(zip(sorted(LABEL_PROMPTS.keys()), scores))
    scored.sort(key=lambda x: x[1], reverse=True)
    top_tier, top_score = scored[0]
    second_score = scored[1][1]
    margin = top_score - second_score

    # Heuristic confidence: stronger when both score and margin are high.
    confidence = max(0.0, min(0.99, (top_score + margin) / 2.0))

    return Result(tier=top_tier, confidence=confidence, source="embed", use_llm=False)


def main() -> int:
    parser = argparse.ArgumentParser(description="Fast tier detection")
    parser.add_argument("--task", help="Task description")
    parser.add_argument("--stdin", action="store_true", help="Read task from stdin")
    parser.add_argument("--model", default="BAAI/bge-small-en-v1.5")
    parser.add_argument("--rules-only", action="store_true")
    parser.add_argument(
        "--max-latency-ms",
        type=int,
        default=1500,
        help="Fallback to rules if embedding pass exceeds this limit",
    )
    parser.add_argument("--format", default="json", choices=["json", "text"])
    args = parser.parse_args()

    if args.stdin:
        task = sys.stdin.read()
    else:
        task = args.task or ""

    try:
        task = normalize(task)
        if not task:
            result = Result(tier=3, confidence=0.0, source="empty", use_llm=False)
        else:
            result = rules_only(task)
            if result is None:
                result = common_heuristics(task)
            if result is None:
                if args.rules_only:
                    result = Result(tier=3, confidence=0.1, source="rules-only", use_llm=False)
                else:
                    started = time.monotonic()
                    with (
                        contextlib.redirect_stdout(io.StringIO()),
                        contextlib.redirect_stderr(io.StringIO()),
                    ):
                        embed = embed_similarity(args.model, task)
                    elapsed_ms = (time.monotonic() - started) * 1000
                    if elapsed_ms > args.max_latency_ms and len(task.split()) <= 12:
                        embed = Result(
                            tier=2,
                            confidence=0.4,
                            source="latency-fallback",
                            use_llm=False,
                        )
                    if embed is None:
                        result = Result(
                            tier=3,
                            confidence=0.1,
                            source="missing-deps",
                            use_llm=False,
                        )
                    else:
                        result = embed
    except Exception:
        # Never block command execution on detector failure.
        result = Result(tier=2, confidence=0.05, source="error-fallback", use_llm=False)

    payload = {
        "tier": result.tier,
        "confidence": round(result.confidence, 3),
        "source": result.source,
        "use_llm": result.use_llm,
    }

    if args.format == "json":
        print(json.dumps(payload))
    else:
        print(
            f"TIER={payload['tier']} CONFIDENCE={payload['confidence']} SOURCE={payload['source']} USE_LLM={payload['use_llm']}"
        )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
