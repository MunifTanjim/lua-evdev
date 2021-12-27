#!/usr/bin/env bash

declare -r output_file="evdev/linux/input-constant.lua"

declare -a group_names=(
  "ID"
  "BUS"
  "MT_TOOL"
  "INPUT_PROP"
  "EV"
  "SYN"
  "KEY"
  "REL"
  "ABS"
  "MSC"
  "SW"
  "LED"
  "SND"
  "REP"
  "FF"
  "PWR"
  "FF_STATUS"
)

function generate_tables() {
  for group_name in ${group_names[@]}; do
    local filter_pattern="#define ${group_name}_"
    if [[ "${group_name}" = "KEY" ]]; then
      filter_pattern="#define \(KEY\|BTN\)_"
    fi

    local lines="$(cat ./c/libevdev/include/linux/linux/input.h ./c/libevdev/include/linux/linux/input-event-codes.h | grep "${filter_pattern}" | \
      sed 's| *+ *1)|+1)|' | \
      awk '{ print "  " $2 " = " $3 "," }')"

    local constant_names="$(printf "\"'%s'\"|" $(echo "${lines[@]}" | grep -o "^  [A-Z][^ =]\+"))"
    constant_names="${constant_names%|}"
    if [[ "${constant_names}" = "\"''\"" ]]; then
      constant_names="nil"
    fi
    echo "---@alias EVDEV_INPUT_${group_name}_CONSTANT_NAME ${constant_names}"
    echo ""

    echo "local ${group_name} = {"

    if [[ "${group_name}" = "EV" ]]; then
      echo "${lines[@]}" | grep -v "EV_VERSION"
    elif [[ "${group_name}" = "FF" ]]; then
      echo "${lines[@]}" | grep -v "FF_STATUS_"
    else
      echo "${lines[@]}"
    fi

    echo "}"
    echo ""
  done
}

generate_tables > ${output_file}

declare tables_content="$(cat ${output_file})"

function get_value() {
  local -r key="${1}"
  local value="$(echo "${tables_content}" | grep "^  ${key} = " | cut -d' ' -f5)"
  value="${value%,}"
  echo "${value}"
}

function substitute_values() {
  for group_name in ${group_names[@]} "BTN"; do
    while IFS= read -r line; do
      if [[ -z "${line}" ]]; then
        continue
      fi

      local key="$(echo ${line} | cut -d' ' -f1)"
      local value="${line#*= }"; value="${value%,}"

      local subst_key="${value}"
      if [[ "${subst_key}" = "("* ]]; then
        subst_key="$(echo ${subst_key} | grep -o '[A-Z_]\+')"
      fi
      local subst_value="$(get_value ${subst_key})"

      local new_value="$(echo "${value}" | sed "s|${subst_key}|${subst_value}|")"

      sed -e "s|${key} = ${value},|${key} = ${new_value}, -- ${value}|" -i ${output_file}
    done <<< $(echo "${tables_content}" | grep "^  ${group_name}_.\\+ = (\?${group_name}_")

  done
}

substitute_values

function generate_exports() {
  local constant_name_types="$(printf "EVDEV_INPUT_%s_CONSTANT_NAME|" "${group_names[@]}")"
  constant_name_types="${constant_name_types%|}"
  echo "---@alias EVDEV_INPUT_CONSTANT_NAME ${constant_name_types}"
  echo ""

  echo "local mod = {"
  for group_name in ${group_names[@]}; do
    echo "  ${group_name} = ${group_name},"
  done
  echo "}"
  echo ""
  echo "return mod"
}

generate_exports >> ${output_file}

stylua ${output_file}
