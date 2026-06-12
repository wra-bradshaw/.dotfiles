{ ... }:
{
  services.paneru = {
    enable = true;
    settings = {
      options = {
        focus_follows_mouse = true;
        mouse_follows_focus = true;
        preset_column_widths = [
          0.33
          0.50
          0.66
          1.00
        ];
        animation_speed = 20;
      };
      windows = {
        ghostty = {
          title = ".*";
          bundle_id = "com.mitchellh.ghostty";
          width = 0.66;
        };
        helium = {
          title = ".*";
          bundle_id = "net.imput.helium";
          width = 0.66;
        };
        bitwarden = {
          title = "Bitwarden";
          bundle_id = "net.imput.helium";
          floating = true;
        };
        system_prefs = {
          title = ".*";
          bundle_id = "com.apple.systempreferences";
          floating = true;
        };
        finder = {
          title = ".*";
          bundle_id = "com.apple.finder";
          floating = true;
        };
        activity_monitor = {
          title = ".*";
          bundle_id = "com.apple.ActivityMonitor";
          floating = true;
        };
        iphone_mirroing = {
          title = ".*";
          bundle_id = "com.apple.iphonesimulator";
          floating = true;
        };
        photo_booth = {
          title = ".*";
          bundle_id = "com.apple.PhotoBooth";
          floating = true;
        };
        calculator = {
          title = ".*";
          bundle_id = "com.apple.calculator";
          floating = true;
        };
      };
      swipe = {
        continuous = false;
        gesture.fingers_count = 3;
      };
      bindings = {
        window_focus_west = "alt - h";
        window_focus_east = "alt - l";
        window_focus_north = "alt - k";
        window_focus_south = "alt - j";
        window_swap_west = "alt + shift - h";
        window_swap_east = "alt + shift - l";
        window_swap_north = "alt + shift - k";
        window_swap_south = "alt + shift - j";
        window_center = "alt - c";
        window_grow = "alt - .";
        window_shrink = "alt - ,";
        window_fullwidth = "alt + shift - f";
        window_manage = "alt - f";
        window_stack = "alt - [";
        window_unstack = "alt - ]";
        window_virtual_north = "cmd + shift - k";
        window_virtual_south = "cmd + shift - j";
        window_virtualmove_north = "cmd + alt - k";
        window_virtualmove_south = "cmd + alt - j";
        quit = "ctrl + alt - q";
        window_virtualnum_1 = "alt - 1";
        window_virtualnum_2 = "alt - 2";
        window_virtualnum_3 = "alt - 3";
        window_virtualnum_4 = "alt - 4";
        window_virtualnum_5 = "alt - 5";
        window_virtualmovenum_1 = "alt + shift - 1";
        window_virtualmovenum_2 = "alt + shift - 2";
        window_virtualmovenum_3 = "alt + shift - 3";
        window_virtualmovenum_4 = "alt + shift - 4";
        window_virtualmovenum_5 = "alt + shift - 5";
      };
    };
  };
}
