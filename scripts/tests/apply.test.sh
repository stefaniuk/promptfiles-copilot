#!/bin/bash
# shellcheck disable=SC2329

set -euo pipefail

# Test suite for the apply command.
#
# Usage:
#   $ ./apply.test.sh
#
# Arguments (provided as environment variables):
#   VERBOSE=true  # Show all the executed commands, default is 'false'

# ==============================================================================

TEMP_DIR=""

function main() {

  cd "$(git rev-parse --show-toplevel)"

  test-apply-suite-setup
  local tests=( \
    test-make-apply-normalises-escaped-space-destination \
  )
  local status=0
  for test in "${tests[@]}"; do
    {
      echo -n "$test"
      # shellcheck disable=SC2015
      $test && echo " PASS" || { echo " FAIL"; ((status++)); }
    }
  done
  echo "Total: ${#tests[@]}, Passed: $(( ${#tests[@]} - status )), Failed: $status"
  test-apply-suite-teardown
  [ $status -gt 0 ] && return 1 || return 0
}

# ==============================================================================

function test-apply-suite-setup() {

  TEMP_DIR=$(mktemp -d)

  return 0
}

function test-apply-suite-teardown() {

  if [[ -n "${TEMP_DIR}" ]] && [[ -d "${TEMP_DIR}" ]]; then
    rm -rf "${TEMP_DIR}"
  fi

  return 0
}

# ==============================================================================

function test-make-apply-normalises-escaped-space-destination() {

  # Arrange
  local root_dir="${TEMP_DIR}/workspace"
  local expected_destination="${root_dir}/Mobile Documents/iCloud~md~obsidian/Documents"
  local escaped_destination="${root_dir}/Mobile\\ Documents/iCloud~md~obsidian/Documents"

  mkdir -p "${root_dir}"

  # Act
  make apply dest="${escaped_destination}" ai=copilot > /dev/null 2>&1 || return 1

  # Assert
  [[ -f "${expected_destination}/project.code-workspace" ]] || return 1
  [[ -d "${expected_destination}/.github/agents" ]] || return 1
  [[ ! -d "${root_dir}/Mobile\\ Documents" ]] || return 1

  return 0
}

# ==============================================================================

function is-arg-true() {

  if [[ "$1" =~ ^(true|yes|y|on|1|TRUE|YES|Y|ON)$ ]]; then
    return 0
  else
    return 1
  fi
}

# ==============================================================================

is-arg-true "${VERBOSE:-false}" && set -x

main "$@"

exit 0
