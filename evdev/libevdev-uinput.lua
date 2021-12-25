local ffi = require("ffi")

ffi.cdef([[
struct libevdev_uinput;

enum libevdev_uinput_open_mode {
  LIBEVDEV_UINPUT_OPEN_MANAGED = -2
};

int libevdev_uinput_create_from_device(const struct libevdev *dev, int uinput_fd, struct libevdev_uinput **uinput_dev);
void libevdev_uinput_destroy(struct libevdev_uinput *uinput_dev);
int libevdev_uinput_get_fd(const struct libevdev_uinput *uinput_dev);
const char* libevdev_uinput_get_syspath(struct libevdev_uinput *uinput_dev);
const char* libevdev_uinput_get_devnode(struct libevdev_uinput *uinput_dev);
int libevdev_uinput_write_event(const struct libevdev_uinput *uinput_dev, unsigned int type, unsigned int code, int value);
]])

local c = ffi.load("evdev")

local mod = {
  libevdev_uinput_create_from_device = c.libevdev_uinput_create_from_device,
  libevdev_uinput_destroy = c.libevdev_uinput_destroy,
  libevdev_uinput_get_fd = c.libevdev_uinput_get_fd,
  libevdev_uinput_get_syspath = c.libevdev_uinput_get_syspath,
  libevdev_uinput_get_devnode = c.libevdev_uinput_get_devnode,
  libevdev_uinput_write_event = c.libevdev_uinput_write_event,
}

return mod
