{
  config,
  pkgs,
  ...
}:
let
  niriConfig = pkgs.writeText "niri-config.kdl" ''
    input {
      keyboard {
        xkb {
          layout "us"
        }
      }
      touchpad {
        tap
        natural-scroll
      }
    }

    layout {
      gaps 8
      center-focused-column "never"
      default-column-width {
        proportion 0.66
      }
      focus-ring {
        width 2
        active-color "#${config.colorScheme.palette.base0D}"
      }
      border {
        off
      }
    }

    prefer-no-csd
    screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

    spawn-at-startup "waybar"
    spawn-at-startup "xwayland-satellite"
    spawn-at-startup "swaybg" "-c" "#1a1b26"

    binds {
      Mod+Return { spawn "ghostty"; }
      Mod+D { spawn "fuzzel"; }
      Mod+Shift+E { quit; }
      Mod+Q { close-window; }
      Mod+H { focus-column-left; }
      Mod+J { focus-window-down; }
      Mod+K { focus-window-up; }
      Mod+L { focus-column-right; }
      Mod+Shift+H { move-column-left; }
      Mod+Shift+J { move-window-down; }
      Mod+Shift+K { move-window-up; }
      Mod+Shift+L { move-column-right; }
      Mod+F { maximize-column; }
      Mod+Shift+F { fullscreen-window; }
      Mod+Space { toggle-window-floating; }
      Mod+1 { focus-workspace 1; }
      Mod+2 { focus-workspace 2; }
      Mod+3 { focus-workspace 3; }
      Mod+4 { focus-workspace 4; }
      Mod+5 { focus-workspace 5; }
      Mod+6 { focus-workspace 6; }
      Mod+7 { focus-workspace 7; }
      Mod+8 { focus-workspace 8; }
      Mod+9 { focus-workspace 9; }
      Mod+Shift+1 { move-column-to-workspace 1; }
      Mod+Shift+2 { move-column-to-workspace 2; }
      Mod+Shift+3 { move-column-to-workspace 3; }
      Mod+Shift+4 { move-column-to-workspace 4; }
      Mod+Shift+5 { move-column-to-workspace 5; }
      Mod+Shift+6 { move-column-to-workspace 6; }
      Mod+Shift+7 { move-column-to-workspace 7; }
      Mod+Shift+8 { move-column-to-workspace 8; }
      Mod+Shift+9 { move-column-to-workspace 9; }
      Mod+Shift+S { screenshot; }
      Mod+Alt+L { spawn "swaylock" "-f"; }
      XF86AudioRaiseVolume { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"; }
      XF86AudioLowerVolume { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
      XF86AudioMute { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
    }
  '';
in
{
  xdg.configFile."niri/config.kdl".source =
    pkgs.runCommand "niri-config-checked"
      {
        nativeBuildInputs = [ pkgs.niri ];
      }
      ''
        niri validate --config ${niriConfig}
        cp ${niriConfig} "$out"
      '';

  programs.waybar = {
    enable = true;
    systemd.enable = false;
    settings.mainBar = {
      layer = "top";
      modules-left = [ "niri/workspaces" ];
      modules-center = [ "niri/window" ];
      modules-right = [
        "pulseaudio"
        "network"
        "clock"
        "tray"
      ];
      clock.format = "{:%a %d %b  %H:%M}";
    };
  };
  services.mako = {
    enable = true;
    settings = {
      background-color = "#${config.colorScheme.palette.base01}";
      border-color = "#${config.colorScheme.palette.base0D}";
      text-color = "#${config.colorScheme.palette.base05}";
    };
  };
  services.swayidle = {
    enable = true;
    events = {
      before-sleep = "${pkgs.swaylock}/bin/swaylock -f";
      lock = "${pkgs.swaylock}/bin/swaylock -f";
    };
    timeouts = [
      {
        timeout = 600;
        command = "${pkgs.swaylock}/bin/swaylock -f";
      }
    ];
  };
}
