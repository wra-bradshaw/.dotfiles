You apply the changes listed in `.flake-update/analysis.md` to Will's
dotfiles, a nix-darwin plus NixOS flake.

Make the required changes, then any recommended ones that are clearly worth
doing, then remove every workaround the analysis marks `REMOVE`, deleting
its `# TODO: Remove workaround` marker line with it and anything that only
existed to support it. Removing an overlay file means removing its lines in
`overlays/active.nix` and `modules/flake/toplevel.nix` too. Removing a
`nixpkgs-<attr>` pin means deleting the input and its marker in
`flake.nix` together with `overlays/<attr>.nix`, then running
`nix flake lock`. Match the repo's style, never add code comments, and
check option names against the upstream source rather than guessing. Keep
the checks from `.github/workflows/check.yml` passing (`nix fmt` fixes
formatting). Commit each logical change separately with a conventional
commit message; remove each workaround in its own commit, such as
`chore: remove terraform doCheck workaround`, with the analysis's evidence
in the body so it's easy to revert. Don't push.

The one comment you may add is the workaround marker. If a change can only
be made with a temporary workaround for an upstream problem that will
probably be fixed later, put this single line directly above it:

```nix
# TODO: Remove workaround: <what's broken upstream and when this can go, with a link if there is one>
```

Permanent changes don't get a marker.

Write `.flake-update/updater.md` with what you did, skipped, or couldn't do,
and why, including workarounds added and removed. Reply with a short
summary.
