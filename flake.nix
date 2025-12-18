{
  description = "System Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-colors.url = "github:misterio77/nix-colors";

    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "nixpkgs";

    brew-nix = {
      url = "github:BatteredBunny/brew-nix";
      inputs.brew-api.follows = "brew-api";
    };
    brew-api = {
      url = "github:BatteredBunny/brew-api";
      flake = false;
    };

    nixvim.url = "github:nix-community/nixvim";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.3.0";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      forAllSupportedSystems = import ./lib/forAllSupportedSystems.nix {
        inherit nixpkgs supportedSystems;
      };

      overlays = import ./overlays {
        nur = inputs.nur;
        brew-nix = inputs.brew-nix;
      };

      homeManagerModules = [
        inputs.nixvim.homeModules.nixvim
        inputs.nix-colors.homeManagerModules.default
      ];

      homeManagerModulesDarwin = [
        inputs.sops-nix.homeManagerModules.sops
      ]
      ++ homeManagerModules;

      homeManagerModulesLinux = [
        inputs.xremap-flake.homeManagerModules.default
        inputs.nix-flatpak.homeManagerModules.nix-flatpak
      ]
      ++ homeManagerModules;

      homeSharedModulesLinux = [ inputs.sops-nix.homeManagerModules.sops ];

      homeManagerExtraSpecialArgs = {
        nixpkgs = nixpkgs;
        nix-colors = inputs.nix-colors;
      };

      homeManagerExtraSpecialArgsLinux = {
        xremap-flake = inputs.xremap-flake;
      };

      homeManagerExtraSpecialArgsDarwin = {
        sops-nix = inputs.sops-nix;
      };

      darwinModules = [
        inputs.sops-nix.darwinModules.sops
        {
          nixpkgs.overlays = overlays;
        }
        ./nixpkgs.nix
      ];

      darwinSpecialArgs = { };

      nixosModules = [
        {
          nixpkgs.overlays = overlays;
        }
        inputs.sops-nix.nixosModules.sops
        inputs.nur.modules.nixos.default
        inputs.nix-flatpak.nixosModules.nix-flatpak
        ./nixpkgs.nix
      ];

      nixosSpecialArgs = { };
    in
    {
      devShells = forAllSupportedSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = [
              (pkgs.writeShellScriptBin "apply-nixos" ''
                set -euox pipefail
                pushd ~/.dotfiles
                sudo nixos-rebuild switch --log-format internal-json -v --upgrade --flake .#$1 |& ${pkgs.nix-output-monitor}/bin/nom --json
                popd
              '')

              (pkgs.writeShellScriptBin "apply-darwin" ''
                set -euox pipefail
                pushd ~/.dotfiles
                sudo ${
                  inputs.nix-darwin.packages.${system}.darwin-rebuild
                }/bin/darwin-rebuild switch --show-trace --flake ".#$1"
                popd
              '')

            ];
          };
        }
      );

      darwinConfigurations = {
        macbook = inputs.nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = darwinSpecialArgs;
          modules = [
            ./darwin/macbook
            inputs.home-manager.darwinModules.home-manager
            (
              { config, ... }:
              {
                home-manager = {
                  useUserPackages = true;
                  useGlobalPkgs = true;
                  extraSpecialArgs = homeManagerExtraSpecialArgs // homeManagerExtraSpecialArgsDarwin;
                  users.${config.username}.imports = [
                    ./home/hosts/macbook
                    (
                      { pkgs, ... }:
                      {
                        options.username =
                          with pkgs.lib;
                          mkOption {
                            type = types.str;
                            default = config.username;
                            description = "The username of the user";
                          };
                      }
                    )
                  ]
                  ++ homeManagerModulesDarwin;
                };
              }
            )
          ]
          ++ darwinModules;
        };

        macbookair = inputs.nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = darwinSpecialArgs;
          modules = [
            ./darwin/macbookair
            inputs.home-manager.darwinModules.home-manager
            (
              { config, ... }:
              {
                home-manager = {
                  useUserPackages = true;
                  useGlobalPkgs = true;
                  extraSpecialArgs = homeManagerExtraSpecialArgs // homeManagerExtraSpecialArgsDarwin;
                  users.${config.username}.imports = [
                    ./home/hosts/macbookair
                    (
                      { pkgs, ... }:
                      {
                        options.username =
                          with pkgs.lib;
                          mkOption {
                            type = types.str;
                            default = config.username;
                            description = "The username of the user";
                          };
                      }
                    )
                  ]
                  ++ homeManagerModulesDarwin;
                };
              }
            )
          ]
          ++ darwinModules;
        };
      };

      nixosConfigurations = {
        server = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = nixosSpecialArgs;
          modules = [
            ./nixos/server
          ]
          ++ nixosModules;
        };
      };
    };
}
