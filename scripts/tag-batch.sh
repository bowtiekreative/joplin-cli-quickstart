#!/usr/bin/env bash
#
# Batch tag notes in a Joplin folder based on title patterns
# Usage: ./tag-batch.sh --folder "Skills" --tag "ai-agents" --pattern "claude\|codex"
#        ./tag-batch.sh --all --tag "reviewed" --exclude "Index"
set -euo pipefail

FOLDER=""
TAG=""
PATTERN=""
ALL=false
EXCLUDE=""

# Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --folder) FOLDER="$2"; shift 2 ;;
        --tag)    TAG="$2";    shift 2 ;;
        --pattern) PATTERN="$2"; shift 2 ;;
        --all)    ALL=true;    shift ;;
        --exclude) EXCLUDE="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

if [ -z "$TAG" ]; then
    echo "Usage: $0 [--folder NAME] --tag TAG [--pattern REGEX] [--all] [--exclude REGEX]"
    exit 1
fi

# Determine scope
if $ALL; then
    echo "Tagging ALL notes with '$TAG'"
    COMMAND="joplin ls --fields title"
else
    if [ -n "$FOLDER" ]; then
        joplin use "$FOLDER" 2>/dev/null || true
        echo "Tagging notes in '$FOLDER' with '$TAG'"
    fi
    COMMAND="joplin ls --fields title"
fi

# Apply tags
count=0
$COMMAND | while IFS= read -r note; do
    [ -z "$note" ] && continue

    if [ -n "$EXCLUDE" ] && echo "$note" | grep -qiE "$EXCLUDE"; then
        echo "  SKIP (excluded): $note"
        continue
    fi

    if [ -n "$PATTERN" ] && ! echo "$note" | grep -qiE "$PATTERN"; then
        continue
    fi

    joplin tag add "$TAG" "$note" 2>/dev/null && echo "  TAGGED: $note" || echo "  ALREADY: $note"
    ((count++)) || true
done

echo "Done. Tagged $count notes."
