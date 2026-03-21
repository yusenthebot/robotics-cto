---
name: ros2-development
description: >
  ROS2 development patterns, lifecycle nodes, launch files, QoS strategies,
  safety-critical rules, sensor integration, and real-time constraints
  for robotics applications on ROS2 Humble.
---

# ROS2 Development Patterns

## Node Architecture

### Lifecycle Nodes (MANDATORY for hardware interfaces)

All nodes that interact with hardware MUST use lifecycle management:

```python
from rclpy.lifecycle import LifecycleNode, TransitionCallbackReturn

class LidarDriverNode(LifecycleNode):
    def __init__(self):
        super().__init__('lidar_driver')
        self.declare_parameter('scan_topic', '/scan')
        self.declare_parameter('frame_id', 'lidar_link')
        self.declare_parameter('update_rate', 10.0)

    def on_configure(self, state):
        # Initialize hardware connection, allocate buffers
        self._scan_pub = self.create_lifecycle_publisher(
            LaserScan, self.get_parameter('scan_topic').value, 10
        )
        return TransitionCallbackReturn.SUCCESS

    def on_activate(self, state):
        # Start data acquisition
        rate = self.get_parameter('update_rate').value
        self._timer = self.create_timer(1.0 / rate, self._scan_callback)
        return TransitionCallbackReturn.SUCCESS

    def on_deactivate(self, state):
        # Stop acquisition, keep resources
        self.destroy_timer(self._timer)
        return TransitionCallbackReturn.SUCCESS

    def on_cleanup(self, state):
        # Release hardware, free resources
        self.destroy_publisher(self._scan_pub)
        return TransitionCallbackReturn.SUCCESS

    def on_shutdown(self, state):
        # Emergency cleanup
        return TransitionCallbackReturn.SUCCESS
```

### Component Containers (Performance-Critical)

Co-locate nodes for zero-copy intra-process communication:

```python
from launch_ros.actions import ComposableNodeContainer, LoadComposableNode
from launch_ros.descriptions import ComposableNode

container = ComposableNodeContainer(
    name='perception_container',
    namespace='',
    package='rclcpp_components',
    executable='component_container',
    composable_node_descriptions=[
        ComposableNode(
            package='camera_driver',
            plugin='camera_driver::CameraNode',
            parameters=[{'use_intra_process_comms': True}],
        ),
        ComposableNode(
            package='image_proc',
            plugin='image_proc::DetectorNode',
            parameters=[{'use_intra_process_comms': True}],
        ),
    ],
)
```

---

## QoS Strategy

| Data Type | Profile | Reliability | Durability | History |
|-----------|---------|-------------|------------|---------|
| Commands (cmd_vel, joint) | RELIABLE | RELIABLE | VOLATILE | KEEP_LAST(1) |
| High-freq sensors (IMU, scan) | SENSOR | BEST_EFFORT | VOLATILE | KEEP_LAST(5) |
| Images / Point clouds | SENSOR | BEST_EFFORT | VOLATILE | KEEP_LAST(1) |
| Parameters / Config | RELIABLE | RELIABLE | TRANSIENT_LOCAL | KEEP_LAST(1) |
| Diagnostics | DEFAULT | RELIABLE | VOLATILE | KEEP_LAST(10) |
| TF | Static: TRANSIENT_LOCAL, Dynamic: VOLATILE |

```python
from rclpy.qos import QoSProfile, ReliabilityPolicy, DurabilityPolicy

SENSOR_QOS = QoSProfile(
    reliability=ReliabilityPolicy.BEST_EFFORT,
    durability=DurabilityPolicy.VOLATILE,
    depth=5,
)

COMMAND_QOS = QoSProfile(
    reliability=ReliabilityPolicy.RELIABLE,
    durability=DurabilityPolicy.VOLATILE,
    depth=1,
)
```

---

## Launch Files

### Parameterized Launch with Sim/Real Switching

```python
from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument, GroupAction
from launch.conditions import IfCondition, UnlessCondition
from launch.substitutions import LaunchConfiguration
from launch_ros.actions import Node

def generate_launch_description():
    use_sim = LaunchConfiguration('use_sim', default='true')
    robot_type = LaunchConfiguration('robot_type', default='wheeled')

    return LaunchDescription([
        DeclareLaunchArgument('use_sim', default_value='true',
                              description='Use simulation instead of hardware'),
        DeclareLaunchArgument('robot_type', default_value='wheeled',
                              description='Robot platform type'),

        # Simulation driver
        Node(
            condition=IfCondition(use_sim),
            package='sim_driver',
            executable='sim_node',
            parameters=[{'robot_type': robot_type}],
        ),

        # Hardware driver
        Node(
            condition=UnlessCondition(use_sim),
            package='hw_driver',
            executable='hw_node',
            parameters=[{'robot_type': robot_type}],
        ),

        # Processing (runs in both modes)
        Node(
            package='perception',
            executable='detector_node',
            remappings=[('/image_raw', '/camera/image_raw')],
            parameters=[{'robot_type': robot_type}],
        ),
    ])
```

---

## Safety-Critical Rules

### Real-Time Constraints

