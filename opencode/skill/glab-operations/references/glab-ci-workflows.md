# GitLab CI/CD Workflows

Comprehensive patterns for working with GitLab CI/CD pipelines using `glab ci` commands.

## Pipeline View

### Interactive View
```bash
# View pipeline for current branch (interactive)
glab ci view

# View pipeline for specific branch
glab ci view main

# View pipeline for tag
glab ci view v1.0.0
```

### Web View
```bash
# Open pipeline in browser
glab ci view --web

# Open specific branch's pipeline
glab ci view main --web
```

### Branch Option
```bash
# Explicit branch flag
glab ci view -b feature-branch
glab ci view --branch develop
```

## Pipeline Status

### Get Pipeline Info
```bash
# Get current pipeline status
glab ci get

# JSON output for scripting
glab ci get --output json

# Pretty print specific fields
glab ci get --output json | jq '{status, ref, sha}'
```

### Check Status in Scripts
```bash
# Get just the status
glab ci get --output json | jq -r '.status'

# Exit code based on status
status=$(glab ci get --output json | jq -r '.status')
if [ "$status" = "success" ]; then
  echo "Pipeline passed!"
else
  echo "Pipeline status: $status"
  exit 1
fi
```

### Include Jobs
```bash
# Get pipeline with job details
glab ci get --output json | jq '.jobs[]'

# List job names and statuses
glab ci get --output json | jq '.jobs[] | {name, status}'
```

### Variables (Maintainer+)
```bash
# Show pipeline variables (requires maintainer role)
glab ci get --with-variables
```

## Pipeline Listing

### List Recent Pipelines
```bash
# List pipelines
glab ci list

# Limit results
glab ci list --per-page 5
```

### Filter by Status
```bash
# Only failed pipelines
glab ci list --status failed

# Only successful
glab ci list --status success

# Running pipelines
glab ci list --status running

# Pending pipelines
glab ci list --status pending
```

### JSON Output
```bash
# Get JSON for scripting
glab ci list --output json

# Extract specific info
glab ci list --output json | jq '.[] | {id, status, ref}'
```

## Job Trace (Logs)

### Interactive Trace
```bash
# Select job interactively
glab ci trace

# Trace follows output in real-time for running jobs
```

### By Job ID
```bash
# Trace specific job by ID
glab ci trace 224356863
```

### By Job Name
```bash
# Trace by job name
glab ci trace lint
glab ci trace test
glab ci trace build
glab ci trace deploy
```

### With Pipeline/Branch
```bash
# Trace job from specific branch
glab ci trace lint -b main

# Trace job from specific pipeline
glab ci trace lint -p 123456789
```

## Job Management

### Retry Jobs
```bash
# Retry specific job
glab ci retry [job-id]

# Retry by job name
glab ci retry lint

# Retry from specific branch
glab ci retry lint -b feature-branch

# Retry from specific pipeline
glab ci retry test -p 123456789
```

### Trigger Manual Jobs
```bash
# Trigger manual job interactively
glab ci trigger

# Trigger specific job
glab ci trigger deploy-production

# Trigger by job ID
glab ci trigger 224356863

# From specific branch/pipeline
glab ci trigger deploy -b main
glab ci trigger deploy -p 123456789
```

### Cancel Jobs
```bash
# Cancel running pipeline (via pipeline delete or web)
glab ci view --web  # Then cancel from web UI
```

## Artifacts

### Download Artifacts
```bash
# Download artifacts from job
glab ci artifact [ref] [job-name]

# Download from main branch, job "build"
glab ci artifact main build

# Download from tag
glab ci artifact v1.0.0 build

# Download to specific directory
glab ci artifact main build --path ./artifacts/
```

### List Available Artifacts
```bash
# View pipeline info to see jobs with artifacts
glab ci get --output json | jq '.jobs[] | select(.artifacts_file) | {name, artifacts_file}'
```

## Pipeline Deletion

### Delete by ID
```bash
# Delete specific pipeline
glab ci delete 34

# Delete multiple
glab ci delete 12,34,56
```

### Delete by Status
```bash
# Delete all failed pipelines
glab ci delete --status=failed

# Delete all canceled pipelines
glab ci delete --status=canceled
```

### Delete by Age
```bash
# Delete pipelines older than 24 hours
glab ci delete --older-than 24h

# Delete old failed pipelines
glab ci delete --older-than 7d --status=failed

# Delete pipelines older than 30 days
glab ci delete --older-than 30d
```

### Delete by Source
```bash
# Delete pipelines from specific source
glab ci delete --source=api
glab ci delete --source=web
glab ci delete --source=push
```

## CI Linting

