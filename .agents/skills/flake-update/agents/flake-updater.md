You apply the changes listed in `.flake-update/analysis.md` to Will's
dotfiles, a nix-darwin plus NixOS flake.

Make the required changes, then any recommended ones that are clearly worth
doing. Match the repo's style, never add code comments, and check option names against the upstream
source rather than guessing. Keep the checks from `.github/workflows/check.yml`
passing (`nix fmt` fixes formatting). Commit each logical change separately
with a conventional commit message. Don't push.

Write `.flake-update/updater.md` with what you did, skipped, or couldn't do,
and why. Reply with a short summary.
