{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.opencode-serve;

  isLoopbackHostname =
    cfg.hostname == "127.0.0.1"
    || cfg.hostname == "localhost"
    || cfg.hostname == "::1"
    || lib.hasSuffix ".localhost" cfg.hostname;

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

  serverArgs = [
    "serve"
    "--hostname"
    cfg.hostname
    "--port"
    (toString cfg.port)
  ]
  ++ cfg.extraArgs;

  workingDirectory =
    if cfg.workingDirectory != null then cfg.workingDirectory else config.home.homeDirectory;
in
{
  options.services.opencode-serve = {
    enable = lib.mkEnableOption "opencode background web server (loopback-only)";

    package = lib.mkPackageOption pkgs "opencode" { };

    port = lib.mkOption {
      type = lib.types.port;
      default = 4096;
      description = "Port for the opencode server. Bookmark http://opencode.localhost:<port>/ (`*.localhost` resolves to 127.0.0.1, no /etc/hosts edit needed).";
    };

    hostname = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Interface to bind. Must stay loopback-only; anything else would expose opencode to the local network.";
    };

    workingDirectory = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Directory the server runs in (opencode scopes to its working directory). Defaults to your home directory.";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "--cors https://example.com" ];
      description = "Extra arguments appended to `opencode serve`. Never add --hostname 0.0.0.0 or --mdns here.";
    };

    extraEnvironment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = {
        OPENCODE_SERVER_PASSWORD = "secret";
      };
      description = "Additional environment variables for the server (e.g. OPENCODE_SERVER_PASSWORD for basic auth).";
    };

    launchd = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to configure a launchd agent for opencode serve (darwin).";
      };
      keepAlive = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether the launchd service should be kept alive.";
      };
    };

    systemd = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to configure a systemd user service for opencode serve (linux).";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    assertions = [
      {
        assertion = isLoopbackHostname;
        message = "services.opencode-serve: hostname must be loopback-only (127.0.0.1, localhost, ::1, or *.localhost), got '${cfg.hostname}'. Refusing to bind opencode to the network.";
      }
    ];

    launchd.agents.opencode-serve = lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin && cfg.launchd.enable) {
      enable = true;
      config = {
        ProgramArguments = [ (lib.getExe cfg.package) ] ++ serverArgs;
        EnvironmentVariables = {
          PATH = defaultPath;
        }
        // cfg.extraEnvironment;
        WorkingDirectory = workingDirectory;
        RunAtLoad = true;
        KeepAlive = cfg.launchd.keepAlive;
        ProcessType = "Background";
        StandardOutPath = "${config.xdg.stateHome}/opencode/serve.stdout.log";
        StandardErrorPath = "${config.xdg.stateHome}/opencode/serve.stderr.log";
      };
    };

    systemd.user.services.opencode-serve =
      lib.mkIf (pkgs.stdenv.hostPlatform.isLinux && cfg.systemd.enable)
        {
          Unit = {
            Description = "opencode background web server (loopback-only)";
            After = [ "default.target" ];
            PartOf = [ "default.target" ];
          };
          Service = {
            ExecStart = lib.escapeShellArgs ([ (lib.getExe cfg.package) ] ++ serverArgs);
            Environment = [
              "PATH=${defaultPath}"
            ]
            ++ lib.mapAttrsToList (k: v: "${k}=${v}") cfg.extraEnvironment;
            WorkingDirectory = workingDirectory;
            Restart = "on-failure";
            RestartSec = 5;
          };
          Install = {
            WantedBy = [ "default.target" ];
          };
        };
  };
}
