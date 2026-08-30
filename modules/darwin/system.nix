{
  config,
  flake,
  lib,
  ...
}:
let
  inherit (flake) inputs;
in
{
  imports = [
    inputs.home-manager.darwinModules.home-manager
  ];

  options.username = lib.mkOption {
    type = lib.types.str;
    default = "will";
    description = "Primary user";
  };

  options.userHome = lib.mkOption {
    type = lib.types.str;
    default = "/Users/${config.username}";
    description = "Home directory of the primary user";
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
        inherit (inputs) nixpkgs;
        inherit (inputs) nix-colors;
      };
      users.${config.username} = {
        home = {
          inherit (config) username;
          homeDirectory = config.userHome;
        };
        imports = [
          inputs.nixvim.homeModules.nixvim
          inputs.nix-colors.homeManagerModules.default
          inputs.paneru.homeModules.paneru
          ../../home/profiles/darwin
        ];
      };
    };
  };
}
