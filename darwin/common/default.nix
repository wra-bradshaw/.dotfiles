{
  imports = [
    ./nix.nix
    ./fonts.nix
    ./containers.nix
    ./users.nix
    ./komorebi.nix
    ./homebrew.nix
    ./packages.nix
    ./security.nix
    ./settings.nix
    ./windows.nix
    ./app-overlays.nix
    ./../../secrets.nix
    ./../extensions
  ];
}
