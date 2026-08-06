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

  options.userHome = lib.mkOption {
    type = lib.types.str;
    default = "/home/${config.username}";
    description = "Home directory of the primary user";
  };

  config = {
    nixpkgs = {
      config.allowUnfree = true;
      overlays = [ (import ../../overlays/active.nix { inherit inputs; }) ];
    };

    users.users.${config.username} = {
      isNormalUser = true;
      description = config.username;
      home = config.userHome;
      shell = pkgs.zsh;
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
    };
    programs.zsh.enable = true;

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
          ../../home/profiles/niri
        ];
      };
    };
  };
}
