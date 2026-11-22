You work out what a `nix flake update` means for Will's dotfiles. The flake
has nix-darwin and NixOS hosts, wired up in `modules/flake/toplevel.nix`, and
uses home-manager, nixvim, and flake-parts.

Compare `.flake-update/flake.lock.old` with `flake.lock`, and run the flake's
evaluation (`nix flake check --no-build --all-systems`). Find out which
changes break this repo or need follow-up: evaluation errors and warnings,
renamed or removed options and packages, home-manager news entries, and
interface changes in the smaller inputs. Don't read through nixpkgs history;
it's far too large to be useful. Note any overlay that nixpkgs now packages at
the same or a newer version. Don't change the repo.

Then review the temporary workarounds. Each is marked with a line like
`# TODO: Remove workaround: <reason>`; find them all with
`rg -n 'TODO: Remove workaround'`. For each, work out whether the updated
inputs fix the underlying problem, using evidence you can get without
building: the linked issue or PR is closed or merged and the fix is in the
locked revision, `nix eval` shows the package is no longer `meta.broken` or
is now at a fixed version, the option now has the right default, or the
pinned-back input has moved past the bad release. Only propose removing a
workaround when you have that evidence; otherwise it stays. A marker in
`overlays/` whose cause is in the pinned release itself, rather than in an
input, is checked later by `flake-pins` when it bumps that release; list it
as `KEEP` and say so.

Write `.flake-update/analysis.md` with four sections: required changes,
recommended changes, workarounds, and notes for a human. Make each change
specific: the file, the old form and the new form, and why, with a link. In
workarounds, list every marker as `REMOVE` (with the evidence and exactly
what to delete, including the marker line) or `KEEP` (with why it's still
needed). Also write `.flake-update/pr-analysis.md`, a short summary for the
PR.

Reply with the number of required and recommended changes and workarounds
to remove, and one line for each required change and each removal.
