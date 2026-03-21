# Security Guidelines

## Mandatory Security Checks

Before ANY commit:
- [ ] No hardcoded secrets (API keys, passwords, tokens, WiFi credentials)
- [ ] All user/external inputs validated
- [ ] No command injection vulnerabilities (sanitize shell calls)
- [ ] No path traversal risks
- [ ] Authentication/authorization verified on network interfaces
- [ ] Error messages don't leak sensitive data (IP, paths, credentials)
- [ ] ROS2 topics with safety implications use appropriate QoS + access control

## Secret Management

- NEVER hardcode secrets in source code
- Use environment variables or ROS2 parameter files (not committed)
- Validate required secrets/configs are present at node startup
- Rotate any secrets that may have been exposed

```python
import os

# Use environment variables, never hardcode
api_key = os.environ["API_KEY"]  # Raises KeyError if missing
```

## Robotics-Specific Security

- Validate sensor data ranges before acting (reject NaN, inf, out-of-range)
- Rate-limit command inputs to actuators
- E-stop must work independently of software stack
- Network interfaces (websocket, REST) require authentication
- Log all safety-critical events with timestamps

## ROS2 Security

- Validate parameter values in `on_configure()` before use
- Range-check all incoming sensor messages
- Use ROS2 SROS2 for DDS security when deploying to network

## Security Scanning

```bash
# Python
bandit -r src/          # Static analysis
safety check            # Dependency vulnerabilities

# C++
cppcheck --enable=all src/
```

## Security Response Protocol

If security issue found:
1. STOP immediately
2. Use **security-reviewer** agent
3. Fix CRITICAL issues before continuing
4. Review codebase for similar issues
