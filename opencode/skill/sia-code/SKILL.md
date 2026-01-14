---
name: sia-code
description: Local-first codebase search with semantic understanding and multi-hop code discovery. Use for architecture analysis, dependency mapping, code research, and finding patterns across unfamiliar codebases. Triggers include "how does X work", "find pattern", "trace dependencies", "code archaeology", "architecture analysis".
license: MIT
compatibility: opencode
---

# Sia-Code Skill

Local-first codebase intelligence with semantic search, multi-hop research, and 12-language AST support.

## Core Concepts

**What is Sia-Code?**
- Single `.mv2` index file containing code chunks and embeddings
- AST-aware chunking for 12 languages (Python, JS/TS, Go, Rust, Java, C/C++, C#, Ruby, PHP)
- Semantic search via OpenAI embeddings (auto-fallback to lexical)
- Multi-hop research for discovering code relationships
- No database, no servers - single portable file

**Index Location:** `.sia-code/index.mv2` (project-local)

## Environment Setup

**OPENAI_API_KEY** is required for semantic search:
```bash
source ~/.config/opencode/scripts/load-mcp-credentials-safe.sh
```

**Without API key:** Searches fallback to lexical/regex mode only.

## Setup (First Use Per Project)

```bash
# Initialize and build index
source ~/.config/opencode/scripts/load-mcp-credentials-safe.sh
uvx --with openai sia-code init
uvx --with openai sia-code index .
```

## Index Staleness Detection

**Check index health:**
```bash
uvx --with openai sia-code status
```

**Output shows:**
```
┃ Property        ┃ Value               ┃
┡━━━━━━━━━━━━━━━━━╇━━━━━━━━━━━━━━━━━━━━━┩
│ Valid Chunks    │ 1,043               │
│ Stale Chunks    │ 401                 │
│ Staleness Ratio │ 27.8%               │
│ Health Status   │ 🟠 Degraded         │
```

**When to update index:**

| Condition | Action |
|-----------|--------|
| `Health Status: 🟢 Healthy` | No action needed |
| `Health Status: 🟠 Degraded` (>20% stale) | Run `sia-code index --update` |
| After `git pull` with many changes | Run `sia-code index --update` |
| After major refactoring | Run `sia-code index --clean` |
| `Health Status: 🔴 Critical` | Run `sia-code index --clean` |

**Update commands:**
```bash
# Incremental update (fast, changed files only)
uvx --with openai sia-code index --update

# Full rebuild (slow, from scratch)
uvx --with openai sia-code index --clean

# Remove stale chunks
uvx --with openai sia-code compact
```

## Common Operations

### 1. Semantic Search

```bash
uvx --with openai sia-code search "authentication logic"
```

### 2. Regex Search

```bash
uvx --with openai sia-code search --regex "def.*login"
```

### 3. Multi-Hop Research

```bash
uvx --with openai sia-code research "how does the API handle errors?"
```

Shows code relationships, call graphs, and entity connections.

### 4. Interactive Mode

```bash
uvx --with openai sia-code interactive
```

Live search with result navigation and export.

### 5. Watch Mode (Auto-Reindex)

```bash
uvx --with openai sia-code index --watch
```

## Output Formats

```bash
# JSON output (for parsing)
uvx --with openai sia-code search "query" --format json

# Rich table (default)
uvx --with openai sia-code search "query" --format table

# CSV (for Excel)
uvx --with openai sia-code search "query" --format csv

# Save to file
uvx --with openai sia-code search "query" --output results.json
```

## Supported Languages

**Full AST Support (12):** Python, JavaScript, TypeScript, JSX, TSX, Go, Rust, Java, C, C++, C#, Ruby, PHP

**Recognized but indexed as text:** Kotlin, Groovy, Swift, Bash, Vue, Svelte

**Not indexed:** Markdown, YAML, JSON, etc. (use grep/ripgrep for these)

## Workflow Integration

### At Task Start (AGENTS.md Pattern)

```bash
# Check if index exists and is healthy
uvx --with openai sia-code status

# If not initialized or degraded:
uvx --with openai sia-code init  # only if not initialized
uvx --with openai sia-code index --update
```

### During Code Exploration

```bash
# Find where feature is implemented
uvx --with openai sia-code research "how does authentication work?"

# Find all usages of a pattern
uvx --with openai sia-code search --regex "class.*Handler"

# Semantic search for concepts
uvx --with openai sia-code search "error handling middleware"
```

### Two-Strike Rule Integration

After 2 failed fixes:
```bash
uvx --with openai sia-code research "trace the error flow from [component]"
```

## Quick Reference

| Task | Command |
|------|---------|
| Initialize | `uvx --with openai sia-code init` |
| Index codebase | `uvx --with openai sia-code index .` |
| Update index | `uvx --with openai sia-code index --update` |
| Full rebuild | `uvx --with openai sia-code index --clean` |
| Check health | `uvx --with openai sia-code status` |
| Semantic search | `uvx --with openai sia-code search "query"` |
| Regex search | `uvx --with openai sia-code search --regex "pattern"` |
| Multi-hop research | `uvx --with openai sia-code research "question"` |
| Interactive mode | `uvx --with openai sia-code interactive` |
| Clean stale chunks | `uvx --with openai sia-code compact` |
| View config | `uvx --with openai sia-code config show` |

## Troubleshooting

### Common Issues

**Error: openai package not found**
- Cause: Using `uvx sia-code` without `--with openai`
- Solution: Use `uvx --with openai sia-code`

**Error: Sia Code not initialized**
- Cause: No `.sia-code` directory in project
- Solution: Run `uvx --with openai sia-code init`

**Search returns unrelated results**
- Cause: Index is stale
- Solution: Run `uvx --with openai sia-code index --update`

**Indexing is slow**
- Cause: Large codebase or many files
- Solution: Add exclusions to `.sia-code/config.json`

**No results for markdown/config files**
- Cause: Sia-code only indexes code files (by design)
- Solution: Use `grep` or `rg` for text files

## Configuration

Edit `.sia-code/config.json`:

```json
{
  "embedding": {
    "enabled": true,
    "provider": "openai",
    "model": "openai-small"
  },
  "indexing": {
    "exclude_patterns": ["node_modules/", "__pycache__/", ".git/"]
  }
}
```

## Notes

- **Portable:** `.sia-code/index.mv2` can be committed or shared
- **API costs:** OpenAI embeddings incur API costs; use lexical search for cost savings
- **Index location:** Always project-local (not global)
- **Markdown not indexed:** Use grep/ripgrep for documentation files
