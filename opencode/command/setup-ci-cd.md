---
description: Implement pre-commit hooks and GitHub Actions for quality assurance
agent: devops-engineer
allowed-tools: ["Bash", "Glob", "Grep", "Read", "Write", "Task", "TodoWrite"]
---

# Setup CI/CD Pipeline

Implement comprehensive DevOps quality gates adapted to project type, including pre-commit hooks and GitHub Actions workflows.

## Usage Examples

```bash
# Auto-detect project and setup
/setup-ci-cd

# Specify language explicitly
/setup-ci-cd python
/setup-ci-cd typescript
/setup-ci-cd go
```

---

## Phase 1: Project Analysis

**Detect Project Type:**

Check for language indicators in this order:
```bash
# TypeScript/JavaScript
if [[ -f "package.json" || -f "tsconfig.json" ]]; then
    PROJECT_TYPE="typescript"
    PACKAGE_MANAGER=$(detect_package_manager)  # npm/yarn/pnpm/bun

# Python
elif [[ -f "requirements.txt" || -f "pyproject.toml" || -f "setup.py" ]]; then
    PROJECT_TYPE="python"

# Go
elif [[ -f "go.mod" ]]; then
    PROJECT_TYPE="go"

# Rust
elif [[ -f "Cargo.toml" ]]; then
    PROJECT_TYPE="rust"

# Java
elif [[ -f "pom.xml" || -f "build.gradle" ]]; then
    PROJECT_TYPE="java"
    BUILD_TOOL=$(detect_build_tool)  # maven/gradle

# Ruby
elif [[ -f "Gemfile" ]]; then
    PROJECT_TYPE="ruby"

# Unknown
else
    echo "⚠️  Unable to detect project type. Please specify explicitly."
    exit 1
fi
```

**Check Existing Configurations:**
```bash
# Pre-commit hooks
EXISTING_PRE_COMMIT=$(test -f ".pre-commit-config.yaml" && echo "yes" || echo "no")

# GitHub Actions
EXISTING_GHACTIONS=$(test -d ".github/workflows" && ls .github/workflows/ || echo "")

# Language-specific configs
EXISTING_ESLINT=$(test -f ".eslintrc*" -o -f "eslint.config.*" && echo "yes" || echo "no")
EXISTING_PRETTIER=$(test -f ".prettierrc*" -o -f ".prettier.config.*" && echo "yes" || echo "no")
EXISTING_PYLINT=$(test -f "pyproject.toml" && grep -q "\[tool.ruff\]" pyproject.toml && echo "yes" || echo "no")
```

**Detect Test Framework:**
```bash
# For TypeScript/JavaScript
if grep -q "jest\|vitest\|mocha" package.json; then
    TEST_FRAMEWORK="jest"  # or vitest, mocha
fi

# For Python
if grep -q "pytest\|unittest" pyproject.toml requirements.txt 2>/dev/null; then
    TEST_FRAMEWORK="pytest"
fi
```

---

## Phase 2: Pre-commit Hooks Configuration

**Create `.pre-commit-config.yaml`:**

```yaml
# See https://pre-commit.com for more information
repos:
  # General hooks
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v5.0.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
        args: [--unsafe]
      - id: check-added-large-files
        args: ['--maxkb=1000']
      - id: check-merge-conflict
      - id: detect-private-key
      - id: mixed-line-ending
```

**Language-Specific Hooks:**

### TypeScript/JavaScript
```yaml
  # Prettier
  - repo: https://github.com/pre-commit/mirrors-prettier
    rev: v4.0.0-alpha.8
    hooks:
      - id: prettier
        types_or: [javascript, jsx, ts, tsx, json, yaml, markdown]
        additional_dependencies:
          - prettier@4

  # ESLint
  - repo: local
    hooks:
      - id: eslint
        name: ESLint
        entry: {{PACKAGE_MANAGER}} lint
        language: system
        types: [javascript, jsx, ts, tsx]

  # TypeScript
  - repo: local
    hooks:
      - id: tsc
        name: TypeScript check
        entry: npx tsc --noEmit
        language: system
        types: [ts, tsx]
        pass_filenames: false

  # npm audit
  - repo: local
    hooks:
      - id: npm-audit
        name: npm audit
        entry: {{PACKAGE_MANAGER}} audit
        language: system
        pass_filenames: false
```

