# Zadrya: Requirements and Use Cases

Nov 16, 2026 · @Joan

## Vision and principles

Zadrya is a harm reduction journal for iOS and Android: free, open source (GPL-3.0) and it never sends data off the device. It takes PsychonautWiki Journal (v11.11, the last GPL release) as its functional reference and improves on it in privacy, languages and design.

**Target user**: an adult who uses psychoactive substances and wants to log ingestions, understand durations and avoid dangerous combinations and redosing. Languages: English and Spanish.

**Principles**

1. **Absolute privacy**: no accounts, no server, no telemetry, no third-party SDKs. The only network connection is the optional download of the signed dataset.
2. **Free forever**: no purchases, no ads, no locked features.
3. **Non-judgmental harm reduction**: inform, never lecture. Clear warnings, never alarmist.
4. **Discretion**: neutral name and icon. The user decides what is visible outside the app.
5. **Smoothness**: 120 Hz in curves, lists and calendar; fast cold start.
6. **Users own their data**: everything can be logged, exported and deleted instantly.
7. **Offline first**: the app is fully functional without a connection.

## Identity

The app and the GitHub organization are called **Zadrya**, inspired by Zarya (Zorya), the dawn in Slavic mythology: the guardian of the passage from night to day. The organization already exists at `github.com/Zadrya`; the name still needs an EUIPO TMview check and reservation in both stores.

| Item | Value |
| --- | --- |
| GitHub organization | `Zadrya` (Free plan; owner: `Sklyvan`) |
| App repository | `Zadrya/Application` |
| Data repository | `Zadrya/Data` |
| Website (GitHub Pages) | `Zadrya/zadrya.github.io` (name fixed by GitHub) |
| Community files | `Zadrya/.github` (profile, SECURITY.md, CONTRIBUTING.md, CODE\_OF\_CONDUCT.md, templates) |
| Bundle ID / applicationId | `io.github.zadrya.app` |
| Dart package | `zadrya` |
| Data manifest | `https://github.com/Zadrya/Data/releases/latest/download/manifest.json` |
| License | GPL-3.0-or-later (code); CC BY-SA 4.0 (data derived from PsychonautWiki) |

**Visual identity: direction A, "Night"**

- **Dark palette (primary)**: background `#0B1026`, surfaces `#141B3A` and `#1C2550`, text `#ECEAF4`, secondary text `#9AA0BF`, gold accent `#D4A84A`, blue accent `#4C7DFF`.
- **Light palette**: background `#F4EEDF`, ink `#1A1A2E`, ochre accent `#A8742A`.
- **Typography**: Inter (OFL) with tabular figures for doses and times.
- **Icon**: an effect curve (rise, plateau, fall) acting as a horizon, with a gold dot peeking above it like the sun at dawn, on a night background. It must read as a silhouette in the iOS 26 dark, clear and tinted variants and in the Android monochrome layer.
- **Alternate icons**: two or three variants of the same motif (different color or stroke), selectable in Settings. Never imitate other apps.
- **Substance colors**: a palette of 12 to 16 luminous, colorblind-safe hues, with solid or dashed stroke as a second cue.

## MVP functional scope

The MVP includes every feature of PsychonautWiki Journal v11.11 plus calendar, reminders, alerts, widgets, Live Activities, encryption, full wipe and import from the original app. Navigation uses five tabs: Journal, Substances, Stats, Guides and Settings.

**Journal**

- List view (experiences, newest first, favorites pinned on top) and calendar view, switchable.
- Search by title, notes, substance and location.
- Floating "+" button to log an ingestion from any Journal view.

**Logging an ingestion**

- Substance (catalog, recents, custom), route of administration, dose or "unknown", unit, "estimate" flag with optional deviation, time or time range (start and end), stomach fullness, consumer (me or a named companion), notes, substance color, custom unit.
- Dose ranges for the chosen route visible while typing the dose, with the resulting category (threshold, light, common, strong, heavy).
- Automatic assignment to the ongoing experience (ingestion within a configurable window, 12 h by default, since the last ingestion) or creation of a new one; the user can change it.

