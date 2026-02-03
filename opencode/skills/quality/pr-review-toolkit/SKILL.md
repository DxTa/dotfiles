# PR Review Toolkit

Comprehensive PR review toolkit with 6 specialized agents - comment-analyzer, pr-test-analyzer, silent-failure-hunter, type-design-analyzer, code-reviewer, and code-simplifier.

## When to Use

Use this skill when:
- Reviewing pull requests
- Analyzing PR comments and discussions
- Checking test coverage and test failures
- Hunting for silent failures and edge cases
- Reviewing type design and API signatures
- Simplifying complex code patterns
- Providing comprehensive PR feedback

## Specialized Agents

### 1. Comment Analyzer
- Analyze PR comments and discussions
- Identify unresolved issues and concerns
- Check for consensus among reviewers
- Identify blockers and critical feedback
- Summarize key discussion points

### 2. PR Test Analyzer
- Review test coverage for changes
- Check test failures and flakiness
- Analyze test performance impact
- Verify test assertions and edge cases
- Check for integration test gaps

### 3. Silent Failure Hunter
- Identify code that fails silently
- Find missing error handling
- Check for unhandled exceptions
- Identify ignored return values
- Find swallowed errors

### 4. Type Design Analyzer
- Review type definitions and interfaces
- Check for type safety issues
- Analyze API design consistency
- Identify type antipatterns
- Review type compatibility

### 5. Code Reviewer
- General code quality review
- Check coding standards and conventions
- Review performance implications
- Check security and best practices
- Identify maintainability issues

### 6. Code Simplifier
- Identify overly complex code
- Suggest simplifications
- Refactor for readability
- Reduce cognitive complexity
- Improve code organization

## Review Workflow

### Automated Analysis
```bash
# Run all agents
pr-review analyze --pr-url https://github.com/user/repo/pull/123

# Run specific agent
pr-review comment-analyzer --pr 123
pr-review test-analyzer --pr 123
pr-review silent-failure --pr 123
```

### Interactive Review
```bash
# Start interactive review session
pr-review interactive --pr 123

# Follow prompts for each agent
# Provide additional context as needed
```

## Agent-Specific Analysis

### Comment Analyzer
```python
# Analyze PR comments
def analyze_comments(pr_url):
    comments = fetch_pr_comments(pr_url)

    analysis = {
        'unresolved_issues': [],
        'concerns': [],
        'blockers': [],
        'consensus': None
    }

    for comment in comments:
        if '?' in comment.body and not has_reply(comment):
            analysis['unresolved_issues'].append(comment)

        if re.search(r'(?i)concern|worry|issue', comment.body):
            analysis['concerns'].append(comment)

        if comment.blocker:
            analysis['blockers'].append(comment)

    return analysis
```

### Test Analyzer
```python
# Analyze test coverage
def analyze_test_coverage(pr_files):
    coverage_diff = get_coverage_diff(pr_files)

    issues = []
    for file in pr_files:
        if file.new_lines > 0:
            if file.test_lines == 0:
                issues.append(f"Missing tests for {file.path}")
            if file.coverage < 80:
                issues.append(f"Low coverage in {file.path}: {file.coverage}%")

    return issues
```

### Silent Failure Hunter
```python
# Hunt for silent failures
def find_silent_failures(code_ast):
    issues = []

    # Find empty except blocks
    for node in code_ast.find_all('ExceptHandler'):
        if not node.body:
            issues.append("Empty except block at line {node.lineno}")

    # Find ignored return values
    for call in code_ast.find_all('Call'):
        if not is_result_used(call):
            issues.append(f"Ignored return value at line {call.lineno}")

    # Find missing error checks
    for node in code_ast.find_all('Call'):
        if is_likely_to_fail(node) and not has_error_handling(node):
            issues.append(f"Potential unhandled error at line {node.lineno}")

    return issues
```

### Type Design Analyzer
```python
# Analyze type design
def analyze_type_design(type_definitions):
    issues = []

    # Check for any types
    for type_def in type_definitions:
        if 'any' in type_def:
            issues.append(f"Avoid 'any' type in {type_def.name}")

        # Check for duplicate fields
        fields = type_def.get_fields()
        if len(fields) != len(set(fields)):
            issues.append(f"Duplicate fields in {type_def.name}")

    # Check for circular dependencies
    dependencies = build_dependency_graph(type_definitions)
    cycles = find_cycles(dependencies)
    for cycle in cycles:
        issues.append(f"Circular dependency: {' -> '.join(cycle)}")

    return issues
```

### Code Reviewer
```python
# General code review
def review_code(pr_diff):
    issues = []

    # Check for code smells
    for line in pr_diff.added_lines:
        if has_code_smell(line):
            issues.append(f"Code smell: {line}")

    # Check for security issues
    security_issues = scan_security(pr_diff)
    issues.extend(security_issues)

    # Check for performance issues
    perf_issues = scan_performance(pr_diff)
    issues.extend(perf_issues)

    return issues
```

### Code Simplifier
```python
# Simplify complex code
def simplify_code(code_block):
    suggestions = []

    # Detect nested if statements
    if has_nested_ifs(code_block, depth=3):
        suggestions.append("Extract nested conditions to separate methods")

    # Detect long functions
    if get_function_length(code_block) > 50:
        suggestions.append(f"Split long function ({get_function_length(code_block)} lines)")

    # Detect complex boolean logic
    if has_complex_logic(code_block):
        suggestions.append("Extract complex logic to named helper method")

    # Detect duplicated code
    duplicates = find_duplicates(code_block)
    if duplicates:
        suggestions.append(f"Extract duplicate code to shared function")

    return suggestions
```

## Best Practices

### Review Process
1. **Automated First**: Run all agents for initial feedback
2. **Context Aware**: Provide relevant context to each agent
3. **Prioritize Issues**: Focus on blockers and critical issues first
4. **Constructive Feedback**: Provide actionable suggestions
5. **Follow Up**: Verify issues are addressed

### Comment Analysis
- Identify all unresolved questions
- Check for conflicting feedback
- Summarize key decisions
- Note any blockers requiring resolution

### Test Review
- Verify tests cover new functionality
- Check for edge cases and error conditions
- Review test assertions and expected outcomes
- Ensure tests are maintainable and clear

### Error Handling
- No empty except blocks
- Proper error logging
- Graceful degradation
- User-friendly error messages

### Type Safety
- Avoid `any` types
- Use discriminated unions for variant types
- Consistent type naming
- Proper error types

## Integration with CI/CD

### GitHub Actions
```yaml
name: PR Review

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Run Comment Analyzer
        run: pr-review comment-analyzer --pr ${{ github.event.pull_request.number }}

      - name: Run Test Analyzer
        run: pr-review test-analyzer --pr ${{ github.event.pull_request.number }}

      - name: Run Silent Failure Hunter
        run: pr-review silent-failure --pr ${{ github.event.pull_request.number }}
```

## File Patterns

Look for:
- `**/.github/workflows/*.{yml,yaml}`
- `**/tests/**/*.{js,ts,py}`
- `**/types/**/*.ts`
- `**/*.d.ts`

## Keywords

PR review, pull request, code review, comment analysis, test analysis, silent failures, type design, code simplification, automated review, PR feedback
