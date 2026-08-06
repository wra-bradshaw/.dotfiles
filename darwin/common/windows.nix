{ pkgs, ... }:
{
  services.skhd = {
    enable = true;
    skhdConfig = ''
      alt - s : ${pkgs.snap}/bin/snap capture
      ctrl - 0x2A [
        "Helium" : /usr/bin/osascript \
          -e 'tell application "Helium" to activate' \
          -e 'tell application "System Events" to tell process "Helium" to click menu item "New Window" of menu "File" of menu bar 1'
        * : /usr/bin/open -na ~/Applications/Home\ Manager\ Apps/Helium.app
      ]
      ctrl - return [
        "Ghostty" ~
        * : /usr/bin/open -na ~/Applications/Home\ Manager\ Apps/Ghostty.app
      ]
    '';
  };
}
