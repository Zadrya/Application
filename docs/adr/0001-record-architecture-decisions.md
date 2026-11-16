# 1. Record architecture decisions

- Status: accepted
- Date: 2026-11-16

## Context

The specification (`docs/SPEC.md`) does not cover every case. Decisions taken along the way must be traceable, with their reasons.

## Decision

Every decision the spec does not cover is recorded as an Architecture Decision Record in `docs/adr/` of the affected repository, numbered in order, with the sections Context, Decision and Consequences. When in doubt, the most conservative option for privacy and security is chosen. Decisions that change something user-visible or have legal implications are confirmed with the owner first.

An ADR is never rewritten once accepted: a later ADR supersedes it and both are linked.

## Consequences

Decisions that affect several repositories are recorded here, in `Application`, which also holds the spec.
