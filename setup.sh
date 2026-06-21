#!/usr/bin/env bash
#
# ============================================================
# Joplin CLI One-Command Installer
# Target: any Linux VPS or local machine (Ubuntu/Debian)
# Result: fully synced Joplin terminal client
# ============================================================
set -euo pipefail

# Server settings (edit if you run your own server)
SERVER_URL="https://joplin-server-s9yj.srv620544.hstgr.cloud"

echo "=========================================="
echo "  Joplin CLI Installer"
echo "=========================================="

# ------------------- NODE CHECK -------------------
if ! command -v node &> /dev/null; then
    echo "Node.js not found. Installing..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - 2>/dev/null || {
        echo "Could not install Node.js automatically."
        echo "Install Node 18+ manually, then re-run this script."
        exit 1
    }
    sudo apt install -y nodejs
else
    echo "Node.js: $(node --version)"
fi

# ------------------- INSTALL JOPLIN CLI -------------------
echo "Installing Joplin CLI globally..."
npm install -g joplin

# Add to PATH for this session
export PATH="$HOME/.npm-global/bin:$PATH"

# Determine shell profile
SHELL_RC=""
if [[ "$SHELL" == */bash ]]; then
    SHELL_RC="$HOME/.bashrc"
elif [[ "$SHELL" == */zsh ]]; then
    SHELL_RC="$HOME/.zshrc"
else
    SHELL_RC="$HOME/.bashrc"
fi

# Add to profile if not present
if ! grep -q "\.npm-global/bin" "$SHELL_RC" 2>/dev/null; then
    echo "Adding Joplin to $SHELL_RC..."
    echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> "$SHELL_RC"
fi

echo ""
echo "=========================================="
echo "       Account Setup"
echo "=========================================="

# Read credentials interactive
read -rp "Enter your email (Joplin login): " USER_EMAIL
read -rsp "Enter the shared server password: " USER_PASS
echo ""

# ------------------- CONFIGURE SYNC -------------------
echo "Configuring sync..."
joplin config sync.target 9
joplin config sync.9.path "$SERVER_URL"
joplin config sync.9.username "$USER_EMAIL"
joplin config sync.9.password "$USER_PASS"

# Default to manual sync (safer for automated scripts)
joplin config sync.interval 0

# Disable wipe failsafe for multi-client use
joplin config sync.wipeOutFailSafe 0

# ------------------- FIRST SYNC -------------------
echo ""
echo "Running first sync..."
joplin sync

echo ""
echo "=========================================="
echo "           INSTALL COMPLETE"
echo "=========================================="
echo ""
echo " Quick commands:"
echo "   joplin                    # Launch interactive UI"
echo "   joplin sync               # Manual sync"
echo "   joplin mkbook \"Notes\"    # Create a notebook"
echo "   joplin ls                 # List notes"
echo "   joplin search \"keyword\"  # Find anything"
echo ""
echo " Sync server:  $SERVER_URL"
echo " Logged in as: $USER_EMAIL"
echo " Sync mode:    manual (interval=0)"
echo ""
echo " See BATCH-OPERATIONS.md for bulk tagging, imports, and advanced workflows."
echo "=========================================="
