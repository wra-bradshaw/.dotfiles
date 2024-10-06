{ pkgs, config, ... }:
{
  # this file is used by wallpaper launch agent
  home.file = {
    ".config/wallpaper/colors.json".text = builtins.toJSON [
      config.colorScheme.palette.base01
      config.colorScheme.palette.base0E
      config.colorScheme.palette.base0B
      config.colorScheme.palette.base05
      config.colorScheme.palette.base06
      config.colorScheme.palette.base0C
      config.colorScheme.palette.base04
      config.colorScheme.palette.base07
      config.colorScheme.palette.base0A
    ];
  };
}
