---
name: reasoning-tools
description: Decision framework for code-reasoning vs shannon-thinking MCP tools
version: "1.0.0"
---

# MCP Reasoning Tools Decision Framework

Comprehensive guide for choosing between code-reasoning and shannon-thinking MCP servers for structured problem-solving.

## Overview

Two complementary MCP servers for structured thinking:
- **code-reasoning:** Iterative, exploratory thinking with branching
- **shannon-thinking:** Structured, rigorous analysis with formal validation

This skill provides:
- Decision framework for tool selection
- Quick reference comparison table
- Practical examples
- Integration strategy for using both

---

## Decision Framework

```
Is this a problem with...
│
├─ Writing/debugging code, step-by-step reasoning?
│  └─ Use: code-reasoning ✅
│
├─ System design, architecture, or theoretical analysis?
│  └─ Use: shannon-thinking ✅
│
└─ Unclear? Ask: "Do I need to track uncertainty and assumptions?"
   ├─ Yes → shannon-thinking
   └─ No → code-reasoning
```

---

## Quick Reference Comparison

| Scenario | code-reasoning | shannon-thinking |
|----------|----------------|------------------|
| **Debugging a specific bug** | ✅ Better | ❌ |
| **Step-by-step algorithm design** | ✅ Better | ⚪ OK |
| **System architecture decisions** | ⚪ OK | ✅ Better |
| **Evaluating tradeoffs with unknowns** | ❌ | ✅ Better |
| **Root cause analysis (complex)** | ⚪ OK | ✅ Better |
| **Quick problem decomposition** | ✅ Better | ❌ Overkill |
| **Formal proof/validation needed** | ❌ | ✅ Better |
| **Tracking dependencies between decisions** | ❌ | ✅ Better |

---

## code-reasoning

### Best For

**Iterative, exploratory thinking:**
- Debugging code
- Algorithm design
- Refactoring decisions
- Feature implementation
- Quick exploration with branching

### Key Features

- **Thought-by-thought progression:** Each thought builds on previous
- **Branching:** Explore alternative approaches (branch_from_thought + branch_id)
- **Revision:** Correct earlier thinking (is_revision + revises_thought)
- **Dynamic total:** Adjust total_thoughts as understanding evolves
- **Uncertainty tracking:** Express confidence in conclusions

### Parameters

```typescript
{
  thought: string,                    // Current reasoning step
  thought_number: number,             // Current number in sequence
  total_thoughts: number,             // Estimated final count (adjustable)
  next_thought_needed: boolean,       // Set false when complete
  branch_from_thought?: number,       // For exploring alternatives
  branch_id?: string,                 // Branch identifier
  is_revision?: boolean,              // Correcting earlier thinking
  revises_thought?: number            // Which thought to revise
}
```

### Example Use Case

**Debugging React component not rendering:**
```
Thought 1: Examine component code for obvious errors
Thought 2: Check if props are being passed correctly
Thought 3: Verify state updates trigger re-renders
Thought 4 (branch A): Could be useEffect dependency issue
Thought 5 (branch B): Or could be conditional rendering logic
Thought 6 (revision of 3): Actually, state updates ARE happening - need to revise approach
Thought 7: Focus on React DevTools inspection
```

---

## shannon-thinking

### Best For

**Structured, rigorous analysis:**
- Architecture decisions
- System design with constraints
- Root cause analysis with unknowns
- Decisions requiring uncertainty quantification (0-1 confidence)
- Validation combining theory + experiments

### The 5 Stages

1. **Problem Definition:** Identify fundamental elements
2. **Constraints:** System limitations and boundaries
3. **Model:** Mathematical/theoretical framework
4. **Proof/Validation:** Formal proofs AND experimental testing
5. **Implementation:** Practical application with constraints

### Key Features

- **Structured progression:** Problem → Constraints → Model → Proof → Implementation
- **Uncertainty quantification:** Confidence levels (0-1) for each thought
- **Explicit assumptions:** Track what you're assuming
- **Dependencies:** Which thoughts build on which
- **Recheck mechanism:** Mark steps for re-examination
- **Dual validation:** Formal proofs + experimental testing

### Parameters

```typescript
{
  thought: string,
  thoughtType: "problem_definition" | "constraints" | "model" | "proof" | "implementation",
  thoughtNumber: number,
  totalThoughts: number,
  uncertainty: number,              // Confidence level 0-1
  dependencies: number[],           // Thought numbers this builds on
  assumptions: string[],            // Explicit assumptions
  nextThoughtNeeded: boolean,
  isRevision?: boolean,
  revisesThought?: number,
  recheckStep?: {                   // Mark steps needing re-examination
    stepToRecheck: string,
    reason: string,
    newInformation: string
  },
  proofElements?: {                 // For formal validation
    hypothesis: string,
    validation: string
  },
  experimentalElements?: {          // For empirical testing
    testDescription: string,
    results: string,
    confidence: number,
    limitations: string[]
  },
  implementationNotes?: {
    practicalConstraints: string[],
    proposedSolution: string
  }
}
```

### Example Use Case

**Designing rate limiting for API:**
```
Stage 1 (Problem Definition):
- Define: Prevent abuse while allowing legitimate traffic
- Assumptions: [list explicit assumptions]

Stage 2 (Constraints):
- Max requests per user: 1000/hour
- System capacity: 10K req/s
- Uncertainty: 0.8 (confident in these numbers)

Stage 3 (Model):
- Token bucket algorithm
- Dependencies: Stages 1, 2
- Mathematical model: [equations]

Stage 4 (Proof):
- Hypothesis: Token bucket prevents abuse while maintaining <100ms latency
- Experimental validation: Load test results
- Confidence: 0.9

Stage 5 (Implementation):
- Practical constraints: Redis for distributed state
- Proposed solution: [architecture]
```

