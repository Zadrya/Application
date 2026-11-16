# 2. Dependabot updates are re-committed by the owner

- Status: accepted, pending owner confirmation at the Phase 0 checkpoint
- Date: 2026-11-16

## Context

The spec requires that every commit on `main` is authored and committed by Sklyvan, enforced by the `authorship` check. It also requires weekly grouped Dependabot updates with no automerge. Dependabot authors its own commits as `dependabot[bot]`, so its pull requests can never pass the check as they are.

## Decision

The `authorship` check has no exception for bots. A Dependabot pull request is treated as a notification: the bump is reproduced as a commit by Sklyvan on a `fix/` or `feature/` branch, merged through a normal pull request, and the Dependabot pull request is closed.

## Consequences

- `git log` on `main` shows only Sklyvan, in all four repositories.
- Dependency updates cost a few manual steps each week.
- Dependabot pull requests always show a failed `authorship` check. This is expected.
- The alternative, an allowlist for `dependabot[bot]`, would be simpler but breaks the single-author rule.