**Experiences**

- Title, location (free text, no GPS), notes, favorite.
- Shulgin ratings (scale − to ++++) with time.
- Timed notes with color, shown as markers on the timeline.
- Summary of total doses per substance within the experience.

**Timeline**

- Intensity curve per ingestion built from the onset, comeup, peak and offset phases for the route; height proportional to the dose relative to the common range.
- "Now" line, clock time or relative time mode, shading for duration uncertainty, ingestions with a time range drawn as an infusion.
- Drag to see the percentage of peak and the equivalent dose at that moment.
- Preview of a planned redose with a dashed stroke.
- If duration data is missing, only an ingestion marker is drawn and the user is told why.

**Interactions**

- On logging, substances within the interaction window (by default, ingestions whose effects or after effects are still active, or the last 24 h) are checked against the dataset's dangerous, unsafe and uncertain fields, including chemical and psychoactive classes.
- Warning screen that requires explicit confirmation for "dangerous".
- Manual interaction checker for several substances.

**Substances**

- Full PsychonautWiki catalog always visible, with accent- and typo-tolerant search and a class filter.
- Substance page: summary, doses per route, durations per route (drawn), tolerance (full, half, zero), cross-tolerance, interactions grouped by severity, safer use tips, link to the PsychonautWiki article and attribution.
- Custom substances (name, units, description) and custom units per substance.

**Tolerance**: estimated tolerance chart based on history, per substance and per cross-tolerance class.

**Stats**: frequency and total doses per substance over 30 days, 26 weeks, 12 months and calendar year, with a bar chart; per-substance history with time between doses; consumer filter.

**Calendar**: monthly grid with dots per substance (up to 3 plus "+N"), intensity mode, substance and consumer filters, day detail in a bottom sheet, "Today" button, week start by locale.

**Reminders and alerts** (all off by default)

- Reminders: hydration during an active experience, and a supplement routine at a configurable time.
- Safe redose time alert (when the curve enters offset).
- Frequency alert: configurable threshold of uses per substance within a window of days.
- All through local notifications; no push server.

**Widgets and Live Activities**

- Active experience widget (mini curve and time since the last ingestion) on iOS (WidgetKit) and Android (Glance).
- Live Activity on iOS (Lock Screen and Dynamic Island) during an active experience; on Android, an ongoing notification.
- Substance names visible by default; a Settings toggle hides them in widgets, Live Activities and notifications.

**Guides**: translated harm reduction content (researching a substance, drug checking and reagents, volumetric dosing, routes of administration, set and setting, emergency signs and when to seek help).

**Settings**: theme, language, alternate icons, Lock Screen visibility, reminders and alerts, data updates, custom units, export, import, wipe everything, licenses and attributions, legal notice.

## Local data model

One encrypted SQLite database (Drift + SQLite3MultipleCiphers) with the original app's tables plus Zadrya's new ones. The substance catalog does not live in the database: it is loaded from the active signed JSON.

**Conventions**: UUIDv7 identifiers as text; instants in UTC (milliseconds) alongside the IANA zone identifier at logging time; hard deletes (there is no sync that would need soft deletes); versioned and tested migrations; foreign keys enabled with `ON DELETE CASCADE` towards the experience.

| Table | Key fields | Relations and indexes |
| --- | --- | --- |
| `experience` | id, title, location\_text, notes, is\_favorite, created\_at, sort\_at | 1:N ingestion, rating, timed\_note; index on sort\_at |
| `ingestion` | id, experience\_id, substance\_ref (canonical name or custom id), route, dose (nullable), units, is\_estimate, estimate\_deviation, start\_at, end\_at, tz, stomach, consumer\_name (null = me), notes, custom\_unit\_id | N:1 experience; indexes on start\_at, (substance\_ref, start\_at), consumer\_name |
| `substance_color` | substance\_ref (PK), color\_argb | stable color per substance |
| `custom_substance` | id, name, units, description | referenced by substance\_ref |
| `custom_unit` | id, substance\_ref, name, unit, dose\_per\_unit, is\_estimate, archived, created\_at | 1:N ingestion |
| `shulgin_rating` | id, experience\_id, at, option | N:1 experience |
| `timed_note` | id, experience\_id, at, text, color\_argb, show\_in\_timeline | N:1 experience |
| `reminder` | id, kind (hydration, supplement, redose, frequency), enabled, schedule (JSON), params (JSON) | standalone |
| `setting` | key (PK), value (JSON) | user preferences |
| `dataset_state` | active\_version, schema\_version, source (bundled or downloaded), sha256, installed\_at, last\_check\_at | single row |

