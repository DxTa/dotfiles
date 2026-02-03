# GitLab Merge Request Workflows

Comprehensive patterns for working with GitLab merge requests using `glab mr` commands.

## MR Creation Patterns

### Basic Creation
```bash
# Create MR with title and description
glab mr create --title "Add feature X" --description "Implementation details"

# Auto-fill from commit messages
glab mr create --fill

# Open web editor for creation
glab mr create --web
```

### With Metadata
```bash
# Assign reviewers and labels
glab mr create --fill --reviewer @alice --label "needs-review"

# Assign to yourself with milestone
glab mr create --fill --assignee @me --milestone "v1.0"

# Multiple labels
glab mr create --fill --label "feature" --label "frontend"
```

### Draft/WIP MRs
```bash
# Create as draft (not ready for review)
glab mr create --fill --draft

# Create as Work In Progress
glab mr create --fill --wip

# Mark existing MR as ready
glab mr update [number] --ready
```

### MR for Issue
```bash
# Create MR that closes issue #34 when merged
glab mr for 34

# Create as WIP/draft
glab mr for 34 --wip
glab mr for 34 --draft

# With custom branch name
glab mr for 34 --branch "fix-issue-34"
```

### Target Branch
```bash
# Target specific branch (default: default branch)
glab mr create --fill --target-branch develop

# From specific source branch
glab mr create --fill --source-branch feature-x --target-branch main
```

## MR Review Workflows

### Approve MRs
```bash
# Approve single MR
glab mr approve 235

# Approve multiple MRs
glab mr approve 123 345

# Approve by branch name
glab mr approve feature-branch

# Approve from current branch
glab mr approve

# Approve with SHA verification
glab mr approve 235 --sha abc123def
```

### Add Review Comments
```bash
# Add note/comment to MR
glab mr note 42 -m "Looks good, but consider refactoring line 50"

# Multi-line comment
glab mr note 42 -m "$(cat <<'EOF'
## Review Notes

1. Consider adding error handling
2. Missing unit tests for edge cases

🤖 Generated with [Claude Code](https://claude.ai/code)
EOF
)"
```

### View Diff
```bash
# View MR diff
glab mr diff 42

# View with context
glab mr diff 42 --color always | less -R
```

### Check CI Status
```bash
# View CI status for MR
glab mr view 42

# Check if CI passed (in JSON)
glab mr view 42 --output json | jq '.pipeline.status'
```

## MR Merge Strategies

### Basic Merge
```bash
# Standard merge
glab mr merge 235

# By branch name
glab mr merge feature-branch

# Merge current branch's MR
glab mr merge
```

### Squash Merge
```bash
# Squash all commits into one
glab mr merge 235 --squash

# With custom commit message
glab mr merge 235 --squash --message "feat: Add user authentication"
```

### Rebase Merge
```bash
# Rebase before merge
glab mr merge 235 --rebase
```

### Auto-Merge
```bash
# Enable auto-merge when pipeline succeeds
glab mr merge 235 --auto-merge

# Also known as "merge when pipeline succeeds"
glab mr merge 235 --when-pipeline-succeeds
```

### Cleanup Options
```bash
# Delete source branch after merge
glab mr merge 235 --remove-source-branch

# Squash + delete branch
glab mr merge 235 --squash --remove-source-branch

# Skip confirmation
glab mr merge 235 --yes
```

## MR Management

### Edit MR
```bash
# Update title
glab mr update 42 --title "New title"

# Update description
glab mr update 42 --description "Updated description"

# Add labels
glab mr update 42 --label "bug" --label "priority::high"

# Assign reviewers
glab mr update 42 --reviewer @alice --reviewer @bob

# Change target branch
glab mr update 42 --target-branch develop
```

### Mark Ready for Review
```bash
# Remove draft/WIP status
glab mr update 42 --ready
```

