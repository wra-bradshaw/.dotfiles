---
name: Flake Update
description: Update this dotfiles flake. Update mode moves nixpkgs and the other inputs, has subagents fix what breaks and bump the pinned packages in overlays/, then prepares an auto-merging PR. Fix mode repairs one round of CI failures on that PR. Use when asked to update the flake, its inputs, or pinned packages, or to fix a failing flake-update PR. CI runs both modes.
---

# Flake update

You orchestrate; the `flake-analyzer`, `flake-updater`, `flake-pins`, and
`flake-ci-fixer` subagents do the work. Use only those, and don't override
their model. They start with no context, so give each the repo path, the
task, and the files to read. They write their findings to `.flake-update/`
(gitignored).

Rules for you and the subagents:

- **Never build packages or configurations**, not even in the background: no
  `nix build` of a package or host, no `nix flake check` without
  `--no-build`, no `*-rebuild`. The Build workflow does that. Realising a
  fixed-output derivation to learn its hash is fine.
- **Checks** are what `.github/workflows/check.yml` runs. Send long output to
  a file in `.flake-update/` and read the end.
- **No code comments**, except that anything added only to get past an
  upstream problem gets this line directly above it, and loses it when the
  workaround goes:
  `# TODO: Remove workaround: <what's broken upstream and when this can go, with a link if there is one>`
- **nixpkgs and the `nixpkgs-<attr>` inputs are pinned to exact revisions;**
  only `scripts/select-nixpkgs.py` changes them.
- **Commit locally, never push.** `scripts/publish.sh <result> [pr]` does
  every write to GitHub. CI runs it after you; interactively, run it once the
  user confirms.
- **In CI** (`CI=true`), never ask questions. Make the safe choice and note
  it in the PR body or comment.
- End your final reply with `FLAKE_UPDATE_RESULT: <result>`.

## Update mode

1. From a clean tree, create `flake-update/<YYYY-MM-DD>` from `origin/main`
   and copy `flake.lock` to `.flake-update/flake.lock.old`.
2. Run `scripts/select-nixpkgs.py apply`. It moves nixpkgs to the newest
   revision the hosts can get from cache.nixos.org, pinning uncached
   packages individually, and commits. CI has already run `select`;
   interactively, run it first (it takes minutes). If its output is missing
   in CI, or `apply` fails, nixpkgs stays put; note it.
3. Run `nix flake update` and commit the lock on its own.
4. Have `flake-analyzer` work out what the changes mean and which
   workarounds can go. Point it at `.flake-update/nixpkgs.md`.
5. Have `flake-updater` apply what it found, if anything.
6. Have `flake-pins` update the pinned packages in `overlays/`, split across
   parallel runs if many are outdated.
7. Run the checks, and give any failures to `flake-ci-fixer`.
8. With no commits beyond `origin/main`, the result is `nothing-to-do`.
   Otherwise write `.flake-update/pr-body.md`: the changed inputs with
   compare links, the nixpkgs section of `nixpkgs.md`, the analysis summary,
   the repo changes, the bumped packages, workarounds added, removed, and
   still needed, and anything unresolved. The result is `ready`.

## Fix mode

You're given PR `#<n>` and fix round `<r>`. CI has already checked that the
failure is on the PR's head and that the round limit hasn't been reached.

1. Check out the PR branch and save the failed jobs' logs
   (`gh run view <run> --log-failed`) under `.flake-update/ci/`.
2. Have `flake-ci-fixer` fix them. Point it at the earlier rounds in the PR
   comments and at any workaround the PR removed.
3. Write `.flake-update/comment.md`, a few lines on what failed and what
   changed. The result is `fixed` (new commits; if you rebased onto main,
   `publish.sh` force-pushes with a lease), `flaky` (infrastructure;
   `publish.sh` re-runs the failed jobs), or `stuck` (needs a human).
