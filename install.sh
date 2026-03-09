#!/usr/bin/env bash
# install.sh — Installs sandbox to /usr/local/bin
# https://github.com/rankgnar/agent-sandbox

set -euo pipefail

INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SANDBOX_SCRIPT="$SCRIPT_DIR/sandbox"

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

echo -e "${BOLD}agent-sandbox installer${RESET}"
echo ""

# Check bubblewrap
if ! command -v bwrap &>/dev/null; then
    echo -e "${RED}Warning: bubblewrap (bwrap) is not installed.${RESET}"
    echo -e "Install it first:"
    echo -e "  Debian/Ubuntu: ${CYAN}sudo apt install bubblewrap${RESET}"
    echo -e "  Fedora/RHEL:   ${CYAN}sudo dnf install bubblewrap${RESET}"
    echo -e "  Arch:          ${CYAN}sudo pacman -S bubblewrap${RESET}"
    echo ""
    read -rp "Continue anyway? [y/N] " yn
    [[ "${yn,,}" == "y" ]] || exit 1
fi

# Install
echo -e "Installing to ${BOLD}$INSTALL_DIR/sandbox${RESET}..."

if [[ ! -w "$INSTALL_DIR" ]]; then
    echo -e "${CYAN}Requesting sudo...${RESET}"
    sudo install -m 755 "$SANDBOX_SCRIPT" "$INSTALL_DIR/sandbox"
else
    install -m 755 "$SANDBOX_SCRIPT" "$INSTALL_DIR/sandbox"
fi

echo -e "${GREEN}✔ Installed: $INSTALL_DIR/sandbox${RESET}"
echo ""
echo -e "Try it:"
echo -e "  ${CYAN}sandbox --help${RESET}"
echo -e "  ${CYAN}sandbox --dry-run bash${RESET}"
echo -e "  ${CYAN}sandbox claude --dangerously-skip-permissions${RESET}"
