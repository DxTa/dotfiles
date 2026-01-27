---
description: Generate comprehensive CLAUDE.md for any repository
agent: technical-writer
---

# Repository Analysis & CLAUDE.md Generation

Analyze the repository and generate a comprehensive `CLAUDE.md` development guide for AI assistants and developers.

## Mission

Create a complete development guide including:
1. Project architecture and patterns
2. Coding standards and conventions
3. Testing requirements
4. Common workflows and pitfalls
5. **Code review guidelines** (critical)
6. Performance considerations
7. **Code index via repomix** (for AI navigation)

---

## Phase 0: Generate Code Index (repomix)

**MANDATORY FIRST STEP** - Generate a token-optimized code index for AI navigation.

### 0.1 Run Repomix Helper

```bash
~/.config/opencode/scripts/repomix-helper.sh .
```

This script:
1. Analyzes token distribution with `--token-count-tree`
2. Auto-identifies large non-essential files (tests, docs, examples)
3. Generates compressed `repomix-output.xml` (≤10k tokens)
4. Scans for external git URLs and generates remote indexes (≤5k tokens each)

### 0.2 If Script Unavailable, Run Manually

```bash
# Analyze token distribution first
npx repomix@latest --token-count-tree 500

# Generate with compression (adjust ignore patterns based on analysis)
npx repomix@latest \
  --output repomix-output.xml \
  --style xml \
  --compress \
  --remove-comments \
  --remove-empty-lines \
  --truncate-base64 \
  -i "test/**,tests/**,docs/**,*.lock,node_modules/**,.git/**,dist/**,build/**,coverage/**,__pycache__/**"
```

### 0.3 For Remote Dependencies

If codebase references external repos (in requirements.txt, package.json, etc.):

```bash
npx repomix@latest \
  --remote https://github.com/owner/repo \
  --output .repomix-remotes/owner_repo.xml \
  --style xml \
  --compress \
  --remove-comments \
  --no-file-summary \
  --include "*.py,*.js,*.ts,*.go,README.md"
```

---

## Phase 1: Repository Scanning

### 1.1 Identify Type & Structure
- Read `README.md`, `package.json`/`requirements.txt`/`go.mod`/`Cargo.toml`
- Determine: language(s), project type, architecture pattern

### 1.2 Scan Documentation
- `README.md`, `CONTRIBUTING.md`, `docs/`, existing `CLAUDE.md`, `.github/`
- Don't duplicate, reference existing docs

### 1.3 Analyze Dependencies
Extract from: `requirements.txt`, `pyproject.toml`, `package.json`, `go.mod`, `Cargo.toml`, `Gemfile`, `pom.xml`
Identify: frameworks, databases, testing tools, build tools

### 1.4 Container/Deployment
Check: `Dockerfile*`, `docker-compose*.yml`, `k8s/`, CI/CD configs
Extract: service architecture, resource requirements, deployment strategies

### 1.5 Source Code Structure
Analyze: entry points, module structure, test directories, config directories

---

## Phase 2: Pattern Extraction

### 2.1 Environment Variables
Search for env var access patterns, naming conventions, configuration sources

### 2.2 Logging Patterns
Find: logger initialization, log levels, structured logging, rotation

### 2.3 Error Handling
Identify: custom exceptions, error response formats, retry mechanisms

### 2.4 API/Interface Patterns
Extract: routing, request/response formats, auth, middleware, health checks

### 2.5 Testing Conventions
Analyze: test naming, structure (AAA/GWT), fixtures, mocking, test data

### 2.6 IPC/Communication
For multi-service: REST, gRPC, message queues, shared memory, sockets

---

## Phase 3: Code Review Analysis

### 3.1 Critical Review Areas
Identify: performance-critical sections, security-sensitive code, concurrency, resource management

### 3.2 Project-Specific Concerns
Look for: TODO/FIXME comments, git history patterns, common bug patterns
Identify: what breaks often, what needs special attention, common mistakes

