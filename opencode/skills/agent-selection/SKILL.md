---
name: agent-selection
description: Decision tree for selecting appropriate agents and tools based on task patterns
version: "1.0.0"
---

# Agent Selection Decision Tree

Complete decision tree for selecting the right agent or tool for any task. Use this when you need to decide which specialized agent or tool to invoke.

## Overview

This skill provides a comprehensive decision tree that maps task patterns to the most appropriate:
- Built-in agents (@explore, @general)
- CLI tools (uvx sia-code)
- Specialist agents (@frontend-specialist, @backend-specialist, etc.)
- Superpowers skills (TDD, code review, debugging)

## Decision Tree

<decision-tree name="agent-selection">
  <!-- Built-in agents and tools -->
  <case pattern="Find files matching pattern X">
    <agent>@explore</agent>
  </case>
  <case pattern="Search code for keyword Y">
    <agent>@explore</agent>
  </case>
  <case pattern="Where is feature Z defined?">
    <cli>uvx sia-code research</cli>
  </case>
  <case pattern="How does X work?">
    <cli>uvx sia-code research</cli>
    <note>architecture</note>
  </case>
  <case pattern="Trace dependencies of module Y">
    <cli>uvx sia-code research</cli>
  </case>
  <case pattern="Unfamiliar codebase area">
    <cli>uvx sia-code research</cli>
    <note>map first</note>
  </case>
  <case pattern="Research library/API/pattern">
    <agent>@general</agent>
    <note>external docs</note>
  </case>
   <case pattern="Complex multi-step analysis">
     <agent>@general</agent>
   </case>
   
   <!-- Spec Analysis (memory-informed) -->
   <case pattern="Analyze Jira ticket or spec">
     <prerequisite>uvx sia-code memory search "[topic]"</prerequisite>
     <skill>spec-analyzer</skill>
     <note>Memory search first for context, then spec-analyzer</note>
   </case>
   <case pattern="Vague or incomplete requirements">
     <skill>spec-analyzer</skill>
     <note>Socratic questioning to clarify</note>
   </case>
   <case pattern="JIRA-[A-Z0-9]+ ticket needs analysis">
     <skill>spec-analyzer</skill>
     <note>Pull via mcp-atlassian if available</note>
   </case>
   <case pattern="Feature request or user story refinement">
     <skill>spec-analyzer</skill>
     <note>Memory-informed before T3+ planning</note>
   </case>
   
   <!-- Self-Reflection (CRITICAL - currently underutilized) -->
  <case pattern="Validate plan before implementation (T2+)">
    <agent>@self-reflect</agent>
    <tier>T2: recommended, T3+: MANDATORY</tier>
  </case>
  <case pattern="Before claiming task/feature complete">
    <agent>@self-reflect</agent>
    <note>Verification gate - assume broken until proven</note>
  </case>
  <case pattern="Review approach after 2 failed fixes">
    <agent>@self-reflect</agent>
    <note>Two-Strike Rule validation</note>
  </case>
  
  <!-- Frontend Specialist -->
  <case pattern="React/Vue/Angular component design">
    <agent>@frontend-specialist</agent>
  </case>
  <case pattern="CSS/styling/responsive layout issues">
    <agent>@frontend-specialist</agent>
  </case>
  <case pattern="Frontend state management (Redux/Zustand/Context)">
    <agent>@frontend-specialist</agent>
  </case>
  <case pattern="UI/UX implementation decisions">
    <agent>@frontend-specialist</agent>
  </case>
  
  <!-- Backend Specialist -->
  <case pattern="API endpoint design (REST/GraphQL/gRPC)">
    <agent>@backend-specialist</agent>
  </case>
  <case pattern="Database schema/query optimization">
    <agent>@backend-specialist</agent>
  </case>
  <case pattern="Server-side authentication/authorization">
    <agent>@backend-specialist</agent>
  </case>
  <case pattern="Microservices architecture decisions">
    <agent>@backend-specialist</agent>
  </case>
  
  <!-- DevOps Engineer -->
  <case pattern="CI/CD pipeline design (GitHub Actions/GitLab CI)">
    <agent>@devops-engineer</agent>
  </case>
  <case pattern="Docker/container configuration">
    <agent>@devops-engineer</agent>
  </case>
  <case pattern="Kubernetes/infrastructure setup">
    <agent>@devops-engineer</agent>
  </case>
  <case pattern="Deployment strategy/rollback planning">
    <agent>@devops-engineer</agent>
  </case>
  
  <!-- QA Engineer -->
  <case pattern="Test strategy/architecture design">
    <agent>@qa-engineer</agent>
  </case>
  <case pattern="Test coverage analysis/gaps">
    <agent>@qa-engineer</agent>
  </case>
  <case pattern="E2E/integration test planning">
    <agent>@qa-engineer</agent>
  </case>
  
  <!-- Security Engineer -->
  <case pattern="Authentication/authorization design">
    <agent>@security-engineer</agent>
  </case>
  <case pattern="OWASP vulnerability check">
    <agent>@security-engineer</agent>
  </case>
  <case pattern="Crypto/secrets management">
    <agent>@security-engineer</agent>
  </case>
  
  <!-- Technical Writer -->
  <case pattern="README/documentation needed">
    <agent>@technical-writer</agent>
  </case>
  <case pattern="API documentation generation">
    <agent>@technical-writer</agent>
  </case>
  
  <!-- Management/Strategy Agents (rare usage) -->
  <case pattern="Product requirements/user stories">
    <agent>@product-owner</agent>
  </case>
  <case pattern="Project timeline/milestone planning">
    <agent>@project-manager</agent>
  </case>
  <case pattern="Team/people management decisions">
    <agent>@engineering-manager</agent>
  </case>
  <case pattern="Technology strategy/roadmap">
    <agent>@enterprise-cto</agent>
  </case>
  <case pattern="Extract reusable insights/patterns">
    <agent>@knowledge-analyzer</agent>
  </case>
  
  <!-- TDD -->
  <case pattern="Implementing new feature or bugfix (T2+)">
    <dispatch>@general with superpowers/test-driven-development</dispatch>
    <enforcement>MANDATORY</enforcement>
  </case>
  
  <!-- Spec Review -->
  <case pattern="Task implementation complete, before code review">
    <dispatch>@general with superpowers/subagent-driven-development spec-reviewer</dispatch>
    <note>Verify spec compliance FIRST</note>
  </case>
  
  <!-- Code Review -->
  <case pattern="Spec review passed, ready for code quality review">
    <dispatch>@general with superpowers/requesting-code-review</dispatch>
    <note>Only after spec compliance ✅</note>
  </case>
  
  <!-- Verification -->
  <case pattern="About to claim work complete or fixed">
    <skill>superpowers/verification-before-completion</skill>
    <note>Evidence before claims, always</note>
  </case>
  
  <!-- Debugging -->
  <case pattern="2+ failed fixes, Two-Strike triggered">
    <dispatch>@general with superpowers/systematic-debugging</dispatch>
    <note>Four-phase debugging, question architecture after 3 failures</note>
  </case>
  
  <!-- Branch Completion -->
  <case pattern="All tasks complete, ready to finish branch">
    <dispatch>@general with superpowers/finishing-a-development-branch + push-all</dispatch>
    <note>Tests → Options → Execute with quality gates</note>
  </case>
