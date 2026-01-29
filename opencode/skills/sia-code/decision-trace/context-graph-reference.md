# Context Graph Reference

Reference insights from "The Next Enterprise Platform Isn't Data-Driven, It's Context-Driven" (Tensorlake, Dec 2025) and "AI's trillion-dollar opportunity: Context graphs" (Foundation Capital).

These insights inform why the decision trace format captures reasoning context, not just outcomes.

## Core Thesis

**Enterprise systems store WHAT happened (outcomes), but not WHY it happened (reasoning).** The reasoning behind decisions lives in chat threads, meetings, or someone's memory — and disappears once the decision is made.

When AI agents evaluate a case, they can see current data and policies, but cannot see how similar situations were resolved in practice. **Each case is treated as new, even when the organization has already made the same decision many times.**

## Rules vs Decisions

| Aspect | Rules | Decisions |
|--------|-------|-----------|
| **Purpose** | Define expected behavior | Record what happened |
| **Scope** | General and reusable | Situation-specific |
| **Stored in systems** | Yes | Limited |
| **Covers exceptions** | No | Yes |
| **Includes prior cases** | No | Yes |
| **Explains outcomes** | No | Yes |

**Key insight:** Rules tell you the default. Decisions tell you what actually happened when the default didn't apply — and WHY.

## What Context Graphs Capture

A context graph records **structured decision traces** with:

1. **Inputs considered** — what data/signals informed the decision
2. **Rules/policies evaluated** — what constraints applied
3. **Exceptions applied** — what edge cases were handled
4. **Approval path** — who approved, what review happened
5. **Alternatives rejected** — what wasn't chosen and why
6. **Final outcome** — what was decided
7. **Temporal relationships** — how this connects to prior decisions

## Application to sia-code Memory

### Current State (Before Decision Trace Format)

```
uvx sia-code memory add-decision "Fix: Added retry logic"
```

This is an **outcome-only record** — equivalent to a system of record that stores what happened but not why.

### Improved State (With Decision Trace Format)

```
uvx sia-code memory add-decision "Fix: Added retry with backoff.
Context: Flaky CI from rate limiting.
Reasoning: Fixed delay → thundering herd; jitter considered but backoff sufficient.
Outcome: CI pass rate 80%→99%."
```

This is a **decision trace** — it captures the context graph elements in a flat string format compatible with sia-code's `add-decision` command.

### What This Enables

1. **Future sessions can understand WHY** — not just that retry was added, but why backoff specifically
2. **Similar situations match better** — searching "rate limiting" or "CI flaky" finds relevant prior reasoning
3. **Alternatives are documented** — future sessions know jitter was already considered and rejected
4. **Outcomes validate decisions** — 80%→99% confirms the approach worked
5. **Accumulated traces build organizational knowledge** — over time, patterns emerge from connected decisions

## Key Takeaway

> "When the same situation comes up again, there is nothing in the system that shows how it was handled before. Each case is treated as new."

The decision trace format prevents this by ensuring every stored learning includes the **reasoning context** that makes it useful for future decision-making.
