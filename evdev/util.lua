local ffi = require("ffi")
local bit = require("bit")

ffi.cdef([[
int open(const char *pathname, int flags, ...);
char *strerror (int errnum);
]])

---@class clib: ffi.namespace*
---@field strerror fun(errnum: number): ffi.cdata*
---@field open fun(pathname: string, flags: number, ...): number
local clib = ffi.C

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
  if str_ptr == nil then
    return ""
  end

  return ffi.string(str_ptr)
end

---@param pathname string
---@param flags number[]
---@return number fd file descriptor
function mod.open_file(pathname, flags)
  return clib.open(pathname, mod.bit_or(flags))
end

---@param errnum number
---@return string err
function mod.err_string(errnum)
  return mod.to_string(clib.strerror(errnum))
end

---@param fd_or_pathname? number|string
---@param flags? nil|number[]
---@return nil|number fd, string|nil err
function mod.to_fd(fd_or_pathname, flags)
  local fd

  if type(fd_or_pathname) == "number" then
    fd = fd_or_pathname
  elseif type(fd_or_pathname) == "string" then
    fd = mod.open_file(fd_or_pathname, flags or { enum.open_flag.RDONLY, enum.open_flag.NONBLOCK })
    if fd < 0 then
      return nil, string.format("Error: can't open %s - %s", fd_or_pathname, mod.err_string(ffi.errno()))
    end
  end

  return fd
end

return mod
