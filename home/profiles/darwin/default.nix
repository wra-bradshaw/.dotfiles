{ config, pkgs, ... }:
{
  imports = [
    ../../modules/cli
    ../../modules/cli/darwin
    ../../modules/gui
    ../../modules/gui/darwin
    ./home.nix
    ./packages.nix
  ];

  services.lima = {
    enable = true;
    instances.default = {
      autostart = true;
      settings = {
        base = [ "template:_images/ubuntu" ];
        vmType = "vz";
        arch = "aarch64";
        cpus = 4;
        memory = "4GiB";
        disk = "100GiB";
        mountType = "virtiofs";
        vmOpts.vz = {
          rosetta = {
            enabled = true;
            binfmt = true;
          };
        };
        mounts = [
          {
            location = config.home.homeDirectory;
            writable = true;
          }
        ];
        containerd = {
          system = false;
          user = true;
        };
      };
    };
  };

  programs.nixos-vm = {
    enable = true;
    configuration = "willnixos";
  };

  home.packages = [
    (pkgs.writeShellScriptBin "nerdctl" ''
      exec env LIMA_INSTANCE=default ${pkgs.lima}/bin/nerdctl.lima "$@"
    '')
    (pkgs.writeShellScriptBin "docker" ''
      exec env LIMA_INSTANCE=default ${pkgs.lima}/bin/nerdctl.lima "$@"
    '')
  ];
}
