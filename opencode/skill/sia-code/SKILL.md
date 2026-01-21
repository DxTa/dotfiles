---
name: sia-code
description: Local-first codebase search with semantic understanding and multi-hop code discovery. Use for architecture analysis, dependency mapping, code research, and finding patterns across unfamiliar codebases. Triggers include "how does X work", "find pattern", "trace dependencies", "code archaeology", "architecture analysis".
license: MIT
compatibility: opencode
version: 0.3.0
---

# Sia-Code Skill

Local-first codebase intelligence with semantic search, multi-hop research, and 12-language AST support.

**Version:** 0.3.0

## Core Concepts

**What is Sia-Code?**
- Single `.mv2` index file containing code chunks and embeddings
- AST-aware chunking for 12 languages (Python, JS/TS, Go, Rust, Java, C/C++, C#, Ruby, PHP)
- Semantic search via OpenAI embeddings (auto-fallback to lexical)
- Multi-hop research for discovering code relationships
- Dependency-aware filtering (exclude or focus on vendored code)
- No database, no servers - single portable file

**Index Location:** `.sia-code/index.mv2` (project-local)

## Environment Setup

**OPENAI_API_KEY** is required for semantic search:
```bash
source ~/.config/opencode/scripts/load-mcp-credentials-safe.sh
```

**Without API key:** Searches fallback to lexical/regex mode only.

## Quick Start

```bash
# Load credentials
source ~/.config/opencode/scripts/load-mcp-credentials-safe.sh

# Initialize and build index
uvx --with openai sia-code init
uvx --with openai sia-code index .

# Preview first (optional)
uvx --with openai sia-code init --dry-run
```

## Indexing

### Basic Indexing

```bash
# Index current directory
uvx --with openai sia-code index .
```

### Incremental Update

```bash
# Re-index changed files only (fast)
uvx --with openai sia-code index --update
```

### Full Rebuild

```bash
# Delete existing index and rebuild from scratch
uvx --with openai sia-code index --clean
```

### Parallel Indexing

For large codebases (100+ files), parallel indexing significantly speeds up initial indexing:

```bash
# Enable parallel processing
uvx --with openai sia-code index . --parallel

# Control worker count (default: CPU count)
uvx --with openai sia-code index . --parallel --workers 4
```

**When to use parallel:**
- Initial indexing of 100+ files
- Large monorepos
- After major refactoring requiring full rebuild

## Index Health & Maintenance

### Check Status

```bash
uvx --with openai sia-code status
```

**Output example:**
```
┃ Property        ┃ Value               ┃
┡━━━━━━━━━━━━━━━━━╇━━━━━━━━━━━━━━━━━━━━━┩
│ Valid Chunks    │ 1,043               │
│ Stale Chunks    │ 401                 │
│ Staleness Ratio │ 27.8%               │
│ Health Status   │ 🟠 Degraded         │
```

### When to Maintain Index

| Condition | Action |
|-----------|--------|
| `Health Status: 🟢 Healthy` | No action needed |
| `Health Status: 🟠 Degraded` (>20% stale) | Run `sia-code index --update` or `compact` |
| After `git pull` with many changes | Run `sia-code index --update` |
| After major refactoring | Run `sia-code index --clean` |
| `Health Status: 🔴 Critical` | Run `sia-code index --clean` |

### Compaction

Remove stale chunks to improve search quality and reduce index size:

```bash
# Compact if >20% stale (default threshold)
uvx --with openai sia-code compact

# Compact only if >30% stale
uvx --with openai sia-code compact --threshold 0.3

# Force compaction regardless of threshold
uvx --with openai sia-code compact --force
```

## Searching

### Semantic Search

Find code by meaning, not just keywords:

```bash
uvx --with openai sia-code search "authentication logic"
uvx --with openai sia-code search "error handling middleware"
```

### Regex Search

Pattern-based lexical search:

```bash
uvx --with openai sia-code search --regex "def.*login"
uvx --with openai sia-code search --regex "class.*Handler"
```

### Limiting Results

```bash
# Return specific number of results
uvx --with openai sia-code search "query" -k 20
uvx --with openai sia-code search "query" --limit 20
```

### Dependency Filtering

Control whether results include dependency/vendored code (node_modules, vendor, etc.):

```bash
# Search YOUR project code only (exclude dependencies)
uvx --with openai sia-code search "authentication" --no-deps

# Search ONLY dependencies (for debugging library behavior)
uvx --with openai sia-code search "jwt verify" --deps-only

# Include stale chunks in results (for code archaeology)
uvx --with openai sia-code search "deleted function" --no-filter
```

**When to use each:**

| Flag | Use Case |
|------|----------|
| `--no-deps` | Focus on your code; debugging project-specific logic; cleaner architecture review |
| `--deps-only` | Debug library behavior; understand how a dependency works; audit vendored code |
| `--no-filter` | Find recently deleted code; code archaeology; historical investigation |

### Output Formats

```bash
# Plain text (default)
uvx --with openai sia-code search "query"

# JSON output (for parsing/automation)
uvx --with openai sia-code search "query" --format json

# Rich table
uvx --with openai sia-code search "query" --format table

# CSV (for spreadsheets)
uvx --with openai sia-code search "query" --format csv

# Save to file
uvx --with openai sia-code search "query" --output results.json
```

## Multi-Hop Research

Automatically discover code relationships and build a complete picture:

### Basic Research

```bash
uvx --with openai sia-code research "how does the API handle errors?"
uvx --with openai sia-code research "what is the authentication flow?"
```

### Controlling Depth

Control how deep the relationship traversal goes:

```bash
# Shallow search (faster, 2 hops default)
uvx --with openai sia-code research "how does login work?"

# Deep architecture trace (3+ hops)
uvx --with openai sia-code research "how does auth middleware work?" --hops 3

# Control results per hop
uvx --with openai sia-code research "error flow" --limit 10
```

### Call Graph Visualization

See what functions call what:

```bash
uvx --with openai sia-code research "what calls the indexer?" --graph
```

### Research Filtering

```bash
# Exclude dependencies from research
uvx --with openai sia-code research "auth flow" --no-filter
```

## Interactive Mode

Live search with result navigation:

```bash
# Semantic interactive search
uvx --with openai sia-code interactive

# Regex interactive search
uvx --with openai sia-code interactive --regex

# Limit results per query
uvx --with openai sia-code interactive -k 15
```

**Features:**
- Live search as you type
- Navigate results with arrow keys
- Preview code chunks
- Export results to file
- Press `Ctrl+C` or `Ctrl+D` to exit

## Configuration

### View Configuration

```bash
# Show current configuration
uvx --with openai sia-code config show

# Show config file path
uvx --with openai sia-code config path
```

### Edit Configuration

```bash
# Open in $EDITOR
uvx --with openai sia-code config edit
```

### Configuration File

Located at `.sia-code/config.json`:

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

# Find project-only patterns (exclude dependencies)
uvx --with openai sia-code search "class.*Handler" --regex --no-deps

# Semantic search for concepts
uvx --with openai sia-code search "error handling middleware"
```

### Two-Strike Rule Integration

After 2 failed fixes:
```bash
uvx --with openai sia-code research "trace the error flow from [component]" --hops 3
```

## Quick Reference

| Task | Command |
|------|---------|
| **Setup** | |
| Initialize | `sia-code init` |
| Initialize (preview) | `sia-code init --dry-run` |
| Index codebase | `sia-code index .` |
| Index (parallel) | `sia-code index . --parallel` |
| **Maintenance** | |
| Update index | `sia-code index --update` |
| Full rebuild | `sia-code index --clean` |
| Check health | `sia-code status` |
| Compact index | `sia-code compact` |
| **Search** | |
| Semantic search | `sia-code search "query"` |
| Regex search | `sia-code search --regex "pattern"` |
| Project code only | `sia-code search "query" --no-deps` |
| **Research** | |
| Multi-hop research | `sia-code research "question"` |
| Deep trace | `sia-code research "question" --hops 3` |
| Call graph | `sia-code research "question" --graph` |
| **Other** | |
| Interactive mode | `sia-code interactive` |
| Watch mode | `sia-code index --watch` |

**Note:** All commands assume `uvx --with openai` prefix.

## Supported Languages

**Full AST Support (12):** Python, JavaScript, TypeScript, JSX, TSX, Go, Rust, Java, C, C++, C#, Ruby, PHP

**Recognized but indexed as text:** Kotlin, Groovy, Swift, Bash, Vue, Svelte

**Not indexed:** Markdown, YAML, JSON, etc. (use grep/ripgrep for these)

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
- Solution: Run `uvx --with openai sia-code index --update` or `compact`

**Too many dependency results**
- Cause: Search includes node_modules/vendor code
- Solution: Use `--no-deps` flag

**Indexing is slow**
- Cause: Large codebase or many files
- Solution: Use `--parallel` flag, or add exclusions to config

**No results for markdown/config files**
- Cause: Sia-code only indexes code files (by design)
- Solution: Use `grep` or `rg` for text files

## Notes

- **Portable:** `.sia-code/index.mv2` can be committed or shared
- **API costs:** OpenAI embeddings incur API costs; use lexical search for cost savings
- **Index location:** Always project-local (not global)
- **Markdown not indexed:** Use grep/ripgrep for documentation files
