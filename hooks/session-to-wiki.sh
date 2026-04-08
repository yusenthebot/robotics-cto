#!/bin/bash
# Stop Hook: Write session summary as wiki raw entry
# Replaces obsidian-sync — captures session data for wiki absorption

# Only run for interactive CLI sessions
[ "${CLAUDE_CODE_ENTRYPOINT:-cli}" = "cli" ] || exit 0

WIKI_DIR="$HOME/Desktop/wiki"
ENTRIES_DIR="$WIKI_DIR/raw/entries"
DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M:%S)
SESSION_ID="${CLAUDE_SESSION_ID:-$(date +%s)}"

# Ensure directory exists
mkdir -p "$ENTRIES_DIR"

# Detect project context
PROJECT_DIR=$(pwd)
PROJECT_NAME=$(basename "$PROJECT_DIR")
GIT_BRANCH=$(git -C "$PROJECT_DIR" branch --show-current 2>/dev/null || echo "none")
GIT_ROOT=$(git -C "$PROJECT_DIR" rev-parse --show-toplevel 2>/dev/null || echo "")

if [ -n "$GIT_ROOT" ]; then
    PROJECT_NAME=$(basename "$GIT_ROOT")
fi

# Get recent git activity (what changed this session)
RECENT_COMMITS=""
if [ -n "$GIT_ROOT" ]; then
    RECENT_COMMITS=$(git -C "$GIT_ROOT" log --oneline --since="4 hours ago" --no-merges 2>/dev/null | head -10)
fi

CHANGED_FILES=""
if [ -n "$GIT_ROOT" ]; then
    CHANGED_FILES=$(git -C "$GIT_ROOT" diff --name-only HEAD~3 HEAD 2>/dev/null | head -20)
fi

# Generate entry filename
ENTRY_FILE="$ENTRIES_DIR/${DATE}_session_${SESSION_ID}.md"

# Don't overwrite existing entry
if [ -f "$ENTRY_FILE" ]; then
    ENTRY_FILE="$ENTRIES_DIR/${DATE}_session_${SESSION_ID}_$(date +%s).md"
fi

# Write entry
cat > "$ENTRY_FILE" << EOF
---
id: session-${DATE}-${SESSION_ID}
date: ${DATE}
time: "${TIME}"
source_type: session
project: ${PROJECT_NAME}
branch: ${GIT_BRANCH}
workdir: ${PROJECT_DIR}
tags: [session]
---

## Session: ${PROJECT_NAME} (${DATE})

Working directory: ${PROJECT_DIR}
Branch: ${GIT_BRANCH}
EOF

# Add recent commits if any
if [ -n "$RECENT_COMMITS" ]; then
    cat >> "$ENTRY_FILE" << EOF

### Recent Commits

\`\`\`
${RECENT_COMMITS}
\`\`\`
EOF
fi

# Add changed files if any
if [ -n "$CHANGED_FILES" ]; then
    cat >> "$ENTRY_FILE" << EOF

### Files Changed

\`\`\`
${CHANGED_FILES}
\`\`\`
EOF
fi

# Check if progress.md exists and capture a snapshot
if [ -n "$GIT_ROOT" ] && [ -f "$GIT_ROOT/progress.md" ]; then
    PROGRESS=$(head -50 "$GIT_ROOT/progress.md")
    cat >> "$ENTRY_FILE" << EOF

### Progress Snapshot

${PROGRESS}
EOF
fi

echo "[Wiki] Session entry saved: $(basename "$ENTRY_FILE")" >&2

exit 0
