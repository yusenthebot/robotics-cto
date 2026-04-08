#!/bin/bash
# Doc File Warning Hook — enforce docs-hygiene rules
# Warns when agent tries to create ad-hoc documentation files
# Exit 0 always (warn only, never block)

INPUT=$(cat)

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
BASENAME_UPPER=$(echo "$BASENAME" | tr '[:lower:]' '[:upper:]')

# Forbidden filenames from docs-hygiene.md
case "$BASENAME_UPPER" in
    DOCUMENTATION_INDEX.MD|START_HERE.MD|README_START_HERE.MD|\
    CHANGELOG_*.MD|FILE_MANIFEST.MD|DOCUMENTATION_COMPLETE.MD|\
    DOCUMENTATION_UPDATE_*.MD)
        echo "[DocHygiene] WARNING: '$BASENAME' is explicitly forbidden by docs-hygiene rules." >&2
        echo "[DocHygiene] Use status.md (overwrite), QUICKSTART.md, or CODEBASE_GUIDE.md instead." >&2
        echo "$INPUT"
        exit 0
        ;;
esac

# Ad-hoc scratch/temp files
case "$BASENAME_UPPER" in
    NOTES.MD|NOTES.TXT|SCRATCH.MD|SCRATCH.TXT|\
    TEMP.MD|TEMP.TXT|DRAFT.MD|DRAFT.TXT|\
    BRAINSTORM.MD|WIP.MD|DEBUG.MD|SPIKE.MD|\
    TODO.MD|TODO.TXT)
        echo "[DocHygiene] WARNING: Ad-hoc file '$BASENAME' detected." >&2
        echo "[DocHygiene] Use a structured path (docs/, .claude/, skills/) or an existing doc." >&2
        echo "$INPUT"
        exit 0
        ;;
esac

# SESSION_*.md pattern — should use status.md overwrite instead
case "$BASENAME_UPPER" in
    SESSION_*.MD|SESSION-*.MD)
        echo "[DocHygiene] WARNING: Session file '$BASENAME' detected." >&2
        echo "[DocHygiene] Use agents/devlog/status.md (overwrite each session) instead." >&2
        echo "$INPUT"
        exit 0
        ;;
esac

echo "$INPUT"
exit 0