### 3.3 Review Checklist Items
Create project-specific items based on: tech stack, architecture, domain, deployment

---

## Phase 4: Generate CLAUDE.md

Create `./CLAUDE.md` with this structure. **Target: ~5,000 tokens max.**

Since `repomix-output.xml` contains the full codebase, CLAUDE.md should focus on:
- Quick reference commands
- Critical patterns and conventions
- Common pitfalls (project-specific)
- Code review checklist

Avoid duplicating code that's in repomix - reference files instead.

```markdown
# [Project Name] - Development Guide

> **📚 Getting Started:** See [README.md](README.md)

---

## Quick Reference

### Essential Commands
```bash
# Setup, test, deployment commands from README
```

---

## Project Architecture

**Overview:** [1-2 sentences]
**Core Services:** [List from docker-compose/structure]
**Communication:** [REST/gRPC/queues/memory]

---

## Repository Structure

```
[Directory tree]
```

**Key Directories:**
- `/src/`: [Purpose and key modules]
- `/tests/`: [Test organization]

---

## Technology Stack

**Core:** [Frameworks, databases, tools]
**Dependencies:** [Key deps with versions]
**Dev Tools:** [Testing, linting, build]

---

## Coding Standards

### Environment Variables
**Pattern:** [Naming convention]
**Examples:** [5-10 actual variables]
```[language]
[Access pattern from code]
```

### Logging
```[language]
[Actual logging pattern]
```

### Error Handling
```[language]
[Actual error handling]
```

### [API/Library/CLI] Design
[Routing, auth, responses OR public API OR commands]

---

## Testing Conventions

**Location:** [Test directories]
**Naming:** [Pattern]
**Structure:** [Organization]

**Patterns:**
```[language]
[Actual fixture/test patterns]
```

**Requirements:** [GPU/network/database needs]
**Running:** `[actual commands]`

---

## Deployment

### For Containerized:
**Dockerfiles:** [List and purpose]
**Services:** [From docker-compose]
**Secrets:** [How handled]
**Resources:** [CPU/memory/GPU]

### For Non-Containerized:
**Build:** [Steps]
**Config:** [Setup]

---

## Common Workflows

### Development Cycle
1. **Setup:** [Commands]
2. **Development:** [Workflow]
3. **Testing:** [Process]
4. **Deployment:** [Steps]

### Adding Features
1. Update `[directory]` with code
2. Add tests in `[test directory]`
3. Update docs if needed
4. Run tests

### Debugging
**Logs:** [Locations]
**Common Issues:** [From git/docs]
**Tools:** [What to use]

---

## Common Pitfalls

### Development
1. **[Issue 1]:** [Solution]
2. **[Issue 2]:** [Solution]
[List 5-10 actual problems from repo]

### Configuration
[Project-specific gotchas]

### Testing
[Common failures and fixes]

### Deployment
[Common deployment issues]

---

## Performance

**[Relevant Area]:** [Optimization strategies]
**Limits:** [From docker-compose/docs]
**Profiling:** [How to profile]

---

## Code Review Guidelines

**MANDATORY - Extract from repository analysis**

### Review Principles
1. Understand context and purpose
2. Review related docs/issues
3. Check existing patterns
4. Consider architecture

### What to Review

**Functionality:**
- Does it work correctly?
- Edge cases handled?
- [Project-specific concerns]?
- Error handling?

**Code Quality:**
- Readable and maintainable?
- Descriptive names?
- Complexity justified?

**Testing:**
- Adequate test coverage?
- Edge cases tested?
- [Project-specific requirements] met?
- Dependencies mocked?

**Performance:**
- Performance issues?
- [Critical operations] optimized?
- Resource usage reasonable?

**Security:**
- Credentials handled properly?
- Input validation adequate?
- No injection vulnerabilities?

**Project-Specific Concerns:**
[LIST 5-10 SPECIFIC ITEMS FROM CODEBASE ANALYSIS]
[Examples: "Frame timing < 2s", "GPU flag in tests", "BuildKit secrets required"]

### Review Process
1. High-level: architecture/approach
2. Detailed: line-by-line
3. Testing: coverage/quality
4. Docs: updates needed

### Self-Review Checklist
- [ ] Tests pass
- [ ] Follows conventions
- [ ] No sensitive data
- [ ] Docs updated
- [ ] Clear commits
- [ ] Edge cases handled
- [ ] [Project-specific checks]

---

## Related Documentation

**Essential:** [README.md and key docs]
**Additional:** [.config/opencode/, wiki, etc.]

---

## Code Index (repomix)

This repository includes a `repomix-output.xml` file for AI-assisted code navigation.

### How to Use

**For AI Assistants (Claude, GPT, etc.):**
- Read `repomix-output.xml` to get a compressed overview of the entire codebase
- Use it to quickly locate files, understand structure, and find patterns
- The XML contains file contents with token-optimized compression

**When to Reference:**
- Starting work on unfamiliar code areas
- Looking for "where is X implemented?"
- Understanding project structure before making changes
- Finding all files related to a feature

**Regenerate After Major Changes:**
```bash
~/.config/opencode/scripts/repomix-helper.sh .
# Or manually:
npx repomix@latest --compress --remove-comments -i "test/**,docs/**,*.lock"
```

**Remote Dependencies:** Check `.repomix-remotes/` for indexed external libraries.

---

**🤖 Generated by `/setup-repo`**
**📅 Last updated:** [timestamp]
**📦 Repository:** [org/repo]
**🔀 Branch:** [branch]

---

## Validation

**Analyzed:**
✓ Repo structure
✓ Dependencies
✓ Docker configs
✓ Source patterns
✓ Tests
✓ Documentation
✓ CI/CD
✓ Git history

**Quality:**
✓ File references verified
✓ Code examples from codebase
✓ Commands tested
✓ Links validated
✓ Project-specific patterns
✓ Tailored review guidelines
✓ Real pitfalls documented
```

