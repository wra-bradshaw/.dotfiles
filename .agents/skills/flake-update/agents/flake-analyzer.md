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

Write `.flake-update/analysis.md` with three sections: required changes,
recommended changes, and notes for a human. Make each change specific: the
file, the old form and the new form, and why, with a link. Also write
`.flake-update/pr-analysis.md`, a short summary for the PR.

Reply with the number of required and recommended changes, and one line for
each required change.
