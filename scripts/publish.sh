#!/usr/bin/env bash

set -eu

declare -r package="lua-evdev"

declare version="${1:-}"
if [[ -z "${version}" ]]; then
  echo "missing version" >&2
  exit 1
fi
if [[ "${version}" != *"-"* ]]; then
  version="${version}-1"
fi
shift

declare -r rockspec="rockspecs/${package}-${version}.rockspec"

if ! test -f ${rockspec}; then
  echo "missing rockspec: ${rockspec}" >&2
  exit 1
fi

luarocks upload rockspecs/lua-evdev-${version}.rockspec --api-key=${LUAROCKS_API_KEY} $@
