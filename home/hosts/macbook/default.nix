{
  pkgs,
  config,
  nix-colors,
  ...
}:
{
  imports = [
    ../../../secrets.nix
    ../../modules/tui
    ../../modules/tui/darwin
    ../../modules/gui
    ../../modules/gui/darwin
    ./home.nix
    ./aws.nix
    ./packages.nix
  ];
}
