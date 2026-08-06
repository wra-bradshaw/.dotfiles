{
  config,
  flake,
  lib,
  pkgs,
  ...
}:
let
  inherit (flake) inputs;
in
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  options.username = lib.mkOption {
    type = lib.types.str;
    default = "will";
    description = "Primary user";
  };

  config = {
    nixpkgs = {
      config.allowUnfree = true;
      overlays = [ (import ../../overlays/active.nix { inherit inputs; }) ];
    };

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

    networking.networkmanager.enable = true;
    time.timeZone = "Australia/Melbourne";
    i18n.defaultLocale = "en_AU.UTF-8";

    users.users.${config.username} = {
      isNormalUser = true;
      description = "Will";
      shell = pkgs.zsh;
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
    };
    programs.zsh.enable = true;
    security.sudo.wheelNeedsPassword = false;

    services = {
      openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
        };
      };
    };
    virtualisation.containerd.enable = true;

    programs.niri.enable = true;
    services.greetd = {
      enable = true;
      settings.initial_session = {
        command = "${config.programs.niri.package}/bin/niri-session";
        user = config.username;
      };
      settings.default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${config.programs.niri.package}/bin/niri-session";
        user = "greeter";
      };
    };
    systemd.user.services.niri.enableDefaultPath = false;

    security.polkit.enable = true;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.swaylock = { };
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config.niri."org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
    };

    environment.systemPackages = with pkgs; [
      ghostty
      fuzzel
      waybar
      mako
      swayidle
      swaylock
      swaybg
      xwayland-satellite
      wl-clipboard
      grim
      slurp
      brightnessctl
      playerctl
      pavucontrol
      helium
      nerdctl
      buildkit
      cni-plugins
    ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "home-manager-backup";
      extraSpecialArgs = {
        inherit flake;
        nixpkgs = inputs.nixpkgs;
        nix-colors = inputs.nix-colors;
      };
      users.${config.username}.imports = [
        inputs.nixvim.homeModules.nixvim
        inputs.nix-colors.homeManagerModules.default
        ../../home/profiles/niri
      ];
    };
  };
}
