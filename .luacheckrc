cache = ".luacheckcache"
-- https://luacheck.readthedocs.io/en/stable/warnings.html
ignore = {
  "211/_.*",
  "212/_.*",
  "213/_.*",
}
include_files = { "*.luacheckrc", "evdev/**/*.lua" }
std = "lua51+luajit"
globals = { "table.unpack" }

-- vim: set filetype=lua :
