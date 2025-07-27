{ pkgs, ... }:
{
  home.packages = with pkgs; [
    brewCasks.container
  ];
}
