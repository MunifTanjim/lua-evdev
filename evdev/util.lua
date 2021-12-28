local ffi = require("ffi")
local bit = require("bit")

ffi.cdef([[
int open(const char *pathname, int flags, ...);
char *strerror (int errnum);
]])

---@diagnostic disable: undefined-field

---@type fun(errnum: number): ffi.cdata*
local strerror = ffi.C.strerror
---@type fun(pathname: string, flags: number, ...): number
local open = ffi.C.open

---@diagnostic enable: undefined-field

if not table.unpack then
  table.unpack = unpack
end

local function octal(s)
  return tonumber(s, 8)
end

local enum = {
  O_RDONLY = octal(00000000),
  O_WRONLY = octal(00000001),
  O_RDWR = octal(00000002),
  O_NONBLOCK = octal(00004000),
  O_CLOEXEC = octal(02000000),
}

enum.open_flag = {
  RDONLY = enum.O_RDONLY,
  WRONLY = enum.O_WRONLY,
  RDWR = enum.O_RDWR,
  NONBLOCK = enum.O_NONBLOCK,
  CLOEXEC = enum.O_CLOEXEC,
}

local mod = {
  enum = enum,
}

---@param bits number|number[]
---@return number
function mod.bit_or(bits)
  return type(bits) == "number" and bits or bit.bor(table.unpack(bits))
end

---@param str_ptr ffi.cdata* pointer to string
---@return string
function mod.to_string(str_ptr)
  return str_ptr and ffi.string(str_ptr) or ""
end

---@param pathname string
---@param flags number[]
---@return number fd file descriptor
function mod.open_file(pathname, flags)
  return open(pathname, mod.bit_or(flags))
end

---@param errnum number
---@return string err
function mod.err_string(errnum)
  return mod.to_string(strerror(errnum))
end

return mod
