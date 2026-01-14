---
name: memvid
description: Single-file AI memory with memvid-cli for persistent knowledge storage and retrieval using text-embedding-3-large (3072 dimensions). Use when storing learnings, searching past context, managing session memory, or implementing long-term memory for AI agents. Triggers include "remember", "recall", "search memory", "store this", "what did we learn", or any task requiring persistent memory across sessions.
license: MIT
compatibility: opencode
---

# Memvid Memory Skill

Organized interface for memvid-cli - single-file AI memory with hybrid search, entity extraction, and persistent storage.

## Core Concepts

**What is Memvid?**
- Single `.mv2` file containing all data, indexes, and embeddings
- No database, no servers, no cloud dependencies
- Git-friendly (can commit, scp, share the file)
- Hybrid search: BM25 lexical + vector similarity
- Entity extraction via Memory Cards (O(1) lookups)

**Memory File Location:**
`~/.config/opencode/memory.mv2`

**Embedding Model:**
text-embedding-3-large (3072 dimensions) via `-m openai-large`

## Environment Setup

**OPENAI_API_KEY** is automatically loaded from `.mcp-credentials.json` via:
```bash
source ~/.config/opencode/scripts/load-mcp-credentials-safe.sh
```

This happens automatically in OpenCode workflows.

## Common Operations

### 1. Search Memory

**Semantic Search (uses embeddings):**
```bash
memvid find ~/.config/opencode/memory.mv2 --query "your search query" --mode sem --top-k 10 -m openai-large
```

**Lexical Search (keyword-based, fast):**
```bash
memvid find ~/.config/opencode/memory.mv2 --query "exact keywords" --mode lex --top-k 10
```

**Auto Mode (automatic selection):**
```bash
memvid find ~/.config/opencode/memory.mv2 --query "your query" --mode auto --top-k 10
```

**Search Modes:**
- `--mode sem`: Vector/semantic search (meaning-based)
- `--mode lex`: BM25 lexical search (keyword-based)
- `--mode auto`: Automatic selection

### 2. Store Memory

**With Embeddings (recommended):**
```bash
echo '{"title":"Topic Name","label":"procedure","text":"Full description of what was learned"}' | memvid put ~/.config/opencode/memory.mv2 --embedding -m openai-large
```

**Quick Text (with label):**
```bash
echo "Key insight about topic" | memvid put ~/.config/opencode/memory.mv2 --label fact --embedding -m openai-large
```

**From File:**
```bash
memvid put ~/.config/opencode/memory.mv2 --input document.pdf --embedding -m openai-large
```

**Labels (use Graphiti convention):**
- `procedure`: Workflows and multi-step processes
- `preference`: Coding patterns and preferences
- `fact`: Key insights, gotchas, important details

### 3. Entity State Lookup

Check entity state (O(1) lookup via Memory Cards):
```bash
memvid state ~/.config/opencode/memory.mv2 "EntityName"
```

Returns structured facts about the entity (employer, role, relationships, etc.).

### 4. Check Statistics

```bash
memvid stats ~/.config/opencode/memory.mv2
```

Shows:
- Frame count
- Storage usage
- Embedding dimensions
- Index status
- Quality metrics

### 5. Ask Questions (LLM-powered Q&A)

```bash
memvid ask ~/.config/opencode/memory.mv2 --question "What did we decide about authentication?" --use-model openai
```

Returns sourced answers with citations.

### 6. Timeline and History

```bash
memvid timeline ~/.config/opencode/memory.mv2
```

View chronological history of stored memories.

## Workflow Integration

### At Task Start (AGENTS.md Pattern)

Search for relevant context:
```bash
source ~/.config/opencode/scripts/load-mcp-credentials-safe.sh
memvid find ~/.config/opencode/memory.mv2 --query "[task description]" --mode sem --top-k 10 -m openai-large
```

### At Task End (AGENTS.md Pattern)

Store learnings:
```bash
source ~/.config/opencode/scripts/load-mcp-credentials-safe.sh
echo '{"title":"[Topic]","label":"procedure","text":"[What was learned]"}' | memvid put ~/.config/opencode/memory.mv2 --embedding -m openai-large
```

### Two-Strike Rule Integration

After 2 failed fixes, search for similar past issues:
```bash
memvid find ~/.config/opencode/memory.mv2 --query "error debugging failed fix" --mode sem --top-k 5 -m openai-large
```

## Storage Guidelines

**When to Store:**
- Solution differed from initial approach
- Debugging revealed non-obvious cause
- Pattern discovered that should be reused
- Decision made with important context

**When to Skip:**
- Behavior matched documentation/expectation
- Trivial or well-known information
- Temporary or session-specific data

**Storage Optimization:**
```bash
# Vector compression (16x storage savings)
memvid put ~/.config/opencode/memory.mv2 --input file.pdf --embedding --vector-compression -m openai-large
```

