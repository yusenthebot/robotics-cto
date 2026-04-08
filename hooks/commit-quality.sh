#!/bin/bash
# Pre-commit Quality Check for ROS2 + Python + C++ projects
# Checks staged files for common issues before allowing git commit
# Exit 2 = block commit, Exit 0 = allow

INPUT=$(cat)

# Only run for git commit commands
COMMAND=$(echo "$INPUT" | python3 -c '
import json, sys
try:
    data = json.load(sys.stdin)
    print(data.get("tool_input", {}).get("command", ""))
except:
    print("")
' 2>/dev/null)

if ! echo "$COMMAND" | grep -q "git commit"; then
    echo "$INPUT"
    exit 0
fi

# Skip for --amend
if echo "$COMMAND" | grep -q "\-\-amend"; then
    echo "$INPUT"
    exit 0
fi

# Get staged files
STAGED=$(git diff --cached --name-only --diff-filter=ACMR 2>/dev/null)
if [ -z "$STAGED" ]; then
    echo "$INPUT"
    exit 0
fi

ERRORS=0
WARNINGS=0

echo "[CommitQuality] Checking $(echo "$STAGED" | wc -l) staged file(s)..." >&2

# Check each staged file
while IFS= read -r file; do
    [ -z "$file" ] && continue
    CONTENT=$(git show ":$file" 2>/dev/null) || continue

    case "$file" in
        *.py)
            # Python: check for print() — should use self.get_logger()
            if echo "$CONTENT" | grep -n "^[^#]*\bprint(" | head -5 | grep -q .; then
                echo "  WARNING $file: print() found — use self.get_logger() in ROS2 nodes" >&2
                WARNINGS=$((WARNINGS + 1))
            fi
            # Python: check for debugger
            if echo "$CONTENT" | grep -nq "^\s*breakpoint()\|^\s*import pdb\|^\s*pdb.set_trace()"; then
                echo "  ERROR $file: debugger statement found" >&2
                ERRORS=$((ERRORS + 1))
            fi
            ;;
        *.cpp|*.hpp|*.h|*.cc)
            # C++: check for std::cout — should use RCLCPP_INFO/WARN/ERROR
            if echo "$CONTENT" | grep -n "std::cout\|std::cerr" | grep -v "^[[:space:]]*//" | head -5 | grep -q .; then
                echo "  WARNING $file: std::cout/cerr found — use RCLCPP_INFO/WARN/ERROR" >&2
                WARNINGS=$((WARNINGS + 1))
            fi
            ;;
        *.js|*.ts|*.tsx|*.jsx)
            # JS/TS: check for console.log
            if echo "$CONTENT" | grep -n "console\.log" | grep -v "^[[:space:]]*//" | head -5 | grep -q .; then
                echo "  WARNING $file: console.log found" >&2
                WARNINGS=$((WARNINGS + 1))
            fi
            # JS/TS: check for debugger
            if echo "$CONTENT" | grep -nq "^\s*debugger"; then
                echo "  ERROR $file: debugger statement found" >&2
                ERRORS=$((ERRORS + 1))
            fi
            ;;
    esac

    # Universal: check for hardcoded secrets
    if echo "$CONTENT" | grep -qiE "(sk-[a-zA-Z0-9]{20,}|ghp_[a-zA-Z0-9]{36}|AKIA[A-Z0-9]{16}|api[_-]?key\s*[=:]\s*['\"][^'\"]{8,}['\"])"; then
        echo "  ERROR $file: potential hardcoded secret detected!" >&2
        ERRORS=$((ERRORS + 1))
    fi

    # ROS2: check for hardcoded IPs (common in robotics)
    if echo "$CONTENT" | grep -qE "(['\"]192\.168\.[0-9]+\.[0-9]+['\"]|['\"]10\.[0-9]+\.[0-9]+\.[0-9]+['\"])"; then
        echo "  WARNING $file: hardcoded IP address — use ROS2 parameters instead" >&2
        WARNINGS=$((WARNINGS + 1))
    fi

done <<< "$STAGED"

# Summary
if [ $ERRORS -gt 0 ]; then
    echo "" >&2
    echo "[CommitQuality] BLOCKED: $ERRORS error(s), $WARNINGS warning(s). Fix errors before committing." >&2
    exit 2
elif [ $WARNINGS -gt 0 ]; then
    echo "" >&2
    echo "[CommitQuality] PASSED with $WARNINGS warning(s). Consider fixing them." >&2
fi

echo "$INPUT"
exit 0
