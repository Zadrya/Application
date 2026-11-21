# CLAUDE.md

The Zadrya app: a harm reduction journal for iOS and Android, built with Flutter. No data ever leaves the device.

`docs/SPEC.md` is the living specification. Any change to it goes through a pull request. Decisions the spec does not cover are recorded as ADRs in `docs/adr/`.

## Commands

- `make setup`: install the git hooks (lefthook), once per clone.
- `make check`: Dart format and analyze, the dependency allowlist, lint, license metadata, script tests, unit and widget tests. Run before every commit.
- `make ci`: `check` plus the coverage gate, the permission check (builds the Android debug APK), authorship and commitlint. Run before opening a pull request.
- `make integration-test DEVICE=<id>`: the integration tests on a running emulator or simulator (`fvm flutter devices` lists the ids).
- `make build-android-debug`, `make build-ios-simulator`, `make build-ios-release`: the builds the CI jobs run (iOS only on macOS with Xcode).
- `make help` lists every target.

Flutter is pinned in `.fvmrc` and always run through fvm: `fvm flutter ...` and `fvm dart ...`, never a global `flutter`. The Makefile does this by default; CI installs the same version with `tool/install-flutter.sh` and sets `FLUTTER=flutter DART=dart`.

Local tools (Homebrew): `fvm lefthook actionlint yamllint markdownlint-cli2 zizmor reuse shellcheck`, plus Node for commitlint and Android Studio for the Android SDK.

### Running the app locally

There is no Xcode, so locally the app runs only on the Android emulator `Medium_Phone_API_37.0` (arm64):

```sh
~/Library/Android/sdk/emulator/emulator -avd Medium_Phone_API_37.0 &
fvm flutter run -d emulator-5554
make integration-test DEVICE=emulator-5554
```

## Rules

- **Authorship.** Sklyvan is the only author and committer. Never add `Co-Authored-By`, `Claude-Session:` or "Generated with Claude Code" to commits, pull requests or code. The `commit-msg` hook and the `authorship` CI check reject them.
- **Small commits.** One logical change per commit, conventional commit messages, refactors separate from features.
- **Branches.** `feature/<description>` or `fix/<description>`, one pull request per slice (ideally under 400 lines of diff), rebase merge once CI is green and the `reviewer` agent approves. Never push to `main`.
- **Language.** Everything is in English. Use commas, colons or parentheses instead of the em dash (`make lint` fails on U+2014).
- **Secrets.** Only in environment variables or GitHub Secrets, never in the repository, the chat or logs.
- **Licenses.** Original code carries the SPDX header `GPL-3.0-or-later`. Files without a comment syntax are covered by `REUSE.toml`.
- **Privacy by construction.** The app's only network connection is the optional download of the signed dataset. Dependencies are limited to those in the spec, or equivalents with no telemetry and no networking.

## Agents and skills

Subagents live in `.claude/agents/`: `app-core`, `native-ios`, `native-android`, `data-pipeline`, `ci`, `reviewer`. No pull request is merged before `reviewer` has checked it against the spec and these rules.

## Gotchas

- Layout: `lib/core/` for shared code, `lib/features/<feature>/{presentation,application,domain,data}`. The coverage gate (85 %) covers `lib/**/domain/**` and `lib/**/data/**`, and fails on any such file that no test imports.
- New direct dependencies must be added to `tool/dependencies.allowed` (spec stack and companions only), and new permissions or Info.plist privacy keys to `tool/permissions.allowed`: both are privacy decisions reviewed in the pull request. `android-debug` entries are allowed in the debug manifest only, never in release.
- Generated platform files under `android/` and `ios/` stay as `flutter create` wrote them (apart from identifiers and minimum OS versions) and are covered by `REUSE.toml`, not by SPDX headers.
- Flutter 3.50 uses Swift Package Manager, so there is no Podfile. If a plugin ever brings one back, set `platform :ios, '17.0'` in it.
- When `.fvmrc` changes, add the new version's archives and SHA-256 to `tool/flutter-sdk.lock`, or every CI job fails at "Install Flutter".
- The CI job names are `lint`, `test` (required checks), `android-build`, `ios-build`, `integration-android` and `integration-ios`.
- There is no local Xcode: iOS builds and tests run only on GitHub macOS runners (see `docs/adr/0003-ios-verified-in-ci-only.md`).
- Actions must be pinned by full commit SHA: the organization enforces it and unpinned workflows do not start.
- The shared scripts in `scripts/` and the base workflows are duplicated in all four Zadrya repositories on purpose, so that each repository can run `make ci` on its own. When you change one, change it in all four. One intentional exception: `.github/workflows/licenses.yml` in Application has an `allow-dependencies-licenses` list of pub packages whose license metadata GitHub gets wrong (ADR 0005). The other three repositories have no pub dependencies, so their copies stay without it; keep the rest of the file in sync.
- The `authorship` and `commitlint` checks run the scripts from the pull request head, so a pull request that edits `scripts/check-*.sh`, the `Makefile` or those workflows validates itself: review such diffs with extra care.
- Tool versions are pinned in `scripts/install-ci-tools.sh` and the `Makefile`, and Dependabot does not track them: bump them by hand.
- Dependency review (license allowlist in `.github/workflows/licenses.yml`) only runs in CI, so `make ci` cannot tell you that a new dependency has a license outside the list.
- Dependabot pull requests fail the `authorship` check by design: re-commit the bump as Sklyvan on a branch and close the Dependabot pull request (see `docs/adr/0002-dependabot-and-authorship.md`).
- Tests and scripts that create a git repository must first clear the variables git exports to hooks (`unset $(git rev-parse --local-env-vars)`): git exports `GIT_INDEX_FILE` to every pre-commit hook, and in a linked worktree or a submodule it also exports `GIT_DIR`, which makes every git command act on the real repository. `scripts/test-hooks-isolation.sh` guards the hook tests against this.
- Before every push: `git log --format='%an <%ae>%n%B' origin/main..HEAD`.
