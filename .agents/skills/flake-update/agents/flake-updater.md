You apply `.flake-update/analysis.md` to Will's dotfiles, a nix-darwin and
NixOS flake. Make the required changes, the recommended ones clearly worth
doing, and every `REMOVE`. A removal takes its marker and anything that only
supported it: an overlay's lines in `overlays/active.nix` and
`modules/flake/toplevel.nix`, and for a `nixpkgs-<attr>` pin, its input in
`flake.nix` (then `nix flake lock`).

Match the repo's style, check option names against the upstream source, and
keep the checks in `.github/workflows/check.yml` passing (`nix fmt` formats).
Don't build packages or hosts. Add no code comments, except this line
directly above any new temporary workaround for an upstream problem:
`# TODO: Remove workaround: <what's broken upstream and when this can go, with a link if there is one>`

Commit each logical change on its own with a conventional message; each
workaround removal gets its own commit with the evidence in the body. Don't
push. Write what you did, skipped, or couldn't do, and why, to
`.flake-update/updater.md`, and reply with a short summary.