### Python
```yaml
  # Black (formatting)
  - repo: https://github.com/psf/black
    rev: 24.10.0
    hooks:
      - id: black

  # Ruff (linting)
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.8.4
    hooks:
      - id: ruff
        args: [--fix, --exit-non-zero-on-fix]
      - id: ruff-format

  # Bandit (security)
  - repo: https://github.com/PyCQA/bandit
    rev: 1.8.0
    hooks:
      - id: bandit
        args: [-c, pyproject.toml]
        additional_dependencies: ["bandit[toml]"]

  # mypy (type checking)
  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.14.1
    hooks:
      - id: mypy
        additional_dependencies: [types-all]

  # pytest
  - repo: local
    hooks:
      - id: pytest
        name: pytest
        entry: pytest
        language: system
        pass_filenames: false
```

### Go
```yaml
  # gofmt
  - repo: https://github.com/dnephin/pre-commit-golang
    rev: v0.5.1
    hooks:
      - id: gofmt

  # golangci-lint
  - repo: https://github.com/golangci/golangci-lint
    rev: v1.62.2
    hooks:
      - id: golangci-lint

  # gosec (security)
  - repo: https://github.com/securego/gosec
    rev: v2.22.0
    hooks:
      - id: gosec

  # go test
  - repo: local
    hooks:
      - id: go-test
        name: go test
        entry: go test ./...
        language: system
        pass_filenames: false
```

### Rust
```yaml
  # rustfmt
  - repo: https://github.com/doublify/pre-commit-rust
    rev: v1.0
    hooks:
      - id: rustfmt

  # Clippy
  - repo: https://github.com/doublify/pre-commit-rust
    rev: v1.0
    hooks:
      - id: clippy
        args: ['--all-targets', '--all-features', '--', '-D', 'warnings']

  # cargo-audit
  - repo: https://github.com/rustsec/rustsec/tree/main/cargo-audit
    rev: v0.21.0
    hooks:
      - id: cargo-audit
```

### Java (Maven)
```yaml
  # Spotless (formatting)
  - repo: https://github.com/dnephin/pre-commit-java
    rev: v0.4.0
    hooks:
      - id: google-java-format

  # Maven test
  - repo: local
    hooks:
      - id: maven-test
        name: Maven test
        entry: mvn test
        language: system
        pass_filenames: false
```

---

## Phase 3: GitHub Actions Workflows

**Create `.github/workflows/ci.yml`:**

### Template: TypeScript/JavaScript
```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  lint-and-test:
    runs-on: ubuntu-latest

    strategy:
      matrix:
        node-version: [18, 20, 22]

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: {{PACKAGE_MANAGER}}

      - name: Install dependencies
        run: {{PACKAGE_MANAGER}} ci

      - name: Run Prettier
        run: npx prettier --check .

      - name: Run ESLint
        run: {{PACKAGE_MANAGER}} lint

      - name: Run TypeScript
        run: npx tsc --noEmit

      - name: Run tests
        run: {{PACKAGE_MANAGER}} test

      - name: Run npm audit
        run: {{PACKAGE_MANAGER}} audit --audit-level=moderate
```

### Template: Python
```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  lint-and-test:
    runs-on: ubuntu-latest

    strategy:
      matrix:
        python-version: ['3.10', '3.11', '3.12']

    steps:
      - uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}
          cache: 'pip'

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install black ruff bandit[toml] mypy pytest
          pip install -e .  # if installable package

      - name: Run Black
        run: black --check .

      - name: Run Ruff
        run: ruff check .

      - name: Run Bandit
        run: bandit -r . -c pyproject.toml

      - name: Run mypy
        run: mypy .

      - name: Run pytest
        run: pytest --cov --cov-report=xml
```

