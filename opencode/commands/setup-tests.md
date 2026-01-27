---
description: Increase test coverage by targeting untested branches and edge cases
agent: qa-engineer
allowed-tools: ["Bash", "Glob", "Grep", "Read", "Task", "TodoWrite"]
---

# Expand Unit Tests

Increase test coverage by targeting untested branches and edge cases using the project's existing testing framework.

## Usage Examples

```bash
/setupup-tests
```

---

## Phase 1: Project Detection

**Detect Project Type & Test Framework:**

```bash
# TypeScript/JavaScript
if [[ -f "package.json" || -f "tsconfig.json" ]]; then
    PROJECT_TYPE="typescript"

    # Detect test framework
    if grep -q "jest" package.json 2>/dev/null; then
        TEST_FRAMEWORK="jest"
        COVERAGE_CMD="npm test -- --coverage"
    elif grep -q "vitest" package.json 2>/dev/null; then
        TEST_FRAMEWORK="vitest"
        COVERAGE_CMD="npm test -- --coverage"
    elif grep -q "mocha" package.json 2>/dev/null; then
        TEST_FRAMEWORK="mocha"
        COVERAGE_CMD="nyc npm test"
    fi

# Python
elif [[ -f "requirements.txt" || -f "pyproject.toml" || -f "setup.py" ]]; then
    PROJECT_TYPE="python"

    # Detect test framework
    if grep -q "pytest" pyproject.toml requirements.txt 2>/dev/null; then
        TEST_FRAMEWORK="pytest"
        COVERAGE_CMD="pytest --cov=. --cov-report=term-missing"
    elif grep -q "unittest" pyproject.toml requirements.txt 2>/dev/null; then
        TEST_FRAMEWORK="unittest"
        COVERAGE_CMD="python -m unittest discover -v"
    fi

# Go
elif [[ -f "go.mod" ]]; then
    PROJECT_TYPE="go"
    TEST_FRAMEWORK="testing"
    COVERAGE_CMD="go test -v -coverprofile=coverage.out ./..."

# Rust
elif [[ -f "Cargo.toml" ]]; then
    PROJECT_TYPE="rust"
    TEST_FRAMEWORK="built-in"
    COVERAGE_CMD="cargo test"
fi
```

**Check for Docker Infrastructure:**

```bash
# Check if Docker is available for running tests
HAS_DOCKERFILE=$(test -f "Dockerfile" && echo "yes" || echo "no")
HAS_COMPOSE=$(test -f "docker-compose.yml" -o -f "docker-compose.yaml" && echo "yes" || echo "no")

if [[ "$HAS_DOCKERFILE" == "yes" || "$HAS_COMPOSE" == "yes" ]]; then
    echo "📦 Docker detected - use container to run tests for consistent environment"
    echo ""
    echo "Recommended commands:"
    if [[ "$HAS_COMPOSE" == "yes" ]]; then
        echo "  docker-compose run --rm app $COVERAGE_CMD"
    else
        echo "  docker build -t test-runner . && docker run --rm test-runner $COVERAGE_CMD"
    fi
    echo ""
fi
```

---

## Phase 2: Analyze Coverage

**Run Coverage Report:**

```bash
# Run the appropriate coverage command
$COVERAGE_CMD
```

**Identify Low-Coverage Areas:**

Review the coverage report and identify:
- Files with coverage below 80%
- Functions with no coverage
- Branches not executed
- Lines not covered

**Common Low-Coverage Patterns:**
- Error handling paths (exceptions, error returns)
- Input validation (null checks, empty strings, invalid types)
- Boundary conditions (min/max values, empty arrays, single items)
- Edge cases (race conditions, concurrent access)
- State transitions (initialization, cleanup, retries)

---

## Phase 3: Identify Gaps

For each low-coverage file, review the code and identify:

**Logical Branches:**
```bash
# Search for conditional statements
grep -rn "if\|else\|switch\|case\|match" src/
```

**Error Paths:**
```bash
# Search for error handling
grep -rn "throw\|catch\|error\|fail\|except\|return err" src/
```

**Boundary Conditions:**
```bash
# Search for loops and range checks
grep -rn "for\|while\|range\|length\|size" src/
```

**Target Test Scenarios:**
- Error handling and exceptions
- Boundary values (min/max, empty, null)
- Edge cases and corner cases
- State transitions and side effects

---

## Phase 4: Write Tests

**Framework-Specific Test Patterns:**

### TypeScript/JavaScript (Jest/Vitest)

