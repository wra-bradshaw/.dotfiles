{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.open-webui;
in
{
  options.services.open-webui = {
    enable = lib.mkEnableOption "open-webui";

    stateDir = lib.mkOption {
      type = lib.types.path;
      example = "~/.local/state/open-webui";
      description = ''
        The directory where the Open-WebUI server state is stored.
      '';
    };

    environment = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = ''
        The environment variables to set for the Open-WebUI server.
      '';
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.open-webui;
      defaultText = lib.literalExpression "pkgs.open-webui";
      description = "The open-webui package to use.";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      example = "127.0.0.1";
      description = ''
        The host address which the Open-WebUI server HTTP interface listens to.
      '';
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      example = 8080;
      description = ''
        Which port the Open-WebUI server listens to.
      '';
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.mkIf pkgs.stdenv.isDarwin {
        launchd.agents.open-webui = {
          enable = true;
          config = {
            ProgramArguments = [
              (lib.getExe cfg.package)
              "serve"
              "--host"
              cfg.host
              "--port"
              "${toString cfg.port}"
            ];
            WorkingDirectory = toString cfg.stateDir;
            EnvironmentVariables = {
              "STATIC_DIR" = ".";
              "DATA_DIR" = ".";
              "HF_HOME" = ".";
              "SENTENCE_TRANSFORMERS_HOME" = ".";
              "WEBUI_URL" = "http://localhost:${toString cfg.port}";
            } // cfg.environment;
            KeepAlive = true;
            RunAtLoad = true;
          };
        };
      })
    ]
  );
}