**Outside the database**: the 256-bit encryption key lives in the Keychain (iOS, `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`, never synced to iCloud) and in the Android Keystore via flutter\_secure\_storage; the downloaded dataset lives in the app support directory with its signature.

**Backup exclusion**: the database and the key are excluded from iCloud Backup and Android Auto Backup (`allowBackup=false`, `dataExtractionRules`), because without sync a cloud copy would contradict the privacy promise. The only copy is the manual export.

## Use cases

Fourteen use cases cover the MVP. Each lists its main flow and the edge cases Claude Code must implement and test.

**UC-01 First launch**

1. Welcome screen: age confirmation and harm reduction notice (not medical advice).
2. The encryption key is generated, the database created and the bundled dataset loaded.
3. Option to import data from PsychonautWiki Journal or start fresh.

Edge cases: failure writing to the Keychain or Keystore (clear message and retry, never an unencrypted database); app closed mid-initialization (idempotent process).

**UC-02 Log an ingestion**

1. "+" → search substance → interaction warnings if any → route → dose with visible ranges → time and remaining fields → save.
2. It is assigned to the ongoing experience or a new one is created; curve, widget, Live Activity and reminders are updated.

Edge cases: unknown dose; unit different from the dataset's (no implicit conversion, only between mass units); future time (allowed only as planned); substance without data for the chosen route; retroactive ingestion in another time zone.

**UC-03 View and edit an experience**: timeline, ingestions, ratings, timed notes; edit or delete any item with a 5 s undo. Edge case: deleting the last ingestion deletes the experience after confirmation.

**UC-04 Plan a redose**: from the experience, "Plan" adds an ingestion with a dashed stroke and shows the resulting curve; one tap turns it into a real one.

**UC-05 Look up a substance**: search, open the page, switch route, see interactions and tolerance; the external link to the article opens only after a notice that it leaves for the browser.

**UC-06 Check interactions manually**: pick 2 or more substances and see the risk matrix with its explanation.

**UC-07 Browse the calendar**: current month, swipe between months, tap a day, filter. Edge cases: experience crossing midnight (shown on both days, the second marked as a continuation); DST change; day with many substances.

**UC-08 Stats and tolerance**: choose a period and a substance; frequency, total dose and estimated tolerance charts.

**UC-09 Configure reminders and alerts**: enable each type, set times and thresholds; the first activation asks for notification permission. Edge case: permission denied (visible state and a link to system Settings).

**UC-10 Widgets and Live Activity**: add a widget; starting an experience starts the Live Activity; it ends on its own when the last ingestion's offset ends, or manually. Edge case: iOS Live Activity duration limits (renewed or degraded to the widget).

**UC-11 Export**: encrypted with a password by default; plain JSON after an explicit warning; shared through the system share sheet.

**UC-12 Import**: pick a file, format detection, validation, preview with counts, merge or replace with confirmation. Edge cases: wrong password, corrupt or truncated file, future schema version, duplicates when merging (same id, or same substance, time and dose).

**UC-13 Update the dataset**: enable checking or tap "Check now"; download, verify signature and hash, apply; revert to the bundled one. Edge cases: no network, invalid signature, incompatible schema, ingestions referencing a renamed or removed substance (the name is kept and marked "no data").

