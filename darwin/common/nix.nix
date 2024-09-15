{ pkgs, config, ... }:
{
  nix = {
    package = pkgs.nixVersions.latest;
    nixPath = [ { nixpkgs = "flake:nixpkgs"; } ];
    settings.trusted-users = [
      "@admin"
      "${config.username}"
    ];
    settings.experimental-features = "nix-command flakes";
    settings.extra-nix-path = "nixpkgs=flake:nixpkgs";
  };

  services.nix-daemon.enable = true;
}
