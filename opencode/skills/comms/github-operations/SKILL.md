---
name: github-operations
description: Manage GitHub repositories using gh CLI - create/review/merge PRs, manage issues, monitor Actions workflows, and search repos. Converts GitHub HTTPS URLs to gh CLI format automatically. Use when working with GitHub PRs, issues, releases, or Actions. Trigger with "create PR", "list issues", "check workflow", "review PR", "merge PR".
version: "1.0.0"
license: MIT
compatibility: opencode
# Original Claude allowed-tools: Bash(gh:*),Read,Grep,Glob
---

# GitHub Operations

Manage GitHub repositories efficiently using the `gh` CLI for PRs, issues, and Actions workflows.

## Overview

This skill provides structured guidance for common GitHub operations:
- **Pull Requests**: Create, review, merge, checkout PRs
- **Issues**: Create, list, close, comment on issues
- **Actions**: Monitor workflow runs, view logs, re-run jobs
- **Search**: Find issues, PRs across repositories

## Prerequisites

**Required**:
- `gh` CLI installed (`gh --version`)
- Authenticated with GitHub (`gh auth status`)

**Verify Setup**:
```bash
gh auth status
```

If not authenticated:
```bash
gh auth login
```

## Working with GitHub URLs

When given a GitHub HTTPS URL, **always convert it to the `gh` CLI format** using `--repo owner/repo` rather than using the URL directly.

### URL Pattern Reference

| URL Type | URL Pattern | Command Format |
|----------|-------------|----------------|
| Repository | `https://github.com/{owner}/{repo}` | `--repo owner/repo` |
| Pull Request | `https://github.com/{owner}/{repo}/pull/{N}` | `gh pr view N --repo owner/repo` |
| Issue | `https://github.com/{owner}/{repo}/issues/{N}` | `gh issue view N --repo owner/repo` |
| Actions Run | `https://github.com/{owner}/{repo}/actions/runs/{id}` | `gh run view id --repo owner/repo` |
| Actions Workflow | `https://github.com/{owner}/{repo}/actions/workflows/{file}` | `gh workflow view file --repo owner/repo` |

### URL Conversion Examples

**Pull Request URL**:
```bash
# Given: https://github.com/topdatascience/metsa_backend/pull/1
# Extract: owner=topdatascience, repo=metsa_backend, number=1

gh pr view 1 --repo topdatascience/metsa_backend
gh pr checkout 1 --repo topdatascience/metsa_backend
gh pr merge 1 --repo topdatascience/metsa_backend --squash
```

**Issue URL**:
```bash
# Given: https://github.com/org/project/issues/42
# Extract: owner=org, repo=project, number=42

gh issue view 42 --repo org/project
gh issue comment 42 --repo org/project --body "Looking into this"
```

**Actions Run URL**:
```bash
# Given: https://github.com/org/repo/actions/runs/123456789
# Extract: owner=org, repo=repo, run-id=123456789

gh run view 123456789 --repo org/repo
gh run view 123456789 --repo org/repo --log-failed
```

### Why Prefer `--repo` Over URLs

1. **Consistency**: All `gh` commands use the same `--repo owner/repo` format
2. **Flexibility**: Easy to modify owner/repo without URL encoding issues
3. **Composability**: Can chain commands using the same repo reference
4. **Clarity**: Command intent is immediately visible

## Claude Attribution

When posting comments or reviews on behalf of the user, **always include the Claude signature** at the end of the message body to indicate it was AI-generated.

### Signature Format

```
🤖 Generated with [Claude Code](https://claude.ai/code)
```

### Usage Examples

**PR Review with signature**:
```bash
gh pr review 42 --approve --body "$(cat <<'EOF'
LGTM! The implementation looks solid.

🤖 Generated with [Claude Code](https://claude.ai/code)
EOF
)"
```

**Issue comment with signature**:
```bash
gh issue comment 15 --body "$(cat <<'EOF'
I've identified the root cause - the timeout occurs because...

🤖 Generated with [Claude Code](https://claude.ai/code)
EOF
)"
```

**PR comment with signature**:
```bash
gh pr comment 7 --body "$(cat <<'EOF'
This approach could cause a race condition. Consider using a mutex here.

🤖 Generated with [Claude Code](https://claude.ai/code)
EOF
)"
```

### When to Include

| Operation | Include Signature |
|-----------|-------------------|
| PR reviews (approve/request-changes/comment) | ✅ Yes |
| PR comments | ✅ Yes |
| Issue comments | ✅ Yes |
| Issue creation (body) | ✅ Yes |
| PR creation (body) | ✅ Yes |
| Closing with comment | ✅ Yes |
| Merge commit messages | ❌ No (use git commit signature instead) |

## Instructions

### Step 1: Determine Operation Type

Identify which GitHub operation is needed:
- **PR operations**: creation, review, merge, checkout
- **Issue operations**: creation, management, comments
- **Actions**: workflow monitoring, job management
- **Search**: finding issues/PRs across repos

### Step 2: Execute Operation

#### Pull Request Operations

**Create PR** (from current branch, include Claude signature in body):
```bash
gh pr create --title "Feature: Add login" --body "$(cat <<'EOF'
Implements user authentication.

🤖 Generated with [Claude Code](https://claude.ai/code)
EOF
)"
```

