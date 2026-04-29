#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$REPO_ROOT"

expected_count="$(
  find \
    design \
    engineering \
    game-development \
    marketing \
    paid-media \
    sales \
    product \
    project-management \
    testing \
    support \
    spatial-computing \
    specialized \
    -name "*.md" -type f \
    | sort \
    | wc -l \
    | awk '{print $1}'
)"

set +e
lint_output="$(./scripts/lint-agents.sh 2>&1)"
lint_status=$?
set -e

actual_count="$(
  printf '%s\n' "$lint_output" \
    | awk '/^Linting [0-9]+ agent files\.\.\.$/{print $2; exit}'
)"

if [[ -z "$actual_count" ]]; then
  printf 'Failed to parse linted file count from output.\n'
  printf '%s\n' "$lint_output"
  exit 1
fi

if [[ "$actual_count" != "$expected_count" ]]; then
  printf 'Default lint coverage mismatch: expected %s files, got %s.\n' "$expected_count" "$actual_count"
  exit 1
fi

if [[ "$lint_status" -ne 0 && "$lint_status" -ne 1 ]]; then
  printf 'Unexpected lint exit status: %s\n' "$lint_status"
  exit 1
fi

printf 'PASS: lint default coverage includes all agent directories (%s files).\n' "$actual_count"
