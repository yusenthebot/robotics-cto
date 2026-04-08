#!/bin/bash
# Strategic Compact Suggester for ROS2 development
# Tracks Edit/Write tool call count per session, suggests /compact at logical intervals
# Non-blocking: only outputs to stderr, never blocks operations

COUNTER_FILE="/tmp/claude-compact-counter-${CLAUDE_SESSION_ID:-$$}"
THRESHOLD="${COMPACT_THRESHOLD:-50}"
INTERVAL=25

# Read and increment counter
if [ -f "$COUNTER_FILE" ]; then
    count=$(cat "$COUNTER_FILE" 2>/dev/null || echo 0)
    count=$((count + 1))
else
    count=1
fi
echo "$count" > "$COUNTER_FILE"

# First threshold hit
if [ "$count" -eq "$THRESHOLD" ]; then
    echo "[Compact] $THRESHOLD tool calls reached. Consider /compact if switching phases (debug->implement, research->code)." >&2
fi

# Periodic reminders after threshold
if [ "$count" -gt "$THRESHOLD" ] && [ $(( (count - THRESHOLD) % INTERVAL )) -eq 0 ]; then
    echo "[Compact] $count tool calls. Good checkpoint for /compact if context feels stale." >&2
fi

# Pass through stdin unchanged
cat
