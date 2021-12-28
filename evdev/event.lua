local ffi = require("ffi")

local input = require("evdev.linux.input")

---@class Event
---@field ev ffi.cdata*|evdev_input_event
local Event = {}

---@param ev ffi.cdata*
---@return Event
local function init(class, ev)
  ---@type Event
  local self = setmetatable({}, { __index = class })

  self.ev = ev or ffi.new("struct input_event")

  return self
end

---@param ev ffi.cdata*
function Event:new(ev)
  return init(self, ev)
end

---@param ev_type number
---@return boolean
function Event:is_type(ev_type)
  return self.ev.type == ev_type
end

---@param ev_type number
---@param code number
---@return boolean
function Event:is_code(ev_type, code)
  return self:is_type(ev_type) and self.ev.code == code
end

---@return number
function Event:code()
  return self.ev.code
end

---@return EVDEV_INPUT_CONSTANT_NAME
function Event:code_name()
  return input.get_name_by_code(self.ev.type, self.ev.code)
end

---@return number
function Event:type()
  return self.ev.type
end

---@return EVDEV_INPUT_EV_CONSTANT_NAME
function Event:type_name()
  return input.get_name_by_code(-1, self.ev.type)
end

---@return number
function Event:value()
  return self.ev.value
end

return Event
