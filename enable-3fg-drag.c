/*
 * enable-3fg-drag — turn on libinput's native three-finger dragging in Wayland compositors.
 *
 * Self-contained: declares minimal libinput signatures and enum values directly,
 * so it compiles with standard cc/gcc/clang without needing libinput development headers.
 */

#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdio.h>

#define LIBINPUT_EVENT_DEVICE_ADDED 1
#define LIBINPUT_CONFIG_3FG_DRAG_ENABLED_3FG 1

struct libinput;
struct libinput_event;
struct libinput_device;

struct libinput_event *libinput_get_event(struct libinput *li)
{
    static struct libinput_event *(*real)(struct libinput *);
    static int (*get_type)(struct libinput_event *);
    static struct libinput_device *(*get_device)(struct libinput_event *);
    static int (*get_finger_count)(struct libinput_device *);
    static int (*set_enabled)(struct libinput_device *, int);
    static const char *(*dev_name)(struct libinput_device *);
    static const char *(*status_str)(int);
    static int resolved;

    if (!resolved) {
        resolved = 1;
        real = dlsym(RTLD_NEXT, "libinput_get_event");
        get_type = dlsym(RTLD_NEXT, "libinput_event_get_type");
        get_device = dlsym(RTLD_NEXT, "libinput_event_get_device");
        get_finger_count = dlsym(RTLD_NEXT, "libinput_device_config_3fg_drag_get_finger_count");
        set_enabled = dlsym(RTLD_NEXT, "libinput_device_config_3fg_drag_set_enabled");
        dev_name = dlsym(RTLD_NEXT, "libinput_device_get_name");
        status_str = dlsym(RTLD_NEXT, "libinput_config_status_to_str");
    }

    if (!real)
        return NULL;

    struct libinput_event *ev = real(li);
    if (ev && get_type && get_device && get_finger_count && set_enabled &&
        get_type(ev) == LIBINPUT_EVENT_DEVICE_ADDED) {
        struct libinput_device *dev = get_device(ev);
        if (get_finger_count(dev) >= 3) {
            int st = set_enabled(dev, LIBINPUT_CONFIG_3FG_DRAG_ENABLED_3FG);
            fprintf(stderr,
                "[enable-3fg-drag] enabled 3-finger drag on \"%s\": %s\n",
                dev_name ? dev_name(dev) : "?",
                status_str ? status_str(st) : "");
        }
    }
    return ev;
}
