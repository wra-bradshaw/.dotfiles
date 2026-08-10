{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.lima;
  yaml = pkgs.formats.yaml { };

  instanceType = lib.types.submodule (
    { name, config, ... }:
    {
      options = {
        autostart = lib.mkEnableOption "starting the Lima instance at login";
        settings = lib.mkOption {
          inherit (yaml) type;
          default = { };
          description = "Lima YAML configuration for the instance.";
        };
        configFile = lib.mkOption {
          type = lib.types.path;
          readOnly = true;
          default = yaml.generate "lima-${name}.yaml" config.settings;
          description = "Generated and validated Lima configuration.";
        };
      };
    }
  );

  enabledInstances = cfg.instances;
  enabledInstanceNames = lib.attrNames enabledInstances;

  limaAutostart = pkgs.writeShellScript "lima-autostart" ''
    unset SSH_AUTH_SOCK
    if [ "''${1:-}" = start ] && [ -n "''${2:-}" ]; then
      ready=${lib.escapeShellArg "${config.home.homeDirectory}/.lima"}/"$2"/.home-manager-ready
      while [ ! -e "$ready" ]; do
        sleep 1
      done
    fi
    exec ${lib.getExe' cfg.package "limactl"} "$@"
  '';

  reconcileInstance = name: instance: ''
    (
    export PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
    unset SSH_AUTH_SOCK

    desired=${lib.escapeShellArg (toString instance.configFile)}
    instance_dir=${lib.escapeShellArg "${config.home.homeDirectory}/.lima/${name}"}
    state_dir=${lib.escapeShellArg "${config.xdg.stateHome}/home-manager/lima"}
    hash_file="$state_dir/${name}.sha256"
    immutable_hash_file="$state_dir/${name}.immutable.sha256"
    ready_file="$instance_dir/.home-manager-ready"
    desired_hash="$(${pkgs.coreutils}/bin/sha256sum "$desired" | ${pkgs.coreutils}/bin/cut -d ' ' -f 1)"
    desired_immutable_hash="$(${lib.getExe pkgs.yq-go} -o=json '{"vmType": .vmType, "arch": .arch, "base": .base, "images": .images}' "$desired" | ${pkgs.coreutils}/bin/sha256sum | ${pkgs.coreutils}/bin/cut -d ' ' -f 1)"

    ${lib.getExe' cfg.package "limactl"} validate "$desired"
    ${pkgs.coreutils}/bin/mkdir -p "$state_dir"
    ${pkgs.coreutils}/bin/mkdir -p ${lib.escapeShellArg "${config.xdg.stateHome}/lima"}

    if [ ! -e "$instance_dir/lima.yaml" ]; then
      ${lib.getExe' cfg.package "limactl"} create --name ${lib.escapeShellArg name} --tty=false "$desired"
      printf '%s\n' "$desired_hash" > "$hash_file"
      printf '%s\n' "$desired_immutable_hash" > "$immutable_hash_file"
    elif [ ! -e "$hash_file" ] || [ "$(cat "$hash_file")" != "$desired_hash" ]; then
      echo "Lima instance ${name} differs from its declarative configuration; recreate it explicitly with 'limactl delete ${name}' and reactivate." >&2
      exit 1
    fi
    ${pkgs.coreutils}/bin/touch "$ready_file"
    )
  '';
in
{
  options.services.lima = {
    enable = lib.mkEnableOption "Lima virtual machines";
    package = lib.mkPackageOption pkgs "lima" { };
    instances = lib.mkOption {
      type = lib.types.attrsOf instanceType;
      default = { };
      description = "Declaratively managed Lima instances.";
    };
    stopRemovedInstances = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Stop previously managed instances after they are removed from services.lima.instances.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    programs.zsh.shellAliases.limactl = "env -u SSH_AUTH_SOCK limactl";

    xdg.configFile = lib.mapAttrs' (
      name: instance:
      lib.nameValuePair "lima/${name}.yaml" {
        source = instance.configFile;
      }
    ) enabledInstances;

    home.activation.limaInstances = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      state_dir=${lib.escapeShellArg "${config.xdg.stateHome}/home-manager/lima"}
      ${pkgs.coreutils}/bin/mkdir -p "$state_dir"

      ${lib.optionalString cfg.stopRemovedInstances ''
        for hash_file in "$state_dir"/*.sha256; do
          [ -e "$hash_file" ] || continue
          case "$hash_file" in *.immutable.sha256) continue ;; esac
          instance_name="''${hash_file##*/}"
          instance_name="''${instance_name%.sha256}"
          case " ${lib.concatStringsSep " " enabledInstanceNames} " in
            *" $instance_name "*) continue ;;
          esac
          if [ "$(${lib.getExe' cfg.package "limactl"} list "$instance_name" --format '{{.Status}}' 2>/dev/null || true)" = Running ]; then
            env -u SSH_AUTH_SOCK ${lib.getExe' cfg.package "limactl"} stop "$instance_name"
          fi
          rm -f "$state_dir/$instance_name.sha256" "$state_dir/$instance_name.immutable.sha256" "$state_dir/$instance_name.resolved.yaml"
        done
      ''}

      ${lib.concatStringsSep "\n" (lib.mapAttrsToList reconcileInstance enabledInstances)}
    '';

    launchd.agents = lib.mapAttrs' (
      name: instance:
      lib.nameValuePair "lima-${name}" {
        enable = instance.autostart;
        config = {
          Label = "io.lima-vm.autostart.${name}";
          ProgramArguments = [
            (toString limaAutostart)
            "start"
            name
            "--foreground"
          ];
          RunAtLoad = true;
          ProcessType = "Background";
          EnvironmentVariables.PATH = "/usr/bin:/bin:/usr/sbin:/sbin";
          WorkingDirectory = "${config.home.homeDirectory}/.lima/${name}";
          StandardOutPath = "${config.xdg.stateHome}/lima/${name}.stdout.log";
          StandardErrorPath = "${config.xdg.stateHome}/lima/${name}.stderr.log";
        };
      }
    ) (lib.filterAttrs (_: instance: instance.autostart) enabledInstances);
  };
}
