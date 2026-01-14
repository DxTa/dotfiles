# GitLab Issue Workflows

Comprehensive patterns for working with GitLab issues using `glab issue` commands.

## Issue Creation Patterns

### Basic Creation
```bash
# Create with title and description
glab issue create --title "Bug: Login fails" --description "Steps to reproduce..."

# Interactive creation (opens editor)
glab issue create

# Open web form
glab issue create --web
```

### With Metadata
```bash
# Assign to yourself with labels
glab issue create --title "Add feature X" \
  --assignee @me \
  --label "feature" \
  --label "frontend"

# With milestone
glab issue create --title "Fix performance" \
  --milestone "v2.0" \
  --label "performance"

# With due date
glab issue create --title "Quarterly report" \
  --due-date "2024-12-31"
```

### Confidential Issues
```bash
# Create confidential issue (only visible to project members)
glab issue create --title "Security: SQL injection" \
  --description "Found vulnerability in..." \
  --confidential \
  --label "security"
```

### Weighted Issues
```bash
# Issue with weight (for planning)
glab issue create --title "Refactor auth module" \
  --weight 5
```

### From File
```bash
# Read description from file
glab issue create --title "Feature spec" \
  --description "$(cat feature-spec.md)"
```

### Link to Epic
```bash
# Associate with epic
glab issue create --title "Sub-task 1" \
  --epic 42
```

### Link Issues Together
```bash
# Create issue linked to existing issues
glab issue create --title "Related bug" \
  --linked-issues 10,15 \
  --link-type "relates_to"

# Link types: relates_to, blocks, is_blocked_by
```

### Link to MR
```bash
# Create issue linked to existing MR
glab issue create --title "Follow-up from MR" \
  --linked-mr 123
```

### Time Tracking
```bash
# Create with time estimate
glab issue create --title "Complex feature" \
  --time-estimate "3d" \
  --time-spent "0h"
```

## Issue Listing and Filtering

### Basic Listing
```bash
# List open issues
glab issue list

# List all issues
glab issue list --all
```

### Filter by State
```bash
# Open issues (default)
glab issue list --state opened

# Closed issues
glab issue list --state closed

# All states
glab issue list --state all
```

### Filter by Assignment
```bash
# Assigned to you
glab issue list --assignee=@me

# Assigned to specific user
glab issue list --assignee=alice

# Unassigned issues
glab issue list --assignee=""
```

### Filter by Labels
```bash
# With specific label
glab issue list --label "bug"

# Multiple labels (AND logic)
glab issue list --label "bug" --label "priority::high"

# Issues without a label (use not-label)
glab issue list --not-label "in-progress"
```

### Filter by Author
```bash
# Created by you
glab issue list --author=@me

# Created by specific user
glab issue list --author=alice
```

### Filter by Milestone
```bash
# In specific milestone
glab issue list --milestone "v1.0"

# Issues without milestone
glab issue list --milestone ""
```

### Search
```bash
# Search in title and description
glab issue list --search "authentication"

# Search with filters
glab issue list --search "login" --label "bug" --state opened
```

### Pagination
```bash
# Limit results
glab issue list --per-page 20

# Get specific page
glab issue list --per-page 50 --page 2
```

### JSON Output
```bash
# Get JSON for scripting
glab issue list --output json

# Extract specific fields
glab issue list --output json | jq '.[] | {iid, title, labels}'

# Count issues by label
glab issue list --output json | jq -r '.[].labels[]' | sort | uniq -c
```

## Issue View

### Basic View
```bash
# View issue details
glab issue view 42

# By URL
glab issue view https://gitlab.com/owner/repo/-/issues/42
```

### With Comments
```bash
# Include all comments
glab issue view 42 --comments
```

### In Browser
```bash
# Open in default browser
glab issue view 42 --web
```

### JSON Output
```bash
# Get full JSON details
glab issue view 42 --output json

# Extract specific fields
glab issue view 42 --output json | jq '{title, state, assignees, labels}'
```

## Issue Management

### Close Issues
```bash
# Close single issue
glab issue close 42

# Close by URL
glab issue close https://gitlab.com/owner/repo/-/issues/42
```

### Reopen Issues
```bash
# Reopen closed issue
glab issue reopen 42
```

### Delete Issues
```bash
# Delete issue (requires maintainer+ permissions)
glab issue delete 42

# Delete by URL
glab issue delete https://gitlab.com/owner/repo/-/issues/42
```

