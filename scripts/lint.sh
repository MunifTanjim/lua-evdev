#!/usr/bin/env sh

echo "[luacheck]"
echo

luacheck $@ .

echo
echo "[luarocks lint]"
echo

echo "Checking lua-evdev-dev-1.rockspec"
./scripts/make-rockspec.sh dev-1
luarocks lint "lua-evdev-dev-1.rockspec"
