{
  config,
  lib,
  pkgs,
  ...
}:

let
  mkSolidColorPng = import ../../../../lib/mkSolidColorPng.nix { inherit pkgs; };
in
{
  services.macos-wallpaper = {
    enable = true;
    image = mkSolidColorPng {
      width = 1;
      height = 1;
      color = "#000000";
    };
  };
}
