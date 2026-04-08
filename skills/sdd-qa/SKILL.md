---
name: sdd-qa
description: "SDD Phase 5: QA verification and delivery. Full build+test, parallel code-review + security-review, completion report for CEO. STOPS for final release approval."
---

# SDD Phase 5: QA Verification & Delivery

**Agents**: code-reviewer + security-reviewer (parallel), then Scribe
**Prereq**: All tasks completed, integration tests pass
**Output**: `.sdd/executive-briefs/completion-report.md`
**Gate**: CEO/CTO final release approval (BLOCKING)

## Preconditions

Check status.json:
- `current_phase` must be `"review"`
- `tasks_progress.completed` must equal `tasks_progress.total`

## Execution Steps

### 1. Full Build Verification

```bash
# Clean build of entire workspace
colcon build

# Full test suite
colcon test
colcon test-result --verbose
```

Record results in status.json `test_metrics`.

If build or tests fail: dispatch build-error-resolver agent. Do NOT proceed to review with failing tests.

### 2. Coverage Check

```bash
# Python coverage
colcon test --packages-select <pkg> --pytest-args --cov --cov-report=term-missing

# Check against targets from plan.md
```

Target: 80% minimum. 100% for safety-critical paths.

### 3. Parallel Quality Review

Launch two reviewers simultaneously:

```
Agent(subagent_type="code-reviewer", prompt="
  Review all files changed in this SDD cycle.
  Changed files: [list from .sdd/summaries/]
  Spec: .sdd/spec.md
  Plan: .sdd/plan.md

  Check:
  - Code meets spec acceptance criteria
  - Proper error handling
  - No hardcoded values
  - Files under 800 lines
  - Functions under 50 lines
  - Immutability preferred
  - ROS2 conventions followed

  Report: PASS/FAIL with specific file:line references.
")

Agent(subagent_type="security-reviewer", prompt="
  Security review for all files changed in this SDD cycle.
  Changed files: [list from .sdd/summaries/]

  Check:
  - No hardcoded secrets, IPs, credentials
  - Input validation on all external data (sensor, parameter, service)
  - No command injection in any shell calls
  - Sensor data range validation (NaN, inf, out-of-range)
  - Rate limiting on actuator commands
  - Proper QoS + access control on safety topics

  Report: PASS/FAIL with severity levels.
")
```

### 4. Address Review Findings

If either reviewer reports FAIL:
- Dispatch engineer agent to fix specific issues
- Re-run the failing reviewer
- Max 2 fix cycles, then escalate to Architect

### 5. Documentation Update

```
Agent(subagent_type="vr-scribe", model="haiku", prompt="
  Update documentation for this SDD cycle:
  - Update README.md if public API changed
  - Update progress.md with current state
  - Verify launch file documentation is current
  - Do NOT create new documentation files
  - Do NOT write production code
")
```

### 6. Generate Completion Report

Write to `.sdd/executive-briefs/completion-report.md`:

```markdown
## SDD Complete: [Feature Name]

### One-liner
<!-- What was built -->

### Tasks: X/X done
| Task | Agent | Tests Added | Status |
|------|-------|-------------|--------|

### Test Results
- Unit: X passed
- Integration: X passed
- Coverage: X%

### Quality Review
- Code review: PASS/FAIL
- Security review: PASS/FAIL
- Issues found and fixed: N

### Files Changed
| File | Operation |
|------|-----------|

### Risks / Known Issues
- [Any remaining]

### Ready for Release: YES / NO
```

### 7. Update status.json

```json
{
  "current_phase": "review",
  "test_metrics": {
    "total_tests": N,
    "passed": N,
    "failed": 0,
    "coverage_percent": X
  }
}
```
Add history entry: `"qa_complete"`.

### 8. STOP — Wait for CEO Final Approval

Present the completion report executive summary. Wait for Yusen's approval.

When approved:
```json
{
  "current_phase": "done"
}
```
Add history entry: `"released"`.
