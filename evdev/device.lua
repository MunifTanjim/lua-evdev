local ffi = require("ffi")

local Event = require("evdev.event")
local input = require("evdev.linux.input")
local util = require("evdev.util")

local libevdev = require("evdev.libevdev")
local evdev_enum = libevdev.enum
local evdev = libevdev.lib

local libevdev_grab_mode = evdev_enum.libevdev_grab_mode
local libevdev_read_flag = evdev_enum.libevdev_read_flag
local open_flag = util.enum.open_flag

local new_libevdev_ptr = ffi.typeof("struct libevdev *[1]")

---@class Device
---@field fd number
---@field pathname string
---@field dev ffi.cdata*
local Device = {}

---@param pathname string
---@param flags number[] `open_flag[]`
---@return Device
local function init(class, pathname, flags)
  ---@type Device
  local self = setmetatable({}, { __index = class })

  self.pathname = pathname

  local fd = util.open_file(pathname, flags or { open_flag.RDONLY, open_flag.NONBLOCK })
  if fd < 0 then
    return nil, string.format("Error: %s", util.err_string(ffi.errno()))
  end

  self.fd = fd

  local dev_ptr = new_libevdev_ptr()

  local rc = evdev.libevdev_new_from_fd(fd, dev_ptr)
  if rc < 0 then
    return nil, string.format("Error: %s", util.err_string(-rc))
  end

  self.dev = dev_ptr[0]

  ffi.gc(self.dev, evdev.libevdev_free)

  return self
end

---@param pathname string
---@param flags number[] `open_flag[]`
---@return Device
function Device:new(pathname, flags)
  return init(self, pathname, flags)
end

---@param mode boolean|number `libevdev_grab_mode`
---@return number
function Device:grab(mode)
  if mode == true then
    mode = libevdev_grab_mode.GRAB
  elseif mode == false then
    mode = libevdev_grab_mode.UNGRAB
  end

  return evdev.libevdev_grab(self.dev, mode)
end

---@param flags? number|number[] `libevdev_read_flag` or `libevdev_read_flag[]` (default: `NORMAL`)
---@param event? Event
---@return number rc, Event event
function Device:next_event(flags, event)
  local flag = util.bit_or(flags or libevdev_read_flag.NORMAL)
  event = event or Event:new()
  local rc = evdev.libevdev_next_event(self.dev, flag, event.ev)
  return rc, event
end

---@return boolean
function Device:has_event_pending()
  return evdev.libevdev_has_event_pending(self.dev) == 1
end

---@return string
function Device:name()
  return util.to_string(evdev.libevdev_get_name(self.dev))
end

---@return string
function Device:phys()
  return util.to_string(evdev.libevdev_get_phys(self.dev))
end

---@return string
function Device:uniq()
  return util.to_string(evdev.libevdev_get_uniq(self.dev))
end

---@return number
function Device:id_product()
  return evdev.libevdev_get_id_product(self.dev)
end

---@return number
function Device:id_vendor()
  return evdev.libevdev_get_id_vendor(self.dev)
end

---@return number
function Device:id_bustype()
  return evdev.libevdev_get_id_bustype(self.dev)
end

---@return number
function Device:id_version()
  return evdev.libevdev_get_id_version(self.dev)
end

---@return number
function Device:driver_version()
  return evdev.libevdev_get_driver_version(self.dev)
end

---@param prop number
---@return boolean
function Device:has_property(prop)
  return evdev.libevdev_has_property(self.dev, prop) == 1
end

---@param prop number
---@return number
function Device:enable_property(prop)
  return evdev.libevdev_enable_property(self.dev, prop)
end

---@param prop number
---@return number
function Device:disable_property(prop)
  return evdev.libevdev_disable_property(self.dev, prop)
end

---@param ev_type number
---@return boolean
function Device:has_event_type(ev_type)
  return evdev.libevdev_has_event_type(self.dev, ev_type) == 1
end

---@param ev_type number
---@param ev_code number
---@return boolean
function Device:has_event_code(ev_type, ev_code)
  return evdev.libevdev_has_event_code(self.dev, ev_type, ev_code) == 1
end

---@param code number
---@return number
function Device:abs_minimum(code)
  return evdev.libevdev_get_abs_minimum(self.dev, code)
end

---@param code number
---@return number
function Device:abs_maximum(code)
  return evdev.libevdev_get_abs_maximum(self.dev, code)
end

---@param code number
---@return number
function Device:abs_fuzz(code)
  return evdev.libevdev_get_abs_fuzz(self.dev, code)
end

---@param code number
---@return number
function Device:abs_flat(code)
  return evdev.libevdev_get_abs_flat(self.dev, code)
end

---@param code number
---@return number
function Device:abs_resolution(code)
  return evdev.libevdev_get_abs_resolution(self.dev, code)
end

---@param code number
---@return ffi.cdata*|evdev_input_absinfo
function Device:abs_info(code)
  return evdev.libevdev_get_abs_info(self.dev, code)
end

---@param ev_type number
---@param code number
---@return number
function Device:event_value(ev_type, code)
  return evdev.libevdev_get_event_value(self.dev, ev_type, code)
end

---@param ev_type number
---@param code number
---@param value_ptr? ffi.cdata*|{ [0]: number }
---@return number|nil
function Device:fetch_event_value(ev_type, code, value_ptr)
  value_ptr = value_ptr or input.ctype.int_ptr()
  local rc = evdev.libevdev_fetch_event_value(self.dev, ev_type, code, value_ptr)
  if rc ~= 0 then
    return value_ptr[0]
  end
end

---@param slot number
---@param code number
---@return number
function Device:slot_value(slot, code)
  return evdev.libevdev_get_slot_value(self.dev, slot, code)
end

---@param slot number
---@param code number
---@param value_ptr? ffi.cdata*|{ [0]: number }
---@return number|nil
function Device:fetch_slot_value(slot, code, value_ptr)
  value_ptr = value_ptr or input.ctype.int_ptr()
  local rc = evdev.libevdev_fetch_slot_value(self.dev, slot, code, value_ptr)
  if rc ~= 0 then
    return value_ptr[0]
  end
end

---@return number
function Device:num_slots()
  return evdev.libevdev_get_num_slots(self.dev)
end

---@return number
function Device:current_slot()
  return evdev.libevdev_get_current_slot(self.dev)
end

---@param ev_type number
---@return number
function Device:enable_event_type(ev_type)
  return evdev.libevdev_enable_event_type(self.dev, ev_type)
end

---@param ev_type number
---@return number
function Device:disable_event_type(ev_type)
  return evdev.libevdev_disable_event_type(self.dev, ev_type)
end

---@param ev_type number
---@param code number
---@param data? nil|ffi.cdata*|evdev_input_absinfo|number
---@return number
function Device:enable_event_code(ev_type, code, data)
  local data_type = type(data)
  if data_type == "number" then
    data = input.ctype.int(data)
  elseif data_type == "table" then
    data = input.ctype.input_absinfo(data)
  end

  return evdev.libevdev_enable_event_code(self.dev, ev_type, code, data)
end

---@param ev_type number
---@param code number
---@return number
function Device:disable_event_code(ev_type, code)
  return evdev.libevdev_disable_event_code(self.dev, ev_type, code)
end

return Device
