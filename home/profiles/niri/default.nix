{
  config,
  nix-colors,
  pkgs,
  ...
}:
{
  imports = [
    ../../modules/tui
    ../../modules/tui/linux
    ./niri.nix
  ];

  home = {
    username = "will";
    homeDirectory = "/home/will";
    stateVersion = "26.05";
  };
  programs.home-manager.enable = true;
  xdg.enable = true;
  colorScheme = nix-colors.colorSchemes.tokyo-night-storm;

  home.packages = with pkgs; [
    wl-clipboard
    swayimg
  ];
}
