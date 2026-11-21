#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Pinned permission list (docs/SPEC.md, "Non-functional requirements"): fails if
# a merged Android manifest requests a permission, or Info.plist declares a
# privacy usage key, that tool/permissions.allowed does not allow.
#
# The debug manifest may hold `android` and `android-debug` entries, the
# release manifest only `android` entries. Merged manifests include what every
# plugin adds, so they come from a build (`make permissions` builds them).
#
# Usage: tool/check-permissions.sh <debug manifest> <release manifest> <Info.plist> [allowlist]
set -euo pipefail

if [[ $# -lt 3 || $# -gt 4 ]]; then
  echo "usage: $0 <debug manifest> <release manifest> <Info.plist> [allowlist]" >&2
  exit 2
fi
debug_manifest="$1"
release_manifest="$2"
info_plist="$3"
allowlist="${4:-tool/permissions.allowed}"

for file in "$debug_manifest" "$release_manifest" "$info_plist" "$allowlist"; do
  if [[ ! -f "$file" ]]; then
    echo "error: $file not found" >&2
    exit 2
  fi
done

# The names requested by <uses-permission> and <uses-permission-sdk-23>, even
# when the element spans several lines.
manifest_permissions() {
  tr '\n' ' ' <"$1" \
    | grep -oE '<uses-permission(-sdk-23)?[[:space:]][^>]*>' \
    | grep -oE 'android:name="[^"]+"' \
    | sed -e 's/^android:name="//' -e 's/"$//' \
    | LC_ALL=C sort -u || true
}

# Info.plist keys that ask the user for access to something private.
plist_privacy_keys() {
  grep -oE '<key>[^<]*UsageDescription[^<]*</key>' "$1" \
    | sed -e 's/^<key>//' -e 's#</key>$##' \
    | LC_ALL=C sort -u || true
}

# allowed <scope...>: the names allowed for any of these scopes
allowed() {
  sed -e 's/#.*//' "$allowlist" | awk -v scopes=" $* " 'NF >= 2 && index(scopes, " " $1 " ") { print $2 }' \
    | LC_ALL=C sort -u
}

failures=0
# compare <label> <found> <allowed>
compare() {
  local unexpected
  unexpected="$(LC_ALL=C comm -23 <(printf '%s\n' "$2") <(printf '%s\n' "$3") | grep -v '^$' || true)"
  if [[ -n "$unexpected" ]]; then
    echo "error: $1 declares entries not allowed by $allowlist:" >&2
    while IFS= read -r name; do echo "  $name" >&2; done <<<"$unexpected"
    failures=$((failures + 1))
  else
    echo "permissions: $1 ok ($(printf '%s\n' "$2" | grep -c . || true) entries)"
  fi
}

compare "the debug Android manifest" "$(manifest_permissions "$debug_manifest")" "$(allowed android android-debug)"
compare "the release Android manifest" "$(manifest_permissions "$release_manifest")" "$(allowed android)"
compare "Info.plist" "$(plist_privacy_keys "$info_plist")" "$(allowed ios)"

if ((failures > 0)); then
  echo "Every permission is a privacy decision: discuss it in a pull request before adding it to $allowlist." >&2
  exit 1
fi
