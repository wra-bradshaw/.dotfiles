{
  pkgs,
  config,
  lib,
  nixpkgs,
  ...
}:
let
  crossPkgs = import nixpkgs { system = "aarch64-linux"; };
  mkNerdctlLinuxWrapper = import ../../../../lib/mkNerdctlLinuxWrapper.nix;
in
{
  home.packages = [
    (mkNerdctlLinuxWrapper {
      inherit lib;
      inherit pkgs;
      inherit crossPkgs;
      binName = "valgrind";
      name = "valgrind-nixpkgs";
      contents = [ crossPkgs.valgrind ];
      cmd = [ "bin/valgrind" ];
    })
  ];
}
