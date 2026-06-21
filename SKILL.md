---
skill_name: joplin-cli
version: 2.0.0
description: Install, configure, and operate the Joplin terminal CLI for headless note-taking synced to a Joplin Server. Covers setup, sync, tagging, batch imports, notebook organization, backlink indices, and conflict resolution.
---

# Joplin CLI — Hermes Skill

## When to Use

- User needs terminal note-taking synced across devices
- User wants to automate note creation, tagging, or organization
- User needs to structure a large number of notes into folders with tags and backlinks
- User needs to clean up or reorganize an existing Joplin library

## Architecture

| Layer | What It Does |
|-------|-------------|
| **Joplin CLI** | Terminal app — CRUD notes, notebooks, tags, search |
| **Joplin Desktop** | GUI for drag-and-drop notebook nesting and rich editing |
| **Joplin Server** | Sync backend — `https://joplin-server-s9yj.srv620544.hstgr.cloud` |
| **Data API** | Desktop/CLI exposes port 41184 for programmatic CRUD |

**Important:** Joplin Server itself does NOT expose note CRUD. All programmatic access goes through the Data API on a running Desktop or CLI instance.

## Phase 1: Install & Connect

### 1. Install Joplin CLI
```bash
npm install -g joplin
# Add to PATH if needed
export PATH="$HOME/.npm-global/bin:$PATH"
```

### 2. Configure Sync Target

**For Joplin Server (current setup):**
```bash
joplin config sync.target 9
joplin config sync.9.path "https://joplin-server-s9yj.srv620544.hstgr.cloud"
joplin config sync.9.username "user@example.com"
joplin config sync.9.password "shared-password"
joplin config sync.interval 0     # 0=manual, or 300 for 5min
```

**Critical settings:**
- `sync.target 9` = Joplin Server
- Key is `sync.9.path`, NOT `sync.9.url`
- `sync.interval 0` for manual-only (prevents half-written notes from uploading)

### 3. Disable Wipe Failsafe (for multi-client)
```bash
joplin config sync.wipeOutFailSafe 0
```

### 4. First Sync
```bash
joplin sync
```

## Phase 2: Notebook Organization

### Creating Structure
```bash
# Create top-level folder
joplin mkbook "Skills"

# Create sub-folder (appears as root sibling on CLI; nest via Desktop later)
joplin mkdir "ai-agents"

# List all folders
joplin ls -f
```

**Important:** The CLI `mkdir` creates folders at the root level in the database. True parent-child nesting is a UI-level relationship established in Joplin Desktop by dragging sub-folders into a parent. On the CLI, folders appear as a flat list.

### Notebook Nesting Strategy
1. Create all folders via CLI: `joplin mkbook "Parent"`, `joplin mkdir "Child"`
2. Sync to server
3. Open Joplin Desktop, sync
4. Drag child folders into the parent for visual nesting
5. Desktop syncs the parent-child relationships back to the server

## Phase 3: Batch Content Import

**PREFERRED: Temp Markdown Files**

For multiline content, NEVER try to pass newlines via CLI arguments — write a temp file instead:

```bash
NOTE_TITLE="My Note"
TMPFILE=$(mktemp)
cat > "$TMPFILE" << 'EOF'
## Header

Code example:
```python
print("hello")
```

Tags: #python #code
EOF

joplin mknote "$NOTE_TITLE"
joplin set "$NOTE_TITLE" body < "$TMPFILE"
rm "$TMPFILE"
```

**Why:** Direct `joplin set body "line1\nline2"` fails on most shells. File redirection (`<`) preserves all formatting.

## Phase 4: Tagging

### Viewing Tags
```bash
joplin tag list                    # All tags
joplin tag notetags "Note Name"    # Tags on a specific note
joplin tag notes "ai-agents"       # All notes with a tag
```

