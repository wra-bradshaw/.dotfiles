{ pkgs, ... }:
{
  services.neru = {
    enable = true;
    package = pkgs.neru-source;
    config = ''
      # ============================================================================
      # General Settings
      # ============================================================================
      [general]
      restore_cursor_position = true

      # ============================================================================
      # Hotkeys
      # ============================================================================
      [hotkeys]
      "Ctrl+F" = "grid"               # Grid navigation
      "Ctrl+S" = "scroll"             # Scroll mode

      # ============================================================================
      # Hints
      # ============================================================================
      [hints]
      enabled = false  # Disabled in favor of grid navigation

      # ============================================================================
      # Grid Navigation
      # ============================================================================
      [grid]
      font_family = "FiraCode Nerd Font"
      characters = "fdsageiruvmtycnwoqpxzb" # Dvorak-optimized character set
      sublayer_keys = "weruioxcv"
      opacity = 0.5

      # ============================================================================
      # Actions
      # ============================================================================
      [action]
      move_mouse_step = 10

      [action.key_bindings]
      left_click = "Shift+H"     # Index finger (Strongest)
      middle_click = "Shift+K"   # Middle finger
      right_click = "Shift+L"    # Ring finger
      mouse_down = "Shift+M"     # Below index finger
      mouse_up = "Shift+I"       # Above middle finger
      move_mouse_left = "H"
      move_mouse_down = "J"
      move_mouse_up = "K"
      move_mouse_right = "L"

      # ============================================================================
      # Smooth Cursor Movement
      # ============================================================================
      [smooth_cursor]
      move_mouse_enabled = true
      steps = 10
      delay = 1

      # ============================================================================
      # Logging
      # ============================================================================
      [logging]
      log_level = "info"
      disable_file_logging = true
    '';
  };
}
