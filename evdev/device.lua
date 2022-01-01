local ffi = require("ffi")

local Event = require("evdev.event")
local input = require("evdev.linux.input")
local util = require("evdev.util")

local libevdev = require("evdev.libevdev")
local evdev_enum = libevdev.enum
local evdev = libevdev.lib

local libevdev_grab_mode = evdev_enum.libevdev_grab_mode
local libevdev_read_flag = evdev_enum.libevdev_read_flag

---@class Device
---@field dev ffi.cdata*
local Device = {}

---@param fd_or_pathname? number|string
---@param flags? nil|number[]
---@return Device
local function init(class, fd_or_pathname, flags)
  ---@type Device
  local self = setmetatable({}, { __index = class })

  local fd, fd_err = util.to_fd(fd_or_pathname, flags)
  if fd_err then
    return nil, fd_err
  end

  if fd then
    local dev_ptr = libevdev.ctype.libevdev_ptr()

    local rc = evdev.libevdev_new_from_fd(fd, dev_ptr)
    if rc < 0 then
      return nil, string.format("Error: %s", util.err_string(-rc))
    end

    self._fd = fd
    self.dev = dev_ptr[0]
  else
    self.dev = evdev.libevdev_new()
  end

  ffi.gc(self.dev, evdev.libevdev_free)

  return self
end

---@override fun(): Device
---@override fun(fd: number): Device
---@override fun(pathname: string, flags: number[]): Device
---@param fd_or_pathname? number|string
---@param flags? nil|number[]
function Device:new(fd_or_pathname, flags)
  return init(self, fd_or_pathname, flags)
end

---@param fd_or_pathname? number|string
---@param flags? nil|number[]
---@return number fd
function Device:fd(fd_or_pathname, flags)
  if not fd_or_pathname then
    local fd = evdev.libevdev_get_fd(self.dev)
    if fd == -1 then
      self._fd = nil
      return nil
    end

    self._fd = fd
    return self._fd
  end

  local fd, fd_err = util.to_fd(fd_or_pathname, flags)
  if fd_err then
    return nil, fd_err
  end

  local rc
  if self._fd then
    rc = evdev.libevdev_change_fd(self.dev, fd)
  else
    rc = evdev.libevdev_set_fd(self.dev, fd)
  end

  if rc < 0 then
    return nil, string.format("Error: %s", util.err_string(-rc))
  end

  self._fd = fd
  return self._fd
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

---@param name? string
---@return string
function Device:name(name)
  if name then
    evdev.libevdev_set_name(self.dev, name)
    return name
  end

  return util.to_string(evdev.libevdev_get_name(self.dev))
end

---@param phys? string
---@return string
function Device:phys(phys)
  if phys then
    evdev.libevdev_set_phys(self.dev, phys)
    return phys
  end

  return util.to_string(evdev.libevdev_get_phys(self.dev))
end

---@param uniq? string
---@return string
function Device:uniq(uniq)
  if uniq then
    evdev.libevdev_set_uniq(self.dev, uniq)
    return uniq
  end

  return util.to_string(evdev.libevdev_get_uniq(self.dev))
end

---@param product_id? number
---@return number
function Device:product_id(product_id)
  if product_id then
    evdev.libevdev_set_id_product(self.dev, product_id)
    return product_id
  end

  return evdev.libevdev_get_id_product(self.dev)
end

---@param vendor_id? number
---@return number
function Device:vendor_id(vendor_id)
  if vendor_id then
    evdev.libevdev_set_id_vendor(self.dev, vendor_id)
    return vendor_id
  end

  return evdev.libevdev_get_id_vendor(self.dev)
end

---@param bustype? number
---@return number
function Device:bustype(bustype)
  if bustype then
    evdev.libevdev_set_id_bustype(self.dev, bustype)
    return bustype
  end

  return evdev.libevdev_get_id_bustype(self.dev)
end

---@param version? number
---@return number
function Device:version(version)
  if version then
    evdev.libevdev_set_id_version(self.dev, version)
    return version
  end

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
---@param value? number
---@return number
function Device:abs_minimum(code, value)
  if value then
    evdev.libevdev_set_abs_minimum(self.dev, code, value)
    return value
  end

  return evdev.libevdev_get_abs_minimum(self.dev, code)
end

---@param code number
---@param value? number
---@return number
function Device:abs_maximum(code, value)
  if value then
    evdev.libevdev_set_abs_maximum(self.dev, code, value)
    return value
  end

  return evdev.libevdev_get_abs_maximum(self.dev, code)
end

---@param code number
---@param value? number
---@return number
function Device:abs_fuzz(code, value)
  if value then
    evdev.libevdev_set_abs_fuzz(self.dev, code, value)
    return value
  end

  return evdev.libevdev_get_abs_fuzz(self.dev, code)
end

---@param code number
---@param value? number
---@return number
function Device:abs_flat(code, value)
  if value then
    evdev.libevdev_set_abs_flat(self.dev, code, value)
    return value
  end

  return evdev.libevdev_get_abs_flat(self.dev, code)
end

---@param code number
---@param value? number
---@return number
function Device:abs_resolution(code, value)
  if value then
    evdev.libevdev_set_abs_resolution(self.dev, code, value)
    return value
  end

  return evdev.libevdev_get_abs_resolution(self.dev, code)
end

---@param code number
---@param abs_info? evdev_input_absinfo
---@return ffi.cdata*|evdev_input_absinfo
function Device:abs_info(code, abs_info)
  if abs_info then
    local value = input.ctype.input_absinfo(abs_info)
    evdev.libevdev_set_abs_info(self.dev, code, value)
    return value
  end

  return evdev.libevdev_get_abs_info(self.dev, code)
end

---@param ev_type number
---@param code number
---@param value? number
---@return number
function Device:event_value(ev_type, code, value)
  if value then
    local rc = evdev.libevdev_set_event_value(self.dev, ev_type, code, value)
    if rc == 0 then
      return value
    end

    return nil, string.format("Error: failed to set event(type:%d, code:%d) value(%d)", ev_type, code, value)
  end

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
---@param value? number
---@return number
function Device:slot_value(slot, code, value)
  if value then
    local rc = evdev.libevdev_set_slot_value(self.dev, slot, code, value)
    if rc == 0 then
      return value
    end

    return nil, string.format("Error: failed to set slot(%d, code:%d) value(%d)", slot, code, value)
  end

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
