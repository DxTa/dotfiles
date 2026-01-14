# Reference: Manus Context Engineering Principles

Based on workflow pattern from Manus AI (acquired by Meta for $2B).

## The 6 Principles

### 1. Filesystem as External Memory
> "Markdown is my 'working memory' on disk."

Store in files, keep paths in context. Agent "looks up" information when needed.

**Integration:** task_plan.md + notes.md = external memory. TodoWrite = working memory.

### 2. Attention Manipulation Through Repetition
After ~50 tool calls, models forget original goals ("lost in the middle" effect).

**Solution:** Re-read task_plan.md before decisions. Goals appear at end of context = high attention.

### 3. Keep Failure Traces
> "Error recovery is one of the clearest signals of TRUE agentic behavior."

**Implementation:** "Errors Encountered" section in task_plan.md. Never hide failures.

### 4. Avoid Few-Shot Overfitting
Introduce controlled variation. Vary phrasings. Don't copy-paste blindly.

### 5. Stable Prefixes for Cache Optimization
Put static content FIRST. Append-only context.

### 6. Append-Only Context
NEVER modify previous messages. Always append.

## TodoWrite + Plan Files = Best of Both

| Manus Principle | TodoWrite | task_plan.md | Combined |
|-----------------|-----------|--------------|----------|
| External memory | No (in-session) | Yes | Yes |
| Attention manipulation | No | Yes (re-read) | Yes |
| Failure traces | No | Yes | Yes |
| Live visibility | Yes | No | Yes |
| Recovery | No | Yes | Yes |

## Graphiti Integration

At task completion, review task_plan.md sections:

| Section | Graphiti Type | Example |
|---------|---------------|---------|
| Errors Encountered | Procedure | "Debug async: check await chains first" |
| Decisions Made | Preference | "Use JWT over sessions for stateless auth" |
| Key Findings | Fact | "Auth module uses async session retrieval" |

## Source
https://manus.im/de/blog/Context-Engineering-for-AI-Agents-Lessons-from-Building-Manus
