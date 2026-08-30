let
  # The pinned neru Home Manager module still uses deprecated stdenv aliases.
  neruModule =
    {
      config,
      flake,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.services.neru;
      tomlFormat = pkgs.formats.toml { };
      defaultConfig = builtins.readFile "${flake.inputs.neru}/configs/default-config.toml";
      defaultPath = lib.concatStringsSep ":" (
        [
          "${config.home.homeDirectory}/.nix-profile/bin"
          "/etc/profiles/per-user/${config.home.username}/bin"
          "/run/current-system/sw/bin"
          "/nix/var/nix/profiles/default/bin"
          "/usr/local/bin"
          "/usr/bin"
          "/bin"
        ]
        ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [ "/opt/homebrew/bin" ]
      );
      effectiveEnv = {
        PATH = defaultPath;
      }
      // cfg.extraEnvironment;
    in
    {
      options.services.neru = {
        enable = lib.mkEnableOption "Neru keyboard navigation";

        package = lib.mkPackageOption pkgs "neru" { };

        config = lib.mkOption {
          type = lib.types.lines;
          default = defaultConfig;
          description = "Configuration for neru/config.toml.";
        };

        configFile = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = "Path to an existing config.toml file.";
        };

        settings = lib.mkOption {
          inherit (tomlFormat) type;
          default = { };
          description = "Neru configuration as Nix data.";
        };

        launchd = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to configure a launchd agent for Neru.";
          };
          keepAlive = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether the launchd service should be kept alive.";
          };
        };

        extraEnvironment = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = { };
          description = "Additional environment variables for the Neru service.";
        };

        systemd = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to configure a systemd user service for Neru.";
          };
          restart = lib.mkOption {
            type = lib.types.str;
            default = "on-failure";
            description = "Systemd restart policy for Neru.";
          };
          restartSec = lib.mkOption {
            type = lib.types.int;
            default = 5;
            description = "Seconds to wait before restarting Neru.";
          };
        };
      };

      config = lib.mkIf cfg.enable {
        home.packages = [ cfg.package ];

        xdg.configFile."neru/config.toml" =
          if cfg.configFile != null then
            { source = cfg.configFile; }
          else if cfg.settings != { } then
            { source = tomlFormat.generate "config.toml" cfg.settings; }
          else
            { text = cfg.config; };

        launchd.agents.neru = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
          enable = cfg.launchd.enable;
          config = {
            ProgramArguments = [
              "${cfg.package}/Applications/Neru.app/Contents/MacOS/neru"
              "launch"
              "--config"
              "${config.xdg.configHome}/neru/config.toml"
            ];
            EnvironmentVariables = effectiveEnv;
            RunAtLoad = true;
            KeepAlive = cfg.launchd.keepAlive;
            StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/neru/daemon.err.log";
            ProcessType = "Interactive";
            LimitLoadToSessionType = "Aqua";
            Nice = -10;
            ThrottleInterval = 10;
          };
        };

        systemd.user.services.neru = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux && cfg.systemd.enable) {
          Unit = {
            Description = "Neru keyboard navigation daemon";
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
          };
          Service = {
            ExecStart = "${cfg.package}/bin/neru launch --config ${config.xdg.configHome}/neru/config.toml";
            Environment = lib.mapAttrsToList (k: v: "${k}=${v}") effectiveEnv;
            Restart = cfg.systemd.restart;
            RestartSec = cfg.systemd.restartSec;
            Nice = "-10";
          };
          Install = {
            WantedBy = [ "graphical-session.target" ];
          };
        };

        assertions = [
          {
            assertion =
              (lib.count (x: x) [
                (cfg.settings != { })
                (cfg.configFile != null)
                (cfg.config != defaultConfig)
              ]) <= 1;
            message = ''
              services.neru: only one of settings, config, or configFile may be set.
            '';
          }
        ];
      };
    };
in
{
  imports = [
    neruModule
    ./packages.nix
    ./paneru.nix
    ./ghostty.nix
    ./zotero.nix
    ./copy-apps.nix
    ./neru.nix
    ./chromium-module.nix
    ./zotero-module.nix
  ];
}
