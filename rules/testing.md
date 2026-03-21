# Testing & TDD

## Minimum Test Coverage: 80%

Test types (ALL required for production code):
1. **Unit Tests** -- Individual functions, utilities, algorithms (pytest / gtest)
2. **Integration Tests** -- Node interactions, service calls, topic pub/sub (launch_testing)
3. **System Tests** -- Full pipeline validation in simulation

## Test-Driven Development (MANDATORY)

```
1. Write test first (RED)
2. Run test -- it should FAIL
3. Write minimal implementation (GREEN)
4. Run test -- it should PASS
5. Refactor (IMPROVE)
6. Verify coverage (80%+)
```

### Rules

- Tests MUST be based on spec interface definitions, NOT on implementation ideas
- Test behavior, not implementation: "node publishes detection within 200ms" not "node calls model.predict()"
- Test names must clearly describe behavior: `test_node_handles_empty_image_gracefully`
- QA agents may reject code with no tests, happy-path-only tests, or tests that cover implementation details instead of interface behavior

### TDD Exemptions (tests still required afterward)

- Launch files and configuration (use integration tests)
- Pure UI/visualization components (e.g., RViz plugins)
- Hardware driver exploration code (add tests once stable)

---

## ROS2 Test Layers

| Layer | When | Framework | Speed | Scope |
|-------|------|-----------|-------|-------|
| Unit | Per task (TDD cycle) | pytest / gtest | Fast (<1s) | Single function/class |
| Integration | Per wave (gate) | launch_testing | Medium (5-30s) | Node interactions |
| System | Final phase | launch_testing + sim | Slow (30s+) | Full pipeline |

### What to Test at Each Layer

**Unit** (in TDD cycle):
- Pure functions, algorithms, data transforms
- Parameter validation, range checks
- Message construction, serialization
- State machine transitions

**Integration** (wave gate):
- Topic pub/sub connectivity + QoS
- Service call/response contracts
- Action server lifecycle
- TF2 transform chains
- Lifecycle node transitions

**System** (final):
- End-to-end data flow in simulation
- Failure/recovery scenarios
- Performance under load
- E-stop paths

### ROS2 Integration Test Pattern

```python
import launch_testing
import launch_testing.actions

def generate_test_description():
    node = Node(package='my_pkg', executable='my_node')
    return LaunchDescription([
        node,
        launch_testing.actions.ReadyToTest(),
    ]), {'my_node': node}

class TestMyNode(unittest.TestCase):
    def test_node_starts(self, proc_info):
        proc_info.assertWaitForStartup(process=self.my_node, timeout=5)
```

### Test Organization

```python
import pytest

@pytest.mark.unit
def test_inverse_kinematics():
    ...

@pytest.mark.integration
def test_sensor_pipeline():
    ...

@pytest.mark.hardware
def test_motor_controller():
    ...  # Skip in CI, run on hardware only
```

## Build Verification

```bash
colcon build --packages-select <pkg> --cmake-args -DCMAKE_BUILD_WARNINGS=ON
colcon test --packages-select <pkg>
colcon test-result --verbose
```

## Coverage

```bash
# Python
pytest --cov=src --cov-report=term-missing

# Full workspace
colcon test --packages-select <pkg>
colcon test-result --verbose
```

## Agent Support

- **tdd-guide** -- use proactively for new features, enforces write-tests-first
- **build-error-resolver** -- use when build/test failures occur
- **code-reviewer** -- use after every code change
