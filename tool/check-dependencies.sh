#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Fails if pubspec.yaml declares a direct dependency (in dependencies,
# dev_dependencies or dependency_overrides) that tool/dependencies.allowed does
# not list. See docs/SPEC.md, "Quality, testing and CI/CD" (network dependency
# check) and "Architecture and stack".
#
# Usage: tool/check-dependencies.sh [pubspec.yaml] [allowlist]
set -euo pipefail

pubspec="${1:-pubspec.yaml}"
allowlist="${2:-tool/dependencies.allowed}"

for file in "$pubspec" "$allowlist"; do
  if [[ ! -f "$file" ]]; then
    echo "error: $file not found" >&2
    exit 2
  fi
done

# Package names are the keys indented one level under the three sections.
# The indentation of the first key in a section sets the level.
declared="$(awk '
  /^[^[:space:]#]/ {
    section = ($0 ~ /^(dependencies|dev_dependencies|dependency_overrides):/) ? 1 : 0
    indent = ""
    next
  }
  section && /^[[:space:]]+[A-Za-z0-9_]+:/ {
    match($0, /^[[:space:]]+/)
    current = substr($0, 1, RLENGTH)
    if (indent == "") indent = current
    if (current != indent) next
    name = substr($0, RLENGTH + 1)
    sub(/:.*/, "", name)
    print name
  }
' "$pubspec" | LC_ALL=C sort -u)"

allowed="$(sed -e 's/#.*//' -e 's/[[:space:]]//g' "$allowlist" | grep -v '^$' | LC_ALL=C sort -u)"

unexpected="$(LC_ALL=C comm -23 <(printf '%s\n' "$declared") <(printf '%s\n' "$allowed") | grep -v '^$' || true)"

if [[ -n "$unexpected" ]]; then
  echo "error: direct dependencies not in $allowlist:" >&2
  while IFS= read -r name; do echo "  $name" >&2; done <<<"$unexpected"
  echo "Only the spec's stack and its companions are allowed; adding one needs a reviewed change to the allowlist." >&2
  exit 1
fi
echo "dependencies: $(printf '%s\n' "$declared" | grep -c .) direct dependencies, all allowed"