---

## Phase 5: Validation

**Completeness Check:**
- [ ] All sections present
- [ ] 5-10 specific examples per pattern
- [ ] Actual code (not placeholders)
- [ ] Links to real files
- [ ] Executable commands
- [ ] 5-10 project-specific review items
- [ ] Pitfalls from repo (not generic)
- [ ] repomix-output.xml generated (≤10k tokens)
- [ ] Code Index section included in CLAUDE.md

**Accuracy:**
- [ ] Service names correct
- [ ] Dependencies match
- [ ] Directory structure accurate
- [ ] Environment variables exist
- [ ] Test commands work
- [ ] Links point to real files

**Specificity:**
- [ ] Project-specific review guidelines
- [ ] Project-specific pitfalls
- [ ] Project-specific test requirements
- [ ] Project-specific performance constraints
- [ ] Examples from actual codebase

**Quality:**
- [ ] No placeholder text
- [ ] Proper code block syntax
- [ ] Correct markdown
- [ ] Working internal links
- [ ] **CRITICAL: Under 5,000 tokens** (check with `npx repomix@latest --token-count-tree . | head -5`)
  - Since repomix contains the full codebase, CLAUDE.md should be concise guidance only
  - If over, remove verbose explanations and redundant examples

---

## Execution

1. Read these instructions
2. **Execute Phase 0 first** (generate repomix-output.xml)
3. Execute Phases 1-5 sequentially
4. Be specific - extract actual patterns
5. Validate with checklist
6. Write to `./CLAUDE.md`
7. Report findings

**Key Points:**
- **Generate repomix first** - essential for AI navigation
- Reference README.md (don't duplicate)
- Extract, don't invent patterns
- Include code review section
- Include Code Index section
- Validate everything
- **Token limit: 5,000 max for CLAUDE.md** (repomix has full code, so CLAUDE.md is guidance only)
- **Token limit: 10k for repomix-output.xml**

---

**Now execute Phase 0 (repomix), then analysis and generation.**
