---
name: glab-operations
description: Manage GitLab repositories using glab CLI - create/review/merge MRs, manage issues, monitor CI/CD pipelines. Converts GitLab HTTPS URLs to glab CLI format automatically. Use when working with GitLab MRs, issues, or pipelines. Trigger with "create MR", "list issues", "check pipeline", "review MR", "merge MR".
version: "1.0.0"
license: MIT
compatibility: opencode
# Original Claude allowed-tools: Bash(glab:*),Read,Grep,Glob
---

# GitLab Operations

Manage GitLab repositories efficiently using the `glab` CLI for merge requests, issues, and CI/CD pipelines.

## Overview

This skill provides structured guidance for common GitLab operations:
- **Merge Requests**: Create, review, merge, checkout MRs
- **Issues**: Create, list, close, comment on issues
- **CI/CD**: Monitor pipelines, view logs, retry jobs
- **Search**: Find issues, MRs across repositories

## Prerequisites

**Required**:
- `glab` CLI installed (`glab --version`)
- Authenticated with GitLab (`glab auth status`)

**Verify Setup**:
```bash
glab auth status
```

If not authenticated:
```bash
glab auth login
```

## Working with GitLab URLs

When given a GitLab HTTPS URL, **always convert it to the `glab` CLI format** using `-R owner/repo` rather than using the URL directly.

### URL Pattern Reference

| URL Type | URL Pattern | Command Format |
|----------|-------------|----------------|
| Repository | `https://gitlab.com/{owner}/{repo}` | `-R owner/repo` |
| Merge Request | `https://gitlab.com/{owner}/{repo}/-/merge_requests/{N}` | `glab mr view N -R owner/repo` |
| Issue | `https://gitlab.com/{owner}/{repo}/-/issues/{N}` | `glab issue view N -R owner/repo` |
| Pipeline | `https://gitlab.com/{owner}/{repo}/-/pipelines/{id}` | `glab ci view -R owner/repo` |
| Job | `https://gitlab.com/{owner}/{repo}/-/jobs/{id}` | `glab ci trace {id} -R owner/repo` |

### URL Conversion Examples

**Merge Request URL**:
```bash
# Given: https://gitlab.com/mygroup/myproject/-/merge_requests/42
# Extract: owner=mygroup, repo=myproject, number=42

glab mr view 42 -R mygroup/myproject
glab mr checkout 42 -R mygroup/myproject
glab mr merge 42 -R mygroup/myproject --squash
```

**Issue URL**:
```bash
# Given: https://gitlab.com/org/project/-/issues/15
# Extract: owner=org, repo=project, number=15

glab issue view 15 -R org/project
glab issue note 15 -R org/project -m "Looking into this"
```

**Pipeline URL**:
```bash
# Given: https://gitlab.com/org/repo/-/pipelines/123456789
# Extract: owner=org, repo=repo

glab ci view -R org/repo
glab ci view -R org/repo --web
```

### Why Prefer `-R` Over URLs

1. **Consistency**: All `glab` commands use the same `-R owner/repo` format
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

**MR Review with signature**:
```bash
glab mr approve 42
glab mr note 42 -m "$(cat <<'EOF'
LGTM! The implementation looks solid.

🤖 Generated with [Claude Code](https://claude.ai/code)
EOF
)"
```

**Issue comment with signature**:
```bash
glab issue note 15 -m "$(cat <<'EOF'
I've identified the root cause - the timeout occurs because...

🤖 Generated with [Claude Code](https://claude.ai/code)
EOF
)"
```

**MR comment with signature**:
```bash
glab mr note 7 -m "$(cat <<'EOF'
This approach could cause a race condition. Consider using a mutex here.

🤖 Generated with [Claude Code](https://claude.ai/code)
EOF
)"
```

### When to Include

| Operation | Include Signature |
|-----------|-------------------|
| MR reviews (approve/note) | Yes |
| MR comments | Yes |
| Issue comments | Yes |
| Issue creation (body) | Yes |
| MR creation (body) | Yes |
| Closing with comment | Yes |
| Merge commit messages | No (use git commit signature instead) |

## Instructions

### Step 1: Determine Operation Type

Identify which GitLab operation is needed:
- **MR operations**: creation, review, merge, checkout
- **Issue operations**: creation, management, comments
- **CI/CD**: pipeline monitoring, job management
- **Search**: finding issues/MRs across repos

### Step 2: Execute Operation

#### Merge Request Operations

**Create MR** (from current branch, include Claude signature in body):
```bash
glab mr create --title "Feature: Add login" --description "$(cat <<'EOF'
Implements user authentication.

🤖 Generated with [Claude Code](https://claude.ai/code)
EOF
)"
```

**Create MR with template** (auto-fill from commits):
```bash
glab mr create --fill
```

**Create MR for an issue**:
```bash
glab mr for 34  # Creates MR linked to issue #34
glab mr for 34 --wip  # Creates as Work in Progress
```

**List open MRs**:
```bash
glab mr list --state opened
glab mr list --assignee=@me  # Your MRs only
glab mr list --reviewer=@me  # MRs you need to review
```

**View MR details**:
```bash
glab mr view [number]
glab mr view [number] --web  # Open in browser
glab mr view [number] --comments  # Include comments
```

