#!/usr/bin/env bash
set -euo pipefail

REPO_RAW_BASE="https://raw.githubusercontent.com/doggsire/wappify/main"
REMOTE_SCRIPT="wappify"
DEST="/usr/bin/wappify"
TMP="/tmp/wappify.$$"
BACKUP_SUFFIX=".bak.$(date +%s)"
BROWSERS=(chromium chromium-browser google-chrome chrome brave-browser)

echog() { printf '%s\n' "$*"; }
err() { printf 'Error: %s\n' "$*" >&2; exit 1; }

# Ensure curl or wget available
fetch() {
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$1" -o "$2"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$2" "$1"
  else
    err "curl or wget required"
  fi
}

# Check browser presence
find_browser() {
  for b in "${BROWSERS[@]}"; do
    if command -v "$b" >/dev/null 2>&1; then
      printf '%s' "$b"
      return 0
    fi
  done
  return 1
}

main() {
  echog "Installing wappify..."

  fetch "${REPO_RAW_BASE}/${REMOTE_SCRIPT}" "$TMP"
  chmod +x "$TMP"

  if [ -w "$(dirname "$DEST")" ] && [ -w "$(dirname "$DEST")/." ]; then
    # writable (root or permissive)
    if [ -f "$DEST" ]; then
      echog "Existing $DEST detected; backing up to ${DEST}${BACKUP_SUFFIX}"
      mv -f "$DEST" "${DEST}${BACKUP_SUFFIX}"
    fi
    mv -f "$TMP" "$DEST"
    chmod 755 "$DEST"
    echog "Installed to $DEST"
  else
    # Try using sudo
    if command -v sudo >/dev/null 2>&1; then
      echog "Requesting sudo to install to $DEST"
      if [ -f "$DEST" ]; then
        sudo mv -f "$DEST" "${DEST}${BACKUP_SUFFIX}"
      fi
      sudo mv -f "$TMP" "$DEST"
      sudo chmod 755 "$DEST"
      echog "Installed to $DEST (via sudo)"
    else
      # fall back to per-user install
      USER_DEST="$HOME/.local/bin/wappify"
      mkdir -p "$(dirname "$USER_DEST")"
      mv -f "$TMP" "$USER_DEST"
      chmod 755 "$USER_DEST"
      echog "No root write access or sudo found — installed to $USER_DEST"
      echog "Add ~/.local/bin to your PATH if it's not already."
    fi
  fi

  # Basic sanity: ensure installed file is executable
  if ! command -v wappify >/dev/null 2>&1; then
    echog "Note: you may need to reopen your shell or ensure /usr/bin or ~/.local/bin is in PATH."
  fi

  # Suggest detected browser
  if browser=$(find_browser); then
    echog "Detected web browser binary: $browser"
  else
    echog "No known browser binary found (checked: ${BROWSERS[*]}). The installed script expects 'chromium' by default; you may want to edit the script or install a supported browser."
  fi

  echog "Done."
}

main "$@"
