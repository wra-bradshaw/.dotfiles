{
  nix-colors,
  pkgs,
  ...
}:
{
  imports = [
    ../../modules/cli
    ../../modules/cli/linux
    ./niri.nix
  ];

  home.stateVersion = "26.05";
  programs.home-manager.enable = true;
  xdg.enable = true;
  colorScheme = nix-colors.colorSchemes.tokyo-night-storm;

  home.packages = with pkgs; [
    wl-clipboard
    swayimg
  ];
}
