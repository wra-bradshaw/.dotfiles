{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.pi-coding-agent;
in
{
  options.programs.pi-coding-agent = {
    enable = lib.mkEnableOption "Pi coding agent";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.pi-coding-agent;
      defaultText = lib.literalExpression "pkgs.pi-coding-agent";
      description = ''
        Package providing the `pi` executable.
      '';
    };

    settings = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
      description = "Settings written to {file}`~/.pi/agent/settings.json`.";
      example = {
        theme = "light";
        defaultProvider = "anthropic";
        defaultThinkingLevel = "medium";
        enableInstallTelemetry = false;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.file.".pi/agent/settings.json" = lib.mkIf (cfg.settings != { }) {
      text = builtins.toJSON cfg.settings;
    };
  };
}
