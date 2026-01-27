# Code Review Plugin

Automated PR code review using multiple specialized agents with confidence-based scoring - CLAUDE.md compliance, bug detection, and git history analysis.

## When to Use

Use this skill when:
- Automating PR code reviews
- Checking compliance with coding standards
- Detecting bugs and issues
- Analyzing git history for patterns
- Scoring PR quality
- Providing actionable review feedback

## Core Components

### Confidence-Based Scoring
- **High Confidence (90-100%)**: Clear issues, definitive findings
- **Medium Confidence (60-89%)**: Likely issues, context-dependent
- **Low Confidence (<60%)**: Potential concerns, needs review

### Specialized Agents
1. **CLAUDE.md Compliance Agent**: Checks adherence to project-specific rules
2. **Bug Detection Agent**: Identifies potential bugs and logic errors
3. **Git History Agent**: Analyzes historical patterns and author patterns

## Agent Implementations

### CLAUDE.md Compliance Agent
```python
class ClaudeMdComplianceAgent:
    def __init__(self, claude_md_path):
        self.rules = self.load_claude_md(claude_md_path)

    def review(self, pr_diff):
        """
        Review PR for CLAUDE.md compliance
        """
        findings = []

        for file_change in pr_diff.changed_files:
            # Check against project rules
            violations = self.check_file_compliance(
                file_change,
                self.rules
            )

            for violation in violations:
                findings.append({
                    'file': file_change.path,
                    'line': violation.line,
                    'rule': violation.rule,
                    'message': violation.message,
                    'confidence': violation.confidence,
                    'severity': violation.severity
                })

        return findings

    def check_file_compliance(self, file_change, rules):
        """
        Check specific file against rules
        """
        violations = []

        # Check naming conventions
        if rules.get('naming_conventions'):
            violations.extend(
                self.check_naming(file_change, rules['naming_conventions'])
            )

        # Check code organization
        if rules.get('code_organization'):
            violations.extend(
                self.check_organization(file_change, rules['code_organization'])
            )

        # Check specific language rules
        language = self.detect_language(file_change.path)
        if language in rules.get('language_rules', {}):
            violations.extend(
                self.check_language_rules(
                    file_change,
                    rules['language_rules'][language]
                )
            )

        return violations
```

### Bug Detection Agent
```python
class BugDetectionAgent:
    def review(self, pr_diff):
        """
        Detect potential bugs in PR
        """
        findings = []

        # Common bug patterns
        bug_patterns = {
            'null_dereference': r'\w+\.[A-Z]\w+\(?',
            'off_by_one': r'for\s+\w+\s*=\s*0\s*;\s*\w+\s*<\s*len\([^)]+\)\s*;\s*\w+\+\+',
            'race_condition': r'if\s*\([^)]*==\s*[^)]*\)\s*{[^}]*\1\s*=',
            'uninitialized': r'if\s*\([^)]+\)\s*{[^}]*\w+\s*=\s*[^;};]+;\s*}'
        }

        for file_change in pr_diff.changed_files:
            for line_num, line in file_change.added_lines:
                # Check against bug patterns
                for pattern_name, pattern in bug_patterns.items():
                    if re.search(pattern, line):
                        findings.append({
                            'file': file_change.path,
                            'line': line_num,
                            'type': pattern_name,
                            'message': f"Potential {pattern_name.replace('_', ' ')}",
                            'code': line,
                            'confidence': 70,
                            'severity': 'high'
                        })

        return findings

    def analyze_data_flow(self, pr_diff):
        """
        Analyze data flow for potential issues
        """
        findings = []

        # Check for type mismatches
        findings.extend(self.check_type_mismatches(pr_diff))

        # Check for missing null checks
        findings.extend(self.check_null_safety(pr_diff))

        # Check for resource leaks
        findings.extend(self.check_resource_leaks(pr_diff))

        return findings
```

### Git History Agent
```python
class GitHistoryAgent:
    def __init__(self, repo_path):
        self.repo = git.Repo(repo_path)

    def analyze_author_patterns(self, author_email):
        """
        Analyze author's past commits
        """
        commits = list(self.repo.iter_commits(author=author_email))

        patterns = {
            'total_commits': len(commits),
            'files_touched': set(),
            'common_patterns': {},
            'bug_rate': 0
        }

        # Analyze each commit
        for commit in commits:
            patterns['files_touched'].update(commit.stats.files)

            # Check if commit was a bug fix
            if self.is_bug_fix(commit.message):
                patterns['bug_rate'] += 1

        patterns['bug_rate'] = patterns['bug_rate'] / len(commits)

        # Analyze common patterns
        patterns['common_patterns'] = self.extract_patterns(commits)

        return patterns

    def analyze_commit_frequency(self, pr_diff):
        """
        Analyze commit frequency and patterns
        """
        findings = []

        # Check for "WIP" or "TODO" commits
        for commit in pr_diff.commits:
            if re.search(r'(?i)wip|todo|fixme', commit.message):
                findings.append({
                    'type': 'commit_quality',
                    'message': 'Commit contains WIP/TODO marker',
                    'commit': commit.sha,
                    'confidence': 95,
                    'severity': 'medium'
                })

        return findings

    def analyze_code_churn(self, file_path):
        """
        Analyze code churn for a file
        """
        churn = {
            'total_changes': 0,
            'authors': set(),
            'time_between_changes': []
        }

        for commit in self.repo.iter_commits(paths=file_path):
            churn['total_changes'] += 1
            churn['authors'].add(commit.author.email)

        return churn
```

## Confidence Scoring

### Calculate Overall Confidence
```python
def calculate_confidence(findings):
    """
    Calculate overall confidence score
    """
    if not findings:
        return 100

    # Weight by severity
    weights = {'high': 1.0, 'medium': 0.7, 'low': 0.4}

    total_confidence = 0
    total_weight = 0

    for finding in findings:
        weight = weights.get(finding['severity'], 0.5)
        total_confidence += finding['confidence'] * weight
        total_weight += weight

    return total_confidence / total_weight if total_weight > 0 else 0
```

## Integration

### GitHub Actions Workflow
```yaml
name: Automated Code Review

on:
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0

      - name: Run Code Review
        run: |
          python code_review_plugin.py \
            --pr-url ${{ github.event.pull_request.html_url }} \
            --token ${{ secrets.GITHUB_TOKEN }}

      - name: Post Review
        uses: actions/github-script@v6
        with:
          script: |
            const fs = require('fs');
            const review = JSON.parse(fs.readFileSync('review.json'));
            // Post review comments
```

### CLI Usage
```bash
# Run review on PR
code-review --pr https://github.com/user/repo/pull/123

# Run review on local changes
code-review --diff

# Generate report
code-review --pr 123 --output report.html
```

## Best Practices

### Agent Design
- Each agent should be independent
- Clear separation of concerns
- Document confidence calculation logic
- Handle edge cases gracefully

### Confidence Levels
- Be conservative with high confidence
- Provide context for lower confidence
- Allow manual review override
- Track confidence accuracy over time

### Feedback
- Provide actionable recommendations
- Include code snippets
- Reference relevant rules
- Suggest fixes where possible

## File Patterns

Look for:
- `**/.github/workflows/review*.yml`
- `**/CLAUDE.md`
- `**/.reviewconfig.json`
- `**/.github/CODEOWNERS`

## Keywords

Code review, automated review, PR review, bug detection, compliance scoring, confidence scoring, git history, CLAUDE.md, static analysis