```typescript
describe('FunctionName', () => {
  // Happy path
  it('should return expected result for valid input', () => {
    const result = functionName(validInput);
    expect(result).toEqual(expectedOutput);
  });

  // Boundary conditions
  it('should handle empty input', () => {
    const result = functionName('');
    expect(result).toEqual(expected);
  });

  it('should handle null/undefined', () => {
    const result = functionName(null);
    expect(result).toEqual(expected);
  });

  // Edge cases
  it('should handle maximum value', () => {
    const result = functionName(Number.MAX_SAFE_INTEGER);
    expect(result).toEqual(expected);
  });

  // Error handling
  it('should throw error for invalid input', () => {
    expect(() => functionName(invalidInput)).toThrow(Error);
  });
});
```

### Python (pytest)

```python
import pytest
from module import function_name

class TestFunctionName:
    # Happy path
    def test_valid_input(self):
        result = function_name(valid_input)
        assert result == expected_output

    # Boundary conditions
    def test_empty_input(self):
        result = function_name('')
        assert result == expected

    def test_none_input(self):
        with pytest.raises(ValueError):
            function_name(None)

    # Edge cases
    @pytest.mark.parametrize("value,expected", [
        (0, expected),
        (-1, expected),
        (999999, expected),
    ])
    def test_boundary_values(self, value, expected):
        result = function_name(value)
        assert result == expected
```

### Go

```go
func TestFunctionName(t *testing.T) {
    tests := []struct {
        name    string
        input   interface{}
        want    interface{}
        wantErr bool
    }{
        {"valid input", validInput, expected, false},
        {"empty input", "", expected, false},
        {"nil input", nil, nil, true},
        {"max value", math.MaxInt64, expected, false},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := FunctionName(tt.input)
            if (err != nil) != tt.wantErr {
                t.Errorf("FunctionName() error = %v, wantErr %v", err, tt.wantErr)
                return
            }
            if got != tt.want {
                t.Errorf("FunctionName() = %v, want %v", got, tt.want)
            }
        })
    }
}
```

### Rust

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_valid_input() {
        let result = function_name(valid_input);
        assert_eq!(result, expected);
    }

    #[test]
    fn test_empty_input() {
        let result = function_name("");
        assert_eq!(result, expected);
    }

    #[test]
    #[should_panic(expected = "invalid input")]
    fn test_invalid_input_panics() {
        function_name(invalid_input);
    }
}
```

---

## Phase 5: Verify Improvement

**Re-run Coverage:**

```bash
$COVERAGE_CMD
```

**Confirm Measurable Increase:**
- Compare before/after coverage percentages
- Verify previously uncovered branches are now tested
- Ensure all new tests pass

**Success Criteria:**
- Coverage increased by at least 5-10 percentage points
- All new tests pass
- No regressions in existing tests

---

## Test Framework Reference

| Language | Frameworks | Coverage Command | Test Location |
|----------|-----------|------------------|---------------|
| TypeScript | Jest, Vitest, Mocha | `npm test -- --coverage` | `**/*.test.ts`, `**/*.spec.ts` |
| Python | pytest, unittest | `pytest --cov` | `tests/`, `**/test_*.py` |
| Go | testing, testify | `go test -coverprofile=coverage.out ./...` | `**/*_test.go` |
| Rust | built-in | `cargo test` | `tests/`, `**/tests.rs` |
| Java | JUnit | `mvn test` or `gradle test` | `src/test/java/` |
| Ruby | RSpec, Minitest | `bundle exec rspec` | `spec/`, `test/` |

---

## Success Criteria

After running this command, verify:
- ✅ Coverage report generated
- ✅ Untested branches and edge cases identified
- ✅ New tests written for identified gaps
- ✅ Coverage increased measurably (5-10% minimum)
- ✅ All tests pass (old and new)
- ✅ Test patterns follow project conventions

---

## Tips

**Start Small:**
- Focus on one file or module at a time
- Prioritize high-impact areas (critical paths, security-sensitive code)

**Use Test Generators:**
- Many IDEs can generate test scaffolding
- Use AI to generate initial test cases, then refine manually

**Maintainability:**
- Keep tests simple and readable
- Use descriptive test names that explain what is being tested
- Follow the Arrange-Act-Assert (AAA) pattern

**Coverage Goals:**
- Aim for 80%+ coverage for critical business logic
- 100% coverage is not always practical or necessary
- Focus on meaningful tests, not just numbers

---

## Troubleshooting

### Coverage command fails
**Issue:** Test framework not configured for coverage
**Fix:** Install coverage tools (nyc for Mocha, pytest-cov for pytest, etc.)

### Tests pass locally but fail in CI
**Issue:** Environment differences (OS, versions)
**Fix:** Use Docker container for consistent test environment

### Coverage not increasing
**Issue:** Tests not targeting new branches or paths
**Fix:** Review code logic, ensure tests exercise all conditional branches

---

**Now analyze coverage, identify gaps, and write targeted tests to improve coverage.**
