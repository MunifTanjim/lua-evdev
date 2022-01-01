local ffi = require("ffi")

local util = require("evdev.util")

local libevdev_uinput = require("evdev.libevdev-uinput")
local evdev_uinput_enum = libevdev_uinput.enum
local evdev_uinput = libevdev_uinput.lib

local libevdev_uinput_open_mode = evdev_uinput_enum.libevdev_uinput_open_mode

---@class UInputDevice
---@field device Device
---@field uinput_dev ffi.cdata*
local UInputDevice = {}

---@param device Device
---@param uinput_fd_or_pathname? number
---@param flags? nil|number[]
---@return UInputDevice
local function init(class, device, uinput_fd_or_pathname, flags)
  ---@type UInputDevice
  local self = setmetatable({}, { __index = class })

  local uinput_fd, fd_err = util.to_fd(uinput_fd_or_pathname, flags)
  if fd_err then
    return nil, fd_err
  end

  if not uinput_fd then
    uinput_fd = libevdev_uinput_open_mode.MANAGED
  end

  local uinput_dev_ptr = libevdev_uinput.ctype.libevdev_uinput_ptr()

  local rc = evdev_uinput.libevdev_uinput_create_from_device(device.dev, uinput_fd, uinput_dev_ptr)
  if rc < 0 then
    return nil, string.format("Error: %s", util.err_string(-rc))
  end

  self.device = device
  self.uinput_dev = uinput_dev_ptr[0]

  ffi.gc(self.uinput_dev, evdev_uinput.libevdev_uinput_destroy)

  return self
end

---@param device Device
---@param uinput_fd_or_pathname? number
---@param flags? nil|number[]
---@return UInputDevice
function UInputDevice:new(device, uinput_fd_or_pathname, flags)
  return init(self, device, uinput_fd_or_pathname, flags)
end

---@return number
function UInputDevice:fd()
  return evdev_uinput.libevdev_uinput_get_fd(self.uinput_dev)
end

---@return string
function UInputDevice:syspath()
  return util.to_string(evdev_uinput.libevdev_uinput_get_syspath(self.uinput_dev))
end

---@return string
function UInputDevice:devnode()
  return util.to_string(evdev_uinput.libevdev_uinput_get_devnode(self.uinput_dev))
end

---@param ev_type number
---@param code number
---@param value number
---@return boolean success
function UInputDevice:write_event(ev_type, code, value)
  local rc = evdev_uinput.libevdev_uinput_write_event(self.uinput_dev, ev_type, code, value)
  return rc == 0
end

return UInputDevice
