#!/usr/bin/env bash

set -eu

declare -r package="lua-evdev"
declare -r repo="github.com/MunifTanjim/lua-evdev"

declare version="${1:-}"
if [[ -z "${version}" ]]; then
  echo "missing version" >&2
  exit 1
fi
if [[ "${version}" != *"-"* ]]; then
  version="${version}-1"
fi


declare -r rockspec_template="${package}-dev-1.rockspec"
declare -r rockspec_file="${package}-${version}.rockspec"
declare -r rockspec="rockspecs/${package}-${version}.rockspec"

mkdir -p "$(dirname ${rockspec})"

if test -f ${rockspec}; then
  echo "already exists: ${rockspec}" >&2
  exit 1
fi

cp ${rockspec_template} ${rockspec}
script="/^version/s|\"[^\"]\\+\"|\"${version}\"|"
sed -e "${script}" -i ${rockspec}
script="/^ \\+tag = nil,/s|nil|version|"
sed -e "${script}" -i ${rockspec}

git add ${rockspec}

git commit -m "chore: release ${version}"
git tag "${version}" -m "${version}"