**UC-14 Wipe everything**: Settings → long press → confirm by typing a word → the key is destroyed; database, downloaded dataset, preferences, notifications, widgets and Live Activities are deleted, and the app returns to first launch. Edge case: failure midway (key destruction goes first, so the data stays unreadable even if the rest fails).

## Non-functional requirements

Measurable targets are verified in CI or in the release checklist; performance targets on a Pixel 6a and an iPhone 13 as reference devices.

| Area | Requirement | Verification |
| --- | --- | --- |
| Privacy | Zero network requests except `github.com` and `objects.githubusercontent.com` for the dataset, and only with updates enabled or "Check now" | Integration test with a spied HTTP client; dependency review in CI |
| Privacy | No analytics, crash reporting or ad SDKs; no location, contacts, camera or microphone permissions | Pinned permission list checked in CI (manifest and Info.plist) |
| Security | Database always encrypted (AES-256 via SQLite3MultipleCiphers); startup fails closed without the key | Test that opens the file without the key and expects an error |
| Security | Export encrypted with Argon2id (m=64 MiB, t=3, p=1) and AES-256-GCM; minimum password of 10 characters with a strength meter | Test vectors and round-trip |
| Security | Downloaded dataset accepted only with a valid Ed25519 signature, correct SHA-256 hash and compatible schema version | Tests with invalid signatures, tampered hash and future schema |
| Security | Screenshots and app switcher not hidden (no lock), except on the export password screen | Manual review |
| Performance | Cold start under 1.5 s to the Journal with 5,000 ingestions | Integration benchmark |
| Performance | Sustained 120 Hz in timeline, calendar and lists: frame build plus raster under 8.3 ms on 120 Hz devices (16.6 ms on 60 Hz) when profiling the main flows | DevTools and `flutter drive --profile` |
| Performance | Catalog search result in under 50 ms | Performance test |
| Reliability | Writes in transactions; no operation leaves the database half-written | Migration and fault-injection tests |
| Accessibility | VoiceOver and TalkBack on every screen; dynamic text up to 200 %; AA contrast; color never the only cue; 44 pt / 48 dp touch targets | Semantics tests and manual audit |
| i18n | Complete English and Spanish, no strings in code; ICU plurals; dates, numbers and units by locale; system language by default with a Settings override | Missing-translation lint in CI |
| Platforms | iOS 17+ and Android 8.0 (API 26)+; phones in portrait, iPad and tablets in compatibility mode | CI matrix |
| Size | Download under 40 MB per platform | Size report in CI |

## Substance dataset

The dataset is built in `Zadrya/Data` from PsychonautWiki, reviewed by hand, signed with Ed25519 and published as a GitHub Release; the app ships with a bundled copy and can download new versions if the user enables it (off by default).

**Pipeline (Python 3.12, pytest, Black, type hints)**

1. **Base**: `Substances.json` from PsychonautWiki Journal v11.11 (GPL-3.0, CC BY-SA content), as a curated starting point.
2. **Extraction**: the PsychonautWiki GraphQL API (`api.psychonautwiki.org`) and, where the API is stale, the wiki itself (MediaWiki API) for missing fields.
3. **Normalization**: drop class and disambiguation pages; canonical names and aliases; units; routes; dose ranges; durations per phase; tolerance; interactions (dangerous, unsafe, uncertain, classes included).
4. **Validation**: strict JSON Schema, invariants (increasing ranges, duration min ≤ max, symmetric interactions, existing references) and a readable diff against the previous version.
5. **Human review**: the diff is opened as a pull request; no release without approval from `Sklyvan`.
6. **Signing and publishing**: `substances.json` + `substances.json.sig` + `manifest.json` (dataset version, schema version, minimum app version, SHA-256, date, attribution) as release assets.

**Signing key**: the private key is generated locally and lives outside any repository (password manager; optionally a GitHub Secret in `Data` if signing from CI). The public key is pinned in the app code; two public keys are accepted so they can be rotated.

**In the app**