**Create PR with template**:
```bash
gh pr create --fill  # Uses PR template
```

**List open PRs**:
```bash
gh pr list --state open
gh pr list --author @me  # Your PRs only
```

**View PR details**:
```bash
gh pr view [number]
gh pr view [number] --web  # Open in browser
```

**Checkout PR locally**:
```bash
gh pr checkout [number]
```

**Merge PR**:
```bash
gh pr merge [number] --squash  # Squash merge
gh pr merge [number] --merge   # Merge commit
gh pr merge [number] --rebase  # Rebase merge
```

**Review PR** (include Claude signature):
```bash
gh pr review [number] --approve --body "$(cat <<'EOF'
LGTM!

🤖 Generated with [Claude Code](https://claude.ai/code)
EOF
)"
gh pr review [number] --request-changes --body "$(cat <<'EOF'
Please fix the null check on line 42.

🤖 Generated with [Claude Code](https://claude.ai/code)
EOF
)"
```

See `{baseDir}/references/gh-pr-workflows.md` for advanced patterns.

#### Issue Operations

**Create issue** (include Claude signature in body):
```bash
gh issue create --title "Bug: Login fails" --body "$(cat <<'EOF'
Steps to reproduce...

🤖 Generated with [Claude Code](https://claude.ai/code)
EOF
)"
gh issue create --label bug --assignee @me --title "Bug title" --body "$(cat <<'EOF'
Description here.

🤖 Generated with [Claude Code](https://claude.ai/code)
EOF
)"
```

**List issues**:
```bash
gh issue list --state open
gh issue list --label bug --state open
gh issue list --assignee @me
```

**View issue**:
```bash
gh issue view [number]
```

**Comment on issue** (include Claude signature):
```bash
gh issue comment [number] --body "$(cat <<'EOF'
Working on this now.

🤖 Generated with [Claude Code](https://claude.ai/code)
EOF
)"
```

**Close issue**:
```bash
gh issue close [number]
gh issue close [number] --comment "$(cat <<'EOF'
Fixed in PR #123.

🤖 Generated with [Claude Code](https://claude.ai/code)
EOF
)"
```

See `{baseDir}/references/gh-issue-workflows.md` for advanced patterns.

#### GitHub Actions Operations

**List recent runs**:
```bash
gh run list
gh run list --workflow=ci.yml
gh run list --status failure
```

**View run details**:
```bash
gh run view [run-id]
gh run view [run-id] --log  # Full logs
gh run view [run-id] --log-failed  # Failed job logs only
```

**Watch running workflow**:
```bash
gh run watch [run-id]
```

**Re-run failed jobs**:
```bash
gh run rerun [run-id] --failed
```

See `{baseDir}/references/gh-actions-workflows.md` for advanced patterns.

#### Search Operations

**Search issues**:
```bash
gh search issues "bug login" --repo owner/repo
gh search issues "is:open label:bug"
```

**Search PRs**:
```bash
gh search prs "feature" --state open
gh search prs "author:@me is:merged"
```

### Step 3: Verify Result

After each operation:
1. Check command output for success/error messages
2. For PRs/issues, note the URL returned
3. For Actions, verify workflow status

## Output

- **PR/Issue URLs**: Links to created/modified items
- **Status messages**: Success/failure confirmations
- **Workflow status**: Run state and results

## Error Handling

1. **Error**: `gh: command not found`
   **Cause**: gh CLI not installed
   **Solution**: Install via `brew install gh` or see https://cli.github.com

2. **Error**: `You are not logged into any GitHub hosts`
   **Cause**: Not authenticated
   **Solution**: Run `gh auth login` and follow prompts

3. **Error**: `Could not resolve to a Repository`
   **Cause**: Not in a git repo or repo not on GitHub
   **Solution**: Ensure you're in a git repo with GitHub remote

4. **Error**: `HTTP 403: Resource not accessible`
   **Cause**: Insufficient permissions
   **Solution**: Check repo access or request permissions

5. **Error**: `pull request create failed: GraphQL: No commits between main and feature`
   **Cause**: No changes to merge
   **Solution**: Ensure branch has commits ahead of base

## Examples

### Example 1: Create and Merge PR

**User Request**: "Create a PR for my feature branch"

**Commands**:
```bash
# Create PR with auto-fill from commits
gh pr create --fill

# After review, merge with squash
gh pr merge --squash --delete-branch
```

### Example 2: Triage Issues

**User Request**: "Show me open bugs assigned to me"

**Command**:
```bash
gh issue list --label bug --assignee @me --state open
```

**Output**:
```
Showing 2 of 2 issues

#42  Login timeout on slow networks    bug, priority:high   about 2 hours ago
#38  Session expires unexpectedly      bug                  about 1 day ago
```

### Example 3: Debug Failed Workflow

**User Request**: "The CI failed, show me what went wrong"

**Commands**:
```bash
# List recent failed runs
gh run list --status failure --limit 5

# View logs for specific run
gh run view [run-id] --log-failed
```

## Resources

- PR workflows: `{baseDir}/references/gh-pr-workflows.md`
- Issue workflows: `{baseDir}/references/gh-issue-workflows.md`
- Actions workflows: `{baseDir}/references/gh-actions-workflows.md`
- Official docs: https://cli.github.com/manual/
