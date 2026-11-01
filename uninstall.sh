#!/usr/bin/env bash
set -euo pipefail

SONAME="libenable-3fg-drag.so"
PRELOAD_FILE="/etc/ld.so.preload"

if [ -d "/usr/lib64" ] && [ ! -L "/usr/lib64" ]; then
    LIBDIR="/usr/lib64"
else
    LIBDIR="/usr/lib"
fi
TARGET_SO="$LIBDIR/$SONAME"

echo "==> Removing $TARGET_SO from $PRELOAD_FILE"
if [ -f "$PRELOAD_FILE" ] && grep -qxF "$TARGET_SO" "$PRELOAD_FILE" 2>/dev/null; then
    sudo grep -vxF "$TARGET_SO" "$PRELOAD_FILE" | sudo tee "${PRELOAD_FILE}.tmp" >/dev/null
    sudo mv "${PRELOAD_FILE}.tmp" "$PRELOAD_FILE"
fi

echo "==> Removing $TARGET_SO"
sudo rm -f "$TARGET_SO"
sudo ldconfig

cat <<EOF

==> Uninstalled. Log out and back in to fully unload.
EOF
