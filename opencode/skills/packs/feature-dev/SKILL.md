# Feature Dev

Structured 7-phase feature development workflow with specialized agents - discovery, codebase exploration, clarifying questions, architecture design, implementation, quality review, and summary.

## When to Use

Use this skill when:
- Starting new feature development
- Planning feature implementation
- Exploring existing codebase
- Designing feature architecture
- Implementing complex features
- Reviewing code quality
- Documenting feature completion

## 7-Phase Workflow

### Phase 1: Discovery
**Agent: Discovery Agent**

- Understand feature requirements
- Identify stakeholders and users
- Gather context and constraints
- Define success criteria
- Identify dependencies

**Outputs:**
- Feature description
- User stories or use cases
- Acceptance criteria
- Constraints and limitations

### Phase 2: Codebase Exploration
**Agent: Codebase Explorer**

- Explore existing codebase structure
- Identify relevant components
- Find similar existing patterns
- Understand data models and APIs
- Map integration points

**Outputs:**
- Codebase map
- Relevant files and modules
- Existing patterns to follow
- Integration points identified

### Phase 3: Clarifying Questions
**Agent: Question Agent**

- Generate clarifying questions
- Identify edge cases
- Clarify ambiguous requirements
- Surface hidden assumptions
- Validate understanding

**Outputs:**
- List of questions for stakeholders
- Assumptions made
- Edge cases identified
- Decisions needed

### Phase 4: Architecture Design
**Agent: Architecture Agent**

- Design component architecture
- Define data flow
- Plan database schema changes
- Design API contracts
- Consider scalability and performance

**Outputs:**
- Architecture diagram
- Component design
- Database schema
- API specifications
- Implementation plan

### Phase 5: Implementation
**Agent: Implementation Agent**

- Write production code
- Implement data models
- Create API endpoints
- Add UI components
- Integrate with existing systems

**Outputs:**
- Source code
- Database migrations
- API documentation
- Unit tests

### Phase 6: Quality Review
**Agent: Quality Agent**

- Code review
- Test coverage analysis
- Performance review
- Security review
- Documentation review

**Outputs:**
- Code review findings
- Test coverage report
- Performance metrics
- Security assessment
- Documentation checklist

### Phase 7: Summary
**Agent: Summary Agent**

- Summarize feature implementation
- Document decisions made
- Identify technical debt
- Provide deployment checklist
- Suggest future improvements

**Outputs:**
- Feature summary
- Decision log
- Known issues or debt
- Deployment guide
- Future enhancements

## Phase Workflows

### Discovery Phase
```python
class DiscoveryAgent:
    def analyze_requirements(self, requirements):
        """
        Analyze feature requirements
        """
        analysis = {
            'user_stories': [],
            'acceptance_criteria': [],
            'constraints': [],
            'dependencies': []
        }

        # Parse requirements
        for req in requirements:
            analysis['user_stories'].append(req.as_user_story())
            analysis['acceptance_criteria'].extend(req.get_criteria())
            analysis['constraints'].extend(req.get_constraints())

        # Identify dependencies
        analysis['dependencies'] = self.find_dependencies(requirements)

        return analysis
```

### Codebase Exploration
```python
class CodebaseExplorer:
    def explore(self, feature_context):
        """
        Explore codebase for relevant components
        """
        exploration = {
            'relevant_files': [],
            'similar_patterns': [],
            'integration_points': [],
            'data_models': []
        }

        # Search for similar features
        exploration['similar_patterns'] = self.find_similar_patterns(feature_context)

        # Find relevant files
        exploration['relevant_files'] = self.find_files_by_keywords(
            feature_context.keywords
        )

        # Identify integration points
        exploration['integration_points'] = self.find_integration_points(
            exploration['relevant_files']
        )

        # Extract data models
        exploration['data_models'] = self.extract_data_models(
            exploration['relevant_files']
        )

        return exploration
```

### Architecture Design
```python
class ArchitectureAgent:
    def design(self, context, exploration):
        """
        Design feature architecture
        """
        architecture = {
            'components': [],
            'data_flow': [],
            'api_contracts': [],
            'database_changes': []
        }

        # Design components
        architecture['components'] = self.design_components(context)

        # Design data flow
        architecture['data_flow'] = self.design_data_flow(
            architecture['components']
        )

        # Design API contracts
        architecture['api_contracts'] = self.design_api(context)

        # Design database changes
        architecture['database_changes'] = self.design_database(
            context.data_requirements
        )

        return architecture
```

### Implementation
```python
class ImplementationAgent:
    def implement(self, architecture, exploration):
        """
        Implement the feature
        """
        implementation = {
            'code_files': [],
            'tests': [],
            'migrations': []
        }

        # Implement components
        for component in architecture['components']:
            code = self.implement_component(component)
            implementation['code_files'].append(code)

            # Write tests
            tests = self.write_tests(component)
            implementation['tests'].extend(tests)

        # Create migrations
        for db_change in architecture['database_changes']:
            migration = self.create_migration(db_change)
            implementation['migrations'].append(migration)

        return implementation
```

## Quality Review

### Code Review Checklist
```yaml
code_review:
  - Naming conventions followed
  - Code is readable and maintainable
  - Proper error handling
  - No code duplication
  - Performance considerations
  - Security best practices
  - Documentation is complete
```

### Test Coverage
```python
def analyze_test_coverage(implementation):
    """
    Analyze test coverage for implementation
    """
    coverage = {
        'overall': 0,
        'by_file': {},
        'uncovered_files': [],
        'edge_cases_missing': []
    }

    # Calculate coverage
    coverage['overall'] = calculate_coverage(implementation)

    # Identify gaps
    coverage['uncovered_files'] = find_uncovered_files(implementation)
    coverage['edge_cases_missing'] = find_missing_edge_cases(implementation)

    return coverage
```

## Best Practices

### Discovery
- Gather requirements from all stakeholders
- Document assumptions
- Define clear success criteria
- Identify constraints early

### Exploration
- Use grep and code search tools
- Look for similar implementations
- Understand existing patterns
- Document integration points

### Architecture
- Consider scalability and performance
- Design for maintainability
- Document design decisions
- Plan for testing

### Implementation
- Follow coding standards
- Write tests alongside code
- Document complex logic
- Keep functions small

## File Patterns

Look for:
- `**/features/**/*`
- `**/src/**/*.{js,ts,py}`
- `**/tests/**/*.{js,ts,py}`
- `**/migrations/**/*.{js,py,sql}`
- `**/docs/**/*.{md,txt}`

## Keywords

Feature development, workflow, discovery, architecture, implementation, quality review, codebase exploration, design patterns, documentation, planning
