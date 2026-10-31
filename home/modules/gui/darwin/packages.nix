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
    # brewCasks.claude ships bin/claude shim that collides with claude-code's
    # bin/claude; deprioritize so the CLI wins and the .app still installs.
    (lib.lowPrio brewCasks.claude)
    brewCasks.mysqlworkbench
    brewCasks."t3-code@nightly"
  ];
}
