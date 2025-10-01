{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.macos-wallpaper;
in
{
  options.services.macos-wallpaper = {
    enable = lib.mkEnableOption "macOS wallpaper service";
    image = lib.mkOption {
      type = lib.types.path;
      description = "Path to the wallpaper image file";
    };
  };

  config = lib.mkIf (cfg.enable && pkgs.stdenv.isDarwin) {
    launchd.agents.macos-wallpaper = {
      enable = true;
      config = {
        ProgramArguments = [
          "${pkgs.macos-wallpaper}/bin/wallpaper"
          "set"
          (builtins.toString cfg.image)
        ];
        RunAtLoad = true;
        KeepAlive = false;
      };
    };
  };
}
