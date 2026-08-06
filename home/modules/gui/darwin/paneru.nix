{ osConfig, ... }:
let
  heliumApps = osConfig.programs.helium.webApps;
in
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
        music = {
          title = ".*";
          bundle_id = "com.apple.Music";
          grid = "12:12:3:1:6:4";
          floating = true;
        };
        gmail = {
          title = ".*";
          bundle_id = heliumApps.gmail.expectedBundleId;
          grid = "12:12:2:1:8:10";
          floating = true;
        };
        outlook = {
          title = ".*";
          bundle_id = heliumApps.outlook.expectedBundleId;
          grid = "12:12:2:1:8:10";
          floating = true;
        };
        calendar = {
          title = ".*";
          bundle_id = "com.apple.iCal";
          grid = "12:12:2:1:8:10";
          floating = true;
        };
        ghostty = {
          title = ".*";
          bundle_id = "com.mitchellh.ghostty";
          width = 0.66;
        };
        harvest = {
          title = ".*";
          bundle_id = "com.getharvest.harvestxapp";
          floating = true;
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
          grid = "12:12:5:2:4:6";
        };
        system_prefs = {
          title = ".*";
          bundle_id = "com.apple.systempreferences";
          floating = true;
          grid = "12:12:3:2:6:6";
        };
        finder = {
          title = ".*";
          bundle_id = "com.apple.finder";
          floating = true;
          grid = "12:12:3:2:6:6";
        };
        activity_monitor = {
          title = ".*";
          bundle_id = "com.apple.ActivityMonitor";
          floating = true;
          grid = "12:12:3:2:6:6";
        };
        iphone_mirroing = {
          title = ".*";
          bundle_id = "com.apple.ScreenContinuity";
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
        window_grow = "alt - .";
        window_shrink = "alt - ,";
        window_fullwidth = "alt + shift - f";
        window_manage = "alt - f";
        window_togglefloatlayer = "alt - space";
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
