---
name: agent-debug
description: Structured self-debugging workflow when an agent is stuck, looping, or consuming tokens without progress. Four-phase loop — capture, diagnose, recover, report.
---

# Agent Introspection Debugging

Use when an agent run is failing repeatedly, consuming tokens without progress, or looping on the same tools.

## When to Activate

- Maximum tool call / loop-limit failures
- Repeated retries with no forward progress
- Context growth that degrades output quality
- Tool failures that are likely recoverable with diagnosis

## Four-Phase Loop

### Phase 1: Capture

Before retrying, record the failure:

```markdown
## Failure Capture
- Goal in progress:
- Error:
- Last successful step:
- Last failed tool/command:
- Repeated pattern seen:
- Environment to verify: cwd, branch, ROS2 workspace state
```

### Phase 2: Diagnose

Match to known pattern:

| Pattern | Likely Cause | Check |
|---------|-------------|-------|
| Same command repeated 3+ times | Loop, no exit condition | Review last N tool calls |
| colcon build fails after "fix" | Wrong hypothesis about error | Read actual compiler error |
| File missing after write | Wrong cwd or branch | `pwd`, `git status`, `ls` |
| ROS2 node won't start | Missing dependency or param | `ros2 pkg xml`, parameter file |
| Test passes locally, fails in CI | Environment difference | Check Python version, ROS2 distro |

### Phase 3: Contained Recovery

Smallest safe action:
1. Restate the real objective in one sentence
2. Verify world state (`pwd`, `git status`, `colcon list`)
3. Shrink the failing scope to ONE file/test/node
4. Run one discriminating check
5. Only then retry

### Phase 4: Report

```markdown
## Debug Report
- Failure: [what broke]
- Root cause: [why]
- Recovery: [what was done]
- Result: success | partial | blocked
- Follow-up: [any remaining issues]
```

## Escalation

If stuck after 2 recovery attempts:
- Engineer agents (Alpha/Beta/Gamma) -> escalate to Architect (Opus)
- Architect -> present executive summary to Yusen
