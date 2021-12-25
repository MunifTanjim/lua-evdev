local ffi = require("ffi")

local function octal(s)
  return tonumber(s, 8)
end

ffi.cdef([[
int printf(const char *__restrict __format, ...);
int open(const char *__file, int __oflag, ...);
extern char *strerror (int __errnum);
]])

local mod = {
  O_RDONLY = octal("0000"),
  O_WRONLY = octal("0001"),
  O_RDWR = octal("0002"),
  O_NONBLOCK = octal("04000"),

  EAGAIN = 11,

  open = ffi.C.open,
  printf = ffi.C.printf,
  strerror = ffi.C.strerror,
}

return mod
