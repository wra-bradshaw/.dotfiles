{ inputs }:
(_final: prev: {
  # TODO: Remove workaround: uses the nixpkgs-vtsls input in flake.nix; remove both together
  vtsls =
    if builtins.elem prev.stdenv.hostPlatform.system [ "aarch64-darwin" ] then
      inputs.nixpkgs-vtsls.legacyPackages.${prev.stdenv.hostPlatform.system}.vtsls
    else
      prev.vtsls;
})
