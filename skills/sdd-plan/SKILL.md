---
name: sdd-plan
description: "SDD Phase 2: Technical planning. Architect (Opus) reads approved spec, scans codebase for reuse, writes plan.md with test strategy. STOPS for architectural changes."
---

# SDD Phase 2: Technical Planning → plan.md

**Agent**: Architect (Opus)
**Prereq**: spec.md approved (spec_status == "approved")
**Output**: `.sdd/plan.md`
**Gate**: CEO approval for architectural changes; async review for non-architectural

## Preconditions

Check status.json:
- `spec_status` must be `"approved"`
- `current_phase` must be `"plan"`

If not, STOP and report the issue.

## Execution Steps

### 1. Read Approved Spec

Read `.sdd/spec.md` completely. Extract:
- Interface definitions (topics, services, actions, TF frames)
- Test contracts (these drive the test strategy)
- Acceptance criteria
- Technical constraints

### 2. Search-First: Scan for Reuse

Before designing anything, check what already exists:

```bash
# Existing implementations in this workspace
grep -r "class.*Node" src/ --include="*.py" --include="*.cpp" | head -20

# Existing ROS2 packages that might provide needed functionality
ros2 pkg list | grep -i <keyword>
apt search ros-humble-<keyword>

# Existing test patterns
find tests/ -name "*.py" -exec head -5 {} \; | grep "def test_"
```

### 3. Write plan.md

Follow the template from sdd/SKILL.md. Critical requirements:

- **Module Design**: Each module has clear responsibility, inputs, outputs, dependencies
- **Data Flow**: How data flows between modules — topic names, message types, QoS
- **Test Strategy**: Specific test approach per module:
  - Which functions get unit tests
  - Which node interactions get integration tests
  - What the launch_testing setup looks like
- **Risks & Mitigations**: At least 3 risks identified

### 4. Classify: Architectural or Non-Architectural?

**Architectural** (requires CEO blocking approval):
- New core nodes added or removed
- New/changed msg/srv/action interfaces
- Cross-package data flow changes
- New external dependencies

**Non-architectural** (CEO reviews async, agent team proceeds):
- Internal refactoring within a package
- Adding tests to existing code
- Configuration changes
- Bug fixes with clear scope

### 5. Update status.json

```json
{
  "plan_status": "review",
  "current_phase": "plan"
}
```
Add history entry: `"plan_draft"`.

### 6. Prepare Executive Summary

Same mandatory format as Phase 1. Include:
- Architecture diagram (mermaid if helpful)
- Module list with one-line descriptions
- Test strategy summary
- Whether this is architectural or non-architectural

### 7. Gate

**If architectural**: STOP — wait for CEO approval. Update `plan_status: "approved"` when approved.

**If non-architectural**: Update `plan_status: "approved"`, advance `current_phase: "tasks"`. Note in executive summary that Yusen can review async.
