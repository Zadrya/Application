# 3. iOS is built and tested in CI only, for now

- Status: accepted, to be revisited before Phase 2
- Date: 2026-11-16

## Context

The spec lists Xcode and a clean `flutter doctor -v` for iOS as the starting condition. The development machine cannot install Xcode, and the owner chose to continue without it.

## Decision

iOS builds, XCTest and the Patrol suite on the iOS simulator run only on GitHub-hosted macOS runners, which are free for public repositories. Android is verified locally on the arm64 emulator and in CI.

## Consequences

- The feedback loop for iOS problems is slower: push, wait for CI, read the logs.
- "Runs on the iOS simulator" exit criteria are proven by CI runs, not by a local run.
- Nobody can look at the iOS UI, widgets or Live Activities until a Mac with Xcode or a physical test path is available. This is a real risk for Phase 6 (WidgetKit and ActivityKit) and must be decided again before Phase 2 starts.
