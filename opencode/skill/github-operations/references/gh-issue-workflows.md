# Issue Workflows

Advanced patterns for issue management with `gh` CLI.

## Issue Creation

### Basic Creation
```bash
# Interactive
gh issue create

# With title and body
gh issue create --title "Bug: Login fails" --body "Steps to reproduce..."

# Open editor for body
gh issue create --title "Feature request" --editor
```

### With Metadata
```bash
# Add labels
gh issue create --title "..." --label "bug,priority:high"

# Assign to users
gh issue create --title "..." --assignee @me
gh issue create --title "..." --assignee user1,user2

# Add to milestone
gh issue create --title "..." --milestone "v2.0"

# Add to project
gh issue create --title "..." --project "Sprint 1"

# All together
gh issue create \
  --title "Bug: Session timeout" \
  --body "Sessions expire after 5 minutes instead of 30" \
  --label "bug,backend" \
  --assignee @me \
  --milestone "v1.5"
```

### From File
```bash
# Body from file
gh issue create --title "..." --body-file issue_template.md
```

### Web Creation
```bash
gh issue create --web
```

## Issue Listing

### Basic Listing
```bash
gh issue list
gh issue list --state all
gh issue list --state closed
```

### Filter by Labels
```bash
gh issue list --label bug
gh issue list --label "bug,urgent"
gh issue list --label "priority:high"
```

### Filter by Assignee
```bash
gh issue list --assignee @me
gh issue list --assignee username
gh issue list --assignee ""  # Unassigned
```

### Filter by Author
```bash
gh issue list --author @me
gh issue list --author username
```

### Filter by Milestone
```bash
gh issue list --milestone "v2.0"
```

### Search Issues
```bash
gh issue list --search "login in:title"
gh issue list --search "is:open label:bug"
gh issue list --search "author:@me created:>2024-01-01"
```

### Limit and Sort
```bash
gh issue list --limit 50
gh issue list --json number,title,createdAt --jq 'sort_by(.createdAt) | reverse'
```

### JSON Output
```bash
gh issue list --json number,title,labels,assignees
gh issue list --json number,title --jq '.[] | "\(.number): \(.title)"'
```

## Issue Management

### View Issue
```bash
gh issue view [number]
gh issue view [number] --web
gh issue view [number] --comments
```

### Edit Issue
```bash
# Edit title
gh issue edit [number] --title "New title"

# Edit body
gh issue edit [number] --body "Updated description"

# Add labels
gh issue edit [number] --add-label "in-progress"

# Remove labels
gh issue edit [number] --remove-label "needs-triage"

# Change assignees
gh issue edit [number] --add-assignee user1
gh issue edit [number] --remove-assignee user2
```

### Close Issue
```bash
gh issue close [number]
gh issue close [number] --comment "Fixed in PR #123"
gh issue close [number] --reason "not planned"
gh issue close [number] --reason "completed"
```

### Reopen Issue
```bash
gh issue reopen [number]
gh issue reopen [number] --comment "Reopening: issue persists"
```

### Delete Issue
```bash
gh issue delete [number] --yes
```

## Issue Comments

### Add Comment
```bash
gh issue comment [number] --body "Working on this now"
gh issue comment [number] --body-file comment.md
gh issue comment [number] --editor
```

### Edit Comment
```bash
# Edit last comment
gh issue comment [number] --edit-last --body "Updated comment"
```

### Web Comment
```bash
gh issue comment [number] --web
```

## Issue Transfer

### Transfer to Another Repo
```bash
gh issue transfer [number] owner/other-repo
```

## Issue Pin/Unpin
```bash
gh issue pin [number]
gh issue unpin [number]
```

## Issue Lock/Unlock
```bash
gh issue lock [number]
gh issue lock [number] --reason "resolved"
gh issue unlock [number]
```

## Cross-Repository Issues

### View Issue in Another Repo
```bash
gh issue view [number] --repo owner/repo
```

### List Issues in Another Repo
```bash
gh issue list --repo owner/repo
```

### Create Issue in Another Repo
```bash
gh issue create --repo owner/repo --title "..."
```

## Linking Issues and PRs

### Reference Issue in PR
When creating a PR, use keywords in body:
- `Fixes #123` - Closes issue when PR merges
- `Closes #123` - Same as Fixes
- `Resolves #123` - Same as Fixes
- `Relates to #123` - Links without auto-close

### Link PR to Issue
```bash
gh pr edit [pr-number] --body "Fixes #[issue-number]"
```

## Bulk Operations

### Close Multiple Issues
```bash
# Close issues matching criteria
gh issue list --label "wontfix" --json number --jq '.[].number' | \
  xargs -I {} gh issue close {}
```

### Add Label to Multiple Issues
```bash
gh issue list --search "is:open" --json number --jq '.[].number' | \
  xargs -I {} gh issue edit {} --add-label "needs-review"
```
