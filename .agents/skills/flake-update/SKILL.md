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
  go in commit messages, the PR body, or the PR comment. The one exception is
  the workaround marker below.
- **Mark temporary workarounds.** Anything added only to get past an upstream
  problem that will probably be fixed later, such as a disabled test, a
  backported patch, a `mkForce` over a bad default, an input pinned back, or
  a package or option disabled on one platform, gets a single comment line
  directly above it:

  ```nix
  # TODO: Remove workaround: <what's broken upstream and when this can go, with a link if there is one>
  ```

  Keep the exact prefix `TODO: Remove workaround` so it can be found with
  `rg 'TODO: Remove workaround'`, and remove the marker with the workaround.
  Permanent choices aren't workarounds and don't get a marker.
- **nixpkgs moves only through `scripts/select-nixpkgs.py`.** It picks the
  newest `nixpkgs-unstable` channel advance that is at least 24 hours old and
  whose packages cache.nixos.org has for every host. Upstream packages that
  aren't cached there are taken from their own `nixpkgs-<attr>` input via
  `overlays/<attr>.nix`, both marked as workarounds. If that isn't possible,
  nixpkgs stays where it is. `flake.nix` pins nixpkgs and every
  `nixpkgs-<attr>` input to an exact revision, so `nix flake update` never
  moves them; don't edit those revisions by hand. `select` writes
  `.flake-update/nixpkgs.json` and `nixpkgs.md`, and takes a few minutes, so
  give it a long timeout.
- **Commit locally, never push.** `scripts/publish.sh <result> [pr]` (next to
  this file) does every write to GitHub. In CI the workflow runs it after you
  finish, and your `gh` is read-only. Interactively, show the user what you
  did and run it after they confirm.
- **In CI** (`CI=true`), nobody is watching. Never ask questions. Make the
  safe choice and note it in the PR body or comment.
- **Finish** your final reply with the line `FLAKE_UPDATE_RESULT: <result>`.

## Update mode

1. With a clean tree, create `flake-update/<YYYY-MM-DD>` from `origin/main`,
   and copy `flake.lock` to `.flake-update/flake.lock.old`.
2. In CI the workflow has already run `scripts/select-nixpkgs.py select`. If
   `.flake-update/nixpkgs.json` is missing, run it yourself interactively; in
   CI, leave nixpkgs alone and say so in the PR body. Then run
   `scripts/select-nixpkgs.py apply`, which commits the nixpkgs bump and each
   per-package pin, or does nothing when the decision is `hold`. If it fails,
   it resets the branch itself and nixpkgs stays; carry on and note it.
3. Run `nix flake update` and commit the lock on its own.
4. Have `flake-analyzer` work out what the changes mean for this repo, and
   check every `TODO: Remove workaround` marker against the new lock. Point
   it at `.flake-update/nixpkgs.md`.
5. If it found anything to change, including workarounds that can now be
   removed, have `flake-updater` apply it.
6. Have `flake-pins` bring the pinned packages in `overlays/` up to date. If
   it reports a lot of outdated packages, you can split them across several
   `flake-pins` runs in parallel, each owning different files.
7. Run the checks. If they fail, give `flake-ci-fixer` the output.
8. If there are no commits beyond `origin/main`, the result is
   `nothing-to-do`. Otherwise write `.flake-update/pr-body.md` with:
   - the changed inputs, with GitHub compare links
   - the nixpkgs section from `.flake-update/nixpkgs.md`: the revision
     taken or why it was held, the per-package pins, and the rejected
     candidates with their Hydra logs
   - the analysis summary
   - the repo changes
   - the pinned packages that were bumped
   - workarounds added and removed, and the markers that are still needed
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
   comments so it doesn't repeat an approach that already failed. If the PR
   removed a workaround, tell it which, so it can restore the workaround if
   that's what broke.
3. Write `.flake-update/comment.md`, a few lines saying what failed and what
   changed. The result is one of:
   - `fixed`: there are new commits. If the branch conflicted with main, you
     rebased and re-ran the update, and `publish.sh` force-pushes with a
     lease.
   - `flaky`: an infrastructure failure. `publish.sh` re-runs the failed jobs.
   - `stuck`: needs a human.
