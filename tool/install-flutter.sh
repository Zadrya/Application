#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Installs the Flutter version pinned in .fvmrc on a GitHub-hosted runner, from
# the official archive, checked against the SHA-256 in tool/flutter-sdk.lock.
# Locally, use fvm instead (see CLAUDE.md).
#
# Usage: tool/install-flutter.sh <install directory>
# An existing SDK of the right version in the directory (a cache hit) is reused.
# The SDK's bin directory is added to GITHUB_PATH when it is set.
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <install directory>" >&2
  exit 2
fi
dest="$1"
base_url="https://storage.googleapis.com/flutter_infra_release/releases"

version="$(sed -n 's/^ *"flutter": *"\([^"]*\)".*/\1/p' .fvmrc)"
if [[ -z "$version" ]]; then
  echo "error: no Flutter version in .fvmrc" >&2
  exit 1
fi

case "$(uname -s)" in
  Linux) os=linux ;;
  Darwin) os=macos ;;
  *) echo "error: unsupported OS $(uname -s)" >&2; exit 1 ;;
esac
case "$(uname -m)" in
  x86_64 | amd64) arch=x64 ;;
  arm64 | aarch64) arch=arm64 ;;
  *) echo "error: unsupported architecture $(uname -m)" >&2; exit 1 ;;
esac

read -r archive sha256 < <(awk -v v="$version" -v o="$os" -v a="$arch" \
  '$1 == v && $2 == o && $3 == a { print $4, $5 }' tool/flutter-sdk.lock) || true
if [[ -z "${archive:-}" ]]; then
  echo "error: no archive for Flutter $version on $os $arch in tool/flutter-sdk.lock" >&2
  exit 1
fi

flutter="$dest/flutter/bin/flutter"
marker="$dest/installed-version"
if [[ -x "$flutter" ]] && grep -qx "$version" "$marker" 2>/dev/null; then
  echo "Flutter $version already in $dest"
else
  rm -rf "$dest"
  mkdir -p "$dest"
  file="$dest/$(basename "$archive")"
  curl --fail --silent --show-error --location --retry 3 --output "$file" "$base_url/$archive"
  actual="$(shasum -a 256 "$file" | cut -d ' ' -f 1)"
  if [[ "$actual" != "$sha256" ]]; then
    echo "error: SHA-256 mismatch for $archive: expected $sha256, got $actual" >&2
    exit 1
  fi
  case "$file" in
    *.tar.xz) tar -xJf "$file" -C "$dest" ;;
    *.zip) unzip -q "$file" -d "$dest" ;;
  esac
  rm -f "$file"
  echo "$version" > "$marker"
fi

# No usage statistics from CI either.
"$flutter" --disable-analytics >/dev/null
"$dest/flutter/bin/dart" --disable-analytics >/dev/null
"$flutter" --version

if [[ -n "${GITHUB_PATH:-}" ]]; then
  echo "$dest/flutter/bin" >> "$GITHUB_PATH"
fi