```
NEVER in real-time paths:
  - Dynamic memory allocation (new, malloc, push_back without reserve)
  - Blocking calls (mutex lock, disk I/O, network I/O)
  - Exceptions for control flow
  - sleep() or busy-wait loops

ALWAYS in real-time paths:
  - Pre-allocated buffers (reserve() in constructor)
  - Lock-free data structures or try_lock()
  - TimerBase for periodic execution
  - Bounded-time algorithms
```

### Watchdog Pattern

```python
class WatchdogMixin:
    """Add to any hardware interface node."""

    def _setup_watchdog(self, timeout_sec: float = 1.0):
        self._last_heartbeat = self.get_clock().now()
        self._watchdog_timer = self.create_timer(
            timeout_sec / 2, self._check_watchdog
        )

    def _feed_watchdog(self):
        self._last_heartbeat = self.get_clock().now()

    def _check_watchdog(self):
        elapsed = (self.get_clock().now() - self._last_heartbeat).nanoseconds / 1e9
        if elapsed > self._watchdog_timeout:
            self.get_logger().error(f'Watchdog timeout: {elapsed:.2f}s')
            self._emergency_stop()

    def _emergency_stop(self):
        """Override in subclass."""
        raise NotImplementedError
```

### E-Stop Requirements

- E-stop hardware circuit must be independent of software
- Software E-stop is a backup, not primary
- E-stop topic: RELIABLE QoS, highest priority
- All actuator nodes must subscribe to E-stop and respond within 1 cycle
- E-stop state must be latched (require explicit reset)

### Sensor Data Validation

```python
import math

def validate_scan(msg: LaserScan) -> bool:
    """Reject corrupted sensor data before processing."""
    for r in msg.ranges:
        if math.isnan(r) or math.isinf(r):
            return False
        if r < msg.range_min or r > msg.range_max:
            return False
    return True

def validate_imu(msg: Imu) -> bool:
    """Check IMU data for reasonable ranges."""
    MAX_ACCEL = 160.0  # m/s^2 (~16g)
    MAX_GYRO = 35.0    # rad/s (~2000 deg/s)
    a = msg.linear_acceleration
    g = msg.angular_velocity
    if any(math.isnan(v) for v in [a.x, a.y, a.z, g.x, g.y, g.z]):
        return False
    if any(abs(v) > MAX_ACCEL for v in [a.x, a.y, a.z]):
        return False
    if any(abs(v) > MAX_GYRO for v in [g.x, g.y, g.z]):
        return False
    return True
```

---

## TF2 Transform Management

```python
# Static transforms (published once, latched)
static_broadcaster = StaticTransformBroadcaster(self)
t = TransformStamped()
t.header.frame_id = 'base_link'
t.child_frame_id = 'lidar_link'
t.transform.translation.x = 0.1
static_broadcaster.sendTransform(t)

# Dynamic transforms (published at sensor rate)
broadcaster = TransformBroadcaster(self)
# Publish in timer callback at sensor frequency
```

### Frame Conventions

```
map -> odom -> base_link -> [sensor_links]
               base_link -> base_footprint (2D projection)
```

- `map -> odom`: provided by localization (AMCL, EKF)
- `odom -> base_link`: provided by odometry
- `base_link -> sensors`: static transforms from URDF

---

## Diagnostics

```python
from diagnostic_updater import Updater, FrequencyStatusParam

class DiagnosticNode(Node):
    def __init__(self):
        super().__init__('my_node')
        self._updater = Updater(self)
        self._updater.setHardwareID('lidar_0')
        self._updater.add('connection', self._check_connection)
        self._freq_stat = FrequencyStatusParam({'min': 9.0, 'max': 11.0})

    def _check_connection(self, stat):
        if self._connected:
            stat.summary(0, 'Connected')  # OK
        else:
            stat.summary(2, 'Disconnected')  # ERROR
        return stat
```

---

## Performance Profiling

```bash
# Topic frequency and bandwidth
ros2 topic hz /scan
ros2 topic bw /camera/image_raw

# Node diagnostics
ros2 doctor --report

# TF tree visualization
ros2 run tf2_tools view_frames

# System-wide latency
ros2 topic delay /scan  # requires header timestamps
```

---

## Package Template

```
my_ros2_pkg/
+-- my_ros2_pkg/
|   +-- __init__.py
|   +-- my_node.py
|   +-- utils.py
+-- test/
|   +-- test_my_node.py
|   +-- test_utils.py
+-- launch/
|   +-- my_node.launch.py
+-- config/
|   +-- params.yaml
+-- msg/                    # Only if custom messages needed
+-- srv/                    # Only if custom services needed
+-- package.xml
+-- setup.py
+-- setup.cfg
```

### package.xml Essentials

```xml
<package format="3">
  <name>my_ros2_pkg</name>
  <version>0.1.0</version>
  <description>Brief description</description>
  <maintainer email="you@example.com">Your Name</maintainer>
  <license>MIT</license>

  <depend>rclpy</depend>
  <depend>std_msgs</depend>

  <test_depend>launch_testing</test_depend>
  <test_depend>launch_testing_ament_cmake</test_depend>

  <export>
    <build_type>ament_python</build_type>
  </export>
</package>
```
