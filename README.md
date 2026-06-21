# Joplin CLI Quickstart — Headless Terminal Setup

> One-command setup for the **Joplin terminal app** (not the server).  
> Syncs with a shared Joplin Server — all you need is the password.

## What this is

This installs the **Joplin CLI** (terminal note-taking app) on any Linux VPS and connects it to a shared Joplin Server. You get a full Markdown note-taking app in your terminal that syncs automatically with everyone else on the same server.

**This does NOT install Joplin Server.** The server is already running — we're just connecting to it as a client.

## Prerequisites

- A Linux VPS (Ubuntu/Debian recommended)
- Node.js 18+ and npm (the script installs these if missing)
- The shared server password from the team

## Quick Start

```bash
curl -sL https://raw.githubusercontent.com/bowtiekreative/joplin-cli-quickstart/main/setup.sh | bash
```

Or clone and run:

```bash
git clone https://github.com/bowtiekreative/joplin-cli-quickstart.git
cd joplin-cli-quickstart
bash setup.sh
```

You'll be prompted for:
1. **Your email** — used as your Joplin Server login
2. **The shared password** — provided by the team admin

## What gets installed

| Component | Purpose |
|-----------|---------|
| **Joplin CLI** | Terminal note-taking app with Markdown, notebooks, tags, search |
| **Auto-sync** | Syncs every 5 minutes with the shared server |
| **Editor** | Set to `nano` (change with `joplin config editor vim`) |

## How to use it

```bash
# Launch the interactive UI
joplin

# Or use commands directly
joplin mkbook "Project Notes"        # create a notebook
joplin mknote "Meeting 2025-06-20"   # create a note
joplin use "Project Notes"           # switch notebook
joplin ls                            # list notes in current notebook
joplin cat "Meeting 2025-06-20"      # read a note
joplin config editor vim             # change your editor
joplin sync                          # manually sync now
joplin search "keyword"              # search all notes
```

The interactive UI has three panes:
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

- **Tab** / **Shift+Tab** — move between panes
- **Arrow keys** — navigate
- **:** — enter command mode (like vim)
- **tc** — toggle console

## What syncs

- All your notes, notebooks, and tags sync to the shared Joplin Server
- Notes created by anyone on the server appear in your terminal after sync
- Sync runs automatically every 5 minutes

## Server Details

- **Server URL:** `https://joplin-server-s9yj.srv620544.hstgr.cloud`
- **Email:** Your email (used as identifier)
- **Password:** Get this from the team admin

## Files in this repo

| File | Purpose |
|------|---------|
| `setup.sh` | One-command installer |
| `SKILL.md` | Hermes AI agent skill for auto-setup |
| `README.md` | This file |