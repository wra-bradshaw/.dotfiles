{ pkgs, ... }:
let
  newAppWindowScript =
    appName: processName:
    pkgs.writeShellScript "new-${processName}-window" ''
      set -euo pipefail

      if pgrep -x ${processName} > /dev/null; then
        frontmost_app=$(/usr/bin/osascript -e 'tell application "System Events" to name of first application process whose frontmost is true')

        if [ "$frontmost_app" != "${appName}" ]; then
          /usr/bin/osascript -e 'tell application "${appName}" to activate'
        fi

        /usr/bin/osascript -e 'tell application "System Events" to tell process "${appName}" to click menu item "New Window" of menu "File" of menu bar 1'
      else
        /usr/bin/open -na "$HOME/Applications/Home Manager Apps/${appName}.app"
      fi
    '';
in
{
  services.rift = {
    enable = false;
    config = ''
      # rift config

      [settings]
      animate = true
      animation_duration = 0.3
      animation_fps = 100.0

      default_disable = false
      focus_follows_mouse = true
      mouse_follows_focus = true
      mouse_hides_on_focus = true
      auto_focus_blacklist = []
      run_on_start = []
      hot_reload = true

      [settings.layout]
      mode = "scrolling"

      [settings.layout.master_stack]
      master_ratio = 0.6
      master_count = 1
      master_side = "left"
      new_window_placement = "master"

      [settings.layout.scrolling]
      column_width_ratio = 0.7
      min_column_width_ratio = 0.3
      max_column_width_ratio = 0.9
      alignment = "center"
      focus_navigation_style = "niri"

      [settings.layout.scrolling.gestures]
      enabled = true
      invert_horizontal = true
      fingers = 3
      propagate_to_workspace_swipe = false

      [settings.layout.stack]
      stack_offset = 40.0
      default_orientation = "perpendicular"

      [settings.layout.gaps]
      [settings.layout.gaps.outer]
      top = 0
      left = 0
      bottom = 0
      right = 0

      [settings.layout.gaps.inner]
      horizontal = 0
      vertical = 0

      [settings.ui.menu_bar]
      enabled = true
      show_empty = false
      mode = "all"
      active_label = "index"
      display_style = "layout"

      [settings.ui.stack_line]
      enabled = false
      horiz_placement = "top"
      vert_placement = "left"
      thickness = 20.0
      spacing = 1.0

      [settings.ui.mission_control]
      enabled = false
      fade_enabled = false
      fade_duration_ms = 180.0

      [settings.gestures]
      enabled = false
      invert_horizontal_swipe = false
      swipe_vertical_tolerance = 0.4
      skip_empty = true
      fingers = 3
      distance_pct = 0.08
      haptics_enabled = true
      haptic_pattern = "level_change"

      [settings.window_snapping]
      drag_swap_fraction = 0.3

      [virtual_workspaces]
      enabled = true
      # Bumped up to 10 workspaces
      default_workspace_count = 10
      auto_assign_windows = true
      preserve_focus_per_workspace = true
      workspace_auto_back_and_forth = false
      reapply_app_rules_on_title_change = false

      workspace_rules = []
      # Letting Rift automatically name them Workspace 1-10

      app_rules = []

      [modifier_combinations]
      comb1 = "Alt + Shift"

      [keys]
      "Ctrl + Backslash" = { exec = ["${newAppWindowScript "Helium" "Helium"}"] }
      "Ctrl + Return" = { exec = ["${newAppWindowScript "Ghostty" "ghostty"}"] }

      # --- Focus Window (Alt + hjkl) ---
      "Alt + H" = { move_focus = "left" }
      "Alt + J" = { move_focus = "down" }
      "Alt + K" = { move_focus = "up" }
      "Alt + L" = { move_focus = "right" }

      # --- Move Window (Alt + Shift + hjkl) ---
      "Alt + Shift + H" = { move_node = "left" }
      "Alt + Shift + J" = { move_node = "down" }
      "Alt + Shift + K" = { move_node = "up" }
      "Alt + Shift + L" = { move_node = "right" }

      # --- Join/Group Windows (Alt + Ctrl + hjkl) ---
      "Alt + Ctrl + H" = { join_window = "left" }
      "Alt + Ctrl + J" = { join_window = "down" }
      "Alt + Ctrl + K" = { join_window = "up" }
      "Alt + Ctrl + L" = { join_window = "right" }

      # --- Column & Layout Toggles ---
      "Alt + T" = "toggle_stack" # Toggle Column Tabbed equivalent
      "Alt + Shift + F" = "toggle_fullscreen_within_gaps" # Toggle Column Full Width
      "Alt + F" = "toggle_fullscreen"
      "Alt + Shift + Space" = "toggle_window_floating"
      "Alt + Ctrl + Space" = "toggle_focus_floating"

      # --- Cycle Column Width (Resize) ---
      "Alt + Period" = "resize_window_grow"
      "Alt + Comma" = "resize_window_shrink"

      # --- Switch Workspaces (Alt + 1-0) ---
      "Alt + 1" = { switch_to_workspace = 0 }
      "Alt + 2" = { switch_to_workspace = 1 }
      "Alt + 3" = { switch_to_workspace = 2 }
      "Alt + 4" = { switch_to_workspace = 3 }
      "Alt + 5" = { switch_to_workspace = 4 }
      "Alt + 6" = { switch_to_workspace = 5 }
      "Alt + 7" = { switch_to_workspace = 6 }
      "Alt + 8" = { switch_to_workspace = 7 }
      "Alt + 9" = { switch_to_workspace = 8 }
      "Alt + 0" = { switch_to_workspace = 9 }

      # --- Move Window to Workspaces (Alt + Shift + 1-0) ---
      "Alt + Shift + 1" = { move_window_to_workspace = 0 }
      "Alt + Shift + 2" = { move_window_to_workspace = 1 }
      "Alt + Shift + 3" = { move_window_to_workspace = 2 }
      "Alt + Shift + 4" = { move_window_to_workspace = 3 }
      "Alt + Shift + 5" = { move_window_to_workspace = 4 }
      "Alt + Shift + 6" = { move_window_to_workspace = 5 }
      "Alt + Shift + 7" = { move_window_to_workspace = 6 }
      "Alt + Shift + 8" = { move_window_to_workspace = 7 }
      "Alt + Shift + 9" = { move_window_to_workspace = 8 }
      "Alt + Shift + 0" = { move_window_to_workspace = 9 }

      # --- Previous Workspace (Back and Forth) ---
      "Ctrl + Alt + Tab" = "switch_to_last_workspace"

      # --- Mission Control / Overview ---
      "Alt + Shift + O" = "show_mission_control_all"

      # ---------------------------------------------------------
      # General Rift Utility Keybinds
      # ---------------------------------------------------------
      "Alt + Z" = "toggle_space_activated"
      "Alt + Slash" = "toggle_orientation"
      "Alt + Ctrl + E" = "unjoin_windows"

      "Alt + Shift + D" = "debug"
      "Alt + Ctrl + S" = "serialize"
      "Alt + Ctrl + Q" = "save_and_exit"
    '';

  };

}
