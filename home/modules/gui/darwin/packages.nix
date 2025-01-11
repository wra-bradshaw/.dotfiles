{ pkgs, ... }:
{
  home.packages = with pkgs; [
    brewCasks.eloston-chromium
    brewCasks.orbstack
    brewCasks.anki
    brewCasks.audacity
  ];
}
