---
name: search-first
description: Research-before-coding workflow for ROS2 robotics + AI development. Search for existing ROS2 packages, PyPI libraries, and community solutions before writing custom code.
---

# Search First — Research Before You Code

Systematizes the "search for existing solutions before implementing" workflow, adapted for ROS2 robotics + AI development.

## When to Activate

- Starting a new feature that likely has existing ROS2/robotics solutions
- Adding a new dependency or integration
- The user asks "add X functionality" and you're about to write code
- Before creating a new utility, helper, or abstraction
- During SDD spec.md phase — search BEFORE specifying

## Workflow

```
1. NEED ANALYSIS
   Define what functionality is needed
   Identify ROS2/framework constraints

2. SEARCH (parallel where possible)
   a. Local repo — grep/glob for existing implementations
   b. ROS2 ecosystem — ros2 pkg list, apt search ros-humble-*
   c. PyPI / pip — existing Python libraries
   d. GitHub — community ROS2 packages
   e. ROS Index — index.ros.org package database

3. EVALUATE
   Score candidates: functionality, maintenance, ROS2 compatibility,
   license, documentation, real-time safety

4. DECIDE
   Adopt as-is | Extend/wrap | Build custom

5. IMPLEMENT
   Install package | Write minimal custom code
```

## Decision Matrix

| Signal | Action |
|--------|--------|
| Exact match in ros-humble-* apt packages | **Adopt** — apt install, add to package.xml |
| Partial match in community ROS2 package | **Extend** — fork or wrap with thin adapter node |
| Good Python library on PyPI | **Adopt** — pip install, write ROS2 wrapper node |
| Multiple weak matches | **Compose** — combine 2-3 packages |
| Nothing suitable found | **Build** — write custom, informed by research |

## Search Shortcuts by Domain

### Navigation & SLAM
- `nav2_*` packages — check before writing any nav logic
- `slam_toolbox` — 2D SLAM
- `rtabmap_ros` — visual SLAM
- `robot_localization` — EKF/UKF sensor fusion

### Manipulation
- `moveit2` — motion planning (already in use for SO-101)
- `ros2_control` — hardware abstraction
- `ros2_controllers` — standard controller implementations

### Perception
- `image_pipeline` — camera calibration, rectification
- `vision_opencv` — OpenCV ROS2 bridge
- `pcl_ros` — point cloud processing
- `depth_image_proc` — RGBD processing

### Communication & Interfaces
- `rosbridge_suite` — WebSocket bridge
- `ros2_socketcan` — CAN bus
- `micro_ros` — microcontroller integration

### Simulation
- `gazebo_ros_pkgs` — Gazebo integration
- `ros2_numpy` — numpy <-> ROS2 message conversion

### AI / ML
- `torch`, `torchvision` — PyTorch (check PyPI first)
- `ultralytics` — YOLO object detection
- `segment-anything` — SAM segmentation
- `open3d` — 3D processing

## Search Commands

```bash
# 1. Local repo search
grep -r "function_name\|ClassName" src/ --include="*.py" --include="*.cpp"
find . -name "*.py" -exec grep -l "related_keyword" {} \;

# 2. Installed ROS2 packages
ros2 pkg list | grep -i keyword
ros2 pkg xml package_name  # check what's already available

# 3. Ubuntu/ROS2 apt packages
apt search ros-humble-keyword
apt show ros-humble-package-name

# 4. PyPI
pip search keyword  # or check pypi.org
pip show package-name  # already installed?

# 5. GitHub
gh search repos "ros2 humble keyword" --sort stars --limit 10
gh search code "keyword" --language python --filename "*.py"
```

## Integration with SDD

In the SDD spec.md phase, add a "Prior Art" section:

```markdown
## Prior Art Search
- ROS2 ecosystem: [results]
- PyPI: [results]
- Community packages: [results]
- Decision: Adopt X / Extend Y / Build custom because Z
```

## Anti-Patterns

- **Jumping to code**: Writing a ROS2 node without checking if nav2/moveit2/ros2_control already provides it
- **Ignoring apt packages**: Not checking `apt search ros-humble-*` before building from source
- **Over-wrapping**: Adding so many layers around an existing package that it loses its benefits
- **Reinventing nav2**: Writing custom path planning when nav2 plugins can be configured
- **Ignoring ros2_control**: Writing raw hardware drivers when ros2_control provides the abstraction

## ROS2-Specific Evaluation Criteria

| Criterion | Weight | Check |
|-----------|--------|-------|
| ROS2 Humble compatible | Critical | Does it build with colcon on Humble? |
| Active maintenance | High | Commits in last 6 months? |
| License | High | Apache-2.0 or BSD preferred for robotics |
| Real-time safe | Medium | Any blocking calls? Dynamic allocation? |
| QoS compatible | Medium | Does it use appropriate QoS settings? |
| Lifecycle node support | Low | Uses managed lifecycle? |
