{ pkgs, ... }:
let
  # Open a window in the running Rex app rather than launching a second instance.
  rexNewWindow = pkgs.writeShellScript "rex-new-window" ''
    app="$HOME/Applications/Home Manager Apps/Rex Beta.app"
    rex="$app/Contents/Helpers/Rex Server.rex/Contents/MacOS/rex"
    client=$("$rex" client ls --json 2>/dev/null | ${pkgs.jq}/bin/jq -r '
      first(.clients[]
        | select(.info.kind == "app" and .connection_state == "connected"
                 and .principal.transport == "unix")
        | .client_id) // empty')
    [ -n "$client" ] && "$rex" -C "$client" do client.window.new >/dev/null 2>&1
    /usr/bin/open -a "$app"
  '';
in
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
        "Rex Beta" ~
        * : ${rexNewWindow}
      ]
    '';
  };
}
