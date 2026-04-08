---
description: "Enhanced SDD status dashboard. Shows phase, progress, test metrics, and next action."
---

# /sdd-status — SDD Progress Dashboard

$ARGUMENTS

Read `.sdd/status.json` from the current project directory. If it doesn't exist, report "No SDD project in this directory."

Display a concise dashboard:

```
SDD: [project name]
Phase: [current_phase] ██████████░░ [percentage]
Spec: [status]  Plan: [status]  Tasks: [status]

Tasks: [completed]/[total] done, [in_progress] active, [pending] queued
Tests: [passed]/[total] ([coverage]% coverage)

Last action: [history[-1].details]
Next: [what needs to happen based on state machine logic]

Blocking: [YES: waiting for CEO approval on X | NO: can auto-advance]
```

If `$ARGUMENTS` is `--history`, also show the full history timeline.
If `$ARGUMENTS` is `--all`, scan all projects on Desktop for .sdd/status.json and show a summary table.