</decision-tree>

## Quick Dispatch Table

For rapid selection, use this condensed table:

| Need | Agent/Tool |
|------|------------|
| File patterns, code search | `@explore` |
| Architecture, "how does X work" | `uvx sia-code research` |
| External docs, multi-step research | `@general` |
| Spec analysis, vague requirements | `spec-analyzer` skill |
| Plan validation (T2+: rec, T3+: MANDATORY) | `@self-reflect` |
| React/Vue/CSS/UI | `@frontend-specialist` |
| API/DB/Auth backend | `@backend-specialist` |
| CI/CD, Docker, K8s | `@devops-engineer` |
| Test strategy, coverage | `@qa-engineer` |
| Security, OWASP, crypto | `@security-engineer` |
| README, API docs | `@technical-writer` |
| TDD implementation (T2+) | `@general` + `superpowers/test-driven-development` |
| Task complete, before review | `@general` + `superpowers/subagent-driven-development` |
| 2+ failed fixes | `@general` + `superpowers/systematic-debugging` |
| Branch complete | `@general` + `superpowers/finishing-a-development-branch` |

## Usage Examples

### Example 1: Unfamiliar Codebase
```
Task: "Implement authentication middleware"
Decision: Run `uvx sia-code research "authentication middleware flow"`
Reason: Architecture exploration before coding
```

### Example 2: Plan Validation
```
Task: Created task_plan.md for T3 task
Decision: Invoke `@self-reflect` with plan content
Reason: T3+ MANDATORY self-reflection before implementation
```

### Example 3: Two-Strike Triggered
```
Task: Third failed fix attempt
Decision: Load `superpowers/systematic-debugging` with @general
Reason: Systematic root cause analysis required
```

## Integration with MASTER CHECKLIST

This skill is referenced in **Step 7 (Exploration)** of the MASTER CHECKLIST:
- **7b. ☐ Subagent Selection (use decision tree, not all agents)**

Load this skill when you need detailed guidance on which agent or tool to use for a specific task type.
