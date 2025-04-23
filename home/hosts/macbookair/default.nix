{
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
    ./packages.nix
    ../../extensions
  ];
}
