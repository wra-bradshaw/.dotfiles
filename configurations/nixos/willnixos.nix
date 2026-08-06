{
  flake,
  lib,
  modulesPath,
  pkgs,
  ...
}:
let
  hostHome = "/Users/will";
  hostMount = "/mnt/host";
  mountHash = builtins.hashString "sha256" "${hostHome}:${hostMount}";
  mountTag = "lima-${builtins.substring 0 16 mountHash}";
in
{
  imports = [
    flake.inputs.self.nixosModules.system
    flake.inputs.self.nixosModules.niri-workstation
  ];

  nixpkgs.hostPlatform = "aarch64-linux";
  networking.hostName = "willnixos";
  username = "will";
  system.stateVersion = "26.05";

  boot = {
    initrd.availableKernelModules = [
      "virtio_pci"
      "virtio_blk"
      "virtio_scsi"
      "virtio_gpu"
      "virtio_input"
      "virtiofs"
      "xhci_pci"
    ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  time.timeZone = "Australia/Melbourne";
  i18n.defaultLocale = "en_AU.UTF-8";
  security.sudo.wheelNeedsPassword = false;
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
  virtualisation.containerd.enable = true;
  environment.systemPackages = with pkgs; [
    nerdctl
    buildkit
    cni-plugins
  ];

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
