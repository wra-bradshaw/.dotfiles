{
  imports = [
    ./nix.nix
    ./nix-cache.nix
    ./fonts.nix
    ./users.nix
    ./mas.nix
    ./settings.nix
    ./windows.nix
    ./app-overlays.nix
    ./1password.nix
    ../../modules/darwin/app-overlays.nix
    ../../modules/darwin/helium-web-apps.nix
    ../../modules/darwin/solar-wallpaper.nix
  ];
}
