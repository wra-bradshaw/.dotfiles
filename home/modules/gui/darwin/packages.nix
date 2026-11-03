{ lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    brewCasks.anki
    brewCasks.audacity
    brewCasks.discord
    brewCasks.jan
    brewCasks.lookaway
    brewCasks.syntax-highlight
    brewCasks.firefox
    brewCasks.roblox
    brewCasks.sketch
    brewCasks.chatgpt
    (lib.lowPrio brewCasks.claude)
    brewCasks.mysqlworkbench
    brewCasks."t3-code@nightly"
    rex-app
  ];
}
