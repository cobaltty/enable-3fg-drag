# enable-3fg-drag

Enable native, macOS-style three-finger dragging on Wayland compositors (GNOME Shell, KWin) using `libinput` (>= 1.28).

## Overview

`libinput` natively supports three-finger dragging (`libinput_device_config_3fg_drag_set_enabled`), emitting real hardware button clicks and motion events that work inside desktop windows and Overview modal grabs. However, desktop environments currently leave this feature disabled by default with no user-facing toggle.

This project provides a lightweight `LD_PRELOAD` C shim (`libenable-3fg-drag.so`) that intercepts `libinput_get_event` and automatically enables three-finger drag on any attached touchpad supporting >= 3 fingers.

## Requirements

- Wayland session with `libinput` >= 1.28
- C compiler (`cc`, `gcc`, or `clang`) and `make`
- Root access (for `/usr/lib/` and `/etc/ld.so.preload`)

## Installation

```bash
git clone https://github.com/<your-username>/enable-3fg-drag.git
cd enable-3fg-drag
./install.sh
```

Log out and log back in to reload your Wayland compositor.

Verify in journal logs:
```bash
journalctl --user -b | grep enable-3fg-drag
# -> [enable-3fg-drag] enabled 3-finger drag on "<touchpad>": Success
```

## Uninstallation

```bash
./uninstall.sh
```

Log out and back in to fully unload the shim.

## Usage Notes

- **Tap to drop instantly:** `libinput` includes an internal ~300ms drag release delay so you can reposition your fingers without losing the drag. To cancel the drag immediately without waiting, tap 1 or 2 fingers on the trackpad.
- **GNOME 4-finger gestures:** Keep the `swap-finger-gestures-3-4` GNOME extension enabled so stock workspace/overview swipe gestures use 4 fingers instead of interfering with 3-finger drag.
