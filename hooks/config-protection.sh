#!/bin/bash
# Config Protection Hook for ROS2 + Python + C++ projects
# Blocks agent from modifying build/linter config files to bypass errors
# Exit 2 = block, Exit 0 = allow

INPUT=$(cat)

# Extract file_path from hook JSON
FILE_PATH=$(echo "$INPUT" | python3 -c '
import json, sys
try:
    data = json.load(sys.stdin)
    print(data.get("tool_input", {}).get("file_path", data.get("tool_input", {}).get("file", "")))
except:
    print("")
' 2>/dev/null)

if [ -z "$FILE_PATH" ]; then
    echo "$INPUT"
    exit 0
fi

BASENAME=$(basename "$FILE_PATH")

# Protected config files — agent should fix code, not weaken configs
case "$BASENAME" in
    # ROS2 / C++ build system
    CMakeLists.txt|package.xml|setup.cfg)
        echo "BLOCKED: Modifying $BASENAME is not allowed. Fix the source code instead of changing build configuration." >&2
        echo "If this is a legitimate config change (adding a new dependency, new node), ask Yusen first." >&2
        exit 2
        ;;
    # Python linting
    .ruff.toml|ruff.toml|.flake8|.pylintrc|pyproject.toml)
        # pyproject.toml is borderline — block only if it's in a ROS2 package (has setup.cfg sibling)
        if [ "$BASENAME" = "pyproject.toml" ]; then
            DIR=$(dirname "$FILE_PATH")
            if [ ! -f "$DIR/setup.cfg" ] && [ ! -f "$DIR/package.xml" ]; then
                echo "$INPUT"
                exit 0
            fi
        fi
        echo "BLOCKED: Modifying $BASENAME is not allowed. Fix the code to satisfy linter rules." >&2
        exit 2
        ;;
    # C++ linting / formatting
    .clang-tidy|.clang-format|.ament_lint|.ament_uncrustify.cfg)
        echo "BLOCKED: Modifying $BASENAME is not allowed. Fix the C++ code to comply with the style rules." >&2
        exit 2
        ;;
    # General configs
    .eslintrc*|.prettierrc*|biome.json|.markdownlint*)
        echo "BLOCKED: Modifying $BASENAME is not allowed. Fix the source code instead." >&2
        exit 2
        ;;
esac

echo "$INPUT"
exit 0
