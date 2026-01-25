---
description: Stage all changes, create commit, and push to remote (use with caution)
allowed-tools: ["Bash(git add:*)", "Bash(git status:*)", "Bash(git commit:*)", "Bash(git push:*)", "Bash(git diff:*)", "Bash(git log:*)", "Bash(git pull:*)", "Bash(npm run:*)", "Bash(npx:*)", "Bash(cargo:*)", "Bash(go:*)", "Bash(golangci-lint:*)", "Bash(ruff:*)", "Bash(mypy:*)", "Bash(pyright:*)", "Bash(flake8:*)", "Bash(bundle exec:*)", "Bash(composer:*)", "Bash(deno:*)", "Bash(cat:*)", "Bash(ls:*)", "Bash(test:*)", "Glob", "Grep", "Read"]
---

# Commit and Push Everything

⚠️ **CAUTION**: Stage ALL changes, commit, and push to remote. Use only when confident all changes belong together.

---

## Workflow

### 1. Analyze Changes

Run the following commands in parallel to gather information:

```bash
git status
git diff --stat
git log -1 --oneline
```

### 2. Quality Gates (Lint/Typecheck)

**Detect project type and run quality checks before pushing.**

#### Detection Strategy

Check for config files in priority order (stop at first match per type):

```bash
# Quick detection
ls package.json pyproject.toml Cargo.toml go.mod composer.json Gemfile deno.json biome.json 2>/dev/null
```

#### Project-Specific Gates

| Config File | Project Type | Lint Command | Typecheck Command |
|-------------|--------------|--------------|-------------------|
| `package.json` | Node.js | Parse `scripts` for: `lint`, `eslint` | Parse `scripts` for: `typecheck`, `type-check`, `tsc` |
| `pyproject.toml` | Python | `ruff check .` (if `[tool.ruff]`) | `mypy .` (if `[tool.mypy]`) |
| `Cargo.toml` | Rust | `cargo clippy` | `cargo check` |
| `go.mod` | Go | `go vet ./...` | (included in vet) |
| `composer.json` | PHP | Parse `scripts` for: `lint`, `phpcs` | `./vendor/bin/phpstan` (if exists) |
| `Gemfile` | Ruby | `bundle exec rubocop` | `bundle exec sorbet tc` (if sorbet) |
| `deno.json` | Deno | `deno lint` | `deno check *.ts` |
| `biome.json` | Biome | `npx biome check .` | (included in check) |

#### Node.js Script Detection

For `package.json`, parse the `scripts` section:

```bash
# Check for lint scripts
cat package.json | grep -E '"(lint|eslint)":'

# Check for typecheck scripts  
cat package.json | grep -E '"(typecheck|type-check|tsc)":'
```

**Patterns to detect:**
- Lint: Script name contains `lint`, `eslint`, or `check`
- Typecheck: Script name contains `type`, `typecheck`, `tsc`

**Execute with:** `npm run <script-name>`

#### Python Tool Detection

For `pyproject.toml`, check for tool configurations:

```bash
# Check for ruff
grep -q "\[tool.ruff\]" pyproject.toml && echo "ruff check ."

# Check for mypy
grep -q "\[tool.mypy\]" pyproject.toml && echo "mypy ."

# Check for pyright
grep -q "\[tool.pyright\]" pyproject.toml && echo "pyright"
```

#### Execution Flow

1. **Detect all project types** (a repo may have multiple, e.g., Node.js + Python)
2. **For each detected type:**
   - Find available lint commands
   - Find available typecheck commands
3. **Run all gates sequentially:**
   - Run all lint commands first
   - Then run all typecheck commands
4. **❌ STOP if any gate fails** - must fix before continuing

**Example output:**

```
🔍 Quality Gates Check

Detected: Node.js project (package.json)

🧹 Running lint: npm run lint
   ✅ Lint passed

🔬 Running typecheck: npm run typecheck
   ✅ Typecheck passed

✅ All quality gates passed!
```

**If gates fail:**

```
🧹 Running lint: npm run lint
   ❌ LINT FAILED

ERROR: Quality gate blocked push. Fix errors before pushing.

Run this to see details:
  npm run lint

Cannot proceed until all gates pass.
```

**If no gates found:**

```
ℹ️  No lint/typecheck scripts detected in this project.
    Consider adding quality checks to your project configuration:
    
    Node.js: Add "lint" and "typecheck" scripts to package.json
    Python: Configure ruff, mypy in pyproject.toml
    
    Continuing with push...
```

**Multi-project example:**

