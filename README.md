# enable-3fg-drag

Enable native, macOS-style three-finger dragging on Wayland compositors (GNOME Shell, KWin) via `libinput`.

---

## Why Native Driver Drag Over Shell Extensions

Most attempts to implement three-finger drag on Linux rely on desktop extensions (such as GNOME Shell extensions). While functional for basic window moving, extension-based implementations suffer from architectural limitations:

| Feature | Shell Extension Approach | Patched libinput | **enable-3fg-drag (Shim)** |
| :--- | :---: | :---: | :---: |
| **Overview & Modal Grab Support** | ❌ Blocked by Mutter modal grab | ✔ Works everywhere | **✔ Works everywhere** |
| **System Update Stability** | ❌ Breaks on DE updates | ❌ Overwritten by package manager | **✔ Survives OS/DE updates** |
| **Cross-Desktop Compatibility** | ❌ GNOME Shell only | ✔ Any compositor | **✔ GNOME, KDE Plasma, etc.** |
| **Input Thread Performance** | ❌ Main UI thread (JS) | ✔ Input thread (C) | **✔ Input thread (C)** |
| **Maintenance Overhead** | ⚠️ High (adapting JS APIs) | ⚠️ High (recompiling each update) | **✔ Zero (stable C ABI)** |

### The Modal Grab Problem in Wayland

When entering the GNOME Overview or opening a modal dialog, the compositor activates a modal grab (`Main.pushModal`). This grab explicitly locks input routing to the physical hardware seat device.

Shell extensions synthesize clicks using secondary virtual pointer devices (`MetaVirtualInputDevice`). Because these secondary devices are not the grab's target, **Mutter silently discards their button events inside the Overview**. This makes dragging application icons or interacting with Overview elements impossible via extensions.

`enable-3fg-drag` bypasses the compositor entirely by activating `libinput`'s built-in drag engine (`libinput_device_config_3fg_drag_set_enabled`). Clicks and motion are synthesized at the driver level, emitting real hardware events from your physical touchpad that pass through all modal grabs.

---

## Highlights

- **Native Driver Integration:** Leverages the native 3-finger drag engine merged into `libinput` ≥ 1.28.
- **Fast-Swipe Aware:** Fast flick gestures continue to register as swipe events (libinput ≥ 1.31).
- **Self-Contained:** Written in minimal C. Compiles with standard tools without requiring `libinput-devel` headers.

---

## Requirements

- Wayland session powered by `libinput` ≥ 1.28
- C compiler (`cc`, `gcc`, or `clang`) and `make`
- Root access (for `/usr/lib/` and `/etc/ld.so.preload`)

---

## Installation

```bash
git clone https://github.com/cobaltty/enable-3fg-drag.git
cd enable-3fg-drag
./install.sh
```

Log out and log back in to reload your Wayland session.

### Verify Activation

Check the system journal after logging in:

```bash
journalctl --user -b | grep enable-3fg-drag
```

Expected log:
```text
[enable-3fg-drag] enabled 3-finger drag on "ELAN0718:00 04F3:30FD Touchpad": Success
```

---

## Behavior & Usage

- **Tap to Drop Instantly:**
  `libinput` implements an internal ~300ms release delay allowing fingers to lift and reposition without prematurely dropping items. To release the drag immediately, tap 1 or 2 fingers on the trackpad.
- **GNOME 4-Finger Navigation:**
  On GNOME Shell, install [swap-finger-gestures-3-4](https://extensions.gnome.org/extension/6049/swap-finger-gestures-3-4/) so desktop switching and Overview toggles use 4 fingers, reserving 3 fingers exclusively for dragging.

---

## Uninstallation

```bash
./uninstall.sh
```

Log out and log back in to fully revert.

---

## License

MIT
