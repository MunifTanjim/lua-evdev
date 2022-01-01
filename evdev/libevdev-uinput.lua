local ffi = require("ffi")

--luacheck: push no max line length

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

--luacheck: pop

---@diagnostic disable: undefined-field
--
local enum = {
  ---@type number
  LIBEVDEV_UINPUT_OPEN_MANAGED = ffi.C.LIBEVDEV_UINPUT_OPEN_MANAGED,
}

---@diagnostic enable: undefined-field

enum.libevdev_uinput_open_mode = {
  MANAGED = enum.LIBEVDEV_UINPUT_OPEN_MANAGED,
}

--luacheck: push no max line length

---@class libevdev_uinput
---@field libevdev_uinput_create_from_device fun(dev: ffi.cdata*, uinput_fd: number, uinput_dev: ffi.cdata*): number
---@field libevdev_uinput_destroy            fun(uinput_dev: ffi.cdata*): nil
---@field libevdev_uinput_get_fd             fun(uinput_dev: ffi.cdata*): number
---@field libevdev_uinput_get_syspath        fun(uinput_dev: ffi.cdata*): ffi.cdata*
---@field libevdev_uinput_get_devnode        fun(uinput_dev: ffi.cdata*): ffi.cdata*
---@field libevdev_uinput_write_event        fun(uinput_dev: ffi.cdata*, type: number, code: number, value: number): number
local libevdev_uinput = ffi.load("evdev")

--luacheck: pop

local ctype = {
  libevdev_uinput_ptr = ffi.typeof("struct libevdev_uinput *[1]"),
}

local mod = {
  ctype = ctype,
  enum = enum,
  lib = libevdev_uinput,
}

return mod
