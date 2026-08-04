{ pkgs, ... }:
{
  home.packages = with pkgs; [
    rift
    brewCasks.anki
    brewCasks.audacity
    brewCasks.jan
    brewCasks.lookaway
    brewCasks.syntax-highlight
    brewCasks.firefox
    brewCasks.intellij-idea
    brewCasks.sketch
    brewCasks.chatgpt
    brewCasks.harvest
    brewCasks.mysqlworkbench
    brewCasks."t3-code@nightly"
  ];
}
