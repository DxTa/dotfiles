# Test Coverage Analyzer

Test coverage analyzer for identifying untested code and analyzing coverage metrics.

## When to Use

Use this skill when:
- Analyzing code coverage reports
- Identifying untested code paths
- Improving test coverage percentages
- Setting coverage thresholds and goals
- Reviewing coverage trends over time
- Auditing quality gates in CI/CD

## Key Concepts

### Coverage Types
- **Line Coverage**: Percentage of executed lines
- **Statement Coverage**: Percentage of executed statements
- **Branch Coverage**: Percentage of executed branches (if/else, switch)
- **Function Coverage**: Percentage of called functions
- **Condition Coverage**: Boolean expression outcomes

### Common Tools
- **Istanbul/nyc**: JavaScript/TypeScript coverage
- **JaCoCo**: Java coverage
- **Coverage.py**: Python coverage
- **pytest-cov**: Python pytest plugin
- **lcov**: Unified coverage format
- **Codecov**: Coverage reporting service
- **SonarQube**: Code quality and coverage

## Patterns and Practices

### Coverage Analysis
1. Generate coverage report
2. Review overall coverage percentage
3. Identify low-coverage modules/files
4. Analyze untested code paths
3. Assess criticality of uncovered code
4. Prioritize test additions based on risk
5. Set coverage thresholds
6. Integrate into CI/CD pipeline

### Best Practices
- Aim for 80%+ line coverage (industry standard)
- Prioritize coverage over complex business logic
- Focus on critical paths and security-sensitive code
- Use coverage as a guide, not a goal
- Combine with mutation testing for quality
- Track coverage trends over time
- Set per-module thresholds, not just global

### Anti-Patterns
- Writing tests solely for coverage numbers
- Ignoring coverage for "trivial" code
- Setting unrealistic 100% coverage goals
- Focusing only on line coverage, ignoring branches

## Tools by Language

### JavaScript/TypeScript
```bash
npx nyc npm test
npx nyc report --reporter=lcov
```

### Python
```bash
pytest --cov=src --cov-report=html
coverage report -m
```

### Java
```bash
mvn jacoco:report
```

## CI/CD Integration

### GitHub Actions
```yaml
- name: Run tests with coverage
  run: npm test -- --coverage
- name: Upload coverage to Codecov
  uses: codecov/codecov-action@v3
```

## File Patterns

Look for:
- `**/coverage/**/*`
- `**/*.lcov`
- `**/test-results/**/*`
- `**/.nyc_output/**/*`
- `**/htmlcov/**/*`

## Keywords

Test coverage, code coverage, coverage analysis, coverage report, untested code, coverage metrics, coverage threshold, code quality, branch coverage, line coverage, function coverage, statement coverage, condition coverage