### Template: Go
```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  lint-and-test:
    runs-on: ubuntu-latest

    strategy:
      matrix:
        go-version: ['1.21', '1.22', '1.23']

    steps:
      - uses: actions/checkout@v4

      - name: Setup Go
        uses: actions/setup-go@v5
        with:
          go-version: ${{ matrix.go-version }}
          cache: true

      - name: Run gofmt
        run: |
          if [ $(gofmt -s -l . | wc -l) -gt 0 ]; then
            gofmt -s -l .
            exit 1
          fi

      - name: Run golangci-lint
        uses: golangci/golangci-lint-action@v6

      - name: Run gosec
        uses: securego/gosec@master
        with:
          args: ./...

      - name: Run tests
        run: go test -v -race -coverprofile=coverage.txt ./...

      - name: Upload coverage
        uses: codecov/codecov-action@v4
```

### Template: Rust
```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  lint-and-test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Setup Rust
        uses: dtolnay/rust-toolchain@stable
        with:
          components: rustfmt, clippy

      - name: Run rustfmt
        run: cargo fmt -- --check

      - name: Run Clippy
        run: cargo clippy --all-targets --all-features -- -D warnings

      - name: Run cargo-audit
        uses: rustsec/audit-check@v2
        with:
          token: ${{ secrets.GITHUB_TOKEN }}

      - name: Run tests
        run: cargo test --all-features

      - name: Generate documentation
        run: cargo doc --no-deps
```

---

## Phase 4: Verification

**Local Testing:**
```bash
# Install pre-commit
pip install pre-commit

# Install hooks
pre-commit install

# Run all hooks on all files
pre-commit run --all-files

# Run on staged files (as in git commit)
pre-commit run
```

**Create Test PR:**
```bash
# Create a test branch
git checkout -b test/ci-setup

# Make a trivial change
echo "# CI Setup Test" >> TEST.md

# Commit and push
git add TEST.md
git commit -m "test: verify CI pipeline"
git push origin test/ci-setup

# Check GitHub Actions tab for results
```

---

## Success Criteria

After running this command, verify:
- ✅ `.pre-commit-config.yaml` created
- ✅ `.github/workflows/ci.yml` created
- ✅ Pre-commit hooks run successfully with `pre-commit run --all-files`
- ✅ GitHub Actions workflow passes on test PR
- ✅ Existing configurations are respected (not overwritten)
- ✅ All tools are free/open-source
- ✅ Pipeline execution completes in reasonable time (<5 minutes for small projects)

---

## Troubleshooting

### Pre-commit fails with "command not found"
**Issue:** Tool not installed in project environment
**Fix:**
```bash
# For Python tools
pip install pre-commit black ruff bandit mypy pytest

# For Node tools
npm install -D prettier eslint typescript @typescript-eslint/parser @typescript-eslint/eslint-plugin
```

### GitHub Actions fails with "permission denied"
**Issue:** Missing GitHub token permissions
**Fix:** Go to repo Settings → Actions → General → Workflow permissions → Enable "Read and write permissions"

### Tests pass locally but fail in CI
**Issue:** Environment differences (OS, versions)
**Fix:** Ensure matrix versions in CI match your local versions, or use same container image

### Pipeline too slow
**Issue:** Too many checks or inefficient tests
**Fix:**
- Remove redundant checks
- Cache dependencies more aggressively
- Split workflow into separate jobs (lint vs test)
- Use `needs` to only run tests after lint passes

### Existing config conflicts
**Issue:** Command wants to overwrite existing config
**Fix:** The command respects existing configs. If conflicts exist:
1. Backup existing: `mv .pre-commit-config.yaml .pre-commit-config.yaml.bak`
2. Run `/setup-ci-cd`
3. Merge configurations manually
4. Test: `pre-commit run --all-files`

---

## Language-Specific Tool References

| Language | Formatter | Linter | Security | Type Check | Test |
|----------|-----------|--------|---------|-----------|------|
| TypeScript | Prettier | ESLint | npm audit | TypeScript | Jest/Vitest |
| Python | Black | Ruff | Bandit | mypy | pytest |
| Go | gofmt | golangci-lint | gosec | - | go test |
| Rust | rustfmt | Clippy | cargo-audit | - | cargo test |
| Java | google-java-format | checkstyle | SpotBugs | - | Maven/Gradle |
| Ruby | rubocop | rubocop | bundler-audit | - | rspec/minitest |
