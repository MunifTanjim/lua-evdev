local ffi = require("ffi")

ffi.cdef([[
struct libevdev;

enum libevdev_read_flag {
 LIBEVDEV_READ_FLAG_SYNC  = 1,
 LIBEVDEV_READ_FLAG_NORMAL = 2,
 LIBEVDEV_READ_FLAG_FORCE_SYNC = 4,
 LIBEVDEV_READ_FLAG_BLOCKING = 8
};

struct libevdev* libevdev_new(void);
int libevdev_new_from_fd(int fd, struct libevdev **dev);
void libevdev_free(struct libevdev *dev);

enum libevdev_log_priority {
 LIBEVDEV_LOG_ERROR = 10,
 LIBEVDEV_LOG_INFO = 20,
 LIBEVDEV_LOG_DEBUG = 30
};

typedef void (*libevdev_log_func_t)(enum libevdev_log_priority priority,
    void *data,
    const char *file, int line,
    const char *func,
    const char *format, va_list args);
void libevdev_set_log_function(libevdev_log_func_t logfunc, void *data);
void libevdev_set_log_priority(enum libevdev_log_priority priority);
enum libevdev_log_priority libevdev_get_log_priority(void);
typedef void (*libevdev_device_log_func_t)(const struct libevdev *dev,
    enum libevdev_log_priority priority,
    void *data,
    const char *file, int line,
    const char *func,
    const char *format, va_list args);
void libevdev_set_device_log_function(struct libevdev *dev,
          libevdev_device_log_func_t logfunc,
          enum libevdev_log_priority priority,
          void *data);

enum libevdev_grab_mode {
 LIBEVDEV_GRAB = 3,
 LIBEVDEV_UNGRAB = 4
};

int libevdev_grab(struct libevdev *dev, enum libevdev_grab_mode grab);
int libevdev_set_fd(struct libevdev* dev, int fd);
int libevdev_change_fd(struct libevdev* dev, int fd);
int libevdev_get_fd(const struct libevdev* dev);

enum libevdev_read_status {
 LIBEVDEV_READ_STATUS_SUCCESS = 0,
 LIBEVDEV_READ_STATUS_SYNC = 1
};

int libevdev_next_event(struct libevdev *dev, unsigned int flags, struct input_event *ev);
int libevdev_has_event_pending(struct libevdev *dev);
const char* libevdev_get_name(const struct libevdev *dev);
void libevdev_set_name(struct libevdev *dev, const char *name);
const char * libevdev_get_phys(const struct libevdev *dev);
void libevdev_set_phys(struct libevdev *dev, const char *phys);
const char * libevdev_get_uniq(const struct libevdev *dev);
void libevdev_set_uniq(struct libevdev *dev, const char *uniq);
int libevdev_get_id_product(const struct libevdev *dev);
void libevdev_set_id_product(struct libevdev *dev, int product_id);
int libevdev_get_id_vendor(const struct libevdev *dev);
void libevdev_set_id_vendor(struct libevdev *dev, int vendor_id);
int libevdev_get_id_bustype(const struct libevdev *dev);
void libevdev_set_id_bustype(struct libevdev *dev, int bustype);
int libevdev_get_id_version(const struct libevdev *dev);
void libevdev_set_id_version(struct libevdev *dev, int version);
int libevdev_get_driver_version(const struct libevdev *dev);
int libevdev_has_property(const struct libevdev *dev, unsigned int prop);
int libevdev_enable_property(struct libevdev *dev, unsigned int prop);
int libevdev_disable_property(struct libevdev *dev, unsigned int prop);
int libevdev_has_event_type(const struct libevdev *dev, unsigned int type);
int libevdev_has_event_code(const struct libevdev *dev, unsigned int type, unsigned int code);
int libevdev_get_abs_minimum(const struct libevdev *dev, unsigned int code);
int libevdev_get_abs_maximum(const struct libevdev *dev, unsigned int code);
int libevdev_get_abs_fuzz(const struct libevdev *dev, unsigned int code);
int libevdev_get_abs_flat(const struct libevdev *dev, unsigned int code);
int libevdev_get_abs_resolution(const struct libevdev *dev, unsigned int code);
const struct input_absinfo* libevdev_get_abs_info(const struct libevdev *dev, unsigned int code);
int libevdev_get_event_value(const struct libevdev *dev, unsigned int type, unsigned int code);
int libevdev_set_event_value(struct libevdev *dev, unsigned int type, unsigned int code, int value);
int libevdev_fetch_event_value(const struct libevdev *dev, unsigned int type, unsigned int code, int *value);
int libevdev_get_slot_value(const struct libevdev *dev, unsigned int slot, unsigned int code);
int libevdev_set_slot_value(struct libevdev *dev, unsigned int slot, unsigned int code, int value);
int libevdev_fetch_slot_value(const struct libevdev *dev, unsigned int slot, unsigned int code, int *value);
int libevdev_get_num_slots(const struct libevdev *dev);
int libevdev_get_current_slot(const struct libevdev *dev);
void libevdev_set_abs_minimum(struct libevdev *dev, unsigned int code, int val);
void libevdev_set_abs_maximum(struct libevdev *dev, unsigned int code, int val);
void libevdev_set_abs_fuzz(struct libevdev *dev, unsigned int code, int val);
void libevdev_set_abs_flat(struct libevdev *dev, unsigned int code, int val);
void libevdev_set_abs_resolution(struct libevdev *dev, unsigned int code, int val);
void libevdev_set_abs_info(struct libevdev *dev, unsigned int code, const struct input_absinfo *abs);
int libevdev_enable_event_type(struct libevdev *dev, unsigned int type);
int libevdev_disable_event_type(struct libevdev *dev, unsigned int type);
int libevdev_enable_event_code(struct libevdev *dev, unsigned int type, unsigned int code, const void *data);
int libevdev_disable_event_code(struct libevdev *dev, unsigned int type, unsigned int code);
int libevdev_kernel_set_abs_info(struct libevdev *dev, unsigned int code, const struct input_absinfo *abs);

enum libevdev_led_value {
 LIBEVDEV_LED_ON = 3,
 LIBEVDEV_LED_OFF = 4
};

int libevdev_kernel_set_led_value(struct libevdev *dev, unsigned int code, enum libevdev_led_value value);
int libevdev_kernel_set_led_values(struct libevdev *dev, ...);
int libevdev_set_clock_id(struct libevdev *dev, int clockid);
int libevdev_event_is_type(const struct input_event *ev, unsigned int type);
int libevdev_event_is_code(const struct input_event *ev, unsigned int type, unsigned int code);
const char * libevdev_event_type_get_name(unsigned int type);
const char * libevdev_event_code_get_name(unsigned int type, unsigned int code);
const char* libevdev_property_get_name(unsigned int prop);
int libevdev_event_type_get_max(unsigned int type);
int libevdev_event_type_from_name(const char *name);
int libevdev_event_type_from_name_n(const char *name, size_t len);
int libevdev_event_code_from_name(unsigned int type, const char *name);
int libevdev_event_code_from_name_n(unsigned int type, const char *name, size_t len);
int libevdev_event_value_from_name(unsigned int type, unsigned int code, const char *name);
int libevdev_event_type_from_code_name(const char *name);
int libevdev_event_type_from_code_name_n(const char *name, size_t len);
int libevdev_event_code_from_code_name(const char *name);
int libevdev_event_code_from_code_name_n(const char *name, size_t len);
int libevdev_event_value_from_name_n(unsigned int type, unsigned int code, const char *name, size_t len);
int libevdev_property_from_name(const char *name);
int libevdev_property_from_name_n(const char *name, size_t len);
int libevdev_get_repeat(const struct libevdev *dev, int *delay, int *period);
]])

