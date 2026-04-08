#!/bin/bash
# PreCompact Hook — save state marker before context compaction
# Logs compaction events so you can track when context was lost

SESSIONS_DIR="$HOME/.claude/sessions"
mkdir -p "$SESSIONS_DIR"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
LOG_FILE="$SESSIONS_DIR/compaction-log.txt"

echo "[$TIMESTAMP] Context compaction triggered in $(pwd)" >> "$LOG_FILE"

# If there's a project progress.md, note the compaction
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -n "$PROJECT_ROOT" ] && [ -f "$PROJECT_ROOT/progress.md" ]; then
    echo "[$TIMESTAMP] Note: progress.md exists at $PROJECT_ROOT/progress.md — state should survive compaction" >> "$LOG_FILE"
fi

echo "[PreCompact] State checkpoint saved." >&2

# Pass through stdin
cat
