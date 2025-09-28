{
  pkgs,
  config,
  lib,
  nixpkgs,
  ...
}:
let
  crossPkgs = import nixpkgs { system = "aarch64-linux"; };
  mkDockerLinuxWrapper = import ../../../../lib/mkDockerLinuxWrapper.nix;
in
{
  home.packages = [
    (mkDockerLinuxWrapper {
      inherit pkgs;
      inherit crossPkgs;
      binName = "valgrind";
      name = "valgrind-nixpkgs";
      contents = [ crossPkgs.valgrind ];
      cmd = [ "bin/valgrind" ];
    })
  ];
}