**Checkout MR locally**:
```bash
glab mr checkout [number]
```

**Merge MR**:
```bash
glab mr merge [number] --squash  # Squash merge
glab mr merge [number]           # Regular merge
glab mr merge [number] --rebase  # Rebase merge
glab mr merge [number] --remove-source-branch  # Delete branch after merge
```

**Review MR** (include Claude signature):
```bash
# Approve MR
glab mr approve [number]

# Add comment with review
glab mr note [number] -m "$(cat <<'EOF'
LGTM!

🤖 Generated with [Claude Code](https://claude.ai/code)
EOF
)"
```

See `{baseDir}/references/glab-mr-workflows.md` for advanced patterns.

#### Issue Operations

**Create issue** (include Claude signature in body):
```bash
glab issue create --title "Bug: Login fails" --description "$(cat <<'EOF'
Steps to reproduce...

🤖 Generated with [Claude Code](https://claude.ai/code)
EOF
)"
glab issue create --label bug --assignee @me --title "Bug title" --description "$(cat <<'EOF'
Description here.

🤖 Generated with [Claude Code](https://claude.ai/code)
EOF
)"
```

**List issues**:
```bash
glab issue list --state opened
glab issue list --label bug --state opened
glab issue list --assignee=@me
```

**View issue**:
```bash
glab issue view [number]
glab issue view [number] --web
glab issue view [number] --comments
```

**Comment on issue** (include Claude signature):
```bash
glab issue note [number] -m "$(cat <<'EOF'
Working on this now.

🤖 Generated with [Claude Code](https://claude.ai/code)
EOF
)"
```

**Close issue**:
```bash
glab issue close [number]
```

**Subscribe to issue**:
```bash
glab issue subscribe [number]
```

See `{baseDir}/references/glab-issue-workflows.md` for advanced patterns.

#### CI/CD Pipeline Operations

**View current pipeline**:
```bash
glab ci view  # Current branch
glab ci view main  # Specific branch
glab ci view --web  # Open in browser
```

**Get pipeline status**:
```bash
glab ci get
glab ci get --output json  # JSON output
```

**List pipelines**:
```bash
glab ci list
```

**Trace job logs**:
```bash
glab ci trace  # Interactive selection
glab ci trace [job-id]  # Specific job
glab ci trace [job-name]  # By job name (e.g., "lint")
```

**Retry failed job**:
```bash
glab ci retry [job-id]
```

**Trigger manual job**:
```bash
glab ci trigger [job-id]
```

**Download artifacts**:
```bash
glab ci artifact [ref] [job-name]
```

**Delete old pipelines**:
```bash
glab ci delete [pipeline-id]
glab ci delete --status=failed  # All failed pipelines
glab ci delete --older-than 24h  # Older than 24 hours
```

**Lint CI config**:
```bash
glab ci lint
glab ci lint --dry-run  # Simulate without running
```

See `{baseDir}/references/glab-ci-workflows.md` for advanced patterns.

### Step 3: Verify Result

After each operation:
1. Check command output for success/error messages
2. For MRs/issues, note the URL returned
3. For CI/CD, verify pipeline/job status

## Output

- **MR/Issue URLs**: Links to created/modified items
- **Status messages**: Success/failure confirmations
- **Pipeline status**: Run state and results

## Error Handling

1. **Error**: `glab: command not found`
   **Cause**: glab CLI not installed
   **Solution**: Install via `brew install glab` or see https://gitlab.com/gitlab-org/cli

2. **Error**: `glab auth: No GitLab hosts configured`
   **Cause**: Not authenticated
   **Solution**: Run `glab auth login` and follow prompts

3. **Error**: `404 Project Not Found`
   **Cause**: Not in a git repo or repo not on GitLab
   **Solution**: Ensure you're in a git repo with GitLab remote, or use `-R owner/repo`

4. **Error**: `403 Forbidden`
   **Cause**: Insufficient permissions
   **Solution**: Check project access or request permissions

5. **Error**: `merge request create failed: The merge request has no commits`
   **Cause**: No changes to merge
   **Solution**: Ensure branch has commits ahead of target

## Examples

### Example 1: Create and Merge MR

**User Request**: "Create an MR for my feature branch"

**Commands**:
```bash
# Create MR with auto-fill from commits
glab mr create --fill

# After review, merge with squash
glab mr merge --squash --remove-source-branch
```

### Example 2: Triage Issues

**User Request**: "Show me open bugs assigned to me"

**Command**:
```bash
glab issue list --label bug --assignee=@me --state opened
```

**Output**:
```
Showing 2 of 2 issues

#42  Login timeout on slow networks    bug, priority::high   about 2 hours ago
#38  Session expires unexpectedly      bug                   about 1 day ago
```

### Example 3: Debug Failed Pipeline

**User Request**: "The CI failed, show me what went wrong"

**Commands**:
```bash
# View pipeline status
glab ci view

# Trace failed job logs
glab ci trace

# Or get specific job logs
glab ci trace lint
```

## Resources

- MR workflows: `{baseDir}/references/glab-mr-workflows.md`
- Issue workflows: `{baseDir}/references/glab-issue-workflows.md`
- CI/CD workflows: `{baseDir}/references/glab-ci-workflows.md`
- Official docs: https://gitlab.com/gitlab-org/cli/-/tree/main/docs
