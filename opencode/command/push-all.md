---
description: Stage all changes, create commit, and push to remote (use with caution)
allowed-tools: ["Bash(git add:*)", "Bash(git status:*)", "Bash(git commit:*)", "Bash(git push:*)", "Bash(git diff:*)", "Bash(git log:*)", "Bash(git pull:*)", "Glob", "Grep", "Read"]
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

### 2. Safety Checks

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

### 3. Request Confirmation

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

### 4. Stage Changes

After confirmation:
```bash
git add .
git status  # Verify staging
```

### 5. Generate Commit Message

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

### 6. Commit and Push

```bash
git commit -m "$(cat <<'EOF'
[Generated commit message]
EOF
)"

git log -1 --oneline --decorate  # Verify commit

git push  # If fails: git pull --rebase && git push
```

### 7. Confirm Success

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

---

## Alternatives

If the user wants more control, suggest:

1. **Selective staging:** Review and stage specific files individually
2. **Interactive staging:** Use `git add -p` for patch-level selection
3. **PR workflow:** Create branch → push → create PR (use `/pr` command)

---

**⚠️ Remember:** Always review changes before pushing. When in doubt, use individual git commands for more control.
