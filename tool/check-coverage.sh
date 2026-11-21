#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Coverage gate for the domain and data layers (docs/SPEC.md, "Quality, testing
# and CI/CD"): the lines of lib/**/domain/** and lib/**/data/** covered by the
# tests must reach the minimum. Generated files (*.g.dart, *.freezed.dart) are
# left out. A gated file that no test loads is missing from lcov.info, so it
# would silently not count: the gate fails on it instead.
# It passes when there is no domain or data file yet.
#
# Usage: tool/check-coverage.sh <lcov.info> <minimum percent>
# Run from the repository root, after `flutter test --coverage`.
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "usage: $0 <lcov.info> <minimum percent>" >&2
  exit 2
fi
lcov="$1"
minimum="$2"

if [[ ! "$minimum" =~ ^[0-9]+$ ]] || ((minimum > 100)); then
  echo "error: the minimum must be an integer from 0 to 100, got '$minimum'" >&2
  exit 2
fi

gated="$(find lib -type f -name '*.dart' \
  \( -path 'lib/domain/*' -o -path 'lib/data/*' -o -path 'lib/*/domain/*' -o -path 'lib/*/data/*' \) \
  ! -name '*.g.dart' ! -name '*.freezed.dart' | LC_ALL=C sort)"

if [[ -z "$gated" ]]; then
  echo "coverage: no domain or data files yet, nothing to gate"
  exit 0
fi

if [[ ! -f "$lcov" ]]; then
  echo "error: $lcov not found, run the tests with --coverage first" >&2
  exit 2
fi

# The first input is the list of gated files, the second is lcov.info.
# Paths in lcov.info can be absolute: they are made relative to the root.
awk -v root="$PWD/" -v minimum="$minimum" '
  FNR == NR { gated[$0] = 1; next }
  /^SF:/ {
    file = substr($0, 4)
    if (index(file, root) == 1) file = substr(file, length(root) + 1)
    current = (file in gated) ? file : ""
    if (current != "") seen[current] = 1
    next
  }
  /^DA:/ && current != "" {
    split(substr($0, 4), fields, ",")
    found++
    if (fields[2] > 0) hit++
  }
  END {
    missing = 0
    for (file in gated) {
      if (!(file in seen)) {
        print "error: " file " is not loaded by any test" > "/dev/stderr"
        missing++
      }
    }
    if (missing > 0) exit 1
    if (found == 0) {
      print "coverage: domain and data have no executable lines"
      exit 0
    }
    printf "coverage: %d of %d lines in domain and data (%.1f %%), minimum %d %%\n", hit, found, 100 * hit / found, minimum
    if (hit * 100 < minimum * found) {
      print "error: coverage of domain and data is below the minimum" > "/dev/stderr"
      exit 1
    }
  }
' <(printf '%s\n' "$gated") "$lcov"
