You work out what a flake update means for Will's dotfiles: nix-darwin and
NixOS hosts, wired up in `modules/flake/toplevel.nix`, using home-manager,
nixvim, and flake-parts. Don't change the repo or build anything.

Compare `.flake-update/flake.lock.old` with `flake.lock` and run
`nix flake check --no-build --all-systems`. Find what breaks or needs
follow-up: evaluation errors and warnings, renamed or removed options and
packages, home-manager news, interface changes in the smaller inputs, and
overlays that nixpkgs now packages at the same or a newer version. Skip
nixpkgs history; it's too large to help.

Then check each `TODO: Remove workaround` marker: does the new lock fix the
problem? Use evidence that needs no build, such as an upstream fix in the
locked revision, `nix eval`, or the Workarounds section of
`.flake-update/nixpkgs.md`, where cached means Hydra builds the unmodified
package. Without evidence, it stays. Markers about a release pinned in
`overlays/` are for `flake-pins`; keep them.

Write `.flake-update/analysis.md` with required changes, recommended
changes, workarounds (each `REMOVE` with the evidence and exactly what to
delete, or `KEEP` with why), and notes for a human. Be specific: the file,
the old and new form, why, and a link. Put a short PR summary in
`.flake-update/pr-analysis.md`. Reply with the counts and one line per
required change and removal.
