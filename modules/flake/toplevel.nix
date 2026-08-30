{
  config,
  inputs,
  lib,
  ...
}:
{
  imports = [ inputs.nixos-unified.flakeModules.default ];

  systems = lib.mkForce [
    "aarch64-darwin"
    "aarch64-linux"
  ];

  flake = {
    darwinConfigurations.willmb = config.flake.nixos-unified.lib.mkMacosSystem {
      home-manager = true;
    } ../../configurations/darwin/willmb.nix;
    nixosConfigurations.willnixos = config.flake.nixos-unified.lib.mkLinuxSystem {
      home-manager = true;
    } ../../configurations/nixos/willnixos.nix;

    darwinModules = {
      app-overlays = ../darwin/app-overlays.nix;
      helium-web-apps = ../darwin/helium-web-apps.nix;
      solar-wallpaper = ../darwin/solar-wallpaper.nix;
      system = ../darwin/system.nix;
    };
    nixosModules = {
      niri-workstation = ../nixos/niri-workstation.nix;
      system = ../nixos/system.nix;
    };
    overlays = {
      active = import ../../overlays/active.nix { inherit inputs; };
      annas-mcp = import ../../overlays/annas-mcp.nix { };
      apfel-llm = import ../../overlays/apfel-llm.nix { };
      helium = import ../../overlays/helium.nix { };
      opencode = import ../../overlays/opencode.nix { };
    };
  };

  perSystem =
    {
      pkgs,
      self',
      ...
    }:
    {
      formatter = pkgs.nixfmt-tree;
      devShells.default = pkgs.mkShellNoCC {
        packages = with pkgs; [
          deadnix
          nixd
          nixfmt
          statix
        ];
      };
      packages.default = self'.packages.activate;
    };
}