---

## Practical Examples

### Example 1: Fix React Component Not Rendering

| Task | Tool | Why |
|------|------|-----|
| "Fix React component not rendering" | code-reasoning | Iterative debugging |

**Approach:**
- Start with obvious checks (props, state)
- Branch if multiple hypotheses emerge
- Revise if initial assumptions wrong
- Quick, exploratory iteration

---

### Example 2: Design Rate Limiting for API

| Task | Tool | Why |
|------|------|-----|
| "Design rate limiting for API" | shannon-thinking | Constraints + model needed |

**Approach:**
- Define problem with explicit constraints
- Model mathematically (token bucket, leaky bucket)
- Validate with both theory and load testing
- Track uncertainty in capacity estimates

---

### Example 3: Implement Binary Search

| Task | Tool | Why |
|------|------|-----|
| "Implement binary search" | code-reasoning | Step-by-step algorithm |

**Approach:**
- Think through algorithm logic step-by-step
- Consider edge cases as they arise
- Quick implementation flow

---

### Example 4: Why is Database Slow Under Load?

| Task | Tool | Why |
|------|------|-----|
| "Why is database slow under load?" | shannon-thinking | Root cause with unknowns |

**Approach:**
- Define problem: Latency >500ms under 100 concurrent users
- Identify constraints: Connection pool size, query complexity
- Model: Database architecture with bottleneck analysis
- Validate: Profiling + load testing
- Track uncertainty in each hypothesis

---

### Example 5: Should We Migrate REST to GraphQL?

| Task | Tool | Why |
|------|------|-----|
| "Should we migrate REST to GraphQL?" | shannon-thinking | Formal tradeoff evaluation |

**Approach:**
- Define: API modernization decision
- Constraints: Team expertise, client diversity, performance requirements
- Model: Tradeoff matrix with explicit assumptions
- Validate: Prototype + performance benchmarks
- Implementation: Migration strategy with dependencies

---

## Integration Strategy

Use **both** in the same session for complex tasks:

### Three-Phase Approach

1. **High-level design (shannon-thinking):**
   - Problem definition
   - Constraints identification
   - Theoretical model

2. **Implementation (code-reasoning):**
   - Step-by-step coding
   - Debugging
   - Algorithm refinement

3. **Validation (shannon-thinking):**
   - Verify implementation meets model
   - Experimental validation
   - Performance analysis

### Example: Build Authentication System

**Phase 1 (shannon-thinking):**
```
Problem: Secure user authentication
Constraints: OAuth 2.1, JWT, <100ms latency
Model: Token-based auth flow with refresh tokens
```

**Phase 2 (code-reasoning):**
```
Thought 1: Implement JWT signing/verification
Thought 2: Add refresh token rotation
Thought 3: Debug token expiration logic
Thought 4: Refactor for clarity
```

**Phase 3 (shannon-thinking):**
```
Validation:
- Hypothesis: Auth flow is secure and performant
- Experimental: Load test + security audit
- Results: ✅ Meets requirements
- Confidence: 0.95
```

---

## When to Use Each Tool

### Use code-reasoning When

- Debugging specific bugs
- Implementing algorithms step-by-step
- Refactoring code
- Exploring multiple implementation approaches quickly
- Iterating on solutions with feedback

### Use shannon-thinking When

- Making architectural decisions
- Designing systems with multiple constraints
- Analyzing complex root causes with unknowns
- Evaluating tradeoffs formally
- Need to track uncertainty and assumptions explicitly
- Combining theoretical models with experimental validation

### Use Both When

- Complex projects requiring design + implementation + validation
- Architectural decisions that need prototyping
- Performance optimization with theoretical analysis
- Root cause investigations needing experimental testing

---

## Quick Decision Checklist

Ask yourself:

1. **Do I need formal proofs or validation?**
   - Yes → shannon-thinking
   - No → code-reasoning

2. **Am I tracking multiple unknowns/assumptions?**
   - Yes → shannon-thinking
   - No → code-reasoning

3. **Is this architectural/system-level?**
   - Yes → shannon-thinking
   - No → code-reasoning

4. **Am I debugging/implementing iteratively?**
   - Yes → code-reasoning
   - No → shannon-thinking

5. **Do I need 5 structured stages?**
   - Yes → shannon-thinking
   - No → code-reasoning

---

## Common Mistakes

### ❌ Wrong Tool Choice

**Mistake:** Using shannon-thinking for simple debugging
**Impact:** Overkill - wastes time on formal structure
**Fix:** Use code-reasoning for quick iteration

**Mistake:** Using code-reasoning for architecture decisions
**Impact:** Miss critical constraints and assumptions
**Fix:** Use shannon-thinking for systematic analysis

### ❌ Not Using Both

**Mistake:** Designing system with shannon-thinking but never implementing
**Impact:** Theoretical only, no validation
**Fix:** Follow up with code-reasoning for implementation

**Mistake:** Implementing with code-reasoning without design phase
**Impact:** No clear model, hard to validate correctness
**Fix:** Start with shannon-thinking for high-level design

---

## Usage

Load this skill when:
- Starting complex problem-solving (choose the right tool)
- Stuck with current approach (consider switching tools)
- Need to explain tool choice to others (reference examples)
- Building multi-phase solution (integration strategy)

**Quick check:** "Is this exploratory iteration or structured analysis?"
