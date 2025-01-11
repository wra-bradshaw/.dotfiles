{ config, ... }: {
  programs.alacritty = {
    enable = true;
    settings = {
      keyboard = {
        bindings = [{
          key = "Return";
          mods = "Super";
          action = "CreateNewWindow";
        }];
      };
      font = {
        normal = { family = "FiraCode Nerd Font"; };

      };
      colors = {
        primary = {
          background = "0x${config.colorScheme.palette.base00}";
          foreground = "0x${config.colorScheme.palette.base05}";
        };
        cursor = {
          text = "0x${config.colorScheme.palette.base00}";
          cursor = "0x${config.colorScheme.palette.base05}";
        };
        normal = {
          black = "0x${config.colorScheme.palette.base00}";
          red = "0x${config.colorScheme.palette.base08}";
          green = "0x${config.colorScheme.palette.base0B}";
          yellow = "0x${config.colorScheme.palette.base0A}";
          blue = "0x${config.colorScheme.palette.base0D}";
          magenta = "0x${config.colorScheme.palette.base0E}";
          cyan = "0x${config.colorScheme.palette.base0C}";
          white = "0x${config.colorScheme.palette.base05}";
        };
        bright = {
          black = "0x${config.colorScheme.palette.base03}";
          red = "0x${config.colorScheme.palette.base08}";
          green = "0x${config.colorScheme.palette.base0B}";
          yellow = "0x${config.colorScheme.palette.base0A}";
          blue = "0x${config.colorScheme.palette.base0D}";
          magenta = "0x${config.colorScheme.palette.base0E}";
          cyan = "0x${config.colorScheme.palette.base0C}";
          white = "0x${config.colorScheme.palette.base07}";
        };
      };
    };
  };
}