---@diagnostic disable: undefined-field

local enum = {
  ---@type number
  LIBEVDEV_READ_FLAG_SYNC = ffi.C.LIBEVDEV_READ_FLAG_SYNC,
  ---@type number
  LIBEVDEV_READ_FLAG_NORMAL = ffi.C.LIBEVDEV_READ_FLAG_NORMAL,
  ---@type number
  LIBEVDEV_READ_FLAG_FORCE_SYNC = ffi.C.LIBEVDEV_READ_FLAG_FORCE_SYNC,
  ---@type number
  LIBEVDEV_READ_FLAG_BLOCKING = ffi.C.LIBEVDEV_READ_FLAG_BLOCKING,

  ---@type number
  LIBEVDEV_LOG_ERROR = ffi.C.LIBEVDEV_LOG_ERROR,
  ---@type number
  LIBEVDEV_LOG_INFO = ffi.C.LIBEVDEV_LOG_INFO,
  ---@type number
  LIBEVDEV_LOG_DEBUG = ffi.C.LIBEVDEV_LOG_DEBUG,

  ---@type number
  LIBEVDEV_GRAB = ffi.C.LIBEVDEV_GRAB,
  ---@type number
  LIBEVDEV_UNGRAB = ffi.C.LIBEVDEV_UNGRAB,

  ---@type number
  LIBEVDEV_READ_STATUS_SUCCESS = ffi.C.LIBEVDEV_READ_STATUS_SUCCESS,
  ---@type number
  LIBEVDEV_READ_STATUS_SYNC = ffi.C.LIBEVDEV_READ_STATUS_SYNC,

  ---@type number
  LIBEVDEV_LED_ON = ffi.C.LIBEVDEV_LED_ON,
  ---@type number
  LIBEVDEV_LED_OFF = ffi.C.LIBEVDEV_LED_OFF,
}