### Adding Tags
```bash
# Correct: space-separated, NO commas
joplin tag add "tag1" "Note Title"
joplin tag add "tag2" "Note Title"

# Batch tagging (in current folder)
for note in $(joplin ls | grep -v "^[[:space:]]*$"); do
    joplin tag add "ai-agents" "$note"
done
```

**PITFALL — NEVER do this:**
```bash
# WRONG: creates a single malformed tag "tag1,tag2,tag3"
joplin tag add "tag1,tag2,tag3" "Note Title"
```

### Removing Bad Tags
```bash
# Remove one tag from one note
joplin tag remove "bad-tag" "Note Title"

# Strip all tags from a note (list them, then remove in loop)
joplin tag notetags "Note Title" | while read tag; do
    joplin tag remove "$tag" "Note Title" 2>/dev/null
done
```

### Tag Naming Convention
| Style | Example | Use |
|-------|--------|-----|
| kebab-case | `ai-agents`, `red-teaming` | CLI-friendly |
| broad category first | `python`, `code`, `mlops` | Easy to search |
| specific after | `phi4-mini`, `jupyter-notebook` | Narrow filtering |

## Phase 5: Index & Backlink Notes

Create a folder index note for navigation:

```bash
FOLDER="AI-Agents"
joplin use "$Folder"

TMPFILE=$(mktemp)
{
  echo "# AI-Agents Index"
  echo ""
  echo "## Notes in this folder"
  joplin ls | while read note; do
    echo "- [[$note]]"
  done
} > "$TMPFILE"

joplin mknote "📁 AI-Agents Index"
joplin set "📁 AI-Agents Index" body < "$TMPFILE"
rm "$TMPFILE"
```

**Backlinks:** Use `[[Note Name]]` syntax in the note body. Joplin Desktop renders these as clickable links to other notes.

## Phase 6: Conflict Resolution & Cleanup

### Duplicate Notes After Sync Conflicts
When multiple clients create notes with the same title Joplin may create duplicates with suffixes like `Note Title (2)`, `Note Title 5630c`.

Clean them:
```bash
joplin search "Query" | grep -E "\([0-9]+\)|[a-f0-9]{5}$" | while read dup; do
    # Verify before deleting
    echo "Will delete: $dup"
    # joplin rmnote "$dup"
done
```

Always run with `echo` first (dry run), then change to `joplin rmnote` after review.

### Server-Side Cleanup
If the server has stale items from a bad import:
1. `joplin sync` to pull current state
2. Delete unwanted notes locally: `joplin rmnote "Note"`
3. Delete empty/unwanted folders: `joplin rmbook "Folder"`
4. `joplin sync` to push deletions to server

## Phase 7: Automation Scripts

### Batch Tag from JSON
Use the provided `scripts/tag-batch.sh`:
```bash
./scripts/tag-batch.sh --folder "Skills" --tag "ai-agents" --pattern "claude\|codex"
```

Or do it inline:
```bash
joplin use "Skills"
joplin ls | grep -i "claude\|codex\|openai" | while read note; do
    joplin tag add "ai-agents" "$note" 2>/dev/null
done
```

## Server Reference

| Setting | Value |
|--------|-------|
| **URL** | `https://joplin-server-s9yj.srv620544.hstgr.cloud` |
| **Sync Target** | `9` (Joplin Server) |
| **Config Key** | `sync.9.path` |
| **Wipe Failsafe** | Set to `0` to prevent accidental wipes across clients |

## Common Pitfalls

| Pitfall | Fix |
|---------|-----|
| Newlines in note body break CLI | Use temp file + redirect (`<`) |
| Comma-separated tags create one malformed tag | Tag individually, or loop |
| `sync.9.url` doesn't work | Use `sync.9.path` |
| Auto-sync uploads half-written notes | `sync.interval 0` for manual |
| Subfolders don't nest in CLI | Nest via Desktop drag-and-drop |
| Sync conflicts create duplicate notes | Search + `grep` for patterns, delete carefully |
