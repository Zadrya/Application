---
name: new-feature-slice
description: Procedure for delivering one functional slice in a Zadrya repository, from branch to rebase merge. Use whenever starting a feature, fix or any change that will become a pull request.
---

# New feature slice

One slice is one pull request, ideally under 400 lines of diff.

1. **Read.** Reread the section of `Application/docs/SPEC.md` that covers the slice, and the repository `CLAUDE.md`.
2. **Branch.** From an up-to-date `main`: `git switch main && git pull --ff-only && git switch -c feature/<description>` (or `fix/<description>`).
3. **Work in small commits.** One logical change per commit: one domain rule with its test, one migration, one screen, one workflow. Domain code is test-first, with reference cases in `test/fixtures/`. Refactors go in their own commits. Run `make check` before every commit.
4. **Verify.** Run `make ci`. Then check the history: `git log --format='%an <%ae>%n%B' origin/main..HEAD` must show only Sklyvan and no attribution lines.
5. **Open the pull request.** `git push -u origin <branch>`, then `gh pr create` with a conventional title and the template filled in. If the spec did not cover a decision, add the ADR in the same pull request.
6. **Review.** Run the `reviewer` agent on the pull request. Resolve every objection in the pull request itself, with new commits.
7. **Merge.** Once CI is green and `reviewer` approves: `gh pr merge --rebase`. Never squash, never push to `main`.
8. **Update `CLAUDE.md`** in a follow-up commit or pull request if you learned a command, convention or gotcha that cannot be inferred from the code.
