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

# --- check-permissions.sh ----------------------------------------------------

permissions="$tool_dir/check-permissions.sh"

manifest() { # <file> <permission...>
  {
    echo '<manifest xmlns:android="http://schemas.android.com/apk/res/android">'
    local name
    for name in "${@:2}"; do echo "    <uses-permission android:name=\"$name\" />"; done
    echo '    <application android:label="Zadrya" />'
    echo '</manifest>'
  } >"$1"
}
plist() { # <file> <key...>
  {
    echo '<plist version="1.0"><dict>'
    local key
    for key in "${@:2}"; do echo "<key>$key</key><string>why</string>"; done
    echo '<key>CFBundleName</key><string>zadrya</string>'
    echo '</dict></plist>'
  } >"$1"
}

dir="$(fresh permissions)"
mkdir -p "$dir/tool"
cp "$tool_dir/permissions.allowed" "$dir/tool/"
manifest "$dir/debug.xml" android.permission.INTERNET io.github.zadrya.app.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION
manifest "$dir/release.xml" io.github.zadrya.app.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION
plist "$dir/Info.plist"
expect "permissions: the current allowlist passes" 0 "$dir" "$permissions" debug.xml release.xml Info.plist

manifest "$dir/camera.xml" android.permission.INTERNET android.permission.CAMERA
expect "permissions: an added Android permission fails" 1 "$dir" "$permissions" camera.xml release.xml Info.plist
manifest "$dir/release-internet.xml" android.permission.INTERNET
expect "permissions: a debug-only permission in release fails" 1 "$dir" "$permissions" debug.xml release-internet.xml Info.plist
cat >"$dir/multiline.xml" <<'XML'
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission-sdk-23
        android:name="android.permission.ACCESS_FINE_LOCATION"
        android:maxSdkVersion="34" />
</manifest>
XML
expect "permissions: a multi-line uses-permission-sdk-23 fails" 1 "$dir" "$permissions" debug.xml multiline.xml Info.plist
plist "$dir/camera.plist" NSCameraUsageDescription
expect "permissions: an added Info.plist privacy key fails" 1 "$dir" "$permissions" debug.xml release.xml camera.plist
expect "permissions: a missing manifest is an error" 2 "$dir" "$permissions" missing.xml release.xml Info.plist

# --- check-dependencies.sh ---------------------------------------------------

dependencies="$tool_dir/check-dependencies.sh"

dir="$(fresh dependencies)"
mkdir -p "$dir/tool"
cp "$tool_dir/dependencies.allowed" "$dir/tool/"
cat >"$dir/pubspec.yaml" <<'YAML'
name: zadrya
environment:
  sdk: ^3.14.0
dependencies:
  flutter:
    sdk: flutter
  go_router: ^17.0.0 # a comment
  drift:
    version: ^2.0.0
dev_dependencies:
  build_runner: ^2.0.0
flutter:
  uses-material-design: true
YAML
expect "dependencies: allowed packages pass, nested keys ignored" 0 "$dir" "$dependencies"
{ cat "$dir/pubspec.yaml"; printf 'dependencies:\n  http: ^1.0.0\n'; } >"$dir/http.yaml"
expect "dependencies: a package outside the allowlist fails" 1 "$dir" "$dependencies" http.yaml
printf 'dev_dependencies:\n  mocktail: ^1.0.0\n' >"$dir/dev.yaml"
expect "dependencies: a dev dependency outside the allowlist fails" 1 "$dir" "$dependencies" dev.yaml
printf 'dependencies:\n    flutter:\n        sdk: flutter\ndependency_overrides:\n    firebase_core: any\n' >"$dir/overrides.yaml"
expect "dependencies: an override outside the allowlist fails, any indentation" 1 "$dir" "$dependencies" overrides.yaml
expect "dependencies: a missing pubspec is an error" 2 "$dir" "$dependencies" missing.yaml

if ((failures > 0)); then
  echo "$failures tool test(s) failed"
  exit 1
fi
echo "all tool tests passed"
