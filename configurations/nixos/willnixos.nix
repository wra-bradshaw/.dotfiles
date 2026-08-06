{
  flake,
  lib,
  modulesPath,
  ...
}:
let
  hostHome = "/Users/will";
  hostMount = "/mnt/host";
  mountHash = builtins.hashString "sha256" "${hostHome}:${hostMount}";
  mountTag = "lima-${builtins.substring 0 16 mountHash}";
in
{
  imports = [ flake.inputs.self.nixosModules.system ];

  nixpkgs.hostPlatform = "aarch64-linux";
  networking.hostName = "willnixos";
  system.stateVersion = "26.05";

  image.modules.lima = {
    imports = [ "${modulesPath}/virtualisation/disk-image.nix" ];

    image = {
      baseName = "willnixos-lima";
      format = "qcow2";
      efiSupport = true;
    };
    virtualisation.diskSize = 80 * 1024;
    boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
    services.cloud-init.enable = true;

    fileSystems.${hostMount} = {
      device = mountTag;
      fsType = "virtiofs";
      options = [
        "ro"
        "nofail"
        "x-systemd.automount"
      ];
    };
  };
}
