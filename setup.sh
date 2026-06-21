#!/usr/bin/env bash
#
# Joplin CLI Quickstart — Headless Terminal Setup
# Installs the Joplin terminal app and syncs it with a shared Joplin Server.
# This does NOT install Joplin Server — only the client.
#
# Server: https://joplin-server-s9yj.srv620544.hstgr.cloud
# Usage:  bash setup.sh
#
set -euo pipefail

JOPLIN_SERVER_URL="https://joplin-server-s9yj.srv620544.hstgr.cloud"
NPM_PREFIX="${HOME}/.npm-global"

# ---- Colors ----
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}============================================${NC}"
echo -e "${CYAN}  Joplin CLI Quickstart — Headless Setup${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""
echo -e "Server: ${GREEN}${JOPLIN_SERVER_URL}${NC}"
echo "This installs the Joplin TERMINAL APP only (not the server)."
echo ""

# ---- Step 1: Install Node.js if missing ----
echo -e "${GREEN}[1/4]${NC} Checking Node.js..."
if ! command -v node &>/dev/null; then
    echo "  Node.js not found. Installing via NodeSource..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -
    sudo apt install -y nodejs
    echo "  Node.js $(node --version) installed."
else
    echo "  Node.js $(node --version) — OK"
fi

if ! command -v npm &>/dev/null; then
    echo "  npm not found. Installing..."
    sudo apt install -y npm
fi
echo "  npm $(npm --version) — OK"

# ---- Step 2: Install Joplin CLI ----
echo -e "${GREEN}[2/4]${NC} Installing Joplin CLI..."
mkdir -p "${NPM_PREFIX}"
npm config set prefix "${NPM_PREFIX}" 2>/dev/null || true
export PATH="${NPM_PREFIX}/bin:$PATH"

if command -v joplin &>/dev/null; then
    echo "  Joplin CLI already installed — checking for update..."
    npm update -g joplin 2>&1 | tail -1
else
    npm install -g joplin
fi

echo "  $(joplin help 2>&1 | head -1)"
echo ""

# ---- Step 3: Configure sync ----
echo -e "${GREEN}[3/4]${NC} Configuring Joplin sync..."

# Prompt for credentials
read -p "  Enter your email for Joplin Server: " JOPLIN_EMAIL
read -s -p "  Enter the shared Joplin Server password: " JOPLIN_PASSWORD
echo ""

if [ -z "${JOPLIN_EMAIL}" ] || [ -z "${JOPLIN_PASSWORD}" ]; then
    echo -e "  ${RED}Error: Email and password are required.${NC}"
    exit 1
fi

# Ensure config directory exists
mkdir -p "${HOME}/.config/joplin"

# Write settings.json
cat > "${HOME}/.config/joplin/settings.json" << SETTINGSEOF
{
	"\$schema": "https://joplinapp.org/schema/settings.json",
	"sync.target": 9,
	"sync.9.path": "${JOPLIN_SERVER_URL}",
	"sync.9.username": "${JOPLIN_EMAIL}",
	"sync.9.password": "${JOPLIN_PASSWORD}",
	"sync.wipeOutFailSafe": false,
	"sync.interval": 300,
	"editor": "nano",
	"locale": "en_GB",
	"markdown.plugin.softbreaks": false,
	"markdown.plugin.typographer": false
}
SETTINGSEOF

echo -e "  ${GREEN}Settings configured.${NC}"

# ---- Step 4: Initial sync ----
echo -e "${GREEN}[4/4]${NC} Running initial sync..."
cd "${HOME}"
joplin sync 2>&1 || true
echo ""

# ---- Add PATH to bashrc ----
if ! grep -q "${NPM_PREFIX}/bin" "${HOME}/.bashrc" 2>/dev/null; then
    echo "export PATH=\"${NPM_PREFIX}/bin:\$PATH\"" >> "${HOME}/.bashrc"
    echo -e "  Added Joplin to ${HOME}/.bashrc"
fi

echo ""
echo -e "${CYAN}============================================${NC}"
echo -e "${GREEN}  ✅  Joplin CLI is ready!${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""
echo -e "  Run ${GREEN}joplin${NC} to launch the interactive UI"
echo "  or use commands like:"
echo "    joplin mknote \"My note\""
echo "    joplin cat \"My note\""
echo "    joplin sync"
echo ""
echo -e "  Server: ${JOPLIN_SERVER_URL}"
echo -e "  Email:  ${JOPLIN_EMAIL}"
echo ""
echo "  Notes are synced automatically every 5 minutes."
echo ""