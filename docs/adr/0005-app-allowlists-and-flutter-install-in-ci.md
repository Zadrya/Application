# 5. App permission and dependency allowlists, and Flutter in CI

- Status: accepted
- Date: 2026-11-21

## Context

The spec asks for a pinned permission list and a network dependency check in CI, and for actions pinned by SHA. Three details are not covered:

- Flutter's template declares `INTERNET` in the debug manifest, because the Flutter tool talks to a debug app over a socket. The release app must not have it (the dataset download is optional and not built yet).
- Flutter now ships its Material library as the `material_ui` package (Flutter 3.47 or later), outside the SDK, and `flutter create` depends on it. It is not in the spec's stack table.
- `subosito/flutter-action` uses `actions/cache` internally by tag, not by SHA, so the organization's pinning policy cannot be met through it.

## Decision

- `tool/permissions.allowed` has scopes. An `android-debug` entry is allowed in the merged debug manifest only; the merged release manifest is also checked and accepts only `android` entries. `INTERNET` is the only `android-debug` entry.
- `material_ui` is allowed as a framework companion: it is Flutter's own Material library, published by the Flutter team, with no networking. `cupertino_icons` from the template is removed.
- CI installs Flutter with `tool/install-flutter.sh` from the official archive, verified against a SHA-256 pinned in `tool/flutter-sdk.lock`, and caches it with `actions/cache` pinned by SHA. The script also disables Flutter and Dart analytics on the runner.

## Consequences

- Moving `INTERNET` into the main manifest (for the dataset download) fails CI until the allowlist gets an `android` entry in a reviewed pull request.
- A Flutter upgrade needs two changes in the same commit: `.fvmrc` and the archive hashes in `tool/flutter-sdk.lock`.
- Every other Flutter-team package outside the SDK still needs its own line in `tool/dependencies.allowed`.
