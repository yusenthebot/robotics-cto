---
name: de-sloppify
description: Post-implementation cleanup pass. Removes debug statements, useless tests, dead code, and over-defensive patterns. Run AFTER implementation, BEFORE code-review.
---

# De-Sloppify — Post-Implementation Cleanup

A focused cleanup pass that runs AFTER implementation and BEFORE code-review. Removes the slop that accumulates when agents implement freely.

## When to Activate

- After any feature implementation by Alpha/Beta/Gamma
- After TDD cycle completion (tests pass but code is messy)
- Before creating a PR
- When `/verify` shows warnings about code quality
- Integrated into SDD task.md as an implicit step after each task

## What to Remove

### 1. Debug Statements
```python
# REMOVE these:
print(f"DEBUG: {variable}")        # use self.get_logger().debug()
print("HERE")                       # debugging breadcrumb
import pdb; pdb.set_trace()         # debugger
breakpoint()                        # debugger
```

```cpp
// REMOVE these:
std::cout << "DEBUG: " << value << std::endl;  // use RCLCPP_DEBUG
printf("HERE\n");                               // debugging breadcrumb
```

### 2. Useless Tests
```python
# REMOVE: tests that verify Python itself works
def test_string_is_string():
    assert isinstance("hello", str)

# REMOVE: tests that verify the framework works
def test_node_can_be_created():
    node = Node("test")
    assert node is not None  # rclpy guarantees this

# KEEP: tests that verify YOUR business logic
def test_obstacle_distance_subtracts_body_radius():
    result = compute_safe_distance(raw_distance=1.0, body_radius=0.34)
    assert result == pytest.approx(0.66)
```

### 3. Over-Defensive Code
```python
# REMOVE: impossible-state handling
if self.publisher is None:  # impossible after __init__
    raise RuntimeError("Publisher not initialized")

# REMOVE: type checks the type system already guarantees
if not isinstance(msg, Twist):  # ROS2 subscription guarantees type
    return

# KEEP: validation at system boundaries
if msg.linear.x > MAX_VELOCITY:  # external input, must validate
    self.get_logger().warn(f"Clamping velocity: {msg.linear.x}")
    msg.linear.x = MAX_VELOCITY
```

### 4. Dead Code
```python
# REMOVE: commented-out old implementations
# def old_approach():
#     ...

# REMOVE: unused imports
from typing import Optional, List, Dict, Tuple  # only Optional is used

# REMOVE: variables assigned but never read
temp_result = compute_something()  # never used after this line
```

## Process

1. `git diff --name-only` — list all changed files
2. For each file:
   - Scan for patterns in the 4 categories above
   - Remove them
   - Do NOT add new code, only remove
3. Run `colcon test --packages-select <pkg>` — verify tests still pass
4. Run `ruff check` / `ament_lint` — verify no new lint issues
5. If tests fail after removal, the removed code was actually needed — put it back

## Key Principle

> Do NOT constrain the implementation agent with negative instructions.
> Let it implement freely, then clean up separately.
> Two focused agents > one constrained agent.

## Integration with SDD

In task.md execution, the implicit flow becomes:

```
For each task:
  1. Alpha/Beta/Gamma implements (TDD: red → green → refactor)
  2. De-sloppify pass (this skill — can be same or different agent)
  3. code-reviewer checks quality
  4. Task marked complete
```

The de-sloppify pass should be a SEPARATE agent call or at minimum a clearly separated prompt — not mixed into the implementation prompt.
