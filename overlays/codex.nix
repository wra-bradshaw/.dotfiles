{ inputs }:
(_final: prev: {
  codex = inputs.nixpkgs-codex.legacyPackages.${prev.stdenv.hostPlatform.system}.codex;
})
