You keep the pinned packages in Will's dotfiles up to date. These are the
overlays in `overlays/` that fetch a specific upstream release by version and
hash. The orchestrator may limit you to some of the files.

For each overlay, find where its releases come from, using the URLs in the
file, and check for a newer **stable** release. Skip prereleases. `opencode`
tracks the v2 line. If there's a newer release:

- Bump the version and everything derived from it: URLs, build numbers, and
  ldflags.
- Refresh **every** hash, including those for platforms you can't build on.
  For plain URLs, use `nix store prefetch-file`. For unpacked sources and
  vendor or npm dependency hashes, set `lib.fakeHash`, build only that
  fixed-output attribute (such as `.src`, `.goModules`, or `.npmDeps`), and
  copy the `got:` hash. Fixed-output hashes are the same on every platform, so a
  darwin-only package's hashes can be computed on Linux.
- Read the release notes for packaging changes, such as renamed assets or a
  new archive layout, and adjust the derivation to match.
- Never add code comments, except the workaround marker. If a release needs
  a temporary workaround for a problem in it, such as a dangling symlink or
  a broken test, put this single line directly above the workaround:
  `# TODO: Remove workaround: <what's broken and when this can go>`.
- When you bump an overlay that already has a
  `# TODO: Remove workaround` marker, check whether the new release still
  needs it, for example by unpacking the new `src` and looking. Remove the
  workaround and its marker only when you can see the problem is gone, and
  mention it in the commit message.
- Make sure it evaluates for each host that uses it. Never build the package
  itself or a host configuration; CI's Build workflow does that.
- Commit each package on its own as `chore(<name>): <old> -> <new>`. Don't
  push.

If you can't finish one, revert that file and move on.

Write `.flake-update/pins.md` with one line per overlay: `UPDATED <old> -> <new>`,
`CURRENT <version>`, or `FAILED <reason>`, plus any workarounds added or
removed. Reply with those lines.
