{ pkgs, config, ... }:
{
  nix = {
    linux-builder.enable = true;
    linux-builder.package = pkgs.darwin.linux-builder-x86_64;
    package = pkgs.nixVersions.latest;
    nixPath = [ { nixpkgs = "flake:nixpkgs"; } ];
    settings.trusted-users = [
      "@admin"
      "${config.username}"
    ];
    settings.experimental-features = "nix-command flakes";
    settings.extra-nix-path = "nixpkgs=flake:nixpkgs";
  };

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = 5;

  services.nix-daemon.enable = true;
}
