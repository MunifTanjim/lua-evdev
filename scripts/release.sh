#!/usr/bin/env bash

set -eu

declare -r package="lua-evdev"

declare version="${1:-}"
if [[ -z "${version}" ]]; then
  echo "missing version" >&2
  exit 1
fi

declare rockspec_revision="1"
if [[ "${version}" = *"-"* ]]; then
  rockspec_revision="${version##*-}"
  version="${version%%-*}"
fi

function prepare_luarocks_package() {
  local -r ver="${version}"
  local -r rev="${rockspec_revision}"

  local -r dev_rockspec="rockspecs/${package}-dev-1.rockspec"
  local -r rockspec="rockspecs/${package}-${ver}-${rev}.rockspec"

  if test -f ${rockspec}; then
    echo "already exists: ${rockspec}" >&2
    exit 1
  fi

  cp ${dev_rockspec} ${rockspec}

  local script
  script="/^version/s|\"[^\"]\\+\"|\"${ver}-${rev}\"|"
  sed -e "${script}" -i ${rockspec}
  script="/^ \\+tag = nil,/s|nil|version|"
  sed -e "${script}" -i ${rockspec}

  luarocks make --no-install "${rockspec}"

  git add "${rockspec}"
}

function prepare_lit_package() {
  local -r ver="${version}"

  local -r metadata="evdev/package.lua"

  local script
  script="/^ \+version/s|\"[^\"]\\+\"|\"${ver}\"|"
  sed -e "${script}" -i "${metadata}"

  git add "${metadata}"
}

prepare_luarocks_package
prepare_lit_package

declare -r tag="${version}-${rockspec_revision}"

git commit -m "chore: release ${tag}"
git tag "${tag}" -m "${tag}"
