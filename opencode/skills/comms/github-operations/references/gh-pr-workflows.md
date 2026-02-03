# Pull Request Workflows

Advanced patterns for PR management with `gh` CLI.

## PR Creation Patterns

### Basic Creation
```bash
# Interactive (prompts for title/body)
gh pr create

# With title and body
gh pr create --title "Feature: Add auth" --body "Implements OAuth2"

# Auto-fill from commit messages
gh pr create --fill

# Draft PR
gh pr create --draft --title "WIP: New feature"

# Specify base branch
gh pr create --base develop --title "Feature branch"
```

### With Metadata
```bash
# Add reviewers
gh pr create --reviewer user1,user2 --title "..."

# Add labels
gh pr create --label "enhancement,needs-review" --title "..."

# Add to milestone
gh pr create --milestone "v2.0" --title "..."

# Assign to users
gh pr create --assignee @me,user2 --title "..."

# All together
gh pr create \
  --title "Feature: User dashboard" \
  --body "Implements user dashboard with charts" \
  --reviewer teamlead \
  --label "feature,frontend" \
  --milestone "Q1-2025"
```

### From Web
```bash
# Create and open in browser
gh pr create --web
```

## PR Review Workflows

### Approve PR
```bash
gh pr review [number] --approve
gh pr review [number] --approve --body "LGTM!"
```

### Request Changes
```bash
gh pr review [number] --request-changes --body "Please address:
- Add unit tests
- Fix lint errors"
```

### Leave Comment (no verdict)
```bash
gh pr review [number] --comment --body "Some suggestions..."
```

### View Diff
```bash
# View diff in terminal
gh pr diff [number]

# View specific file diff
gh pr diff [number] -- path/to/file.js
```

### Check CI Status
```bash
gh pr checks [number]
gh pr checks [number] --watch  # Watch until complete
```

## PR Merge Strategies

### Squash Merge (Recommended)
```bash
gh pr merge [number] --squash
gh pr merge [number] --squash --delete-branch
```

### Merge Commit
```bash
gh pr merge [number] --merge
```

### Rebase
```bash
gh pr merge [number] --rebase
```

### Auto-Merge
```bash
# Enable auto-merge (merges when checks pass)
gh pr merge [number] --auto --squash

# Disable auto-merge
gh pr merge [number] --disable-auto
```

### Custom Commit Message
```bash
gh pr merge [number] --squash --subject "feat: add login" --body "Closes #42"
```

## PR Management

### Update PR
```bash
# Edit title
gh pr edit [number] --title "New title"

# Edit body
gh pr edit [number] --body "Updated description"

# Add reviewers
gh pr edit [number] --add-reviewer user1

# Add labels
gh pr edit [number] --add-label "urgent"

# Remove labels
gh pr edit [number] --remove-label "wip"
```

### Ready for Review
```bash
# Mark draft as ready
gh pr ready [number]
```

### Convert to Draft
```bash
gh pr ready [number] --undo
```

### Close/Reopen
```bash
gh pr close [number]
gh pr close [number] --comment "Superseded by #456"
gh pr reopen [number]
```

## Listing and Filtering PRs

### Basic Listing
```bash
gh pr list
gh pr list --state all  # Open, closed, merged
gh pr list --state merged --limit 10
```

### Filter by Author
```bash
gh pr list --author @me
gh pr list --author username
```

### Filter by Labels
```bash
gh pr list --label bug
gh pr list --label "bug,urgent"
```

### Filter by Base/Head Branch
```bash
gh pr list --base main
gh pr list --head feature-branch
```

### Search PRs
```bash
gh pr list --search "login in:title"
gh pr list --search "author:@me is:open"
```

### JSON Output
```bash
gh pr list --json number,title,author
gh pr list --json number,title,state --jq '.[] | select(.state=="OPEN")'
```

## Working with PRs Locally

### Checkout PR
```bash
# Checkout PR branch
gh pr checkout [number]

# Checkout and create local branch with custom name
gh pr checkout [number] --branch my-local-name
```

### View PR in Browser
```bash
gh pr view [number] --web
```

### View PR Comments
```bash
gh pr view [number] --comments
```

## Cross-Repository PRs

### Create PR to Upstream
```bash
# Fork workflow: PR from your fork to upstream
gh pr create --repo upstream/repo --head youruser:feature-branch
```

### List PRs in Another Repo
```bash
gh pr list --repo owner/repo
```
