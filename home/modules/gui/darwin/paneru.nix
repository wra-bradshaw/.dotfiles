{ osConfig, ... }:
let
  heliumApps = osConfig.programs.helium.webApps;
in
{
  services.paneru = {
    enable = true;
    luaConfig.enable = true;
    config = ''
      paneru.setup {
        options = {
          focus_follows_mouse = true,
          mouse_follows_focus = true,
          preset_column_widths = { 0.33, 0.50, 0.66, 1.0 },
          animation_speed = 20.0,
        },
        windows = {
          music = {
            title = ".*",
            bundle_id = "com.apple.Music",
            grid = "12:12:3:1:6:4",
            floating = true,
          },
          gmail = {
            title = ".*",
            bundle_id = "${heliumApps.gmail.expectedBundleId}",
            grid = "12:12:2:1:8:10",
            floating = true,
          },
          outlook = {
            title = ".*",
            bundle_id = "${heliumApps.outlook.expectedBundleId}",
            grid = "12:12:2:1:8:10",
            floating = true,
          },
          calendar = {
            title = ".*",
            bundle_id = "com.apple.iCal",
            grid = "12:12:2:1:8:10",
            floating = true,
          },
          ghostty = {
            title = ".*",
            bundle_id = "com.mitchellh.ghostty",
            width = 0.66,
          },
          harvest = {
            title = ".*",
            bundle_id = "com.getharvest.harvestxapp",
            floating = true,
          },
          helium = {
            title = ".*",
            bundle_id = "net.imput.helium",
            width = 0.66,
          },
          bitwarden = {
            title = "Bitwarden",
            bundle_id = "net.imput.helium",
            floating = true,
            grid = "12:12:5:2:4:6",
          },
          system_prefs = {
            title = ".*",
            bundle_id = "com.apple.systempreferences",
            floating = true,
            grid = "12:12:3:2:6:6",
          },
          finder = {
            title = ".*",
            bundle_id = "com.apple.finder",
            floating = true,
            grid = "12:12:3:2:6:6",
          },
          activity_monitor = {
            title = ".*",
            bundle_id = "com.apple.ActivityMonitor",
            floating = true,
            grid = "12:12:3:2:6:6",
          },
          iphone_mirroing = {
            title = ".*",
            bundle_id = "com.apple.ScreenContinuity",
            floating = true,
          },
          photo_booth = {
            title = ".*",
            bundle_id = "com.apple.PhotoBooth",
            floating = true,
          },
          calculator = {
            title = ".*",
            bundle_id = "com.apple.calculator",
            floating = true,
          },
        },
        swipe = {
          continuous = false,
          gesture = { fingers_count = 3 },
        },
        bindings = {
          ["window focus west"] = "alt - h",
          ["window focus east"] = "alt - l",
          ["window focus north"] = "alt - k",
          ["window focus south"] = "alt - j",
          ["window swap west"] = "alt + shift - h",
          ["window swap east"] = "alt + shift - l",
          ["window swap north"] = "alt + shift - k",
          ["window swap south"] = "alt + shift - j",
          ["window grow"] = "alt - .",
          ["window shrink"] = "alt - ,",
          ["window fullwidth"] = "alt + shift - f",
          ["window manage"] = "alt - f",
          ["window togglefloatlayer"] = "alt - space",
          ["window stack"] = "alt - [",
          ["window unstack"] = "alt - ]",
          ["window virtual north"] = "cmd + shift - k",
          ["window virtual south"] = "cmd + shift - j",
          ["window virtualmove north"] = "cmd + alt - k",
          ["window virtualmove south"] = "cmd + alt - j",
          ["quit"] = "ctrl + alt - q",
          ["window virtualnum 1"] = "alt - 1",
          ["window virtualnum 2"] = "alt - 2",
          ["window virtualnum 3"] = "alt - 3",
          ["window virtualnum 4"] = "alt - 4",
          ["window virtualnum 5"] = "alt - 5",
          ["window virtualmovenum 1"] = "alt + shift - 1",
          ["window virtualmovenum 2"] = "alt + shift - 2",
          ["window virtualmovenum 3"] = "alt + shift - 3",
          ["window virtualmovenum 4"] = "alt + shift - 4",
          ["window virtualmovenum 5"] = "alt + shift - 5",
        },
      }
    '';
  };
}
