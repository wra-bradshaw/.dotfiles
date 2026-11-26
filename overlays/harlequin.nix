{ inputs }:
(_final: prev: {
  # TODO: Remove workaround: uses the nixpkgs-harlequin input in flake.nix; remove both together
  harlequin =
    if builtins.elem prev.stdenv.hostPlatform.system [ "aarch64-linux" ] then
      inputs.nixpkgs-harlequin.legacyPackages.${prev.stdenv.hostPlatform.system}.harlequin
    else
      prev.harlequin;
})
