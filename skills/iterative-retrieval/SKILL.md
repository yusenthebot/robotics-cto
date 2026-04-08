---
name: iterative-retrieval
description: 3-round progressive context retrieval for subagents working in unfamiliar ROS2 packages. Search systematically before writing code.
---

# Iterative Retrieval — Subagent Context Protocol

When dispatched to work in an unfamiliar package or module, do NOT start writing code immediately. Run this 3-round retrieval protocol first.

## When to Activate

- Assigned to a ROS2 package you haven't explored this session
- Task spans multiple packages or crosses package boundaries
- You're about to write a new file but aren't sure what already exists
- You grep'd once and found nothing — the codebase may use different terminology

## The 3-Round Protocol

### Round 1: Broad Discovery (what exists?)

Goal: understand the package structure and naming conventions.

```
1. ls the package root — see directory structure
2. Read package.xml or setup.cfg — see dependencies and description
3. Glob *.py or *.cpp — see all source files
4. Read the main node file — understand the coding style
```

After Round 1 you should know:
- Directory layout (src/ vs package_name/ vs nodes/)
- Naming convention (snake_case? what prefix?)
- What nodes already exist
- What msg/srv/action types are used

### Round 2: Targeted Search (what's relevant?)

Goal: find code directly related to your task.

```
1. Grep for the functionality keywords in YOUR terms
2. If nothing found — grep for SYNONYMS the codebase might use
   (e.g., "perception" vs "detection", "waypoint" vs "goal", "obstacle" vs "costmap")
3. Read the 2-3 most relevant files completely
4. Check the launch files — understand the node graph
```

After Round 2 you should know:
- Which files you need to modify
- What existing functions/classes you can reuse
- What topics/services/actions are already defined
- What the launch configuration expects

### Round 3: Gap Check (what's missing?)

Goal: verify you have enough context to start.

```
1. Do you know the message types you'll publish/subscribe?
   → If no, read the msg/srv/action definitions
2. Do you know the parameter names and defaults?
   → If no, read the parameter declarations in existing nodes
3. Do you know the QoS settings used by related topics?
   → If no, check existing publishers/subscribers
4. Do you know the test patterns used in this package?
   → If no, read one existing test file
```

After Round 3: you have sufficient context. Start coding.

## Stopping Early

If Round 1 already gives you everything (e.g., small package, familiar structure), skip to coding. Don't do 3 rounds for the sake of it.

## Anti-Patterns

- Grep once, find nothing, start writing from scratch → WRONG (try synonyms)
- Read every file in the package → WRONG (too much context burn)
- Skip straight to writing code → WRONG (you'll duplicate existing utilities)
- Ask the user "what files should I look at?" → WRONG (you have grep/glob, use them)

## Integration

This skill is automatically relevant to:
- vr-alpha, vr-beta, vr-gamma when assigned cross-package tasks
- Any agent dispatched with `isolation: "worktree"` (starts with minimal context)
- SDD plan.md execution phase when tasks span multiple packages
