---
name: sdd-execute
description: "SDD Phase 4: Parallel TDD execution with FORCED subagent isolation. Each task runs in a fresh Agent with task-specific context. Wave gates between groups. De-sloppify after each wave."
---

# SDD Phase 4: TDD Execution with Subagent Isolation

**Agents**: Alpha/Beta/Gamma (Sonnet) via Agent tool — each in FRESH context
**Prereq**: task.md approved (tasks_status == "approved")
**Gate**: Wave gates (colcon build+test), then CEO final review

## Preconditions

Check status.json:
- `tasks_status` must be `"approved"`
- `current_phase` must be `"execute"`

## CRITICAL: Context Isolation

**NEVER execute tasks in the main session's context.**

Each task MUST be dispatched via the Agent tool, creating a fresh subagent with:
- Only the task description
- Relevant spec.md excerpts (interface definitions for this task)
- Relevant plan.md excerpts (module design for this task)
- The verify command
- NO conversation history from previous tasks/phases

This prevents context pollution between waves and ensures each agent starts clean.

## Execution Steps

### 1. Parse task.md

Read `.sdd/task.md`. Extract:
- All tasks with their status, agent assignment, dependencies
- Execution waves
- Identify the CURRENT wave (first wave with pending/in_progress tasks)

### 2. Crash Recovery Check

If status.json shows `in_progress` tasks:
- These tasks were interrupted. Re-dispatch them in the current wave.
- Do NOT re-execute `completed` tasks.

### 3. Execute Current Wave

For each task in the current wave, build a subagent prompt:

```markdown
# Task: [Title]

## Context
You are [Alpha/Beta/Gamma], a ROS2 engineer executing a TDD task.

## Spec Context (relevant excerpt)
[Paste ONLY the interface definitions and acceptance criteria relevant to this task from spec.md]

## Plan Context (relevant excerpt)
[Paste ONLY the module design relevant to this task from plan.md]

## Task
- Package: [pkg_name]
- Input: [files to read]
- Output: [files to create/modify]
- Test file: [test path]

## TDD Cycle (MANDATORY ORDER)
1. RED: Write tests at [test path] based on the spec interface definitions above.
   Run: [verify command] — tests MUST FAIL (implementation doesn't exist yet).
2. GREEN: Write minimal implementation at [output path] to make tests pass.
   Run: [verify command] — tests MUST PASS.
3. REFACTOR: Clean up code. Run tests again — MUST still PASS.

## Rules
- Test BEHAVIOR, not implementation
- Use self.get_logger() not print()
- Use RCLCPP_INFO not std::cout
- No hardcoded IPs or paths — use ROS2 parameters
- Lifecycle nodes for hardware interfaces
- MUST run verify command before reporting done

## Verify
[verify command from task.md]
```

### 4. Dispatch Subagents in Parallel

Launch all tasks in the current wave simultaneously:

```
Agent(subagent_type="vr-alpha", prompt="[Task T1 prompt above]")
Agent(subagent_type="vr-beta",  prompt="[Task T2 prompt above]")
Agent(subagent_type="vr-gamma", prompt="[Task T3 prompt above]")
```

**Use `isolation: "worktree"` when tasks touch overlapping files.**

Wait for all agents to complete.

### 5. Collect Results

For each completed subagent:
- Did it report success?
- What files were created/modified?
- What tests pass/fail?
- Any issues or escalations?

Update status.json per task:
```json
{
  "tasks_progress": { "completed": N+1, "in_progress": 0, "pending": M-1 }
}
```
Add history entry per task: `"task_N_complete"`.

Write task summary to `.sdd/summaries/task-N.md`:
```markdown
## Task N: [Title]
- Agent: alpha
- Files changed: [list]
- Tests: X passed, Y failed
- Duration: ~N minutes
- Issues: [any]
```

### 6. Wave Gate

After all tasks in the wave complete:

```bash
colcon build --packages-select <affected-packages>
colcon test --packages-select <affected-packages>
colcon test-result --verbose
```

If ANY test fails:
- Identify which task broke it
- Re-dispatch ONLY that task's agent with the error context
- Max 2 retries per task
- After 2 failures: escalate to Architect (Opus) via vr-lead agent

If all tests pass:
- Add history entry: `"wave_N_complete"`
- Advance to next wave

### 7. De-Sloppify Pass (after each wave)

After wave gate passes, run a cleanup agent:

```
Agent(subagent_type="code-reviewer", prompt="
  Review all files changed in the following tasks: [list].
  Apply de-sloppify checks:
  - Remove print()/std::cout debug statements
  - Remove tests that verify language behavior, not business logic
  - Remove over-defensive checks for impossible states
  - Remove commented-out code
  - Run colcon test to verify nothing breaks.
")
```

### 8. Repeat for Next Wave

Go back to step 3 with the next wave. Continue until all waves complete.

### 9. Integration Tests

After all waves:

```bash
colcon build
colcon test
colcon test-result --verbose
```

If integration tests fail, dispatch a single agent to fix.

### 10. Update Status

```json
{
  "current_phase": "review",
  "tasks_progress": { "total": N, "completed": N, "in_progress": 0, "pending": 0 }
}
```

## Escalation Protocol

Agent stuck after 2 attempts on the same error:

```
Agent(subagent_type="vr-lead", prompt="
  Architect escalation: Task [N] failed twice.
  Error: [error details]
  Files involved: [list]
  Spec context: [relevant excerpt]
  
  Diagnose root cause and either:
  1. Fix directly and report what changed
  2. Redefine the approach and hand back to Engineer
")
```
