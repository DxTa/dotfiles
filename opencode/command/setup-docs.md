---
description: Restructure project documentation for clarity and accessibility, with optional workspace analysis
args:
  - name: scope
    description: "Scope of analysis: 'full' (complete refactor), 'quick' (scan for gaps), or 'review' (analyze existing only)"
    required: false
---

# Documentation Refactor & Review

Restructure project documentation for clarity and accessibility. Adapt the approach to the project type (library/API/web app/CLI/microservices).

## Usage

```
/setup-docs full    # Complete documentation refactor
/setup-docs quick   # Quick scan for missing documentation
/setup-docs review  # Review and analyze existing docs only
```

---

## Phase 1: Analyze Project

First, understand the project to tailor documentation appropriately:

### 1.1 Identify Project Type

Analyze the codebase to determine which type it is:

| Type | Indicators | Documentation Focus |
|------|-----------|---------------------|
| **Library** | `package.json`, `setup.py`, `go.mod` with no main entry | API reference, usage examples, integration guide |
| **API** | OpenAPI specs, `routes/`, `controllers/` | Endpoints, authentication, request/response examples |
| **Web App** | `frontend/`, `components/`, SSR framework | User guide, deployment, environment setup |
| **CLI** | `bin/`, `cli/`, command parsers | Installation, command reference, usage examples |
| **Microservices** | `docker-compose.yml`, multiple services, message queues | Architecture, inter-service communication, deployment |

### 1.2 Identify User Personas

Determine who will read the documentation:

- **End Users**: Installation, usage, configuration
- **Developers**: Architecture, development setup, contribution guide
- **Operators**: Deployment, monitoring, troubleshooting
- **Integrators**: API documentation, webhooks, extensions

### 1.3 Map Existing Documentation

Scan for existing docs:

```bash
# Find all README files
find . -name "README*.md" -o -name "*.md" | grep -v node_modules | grep -v .git

# Check for common doc locations
ls -la docs/ 2>/dev/null || echo "No docs/ directory"
ls -la .github/ 2>/dev/null || echo "No .github/ directory"
```

---

## Phase 2: Centralize Documentation

### 2.1 Create `docs/` Structure

If it doesn't exist, create the documentation directory:

```bash
mkdir -p docs/{guides,api,architecture,deployment,troubleshooting}
```

### 2.2 Move Technical Docs

Move scattered documentation into `docs/` with proper organization:

| From | To | Category |
|------|-----|----------|
| Root `ARCHITECTURE.md` | `docs/architecture/overview.md` | Architecture |
| Root `CONTRIBUTING.md` | `docs/guides/contributing.md` | Guides |
| Root `DEPLOYMENT.md` | `docs/deployment/production.md` | Deployment |
| Root `API.md` | `docs/api/reference.md` | API |
| Root `TROUBLESHOOTING.md` | `docs/troubleshooting/common-issues.md` | Troubleshooting |

---

## Phase 3: Root README.md

Streamline the root `README.md` as the entry point. It should include:

### Required Sections

```markdown
# Project Name

> Brief one-line description of what this project does

## Overview

[2-3 sentences explaining the project's purpose and value proposition]

## Quick Start

[Minimal steps to get running - for the simplest use case]

\`\`\`bash
# Installation/running commands
\`\`\`

## Documentation

- **[User Guide](docs/guides/user-guide.md)** - End-user documentation
- **[API Reference](docs/api/reference.md)** - API endpoints and usage
- **[Development Guide](docs/guides/development.md)** - Setup for contributors
- **[Architecture](docs/architecture/overview.md)** - System design and components
- **[Deployment](docs/deployment/production.md)** - Production deployment

## Modules/Components

[Summary of main modules or components with links to their docs]

## License

[License type and link]

## Contact

[Links: issues, discussions, email, etc.]
```

### Keep It Concise

- Root README should be **scannable in under 2 minutes**
- Link out to detailed docs in `docs/`
- Focus on: What is this? How do I start? Where do I learn more?

---

