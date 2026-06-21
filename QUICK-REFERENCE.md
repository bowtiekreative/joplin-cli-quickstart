# Quick Reference — Joplin Terminal

> 30 most common Joplin CLI operations. Copy-paste ready.

## Navigation

```bash
joplin                    # Launch interactive UI  
joplin use "Notes"        # Switch to notebook
joplin ls                 # List notes in current notebook
joplin ls --fields title  # Pipe-friendly list
joplin cat "Note"         # Read note body
```

## Notes

```bash
joplin mknote "Title"                       # Create
joplin edit "Title"                         # Open in default editor
joplin set "Title" body < file.md         # Set body from file (preserves newlines)
joplin rmnote "Title"                       # Delete
joplin mv "Title" "Folder"                  # Move to folder
joplin search "keyword"                     # Full-text search
```

## Notebooks

```bash
joplin mkbook "Work"        # Create folder
joplin mkdir "Sub"          # Create subfolder (root-level in DB)
joplin rmbook "Work"        # Delete (must be empty)
joplin ls -f                # List all folders
```

## Tags

```bash
joplin tag list                     # All tags
joplin tag add "tag" "Note"         # Add tag to note
joplin tag remove "tag" "Note"      # Remove tag from note
joplin tag notetags "Note"          # Tags on note
joplin tag notes "tag"              # Notes with tag
```

## Sync

```bash
joplin sync                          # Sync now
joplin config sync.interval 0        # Manual only
joplin config sync.interval 300     # Every 5 min
joplin config sync.wipeOutFailSafe 0 # Disable for multi-client
joplin config                       # Show all config
```

## Bulk Operations

```bash
# Tag all notes in folder
for n in $(joplin ls --fields title); do
    joplin tag add "reviewed" "$n"
done

# Find + delete duplicates
grep -E " [a-f0-9]{5}$|\([0-9]+\)$" | while read dup; do
    joplin rmnote "$dup"
done

# Import from markdown files
for f in *.md; do
    t=$(basename "$f" .md)
    joplin mknote "$t"
    joplin set "$t" body < "$f"
done
```

## Multi-Client Safety

| Setting | Recommended | Why |
|---------|------------|-----|
| `sync.interval` | `0` (manual) | Prevents half-written notes from uploading |
| `sync.wipeOutFailSafe` | `0` | Allow another client to overwrite without blocking |
| Config key for URL | `sync.9.path` | Not `.url` — Joplin Server uses `.path` |

## Backlinks

In any note body:
```markdown
# My Note

See also [[Related Note]] and [[Another Note]]
```

Joplin Desktop renders `[[Title]]` as clickable links.

## File Size Limits

| Item | Limit |
|------|-------|
| Note body | effectively unlimited (tested with 100KB+) |
| Attachments | 10 MB default (configurable) |
| Total account | depends on server storage |

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `sync.9.url` not working | Change to `sync.9.path` |
| Body loses newlines | Use file redirect: `set body < file.md` |
| Tags not working | Check for commas — tag one at a time |
| Folder not nested | Nested only in Desktop UI; CLI is flat |
| Duplicates after sync | Search for hex suffixes, delete carefully |