### Close/Reopen
```bash
# Close MR
glab mr close 42

# Close multiple MRs
glab mr close 1 2 3 4

# Reopen MR
glab mr reopen 42
```

### Delete MR
```bash
# Delete MR by ID
glab mr delete 123

# Delete multiple
glab mr delete 123 456 789

# Delete by branch
glab mr delete feature-branch
```

## Listing and Filtering MRs

### Basic Listing
```bash
# List all open MRs
glab mr list

# List all MRs (any state)
glab mr list --all
```

### Filter by State
```bash
# Open MRs (default)
glab mr list --state opened

# Merged MRs
glab mr list --state merged

# Closed MRs
glab mr list --state closed
```

### Filter by Assignment
```bash
# Assigned to you
glab mr list --assignee=@me

# Assigned to specific user
glab mr list --assignee=alice

# You are reviewer
glab mr list --reviewer=@me
```

### Filter by Branch
```bash
# By source branch
glab mr list --source-branch=feature-x

# By target branch
glab mr list --target-branch=main
```

### Filter by Labels
```bash
# With specific label
glab mr list --label "needs-review"

# Exclude labels
glab mr list --not-label "work-in-progress"
```

### Filter by Draft Status
```bash
# Only drafts
glab mr list --draft

# Exclude drafts
glab mr list --not-draft
```

### Search
```bash
# Search by title/description
glab mr list --search "authentication"
```

### Pagination
```bash
# Limit results
glab mr list --per-page 10

# With pagination (use for scripts)
glab mr list --per-page 100 --page 2
```

### JSON Output
```bash
# Get JSON for scripting
glab mr list --output json

# Filter with jq
glab mr list --output json | jq '.[] | {iid, title, author}'
```

## Local MR Operations

### Checkout MR
```bash
# Checkout MR branch locally
glab mr checkout 42

# Checkout by branch name
glab mr checkout feature-branch
```

### View in Browser
```bash
# Open MR in browser
glab mr view 42 --web

# View diff in browser
glab mr view 42 --web
```

### View Details
```bash
# View MR summary
glab mr view 42

# Include comments
glab mr view 42 --comments

# View as JSON
glab mr view 42 --output json
```

## Cross-Repository Operations

All commands support `-R` flag for cross-repository operations:

```bash
# List MRs in another repo
glab mr list -R gitlab-org/gitlab

# View MR in another repo
glab mr view 42 -R owner/project

# Create MR in another repo
glab mr create --fill -R owner/project

# Approve MR in another repo
glab mr approve 123 -R owner/project
```

## Linking MRs to Issues

### Auto-close Issues
Use keywords in MR description to auto-close issues:

```bash
glab mr create --title "Fix login bug" --description "$(cat <<'EOF'
Fixes #42

This MR resolves the login timeout issue by...

🤖 Generated with [Claude Code](https://claude.ai/code)
EOF
)"
```

**Supported keywords** (case-insensitive):
- `Closes #123`
- `Fixes #123`
- `Resolves #123`

### List Issues for MR
```bash
# List issues that will be closed
glab mr issues 42

# By branch name
glab mr issues feature-branch
```

## Common Patterns

### Review and Merge Workflow
```bash
# 1. List MRs needing your review
glab mr list --reviewer=@me

# 2. View MR details
glab mr view 42 --comments

# 3. Checkout and test locally
glab mr checkout 42

# 4. Approve
glab mr approve 42

# 5. Merge
glab mr merge 42 --squash --remove-source-branch
```

### Create MR for Hotfix
```bash
# Create MR targeting production branch
glab mr create --fill \
  --target-branch production \
  --label "hotfix" \
  --label "priority::critical" \
  --reviewer @oncall-team
```

### Batch Close Old MRs
```bash
# List old MRs (JSON for processing)
glab mr list --state opened --output json | \
  jq -r '.[] | select(.created_at < "2024-01-01") | .iid' | \
  xargs -I {} glab mr close {}
```
