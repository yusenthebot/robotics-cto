---
name: sdd-init
description: "SDD Phase 1: Intent definition and spec generation. Architect (Opus) researches codebase, brainstorms with Yusen, writes spec.md with testable acceptance criteria. STOPS for CEO approval."
---

# SDD Phase 1: Intent Definition → spec.md

**Agent**: Architect (Opus)
**Output**: `.sdd/spec.md`
**Gate**: CEO/CTO approval (BLOCKING)

## Preconditions

- A clear feature description or problem statement from Yusen
- If `.sdd/` doesn't exist, create it with initial status.json

## Execution Steps

### 1. Initialize .sdd/ (if new)

```
mkdir -p .sdd
```

Write initial status.json:
```json
{
  "project": "<project-name>",
  "current_phase": "spec",
  "spec_status": "draft",
  "plan_status": "pending",
  "tasks_status": "pending",
  "tasks_progress": { "total": 0, "completed": 0, "in_progress": 0, "pending": 0 },
  "test_metrics": { "total_tests": 0, "passed": 0, "failed": 0, "coverage_percent": 0 },
  "history": [{ "timestamp": "<now>", "action": "init", "agent": "dispatcher", "details": "<description>" }]
}
```

### 2. Research (search-first)

Before writing anything, understand the existing landscape:

- **Local**: Grep/glob the project for related code, existing tests, existing interfaces
- **ROS2 ecosystem**: `ros2 pkg list | grep <keyword>`, `apt search ros-humble-<keyword>`
- **Dependencies**: Read package.xml, CMakeLists.txt to understand current structure
- **Topology**: What nodes exist? What topics/services? What's the TF tree?

Use the iterative-retrieval skill if working in an unfamiliar package.

### 3. Brainstorm with Yusen

Ask targeted questions to resolve ambiguity:
- What nodes? What topics/services/actions? What message types?
- RT constraints? Hardware dependencies? Sim/real?
- Cross-platform requirements (wheeled/quadruped/humanoid)?
- What's explicitly out of scope?

Do NOT ask open-ended questions. Present options with recommendations.

### 4. Write spec.md

Follow the template from sdd/SKILL.md. Critical requirements:

- Section 7 (Interface Definitions): MUST have complete ROS2 interface tables
- Section 8 (Test Contracts): MUST have testable assertions — these become RED tests in Phase 4
- Section 9 (Acceptance Criteria): Each criterion must be verifiable by running a command

### 5. Update status.json

```json
{ "action": "spec_draft", "agent": "architect", "details": "Spec drafted, awaiting CEO review" }
```

### 6. Prepare Executive Summary

MANDATORY format — never dump the full spec:

```markdown
## Review Request: [Project/Module]

### One-liner
<!-- What this spec does -->

### Key Decisions (need CEO/CTO call)
1. [Decision 1]: Option A vs B, recommended A because...

### Impact
- Nodes added/modified:
- Topics/services affected:

### Risks
- [Risk 1]

### Attachments
- Full spec.md available at .sdd/spec.md
```

### 7. STOP — Wait for CEO approval

Do NOT proceed to plan.md. Present the executive summary and wait.

When approved, update status.json:
```json
{
  "spec_status": "approved",
  "current_phase": "plan"
}
```
Add history entry with timestamp.
