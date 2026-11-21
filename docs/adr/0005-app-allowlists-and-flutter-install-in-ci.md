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

## License metadata exceptions for pub packages

GitHub's dependency graph reports the license of several pub packages as a lowercase id (`apache-2.0`, `bsd-3-clause`), which `actions/dependency-review-action` rejects as invalid SPDX, or reports no license at all (`fake_async`, `matcher`). The `licenses` check therefore failed on packages whose real licenses are on the allowlist. The policy stays the same: Application's `.github/workflows/licenses.yml` lists only these packages in `allow-dependencies-licenses`, after reading each LICENSE file by hand. The other three repositories have no pub dependencies and keep the file without the list.

All files were read in the local pub cache, `~/.pub-cache/hosted/pub.dev/<package>-<version>/LICENSE`, with the version resolved in `pubspec.lock`. "BSD-3-Clause" means the standard three-clause text: retain the notice in source, reproduce it in binary distributions, and no endorsement by the named authors, followed by the usual disclaimer, with nothing added. "Apache-2.0" means the full text of the Apache License, Version 2.0, January 2004.

| Package | Version | License found in LICENSE | Copyright line |
| --- | --- | --- | --- |
| clock | 1.1.3 | Apache-2.0 | (license text only) |
| cupertino_ui | 1.1.7 | BSD-3-Clause | 2013 The Flutter Authors |
| fake_async | 1.3.3 | Apache-2.0 | (license text only) |
| listen | 1.0.1 | BSD-3-Clause | 2013 The Flutter Authors |
| matcher | 0.12.20 | BSD-3-Clause | 2014, the Dart project authors |
| material_color_utilities | 0.13.0 | Apache-2.0 | (license text only) |
| material_ui | 1.11.1 | BSD-3-Clause | 2013 The Flutter Authors |
| platform | 3.2.0 | BSD-3-Clause | 2017, the Dart project authors |
| process | 5.0.6 | BSD-3-Clause | 2013, the Dart project authors |
| stack_trace | 1.12.2 | BSD-3-Clause | 2014, the Dart project authors |
| test_api | 0.7.14 | BSD-3-Clause | 2018, the Dart project authors |
| vector_math | 2.4.3 | BSD-3-Clause | 2013 The Flutter Authors |
| vm_service | 15.4.0 | BSD-3-Clause | 2015, the Dart project authors |
| web | 1.1.2 | BSD-3-Clause | 2023, the Dart project authors |
| webdriver | 3.2.0 | Apache-2.0 | (license text only) |

Why they are GPL-3.0 compatible:

- BSD-3-Clause is a permissive license the FSF lists as compatible with the GNU GPL: its conditions (keep the notice and disclaimer, no endorsement) add nothing the GPL forbids.
- Apache-2.0 is compatible with GPL-3.0 (not with GPL-2.0): the FSF lists it as compatible with version 3, whose patent and additional-terms provisions accommodate Apache's patent clause.

Both ids are already on the `allow-licenses` list of the workflow; the exception only corrects metadata.

Rules:

- Every new entry in `allow-dependencies-licenses` needs the same verification in the pull request that adds it: package, version, license found in its LICENSE file, where it was read, and why it is GPL-3.0 compatible, added to the table above. The `reviewer` agent checks it.
- The action matches these entries by name only and ignores any version (`purlsMatch` in its `src/purl.ts`), so versionless purls are used and the exception covers every version. A pull request that changes the resolved version of a listed package must read its LICENSE again and update the table.