---@diagnostic enable: undefined-field

enum.libevdev_read_flag = {
  SYNC = enum.LIBEVDEV_READ_FLAG_SYNC,
  NORMAL = enum.LIBEVDEV_READ_FLAG_NORMAL,
  FORCE_SYNC = enum.LIBEVDEV_READ_FLAG_FORCE_SYNC,
  BLOCKING = enum.LIBEVDEV_READ_FLAG_BLOCKING,
}

enum.libevdev_log_priority = {
  ERROR = enum.LIBEVDEV_LOG_ERROR,
  INFO = enum.LIBEVDEV_LOG_INFO,
  DEBUG = enum.LIBEVDEV_LOG_DEBUG,
}

enum.libevdev_grab_mode = {
  GRAB = enum.LIBEVDEV_GRAB,
  UNGRAB = enum.LIBEVDEV_UNGRAB,
}

enum.libevdev_read_status = {
  SUCCESS = enum.LIBEVDEV_READ_STATUS_SUCCESS,
  SYNC = enum.LIBEVDEV_READ_STATUS_SYNC,
}

enum.libevdev_led_value = {
  ON = enum.LIBEVDEV_LED_ON,
  OFF = enum.LIBEVDEV_LED_OFF,
}

--luacheck: push no max line length

---@class libevdev: ffi.namespace*
---@field libevdev_new                         fun(): ffi.cdata*
---@field libevdev_new_from_fd                 fun(fd: number, dev: ffi.cdata*): number
---@field libevdev_free                        fun(dev: ffi.cdata*): nil
---@field libevdev_set_log_function            fun(logfunc: ffi.cdata*, data: ffi.cdata*): nil
---@field libevdev_set_log_priority            fun(priority: number): nil
---@field libevdev_get_log_priority            fun(): number
---@field libevdev_set_device_log_function     fun(dev: ffi.cdata*, logfunc: ffi.cdata*, priority: number, data: ffi.cdata*): nil
---@field libevdev_grab                        fun(dev: ffi.cdata*, grab: number): number
---@field libevdev_set_fd                      fun(dev: ffi.cdata*, fd: number): number
---@field libevdev_change_fd                   fun(dev: ffi.cdata*, fd: number): number
---@field libevdev_get_fd                      fun(dev: ffi.cdata*): number
---@field libevdev_next_event                  fun(dev: ffi.cdata*, flags: number, ev: ffi.cdata*): number
---@field libevdev_has_event_pending           fun(dev: ffi.cdata*): number
---@field libevdev_get_name                    fun(dev: ffi.cdata*): ffi.cdata*
---@field libevdev_set_name                    fun(dev: ffi.cdata*, name: ffi.cdata*): nil
---@field libevdev_get_phys                    fun(dev: ffi.cdata*): ffi.cdata*
---@field libevdev_set_phys                    fun(dev: ffi.cdata*, phys: ffi.cdata*): nil
---@field libevdev_get_uniq                    fun(dev: ffi.cdata*): ffi.cdata*
---@field libevdev_set_uniq                    fun(dev: ffi.cdata*, uniq: ffi.cdata*): nil
---@field libevdev_get_id_product              fun(dev: ffi.cdata*): number
---@field libevdev_set_id_product              fun(dev: ffi.cdata*, product_id: number): nil
---@field libevdev_get_id_vendor               fun(dev: ffi.cdata*): number
---@field libevdev_set_id_vendor               fun(dev: ffi.cdata*, vendor_id: number): nil
---@field libevdev_get_id_bustype              fun(dev: ffi.cdata*): number
---@field libevdev_set_id_bustype              fun(dev: ffi.cdata*, bustype: number): nil
---@field libevdev_get_id_version              fun(dev: ffi.cdata*): number
---@field libevdev_set_id_version              fun(dev: ffi.cdata*, version: number): nil
---@field libevdev_get_driver_version          fun(dev: ffi.cdata*): number
---@field libevdev_has_property                fun(dev: ffi.cdata*, prop: number): number
---@field libevdev_enable_property             fun(dev: ffi.cdata*, prop: number): number
---@field libevdev_disable_property            fun(dev: ffi.cdata*, prop: number): number
---@field libevdev_has_event_type              fun(dev: ffi.cdata*, type: number): number
---@field libevdev_has_event_code              fun(dev: ffi.cdata*, type: number, code: number): number
---@field libevdev_get_abs_minimum             fun(dev: ffi.cdata*, code: number): number
---@field libevdev_get_abs_maximum             fun(dev: ffi.cdata*, code: number): number
---@field libevdev_get_abs_fuzz                fun(dev: ffi.cdata*, code: number): number
---@field libevdev_get_abs_flat                fun(dev: ffi.cdata*, code: number): number
---@field libevdev_get_abs_resolution          fun(dev: ffi.cdata*, code: number): number
---@field libevdev_get_abs_info                fun(dev: ffi.cdata*, code: number): ffi.cdata*
---@field libevdev_get_event_value             fun(dev: ffi.cdata*, type: number, code: number): number
---@field libevdev_set_event_value             fun(dev: ffi.cdata*, type: number, code: number, value: number): number
---@field libevdev_fetch_event_value           fun(dev: ffi.cdata*, type: number, code: number, value: ffi.cdata*): number
---@field libevdev_get_slot_value              fun(dev: ffi.cdata*, slot: number, code: number): number
---@field libevdev_set_slot_value              fun(dev: ffi.cdata*, slot: number, code: number, value: number): number
---@field libevdev_fetch_slot_value            fun(dev: ffi.cdata*, slot: number, code: number, value: ffi.cdata*): number
---@field libevdev_get_num_slots               fun(dev: ffi.cdata*): number
---@field libevdev_get_current_slot            fun(dev: ffi.cdata*): number
---@field libevdev_set_abs_minimum             fun(dev: ffi.cdata*, code: number, val: number): nil
---@field libevdev_set_abs_maximum             fun(dev: ffi.cdata*, code: number, val: number): nil
---@field libevdev_set_abs_fuzz                fun(dev: ffi.cdata*, code: number, val: number): nil
---@field libevdev_set_abs_flat                fun(dev: ffi.cdata*, code: number, val: number): nil
---@field libevdev_set_abs_resolution          fun(dev: ffi.cdata*, code: number, val: number): nil
---@field libevdev_set_abs_info                fun(dev: ffi.cdata*, code: number, abs: ffi.cdata*): nil
---@field libevdev_enable_event_type           fun(dev: ffi.cdata*, type: number): number
---@field libevdev_disable_event_type          fun(dev: ffi.cdata*, type: number): number
---@field libevdev_enable_event_code           fun(dev: ffi.cdata*, type: number, code: number, data: ffi.cdata*): number
---@field libevdev_disable_event_code          fun(dev: ffi.cdata*, type: number, code: number): number
---@field libevdev_kernel_set_abs_info         fun(dev: ffi.cdata*, code: number, abs: ffi.cdata*): number
---@field libevdev_kernel_set_led_value        fun(dev: ffi.cdata*, code: number, value: number): number
---@field libevdev_kernel_set_led_values       fun(dev: ffi.cdata*, code: number, value: number, ...): number
---@field libevdev_set_clock_id                fun(dev: ffi.cdata*, clockid: number): number
---@field libevdev_event_is_type               fun(ev: ffi.cdata*, type: number): number
---@field libevdev_event_is_code               fun(ev: ffi.cdata*, type: number, code: number): number
---@field libevdev_event_type_get_name         fun(type: number): ffi.cdata*
---@field libevdev_event_code_get_name         fun(type: number, code: number): ffi.cdata*
---@field libevdev_property_get_name           fun(prop: number): ffi.cdata*
---@field libevdev_event_type_get_max          fun(type: number): number
---@field libevdev_event_type_from_name        fun(name: ffi.cdata*): number
---@field libevdev_event_type_from_name_n      fun(name: ffi.cdata*, len: number): number
---@field libevdev_event_code_from_name        fun(type: number, name: ffi.cdata*): number
---@field libevdev_event_code_from_name_n      fun(type: number, name: ffi.cdata*, len: number): number
---@field libevdev_event_value_from_name       fun(type: number, code: number, name: ffi.cdata*): number
---@field libevdev_event_type_from_code_name   fun(name: ffi.cdata*): number
---@field libevdev_event_type_from_code_name_n fun(name: ffi.cdata*, len: number): number
---@field libevdev_event_code_from_code_name   fun(name: ffi.cdata*): number
---@field libevdev_event_code_from_code_name_n fun(name: ffi.cdata*, len: number): number
---@field libevdev_event_value_from_name_n     fun(type: number, code: number, name: ffi.cdata*, len: number): number
---@field libevdev_property_from_name          fun(name: ffi.cdata*): number
---@field libevdev_property_from_name_n        fun(name: ffi.cdata*, len: number): number
---@field libevdev_get_repeat                  fun(dev: ffi.cdata*, delay: ffi.cdata*, period: ffi.cdata*): number
local libevdev = ffi.load("evdev")

--luacheck: pop

local ctype = {
  libevdev_ptr = ffi.typeof("struct libevdev *[1]"),
}

local mod = {
  ctype = ctype,
  enum = enum,
  lib = libevdev,
}

return mod
