#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SONAME="libenable-3fg-drag.so"
PRELOAD_FILE="/etc/ld.so.preload"

# Determine system library directory
if [ -d "/usr/lib64" ] && [ ! -L "/usr/lib64" ]; then
    LIBDIR="/usr/lib64"
else
    LIBDIR="/usr/lib"
fi
TARGET_SO="$LIBDIR/$SONAME"

echo "==> Building $SONAME"
make -C "$HERE" clean >/dev/null 2>&1 || true
make -C "$HERE"

echo "==> Installing $TARGET_SO (mode 4755)"
sudo install -m 4755 -o root -g root "$HERE/$SONAME" "$TARGET_SO"
sudo ldconfig

echo "==> Registering in $PRELOAD_FILE"
if ! sudo grep -qxF "$TARGET_SO" "$PRELOAD_FILE" 2>/dev/null; then
    echo "$TARGET_SO" | sudo tee -a "$PRELOAD_FILE" >/dev/null
fi

# Clean up obsolete JS extension if present
rm -rf "$HOME/.local/share/gnome-shell/extensions/three-finger-drag@local"

cat <<EOF

==> Installation complete.

To activate:
  Log out and log back in (full Wayland session restart).

Verify in journal after login:
  journalctl --user -b | grep enable-3fg-drag
  # -> [enable-3fg-drag] enabled 3-finger drag on "<touchpad>": Success

To uninstall:
  ./uninstall.sh
EOF
