---
description: "SDD automatic state machine. Reads .sdd/status.json, determines next phase, executes it, stops at CEO gates. Supports crash recovery."
---

# /sdd-auto — Automatic SDD State Machine

Reads `.sdd/status.json` and automatically advances to the next phase. Stops at CEO approval gates.

$ARGUMENTS

## State Machine Logic

Read `.sdd/status.json` from the current project directory. If it doesn't exist, report error and suggest `/sdd init`.

Based on `current_phase` and document statuses, execute the following:

### State: spec + draft
**Action**: The spec needs to be written or revised.
1. Load the `sdd-init` skill
2. Execute Phase 1: research codebase, write spec.md
3. Update status.json: `spec_status: "review"`
4. Present executive summary to Yusen
5. **STOP** — wait for `/sdd approve` or `/sdd reject`

### State: spec + review
**Action**: Spec is awaiting CEO approval.
1. Show the executive summary again
2. **STOP** — remind Yusen to approve or reject

### State: spec + approved, current_phase == plan, plan_status == pending|draft
**Action**: Spec approved, plan needs to be written.
1. Load the `sdd-plan` skill
2. Execute Phase 2: read spec, scan codebase, write plan.md
3. Classify: architectural or non-architectural?
4. If **architectural**: update `plan_status: "review"`, present executive summary, **STOP**
5. If **non-architectural**: update `plan_status: "approved"`, advance `current_phase: "tasks"`, **continue to next state**

### State: plan + approved, current_phase == tasks, tasks_status == pending|draft
**Action**: Plan approved, tasks need to be decomposed.
1. Load the `sdd-tasks` skill
2. Execute Phase 3: decompose into tasks with TDD structure
3. QA review (automated, no CEO needed)
4. Update `tasks_status: "approved"`, advance `current_phase: "execute"`
5. **Continue to next state** (no CEO gate here)

### State: current_phase == execute
**Action**: Tasks approved, execute TDD in parallel.
1. Load the `sdd-execute` skill
2. Check for crash recovery: if `in_progress` tasks exist, resume from there
3. Execute wave by wave:
   - Parse task.md for current wave
   - Dispatch subagents (Alpha/Beta/Gamma) in parallel via Agent tool
   - Wait for completion
   - Wave gate: colcon build + test
   - De-sloppify pass
   - Advance to next wave
4. After all waves: integration tests
5. Update `current_phase: "review"`
6. **Continue to next state**

### State: current_phase == review
**Action**: All tasks done, run QA.
1. Load the `sdd-qa` skill
2. Full build + test + coverage
3. Parallel code-review + security-review via subagents
4. Generate completion report in `.sdd/executive-briefs/`
5. Present executive summary to Yusen
6. **STOP** — wait for final release approval

### State: current_phase == done
**Action**: Project complete.
1. Report: "SDD cycle complete. Project: [name]. Tasks: N/N. Tests: X passed."
2. No further action.

## Crash Recovery

If the session crashes or is interrupted:
1. On next `/sdd-auto`, status.json is read
2. `completed` tasks are NOT re-executed
3. `in_progress` tasks are re-dispatched
4. The state machine picks up from the exact point of interruption

## CEO Gates (where /sdd-auto STOPS)

1. **After spec.md draft** — "Review Request" executive summary
2. **After architectural plan.md draft** — "Review Request" executive summary
3. **After QA complete** — "Completion Report" executive summary

At each gate, Yusen uses:
- `/sdd approve` — advance to next phase
- `/sdd reject <feedback>` — agent revises current phase

## Non-Blocking Phases (auto-advance)

- Non-architectural plan.md — auto-approved, Yusen reviews async
- task.md — QA reviews, auto-approved
- TDD execution — fully autonomous per wave
- De-sloppify — fully autonomous

## Directory Management

On first run, ensure these directories exist:
```
.sdd/summaries/
.sdd/executive-briefs/
```

Write a human-readable `.sdd/STATE.md` after each state transition:
```markdown
# SDD State: [phase]
Project: [name]
Phase: [current_phase]
Last action: [description]
Next: [what happens next or what's blocking]
Updated: [timestamp]
```
