---
name: learn
description: /learn — Extract reusable patterns from the current session. Run when you solved a non-trivial problem worth remembering.
---

# /learn — Extract Reusable Patterns

Analyze the current session and extract patterns worth saving as skills for future sessions.

## When to Use

Run `/learn` when you just:
- Solved a non-trivial bug (especially one that took multiple attempts)
- Discovered a ROS2/library quirk or workaround
- Found a debugging technique that wasn't obvious
- Established a project-specific convention
- Figured out a colcon/CMake/ament configuration trick

Do NOT run `/learn` for:
- Simple typo fixes or syntax errors
- One-time issues (specific API outage, transient network problem)
- Things already documented in official ROS2/library docs
- Information already in your CLAUDE.md or rules/

## Process

1. Review the current session for the most valuable insight
2. Identify the pattern: Problem → Root Cause → Solution → When You'll See This Again
3. Draft a skill file following the format below
4. Show the draft to Yusen for confirmation
5. Save to `~/.claude/skills/learned/`

## Output Format

Save to `~/.claude/skills/learned/<pattern-name>.md`:

```markdown
---
name: <pattern-name>
description: <one-line description of when this pattern applies>
type: learned
extracted: <YYYY-MM-DD>
project: <which project this came from>
---

# <Descriptive Pattern Name>

## Problem
<What went wrong or was confusing — be specific>

## Root Cause
<Why it happened — the non-obvious part>

## Solution
<What fixed it — concrete steps or code>

## When You'll See This Again
<Trigger conditions — what situation should activate this knowledge>
```

## Examples of Good Patterns to Extract

### Example 1: ROS2 Environment
```
Problem: colcon build uses wrong Python (3.13 from miniconda instead of 3.10 from ROS2)
Root Cause: miniconda PATH shadows /usr/bin/python3
Solution: prepend /usr/bin to PATH before colcon build
When: any colcon operation on a machine with miniconda installed
```

### Example 2: Hardware Interface
```
Problem: Go2 nav oscillates near obstacles
Root Cause: safety margin didn't account for robot body width (0.34m front)
Solution: subtract body radius from obstacle distance before feeding to planner
When: any time you're tuning obstacle avoidance for Go2
```

### Example 3: Build System
```
Problem: ament_cmake package can't find a Python dependency at build time
Root Cause: missing <exec_depend> in package.xml (had <build_depend> but not exec)
Solution: add both <build_depend> and <exec_depend> for Python packages
When: adding a new Python dependency to a C++ ROS2 package
```

## Quality Bar

A good learned pattern:
- Saves at least 10 minutes next time it's encountered
- Is not obvious from reading the error message alone
- Applies to more than one specific instance
- Includes the root cause, not just the fix
