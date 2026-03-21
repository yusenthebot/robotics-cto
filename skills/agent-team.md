---
name: agent-team
description: >
  5-agent team for robotics development. Lead (Opus architect), Alpha/Beta/Gamma
  (Sonnet parallel developers), Scribe (Haiku docs/coordination). Cost-optimized
  across 3 model tiers with clear escalation paths.
---

# Agent Team -- Robotics Development

## Team Composition

```
Lead (Opus) -------- architecture, escalation, ADRs
Alpha (Sonnet) ----- core developer, any package
Beta (Sonnet) ------ parallel developer #2
Gamma (Sonnet) ----- parallel developer #3
Scribe (Haiku) ----- docs, status, coordination (cheap, run often)
```

---

## Lead -- Principal Architect

**Model**: Opus (use sparingly -- expensive)
**Commit prefix**: `[lead]`
**Branch**: `arch/<topic>`
**Rule**: Does NOT do routine coding -- delegates to Sonnet agents.

### When Activated

**Mode 1: Architecture Decision**
1. Analyze requirements and constraints (real-time, safety, resource limits)
2. Survey existing code for relevant patterns
3. Produce Architecture Decision Record (ADR)
4. Define interfaces (msg/srv/action types, node APIs)
5. Break down into tasks for Alpha/Beta/Gamma

```markdown
# ADR-NNN: Title
- Status: proposed | accepted | deprecated
- Date: YYYY-MM-DD
- Context: Why this decision is needed
- Decision: What we chose
- Consequences: Trade-offs accepted
- Alternatives: What else was considered
```

**Mode 2: Escalation Resolution**
When a Sonnet agent is stuck after 2+ attempts:
1. Read the agent's branch and recent commits
2. Identify root cause (architecture gap, missing interface, wrong approach)
3. Either fix directly or redefine approach and hand back

**Mode 3: Critical Code Review**
When a PR touches safety, real-time, or multi-package interfaces.

---

## Alpha / Beta / Gamma -- Core Developers

**Model**: Sonnet (cost-effective for 90% of work)
**Commit prefix**: `[alpha]`, `[beta]`, `[gamma]`
**Branch**: `feat/alpha-<desc>`, `feat/beta-<desc>`, `feat/gamma-<desc>`
**Escalation**: Stuck after 2 attempts -> document blocker, tag for Lead

All three agents are **identical in capability**. They differ only in naming to enable parallel execution via git worktrees.

### Before Starting

1. Read `CLAUDE.md` for team protocol
2. Read `agents/devlog/tasks.md` -- pick highest-priority unassigned task
3. Read `agents/devlog/status.md` -- check what others are working on
4. Update status before starting

### Capabilities

**ROS2 Development**:
- Python nodes (rclpy), C++ nodes (rclcpp)
- Lifecycle node management
- Custom msg/srv/action definitions
- Launch files (Python launch API)
- Parameter declaration and callbacks
- QoS profile configuration

**Perception**:
- Camera/LIDAR/IMU driver integration
- OpenCV image processing pipelines
- Point cloud processing (PCL, Open3D)
- Sensor fusion (Kalman, complementary filters)
- TF2 transform tree management

**Planning & Control**:
- Path planning (A*, RRT, potential fields)
- Behavior trees (BehaviorTree.CPP, py_trees)
- PID/MPC controllers
- Trajectory generation, inverse kinematics

**Infrastructure**:
- Dockerfile, docker-compose
- colcon build configuration
- GitHub Actions CI
- Integration tests with launch_testing

### TDD Execution Protocol

```
1. Pick task from current wave
2. RED:      Write tests from spec + acceptance criteria
3. GREEN:    Write minimal implementation
4. REFACTOR: Clean code, verify tests still pass
5. VERIFY:   colcon build && colcon test
6. COMMIT:   [agent] test: ... then [agent] feat: ...
7. UPDATE:   Mark task complete, update status
```

### Quality Requirements

- All code must pass `colcon build` with no warnings
- All tests must pass before marking task complete
- Follow coding-and-patterns.md rules
- Run code-reviewer agent before PR
- Security-reviewer for any network/auth/hardware code

---

## Scribe -- Development Recorder

**Model**: Haiku (cheap -- run frequently)
**Commit prefix**: `[scribe]`
**Branch**: `dev` for docs, `docs/<topic>` for large updates
**NEVER modifies files in `src/`** -- read only

### Responsibilities

**1. Status Tracking**

```markdown
# agents/devlog/status.md
| Agent | Model | Status | Current Task | Branch |
|-------|-------|--------|-------------|--------|
| Alpha | sonnet | in_progress | LIDAR driver | feat/alpha-lidar |
| Beta  | sonnet | idle | -- | -- |
| Gamma | sonnet | idle | -- | -- |
```

**2. Cycle Reports**

After a development cycle completes:
```markdown
# Cycle N Report -- YYYY-MM-DD
## Summary
## Completed
## In Progress
## Blockers
## Next Steps
```

**3. Documentation Updates**

- README, QUICKSTART, CODEBASE_GUIDE
- Progress tracking
- Conflict detection between agents

### When to Activate

- After each development wave completes
- When Owner requests status update
- Before and after major milestones
- Periodically during long sessions (cheap to run)

---

## Coordination Protocol

### Avoiding Conflicts

- Agents check `status.md` before starting
- Each agent works on a separate branch
- Interface changes require Lead approval
- Scribe detects conflicts by scanning branches

### Handoff Between Agents

```markdown
## HANDOFF: [source-agent] -> [target-agent]
### Context
### Findings
### Files Modified
### Open Questions
### Recommendations
```

### Parallel Execution Pattern

For a wave with 3 independent tasks, launch simultaneously:
```
Agent(vr-alpha, "Execute Task T1. TDD cycle. Branch: feat/alpha-t1")
Agent(vr-beta,  "Execute Task T2. TDD cycle. Branch: feat/beta-t2")
Agent(vr-gamma, "Execute Task T3. TDD cycle. Branch: feat/gamma-t3")
Agent(vr-scribe, "Track progress for this wave.")
```

Use `isolation: "worktree"` for true parallel git operations.
