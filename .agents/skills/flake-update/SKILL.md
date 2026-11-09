---
name: Flake Update
description: Update this dotfiles flake. Update mode runs `nix flake update`, has subagents work out and fix what the lock changes break and bump the pinned packages in overlays/, then prepares an auto-merging PR. Fix mode repairs one round of CI failures on that PR. Use when asked to update the flake, its inputs, or pinned packages, or to fix a failing flake-update PR. CI runs both modes.
---

# Flake update

You orchestrate; subagents do the heavy lifting so your context stays small.

- **Subagents:** `flake-analyzer`, `flake-updater`, `flake-pins`, and
  `flake-ci-fixer`. They're already set to the right model, so don't override
  it, and don't use any other subagents. They start with no context: tell
  each one the repo path, the task, and which files to read. Each writes its
  findings to `.flake-update/` (gitignored) and replies briefly.
- **Checks** are whatever `.github/workflows/check.yml` runs: evaluation and
  lint. Send long output (`nix flake check`, CI logs) to a file in
  `.flake-update/` and read the end of it.
- **Never build packages or configurations**, and don't let subagents build
  them, in the foreground or the background: no `nix build` of a package or
  host, no `nix flake check` without `--no-build`, no `*-rebuild`. Builds are
  the Build workflow's job; it has the binary cache and the right platforms.
  The only exception is realising a fixed-output derivation (a `src`, vendor,
  or npm deps attribute) to learn its hash.
- **Never add code comments**, and don't let subagents add them. Explanations
  go in commit messages, the PR body, or the PR comment.
- **Commit locally, never push.** `scripts/publish.sh <result> [pr]` (next to
  this file) does every write to GitHub. In CI the workflow runs it after you
  finish, and your `gh` is read-only. Interactively, show the user what you
  did and run it after they confirm.
- **In CI** (`CI=true`), nobody is watching. Never ask questions. Make the
  safe choice and note it in the PR body or comment.
- **Finish** your final reply with the line `FLAKE_UPDATE_RESULT: <result>`.

## Update mode

1. With a clean tree, create `flake-update/<YYYY-MM-DD>` from `origin/main`.
   Copy `flake.lock` to `.flake-update/flake.lock.old`, run
   `nix flake update`, and commit the lock on its own.
2. Have `flake-analyzer` work out what the changes mean for this repo.
3. If it found anything to change, have `flake-updater` apply it.
4. Have `flake-pins` bring the pinned packages in `overlays/` up to date. If
   it reports a lot of outdated packages, you can split them across several
   `flake-pins` runs in parallel, each owning different files.
5. Run the checks. If they fail, give `flake-ci-fixer` the output.
6. If there are no commits beyond `origin/main`, the result is
   `nothing-to-do`. Otherwise write `.flake-update/pr-body.md` with:
   - the changed inputs, with GitHub compare links
   - the analysis summary
   - the repo changes
   - the pinned packages that were bumped
   - anything left unresolved

   The result is then `ready`, and `publish.sh ready` opens the PR with
   auto-merge.

## Fix mode

You're given PR `#<n>` and fix round `<r>`. CI has already confirmed the
failure is on the PR's current head and that the round limit hasn't been
reached.

1. Check out the PR branch. Save the failed jobs' logs for the head commit
   (`gh run view <run> --log-failed`) under `.flake-update/ci/`.
2. Have `flake-ci-fixer` fix them. Point it at the earlier rounds in the PR
   comments so it doesn't repeat an approach that already failed.
3. Write `.flake-update/comment.md`, a few lines saying what failed and what
   changed. The result is one of:
   - `fixed`: there are new commits. If the branch conflicted with main, you
     rebased and re-ran the update, and `publish.sh` force-pushes with a
     lease.
   - `flaky`: an infrastructure failure. `publish.sh` re-runs the failed jobs.
   - `stuck`: needs a human.
