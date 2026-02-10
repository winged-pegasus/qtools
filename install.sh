#!/bin/bash
# Qtools Installer
# Usage: curl -sSL https://raw.githubusercontent.com/QuilibriumNetwork/qtools/main/install.sh | bash
#    or: wget -qO- https://raw.githubusercontent.com/QuilibriumNetwork/qtools/main/install.sh | bash
#
# This script clones the qtools repository and runs the initialization process.
# It should be run as a regular user with sudo access (NOT as root directly).

set -e

REPO_URL="https://github.com/QuilibriumNetwork/qtools.git"
BRANCH="main"
INSTALL_DIR="$HOME/qtools"

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
RESET="\033[0m"

info()    { echo -e "${BLUE}[INFO]${RESET} $1"; }
success() { echo -e "${GREEN}[OK]${RESET} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET} $1"; }
error()   { echo -e "${RED}[ERROR]${RESET} $1"; exit 1; }

# -------------------------------------------------------------------
# Pre-flight checks
# -------------------------------------------------------------------

# Ensure we are NOT running as root (the init script uses sudo internally)
if [ "$(id -u)" -eq 0 ]; then
    error "Do not run this script as root. Run as a regular user with sudo access.\n       Example: curl -sSL <url> | bash"
fi

# Verify sudo access
if ! sudo -v 2>/dev/null; then
    error "This script requires sudo access. Please ensure your user can run sudo."
fi

# Check for git
if ! command -v git >/dev/null 2>&1; then
    info "git is not installed. Attempting to install..."
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update -y && sudo apt-get install -y git
    elif command -v yum >/dev/null 2>&1; then
        sudo yum install -y git
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y git
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -Sy --noconfirm git
    else
        error "Cannot install git automatically. Please install git and try again."
    fi

    if ! command -v git >/dev/null 2>&1; then
        error "Failed to install git. Please install it manually and try again."
    fi
    success "git installed"
fi

# -------------------------------------------------------------------
# Clone or update the repository
# -------------------------------------------------------------------

if [ -d "$INSTALL_DIR/.git" ]; then
    info "Existing qtools installation found at $INSTALL_DIR"
    info "Pulling latest changes..."
    cd "$INSTALL_DIR"
    git fetch origin
    git checkout "$BRANCH"
    git pull origin "$BRANCH"
    success "Repository updated"
else
    if [ -d "$INSTALL_DIR" ]; then
        warn "$INSTALL_DIR exists but is not a git repo. Backing up to ${INSTALL_DIR}.bak"
        mv "$INSTALL_DIR" "${INSTALL_DIR}.bak.$(date +%s)"
    fi

    info "Cloning qtools from $REPO_URL ..."
    git clone "$REPO_URL" "$INSTALL_DIR"
    cd "$INSTALL_DIR"
    git checkout "$BRANCH"
    success "Repository cloned to $INSTALL_DIR"
fi

# -------------------------------------------------------------------
# Run initialization
# -------------------------------------------------------------------

info "Running qtools init..."
chmod +x "$INSTALL_DIR/qtools.sh"
cd "$INSTALL_DIR"
./qtools.sh init

success "qtools has been installed!"

echo ""
echo -e "${GREEN}============================================${RESET}"
echo -e "${GREEN}  Qtools installation complete!${RESET}"
echo -e "${GREEN}============================================${RESET}"
echo ""
echo "  To finish setting up your shell, run:"
echo ""
echo -e "    ${YELLOW}source ~/.bashrc${RESET}"
echo ""
echo "  Then install a Quilibrium node with:"
echo ""
echo -e "    ${YELLOW}qtools complete-install${RESET}"
echo ""
echo "  For all available commands, run:"
echo ""
echo -e "    ${YELLOW}qtools --help${RESET}"
echo ""
