local ffi = require("ffi")

ffi.cdef([[
struct timeval {
  long tv_sec;
  long tv_usec;
};
]])

ffi.cdef([[
struct input_event {
  struct timeval time;
  uint16_t type;
  uint16_t code;
  int32_t value;
};

struct input_id {
  uint16_t bustype;
  uint16_t vendor;
  uint16_t product;
  uint16_t version;
};

struct input_absinfo {
  int32_t value;
  int32_t minimum;
  int32_t maximum;
  int32_t fuzz;
  int32_t flat;
  int32_t resolution;
};

struct input_keymap_entry {
  uint8_t  flags;
  uint8_t  len;
  uint16_t index;
  uint32_t keycode;
  uint8_t  scancode[32];
};

struct input_mask {
  uint32_t type;
  uint32_t codes_size;
  uint64_t codes_ptr;
};

struct ff_replay {
  uint16_t length;
  uint16_t delay;
};

struct ff_trigger {
  uint16_t button;
  uint16_t interval;
};

struct ff_envelope {
  uint16_t attack_length;
  uint16_t attack_level;
  uint16_t fade_length;
  uint16_t fade_level;
};

struct ff_constant_effect {
  int16_t level;
  struct ff_envelope envelope;
};

struct ff_ramp_effect {
  int16_t start_level;
  int16_t end_level;
  struct ff_envelope envelope;
};

struct ff_condition_effect {
  uint16_t right_saturation;
  uint16_t left_saturation;

  int16_t right_coeff;
  int16_t left_coeff;

  uint16_t deadband;
  int16_t center;
};

struct ff_periodic_effect {
  uint16_t waveform;
  uint16_t period;
  int16_t magnitude;
  int16_t offset;
  uint16_t phase;

  struct ff_envelope envelope;

  uint32_t custom_len;
  int16_t *custom_data;
};

struct ff_rumble_effect {
  uint16_t strong_magnitude;
  uint16_t weak_magnitude;
};

struct ff_effect {
  uint16_t type;
  int16_t id;
  uint16_t direction;
  struct ff_trigger trigger;
  struct ff_replay replay;

  union {
    struct ff_constant_effect constant;
    struct ff_ramp_effect ramp;
    struct ff_periodic_effect periodic;
    struct ff_condition_effect condition[2];
    struct ff_rumble_effect rumble;
  } u;
};
]])

local int = ffi.typeof("int")
local uint2 = ffi.typeof("unsigned int[2]")
local input_id = ffi.typeof("struct input_id")
local input_absinfo = ffi.typeof("struct input_absinfo")
local input_keymap_entry = ffi.typeof("struct input_keymap_entry")
local input_mask = ffi.typeof("struct input_mask")
local ff_effect = ffi.typeof("struct ff_effect")

local ioctl = require("evdev.linux.sys.ioctl")
local _IOC = ioctl._IOC
local _IOR = ioctl._IOR
local _IOW = ioctl._IOW
local _IOC_READ = ioctl._IOC_READ

local mod = {
  EV_VERSION = 0x010001,
  INPUT_KEYMAP_BY_INDEX = 0x01, -- (1 << 0)

  EVIOCGVERSION = _IOR("E", 0x01, int),
  EVIOCGID = _IOR("E", 0x02, input_id),
  EVIOCGREP = _IOR("E", 0x03, uint2),
  EVIOCSREP = _IOW("E", 0x03, uint2),

  EVIOCGKEYCODE = _IOR("E", 0x04, uint2),
  EVIOCGKEYCODE_V2 = _IOR("E", 0x04, input_keymap_entry),
  EVIOCSKEYCODE = _IOW("E", 0x04, uint2),
  EVIOCSKEYCODE_V2 = _IOW("E", 0x04, input_keymap_entry),

  EVIOCGNAME = function(len)
    return _IOC(_IOC_READ, "E", 0x06, len)
  end,
  EVIOCGPHYS = function(len)
    return _IOC(_IOC_READ, "E", 0x07, len)
  end,
  EVIOCGUNIQ = function(len)
    return _IOC(_IOC_READ, "E", 0x08, len)
  end,
  EVIOCGPROP = function(len)
    return _IOC(_IOC_READ, "E", 0x09, len)
  end,

  EVIOCGMTSLOTS = function(len)
    return _IOC(_IOC_READ, "E", 0x0a, len)
  end,

  EVIOCGKEY = function(len)
    return _IOC(_IOC_READ, "E", 0x18, len)
  end,
  EVIOCGLED = function(len)
    return _IOC(_IOC_READ, "E", 0x19, len)
  end,
  EVIOCGSND = function(len)
    return _IOC(_IOC_READ, "E", 0x1a, len)
  end,
  EVIOCGSW = function(len)
    return _IOC(_IOC_READ, "E", 0x1b, len)
  end,

  EVIOCGBIT = function(ev, len)
    return _IOC(_IOC_READ, "E", 0x20 + ev, len)
  end,
  EVIOCGABS = function(abs)
    return _IOR("E", 0x40 + abs, input_absinfo)
  end,
  EVIOCSABS = function(abs)
    return _IOW("E", 0xc0 + abs, input_absinfo)
  end,

  EVIOCSFF = _IOW("E", 0x80, ff_effect),
  EVIOCRMFF = _IOW("E", 0x81, int),
  EVIOCGEFFECTS = _IOR("E", 0x84, int),

  EVIOCGRAB = _IOW("E", 0x90, int),
  EVIOCREVOKE = _IOW("E", 0x91, int),

  EVIOCGMASK = _IOR("E", 0x92, input_mask),

  EVIOCSMASK = _IOW("E", 0x93, input_mask),

  EVIOCSCLOCKID = _IOW("E", 0xa0, int),
}

local const = require("evdev.linux.input-constant")

local event_map_by_type = {
  [-1] = { by_name = const.EV, by_code = {} },
  [const.EV.EV_SYN] = { by_name = const.SYN, by_code = {} },
  [const.EV.EV_KEY] = { by_name = const.KEY, by_code = {} },
  [const.EV.EV_REL] = { by_name = const.REL, by_code = {} },
  [const.EV.EV_ABS] = { by_name = const.ABS, by_code = {} },
  [const.EV.EV_MSC] = { by_name = const.MSC, by_code = {} },
  [const.EV.EV_SW] = { by_name = const.SW, by_code = {} },
  [const.EV.EV_LED] = { by_name = const.LED, by_code = {} },
  [const.EV.EV_SND] = { by_name = const.SND, by_code = {} },
  [const.EV.EV_REP] = { by_name = const.REP, by_code = {} },
  [const.EV.EV_FF] = { by_name = const.FF, by_code = {} },
  [const.EV.EV_PWR] = { by_name = const.PWR, by_code = {} },
  [const.EV.EV_FF_STATUS] = { by_name = const.FF_STATUS, by_code = {} },
}

for _, event_map in pairs(event_map_by_type) do
  for name, code in pairs(event_map.by_name) do
    mod[name] = code
    event_map.by_code[code] = name
  end
end

function mod.get_code_by_name(type_, name)
  return event_map_by_type[type_].by_name[name]
end

function mod.get_name_by_code(type_, code)
  return event_map_by_type[type_].by_code[code]
end

return mod
