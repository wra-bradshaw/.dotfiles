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
          workspace = "C";
          apps = [
            {
              id = "com.apple.iCal";
              bundle = "/System/Applications/Calendar.app";
            }
          ];
        }
        {
          workspace = "A";
          apps = [
            {
              id = "jan.ai.app";
              bundle = "${pkgs.brewCasks.jan}/Applications/Jan.app";
            }
          ];
        }
        {
          workspace = "S";
          apps = [
            {
              id = "com.apple.stocks";
              bundle = "/System/Applications/Stocks.app";
            }
          ];
        }
        {
          workspace = "M";
          apps = [
            {
              id = "com.apple.Music";
              bundle = "/System/Applications/Music.app";
            }
          ];
        }
        {
          workspace = "P";
          apps = [
            {
              bundle = "/System/Applications/Podcasts.app";
              workspace = "P";
            }
          ];
        }
        {
          workspace = "O";
          apps = [
            {
              id = "net.imput.helium.app.faolnafnngnfdaknnbpnkhgohbobgegn";
              bundle = "/Users/will/Applications/Helium Apps.localized/Outlook (PWA).app";
            }
          ];
        }
        {
          workspace = "G";
          apps = [
            {
              id = "net.imput.helium.app.fmgjjmmmlfnkbppncabfkddbjimcfncm";
              bundle = "/Users/will/Applications/Helium Apps.localized/Gmail.app";
              workspace = "G";
            }
          ];
        }
        {
          workspace = "I";
          apps = [
            {
              id = "com.apple.MobileSMS";
              bundle = "/System/Applications/Messages.app";
            }
          ];

        }
      ];

      mainConfig = {
        cmd-h = [ ];
        cmd-alt-h = [ ];
        alt-r = "mode resize";
        alt-f = "layout floating tiling";

        alt-slash = "layout tiles horizontal vertical";
        alt-comma = "layout accordion horizontal vertical";

        # ctrl-n = ''
        #   exec-and-forget osascript -e 'tell application "Finder" to activate
        #   tell application "System Events" to tell process "Finder" to click menu item "New Finder Window" of menu "File" of menu bar 1'
        # '';
        #
        ctrl-backslash = ''
          exec-and-forget osascript -e 'if application "Helium" is not running then
          	tell application "Helium" to activate
          else
          	tell application "Helium" to activate
          	tell application "System Events" to tell process "Helium" to click menu item "New Window" of menu "File" of menu bar 1
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
        map (ws: {
          name = "alt-${pkgs.lib.toLower ws.workspace}";
          value =
            (map (app: ''exec-and-forget open "${app.bundle}"'') (
              builtins.filter (a: a ? bundle) (ws.apps or [ ])
            ))
            ++ [ "workspace ${ws.workspace}" ];
        }) appLinkedWorkspaces
      );
    in
    {
      enable = false;
      settings = {
        workspace-to-monitor-force-assignment = {
          E = "secondary";
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
        ++ (builtins.concatMap (
          ws:
          (map (app: {
            "if" = {
              app-id = app.id;
            };
            run = [
              "move-node-to-workspace ${app.workspace or ws.workspace}"
            ];
          }) (builtins.filter (a: a ? id) (ws.apps or [ ])))
        ) appLinkedWorkspaces);

        mode.main.binding = mainConfig // {
          ctrl-enter = ''
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
