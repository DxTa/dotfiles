#!/usr/bin/env bash
set -euo pipefail

if ! command -v git >/dev/null 2>&1; then
  exit 0
fi

if git rev-parse --verify HEAD >/dev/null 2>&1; then
  base=HEAD
else
  base=4b825dc642cb6eb9a060e54bf8d69288fbee4904
fi

scan_output="$(git diff --cached -U0 "$base" -- . || true)"

if [ -z "$scan_output" ]; then
  exit 0
fi

deny_patterns=(
  'OPENAI_API_KEY=sk-(?!proj-)[A-Za-z0-9_-]{20,}'
  'OPENAI_API_KEY=sk-proj-[A-Za-z0-9_-]{20,}'
  'GITHUB_TOKEN=ghp_[A-Za-z0-9]+'
  'CR_PAT=ghp_[A-Za-z0-9]+'
  'AKIA[0-9A-Z]{16}'
  'AWS_SECRET_ACCESS_KEY=[A-Za-z0-9/+=]+'
  'STRIPE_API_KEY=sk_live_[A-Za-z0-9]+'
  'GEMINI_API_KEY=AIzaSy[A-Za-z0-9_-]+'
  'GCP_SA_KEY=eyJ[0-9A-Za-z_-]+'
  'BEGIN( RSA| EC| OPENSSH)? PRIVATE KEY'
)

for pattern in "${deny_patterns[@]}"; do
  if command -v rg >/dev/null 2>&1; then
    if printf "%s" "$scan_output" | rg -n --pcre2 "$pattern" >/dev/null 2>&1; then
      echo "Secret scan blocked the commit." >&2
      echo "Matched pattern: $pattern" >&2
      echo "If this is a false positive, remove or redact the secret and try again." >&2
      exit 1
    fi
  else
    if printf "%s" "$scan_output" | grep -n -E "$pattern" >/dev/null 2>&1; then
      echo "Secret scan blocked the commit." >&2
      echo "Matched pattern: $pattern" >&2
      echo "If this is a false positive, remove or redact the secret and try again." >&2
      exit 1
    fi
  fi
done

exit 0
