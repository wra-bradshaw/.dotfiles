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

  reconcileInstance = name: instance: ''
    (
    export PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

    desired=${lib.escapeShellArg (toString instance.configFile)}
    instance_dir=${lib.escapeShellArg "${config.home.homeDirectory}/.lima/${name}"}
    state_dir=${lib.escapeShellArg "${config.xdg.stateHome}/home-manager/lima"}
    resolved="$state_dir/${name}.resolved.yaml"
    hash_file="$state_dir/${name}.sha256"
    immutable_hash_file="$state_dir/${name}.immutable.sha256"
    desired_hash="$(${pkgs.coreutils}/bin/sha256sum "$desired" | ${pkgs.coreutils}/bin/cut -d ' ' -f 1)"
    desired_immutable_hash="$(${lib.getExe pkgs.yq-go} -o=json '{"vmType": .vmType, "arch": .arch, "base": .base, "images": .images}' "$desired" | ${pkgs.coreutils}/bin/sha256sum | ${pkgs.coreutils}/bin/cut -d ' ' -f 1)"

    ${lib.getExe' cfg.package "limactl"} validate "$desired"
    ${pkgs.coreutils}/bin/mkdir -p "$state_dir"
    ${pkgs.coreutils}/bin/mkdir -p ${lib.escapeShellArg "${config.xdg.stateHome}/lima"}

    if [ ! -e "$instance_dir/lima.yaml" ]; then
      ${lib.getExe' cfg.package "limactl"} create --name ${lib.escapeShellArg name} --tty=false "$desired"
      printf '%s\n' "$desired_hash" > "$hash_file"
      printf '%s\n' "$desired_immutable_hash" > "$immutable_hash_file"
    elif [ ! -e "$hash_file" ] || [ "$(cat "$hash_file")" != "$desired_hash" ] \
      || ! ${lib.getExe' cfg.package "limactl"} validate "$instance_dir/lima.yaml" >/dev/null 2>&1; then
      if [ -e "$immutable_hash_file" ] && [ "$(cat "$immutable_hash_file")" != "$desired_immutable_hash" ]; then
        echo "Lima instance ${name} has immutable VM or image changes; recreate it explicitly." >&2
        exit 1
      fi

      ${lib.getExe' cfg.package "limactl"} validate --fill "$desired" > "$resolved"
      status="$(${lib.getExe' cfg.package "limactl"} list ${lib.escapeShellArg name} --format '{{.Status}}' 2>/dev/null || true)"
      if [ "$status" = Running ]; then
        ${lib.getExe' cfg.package "limactl"} stop ${lib.escapeShellArg name}
      fi
      ${pkgs.coreutils}/bin/install -m 0644 "$resolved" "$instance_dir/lima.yaml"
      printf '%s\n' "$desired_hash" > "$hash_file"
      printf '%s\n' "$desired_immutable_hash" > "$immutable_hash_file"
      if [ "$status" = Running ]; then
        ${lib.getExe' cfg.package "limactl"} start --tty=false ${lib.escapeShellArg name}
      fi
    fi
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
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile = lib.mapAttrs' (
      name: instance:
      lib.nameValuePair "lima/${name}.yaml" {
        source = instance.configFile;
      }
    ) enabledInstances;

    home.activation.limaInstances = lib.hm.dag.entryAfter [ "writeBoundary" ] (
      lib.concatStringsSep "\n" (lib.mapAttrsToList reconcileInstance enabledInstances)
    );

    launchd.agents = lib.mapAttrs' (
      name: instance:
      lib.nameValuePair "lima-${name}" {
        enable = instance.autostart;
        config = {
          Label = "io.lima-vm.autostart.${name}";
          ProgramArguments = [
            (lib.getExe' cfg.package "limactl")
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