- At startup the active dataset is used: the downloaded one if valid, otherwise the bundled one.
- With updates enabled, a check at most once every 7 days when the app opens, never in the background; "Check now" in Settings.
- Download → signature, hash and compatibility check → atomic write → activation on next launch or on confirmation.
- "Restore bundled dataset" always available.
- Ingestions store the canonical name; if a substance disappears from the dataset, the ingestion keeps its name and is marked "no data".

**Shared schema**: lives in `Zadrya/Data/schema/` with semantic versioning; `Application` pins a version, generates its Dart models from it, and its CI fails if the latest data release requires an unsupported major version.

## Import and export

Export is the only backup: encrypted by default, plain JSON only after a warning. Import accepts three formats and never touches data before validating and confirming.

| Format | Extension | Export | Import |
| --- | --- | --- | --- |
| Zadrya encrypted | `.zadrya` | Yes (default) | Yes |
| Zadrya plain JSON | `.json` | Yes, after a warning | Yes |
| PsychonautWiki Journal | `.json` | No | Yes (v11.x and GPL forks) |

**`.zadrya` format**: binary header with magic `ZDRY`, format version, Argon2id parameters, 16-byte salt and 12-byte nonce; AES-256-GCM body over the gzip-compressed Zadrya JSON. The header is passed as associated data (AAD), so tampering with it invalidates the file.

**Zadrya JSON**: `{ formatVersion, exportedAt, appVersion, datasetVersion, experiences[], customSubstances[], customUnits[], substanceColors[], reminders[], settings{} }`, described by a JSON Schema published in `Application/docs/`.

**Import flow**