```
🔍 Quality Gates Check

Detected: Node.js (package.json) + Python (pyproject.toml)

Node.js gates:
  🧹 npm run lint → ✅ Passed
  🔬 npm run typecheck → ✅ Passed

Python gates:
  🧹 ruff check . → ✅ Passed
  🔬 mypy . → ✅ Passed

✅ All quality gates passed!
```

#### Hard Gate Policy

**No bypass mechanism** - if gates fail, the push is blocked. This ensures:
- Code quality standards are maintained
- Type safety is enforced
- Linting rules are followed
- No broken code reaches the repository

**To proceed after failure:**
1. Fix the reported errors
2. Re-run the push-all command
3. Gates will re-check automatically

### 3. Safety Checks

**❌ STOP and WARN if any of the following are detected:**

**Secrets (file patterns to check):**
- `.env*`, `*.key`, `*.pem`, `credentials.json`, `secrets.yaml`, `id_rsa`, `*.p12`, `*.pfx`, `*.cer`

**API Keys (check for real values in modified files):**

Patterns that indicate REAL keys (should block):
```bash
# Real key patterns:
OPENAI_API_KEY=sk-proj-xxxxx
AWS_SECRET_KEY=AKIA...
STRIPE_API_KEY=sk_live_...
GCP_SA_KEY=eyJhbGci...
```

Acceptable placeholders (should allow):
```bash
API_KEY=your-api-key-here
SECRET_KEY=placeholder
TOKEN=xxx
API_KEY=<your-key>
SECRET=${YOUR_SECRET}
```

**Large files:** Check for any file >10MB without Git LFS

**Build artifacts to exclude:**
- `node_modules/`, `dist/`, `build/`, `__pycache__/`, `*.pyc`, `.venv/`

**Temp files:**
- `.DS_Store`, `thumbs.db`, `*.swp`, `*.tmp`

**✅ Verify:**
- `.gitignore` properly configured
- No merge conflicts present
- Correct branch (warn if committing directly to main/master)

### 4. Request Confirmation

Present summary to user:

```
📊 Changes Summary:
- X files modified, Y added, Z deleted
- Total: +AAA insertions, -BBB deletions

🔒 Safety: ✅ No secrets | ✅ No large files | ⚠️ [any warnings]
🌿 Branch: [branch-name] → origin/[branch-name]

I will: git add . → commit → push

Type 'yes' to proceed or 'no' to cancel.
```

**WAIT for explicit "yes" from the user before proceeding.**

### 5. Stage Changes

After confirmation:
```bash
git add .
git status  # Verify staging
```

### 6. Generate Commit Message

Analyze the changes and create a conventional commit message:

**Format:**
```
[type]: Brief summary (max 72 characters)

- Key change 1
- Key change 2
- Key change 3
```

**Commit types:** `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `perf`, `build`, `ci`

**Example:**
```
docs: Update concept README files with comprehensive documentation

- Add architecture diagrams and tables
- Include practical examples
- Expand best practices sections
```

Use `Git(haiku)` model for generating commit messages:
- Keep summary under 72 characters
- Use imperative mood ("add" not "added" or "adds")
- Reference issues with # if applicable

### 7. Commit and Push

```bash
git commit -m "$(cat <<'EOF'
[Generated commit message]
EOF
)"

git log -1 --oneline --decorate  # Verify commit

git push  # If fails: git pull --rebase && git push
```

### 8. Confirm Success

```
✅ Successfully pushed to remote!

Commit: [hash] [message]
Branch: [branch] → origin/[branch]
Files changed: X (+insertions, -deletions)
```

---

## Error Handling

**git add fails:**
- Check file permissions
- Check for locked files
- Verify git repository is initialized

**git commit fails:**
- Fix pre-commit hook failures
- Check git config (user.name, user.email)
- Resolve merge conflicts if present

**git push fails:**
- Non-fast-forward: `git pull --rebase && git push`
- No remote branch: `git push -u origin [branch]`
- Protected branch: Suggest using PR workflow instead

---

## When to Use

✅ **Good for:**
- Multi-file documentation updates
- Feature with tests and docs
- Bug fixes across related files
- Project-wide formatting/refactoring
- Configuration changes

❌ **Avoid when:**
- Uncertain what's being committed
- Changes contain secrets/sensitive data
- Committing to protected branches (use PR)
- Merge conflicts are present
- Want granular commit history
- Pre-commit hooks are failing
- Lint or typecheck errors are present (gates will block)

---

## Alternatives

If the user wants more control, suggest:

1. **Selective staging:** Review and stage specific files individually
2. **Interactive staging:** Use `git add -p` for patch-level selection
3. **PR workflow:** Create branch → push → create PR (use `/pr` command)

---

**⚠️ Remember:** Always review changes before pushing. When in doubt, use individual git commands for more control.
