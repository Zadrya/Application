#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Tests for the check scripts in tool/. Each case runs a script inside a
# temporary copy of the files it reads and compares the exit status.
set -uo pipefail

tool_dir="$(cd "$(dirname "$0")" && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
failures=0

# expect <name> <expected status> <directory> <command...>
expect() {
  local name="$1" expected="$2" dir="$3"
  shift 3
  local status=0
  (cd "$dir" && "$@") >"$work/out" 2>&1 || status=$?
  if [[ "$status" -eq "$expected" ]]; then
    echo "ok: $name"
  else
    echo "FAIL: $name (expected $expected, got $status)"
    sed 's/^/    /' "$work/out"
    failures=$((failures + 1))
  fi
}

# fresh <name>: an empty directory for one case
fresh() {
  rm -rf "${work:?}/$1"
  mkdir -p "$work/$1"
  echo "$work/$1"
}

# --- check-coverage.sh -------------------------------------------------------

coverage="$tool_dir/check-coverage.sh"

dir="$(fresh coverage-empty)"
mkdir -p "$dir/lib/core"
touch "$dir/lib/app.dart" "$dir/lib/core/theme.dart"
expect "coverage: passes with no domain or data files" 0 "$dir" "$coverage" missing.info 85

dir="$(fresh coverage-gated)"
mkdir -p "$dir/lib/features/journal/domain" "$dir/lib/features/journal/data" "$dir/lib/features/journal/presentation"
touch "$dir/lib/features/journal/domain/dose.dart" "$dir/lib/features/journal/data/repo.dart" \
  "$dir/lib/features/journal/domain/dose.g.dart" "$dir/lib/features/journal/presentation/screen.dart"
lcov_record() { # <file> <hit lines> <missed lines>
  echo "SF:$1"
  local i
  for ((i = 1; i <= $2; i++)); do echo "DA:$i,1"; done
  for ((i = 1; i <= $3; i++)); do echo "DA:$((100 + i)),0"; done
  echo "end_of_record"
}
{
  lcov_record lib/features/journal/domain/dose.dart 9 1
  lcov_record "$dir/lib/features/journal/data/repo.dart" 8 2
  lcov_record lib/features/journal/presentation/screen.dart 0 50
  lcov_record lib/features/journal/domain/dose.g.dart 0 50
} >"$dir/high.info"
expect "coverage: 85 % in domain and data passes, other layers ignored" 0 "$dir" "$coverage" high.info 85
{
  lcov_record lib/features/journal/domain/dose.dart 9 1
  lcov_record lib/features/journal/data/repo.dart 7 3
} >"$dir/low.info"
expect "coverage: 80 % fails a minimum of 85 %" 1 "$dir" "$coverage" low.info 85
lcov_record lib/features/journal/domain/dose.dart 10 0 >"$dir/partial.info"
expect "coverage: a gated file no test loads fails" 1 "$dir" "$coverage" partial.info 85
expect "coverage: a missing lcov.info is an error" 2 "$dir" "$coverage" missing.info 85
expect "coverage: an invalid minimum is an error" 2 "$dir" "$coverage" high.info 85.5

if ((failures > 0)); then
  echo "$failures tool test(s) failed"
  exit 1
fi
echo "all tool tests passed"
