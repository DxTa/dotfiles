---
name: sia-code
description: Local-first codebase search with lexical-first BM25 (89.9% Recall@5), multi-hop research, and built-in project memory. Use for architecture analysis, dependency mapping, code research, and finding patterns across unfamiliar codebases. Triggers include "how does X work", "find pattern", "trace dependencies", "code archaeology", "architecture analysis".
license: MIT
compatibility: opencode
version: 0.5.0
---

# Sia-Code Skill

Local-first codebase intelligence with lexical-first search, multi-hop research, built-in project memory, and 12-language AST support.

**Version:** 0.5.0

## Core Concepts

**What is Sia-Code?**
- `.sia-code/` directory containing index, config, and cache
- **Lexical-first search:** BM25 + FTS5 achieves 89.9% Recall@5 (outperforms hybrid!)
- AST-aware chunking for 12 languages (Python, JS/TS, Go, Rust, Java, C/C++, C#, Ruby, PHP)
- **Built-in project memory:** Timeline events, changelogs, technical decisions
- Optional semantic search via embeddings (requires API key)
- Multi-hop research for discovering code relationships
- Dependency-aware filtering (exclude or focus on vendored code)
- Portable index (17-25 MB per repo, 2x smaller than v0.3)

**Index Structure:**
```
.sia-code/
├── config.json       # Configuration
├── vectors.usearch   # HNSW vector index (optional)
├── index.db          # SQLite FTS5 (BM25 lexical search)
└── cache/            # Embedding cache
```

## Environment Setup

**OPENAI_API_KEY** is OPTIONAL (only needed for semantic/hybrid search):
```bash
source ~/.config/opencode/scripts/load-mcp-credentials-safe.sh
```

**Without API key:** Lexical search works perfectly (recommended approach, 89.9% Recall@5).

## Quick Start

```bash
# Initialize and build index
uvx sia-code init
uvx sia-code index .

# Search (lexical-only, RECOMMENDED)
uvx sia-code search --regex "def.*authenticate"

# Search (hybrid, requires OPENAI_API_KEY)
uvx sia-code search "authentication logic"

# Multi-hop research
uvx sia-code research "how does the API handle errors?"

# Check index health
uvx sia-code status
```

## Indexing

### Basic Indexing

```bash
# Index current directory
uvx sia-code index .
```

### Incremental Update

```bash
# Re-index changed files only (fast)
uvx sia-code index --update
```

### Full Rebuild

```bash
# Delete existing index and rebuild from scratch
uvx sia-code index --clean
```

### Skip Git Sync

```bash
# Index without syncing git history (faster for quick updates)
uvx sia-code index . --no-git-sync
```

### Parallel Indexing

For large codebases (100+ files), parallel indexing significantly speeds up initial indexing:

```bash
# Enable parallel processing
uvx sia-code index . --parallel

# Control worker count (default: CPU count)
uvx sia-code index . --parallel --workers 4
```

**When to use parallel:**
- Initial indexing of 100+ files
- Large monorepos
- After major refactoring requiring full rebuild

### Watch Mode

Auto-reindex on file changes:

```bash
# Start watch mode (auto-reindex on changes)
uvx sia-code index --watch

# Custom debounce delay (default: 2 seconds)
uvx sia-code index --watch --debounce 3.0
```

## Index Health & Maintenance

### Check Status

```bash
uvx sia-code status
```

**Output example:**
```
┃ Property        ┃ Value               ┃
┡━━━━━━━━━━━━━━━━━╇━━━━━━━━━━━━━━━━━━━━━┩
│ Valid Chunks    │ 7,378               │
│ Stale Chunks    │ 200                 │
│ Staleness Ratio │ 2.6%                │
│ Health Status   │ 🟢 Healthy          │
```

### When to Maintain Index

| Condition | Action |
|-----------|--------|
| `Health Status: 🟢 Healthy` | No action needed |
| `Health Status: 🟡 Degraded` (10-20% stale) | Run `uvx sia-code index --update` or `compact` |
| `Health Status: 🔴 Critical` (>20% stale) | Run `uvx sia-code index --clean` |
| After `git pull` with many changes | Run `uvx sia-code index --update` |
| After major refactoring | Run `uvx sia-code index --clean` |

### Compaction

Remove stale chunks to improve search quality and reduce index size:

```bash
# Compact if >20% stale (default threshold)
uvx sia-code compact

# Compact only if >30% stale
uvx sia-code compact --threshold 0.3

# Force compaction regardless of threshold
uvx sia-code compact --force
```

## Searching

**Recommendation:** Use lexical-only search (`--regex`) for best performance (89.9% Recall@5 on RepoEval benchmark).

### Lexical Search (RECOMMENDED)

Pattern-based search using BM25 + FTS5:

```bash
uvx sia-code search --regex "def.*login"
uvx sia-code search --regex "class.*Handler"
uvx sia-code search --regex "authenticate"
```

**Why lexical-first?**
- 89.9% Recall@5 (vs 89.1% hybrid, 78.0% semantic-only)
- Works without API key
- Faster queries (~60ms vs ~80ms)
- Code has precise identifiers that benefit from exact matching

### Hybrid Search (Default)

Combines BM25 lexical + semantic vector search:

```bash
uvx sia-code search "authentication logic"
uvx sia-code search "error handling middleware"
```

**Note:** Requires OPENAI_API_KEY. Lexical-only (`--regex`) recommended instead.

### Semantic-Only Search

Vector similarity search only (not recommended for code):

```bash
uvx sia-code search --semantic-only "handle user login"
```

### Limiting Results

```bash
# Return specific number of results
uvx sia-code search "query" -k 20
uvx sia-code search "query" --limit 20
```

### Dependency Filtering

Control whether results include dependency/vendored code (node_modules, vendor, etc.):

```bash
# Search YOUR project code only (exclude dependencies)
uvx sia-code search "authentication" --no-deps

# Search ONLY dependencies (for debugging library behavior)
uvx sia-code search "jwt verify" --deps-only

# Include stale chunks in results (for code archaeology)
uvx sia-code search "deleted function" --no-filter
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
uvx sia-code search "query"

# JSON output (for parsing/automation)
uvx sia-code search "query" --format json

# Rich table
uvx sia-code search "query" --format table

# CSV (for spreadsheets)
uvx sia-code search "query" --format csv

# Save to file
uvx sia-code search "query" --output results.json
```

## Multi-Hop Research

Automatically discover code relationships and build a complete picture:

### Basic Research

```bash
uvx sia-code research "how does the API handle errors?"
uvx sia-code research "what is the authentication flow?"
```

### Controlling Depth

Control how deep the relationship traversal goes:

```bash
# Shallow search (faster, 2 hops default)
uvx sia-code research "how does login work?"

# Deep architecture trace (3+ hops)
uvx sia-code research "how does auth middleware work?" --hops 3

# Control results per hop
uvx sia-code research "error flow" --limit 10
```

### Call Graph Visualization

See what functions call what:

```bash
uvx sia-code research "what calls the indexer?" --graph
```

### Research Filtering

```bash
# Exclude dependencies from research
uvx sia-code research "auth flow" --no-filter
```

## Project Memory

**New in 0.4.0:** Built-in project memory for storing learnings, decisions, and tracking timeline events.

### Search Past Learnings

Search through stored decisions and timeline events:

```bash
uvx sia-code memory search "authentication"
uvx sia-code memory search "database migration"
```

### Store New Learning

Add decisions, procedures, or facts to project memory:

```bash
# Store a procedure
uvx sia-code memory add-decision "Procedure: Always run tests before deploying"

# Store a fact
uvx sia-code memory add-decision "Fact: Module Y requires config Z to be set"

# Store a technical decision
uvx sia-code memory add-decision "Migrate from REST to GraphQL API"
```

### View Timeline & Decisions

```bash
# List timeline events (from git commits)
uvx sia-code memory list --type timeline

# List stored decisions
uvx sia-code memory list --type decision

# List changelogs (from git tags)
uvx sia-code memory list --type changelog

# Limit number of items shown
uvx sia-code memory list --type timeline --limit 20

# Filter decisions by status
uvx sia-code memory list --type decision --status pending
```

### View Timeline (Dedicated Command)

New in 0.5.0 - dedicated timeline viewing with filtering:

```bash
# Show recent timeline
uvx sia-code memory timeline

# Filter by date
uvx sia-code memory timeline --since 2024-01-01

# Filter by event type
uvx sia-code memory timeline --event-type merge
uvx sia-code memory timeline --event-type tag
uvx sia-code memory timeline --event-type major_change

# Filter by importance
uvx sia-code memory timeline --importance high

# Output formats
uvx sia-code memory timeline --format markdown
uvx sia-code memory timeline --format json
```

### Sync from Git

Import timeline events and changelogs from git history:

```bash
# Sync all git history
uvx sia-code memory sync-git

# Sync last 100 events
uvx sia-code memory sync-git --limit 100

# Sync events after specific date
uvx sia-code memory sync-git --since "2024-01-01"
```

### Decision Workflow

Track and approve/reject technical decisions:

```bash
# Add a pending decision
uvx sia-code memory add-decision "Migrate to GraphQL"

# Approve decision (ID shown in list output)
uvx sia-code memory approve 1

# Reject decision
uvx sia-code memory reject 2
```

### Generate Changelog

Generate changelog from stored memory:

```bash
# Generate markdown changelog
uvx sia-code memory changelog --format markdown

# Export to file
uvx sia-code memory changelog --format markdown -o CHANGELOG.md

# Specific tag range
uvx sia-code memory changelog v1.0.0..v2.0.0
```

### Export/Import Memory

Backup or share project memory:

```bash
# Export to JSON
uvx sia-code memory export memory-backup.json

# Import from JSON
uvx sia-code memory import memory-backup.json
```

## Interactive Mode

Live search with result navigation:

```bash
# Hybrid interactive search
uvx sia-code interactive

# Lexical-only interactive search
uvx sia-code interactive --regex

# Limit results per query
uvx sia-code interactive -k 15
```

**Features:**
- Live search as you type
- Navigate results with arrow keys
- Preview code chunks
- Export results to file
- Press `Ctrl+C` or `Ctrl+D` to exit

## Embedding Server (New in 0.5.0)

Share embedding models across multiple repos to save memory and improve startup time.

### Start Server

```bash
# Start daemon (backgrounds automatically)
uvx sia-code embed start

# Run in foreground (for debugging)
uvx sia-code embed start --foreground

# Custom idle timeout (default: 1 hour)
uvx sia-code embed start --idle-timeout 7200  # 2 hours
```

**Auto-starts on demand:** The daemon loads embedding models only when needed and shares them across all sia-code sessions, reducing memory usage and startup time.

**Auto-unload:** Models are automatically unloaded after idle timeout (default: 1 hour) to save memory, and reloaded on next request.

### Check Status

```bash
uvx sia-code embed status
```

### Stop Server

```bash
uvx sia-code embed stop
```

**When to use:**
- Multi-repo workflows (reduces memory from loading model per-repo)
- Frequent switching between projects
- CI/CD pipelines with multiple repos
- **Required for hybrid/semantic search** (lexical `--regex` search works without daemon)

## Configuration

### View Configuration

```bash
# Show current configuration
uvx sia-code config show

# Get specific value
uvx sia-code config get search.vector_weight
```

### Set Configuration

```bash
# Set value
uvx sia-code config set search.vector_weight 0.0
uvx sia-code config set chunking.max_chunk_size 1500
uvx sia-code config set embedding.enabled false
```

### Configuration File

Located at `.sia-code/config.json`:

```json
{
  "embedding": {
    "enabled": true,
    "model": "BAAI/bge-small-en-v1.5",
    "dimensions": 384
  },
  "search": {
    "vector_weight": 0.0,
    "default_limit": 10,
    "include_dependencies": true
  },
  "chunking": {
    "max_chunk_size": 1200,
    "min_chunk_size": 50,
    "merge_threshold": 0.8,
    "greedy_merge": true
  },
  "indexing": {
    "max_file_size_mb": 5,
    "exclude_patterns": [
      "node_modules/",
      "__pycache__/",
      ".git/",
      "venv/"
    ]
  },
  "summarization": {
    "enabled": false,
    "model": "google/flan-t5-base",
    "max_commits": 20
  }
}
```

**Key Settings:**

- `search.vector_weight`: 0.0 = lexical-only (RECOMMENDED!), 0.5 = hybrid, 1.0 = semantic-only
- `embedding.enabled`: Set to `false` to disable embeddings entirely (saves API costs)
- `chunking.max_chunk_size`: Maximum characters per chunk (default: 1200)
- `indexing.exclude_patterns`: Directories/files to exclude from indexing

## Workflow Integration

### At Task Start (AGENTS.md Pattern)

```bash
# Check if index exists and is healthy
uvx sia-code status

# If not initialized:
uvx sia-code init
uvx sia-code index .

# If degraded (>10% stale):
uvx sia-code index --update

# Search past learnings
uvx sia-code memory search "[task description]"
```

### During Code Exploration

```bash
# Find where feature is implemented
uvx sia-code research "how does authentication work?"

# Find project-only patterns (exclude dependencies)
uvx sia-code search --regex "class.*Handler" --no-deps

# Lexical search for exact matches
uvx sia-code search --regex "def authenticate"
```

### Two-Strike Rule Integration

After 2 failed fixes:
```bash
uvx sia-code research "trace the error flow from [component]" --hops 3
```

Store the root cause:
```bash
uvx sia-code memory add-decision "Root cause: [description] - Fix: [solution]"
```

## Quick Reference

| Task | Command |
|------|---------|
| **Setup** | |
| Initialize | `uvx sia-code init` |
| Initialize (preview) | `uvx sia-code init --dry-run` |
| Index codebase | `uvx sia-code index .` |
| Index (parallel) | `uvx sia-code index . --parallel` |
| **Maintenance** | |
| Update index | `uvx sia-code index --update` |
| Full rebuild | `uvx sia-code index --clean` |
| Index (no git sync) | `uvx sia-code index . --no-git-sync` |
| Watch mode | `uvx sia-code index --watch` |
| Check health | `uvx sia-code status` |
| Compact index | `uvx sia-code compact` |
| **Search** | |
| Lexical search (RECOMMENDED) | `uvx sia-code search --regex "pattern"` |
| Hybrid search | `uvx sia-code search "query"` |
| Semantic search | `uvx sia-code search --semantic-only "query"` |
| Project code only | `uvx sia-code search "query" --no-deps` |
| Dependencies only | `uvx sia-code search "query" --deps-only` |
| JSON output | `uvx sia-code search "query" --format json` |
| **Research** | |
| Multi-hop research | `uvx sia-code research "question"` |
| Deep trace | `uvx sia-code research "question" --hops 3` |
| Call graph | `uvx sia-code research "question" --graph` |
| **Memory** | |
| Search past learnings | `uvx sia-code memory search "query"` |
| Store decision/learning | `uvx sia-code memory add-decision "..."` |
| View timeline | `uvx sia-code memory timeline` |
| List timeline events | `uvx sia-code memory list --type timeline` |
| List decisions | `uvx sia-code memory list --type decision` |
| Sync from git | `uvx sia-code memory sync-git` |
| Generate changelog | `uvx sia-code memory changelog --format markdown` |
| **Embedding** | |
| Start embed server | `uvx sia-code embed start` |
| Check embed status | `uvx sia-code embed status` |
| Stop embed server | `uvx sia-code embed stop` |
| **Configuration** | |
| Show config | `uvx sia-code config show` |
| Get value | `uvx sia-code config get KEY` |
| Set value | `uvx sia-code config set KEY VALUE` |
| **Other** | |
| Interactive mode | `uvx sia-code interactive` |
| Interactive (lexical) | `uvx sia-code interactive --regex` |

## Supported Languages

**Full AST Support (12):** Python, JavaScript, TypeScript, JSX, TSX, Go, Rust, Java, C, C++, C#, Ruby, PHP

**Recognized but indexed as text:** Kotlin, Groovy, Swift, Bash, Vue, Svelte

**Not indexed:** Markdown, YAML, JSON, etc. (use grep/ripgrep for these)

## Troubleshooting

### Common Issues

**Error: Sia Code not initialized**
- Cause: No `.sia-code` directory in project
- Solution: Run `uvx sia-code init`

**Search returns unrelated results**
- Cause: Index is stale (>10% degraded)
- Solution: Run `uvx sia-code index --update` or `uvx sia-code compact`

**Too many dependency results**
- Cause: Search includes node_modules/vendor code
- Solution: Use `--no-deps` flag

**Indexing is slow**
- Cause: Large codebase or many files
- Solution: Use `--parallel` flag, or add exclusions to config

**No results for markdown/config files**
- Cause: Sia-code only indexes code files (by design)
- Solution: Use `grep` or `rg` for text files

**No API key warning (during hybrid search)**
- This is normal - lexical search still works without API key
- Use `--regex` flag for pure lexical search (recommended)

### Performance Notes

**Index Size:** 17-25 MB per repo (2x smaller than v0.3)
**Query Speed:** ~60ms lexical, ~80ms hybrid
**Benchmark:** 89.9% Recall@5 on RepoEval (1,600 queries, 8 repositories)

## Notes

- **Portable:** `.sia-code/` directory can be committed or shared
- **API costs:** Lexical search is FREE (no API calls); hybrid/semantic requires OpenAI API key
- **Index location:** Always project-local (not global)
- **Lexical-first philosophy:** BM25 outperforms hybrid for code search (+0.8 percentage points)
- **Memory is git-centric:** Timeline events come from commits, changelogs from tags
