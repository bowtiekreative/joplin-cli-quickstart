# Joplin CLI Quickstart — Headless Terminal Setup

> One-command setup for the **Joplin terminal app** (not the server). Syncs with a shared Joplin Server — all you need is the password.

## What It Is

Installs the **Joplin CLI** (terminal note-taking app) on any Linux VPS and connects it to a shared Joplin Server as a **client**. This does **NOT** install Joplin Server itself — it only connects to an existing instance.

**Key benefit:** Full Markdown note-taking in your terminal with automatic multi-user sync.

## Prerequisites

- Linux VPS (Ubuntu/Debian recommended)
- Node.js 18+ and npm *(script installs these if missing)*
- Shared server password from your team admin

## Quick Start

One-command install:
```bash
curl -sL https://raw.githubusercontent.com/bowtiekreative/joplin-cli-quickstart/main/setup.sh | bash
```

Or clone manually:
```bash
git clone https://github.com/bowtiekreative/joplin-cli-quickstart.git
cd joplin-cli-quickstart
bash setup.sh
```

**Setup prompts:**
1. **Your email** — used as your Joplin Server login/identifier
2. **Shared password** — provided by the team admin

## Server Details

| Setting | Value |
|--------|-------|
| **Server URL** | `https://joplin-server-s9yj.srv620544.hstgr.cloud` |
| **Email** | Your email |
| **Password** | From team admin |

## What Gets Installed

| Component | Purpose |
|-----------|---------|
| **Joplin CLI** | Terminal note-taking with Markdown, notebooks, tags, and search |
| **Auto-sync** | Syncs every 5 minutes with the shared server *(change to manual with `-m`)* |
| **Editor** | Default: `nano` (change via `joplin config editor vim`) |

## How to Use It

### Common Commands
```bash
joplin                              # Launch interactive UI
joplin mkbook "Project Notes"        # Create a notebook
joplin mknote "Meeting 2025-06-20"   # Create a note
joplin use "Project Notes"           # Switch notebook
joplin ls                            # List notes in current notebook
joplin cat "Meeting 2025-06-20"      # Read a note
joplin config editor vim             # Change default editor
joplin sync                          # Manual sync now
joplin search "keyword"              # Search all notes
```

### Interactive UI Layout
```
┌─────────────┬─────────────┬──────────────────┐
│  Notebooks  │   Notes     │   Note Content   │
│  (left)     │  (center)   │     (right)      │
│             │             │                  │
│  Project X  │  Meeting 1  │  ## Discussion   │
│  Personal   │  Todo list  │  We talked about │
│  Recipes    │  Ideas      │  the timeline... │
└─────────────┴─────────────┴──────────────────┘
```

**Navigation:**
- **Tab / Shift+Tab** — move between panes
- **Arrow keys** — navigate
- **:** — enter command mode (vim-style)
- **tc** — toggle console

## Advanced Operations

See **[BATCH-OPERATIONS.md](BATCH-OPERATIONS.md)** for bulk tagging, batch imports, notebook organization, and automation workflows — everything needed to scale from 10 notes to a structured knowledge library.

## What Syncs

- All notes, notebooks, and tags sync to the shared Joplin Server
- Notes created by anyone on the server appear in your terminal after sync
- Automatic sync runs every **5 minutes** by default

## Repository Files

| File | Purpose |
|------|---------|
| `setup.sh` | One-command installer |
| `SKILL.md` | Hermes AI agent skill for auto-setup |
| `README.md` | Documentation |
| `BATCH-OPERATIONS.md` | Bulk tagging, import, organization playbook |
| `scripts/tag-batch.sh` | Batch tag helper |

## Repo Metadata

- **Author:** [bowtiekreative](https://github.com/bowtiekreative)
- **Language:** Shell (100%)
