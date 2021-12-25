local ffi = require("ffi")
local bit = require("bit")
local bor = bit.bor
local lshift = bit.lshift

local _IOC_NRBITS = 8
local _IOC_TYPEBITS = 8

local _IOC_SIZEBITS = 14

local _IOC_NRSHIFT = 0
local _IOC_TYPESHIFT = (_IOC_NRSHIFT + _IOC_NRBITS)
local _IOC_SIZESHIFT = (_IOC_TYPESHIFT + _IOC_TYPEBITS)
local _IOC_DIRSHIFT = (_IOC_SIZESHIFT + _IOC_SIZEBITS)

local _IOC_NONE = 0
local _IOC_WRITE = 1
local _IOC_READ = 2

local function _IOC(dir, type_, nr, size)
  if type(type_) == "string" then
    type_ = type_:byte()
  end

  return bor(
    lshift(dir, _IOC_DIRSHIFT),
    lshift(type_, _IOC_TYPESHIFT),
    lshift(nr, _IOC_NRSHIFT),
    lshift(size, _IOC_SIZESHIFT)
  )
end

local function _IOC_TYPECHECK(t)
  return ffi.sizeof(t)
end

local function _IO(type, nr)
  return _IOC(_IOC_NONE, type, nr, 0)
end

local function _IOR(type, nr, size)
  return _IOC(_IOC_READ, type, nr, _IOC_TYPECHECK(size))
end

local function _IOW(type, nr, size)
  return _IOC(_IOC_WRITE, type, nr, _IOC_TYPECHECK(size))
end

local function _IOWR(type, nr, size)
  return _IOC(bor(_IOC_READ, _IOC_WRITE), type, nr, _IOC_TYPECHECK(size))
end

local mod = {
  _IOC_NONE = _IOC_NONE,
  _IOC_WRITE = _IOC_WRITE,
  _IOC_READ = _IOC_READ,

  _IOC = _IOC,
  _IO = _IO,
  _IOR = _IOR,
  _IOW = _IOW,
  _IOWR = _IOWR,
}

return mod
