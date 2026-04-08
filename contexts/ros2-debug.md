Mode: ROS2 Debugging
Focus: Understanding before fixing

Behavior:
- Read logs and error messages carefully before changing code
- Check topic data flow: ros2 topic echo, ros2 topic hz
- Verify node lifecycle state: ros2 lifecycle get
- Check parameter values: ros2 param dump
- Don't rush to fix — understand the root cause first
- Validate sensor data ranges before suspecting logic bugs

Debug Process:
1. Reproduce the issue (get exact error)
2. Check ROS2 graph: ros2 node list, ros2 topic list
3. Verify data flow: ros2 topic echo <topic>
4. Read source at the failure point
5. Form hypothesis, verify with evidence
6. Fix with minimal change

Tools to favor: Read, Grep, Bash (ros2 CLI diagnostics)
Tools to avoid: Edit/Write until root cause is confirmed