## Phase 4: Component Documentation

Add module/package/service-level README files:

### When to Create Component READMEs

| Location | Create README When... |
|----------|----------------------|
| `packages/*` | Always (monorepo packages) |
| `src/modules/*` | If module has external interfaces |
| `services/*` | Always (microservices) |
| `src/components/*` | If reusable/shared component |

### Component README Template

```markdown
# Module/Component Name

> Brief description of this component's purpose

## Purpose

[What problem does this component solve?]

## Usage

\`\`\`typescript
// Minimal usage example
\`\`\`

## API

- `functionName()` - Description
- `className.method()` - Description

## Testing

\`\`\`bash
# How to test this component
npm test -- componentName
\`\`\`

## Dependencies

- [List of internal/external dependencies]

## Related

- [Link to related components or docs]
```

---

## Phase 5: Organize `docs/` Directory

Structure `docs/` by category, adapted to project needs:

### Standard Categories

```
docs/
├── guides/
│   ├── user-guide.md          # End-user documentation
│   ├── development.md         # Developer setup & workflow
│   └── contributing.md        # Contribution guidelines
├── api/
│   ├── reference.md           # API endpoints/methods
│   └── authentication.md      # Auth mechanisms
├── architecture/
│   ├── overview.md            # System architecture
│   ├── data-model.md          # Database schema
│   └── design-decisions.md    # Key architectural choices
├── deployment/
│   ├── production.md          # Production deployment
│   ├── docker.md              # Container deployment
│   └── kubernetes.md          # K8s deployment (if applicable)
└── troubleshooting/
    ├── common-issues.md       # Frequently encountered problems
    └── logs.md                # Log locations and debugging
```

### Adapt to Project Type

| Project Type | Emphasize These Categories |
|-------------|---------------------------|
| **Library** | API Reference, Usage Examples, Integration |
| **API** | API Reference, Authentication, Rate Limiting |
| **Web App** | User Guide, Deployment, Environment Setup |
| **CLI** | Command Reference, Installation, Configuration |
| **Microservices** | Architecture, Inter-service Communication, Deployment |

---

## Phase 6: Create Guides (Select Applicable)

### User Guide (End-User Documentation)

Create `docs/guides/user-guide.md` when:
- Building a web application or CLI tool
- Users interact with the software directly

Include:
- Installation/setup instructions
- Common workflows with screenshots/diagrams
- Configuration options
- FAQ section

### API Documentation (API-Only Projects)

Create `docs/api/reference.md` when:
- Building REST/GraphQL/gRPC APIs
- Providing library interfaces

Include:
- All endpoints/methods with examples
- Authentication mechanism
- Request/response schemas
- Error codes and handling
- Rate limiting information

### Development Guide (Contributor-Facing)

Create `docs/guides/development.md` with:
- Prerequisites (languages, tools)
- Local development setup
- Testing procedures
- Code style guidelines
- Pull request process

### Deployment Guide (Operations-Facing)

Create `docs/deployment/production.md` with:
- Environment variables
- Deployment steps
- Health checks
- Monitoring and logging
- Rollback procedures

---

## Phase 7: Use Mermaid for Diagrams

Use Mermaid for ALL diagrams (architecture, flows, schemas). It renders in GitHub, GitLab, and many markdown viewers.

### Architecture Diagram

\`\`\`mermaid
graph TB
    subgraph "Frontend"
        A[React App]
    end

    subgraph "Backend"
        B[API Gateway]
        C[Auth Service]
        D[Business Logic]
    end

    subgraph "Data Layer"
        E[(PostgreSQL)]
        F[(Redis)]
    end

    A --> B
    B --> C
    B --> D
    D --> E
    D --> F
\`\`\`

### Data Flow Diagram

\`\`\`mermaid
sequenceDiagram
    participant User
    participant API
    participant Service
    participant DB

    User->>API: POST /resource
    API->>Service: validateRequest()
    Service->>DB: INSERT data
    DB-->>Service: confirmation
    Service-->>API: response
    API-->>User: 201 Created
\`\`\`

### Database Schema

\`\`\`mermaid
erDiagram
    USERS {
        uuid id PK
        string email
        string password_hash
    }
    POSTS {
        uuid id PK
        uuid user_id FK
        string title
        text content
    }
    USERS ||--o{ POSTS : "creates"
\`\`\`

---

## Documentation Quick Scan (`quick` scope)

When using `/setup-docs quick`, perform a gap analysis:

### Check for Missing Documentation

Use this checklist:

```bash
# Check for README files
find . -name "README.md" -not -path "*/node_modules/*"

