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

declare force_upload=""

if [[ "${LUAROCKS_UPLOAD_FORCE}" = "true" ]]; then
  force_upload="--force"
fi

luarocks upload --api-key=${LUAROCKS_API_KEY} ${force_upload} ${rockspec}
