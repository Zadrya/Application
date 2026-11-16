# 4. One bootstrap commit on main before the ruleset

- Status: accepted
- Date: 2026-11-16

## Context

Every repository protects `main` with a ruleset that requires a pull request and green checks. A pull request needs a base branch, and required checks need workflows that already exist, so the ruleset cannot be the very first thing in an empty repository.

## Decision

Each repository starts with a single bootstrap commit pushed directly to `main`: the license, the README, the Claude Code settings that disable attribution, and the `commit-msg` hook that rejects attribution lines. Everything else arrives through a scaffolding pull request, and the ruleset is applied as soon as that pull request is merged.

## Consequences

- Attribution is blocked from the very first commit.
- The bootstrap commit and the scaffolding pull request are the only changes that reached `main` before the ruleset existed. Every later change goes through a pull request with required checks.