### Validate Config
```bash
# Lint .gitlab-ci.yml
glab ci lint

# Lint specific file
glab ci lint --path ./ci-config.yml
```

### Dry Run
```bash
# Simulate pipeline creation
glab ci lint --dry-run

# Include job details
glab ci lint --dry-run --include-jobs

# For specific ref
glab ci lint --dry-run --ref main
```

## Cross-Repository Operations

All commands support `-R` flag:

```bash
# View pipeline in another repo
glab ci view -R gitlab-org/gitlab

# Get pipeline status
glab ci get -R owner/project

# List pipelines
glab ci list -R owner/project

# Trace job logs
glab ci trace lint -R owner/project

# Download artifacts
glab ci artifact main build -R owner/project
```

## Common Patterns

### Wait for Pipeline to Complete
```bash
# Watch pipeline until completion
watch -n 10 'glab ci get --output json | jq "{status, ref}"'

# Or use view for interactive watching
glab ci view
```

### Debug Failed Pipeline
```bash
# 1. Check which jobs failed
glab ci get --output json | jq '.jobs[] | select(.status == "failed") | {name, stage}'

# 2. Get failed job logs
glab ci trace [failed-job-name]

# 3. Or view in browser for full context
glab ci view --web
```

### CI Status Before Merge
```bash
# Check if pipeline passed before merging
status=$(glab ci get --output json | jq -r '.status')
if [ "$status" = "success" ]; then
  glab mr merge --squash --remove-source-branch
else
  echo "Pipeline not successful: $status"
  exit 1
fi
```

### Retry All Failed Jobs
```bash
# Get failed jobs and retry each
glab ci get --output json | \
  jq -r '.jobs[] | select(.status == "failed") | .name' | \
  xargs -I {} glab ci retry {}
```

### Monitor Deployment
```bash
# Trigger deployment and trace logs
glab ci trigger deploy-staging
glab ci trace deploy-staging

# Or watch until complete
glab ci view
```

### Pipeline Duration Analysis
```bash
# Get pipeline duration
glab ci get --output json | jq '{
  duration: .duration,
  started_at: .started_at,
  finished_at: .finished_at
}'

# List recent pipelines with duration
glab ci list --output json | jq '.[] | {ref, status, duration}'
```

### Export Job Logs
```bash
# Save job logs to file
glab ci trace lint 2>&1 | tee lint-logs.txt

# All failed job logs
for job in $(glab ci get --output json | jq -r '.jobs[] | select(.status == "failed") | .name'); do
  echo "=== $job ===" >> failed-jobs.log
  glab ci trace "$job" >> failed-jobs.log 2>&1
done
```

## Pipeline Variables

### View Variables (Maintainer+)
```bash
# Get pipeline with variables
glab ci get --with-variables

# Extract variable values
glab ci get --with-variables --output json | jq '.variables'
```

### Trigger Pipeline with Variables
```bash
# Trigger pipeline via web (for variable input)
glab ci view --web

# Or use API (advanced)
# Variables can be passed when triggering pipelines via GitLab API
```

## Scheduled Pipelines

Note: `glab` doesn't have direct commands for scheduled pipelines yet. Use web UI:

```bash
# Open project schedules page
glab ci view --web  # Then navigate to CI/CD > Schedules
```

## Pipeline Badges

```bash
# Get pipeline status badge URL (for README)
# Format: https://gitlab.com/owner/repo/badges/branch/pipeline.svg

# Can view current status
glab ci get --output json | jq -r '"Pipeline: " + .status'
```

## Tips

### Efficient Log Viewing
```bash
# Stream logs as job runs
glab ci trace [job]  # Automatically streams

# Get only last N lines (pipe to tail)
glab ci trace [job] 2>&1 | tail -100
```

### JSON Filtering Examples
```bash
# Jobs by stage
glab ci get --output json | jq -r '.jobs | group_by(.stage) | .[] | {stage: .[0].stage, jobs: [.[].name]}'

# Failed jobs with failure reason
glab ci get --output json | jq '.jobs[] | select(.status == "failed") | {name, failure_reason, web_url}'

# Pipeline summary
glab ci get --output json | jq '{
  pipeline_id: .id,
  status: .status,
  ref: .ref,
  jobs_total: (.jobs | length),
  jobs_failed: ([.jobs[] | select(.status == "failed")] | length),
  jobs_passed: ([.jobs[] | select(.status == "success")] | length)
}'
```

### Integration with MRs
```bash
# Check MR's pipeline status
glab mr view [mr-id] --output json | jq '.pipeline'

# Wait for MR pipeline before merge
mr_status=$(glab mr view [mr-id] --output json | jq -r '.pipeline.status')
if [ "$mr_status" = "success" ]; then
  glab mr merge [mr-id]
fi
```
