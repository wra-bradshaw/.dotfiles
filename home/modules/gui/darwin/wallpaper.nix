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
    enable = false;
    image = ../../../../wallpaper.heic;
  };
}
