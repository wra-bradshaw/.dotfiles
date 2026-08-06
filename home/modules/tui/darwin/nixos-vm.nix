{
  config,
  lib,
  pkgs,
  ...
}:
let
  flakeDir = "${config.home.homeDirectory}/.dotfiles";
  instanceName = "nixos";
  template = (pkgs.formats.yaml { }).generate "lima-nixos.yaml" {
    vmType = "vz";
    os = "Linux";
    arch = "aarch64";
    cpus = 4;
    memory = "8GiB";
    disk = "100GiB";
    mountType = "virtiofs";
    mounts = [
      {
        location = config.home.homeDirectory;
        mountPoint = "/mnt/host";
        writable = false;
      }
    ];
    containerd = {
      system = false;
      user = false;
    };
    video.display = "vz";
    audio.device = "vz";
    user.name = config.home.username;
    images = [
      {
        location = "@IMAGE@";
        arch = "aarch64";
      }
    ];
  };

  nixosVm = pkgs.writeShellApplication {
    name = "nixos-vm";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.findutils
      pkgs.gnugrep
      pkgs.lima
      pkgs.nix
      pkgs.gnused
    ];
    text = ''
      set -euo pipefail
      export PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

      instance=${lib.escapeShellArg instanceName}
      flake_dir=${lib.escapeShellArg flakeDir}

      exists() {
        limactl list "$instance" --format '{{.Name}}' 2>/dev/null | grep -qx "$instance"
      }

      create() {
        if exists; then
          echo "Lima instance $instance already exists"
          return
        fi

        image_out=$(nix build \
          "$flake_dir#nixosConfigurations.willnixos.config.system.build.images.lima" \
          --no-link --print-out-paths)
        image=$(find "$image_out" -type f -name '*.qcow2' -print -quit)
        if [ -z "$image" ]; then
          echo "No qcow2 image found in $image_out" >&2
          exit 1
        fi

        rendered=$(mktemp -t lima-nixos.XXXXXX.yaml)
        trap 'rm -f "$rendered"' RETURN
        sed "s|@IMAGE@|$image|" ${template} > "$rendered"
        limactl validate "$rendered"
        limactl create --name "$instance" --tty=false "$rendered"
        rm -f "$rendered"
        trap - RETURN
      }

      command="''${1:-start}"
      case "$command" in
        create)
          create
          ;;
        start)
          create
          limactl start --tty=false "$instance"
          ;;
        stop)
          limactl stop "$instance"
          ;;
        rebuild)
          create
          limactl start --tty=false "$instance"
          limactl shell "$instance" -- \
            sudo nixos-rebuild switch --flake /mnt/host/.dotfiles#willnixos
          ;;
        recreate)
          if exists; then
            printf 'Delete and recreate Lima instance %s? [y/N] ' "$instance"
            read -r answer
            case "$answer" in
              y|Y|yes|YES) ;;
              *) echo "Cancelled"; exit 1 ;;
            esac
            limactl stop "$instance" 2>/dev/null || true
            limactl delete --force "$instance"
          fi
          create
          ;;
        *)
          echo "usage: nixos-vm create|start|stop|rebuild|recreate" >&2
          exit 2
          ;;
      esac
    '';
  };
in
{
  home.packages = [ nixosVm ];
  xdg.configFile."lima/nixos.template.yaml".source = template;
}