# Check for docs directory
test -d docs && echo "✅ docs/ exists" || echo "❌ Missing docs/"

# Check for common docs
for doc in CONTRIBUTING.md ARCHITECTURE.md API.md CHANGELOG.md LICENSE; do
  test -f "$doc" && echo "✅ $doc" || echo "❌ Missing $doc"
done

# Check for package READMEs (monorepos)
find packages -name "README.md" 2>/dev/null | wc -l
```

### Common Documentation Gaps

| Gap | Symptom | Recommendation |
|-----|---------|----------------|
| No `CONTRIBUTING.md` | No contribution guidelines | Create `docs/guides/contributing.md` |
| No architecture docs | Unclear system design | Create `docs/architecture/overview.md` with Mermaid diagram |
| No setup instructions | "How do I run this?" questions | Add Quick Start to README.md |
| No testing guide | Unclear how to test | Add testing section to `docs/guides/development.md` |
| No deployment docs | Deployments are difficult | Create `docs/deployment/production.md` |
| No API documentation | Unknown endpoints | Create `docs/api/reference.md` with examples |
| No troubleshooting docs | Repeated issues | Create `docs/troubleshooting/common-issues.md` |

---

## Documentation Review (`review` scope)

When using `/setup-docs review`, analyze existing docs:

### Review Checklist

For each documentation file, assess:

1. **Clarity**: Is it scannable? Can a reader find information quickly?
2. **Completeness**: Are all critical topics covered?
3. **Accuracy**: Is the information up-to-date with the code?
4. **Diagrams**: Are complex concepts illustrated with Mermaid?
5. **Examples**: Are code/example blocks provided and tested?
6. **Cross-references**: Are related docs linked?

### Report Format

Generate a report with:

```markdown
# Documentation Review Report

## Coverage Summary

| Category | Status | Notes |
|----------|--------|-------|
| Root README | ✅/❌ | [Assessment] |
| User Guide | ✅/❌ | [Assessment] |
| API Reference | ✅/❌ | [Assessment] |
| Architecture | ✅/❌ | [Assessment] |
| Deployment | ✅/❌ | [Assessment] |
| Troubleshooting | ✅/❌ | [Assessment] |

## Missing Documentation

[List gaps with priorities: High/Medium/Low]

## Quality Issues

- [Issue 1]
- [Issue 2]

## Recommendations

1. [Priority 1 recommendation]
2. [Priority 2 recommendation]
```

---

## Best Practices

### Keep Docs Concise
- **Scannable**: Use headings, bullet points, tables
- **Focused**: One main idea per section
- **Contextual**: Adapt to project type and user personas

### Keep Docs Updated
- Review docs when changing APIs or architecture
- Update diagrams when systems change
- Tag documentation commits in git history

### Use Visual Aids
- Mermaid diagrams for architecture and flows
- Code blocks with syntax highlighting
- Tables for comparisons and references
- Emojis for visual emphasis (⚠️, ✅, ❌, 💡)

### Cross-Reference
- Link between related docs
- Use relative paths: `[link text](docs/path/to/file.md)`
- Include "Related" sections at the bottom of pages

---

## When to Use This Command

| Situation | Scope |
|-----------|-------|
| New project with no docs | `full` |
| Existing docs are scattered | `full` |
| Want to check what's missing | `quick` |
| About to release v1.0 | `review` then `full` |
| Onboarding new developers | `quick` |
| Preparing for open source | `full` |
