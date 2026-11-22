{ inputs }:
(_final: prev: {
  # TODO: Remove workaround: uses the nixpkgs-codex input in flake.nix; remove both together
  codex = inputs.nixpkgs-codex.legacyPackages.${prev.stdenv.hostPlatform.system}.codex;
})