### Update Issues
```bash
# Update title
glab issue update 42 --title "New title"

# Update description
glab issue update 42 --description "Updated description"

# Add labels
glab issue update 42 --label "in-progress"

# Remove labels
glab issue update 42 --unlabel "needs-triage"

# Change assignee
glab issue update 42 --assignee @alice

# Set milestone
glab issue update 42 --milestone "v1.0"

# Mark as confidential
glab issue update 42 --confidential
```

## Issue Comments

### Add Comment
```bash
# Simple comment
glab issue note 42 -m "Looking into this"

# Multi-line comment
glab issue note 42 -m "$(cat <<'EOF'
## Investigation Results

1. Root cause identified
2. Fix in progress

🤖 Generated with [Claude Code](https://claude.ai/code)
EOF
)"
```

### Edit Comment
```bash
# Edit a specific comment (via web)
glab issue view 42 --web
```

## Issue Subscription

### Subscribe
```bash
# Subscribe to issue updates
glab issue subscribe 42

# By URL
glab issue subscribe https://gitlab.com/owner/repo/-/issues/42
```

### Unsubscribe
```bash
# Stop receiving notifications
glab issue unsubscribe 42
```

## Cross-Repository Operations

All commands support `-R` flag:

```bash
# List issues in another repo
glab issue list -R gitlab-org/gitlab

# View issue in another repo
glab issue view 42 -R owner/project

# Create issue in another repo
glab issue create --title "Bug report" -R owner/project

# Close issue in another repo
glab issue close 123 -R owner/project
```

## Linking Issues to MRs

### Close Issue via MR

Use these keywords in MR description to auto-close issues:

| Keyword | Example |
|---------|---------|
| `Closes` | `Closes #42` |
| `Fixes` | `Fixes #42` |
| `Resolves` | `Resolves #42` |

**Multiple issues**:
```
Closes #42, #43, #44
```

**Cross-project issues**:
```
Closes gitlab-org/gitlab#123
```

### Create MR from Issue
```bash
# Create MR that references issue
glab mr for 42
```

### View MR Issues
```bash
# List issues that will be closed by MR
glab mr issues 42
```

## Common Patterns

### Triage Workflow
```bash
# 1. List unassigned bugs
glab issue list --label "bug" --assignee="" --state opened

# 2. View specific issue
glab issue view 42

# 3. Assign and label
glab issue update 42 --assignee @me --label "in-progress"

# 4. Add comment
glab issue note 42 -m "$(cat <<'EOF'
Taking this on. Will investigate and provide update by EOD.

🤖 Generated with [Claude Code](https://claude.ai/code)
EOF
)"
```

### Bug Report Template
```bash
glab issue create \
  --title "Bug: [Component] Brief description" \
  --label "bug" \
  --label "needs-triage" \
  --description "$(cat <<'EOF'
## Description
Brief description of the bug.

## Steps to Reproduce
1. Step one
2. Step two
3. Step three

## Expected Behavior
What should happen.

## Actual Behavior
What actually happens.

## Environment
- OS:
- Browser/Version:
- GitLab Version:

🤖 Generated with [Claude Code](https://claude.ai/code)
EOF
)"
```

### Feature Request Template
```bash
glab issue create \
  --title "Feature: Brief description" \
  --label "feature" \
  --label "needs-discussion" \
  --description "$(cat <<'EOF'
## Summary
Brief summary of the feature request.

## Problem Statement
What problem does this solve?

## Proposed Solution
How should this work?

## Alternatives Considered
Other approaches considered.

## Additional Context
Any other relevant information.

🤖 Generated with [Claude Code](https://claude.ai/code)
EOF
)"
```

### Batch Operations
```bash
# Close multiple issues
glab issue close 1 2 3 4 5

# Subscribe to multiple issues
for i in 10 11 12; do glab issue subscribe $i; done

# Add label to multiple issues via API (example with jq)
glab issue list --output json | \
  jq -r '.[] | select(.labels | index("needs-review") | not) | .iid' | \
  head -10 | \
  xargs -I {} glab issue update {} --label "reviewed"
```

### Export Issues
```bash
# Export all open issues to JSON file
glab issue list --state opened --output json > issues.json

# Export with specific fields
glab issue list --output json | \
  jq '[.[] | {iid, title, labels, assignees: [.assignees[].username], state}]' \
  > issues-summary.json
```
