{ pkgs, ... }:
{
  home.packages = with pkgs; [
    brewCasks.slack
    brewCasks.notion
    brewCasks.eloston-chromium
    brewCasks.orbstack
    brewCasks.anki
    brewCasks.homerow
  ];
}
