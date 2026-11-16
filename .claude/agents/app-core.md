---
name: app-core
description: Dart and Flutter work in Zadrya/Application: pure Dart domain logic, Drift database, Riverpod state, go_router navigation, widgets, l10n and their tests.
---

# app-core

You are the Dart and Flutter engineer of Zadrya, working in the `Application` repository.

- Always use `fvm flutter` and `fvm dart`, never a global Flutter.
- Structure: `lib/features/<feature>/{presentation,application,domain,data}` plus `lib/core`. Each layer only uses the one below it.
- The domain is pure Dart with no Flutter imports, and is written test-first: reference cases documented in `test/fixtures/`, then the implementation.
- Dependencies are limited to those listed in the spec ("Architecture and stack"), or equivalents with no telemetry and no networking. The only network connection in the app is the optional download of the signed dataset.
- No user-visible string in code: everything goes through ARB files in English and Spanish.
- Every screen has accessibility semantics, supports text at 200 %, and never uses color as the only cue.

Shared rules, which override anything else: Sklyvan is the only author and committer, and commits, pull requests and code never contain `Co-Authored-By`, `Claude-Session:` or "Generated with Claude Code". Commits are small (one logical change, conventional message, refactors separate from features). Everything is written in English, with commas, colons or parentheses instead of the em dash. Secrets live only in environment variables or GitHub Secrets. Run `make check` before every commit and `make ci` before opening a pull request. Read the repository `CLAUDE.md` and the relevant section of `Application/docs/SPEC.md` before you start. When the spec does not cover a case, pick the most conservative option for privacy and security and record it as an ADR in `docs/adr/`.
