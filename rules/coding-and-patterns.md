# Coding Style & Patterns

## Immutability (CRITICAL)

ALWAYS create new objects, NEVER mutate existing ones:
- C++: use `const`, `constexpr`, pass by const reference
- Python: use `frozen=True` dataclasses, `NamedTuple`, tuple over list where possible

## File Organization

MANY SMALL FILES > FEW LARGE FILES:
- High cohesion, low coupling
- 200-400 lines typical, 800 max
- Extract utilities from large modules
- Organize by feature/domain, not by type

## Functions

- <50 lines, single responsibility
- No deep nesting (>4 levels)
- Descriptive names -- the name IS the documentation

## Error Handling

- Handle errors explicitly at every level
- C++: use Result types or exceptions at boundaries, not in RT paths
- Python: explicit try/except with specific exception types
- ROS2: use rclcpp::Logger, never print/cout in production
- Never silently swallow errors

## Input Validation

- Validate all external input (parameters, messages, sensor data)
- Use schema-based validation where available
- Fail fast with clear error messages
- Range-check sensor values before use

---

## Python Standards

- Follow **PEP 8** conventions
- Use **type annotations** on all function signatures
- Use `rclpy` logging, never `print()` in production nodes
- **black** for formatting, **isort** for imports, **ruff** for linting

### Immutable Data Types

```python
from dataclasses import dataclass
from typing import NamedTuple

@dataclass(frozen=True)
class SensorConfig:
    frame_id: str
    update_rate: float
    topic: str

class Pose2D(NamedTuple):
    x: float
    y: float
    theta: float
```

### Protocol (Duck Typing)

```python
from typing import Protocol

class SensorDriver(Protocol):
    def configure(self, params: dict) -> bool: ...
    def read(self) -> SensorData: ...
    def shutdown(self) -> None: ...
```

### ROS2 Python Specifics

- Always call `declare_parameter()` with defaults in `__init__`
- Use `self.get_logger()` not `print()` or `logging`
- Callbacks should be short -- offload heavy work to separate threads
- Use `ReentrantCallbackGroup` only when necessary
- Timer-based periodic tasks, not while-loop + sleep

---

## C++ Standards

- ROS2 style guide, ament_lint
- `const` and `constexpr` wherever possible
- Pre-allocate buffers in real-time paths (no dynamic allocation)
- Pass by const reference, return by value or smart pointer

---

## ROS2 Lifecycle Node Pattern

```python
class MyNode(LifecycleNode):
    def __init__(self):
        super().__init__('my_node')
        self.declare_parameter('param_name', default_value)

    def on_configure(self, state):
        # Initialize resources
        return TransitionCallbackReturn.SUCCESS

    def on_activate(self, state):
        # Start processing
        return TransitionCallbackReturn.SUCCESS

    def on_deactivate(self, state):
        # Stop processing
        return TransitionCallbackReturn.SUCCESS

    def on_cleanup(self, state):
        # Release resources
        return TransitionCallbackReturn.SUCCESS
```

## Launch File Pattern

```python
def generate_launch_description():
    use_sim = LaunchConfiguration('use_sim', default='true')
    return LaunchDescription([
        DeclareLaunchArgument('use_sim', default_value='true'),
        Node(
            package='my_pkg',
            executable='my_node',
            parameters=[{'use_sim': use_sim}],
        ),
    ])
```

## Quality Checklist

- [ ] Code is readable and well-named
- [ ] Functions are small (<50 lines)
- [ ] Files are focused (<800 lines)
- [ ] No deep nesting (>4 levels)
- [ ] Proper error handling
- [ ] No hardcoded values (use constants, parameters, or config)
- [ ] No mutation where avoidable
- [ ] No dynamic allocation in real-time paths
