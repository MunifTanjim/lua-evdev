local ffi = require("ffi")
local input = require("evdev.linux.input")

---@class Event
---@field ev ffi.cdata*|{code: number, type: number, value: number, time: any}
local Event = {}

---@return Event
local function init(class, ev)
  local self = setmetatable({}, { __index = class })

  self.ev = ev or ffi.new("struct input_event")

  return self
end

function Event:new(ev)
  return init(self, ev)
end

---@return number
function Event:code()
  return self.ev.code
end

---@return EVDEV_INPUT_CONSTANT
function Event:code_name()
  return input.get_name_by_code(self.ev.type, self.ev.code)
end

---@return number
function Event:type()
  return self.ev.type
end

---@return EVDEV_INPUT_CONSTANT_EV
function Event:type_name()
  return input.get_name_by_code(-1, self.ev.type)
end

---@return number
function Event:value()
  return self.ev.value
end

return Event
