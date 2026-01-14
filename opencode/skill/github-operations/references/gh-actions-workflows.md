# GitHub Actions Workflows

Advanced patterns for monitoring and managing GitHub Actions with `gh` CLI.

## Listing Workflow Runs

### Basic Listing
```bash
gh run list
gh run list --limit 20
```

### Filter by Workflow
```bash
gh run list --workflow=ci.yml
gh run list --workflow="Build and Test"
```

### Filter by Status
```bash
gh run list --status failure
gh run list --status success
gh run list --status in_progress
gh run list --status queued
```

### Filter by Branch
```bash
gh run list --branch main
gh run list --branch feature-branch
```

### Filter by User
```bash
gh run list --user @me
gh run list --user username
```

### Filter by Event
```bash
gh run list --event push
gh run list --event pull_request
gh run list --event workflow_dispatch
```

### JSON Output
```bash
gh run list --json databaseId,displayTitle,status,conclusion
gh run list --json status --jq '.[] | select(.status=="failure")'
```

## Viewing Run Details

### Basic View
```bash
gh run view [run-id]
```

### View with Jobs
```bash
gh run view [run-id] --job [job-id]
```

### View Logs
```bash
# All logs
gh run view [run-id] --log

# Failed jobs only
gh run view [run-id] --log-failed

# Specific job logs
gh run view [run-id] --job [job-id] --log
```

### Exit Code (for scripting)
```bash
gh run view [run-id] --exit-status
# Returns 0 if successful, non-zero otherwise
```

### Open in Browser
```bash
gh run view [run-id] --web
```

## Watching Runs

### Watch Live
```bash
gh run watch [run-id]
```

### Watch with Exit Code
```bash
gh run watch [run-id] --exit-status
# Waits for completion and returns appropriate exit code
```

### Watch Latest Run
```bash
# Watch most recent run for current branch
gh run watch
```

## Re-running Workflows

### Re-run All Jobs
```bash
gh run rerun [run-id]
```

### Re-run Failed Jobs Only
```bash
gh run rerun [run-id] --failed
```

### Re-run with Debug Logging
```bash
gh run rerun [run-id] --debug
```

## Downloading Artifacts

### List Artifacts
```bash
gh run view [run-id] --json artifacts
```

### Download All Artifacts
```bash
gh run download [run-id]
```

### Download Specific Artifact
```bash
gh run download [run-id] --name artifact-name
```

### Download to Specific Directory
```bash
gh run download [run-id] --dir ./artifacts
```

## Canceling Runs

### Cancel a Run
```bash
gh run cancel [run-id]
```

## Workflow Management

### List Workflows
```bash
gh workflow list
gh workflow list --all  # Include disabled
```

### View Workflow
```bash
gh workflow view ci.yml
gh workflow view ci.yml --web
```

### Enable/Disable Workflow
```bash
gh workflow enable ci.yml
gh workflow disable ci.yml
```

### Trigger Workflow Manually
```bash
# Trigger workflow_dispatch event
gh workflow run ci.yml

# With inputs
gh workflow run ci.yml --field name=value

# On specific branch
gh workflow run ci.yml --ref feature-branch
```

## Common Patterns

### Wait for CI Before Merge
```bash
# Start watching current PR's checks
gh pr checks --watch

# Or watch specific run
gh run watch [run-id] --exit-status && gh pr merge --squash
```

### Debug Failed Run
```bash
# 1. Find failed run
gh run list --status failure --limit 5

# 2. View failed job logs
gh run view [run-id] --log-failed

# 3. Re-run with debug
gh run rerun [run-id] --debug --failed
```

### Monitor Deployment
```bash
# Watch deployment workflow
gh run list --workflow=deploy.yml --limit 1 --json databaseId --jq '.[0].databaseId' | \
  xargs gh run watch
```

### Get Latest Successful Run
```bash
gh run list --status success --limit 1 --json databaseId --jq '.[0].databaseId'
```

### Download Latest Artifact
```bash
# Get latest successful run ID and download
RUN_ID=$(gh run list --status success --limit 1 --json databaseId --jq '.[0].databaseId')
gh run download $RUN_ID --name build-artifact
```

## Cross-Repository

### View Runs in Another Repo
```bash
gh run list --repo owner/repo
gh run view [run-id] --repo owner/repo
```

### Trigger Workflow in Another Repo
```bash
gh workflow run ci.yml --repo owner/repo
```

## JSON Queries

### Failed Runs with Details
```bash
gh run list --status failure --json databaseId,displayTitle,conclusion,headBranch \
  --jq '.[] | "\(.databaseId): \(.displayTitle) (\(.headBranch))"'
```

### Run Duration
```bash
gh run view [run-id] --json createdAt,updatedAt \
  --jq '"Started: \(.createdAt), Completed: \(.updatedAt)"'
```

### Jobs Summary
```bash
gh run view [run-id] --json jobs \
  --jq '.jobs[] | "\(.name): \(.conclusion)"'
```
