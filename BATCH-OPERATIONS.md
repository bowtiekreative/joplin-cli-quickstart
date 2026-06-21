# Batch Operations Playbook

> Advanced workflows for importing, tagging, organizing, and maintaining large Joplin libraries from the terminal.

## Table of Contents

1. [Batch Content Import](#batch-content-import)
2. [Bulk Tagging](#bulk-tagging)
3. [Creating Index Notes](#creating-index-notes)
4. [Conflict Cleanup](#conflict-cleanup)
5. [JSON-Driven Import](#json-driven-import)
6. [Notebook Reorganization](#notebook-reorganization)

---

## Batch Content Import

**Problem:** `joplin set body` fails when you pass multiline strings with `\n`.

**Solution:** Write temp Markdown files, then redirect into Joplin.

```bash
# Single note with full markdown
TITLE="My Structured Note"
TMP=$(mktemp)
cat > "$TMP" <<'EOF'
## Overview

This note contains:
- Bullet lists
- **Bold text**
- Code blocks

```bash
echo "hello"
```

Tags: #project-alpha #reference
EOF

joplin mknote "$TITLE"
joplin set "$TITLE" body < "$TMP"
rm "$TMP"
```

### Bulk Import from Directory

If you have a folder `notes/` with `.md` files:

```bash
NOTEBOOK="Imported Notes"
joplin mkbook "$NOTEBOOK" 2>/dev/null || true
joplin use "$NOTEBOOK"

for f in notes/*.md; do
    title=$(basename "$f" .md)
    joplin mknote "$title"
    joplin set "$title" body < "$f"
done
```

**Tip:** Add `--time 60` to long Joplin operations to avoid timeouts.

---

## Bulk Tagging

### Tag All Notes in a Folder

```bash
FOLDER="Research"
TAG="research"

# Enter folder
joplin use "$FOLDER"

# Add tag to every note
joplin ls --fields title | while IFS= read -r note; do
    [ -n "$note" ] && joplin tag add "$TAG" "$note" 2>/dev/null
done
```

### Conditional Tagging (Regex)

```bash
# Tag notes mentioning "python" or "github"
joplin ls --fields title | while IFS= read -r note; do
    body=$(joplin cat "$note" 2>/dev/null || echo "")
    if echo "$body" | grep -qi "python"; then
        joplin tag add "python" "$note" 2>/dev/null
    fi
    if echo "$body" | grep -qi "github"; then
        joplin tag add "github" "$note" 2>/dev/null
    fi
done
```

### Retagging Everything

```bash
# Strip all tags from a folder, then re-tag
joplin use "Target Folder"
for note in $(joplin ls --fields title); do
    # Remove existing tags
    joplin tag notetags "$note" | while IFS= read -r tag; do
        [ -n "$tag" ] && joplin tag remove "$tag" "$note" 2>/dev/null
    done
    # Add new unified tag
    joplin tag add "reviewed" "$note"
done
```

---

## Creating Index Notes

Generate a backlink index for any notebook:

```bash
INDEX_TITLE="📁 $(joplin curnotebook) Index"
TMP=$(mktemp)

{
  echo "# $(joplin curnotebook) — Table of Contents"
  echo ""
  echo "## Notes"
  joplin ls --fields title | while IFS= read -r note; do
    echo "- [[$note]]"
  done
  echo ""
  echo "## Tags Used"
  joplin tag list | head -20 | while IFS= read -r tag; do
    count=$(joplin tag notes "$tag" 2>/dev/null | wc -l)
    echo "- $tag ($count notes)"
  done
} > "$TMP"

joplin mknote "$INDEX_TITLE"
joplin set "$INDEX_TITLE" body < "$TMP"
rm "$TMP"
```

---

## Conflict Cleanup

### Find Duplicate Notes

```bash
# Notes with hex suffixes like "Note 5630c" or "Note (2)"
joplin ls --fields title | grep -E " [a-f0-9]{5}$|\([0-9]+\)$"
```

### Remove Duplicates (with dry-run)

```bash
echo "=== DRY RUN ==="
joplin ls --fields title | grep -E " [a-f0-9]{5}$|\([0-9]+\)$" | while IFS= read -r dup; do
    echo "Would delete: $dup"
    # Uncomment next line after review:
    # joplin rmnote "$dup"
done
```

### Clean All Empty Notes (zero body)

```bash
joplin ls --fields title | while IFS= read -r note; do
    size=$(joplin cat "$note" 2>/dev/null | wc -c)
    if [ "$size" -lt 2 ]; then
        echo "Empty: $note"
        # joplin rmnote "$note"
    fi
done
```

---

## JSON-Driven Import

For complex imports, use a JSON manifest:

```bash
# manifest.json
# [
#   {"title":"Note 1","body":"# Hello\n\nContent","tags":["tag-a","tag-b"],"folder":"Research"},
#   {"title":"Note 2","body":"## Section\n\nMore...","tags":["tag-a"],"folder":"Research"}
# ]

# Import script
jq -c '.[]' manifest.json | while IFS= read -r row; do
    title=$(echo "$row" | jq -r '.title')
    body=$(echo "$row" | jq -r '.body')
    folder=$(echo "$row" | jq -r '.folder')
    tags=$(echo "$row" | jq -r '.tags[]')

    joplin mkdir "$folder" 2>/dev/null || true
    joplin use "$folder" 2>/dev/null || true

    # Write body via temp file to preserve newlines
    TMP=$(mktemp)
    echo "$body" > "$TMP"
    joplin mknote "$title" 2>/dev/null || true
    joplin set "$title" body < "$TMP" 2>/dev/null || true
    rm "$TMP"

    # Apply tags
    for tag in $tags; do
        joplin tag add "$tag" "$title" 2>/dev/null || true
    done
done
```

---

## Notebook Reorganization

### Move Notes Between Folders

```bash
# Move all notes from "Old" to "New"
joplin use "Old"
joplin ls --fields title | while IFS= read -r note; do
    joplin mv "$note" "New" 2>/dev/null || echo "Skip: $note"
done
```

### Rename Folder

```bash
# Joplin CLI doesn't have rename; create new, move, delete old
joplin mkbook "New Name"
joplin use "Old Name"
joplin ls --fields title | while IFS= read -r note; do
    joplin mv "$note" "New Name"
done
joplin rmbook "Old Name"
```

### Sync After Bulk Changes

```bash
joplin sync
```

Always sync after bulk operations so the server gets the final state.

---

## Quick Reference

| Command | What It Does |
|---------|-------------|
| `joplin ls --fields title` | List note titles (pipe-friendly) |
| `joplin cat "Note"` | Output note body |
| `joplin tag list` | All tags |
| `joplin tag add "tag" "Note"` | Add single tag |
| `joplin tag remove "tag" "Note"` | Remove single tag |
| `joplin tag notetags "Note"` | Tags on a note |
| `joplin tag notes "tag"` | Notes with tag |
| `joplin mv "Note" "Folder"` | Move note |
| `joplin rmnote "Note"` | Delete note |
| `joplin rmbook "Folder"` | Delete folder (must be empty) |

