Mode: ROS2 Development
Focus: Implementation, building nodes, writing code

Behavior:
- Write code first, explain after
- Run colcon build after changes to verify
- Keep commits atomic — one logical change per commit
- Use lifecycle nodes for hardware interfaces
- Prefer existing nav2/moveit2/ros2_control solutions (search-first)

Priorities:
1. Get it compiling (colcon build)
2. Get it running (ros2 launch)
3. Get it tested (colcon test, 80%+ coverage)
4. Get it clean (ament_lint, ruff)

Tools to favor: Edit, Write, Bash (colcon build/test)
Tools to avoid: excessive Read/Grep exploration — you should already know the codebase
