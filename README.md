# enable-3fg-drag

Enable native, macOS-style three-finger drag on Wayland compositors (GNOME Shell, KWin) using libinput's built-in engine.

---

## Highlights

- **Works in Overview & Modal Grabs:** Synthesizes hardware pointer events directly inside `libinput`. Unlike Shell extensions, it cannot be blocked by Mutter's modal grab filter.
- **Zero Package Breakage:** Standalone `LD_PRELOAD` shim. Survives distro upgrades, kernel updates, and GNOME Shell releases.
- **Fast Swipes Preserved:** A fast 3-finger flick still acts as a swipe gesture (libinput ≥ 1.31).
- **No Build Dependencies:** Zero external headers needed. Compiles cleanly with standard `cc` / `gcc` / `clang`.

---

## Why This Exists

`libinput` has shipped full native three-finger dragging since **v1.28** (`libinput_device_config_3fg_drag_set_enabled`), handling finger tracking, button holds, pointer motion, and palm rejection in C.

However, neither GNOME Shell nor KDE Plasma expose a toggle to turn it on. GNOME extensions attempt to emulate this via virtual pointer devices, but Mutter completely drops secondary virtual pointer clicks inside the Overview (modal grab).

This shim hooks `libinput_get_event()` to automatically flip the native driver switch whenever a touchpad is detected.

---

## Comparison

| Feature | GNOME Extension | Patched libinput | **enable-3fg-drag** |
| :--- | :---: | :---: | :---: |
| **Desktop Windows & Text Drag** | Yes | Yes | **Yes** |
| **Overview App Icon Reordering** | No (blocked by grab) | Yes | **Yes** |
| **Survives OS / GNOME Updates** | Often breaks yearly | Overwritten on update | **Yes (stable ABI)** |
| **System Modification** | Extension directory | Replaced binary | **Single `.so` file** |

---

## Requirements

- Linux with Wayland session
- `libinput` ≥ 1.28
- C compiler (`cc`, `gcc`, or `clang`) and `make`
- `sudo` access (for `/usr/lib/` and `/etc/ld.so.preload`)

---

## Installation

```bash
git clone https://github.com/cobaltty/enable-3fg-drag.git
cd enable-3fg-drag
./install.sh
```

Log out and log back in to reload your Wayland compositor session.

### Verify Activation

Check user journal logs after logging in:

```bash
journalctl --user -b | grep enable-3fg-drag
```

Expected output:
```text
[enable-3fg-drag] enabled 3-finger drag on "ELAN0718:00 04F3:30FD Touchpad": Success
```

---

## Behavior & Tips

- **Instant Drop (Bypassing Delay):**
  `libinput` includes an internal ~300ms release delay so you can lift and reposition your fingers across trackpad edges without dropping.
  *To drop immediately without waiting, tap 1 or 2 fingers on the trackpad right after lifting.*
- **Retain 4-Finger Workspace Navigation (GNOME):**
  Keep the [swap-finger-gestures-3-4](https://extensions.gnome.org/extension/6049/swap-finger-gestures-3-4/) extension enabled to remap GNOME's workspace switching and Overview gestures to 4 fingers, preventing gesture collisions with 3-finger drag.

---

## Uninstallation

```bash
./uninstall.sh
```

Log out and log back in to fully unload the library from the session.

---

## License

MIT
