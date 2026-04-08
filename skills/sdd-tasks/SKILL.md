---
name: sdd-tasks
description: "SDD Phase 3: Task decomposition. Break plan.md into atomic tasks with TDD structure, dependency graph, and execution waves. QA reviews, CEO not needed."
---

# SDD Phase 3: Task Decomposition → task.md

**Agent**: Engineer (Sonnet) or Dispatcher
**Prereq**: plan.md approved (plan_status == "approved")
**Output**: `.sdd/task.md`
**Gate**: QA Agent reviews (CEO not needed)

## Preconditions

Check status.json:
- `plan_status` must be `"approved"`
- `current_phase` must be `"tasks"`

## Execution Steps

### 1. Read Approved Plan

Read `.sdd/plan.md` and `.sdd/spec.md`. Extract:
- Module list with responsibilities
- Test strategy per module
- Data flow and dependencies between modules

### 2. Decompose into Atomic Tasks

Each task must be:
- **Atomic**: one task, one deliverable (one node, one utility, one interface)
- **Testable**: has explicit TDD deliverables (test file + implementation file)
- **Assignable**: can be given to one agent independently
- **Verifiable**: has a concrete verify command

For each task, specify:
```markdown
### Task N: [Title]
- **Status**: [ ] pending
- **Agent**: alpha | beta | gamma
- **Depends**: none | Task X, Task Y
- **Package**: pkg_name
- **Input**: [required files/info the agent needs to read]
- **Output**: [deliverable files the agent will create/modify]
- **Test file**: tests/unit/test_foo.py (or tests/node/test_foo.py)
- **TDD Deliverables**:
  - RED: Write failing tests based on spec interface definitions
  - GREEN: Minimal implementation to pass
  - REFACTOR: Clean up, run full suite
- **Acceptance Criteria**: [from spec]
- **Verify**: colcon build --packages-select <pkg> && colcon test --packages-select <pkg>
```

### 3. Build Dependency Graph

Identify which tasks depend on which:
```
Task 1 (msg definitions) ──> Task 3 (node using those msgs)
Task 2 (utility lib)     ──> Task 4 (node using that lib)
```

Tasks with no dependencies can run in parallel.

### 4. Assign Execution Waves

Group tasks into waves based on dependencies:

```markdown
## Execution Waves
| Wave | Tasks | Agents | Gate |
|------|-------|--------|------|
| 1 | T1, T2, T4 | Alpha, Beta, Gamma | unit tests pass |
| 2 | T3, T5 | Alpha, Beta | unit tests pass |
| 3 | T6 | Alpha | integration tests pass |
| -- | review | code-reviewer + security-reviewer | approve |
```

Rules:
- Max 3 agents per wave (Alpha, Beta, Gamma)
- If >3 independent tasks, split into sub-waves
- Each wave gate: `colcon build && colcon test` on affected packages
- Final wave: integration tests across all affected packages

### 5. Agent Assignment Strategy

- **msg/srv/action definitions**: Give to one agent (usually Alpha) — these are shared interfaces
- **Independent nodes**: Distribute across Alpha/Beta/Gamma
- **Utility libraries**: One agent per library
- **Integration tests**: After all units pass, one agent writes integration tests
- **Launch files**: Same agent as the node they launch

### 6. Update status.json

```json
{
  "tasks_status": "review",
  "current_phase": "tasks",
  "tasks_progress": {
    "total": N,
    "completed": 0,
    "in_progress": 0,
    "pending": N
  }
}
```
Add history entry: `"tasks_draft"`.

### 7. QA Review

QA Agent (code-reviewer or tdd-guide) reviews task.md:
- Are tasks truly atomic?
- Do TDD deliverables match spec acceptance criteria?
- Are dependencies correct?
- Is wave grouping optimal for parallelism?

After QA approval, update:
```json
{
  "tasks_status": "approved",
  "current_phase": "execute"
}
```

CEO is NOT needed for task.md approval. Notify async if desired.
