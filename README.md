# lua-evdev

LuaJIT FFI Bindings for [`libevdev`](https://gitlab.freedesktop.org/libevdev/libevdev).

## Usage

### Initializing a Device

```lua
local Device = require("evdev.device")

---@param dev Device
local function print_device(dev)
  local name = dev:name():gsub("\n", " | ")
  print("============", "===")
  print("= Pathname: ", dev.pathname)
  print("=     Name: ", name)
  print("=     Phys: ", dev:phys())
  print("=     Uniq: ", dev:uniq())
  print("=  Product: ", dev:product_id())
  print("=   Vendor: ", dev:vendor_id())
  print("=  Bustype: ", dev:bustype())
  print("=  Version: ", dev:version())
  print("============", "===")
end

local dev = Device:new("/dev/input/event7")

print_device(dev)
```

### Reading Events from a Device

```lua
local Event = require("evdev.event")
local Device = require("evdev.device")
local libevdev = require("evdev.libevdev")
local input = require("evdev.linux.input")

local enum = libevdev.enum
local input_constant = input.constant

---@param ev Event
local function print_event(ev)
  print(string.format("{'%s', '%s', %d};", ev:type_name(), ev:code_name(), ev:value()))
end

---@param dev Device
---@param initial_state table
local function events(dev, initial_state)
  initial_state = initial_state or {}

  if not initial_state.read_flag then
    initial_state.read_flag = initial_state.read_flag or enum.libevdev_read_flag.NORMAL
  end

  if not initial_state.should_skip then
    initial_state.should_skip = function()
      return false
    end
  end

  local function iter(state)
    local rc, ev = 0, Event:new()

    repeat
      rc, ev = dev:next_event(state.read_flag, ev)
      if (rc == enum.libevdev_read_status.SUCCESS) or (rc == enum.libevdev_read_status.SYNC) then
        if not state.should_skip(ev) then
          return ev, state
        end
      end
    until rc ~= enum.libevdev_read_status.SUCCESS and rc ~= enum.libevdev_read_status.SYNC and rc ~= -11

    return nil, state
  end

  return iter, initial_state
end

local dev = Device:new("/dev/input/event7")

local initial_state = {
  ---@param ev Event
  should_skip = function(ev)
    ev:is_type(input_constant.EV_KEY)
  end,
}

for ev in events(dev, initial_state) do
  print_event(ev)
end
```

## License

Licensed under the MIT License. Check the [LICENSE](./LICENSE) file for details.
