---
name: sia-code/health-check
description: Pre-flight sia-code health check. Run at session start or before any sia-code command. Detects broken/missing/degraded index and ASKS USER to initialize immediately instead of silently failing.
license: MIT
compatibility: opencode
version: 1.0.0
---

# sia-code Health Check

Pre-flight check that ensures sia-code index is functional before any memory search, code research, or search commands. **The key behavior: ASK the user to fix problems instead of silently skipping.**

## When to Use

- **Session start** (Step 0 of Master Checklist — before any task work)
- **Before first `memory search`** (if Step 0 was skipped)
- **After any sia-code command returns a traceback**
- **When memory search returns suspiciously empty results** on a project with prior history

## Why This Matters

A broken or missing index **masquerades as "no results found"**. The agent silently moves on, documenting "No prior context found" — when in reality the entire memory subsystem is non-functional. This causes:

- All memory search gates (T2+) pass with false "no results"
- Code research returns nothing useful
- Two-Strike Rule research fails silently
- POST-TASK memory storage fails (learnings lost)
- Future sessions lose all accumulated reasoning

**The fix is simple: detect and ASK, don't silently skip.**

## Health Check Flow

### Step 1: Run Status Check

```bash
uvx sia-code status 2>&1
```

Capture both stdout and stderr — errors go to stderr.

### Step 2: Evaluate Output

| Output Contains | State | Action |
|-----------------|-------|--------|
| `Health Status: 🟢 Healthy` | ✅ HEALTHY | Continue to task work |
| `Health Status: 🟡 Degraded` (10-20% stale) | ⚠️ STALE | Suggest: `uvx sia-code index --update` or `compact` |
| `Health Status: 🔴 Critical` (>20% stale) | ❌ CRITICAL | Suggest: `uvx sia-code index --clean` |
| `Traceback` or `FileNotFoundError` | ❌ BROKEN | **→ Step 3: ASK USER** |
| `Sia Code not initialized` | ❌ MISSING | **→ Step 3: ASK USER** |
| No `.sia-code/` directory exists | ❌ MISSING | **→ Step 3: ASK USER** |

### Step 3: ASK USER (MANDATORY for BROKEN or MISSING)

⚠️ **Do NOT silently skip. Do NOT just document "no results found".**

**Prompt the user immediately:**

> sia-code index is broken or uninitialized in this project. This is required for:
> - Memory search (past decisions and learnings)
> - Code research (architecture analysis)
> - Learning storage (preserving reasoning for future sessions)
>
> Initialize now with `uvx sia-code init && uvx sia-code index .`?

### Step 4: Handle User Response

**If user approves:**
```bash
uvx sia-code init && uvx sia-code index .
```
Then re-run `uvx sia-code status` to confirm healthy.

**If user declines:**
Document in task_plan.md:
```markdown
## sia-code Status
**UNAVAILABLE** — User declined initialization.
- Memory search: SKIPPED (no index)
- Code research: UNAVAILABLE
- Learning storage: UNAVAILABLE
```

This makes it explicit that memory gates were not truly satisfied — just bypassed by user choice.

## Common Failure Modes

### 1. Directory exists but vector index missing

**Symptom:** `.sia-code/` exists, `config.json` present, but `uvx sia-code status` throws `FileNotFoundError: Vector index not found: .sia-code/vectors.usearch`

**Cause:** `init` ran but `index .` never completed (or was interrupted).

**Fix:** `uvx sia-code index .` (full index, not just `--update`)

### 2. Directory completely missing

**Symptom:** No `.sia-code/` directory at all.

**Fix:** `uvx sia-code init && uvx sia-code index .`

### 3. Index severely degraded

**Symptom:** Status shows `🔴 Critical` with >20% stale chunks.

**Cause:** Major refactoring, many file changes since last index.

**Fix:** `uvx sia-code index --clean` (full rebuild)

### 4. Embed daemon not running (hybrid search only)

**Symptom:** Hybrid/semantic search fails, lexical search (`--regex`) works fine.

**Fix:** `uvx sia-code embed start` (or use `--regex` flag for lexical-only)

**Note:** Lexical search (89.9% Recall@5) works without the embed daemon and is the recommended default.

## Recovery Commands Quick Reference

| Severity | Command | When to Use |
|----------|---------|-------------|
| **Full init** | `uvx sia-code init && uvx sia-code index .` | Missing directory, first setup |
| **Rebuild index** | `uvx sia-code index .` | Broken vector index, incomplete init |
| **Clean rebuild** | `uvx sia-code index --clean` | Critical degradation (>20% stale) |
| **Update** | `uvx sia-code index --update` | After git pull, moderate changes |
| **Compact** | `uvx sia-code compact` | Mild degradation (10-20% stale) |
| **Start embed** | `uvx sia-code embed start` | Hybrid search needed |

## Integration with AGENTS.md

This skill is referenced in:
- **Step 0** of Master Checklist (pre-flight at session start)
- **Step 2** recovery path (when memory search fails)
- **Core Tools** section (sia-code fallback)
- **Anti-patterns** #3 (Skipped Sia-Code)

**Load this skill:** `Load skill sia-code/health-check`

**Full sia-code reference:** `Load skill sia-code`