## Advanced Features

### Enrichment (Entity Extraction)

```bash
# Extract entities and relationships
memvid enrich ~/.config/opencode/memory.mv2 --engine rules
```

Creates Memory Cards for O(1) entity lookups.

### Session Replay (Time Travel)

```bash
# Start recording session
memvid session start ~/.config/opencode/memory.mv2 --name "task-name"

# End session
memvid session end ~/.config/opencode/memory.mv2

# Replay with different parameters
memvid session replay ~/.config/opencode/memory.mv2 --session abc123 --top-k 10
```

### Maintenance

```bash
# Rebuild indexes and reclaim space
memvid doctor ~/.config/opencode/memory.mv2 --vacuum --rebuild-time-index --rebuild-lex-index
```

## Common Patterns

### Pattern 1: Research Task Memory

```bash
# Store research findings
echo '{"title":"API Authentication Research","label":"procedure","text":"Investigated JWT vs OAuth. Chose JWT for stateless microservices. Refresh token stored in httpOnly cookie, access token in memory. 15min expiry."}' | memvid put ~/.config/opencode/memory.mv2 --embedding -m openai-large
```

### Pattern 2: Bug Fix Documentation

```bash
# Document bug fix
echo '{"title":"React Hydration Error Fix","label":"fact","text":"Hydration errors caused by useLayoutEffect on SSR. Solution: use useEffect or check typeof window !== undefined before DOM access."}' | memvid put ~/.config/opencode/memory.mv2 --embedding -m openai-large
```

### Pattern 3: Architecture Decision

```bash
# Store decision
echo '{"title":"Database Choice Decision","label":"preference","text":"Chose PostgreSQL over MongoDB for e-commerce. Strong ACID guarantees needed for transactions. Referential integrity critical for orders/inventory."}' | memvid put ~/.config/opencode/memory.mv2 --embedding -m openai-large
```

### Pattern 4: Recall Previous Decision

```bash
# Search for past decisions
memvid find ~/.config/opencode/memory.mv2 --query "why did we choose postgresql database" --mode sem --top-k 5 -m openai-large
```

## Error Handling

### Common Issues

**Error: Lock failure**
- Cause: File being written by another process
- Solution: Wait and retry, or check for zombie processes

**Error: OPENAI_API_KEY not found**
- Cause: Environment variable not set
- Solution: Run `source ~/.config/opencode/scripts/load-mcp-credentials-safe.sh`

**Error: Capacity exceeded**
- Cause: Free tier 50MB limit reached
- Solution: Use `--vector-compression` or upgrade plan

**Warning: Uncompressed vectors**
- Cause: Large embeddings without compression
- Solution: Add `--vector-compression` flag (16x smaller)

## Performance Tips

1. **Use lexical search for exact keywords** (`--mode lex`)
2. **Use semantic search for concepts** (`--mode sem`)
3. **Enable vector compression** for large datasets (`--vector-compression`)
4. **Batch operations** when storing multiple entries
5. **Regular maintenance** (`memvid doctor` monthly)

## Integration with AGENTS.md Tiers

**Tier 1 (<30 lines):**
- Memvid search: Optional
- Store: Optional (only if useful pattern discovered)

**Tier 2 (30-100 lines):**
- Memvid search: MANDATORY (skip only if <30s task)
- Store: MANDATORY

**Tier 3 (100+ lines):**
- Memvid search: MANDATORY (before exploration)
- Store: MANDATORY

**Tier 4 (Critical/Deployment):**
- All Tier 3 requirements
- Store rollback procedures
- Document deployment decisions

## Quick Reference

| Task | Command |
|------|---------|
| Search semantically | `memvid find memory.mv2 --query "X" --mode sem --top-k 10 -m openai-large` |
| Search keywords | `memvid find memory.mv2 --query "X" --mode lex --top-k 10` |
| Store with embedding | `echo '{"title":"X","label":"Y","text":"Z"}' \| memvid put memory.mv2 --embedding -m openai-large` |
| Entity lookup | `memvid state memory.mv2 "EntityName"` |
| Ask question | `memvid ask memory.mv2 --question "X" --use-model openai` |
| Check stats | `memvid stats memory.mv2` |
| View timeline | `memvid timeline memory.mv2` |
| Enrich entities | `memvid enrich memory.mv2 --engine rules` |
| Maintenance | `memvid doctor memory.mv2 --vacuum --rebuild-time-index` |

## Notes

- Always use absolute path: `~/.config/opencode/memory.mv2`
- Flag `-m openai-large` maps to `text-embedding-3-large` (3072 dimensions)
- Memory file is portable: can git commit, scp, share
- Free tier: 50MB capacity (~194 documents with embeddings)
- Use `--vector-compression` to fit ~3000 documents in 50MB
