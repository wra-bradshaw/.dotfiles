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
  imports = [
    inputs.home-manager.darwinModules.home-manager
    ../../darwin/common
  ];

  options.username = lib.mkOption {
    type = lib.types.str;
    default = "will";
    description = "Primary user";
  };

  config = {
    nixpkgs.overlays = [
      inputs.brew-nix.overlays.default
      inputs.neru.overlays.default
      (import ../../overlays/active.nix { inherit inputs; })
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
        inputs.paneru.homeModules.paneru
        inputs.neru.homeManagerModules.default
        ../../home/profiles/darwin
      ];
    };
  };
}
