#!/usr/bin/env sh

echo "[luacheck]"
echo

luacheck $@ .

echo
echo "[luarocks lint]"
echo

luarocks lint "lua-evdev.rockspec"
