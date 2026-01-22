{
  nixpkgs,
  config,
  pkgs,
  ...
}:
{
  nix = {
    registry.nixpkgs.flake = nixpkgs;
  };
  home.file = {
    ".config/nix/nix.conf".text = ''
      !include ${config.sops.secrets.github.path}
    '';
  };
}