1. Detection by magic or JSON shape; maximum size 50 MB.
2. Decryption for `.zadrya` (three password attempts before going back to file selection).
3. Full validation against the schema; a JSON that does not match is rejected (this fixes the original app's bug, which accepted it as an empty journal and wiped the data).
4. PsychonautWiki Journal mapping: experiences, ingestions, ratings, timed notes, colors, custom substances and units; fields without an equivalent are appended to the notes.
5. Preview: counts per type, date range, detected conflicts.
6. Choice: merge (deduplicating by id and by substance + time + dose) or replace (with typed confirmation).
7. Single-transaction write and final summary.

## Architecture and stack

Flutter with a layered architecture and feature-first folders (`lib/features/<feature>/{presentation,application,domain,data}` plus `lib/core`). The domain is pure Dart and holds all the harm reduction logic, so it can be tested without a device.

&#91;embedded content: Zadrya architecture · 5 layers on device, 2 external items\]

Each layer only uses the one below it. Only two things live outside the device: the signed release from `Zadrya/Data`, downloaded if the user enables it, and the export file the user moves themselves.

| Layer | Choice | Reason |
| --- | --- | --- |
| Framework | Stable Flutter pinned with `fvm`, Dart 3 | One codebase for iOS and Android; Impeller for 120 Hz curves |
| State | Riverpod with code generation | Typed, testable without widgets |
| Navigation | go\_router | Typed routes and deep links from widgets and notifications |
| Models | freezed + json\_serializable | Immutability and JSON generated from the schema |
| Database | Drift + sqlite3 with SQLite3MultipleCiphers | Typed SQL, verifiable migrations, built-in encryption |
| Key storage | flutter\_secure\_storage | Keychain and Keystore |
| Cryptography | `cryptography` (Argon2id, AES-GCM, Ed25519, SHA-256) | Encrypted export and dataset verification |
| Curves | Custom CustomPainter | Full control of phases, shading and gestures |
| Stats charts | fl\_chart | Ready-made bars and lines |
| Notifications | flutter\_local\_notifications + timezone | Local reminders without a server |
| Widgets | home\_widget + WidgetKit (Swift) + Glance (Kotlin) | Data shared via App Group and SharedPreferences |
| Live Activities | ActivityKit (Swift) via a platform channel | Lock Screen and Dynamic Island |
| Files | file\_picker + share\_plus | Import and export through the system sheet |
| i18n | ARB + gen-l10n | English and Spanish with ICU plurals |
| E2E tests | Patrol | Interaction with native dialogs (permissions, share sheet) |

## Quality, testing and CI/CD

No change reaches `main` without green CI; minimum 85 % coverage in domain and data, and every curve, tolerance and interaction formula tested against reference cases.

**Tests**

- **Unit** (`flutter test`): pure domain (curves, tolerance, interactions, experience assignment, calendar and time zones), export encryption, signature verification, import mapping.
- **Database**: Drift tests with an in-memory database and generated migration tests (`drift_dev schema steps`) for every version.
- **Widget and golden tests**: timeline, calendar, substance pages and charts, in English and Spanish, light and dark theme, text at 100 % and 200 %.
- **Integration / E2E** (Patrol): UC-01, UC-02, UC-11, UC-12, UC-13 and UC-14 on the iOS simulator and the Android emulator.
- **Native**: widget and Live Activity tests in Swift (XCTest) and Glance widget tests in Kotlin.
- **Data pipeline**: pytest with API response fixtures, invariant tests and signature tests.

**Static quality**: `very_good_analysis` or equivalent strict lints, `dart format`, `dart fix`; SwiftLint for Swift; ktlint for Kotlin; Black and mypy for Python.

**Git**: conventional commits; `feature/<description>` and `fix/<description>` branches; pull requests with a template and rebase merge, no squash, to keep small commits on main; `main` protected in every repository.

**Small commits**: one commit per logical, self-contained change (a domain rule, a migration, a screen, a test) that builds and passes tests on its own; refactors never mixed with features in the same commit; conventional commit messages in English.

**Authorship**: every commit and pull request belongs to `Sklyvan` only, with his git identity. Claude never appears as author or co-author: no `Co-Authored-By`, no `Claude-Session:` and no "Generated with Claude Code" in commits, PRs or code. Enforced in three layers: `attribution` disabled in the project's `.claude/settings.json` (empty `commit` and `pr`, `sessionUrl: false`), the rule written in `CLAUDE.md`, and a `commit-msg` hook that rejects any commit containing those lines.

**CI/CD**: GitHub Actions in all four repositories, with the same hygiene and security rules. Since the repositories are public, runners (macOS included) are free.

**Common to every repository**

- **Ruleset on `main`**: pull request required, required checks green, linear history, conversations resolved, no force-push or deletion. Only the owner may bypass it, and only in an emergency.
- **Templates and ownership**: PR and issue templates, `CODEOWNERS` with `@Sklyvan`, standard labels.
- **Conventional commits**: commitlint validates the PR title and every commit.
- **Authorship**: a check fails if any commit in the PR contains `Co-Authored-By`, `Claude-Session:` or "Generated with Claude Code", or if its author is not `Sklyvan`.
- **Dependencies**: weekly grouped Dependabot for `github-actions`, `pub`, `gradle`, `swift` and `pip`; no automerge. A license check fails if a GPL-3.0-incompatible dependency is added.
- **Actions hardening**: actions pinned by SHA, minimal `permissions` per job (`contents: read` by default), `concurrency` that cancels stale runs, `timeout-minutes` on every job, dependency caching.
- **Security**: secret scanning with push protection, CodeQL for Actions and Python, weekly OpenSSF Scorecard, `SECURITY.md` with a private reporting channel.

| Repository | On every PR | On `main` and nightly | Release |
| --- | --- | --- | --- |
| `Application` | `dart format`, `flutter analyze`, unit, widget, golden and migration tests with ≥ 85 % coverage in domain and data; complete l10n strings; permission list and network dependency check; SwiftLint, ktlint, XCTest and Kotlin tests; Android debug build and unsigned iOS build; size report | All of the above plus Patrol E2E on the Android emulator and the iOS simulator; compatibility with the latest schema published in `Data` | Tag `vX.Y.Z`: signed AAB to Google Play (internal or closed track), IPA to TestFlight, signed APK with SHA-256 and build provenance attestation in the GitHub Release |
| `Data` | Black, mypy, pytest, schema and invariant validation, readable dataset diff posted on the PR | Full validation | Manual with `release` environment approval: Ed25519 signature, `manifest.json`, GitHub Release and verification of the published signature |
| `zadrya.github.io` | Build, broken links, valid HTML | Deploy to GitHub Pages | Not applicable |
| `.github` | YAML and Markdown lint | Not applicable | Not applicable |

**Versioning and CD**: release-please in `Application` and `Data` produces the semantic version, `CHANGELOG.md` and the tag from conventional commits; the build number comes from the CI run. Fastlane with `beta` and `release` lanes publishes to TestFlight and Google Play; the GitHub environments `beta` and `production` require owner approval. Secrets (Android keystore, Apple certificates via fastlane match in a private repository of the organization, App Store Connect API key, Google Play service account, Ed25519 key) exist only in those environments. Publishing jobs stay disabled until the store accounts exist.

**Local parity**: lefthook hooks (`pre-commit`: format and analyze changed files; `commit-msg`: conventional commits and the Claude attribution block) and the same CI commands exposed in a `Makefile`, so passing locally means passing in CI.

**Local environment**: macOS with Xcode, Android Studio (SDK, arm64 emulator, Command-line Tools), `fvm` with the Flutter version pinned in `.fvmrc`, CocoaPods, authenticated `gh`. A clean `flutter doctor -v` is the starting condition.

## Publishing and compliance

Channels: App Store and Google Play as primary, signed APK on GitHub Releases as secondary; F-Droid is postponed until it is clear how it fits Android developer verification.

| Topic | Decision |
| --- | --- |
| Accounts | Apple Developer Program (USD 99/year) and Google Play Console (USD 25, one-time), not created yet |
| Google Play | New personal account: closed test with 12 testers for 14 days before production; plan for about 3 weeks |
| Android verification | Register the package and signing key so the GitHub APK can be installed on certified devices |
| Category | Health & Fitness |
| Age rating | 18+ on the App Store; IARC answered honestly about drug references |
| Declared privacy | "Data Not Collected" (App Store) and "No data collected" (Play); health app declaration in Play Console |
| Privacy policy | At `zadrya.github.io/privacy`, in English and Spanish: data only on device, optional download from GitHub (which sees the IP), no third parties |
| Support | `zadrya.github.io/support` and GitHub issues |
| Listing and screenshots | Educational, harm reduction framing; no images of drug use; no links to sales |
| Notes for Apple review | Harm reduction purpose, data sources, no sales and no data collection (guideline 1.4.3) |
| Apple plan B | Feature flag ready to switch the catalog to "partial by default, full when enabled" if rejected |
| GDPR | No processing by the developer; encryption at rest, export under user control, no third parties |
| Attribution | `DATA_LICENSES.md` and a licenses screen: PsychonautWiki (CC BY-SA 4.0 text, CC BY 4.0 semantic data), PsychonautWiki Journal v11.11 (GPL-3.0), OFL fonts and package licenses |
| Legal notice | Not medical advice; shown on first launch, substance pages and Settings |

## Out of scope and decisions

**Out of MVP scope**: desktop and web; accounts and sync; biometric or PIN lock; telemetry and crash reporting; GPS location; Apple Health and Health Connect; TripSit data; social features; drug checking lab results; F-Droid distribution.

**Confirmed defaults**

- The database and the key are excluded from iCloud Backup and Android Auto Backup: the only copy is the manual export.
- Window for grouping ingestions into one experience: 12 h.
- Interaction check window: active effects or the last 24 h.
- Maximum dataset check frequency: every 7 days.
- Performance reference devices: Pixel 6a and iPhone 13.
- Icon concept: the effect curve as a horizon with a gold dot peeking above it like the sun.

**Before starting in Claude Code**

- [x] Create the `Zadrya` organization on GitHub.
- [ ] Search "Zadrya" in EUIPO TMview.
- [ ] Install Xcode, Android Studio, `fvm`, `cocoapods` and `gh`, and authenticate `gh` with the `repo`, `workflow` and `admin:org` scopes.
- [ ] Generate the Ed25519 data signing key locally and store it in a password manager.
