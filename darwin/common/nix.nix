{ pkgs, config, ... }:
{
  nix.enable = false;

  environment.etc."nix/nix.custom.conf".text = ''
    !include ${config.sops.secrets.github.path}
  '';

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken = true;

  system.stateVersion = 5;
}
