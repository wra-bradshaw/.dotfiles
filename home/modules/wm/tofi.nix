{ pkgs, config, ... }:
{
  home.packages = with pkgs; [ tofi ];

  wayland.windowManager.hyprland.settings = {
    bindr = [ "SUPER, D, exec, tofi-drun | xargs hyprctl dispatch exec --" ];
  };

  home.file = {
    ".config/tofi/config".text = ''
      font = "${pkgs.nerd-fonts.fira-code}/share/fonts/truetype/NerdFonts/FiraCode/FiraCodeNerdFont-Regular.ttf"
      width = 100%
      height = 100%
      border-width = 0
      outline-width = 0
      text-cursor = true
      padding-left = 35%
      padding-top = 35%
      result-spacing = 25
      num-results = 5
      background-color = #${config.colorScheme.palette.base00}99
      default-result-background = #${config.colorScheme.palette.base00}
      default-result-color = #${config.colorScheme.palette.base03}
      default-result-background-padding = 10
      selection-background = #${config.colorScheme.palette.base02}
      selection-background-padding = 10
      selection-color = #${config.colorScheme.palette.base0E}
      selection-match-color = #${config.colorScheme.palette.base0C}
      input-color = #${config.colorScheme.palette.base0C}
      prompt-text = "run "
      prompt-color = #${config.colorScheme.palette.base05}
      result-spacing = 30
    '';
  };
}
