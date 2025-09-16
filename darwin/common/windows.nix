{ pkgs, ... }:
{
  services.aerospace =
    let
      focusScript = pkgs.writeShellScriptBin "focus-script" ''
        set -euox pipefail

        if [ "$(${pkgs.lib.getExe pkgs.aerospace} list-windows --focused --format "%{app-bundle-id}")" = "com.mitchellh.ghostty" ]; then
        	${pkgs.lib.getExe pkgs.aerospace} mode terminal
        else
        	${pkgs.lib.getExe pkgs.aerospace} mode main
        fi
      '';

      floatingApps = [
        "com.raycast.macos"
        "com.apple.ActivityMonitor"
        "com.apple.iBooksX"
        "com.apple.Preview"
        "com.pattonium.Sidekick"
        "com.apple.finder"
        "com.sproutcube.Shortcat"
      ];

      appLinkedWorkspaces = [
        {
          id = "com.apple.iCal";
          bundle = "/System/Applications/Calendar.app";
          workspace = "C";
        }
        {
          id = "com.apple.Music";
          bundle = "/System/Applications/Music.app";
          workspace = "M";
        }
        {
          id = "com.apple.Podcasts";
          bundle = "/System/Applications/Podcasts.app";
          workspace = "P";
        }
        {
          id = "com.brave.Browser.app.faolnafnngnfdaknnbpnkhgohbobgegn";
          bundle = "/Users/will/Applications/Brave Browser Apps.localized/Outlook (PWA).app";
          workspace = "O";
        }
        {
          id = "com.brave.Browser.app.fmgjjmmmlfnkbppncabfkddbjimcfncm";
          bundle = "/Users/will/Applications/Brave Browser Apps.localized/Gmail.app";
          workspace = "G";
        }
      ];

      mainConfig = {
        cmd-h = [ ];
        cmd-alt-h = [ ];
        alt-r = "mode resize";
        alt-f = "layout floating tiling";

        alt-slash = "layout tiles horizontal vertical";
        alt-comma = "layout accordion horizontal vertical";

        cmd-shift-enter = ''
          exec-and-forget osascript -e 'if application "Ghostty" is not running then
          	tell application "Ghostty" to activate
          end if
          tell application "System Events" to tell process "Ghostty" to click menu item "Quick Terminal" of menu "View" of menu bar 1'
        '';

        cmd-backslash = ''
          exec-and-forget osascript -e 'if application "Brave" is not running then
          tell application "Brave" to activate
          else
          tell application "Brave" to activate
          tell application "System Events" to tell process "Brave" to click menu item "New Window" of menu "File" of menu bar 1
          end if'
        '';

        alt-h = "focus left";
        alt-j = "focus down";
        alt-k = "focus up";
        alt-l = "focus right";

        alt-shift-h = "move left";
        alt-shift-j = "move down";
        alt-shift-k = "move up";
        alt-shift-l = "move right";

        alt-ctrl-h = "join-with left";
        alt-ctrl-j = "join-with down";
        alt-ctrl-k = "join-with up";
        alt-ctrl-l = "join-with right";

        alt-1 = "workspace 1";
        alt-2 = "workspace 2";
        alt-3 = "workspace 3";
        alt-4 = "workspace 4";
        alt-5 = "workspace 5";
        alt-6 = "workspace 6";
        alt-7 = "workspace 7";
        alt-8 = "workspace 8";
        alt-9 = "workspace 9";
        alt-a = "workspace A";
        alt-b = "workspace B";
        alt-c = "workspace C";
        alt-d = "workspace D";
        alt-e = "workspace E";
        alt-g = "workspace G";
        alt-i = "workspace I";
        alt-m = "workspace M";
        alt-n = "workspace N";
        alt-o = "workspace O";
        alt-p = "workspace P";
        alt-q = "workspace Q";
        alt-s = "workspace S";
        alt-t = "workspace T";
        alt-u = "workspace U";
        alt-v = "workspace V";
        alt-w = "workspace W";
        alt-x = "workspace X";
        alt-y = "workspace Y";
        alt-z = "workspace Z";

        alt-shift-1 = "move-node-to-workspace 1";
        alt-shift-2 = "move-node-to-workspace 2";
        alt-shift-3 = "move-node-to-workspace 3";
        alt-shift-4 = "move-node-to-workspace 4";
        alt-shift-5 = "move-node-to-workspace 5";
        alt-shift-6 = "move-node-to-workspace 6";
        alt-shift-7 = "move-node-to-workspace 7";
        alt-shift-8 = "move-node-to-workspace 8";
        alt-shift-9 = "move-node-to-workspace 9";
        alt-shift-a = "move-node-to-workspace A";
        alt-shift-b = "move-node-to-workspace B";
        alt-shift-c = "move-node-to-workspace C";
        alt-shift-d = "move-node-to-workspace D";
        alt-shift-e = "move-node-to-workspace E";
        alt-shift-f = "move-node-to-workspace F";
        alt-shift-g = "move-node-to-workspace G";
        alt-shift-i = "move-node-to-workspace I";
        alt-shift-m = "move-node-to-workspace M";
        alt-shift-n = "move-node-to-workspace N";
        alt-shift-o = "move-node-to-workspace O";
        alt-shift-p = "move-node-to-workspace P";
        alt-shift-q = "move-node-to-workspace Q";
        alt-shift-s = "move-node-to-workspace S";
        alt-shift-t = "move-node-to-workspace T";
        alt-shift-u = "move-node-to-workspace U";
        alt-shift-v = "move-node-to-workspace V";
        alt-shift-w = "move-node-to-workspace W";
        alt-shift-x = "move-node-to-workspace X";
        alt-shift-y = "move-node-to-workspace Y";
        alt-shift-z = "move-node-to-workspace Z";
      }
      // builtins.listToAttrs (
        map (appLinkedWorkspace: {
          name = "alt-${pkgs.lib.toLower appLinkedWorkspace.workspace}";
          value = [
            ''exec-and-forget open "${appLinkedWorkspace.bundle}"''
            "workspace ${appLinkedWorkspace.workspace}"
          ];
        }) appLinkedWorkspaces
      );
    in
    {
      enable = true;
      settings = {
        gaps = {
          inner.horizontal = 8;
          inner.vertical = 8;
          outer.left = 8;
          outer.right = 8;
          outer.top = 2;
          outer.bottom = 6;
        };

        workspace-to-monitor-force-assignment = {
          M = "secondary";
        };

        on-focus-changed = [
          "move-mouse window-lazy-center"
          "exec-and-forget ${pkgs.lib.getExe focusScript}"
        ];

        on-window-detected = [
          {
            "if" = {
              window-title-regex-substring = "Bitwarden";
              app-id = "com.kagi.kagimacOS";
            };
            run = [
              "layout floating"
            ];
            # check-further-callbacks = true;
          }
        ]
        ++ (map (appIdStr: {
          "if" = {
            app-id = appIdStr;
          };
          run = [
            "layout floating"
          ];
        }) floatingApps)
        ++ (map (appLinkedWorkspace: {
          "if" = {
            app-id = appLinkedWorkspace.id;
          };
          run = [
            "move-node-to-workspace ${appLinkedWorkspace.workspace}"
          ];

        }) appLinkedWorkspaces);

        mode.main.binding = mainConfig // {
          cmd-enter = ''
            exec-and-forget osascript -e 'if application "Ghostty" is not running then
            	tell application "Ghostty" to activate
            else
            	tell application "Ghostty" to activate
            	tell application "System Events" to tell process "Ghostty" to click menu item "New Window" of menu "File" of menu bar 1
            end if'
          '';
        };

        mode.terminal.binding = mainConfig;

        mode.resize.binding = {
          backspace = "balance-sizes";
          shift-backspace = "flatten-workspace-tree";
          minus = "resize smart -20";
          equal = "resize smart +20";
          leftSquareBracket = "resize smart-opposite -20";
          rightSquareBracket = "resize smart-opposite +20";
          esc = "exec-and-forget ${pkgs.lib.getExe focusScript}";

          h = "join-with left";
          j = "join-with down";
          k = "join-with up";
          l = "join-with right";
        };
      };
    };
}
