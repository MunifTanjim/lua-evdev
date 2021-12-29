#!/usr/bin/env sh

echo "[luacheck]"
echo

luacheck $@ .

echo
echo "[luarocks lint]"
echo

for rockspec in rockspecs/*; do
  echo luarocks lint "${rockspec}"
  luarocks lint "${rockspec}"
done
