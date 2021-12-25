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

  ID_BUS = 0,
  ID_VENDOR = 1,
  ID_PRODUCT = 2,
  ID_VERSION = 3,

  BUS_PCI = 0x01,
  BUS_ISAPNP = 0x02,
  BUS_USB = 0x03,
  BUS_HIL = 0x04,
  BUS_BLUETOOTH = 0x05,
  BUS_VIRTUAL = 0x06,

  BUS_ISA = 0x10,
  BUS_I8042 = 0x11,
  BUS_XTKBD = 0x12,
  BUS_RS232 = 0x13,
  BUS_GAMEPORT = 0x14,
  BUS_PARPORT = 0x15,
  BUS_AMIGA = 0x16,
  BUS_ADB = 0x17,
  BUS_I2C = 0x18,
  BUS_HOST = 0x19,
  BUS_GSC = 0x1A,
  BUS_ATARI = 0x1B,
  BUS_SPI = 0x1C,
  BUS_RMI = 0x1D,
  BUS_CEC = 0x1E,
  BUS_INTEL_ISHTP = 0x1F,

  MT_TOOL_FINGER = 0x00,
  MT_TOOL_PEN = 0x01,
  MT_TOOL_PALM = 0x02,
  MT_TOOL_DIAL = 0x0a,
  MT_TOOL_MAX = 0x0f,

  FF_STATUS_STOPPED = 0x00,
  FF_STATUS_PLAYING = 0x01,
  FF_STATUS_MAX = 0x01,

  FF_RUMBLE = 0x50,
  FF_PERIODIC = 0x51,
  FF_CONSTANT = 0x52,
  FF_SPRING = 0x53,
  FF_FRICTION = 0x54,
  FF_DAMPER = 0x55,
  FF_INERTIA = 0x56,
  FF_RAMP = 0x57,

  FF_EFFECT_MIN = 0x50, -- FF_RUMBLE
  FF_EFFECT_MAX = 0x57, -- FF_RAMP

  FF_SQUARE = 0x58,
  FF_TRIANGLE = 0x59,
  FF_SINE = 0x5a,
  FF_SAW_UP = 0x5b,
  FF_SAW_DOWN = 0x5c,
  FF_CUSTOM = 0x5d,

  FF_WAVEFORM_MIN = 0x58, -- FF_SQUARE
  FF_WAVEFORM_MAX = 0x5d, -- FF_CUSTOM

  FF_GAIN = 0x60,
  FF_AUTOCENTER = 0x61,

  FF_MAX_EFFECTS = 0x60, -- FF_GAIN

  FF_MAX = 0x7f,
  FF_CNT = (0x7f + 1), -- (FF_MAX + 1)
}

return mod
