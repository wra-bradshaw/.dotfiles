{ pkgs, config, ... }:
{
  programs.ghostty = {
    enable = true;
    package = pkgs.brewCasks.ghostty;
    settings = {
      theme = "default";
      font-family = "FiraCode Nerd Font";
      keybind = [
        "super+enter=new_window"
        "ctrl+tab=unbind"
      ];
    };
    themes = {
      default = {
        palette = [
          "0=#${config.colorScheme.palette.base00}"
          "1=#${config.colorScheme.palette.base08}"
          "2=#${config.colorScheme.palette.base0B}"
          "3=#${config.colorScheme.palette.base0A}"
          "4=#${config.colorScheme.palette.base0D}"
          "5=#${config.colorScheme.palette.base0E}"
          "6=#${config.colorScheme.palette.base0C}"
          "7=#${config.colorScheme.palette.base05}"
          "8=#${config.colorScheme.palette.base03}"
          "9=#${config.colorScheme.palette.base08}"
          "10=#${config.colorScheme.palette.base0B}"
          "11=#${config.colorScheme.palette.base0A}"
          "12=#${config.colorScheme.palette.base0D}"
          "13=#${config.colorScheme.palette.base0E}"
          "14=#${config.colorScheme.palette.base0C}"
          "15=#${config.colorScheme.palette.base07}"
        ];

        background = "#${config.colorScheme.palette.base00}";
        foreground = "#${config.colorScheme.palette.base05}";
        cursor-color = "#${config.colorScheme.palette.base05}";
        selection-background = "#${config.colorScheme.palette.base02}";
        selection-foreground = "#${config.colorScheme.palette.base05}";
      };
    };

    enableZshIntegration = true;
  };
}
