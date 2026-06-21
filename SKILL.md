---
name: joplin-cli-quickstart
description: >
  Install the Joplin terminal note-taking app (not the server) on any Linux VPS
  and sync with the shared Joplin Server at
  https://joplin-server-s9yj.srv620544.hstgr.cloud. Only the password is needed
  from the user; the email is prompted for during setup.
category: productivity
---

# Joplin CLI Quickstart

Install the Joplin terminal app (headless CLI, **not** Joplin Server) and sync
it with the shared server. This is for users who want terminal-based
note-taking that syncs across the team.

## Trigger conditions

- User says "install Joplin", "set up Joplin", "sync Joplin", "Joplin CLI"
- User needs terminal note-taking that syncs with the shared server

## Prerequisites

- Linux VPS (Ubuntu/Debian)
- `curl` installed
- The shared Joplin Server password (user provides this)

## Steps

### 1. Clone or curl the repo

```
git clone https://github.com/bowtiekreative/joplin-cli-quickstart.git
cd joplin-cli-quickstart
```

Or run directly:

```
curl -sL https://raw.githubusercontent.com/bowtiekreative/joplin-cli-quickstart/main/setup.sh | bash
```

### 2. Provide credentials when prompted

The script prompts for:
- **Email** — the user's email (used as identifier on the server)
- **Password** — the shared server password (provided by the team admin)

### 3. Verify sync

After setup completes, verify:

```bash
joplin ls
joplin sync
```

The first sync should pull the Welcome notes and any team notes.

## Server details

- **URL:** `https://joplin-server-s9yj.srv620544.hstgr.cloud`
- **Type:** Joplin Server (sync target 9)
- **Config key for URL:** `sync.9.path` (NOT `sync.9.url`)
- **Config key for username:** `sync.9.username`
- **Config key for password:** `sync.9.password`

## Important notes

- This installs the **Joplin CLI app only** — never install Joplin Server
- The terminal app connects to the existing server as a client
- Sync interval defaults to 5 minutes
- Editor defaults to `nano` — user can change with `joplin config editor vim`
- The `/api/sessions` URL is constructed automatically by the client from the
  `sync.9.path` setting — no manual URL path needed

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `Unknown key: sync.9.url` | Use `sync.9.path` instead |
| `Not a valid URL: /api/sessions` | `sync.9.path` is missing or wrong |
| Sync hangs | Check that the server URL is reachable: `curl -sI ${URL}` |
| `npm install -g joplin` fails | Set npm prefix: `npm config set prefix ~/.npm-global` |

## Files in repo

| File | Purpose |
|------|---------|
| `setup.sh` | One-command interactive installer |
| `README.md` | Full documentation |
| `SKILL.md` | This file — for Hermes agent auto-setup |